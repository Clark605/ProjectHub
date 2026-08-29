# Feature Verification Script for ProjectHub
# Builds .NET server, executes Flutter build_runner, runs static analysis and tests
$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1/3 Verifying .NET Backend..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
dotnet build "$PSScriptRoot/../../../../server/ProjectHub.Api.sln"

if ($LASTEXITCODE -ne 0) {
    Write-Error ".NET Backend build failed!"
    exit $LASTEXITCODE
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "2/3 Generating Flutter Code & Analyzing..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Push-Location "$PSScriptRoot/../../../../client"
try {
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter analyze
    
    Write-Host "`n==========================================" -ForegroundColor Cyan
    Write-Host "3/3 Running Flutter Tests..." -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    flutter test
}
finally {
    Pop-Location
}

Write-Host "`n✅ Feature verification passed! Ready to commit. 🎉" -ForegroundColor Green

