"""D3 collector and canonical composition; every external boundary is fake."""
from contextlib import contextmanager
from datetime import datetime, timedelta, timezone
from types import SimpleNamespace
from unittest.mock import MagicMock, Mock, patch
from uuid import UUID, uuid4

from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold, PreparationConflict, QuestionCommand
from evidence.question_orm_q0_connected_recipe_dormant import _review_q0_persistence_d1
from evidence.question_orm_q0_evidence_dormant import (
    _WriterTrace, _expected_receipt, _collect_q0_commit_evidence,
    _capture_q0_writer_transaction, _review_q0_privileges, _recover_q0_commit_evidence,
)
from preparer_identity.models import PreparerIdentity

E = "evidence.question_orm_q0_evidence_dormant."
C = "evidence.question_orm_q0_connected_recipe_dormant."


class EvidenceD3Tests(SimpleTestCase):
    def setUp(self):
        self.actor = "oes:actor:12345678-1234-4234-8234-123456789abc"
        self.command = QuestionCommand("d3-request", "OES-SYNTH-D3", 0, "Synthetic technical question?")
        self.expected = _expected_receipt(self.command, self.actor)
        self.e, self.v = uuid4(), uuid4()
        self.now = datetime(2026, 11, 7, 20, 0, tzinfo=timezone.utc)
        self.snapshot = ("oes_pg_a4_reader", "oes_sandbox", "on", "repeatable read", False,
                         "101:105:", self.now, self.now + timedelta(seconds=1))
        self.status = "committed"
        self.has_receipt = True
        self.writer_exit_failure = False
        self.reader_exit_failure = False
        self.bad_reader_identity = False
        self.bad_privileges = False
        self.bad_writer_identity = False
        self.reader_unavailable = False
        self.dynamic_ids = False
        self.events = []
        self.writer = MagicMock(alias="oes_q0_writer", vendor="postgresql", in_atomic_block=False)
        self.reader = MagicMock(alias="oes_synthetic_reader", vendor="postgresql", in_atomic_block=False)
        self.configs = {}
        for alias, role, options in (
                ("default", "oes_auth_trial_login", "-c search_path=django_auth,public"),
                ("oes_q0_writer", "oes_qprep_login", ""),
                ("oes_synthetic_reader", "oes_pg_a4_reader", "-c default_transaction_read_only=on")):
            self.configs[alias] = {"ENGINE": "django.db.backends.postgresql",
                "HOST": "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech", "PORT": "5432",
                "NAME": "oes_sandbox", "USER": role, "PASSWORD": "offline-fake-" + alias,
                "OPTIONS": {"sslmode": "require", "options": options}}
        for connection in (self.writer, self.reader):
            connection.get_autocommit.side_effect = lambda connection=connection: not connection.in_atomic_block
            cursor = connection.cursor.return_value.__enter__.return_value
            def execute(sql, params=None, cursor=cursor, connection=connection):
                self.events.append((connection.alias, sql))
                if connection is self.reader and self.reader_unavailable:
                    raise RuntimeError("offline reader error")
                if "has_schema_privilege" in sql:
                    row = (not self.bad_privileges,)
                elif "has_table_privilege" in sql:
                    row = (True, True, False) if connection is self.writer else (True, False, False)
                    if self.bad_privileges:
                        row = (True, True, True)
                elif "pg_current_xact_id" in sql:
                    row = ("100",)
                elif "pg_xact_status" in sql:
                    row = (self.status,)
                elif "pg_current_snapshot" in sql:
                    row = self.snapshot
                elif "current_setting('transaction_isolation'),pg_is_in_recovery" in sql:
                    row = (self.snapshot[3], self.snapshot[4])
                elif "current_setting('transaction_read_only'), current_user" in sql:
                    row = ("on", "oes_pg_a4_reader", "oes_sandbox")
                elif connection is self.writer:
                    row = ("owner" if self.bad_writer_identity else "oes_qprep_login", "oes_sandbox", "off")
                else:
                    row = ("owner" if self.bad_reader_identity else "oes_pg_a4_reader", "oes_sandbox", "on")
                cursor.fetchone.return_value = row
            cursor.execute.side_effect = execute
        connections = MagicMock(databases=self.configs)
        connections.__getitem__.side_effect = {"oes_q0_writer": self.writer, "oes_synthetic_reader": self.reader}.__getitem__
        self.enterContext(patch(E + "connections", connections))
        self.enterContext(patch(C + "connections", connections))

        @contextmanager
        def atomic(*, using, savepoint):
            self.assertIs(savepoint, False)
            conn = self.writer if using == "oes_q0_writer" else self.reader
            self.assertFalse(conn.in_atomic_block)
            conn.in_atomic_block = True
            try:
                yield
            finally:
                conn.in_atomic_block = False
            if conn is self.writer and self.writer_exit_failure:
                raise RuntimeError("offline lost acknowledgement")
            if conn is self.reader and self.reader_exit_failure:
                raise RuntimeError("offline reader exit error")
        self.atomic = self.enterContext(patch(C + "transaction.atomic", side_effect=atomic))
        # Both modules use the same django.db.transaction object.
        self.models = {}
        for name in ("OesEntity", "OesQuestion", "OesEntityVersion", "OesQuestionVersion", "OesQuestionCommandReceipt"):
            model = MagicMock()
            model.objects.using.return_value.filter.return_value.count.return_value = 1
            model.objects.using.return_value.filter.return_value.exists.return_value = False
            self.enterContext(patch(E + name, model))
            self.enterContext(patch(C + name, model))
            self.models[name] = model
        self.repo = Mock()
        self.repo.find_receipt.return_value = None
        self.repo.current_question.return_value = None
        self.repo.can_access_question.return_value = True
        self.record = SimpleNamespace(actor_id=self.actor, request_id=self.command.request_id,
            fingerprint_sha256=self.expected.fingerprint, question_id=self.command.question_id,
            resulting_version_no=1, command_kind="REGISTER_Q0", justification="",
            question_entity_uuid=self.e, resulting_version_uuid=self.v,
            committed_at=self.now - timedelta(seconds=1))
        def get_record():
            if not self.has_receipt:
                return None
            if self.dynamic_ids and self.repo.insert_receipt.call_args:
                _, self.record.question_entity_uuid, self.record.resulting_version_uuid = self.repo.insert_receipt.call_args.args
            return self.record
        self.lookup_receipt = self.enterContext(patch(E + "request_receipt"))
        self.lookup_receipt.return_value.using.return_value.first.side_effect = get_record
        self.user = Mock(pk=42, is_authenticated=True, is_active=True, is_staff=False, is_superuser=False)
        self.user.has_perm.return_value = True
        self.identity_lookup = self.enterContext(patch("preparer_identity.resolver.PreparerIdentity.objects.using"))
        self.identity_lookup.return_value.get.return_value = SimpleNamespace(
            actor_uuid=UUID(self.actor.removeprefix("oes:actor:")))

    def trace(self):
        trace = _WriterTrace(self.expected, atomic_entered=True, xid="100")
        trace.candidate = {"entity_uuid": self.e, "version_uuid": self.v,
            "actor_id": self.actor, "request_id": self.command.request_id,
            "question_id": self.command.question_id, "fingerprint": self.expected.fingerprint}
        return trace

    def collect(self, trace=None):
        return _collect_q0_commit_evidence(command=self.command, actor_id=self.actor, trace=trace)

    def canonical(self):
        # Unit-test replacement only. No production constructor activation or
        # alternate repository class/factory exists in the application.
        self.enterContext(patch(C + "DjangoQ0Repository", return_value=self.repo))
        self.dynamic_ids = True
        return _review_q0_persistence_d1(user=self.user, command=self.command)

    def test_receipt_recovers_after_total_loss_of_writer_memory(self):
        result = self.collect()
        self.assertEqual(result["outcome"], "PERSISTED")
        self.assertIs(result["automatic_retry"], False)
        self.assertEqual(result["entity_uuid"], str(self.e))
        self.lookup_receipt.assert_called_once_with(actor_id=self.actor, request_id=self.command.request_id)
        self.assertEqual(result["snapshot"], "101:105:")
        self.assertIsNone(result["writer_identity"])
        self.assertEqual(result["reader_identity"], ("oes_pg_a4_reader", "oes_sandbox", "on"))
        self.assertEqual(len(result["reader_privileges"]), 7)
        for model in self.models.values():
            model.objects.using.return_value.filter.return_value.count.assert_called_once()
        self.assertFalse(self.reader.in_atomic_block)

    def test_no_arbitrary_success_or_consistency_flags_are_accepted(self):
        with self.assertRaises(TypeError):
            _collect_q0_commit_evidence(command=self.command, actor_id=self.actor,
                readback_verified=True, writer_finished=True, consistent_read=True)
        self.atomic.assert_not_called()

    def test_missing_receipt_after_memory_loss_is_indeterminate(self):
        self.has_receipt = False
        self.assertEqual(self.collect()["outcome"], "INDETERMINATE")

    def test_aborted_server_transaction_and_all_residues_absent_prove_absence(self):
        self.status = "aborted"
        self.has_receipt = False
        result = self.collect(self.trace())
        self.assertEqual(result["outcome"], "ABSENT")
        self.assertIs(result["automatic_retry"], False)
        self.assertEqual(result["server_xact_status"], "aborted")

    def test_close_timeout_and_ack_do_not_prove_server_finalization(self):
        self.has_receipt = False
        trace = self.trace()
        trace.local_closed = True
        trace.boundary = "COMMIT_ACKNOWLEDGED"
        for status in (None, "in progress", "committed"):
            self.status = status
            with self.subTest(status=status):
                self.assertEqual(self.collect(trace)["outcome"], "INDETERMINATE")

    def test_residue_or_missing_candidate_prevents_absent_classification(self):
        self.status = "aborted"
        self.has_receipt = False
        self.models["OesEntity"].objects.using.return_value.filter.return_value.exists.return_value = True
        self.assertEqual(self.collect(self.trace())["outcome"], "INDETERMINATE")
        self.models["OesEntity"].objects.using.return_value.filter.return_value.exists.return_value = False
        trace = self.trace()
        trace.candidate = None
        self.assertEqual(self.collect(trace)["outcome"], "INDETERMINATE")

    def test_inflight_or_unknown_xid_is_indeterminate_even_with_apparent_receipt(self):
        for status in (None, "in progress", "unrecognized"):
            self.status = status
            with self.subTest(status=status):
                self.assertEqual(self.collect(self.trace())["outcome"], "INDETERMINATE")

    def test_lost_ack_and_closed_false_can_be_reconciled_by_server_evidence(self):
        result = self.collect(self.trace())
        self.assertEqual(result["outcome"], "PERSISTED")
        self.assertEqual(result["writer_boundary"], "UNKNOWN")
        self.assertIs(result["writer_local_closed"], False)

    def test_contradictory_server_ack_or_receipt_evidence_stays_indeterminate(self):
        self.status = "aborted"
        self.assertEqual(self.collect(self.trace())["outcome"], "INDETERMINATE")
        self.has_receipt = False
        trace = self.trace()
        trace.boundary = "COMMIT_ACKNOWLEDGED"
        self.assertEqual(self.collect(trace)["outcome"], "INDETERMINATE")

    def test_reader_unavailable_or_wrong_identity_or_privilege_fails_closed(self):
        for attribute in ("reader_unavailable", "bad_reader_identity", "bad_privileges"):
            setattr(self, attribute, True)
            with self.subTest(attribute=attribute):
                self.assertEqual(self.collect()["outcome"], "INDETERMINATE")
            setattr(self, attribute, False)

    def test_snapshot_replica_isolation_time_and_token_are_validated(self):
        original = self.snapshot
        for index, value in ((0, "owner"), (2, "off"), (3, "read committed"),
                (4, True), (4, 0), (5, "invalid"), (6, datetime(2026, 1, 1)),
                (7, self.now - timedelta(seconds=1))):
            row = list(original)
            row[index] = value
            self.snapshot = tuple(row)
            with self.subTest(index=index, value=value):
                self.assertEqual(self.collect()["outcome"], "INDETERMINATE")
        self.snapshot = original

    def test_inconsistent_five_records_or_receipt_identifiers_fails_closed(self):
        for model in self.models.values():
            query = model.objects.using.return_value.filter.return_value
            query.count.return_value = 0
            self.assertEqual(self.collect()["outcome"], "INDETERMINATE")
            query.count.return_value = 1
        self.record.resulting_version_uuid = self.e
        self.assertEqual(self.collect()["outcome"], "INDETERMINATE")

    def test_fingerprint_conflict_preserves_existing_exception(self):
        self.record.fingerprint_sha256 = "b" * 64
        with self.assertRaises(PreparationConflict):
            self.collect()

    def test_wrong_request_receipt_cannot_be_used_as_conflict_or_success(self):
        self.record.request_id = "different"
        self.record.fingerprint_sha256 = "b" * 64
        self.assertEqual(self.collect()["outcome"], "INDETERMINATE")

    def test_observed_receipt_ids_must_match_retained_attempt(self):
        trace = self.trace()
        trace.candidate["entity_uuid"] = uuid4()
        self.assertEqual(self.collect(trace)["outcome"], "INDETERMINATE")

    def test_reader_close_or_transaction_exit_failure_invalidates_positive_result(self):
        self.reader_exit_failure = True
        self.assertEqual(self.collect()["outcome"], "INDETERMINATE")
        self.reader_exit_failure = False
        self.reader.close.side_effect = [None, RuntimeError("offline close failure")]
        self.assertEqual(self.collect()["outcome"], "INDETERMINATE")

    def test_external_reader_transaction_is_not_closed_or_used(self):
        self.reader.in_atomic_block = True
        self.assertEqual(self.collect()["outcome"], "INDETERMINATE")
        self.reader.close.assert_not_called()
        self.reader.cursor.assert_not_called()

    def test_pre_transaction_failure_proves_only_no_effects_this_attempt(self):
        trace = _WriterTrace(self.expected)
        result = self.collect(trace)
        self.assertEqual((result["outcome"], result["scope"]), ("ABSENT", "THIS_ATTEMPT"))
        self.atomic.assert_not_called()
        self.reader.cursor.assert_not_called()

    def test_writer_preflight_permissions_and_xid_capture(self):
        rights = _review_q0_privileges(self.writer)
        self.assertEqual(len(rights), 7)
        trace = _WriterTrace(self.expected)
        with self.assertRaises(PreparationHold):
            _capture_q0_writer_transaction(self.writer, trace)
        self.writer.in_atomic_block = True
        _capture_q0_writer_transaction(self.writer, trace)
        self.assertEqual(trace.xid, "100")
        self.assertEqual(trace.writer_identity, ("oes_qprep_login", "oes_sandbox", "off"))
        self.bad_writer_identity = True
        with self.assertRaises(PreparationHold):
            _capture_q0_writer_transaction(self.writer, trace)

    def test_canonical_single_q0_keeps_service_contract_and_preflight_order(self):
        self.assertEqual(self.canonical(), {"status": "PREPARATORY_ONLY", "question_id": self.command.question_id, "version": 1})
        self.repo.insert_receipt.assert_called_once()
        self.assertEqual([c.kwargs["using"] for c in self.atomic.call_args_list], ["oes_q0_writer", "oes_synthetic_reader"])
        self.identity_lookup.return_value.get.assert_called_with(user_id=42)
        self.repo.lock_request.assert_called_once_with(self.actor, self.command.request_id)
        writer_sql = [sql for alias, sql in self.events if alias == "oes_q0_writer"]
        self.assertLess(next(i for i,s in enumerate(writer_sql) if "has_table_privilege" in s), next(i for i,s in enumerate(writer_sql) if "pg_current_xact_id" in s))

    def test_canonical_bad_preflight_never_starts_atomic_or_inserts(self):
        self.bad_privileges = True
        with self.assertRaises(PreparationHold):
            self.canonical()
        self.atomic.assert_not_called()
        self.repo.insert_entity.assert_not_called()

    def test_canonical_each_insert_failure_stays_hold_without_retry(self):
        for name in ("insert_entity", "insert_question", "insert_entity_version", "insert_question_version", "insert_receipt"):
            self.repo.reset_mock()
            self.atomic.reset_mock()
            getattr(self.repo, name).side_effect = RuntimeError("offline insert failure")
            self.status = "aborted"
            self.has_receipt = False
            with self.subTest(name=name), self.assertRaises(PreparationHold) as raised:
                self.canonical()
            self.assertEqual(raised.exception.q0_observation["outcome"], "ABSENT")
            self.assertIs(raised.exception.q0_observation["automatic_retry"], False)
            getattr(self.repo, name).assert_called_once()
            self.assertEqual(sum(c.kwargs["using"] == "oes_q0_writer" for c in self.atomic.call_args_list), 1)
            getattr(self.repo, name).side_effect = None

    def test_canonical_lost_ack_retains_hold_even_when_persistence_reconciled(self):
        self.writer_exit_failure = True
        with self.assertRaises(PreparationHold) as raised:
            self.canonical()
        self.assertEqual(raised.exception.q0_observation["outcome"], "PERSISTED")
        self.repo.insert_receipt.assert_called_once()

    def test_canonical_reader_failure_after_writes_is_hold_with_no_retry(self):
        self.repo.insert_receipt.side_effect = lambda *args: setattr(self, "reader_unavailable", True)
        with self.assertRaises(PreparationHold) as raised:
            self.canonical()
        self.assertEqual(raised.exception.q0_observation["outcome"], "INDETERMINATE")
        self.repo.insert_receipt.assert_called_once()

    def test_recovery_authorization_and_real_gate_never_activate_connections(self):
        self.user.has_perm.return_value = False
        with self.assertRaises(PermissionDenied):
            _recover_q0_commit_evidence(user=self.user, command=self.command)
        self.user.has_perm.return_value = True
        self.identity_lookup.return_value.get.side_effect = PreparerIdentity.DoesNotExist
        with self.assertRaises(PreparationHold):
            _recover_q0_commit_evidence(user=self.user, command=self.command)
        self.identity_lookup.return_value.get.side_effect = None
        with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
            _recover_q0_commit_evidence(user=self.user, command=self.command)
        self.atomic.assert_not_called()
        self.writer.cursor.assert_not_called()
        self.reader.cursor.assert_not_called()
