from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


def _as_bool(value: str | None, default: bool = False) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _as_list(value: str | None) -> list[str]:
    if not value:
        return []
    return [item.strip() for item in value.split(",") if item.strip()]


def _as_int(value: str | None, default: int) -> int:
    if value is None:
        return default
    try:
        return int(value.strip())
    except (TypeError, ValueError):
        return default


@dataclass(frozen=True)
class Settings:
    environment: str
    app_log_level: str
    jwt_algorithm: str
    jwt_active_secret: str
    jwt_previous_secrets: tuple[str, ...]
    jwt_active_kid: str | None
    app_log_file: str | None
    skip_schema_verify: bool
    auto_run_migrations: bool
    admin_auth_max_failed_attempts: int
    admin_auth_lockout_minutes: int
    admin_suspicious_failed_threshold: int
    admin_sensitive_confirmation_required: bool

    @property
    def is_production(self) -> bool:
        return self.environment == "production"

    @classmethod
    def from_env(cls) -> "Settings":
        environment = os.getenv("ENVIRONMENT", "development").strip().lower()
        app_log_level = (os.getenv("APP_LOG_LEVEL") or "INFO").strip().upper()
        jwt_algorithm = os.getenv("JWT_ALGORITHM", "HS256").strip() or "HS256"
        jwt_active_secret = (
            os.getenv("KINDER_JWT_SECRET")
            or os.getenv("JWT_SECRET_KEY")
            or os.getenv("SECRET_KEY")
            or ""
        ).strip()
        previous = tuple(
            secret
            for secret in _as_list(os.getenv("JWT_PREVIOUS_SECRETS"))
            if secret and secret != jwt_active_secret
        )
        jwt_active_kid = (os.getenv("JWT_ACTIVE_KID") or "").strip() or None
        app_log_file = (os.getenv("APP_LOG_FILE") or "").strip() or None
        skip_schema_verify = _as_bool(os.getenv("SKIP_SCHEMA_VERIFY"), default=False)
        auto_run_migrations = _as_bool(os.getenv("AUTO_RUN_MIGRATIONS"), default=False)
        admin_auth_max_failed_attempts = max(
            _as_int(os.getenv("ADMIN_AUTH_MAX_FAILED_ATTEMPTS"), 5),
            1,
        )
        admin_auth_lockout_minutes = max(
            _as_int(os.getenv("ADMIN_AUTH_LOCKOUT_MINUTES"), 15),
            1,
        )
        admin_suspicious_failed_threshold = max(
            _as_int(os.getenv("ADMIN_SUSPICIOUS_FAILED_THRESHOLD"), 3),
            1,
        )
        admin_sensitive_confirmation_required = _as_bool(
            os.getenv("ADMIN_SENSITIVE_CONFIRMATION_REQUIRED"),
            default=False,
        )

        if not jwt_active_secret:
            raise ValueError(
                "JWT secret not configured. Set KINDER_JWT_SECRET "
                "(preferred) or JWT_SECRET_KEY/SECRET_KEY for compatibility."
            )
        if environment == "production" and jwt_active_secret in {
            "CHANGE_ME",
            "DEV_ONLY_SECRET",
            "TEST_ONLY_SECRET",
        }:
            raise ValueError("Production JWT secret is insecure. Use a strong random value.")

        return cls(
            environment=environment,
            app_log_level=app_log_level,
            jwt_algorithm=jwt_algorithm,
            jwt_active_secret=jwt_active_secret,
            jwt_previous_secrets=previous,
            jwt_active_kid=jwt_active_kid,
            app_log_file=app_log_file,
            skip_schema_verify=skip_schema_verify,
            auto_run_migrations=auto_run_migrations,
            admin_auth_max_failed_attempts=admin_auth_max_failed_attempts,
            admin_auth_lockout_minutes=admin_auth_lockout_minutes,
            admin_suspicious_failed_threshold=admin_suspicious_failed_threshold,
            admin_sensitive_confirmation_required=admin_sensitive_confirmation_required,
        )


settings = Settings.from_env()
