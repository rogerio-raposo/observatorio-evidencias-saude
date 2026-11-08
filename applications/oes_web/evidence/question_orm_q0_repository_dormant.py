"""Dormant Q0 Django ORM repository implementation.

This module is deliberately uninstantiable until a distinct connected gate.
It is not a Django setting, a writer factory, or an application backend.
The ORM methods show the exact five canonical writes without an SQL adapter.
"""
from .models import (
    OesEntity, OesQuestion, OesEntityVersion,
    OesQuestionVersion, OesQuestionCommandReceipt,
)
from .question_preparation import PreparationHold
from .question_uow_offline import Receipt
from .question_orm_transaction_offline import scoped_current_question, request_receipt


from contextlib import contextmanager
from contextvars import ContextVar
from dataclasses import dataclass


@dataclass
class _TrialScope:
    user: object
    command: object
    actor: str
    fingerprint: str
    active: bool = True
    binding: object = None
    transaction_used: bool = False
    observation: object = None
    conflict_before_insert: bool = False


_trial_scope = ContextVar("q0_first_trial_scope", default=None)


def _require_first_trial_source_activation():
    from scripts import q0_general_first_commit as trial
    try:
        trial._require_operation(trial.COMMIT)
    except trial._Hold:
        raise PreparationHold("HOLD: reserved Q0 writer operation required") from None


@contextmanager
def _first_trial_scope(*, sha, user, command):
    """Only the reserved CLI enters here; not a general application factory.

    Python private state is not a sandbox against arbitrary in-process code.
    Administrative approval alone cannot establish the internal CLI context.
    """
    _require_first_trial_source_activation()
    import os
    from scripts import q0_general_first_commit as trial
    from .question_preparation import command_fingerprint
    if (_trial_scope.get() is not None
            or trial.checked_out_sha() != sha
            or trial.check_boundary(os.environ, sha) != trial.COMMIT):
        raise PreparationHold("HOLD: invalid trial issuance context")
    trial.check_profile(trial.COMMIT, os.environ)
    actor = trial._validate_reserved_user(user)
    if command != trial.reserved_command():
        raise PreparationHold("HOLD: trial manifest mismatch")
    scope = _TrialScope(user, command, actor, command_fingerprint(command))
    token = _trial_scope.set(scope)
    try:
        yield
    finally:
        scope.active = False
        scope.binding = None
        _trial_scope.reset(token)


def _require_q0_application_write_activation():
    """F1 offline only: no env, caller token or HTTP route can activate this."""
    raise PreparationHold("HOLD: Q0 application write not authorized")


@contextmanager
def _application_q0_scope(*, user, command):
    from .preparation_auth import require_question_preparer
    from .question_preparation import validate_register_q0, command_fingerprint
    from preparer_identity.resolver import persisted_preparer_actor_id
    require_question_preparer(user)
    validate_register_q0(command)
    _require_q0_application_write_activation()
    if _trial_scope.get() is not None:
        raise PreparationHold("HOLD: nested Q0 application scope")
    scope = _TrialScope(user, command, persisted_preparer_actor_id(user), command_fingerprint(command))
    token = _trial_scope.set(scope)
    try:
        yield scope
    finally:
        scope.active = False
        scope.binding = None
        _trial_scope.reset(token)


def _require_restricted_q0_construction(*, user=None, command=None):
    scope = _trial_scope.get()
    if type(scope) is not _TrialScope or not scope.active:
        raise PreparationHold("HOLD: Django ORM writer gate G2 restricted construction not authorized")
    if user is not None or command is not None:
        from preparer_identity.resolver import persisted_preparer_actor_id
        from .preparation_auth import require_question_preparer
        from .question_preparation import command_fingerprint
        require_question_preparer(user)
        if (user is not scope.user or command != scope.command
                or persisted_preparer_actor_id(user) != scope.actor
                or command_fingerprint(command) != scope.fingerprint):
            raise PreparationHold("HOLD: trial command identity mismatch")
    return scope


@contextmanager
def _bind_trial_transaction(writer, trace):
    # No scope is created here. Existing offline D1 tests replace construction.
    scope = _trial_scope.get()
    if scope is None:
        yield
        return
    _require_restricted_q0_construction()
    from .question_orm_q0_evidence_dormant import _expected_receipt
    if (trace.expected != _expected_receipt(scope.command, scope.actor)
            or trace.atomic_entered is not True
            or scope.transaction_used or scope.binding is not None or not trace.xid or not trace.writer_privileges
            or trace.writer_identity != ("oes_qprep_login", "oes_sandbox", "off")
            or not writer.in_atomic_block or writer.get_autocommit()
            or not writer.atomic_blocks or writer.connection is None):
        raise PreparationHold("HOLD: trial transaction not preflighted")
    scope.transaction_used = True
    scope.binding = (writer, writer.connection, writer.atomic_blocks[-1], trace, trace.xid)
    try:
        yield
    finally:
        scope.binding = None


def _check_trial_binding(writer, expected=None):
    scope = _require_restricted_q0_construction()
    binding = scope.binding
    from .question_orm_q0_evidence_dormant import _expected_receipt
    if (binding is None or (expected is not None and binding is not expected)
            or writer is not binding[0] or writer.connection is not binding[1]
            or not writer.in_atomic_block or writer.get_autocommit()
            or not writer.atomic_blocks or writer.atomic_blocks[-1] is not binding[2]
            or binding[3].xid != binding[4]
            or binding[3].expected != _expected_receipt(scope.command, scope.actor)):
        raise PreparationHold("HOLD: trial transaction binding mismatch")
    with writer.cursor() as cursor:
        cursor.execute("SELECT pg_current_xact_id()::text")
        if cursor.fetchone() != (binding[4],):
            raise PreparationHold("HOLD: trial xid mismatch")
    return binding


class DjangoQ0Repository:
    """Concrete ORM mapping; all entry points remain fail-closed."""

    def __init__(self, *, alias=None, _writer=None):
        if _writer is None:
            # General construction remains unconditionally blocked, even after
            # a future separate activation of the restricted source path.
            raise PreparationHold("HOLD: Django ORM writer gate G2 not authorized")
        _require_restricted_q0_construction()
        # Normal Python construction of THIS repository; no __new__, subclass,
        # attribute assignment by an executor or alternate ORM implementation.
        from django.db import connections
        from .question_orm_transaction_offline import postgres_session_identity
        from .question_orm_q0_evidence_dormant import _review_q0_privileges
        if (type(self) is not DjangoQ0Repository
                or alias != "oes_q0_writer" or _writer.alias != alias
                or _writer is not connections[alias]
                or _writer.vendor != "postgresql" or _writer.in_atomic_block is not True
                or _writer.get_autocommit() is not False):
            raise PreparationHold("HOLD: restricted Q0 writer boundary invalid")
        with _writer.cursor() as cursor:
            if postgres_session_identity(cursor) != ("oes_qprep_login", "oes_sandbox", "off"):
                raise PreparationHold("HOLD: restricted Q0 writer identity mismatch")
        _review_q0_privileges(_writer)
        self.alias = alias
        self._trial_binding = _check_trial_binding(_writer)

    @classmethod
    def _from_preflighted_writer(cls, *, writer):
        """Internal D1 construction inside its validated atomic, still SOURCE HOLD.

        A connection is context, never sufficient operational authorization.
        General aliases, caller factories and alternate repository types rejected.
        """
        _require_restricted_q0_construction()
        if cls is not DjangoQ0Repository:
            raise PreparationHold("HOLD: canonical Q0 repository required")
        return cls(alias="oes_q0_writer", _writer=writer)

    def insert_entity(self, entity_uuid, question_id, actor_id):
        from django.db import connections
        _check_trial_binding(connections[self.alias], self._trial_binding)
        return OesEntity.objects.using(self.alias).create(
            entity_uuid=entity_uuid, oes_id=question_id,
            entity_type="Question", created_by=actor_id,
        )

    def insert_question(self, entity_uuid, actor_id):
        from django.db import connections
        _check_trial_binding(connections[self.alias], self._trial_binding)
        return OesQuestion.objects.using(self.alias).create(
            entity_uuid=entity_uuid, responsible_actor_id=actor_id,
        )

    def insert_entity_version(self, version_uuid, entity_uuid, actor_id):
        from django.db import connections
        _check_trial_binding(connections[self.alias], self._trial_binding)
        return OesEntityVersion.objects.using(self.alias).create(
            version_uuid=version_uuid, entity_uuid=entity_uuid, version_no=1,
            version_status="current", created_by=actor_id,
            change_type="initial",
        )

    def insert_question_version(self, version_uuid, entity_uuid, original_text):
        from django.db import connections
        _check_trial_binding(connections[self.alias], self._trial_binding)
        return OesQuestionVersion.objects.using(self.alias).create(
            version_uuid=version_uuid, entity_uuid=entity_uuid,
            original_text=original_text, normalized_text=None,
            preparation_stage="q0_draft",
        )

    def insert_receipt(self, receipt, entity_uuid, version_uuid):
        from django.db import connections
        _check_trial_binding(connections[self.alias], self._trial_binding)
        return OesQuestionCommandReceipt.objects.using(self.alias).create(
            actor_id=receipt.actor_id, request_id=receipt.request_id,
            fingerprint_sha256=receipt.fingerprint,
            question_entity_uuid=entity_uuid, question_id=receipt.question_id,
            resulting_version_uuid=version_uuid,
            resulting_version_no=receipt.version,
            command_kind=receipt.command_kind,
            justification=receipt.justification,
        )

    def _advisory_lock(self, identity):
        from django.db import connections
        _check_trial_binding(connections[self.alias], self._trial_binding)
        # Requires an authorized single PostgreSQL transaction and alias.
        # No factory or connection is exposed by this dormant class.
        from django.db import connections
        with connections[self.alias].cursor() as cursor:
            cursor.execute(
                "SELECT pg_advisory_xact_lock(hashtextextended(%s, 0))",
                [identity],
            )

    def lock_request(self, actor_id, request_id):
        if not actor_id or not request_id:
            raise PreparationHold("HOLD: invalid request lock identity")
        identity = f"{len(actor_id)}:{actor_id}:{len(request_id)}:{request_id}"
        self._advisory_lock(identity)

    def lock_question(self, question_id):
        if not isinstance(question_id, str) or not question_id:
            raise PreparationHold("HOLD: invalid question identity")
        self._advisory_lock("oes:question:" + question_id)

    def find_receipt(self, actor_id, request_id):
        record = request_receipt(actor_id=actor_id, request_id=request_id).using(
            self.alias).first()
        if record is None:
            return None
        if (record.actor_id != actor_id or record.request_id != request_id
                or not isinstance(record.fingerprint_sha256, str)
                or len(record.fingerprint_sha256) != 64
                or any(ch not in "0123456789abcdef" for ch in record.fingerprint_sha256)):
            raise PreparationHold("HOLD: invalid receipt")
        return Receipt(record.actor_id, record.request_id,
                       record.fingerprint_sha256, record.question_id,
                       record.resulting_version_no, record.command_kind,
                       record.justification)

    def current_question(self, question_id, actor_id):
        # Lock question before this method; never FOR UPDATE on question.
        versions = scoped_current_question(
            question_id=question_id, actor_id=actor_id).using(self.alias)
        record = versions.values("version_no", "q0_original_text").first()
        if record is None:
            return None
        if (type(record["version_no"]) is not int or record["version_no"] < 1
                or not isinstance(record["q0_original_text"], str)
                or not record["q0_original_text"]):
            raise PreparationHold("HOLD: malformed current question")
        return {"version": record["version_no"],
                "original_text": record["q0_original_text"]}

    def can_access_question(self, question_id, actor_id):
        return OesQuestion.objects.using(self.alias).filter(
            entity_uuid__in=OesEntity.objects.using(self.alias).filter(
                oes_id=question_id, entity_type="Question").values("entity_uuid"),
            responsible_actor_id=actor_id,
        ).exists()
