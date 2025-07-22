#!/bin/bash
# AWS cost report for the last 30 days
# Usage: ./cost-report.sh [profile]

set -euo pipefail

PROFILE="${1:-default}"
START_DATE=$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

echo "=== AWS Cost Report ==="
echo "Period: $START_DATE to $END_DATE"
echo ""

echo "--- Cost by Service ---"
aws ce get-cost-and-usage \
    --profile "$PROFILE" \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount > `1`].[Keys[0], Metrics.BlendedCost.Amount]' \
    --output table 2>/dev/null || echo "(Requires Cost Explorer access)"

echo ""
echo "--- Total Cost ---"
aws ce get-cost-and-usage \
    --profile "$PROFILE" \
    --time-period Start="$START_DATE",End="$END_DATE" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --output table 2>/dev/null || echo "(Requires Cost Explorer access)"
