.PHONY: help build test lint deploy clean

DOCKER_REGISTRY ?= ghcr.io/myorg
IMAGE_NAME ?= myapp
VERSION ?= $(shell git describe --tags --always --dirty)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker image
	docker build -t $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION) .
	docker tag $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION) $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

test: ## Run tests
	pytest tests/ -v --cov=src

lint: ## Run linters
	ruff check .
	mypy src/

push: build ## Push Docker image to registry
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION)
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

deploy-staging: ## Deploy to staging
	kubectl apply -k kubernetes/overlays/staging/

deploy-prod: ## Deploy to production (requires approval)
	@echo "Deploying $(VERSION) to production..."
	kubectl apply -k kubernetes/overlays/production/

health-check: ## Run health checks
	./scripts/health-check.sh

ssl-check: ## Check SSL certificate expiration
	./scripts/ssl-check.sh

clean: ## Clean up Docker resources
	./scripts/cleanup-images.sh
	docker system prune -f
