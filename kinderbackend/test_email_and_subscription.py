"""
Tests for email normalization and subscription endpoints.

Run with: pytest test_email_and_subscription.py -v
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool

from auth import create_access_token, hash_password
from database import Base, SessionLocal
from main import app
from models import User
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
    def override_get_db():
        return db

    from deps import get_db
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def test_register_normalizes_email(client: TestClient, db):
    response = client.post(
        "/auth/register",
        json={
            "name": "Case User",
            "email": "Case.User@Gmail.COM",
            "password": "Password123!",
            "confirmPassword": "Password123!",
        },
    )

    assert response.status_code == 200
    user = db.query(User).filter(User.name == "Case User").first()
    assert user is not None
    assert user.email == "case.user@gmail.com"


def test_register_accepts_non_gmail_when_no_allowlist(client: TestClient, db):
    response = client.post(
        "/auth/register",
        json={
            "name": "Any Domain User",
            "email": "person@yahoo.com",
            "password": "Password123!",
            "confirmPassword": "Password123!",
        },
    )

    assert response.status_code == 200
    user = db.query(User).filter(User.name == "Any Domain User").first()
    assert user is not None
    assert user.email == "person@yahoo.com"


def test_register_respects_email_allowlist_policy(client: TestClient, monkeypatch):
    monkeypatch.setenv("EMAIL_DOMAIN_ALLOWLIST", "example.com")
    monkeypatch.delenv("EMAIL_DOMAIN_DENYLIST", raising=False)

    blocked = client.post(
        "/auth/register",
        json={
            "name": "Blocked Domain",
            "email": "blocked@gmail.com",
            "password": "Password123!",
            "confirmPassword": "Password123!",
        },
    )
    assert blocked.status_code == 400
    assert blocked.json()["detail"] == "Email domain is not allowed by policy"

    allowed = client.post(
        "/auth/register",
        json={
            "name": "Allowed Domain",
            "email": "allowed@example.com",
            "password": "Password123!",
            "confirmPassword": "Password123!",
        },
    )
    assert allowed.status_code == 200


def test_login_accepts_uppercase_email(client: TestClient):
    register = client.post(
        "/auth/register",
        json={
            "name": "Login Case",
            "email": "Login.Case@Gmail.COM",
            "password": "Password123!",
            "confirmPassword": "Password123!",
        },
    )
    assert register.status_code == 200

    response = client.post(
        "/auth/login",
        json={
            "email": "LOGIN.CASE@GMAIL.COM",
            "password": "Password123!",
        },
    )
    assert response.status_code == 200
    assert "access_token" in response.json()


def test_subscription_endpoints(client: TestClient, db):
    user = User(
        email="sub@example.com",
        password_hash=hash_password("Password123!"),
        name="Sub User",
        plan=PLAN_FREE,
        role="parent",
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(str(user.id))

    plans_response = client.get("/plans")
    assert plans_response.status_code == 200
    plans = plans_response.json()
    assert isinstance(plans, list)
    assert any(plan["id"] == PLAN_FREE for plan in plans)

    status_response = client.get(
        "/subscription",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert status_response.status_code == 200
    status = status_response.json()
    assert status["current_plan_id"] == PLAN_FREE
    assert status["is_active"] is True

    select_free = client.post(
        "/subscription/select",
        json={"plan_id": "free"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert select_free.status_code == 200
    db.refresh(user)
    assert user.plan == PLAN_FREE

    select_paid = client.post(
        "/subscription/select",
        json={"plan_id": PLAN_PREMIUM},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert select_paid.status_code == 200
    paid_payload = select_paid.json()
    assert paid_payload["current_plan_id"] == PLAN_PREMIUM
    assert paid_payload["session_id"]



