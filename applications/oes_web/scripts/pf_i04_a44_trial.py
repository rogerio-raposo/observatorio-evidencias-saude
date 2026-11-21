"""Private CLI for one supervised Q0 → Q1 fixture. Source HOLD by default."""
import argparse
import os
import re
from contextvars import ContextVar
from dataclasses import replace
from uuid import UUID

from scripts.q0_manual_rollback_trial import checked_out_sha


# Fill only in a separately reviewed, temporary trial commit. The approved
# SHA is that commit's hash, verified at runtime, not a self-referential field.
_APPROVED_FIXTURE = None  # (canonical UUID v4 string, Django user pk, persisted actor)
_window = ContextVar("pf_i04_a44_window", default=None)


def _commands(run_id):
    from evidence.question_preparation import QuestionCommand

    prefix = f"PF-I04-A44-{run_id.hex}"
    q0 = QuestionCommand(f"{prefix}-R0", f"{prefix}-Q", 0,
                         "Como o procedimento fictício A se compara ao procedimento fictício B?")
    q1 = QuestionCommand(f"{prefix}-R1", q0.question_id, 1, q0.original_text,
                         "Comparar A e B quanto ao desfecho sintético C.",
                         "Delimitar o desfecho fictício para o ensaio.")
    return q0, q1


def _require_window():
    from evidence.question_preparation import PreparationHold

    window = _window.get()
    if _APPROVED_FIXTURE is None or window is None:
        raise PreparationHold("HOLD: PF-I04-A4.4 trial not authorized")
    return window


def _divergent(command):
    return replace(command, justification="Justificativa divergente para o teste de conflito.")


def _require_operation(*, user, command, operation):
    from evidence.question_preparation import PreparationHold

    _, run_id, pk, actor, phase = _require_window()
    q0, q1 = _commands(run_id)
    expected = {
        ("register", "q0-write"): q0,
        ("review", "q0-read"): q0,
        ("review-q0", "q0-read"): q0,
        ("propose", "q1-read"): q1,
        ("propose", "q1-write"): q1,
        ("review", "q1-read"): q1,
        ("conflict", "q1-read"): q1,
        ("conflict", "q1-write"): _divergent(q1),
    }.get((phase, operation))
    if expected is None or getattr(user, "pk", None) != pk or command != expected:
        raise PreparationHold("HOLD: supervised phase, user or command mismatch")
    return actor


def _run():
    from config.mb_oc1 import _require_private_profile
    from django.conf import settings
    from django.contrib.auth import get_user_model
    from evidence.preparation_auth import require_question_preparer
    from evidence.question_orm_q0_connected_recipe_dormant import (
        _review_q0_database_configuration, _review_q0_reader_configuration,
    )
    from evidence.question_orm_q0_repository_dormant import _application_q0_scope, _supervised_q1_trial
    from evidence.question_orm_q1_dormant import propose_authenticated_q1_orm, review_authenticated_q1
    from evidence.question_preparation import (
        PreparationConflict, PreparationHold, register_authenticated_q0, review_registered_q0,
    )
    from preparer_identity.resolver import persisted_preparer_actor_id

    _, run_id, user_id, actor, phase = _require_window()
    _require_private_profile()
    if settings.MB_OC1_RELEASE_MODE != "HOLD":
        raise PreparationHold("HOLD: HTTP release must remain disabled")
    if phase in ("review", "review-q0"):
        _review_q0_reader_configuration(settings.DATABASES)
    else:
        _review_q0_database_configuration(settings.DATABASES)
    user = get_user_model().objects.using("default").get(pk=user_id)
    require_question_preparer(user)
    if persisted_preparer_actor_id(user) != actor:
        raise PreparationHold("HOLD: trial actor mismatch")
    q0, q1 = _commands(run_id)
    if phase == "register":
        with _application_q0_scope(user=user, command=q0) as scope:
            result = register_authenticated_q0(user=user, command=q0)
            if (result.get("version") != 1
                    or (scope.observation or {}).get("outcome") != "PERSISTED"):
                raise PreparationHold("HOLD: Q0 receipt unconfirmed")
        return "Q0_VERIFIED"

    if phase == "propose":
        with _supervised_q1_trial(user=user, command=q1, actor=actor, write=True):
            propose_authenticated_q1_orm(user=user, command=q1)
        return "Q1_VERIFIED"

    if phase == "review-q0":
        if review_registered_q0(user=user, command=q0).get("outcome") != "PERSISTED":
            raise PreparationHold("HOLD: Q0 receipt unconfirmed")
        return "Q0_VERIFIED"

    # A negative fingerprint probe can only proceed after proving the
    # original Q1 exists. It uses the same key and changes just the justification.
    with _supervised_q1_trial(user=user, command=q1, actor=actor, write=False):
        review_authenticated_q1(user=user, command=q1, _expected_actor=actor)
    if phase == "review":
        if review_registered_q0(user=user, command=q0).get("outcome") != "PERSISTED":
            raise PreparationHold("HOLD: historical Q0 receipt unconfirmed")
        return "Q1_AND_HISTORICAL_Q0_VERIFIED"

    divergent = _divergent(q1)
    try:
        with _supervised_q1_trial(user=user, command=divergent, actor=actor, write=True):
            propose_authenticated_q1_orm(user=user, command=divergent)
    except PreparationConflict as exc:
        if str(exc) == "HOLD: request fingerprint conflict":
            return "Q1_CONFLICT_VERIFIED"
        raise
    raise PreparationHold("HOLD: fingerprint conflict not observed")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("register", "propose", "review", "review-q0", "conflict"))
    parser.add_argument("--run-id", type=UUID, required=True)
    parser.add_argument("--user-id", type=int, required=True)
    parser.add_argument("--actor", required=True)
    args = parser.parse_args(argv)
    approved_sha = os.environ.get("OES_PF_I04_A44_APPROVED_SHA", "")
    if (args.run_id.version != 4 or args.user_id < 1
            or os.environ.get("OES_PF_I04_A44_TRIAL") != str(args.run_id)
            or os.environ.get("DJANGO_SETTINGS_MODULE") != "config.settings_mb_oc1"):
        print("HOLD: explicit PF-I04-A4.4 context required")
        return 2

    try:
        if (_APPROVED_FIXTURE != (str(args.run_id), args.user_id, args.actor)
                or re.fullmatch(r"[0-9a-f]{40}", approved_sha) is None
                or checked_out_sha() != approved_sha
                or os.environ.get("OES_MB_OC1_RELEASE_MODE", "HOLD") != "HOLD"
                or os.environ.get("OES_CODESPACES_CSRF_LOCALHOST_ORIGIN", "0") != "0"):
            print("HOLD: approved trial checkout, fixture and closed HTTP required")
            return 1
        token = _window.set((approved_sha, args.run_id, args.user_id, args.actor, args.phase))
        try:
            import django
            django.setup()
            outcome = _run()
        finally:
            _window.reset(token)
    except Exception:
        # Driver errors and tracebacks may contain connection details.
        print("HOLD: trial incomplete or unconfirmed; stop writes and reconcile by reader")
        return 1
    print(outcome)
    return 0


if __name__ == "__main__":
    # Keep a single context even when launched with python -m.
    from scripts.pf_i04_a44_trial import main as entrypoint
    raise SystemExit(entrypoint())
