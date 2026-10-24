"""G2-P3: offline-only injected-session identity gate for synthetic roundtrip.

No driver, credential, connection factory, network, or actual SQL execution here.
The caller injects DB-API-like connections. Actual role login provisioning,
connection security and cleanup require independent G2 authorizations.
"""
from e6_private_pg_offline import PersistenceHold
from e6_private_roundtrip_injected_offline import synthetic_roundtrip_with_private_reader

IDENTITY_SQL = (
    "SELECT current_database(), session_user, current_user, "
    "has_schema_privilege(current_user, 'oes_raw_private', 'USAGE'), "
    "has_table_privilege(current_user, 'oes_raw_private.source_observation', 'INSERT'), "
    "has_table_privilege(current_user, 'oes_raw_private.source_observation', 'SELECT')"
)


def _identity(connection):
    try:
        with connection.cursor() as cursor:
            cursor.execute(IDENTITY_SQL)
            row = cursor.fetchone()
        if (not isinstance(row, (tuple, list)) or len(row) != 6
                or any(not isinstance(x, str) or not x for x in row[:3])
                or any(type(x) is not bool for x in row[3:])):
            raise ValueError("unverifiable")
        return tuple(row)
    except Exception:
        raise PersistenceHold("HOLD: session identity preflight failed") from None


def validate_injected_identities(writer_connection, verifier_connection):
    """Require distinct authenticated sessions and effective least-privilege roles.

    This checks the *reported* DB-session metadata, not independent evidence
    that authentication succeeded: that remains a connected G2 gate.
    """
    if (writer_connection is None or verifier_connection is None
            or writer_connection is verifier_connection):
        raise PersistenceHold("HOLD: distinct sessions required")
    writer = _identity(writer_connection)
    verifier = _identity(verifier_connection)
    wdb, wlogin, wrole, wusage, wins, wsel = writer
    vdb, vlogin, vrole, vusage, vins, vsel = verifier
    if (wdb != "oes_sandbox" or vdb != wdb
            or wlogin == vlogin or wlogin == "oes_sandbox_owner"
            or vlogin == "oes_sandbox_owner" or wlogin == "oes_e6_capture_login"
            or vlogin == "oes_e6_capture_login"
            or wrole != "oes_e6_writer" or vrole != "oes_e6_verifier"
            or (wusage, wins, wsel) != (True, True, False)
            or (vusage, vins, vsel) != (True, False, True)):
        raise PersistenceHold("HOLD: session identity or ACL mismatch")
    return None


def synthetic_g2_preflight_roundtrip(raw, provenance, writer_connection, verifier_connection):
    """Identity-gated offline orchestration. No automatic cleanup or retry."""
    validate_injected_identities(writer_connection, verifier_connection)
    return synthetic_roundtrip_with_private_reader(
        raw, provenance, writer_connection, verifier_connection
    )
