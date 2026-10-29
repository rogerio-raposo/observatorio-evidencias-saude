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
    """Public gate: a source-level change and separate approval are required."""
    raise PreparationHold("HOLD: G2-P2B connected execution not authorized")


def _review_authenticated_q0_composition(*, user, command, atomic_factory,
                                         repository_factory, readback_verifier,
                                         writer_alias, read_alias):
    """Dormant integration blueprint. Never callable as an operational executor.

    This function is deliberately blocked BEFORE evaluating user identity,
    factories or aliases, including when invoked directly by an internal caller.
    The code following the gate is reviewed source for a future separately
    approved activation; it is not evidence of commit or database readiness.
    """
    raise PreparationHold("HOLD: Django Q0 integrated executor not authorized")

    # Unreachable until a distinct source-reviewed gate activation. The future
    # implementation must also prove real transaction.atomic, branch identity,
    # least-privilege ACL and durable receipt-based reconciliation.
    from .question_orm_q0_dormant import DormantQ0OrmPort
    from .question_uow_offline import OfflineQuestionUnitOfWork
    from .question_preparation import submit_authenticated_question_command

    port = DormantQ0OrmPort(
        atomic_factory=atomic_factory,
        repository_factory=repository_factory,
        readback_verifier=readback_verifier,
        writer_alias=writer_alias,
        read_alias=read_alias,
    )
    return submit_authenticated_question_command(
        user=user,
        command=command,
        unit_of_work=OfflineQuestionUnitOfWork(port),
    )


def _rollback_recipe(*, alias, actor_id, request_id, question_id, original_text,
                     fingerprint, trial=None, reconcile_alias=None, _trial_repository=None, _phase=None):
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
    # A separate alias is mandatory; never reconcile through the writer session.
    if (not isinstance(reconcile_alias, str) or not reconcile_alias
            or reconcile_alias == alias or reconcile_alias not in connections.databases):
        raise PreparationHold("HOLD: independent readonly reconciliation alias absent")
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
                transaction.set_rollback(True, using=alias)
                if _phase is not None:
                    _phase("FORCE_ROLLBACK")
    except Exception as exc:
        transaction_failure = exc
    finally:
        # Attempt independent read-only reconciliation even after an INSERT,
        # constraint or transaction error. Never retry or compensate with DELETE.
        boundary_open = connection.in_atomic_block
        connection.close()
        if boundary_open:
            raise PreparationHold("HOLD: transaction boundary remained open")

    reader = connections[reconcile_alias]
    try:
        if _phase is not None:
            _phase("VERIFY_ZERO_RESIDUES_NEW_SESSION")
        if (reader is connection or reader.vendor != "postgresql"
                or reader.in_atomic_block or not reader.get_autocommit()):
            raise PreparationHold("HOLD: independent reader transaction boundary invalid")
        # Server-side check; a Django alias name alone is not an ACL guarantee.
        with reader.cursor() as cursor:
            cursor.execute("SELECT current_setting('transaction_read_only'), current_user, current_database()")
            readonly, reader_role, reader_database = cursor.fetchone()
        if (readonly != "on" or reader_role == "oes_qprep_login"
                or reader_database != "oes_sandbox"):
            raise PreparationHold("HOLD: reconciler must be a separate readonly identity")
        residues = (
            OesEntity.objects.using(reconcile_alias).filter(pk=entity_uuid).exists(),
            OesQuestion.objects.using(reconcile_alias).filter(pk=entity_uuid).exists(),
            OesEntityVersion.objects.using(reconcile_alias).filter(pk=version_uuid).exists(),
            OesQuestionVersion.objects.using(reconcile_alias).filter(pk=version_uuid).exists(),
            OesQuestionCommandReceipt.objects.using(reconcile_alias).filter(
                actor_id=actor_id, request_id=request_id).exists(),
        )
    except Exception as exc:
        raise PreparationHold("HOLD: independent rollback reconciliation unavailable") from exc
    finally:
        reader.close()
    if any(residues):
        raise PreparationHold("HOLD: residual Q0 records after rollback")
    if transaction_failure is not None:
        raise PreparationHold("HOLD: Q0 transaction failed; zero residues verified") from transaction_failure
    return {"status": "ROLLED_BACK_ONLY", "verified_zero_residues": True}


def _verify_committed_q0_readback(*, writer_alias, read_alias, actor_id,
                                  request_id, question_id, fingerprint,
                                  entity_uuid, version_uuid, original_text):
    """Dormant, internal positive readback; NOT a writer or execution gate.

    Caller must separately establish a successful authorized commit and
    trustworthy same-branch reader configuration. A matching readback is
    necessary evidence, not a substitute for that commit proof.
    """
    if (not isinstance(read_alias, str) or not read_alias
            or not isinstance(writer_alias, str) or read_alias == writer_alias
            or read_alias not in connections.databases):
        raise PreparationHold("HOLD: independent readback alias required")
    if (not all(isinstance(value, str) and value for value in (
            actor_id, request_id, question_id, fingerprint, original_text))
            or len(fingerprint) != 64
            or any(ch not in "0123456789abcdef" for ch in fingerprint)
            or type(entity_uuid) is not UUID or type(version_uuid) is not UUID
            or entity_uuid == version_uuid):
        raise PreparationHold("HOLD: invalid Q0 readback identity")
    reader = connections[read_alias]
    try:
        if (reader.vendor != "postgresql" or reader.in_atomic_block
                or not reader.get_autocommit()):
            raise PreparationHold("HOLD: invalid readback session")
        with reader.cursor() as cursor:
            cursor.execute(
                "SELECT current_setting('transaction_read_only'), "
                "current_user, current_database()"
            )
            readonly, role, database = cursor.fetchone()
        if readonly != "on" or role == "oes_qprep_login" or database != "oes_sandbox":
            raise PreparationHold("HOLD: readback session is not independent readonly")
        checks = (
            OesEntity.objects.using(read_alias).filter(
                pk=entity_uuid, oes_id=question_id, entity_type="Question",
                created_by=actor_id).count() == 1,
            OesQuestion.objects.using(read_alias).filter(
                pk=entity_uuid, responsible_actor_id=actor_id).count() == 1,
            OesEntityVersion.objects.using(read_alias).filter(
                pk=version_uuid, entity_uuid=entity_uuid, version_no=1,
                version_status="current", created_by=actor_id).count() == 1,
            OesQuestionVersion.objects.using(read_alias).filter(
                pk=version_uuid, entity_uuid=entity_uuid,
                original_text=original_text, preparation_stage="q0_draft",
                normalized_text__isnull=True).count() == 1,
            OesQuestionCommandReceipt.objects.using(read_alias).filter(
                actor_id=actor_id, request_id=request_id,
                fingerprint_sha256=fingerprint, question_id=question_id,
                question_entity_uuid=entity_uuid,
                resulting_version_uuid=version_uuid, resulting_version_no=1,
                command_kind="REGISTER_Q0").count() == 1,
        )
        if checks != (True,) * 5:
            raise PreparationHold("HOLD: committed Q0 readback invariant failed")
    except PreparationHold:
        raise
    except Exception as exc:
        raise PreparationHold("HOLD: positive Q0 readback unavailable") from exc
    finally:
        reader.close()
    return {"readback_verified": True, "question_id": question_id, "version": 1}
