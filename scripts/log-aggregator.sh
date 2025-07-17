#!/bin/bash
# Aggregate and search logs across multiple K8s pods
# Usage: ./log-aggregator.sh <namespace> <label-selector> [search-term]

set -euo pipefail

NAMESPACE="${1:-default}"
SELECTOR="${2:-app=myapp}"
SEARCH="${3:-}"
TAIL_LINES=100

echo "Aggregating logs from namespace=$NAMESPACE selector=$SELECTOR"
echo "---"

PODS=$(kubectl get pods -n "$NAMESPACE" -l "$SELECTOR" -o jsonpath='{.items[*].metadata.name}')

for pod in $PODS; do
    echo "--- Logs from $pod ---"
    if [ -n "$SEARCH" ]; then
        kubectl logs "$pod" -n "$NAMESPACE" --tail="$TAIL_LINES" 2>/dev/null | grep -i "$SEARCH" || true
    else
        kubectl logs "$pod" -n "$NAMESPACE" --tail="$TAIL_LINES" 2>/dev/null
    fi
    echo ""
done
