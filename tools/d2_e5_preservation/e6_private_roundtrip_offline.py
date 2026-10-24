"""Offline synthetic orchestration; no driver, connection factory or network calls.

Writer and verifier are injected separately. Never expose retrieved raw bytes.
A committed write followed by failed verification is HOLD, not rollback.
"""
import hashlib
import hmac
from typing import Callable, Any

from e6_private_pg_offline import PersistenceHold, prepare_observation, persist_observation


def verify_private_readback(readback: Any, observation_id: str, expected_digest: str,
                            expected_size: int) -> None:
    """Validate private reader's (id, digest, length, raw_bytes) tuple."""
    if (not isinstance(readback, tuple) or len(readback) != 4
            or not isinstance(readback[0], str)
            or not isinstance(readback[1], str)
            or type(readback[2]) is not int
            or not isinstance(readback[3], bytes)):
        raise PersistenceHold("HOLD: invalid private readback")
    ident, stored_digest, stored_size, raw = readback
    actual = hashlib.sha256(raw).hexdigest()
    if (ident != observation_id or stored_size != expected_size
            or len(raw) != expected_size
            or not hmac.compare_digest(stored_digest, expected_digest)
            or not hmac.compare_digest(actual, expected_digest)):
        raise PersistenceHold("HOLD: private readback integrity mismatch")


def synthetic_private_roundtrip(raw: bytes, provenance: dict,
                                writer_connection: Any,
                                independent_reader: Callable[[str], tuple]) -> dict:
    """Mockable two-identity flow. Reader callable must enforce separate identity.

    No automatic cleanup. On readback HOLD the write may already be committed:
    caller must quarantine and investigate before reattempting.
    """
    if not callable(independent_reader):
        raise PersistenceHold("HOLD: independent verifier unavailable")
    prepared = prepare_observation(raw, provenance)
    persist_observation(writer_connection, prepared)
    try:
        result = independent_reader(prepared.observation_id)
        verify_private_readback(result, prepared.observation_id,
                                prepared.sha256, prepared.byte_count)
    except Exception:
        raise PersistenceHold("HOLD: private verification failed; write may be committed") from None
    return {"status": "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE",
            "observation_id": prepared.observation_id,
            "sha256": prepared.sha256, "payload_bytes": prepared.byte_count}
