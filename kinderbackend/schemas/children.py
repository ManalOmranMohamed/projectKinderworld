from datetime import date
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, EmailStr


class ChildCreate(BaseModel):
    name: str
    picture_password: List[str]
    date_of_birth: Optional[date] = None
    age: Optional[int] = None
    avatar: Optional[str] = None
    parent_email: Optional[EmailStr] = None

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "name": "Alice",
                "picture_password": ["cat", "dog", "apple"],
                "parent_email": "parent@example.com",
            }
        }
    )


class ChildUpdate(BaseModel):
    name: Optional[str] = None
    picture_password: Optional[List[str]] = None
    date_of_birth: Optional[date] = None
    age: Optional[int] = None
    avatar: Optional[str] = None
