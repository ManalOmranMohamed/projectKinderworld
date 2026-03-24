# Migration Workflow

## Startup Behavior

- Normal startup verifies that the database revision matches the Alembic head.
- `SKIP_SCHEMA_VERIFY=true` disables that check. Use it only for tests or controlled local work.
- `AUTO_RUN_MIGRATIONS=true` allows app startup to run `alembic upgrade head` automatically.
  Keep this off in production and run migrations explicitly in deployment instead.

## Commands

Run these from `kinderbackend/`:

```bash
alembic current
alembic heads
alembic upgrade head
alembic downgrade -1
alembic revision -m "describe_change"
```

If you work from the repo root, use:

```bash
python -m alembic -c kinderbackend/alembic.ini current
python -m alembic -c kinderbackend/alembic.ini upgrade head
```

## Conventions

- Keep one migration head. If `alembic heads` shows more than one, merge them before shipping.
- Keep migrations self-contained. Do not import runtime app modules from revision files.
- Prefer deterministic, schema-focused migrations. Data migrations are fine, but keep their logic local to the revision file.
- Use clear names: `<revision>_<short_snake_case_description>.py`.
- When changing foreign keys or nullability, verify both ORM behavior and the database-level migration.

## Reliability Checks

- `db_migrations.verify_database_schema(...)` now fails fast on multi-head state and on migration loading failures.
- Historical revision loading should work without relying on the current runtime import graph.

## Recommended Release Flow

1. Generate or edit the migration.
2. Run `alembic upgrade head` against a local/dev database.
3. Run focused tests that touch the changed schema paths.
4. Confirm `alembic heads` returns exactly one head.
5. Apply migrations in deployment before starting new app instances.
