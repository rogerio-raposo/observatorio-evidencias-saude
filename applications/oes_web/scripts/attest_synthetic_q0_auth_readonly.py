"""One read-only attestation, no Django login, Q0 DML, or sensitive output."""
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings_q0_auth_attestation")

import django
django.setup()

from evidence.question_preparation import PreparationHold
from preparer_identity.synthetic_service_readonly import attest_synthetic_identity_readonly


def main():
    if os.getenv("OES_AUTH_ATTEST_ONLY") != "1":
        raise PreparationHold("HOLD: auth-only gate absent")
    actor = attest_synthetic_identity_readonly()
    if not actor.startswith("oes:actor:"):
        raise PreparationHold("HOLD: actor attestation invalid")
    print("PASS_READ_ONLY_SYNTHETIC_SERVICE_IDENTITY")


if __name__ == "__main__":
    main()
