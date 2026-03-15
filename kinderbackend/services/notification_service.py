from __future__ import annotations

from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import Notification, SupportTicket, User
from serializers import notification_to_json


class NotificationService:
    def create_notification(
        self,
        db: Session,
        *,
        user_id: int,
        type: str,
        title: str,
        body: str,
        child_id: int | None = None,
    ) -> Notification:
        notification = Notification(
            user_id=user_id,
            child_id=child_id,
            type=type,
            title=title,
            body=body,
            is_read=False,
        )
        db.add(notification)
        db.flush()
        return notification

    def notify_support_ticket_updated(
        self,
        db: Session,
        *,
        ticket: SupportTicket,
        title: str,
        body: str,
    ) -> Notification | None:
        if ticket.user_id is None:
            return None
        return self.create_notification(
            db,
            user_id=ticket.user_id,
            type="SUPPORT_TICKET_UPDATE",
            title=title,
            body=body,
        )

    def notify_subscription_changed(
        self,
        db: Session,
        *,
        user: User,
        old_plan: str,
        new_plan: str,
        source: str,
    ) -> Notification | None:
        if old_plan == new_plan:
            return None
        return self.create_notification(
            db,
            user_id=user.id,
            type="SUBSCRIPTION_UPDATED",
            title="Subscription updated",
            body=f"Your plan changed from {old_plan} to {new_plan} via {source}.",
        )

    def list_notifications(
        self,
        *,
        db: Session,
        user: User,
        limit: int,
        offset: int,
    ) -> dict:
        base_query = db.query(Notification).filter(Notification.user_id == user.id)
        query = (
            base_query.order_by(Notification.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        unread_count = base_query.filter(Notification.is_read.is_(False)).count()
        return {
            "notifications": [notification_to_json(n) for n in query.all()],
            "summary": {
                "unread_count": unread_count,
            },
        }

    def mark_all_read(self, *, db: Session, user: User) -> dict:
        db.query(Notification).filter(Notification.user_id == user.id).update(
            {"is_read": True}
        )
        db.commit()
        return {"success": True}

    def mark_read(self, *, db: Session, user: User, notification_id: int) -> dict:
        notification = (
            db.query(Notification)
            .filter(Notification.id == notification_id, Notification.user_id == user.id)
            .first()
        )
        if not notification:
            raise HTTPException(status_code=404, detail="Notification not found")
        notification.is_read = True
        db.add(notification)
        db.commit()
        return {"success": True}

    def get_basic_feature_notifications(self, *, user: User) -> dict:
        return {
            "notifications": [
                {
                    "id": 1,
                    "type": "SCREEN_TIME_LIMIT",
                    "message": "Child reached 1 hour screen time today",
                    "created_at": "2024-01-18T14:30:00Z",
                },
                {
                    "id": 2,
                    "type": "WEEKLY_SUMMARY",
                    "message": "Weekly summary ready for review",
                    "created_at": "2024-01-17T08:00:00Z",
                },
            ],
            "access_level": "basic",
        }

    def get_smart_feature_notifications(self, *, user: User) -> dict:
        return {
            "notifications": [
                {
                    "id": 1,
                    "type": "BEHAVIORAL_INSIGHT",
                    "message": "Child's usage pattern changing: 20% increase in evening usage",
                    "severity": "warning",
                    "created_at": "2024-01-18T16:00:00Z",
                },
                {
                    "id": 2,
                    "type": "ANOMALY_ALERT",
                    "message": "Unusual activity: New app installed at 2 AM",
                    "severity": "critical",
                    "created_at": "2024-01-18T02:15:00Z",
                },
            ],
            "access_level": "smart",
        }


notification_service = NotificationService()
