from __future__ import annotations

import logging

from sqlalchemy import inspect
from sqlalchemy.engine import Engine

EXPECTED_TABLES = {
    "admin_user_roles",
    "admin_users",
    "audit_logs",
    "categories",
    "child_profiles",
    "contents",
    "notifications",
    "parental_controls",
    "payment_methods",
    "permissions",
    "privacy_settings",
    "quizzes",
    "role_permissions",
    "roles",
    "support_ticket_messages",
    "support_tickets",
    "system_settings",
    "users",
}


def verify_database_schema(engine: Engine, logger: logging.Logger) -> None:
    inspector = inspect(engine)
    table_names = set(inspector.get_table_names())
    missing_tables = sorted(EXPECTED_TABLES - table_names)

    if missing_tables:
        raise RuntimeError(
            "Database schema is incomplete. Run 'python -m alembic upgrade head' "
            f"before starting the app. Missing tables: {', '.join(missing_tables)}"
        )

    if "alembic_version" not in table_names:
        logger.warning(
            "Legacy database detected without alembic version tracking. "
            "After backing up the database, run 'python -m alembic stamp head' once "
            "to align Alembic with the current schema."
        )
