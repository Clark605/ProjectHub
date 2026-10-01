# Starts Cloudflare Quick Tunnel and automatically updates API_BASE_URL in .env
param(
    [int]$Port = 5259
)

$cloudflared = "$PSScriptRoot\tools\cloudflared.exe"
$envPath = "$PSScriptRoot\..\.env"

if (-not (Test-Path $cloudflared)) {
    Write-Error "cloudflared.exe not found at $cloudflared. Please make sure the tool exists."
    exit 1
}

function Update-EnvFile([string]$path, [string]$url) {
    if (-not (Test-Path $path)) {
        "API_BASE_URL=$url" | Out-File -FilePath $path -Encoding utf8
        return
    }

    $content = [System.IO.File]::ReadAllText($path)
    if ($content -match '(?m)^API_BASE_URL=.*$') {
        $updated = $content -replace '(?m)^API_BASE_URL=.*$', "API_BASE_URL=$url"
    } else {
        $updated = $content.TrimEnd() + "`r`nAPI_BASE_URL=$url`r`n"
    }
    [System.IO.File]::WriteAllText($path, $updated)
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Starting Cloudflare Tunnel & Auto-Syncing .env" -ForegroundColor Cyan
Write-Host " Target Backend: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Connecting to Cloudflare edge network...`n" -ForegroundColor Yellow

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $cloudflared
$psi.Arguments = "tunnel --url http://localhost:$Port"
$psi.RedirectStandardError = $true
$psi.RedirectStandardOutput = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true

$proc = [System.Diagnostics.Process]::Start($psi)

$urlFound = $false

# Cleanup handler on exit or Ctrl+C
$cleanup = {
    if ($proc -and -not $proc.HasExited) {
        Write-Host "`nStopping Cloudflare Tunnel..." -ForegroundColor Yellow
        $proc.Kill()
    }
}
Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $cleanup | Out-Null

try {
    while (-not $proc.HasExited) {
        $line = $proc.StandardError.ReadLine()
        if ($null -eq $line) { break }

        # Check for generated trycloudflare.com URL
        if (-not $urlFound -and $line -match 'https://[a-zA-Z0-9-]+\.trycloudflare\.com') {
            $tunnelUrl = $matches[0]
            $urlFound = $true

            # Automatically update .env
            Update-EnvFile -path $envPath -url $tunnelUrl

            Write-Host "`n==========================================================================" -ForegroundColor Green
            Write-Host " [SUCCESS] Cloudflare Tunnel Connected!" -ForegroundColor Green
            Write-Host " Public URL : $tunnelUrl" -ForegroundColor Cyan
            Write-Host " Auto-Sync  : Updated 'API_BASE_URL' in .env automatically!" -ForegroundColor Green
            Write-Host "==========================================================================`n" -ForegroundColor Green
            Write-Host "Traffic is streaming. Press Ctrl+C at any time to stop.`n" -ForegroundColor DarkGray
        }

        # Print informational lines cleanly
        if ($line -match 'INF' -or $line -match 'ERR') {
            Write-Host $line -ForegroundColor DarkGray
        }
    }
}
finally {
    & $cleanup
}
