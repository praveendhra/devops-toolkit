#!/bin/bash
# Health check script for monitoring endpoints
# Usage: ./health-check.sh [config_file]
# Returns exit code 0 if all checks pass, 1 if any fail

set -euo pipefail

CONFIG_FILE="${1:-endpoints.json}"
TIMEOUT=5
FAILURES=0
TOTAL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

check_http() {
    local name="$1" url="$2" expected_status="${3:-200}"
    TOTAL=$((TOTAL + 1))

    response=$(curl -s -o /dev/null -w "%{http_code}|%{time_total}" \
        --max-time "$TIMEOUT" "$url" 2>/dev/null) || {
        log_fail "$name - Connection failed ($url)"
        FAILURES=$((FAILURES + 1))
        return
    }

    http_code=$(echo "$response" | cut -d'|' -f1)
    response_time=$(echo "$response" | cut -d'|' -f2)

    if [ "$http_code" = "$expected_status" ]; then
        if (( $(echo "$response_time > 2.0" | bc -l) )); then
            log_warn "$name - ${response_time}s (slow) [$http_code]"
        else
            log_ok "$name - ${response_time}s [$http_code]"
        fi
    else
        log_fail "$name - Expected $expected_status, got $http_code ($url)"
        FAILURES=$((FAILURES + 1))
    fi
}

check_tcp() {
    local name="$1" host="$2" port="$3"
    TOTAL=$((TOTAL + 1))

    if nc -z -w "$TIMEOUT" "$host" "$port" 2>/dev/null; then
        log_ok "$name ($host:$port)"
    else
        log_fail "$name ($host:$port)"
        FAILURES=$((FAILURES + 1))
    fi
}

echo "=============================="
echo "Health Check - $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================="

# HTTP Endpoints
check_http "API"         "https://api.example.com/health"
check_http "Frontend"    "https://app.example.com" "200"
check_http "Auth"        "https://auth.example.com/health"

# TCP Services
check_tcp  "PostgreSQL"  "db.internal" 5432
check_tcp  "Redis"       "redis.internal" 6379

echo ""
echo "Results: $((TOTAL - FAILURES))/$TOTAL passed"

if [ "$FAILURES" -gt 0 ]; then
    echo -e "${RED}$FAILURES check(s) failed!${NC}"
    exit 1
fi

echo -e "${GREEN}All checks passed.${NC}"
