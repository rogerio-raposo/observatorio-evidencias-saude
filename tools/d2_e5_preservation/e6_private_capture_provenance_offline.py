"""Synthetic/offline-only E6 capture provenance adapter for private storage.

Converts legacy capture metadata into the private PostgreSQL preparation
contract. Does not call capture, connect, persist, publish or use credentials.
"""
from datetime import datetime, timezone
from typing import Any

from e6_private_pg_offline import PersistenceHold, prepare_observation

SOURCE_NAME = "ClinicalTrials.gov API v2"
ACTIVITY_ID = "OES/D2-E6-A2/CONTROLLED_FACTUAL_CAPTURE"


def _utc_timestamp(value: Any) -> datetime:
    if not isinstance(value, str) or not value.strip():
        raise PersistenceHold("HOLD: invalid capture timestamp")
    try:
        parsed = datetime.fromisoformat(value)
        if parsed.tzinfo is None or parsed.utcoffset() is None:
            raise ValueError("naive timestamp")
        return parsed.astimezone(timezone.utc)
    except (ValueError, OverflowError):
        raise PersistenceHold("HOLD: invalid capture timestamp") from None


def prepare_capture_for_private_storage(
    raw: bytes, *, observation_id: str, repository_commit_sha: str,
    github_run_id: int, run_attempt: int, requested_url_exact: str,
    started_at_utc: str, completed_at_utc: str,
    response_content_type: str,
):
    """Prepare only; never perform GET, SQL, publication, or a connection.

    All metadata must be supplied explicitly by the caller. The source and
    activity are fixed by this scoped E6 adapter, never inferred from JSON.
    """
    meta = {
        "observation_id": observation_id,
        "activity_id": ACTIVITY_ID,
        "repository_commit_sha": repository_commit_sha,
        "github_run_id": github_run_id,
        "run_attempt": run_attempt,
        "source_name": SOURCE_NAME,
        "requested_url_exact": requested_url_exact,
        "started_at_utc": _utc_timestamp(started_at_utc),
        "completed_at_utc": _utc_timestamp(completed_at_utc),
        "source_http_status": 200,
        "response_content_type": response_content_type,
    }
    return prepare_observation(raw, meta)
