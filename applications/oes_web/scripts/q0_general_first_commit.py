"""Restricted first Q0 general commit and independent READ ONLY reconciliation.

Not the exceptional PR25 executor. No Django, connection or side effect at import.
"""
import json
import os
import re
import sys
from contextvars import ContextVar

from scripts.q0_manual_rollback_trial import WORKFLOW_CONTEXT, checked_out_sha

REVIEW = "REVIEW_ONLY"
COMMIT = "FIRST_CANONICAL_Q0_COMMIT"
RECOVER = "RECONCILE_FIRST_Q0_READ_ONLY"
REQUEST_ID = "q0-general-first-6bf4279cc0844fda9ad4d07f5656fb0a"
QUESTION_ID = "OES-SYNTH-Q0-GENERAL-FIRST-6bf4279cc0844fda9ad4d07f5656fb0a"
USERNAME = "oes_synth_preparer_marco_b_trial_20261029"
FINGERPRINT = "5331c6337bb7fe19c29a43b659722844b8591c100a56d3e7333b3c853a2ae667"
TEXT = "First canonical Q0 general persistence trial. Synthetic technical question; no factual evidence."
HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
REVIEW_CODE = "Q0_FIRST_COMMIT_REVIEW_ONLY_SOURCE_HOLD"
WRITE_HOLD = "Q0_FIRST_COMMIT_RESTRICTED_ACTIVATION_SOURCE_HOLD"
READ_HOLD = "Q0_FIRST_COMMIT_READ_RECOVERY_SOURCE_HOLD"
BOUNDARY = "Q0_FIRST_COMMIT_BOUNDARY_HOLD"
INCONCLUSIVE = "Q0_FIRST_COMMIT_INDETERMINATE_NO_RETRY"
ATTEMPT_FAILED = "Q0_FIRST_COMMIT_ATTEMPT_FAILED_NO_RETRY"


_operation = ContextVar("q0_reserved_operation", default=None)

class _Hold(RuntimeError):
    pass


def reserved_command():
    """No operator payload, actor or generated request; canonical contract only."""
    from evidence.question_preparation import QuestionCommand
    from evidence.question_preparation import command_fingerprint
    command = QuestionCommand(REQUEST_ID, QUESTION_ID, 0, TEXT)
    if command_fingerprint(command) != FINGERPRINT:
        raise _Hold(BOUNDARY)
    return command


def check_boundary(environ, checkout_sha):
    if any(environ.get(k) != v for k, v in WORKFLOW_CONTEXT.items()):
        raise _Hold(BOUNDARY)
    sha = environ.get("GITHUB_SHA", "")
    if (re.fullmatch(r"[0-9a-f]{40}", sha) is None or checkout_sha != sha
            or environ.get("OES_Q0_FIRST_REQUESTED_SHA", "") not in ("", sha)):
        raise _Hold(BOUNDARY)
    mode = environ.get("OES_Q0_FIRST_MODE", REVIEW)
    if mode == REVIEW:
        return mode
    if mode not in (COMMIT, RECOVER):
        raise _Hold(BOUNDARY)
    prefix = "APPROVED_FIRST_CANONICAL_Q0_COMMIT" if mode == COMMIT else "APPROVED_FIRST_Q0_READ_ONLY_RECONCILIATION"
    if (environ.get("GITHUB_WORKFLOW_REF") !=
            "rogerio-raposo/observatorio-evidencias-saude/.github/workflows/oes-q0-general-first-persistent-commit.yml@refs/heads/main"
            or environ.get("GITHUB_WORKFLOW_SHA") != sha
            or environ.get("OES_Q0_FIRST_REQUESTED_SHA") != sha
            or environ.get("OES_Q0_FIRST_APPROVED_SHA") != sha
            or environ.get("OES_Q0_FIRST_AUTHORIZATION") != f"{prefix}:{sha}:{REQUEST_ID}"):
        raise _Hold(BOUNDARY)
    # Do not silently accept an operator-defined scope or a consumption claim.
    if any(k in environ for k in ("OES_Q0_FIRST_USER", "OES_Q0_FIRST_ACTOR", "OES_Q0_FIRST_REQUEST_ID",
            "OES_Q0_FIRST_QUESTION_ID", "OES_Q0_FIRST_TEXT", "OES_Q0_FIRST_COMMAND",
            "OES_Q0_FIRST_CONSUMED", "OES_Q0_FIRST_UNUSED")):
        raise _Hold(BOUNDARY)
    return mode


def _emit(sha, phase, *, outcome=None, scope=None, fingerprint=None):
    if re.fullmatch(r"[0-9a-f]{40}", sha) is None or phase not in ("REVIEW", "BEFORE_ATTEMPT", "RESULT"):
        raise _Hold(BOUNDARY)
    if outcome not in (None, "PERSISTED", "ABSENT", "INDETERMINATE"):
        raise _Hold(BOUNDARY)
    record = {"sha":sha, "request_id":REQUEST_ID, "question_id":QUESTION_ID,
              "phase":phase, "automatic_retry":False}
    if outcome is not None:
        record["outcome"] = outcome
    if scope in ("THIS_ATTEMPT", "Q0_RECORDS"):
        record["scope"] = scope
    if isinstance(fingerprint, str) and re.fullmatch(r"[0-9a-f]{64}", fingerprint):
        record["fingerprint"] = fingerprint
    print(json.dumps(record, sort_keys=True), flush=True)


def check_profile(mode, environ):
    """Pure profile boundary; no technical single-use guarantee or activation."""
    if (environ.get("DJANGO_SETTINGS_MODULE") != "config.settings"
            or environ.get("OES_PG_A4_ENABLED") != "1" or environ.get("OES_PG_A4_HOST") != HOST):
        raise _Hold(BOUNDARY)
    names = ("OES_Q0_AUTH_PASSWORD", "OES_PG_A4_PASSWORD")
    if mode == COMMIT:
        if (environ.get("OES_Q0_MULTI_ALIAS_ENABLED") != "1"
                or environ.get("OES_Q0_RECOVERY_READONLY_ENABLED") not in (None, "", "0")):
            raise _Hold(BOUNDARY)
        names += ("OES_Q0_WRITER_PASSWORD",)
    elif mode == RECOVER:
        if (environ.get("OES_Q0_RECOVERY_READONLY_ENABLED") != "1"
                or environ.get("OES_Q0_MULTI_ALIAS_ENABLED") not in (None, "", "0")
                or "OES_Q0_WRITER_PASSWORD" in environ or "OES_QPREP_LOGIN_PASSWORD" in environ):
            raise _Hold(BOUNDARY)
    else:
        raise _Hold(BOUNDARY)
    values = [environ.get(name) for name in names]
    if any(not isinstance(v, str) or not v for v in values) or len(set(values)) != len(values):
        raise _Hold(BOUNDARY)


def _validate_reserved_user(user):
    """Application authorization and persistent identity, never browser input."""
    from evidence.preparation_auth import require_question_preparer
    from preparer_identity.resolver import persisted_preparer_actor_id
    require_question_preparer(user)
    if user.username != USERNAME or user.has_usable_password() is not False:
        raise _Hold(BOUNDARY)
    return persisted_preparer_actor_id(user)


def _load_reserved_user(mode):
    """Used only BELOW source gates in a future authorized invocation.

    Commit reuses the existing full synthetic READ ONLY attestation. Recovery
    uses the default READ ONLY auth-store and existing pure synthetic classifier,
    without requiring a writer alias or the auth-only alias of the writer profile.
    """
    from django.contrib.auth import get_user_model
    from preparer_identity.models import PreparerIdentity
    from preparer_identity.synthetic_service_readonly import (
        attest_synthetic_identity_readonly, classify_synthetic_identity,
    )
    if mode == COMMIT:
        actor = attest_synthetic_identity_readonly()
        user = get_user_model().objects.using("default").get(username=USERNAME)
    elif mode == RECOVER:
        from django.db import connections
        from scripts.q0_django_readonly_attestation import _session
        connection = connections["default"]
        if connection.in_atomic_block:
            raise _Hold(BOUNDARY)
        try:
            _session(connection, "oes_auth_trial_login")
            users = list(get_user_model().objects.using("default").filter(username=USERNAME))
            identities = list(PreparerIdentity.objects.using("default").filter(user_id=users[0].pk)) if len(users)==1 else []
            permissions = list(users[0].user_permissions.using("default").values_list(
                "content_type__app_label", "content_type__model", "codename")) if len(users)==1 else []
            groups = list(users[0].groups.using("default").values_list("pk", flat=True)) if len(users)==1 else []
            actor = classify_synthetic_identity(users=users, identities=identities,
                permissions=permissions, groups=groups)
            user = users[0]
        finally:
            connection.close()
    else:
        raise _Hold(BOUNDARY)
    if _validate_reserved_user(user) != actor:
        raise _Hold(BOUNDARY)
    return user


def _require_operation(mode, sha=None):
    """Internal CLI context, never an env-only permission to construct ORM."""
    operation = _operation.get()
    if (operation is None or operation[0] != mode
            or (sha is not None and operation[1] != sha)
            or check_boundary(os.environ, checked_out_sha()) != mode
            or operation[1] != checked_out_sha()):
        raise _Hold(BOUNDARY)
    check_profile(mode, os.environ)
    return operation[1]


def _execute_first_commit(sha):
    """Reserved operation requiring the validated internal CLI context.

    Durable consumption is waived for this supervised experiment only.
    Administrative approval is necessary, never sufficient for construction;
    it cannot prevent a second administrative run. No automatic retry.
    """
    _require_operation(COMMIT, sha)

    # Canonical repository/UoW/D3 only.
    import django
    django.setup()
    from django.conf import settings
    from evidence.question_preparation import register_authenticated_q0, command_fingerprint
    from evidence.question_orm_q0_connected_recipe_dormant import _review_q0_database_configuration
    _review_q0_database_configuration(settings.DATABASES)
    user = _load_reserved_user(COMMIT)
    command = reserved_command()
    fingerprint = command_fingerprint(command)
    _emit(sha, "BEFORE_ATTEMPT", fingerprint=fingerprint)
    try:
        from evidence.question_orm_q0_repository_dormant import _first_trial_scope
        with _first_trial_scope(sha=sha, user=user, command=command):
            result = register_authenticated_q0(user=user, command=command)
    except Exception as error:
        observation = getattr(error, "q0_observation", None)
        outcome = _emit_observation(sha, observation, fingerprint)
        # A failed service call may have a reconciled PERSISTED/ABSENT result.
        # Preserve that classification instead of calling it indeterminate.
        raise _Hold(INCONCLUSIVE if outcome == "INDETERMINATE" else ATTEMPT_FAILED) from None
    if result != {"status":"PREPARATORY_ONLY", "question_id":QUESTION_ID, "version":1}:
        raise _Hold(INCONCLUSIVE)
    # Normal D1/D3 return requires verified PERSISTED; no second verification,
    # replay or new writer transaction is introduced here.
    _emit(sha, "RESULT", outcome="PERSISTED", scope="Q0_RECORDS", fingerprint=fingerprint)


def _reconcile_first_commit(sha):
    """Independent reader-only operation; never invokes submission."""
    _require_operation(RECOVER, sha)

    # Independently authorized READ ONLY operation.
    import django
    django.setup()
    from django.conf import settings
    from evidence.question_preparation import review_registered_q0, command_fingerprint
    from evidence.question_orm_q0_connected_recipe_dormant import _review_q0_reader_configuration
    if set(settings.DATABASES) != {"default", "oes_synthetic_reader"}:
        raise _Hold(BOUNDARY)
    _review_q0_reader_configuration(settings.DATABASES)
    user = _load_reserved_user(RECOVER)
    command = reserved_command()
    observation = review_registered_q0(user=user, command=command)
    outcome = _emit_observation(sha, observation, command_fingerprint(command))
    if outcome == "INDETERMINATE":
        raise _Hold(INCONCLUSIVE)


def _emit_observation(sha, observation, fingerprint):
    outcome = observation.get("outcome") if isinstance(observation, dict) else None
    scope = observation.get("scope") if isinstance(observation, dict) else None
    # Normalize D3's internal result shape; this never authorizes an operation
    # and is not itself proof of persistence, absence or single-use consumption.
    if (outcome not in ("PERSISTED", "ABSENT", "INDETERMINATE")
            or scope not in ("THIS_ATTEMPT", "Q0_RECORDS")
            or observation.get("automatic_retry") is not False
            or (outcome == "PERSISTED" and scope != "Q0_RECORDS")):
        outcome, scope = "INDETERMINATE", "Q0_RECORDS"
    _emit(sha, "RESULT", outcome=outcome, scope=scope, fingerprint=fingerprint)
    return outcome


def main(argv=None):
    arguments = list(sys.argv[1:] if argv is None else argv)
    if arguments not in ([], ["--review-workflow"]):
        raise _Hold(BOUNDARY)
    review_workflow = arguments == ["--review-workflow"]
    if os.environ.get("OES_Q0_FIRST_MODE", REVIEW) == REVIEW and not review_workflow:
        print(REVIEW_CODE)
        return 0
    sha = checked_out_sha()
    mode = check_boundary(os.environ, sha)
    _emit(sha, "REVIEW")
    if mode == REVIEW or review_workflow:
        return 0
    check_profile(mode, os.environ)
    token = _operation.set((mode, sha))
    try:
        if mode == COMMIT:
            _execute_first_commit(sha)
        else:
            _reconcile_first_commit(sha)
    finally:
        _operation.reset(token)
    return 0


def entrypoint():
    try:
        return main()
    except _Hold as error:
        code = str(error)
        print(code if code in (WRITE_HOLD, READ_HOLD, BOUNDARY, INCONCLUSIVE, ATTEMPT_FAILED) else INCONCLUSIVE)
        return 1
    except BaseException:
        print(INCONCLUSIVE)
        return 1


if __name__ == "__main__":
    # Canonical module owns the ContextVar also imported by D1/D3.
    # python -m must not create a second operational-context instance.
    from scripts.q0_general_first_commit import entrypoint as canonical_entrypoint
    sys.exit(canonical_entrypoint())
