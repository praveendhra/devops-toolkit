#!/bin/bash
# One-command development environment setup
# Usage: ./setup-dev-env.sh

set -euo pipefail

echo "=== Development Environment Setup ==="

# Check prerequisites
for cmd in docker kubectl helm python3 node aws terraform; do
    if command -v "$cmd" &> /dev/null; then
        echo "[OK] $cmd: $(command -v $cmd)"
    else
        echo "[MISSING] $cmd"
    fi
done

# Setup Python environment
if [ -f "requirements.txt" ]; then
    echo ""
    echo "--- Setting up Python ---"
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    [ -f requirements-dev.txt ] && pip install -r requirements-dev.txt
fi

# Setup pre-commit hooks
if [ -f ".pre-commit-config.yaml" ]; then
    echo ""
    echo "--- Setting up pre-commit hooks ---"
    pip install pre-commit
    pre-commit install
fi

# Setup Docker Compose
if [ -f "docker-compose.yml" ] || [ -f "docker/docker-compose.yml" ]; then
    echo ""
    echo "--- Starting Docker Compose ---"
    docker compose up -d
fi

# Setup kubectl context
if command -v kubectl &> /dev/null; then
    echo ""
    echo "--- Current kubectl context ---"
    kubectl config current-context 2>/dev/null || echo "No kubectl context configured"
fi

echo ""
echo "=== Setup complete! ==="
