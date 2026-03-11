# Kinder World

## Overview

**Kinder World** is a graduation project that combines:

- a Flutter application for child, parent, and admin-facing flows
- a FastAPI backend for authentication, profile management, settings, subscriptions, and admin APIs

The repository is an active prototype rather than a finished production system. Some parts are fully connected to the backend and database, while other parts are still UI-first, locally simulated, or backed by static demo data.

## Current Status

### Implemented and present in the codebase

- Parent registration, login, logout, profile update, and password change
- Child profile creation, listing, update, deletion, child login, and picture-password change
- Parent features backed by persistent API endpoints:
  - privacy settings
  - parental controls
  - support ticket submission
  - billing method CRUD
  - subscription state and plan selection
  - notification listing and read actions
- Admin backend with:
  - dedicated admin authentication
  - RBAC roles and permissions
  - audit logging
  - user, child, support, subscription, analytics, content, settings, and admin management routers
- Flutter app structure for:
  - onboarding and authentication
  - child mode
  - parent dashboard and settings
  - admin portal routing and screens
  - Arabic and English localization
  - Android, iOS, and Web project targets
- Alembic migration setup for backend schema management
- Automated tests for Flutter admin flow and backend API coverage

### Implemented but still demo-oriented or partial

- `AI Buddy` in the Flutter app is **not connected to an AI service**. It generates replies locally inside the app using simulated logic.
- Subscription selection is **demo mode**. `/subscription/select` activates plans immediately and returns a `mock_session_*` value instead of using a real payment gateway.
- Billing portal endpoints exist but currently return `501 Not Implemented`.
- Several feature-gated backend endpoints return fixed demo payloads rather than real analytics or AI output, such as:
  - `/reports/basic`
  - `/reports/advanced`
  - `/notifications/basic`
  - `/notifications/smart`
  - `/parental-controls/basic`
  - `/parental-controls/advanced`
  - `/ai/insights`
  - `/downloads/offline`
  - `/support/priority`
- Some app sections are UI-complete but still use local/static content rather than CMS-driven backend content, especially in child learning and play flows.
- Some legal/help/about content is still placeholder text from the backend or localization files.
- Billing management screen in Flutter is present, but the screen itself states that billing management is coming soon.

## Repository Structure

```text
Graduation Project/
├─ README.md
├─ kinderbackend/                 # FastAPI backend
│  ├─ alembic/
│  ├─ routers/
│  ├─ main.py
│  ├─ models.py
│  ├─ admin_models.py
│  ├─ database.py
│  ├─ db_migrations.py
│  ├─ requirements.txt
│  ├─ .env.example
│  └─ test_*.py
└─ kinder_world_child_mode/       # Flutter app
   ├─ lib/
   ├─ assets/
   ├─ test/
   ├─ android/
   ├─ ios/
   ├─ web/
   └─ pubspec.yaml
```

## Main Application Areas

### Flutter Application

The Flutter project is organized by feature area:

- `lib/features/auth`: parent/child login, registration, and forgot-password flows
- `lib/features/child_mode`: home, learn, play, AI Buddy, profile, paywall
- `lib/features/parent_mode`: dashboard, child management, reports, controls, notifications, settings, subscription
- `lib/features/admin`: admin login, dashboard shell, users, children, content, reports, subscriptions, admins, audit, support, settings
- `lib/core`: providers, repositories, services, models, theme, localization, storage, networking

### Backend Service

The FastAPI backend provides:

- parent and child auth flows
- child profile management
- subscription and plan logic
- privacy and parental control settings
- notifications and support tickets
- billing method management
- admin authentication and RBAC-protected admin endpoints

## Technology Stack

### Frontend

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Hive
- Flutter Secure Storage
- Freezed / JSON Serializable
- FL Chart

### Backend

- Python
- FastAPI
- SQLAlchemy
- Alembic
- Pydantic
- SQLite by default
- PostgreSQL support through `DATABASE_URL`
- JWT authentication with `python-jose`

## Local Setup

### 1. Backend Setup

From [`kinderbackend`](/c:/Graduation%20Project/kinderbackend):

```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
Copy-Item .env.example .env
```

### Environment Notes

- If `DATABASE_URL` is not set, the backend falls back to a local SQLite database at `kinderbackend/kinder.db`.
- The sample `.env.example` is written for PostgreSQL. If you want to use SQLite locally, leave `DATABASE_URL` unset in `.env`.
- `main.py` loads environment variables automatically from `.env`.

### Database Migration

The backend checks the schema on startup and fails if required tables are missing. Run migrations before starting the server:

```powershell
python -m alembic upgrade head
```

### Run the API

```powershell
python -m uvicorn main:app --reload
```

Default local API URL:

```text
http://127.0.0.1:8000
```

### Optional: Seed an Admin Account

Admin seeding is disabled by default in `.env.example`. If you enable it:

- set `ENABLE_ADMIN_SEED_ENDPOINT=true`
- set `ADMIN_SEED_SECRET`
- set `ADMIN_SEED_PASSWORD`

Then call:

```text
POST /admin/seed?secret=YOUR_SECRET
```

This seeds roles, permissions, and a default super admin.

### 2. Flutter Setup

From [`kinder_world_child_mode`](/c:/Graduation%20Project/kinder_world_child_mode):

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### Notes

- The app uses `API_BASE_URL` via `--dart-define`.
- The fallback API URL currently hardcoded in the app points to a local network IP, so overriding it during local development is strongly recommended.
- Generated model files are already committed. If models change, regenerate them with:

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

### Backend

From [`kinderbackend`](/c:/Graduation%20Project/kinderbackend):

```powershell
python -m pytest
```

Backend test files currently present:

- `test_auth_and_features.py`
- `test_change_password_compat.py`
- `test_email_and_subscription.py`
- `test_imports.py`

### Flutter

From [`kinder_world_child_mode`](/c:/Graduation%20Project/kinder_world_child_mode):

```powershell
flutter test
```

Flutter test files currently present:

- `test/widget_test.dart`
- `test/admin_flow_test.dart`

### Verification During README Rewrite

- `flutter test` ran successfully in the current workspace.
- Backend tests did not run cleanly in the current local environment because `httpx` was missing from the active virtual environment during collection. This should be resolved after a clean `pip install -r requirements.txt`.

## Backend API Areas

The backend currently exposes routes in these areas:

- authentication: parent auth, child auth, logout, profile update, password change
- children: create, list, update, delete
- subscription: plan catalog, current plan, upgrade, cancel, select, activate, billing portal placeholder
- notifications: list, mark one read, mark all read
- privacy: get and update settings
- parental controls: get and update settings
- billing methods: list, add, delete
- support: contact support
- content/legal/help: basic informational endpoints
- admin: auth, users, children, support, subscriptions, analytics, CMS, settings, audit, admins, seed

## What Is Actually Persistent Today

These backend-backed areas write to the database:

- parent accounts
- child profiles
- privacy settings
- parental controls
- support tickets
- billing methods
- notifications read state
- admin users, roles, permissions, and audit logs

These areas exist but are currently not production-complete:

- AI companion features
- payment processing
- billing portal
- advanced analytics
- smart notifications
- offline download management
- dynamic legal/CMS content rollout in the mobile app

## Current Limitations

- `AI Buddy` is simulated in the Flutter app and does not call any AI model or external AI API.
- Subscription upgrades are demo-only and do not process real payments.
- Some premium feature endpoints return static sample data instead of real analytics.
- Child learning and play content is largely asset-driven and hardcoded in the app UI.
- Billing management is not finished end-to-end.
- Some legal, privacy, and help text is still placeholder content.
- No production deployment configuration is documented in this repository yet.
- The current repository does not include a frontend `.env.example`; API configuration is passed through `--dart-define`.

## Future Improvements

- Integrate a real AI service for `AI Buddy` with safety controls suitable for children.
- Replace mock subscription activation with a real payment provider and billing portal.
- Move more child content from hardcoded/local UI structures to backend-managed content.
- Expand real analytics and reporting instead of static demo responses.
- Complete legal/help/CMS content management and connect it cleanly to the mobile app.
- Add broader automated test coverage for parent flows, child flows, and admin backend endpoints.
- Document deployment for production-like environments.

## Graduation Project Positioning

In its current form, **Kinder World** is best described as a substantial graduation-project prototype with:

- a real multi-role application structure
- a working backend with database persistence for core account and settings flows
- an admin architecture with RBAC and audit logging
- a mobile app that demonstrates child, parent, and admin user journeys

It should not be described as a fully production-ready platform yet, especially for AI, billing, analytics, and dynamic content delivery.
