"""Restricted manual Django-Q0 trial entrypoint; not called by enabled workflows.

Uses the already reviewed candidate. Never prints credentials, actors or SQL.
"""
import os
import sys

REQUIRED = {
    "OES_Q0_MANUAL_ROLLBACK_ONLY": "APPROVED_SINGLE_SYNTHETIC_ROLLBACK",
    "GITHUB_EVENT_NAME": "workflow_dispatch",
    "GITHUB_RUN_ATTEMPT": "1",
    "GITHUB_REPOSITORY": "rogerio-raposo/observatorio-evidencias-saude",
    "GITHUB_REF": "refs/heads/main",
    "DJANGO_SETTINGS_MODULE": "config.settings",
}


def check_manual_boundary(environ):
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
