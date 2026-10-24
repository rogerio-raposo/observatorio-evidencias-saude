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


def run():
    if any(not os.environ.get(k) for k in REQUIRED):
        return False
    # The client is imported only after the minimum secret gate.
    import psycopg

    host = os.environ["OES_G2_HOST"]
    for login, effective_role, secret_name, acl in IDENTITIES:
        try:
            with psycopg.connect(
                host=host, dbname="oes_sandbox", user=login,
                password=os.environ[secret_name], sslmode="verify-full",
                connect_timeout=8, autocommit=False,
                options="-c statement_timeout=5000",
            ) as connection:
                with connection.cursor() as cursor:
                    cursor.execute("SET LOCAL ROLE " + effective_role)
                    cursor.execute(SQL)
                    row = cursor.fetchone()
                    if (not isinstance(row, tuple) or len(row) != 6
                            or row[:3] != ("oes_sandbox", login, effective_role)
                            or row[3:] != acl):
                        return False
                connection.rollback()
        except Exception:
            return False
    return True


if __name__ == "__main__":
    if run():
        print("G2_I1_AUTHENTICATION_METADATA_PASS")
        sys.exit(0)
    print("G2_I1_AUTHENTICATION_HOLD")
    sys.exit(1)
