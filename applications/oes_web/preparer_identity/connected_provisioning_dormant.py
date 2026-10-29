"""Django-first synthetic preparer provisioning composition — inert by design.

Neither public nor private entrypoint performs database I/O. The reference code
is unreachable until a separately approved, source-reviewed connected gate.
No credential, secret, route, workflow or factory can activate this module.
"""
from .provisioning_plan_offline import ProvisioningHold, PROVISIONING_SEQUENCE


def execute_connected_provisioning(*args, **kwargs):
    raise ProvisioningHold("HOLD: connected Django preparer provisioning not authorized")


def _review_single_use_transaction(*, plan, alias, read_alias):
    raise ProvisioningHold("HOLD: synthetic preparer administrative DML gate absent")

    # UNREACHABLE composition notes, not an executable transaction:
    # - validate exact role/branch/schema and single-use approval
    # - make explicit transaction.atomic(using=alias, savepoint=False)
    # - obtain transaction-scoped lock; re-check all preconditions
    # - use only Django auth/contenttypes and PreparerIdentity models
    # - set_unusable_password; save one user, identity, and direct permission
    # - validate all links and privilege flags before transaction exit
    # - independent readback from auth read-only role on successful commit
    # - if outcome uncertain, block any retry pending manual reconciliation
    return PROVISIONING_SEQUENCE
