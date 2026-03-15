# Kinder World

Kinder World is a multi-role educational and parental-control platform built with Flutter and FastAPI.

The project currently contains:

- A Flutter application for public onboarding, parent mode, child mode, and admin mode
- A FastAPI backend for authentication, child/parent management, subscriptions, support, analytics, and admin operations
- Automated backend and Flutter checks through GitHub Actions

This README is based on the current codebase, not on legacy documentation.

## Overview

Kinder World is structured around three distinct user contexts:

- `Parent`: manages children, views reports, controls privacy and parental settings, handles support tickets, and manages subscription state
- `Child`: signs in using a picture-password-based flow and uses a child-facing learning/play experience
- `Admin`: uses a separate authentication system and RBAC permission model to manage users, children, content, support, subscriptions, analytics, and system settings

The project is split into:

- `kinderbackend/`: FastAPI backend with SQLAlchemy models, service-layer logic, and pytest tests
- `kinder_world_child_mode/`: Flutter client with Riverpod, GoRouter, local storage, and widget/unit tests

## Key Features

### Parent Flows

- Parent registration, login, refresh, logout
- Parent profile update and password change
- Parent PIN setup, verification, change, and reset request
- Child profile creation, update, listing, and deletion
- Parent dashboard, reports, notifications, privacy settings, and parental controls
- Support ticket creation, history, detail, and replies
- Subscription plan selection, activation, and basic billing-method management

### Child Flows

- Child registration and login endpoints
- Picture-password-based child auth flow
- Child session validation
- Child change-password flow
- Child-facing routes for home, learning, play, AI buddy, profile, achievements, and store

### Admin Flows

- Dedicated admin login, refresh, logout, and profile retrieval
- RBAC-protected admin routes
- Admin user management
- Admin child management
- Admin analytics overview and usage endpoints
- Admin audit log access
- Admin support ticket triage and replies
- Admin CMS/content/category/quiz management
- Admin subscription management
- Admin system settings
- Optional admin seed endpoint for development/test environments

### Platform / Cross-Cutting

- Request ID middleware
- Centralized exception handling
- Maintenance mode guard
- Feature/plan gating on selected backend endpoints
- Local-first storage in Flutter using Hive and secure/session storage

## Architecture Summary

### Backend

The backend follows a practical layered structure:

- `routers/`: HTTP endpoints and request wiring
- `services/`: domain/business logic
- `schemas/`: request/response validation with Pydantic
- `models.py` + `admin_models.py`: SQLAlchemy models
- `deps.py` / `admin_deps.py`: auth, RBAC, and database dependencies
- `core/`: logging, settings, exception handling, system settings, validators, security helpers

The current backend architecture is service-oriented rather than purely endpoint-driven. Recent refactors moved substantial logic out of routers into services, especially in admin auth and support flows.

### Frontend

The Flutter app uses:

- `Riverpod` for state and dependency injection
- `GoRouter` for navigation and access guards
- `Hive` for local JSON-based persistence
- `SharedPreferences` for preference/state flags
- `SecureStorage` for auth/session data
- Local-first loading patterns with background sync in selected areas

The app is organized by feature domains:

- `features/app_core`
- `features/auth`
- `features/child_mode`
- `features/parent_mode`
- `features/admin`
- `features/system_pages`

## Tech Stack

### Backend

- Python
- FastAPI
- SQLAlchemy
- Pydantic v2
- Alembic
- pytest
- python-jose
- bcrypt
- SQLite by default, PostgreSQL supported via `DATABASE_URL`

### Frontend

- Flutter
- Dart
- flutter_riverpod
- go_router
- dio
- hive / hive_flutter
- flutter_secure_storage
- shared_preferences
- logger
- fl_chart

### Tooling / CI

- GitHub Actions
- `dart analyze`
- `flutter test`
- `pytest`

## Project Structure

```text
.
├── .github/
│   └── workflows/
│       ├── backend-ci.yml
│       └── flutter-ci.yml
├── kinderbackend/
│   ├── alembic/
│   ├── core/
│   ├── routers/
│   ├── schemas/
│   ├── services/
│   ├── admin_models.py
│   ├── auth.py
│   ├── conftest.py
│   ├── database.py
│   ├── deps.py
│   ├── main.py
│   ├── models.py
│   ├── pytest.ini
│   └── test_*.py
└── kinder_world_child_mode/
    ├── assets/
    ├── lib/
    │   ├── core/
    │   ├── features/
    │   ├── routing/
    │   ├── app.dart
    │   ├── main.dart
    │   └── router.dart
    ├── test/
    ├── pubspec.yaml
    └── analysis_options.yaml
```

## Authentication & Roles

### Parent Authentication

Parent auth uses JWT-based access and refresh tokens.

Current parent auth-related backend endpoints include:

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `GET /auth/me`
- `PUT /auth/profile`
- `POST /auth/change-password`
- `POST /auth/logout`

Additional parent security flows:

- `GET /auth/parent-pin/status`
- `POST /auth/parent-pin/set`
- `POST /auth/parent-pin/verify`
- `POST /auth/parent-pin/change`
- `POST /auth/parent-pin/reset-request`

The current code includes token-version-based revocation checks for access and refresh flows.

### Child Authentication

Child auth is separate from parent auth and includes:

- `POST /auth/child/register`
- `POST /auth/child/login`
- `POST /auth/child/session/validate`
- `POST /auth/child/change-password`

Child login uses a picture-password flow. Child session behavior exists in both backend and Flutter, but the implementation is not identical in all places and should be treated as an actively evolving area.

### Admin Authentication

Admin auth is fully separate from parent/child auth:

- `POST /admin/auth/login`
- `POST /admin/auth/refresh`
- `POST /admin/auth/logout`
- `GET /admin/auth/me`

Admin access is protected through RBAC permissions enforced by backend dependencies and mirrored in Flutter route guards/UI visibility.

### Roles in Current Code

- `parent`
- `child`
- `admin` users with role/permission mappings in the admin subsystem

## Backend Overview

### Main App

Backend entrypoint: `kinderbackend/main.py`

The app currently includes routers for:

- public auth
- parent auth
- children
- notifications
- privacy
- content/legal
- support
- subscriptions
- billing methods
- feature-gated reports/notifications/parental-controls/AI/downloads
- admin auth
- admin users
- admin children
- admin analytics
- admin audit
- admin support
- admin CMS
- admin subscriptions
- admin settings
- optional admin seed

### Database Behavior

- Default local database: `sqlite:///kinder.db`
- PostgreSQL URLs are normalized to `postgresql+psycopg://...`
- SQLite pragmas are configured for WAL / busy timeout / foreign keys
- Alembic is present for migrations
- Startup schema verification exists and can be skipped with env flags

### Notable Backend Modules

- `services/auth_service.py`: parent auth, profile, password, parent PIN
- `services/child_service.py`: child registration/login/session/password and child profile operations
- `services/support_ticket_service.py`: parent/admin support flows
- `services/admin_auth_service.py`: admin auth flow and security logic
- `services/subscription_service.py`: subscription state and plan selection logic
- `services/analytics_service.py`: analytics ingestion and report construction
- `core/system_settings.py`: maintenance mode, registration toggle, AI buddy toggle, default feature flags

### Feature Flags / System Toggles Present in Code

The system settings layer currently defines these defaults:

- `maintenance_mode`
- `registration_enabled`
- `ai_buddy_enabled`
- `feature_flags.support_center`
- `feature_flags.analytics_dashboard`
- `feature_flags.cms`

These are backend-side settings, not a full frontend feature-flag platform.

## Frontend Overview

### App Entry

Flutter entrypoint: `kinder_world_child_mode/lib/main.dart`

Startup behavior currently includes:

- Hive initialization
- opening key local boxes
- secure storage preload
- shared preferences init
- logger injection
- app-level error handling

### Routing

GoRouter routes are split into:

- `routes_public.dart`
- `routes_parent.dart`
- `routes_child.dart`
- `routes_admin.dart`

Routing guards currently enforce:

- public vs authenticated entry
- parent vs child separation
- admin auth state
- admin permission checks
- parent PIN protection for parent routes

### Storage / State

The current app uses:

- `Hive` boxes for cached child/profile/progress-related data
- `SecureStorage` for auth/session data
- `SharedPreferences` for preference and UI-related persisted state
- Riverpod providers for repositories, controllers, and feature services

### Main Frontend Areas

- `features/app_core`: splash, language, onboarding, welcome
- `features/auth`: parent/child auth screens
- `features/child_mode`: child home, learn, play, AI buddy, profile, store, achievements
- `features/parent_mode`: dashboard, reports, controls, settings, subscription, notifications, safety
- `features/admin`: admin login and admin dashboard sections
- `features/system_pages`: maintenance, help, legal, no-internet, data sync, error

## Testing

### Backend

Backend tests use `pytest` with shared fixtures in `kinderbackend/conftest.py`.

Current backend suite characteristics:

- test files live directly under `kinderbackend/`
- DB tests use an in-memory SQLite engine through shared fixtures
- auth/admin/RBAC/support/subscription/parent-child flows are covered

Local command:

```bash
cd kinderbackend
python -m pytest -q
```

On the current code snapshot, the backend suite passes locally with `98 passed`.

### Flutter

Flutter tests live under `kinder_world_child_mode/test/` and include:

- unit tests
- repository/session tests
- widget tests
- routing/startup tests
- admin/parent/child flow tests

Local commands:

```bash
cd kinder_world_child_mode
dart analyze
flutter test
```

Current state from local verification on this code snapshot:

- `dart analyze` completes, but still reports one `info` suggestion
- the full `flutter test` suite is **not fully green yet**; it currently has remaining failing tests
- several targeted tests and newer regression tests do pass, but the full suite should be treated as still in stabilization

## Running the Project Locally

## 1. Backend Setup

### Prerequisites

- Python 3.11 recommended
- pip
- optional: PostgreSQL if you do not want SQLite

### Install

```bash
cd kinderbackend
python -m venv .venv
```

Windows:

```bash
.venv\Scripts\activate
```

Linux/macOS:

```bash
source .venv/bin/activate
```

Then install dependencies:

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Configure Environment

Create a `.env` file in `kinderbackend/` based on `.env.example`.

At minimum, set:

```env
KINDER_JWT_SECRET=CHANGE_ME_TO_A_REAL_SECRET
```

Optional but commonly useful for local dev:

```env
ENVIRONMENT=development
DATABASE_URL=
SKIP_SCHEMA_VERIFY=false
AUTO_RUN_MIGRATIONS=false
```

If `DATABASE_URL` is empty, the backend falls back to local SQLite at `kinderbackend/kinder.db`.

### Run Backend

```bash
cd kinderbackend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend root endpoint:

- `GET /` → basic health response

### Run Backend Tests

```bash
cd kinderbackend
python -m pytest -q
```

## 2. Flutter Setup

### Prerequisites

- Flutter SDK
- Dart SDK bundled with Flutter
- Android Studio / Xcode / Chrome depending on target platform

The project currently declares:

- Dart: `>=3.0.0 <4.0.0`
- Flutter: `>=3.10.0`

### Install Dependencies

```bash
cd kinder_world_child_mode
flutter pub get
```

### Configure Backend URL

The app supports overriding the backend base URL with a Dart define:

```bash
flutter run --dart-define=API_BASE_URL=http://<HOST>:8000
```

This is important because the current default fallback in code is a LAN IP address, which is not suitable for most environments.

### Run the App

```bash
cd kinder_world_child_mode
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### Analyze / Test

```bash
cd kinder_world_child_mode
dart analyze
flutter test
```

## Environment Variables

## Backend (`kinderbackend/.env`)

The codebase currently recognizes at least the following environment variables.

### Runtime / Logging

- `ENVIRONMENT`
- `APP_LOG_FILE`
- `APP_LOG_LEVEL`
- `SKIP_SCHEMA_VERIFY`
- `AUTO_RUN_MIGRATIONS`

### Database

- `DATABASE_URL`
- `DB_POOL_SIZE`
- `DB_MAX_OVERFLOW`
- `DB_POOL_RECYCLE_SECONDS`

### JWT / Auth

- `KINDER_JWT_SECRET`
- `JWT_SECRET_KEY`
- `SECRET_KEY`
- `JWT_ALGORITHM`
- `JWT_ACTIVE_KID`
- `JWT_PREVIOUS_SECRETS`

### Email Policy

- `EMAIL_DOMAIN_ALLOWLIST`
- `EMAIL_DOMAIN_DENYLIST`

### Child Auth Hardening

- `CHILD_AUTH_RATE_LIMIT_MAX_ATTEMPTS`
- `CHILD_AUTH_RATE_LIMIT_WINDOW_SECONDS`
- `CHILD_AUTH_SUSPICIOUS_THRESHOLD`
- `CHILD_SESSION_TTL_MINUTES`
- `CHILD_AUTH_DEVICE_BINDING_ENABLED`
- `CHILD_AUTH_REQUIRE_DEVICE_ID`

### Analytics Lifecycle

- `ANALYTICS_RETENTION_DAYS`
- `ANALYTICS_SUMMARY_RETENTION_DAYS`

### Admin Seed / Admin Security

- `ENABLE_ADMIN_SEED_ENDPOINT`
- `ADMIN_SEED_SECRET`
- `ADMIN_SEED_PASSWORD`
- `ADMIN_SEED_EMAIL`
- `ADMIN_SEED_NAME`
- `ADMIN_AUTH_MAX_FAILED_ATTEMPTS`
- `ADMIN_AUTH_LOCKOUT_MINUTES`
- `ADMIN_SUSPICIOUS_FAILED_THRESHOLD`
- `ADMIN_SENSITIVE_CONFIRMATION_REQUIRED`

## Frontend

The frontend currently uses one important build-time setting:

- `API_BASE_URL`

Example:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## API / Main Modules Summary

### Parent / Auth

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `GET /auth/me`
- `PUT /auth/profile`
- `POST /auth/change-password`
- `POST /auth/logout`
- parent PIN endpoints under `/auth/parent-pin/*`

### Child

- `POST /auth/child/register`
- `POST /auth/child/login`
- `POST /auth/child/session/validate`
- `POST /auth/child/change-password`
- `/children` CRUD for parent-owned child profiles

### Parent Features

- `/notifications`
- `/privacy/settings`
- `/parental-controls/*`
- `/support/*`
- `/subscription/*`
- `/billing/methods`
- `/reports/basic`
- `/reports/advanced`
- `/analytics/events`
- `/analytics/sessions`

### Feature-Gated / Plan-Based Endpoints

- `/notifications/basic`
- `/notifications/smart`
- `/parental-controls/basic`
- `/parental-controls/advanced`
- `/ai/insights`
- `/downloads/offline`
- `/support/priority`

### Admin

- `/admin/auth/*`
- `/admin/users*`
- `/admin/children*`
- `/admin/analytics/*`
- `/admin/audit-logs`
- `/admin/support/tickets*`
- `/admin/categories`
- `/admin/contents`
- `/admin/quizzes`
- `/admin/subscriptions*`
- `/admin/settings*`
- optional `/admin/seed`

## CI

The repository currently includes GitHub Actions workflows:

- `.github/workflows/backend-ci.yml`
- `.github/workflows/flutter-ci.yml`

### Backend CI

Runs on backend changes and currently performs:

- dependency installation
- Python source compile check
- import smoke test
- full pytest suite

### Flutter CI

Runs on Flutter changes and currently performs:

- `flutter pub get`
- `dart analyze`
- `flutter test`

Important: the Flutter workflow exists in code, but because the full Flutter test suite is not fully green on the current snapshot, Flutter CI should be expected to fail until the remaining test issues are resolved.

## Current Status / Known Limitations

These points are based on the current codebase behavior.

- Backend test suite is in better shape than the full Flutter test suite.
- The Flutter app still uses a hardcoded LAN IP fallback for `API_BASE_URL` if no `--dart-define` is supplied.
- Billing portal functionality is not fully implemented:
  - `POST /subscription/manage` returns `501`
  - `POST /billing/portal` returns `501`
- Some content/legal/help endpoints are static text/data rather than a full dynamic CMS-backed public content system.
- Some premium/family endpoints currently return fixed/demo-style payloads rather than deeply integrated external services:
  - AI insights
  - offline downloads
  - priority support metadata
- The backend has system flags for maintenance mode, registration toggle, and AI buddy availability, but not every feature toggle path is part of a complete frontend admin control surface yet.
- The codebase still contains technical debt warnings such as deprecated FastAPI startup event usage and multiple `datetime.utcnow()` usages in Python.
- Full Flutter tests currently have remaining failures related to test harness/provider setup in some widget tests.

## Future Improvements

Based on the current code structure, reasonable next improvements would be:

- Stabilize the remaining Flutter widget/integration tests so `flutter test` is fully green
- Replace the default hardcoded Flutter API base URL fallback with environment-specific configuration
- Complete billing portal and real payment-provider integration
- Replace placeholder/static public legal/help content with managed content where needed
- Continue extracting complex UI/state logic from large Flutter screens into smaller controllers/services
- Migrate deprecated backend startup patterns to FastAPI lifespan APIs
- Reduce remaining `datetime.utcnow()` deprecation warnings by moving to timezone-aware datetimes
- Expand CI with coverage reporting and optional artifacts

## Notes

This README intentionally reflects the current codebase, including unfinished or placeholder areas. It should be treated as a technical status document for contributors, reviewers, and academic evaluation rather than a marketing page.
