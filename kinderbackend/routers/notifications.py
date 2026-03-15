from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from deps import get_current_user, get_db
from models import User
from schemas.common import SuccessResponse
from services.notification_service import notification_service

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("")
def list_notifications(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return notification_service.list_notifications(
        db=db,
        user=user,
        limit=limit,
        offset=offset,
    )


@router.post("/mark-all-read", response_model=SuccessResponse)
def mark_all_read(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return notification_service.mark_all_read(db=db, user=user)


@router.post("/{notification_id}/read", response_model=SuccessResponse)
def mark_read(
    notification_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return notification_service.mark_read(
        db=db,
        user=user,
        notification_id=notification_id,
    )
