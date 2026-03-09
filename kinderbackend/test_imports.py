"""
Import validation test - verifies all modules load without errors.
Run from kinderbackend/ directory with the venv activated.
"""
import os
import sys

os.environ.setdefault("SECRET_KEY", "test-secret-key-for-demo-testing-only")
os.environ.setdefault("ENABLE_ADMIN_SEED_ENDPOINT", "true")
os.environ.setdefault("ADMIN_SEED_SECRET", "demo-seed-secret")

print("=" * 60)
print("KINDERWORLD BACKEND — IMPORT VALIDATION")
print("=" * 60)

errors = []

modules = [
    ("database", "database"),
    ("models", "models"),
    ("auth", "auth"),
    ("admin_auth", "admin_auth"),
    ("admin_models", "admin_models"),
    ("admin_deps", "admin_deps"),
    ("deps", "deps"),
    ("plan_service", "plan_service"),
    ("serializers", "serializers"),
    ("rate_limit", "rate_limit"),
    ("routers.auth", "routers.auth"),
    ("routers.notifications", "routers.notifications"),
    ("routers.privacy", "routers.privacy"),
    ("routers.content", "routers.content"),
    ("routers.support", "routers.support"),
    ("routers.features", "routers.features"),
    ("routers.parental_controls", "routers.parental_controls"),
    ("routers.billing_methods", "routers.billing_methods"),
    ("routers.subscription", "routers.subscription"),
    ("routers.admin_auth", "routers.admin_auth"),
    ("routers.admin_admins", "routers.admin_admins"),
    ("routers.admin_audit", "routers.admin_audit"),
    ("routers.admin_analytics", "routers.admin_analytics"),
    ("routers.admin_cms", "routers.admin_cms"),
    ("routers.admin_settings", "routers.admin_settings"),
    ("routers.admin_children", "routers.admin_children"),
    ("routers.admin_seed", "routers.admin_seed"),
    ("routers.admin_support", "routers.admin_support"),
    ("routers.admin_subscriptions", "routers.admin_subscriptions"),
    ("routers.admin_users", "routers.admin_users"),
    ("main", "main"),
]

for label, mod in modules:
    try:
        __import__(mod)
        print(f"  [OK]  {label}")
    except Exception as e:
        print(f"  [FAIL] {label}: {e}")
        errors.append((label, str(e)))

print()
if errors:
    print(f"RESULT: {len(errors)} IMPORT ERROR(S) FOUND")
    for label, err in errors:
        print(f"  - {label}: {err}")
    sys.exit(1)
else:
    print(f"RESULT: ALL {len(modules)} MODULES IMPORTED SUCCESSFULLY")
    sys.exit(0)
