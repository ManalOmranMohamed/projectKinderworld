from datetime import date
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class RegisterIn(BaseModel):
    name: str
    email: EmailStr
    password: str
    confirmPassword: str

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "name": "Parent Name",
                "email": "parent@example.com",
                "password": "secret123",
                "confirmPassword": "secret123",
            }
        }
    )


class LoginIn(BaseModel):
    email: EmailStr
    password: str

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "email": "parent@example.com",
                "password": "secret123",
            }
        }
    )


class RefreshIn(BaseModel):
    refresh_token: str


class ChildLoginIn(BaseModel):
    child_id: int
    name: str
    picture_password: List[str]
    device_id: Optional[str] = None
    device_fingerprint: Optional[str] = None

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "child_id": 1,
                "picture_password": ["cat", "dog", "apple"],
                "device_id": "tablet-kid-a",
            }
        }
    )


class ChildRegisterIn(BaseModel):
    name: str
    picture_password: List[str]
    date_of_birth: Optional[date] = None
    age: Optional[int] = None
    avatar: Optional[str] = None
    parent_email: EmailStr

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "name": "Alice",
                "picture_password": ["cat", "dog", "apple"],
                "parent_email": "parent@example.com",
            }
        }
    )


class ChildChangePasswordIn(BaseModel):
    child_id: int
    name: str
    currentPicturePassword: List[str] = Field(..., alias="current_picture_password")
    newPicturePassword: List[str] = Field(..., alias="new_picture_password")

    model_config = ConfigDict(populate_by_name=True)


class ChildSessionValidateIn(BaseModel):
    session_token: str
    device_id: Optional[str] = None
