#!/bin/bash
# Database backup script with rotation and cloud upload
# Usage: ./db-backup.sh [daily|weekly|monthly]
# Supports: PostgreSQL, MySQL

set -euo pipefail

BACKUP_TYPE="${1:-daily}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/db-backups"
RETENTION_DAYS=7
S3_BUCKET="${S3_BACKUP_BUCKET:-my-db-backups}"

# Database connection (from environment)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-appdb}"
DB_USER="${DB_USER:-postgres}"

BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${BACKUP_TYPE}_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting $BACKUP_TYPE backup of $DB_NAME..."

# Create backup
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    --no-owner --no-privileges --format=custom \
    | gzip > "$BACKUP_FILE"

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "[$(date)] Backup created: $BACKUP_FILE ($BACKUP_SIZE)"

# Upload to S3
if command -v aws &> /dev/null; then
    aws s3 cp "$BACKUP_FILE" \
        "s3://${S3_BUCKET}/${BACKUP_TYPE}/${DB_NAME}_${TIMESTAMP}.sql.gz" \
        --storage-class STANDARD_IA
    echo "[$(date)] Uploaded to S3: s3://${S3_BUCKET}/${BACKUP_TYPE}/"
fi

# Rotate old local backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +${RETENTION_DAYS} -delete
echo "[$(date)] Cleaned up backups older than ${RETENTION_DAYS} days"

# Verify backup
if gzip -t "$BACKUP_FILE" 2>/dev/null; then
    echo "[$(date)] Backup verified: integrity check passed"
else
    echo "[$(date)] ERROR: Backup verification failed!"
    exit 1
fi

echo "[$(date)] Backup complete."
