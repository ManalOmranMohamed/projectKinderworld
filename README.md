# KinderWorld

KinderWorld is a multi-module graduation project with:

- a Flutter app (`kinder_world_child_mode/`) for child, parent, and admin experiences
- a FastAPI + SQLAlchemy backend (`kinderbackend/`) with JWT auth, role-based admin APIs, and Alembic migrations

This repository is an engineering prototype with real persistence in core flows, plus a few demo/placeholder feature endpoints that are explicitly listed below.

## Architecture Overview

### High-level

```text
Flutter App (Riverpod + GoRouter + Dio)
  -> HTTP (JWT, X-Request-ID)
FastAPI Backend (routers -> services -> SQLAlchemy models)
  -> SQLite (default) or PostgreSQL (DATABASE_URL)
  -> Alembic migrations
```

### Frontend architecture (Flutter)

- Routing: modular GoRouter setup in `lib/routing/`
  - public routes, parent routes, child routes, admin routes, route guards
- State management: Riverpod providers/controllers in `lib/core/providers/`
- Network:
  - low-level transport: `lib/core/network/network_service.dart`
  - typed API clients: `lib/core/api/` (`AuthApi`, `ChildrenApi`, `SubscriptionApi`, `ReportsApi`, `AdminApi`)
- Data/storage:
  - secure tokens/session: `flutter_secure_storage`
  - local cache/state: Hive + SharedPreferences
  - offline deferred write queue: `lib/core/offline/deferred_operations_queue.dart`
- Features grouped by mode in `lib/features/`
  - `app_core`, `auth`, `child_mode`, `parent_mode`, `admin`, `system_pages`

### Backend architecture (FastAPI)

- App bootstrap: `kinderbackend/main.py`
  - middleware (CORS + request ID middleware)
  - centralized exception handlers
  - router registration
- Routers: `kinderbackend/routers/`
  - public auth, parent auth/profile/pin, children, subscription, notifications, support, privacy, parental controls
  - admin auth/RBAC/users/children/support/subscriptions/analytics/audit/settings/CMS
  - feature endpoints (reports/analytics ingestion, premium feature gates)
- Services: `kinderbackend/services/`
  - auth, child, subscription, analytics, notification, parental controls, data lifecycle
- Schemas: `kinderbackend/schemas/`
  - request/response models for auth, children, analytics, parental controls, common responses
- Core: `kinderbackend/core/`
  - validators, settings/env parsing, error helpers, exception handlers, admin RBAC/security, request-context logging
- DB:
  - SQLAlchemy models in `models.py` and `admin_models.py`
  - Alembic migrations in `kinderbackend/alembic/versions/`

## Repository Structure

```text
.
|- README.md
|- kinderbackend/
|  |- main.py
|  |- database.py
|  |- models.py
|  |- admin_models.py
|  |- routers/
|  |- services/
|  |- schemas/
|  |- core/
|  |- alembic/
|  |- requirements.txt
|  |- .env.example
|  |- pytest.ini
|  |- run_live_tests.py
|  `- test_*.py
`- kinder_world_child_mode/
   |- lib/
   |  |- app.dart
   |  |- main.dart
   |  |- router.dart
   |  |- routing/
   |  |- core/
   |  `- features/
   |- assets/
   |- test/
   |- android/
   |- ios/
   |- web/
   `- pubspec.yaml
```

## Setup

## 1) Backend (FastAPI)

From `kinderbackend/`:

```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
Copy-Item .env.example .env
```

Set at minimum in `.env`:

- `KINDER_JWT_SECRET` (required)

Then run migrations and start:

```powershell
python -m alembic upgrade head
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

Windows helper:

```powershell
start_server.bat
```

Notes:

- Default DB is local SQLite (`kinderbackend/kinder.db`) if `DATABASE_URL` is empty.
- PostgreSQL is supported by setting `DATABASE_URL`.
- Startup enforces schema/head checks unless `SKIP_SCHEMA_VERIFY=true`.

## 2) Flutter app

From `kinder_world_child_mode/`:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Notes:

- API base URL is compile-time (`String.fromEnvironment`) in `lib/core/constants/app_constants.dart`.
- If omitted, app falls back to the default value currently in code.

## 3) Android release signing (app module)

The Android module supports `key.properties`-based release signing.

Use:

```text
kinder_world_child_mode/android/key.properties.example
```

Copy to:

```text
kinder_world_child_mode/android/key.properties
```

and fill real values locally. Do not commit keystore or secrets.

## Environment Variables (Backend)

Use `kinderbackend/.env.example` as the source of truth. Key variables:

- Runtime/logging
  - `ENVIRONMENT` (`development|test|production`)
  - `APP_LOG_LEVEL`
  - `APP_LOG_FILE`
  - `SKIP_SCHEMA_VERIFY`
  - `AUTO_RUN_MIGRATIONS`
- Database
  - `DATABASE_URL`
  - `DB_POOL_SIZE`
  - `DB_MAX_OVERFLOW`
  - `DB_POOL_RECYCLE_SECONDS`
- JWT/auth
  - `KINDER_JWT_SECRET` (required)
  - `JWT_ALGORITHM`
  - `JWT_ACTIVE_KID`
  - `JWT_PREVIOUS_SECRETS`
  - legacy compatibility: `JWT_SECRET_KEY`, `SECRET_KEY`
- Email policy (optional)
  - `EMAIL_DOMAIN_ALLOWLIST`
  - `EMAIL_DOMAIN_DENYLIST`
- Child auth hardening
  - `CHILD_AUTH_RATE_LIMIT_MAX_ATTEMPTS`
  - `CHILD_AUTH_RATE_LIMIT_WINDOW_SECONDS`
  - `CHILD_AUTH_SUSPICIOUS_THRESHOLD`
  - `CHILD_SESSION_TTL_MINUTES`
  - `CHILD_AUTH_DEVICE_BINDING_ENABLED`
  - `CHILD_AUTH_REQUIRE_DEVICE_ID`
- Analytics/data lifecycle
  - `ANALYTICS_RETENTION_DAYS`
  - `ANALYTICS_SUMMARY_RETENTION_DAYS`
- Admin/dev
  - `ENABLE_ADMIN_SEED_ENDPOINT`
  - `ADMIN_SEED_SECRET`
  - `ADMIN_SEED_EMAIL`
  - `ADMIN_SEED_PASSWORD`
  - `ADMIN_SEED_NAME`
  - `ADMIN_AUTH_MAX_FAILED_ATTEMPTS`
  - `ADMIN_AUTH_LOCKOUT_MINUTES`
  - `ADMIN_SUSPICIOUS_FAILED_THRESHOLD`
  - `ADMIN_SENSITIVE_CONFIRMATION_REQUIRED`

## Features: Implemented vs Partial vs Planned

### Implemented (code-backed)

- Multi-role Flutter app with role-based navigation and route guards
- Parent auth flows (register/login/refresh/logout/profile/password)
- Child auth flows (picture password, session validation, password change)
- Child profile management (CRUD)
- Parent PIN flows
- Parent dashboards: reports, controls, notifications, settings, safety pages
- Admin auth + RBAC + management areas:
  - admins/roles/permissions
  - users
  - children
  - support tickets
  - subscriptions
  - analytics endpoints
  - audit logs
  - settings
  - CMS endpoints
- SQLAlchemy persistence for:
  - users/children/subscription/support/notifications/privacy
  - parental controls + per-child rules/lists
  - activity/progress/mood/screen-time/reward/AI interaction tracking
  - daily summary + lifecycle-oriented data structures
- Alembic migration workflow and versioned schema changes
- Structured logging foundation with request IDs (`X-Request-ID`) in backend and Flutter network layer
- Flutter offline improvements:
  - deferred operations queue (selected write flows)
  - reconnect sync hooks
  - offline-capable cached reads for selected screens

### Partially implemented / mixed (real + demo)

- `kinderbackend/routers/features.py` contains a mix:
  - reports and parental controls routes use backend data
  - some premium feature routes still return static/demo payloads:
    - `/ai/insights`
    - `/downloads/offline`
    - `/support/priority`
    - notification feature routes are simplified feature-level wrappers
- Some app UX/screens are presentation-heavy and may rely on local/mock-derived values when backend data is unavailable
- Offline deferred sync currently covers selected operations, not every mutation path

### Planned / future work

- Full device-side enforcement sync loop for parental controls
- Broader deferred-write coverage and conflict-resolution strategy
- External AI integration (replace local/demo AI placeholders)
- Production billing portal + payment workflow completion
- End-to-end observability integration (external log aggregation/crash backend)

## Running Tests

### Backend

From `kinderbackend/`:

```powershell
python -m pytest
```

Smoke/integration-style live runner (starts local server):

```powershell
python run_live_tests.py
```

### Flutter

From `kinder_world_child_mode/`:

```powershell
flutter test
```

For faster iteration, run targeted tests:

```powershell
flutter test test/admin_flow_test.dart
flutter test test/parent_pin_flow_test.dart
```

## Screenshots

Add screenshots in a future docs/assets pass.

- [TODO] Welcome / onboarding
- [TODO] Child home + learning flow
- [TODO] Parent dashboard + reports
- [TODO] Admin dashboard + management screens
- [TODO] System pages (offline/error/maintenance)

## API Surface (high-level)

Primary route groups:

- Public + parent/child auth: `/auth/*`
- Children: `/children*`
- Subscription + billing: `/subscription*`, `/billing/*`, `/plans`
- Parent features: `/notifications*`, `/privacy/*`, `/support/*`, `/parental-controls/*`, `/reports/*`, `/analytics/*`
- Admin: `/admin/auth/*`, `/admin/users*`, `/admin/children*`, `/admin/support/tickets*`, `/admin/subscriptions*`, `/admin/analytics/*`, `/admin/audit-logs`, `/admin/settings`, `/admin/categories|contents|quizzes`, `/admin/admin-users|roles|permissions`

## Current State Summary

This is a large, active prototype with meaningful backend persistence and test coverage, plus ongoing iteration in UI/UX, offline behavior, and premium/AI feature completeness. Use this README as a developer-facing map of what is currently in code, not a marketing statement.
