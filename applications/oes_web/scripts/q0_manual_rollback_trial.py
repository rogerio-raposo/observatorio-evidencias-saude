"""Restricted manual Django-Q0 trial entrypoint; operational approval required.

Uses the already reviewed candidate. Never prints credentials, actors or SQL.
"""
import os
import sys
import subprocess
from pathlib import Path

REQUIRED = {
    "OES_Q0_MANUAL_ROLLBACK_ONLY": "APPROVED_SINGLE_SYNTHETIC_ROLLBACK",
    "GITHUB_EVENT_NAME": "workflow_dispatch",
    "GITHUB_RUN_ATTEMPT": "1",
    "GITHUB_REPOSITORY": "rogerio-raposo/observatorio-evidencias-saude",
    "GITHUB_REF": "refs/heads/main",
    "DJANGO_SETTINGS_MODULE": "config.settings",
}


WORKFLOW_CONTEXT = {
    name: REQUIRED[name] for name in (
        "GITHUB_EVENT_NAME", "GITHUB_RUN_ATTEMPT", "GITHUB_REPOSITORY", "GITHUB_REF"
    )
}


def checked_out_sha():
    """Read the actual checkout and reject modified tracked source; no network."""
    root = Path(__file__).resolve().parents[3]
    revision = subprocess.run(
        ["git", "rev-parse", "--verify", "HEAD"], cwd=root,
        capture_output=True, text=True, check=True,
    ).stdout.strip()
    subprocess.run(
        ["git", "diff", "--quiet", "HEAD", "--"], cwd=root,
        capture_output=True, text=True, check=True,
    )
    return revision


def check_workflow_boundary(environ, checkout_sha):
    """Pure review/operational boundary, usable before loading Django or secrets.

    The repository authorization value must be set by the responsible operator
    only after review of the published workflow and approval of the exact SHA.
    It is a human operational control, not proof of approval or single use.
    """
    if any(environ.get(name) != expected for name, expected in WORKFLOW_CONTEXT.items()):
        raise RuntimeError("HOLD: manual workflow context")
    sha = environ.get("GITHUB_SHA", "")
    if (len(sha) != 40 or any(ch not in "0123456789abcdef" for ch in sha)
            or checkout_sha != sha):
        raise RuntimeError("HOLD: checkout revision mismatch")
    mode = environ.get("OES_Q0_MODE", "")
    if mode == "REVIEW_ONLY":
        return mode
    if (mode != "SINGLE_SYNTHETIC_ROLLBACK"
            or environ.get("OES_Q0_APPROVED_SHA") != sha
            or environ.get("OES_Q0_REQUESTED_SHA") != sha
            or environ.get("OES_Q0_OPERATIONAL_AUTHORIZATION") !=
                "APPROVED_SINGLE_SYNTHETIC_ROLLBACK:" + sha):
        raise RuntimeError("HOLD: operational authorization or mode")
    return mode


def check_manual_boundary(environ):
    if check_workflow_boundary(environ, environ.get("GITHUB_SHA", "")) != "SINGLE_SYNTHETIC_ROLLBACK":
        raise RuntimeError("HOLD: connected CLI requires explicit rollback mode")
    for name, expected in REQUIRED.items():
        if environ.get(name) != expected:
            raise RuntimeError("HOLD: manual trial boundary")
    sha = environ.get("GITHUB_SHA", "")
    if (len(sha) != 40 or any(ch not in "0123456789abcdef" for ch in sha)
            or environ.get("OES_Q0_APPROVED_SHA") != sha):
        raise RuntimeError("HOLD: unreviewed trial revision")
    for name in ("OES_PG_A4_PASSWORD", "OES_Q0_AUTH_PASSWORD",
                 "OES_Q0_WRITER_PASSWORD", "OES_PG_A4_HOST"):
        if not environ.get(name):
            raise RuntimeError("HOLD: required isolated connection configuration")
    if environ.get("OES_PG_A4_ENABLED") != "1" or environ.get(
            "OES_Q0_MULTI_ALIAS_ENABLED") != "1":
        raise RuntimeError("HOLD: multi-alias configuration disabled")
    return True


def main():
    check_manual_boundary(os.environ)
    check_workflow_boundary(os.environ, checked_out_sha())
    import django
    django.setup()
    from scripts.q0_rollback_transaction_candidate import (
        review_and_execute_isolated_trial,
    )
    result = review_and_execute_isolated_trial()
    if result != "PASS_ROLLBACK_ZERO_RESIDUES":
        raise RuntimeError("HOLD: unexpected rollback classification")
    print("PASS_ROLLBACK_ZERO_RESIDUES")


if __name__ == "__main__":
    try:
        main()
    except BaseException:
        # No exception strings, identifiers, credentials or query parameters.
        sys.exit("HOLD_Q0_MANUAL_ROLLBACK_INCONCLUSIVE")
