from typing import Any, Dict

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.schemas import TaskCreate
from app.database import get_session
from app.services import TaskService

router = APIRouter(prefix="/api/v1", tags=["tasks"])


@router.post("/tasks", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_task(task_data: TaskCreate, session: AsyncSession = Depends(get_session)):
    """
    Create a new task

    - **type**: Task type (e.g., 'optimize_route', 'generate_report')
    - **payload**: JSON payload with task-specific data
    """
    task = await TaskService.create_task(
        session=session, task_type=task_data.type, payload=task_data.payload
    )

    return {"message": "Task created successfully", "task": task.to_dict()}


@router.get("/tasks/{task_id}", response_model=Dict[str, Any])
async def get_task(task_id: str, session: AsyncSession = Depends(get_session)):
    """
    Retrieve a task by ID

    - **task_id**: UUID of the task to retrieve

    If task type is 'optimize_route', returns mock route optimization data
    """
    task = await TaskService.get_task_by_id(session=session, task_id=task_id)

    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=f"Task with id '{task_id}' not found"
        )

    # Generate special response for optimize_route tasks
    if task.type == "optimize_route":
        return TaskService.generate_optimize_route_response(task)

    return task.to_dict()


@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "nexa-task-api", "version": "1.0.0"}
