"""Offline synthetic adapter: connect an injected verifier to the E6 roundtrip.

No connection factory, driver, HTTP, role switching, secrets, or file writes.
Caller is responsible for independent verifier identity at any later G2 gate.
"""
from typing import Any

from e6_private_pg_offline import PersistenceHold
from e6_private_reader_offline import read_private_observation
from e6_private_roundtrip_offline import synthetic_private_roundtrip


def synthetic_roundtrip_with_private_reader(
    raw: bytes, provenance: dict, writer_connection: Any, verifier_connection: Any
) -> dict:
    """Run the existing roundtrip using a DB-API-like injected private reader.

    This is an *offline interface*, not proof of independent DB authentication.
    Never return the raw readback outside the internal verification call.
    """
    if writer_connection is None or verifier_connection is None:
        raise PersistenceHold("HOLD: separate injected connections required")
    if writer_connection is verifier_connection:
        raise PersistenceHold("HOLD: writer and verifier must be distinct objects")
    def private_read(observation_id: str) -> tuple:
        return read_private_observation(verifier_connection, observation_id)
    return synthetic_private_roundtrip(raw, provenance, writer_connection, private_read)
