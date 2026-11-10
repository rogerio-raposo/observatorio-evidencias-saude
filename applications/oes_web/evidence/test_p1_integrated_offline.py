"""P1 deltas only: shared D3/F1 fakes, no PostgreSQL connection or commit proof."""
from types import SimpleNamespace
from unittest.mock import patch

from django.db import IntegrityError, OperationalError
from django.test import SimpleTestCase
from psycopg.pq import TransactionStatus

from config.mb_oc1 import private_configuration
from config.q0_limits import execution_limits, review_limit_options
from evidence import test_mb_oc1_offline as mb
from evidence import test_q0_f1_offline as f1
from evidence import test_q0_persistence_d3_offline as d3
from evidence.forms import prepare_q0_submission
from evidence.question_preparation import (
    PreparationHold, _q0_failure_evidence, register_authenticated_q0,
)
from evidence.question_orm_q0_connected_recipe_dormant import (
    _review_q0_database_configuration, _review_q0_reader_configuration,
)
from evidence.question_orm_q0_evidence_dormant import _review_q0_privileges
from evidence import question_orm_q0_repository_dormant as repository


def database_failure(state="23505", schema="core", table="entity", constraint="entity_oes_id_key"):
    cause = Exception("private owner/content/password must not escape")
    cause.sqlstate = state
    cause.diag = SimpleNamespace(schema_name=schema, table_name=table, constraint_name=constraint)
    error = IntegrityError("private database details") if state.startswith("23") else OperationalError("private details")
    error.__cause__ = cause
    return error


class P1AttemptTests(SimpleTestCase):
    def setUp(self):
        self.case = f1.Q0F1Tests()
        self.case.setUp()
        self.addCleanup(self.case.doCleanups)
        self.f = self.case.f
        self.f.writer.closed_in_transaction = False
        self.f.writer.needs_rollback = False
        self.f.writer.connection.info.transaction_status = TransactionStatus.IDLE

    def submit_error(self):
        with self.assertRaises(PreparationHold) as raised:
            with repository._application_q0_scope(user=self.f.user, command=self.f.command):
                register_authenticated_q0(user=self.f.user, command=self.f.command)
        self.assertIsNone(repository._trial_scope.get())
        return raised.exception

    def test_known_unique_violation_has_confirmed_rollback_not_commit_uncertainty(self):
        self.f.status = "aborted"
        self.f.has_receipt = False
        self.f.models["OesEntity"].objects.using.return_value.create.side_effect = database_failure()
        error = self.submit_error()
        self.assertIn("rolled back", str(error))
        self.assertEqual(error.q0_failure, {"kind": "DETERMINISTIC_ROLLBACK",
            "attempt_outcome": "ROLLED_BACK", "automatic_retry": False,
            "sqlstate": "23505", "constraint_class": "GLOBAL_IDENTIFIER"})
        self.assertEqual(error.q0_observation["outcome"], "ABSENT")
        self.f.models["OesQuestion"].objects.using.return_value.create.assert_not_called()

    def test_unknown_unique_constraint_is_still_rolled_back_without_contract_conflict(self):
        error = _q0_failure_evidence(database_failure(schema="foreign"), phase="IN_TRANSACTION",
            boundary="ROLLED_BACK", candidate_present=True)
        self.assertEqual(error["kind"], "FAILURE_ROLLED_BACK")
        self.assertEqual(error["attempt_outcome"], "ROLLED_BACK")
        self.assertNotIn("constraint_class", error)

    def test_lock_timeout_deadlock_and_serialization_rollback_never_retry(self):
        for state in ("55P03", "40P01", "40001", "57014"):
            with self.subTest(state=state):
                evidence = _q0_failure_evidence(database_failure(state), phase="IN_TRANSACTION",
                    boundary="ROLLED_BACK", candidate_present=True)
                self.assertEqual(evidence["kind"], "DETERMINISTIC_ROLLBACK")
                self.assertFalse(evidence["automatic_retry"])

    def test_each_insert_failure_preserves_known_rollback_and_single_attempt(self):
        self.f.has_receipt = False
        for model in self.f.models.values():
            create = model.objects.using.return_value.create
            create.side_effect = database_failure("23514")
            with self.subTest(model=model), self.assertRaises(PreparationHold) as raised:
                with repository._application_q0_scope(user=self.f.user, command=self.f.command):
                    register_authenticated_q0(user=self.f.user, command=self.f.command)
            self.assertEqual(raised.exception.q0_failure["attempt_outcome"], "ROLLED_BACK")
            self.assertFalse(raised.exception.q0_failure["automatic_retry"])
            create.assert_called_once()
            create.side_effect = None
            for reset in self.f.models.values():
                reset.objects.using.return_value.create.reset_mock()

    def test_unusable_connection_does_not_prove_rollback(self):
        self.f.writer.closed_in_transaction = True
        self.f.writer.connection.info.transaction_status = TransactionStatus.UNKNOWN
        error = self.submit_error()
        self.assertEqual(error.q0_failure["attempt_outcome"], "UNKNOWN")
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_not_called()

    def test_commit_rejection_and_transport_loss_with_idle_driver_are_distinct(self):
        from unittest.mock import MagicMock
        writer = self.native_writer_boundary()
        for state, outcome in (("23505", "ROLLED_BACK"), ("40001", "ROLLED_BACK"), ("08006", "UNKNOWN")):
            driver = writer.connection = MagicMock()
            driver.info.transaction_status = TransactionStatus.IDLE
            driver.commit.side_effect = database_failure(state)
            self.f.has_receipt = False
            self.f.status = "aborted" if outcome == "ROLLED_BACK" else None
            with self.subTest(sqlstate=state):
                error = self.submit_error()
                driver.commit.assert_called_once()
                driver.rollback.assert_called_once()
                self.assertEqual(error.q0_failure["attempt_outcome"], outcome)
                self.assertFalse(error.q0_failure["automatic_retry"])

    def test_lost_commit_confirmation_stays_uncertain_despite_positive_readback(self):
        self.f.writer_exit_failure = True
        error = self.submit_error()
        self.assertEqual(error.q0_failure["attempt_outcome"], "UNKNOWN")
        self.assertEqual(error.q0_observation["outcome"], "PERSISTED")
        self.f.models["OesEntity"].objects.using.return_value.create.assert_called_once()

    def native_writer_boundary(self):
        # Real Django Atomic and PostgreSQL wrapper transaction lifecycle; only
        # its driver/cursors are fake. No connection or SQL is executed.
        from django.db.transaction import Atomic
        from django.db.backends.postgresql.base import DatabaseWrapper
        from unittest.mock import MagicMock

        previous = self.f.writer
        writer = DatabaseWrapper({**self.f.configs["oes_q0_writer"], "AUTOCOMMIT": True},
                                 alias="oes_q0_writer")
        driver = writer.connection = MagicMock()
        writer.connection.info.transaction_status = TransactionStatus.IDLE
        writer.autocommit = True
        writer.cursor = previous.cursor  # Same offline catalogue fixture.
        cursor = writer.cursor.return_value.__enter__.return_value
        original_query = cursor.execute.side_effect
        def query(sql, params=None):
            # The shared fixture identifies its original writer by object identity.
            self.f.writer = previous
            try:
                return original_query(sql, params)
            finally:
                self.f.writer = writer
        cursor.execute.side_effect = query
        self.f.writer = writer
        self.addCleanup(setattr, self.f, "writer", previous)
        self.f.connections.__getitem__.side_effect = {
            "oes_q0_writer": writer, "oes_synthetic_reader": self.f.reader}.__getitem__
        original = self.f.atomic.side_effect

        def boundary(*, using, savepoint):
            if using == "oes_q0_writer":
                return Atomic(using, savepoint, durable=False)
            return original(using=using, savepoint=savepoint)

        self.f.atomic.side_effect = boundary
        self.enterContext(patch("django.db.transaction.get_connection", side_effect=lambda using=None: writer))
        # Ensure a test bug cannot open even an accidental real session.
        self.enterContext(patch.object(writer, "get_new_connection", side_effect=AssertionError("real connection forbidden")))
        return writer

    def test_native_atomic_post_commit_error_is_not_a_commit_rejection(self):
        from django.db import transaction
        writer = self.native_writer_boundary()
        driver = writer.connection
        events = []
        driver.commit.side_effect = lambda: events.append("commit returned")
        def failed_hook():
            events.append("callback failed")
            raise database_failure("23505")
        def insert(**kwargs):
            transaction.on_commit(failed_hook, using="oes_q0_writer")
        self.f.models["OesEntity"].objects.using.return_value.create.side_effect = insert
        error = self.submit_error()
        self.assertEqual(events, ["commit returned", "callback failed"])
        driver.rollback.assert_not_called()
        self.assertEqual(error.q0_failure["kind"], "POST_COMMIT_VERIFICATION_FAILED")
        self.assertEqual(error.q0_failure["attempt_outcome"], "COMMIT_ACKNOWLEDGED")
        self.assertEqual(error.q0_observation["outcome"], "PERSISTED")
        self.assertFalse(error.q0_failure["automatic_retry"])

    def test_native_body_rollback_clears_commit_acknowledgement_hook(self):
        writer = self.native_writer_boundary()
        driver = writer.connection
        self.f.status = "aborted"
        self.f.has_receipt = False
        self.f.models["OesEntity"].objects.using.return_value.create.side_effect = database_failure()
        error = self.submit_error()
        driver.commit.assert_not_called()
        driver.rollback.assert_called_once()
        self.assertEqual(writer.run_on_commit, [])
        self.assertEqual(error.q0_failure["attempt_outcome"], "ROLLED_BACK")
        self.assertEqual(error.q0_observation["outcome"], "ABSENT")

    def test_running_attempt_can_observe_older_receipt_without_becoming_success(self):
        self.f.status = "in progress"
        self.f.writer.connection.info.transaction_status = TransactionStatus.UNKNOWN
        self.f.repo.current_question.side_effect = database_failure("23514")
        error = self.submit_error()
        self.assertEqual(error.q0_failure["attempt_outcome"], "UNKNOWN")
        self.assertEqual(error.q0_observation["outcome"], "PERSISTED")
        self.assertEqual(error.q0_observation["server_xact_status"], "in progress")
        self.assertEqual(error.q0_observation["receipt_association"], "EXISTING_OR_UNATTRIBUTED")
        self.assertFalse(error.q0_observation["automatic_retry"])
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_not_called()

    def test_receipt_preexisting_after_failed_lookup_never_promotes_current_attempt(self):
        self.f.status = "aborted"
        self.f.repo.current_question.side_effect = database_failure("23514")
        error = self.submit_error()
        self.assertEqual(error.q0_failure["attempt_outcome"], "ROLLED_BACK")
        self.assertEqual(error.q0_observation["outcome"], "PERSISTED")
        self.assertEqual(error.q0_observation["receipt_association"], "EXISTING_OR_UNATTRIBUTED")
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_not_called()

    def test_replay_readback_conflict_is_post_commit_failure_not_preinsert_409(self):
        self.f.repo.find_receipt.return_value = self.f.expected
        self.f.record.fingerprint_sha256 = "0" * 64
        error = self.submit_error()
        self.assertEqual(error.q0_failure["kind"], "POST_COMMIT_VERIFICATION_FAILED")
        self.assertEqual(error.q0_observation["outcome"], "INDETERMINATE")
        self.f.lookup_receipt.return_value.using.return_value.first.assert_called_once()
        with patch("evidence.question_preparation.register_authenticated_q0", side_effect=error):
            self.assertEqual(prepare_q0_submission(user=self.f.user, data=self.case.data)[0], 503)
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_not_called()

    def test_post_commit_reader_failure_retains_acknowledgement_without_success(self):
        self.f.models["OesQuestionCommandReceipt"].objects.using.return_value.create.side_effect = (
            lambda **kwargs: setattr(self.f, "reader_unavailable", True))
        error = self.submit_error()
        self.assertEqual(error.q0_failure["kind"], "POST_COMMIT_VERIFICATION_FAILED")
        self.assertEqual(error.q0_observation["outcome"], "INDETERMINATE")

    def test_preflight_failure_has_no_write_attempt(self):
        self.f.bad_writer_identity = True
        error = self.submit_error()
        self.assertEqual(error.q0_failure["kind"], "BEFORE_TRANSACTION")
        self.assertEqual(error.q0_observation["scope"], "THIS_ATTEMPT")
        self.f.atomic.assert_not_called()

    def test_global_collision_never_becomes_external_409_or_discloses_details(self):
        self.f.has_receipt = False
        self.f.models["OesEntity"].objects.using.return_value.create.side_effect = database_failure()
        status, context = prepare_q0_submission(user=self.f.user, data=self.case.data)
        self.assertEqual(status, 503)
        self.assertIn("revertida", context["result_message"])
        for private in ("private", "GLOBAL_IDENTIFIER", "23505", "entity_oes_id_key"):
            self.assertNotIn(private, context["result_message"])
        self.assertEqual(context["form"].data, self.case.data)
        self.assertNotIn("confirmed_question_id", context)

    def test_simplified_path_has_one_question_lock_xid_and_privilege_pass(self):
        status, _ = prepare_q0_submission(user=self.f.user, data=self.case.data)
        self.assertEqual(status, 200)
        sql = [s for alias, s in self.f.events if alias == "oes_q0_writer"]
        self.assertEqual(sum("pg_current_xact_id" in s for s in sql), 1)
        self.assertEqual(sum("has_table_privilege" in s for s in sql), 5)
        self.assertEqual(sum("has_schema_privilege" in s for s in sql), 2)
        self.assertEqual(sum("pg_advisory_xact_lock" in s for s in sql), 2)  # request + question
        self.assertEqual(sum("current_user" in s and "has_" not in s for s in sql), 2)
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_called_once()

    def test_simulated_competitors_observe_receipt_after_request_lock_without_second_insert(self):
        # Serialized schedule at the existing request lock; not a PostgreSQL race test.
        self.assertEqual(prepare_q0_submission(user=self.f.user, data=self.case.data)[0], 200)
        self.f.repo.find_receipt.return_value = self.f.expected
        self.assertEqual(prepare_q0_submission(user=self.f.user, data=self.case.data)[0], 200)
        changed = {**self.case.data, "original_text": "Different synthetic command"}
        self.assertEqual(prepare_q0_submission(user=self.f.user, data=changed)[0], 409)
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_called_once()


class P1EvidenceTests(SimpleTestCase):
    def setUp(self):
        self.f = d3.EvidenceD3Tests()
        self.f.setUp()
        self.addCleanup(self.f.doCleanups)

    def test_positive_receipt_survives_unavailable_xid_history(self):
        cursor = self.f.reader.cursor.return_value.__enter__.return_value
        original = cursor.execute.side_effect
        def query(sql, params=None):
            if "pg_xact_status" in sql:
                raise OperationalError("unavailable function/history")
            return original(sql, params)
        cursor.execute.side_effect = query
        result = self.f.collect(self.f.trace())
        self.assertEqual(result["outcome"], "PERSISTED")
        self.assertIsNone(result["server_xact_status"])
        self.assertEqual(result["receipt_association"], "CURRENT_CANDIDATE")

    def test_previous_receipt_after_aborted_attempt_is_not_success_of_that_attempt(self):
        self.f.status = "aborted"
        trace = self.f.trace()
        trace.candidate = None
        trace.boundary = "ROLLED_BACK"
        result = self.f.collect(trace)
        self.assertEqual(result["outcome"], "PERSISTED")
        self.assertEqual(result["receipt_association"], "EXISTING_OR_UNATTRIBUTED")
        self.assertEqual(result["writer_boundary"], "ROLLED_BACK")

    def test_rollback_contradicts_same_candidate_even_without_xid_status(self):
        self.f.status = None
        trace = self.f.trace()
        trace.boundary = "ROLLED_BACK"
        self.assertEqual(self.f.collect(trace)["outcome"], "INDETERMINATE")

    def test_missing_receipt_without_xid_proof_remains_indeterminate(self):
        self.f.status = None
        self.f.has_receipt = False
        self.assertEqual(self.f.collect(self.f.trace())["outcome"], "INDETERMINATE")

    def test_column_only_insert_update_grants_fail_existing_acl_verifier(self):
        for connection, row in ((self.f.reader, (True, False, False, True, False)),
                                (self.f.reader, (True, False, False, False, True)),
                                (self.f.writer, (True, True, False, True, True))):
            cursor = connection.cursor.return_value.__enter__.return_value
            original = cursor.execute.side_effect
            def query(sql, params=None, original=original, row=row, cursor=cursor):
                original(sql, params)
                if "has_table_privilege" in sql:
                    self.assertIn("has_any_column_privilege", sql)
                    cursor.fetchone.return_value = row
            with self.subTest(alias=connection.alias, row=row), patch.object(cursor, "execute", side_effect=query):
                with self.assertRaises(PreparationHold):
                    _review_q0_privileges(connection)


class P1LimitsTests(SimpleTestCase):
    def test_private_application_and_existing_validators_agree_without_connection(self):
        config = private_configuration(mb.PrivateProfileTests().env())
        with patch("django.db.connections") as connections:
            _review_q0_database_configuration(config["DATABASES"])
            _review_q0_reader_configuration(config["DATABASES"])
            connections.__getitem__.assert_not_called()
        for database in config["DATABASES"].values():
            self.assertEqual(database["OPTIONS"]["connect_timeout"], 3)
            self.assertIn("statement_timeout=1000 -c lock_timeout=200", database["OPTIONS"]["options"])

    def test_limits_are_explicit_finite_ordered_and_have_no_operational_defaults(self):
        env = mb.PrivateProfileTests().env()
        for value in ("", "0", "-1", "1.5", " 3", "03", "2147483648", "1 -c anything=on"):
            with self.subTest(value=value), self.assertRaises(RuntimeError):
                execution_limits({**env, "OES_MB_OC1_CONNECT_TIMEOUT_SECONDS": value})
        for value in ("1000", "1001"):
            with self.assertRaises(RuntimeError):
                execution_limits({**env, "OES_MB_OC1_LOCK_TIMEOUT_MS": value})

    def test_incomplete_or_injected_limit_options_rejected_legacy_stays_valid(self):
        baseline = "-c default_transaction_read_only=on"
        self.assertTrue(review_limit_options({"options": baseline}, baseline))
        for options in ({"options": baseline, "connect_timeout": 3},
                        {"options": baseline + " -c statement_timeout=1000 -c lock_timeout=200"},
                        {"options": baseline + " -c transaction_read_only=off", "connect_timeout": 3},
                        {"options": baseline, "arbitrary": True}):
            self.assertFalse(review_limit_options(options, baseline))
