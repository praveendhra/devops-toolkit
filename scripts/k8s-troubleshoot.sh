#!/bin/bash
# Kubernetes troubleshooting script
# Usage: ./k8s-troubleshoot.sh <namespace> [pod-name]

set -euo pipefail

NAMESPACE="${1:-default}"
POD_NAME="${2:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

section "Cluster Info"
kubectl cluster-info 2>/dev/null || echo "Cannot connect to cluster"

section "Node Status"
kubectl get nodes -o wide

section "Pods in $NAMESPACE"
kubectl get pods -n "$NAMESPACE" -o wide

section "Recent Events (last 30 min)"
kubectl get events -n "$NAMESPACE" --sort-by=.lastTimestamp 2>/dev/null | tail -20

section "Pods Not Running"
kubectl get pods -n "$NAMESPACE" --field-selector='status.phase!=Running,status.phase!=Succeeded' 2>/dev/null || echo "All pods running"

section "Resource Usage"
kubectl top pods -n "$NAMESPACE" 2>/dev/null || echo "Metrics server not available"

if [ -n "$POD_NAME" ]; then
    section "Pod Details: $POD_NAME"
    kubectl describe pod "$POD_NAME" -n "$NAMESPACE"

    section "Pod Logs (last 50 lines)"
    kubectl logs "$POD_NAME" -n "$NAMESPACE" --tail=50 2>/dev/null || echo "No logs available"

    section "Previous Container Logs"
    kubectl logs "$POD_NAME" -n "$NAMESPACE" --previous --tail=20 2>/dev/null || echo "No previous logs"
fi

section "PVC Status"
kubectl get pvc -n "$NAMESPACE" 2>/dev/null || echo "No PVCs"

section "Services"
kubectl get svc -n "$NAMESPACE"

section "Ingress"
kubectl get ingress -n "$NAMESPACE" 2>/dev/null || echo "No ingress resources"

echo -e "\n${GREEN}Troubleshooting complete.${NC}"
