# Build all projects in the monorepo
$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1/2 Building .NET Server..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
dotnet build "$PSScriptRoot/../server/ProjectHub.Api.sln"

if ($LASTEXITCODE -ne 0) {
    Write-Error ".NET Server build failed!"
    exit $LASTEXITCODE
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "2/2 Checking Flutter Client..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Push-Location "$PSScriptRoot/../client"
try {
    flutter pub get
    flutter analyze
}
finally {
    Pop-Location
}

Write-Host "`nAll projects built and analyzed successfully! 🎉" -ForegroundColor Green

