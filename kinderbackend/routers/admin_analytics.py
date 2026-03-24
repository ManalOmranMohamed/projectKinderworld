from __future__ import annotations

from collections import defaultdict
from datetime import date, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from admin_deps import require_permission
from core.cache_service import cache_service
from core.settings import settings
from core.time_utils import utc_start_of_day, utc_today
from deps import get_db
from models import ChildProfile, Notification, SupportTicket, User

router = APIRouter(prefix="/admin/analytics", tags=["Admin Analytics"])


def _start_of_today() -> datetime:
    return utc_start_of_day(utc_today())


def _range_days(range_name: str) -> int:
    if range_name == "week":
        return 7
    if range_name == "month":
        return 30
    raise HTTPException(status_code=400, detail="Range must be week or month")


def _bucket_label(day: date) -> str:
    return day.strftime("%b %d")


def _overview_cache_key() -> str:
    return f"admin_analytics:overview:{utc_today().isoformat()}"


def _usage_cache_key(range_name: str) -> str:
    return f"admin_analytics:usage:{range_name}:{utc_today().isoformat()}"


def _build_analytics_overview_payload(*, db: Session) -> dict[str, object]:
    today_start = _start_of_today()
    last_7_days_start = utc_start_of_day(utc_today() - timedelta(days=6))

    total_users = db.query(User).count()
    active_children = (
        db.query(ChildProfile)
        .filter(ChildProfile.is_active.is_(True), ChildProfile.deleted_at.is_(None))
        .count()
    )
    activities_today = db.query(Notification).filter(Notification.created_at >= today_start).count()
    open_tickets = (
        db.query(SupportTicket)
        .filter(SupportTicket.deleted_at.is_(None), SupportTicket.status != "closed")
        .count()
    )

    subscription_rows = db.query(User.plan, func.count(User.id)).group_by(User.plan).all()
    subscriptions_by_plan = {plan or "FREE": count for plan, count in subscription_rows}
    paid_subscriptions = sum(
        count for plan, count in subscriptions_by_plan.items() if (plan or "FREE").upper() != "FREE"
    )

    usage_summary = {
        "new_users_last_7_days": db.query(User)
        .filter(User.created_at >= last_7_days_start)
        .count(),
        "new_children_last_7_days": (
            db.query(ChildProfile)
            .filter(
                ChildProfile.created_at >= last_7_days_start,
                ChildProfile.deleted_at.is_(None),
            )
            .count()
        ),
        "tickets_last_7_days": db.query(SupportTicket)
        .filter(
            SupportTicket.created_at >= last_7_days_start,
            SupportTicket.deleted_at.is_(None),
        )
        .count(),
        "activities_last_7_days": db.query(Notification)
        .filter(Notification.created_at >= last_7_days_start)
        .count(),
    }

    recent_tickets = (
        db.query(SupportTicket)
        .filter(SupportTicket.deleted_at.is_(None), SupportTicket.status != "closed")
        .order_by(SupportTicket.updated_at.desc(), SupportTicket.created_at.desc())
        .limit(5)
        .all()
    )

    return {
        "kpis": {
            "total_users": total_users,
            "active_children": active_children,
            "activities_today": activities_today,
            "open_tickets": open_tickets,
        },
        "subscriptions_summary": {
            "by_plan": subscriptions_by_plan,
            "paid_total": paid_subscriptions,
            "free_total": subscriptions_by_plan.get("FREE", 0),
        },
        "usage_summary": usage_summary,
        "recent_tickets": [
            {
                "id": ticket.id,
                "subject": ticket.subject,
                "status": ticket.status,
                "email": ticket.email or getattr(ticket.user, "email", None),
                "updated_at": ticket.updated_at.isoformat() if ticket.updated_at else None,
            }
            for ticket in recent_tickets
        ],
    }


def _build_analytics_usage_payload(*, db: Session, range_name: str) -> dict[str, object]:
    total_days = _range_days(range_name)
    start_day = utc_today() - timedelta(days=total_days - 1)
    start_dt = utc_start_of_day(start_day)

    buckets: dict[date, dict[str, int]] = defaultdict(
        lambda: {
            "users": 0,
            "children": 0,
            "activities": 0,
            "tickets": 0,
        }
    )

    for created_at, count in (
        db.query(func.date(User.created_at), func.count(User.id))
        .filter(User.created_at >= start_dt)
        .group_by(func.date(User.created_at))
        .all()
    ):
        buckets[date.fromisoformat(created_at)]["users"] = count

    for created_at, count in (
        db.query(func.date(ChildProfile.created_at), func.count(ChildProfile.id))
        .filter(
            ChildProfile.created_at >= start_dt,
            ChildProfile.deleted_at.is_(None),
        )
        .group_by(func.date(ChildProfile.created_at))
        .all()
    ):
        buckets[date.fromisoformat(created_at)]["children"] = count

    for created_at, count in (
        db.query(func.date(Notification.created_at), func.count(Notification.id))
        .filter(Notification.created_at >= start_dt)
        .group_by(func.date(Notification.created_at))
        .all()
    ):
        buckets[date.fromisoformat(created_at)]["activities"] = count

    for created_at, count in (
        db.query(func.date(SupportTicket.created_at), func.count(SupportTicket.id))
        .filter(
            SupportTicket.created_at >= start_dt,
            SupportTicket.deleted_at.is_(None),
        )
        .group_by(func.date(SupportTicket.created_at))
        .all()
    ):
        buckets[date.fromisoformat(created_at)]["tickets"] = count

    points = []
    for offset in range(total_days):
        bucket_day = start_day + timedelta(days=offset)
        values = buckets[bucket_day]
        points.append(
            {
                "date": bucket_day.isoformat(),
                "label": _bucket_label(bucket_day),
                **values,
            }
        )

    return {
        "range": range_name,
        "points": points,
    }


@router.get("/overview")
def get_analytics_overview(
    db: Session = Depends(get_db),
    admin=Depends(require_permission("admin.analytics.view")),
):
    cache_key = _overview_cache_key()
    cached = cache_service.get_json(cache_key)
    if isinstance(cached, dict):
        return cached

    payload = _build_analytics_overview_payload(db=db)
    cache_service.set_json(
        cache_key,
        payload,
        ttl_seconds=settings.admin_analytics_cache_ttl_seconds,
    )
    return payload


@router.get("/usage")
def get_analytics_usage(
    range_name: str = Query("week", alias="range"),
    db: Session = Depends(get_db),
    admin=Depends(require_permission("admin.analytics.view")),
):
    cache_key = _usage_cache_key(range_name)
    cached = cache_service.get_json(cache_key)
    if isinstance(cached, dict):
        return cached

    payload = _build_analytics_usage_payload(db=db, range_name=range_name)
    cache_service.set_json(
        cache_key,
        payload,
        ttl_seconds=settings.admin_analytics_cache_ttl_seconds,
    )
    return payload
