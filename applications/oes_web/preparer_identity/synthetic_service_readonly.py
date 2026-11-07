"""Read-only synthetic-service identity attestation for the isolated Q0 trial.

Not authentication, not HTTP authorization, and never a DML gate.
"""
from uuid import UUID
from django.contrib.auth import get_user_model
from django.db import connections, InterfaceError, OperationalError
from evidence.question_preparation import PreparationHold
from .models import PreparerIdentity

RESERVED_USERNAME = "oes_synth_preparer_marco_b_trial_20261029"
EXPECTED_PERMISSION = ("evidence", "oesquestion", "prepare_question")


DIAGNOSTIC_CODES = frozenset((
    "Q0_AUTH_DIAG_PASS_READ_ONLY_SYNTHETIC_IDENTITY",
    "Q0_AUTH_DIAG_HOLD_LOCAL_CONFIGURATION",
    "Q0_AUTH_DIAG_HOLD_CONNECTION_OR_AUTHENTICATION",
    "Q0_AUTH_DIAG_HOLD_SESSION_MISMATCH",
    "Q0_AUTH_DIAG_HOLD_STRUCTURES_UNAVAILABLE",
    "Q0_AUTH_DIAG_HOLD_SYNTHETIC_USER_CARDINALITY",
    "Q0_AUTH_DIAG_HOLD_IDENTITY_BINDING",
    "Q0_AUTH_DIAG_HOLD_IDENTITY_FLAGS",
    "Q0_AUTH_DIAG_HOLD_PERMISSIONS_OR_GROUPS",
    "Q0_AUTH_DIAG_HOLD_INCONCLUSIVE",
))


def _identity_hold(message, code):
    # Preserve the original exception class/message and add static metadata only.
    failure = PreparationHold(message)
    failure.diagnostic_code = code
    return failure


def diagnostic_failure_code(error):
    """Classify by static metadata/type/SQLSTATE, never exception text."""
    code = getattr(error, "diagnostic_code", None)
    if type(code) is str and code in DIAGNOSTIC_CODES and "_HOLD_" in code:
        return code
    cause = error.__cause__ if error.__cause__ is not None else error
    state = getattr(cause, "sqlstate", None) or getattr(cause, "pgcode", None)
    if state in ("3F000", "42P01", "42703", "42501"):
        return "Q0_AUTH_DIAG_HOLD_STRUCTURES_UNAVAILABLE"
    if isinstance(error, (InterfaceError, OperationalError)) or (
            type(state) is str and state.startswith(("08", "28"))):
        return "Q0_AUTH_DIAG_HOLD_CONNECTION_OR_AUTHENTICATION"
    return "Q0_AUTH_DIAG_HOLD_INCONCLUSIVE"


def classify_synthetic_identity(*, users, identities, permissions, groups):
    """Pure fail-closed classifier; callers supply complete query results."""
    if len(users) != 1 or len(identities) != 1:
        raise _identity_hold("HOLD: synthetic identity cardinality",
                             "Q0_AUTH_DIAG_HOLD_SYNTHETIC_USER_CARDINALITY" if len(users) != 1
                             else "Q0_AUTH_DIAG_HOLD_IDENTITY_BINDING")
    user, identity = users[0], identities[0]
    if (user.username != RESERVED_USERNAME or user.pk != identity.user_id
            or user.is_active is not True or user.is_staff is not False
            or user.is_superuser is not False
            or not isinstance(user.password, str)
            or not user.password.startswith("!")):
        raise _identity_hold("HOLD: synthetic identity flags or binding",
                             "Q0_AUTH_DIAG_HOLD_IDENTITY_BINDING" if user.pk != identity.user_id
                             else "Q0_AUTH_DIAG_HOLD_IDENTITY_FLAGS")
    actor = identity.actor_uuid
    if type(actor) is not UUID or actor.version != 4 or str(actor) != str(UUID(str(actor))):
        raise _identity_hold("HOLD: invalid persisted synthetic actor",
                             "Q0_AUTH_DIAG_HOLD_IDENTITY_BINDING")
    if list(permissions) != [EXPECTED_PERMISSION] or list(groups):
        raise _identity_hold("HOLD: synthetic permission or group mismatch",
                             "Q0_AUTH_DIAG_HOLD_PERMISSIONS_OR_GROUPS")
    return "oes:actor:" + str(actor)


def attest_synthetic_identity_readonly():
    """One read-only alias; returns actor only to the offline isolated review.

    Requires an already configured independent auth-store alias and never
    fabricates is_authenticated or calls login/force_login.
    """
    conn = connections["oes_auth_readonly"]
    if conn.vendor != "postgresql" or conn.in_atomic_block or not conn.get_autocommit():
        raise _identity_hold("HOLD: auth-store connection boundary",
                             "Q0_AUTH_DIAG_HOLD_SESSION_MISMATCH")
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT current_user,current_database(),current_schema(),"
                "current_setting('transaction_read_only')"
            )
            observed = cursor.fetchone()
            if observed != ("oes_auth_trial_login", "oes_sandbox", "django_auth", "on"):
                schema_unavailable = (
                    type(observed) is tuple and len(observed) == 4
                    and observed[:2] == ("oes_auth_trial_login", "oes_sandbox")
                    and observed[3] == "on" and observed[2] != "django_auth")
                raise _identity_hold("HOLD: auth-store readonly identity",
                                     "Q0_AUTH_DIAG_HOLD_STRUCTURES_UNAVAILABLE" if schema_unavailable
                                     else "Q0_AUTH_DIAG_HOLD_SESSION_MISMATCH")
        users = list(get_user_model().objects.using("oes_auth_readonly").filter(
            username=RESERVED_USERNAME))
        identities = (list(PreparerIdentity.objects.using("oes_auth_readonly").filter(
            user_id=users[0].pk)) if len(users) == 1 else [])
        permissions = (list(users[0].user_permissions.using("oes_auth_readonly").values_list(
                "content_type__app_label", "content_type__model", "codename"))
            if len(users) == 1 else [])
        groups = (list(users[0].groups.using("oes_auth_readonly").values_list("pk", flat=True))
                  if len(users) == 1 else [])
        return classify_synthetic_identity(
            users=users, identities=identities, permissions=permissions, groups=groups)
    except PreparationHold:
        raise
    except Exception as exc:
        raise _identity_hold("HOLD: synthetic auth readback unavailable",
                             diagnostic_failure_code(exc)) from exc
    finally:
        conn.close()


def diagnose_synthetic_identity_readonly():
    """Auth-only wrapper around the unchanged attestation path; no new queries."""
    from django.conf import settings
    invalid = "Q0_AUTH_DIAG_HOLD_LOCAL_CONFIGURATION"
    databases = settings.DATABASES
    if (settings.SETTINGS_MODULE != "config.settings_q0_auth_attestation"
            or set(databases) != {"default", "oes_auth_readonly"}
            or databases["default"].get("ENGINE") != "django.db.backends.dummy"):
        return invalid
    from config.settings_q0_auth_attestation import HOST
    config = databases["oes_auth_readonly"]
    if (config.get("ENGINE") != "django.db.backends.postgresql"
            or config.get("HOST") != HOST or config.get("NAME") != "oes_sandbox"
            or config.get("USER") != "oes_auth_trial_login" or config.get("PORT") != "5432"
            or not config.get("PASSWORD") or config.get("CONN_MAX_AGE") != 0
            or config.get("OPTIONS", {}).get("sslmode") != "require"
            or config.get("OPTIONS", {}).get("options") !=
                "-c search_path=django_auth,public -c default_transaction_read_only=on"):
        return invalid
    connection = None
    try:
        connection = connections["oes_auth_readonly"]
        actor = attest_synthetic_identity_readonly()
        result = ("Q0_AUTH_DIAG_PASS_READ_ONLY_SYNTHETIC_IDENTITY"
                  if type(actor) is str and actor.startswith("oes:actor:")
                  else "Q0_AUTH_DIAG_HOLD_INCONCLUSIVE")
    except Exception as error:
        result = diagnostic_failure_code(error)
    finally:
        if connection is not None:
            try:
                connection.close()
            except Exception:
                result = "Q0_AUTH_DIAG_HOLD_INCONCLUSIVE"
    return result
