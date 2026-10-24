"""G2-I1 metadata-only private authentication test; never run until approved.

No observation INSERT/DELETE/SELECT; no payload. No credentials or DSNs logged.
The workflow remains hard-disabled independently of this script.
"""
import os
import sys

REQUIRED = ("OES_G2_HOST", "OES_G2_WRITER_PASSWORD", "OES_G2_VERIFIER_PASSWORD")
IDENTITIES = (
    ("oes_e6_g2_writer_tmp", "oes_e6_writer", "OES_G2_WRITER_PASSWORD", (True, True, False)),
    ("oes_e6_g2_verifier_tmp", "oes_e6_verifier", "OES_G2_VERIFIER_PASSWORD", (True, False, True)),
)
SQL = (
    "SELECT current_database(), session_user, current_user, "
    "has_schema_privilege(current_user, 'oes_raw_private', 'USAGE'), "
    "has_table_privilege(current_user, 'oes_raw_private.source_observation', 'INSERT'), "
    "has_table_privilege(current_user, 'oes_raw_private.source_observation', 'SELECT')"
)


def sanitized_failure(exc, phase):
    """Return categories only; never print exception text, host, user or secrets."""
    code = getattr(exc, "sqlstate", None)
    if code in ("28P01", "28000"):
        return "AUTHENTICATION"
    if code == "42501":
        return "PRIVILEGE"
    if code == "42704":
        return "ROLE_MISSING"
    return "CONNECTION_OR_TLS" if phase == "connect" else "ROLE_OR_METADATA"


def run():
    if any(not os.environ.get(k) for k in REQUIRED):
        return "MISSING_CONFIGURATION"
    host = os.environ["OES_G2_HOST"]
    if ("/" in host or "@" in host or ":" in host or " " in host
            or not host.endswith(".neon.tech")):
        return "INVALID_HOST_CONFIGURATION"
    # The client is imported only after the minimum secret gate.
    import psycopg

    for login, effective_role, secret_name, acl in IDENTITIES:
        phase = "connect"
        try:
            with psycopg.connect(
                host=host, dbname="oes_sandbox", user=login,
                password=os.environ[secret_name], sslmode="verify-full",
                channel_binding="require",
                connect_timeout=8, autocommit=False,
                options="-c statement_timeout=5000",
            ) as connection:
                phase = "role"
                with connection.cursor() as cursor:
                    cursor.execute("SET LOCAL ROLE " + effective_role)
                    phase = "metadata"
                    cursor.execute(SQL)
                    row = cursor.fetchone()
                    if (not isinstance(row, tuple) or len(row) != 6
                            or row[:3] != ("oes_sandbox", login, effective_role)
                            or row[3:] != acl):
                        return "METADATA_MISMATCH"
                connection.rollback()
        except Exception as exc:
            return sanitized_failure(exc, phase)
    return "PASS"


if __name__ == "__main__":
    status = run()
    print("G2_I1_DIAGNOSTIC_" + status)
    sys.exit(0 if status == "PASS" else 1)
