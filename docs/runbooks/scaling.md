# Scaling Runbook

## Horizontal Scaling (Add instances)

### Kubernetes
```bash
# Scale deployment
kubectl scale deployment/app -n app --replicas=10

# Check HPA status
kubectl get hpa -n app

# Adjust HPA limits
kubectl patch hpa app-hpa -n app -p '{"spec":{"maxReplicas":30}}'
```

### ECS
```bash
# Update desired count
aws ecs update-service --cluster prod --service myapp --desired-count 10

# Check service status
aws ecs describe-services --cluster prod --services myapp \
  --query 'services[0].{desired:desiredCount,running:runningCount,pending:pendingCount}'
```

## Vertical Scaling (Bigger instances)

### Kubernetes
Update resource requests/limits in deployment:
```yaml
resources:
  requests:
    cpu: 1000m    # was 500m
    memory: 2Gi   # was 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

### RDS
```bash
aws rds modify-db-instance \
  --db-instance-identifier myapp-prod \
  --db-instance-class db.r6g.2xlarge \
  --apply-immediately
```

## Database Connection Pooling
If DB connections are saturated:
```bash
# Check current connections
psql -c "SELECT count(*) FROM pg_stat_activity;"

# PgBouncer: increase pool_size
# Application: reduce connection pool max
```
