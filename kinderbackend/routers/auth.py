from fastapi import APIRouter, Depends
from pydantic import AliasChoices, BaseModel, ConfigDict, Field
from sqlalchemy.orm import Session

from deps import get_current_user, get_db
from models import User
from schemas.common import SuccessResponse
from services.auth_service import (
    change_parent_pin,
    change_password,
    get_parent_pin_status,
    logout,
    request_parent_pin_reset,
    set_parent_pin,
    update_profile,
    verify_parent_pin,
)

router = APIRouter(tags=["auth"])

PARENT_PIN_LENGTH = 4


class ProfileUpdate(BaseModel):
    name: str


class ChangePasswordRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    current_password: str = Field(
        ...,
        min_length=1,
        validation_alias=AliasChoices("current_password", "currentPassword"),
    )
    new_password: str = Field(
        ...,
        description="Must contain uppercase, digit, and special character",
        validation_alias=AliasChoices("new_password", "newPassword"),
    )
    confirm_password: str = Field(
        ...,
        validation_alias=AliasChoices("confirm_password", "confirmPassword"),
    )


class ChangePasswordResponse(BaseModel):
    success: bool
    message: str = "Password changed successfully"


ChangePassword = ChangePasswordRequest


class ParentPinStatusResponse(BaseModel):
    has_pin: bool
    is_locked: bool
    failed_attempts: int
    locked_until: str | None = None


class ParentPinSetRequest(BaseModel):
    pin: str = Field(..., min_length=PARENT_PIN_LENGTH, max_length=PARENT_PIN_LENGTH)
    confirm_pin: str = Field(
        ...,
        min_length=PARENT_PIN_LENGTH,
        max_length=PARENT_PIN_LENGTH,
    )


class ParentPinVerifyRequest(BaseModel):
    pin: str = Field(..., min_length=PARENT_PIN_LENGTH, max_length=PARENT_PIN_LENGTH)


class ParentPinChangeRequest(BaseModel):
    current_pin: str = Field(
        ...,
        min_length=PARENT_PIN_LENGTH,
        max_length=PARENT_PIN_LENGTH,
    )
    new_pin: str = Field(..., min_length=PARENT_PIN_LENGTH, max_length=PARENT_PIN_LENGTH)
    confirm_pin: str = Field(
        ...,
        min_length=PARENT_PIN_LENGTH,
        max_length=PARENT_PIN_LENGTH,
    )


class ParentPinResetRequest(BaseModel):
    note: str | None = None


class ParentPinActionResponse(BaseModel):
    success: bool
    message: str
    locked_until: str | None = None


@router.put("/auth/profile")
def update_profile_endpoint(
    payload: ProfileUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return update_profile(payload=payload, db=db, user=user)


@router.post("/auth/change-password", response_model=ChangePasswordResponse)
def change_password_endpoint(
    payload: ChangePasswordRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return change_password(payload=payload, db=db, user=user)


@router.post("/auth/logout", response_model=SuccessResponse)
def logout_endpoint(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return logout(db=db, user=user)


@router.get("/auth/parent-pin/status", response_model=ParentPinStatusResponse)
def get_parent_pin_status_endpoint(user: User = Depends(get_current_user)):
    return get_parent_pin_status(user=user)


@router.post("/auth/parent-pin/set", response_model=ParentPinActionResponse)
def set_parent_pin_endpoint(
    payload: ParentPinSetRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return set_parent_pin(payload=payload, db=db, user=user)


@router.post("/auth/parent-pin/verify", response_model=ParentPinActionResponse)
def verify_parent_pin_endpoint(
    payload: ParentPinVerifyRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return verify_parent_pin(payload=payload, db=db, user=user)


@router.post("/auth/parent-pin/change", response_model=ParentPinActionResponse)
def change_parent_pin_endpoint(
    payload: ParentPinChangeRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return change_parent_pin(payload=payload, db=db, user=user)


@router.post("/auth/parent-pin/reset-request", response_model=ParentPinActionResponse)
def request_parent_pin_reset_endpoint(
    payload: ParentPinResetRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return request_parent_pin_reset(payload=payload, db=db, user=user)
