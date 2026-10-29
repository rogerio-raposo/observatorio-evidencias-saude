"""Dormant Django-first Q0 ORM transaction port.

DO NOT wire into URLs, settings, services, or a live connection. The factory
must supply a synthetic context manager and synthetic ORM repositories.
No default repository, alias, or actual connection is available. Q1 is HOLD.
"""
from contextlib import contextmanager
from uuid import uuid4

from .question_preparation import PreparationHold
from .question_uow_offline import Receipt


class DormantQ0OrmPort:
    def __init__(self, *, atomic_factory=None, repository_factory=None):
        if not callable(atomic_factory) or not callable(repository_factory):
            raise PreparationHold("HOLD: Q0 ORM backend not configured")
        self.atomic_factory = atomic_factory
        self.repository_factory = repository_factory

    @contextmanager
    def begin(self):
        with self.atomic_factory():
            with self.repository_factory() as repo:
                tx = _Q0Transaction(repo)
                yield tx
                if tx.pending is not None:
                    raise PreparationHold("HOLD: receipt missing; rollback")
                # Retain identifiers only within this dormant transaction context.
                # No successful commit or positive readback is implied here.
                if tx.created_q0 is not None and not tx.receipt_saved:
                    raise PreparationHold("HOLD: Q0 identifiers without receipt")


class _Q0Transaction:
    def __init__(self, repository):
        self.repo = repository
        self.request = None
        self.pending = None
        self.created_q0 = None
        self.receipt_saved = False

    def lock_request(self, actor_id, request_id):
        self.repo.lock_request(actor_id, request_id)
        self.request = (actor_id, request_id)

    def find_receipt(self, actor_id, request_id):
        if self.request != (actor_id, request_id):
            raise PreparationHold("HOLD: request not locked")
        receipt = self.repo.find_receipt(actor_id, request_id)
        if receipt is not None and not isinstance(receipt, Receipt):
            raise PreparationHold("HOLD: malformed receipt")
        return receipt

    def current_question(self, question_id, actor_id, lock=False):
        self._require_lock(actor_id)
        self.repo.lock_question(question_id)
        return self.repo.current_question(question_id, actor_id)

    def can_access_question(self, question_id, actor_id):
        self._require_lock(actor_id)
        self.repo.lock_question(question_id)
        return self.repo.can_access_question(question_id, actor_id)

    def register_q0(self, command, actor_id):
        self._require_lock(actor_id)
        if self.pending is not None or command.expected_version != 0 or command.normalized_text is not None:
            raise PreparationHold("HOLD: invalid Q0 transition")
        self.repo.lock_question(command.question_id)
        entity_uuid, version_uuid = uuid4(), uuid4()
        self.repo.insert_entity(entity_uuid, command.question_id, actor_id)
        self.repo.insert_question(entity_uuid, actor_id)
        self.repo.insert_entity_version(version_uuid, entity_uuid, actor_id)
        self.repo.insert_question_version(version_uuid, entity_uuid, command.original_text)
        self.pending = (actor_id, command.question_id, entity_uuid, version_uuid)
        self.created_q0 = {
            "actor_id": actor_id,
            "question_id": command.question_id,
            "entity_uuid": entity_uuid,
            "version_uuid": version_uuid,
            "original_text": command.original_text,
        }

    def propose_q1(self, command, actor_id):
        raise PreparationHold("HOLD: Django ORM Q1 backend not implemented")

    def save_receipt(self, receipt):
        if self.pending is None or not isinstance(receipt, Receipt):
            raise PreparationHold("HOLD: unexpected receipt")
        actor_id, question_id, entity_uuid, version_uuid = self.pending
        if (receipt.actor_id != actor_id or receipt.question_id != question_id
                or receipt.command_kind != "REGISTER_Q0" or receipt.version != 1
                or receipt.justification):
            raise PreparationHold("HOLD: receipt mismatch")
        self.repo.insert_receipt(receipt, entity_uuid, version_uuid)
        self.receipt_saved = True
        self.pending = None

    def _require_lock(self, actor_id):
        if self.request is None or self.request[0] != actor_id:
            raise PreparationHold("HOLD: request not locked")
