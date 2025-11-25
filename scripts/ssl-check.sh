#!/bin/bash
# Check SSL certificate expiration for domains
# Alerts if certificate expires within WARNING_DAYS

set -euo pipefail

WARNING_DAYS=30
CRITICAL_DAYS=7

DOMAINS=(
    "app.example.com"
    "api.example.com"
    "admin.example.com"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== SSL Certificate Check ==="
echo "Warning threshold: ${WARNING_DAYS} days"
echo "Critical threshold: ${CRITICAL_DAYS} days"
echo ""

EXIT_CODE=0

for domain in "${DOMAINS[@]}"; do
    expiry_date=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null \
        | openssl x509 -noout -enddate 2>/dev/null \
        | cut -d= -f2)

    if [ -z "$expiry_date" ]; then
        echo -e "${RED}[ERROR]${NC} $domain - Could not retrieve certificate"
        EXIT_CODE=1
        continue
    fi

    expiry_epoch=$(date -j -f "%b %d %T %Y %Z" "$expiry_date" "+%s" 2>/dev/null || \
                   date -d "$expiry_date" "+%s" 2>/dev/null)
    now_epoch=$(date "+%s")
    days_left=$(( (expiry_epoch - now_epoch) / 86400 ))

    if [ "$days_left" -le "$CRITICAL_DAYS" ]; then
        echo -e "${RED}[CRITICAL]${NC} $domain - Expires in ${days_left} days ($expiry_date)"
        EXIT_CODE=1
    elif [ "$days_left" -le "$WARNING_DAYS" ]; then
        echo -e "${YELLOW}[WARNING]${NC} $domain - Expires in ${days_left} days ($expiry_date)"
    else
        echo -e "${GREEN}[OK]${NC}      $domain - Expires in ${days_left} days ($expiry_date)"
    fi
done

echo ""
exit $EXIT_CODE
