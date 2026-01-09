#!/bin/bash
# Database migration runner with safety checks
# Usage: ./migration-runner.sh <up|down|status> [environment]

set -euo pipefail

ACTION="${1:-status}"
ENV="${2:-dev}"

DB_URL="${DATABASE_URL:-}"

if [ -z "$DB_URL" ]; then
    case "$ENV" in
        dev)     DB_URL="postgresql://postgres:localpass@localhost:5432/appdb" ;;
        staging) DB_URL=$(aws secretsmanager get-secret-value --secret-id staging/db --query SecretString --output text) ;;
        prod)    DB_URL=$(aws secretsmanager get-secret-value --secret-id prod/db --query SecretString --output text) ;;
        *) echo "Unknown env: $ENV"; exit 1 ;;
    esac
fi

echo "=== Database Migration ==="
echo "Environment: $ENV"
echo "Action: $ACTION"
echo ""

case "$ACTION" in
    up)
        echo "Running migrations..."
        alembic upgrade head
        echo "Migrations applied successfully."
        ;;
    down)
        if [ "$ENV" = "prod" ]; then
            echo "WARNING: Rolling back production database!"
            read -p "Type 'CONFIRM' to proceed: " confirm
            [ "$confirm" != "CONFIRM" ] && echo "Aborted." && exit 1
        fi
        alembic downgrade -1
        echo "Rolled back 1 migration."
        ;;
    status)
        alembic current
        echo ""
        echo "Pending migrations:"
        alembic heads
        ;;
    *)
        echo "Usage: $0 <up|down|status> [dev|staging|prod]"
        exit 1
        ;;
esac
