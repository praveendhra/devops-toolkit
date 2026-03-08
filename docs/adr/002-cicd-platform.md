# ADR 002: CI/CD Platform

## Status
Accepted

## Context
We need a CI/CD platform for building, testing, and deploying applications.

## Decision
We will use **GitHub Actions** as our primary CI/CD platform, with **ArgoCD** for Kubernetes deployments (GitOps).

## Rationale
- Tight integration with GitHub repositories
- Marketplace with pre-built actions
- OIDC support for cloud authentication (no stored credentials)
- Free tier sufficient for our needs
- ArgoCD provides GitOps workflow with auto-sync and self-healing

## Consequences
- Dependent on GitHub availability
- Complex workflows need careful structuring
- ArgoCD adds operational overhead
