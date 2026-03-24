from __future__ import annotations

"""Compatibility shim for legacy imports.

Notification logic lives in services.notification_service.
"""

from services.notification_service import (
    create_notification,
    notification_service,
    notify_subscription_changed,
    notify_support_ticket_updated,
)

__all__ = [
    "notification_service",
    "create_notification",
    "notify_support_ticket_updated",
    "notify_subscription_changed",
]
