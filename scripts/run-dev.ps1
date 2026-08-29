# Run both .NET Server and Flutter Client for local development
$ErrorActionPreference = "Stop"

Write-Host "Starting .NET API in a new window..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Starting .NET API...' -ForegroundColor Cyan; cd '$PSScriptRoot/../server/ProjectHub.Api'; dotnet watch run"

Write-Host "Launching Flutter Client..." -ForegroundColor Cyan
Push-Location "$PSScriptRoot/../client"
try {
    flutter run
}
finally {
    Pop-Location
}

