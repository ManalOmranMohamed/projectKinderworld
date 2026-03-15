from typing import Any

from pydantic import BaseModel


class SuccessResponse(BaseModel):
    success: bool


class ActionResponse(SuccessResponse):
    message: str | None = None


class ErrorResponse(BaseModel):
    detail: Any
