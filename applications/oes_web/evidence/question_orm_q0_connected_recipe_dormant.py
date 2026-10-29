"""Dormant Django Q0 transaction recipe. NEVER imported into runtime routing.

G2-P2B is NO-GO. No writer alias, credential, repository factory or network
entrypoint is supplied. The execution gate below intentionally always HOLDs.
This recipe does not establish least privilege, commit or connected readiness.
"""
from uuid import UUID, uuid4

from django.db import connections, transaction

from .models import (
    OesEntity, OesEntityVersion, OesQuestion, OesQuestionVersion,
    OesQuestionCommandReceipt,
)
from .question_preparation import PreparationHold
from .question_orm_q0_repository_dormant import DjangoQ0Repository


def prepare_q0_trial_review(*, actor_id, request_id, question_id, original_text):
    """Prepare a synthetic proposal offline; deliberately does not call the recipe.

    This is a one-way link to the existing preflight, not a writer activation.
    The public execution gate and repository constructor still reject calls.
    """
    from scripts.q0_rollback_trial_preflight_offline import prepare_synthetic_q0_trial
    return prepare_synthetic_q0_trial(
        actor_id=actor_id, request_id=request_id,
        question_id=question_id, original_text=original_text,
    )


def execute_connected_q0(*args, **kwargs):
    raise PreparationHold("HOLD: G2-P2B connected execution not authorized")


def _rollback_recipe(*, alias, actor_id, request_id, question_id, original_text,
                     fingerprint, trial=None, _trial_repository=None, _phase=None):
    """Unwired review-only recipe. NOT an approved callable execution path.

    Requires separate security review, gate activation and explicit approval.
    The ininstantiable repository prevents reaching an ORM connection here.
    """
    if not all(isinstance(x, str) and x for x in (
            alias, actor_id, request_id, question_id, original_text, fingerprint)):
        raise PreparationHold("HOLD: invalid synthetic identity")
    if len(fingerprint) != 64 or any(x not in "0123456789abcdef" for x in fingerprint):
        raise PreparationHold("HOLD: invalid fingerprint")
    if trial is not None:
        # A future authorized trial must reuse the preflight UUIDs exactly.
        from scripts.q0_rollback_trial_preflight_offline import SyntheticQ0Trial
        if (type(trial) is not SyntheticQ0Trial
                or trial.target_alias != alias
                or (trial.actor_id, trial.request_id, trial.question_id,
                    trial.original_text, trial.fingerprint)
                != (actor_id, request_id, question_id, original_text, fingerprint)
                or type(trial.entity_uuid) is not UUID
                or type(trial.version_uuid) is not UUID
                or trial.entity_uuid == trial.version_uuid
                or trial.expected_insert_count != 5
                or trial.rollback_required is not True):
            raise PreparationHold("HOLD: synthetic trial identity mismatch")
    # This line is a hard blocker, not a gate to bypass via object.__new__.
    repo = (DjangoQ0Repository(alias=alias) if _trial_repository is None
            else _trial_repository)
    connection = connections[alias]
    if connection.vendor != "postgresql" or connection.in_atomic_block or not connection.get_autocommit():
        raise PreparationHold("HOLD: non-independent transaction boundary")
    from .question_uow_offline import Receipt

    entity_uuid, version_uuid = (trial.entity_uuid, trial.version_uuid) if trial is not None else (uuid4(), uuid4())
    if _phase is not None:
        _phase("TRANSACTION_START")
    transaction_failure = None
    try:
        with transaction.atomic(using=alias, savepoint=False):
            if not connection.in_atomic_block or connection.get_autocommit():
                raise PreparationHold("HOLD: wrong backend or transaction")
            try:
                repo.lock_request(actor_id, request_id)
                repo.lock_question(question_id)
                if repo.find_receipt(actor_id, request_id) is not None:
                    raise PreparationHold("HOLD: request already exists")
                if OesEntity.objects.using(alias).filter(oes_id=question_id).exists():
                    raise PreparationHold("HOLD: question identity occupied")
                if _phase is not None:
                    _phase("FIVE_ORM_INSERTS")
                repo.insert_entity(entity_uuid, question_id, actor_id)
                repo.insert_question(entity_uuid, actor_id)
                repo.insert_entity_version(version_uuid, entity_uuid, actor_id)
                repo.insert_question_version(version_uuid, entity_uuid, original_text)
                repo.insert_receipt(
                    Receipt(actor_id, request_id, fingerprint, question_id, 1, "REGISTER_Q0"),
                    entity_uuid, version_uuid,
                )
                if _phase is not None:
                    _phase("VERIFY_INSIDE_TRANSACTION")
                checks = (
                    OesEntity.objects.using(alias).filter(pk=entity_uuid, oes_id=question_id).exists(),
                    OesQuestion.objects.using(alias).filter(
                        pk=entity_uuid, responsible_actor_id=actor_id).exists(),
                    OesEntityVersion.objects.using(alias).filter(
                        pk=version_uuid, entity_uuid=entity_uuid, version_no=1,
                        version_status="current").exists(),
                    OesQuestionVersion.objects.using(alias).filter(
                        pk=version_uuid, entity_uuid=entity_uuid,
                        preparation_stage="q0_draft", normalized_text__isnull=True).exists(),
                    OesQuestionCommandReceipt.objects.using(alias).filter(
                        actor_id=actor_id, request_id=request_id,
                        question_entity_uuid=entity_uuid,
                        resulting_version_uuid=version_uuid).exists(),
                )
                if checks != (True,) * 5:
                    raise PreparationHold("HOLD: five-record invariant failed")
            finally:
                # Fail closed: even an unintended normal exit must not commit.
                if _phase is not None:
                    _phase("FORCE_ROLLBACK")
                transaction.set_rollback(True, using=alias)
    except Exception as exc:
        transaction_failure = exc
    finally:
        # Attempt independent read-only reconciliation even after an INSERT,
        # constraint or transaction error. Never retry or compensate with DELETE.
        if connection.in_atomic_block:
            raise PreparationHold("HOLD: transaction boundary remained open")
        connection.close()

    if _phase is not None:
        _phase("VERIFY_ZERO_RESIDUES_NEW_SESSION")
    try:
        residues = (
            OesEntity.objects.using(alias).filter(pk=entity_uuid).exists(),
            OesQuestion.objects.using(alias).filter(pk=entity_uuid).exists(),
            OesEntityVersion.objects.using(alias).filter(pk=version_uuid).exists(),
            OesQuestionVersion.objects.using(alias).filter(pk=version_uuid).exists(),
            OesQuestionCommandReceipt.objects.using(alias).filter(
                actor_id=actor_id, request_id=request_id).exists(),
        )
    except Exception as exc:
        raise PreparationHold("HOLD: independent rollback reconciliation unavailable") from exc
    finally:
        connection.close()
    if any(residues):
        raise PreparationHold("HOLD: residual Q0 records after rollback")
    if transaction_failure is not None:
        raise PreparationHold("HOLD: Q0 transaction failed; zero residues verified") from transaction_failure
    return {"status": "ROLLED_BACK_ONLY", "verified_zero_residues": True}
