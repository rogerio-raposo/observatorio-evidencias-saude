"""Offline preparation of ONE canonical Django Q0 trial. SOURCE HOLD remains.

No Django import at startup. REVIEW_ONLY never loads settings or credentials.
This is not the historical subclass-based synthetic commit executor.
"""
import argparse
from dataclasses import dataclass
import json
import os
import re
import sys
from uuid import UUID

from scripts.q0_manual_rollback_trial import WORKFLOW_CONTEXT, checked_out_sha

REVIEW = "REVIEW_ONLY"
SINGLE = "SINGLE_SYNTHETIC_COMMIT"
USERNAME = "oes_synth_preparer_marco_b_trial_20261029"
TEXT = "Synthetic technical persistent Q0 trial; no factual research data."
HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"


@dataclass(frozen=True)
class TrialPlan:
    sha: str
    run_id: str
    trial_id: str

    @property
    def request_id(self):
        return "q0-single-persistent-" + self.trial_id

    @property
    def question_id(self):
        return "OES-SYNTH-Q0-PERSIST-" + self.trial_id

    def identifiers(self):
        return {"sha": self.sha, "run_id": self.run_id, "trial_id": self.trial_id,
                "request_id": self.request_id, "question_id": self.question_id}


def _validate_reserved_plan(plan):
    if (type(plan) is not TrialPlan or re.fullmatch(r"[0-9a-f]{40}", plan.sha) is None
            or re.fullmatch(r"[1-9][0-9]*", plan.run_id) is None
            or re.fullmatch(r"[0-9a-f]{32}", plan.trial_id) is None
            or UUID(hex=plan.trial_id).version != 4):
        raise RuntimeError("HOLD: invalid reserved metadata")


def review_boundary(environ, checkout_sha):
    """Pure checks, no settings, network, state consumption or connection.

    Run binding and run_attempt reject obvious replays; they DO NOT implement
    atomic authorization consumption. Source HOLD remains until that is solved.
    IDs come from the dispatch input/nominal approval, never from random state.
    """
    if any(environ.get(k) != v for k, v in WORKFLOW_CONTEXT.items()):
        raise RuntimeError("HOLD: workflow context")
    sha = environ.get("GITHUB_SHA", "")
    if re.fullmatch(r"[0-9a-f]{40}", sha) is None or checkout_sha != sha:
        raise RuntimeError("HOLD: actual checkout mismatch")
    if environ.get("OES_Q0_PERSIST_REQUESTED_SHA", "") not in ("", sha):
        raise RuntimeError("HOLD: requested checkout mismatch")
    mode = environ.get("OES_Q0_PERSIST_MODE", REVIEW)
    if mode == REVIEW:
        # Optional offline manifest: preserve the operator-reserved identifiers
        # before any authorization or credential is supplied. Still no write.
        if environ.get("OES_Q0_PERSIST_TRIAL_ID"):
            plan = TrialPlan(sha, environ.get("GITHUB_RUN_ID", ""), environ["OES_Q0_PERSIST_TRIAL_ID"])
            _validate_reserved_plan(plan)
            return plan
        return None
    if mode != SINGLE:
        raise RuntimeError("HOLD: unsupported mode")
    run_id = environ.get("GITHUB_RUN_ID", "")
    nonce = environ.get("OES_Q0_PERSIST_TRIAL_ID", "")
    if (re.fullmatch(r"[1-9][0-9]*", run_id) is None
            or re.fullmatch(r"[0-9a-f]{32}", nonce) is None
            or UUID(hex=nonce).version != 4):
        raise RuntimeError("HOLD: reserved trial identity")
    if (environ.get("OES_Q0_PERSIST_REQUESTED_SHA") != sha
            or environ.get("OES_Q0_PERSIST_APPROVED_SHA") != sha
            or environ.get("OES_Q0_PERSIST_APPROVED_RUN_ID") != run_id
            or environ.get("OES_Q0_PERSIST_OPERATIONAL_AUTHORIZATION") !=
                f"APPROVED_SINGLE_SYNTHETIC_Q0_COMMIT:{sha}:{run_id}:{nonce}"):
        raise RuntimeError("HOLD: nominal SHA/run/trial authorization")
    if (environ.get("OES_Q0_PERSIST_USERNAME", USERNAME) != USERNAME
            or environ.get("OES_Q0_PERSIST_COMMAND", "REGISTER_Q0") != "REGISTER_Q0"
            or any(k in environ for k in ("OES_Q0_PERSIST_ORIGINAL_TEXT", "OES_Q0_PERSIST_QUESTION_ID",
                                         "OES_Q0_PERSIST_REQUEST_ID", "OES_Q0_PERSIST_AUTHORIZATION_STATE"))):
        raise RuntimeError("HOLD: arbitrary command or unverifiable consumption claim")
    plan = TrialPlan(sha, run_id, nonce)
    _validate_reserved_plan(plan)
    return plan


def review_credentials(environ):
    """Presence/separation only; does not authenticate or print credentials."""
    expected = {"DJANGO_SETTINGS_MODULE": "config.settings", "OES_PG_A4_ENABLED": "1",
                "OES_Q0_MULTI_ALIAS_ENABLED": "1", "OES_PG_A4_HOST": HOST}
    if any(environ.get(k) != v for k, v in expected.items()):
        raise RuntimeError("HOLD: isolated multi-alias configuration")
    passwords = [environ.get(k) for k in ("OES_PG_A4_PASSWORD", "OES_Q0_AUTH_PASSWORD", "OES_Q0_WRITER_PASSWORD")]
    if any(not isinstance(v, str) or not v for v in passwords) or len(set(passwords)) != 3:
        raise RuntimeError("HOLD: required distinct credentials")


def _emit(plan, phase, outcome=None, scope=None, fingerprint=None):
    """Allowlisted metadata only. Never serialize exceptions or DB observations."""
    _validate_reserved_plan(plan)
    phases = {"PREPARED_SOURCE_HOLD", "IDENTIFIERS_BEFORE_ATTEMPT", "RESULT"}
    if phase not in phases or outcome not in (None, "PERSISTED", "ABSENT", "INDETERMINATE"):
        raise RuntimeError("HOLD: invalid sanitized result")
    data = {**plan.identifiers(), "phase": phase, "automatic_retry": False}
    if outcome is not None:
        data["outcome"] = outcome
    if scope in ("THIS_ATTEMPT", "Q0_RECORDS"):
        data["scope"] = scope
    if isinstance(fingerprint, str) and re.fullmatch(r"[0-9a-f]{64}", fingerprint):
        data["fingerprint"] = fingerprint
    print(json.dumps(data, sort_keys=True), flush=True)


def _invoke_canonical_trial(plan):
    """INOPERATIVE source blueprint. Not activatable by environment/input.

    Required before any source change: approved durable one-use consumption,
    and a scoped construction path reviewed inside the canonical repository.
    The general constructor must stay HOLD. No operational monkeypatch.
    """
    raise RuntimeError("HOLD: source activation and durable one-use authorization unavailable")

    # UNREACHABLE preparation for review; no alternate repository or UoW.
    import django
    django.setup()
    from django.conf import settings
    from django.contrib.auth import get_user_model
    from evidence.preparation_auth import require_question_preparer
    from evidence.question_preparation import QuestionCommand, command_fingerprint
    from preparer_identity.resolver import persisted_preparer_actor_id
    from preparer_identity.synthetic_service_readonly import attest_synthetic_identity_readonly
    from evidence.question_orm_q0_connected_recipe_dormant import (
        _review_q0_database_configuration, _review_q0_persistence_d1,
    )
    _review_q0_database_configuration(settings.DATABASES)
    attested_actor = attest_synthetic_identity_readonly()
    user = get_user_model().objects.using("default").get(username=USERNAME)
    require_question_preparer(user)
    if persisted_preparer_actor_id(user) != attested_actor:
        raise RuntimeError("HOLD: synthetic persistent binding mismatch")
    command = QuestionCommand(plan.request_id, plan.question_id, 0, TEXT)
    fingerprint = command_fingerprint(command)
    # Persist these identifiers in the responsible operator's authorization
    # record BEFORE dispatch. Logs are an additional copy, not a new ledger.
    _emit(plan, "IDENTIFIERS_BEFORE_ATTEMPT", fingerprint=fingerprint)
    try:
        result = _review_q0_persistence_d1(user=user, command=command)
    except Exception as error:
        observation = getattr(error, "q0_observation", None)
        outcome = observation.get("outcome") if isinstance(observation, dict) else None
        scope = observation.get("scope") if isinstance(observation, dict) else None
        _emit(plan, "RESULT", outcome=outcome if outcome in ("PERSISTED", "ABSENT") else "INDETERMINATE",
              scope=scope, fingerprint=fingerprint)
        raise RuntimeError("HOLD: canonical trial failed; no retry") from None
    if result != {"status": "PREPARATORY_ONLY", "question_id": plan.question_id, "version": 1}:
        raise RuntimeError("HOLD: unexpected canonical result")
    # D3 only allows this normal return after its independent PERSISTED evidence;
    # classification is not promoted to operational permission or a retry.
    _emit(plan, "RESULT", outcome="PERSISTED", scope="Q0_RECORDS", fingerprint=fingerprint)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--review-workflow", action="store_true")
    args = parser.parse_args(argv)
    mode = os.environ.get("OES_Q0_PERSIST_MODE", REVIEW)
    if mode == REVIEW and not args.review_workflow:
        print("REVIEW_ONLY_Q0_PERSISTENT_TRIAL_SOURCE_HOLD")
        return
    plan = review_boundary(os.environ, checked_out_sha())
    if plan is None:
        print("REVIEW_ONLY_Q0_PERSISTENT_TRIAL_SOURCE_HOLD")
        return
    if args.review_workflow:
        _emit(plan, "PREPARED_SOURCE_HOLD")
        return
    review_credentials(os.environ)
    _emit(plan, "PREPARED_SOURCE_HOLD")
    _invoke_canonical_trial(plan)


def entrypoint():
    try:
        main()
    except BaseException:
        sys.exit("HOLD_Q0_PERSISTENT_TRIAL_INCONCLUSIVE_NO_RETRY")


if __name__ == "__main__":
    entrypoint()
