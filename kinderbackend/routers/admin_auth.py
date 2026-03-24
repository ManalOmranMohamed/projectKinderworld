"""
Admin authentication router - fully separate from parent/child auth.

Endpoints:
  POST /admin/auth/login    - email + password -> access + refresh tokens
  POST /admin/auth/refresh  - refresh token -> new access token
  POST /admin/auth/logout   - invalidate refresh tokens (bump token_version)
  GET  /admin/auth/me       - return current admin profile + roles + permissions
"""

import logging

from fastapi import APIRouter, Depends, Request
from pydantic import AliasChoices, BaseModel, EmailStr, Field, field_validator
from sqlalchemy.orm import Session

from admin_deps import get_current_admin
from deps import get_db
from rate_limit import auth_rate_limit
from services.admin_auth_service import admin_auth_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/admin/auth", tags=["Admin Auth"])


class AdminLoginRequest(BaseModel):
    email: EmailStr
    password: str
    two_factor_code: str | None = Field(
        default=None,
        validation_alias=AliasChoices("two_factor_code", "twoFactorCode"),
    )

    @field_validator("two_factor_code", mode="before")
    @classmethod
    def _normalize_two_factor_code(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = "".join(char for char in value.strip() if char.isdigit())
        return normalized or None


class AdminRefreshRequest(BaseModel):
    refresh_token: str


class AdminTokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class AdminLoginResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    admin: dict


class TwoFactorStatusResponse(BaseModel):
    enabled: bool
    method: str | None = None
    confirmed_at: str | None = None


class TwoFactorSetupResponse(TwoFactorStatusResponse):
    secret: str
    manual_entry_key: str
    issuer: str
    provisioning_uri: str


class TwoFactorEnableRequest(BaseModel):
    code: str = Field(..., min_length=6, max_length=12)

    @field_validator("code", mode="before")
    @classmethod
    def _normalize_code(cls, value: str) -> str:
        normalized = "".join(char for char in value.strip() if char.isdigit())
        if not normalized:
            raise ValueError("value must not be blank")
        return normalized


class TwoFactorActionResponse(TwoFactorStatusResponse):
    success: bool
    message: str


@router.post("/login", response_model=AdminLoginResponse, summary="Admin login")
def admin_login(
    payload: AdminLoginRequest,
    request: Request,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    return admin_auth_service.login(payload=payload, request=request, db=db)


@router.post("/refresh", response_model=AdminTokenResponse, summary="Refresh admin access token")
def admin_refresh(
    payload: AdminRefreshRequest,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    """
    Exchange a valid admin refresh token for a new access token.

    - Validates token_type='admin' claim.
    - Validates token_version matches the stored value (logout invalidates old tokens).
    - Disabled admins are blocked.
    """
    return admin_auth_service.refresh(payload=payload, db=db)


@router.post("/logout", summary="Admin logout - invalidates refresh tokens")
def admin_logout(
    request: Request,
    admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return admin_auth_service.logout(request=request, admin=admin, db=db)


@router.get("/me", summary="Get current admin profile")
def admin_me(
    admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return admin_auth_service.current_profile(admin=admin, db=db)


@router.get("/2fa/status", response_model=TwoFactorStatusResponse, summary="Get admin 2FA status")
def admin_two_factor_status(admin=Depends(get_current_admin)):
    return admin_auth_service.two_factor_status(admin=admin)


@router.post("/2fa/setup", response_model=TwoFactorSetupResponse, summary="Start admin 2FA setup")
def admin_two_factor_setup(
    admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return admin_auth_service.two_factor_setup(admin=admin, db=db)


@router.post(
    "/2fa/enable",
    response_model=TwoFactorActionResponse,
    summary="Enable admin 2FA",
)
def admin_two_factor_enable(
    payload: TwoFactorEnableRequest,
    admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return admin_auth_service.enable_two_factor(admin=admin, code=payload.code, db=db)


@router.post(
    "/2fa/disable",
    response_model=TwoFactorActionResponse,
    summary="Disable admin 2FA",
)
def admin_two_factor_disable(
    admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return admin_auth_service.disable_two_factor(admin=admin, db=db)
