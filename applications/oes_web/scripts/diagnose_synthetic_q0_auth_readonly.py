"""Explicit opt-in auth-only diagnostic. Importing this module never runs it.

No workflow or operational approval is implied by this command. Any future
connected invocation requires its own authorization. Output is one static code.
"""
import os
import sys

LOCAL_CONFIGURATION = "Q0_AUTH_DIAG_HOLD_LOCAL_CONFIGURATION"
INCONCLUSIVE = "Q0_AUTH_DIAG_HOLD_INCONCLUSIVE"


def diagnostic_result(environ):
    if (environ.get("OES_AUTH_DIAGNOSTIC_ONLY") != "READ_ONLY_SYNTHETIC_IDENTITY"
            or environ.get("OES_AUTH_ATTEST_ONLY") != "1"
            or environ.get("DJANGO_SETTINGS_MODULE") != "config.settings_q0_auth_attestation"
            or not environ.get("OES_Q0_AUTH_PASSWORD")
            or any(environ.get(name) not in (None, "", "0")
                   for name in ("OES_Q0_MULTI_ALIAS_ENABLED", "OES_PG_A4_ENABLED"))
            or any(name in environ for name in ("OES_Q0_WRITER_PASSWORD", "OES_PG_A4_PASSWORD"))):
        return LOCAL_CONFIGURATION
    try:
        import django
        django.setup()
    except Exception:
        return LOCAL_CONFIGURATION
    from preparer_identity.synthetic_service_readonly import (
        diagnose_synthetic_identity_readonly, DIAGNOSTIC_CODES,
    )
    result = diagnose_synthetic_identity_readonly()
    return result if type(result) is str and result in DIAGNOSTIC_CODES else INCONCLUSIVE


def main():
    try:
        result = diagnostic_result(os.environ)
    except BaseException:
        result = INCONCLUSIVE
    print(result)
    return 0 if result == "Q0_AUTH_DIAG_PASS_READ_ONLY_SYNTHETIC_IDENTITY" else 1


if __name__ == "__main__":
    try:
        exit_code = main()
    except BaseException:
        sys.exit(INCONCLUSIVE)
    sys.exit(exit_code)
