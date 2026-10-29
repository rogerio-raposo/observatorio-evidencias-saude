"""Synthetic preparer provisioning contract, offline only.

No database connection, write, execution entrypoint, or secret is provided here.
An independently authorized connected implementation is still required.
"""
from dataclasses import dataclass
from enum import Enum
from uuid import UUID


class ProvisioningHold(RuntimeError):
    pass


class Outcome(str, Enum):
    COMMITTED_VERIFIED = "COMMITTED_VERIFIED"
    NOT_COMMITTED_VERIFIED = "NOT_COMMITTED_VERIFIED"
    UNCERTAIN_OR_DIVERGENT = "UNCERTAIN_OR_DIVERGENT"


@dataclass(frozen=True)
class SyntheticIdentityPlan:
    username: str
    actor_uuid: UUID
    permission: str = "evidence.prepare_question"

    def __post_init__(self):
        if not isinstance(self.username, str) or not self.username.startswith("oes_synth_preparer_"):
            raise ProvisioningHold("HOLD: synthetic username namespace required")
        if len(self.username) > 150 or not all(c.isascii() and (c.islower() or c.isdigit() or c == "_")
                                               for c in self.username):
            raise ProvisioningHold("HOLD: invalid synthetic username")
        if not isinstance(self.actor_uuid, UUID) or self.actor_uuid.version != 4:
            raise ProvisioningHold("HOLD: unique UUIDv4 required")
        if self.permission != "evidence.prepare_question":
            raise ProvisioningHold("HOLD: unexpected permission")


def classify_readback(*, user_found, identity_found, permission_found, flags_valid,
                      same_user_link, same_actor_uuid, no_extra_access,
                      read_complete, independent_reader):
    """Classify verified booleans, never infer commit from an incomplete read.

    permission_found means the exact user-permission LINK, never the global\n    auth_permission definition (which may preexist). A connected verifier must\n    independently establish each proposition for the reserved synthetic identity.\n    This helper performs no I/O and does not authorize retry or writes.
    """
    values = (user_found, identity_found, permission_found, flags_valid,
              same_user_link, same_actor_uuid, no_extra_access,
              read_complete, independent_reader)
    if any(type(v) is not bool for v in values):
        return Outcome.UNCERTAIN_OR_DIVERGENT
    if not read_complete or not independent_reader:
        return Outcome.UNCERTAIN_OR_DIVERGENT
    # The global permission/content-type may have existed before this trial.\n    # Absence only means all three trial-specific records/links are absent.\n    if not user_found and not identity_found and not permission_found:\n        return Outcome.NOT_COMMITTED_VERIFIED
    if all(values):
        return Outcome.COMMITTED_VERIFIED
    return Outcome.UNCERTAIN_OR_DIVERGENT


def execute_provisioning(*args, **kwargs):
    raise ProvisioningHold("HOLD: connected synthetic provisioning not authorized")


# Ordered contract only: these symbolic steps contain no SQL or ORM operations.
PROVISIONING_SEQUENCE = (
    "CHECK_FRESH_ADMIN_IDENTITY_AND_SCHEMA",
    "CHECK_SINGLE_USE_GATE_AND_SYNTHETIC_PARAMETERS",
    "BEGIN_ATOMIC",
    "ACQUIRE_TRANSACTION_SCOPED_LOCK",
    "RECHECK_ABSENCE_AND_FOREIGN_KEY_TARGETS",
    "ENSURE_EXACT_CONTENT_TYPE_AND_PERMISSION",
    "CREATE_ONE_USER_WITH_UNUSABLE_PASSWORD",
    "CREATE_ONE_LINKED_PREPARER_IDENTITY",
    "LINK_ONE_DIRECT_PREPARATION_PERMISSION",
    "ASSERT_ONE_USER_ONE_IDENTITY_ONE_PERMISSION_NO_EXTRA_ACCESS",
    "COMMIT_ONCE",
    "INDEPENDENT_READBACK_BEFORE_DECLARING_SUCCESS",
)


def review_provisioning_sequence(steps=PROVISIONING_SEQUENCE):
    """Pure contract validation; intentionally cannot perform any step."""
    if type(steps) is not tuple or steps != PROVISIONING_SEQUENCE:
        raise ProvisioningHold("HOLD: unauthorized provisioning sequence")
    if len(steps) != len(set(steps)):
        raise ProvisioningHold("HOLD: duplicated provisioning step")
    return PROVISIONING_SEQUENCE
