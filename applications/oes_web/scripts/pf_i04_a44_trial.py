"""Private CLI for one supervised Q0 → Q1 fixture. Source HOLD by default."""
import argparse
import os
from dataclasses import replace
from uuid import UUID


def _commands(run_id):
    from evidence.question_preparation import QuestionCommand

    prefix = f"PF-I04-A44-{run_id.hex}"
    q0 = QuestionCommand(f"{prefix}-R0", f"{prefix}-Q", 0,
                         "Como o procedimento fictício A se compara ao procedimento fictício B?")
    q1 = QuestionCommand(f"{prefix}-R1", q0.question_id, 1, q0.original_text,
                         "Comparar A e B quanto ao desfecho sintético C.",
                         "Delimitar o desfecho fictício para o ensaio.")
    return q0, q1


def _run(args):
    from config.mb_oc1 import require_mb_oc1
    from django.contrib.auth import get_user_model
    from evidence.preparation_auth import require_question_preparer
    from evidence.question_orm_q0_repository_dormant import (
        _application_q0_scope, _require_q1_trial_release, _supervised_q1_trial,
    )
    from evidence.question_orm_q1_dormant import propose_authenticated_q1_orm, review_authenticated_q1
    from evidence.question_preparation import (
        PreparationConflict, PreparationHold, register_authenticated_q0, review_registered_q0,
    )
    from preparer_identity.resolver import persisted_preparer_actor_id

    _require_q1_trial_release()
    require_mb_oc1()
    user = get_user_model().objects.using("default").get(pk=args.user_id)
    require_question_preparer(user)
    if persisted_preparer_actor_id(user) != args.actor:
        raise PreparationHold("HOLD: trial actor mismatch")
    q0, q1 = _commands(args.run_id)
    if args.phase == "register":
        with _application_q0_scope(user=user, command=q0) as scope:
            if scope.actor != args.actor:
                raise PreparationHold("HOLD: Q0 trial actor mismatch")
            result = register_authenticated_q0(user=user, command=q0)
            if (result.get("version") != 1
                    or (scope.observation or {}).get("outcome") != "PERSISTED"):
                raise PreparationHold("HOLD: Q0 receipt unconfirmed")
        return "Q0_VERIFIED"

    if args.phase == "propose":
        with _supervised_q1_trial(user=user, command=q1, actor=args.actor, write=True):
            propose_authenticated_q1_orm(user=user, command=q1)
        return "Q1_VERIFIED"

    # A negative fingerprint probe can only proceed after proving the
    # original Q1 exists. It uses the same key and changes just the justification.
    with _supervised_q1_trial(user=user, command=q1, actor=args.actor, write=False):
        review_authenticated_q1(user=user, command=q1, _expected_actor=args.actor)
    if args.phase == "review":
        if review_registered_q0(user=user, command=q0).get("outcome") != "PERSISTED":
            raise PreparationHold("HOLD: historical Q0 receipt unconfirmed")
        return "Q1_AND_HISTORICAL_Q0_VERIFIED"

    divergent = replace(q1, justification="Justificativa divergente para o teste de conflito.")
    try:
        with _supervised_q1_trial(user=user, command=divergent, actor=args.actor, write=True):
            propose_authenticated_q1_orm(user=user, command=divergent)
    except PreparationConflict as exc:
        if str(exc) == "HOLD: request fingerprint conflict":
            return "Q1_CONFLICT_VERIFIED"
        raise
    raise PreparationHold("HOLD: fingerprint conflict not observed")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("register", "propose", "review", "conflict"))
    parser.add_argument("--run-id", type=UUID, required=True)
    parser.add_argument("--user-id", type=int, required=True)
    parser.add_argument("--actor", required=True)
    args = parser.parse_args(argv)
    if (args.run_id.version != 4 or args.user_id < 1
            or os.environ.get("OES_PF_I04_A44_TRIAL") != str(args.run_id)
            or os.environ.get("DJANGO_SETTINGS_MODULE") != "config.settings_mb_oc1"):
        print("HOLD: explicit PF-I04-A4.4 context required")
        return 2

    try:
        import django
        django.setup()
        outcome = _run(args)
    except Exception:
        # Driver errors and tracebacks may contain connection details.
        print("HOLD: trial incomplete or unconfirmed; stop writes and reconcile by reader")
        return 1
    print(outcome)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
