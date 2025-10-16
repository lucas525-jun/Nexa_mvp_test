import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.database import get_session
from app.main import app
from app.models import Base

# Test database URL
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

# Create test engine and session
test_engine = create_async_engine(TEST_DATABASE_URL, echo=True)
test_session_maker = async_sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)


async def override_get_session():
    """Override database session for testing"""
    async with test_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


@pytest.fixture(scope="function")
async def setup_database():
    """Set up test database"""
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture
def client(setup_database):
    """Create test client"""
    app.dependency_overrides[get_session] = override_get_session
    return AsyncClient(app=app, base_url="http://test")


@pytest.mark.asyncio
async def test_create_task_success(client):
    """Test successful task creation"""
    async with client:
        response = await client.post(
            "/api/v1/tasks",
            json={"type": "optimize_route", "payload": {"locations": ["A", "B", "C"]}},
        )

        assert response.status_code == 201
        data = response.json()
        assert data["message"] == "Task created successfully"
        assert "task" in data
        assert data["task"]["type"] == "optimize_route"
        assert data["task"]["status"] == "pending"
        assert "id" in data["task"]


@pytest.mark.asyncio
async def test_create_task_with_different_type(client):
    """Test task creation with different task type"""
    async with client:
        response = await client.post(
            "/api/v1/tasks", json={"type": "generate_report", "payload": {"report_type": "monthly"}}
        )

        assert response.status_code == 201
        data = response.json()
        assert data["task"]["type"] == "generate_report"
        assert data["task"]["payload"]["report_type"] == "monthly"


@pytest.mark.asyncio
async def test_get_task_success(client):
    """Test successful task retrieval"""
    async with client:
        # First create a task
        create_response = await client.post(
            "/api/v1/tasks",
            json={"type": "optimize_route", "payload": {"locations": ["A", "B", "C", "D"]}},
        )
        task_id = create_response.json()["task"]["id"]

        # Then retrieve it
        get_response = await client.get(f"/api/v1/tasks/{task_id}")

        assert get_response.status_code == 200
        data = get_response.json()
        assert data["id"] == task_id
        assert data["type"] == "optimize_route"
        assert "result" in data  # optimize_route tasks should have result
        assert "total_distance" in data["result"]
        assert "suggested_order" in data["result"]
        assert "timestamp" in data["result"]


@pytest.mark.asyncio
async def test_get_nonexistent_task(client):
    """Test retrieving non-existent task"""
    async with client:
        response = await client.get("/api/v1/tasks/nonexistent-id")

        assert response.status_code == 404
        assert "not found" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_get_non_optimize_route_task(client):
    """Test retrieving non-optimize_route task doesn't add result"""
    async with client:
        # Create a different task type
        create_response = await client.post(
            "/api/v1/tasks", json={"type": "generate_report", "payload": {"data": "test"}}
        )
        task_id = create_response.json()["task"]["id"]

        # Retrieve it
        get_response = await client.get(f"/api/v1/tasks/{task_id}")

        assert get_response.status_code == 200
        data = get_response.json()
        assert "result" not in data  # Non-optimize_route tasks shouldn't have result


@pytest.mark.asyncio
async def test_health_check(client):
    """Test health check endpoint"""
    async with client:
        response = await client.get("/api/v1/health")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "nexa-task-api"
