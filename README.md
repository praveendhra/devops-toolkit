# DevOps Toolkit

A comprehensive collection of production-ready DevOps templates, configurations, and operational scripts.

## Structure

```
├── github-actions/       # GitHub Actions workflow templates
├── azure-pipelines/      # Azure DevOps pipeline templates
├── docker/               # Dockerfiles and compose configs
├── kubernetes/           # K8s manifests, overlays, and Helm charts
│   ├── base/             # Base manifests (kustomize)
│   └── overlays/         # Environment-specific overlays
├── helm/                 # Helm chart templates
├── argocd/               # ArgoCD GitOps configs
├── scripts/              # Operational shell scripts
├── monitoring/           # Prometheus, Grafana, Loki configs
├── nginx/                # NGINX reverse proxy configurations
├── security/             # Security scanning, Falco, Kyverno
├── terraform/            # IaC for backend and ECR
├── ansible/              # Configuration management playbooks
└── docs/                 # Runbooks and ADRs
    ├── runbooks/         # Incident response and scaling guides
    └── adr/              # Architecture Decision Records
```

## Quick Start

```bash
# Setup development environment
./scripts/setup-dev-env.sh

# Run health checks
./scripts/health-check.sh

# Deploy with Helm
helm install myapp ./helm/myapp -f helm/myapp/values.yaml

# Deploy with ArgoCD
kubectl apply -f argocd/application.yaml
```

## Tech Stack

- **CI/CD**: GitHub Actions, Azure DevOps, ArgoCD
- **Containers**: Docker, Docker Compose, Helm
- **Orchestration**: Kubernetes (EKS, AKS, GKE)
- **Monitoring**: Prometheus, Grafana, Loki, Alertmanager
- **Security**: Trivy, Falco, Kyverno, Gitleaks
- **IaC**: Terraform, Ansible
- **Cloud**: AWS, Azure, GCP
