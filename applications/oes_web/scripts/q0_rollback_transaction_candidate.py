"""Isolated Django Q0 rollback transaction candidate; NOT an executable entrypoint.

Internal recipe may be reviewed/tested offline. Public execution remains HOLD.
Never import this module in HTTP routing or production services.
"""
from django.db import connections, transaction
from evidence.models import (OesEntity, OesQuestion, OesEntityVersion,
                             OesQuestionVersion, OesQuestionCommandReceipt)
from evidence.question_preparation import PreparationHold
from evidence.q0_rollback_execution_gate_offline import (
    RollbackTrialBoundary, validate_persisted_actor_trial)

WRITER = "oes_q0_writer"
READER = "oes_synthetic_reader"


def review_persisted_actor_binding(*, user, trial):
    """Review the persisted auth-store binding; not a real login or DML gate."""
    from evidence.preparation_auth import require_question_preparer
    from preparer_identity.resolver import persisted_preparer_actor_id
    require_question_preparer(user)
    actor = persisted_preparer_actor_id(user)
    validate_persisted_actor_trial(authenticated_actor_id=actor, trial=trial)
    return "PERSISTED_ACTOR_BINDING_REVIEW_PASS"


def _perform_rollback_only(*, trial, verified_actor):
    """Internal, intentionally unwired transaction recipe. No commit path."""
    RollbackTrialBoundary(WRITER, READER, 5, True, True, True, True).review()
    validate_persisted_actor_trial(authenticated_actor_id=verified_actor, trial=trial)
    writer = connections[WRITER]
    if writer.vendor != "postgresql" or writer.in_atomic_block or not writer.get_autocommit():
        raise PreparationHold("HOLD: invalid writer transaction boundary")
    completed = False
    transaction_failure = None
    try:
        with transaction.atomic(using=WRITER, savepoint=False):
            try:
                with writer.cursor() as cursor:
                    cursor.execute("SELECT current_user,current_database(),current_setting('transaction_read_only')")
                    if cursor.fetchone() != ("oes_qprep_login", "oes_sandbox", "off"):
                        raise PreparationHold("HOLD: writer identity mismatch")
                    cursor.execute("SELECT pg_advisory_xact_lock(hashtextextended(%s,0))",
                                   [trial.request_id])
                    cursor.execute("SELECT pg_advisory_xact_lock(hashtextextended(%s,0))",
                                   [trial.question_id])
                if (OesEntity.objects.using(WRITER).filter(oes_id=trial.question_id).exists()
                        or OesQuestionCommandReceipt.objects.using(WRITER).filter(
                            actor_id=verified_actor, request_id=trial.request_id).exists()):
                    raise PreparationHold("HOLD: occupied synthetic identifiers")
                e, v = trial.entity_uuid, trial.version_uuid
                OesEntity.objects.using(WRITER).create(
                    entity_uuid=e, oes_id=trial.question_id, entity_type="Question",
                    created_by=verified_actor)
                OesQuestion.objects.using(WRITER).create(
                    entity_uuid=e, responsible_actor_id=verified_actor)
                OesEntityVersion.objects.using(WRITER).create(
                    version_uuid=v, entity_uuid=e, version_no=1,
                    version_status="current", created_by=verified_actor, change_type="initial")
                OesQuestionVersion.objects.using(WRITER).create(
                    version_uuid=v, entity_uuid=e, original_text=trial.original_text,
                    normalized_text=None, preparation_stage="q0_draft")
                OesQuestionCommandReceipt.objects.using(WRITER).create(
                    actor_id=verified_actor, request_id=trial.request_id,
                    fingerprint_sha256=trial.fingerprint, question_entity_uuid=e,
                    question_id=trial.question_id, resulting_version_uuid=v,
                    resulting_version_no=1, command_kind="REGISTER_Q0", justification="")
                counts = (
                    OesEntity.objects.using(WRITER).filter(pk=e, oes_id=trial.question_id).count(),
                    OesQuestion.objects.using(WRITER).filter(pk=e, responsible_actor_id=verified_actor).count(),
                    OesEntityVersion.objects.using(WRITER).filter(pk=v, entity_uuid=e).count(),
                    OesQuestionVersion.objects.using(WRITER).filter(pk=v, entity_uuid=e).count(),
                    OesQuestionCommandReceipt.objects.using(WRITER).filter(
                        actor_id=verified_actor, request_id=trial.request_id,
                        fingerprint_sha256=trial.fingerprint).count(),
                )
                if counts != (1, 1, 1, 1, 1):
                    raise PreparationHold("HOLD: in-transaction invariants")
                completed = True
            finally:
                transaction.set_rollback(True, using=WRITER)
    except Exception as exc:
        transaction_failure = exc
    finally:
        # Do not reconcile through a connection whose transaction remains open.
        boundary_open = writer.in_atomic_block
        writer.close()
        if boundary_open:
            raise PreparationHold("HOLD: writer transaction boundary remained open")
    reader = connections[READER]
    try:
        reader.close()
        if (reader is writer or reader.vendor != "postgresql" or reader.in_atomic_block
                or not reader.get_autocommit()):
            raise PreparationHold("HOLD: independent reader invalid")
        with reader.cursor() as cursor:
            cursor.execute("SELECT current_user,current_database(),current_setting('transaction_read_only')")
            if cursor.fetchone() != ("oes_pg_a4_reader", "oes_sandbox", "on"):
                raise PreparationHold("HOLD: independent reader identity mismatch")
        residues = (
            OesEntity.objects.using(READER).filter(pk=trial.entity_uuid).exists(),
            OesEntity.objects.using(READER).filter(oes_id=trial.question_id).exists(),
            OesQuestion.objects.using(READER).filter(pk=trial.entity_uuid).exists(),
            OesEntityVersion.objects.using(READER).filter(pk=trial.version_uuid).exists(),
            OesQuestionVersion.objects.using(READER).filter(pk=trial.version_uuid).exists(),
            OesQuestionCommandReceipt.objects.using(READER).filter(
                actor_id=verified_actor, request_id=trial.request_id).exists(),
        )
    except Exception as exc:
        raise PreparationHold("HOLD: independent reconciliation unavailable") from exc
    finally:
        reader.close()
    if any(residues):
        raise PreparationHold("HOLD: scientific rollback residues")
    if transaction_failure is not None:
        raise PreparationHold("HOLD: transaction failed; zero residues independently verified") from transaction_failure
    if not completed:
        raise PreparationHold("HOLD: transaction did not complete")
    return "PASS_ROLLBACK_ZERO_RESIDUES"


def run_connected(*args, **kwargs):
    raise PreparationHold("HOLD: isolated connected runner not CI-validated or wired")


if __name__ == "__main__":
    raise SystemExit("HOLD: connected Q0 trial remains disabled")
