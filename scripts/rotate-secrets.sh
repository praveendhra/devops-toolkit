#!/bin/bash
# Rotate secrets in AWS Secrets Manager and restart services
# Usage: ./rotate-secrets.sh <secret-name> <ecs-cluster> <ecs-service>

set -euo pipefail

SECRET_NAME="$1"
ECS_CLUSTER="${2:-}"
ECS_SERVICE="${3:-}"

echo "[$(date)] Starting secret rotation for: $SECRET_NAME"

# Generate new secret value
NEW_SECRET=$(openssl rand -base64 32)

# Update in AWS Secrets Manager
aws secretsmanager put-secret-value \
    --secret-id "$SECRET_NAME" \
    --secret-string "$NEW_SECRET"

echo "[$(date)] Secret updated in Secrets Manager"

# Force ECS service to pull new secret
if [ -n "$ECS_CLUSTER" ] && [ -n "$ECS_SERVICE" ]; then
    echo "[$(date)] Forcing ECS service restart..."
    aws ecs update-service \
        --cluster "$ECS_CLUSTER" \
        --service "$ECS_SERVICE" \
        --force-new-deployment

    echo "[$(date)] Waiting for service stability..."
    aws ecs wait services-stable \
        --cluster "$ECS_CLUSTER" \
        --services "$ECS_SERVICE"
fi

echo "[$(date)] Secret rotation complete."
