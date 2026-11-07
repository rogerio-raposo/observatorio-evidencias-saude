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
from .question_preparation import PreparationHold, PreparationConflict
from .question_orm_q0_repository_dormant import DjangoQ0Repository
from .question_orm_transaction_offline import postgres_session_identity


def _review_q0_database_configuration(databases):
    """Pure review of existing three-alias settings, never a readiness proof.

    A direct pinned endpoint avoids accepting two arbitrary matching hosts as
    evidence of the approved branch. Passwords are compared, never returned.
    Server observations and operational review are still mandatory.
    """
    host = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
    roles = {"default": "oes_auth_trial_login", "oes_q0_writer": "oes_qprep_login",
             "oes_synthetic_reader": "oes_pg_a4_reader"}
    passwords = []
    for alias, role in roles.items():
        config = databases.get(alias, {})
        if (config.get("ENGINE") != "django.db.backends.postgresql"
                or config.get("HOST") != host or str(config.get("PORT")) != "5432"
                or config.get("NAME") != "oes_sandbox" or config.get("USER") != role
                or config.get("OPTIONS", {}).get("sslmode") != "require"
                or not isinstance(config.get("PASSWORD"), str) or not config["PASSWORD"]):
            raise PreparationHold("HOLD: invalid D2 database configuration")
        # Reject alternate libpq routing/identity options rather than assume
        # HOST/USER describe the effective connection in their presence.
        if set(config.get("OPTIONS", {})) - {"sslmode", "options"}:
            raise PreparationHold("HOLD: unsupported D2 connection options")
        expected_options = {
            "default": "-c search_path=django_auth,public",
            "oes_q0_writer": "",
            "oes_synthetic_reader": "-c default_transaction_read_only=on",
        }
        if config.get("OPTIONS", {}).get("options", "") != expected_options[alias]:
            raise PreparationHold("HOLD: unsupported D2 session options")
        passwords.append(config["PASSWORD"])
    if len(set(passwords)) != 3:
        raise PreparationHold("HOLD: D2 requires distinct credentials")


def _review_q0_session_boundary(*, writer, reader):
    """Dormant session preflight after the repository gate, before atomic.

    Reuses the rollback identity probe; no factories or alias overrides.
    This helper is not an execution entrypoint. Tests use fake connections.
    """
    if (writer is reader or writer.alias != "oes_q0_writer"
            or reader.alias != "oes_synthetic_reader"):
        raise PreparationHold("HOLD: independent D2 reader required")
    for connection in (writer, reader):
        if (connection.vendor != "postgresql" or connection.in_atomic_block
                or connection.get_autocommit() is not True):
            raise PreparationHold("HOLD: invalid D2 transaction boundary")
    with writer.cursor() as cursor:
        if postgres_session_identity(cursor) != ("oes_qprep_login", "oes_sandbox", "off"):
            raise PreparationHold("HOLD: D2 writer identity mismatch")
    with reader.cursor() as cursor:
        if postgres_session_identity(cursor) != ("oes_pg_a4_reader", "oes_sandbox", "on"):
            raise PreparationHold("HOLD: D2 reader identity mismatch")


def _classify_q0_commit_observation(*, expected_receipt, observed_receipt=None,
                                    boundary="UNKNOWN", writer_finished=False,
                                    consistent_read=False, readback_verified=False,
                                    all_records_absent=False):
    """Pure reconciliation policy over the EXISTING receipt/readback contract.

    Inputs are evidence, not caller authorization. No SQL, retry, connection or
    new ledger. A future authorized collector must establish a fresh consistent
    primary snapshot AFTER server-side writer completion and inspect all five
    records (including partial writes/occupied question IDs) before asserting
    absence. Neither close() nor a missing receipt establishes those facts.
    Never pass these classifications off as the command service result.
    """
    from .question_uow_offline import Receipt
    if (not isinstance(expected_receipt, Receipt)
            or not all(isinstance(value, str) and value for value in (
                expected_receipt.actor_id, expected_receipt.request_id,
                expected_receipt.question_id, expected_receipt.fingerprint))
            or len(expected_receipt.fingerprint) != 64
            or any(ch not in "0123456789abcdef" for ch in expected_receipt.fingerprint)
            or type(expected_receipt.version) is not int or expected_receipt.version != 1
            or expected_receipt.command_kind != "REGISTER_Q0" or expected_receipt.justification):
        raise PreparationHold("HOLD: invalid D2 reconciliation identity")
    if boundary not in ("NOT_STARTED", "ROLLED_BACK", "COMMIT_ACKNOWLEDGED", "UNKNOWN"):
        raise PreparationHold("HOLD: invalid D2 boundary evidence")
    outcome = "INDETERMINATE"
    if boundary == "NOT_STARTED":
        # No writer effects is local evidence only for this invocation. A
        # previous attempt using these keys must still be reconciled separately.
        if observed_receipt is None and readback_verified is False:
            outcome = "ABSENT"
    elif writer_finished is True and consistent_read is True:
        if isinstance(observed_receipt, Receipt):
            if (observed_receipt.actor_id, observed_receipt.request_id) != (
                    expected_receipt.actor_id, expected_receipt.request_id):
                return {"outcome": outcome, "scope": "Q0_RECORDS", "automatic_retry": False}
            if observed_receipt.fingerprint != expected_receipt.fingerprint:
                raise PreparationConflict("HOLD: request fingerprint conflict")
            if (type(observed_receipt.version) is int
                    and observed_receipt == expected_receipt and readback_verified is True
                    and all_records_absent is False and boundary != "ROLLED_BACK"):
                outcome = "PERSISTED"
        elif (observed_receipt is None and all_records_absent is True
                and readback_verified is False and boundary != "COMMIT_ACKNOWLEDGED"):
            outcome = "ABSENT"
    return {"outcome": outcome,
            "scope": "THIS_ATTEMPT" if boundary == "NOT_STARTED" else "Q0_RECORDS",
            "automatic_retry": False}


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


def _review_q0_persistence_d1(*, user, command):
    """Internal commit composition, blocked by the existing repository gate.

    No HTTP/CLI wiring. Offline tests replace the repository, atomic boundary,
    auth-store lookup and readback; their normal exits are NOT commit evidence.
    No factory or alias is accepted from callers. Do not activate the repository
    to use this blueprint without separate connected review and authorization.
    """
    from contextlib import contextmanager
    from .question_preparation import (
        QuestionCommand, submit_authenticated_question_command,
    )
    from .question_orm_q0_dormant import DormantQ0OrmPort
    from .question_uow_offline import OfflineQuestionUnitOfWork

    if (not isinstance(command, QuestionCommand)
            or type(command.expected_version) is not int
            or command.expected_version != 0
            or command.normalized_text is not None or command.justification != ""):
        raise PreparationHold("HOLD: D1 accepts REGISTER_Q0 only")

    class Composition:
        def execute(self, *, command, actor_id, fingerprint):
            # Authentication, permission, command validation and persisted actor
            # resolution have completed before the (still blocked) constructor.
            # Never use object.__new__, subclassing or a trial repository here.
            repository = DjangoQ0Repository(alias="oes_q0_writer")

            @contextmanager
            def writer_transaction():
                writer = connections["oes_q0_writer"]
                if (writer.vendor != "postgresql" or writer.in_atomic_block
                        or not writer.get_autocommit()):
                    raise PreparationHold("HOLD: D1 requires an independent writer boundary")
                try:
                    _review_q0_database_configuration(connections.databases)
                    reader = connections["oes_synthetic_reader"]
                    # Discard a previous reader session before preflight. No
                    # assumption that this alone provides snapshot consistency.
                    if reader is writer:
                        raise PreparationHold("HOLD: independent D2 reader required")
                    if reader.in_atomic_block:
                        raise PreparationHold("HOLD: invalid D2 reader boundary")
                    reader.close()
                    try:
                        _review_q0_session_boundary(writer=writer, reader=reader)
                    finally:
                        reader.close()
                    with transaction.atomic(using="oes_q0_writer", savepoint=False):
                        # Recheck the effective writer inside the boundary,
                        # exactly as the rollback-only recipe does.
                        with writer.cursor() as cursor:
                            if postgres_session_identity(cursor) != (
                                    "oes_qprep_login", "oes_sandbox", "off"):
                                raise PreparationHold("HOLD: D2 writer identity mismatch")
                        yield
                finally:
                    boundary_open = writer.in_atomic_block
                    writer.close()
                    if boundary_open:
                        raise PreparationHold("HOLD: D1 writer boundary remained open")

            @contextmanager
            def repository_context():
                yield repository

            port = DormantQ0OrmPort(
                atomic_factory=writer_transaction,
                repository_factory=repository_context,
                readback_verifier=_verify_committed_q0_readback,
                writer_alias="oes_q0_writer", read_alias="oes_synthetic_reader",
            )
            return OfflineQuestionUnitOfWork(port).execute(
                command=command, actor_id=actor_id, fingerprint=fingerprint)

    return submit_authenticated_question_command(
        user=user, command=command, unit_of_work=Composition())


def _review_authenticated_q0_composition(*, user, command, writer_alias,
                                         read_alias):
    """Non-executable Django Q0 blueprint, gated before any external effect.

    Future activation requires a separate review of the concrete aliases,
    database roles, transaction guarantees and receipt reconciliation.
    No caller-supplied factories can bypass this gate.
    """
    raise PreparationHold("HOLD: Django Q0 integrated executor not authorized")

    # UNREACHABLE reference composition; no database connection is available.
    # Unlike the earlier injected atomic_factory, the future transaction must
    # be bound explicitly to the same writer alias as the ORM repository.
    from contextlib import contextmanager
    from .question_orm_q0_dormant import DormantQ0OrmPort
    from .question_uow_offline import OfflineQuestionUnitOfWork
    from .question_preparation import submit_authenticated_question_command

    @contextmanager
    def writer_transaction():
        with transaction.atomic(using=writer_alias, savepoint=False):
            yield

    @contextmanager
    def writer_repository():
        yield DjangoQ0Repository(alias=writer_alias)

    port = DormantQ0OrmPort(
        atomic_factory=writer_transaction,
        repository_factory=writer_repository,
        readback_verifier=_verify_committed_q0_readback,
        writer_alias=writer_alias,
        read_alias=read_alias,
    )
    return submit_authenticated_question_command(
        user=user, command=command,
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
