# Incident Response Runbook

## Severity Levels
| Level | Impact | Response Time | Examples |
|-------|--------|---------------|---------|
| SEV-1 | Full outage | 15 min | Site down, data loss |
| SEV-2 | Major degradation | 30 min | >50% error rate |
| SEV-3 | Minor impact | 2 hours | Slow responses |
| SEV-4 | No user impact | Next business day | Internal alert |

## Response Steps

### 1. Acknowledge
- Join incident Slack channel
- Assign Incident Commander (IC)
- Start incident document

### 2. Assess
```bash
# Quick health check
./scripts/health-check.sh

# Check error rates
kubectl top pods -n app
kubectl get events -n app --sort-by=.lastTimestamp | tail -20
```

### 3. Mitigate
- Scale up: `kubectl scale deployment/app -n app --replicas=10`
- Rollback: `kubectl rollout undo deployment/app -n app`
- Feature flag: Disable via LaunchDarkly
- Traffic shift: Update DNS/load balancer weights

### 4. Communicate
- Update status page
- Notify stakeholders
- Post to #incidents channel every 30 min

### 5. Resolve & Review
- Confirm service restored
- Schedule post-mortem within 48 hours
- Create follow-up action items
