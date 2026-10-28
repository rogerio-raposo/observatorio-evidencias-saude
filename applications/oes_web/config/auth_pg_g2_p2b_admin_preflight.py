"""G2-P2-B administrative preflight specification; offline assertions only.

No connection creation, settings opt-in, execution entrypoint or write operation.
The caller must establish evidence from an independently authorized session.
"""
from config.auth_pg_g2_p2b_offline import (
    CONNECTED_BASELINE, ProvisioningHold,
)

EXPECTED_IDENTITY = (
    "oes_sandbox", "oes_auth_migrator", "oes_auth_migrator",
    "django_auth", "django_auth",
)
REQUIRED_TABLES = frozenset({
    "auth_permission", "auth_user", "auth_user_user_permissions",
    "preparer_identity_prepareridentity",
})
REQUIRED_SEQUENCES = frozenset({
    "auth_permission_id_seq", "auth_user_id_seq",
    "auth_user_user_permissions_id_seq",
    "preparer_identity_prepareridentity_id_seq",
})


def assert_administrative_preflight(*, identity, baseline, insert_tables,
                                    delete_tables, usage_sequences,
                                    content_type_count, permission_absent):
    """Pure verifier of an administrative evidence snapshot; not authorization.

    All sets must be exact and separately collected for current_user.
    """
    if tuple(identity) != EXPECTED_IDENTITY:
        raise ProvisioningHold("HOLD: administrative identity or schema mismatch")
    if type(baseline) is not dict or baseline != CONNECTED_BASELINE:
        raise ProvisioningHold("HOLD: administrative baseline mismatch")
    if (set(insert_tables) != REQUIRED_TABLES
            or set(delete_tables) != REQUIRED_TABLES
            or set(usage_sequences) != REQUIRED_SEQUENCES):
        raise ProvisioningHold("HOLD: administrative privileges mismatch")
    if content_type_count != 1 or permission_absent is not True:
        raise ProvisioningHold("HOLD: evidence permission prerequisites mismatch")
    return "PASS_ADMIN_PREFLIGHT_CONTRACT_OFFLINE_ONLY"
