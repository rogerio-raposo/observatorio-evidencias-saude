"""CP313: opt-in Django authentication probe, read-only, synthetic Neon branch.

No writes, migrations, ORM Q0 activation, or permanent writer alias. A temporary
password must be injected by the operator's approved private execution channel.
The probe never prints the password, connection string, or exception message.
"""

import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

EXPECTED_USER = "oes_qprep_login"
EXPECTED_DATABASE = "oes_sandbox"
EXPECTED_HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
ALIAS = "oes_qprep_probe"

if os.getenv("OES_QPREP_PROBE_ENABLED") != "1":
    sys.exit("NOT_RUN: explicit connected-probe opt-in missing")
password = os.getenv("OES_QPREP_LOGIN_PASSWORD")
if not password:
    sys.exit("NOT_RUN: temporary secret unavailable")

if os.environ.get("DJANGO_SETTINGS_MODULE", "config.settings") != "config.settings":
    sys.exit("NOT_RUN: unexpected Django settings module")
os.environ["DJANGO_SETTINGS_MODULE"] = "config.settings"
from django.conf import settings

# Never combine this temporary identity with the older PG-A4 reader or an
# application database configuration. The repository baseline is DATABASES={}.
if settings.DATABASES:
    sys.exit("NOT_RUN: expected unconfigured Django DATABASES baseline")
settings.DATABASES = {
    "default": {"ENGINE": "django.db.backends.dummy"},
    ALIAS: {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": EXPECTED_DATABASE,
        "USER": EXPECTED_USER,
        "PASSWORD": password,
        "HOST": EXPECTED_HOST,
        "PORT": "5432",
        "OPTIONS": {
            "sslmode": "require",
            "options": "-c default_transaction_read_only=on",
            "connect_timeout": 10,
        },
        "CONN_MAX_AGE": 0,
    },
}

import django

django.setup()
from django.db import connections

try:
    with connections[ALIAS].cursor() as cursor:
        # Query 1: authenticated identity and connection transaction mode.
        cursor.execute(
            "SELECT session_user, current_user, current_database(), "
            "current_setting('transaction_read_only'), "
            "current_setting('default_transaction_read_only')"
        )
        identity = cursor.fetchone()
        if identity != (EXPECTED_USER, EXPECTED_USER, EXPECTED_DATABASE, "on", "on"):
            sys.exit("FAIL: unexpected identity, database, or read-only mode")

        # Query 2: admin flags of the *actually authenticated* role.
        cursor.execute(
            "SELECT rolcanlogin, rolinherit, rolsuper, rolcreatedb, "
            "rolcreaterole, rolreplication, rolbypassrls "
            "FROM pg_roles WHERE rolname = current_user"
        )
        if cursor.fetchone() != (True, True, False, False, False, False, False):
            sys.exit("FAIL: unexpected authenticated role attributes")

        # Query 3: allowed inheritance and forbidden privileged membership.
        cursor.execute(
            "SELECT pg_has_role(current_user, 'oes_qprep_writer', 'USAGE'), "
            "COALESCE((SELECT pg_has_role(current_user, r.oid, 'MEMBER') "
            "FROM pg_roles AS r WHERE r.rolname = 'neon_superuser'), false)"
        )
        if cursor.fetchone() != (True, False):
            sys.exit("FAIL: writer inheritance or privileged membership mismatch")

        # Query 4: direct membership options; SET ROLE must remain disabled.
        cursor.execute(
            "SELECT m.inherit_option, m.set_option "
            "FROM pg_auth_members AS m "
            "JOIN pg_roles AS member ON member.oid = m.member "
            "JOIN pg_roles AS granted ON granted.oid = m.roleid "
            "WHERE member.rolname = current_user "
            "AND granted.rolname = 'oes_qprep_writer'"
        )
        if cursor.fetchall() != [(True, False)]:
            sys.exit("FAIL: writer membership options mismatch")
except Exception as exc:
    # Do not print database exception messages; they may contain connection data.
    raise SystemExit(f"FAIL: Django PostgreSQL probe ({type(exc).__name__})") from None
finally:
    connections.close_all()

print("PASS OES_QPREP_DJANGO_AUTH_READ_ONLY: verified identity, database, "
      "read-only session, non-admin flags and restricted writer inheritance")
