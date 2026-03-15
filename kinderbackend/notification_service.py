from __future__ import annotations

from models import Notification, SupportTicket, User
from services.notification_service import notification_service


def create_notification(
    db,
    *,
    user_id: int,
    type: str,
    title: str,
    body: str,
    child_id: int | None = None,
) -> Notification:
    return notification_service.create_notification(
        db,
        user_id=user_id,
        type=type,
        title=title,
        body=body,
        child_id=child_id,
    )


def notify_support_ticket_updated(
    db,
    *,
    ticket: SupportTicket,
    title: str,
    body: str,
) -> Notification | None:
    return notification_service.notify_support_ticket_updated(
        db,
        ticket=ticket,
        title=title,
        body=body,
    )


def notify_subscription_changed(
    db,
    *,
    user: User,
    old_plan: str,
    new_plan: str,
    source: str,
) -> Notification | None:
    return notification_service.notify_subscription_changed(
        db,
        user=user,
        old_plan=old_plan,
        new_plan=new_plan,
        source=source,
    )
