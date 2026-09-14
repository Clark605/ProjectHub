# Stop PostgreSQL and Redis Docker containers for ProjectHub
$ErrorActionPreference = "SilentlyContinue"

Write-Host "Stopping ProjectHub Docker containers..." -ForegroundColor Yellow

$containers = @("projecthub-postgres", "projecthub-redis")
foreach ($c in $containers) {
    $running = docker inspect -f "{{.State.Running}}" $c 2>$null
    if ($running -eq "true") {
        Write-Host "Stopping '$c'..." -ForegroundColor Cyan
        docker stop $c | Out-Null
        Write-Host "Stopped '$c'." -ForegroundColor Green
    } else {
        Write-Host "'$c' is not running." -ForegroundColor Gray
    }
}

Write-Host "All ProjectHub containers stopped." -ForegroundColor Green
