from __future__ import annotations

from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import User
from plan_service import (
    PLAN_FREE,
    get_plan_catalog,
    get_plan_features,
    get_plan_limits,
    get_user_plan,
    validate_plan_value,
)
from services.notification_service import notification_service


class SubscriptionService:
    def get_subscription(self, *, user: User) -> dict:
        plan = get_user_plan(user)
        return {
            "plan": plan,
            "limits": get_plan_limits(plan),
            "features": get_plan_features(plan),
        }

    def upgrade_subscription(self, *, payload, db: Session, user: User) -> dict:
        previous_plan = get_user_plan(user)
        try:
            plan = validate_plan_value(payload.plan)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid plan")

        user.plan = plan
        db.add(user)
        db.commit()
        db.refresh(user)
        notification_service.notify_subscription_changed(
            db,
            user=user,
            old_plan=previous_plan,
            new_plan=plan,
            source="parent_upgrade",
        )
        db.commit()

        return {
            "plan": plan,
            "limits": get_plan_limits(plan),
            "features": get_plan_features(plan),
        }

    def cancel_subscription(self, *, db: Session, user: User) -> dict:
        previous_plan = get_user_plan(user)
        user.plan = PLAN_FREE
        db.add(user)
        db.commit()
        db.refresh(user)
        notification_service.notify_subscription_changed(
            db,
            user=user,
            old_plan=previous_plan,
            new_plan=PLAN_FREE,
            source="parent_cancel",
        )
        db.commit()

        return {
            "plan": PLAN_FREE,
            "limits": get_plan_limits(PLAN_FREE),
            "features": get_plan_features(PLAN_FREE),
        }

    def list_plans(self) -> list[dict]:
        catalog = get_plan_catalog()
        plans = []
        for plan_id, details in catalog.items():
            plans.append(
                {
                    "id": details["id"],
                    "name": details["name"],
                    "price": details["price"],
                    "period": details["period"],
                    "features": get_plan_features(plan_id),
                }
            )
        return plans

    def subscription_status(self, *, user: User) -> dict:
        plan = get_user_plan(user)
        return {
            "current_plan_id": plan,
            "is_active": bool(user.is_active),
            "expires_at": None,
            "will_renew": None,
        }

    def select_subscription(self, *, payload, db: Session, user: User) -> dict:
        requested = payload.resolved_plan
        if not requested:
            raise HTTPException(
                status_code=422, detail="plan_id or plan_type is required"
            )
        catalog = get_plan_catalog()
        if requested not in catalog:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid plan '{requested}'. Valid: {list(catalog.keys())}",
            )

        plan = requested
        previous_plan = get_user_plan(user)
        user.plan = plan
        db.add(user)
        db.commit()
        db.refresh(user)
        notification_service.notify_subscription_changed(
            db,
            user=user,
            old_plan=previous_plan,
            new_plan=plan,
            source="parent_select",
        )
        db.commit()

        response = {
            "current_plan_id": plan,
            "is_active": True,
            "expires_at": None,
            "will_renew": False,
        }
        if plan != PLAN_FREE:
            response.update(self._build_mock_checkout(plan=plan, user_id=user.id))
        return response

    def activate_subscription(self, *, payload, db: Session, user: User) -> dict:
        return self.select_subscription(payload=payload, db=db, user=user)

    def manage_subscription(self, *, user: User) -> dict:
        raise HTTPException(
            status_code=501,
            detail="Billing portal is not configured yet",
        )

    def billing_portal(self, *, user: User) -> dict:
        raise HTTPException(
            status_code=501,
            detail="Billing portal is not configured yet",
        )

    @staticmethod
    def _build_mock_checkout(plan: str, user_id: int) -> dict[str, str]:
        normalized_plan = plan.lower()
        session_id = f"mock_session_{user_id}_{normalized_plan}"
        return {
            "session_id": session_id,
            "payment_intent_url": f"https://example.invalid/mock-checkout/{session_id}",
        }


subscription_service = SubscriptionService()
