#!/usr/bin/env bash
# Stop PostgreSQL and Redis Docker containers for ProjectHub

echo "Stopping ProjectHub Docker containers..."

containers=("projecthub-postgres" "projecthub-redis")
for c in "${containers[@]}"; do
    state=$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null || true)
    if [ "$state" = "true" ]; then
        echo "Stopping '$c'..."
        docker stop "$c" >/dev/null
        echo "Stopped '$c'."
    else
        echo "'$c' is not running."
    fi
done

echo "All ProjectHub containers stopped."
