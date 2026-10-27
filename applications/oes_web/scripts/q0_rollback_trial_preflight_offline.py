"""Offline-only preflight for a future, separately authorized Django Q0 rollback trial.

Never connects, configures a database, or enables the dormant ORM repository.
No executable connected trial is exposed by this module.
"""
from dataclasses import dataclass
from hashlib import sha256
from uuid import UUID, uuid4


class TrialHold(ValueError):
    """Fail-closed trial preflight rejection."""


@dataclass(frozen=True)
class SyntheticQ0Trial:
    actor_id: str
    request_id: str
    question_id: str
    original_text: str
    fingerprint: str
    entity_uuid: UUID
    version_uuid: UUID
    target_alias: str = "oes_qprep_trial"
    expected_insert_count: int = 5
    rollback_required: bool = True


def prepare_synthetic_q0_trial(*, actor_id: str, request_id: str,
                               question_id: str, original_text: str) -> SyntheticQ0Trial:
    """Validate prospective identifiers offline; create no DB connection."""
    for label, value in (("actor_id", actor_id), ("request_id", request_id)):
        if not isinstance(value, str) or not (1 <= len(value) <= 128) or not value.strip():
            raise TrialHold(f"HOLD: invalid {label}")
    for label, value in (("question_id", question_id), ("original_text", original_text)):
        if not isinstance(value, str) or not value.strip():
            raise TrialHold(f"HOLD: invalid {label}")
    if not question_id.startswith("OES-SYNTH-Q0-"):
        raise TrialHold("HOLD: only synthetic question identifiers")
    payload = "\x1f".join((actor_id, request_id, question_id, original_text))
    fingerprint = sha256(payload.encode("utf-8")).hexdigest()
    return SyntheticQ0Trial(actor_id, request_id, question_id, original_text,
                            fingerprint, uuid4(), uuid4())


def execute_connected_q0_rollback_trial(*args, **kwargs):
    """Intentionally blocked: G2-P2B is NO-GO; no database entrypoint."""
    raise TrialHold("HOLD: connected Django Q0 rollback trial not authorized; G2-P2B NO-GO")
