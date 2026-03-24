from __future__ import annotations

from datetime import timedelta

from core.settings import settings
from plan_service import PLAN_FREE, get_plan_catalog, get_plan_features


class SubscriptionPlansMixin:
    def list_plans(self) -> list[dict[str, object]]:
        catalog = get_plan_catalog()
        plans: list[dict[str, object]] = []
        for plan_id, details in catalog.items():
            if plan_id == PLAN_FREE:
                continue
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

    @staticmethod
    def _plan_duration(plan: str) -> timedelta:
        catalog = get_plan_catalog()
        details = catalog.get(plan, catalog[PLAN_FREE])
        period = str(details.get("period", "month")).lower()
        if period == "month":
            return timedelta(days=30)
        return timedelta(days=30)

    @staticmethod
    def _price_cents_for_plan(plan: str) -> int:
        catalog = get_plan_catalog()
        details = catalog.get(plan, catalog[PLAN_FREE])
        return int(float(details.get("price", 0)) * 100)

    @staticmethod
    def _mock_session_id(*, plan: str, user_id: int) -> str:
        if settings.is_production:
            raise RuntimeError("Mock checkout session ids are not allowed in production.")
        normalized_plan = plan.lower()
        return f"mock_session_{user_id}_{normalized_plan}"

    @classmethod
    def _build_mock_checkout(cls, *, plan: str, user_id: int) -> dict[str, str]:
        session_id = cls._mock_session_id(plan=plan, user_id=user_id)
        return {
            "session_id": session_id,
            "payment_intent_url": f"https://example.invalid/mock-checkout/{session_id}",
        }
