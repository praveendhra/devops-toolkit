# ADR 001: Container Orchestration Platform

## Status
Accepted

## Context
We need a container orchestration platform for running microservices in production. Options considered:
1. Amazon ECS (Fargate)
2. Kubernetes (EKS/AKS/GKE)
3. Docker Swarm

## Decision
We will use **Kubernetes** (managed via EKS/AKS) as our primary container orchestration platform.

## Rationale
- **Portability**: Same manifests work across EKS, AKS, GKE, and on-premise
- **Ecosystem**: Helm, ArgoCD, Prometheus, Istio, cert-manager
- **Scaling**: HPA and VPA for automatic scaling
- **Team skills**: Team has existing Kubernetes experience
- **Industry standard**: Largest community and support

## Consequences
- Higher operational complexity than ECS
- Need for dedicated cluster management
- Learning curve for advanced features (CRDs, operators)
- Cost of control plane (~$73/month per cluster on EKS)

## Alternatives Rejected
- **ECS Fargate**: Simpler but AWS-locked; less ecosystem
- **Docker Swarm**: Limited features and declining community
