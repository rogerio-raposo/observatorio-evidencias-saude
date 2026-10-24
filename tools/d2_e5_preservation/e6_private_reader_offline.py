"""Offline-only private verifier reader; caller injects a restricted DB-API connection.

No driver imports, connection creation, network calls, role switching or logging.
The returned raw bytes must remain inside the trusted verification boundary.
"""
from typing import Any

from e6_private_pg_offline import PersistenceHold

READ_SQL = (
    "SELECT observation_id, payload_sha256, payload_bytes, raw_payload "
    "FROM oes_raw_private.source_observation WHERE observation_id = %s"
)


def read_private_observation(connection: Any, observation_id: str) -> tuple[str, str, int, bytes]:
    """Return a private tuple to verify_private_readback; NEVER print/serialize it.

    Caller must supply a verifier-only connection. This function does not
    prove the database role or authenticate independently; those are G2 gates.
    """
    if not isinstance(observation_id, str) or not observation_id.strip():
        raise PersistenceHold("HOLD: invalid observation id")
    if connection is None:
        raise PersistenceHold("HOLD: private verifier unavailable")
    try:
        with connection.cursor() as cursor:
            cursor.execute(READ_SQL, (observation_id,))
            row = cursor.fetchone()
        if (not isinstance(row, (tuple, list)) or len(row) != 4
                or not isinstance(row[0], str) or row[0] != observation_id
                or not isinstance(row[1], str)
                or type(row[2]) is not int
                or not isinstance(row[3], bytes)):
            raise PersistenceHold("HOLD: private readback unavailable or malformed")
        return (row[0], row[1], row[2], row[3])
    except Exception:
        # Never propagate DB exceptions: they might contain SQL or payload.
        raise PersistenceHold("HOLD: private readback failed") from None
