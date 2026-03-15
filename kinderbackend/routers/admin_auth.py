"""
Admin authentication router - fully separate from parent/child auth.

Endpoints:
  POST /admin/auth/login    - email + password -> access + refresh tokens
  POST /admin/auth/refresh  - refresh token -> new access token
  POST /admin/auth/logout   - invalidate refresh tokens (bump token_version)
  GET  /admin/auth/me       - return current admin profile + roles + permissions
"""
import logging
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Request, status
from jose import JWTError
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from admin_auth import ADMIN_TOKEN_TYPE, create_admin_access_token, create_admin_refresh_token
from admin_deps import get_current_admin
from admin_utils import build_admin_payload, write_audit_log
from auth import decode_token, verify_password
from core.settings import settings
from deps import get_db
from rate_limit import auth_rate_limit

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/admin/auth", tags=["Admin Auth"])


class AdminLoginRequest(BaseModel):
    email: EmailStr
    password: str


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


@router.post("/login", response_model=AdminLoginResponse, summary="Admin login")
def admin_login(
    payload: AdminLoginRequest,
    request: Request,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    """
    Authenticate an admin with email + password.

    - Returns access_token (1 h) and refresh_token (7 d).
    - Disabled admins receive 403 before any token is issued.
    - Uses a generic 401 for wrong credentials to prevent email enumeration.
    """
    from admin_models import AdminUser

    email = payload.email.strip().lower()
    admin = db.query(AdminUser).filter(AdminUser.email == email).first()
    now = datetime.utcnow()
    client_host = request.client.host if request.client else None
    user_agent = request.headers.get("user-agent")

    if admin and admin.locked_until and admin.locked_until > now:
        write_audit_log(
            db=db,
            request=request,
            admin=admin,
            action="admin_auth.login_locked",
            entity_type="admin_user",
            entity_id=admin.id,
            before_json=None,
            after_json={
                "email": email,
                "locked_until": admin.locked_until.isoformat(),
                "failed_login_attempts": int(admin.failed_login_attempts or 0),
            },
        )
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_423_LOCKED,
            detail={
                "code": "ADMIN_TEMP_LOCKED",
                "message": "Too many failed login attempts. Try again later.",
                "locked_until": admin.locked_until.isoformat(),
            },
        )

    # Constant-time-ish: always call verify_password even on miss
    password_ok = verify_password(payload.password, admin.password_hash) if admin else False

    if not admin or not password_ok:
        logger.warning("Failed admin login attempt for email: %s", email)
        failure_entity_type = "admin_auth"
        failure_entity_id = email

        if admin is not None:
            admin.failed_login_attempts = int(admin.failed_login_attempts or 0) + 1
            admin.last_failed_login_at = now
            admin.last_failed_login_ip = client_host
            admin.last_failed_login_user_agent = user_agent

            if admin.failed_login_attempts >= settings.admin_suspicious_failed_threshold:
                admin.suspicious_access_count = int(admin.suspicious_access_count or 0) + 1
                admin.is_flagged_suspicious = True

            if admin.failed_login_attempts >= settings.admin_auth_max_failed_attempts:
                admin.locked_until = now + timedelta(minutes=settings.admin_auth_lockout_minutes)

            admin.updated_at = now
            db.add(admin)
            failure_entity_type = "admin_user"
            failure_entity_id = str(admin.id)

        write_audit_log(
            db=db,
            request=request,
            admin=admin,
            action="admin_auth.login_failed",
            entity_type=failure_entity_type,
            entity_id=failure_entity_id,
            before_json=None,
            after_json={
                "email": email,
                "ip_address": client_host,
                "user_agent": user_agent,
                "failed_login_attempts": int(getattr(admin, "failed_login_attempts", 0) or 0),
                "locked_until": (
                    admin.locked_until.isoformat()
                    if admin is not None and admin.locked_until
                    else None
                ),
            },
        )
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not admin.is_active:
        logger.warning("Disabled admin login attempt: %s (id=%s)", admin.email, admin.id)
        write_audit_log(
            db=db,
            request=request,
            admin=admin,
            action="admin_auth.login_disabled",
            entity_type="admin_user",
            entity_id=admin.id,
            before_json=None,
            after_json={"id": admin.id, "email": admin.email, "is_active": admin.is_active},
        )
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={
                "code": "ADMIN_DISABLED",
                "message": "This admin account has been disabled. Contact a super admin.",
            },
        )

    suspicious_ip_change = bool(admin.last_login_ip and client_host and admin.last_login_ip != client_host)
    if suspicious_ip_change:
        admin.suspicious_access_count = int(admin.suspicious_access_count or 0) + 1
        admin.is_flagged_suspicious = True

    admin.last_login_at = now
    admin.last_login_ip = client_host
    admin.last_login_user_agent = user_agent
    admin.failed_login_attempts = 0
    admin.locked_until = None
    admin.updated_at = now
    db.add(admin)
    db.commit()
    db.refresh(admin)

    logger.info("Admin login success: %s (id=%s)", admin.email, admin.id)
    write_audit_log(
        db=db,
        request=request,
        admin=admin,
        action="admin_auth.login",
        entity_type="admin_user",
        entity_id=admin.id,
        before_json=None,
        after_json={"id": admin.id, "email": admin.email, "is_active": admin.is_active},
    )
    if suspicious_ip_change:
        write_audit_log(
            db=db,
            request=request,
            admin=admin,
            action="admin_auth.suspicious_ip_change",
            entity_type="admin_user",
            entity_id=admin.id,
            before_json=None,
            after_json={
                "id": admin.id,
                "email": admin.email,
                "last_login_ip": admin.last_login_ip,
                "suspicious_access_count": int(admin.suspicious_access_count or 0),
            },
        )
    db.commit()
    db.refresh(admin)

    return {
        "access_token": create_admin_access_token(admin.id, admin.token_version),
        "refresh_token": create_admin_refresh_token(admin.id, admin.token_version),
        "token_type": "bearer",
        "admin": build_admin_payload(admin, db),
    }


@router.post("/refresh", response_model=AdminTokenResponse, summary="Refresh admin access token")
def admin_refresh(payload: AdminRefreshRequest, db: Session = Depends(get_db), rate_limit_check: None = Depends(auth_rate_limit)):
    """
    Exchange a valid admin refresh token for a new access token.

    - Validates token_type='admin' claim.
    - Validates token_version matches the stored value (logout invalidates old tokens).
    - Disabled admins are blocked.
    """
    from admin_models import AdminUser

    try:
        decoded = decode_token(payload.refresh_token)
    except JWTError as exc:
        logger.warning("Admin refresh token decode failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
        )

    if decoded.get("token_type") != ADMIN_TOKEN_TYPE:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token type",
        )

    admin_id_str = decoded.get("sub")
    stored_version = decoded.get("token_version", 0)

    try:
        admin_id = int(admin_id_str)
    except (ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token payload",
        )

    admin = db.query(AdminUser).filter(AdminUser.id == admin_id).first()
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Admin not found",
        )

    try:
        stored_version_value = int(stored_version)
    except (TypeError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token payload",
        )

    if stored_version_value != int(admin.token_version or 0):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token has been revoked",
        )

    if not admin.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={
                "code": "ADMIN_DISABLED",
                "message": "This admin account has been disabled",
            },
        )

    return {
        "access_token": create_admin_access_token(admin.id, admin.token_version),
        "token_type": "bearer",
    }


@router.post("/logout", summary="Admin logout - invalidates refresh tokens")
def admin_logout(
    request: Request,
    admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    """
    Logout the current admin by bumping token_version.
    All existing refresh tokens become invalid immediately.
    """
    admin.token_version = (admin.token_version or 0) + 1
    admin.updated_at = datetime.utcnow()
    db.add(admin)
    write_audit_log(
        db=db,
        request=request,
        admin=admin,
        action="admin_auth.logout",
        entity_type="admin_user",
        entity_id=admin.id,
        before_json={"id": admin.id, "token_version": (admin.token_version or 0) - 1},
        after_json={"id": admin.id, "token_version": admin.token_version},
    )
    db.commit()

    logger.info("Admin logout: %s (id=%s)", admin.email, admin.id)

    return {"success": True, "message": "Logged out successfully"}


@router.get("/me", summary="Get current admin profile")
def admin_me(
    admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    """
    Return the authenticated admin's profile, roles, and permissions.
    Disabled admins are blocked by get_current_admin before reaching here.
    """
    return {"admin": build_admin_payload(admin, db)}
