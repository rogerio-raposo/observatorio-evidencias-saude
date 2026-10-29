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


def _perform_rollback_only(*, trial, verified_actor):
    """Internal, intentionally unwired transaction recipe. No commit path."""
    RollbackTrialBoundary(WRITER, READER, 5, True, True, True, True).review()
    validate_persisted_actor_trial(authenticated_actor_id=verified_actor, trial=trial)
    writer = connections[WRITER]
    if writer.vendor != "postgresql" or writer.in_atomic_block or not writer.get_autocommit():
        raise PreparationHold("HOLD: invalid writer transaction boundary")
    completed = False
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
                            actor_id=verified_actor,request_id=trial.request_id).exists()):
                    raise PreparationHold("HOLD: occupied synthetic identifiers")
                e, v = trial.entity_uuid, trial.version_uuid
                OesEntity.objects.using(WRITER).create(
                    entity_uuid=e,oes_id=trial.question_id,entity_type="Question",
                    created_by=verified_actor)
                OesQuestion.objects.using(WRITER).create(
                    entity_uuid=e,responsible_actor_id=verified_actor)
                OesEntityVersion.objects.using(WRITER).create(
                    version_uuid=v,entity_uuid=e,version_no=1,
                    version_status="current",created_by=verified_actor,change_type="initial")
                OesQuestionVersion.objects.using(WRITER).create(
                    version_uuid=v,entity_uuid=e,original_text=trial.original_text,
                    normalized_text=None,preparation_stage="q0_draft")
                OesQuestionCommandReceipt.objects.using(WRITER).create(
                    actor_id=verified_actor,request_id=trial.request_id,
                    fingerprint_sha256=trial.fingerprint,question_entity_uuid=e,
                    question_id=trial.question_id,resulting_version_uuid=v,
                    resulting_version_no=1,command_kind="REGISTER_Q0",justification="")
                counts = (
                    OesEntity.objects.using(WRITER).filter(pk=e,oes_id=trial.question_id).count(),
                    OesQuestion.objects.using(WRITER).filter(pk=e,responsible_actor_id=verified_actor).count(),
                    OesEntityVersion.objects.using(WRITER).filter(pk=v,entity_uuid=e).count(),
                    OesQuestionVersion.objects.using(WRITER).filter(pk=v,entity_uuid=e).count(),
                    OesQuestionCommandReceipt.objects.using(WRITER).filter(
                        actor_id=verified_actor,request_id=trial.request_id,
                        fingerprint_sha256=trial.fingerprint).count(),
                )
                if counts != (1,1,1,1,1):
                    raise PreparationHold("HOLD: in-transaction invariants")
                completed = True
            finally:
                transaction.set_rollback(True, using=WRITER)
    finally:
        writer.close()
    if not completed:
        raise PreparationHold("HOLD: transaction did not complete")
    reader = connections[READER]
    try:
        reader.close()
        with reader.cursor() as cursor:
            cursor.execute("SELECT current_user,current_database(),current_setting('transaction_read_only')")
            if cursor.fetchone() != ("oes_pg_a4_reader","oes_sandbox","on"):
                raise PreparationHold("HOLD: independent reader identity mismatch")
        if any((
            OesEntity.objects.using(READER).filter(pk=trial.entity_uuid).exists(),
            OesQuestion.objects.using(READER).filter(pk=trial.entity_uuid).exists(),
            OesEntityVersion.objects.using(READER).filter(pk=trial.version_uuid).exists(),
            OesQuestionVersion.objects.using(READER).filter(pk=trial.version_uuid).exists(),
            OesQuestionCommandReceipt.objects.using(READER).filter(
                actor_id=verified_actor,request_id=trial.request_id).exists(),
        )):
            raise PreparationHold("HOLD: scientific rollback residues")
    finally:
        reader.close()
    return "PASS_ROLLBACK_ZERO_RESIDUES"


def run_connected(*args, **kwargs):
    raise PreparationHold("HOLD: isolated connected runner not CI-validated or wired")


if __name__ == "__main__":
    raise SystemExit("HOLD: connected Q0 trial remains disabled")
