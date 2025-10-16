# Nexa Task Manager - Technical Validation Test #1

A minimal but functional AI-ready task module built with FastAPI (backend), React (frontend), and PostgreSQL (database), fully containerized with Docker.

## Features

- **FastAPI Backend**: Async-ready REST API with modular architecture
- **React Frontend**: Interactive UI for creating and viewing tasks
- **PostgreSQL Database**: Fully async database operations with SQLAlchemy
- **Docker Compose**: Complete containerization for easy deployment
- **Unit Tests**: Comprehensive test coverage for API endpoints
- **Route Optimization**: Mock route optimization for `optimize_route` tasks

## Architecture

```
nexa-task-manager/
├── backend/
│   ├── app/
│   │   ├── api/              # API routes and schemas
│   │   ├── models/           # SQLAlchemy models
│   │   ├── services/         # Business logic layer
│   │   ├── database/         # Database configuration
│   │   └── main.py           # FastAPI application
│   ├── tests/                # Unit tests
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── App.js           # Main React component
│   │   └── App.css          # Styling
│   ├── public/
│   ├── Dockerfile
│   └── package.json
└── docker-compose.yml
```

## Prerequisites

- Docker & Docker Compose installed
- Git (for cloning the repository)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd testing
```

### 2. Start All Services

```bash
docker-compose up --build
```

This will start:
- **PostgreSQL**: `localhost:5433`
- **Backend API**: `http://localhost:8002`
- **Frontend**: `http://localhost:3002`

### 3. Access the Application

- **Frontend UI**: http://localhost:3002
- **Backend API Docs**: http://localhost:8002/docs
- **Health Check**: http://localhost:8002/api/v1/health

## API Documentation

### Base URL
```
http://localhost:8002/api/v1
```

### Endpoints

#### 1. Create Task
**POST** `/api/v1/tasks`

Creates a new task in the system.

**Request Body:**
```json
{
  "type": "optimize_route",
  "payload": {
    "locations": ["A", "B", "C", "D"],
    "vehicle_type": "truck"
  }
}
```

**Response (201 Created):**
```json
{
  "message": "Task created successfully",
  "task": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "optimize_route",
    "payload": {
      "locations": ["A", "B", "C", "D"],
      "vehicle_type": "truck"
    },
    "status": "pending",
    "created_at": "2025-10-16T12:00:00.000000",
    "updated_at": "2025-10-16T12:00:00.000000"
  }
}
```

#### 2. Get Task by ID
**GET** `/api/v1/tasks/{task_id}`

Retrieves a task by its ID. For `optimize_route` tasks, returns mock route optimization data.

**Response (200 OK) - optimize_route:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "optimize_route",
  "payload": {
    "locations": ["A", "B", "C", "D"],
    "vehicle_type": "truck"
  },
  "status": "pending",
  "created_at": "2025-10-16T12:00:00.000000",
  "updated_at": "2025-10-16T12:00:00.000000",
  "result": {
    "total_distance": 125.45,
    "suggested_order": [1, 2, 3, 4],
    "timestamp": "2025-10-16T12:00:00.000000",
    "optimization_details": {
      "algorithm": "greedy_nearest_neighbor",
      "time_saved": "25 minutes",
      "fuel_saved": "5.2 liters"
    }
  }
}
```

**Response (404 Not Found):**
```json
{
  "detail": "Task with id '...' not found"
}
```

#### 3. Health Check
**GET** `/api/v1/health`

Check API health status.

**Response (200 OK):**
```json
{
  "status": "healthy",
  "service": "nexa-task-api",
  "version": "1.0.0"
}
```

## Sample API Requests

### Using cURL

**Create a Task:**
```bash
curl -X POST http://localhost:8002/api/v1/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "type": "optimize_route",
    "payload": {
      "locations": ["NYC", "Boston", "Philadelphia"],
      "vehicle_type": "van"
    }
  }'
```

**Get a Task:**
```bash
curl http://localhost:8002/api/v1/tasks/{task_id}
```

### Using Python

```python
import requests

# Create a task
response = requests.post(
    "http://localhost:8002/api/v1/tasks",
    json={
        "type": "optimize_route",
        "payload": {
            "locations": ["A", "B", "C"],
            "vehicle_type": "truck"
        }
    }
)
task_id = response.json()["task"]["id"]

# Retrieve the task
response = requests.get(f"http://localhost:8002/api/v1/tasks/{task_id}")
print(response.json())
```

## CI/CD Pipeline

This project includes a comprehensive CI/CD pipeline using GitHub Actions that runs automatically on pull requests and pushes to `main` and `develop` branches.

### What Gets Checked

The CI pipeline performs the following checks:

1. **Backend Linting**
   - Black (code formatting)
   - Flake8 (style guide enforcement)
   - isort (import sorting)

2. **Backend Unit Tests**
   - Full test suite with pytest
   - Code coverage reporting
   - PostgreSQL integration tests

3. **Frontend Linting**
   - ESLint for JavaScript/React code

4. **Frontend Build Test**
   - Ensures the application builds successfully

5. **Docker Build Test**
   - Validates Docker images can be built

### Running Linting Locally

**Backend:**
```bash
cd backend

# Install dev dependencies
pip install -r requirements-dev.txt

# Run black formatter
black app/ tests/

# Run flake8 linter
flake8 app/ tests/

# Run isort
isort app/ tests/
```

**Frontend:**
```bash
cd frontend

# Run ESLint
npm run lint

# Fix linting issues automatically
npm run lint:fix
```

### Pre-commit Hooks

Install pre-commit hooks to automatically check code before committing:

```bash
# Install pre-commit
pip install pre-commit

# Install the git hooks
pre-commit install

# Run hooks manually on all files
pre-commit run --all-files
```

### CI Workflow Status

The CI workflow will:
- ✅ Run on every pull request
- ✅ Run on pushes to main/develop
- ✅ Report coverage to Codecov
- ✅ Cache dependencies for faster runs
- ✅ Run all jobs in parallel

View workflow runs in the GitHub Actions tab of your repository.

## Make Commands (Quick Reference)

This project includes a comprehensive Makefile for easy development. Run `make help` to see all available commands.

### Most Common Commands

```bash
# Show all available commands
make help

# Run all checks (lint + test + build) - Recommended before pushing!
make check

# Run all linters (backend + frontend)
make lint

# Format backend code automatically
make backend-format

# Run backend tests with coverage
make backend-test-cov

# Start Docker services
make docker-up

# Stop Docker services
make docker-down

# Simulate CI pipeline locally (full validation)
make ci-local

# Clean up generated files
make clean
```

### Backend Commands

```bash
make backend-format      # Format code with black and isort
make backend-lint        # Run all linters (black, flake8, isort)
make backend-test        # Run unit tests
make backend-test-cov    # Run tests with coverage report
make backend-check       # Run lint + test
```

### Frontend Commands

```bash
make frontend-lint       # Run ESLint
make frontend-lint-fix   # Fix linting issues automatically
make frontend-build      # Build production bundle
make frontend-check      # Run lint + build
```

### Docker Commands

```bash
make docker-build        # Build Docker images
make docker-up           # Start services
make docker-up-build     # Build and start services
make docker-down         # Stop services
make docker-down-v       # Stop services and remove volumes
make docker-logs         # View all logs
make docker-test         # Run tests in Docker
```

### Setup Commands

```bash
make setup               # Install all dependencies
make install-dev         # Install dev dependencies + pre-commit
make pre-commit-install  # Install pre-commit hooks
make clean               # Clean up generated files
```

### Example Workflow

Before committing code:
```bash
# Option 1: Quick check
make check

# Option 2: Full CI simulation (recommended before PR)
make ci-local

# Option 3: Just format and lint
make format
make lint
```

## Running Tests

### Backend Unit Tests

```bash
# Enter backend container
docker-compose exec backend bash

# Run tests
pytest

# Run with coverage
pytest --cov=app tests/
```

**Tests include:**
- Task creation with different types
- Task retrieval by ID
- Optimize route special response
- Error handling (404 for non-existent tasks)
- Health check endpoint

## Development

### Backend Development

The backend uses FastAPI with:
- **Async SQLAlchemy** for database operations
- **Pydantic** for request/response validation
- **AsyncPG** for PostgreSQL async driver
- **Modular architecture**: Separate layers for API, services, models, and database

### Frontend Development

The frontend is a React app with:
- **Axios** for API communication
- **Clean UI** with gradient styling
- **Real-time task creation and retrieval**
- **Error handling and loading states**

### Environment Variables

**Backend (.env):**
```bash
DATABASE_URL=postgresql+asyncpg://nexa:nexa123@postgres:5432/nexa_tasks
```

**Frontend (.env):**
```bash
REACT_APP_API_URL=http://localhost:8002
```

## Stopping the Services

```bash
docker-compose down

# Remove volumes (clears database)
docker-compose down -v
```

## Key Design Decisions

1. **Modular Backend Architecture**: Clean separation between API routes, business logic (services), and data models
2. **Async-Ready**: All database operations use async/await for better scalability
3. **Docker Compose**: Simple orchestration of all services with proper health checks
4. **Mock Route Optimization**: Special handling for `optimize_route` task type with generated optimization data
5. **Type Safety**: Pydantic schemas for request/response validation
6. **Test Coverage**: Unit tests with in-memory SQLite for fast execution

## Technologies Used

**Backend:**
- FastAPI 0.109.0
- SQLAlchemy 2.0.25 (async)
- PostgreSQL 15
- AsyncPG 0.29.0
- Pytest 7.4.4

**Frontend:**
- React 18.2.0
- Axios 1.6.5

**Infrastructure:**
- Docker & Docker Compose
- PostgreSQL 15 (Alpine)

## Future Enhancements

- Authentication & authorization
- Real route optimization algorithm
- Task status updates (processing, completed, failed)
- WebSocket support for real-time updates
- Background task processing with Celery
- API rate limiting
- Logging and monitoring
