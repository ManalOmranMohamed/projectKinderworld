from __future__ import annotations

import os
from collections import defaultdict
from datetime import date, datetime, time, timedelta, timezone
from math import floor
from typing import Iterable

from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import (
    ChildActivityEvent,
    ChildDailyActivitySummary,
    ChildProfile,
    ChildSessionLog,
    Notification,
    PaymentMethod,
    SupportTicket,
    User,
)

TRACKED_EVENT_TYPES = {
    "activity_completed",
    "lesson_completed",
    "mood_entry",
    "achievement_unlocked",
}


class AnalyticsService:
    @staticmethod
    def _start_of_day(day: date) -> datetime:
        return datetime.combine(day, time.min)

    def _ensure_parent_child_access(
        self,
        *,
        db: Session,
        parent: User,
        child_id: int,
    ) -> ChildProfile:
        child = (
            db.query(ChildProfile)
            .filter(ChildProfile.id == child_id, ChildProfile.deleted_at.is_(None))
            .first()
        )
        if child is None:
            raise HTTPException(status_code=404, detail="Child not found")
        if child.parent_id != parent.id:
            raise HTTPException(status_code=403, detail="Forbidden")
        return child

    @staticmethod
    def _retention_days() -> int:
        try:
            value = int((os.getenv("ANALYTICS_RETENTION_DAYS") or "365").strip())
        except (TypeError, ValueError):
            value = 365
        return max(value, 30)

    def _retention_expires_at(self, occurred_at: datetime) -> datetime:
        return occurred_at + timedelta(days=self._retention_days())

    @staticmethod
    def _as_naive_utc(value: datetime) -> datetime:
        if value.tzinfo is None:
            return value
        return value.astimezone(timezone.utc).replace(tzinfo=None)

    def _get_or_create_daily_summary(
        self,
        *,
        db: Session,
        child_id: int,
        summary_date: date,
    ) -> ChildDailyActivitySummary:
        summary = (
            db.query(ChildDailyActivitySummary)
            .filter(
                ChildDailyActivitySummary.child_id == child_id,
                ChildDailyActivitySummary.summary_date == summary_date,
                ChildDailyActivitySummary.archived_at.is_(None),
            )
            .first()
        )
        if summary is not None:
            return summary
        summary = ChildDailyActivitySummary(
            child_id=child_id,
            summary_date=summary_date,
            screen_time_minutes=0,
            activities_completed=0,
            lessons_completed=0,
            mood_entries=0,
            achievements_unlocked=0,
            ai_interactions_count=0,
            data_source="realtime",
        )
        db.add(summary)
        db.flush()
        return summary

    def _increment_daily_summary(
        self,
        *,
        db: Session,
        child_id: int,
        occurred_at: datetime,
        screen_time_minutes: int = 0,
        activities_completed: int = 0,
        lessons_completed: int = 0,
        mood_entries: int = 0,
        achievements_unlocked: int = 0,
        ai_interactions_count: int = 0,
    ) -> None:
        summary = self._get_or_create_daily_summary(
            db=db,
            child_id=child_id,
            summary_date=occurred_at.date(),
        )
        summary.screen_time_minutes = max(
            int(summary.screen_time_minutes or 0) + max(screen_time_minutes, 0),
            0,
        )
        summary.activities_completed = max(
            int(summary.activities_completed or 0) + max(activities_completed, 0),
            0,
        )
        summary.lessons_completed = max(
            int(summary.lessons_completed or 0) + max(lessons_completed, 0),
            0,
        )
        summary.mood_entries = max(
            int(summary.mood_entries or 0) + max(mood_entries, 0),
            0,
        )
        summary.achievements_unlocked = max(
            int(summary.achievements_unlocked or 0) + max(achievements_unlocked, 0),
            0,
        )
        summary.ai_interactions_count = max(
            int(summary.ai_interactions_count or 0) + max(ai_interactions_count, 0),
            0,
        )
        if summary.last_event_at is None or occurred_at > summary.last_event_at:
            summary.last_event_at = occurred_at
        db.add(summary)

    def record_activity_event(self, *, db: Session, parent: User, payload) -> dict:
        if payload.event_type not in TRACKED_EVENT_TYPES:
            raise HTTPException(
                status_code=422,
                detail={
                    "code": "INVALID_ACTIVITY_EVENT_TYPE",
                    "message": f"Unsupported event_type '{payload.event_type}'",
                    "allowed_types": sorted(TRACKED_EVENT_TYPES),
                },
            )

        self._ensure_parent_child_access(db=db, parent=parent, child_id=payload.child_id)
        occurred_at = self._as_naive_utc(payload.occurred_at or datetime.utcnow())

        event = ChildActivityEvent(
            child_id=payload.child_id,
            event_type=payload.event_type,
            occurred_at=occurred_at,
            source=payload.source,
            activity_name=payload.activity_name,
            lesson_id=payload.lesson_id,
            mood_value=payload.mood_value,
            achievement_key=payload.achievement_key,
            points=payload.points,
            duration_seconds=payload.duration_seconds,
            metadata_json=payload.metadata_json,
            retention_expires_at=self._retention_expires_at(occurred_at),
        )
        db.add(event)
        self._increment_daily_summary(
            db=db,
            child_id=payload.child_id,
            occurred_at=occurred_at,
            activities_completed=1,
            lessons_completed=1 if payload.event_type == "lesson_completed" else 0,
            mood_entries=1 if payload.event_type == "mood_entry" else 0,
            achievements_unlocked=1 if payload.event_type == "achievement_unlocked" else 0,
        )
        db.commit()
        db.refresh(event)

        return {
            "event": {
                "id": event.id,
                "child_id": event.child_id,
                "event_type": event.event_type,
                "occurred_at": event.occurred_at.isoformat() if event.occurred_at else None,
            }
        }

    def record_session_log(self, *, db: Session, parent: User, payload) -> dict:
        self._ensure_parent_child_access(db=db, parent=parent, child_id=payload.child_id)
        if payload.ended_at < payload.started_at:
            raise HTTPException(
                status_code=422,
                detail="ended_at must be greater than or equal to started_at",
            )

        started_at = self._as_naive_utc(payload.started_at)
        ended_at = self._as_naive_utc(payload.ended_at)
        duration = max(int((ended_at - started_at).total_seconds()), 0)
        session_log = ChildSessionLog(
            child_id=payload.child_id,
            session_id=payload.session_id,
            source=payload.source,
            started_at=started_at,
            ended_at=ended_at,
            duration_seconds=duration,
            metadata_json=payload.metadata_json,
            retention_expires_at=self._retention_expires_at(ended_at),
        )
        db.add(session_log)
        self._increment_daily_summary(
            db=db,
            child_id=payload.child_id,
            occurred_at=started_at,
            screen_time_minutes=floor(duration / 60),
        )
        db.commit()
        db.refresh(session_log)

        return {
            "session": {
                "id": session_log.id,
                "child_id": session_log.child_id,
                "duration_seconds": session_log.duration_seconds,
                "started_at": session_log.started_at.isoformat()
                if session_log.started_at
                else None,
                "ended_at": session_log.ended_at.isoformat()
                if session_log.ended_at
                else None,
            }
        }

    def _children_for_parent(self, db: Session, parent_id: int) -> list[ChildProfile]:
        return (
            db.query(ChildProfile)
            .filter(
                ChildProfile.parent_id == parent_id,
                ChildProfile.deleted_at.is_(None),
            )
            .order_by(ChildProfile.created_at.desc(), ChildProfile.id.desc())
            .all()
        )

    @staticmethod
    def _serialize_child(child: ChildProfile) -> dict:
        return {
            "id": child.id,
            "name": child.name,
            "age": child.age,
            "avatar": child.avatar,
            "is_active": child.is_active,
            "created_at": child.created_at.isoformat() if child.created_at else None,
            "updated_at": child.updated_at.isoformat() if child.updated_at else None,
        }

    @staticmethod
    def _daily_points_template(days: int) -> list[dict]:
        today = date.today()
        points = []
        for offset in range(days - 1, -1, -1):
            day = today - timedelta(days=offset)
            points.append(
                {
                    "date": day.isoformat(),
                    "screen_time_minutes": 0,
                    "activities_completed": 0,
                    "lessons_completed": 0,
                    "data_available": False,
                }
            )
        return points

    def _aggregate_daily_points(
        self,
        *,
        db: Session,
        child_ids: Iterable[int],
        days: int,
    ) -> tuple[list[dict], dict]:
        child_ids = list(child_ids)
        points = self._daily_points_template(days)
        if not child_ids:
            return points, {"has_sessions": False, "has_events": False}

        point_by_date = {item["date"]: item for item in points}
        start_day = date.today() - timedelta(days=days - 1)
        start_dt = self._start_of_day(start_day)

        sessions = (
            db.query(ChildSessionLog)
            .filter(
                ChildSessionLog.child_id.in_(child_ids),
                ChildSessionLog.started_at >= start_dt,
                ChildSessionLog.archived_at.is_(None),
            )
            .all()
        )
        for session in sessions:
            day_key = session.started_at.date().isoformat()
            if day_key in point_by_date:
                item = point_by_date[day_key]
                item["screen_time_minutes"] += floor((session.duration_seconds or 0) / 60)
                item["data_available"] = True

        events = (
            db.query(ChildActivityEvent)
            .filter(
                ChildActivityEvent.child_id.in_(child_ids),
                ChildActivityEvent.occurred_at >= start_dt,
                ChildActivityEvent.archived_at.is_(None),
            )
            .all()
        )
        for event in events:
            day_key = event.occurred_at.date().isoformat()
            if day_key not in point_by_date:
                continue
            item = point_by_date[day_key]
            item["activities_completed"] += 1
            if event.event_type == "lesson_completed":
                item["lessons_completed"] += 1
            item["data_available"] = True

        return points, {"has_sessions": bool(sessions), "has_events": bool(events)}

    def _mood_trend(self, *, db: Session, child_ids: list[int], days: int = 14) -> list[dict]:
        if not child_ids:
            return []
        start_dt = self._start_of_day(date.today() - timedelta(days=days - 1))
        events = (
            db.query(ChildActivityEvent)
            .filter(
                ChildActivityEvent.child_id.in_(child_ids),
                ChildActivityEvent.event_type == "mood_entry",
                ChildActivityEvent.occurred_at >= start_dt,
                ChildActivityEvent.mood_value.is_not(None),
                ChildActivityEvent.archived_at.is_(None),
            )
            .all()
        )
        by_day: dict[str, list[int]] = defaultdict(list)
        for event in events:
            by_day[event.occurred_at.date().isoformat()].append(int(event.mood_value))
        points = []
        for day_key in sorted(by_day.keys()):
            values = by_day[day_key]
            points.append(
                {
                    "date": day_key,
                    "avg_mood": round(sum(values) / len(values), 2),
                    "entries": len(values),
                }
            )
        return points

    def _achievements(
        self,
        *,
        db: Session,
        child_ids: list[int],
        limit: int = 10,
    ) -> tuple[int, list[dict]]:
        if not child_ids:
            return 0, []
        rows = (
            db.query(ChildActivityEvent)
            .filter(
                ChildActivityEvent.child_id.in_(child_ids),
                ChildActivityEvent.event_type == "achievement_unlocked",
                ChildActivityEvent.archived_at.is_(None),
            )
            .order_by(ChildActivityEvent.occurred_at.desc(), ChildActivityEvent.id.desc())
            .all()
        )
        recent = []
        for event in rows[:limit]:
            recent.append(
                {
                    "child_id": event.child_id,
                    "achievement_key": event.achievement_key,
                    "activity_name": event.activity_name,
                    "occurred_at": event.occurred_at.isoformat()
                    if event.occurred_at
                    else None,
                }
            )
        return len(rows), recent

    def _child_summaries(
        self,
        *,
        db: Session,
        children: list[ChildProfile],
        days: int = 7,
    ) -> list[dict]:
        if not children:
            return []
        start_dt = self._start_of_day(date.today() - timedelta(days=days - 1))
        child_ids = [child.id for child in children]

        sessions = (
            db.query(ChildSessionLog)
            .filter(
                ChildSessionLog.child_id.in_(child_ids),
                ChildSessionLog.started_at >= start_dt,
                ChildSessionLog.archived_at.is_(None),
            )
            .all()
        )
        events = (
            db.query(ChildActivityEvent)
            .filter(
                ChildActivityEvent.child_id.in_(child_ids),
                ChildActivityEvent.occurred_at >= start_dt,
                ChildActivityEvent.archived_at.is_(None),
            )
            .all()
        )

        session_minutes_by_child: dict[int, int] = defaultdict(int)
        for item in sessions:
            session_minutes_by_child[item.child_id] += floor(
                (item.duration_seconds or 0) / 60
            )

        activities_by_child: dict[int, int] = defaultdict(int)
        lessons_by_child: dict[int, int] = defaultdict(int)
        mood_entries_by_child: dict[int, int] = defaultdict(int)
        achievements_by_child: dict[int, int] = defaultdict(int)
        for event in events:
            activities_by_child[event.child_id] += 1
            if event.event_type == "lesson_completed":
                lessons_by_child[event.child_id] += 1
            elif event.event_type == "mood_entry":
                mood_entries_by_child[event.child_id] += 1
            elif event.event_type == "achievement_unlocked":
                achievements_by_child[event.child_id] += 1

        summaries = []
        for child in children:
            summaries.append(
                {
                    "child_id": child.id,
                    "name": child.name,
                    "screen_time_minutes_7d": session_minutes_by_child.get(child.id, 0),
                    "activities_completed_7d": activities_by_child.get(child.id, 0),
                    "lessons_completed_7d": lessons_by_child.get(child.id, 0),
                    "mood_entries_7d": mood_entries_by_child.get(child.id, 0),
                    "achievements_7d": achievements_by_child.get(child.id, 0),
                }
            )
        return summaries

    def build_basic_report(self, *, db: Session, user: User) -> dict:
        children = self._children_for_parent(db, user.id)
        child_ids = [child.id for child in children]
        daily_points, presence = self._aggregate_daily_points(
            db=db,
            child_ids=child_ids,
            days=7,
        )

        unread_notifications = (
            db.query(Notification)
            .filter(Notification.user_id == user.id, Notification.is_read.is_(False))
            .count()
        )
        open_support_tickets = (
            db.query(SupportTicket)
            .filter(
                SupportTicket.user_id == user.id,
                SupportTicket.status.in_(("open", "in_progress")),
            )
            .count()
        )
        payment_methods = (
            db.query(PaymentMethod).filter(PaymentMethod.user_id == user.id).count()
        )

        summary = {
            "child_count": len(children),
            "active_child_count": sum(1 for child in children if child.is_active),
            "unread_notifications": unread_notifications,
            "open_support_tickets": open_support_tickets,
            "payment_methods_count": payment_methods,
            "screen_time_minutes_7d": sum(item["screen_time_minutes"] for item in daily_points),
            "activities_completed_7d": sum(item["activities_completed"] for item in daily_points),
            "lessons_completed_7d": sum(item["lessons_completed"] for item in daily_points),
        }

        data_availability = {
            "child_profiles": bool(children),
            "screen_time": presence["has_sessions"],
            "activities": presence["has_events"],
            "lessons": any(item["lessons_completed"] > 0 for item in daily_points),
            "mood_trends": bool(self._mood_trend(db=db, child_ids=child_ids, days=7)),
            "achievements": self._achievements(db=db, child_ids=child_ids)[0] > 0,
        }

        return {
            "reports": daily_points,
            "summary": summary,
            "children": [self._serialize_child(child) for child in children],
            "data_availability": data_availability,
            "data_source": "backend_analytics",
            "access_level": "basic",
        }

    def build_advanced_report(self, *, db: Session, user: User) -> dict:
        children = self._children_for_parent(db, user.id)
        child_ids = [child.id for child in children]
        daily_points, presence = self._aggregate_daily_points(
            db=db,
            child_ids=child_ids,
            days=30,
        )
        newest_child = children[0] if children else None

        age_distribution = {
            "5_6": sum(1 for child in children if (child.age or 0) in (5, 6)),
            "7_9": sum(1 for child in children if 7 <= (child.age or 0) <= 9),
            "10_12": sum(1 for child in children if 10 <= (child.age or 0) <= 12),
            "unknown": sum(1 for child in children if child.age is None),
        }
        mood_trends = self._mood_trend(db=db, child_ids=child_ids, days=30)
        achievement_count, recent_achievements = self._achievements(
            db=db,
            child_ids=child_ids,
            limit=10,
        )
        child_summaries = self._child_summaries(db=db, children=children, days=7)

        data_availability = {
            "child_profiles": bool(children),
            "screen_time": presence["has_sessions"],
            "activities": presence["has_events"],
            "lessons": any(item["lessons_completed"] > 0 for item in daily_points),
            "mood_trends": bool(mood_trends),
            "achievements": achievement_count > 0,
        }

        insight_notes = []
        if not presence["has_sessions"]:
            insight_notes.append("No screen-time sessions recorded yet.")
        if not presence["has_events"]:
            insight_notes.append("No activity events recorded yet.")
        if not insight_notes:
            insight_notes.append(
                "Insights are generated from recorded child activity events."
            )

        comparison = {
            "status": "available"
            if presence["has_events"] or presence["has_sessions"]
            else "not_available",
            "reason": "Built from backend-stored analytics events and session logs."
            if presence["has_events"] or presence["has_sessions"]
            else "No activity/session data has been recorded yet.",
        }

        return {
            "reports": {
                "daily_overview": daily_points,
                "children": [self._serialize_child(child) for child in children],
                "account_summary": {
                    "child_count": len(children),
                    "active_child_count": sum(1 for child in children if child.is_active),
                    "newest_child_created_at": newest_child.created_at.isoformat()
                    if newest_child and newest_child.created_at
                    else None,
                    "screen_time_minutes_30d": sum(
                        item["screen_time_minutes"] for item in daily_points
                    ),
                    "activities_completed_30d": sum(
                        item["activities_completed"] for item in daily_points
                    ),
                    "lessons_completed_30d": sum(
                        item["lessons_completed"] for item in daily_points
                    ),
                },
                "age_distribution": age_distribution,
                "data_availability": data_availability,
                "insight_notes": insight_notes,
                "comparison": comparison,
                "mood_trends": mood_trends,
                "achievements": {
                    "total_unlocked": achievement_count,
                    "recent_unlocks": recent_achievements,
                },
                "child_summaries": child_summaries,
            },
            "access_level": "advanced",
        }


analytics_service = AnalyticsService()


def record_activity_event(*, db: Session, parent: User, payload) -> dict:
    return analytics_service.record_activity_event(db=db, parent=parent, payload=payload)


def record_session_log(*, db: Session, parent: User, payload) -> dict:
    return analytics_service.record_session_log(db=db, parent=parent, payload=payload)


def build_basic_report(*, db: Session, user: User) -> dict:
    return analytics_service.build_basic_report(db=db, user=user)


def build_advanced_report(*, db: Session, user: User) -> dict:
    return analytics_service.build_advanced_report(db=db, user=user)

