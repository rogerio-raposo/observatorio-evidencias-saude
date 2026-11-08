"""Manual metadata-only Django Q0 attestation. Import is connection-free."""
import os
import re
import sys

from scripts.q0_manual_rollback_trial import WORKFLOW_CONTEXT, checked_out_sha

MODE = "SINGLE_DJANGO_Q0_READ_ONLY_ATTESTATION"
SETTINGS = "config.settings_q0_readonly_attestation"
HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
AUTH_TABLES = (
    "auth_user", "auth_group", "auth_permission", "auth_user_groups",
    "auth_user_user_permissions", "auth_group_permissions", "django_content_type",
    "django_session", "preparer_identity_prepareridentity",
)
# Availability of writer-only pg_current_xact_id is checked, never invoked.
FUNCTIONS = (("pg_catalog.pg_current_xact_id()", False),
             ("pg_catalog.pg_xact_status(xid8)", True),
             ("pg_catalog.pg_current_snapshot()", True),
             ("pg_catalog.pg_is_in_recovery()", True))
PASS = "Q0_DJANGO_RO_ATTESTATION_PASS"
REVIEW = "Q0_DJANGO_RO_REVIEW_ONLY"
PREFLIGHT = "Q0_DJANGO_RO_APPROVAL_REVIEWED_NO_CONNECTION"
BOUNDARY = "Q0_DJANGO_RO_HOLD_BOUNDARY"
CONFIG = "Q0_DJANGO_RO_HOLD_CONFIGURATION"
SESSION = "Q0_DJANGO_RO_HOLD_SESSION"
PRIVILEGES = "Q0_DJANGO_RO_HOLD_PRIVILEGES"
FUNCTION = "Q0_DJANGO_RO_HOLD_FUNCTIONS"
SNAPSHOT = "Q0_DJANGO_RO_HOLD_SNAPSHOT"
INCONCLUSIVE = "Q0_DJANGO_RO_HOLD_INCONCLUSIVE"
CODES = frozenset((PASS, REVIEW, PREFLIGHT, BOUNDARY, CONFIG, SESSION, PRIVILEGES,
                   FUNCTION, SNAPSHOT, INCONCLUSIVE))


class _Hold(RuntimeError):
    def __init__(self, code):
        self.code = code if code in CODES and code.startswith("Q0_DJANGO_RO_HOLD_") else INCONCLUSIVE
        super().__init__(self.code)


def check_boundary(environ, checkout_sha):
    """No settings/credential loading. Exact manual/SHA/nominal authorization."""
    if any(environ.get(k) != v for k, v in WORKFLOW_CONTEXT.items()):
        raise _Hold(BOUNDARY)
    sha = environ.get("GITHUB_SHA", "")
    if (re.fullmatch(r"[0-9a-f]{40}", sha) is None or checkout_sha != sha
            or environ.get("OES_Q0_DJANGO_RO_REQUESTED_SHA", "") not in ("", sha)):
        raise _Hold(BOUNDARY)
    mode = environ.get("OES_Q0_DJANGO_RO_MODE", "REVIEW_ONLY")
    if mode == "REVIEW_ONLY":
        return False
    if (mode != MODE or environ.get("OES_Q0_DJANGO_RO_REQUESTED_SHA") != sha
            or environ.get("OES_Q0_DJANGO_RO_APPROVED_SHA") != sha
            or environ.get("OES_Q0_DJANGO_RO_AUTHORIZATION") !=
                "APPROVED_SINGLE_DJANGO_Q0_READ_ONLY_ATTESTATION:" + sha):
        raise _Hold(BOUNDARY)
    return True


def _configuration(settings):
    if (settings.SETTINGS_MODULE != SETTINGS or settings.DEBUG is not False
            or set(settings.DATABASES) != {"default", "oes_synthetic_reader"}):
        raise _Hold(CONFIG)
    passwords = []
    for alias, role, options in (
            ("default", "oes_auth_trial_login", "-c search_path=django_auth,public -c default_transaction_read_only=on"),
            ("oes_synthetic_reader", "oes_pg_a4_reader", "-c default_transaction_read_only=on")):
        c = settings.DATABASES[alias]
        if (c.get("ENGINE") != "django.db.backends.postgresql" or c.get("NAME") != "oes_sandbox"
                or c.get("HOST") != HOST or str(c.get("PORT")) != "5432" or c.get("USER") != role
                or c.get("CONN_MAX_AGE") != 0 or c.get("CONN_HEALTH_CHECKS") is not False
                or c.get("OPTIONS") != {"sslmode":"require", "connect_timeout":12, "options":options}
                or not isinstance(c.get("PASSWORD"), str) or not c["PASSWORD"]):
            raise _Hold(CONFIG)
        passwords.append(c["PASSWORD"])
    if passwords[0] == passwords[1]:
        raise _Hold(CONFIG)


def _session(connection, role):
    if (connection.vendor != "postgresql" or connection.in_atomic_block
            or connection.get_autocommit() is not True):
        raise _Hold(SESSION)
    with connection.cursor() as cursor:
        cursor.execute("SELECT session_user,current_user,current_database(),"
                       "current_setting('transaction_read_only'),current_setting('search_path'),current_schemas(false)")
        row = cursor.fetchone()
        if not isinstance(row, tuple) or len(row) != 6 or row[:4] != (role, role, "oes_sandbox", "on"):
            raise _Hold(SESSION)
        if connection.alias == "default":
            if (not isinstance(row[4], str) or row[4].replace(" ", "") != "django_auth,public"
                    or not isinstance(row[5], (list, tuple)) or not row[5]
                    or row[5][0] != "django_auth" or any(s not in ("django_auth", "public") for s in row[5])):
                raise _Hold(SESSION)


def _auth_privileges(connection):
    with connection.cursor() as cursor:
        cursor.execute("SELECT has_schema_privilege(current_user,%s,'USAGE')", ["django_auth"])
        row = cursor.fetchone()
        if not isinstance(row, tuple) or len(row) != 1 or row[0] is not True:
            raise _Hold(PRIVILEGES)
        for name in AUTH_TABLES:
            table = "django_auth." + name
            cursor.execute("SELECT to_regclass(%s)::text,has_table_privilege(current_user,%s,'SELECT')", [table, table])
            row = cursor.fetchone()
            if (not isinstance(row, tuple) or len(row) != 2
                    or not isinstance(row[0], str) or not row[0] or row[1] is not True):
                raise _Hold(PRIVILEGES)


def _functions(connection):
    with connection.cursor() as cursor:
        cursor.execute("SELECT current_setting('server_version_num')")
        row = cursor.fetchone()
        if (not isinstance(row, tuple) or len(row) != 1 or not isinstance(row[0], str)
                or not row[0].isdigit() or int(row[0]) < 140000):
            raise _Hold(FUNCTION)
        for signature, execute_required in FUNCTIONS:
            cursor.execute("SELECT to_regprocedure(%s)::oid,has_function_privilege(current_user,to_regprocedure(%s),'EXECUTE')",
                           [signature, signature])
            row = cursor.fetchone()
            if (not isinstance(row, tuple) or len(row) != 2 or type(row[0]) is not int or row[0] <= 0
                    or (execute_required and row[1] is not True)):
                raise _Hold(FUNCTION)


def _snapshot(connection, transaction):
    with transaction.atomic(using="oes_synthetic_reader", savepoint=False):
        if not connection.in_atomic_block or connection.get_autocommit() is not False:
            raise _Hold(SNAPSHOT)
        with connection.cursor() as cursor:
            cursor.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY")
            cursor.execute("SELECT current_setting('transaction_read_only'),current_setting('transaction_isolation'),"
                           "pg_is_in_recovery(),pg_current_snapshot()::text")
            row = cursor.fetchone()
            if (not isinstance(row, tuple) or len(row) != 4 or row[:2] != ("on", "repeatable read")
                    or row[2] is not False or not isinstance(row[3], str)
                    or re.fullmatch(r"[0-9]+:[0-9]+:(?:[0-9]+(?:,[0-9]+)*)?", row[3]) is None):
                raise _Hold(SNAPSHOT)
            cursor.execute("SELECT pg_current_snapshot()::text")
            if cursor.fetchone() != (row[3],):
                raise _Hold(SNAPSHOT)


def attest_metadata():
    """Only identity/session/catalog/privilege probes; never user/question rows."""
    # Also guard direct internal invocation, not only the CLI/workflow wrapper.
    try:
        if not check_boundary(os.environ, checked_out_sha()):
            return BOUNDARY
    except BaseException:
        return BOUNDARY
    from django.conf import settings
    from django.db import connections, transaction
    from evidence.question_orm_q0_evidence_dormant import _review_q0_privileges
    owned = []
    code = INCONCLUSIVE
    try:
        _configuration(settings)
        for alias, role in (("default", "oes_auth_trial_login"), ("oes_synthetic_reader", "oes_pg_a4_reader")):
            c = connections[alias]
            if c.in_atomic_block:
                raise _Hold(SESSION)  # never take ownership of an external transaction
            owned.append(c)
            c.close()
            _session(c, role)
            if alias == "default":
                _auth_privileges(c)
            else:
                try:
                    _review_q0_privileges(c)  # existing schema + five-table SELECT/no-write probe
                except Exception:
                    raise _Hold(PRIVILEGES) from None
                _functions(c)
                _snapshot(c, transaction)
        code = PASS
    except _Hold as error:
        code = error.code
    except BaseException:
        code = INCONCLUSIVE
    finally:
        for connection in owned:
            try:
                connection.close()
            except BaseException:
                code = INCONCLUSIVE
    return code


def main(argv=None):
    arguments = list(sys.argv[1:] if argv is None else argv)
    if arguments not in ([], ["--review-workflow"]):
        raise _Hold(BOUNDARY)  # never echo an unexpected argument to stderr
    review_workflow = arguments == ["--review-workflow"]
    if os.environ.get("OES_Q0_DJANGO_RO_MODE", "REVIEW_ONLY") == "REVIEW_ONLY" and not review_workflow:
        print(REVIEW)
        return 0
    approved = check_boundary(os.environ, checked_out_sha())
    if review_workflow:
        if os.environ.get("GITHUB_OUTPUT"):
            with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as out:
                out.write("approved=" + ("true" if approved else "false") + "\n")
        print(PREFLIGHT if approved else REVIEW)
        return 0
    if not approved:
        print(REVIEW)
        return 0
    if (os.environ.get("DJANGO_SETTINGS_MODULE") != SETTINGS
            or os.environ.get("OES_Q0_DJANGO_RO_PROFILE") != "AUTH_AND_Q0_METADATA_ONLY"):
        raise _Hold(CONFIG)
    try:
        import django
        django.setup()
        code = attest_metadata()
    except BaseException:
        code = INCONCLUSIVE
    print(code if code in CODES else INCONCLUSIVE)
    return 0 if code == PASS else 1


def entrypoint():
    try:
        return main()
    except _Hold as error:
        print(error.code)
        return 1
    except BaseException:
        print(INCONCLUSIVE)
        return 1


if __name__ == "__main__":
    sys.exit(entrypoint())
