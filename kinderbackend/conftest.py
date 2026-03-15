import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool

# Ensure tests have deterministic auth/admin env defaults before app imports.
os.environ.setdefault("SECRET_KEY", "TEST_ONLY_SECRET")
os.environ.setdefault("KINDER_JWT_SECRET", os.environ["SECRET_KEY"])
os.environ.setdefault("ENABLE_ADMIN_SEED_ENDPOINT", "true")
os.environ.setdefault("ADMIN_SEED_SECRET", "TEST_ONLY_SECRET")
os.environ.setdefault("ADMIN_SEED_PASSWORD", "CHANGE_ME")
os.environ.setdefault("ADMIN_SEED_EMAIL", "change-me@example.invalid")
os.environ.setdefault("ADMIN_SEED_NAME", "DEV ONLY ADMIN")
os.environ.setdefault("SKIP_SCHEMA_VERIFY", "true")


@pytest.fixture(scope="session")
def test_db():
    from database import Base
    import models  # noqa: F401
    import admin_models  # noqa: F401

    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    return engine


@pytest.fixture
def db(test_db):
    from database import SessionLocal

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
    from main import app

    def override_get_db():
        return db

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture(autouse=True)
def reset_global_state():
    # Keep tests independent if/when route dependencies start using this state.
    from rate_limit import rate_limiter
    from services.child_service import _DEVICE_BINDINGS, _FAILED_ATTEMPTS

    rate_limiter.requests.clear()
    _FAILED_ATTEMPTS.clear()
    _DEVICE_BINDINGS.clear()
    yield
    rate_limiter.requests.clear()
    _FAILED_ATTEMPTS.clear()
    _DEVICE_BINDINGS.clear()
