from typing import List, Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from deps import get_current_user, get_db
from models import User
from services.subscription_service import subscription_service

router = APIRouter(prefix="/subscription", tags=["subscription"])
public_router = APIRouter(tags=["subscription"])
billing_router = APIRouter(prefix="/billing", tags=["subscription"])


class SubscriptionInfo(BaseModel):
    plan: str
    limits: dict
    features: dict


class SubscriptionChange(BaseModel):
    plan: str


class PlanOut(BaseModel):
    id: str
    name: str
    price: float
    period: str
    features: dict


class SubscriptionStatus(BaseModel):
    current_plan_id: str
    is_active: bool
    expires_at: Optional[str] = None
    will_renew: Optional[bool] = None


class SubscriptionSelectRequest(BaseModel):
    plan_id: str | None = Field(
        None,
        description="Plan id: FREE|PREMIUM|FAMILY_PLUS",
    )
    plan_type: str | None = Field(
        None,
        description="Alias for plan_id (Flutter compat): free|premium|family_plus",
    )

    @property
    def resolved_plan(self) -> str:
        raw = self.plan_id or self.plan_type or ""
        return raw.strip().upper().replace("-", "_")


class SubscriptionSelectResponse(SubscriptionStatus):
    payment_intent_url: Optional[str] = None
    session_id: Optional[str] = None


@router.get("/me", response_model=SubscriptionInfo)
def get_subscription(user: User = Depends(get_current_user)):
    return subscription_service.get_subscription(user=user)


@router.post("/upgrade", response_model=SubscriptionInfo)
def upgrade_subscription(
    payload: SubscriptionChange,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return subscription_service.upgrade_subscription(payload=payload, db=db, user=user)


@router.post("/cancel", response_model=SubscriptionInfo)
def cancel_subscription(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return subscription_service.cancel_subscription(db=db, user=user)


@public_router.get("/plans", response_model=List[PlanOut])
def list_plans():
    return subscription_service.list_plans()


@router.get("", response_model=SubscriptionStatus)
def subscription_status(user: User = Depends(get_current_user)):
    return subscription_service.subscription_status(user=user)


@router.post("/select", response_model=SubscriptionSelectResponse)
def select_subscription(
    payload: SubscriptionSelectRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return subscription_service.select_subscription(payload=payload, db=db, user=user)


@router.post("/activate", response_model=SubscriptionSelectResponse)
def activate_subscription(
    payload: SubscriptionSelectRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return subscription_service.activate_subscription(payload=payload, db=db, user=user)


@router.post("/manage")
def manage_subscription(user: User = Depends(get_current_user)):
    return subscription_service.manage_subscription(user=user)


@billing_router.post("/portal")
def billing_portal(user: User = Depends(get_current_user)):
    return subscription_service.billing_portal(user=user)
