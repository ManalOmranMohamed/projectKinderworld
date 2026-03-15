from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool
from datetime import datetime, timedelta, timezone

import admin_models  # noqa: F401
import pytest

from auth import create_access_token, hash_password
from database import Base, SessionLocal
from main import app
from models import ChildActivityEvent, ChildProfile, ChildSessionLog, Notification, PaymentMethod, SupportTicket, User
from plan_service import PLAN_FREE, PLAN_PREMIUM


@pytest.fixture(scope="session")
def test_db():
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    return engine


@pytest.fixture
def db(test_db):
    connection = test_db.connect()
    transaction = connection.begin()
    session = SessionLocal(bind=connection)
    yield session
    session.close()
    if transaction.is_active:
        transaction.rollback()
    connection.close()


@pytest.fixture
def client(db):
    from deps import get_db

    def override_get_db():
        return db

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def _create_parent(db, *, email: str, plan: str) -> User:
    user = User(
        email=email,
        password_hash=hash_password("Password123!"),
        name="Report Parent",
        role="parent",
        is_active=True,
        plan=plan,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def _headers(user: User) -> dict[str, str]:
    token = create_access_token(str(user.id), getattr(user, "token_version", 0))
    return {"Authorization": f"Bearer {token}"}


def test_basic_reports_returns_dynamic_parent_summary(client: TestClient, db):
    parent = _create_parent(db, email="reports-basic@example.com", plan=PLAN_FREE)
    db.add_all(
        [
            ChildProfile(
                parent_id=parent.id,
                name="Dana",
                picture_password=["cat", "dog", "apple"],
                age=7,
                avatar="av1",
                is_active=True,
            ),
            ChildProfile(
                parent_id=parent.id,
                name="Lina",
                picture_password=["sun", "moon", "star"],
                age=9,
                avatar="av2",
                is_active=False,
            ),
            Notification(
                user_id=parent.id,
                type="SYSTEM",
                title="Unread",
                body="Unread body",
                is_read=False,
            ),
            SupportTicket(
                user_id=parent.id,
                subject="Need help",
                message="Testing report summary",
                status="open",
            ),
            PaymentMethod(
                user_id=parent.id,
                label="Visa ending 1111",
            ),
        ]
    )
    db.commit()

    response = client.get("/reports/basic", headers=_headers(parent))

    assert response.status_code == 200
    payload = response.json()
    assert payload["access_level"] == "basic"
    assert payload["data_source"] == "backend_analytics"
    assert payload["summary"]["child_count"] == 2
    assert payload["summary"]["active_child_count"] == 1
    assert payload["summary"]["unread_notifications"] == 1
    assert payload["summary"]["open_support_tickets"] == 1
    assert payload["summary"]["payment_methods_count"] == 1
    assert len(payload["children"]) == 2
    assert payload["data_availability"]["screen_time"] is False
    assert payload["summary"]["screen_time_minutes_7d"] == 0


def test_advanced_reports_returns_dynamic_profile_metadata(client: TestClient, db):
    parent = _create_parent(db, email="reports-advanced@example.com", plan=PLAN_PREMIUM)
    db.add_all(
        [
            ChildProfile(
                parent_id=parent.id,
                name="Adam",
                picture_password=["cat", "dog", "apple"],
                age=5,
                avatar="av1",
                is_active=True,
            ),
            ChildProfile(
                parent_id=parent.id,
                name="Sara",
                picture_password=["sun", "moon", "star"],
                age=10,
                avatar="av2",
                is_active=True,
            ),
        ]
    )
    db.commit()

    response = client.get("/reports/advanced", headers=_headers(parent))

    assert response.status_code == 200
    payload = response.json()
    assert payload["access_level"] == "advanced"
    reports = payload["reports"]
    assert reports["account_summary"]["child_count"] == 2
    assert reports["age_distribution"]["5_6"] == 1
    assert reports["age_distribution"]["10_12"] == 1
    assert reports["comparison"]["status"] == "not_available"
    assert reports["data_availability"]["activities"] is False


def test_reports_with_recorded_analytics_data(client: TestClient, db):
    parent = _create_parent(db, email="reports-analytics@example.com", plan=PLAN_PREMIUM)
    child = ChildProfile(
        parent_id=parent.id,
        name="Nora",
        picture_password=["cat", "dog", "apple"],
        age=8,
        avatar="av1",
        is_active=True,
    )
    db.add(child)
    db.commit()
    db.refresh(child)

    start = datetime.now(timezone.utc).replace(microsecond=0)
    end = start + timedelta(minutes=20)

    session_resp = client.post(
        "/analytics/sessions",
        json={
            "child_id": child.id,
            "session_id": "sess-1",
            "source": "child_mode",
            "started_at": start.isoformat().replace("+00:00", "Z"),
            "ended_at": end.isoformat().replace("+00:00", "Z"),
        },
        headers=_headers(parent),
    )
    assert session_resp.status_code == 200

    lesson_resp = client.post(
        "/analytics/events",
        json={
            "child_id": child.id,
            "event_type": "lesson_completed",
            "lesson_id": "lesson_math_01",
            "activity_name": "Numbers",
            "occurred_at": (start + timedelta(minutes=10)).isoformat().replace("+00:00", "Z"),
        },
        headers=_headers(parent),
    )
    assert lesson_resp.status_code == 200

    mood_resp = client.post(
        "/analytics/events",
        json={
            "child_id": child.id,
            "event_type": "mood_entry",
            "mood_value": 4,
            "occurred_at": (start + timedelta(minutes=12)).isoformat().replace("+00:00", "Z"),
        },
        headers=_headers(parent),
    )
    assert mood_resp.status_code == 200

    achievement_resp = client.post(
        "/analytics/events",
        json={
            "child_id": child.id,
            "event_type": "achievement_unlocked",
            "achievement_key": "first_lesson",
            "occurred_at": (start + timedelta(minutes=15)).isoformat().replace("+00:00", "Z"),
        },
        headers=_headers(parent),
    )
    assert achievement_resp.status_code == 200

    basic = client.get("/reports/basic", headers=_headers(parent))
    assert basic.status_code == 200
    basic_payload = basic.json()
    assert basic_payload["data_availability"]["screen_time"] is True
    assert basic_payload["data_availability"]["activities"] is True
    assert basic_payload["data_availability"]["lessons"] is True
    assert basic_payload["summary"]["screen_time_minutes_7d"] >= 20
    assert basic_payload["summary"]["lessons_completed_7d"] >= 1

    advanced = client.get("/reports/advanced", headers=_headers(parent))
    assert advanced.status_code == 200
    reports = advanced.json()["reports"]
    assert reports["data_availability"]["mood_trends"] is True
    assert reports["data_availability"]["achievements"] is True
    assert reports["comparison"]["status"] == "available"
    assert reports["achievements"]["total_unlocked"] >= 1
    assert len(reports["mood_trends"]) >= 1
    assert len(reports["child_summaries"]) == 1

    assert db.query(ChildSessionLog).count() == 1
    assert db.query(ChildActivityEvent).count() == 3



