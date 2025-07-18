#!/bin/bash
# Quick port-forward to common services in Kubernetes
# Usage: ./port-forward.sh <service> [namespace]

set -euo pipefail

SERVICE="$1"
NAMESPACE="${2:-default}"

declare -A PORTS=(
    ["postgres"]="5432:5432"
    ["redis"]="6379:6379"
    ["grafana"]="3000:3000"
    ["prometheus"]="9090:9090"
    ["kibana"]="5601:5601"
    ["argocd"]="8080:443"
    ["jaeger"]="16686:16686"
    ["rabbitmq"]="15672:15672"
)

if [[ -z "${PORTS[$SERVICE]+_}" ]]; then
    echo "Unknown service: $SERVICE"
    echo "Available: ${!PORTS[*]}"
    exit 1
fi

PORT="${PORTS[$SERVICE]}"
LOCAL_PORT="${PORT%%:*}"

echo "Port-forwarding $SERVICE ($PORT) in namespace $NAMESPACE"
echo "Access at: http://localhost:$LOCAL_PORT"

kubectl port-forward -n "$NAMESPACE" "svc/$SERVICE" "$PORT"
