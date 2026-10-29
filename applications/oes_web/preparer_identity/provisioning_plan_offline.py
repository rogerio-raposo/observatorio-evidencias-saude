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

    A connected verifier must independently establish each proposition.
    This helper performs no I/O and does not authorize retry or writes.
    """
    values = (user_found, identity_found, permission_found, flags_valid,
              same_user_link, same_actor_uuid, no_extra_access,
              read_complete, independent_reader)
    if any(type(v) is not bool for v in values):
        return Outcome.UNCERTAIN_OR_DIVERGENT
    if not read_complete or not independent_reader:
        return Outcome.UNCERTAIN_OR_DIVERGENT
    if not user_found and not identity_found and not permission_found:
        return Outcome.NOT_COMMITTED_VERIFIED
    if all(values):
        return Outcome.COMMITTED_VERIFIED
    return Outcome.UNCERTAIN_OR_DIVERGENT


def execute_provisioning(*args, **kwargs):
    raise ProvisioningHold("HOLD: connected synthetic provisioning not authorized")
