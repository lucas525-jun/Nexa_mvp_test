.PHONY: help setup install-dev clean test lint format check docker-up docker-down docker-logs

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Nexa Task Manager - Development Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ============================================================================
# Setup & Installation
# ============================================================================

setup: ## Initial setup - install all dependencies
	@echo "$(BLUE)Installing backend dependencies...$(NC)"
	cd backend && pip install -r requirements.txt -r requirements-dev.txt
	@echo "$(BLUE)Installing frontend dependencies...$(NC)"
	cd frontend && npm install
	@echo "$(GREEN)✓ Setup complete!$(NC)"

install-dev: ## Install development dependencies only
	cd backend && pip install -r requirements-dev.txt
	pip install pre-commit
	pre-commit install
	@echo "$(GREEN)✓ Dev dependencies installed!$(NC)"

# ============================================================================
# Backend - Linting & Formatting
# ============================================================================

backend-format: ## Format backend code with black and isort
	@echo "$(BLUE)Formatting backend code...$(NC)"
	cd backend && black app/ tests/
	cd backend && isort app/ tests/
	@echo "$(GREEN)✓ Backend formatting complete!$(NC)"

backend-lint: ## Run all backend linters (black, flake8, isort)
	@echo "$(BLUE)Running backend linters...$(NC)"
	@echo "$(YELLOW)→ Black (format check)...$(NC)"
	cd backend && black --check --diff app/ tests/
	@echo "$(YELLOW)→ Flake8 (linting)...$(NC)"
	cd backend && flake8 app/ tests/
	@echo "$(YELLOW)→ isort (import sorting)...$(NC)"
	cd backend && isort --check-only app/ tests/
	@echo "$(GREEN)✓ All backend linting passed!$(NC)"

backend-test: ## Run backend unit tests
	@echo "$(BLUE)Running backend tests...$(NC)"
	cd backend && pytest tests/ -v
	@echo "$(GREEN)✓ Backend tests passed!$(NC)"

backend-test-cov: ## Run backend tests with coverage report
	@echo "$(BLUE)Running backend tests with coverage...$(NC)"
	cd backend && pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=html
	@echo "$(GREEN)✓ Coverage report generated in backend/htmlcov/$(NC)"

backend-check: backend-lint backend-test ## Run all backend checks (lint + test)

# ============================================================================
# Frontend - Linting & Building
# ============================================================================

frontend-lint: ## Run frontend linter (ESLint)
	@echo "$(BLUE)Running frontend linter...$(NC)"
	cd frontend && npm run lint
	@echo "$(GREEN)✓ Frontend linting passed!$(NC)"

frontend-lint-fix: ## Fix frontend linting issues automatically
	@echo "$(BLUE)Fixing frontend linting issues...$(NC)"
	cd frontend && npm run lint:fix
	@echo "$(GREEN)✓ Frontend linting issues fixed!$(NC)"

frontend-build: ## Build frontend application
	@echo "$(BLUE)Building frontend...$(NC)"
	cd frontend && npm run build
	@echo "$(GREEN)✓ Frontend build complete!$(NC)"

frontend-check: frontend-lint frontend-build ## Run all frontend checks (lint + build)

# ============================================================================
# Combined Checks
# ============================================================================

lint: backend-lint frontend-lint ## Run all linters (backend + frontend)

test: backend-test ## Run all tests

check: backend-check frontend-check ## Run ALL checks (lint + test + build)
	@echo "$(GREEN)✓✓✓ All checks passed! Ready to commit! ✓✓✓$(NC)"

format: backend-format ## Format all code

# ============================================================================
# Docker Commands
# ============================================================================

docker-build: ## Build Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	docker-compose build
	@echo "$(GREEN)✓ Docker images built!$(NC)"

docker-up: ## Start all services with Docker Compose
	@echo "$(BLUE)Starting services...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✓ Services started!$(NC)"
	@echo "$(YELLOW)Frontend: http://localhost:3002$(NC)"
	@echo "$(YELLOW)Backend API: http://localhost:8002/docs$(NC)"
	@echo "$(YELLOW)PostgreSQL: localhost:5433$(NC)"

docker-up-build: ## Build and start all services
	@echo "$(BLUE)Building and starting services...$(NC)"
	docker-compose up -d --build
	@echo "$(GREEN)✓ Services started!$(NC)"

docker-down: ## Stop all services
	@echo "$(BLUE)Stopping services...$(NC)"
	docker-compose down
	@echo "$(GREEN)✓ Services stopped!$(NC)"

docker-down-v: ## Stop all services and remove volumes
	@echo "$(BLUE)Stopping services and removing volumes...$(NC)"
	docker-compose down -v
	@echo "$(GREEN)✓ Services stopped and volumes removed!$(NC)"

docker-logs: ## View logs from all services
	docker-compose logs -f

docker-logs-backend: ## View backend logs
	docker-compose logs -f backend

docker-logs-frontend: ## View frontend logs
	docker-compose logs -f frontend

docker-shell-backend: ## Open shell in backend container
	docker-compose exec backend bash

docker-shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend sh

docker-test: ## Run tests inside Docker container
	docker-compose exec backend pytest tests/ -v

# ============================================================================
# Pre-commit Hooks
# ============================================================================

pre-commit-install: ## Install pre-commit hooks
	pip install pre-commit
	pre-commit install
	@echo "$(GREEN)✓ Pre-commit hooks installed!$(NC)"

pre-commit-run: ## Run pre-commit hooks on all files
	pre-commit run --all-files

pre-commit-update: ## Update pre-commit hooks
	pre-commit autoupdate

# ============================================================================
# Cleanup
# ============================================================================

clean: ## Clean up generated files and caches
	@echo "$(BLUE)Cleaning up...$(NC)"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.coverage" -delete
	rm -rf backend/htmlcov/ backend/.coverage
	rm -rf frontend/build/ frontend/node_modules/.cache/
	@echo "$(GREEN)✓ Cleanup complete!$(NC)"

clean-all: clean docker-down-v ## Clean everything including Docker volumes
	@echo "$(GREEN)✓ Full cleanup complete!$(NC)"

# ============================================================================
# CI/CD Simulation
# ============================================================================

ci-local: ## Simulate CI pipeline locally (all checks)
	@echo "$(BLUE)========================================$(NC)"
	@echo "$(BLUE)Running CI Pipeline Locally$(NC)"
	@echo "$(BLUE)========================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Step 1/5: Backend Linting$(NC)"
	@$(MAKE) backend-lint
	@echo ""
	@echo "$(YELLOW)Step 2/5: Backend Testing$(NC)"
	@$(MAKE) backend-test-cov
	@echo ""
	@echo "$(YELLOW)Step 3/5: Frontend Linting$(NC)"
	@$(MAKE) frontend-lint
	@echo ""
	@echo "$(YELLOW)Step 4/5: Frontend Build$(NC)"
	@$(MAKE) frontend-build
	@echo ""
	@echo "$(YELLOW)Step 5/5: Docker Build Test$(NC)"
	@$(MAKE) docker-build
	@echo ""
	@echo "$(GREEN)========================================$(NC)"
	@echo "$(GREEN)✓✓✓ CI Pipeline Complete! ✓✓✓$(NC)"
	@echo "$(GREEN)========================================$(NC)"
