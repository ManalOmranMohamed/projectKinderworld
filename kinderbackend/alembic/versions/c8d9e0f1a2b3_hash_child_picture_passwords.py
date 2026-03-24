"""hash_child_picture_passwords

Revision ID: c8d9e0f1a2b3
Revises: b8c9d0e1f2a3
Create Date: 2026-03-23 11:15:00.000000

"""

from __future__ import annotations

import json
from typing import Sequence, Union

import bcrypt
import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision: str = "c8d9e0f1a2b3"
down_revision: Union[str, Sequence[str], None] = "b8c9d0e1f2a3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_SCHEME = "bcrypt_json_v1"


def _hash_password(value: str) -> str:
    # Keep the migration self-contained so historical revisions remain replayable.
    hashed = bcrypt.hashpw(value.encode("utf-8"), bcrypt.gensalt())
    return hashed.decode("utf-8")


def _hash_picture_password(items: list[str]) -> dict[str, str | int]:
    canonical = json.dumps(items, separators=(",", ":"), ensure_ascii=True)
    return {
        "scheme": _SCHEME,
        "hash": _hash_password(canonical),
        "length": len(items),
    }


def upgrade() -> None:
    connection = op.get_bind()
    rows = connection.execute(
        sa.text("SELECT id, picture_password FROM child_profiles")
    ).mappings()
    for row in rows:
        stored = row["picture_password"]
        if not isinstance(stored, list):
            continue
        connection.execute(
            sa.text("UPDATE child_profiles SET picture_password = :picture_password WHERE id = :id"),
            {
                "id": row["id"],
                "picture_password": json.dumps(_hash_picture_password(stored)),
            },
        )


def downgrade() -> None:
    # Password hashes cannot be safely reverted to the original raw picture sequence.
    pass
