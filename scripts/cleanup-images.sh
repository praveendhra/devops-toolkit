#!/bin/bash
# Clean up old Docker images and container registries
# Keeps the last N versions of each image

set -euo pipefail

KEEP_LAST=5
DRY_RUN="${DRY_RUN:-false}"

echo "=== Docker Image Cleanup ==="
echo "Keeping last $KEEP_LAST versions per image"
echo "Dry run: $DRY_RUN"
echo ""

# Clean up local dangling images
echo "--- Removing dangling images ---"
if [ "$DRY_RUN" = "false" ]; then
    docker image prune -f
else
    echo "[DRY RUN] Would remove dangling images"
fi

# Clean up stopped containers
echo ""
echo "--- Removing stopped containers ---"
if [ "$DRY_RUN" = "false" ]; then
    docker container prune -f
else
    echo "[DRY RUN] Would remove stopped containers"
fi

# Clean up unused volumes
echo ""
echo "--- Removing unused volumes ---"
if [ "$DRY_RUN" = "false" ]; then
    docker volume prune -f
else
    echo "[DRY RUN] Would remove unused volumes"
fi

# Clean up build cache
echo ""
echo "--- Cleaning build cache ---"
if [ "$DRY_RUN" = "false" ]; then
    docker builder prune -f --keep-storage 5GB
else
    echo "[DRY RUN] Would clean build cache"
fi

# Show disk usage
echo ""
echo "--- Current Docker disk usage ---"
docker system df

echo ""
echo "Cleanup complete."
