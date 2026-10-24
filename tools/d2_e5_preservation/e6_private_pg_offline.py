"""Offline-only, dependency-free PostgreSQL parameter builder for OES E6.

No connection, network, credential handling, or implicit execution.
The caller supplies a DB-API connection already authorized separately.
"""
import hashlib
from dataclasses import dataclass
from datetime import datetime
from typing import Any

MAX_BYTES = 2_000_000
INSERT_SQL = (
    "INSERT INTO oes_raw_private.source_observation "
    "(observation_id, activity_id, repository_commit_sha, github_run_id, "
    "run_attempt, source_name, requested_url_exact, started_at_utc, "
    "completed_at_utc, source_http_status, response_content_type, "
    "payload_sha256, payload_bytes, raw_payload) "
    "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
)
FIELDS = (
    "observation_id", "activity_id", "repository_commit_sha", "github_run_id",
    "run_attempt", "source_name", "requested_url_exact", "started_at_utc",
    "completed_at_utc", "source_http_status", "response_content_type",
)


class PersistenceHold(ValueError):
    """Sanitized failure; never embeds input or DB exception text."""


@dataclass(frozen=True)
class PreparedObservation:
    statement: str
    parameters: tuple
    sha256: str
    byte_count: int
    observation_id: str


def prepare_observation(raw: bytes, provenance: dict[str, Any]) -> PreparedObservation:
    if not isinstance(raw, bytes) or not 0 < len(raw) <= MAX_BYTES:
        raise PersistenceHold("HOLD: invalid raw byte count")
    if not isinstance(provenance, dict) or any(k not in provenance for k in FIELDS):
        raise PersistenceHold("HOLD: missing provenance")
    if any(provenance[k] is None or isinstance(provenance[k], (dict, list, bytes)) for k in FIELDS):
        raise PersistenceHold("HOLD: invalid provenance")
    if any(not isinstance(provenance[k], str) or not provenance[k].strip() for k in (
        "observation_id", "activity_id", "repository_commit_sha",
        "requested_url_exact", "response_content_type"
    )):
        raise PersistenceHold("HOLD: invalid provenance strings")
    if provenance["source_name"] != "ClinicalTrials.gov API v2":
        raise PersistenceHold("HOLD: invalid source")
    if type(provenance["github_run_id"]) is not int or provenance["github_run_id"] <= 0:
        raise PersistenceHold("HOLD: invalid run id")
    if type(provenance["run_attempt"]) is not int or provenance["run_attempt"] <= 0:
        raise PersistenceHold("HOLD: invalid run attempt")
    if type(provenance["source_http_status"]) is not int or provenance["source_http_status"] != 200:
        raise PersistenceHold("HOLD: invalid response status")
    if not provenance["response_content_type"].lower().split(';', 1)[0].strip() == "application/json":
        raise PersistenceHold("HOLD: invalid content type")
    start, end = provenance["started_at_utc"], provenance["completed_at_utc"]
    if (not isinstance(start, datetime) or not isinstance(end, datetime)
            or start.tzinfo is None or end.tzinfo is None
            or start.utcoffset() is None or end.utcoffset() is None or end < start):
        raise PersistenceHold("HOLD: invalid timestamps")
    digest = hashlib.sha256(raw).hexdigest()
    values = tuple(provenance[k] for k in FIELDS) + (digest, len(raw), raw)
    return PreparedObservation(INSERT_SQL, values, digest, len(raw), provenance["observation_id"])


def persist_observation(connection: Any, prepared: PreparedObservation) -> dict[str, Any]:
    """Execute under caller-managed, non-autocommit DB-API transaction.

    No SQL readback, no commit on failure; the caller must not reuse a failed
    transaction. Connection factory and credentials intentionally out of scope.
    """
    if not isinstance(prepared, PreparedObservation) or prepared.statement != INSERT_SQL:
        raise PersistenceHold("HOLD: invalid prepared observation")
    if (len(prepared.parameters) != len(FIELDS) + 3
            or prepared.byte_count < 1 or prepared.byte_count > MAX_BYTES
            or not isinstance(prepared.parameters[-1], bytes)
            or prepared.byte_count != len(prepared.parameters[-1])
            or prepared.parameters[-2] != prepared.byte_count
            or hashlib.sha256(prepared.parameters[-1]).hexdigest() != prepared.sha256
            or prepared.parameters[-3] != prepared.sha256
            or prepared.parameters[0] != prepared.observation_id):
        raise PersistenceHold("HOLD: prepared integrity mismatch")
    try:
        if connection.autocommit:
            raise PersistenceHold("HOLD: autocommit forbidden")
        with connection.cursor() as cursor:
            cursor.execute(prepared.statement, prepared.parameters)
        connection.commit()
    except Exception:
        try:
            connection.rollback()
        except Exception:
            pass
        raise PersistenceHold("HOLD: private persistence failed") from None
    return {"status": "PRIVATE_PERSISTED_UNVERIFIED", "observation_id": prepared.observation_id,
            "sha256": prepared.sha256, "payload_bytes": prepared.byte_count}
