# Run test coverage for server and client in the monorepo
$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1/2 Running .NET Server Tests with Coverage..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
dotnet test "$PSScriptRoot/../server/ProjectHub.Api.sln" --configuration Release --collect:"XPlat Code Coverage" --results-directory "$PSScriptRoot/../server/coverage"

if ($LASTEXITCODE -ne 0) {
    Write-Error ".NET Server tests failed!"
    exit $LASTEXITCODE
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "2/2 Running Flutter Client Tests with Coverage..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Push-Location "$PSScriptRoot/../client"
try {
    flutter test --coverage
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Flutter client tests failed!"
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}

Write-Host "`nAll tests passed and code coverage collected successfully! 🎉" -ForegroundColor Green
