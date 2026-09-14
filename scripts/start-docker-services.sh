#!/usr/bin/env bash
# Ensure PostgreSQL and Redis Docker containers are running for ProjectHub
set -e

if ! command -v docker &> /dev/null; then
    echo "[Docker] 'docker' CLI is not found in PATH. Please install Docker and ensure it is in your PATH." >&2
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "[Docker] Docker daemon is not running. Please start Docker before launching ProjectHub." >&2
    exit 1
fi

ensure_container() {
    local name="$1"
    local run_cmd="$2"

    local state
    state=$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null || true)

    if [ "$state" = "true" ]; then
        echo "[Docker] Container '$name' is already running."
    elif [ "$state" = "false" ]; then
        echo "[Docker] Container '$name' exists but is stopped. Starting..."
        docker start "$name" >/dev/null
        echo "[Docker] Container '$name' started successfully."
    else
        echo "[Docker] Container '$name' not found. Creating and starting..."
        eval "$run_cmd" >/dev/null
        echo "[Docker] Container '$name' created and started successfully."
    fi
}

# 1. PostgreSQL container
ensure_container "projecthub-postgres" "docker run -d --name projecthub-postgres -p 5432:5432 -e POSTGRES_DB=ProjectHubDb -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres postgres:16-alpine"

# 2. Redis container
ensure_container "projecthub-redis" "docker run -d --name projecthub-redis -p 6379:6379 redis:7-alpine"

echo "[Docker] All infrastructure services (PostgreSQL + Redis) are operational."
