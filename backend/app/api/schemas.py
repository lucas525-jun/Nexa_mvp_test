from typing import Any, Dict

from pydantic import BaseModel, ConfigDict, Field


class TaskCreate(BaseModel):
    """Schema for creating a new task"""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "type": "optimize_route",
                "payload": {"locations": ["A", "B", "C", "D"], "vehicle_type": "truck"},
            }
        }
    )

    type: str = Field(..., description="Task type (e.g., 'optimize_route')")
    payload: Dict[str, Any] = Field(..., description="Task payload data")


class TaskResponse(BaseModel):
    """Schema for task response"""

    model_config = ConfigDict(from_attributes=True)

    id: str
    type: str
    payload: Dict[str, Any]
    status: str
    created_at: str
    updated_at: str
