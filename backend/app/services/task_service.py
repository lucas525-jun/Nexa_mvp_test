import random
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.task import Task


class TaskService:
    """Service layer for task operations"""

    @staticmethod
    async def create_task(session: AsyncSession, task_type: str, payload: dict) -> Task:
        """Create a new task"""
        task = Task(type=task_type, payload=payload, status="pending")
        session.add(task)
        await session.flush()
        await session.refresh(task)
        return task

    @staticmethod
    async def get_task_by_id(session: AsyncSession, task_id: str) -> Task | None:
        """Retrieve task by ID"""
        result = await session.execute(select(Task).where(Task.id == task_id))
        return result.scalar_one_or_none()

    @staticmethod
    def generate_optimize_route_response(task: Task) -> dict:
        """Generate mock route optimization data for optimize_route tasks"""
        if task.type != "optimize_route":
            return task.to_dict()

        # Generate mock route optimization data
        locations = task.payload.get("locations", [])
        num_locations = len(locations) if locations else random.randint(3, 8)

        mock_route = {
            **task.to_dict(),
            "result": {
                "total_distance": round(random.uniform(10.5, 150.8), 2),
                "suggested_order": list(range(1, num_locations + 1)),
                "timestamp": datetime.utcnow().isoformat(),
                "optimization_details": {
                    "algorithm": "greedy_nearest_neighbor",
                    "time_saved": f"{random.randint(5, 45)} minutes",
                    "fuel_saved": f"{round(random.uniform(2.1, 8.5), 1)} liters",
                },
            },
        }

        return mock_route
