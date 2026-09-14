# Ensure PostgreSQL and Redis Docker containers are running for ProjectHub
$ErrorActionPreference = "Stop"

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

if (-not (Test-CommandExists "docker")) {
    Write-Error "[Docker] 'docker' CLI is not found in PATH. Please install Docker Desktop and ensure it is in your PATH."
    exit 1
}

# Verify Docker daemon is running
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "[Docker] Docker daemon is not running. Please start Docker Desktop before launching ProjectHub."
    exit 1
}

function Ensure-Container {
    param(
        [string]$Name,
        [string]$Image,
        [string[]]$Ports,
        [hashtable]$EnvVars = @{}
    )

    $state = docker inspect -f "{{.State.Running}}" $Name 2>$null

    if ($state -eq "true") {
        Write-Host "[Docker] Container '$Name' is already running." -ForegroundColor Green
        return
    }

    if ($state -eq "false") {
        Write-Host "[Docker] Container '$Name' exists but is stopped. Starting..." -ForegroundColor Yellow
        docker start $Name | Out-Null
        Write-Host "[Docker] Container '$Name' started successfully." -ForegroundColor Green
        return
    }

    # Container does not exist, create and run it
    Write-Host "[Docker] Container '$Name' not found. Creating and starting container with image '$Image'..." -ForegroundColor Cyan

    $argList = @("run", "-d", "--name", $Name)
    foreach ($p in $Ports) {
        $argList += @("-p", $p)
    }
    foreach ($key in $EnvVars.Keys) {
        $argList += @("-e", "$key=$($EnvVars[$key])")
    }
    $argList += $Image

    docker @argList | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "[Docker] Failed to start container '$Name'."
        exit 1
    }

    Write-Host "[Docker] Container '$Name' created and started successfully." -ForegroundColor Green
}

# 1. PostgreSQL container
Ensure-Container `
    -Name "projecthub-postgres" `
    -Image "postgres:16-alpine" `
    -Ports @("5432:5432") `
    -EnvVars @{
        "POSTGRES_DB"       = "ProjectHubDb"
        "POSTGRES_USER"     = "postgres"
        "POSTGRES_PASSWORD" = "postgres"
    }

# 2. Redis container
Ensure-Container `
    -Name "projecthub-redis" `
    -Image "redis:7-alpine" `
    -Ports @("6379:6379")

Write-Host "[Docker] All infrastructure services (PostgreSQL + Redis) are operational." -ForegroundColor Green
