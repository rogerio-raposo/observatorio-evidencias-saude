"""Synthetic-only A2-G4 fingerprint and JSONB adaptation boundaries.

Static source candidate: no Psycopg installation, connection, or import at
module load. The supported interchange subset is the five T1 commands, not
arbitrary Python objects accepted by generic T2-A1 Receipt.response: Any.
"""

from __future__ import annotations

from hashlib import sha256
import json
from typing import Any

from prototypes.d1.monitor import encoded
from .errors import JsonbCompatibilityError


def fingerprint(payload: dict[str, Any]) -> str:
    """Preserve the exact T1/T2-A1 fingerprint, not the DB JSONB rendering."""
    return sha256(encoded(payload).encode("utf-8")).hexdigest()


def _reject_constant(value: str) -> None:
    raise JsonbCompatibilityError(f"non-finite JSON number is not supported: {value}")


def _validate_strings(value: Any) -> None:
    if isinstance(value, str):
        if "\x00" in value or any(0xD800 <= ord(c) <= 0xDFFF for c in value):
            raise JsonbCompatibilityError("unsupported JSONB string character")
    elif isinstance(value, list):
        for part in value:
            _validate_strings(part)
    elif isinstance(value, dict):
        for key, part in value.items():
            _validate_strings(key)
            _validate_strings(part)


def jsonb_value(value: Any) -> Any:
    """Return a detached JSON-compatible value, or reject unsupported input.

    This is a conservative local boundary; it does not establish PostgreSQL
    numeric-range or encoding compatibility without separately approved tests.
    """
    try:
        normalized = json.loads(encoded(value), parse_constant=_reject_constant)
    except JsonbCompatibilityError:
        raise
    except (TypeError, ValueError, OverflowError) as exc:
        raise JsonbCompatibilityError("value is not JSON serializable") from exc
    _validate_strings(normalized)
    return normalized


def psycopg_jsonb(value: Any) -> Any:
    """Return a Psycopg Jsonb wrapper only when explicitly called later.

    Deferred import prevents the static package from requiring an installed
    database driver merely to load its modules.
    """
    normalized = jsonb_value(value)
    from psycopg.types.json import Jsonb  # type: ignore[import-not-found]
    return Jsonb(normalized)
