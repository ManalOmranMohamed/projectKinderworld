from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from deps import get_current_user, get_db
from models import User
from rate_limit import auth_rate_limit
from schemas.auth import (
    ChildChangePasswordIn,
    ChildLoginIn,
    ChildRegisterIn,
    ChildSessionValidateIn,
    LoginIn,
    RefreshIn,
    RegisterIn,
)
from serializers import user_to_json
from services.auth_service import login_parent, refresh_parent_access_token, register_parent
from services.child_service import (
    change_child_password,
    login_child,
    register_child,
    validate_child_session,
)

router = APIRouter()


@router.post("/auth/register")
def register(
    payload: RegisterIn,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    return register_parent(payload, db)


@router.post("/auth/login")
def login(
    payload: LoginIn,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    return login_parent(payload, db)


@router.post("/auth/refresh")
def refresh(
    payload: RefreshIn,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    return refresh_parent_access_token(payload, db)


@router.post("/auth/child/register")
def child_register(
    payload: ChildRegisterIn,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    return register_child(payload, db)


@router.post("/auth/child/login")
def child_login(
    payload: ChildLoginIn,
    request: Request,
    db: Session = Depends(get_db),
    rate_limit_check: None = Depends(auth_rate_limit),
):
    client_ip = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("User-Agent")
    return login_child(payload, db, client_ip=client_ip, user_agent=user_agent)


@router.post("/auth/child/session/validate")
def child_session_validate(
    payload: ChildSessionValidateIn,
    db: Session = Depends(get_db),
):
    return validate_child_session(payload, db)


@router.post("/auth/child/change-password")
def child_change_password(
    payload: ChildChangePasswordIn,
    db: Session = Depends(get_db),
):
    return change_child_password(payload, db)


@router.get("/auth/me")
def me(user: User = Depends(get_current_user)):
    return {"user": user_to_json(user)}
