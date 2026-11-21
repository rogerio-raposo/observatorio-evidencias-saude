"""Gated Django Q1 composition. No URL, CLI or environment activation."""
from contextlib import contextmanager

from django.db import connections, transaction
from django.db.models import Exists, OuterRef

from .models import OesEntity, OesEntityVersion, OesQuestion, OesQuestionVersion
from .preparation_auth import require_question_preparer
from .question_orm_q0_connected_recipe_dormant import (
    _review_q0_database_configuration, _review_q0_reader_configuration,
    _review_q0_session_boundary,
)
from .question_orm_q0_dormant import DormantQ0OrmPort
from .question_orm_q0_evidence_dormant import (
    READER, WRITER, _WriterTrace, _capture_q0_writer_transaction, _review_q0_privileges,
)
from .question_orm_q0_repository_dormant import (
    DjangoQ0Repository, _application_q1_scope, _bind_trial_transaction, _expected_scope_receipt,
    _require_q1_source_activation,
)
from .question_orm_transaction_offline import request_receipt
from .question_preparation import PreparationHold, command_fingerprint, submit_question_command, validate_propose_q1
from .question_uow_offline import OfflineQuestionUnitOfWork, Receipt


def _submit_q1(*, user, command):
    with _application_q1_scope(user=user, command=command) as scope:
        _review_q0_database_configuration(connections.databases)
        writer, reader = connections[WRITER], connections[READER]

        @contextmanager
        def writer_atomic():
            _review_q0_session_boundary(writer=writer, reader=reader)
            try:
                _review_q0_privileges(reader)
            finally:
                reader.close()
            with transaction.atomic(using=WRITER, durable=True):
                # The receipt lookup after waiting for a request lock must
                # see the preceding transaction's committed receipt.
                with writer.cursor() as cursor:
                    cursor.execute("SET TRANSACTION ISOLATION LEVEL READ COMMITTED")
                trace = _WriterTrace(_expected_scope_receipt(scope), atomic_entered=True)
                _capture_q0_writer_transaction(writer, trace)
                trace.writer_privileges = _review_q0_privileges(writer)
                with _bind_trial_transaction(writer, trace):
                    yield

        @contextmanager
        def repository():
            yield DjangoQ0Repository._from_preflighted_writer(writer=writer)

        port = DormantQ0OrmPort(atomic_factory=writer_atomic, repository_factory=repository, q1=True)
        try:
            result = submit_question_command(user=user, command=command,
                                             actor_id_resolver=lambda _: scope.actor,
                                             unit_of_work=OfflineQuestionUnitOfWork(port))
            return result, scope.actor
        finally:
            if not writer.in_atomic_block:
                writer.close()


def _observe_q1(*, user, command, actor):
    require_question_preparer(user)
    _review_q0_reader_configuration(connections.databases)
    reader = connections[READER]
    if (reader.alias != READER or reader.vendor != "postgresql" or reader.in_atomic_block
            or reader.get_autocommit() is not True):
        raise PreparationHold("HOLD: independent Q1 reader required")

    expected = Receipt(actor, command.request_id, command_fingerprint(command),
                       command.question_id, command.expected_version + 1,
                       "PROPOSE_Q1", command.justification)
    try:
        with transaction.atomic(using=READER, durable=True):
            with reader.cursor() as cursor:
                cursor.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY")
                cursor.execute(
                    "SELECT current_user,current_database(),"
                    "current_setting('transaction_read_only'),pg_is_in_recovery()"
                )
                if cursor.fetchone() != ("oes_pg_a4_reader", "oes_sandbox", "on", False):
                    raise PreparationHold("HOLD: Q1 reader identity mismatch")
            _review_q0_privileges(reader)
            owned = OesQuestion.objects.filter(responsible_actor_id=actor, entity_uuid__in=(
                OesEntity.objects.filter(oes_id=command.question_id, entity_type="Question").values("entity_uuid")
            )).values("entity_uuid")
            record = request_receipt(actor_id=actor, request_id=command.request_id).using(READER).first()
            if record is None or Receipt(
                    record.actor_id, record.request_id, record.fingerprint_sha256,
                    record.question_id, record.resulting_version_no, record.command_kind,
                    record.justification) != expected:
                raise PreparationHold("HOLD: Q1 receipt not verified")

            version = OesEntityVersion.objects.using(READER).filter(
                version_uuid=record.resulting_version_uuid, entity_uuid=record.question_entity_uuid,
                entity_uuid__in=owned, version_no=expected.version, created_by=actor,
                change_type="normalization_proposed",
            ).first()
            if version is None or version.supersedes_version_uuid is None:
                raise PreparationHold("HOLD: Q1 version not verified")
            previous_draft = OesQuestionVersion.objects.filter(
                version_uuid=OuterRef("version_uuid"), entity_uuid=OuterRef("entity_uuid"),
                original_text=command.original_text, normalized_text__isnull=True,
                preparation_stage="q0_draft",
            )
            closed = OesEntityVersion.objects.using(READER).filter(
                Exists(previous_draft), entity_uuid=version.entity_uuid,
                version_uuid=version.supersedes_version_uuid, version_no=command.expected_version,
                version_status="superseded", valid_to__isnull=False,
            ).exists()
            proposed = OesQuestionVersion.objects.using(READER).filter(
                entity_uuid=version.entity_uuid, version_uuid=version.version_uuid,
                original_text=command.original_text, normalized_text=command.normalized_text,
                preparation_stage="q1_proposed",
            ).exists()
            if not closed or not proposed:
                raise PreparationHold("HOLD: Q1 transition not verified")
    finally:
        reader.close()
    return expected


def review_authenticated_q1(*, user, command, _expected_actor=None):
    """Independent positive receipt proof, or HOLD. Never resubmits."""
    _require_q1_source_activation()
    validate_propose_q1(command)
    from preparer_identity.resolver import persisted_preparer_actor_id
    require_question_preparer(user)
    actor = persisted_preparer_actor_id(user)
    if _expected_actor is not None and actor != _expected_actor:
        raise PreparationHold("HOLD: Q1 actor binding changed")
    try:
        receipt = _observe_q1(user=user, command=command, actor=actor)
        require_question_preparer(user)
        if persisted_preparer_actor_id(user) != actor:
            raise PreparationHold("HOLD: Q1 actor binding changed")
        return receipt
    except PreparationHold:
        raise
    except Exception:
        raise PreparationHold("HOLD: Q1 readback unavailable; no automatic retry") from None


def propose_authenticated_q1_orm(*, user, command):
    """Internal candidate. A failed write or readback never triggers a retry."""
    result, actor = _submit_q1(user=user, command=command)
    review_authenticated_q1(user=user, command=command, _expected_actor=actor)
    return result
