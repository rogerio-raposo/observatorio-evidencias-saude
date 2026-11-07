"""D2 evidence policy only: fake sessions/port; no real repository activation."""
from contextlib import contextmanager
from copy import deepcopy
from dataclasses import replace
from types import SimpleNamespace
from unittest.mock import MagicMock, Mock, patch
from uuid import UUID

from django.test import SimpleTestCase
from evidence.question_orm_q0_connected_recipe_dormant import (
    _review_q0_database_configuration, _review_q0_session_boundary,
    _classify_q0_commit_observation, _review_q0_persistence_d1,
    execute_connected_q0, _review_authenticated_q0_composition,
)
from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
from evidence.question_orm_q0_dormant import DormantQ0OrmPort
from evidence.question_preparation import (
    QuestionCommand, PreparationHold, PreparationConflict, command_fingerprint,
)
from evidence.question_uow_offline import Receipt, OfflineQuestionUnitOfWork
from evidence.question_orm_transaction_offline import postgres_session_identity


class BoundaryD2Tests(SimpleTestCase):
    def setUp(self):
        self.configs = {}
        for alias, role, options in (
                ("default", "oes_auth_trial_login", "-c search_path=django_auth,public"),
                ("oes_q0_writer", "oes_qprep_login", ""),
                ("oes_synthetic_reader", "oes_pg_a4_reader", "-c default_transaction_read_only=on")):
            self.configs[alias] = {"ENGINE": "django.db.backends.postgresql",
                "HOST": "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech",
                "PORT": "5432", "NAME": "oes_sandbox", "USER": role,
                "PASSWORD": "synthetic-not-a-credential-" + alias,
                "OPTIONS": {"sslmode": "require", "options": options}}
        self.writer = self.session("oes_q0_writer", ("oes_qprep_login", "oes_sandbox", "off"))
        self.reader = self.session("oes_synthetic_reader", ("oes_pg_a4_reader", "oes_sandbox", "on"))

    def session(self, alias, identity):
        connection = MagicMock(alias=alias, vendor="postgresql", in_atomic_block=False)
        connection.get_autocommit.return_value = True
        connection.cursor.return_value.__enter__.return_value.fetchone.return_value = identity
        return connection

    def test_configuration_and_exact_session_pair_accepted_offline(self):
        _review_q0_database_configuration(self.configs)
        _review_q0_session_boundary(writer=self.writer, reader=self.reader)
        for connection in (self.writer, self.reader):
            cursor = connection.cursor.return_value.__enter__.return_value
            cursor.execute.assert_called_once_with("SELECT current_user,current_database(),current_setting('transaction_read_only')")

    def test_same_arbitrary_host_pooler_wrong_database_or_role_rejected(self):
        for alias in self.configs:
            for key, value in (("HOST", "other-branch"), ("NAME", "other"), ("USER", "owner"), ("ENGINE", "django.db.backends.sqlite3"), ("PORT", "6543"), ("PASSWORD", "")):
                configs = deepcopy(self.configs)
                configs[alias][key] = value
                with self.subTest(alias=alias, key=key), self.assertRaises(PreparationHold):
                    _review_q0_database_configuration(configs)
        for config in self.configs.values():
            config["HOST"] = "same-but-unapproved"
        with self.assertRaises(PreparationHold):
            _review_q0_database_configuration(self.configs)

    def test_missing_alias_shared_credential_and_connection_overrides_rejected(self):
        for alias in self.configs:
            configs = deepcopy(self.configs)
            del configs[alias]
            with self.subTest(alias=alias), self.assertRaises(PreparationHold):
                _review_q0_database_configuration(configs)
        configs = deepcopy(self.configs)
        configs["oes_q0_writer"]["PASSWORD"] = configs["default"]["PASSWORD"]
        with self.assertRaisesRegex(PreparationHold, "distinct credentials"):
            _review_q0_database_configuration(configs)
        for option in ({"sslmode": "disable"}, {"sslmode": "require", "service": "alternate"}, {"sslmode": "require", "options": "-c role=owner"}):
            configs = deepcopy(self.configs)
            configs["oes_q0_writer"]["OPTIONS"] = option
            with self.subTest(option=option), self.assertRaises(PreparationHold):
                _review_q0_database_configuration(configs)
        self.writer.cursor.assert_not_called()

    def test_incorrect_writer_and_reader_effective_identity_rejected(self):
        for connection, identities in (
                (self.writer, (("owner", "oes_sandbox", "off"), ("oes_qprep_login", "other", "off"), ("oes_qprep_login", "oes_sandbox", "on"))),
                (self.reader, (("oes_qprep_login", "oes_sandbox", "on"), ("oes_pg_a4_reader", "other", "on"), ("oes_pg_a4_reader", "oes_sandbox", "off")))):
            cursor = connection.cursor.return_value.__enter__.return_value
            original = cursor.fetchone.return_value
            for identity in identities:
                cursor.fetchone.return_value = identity
                with self.subTest(identity=identity), self.assertRaises(PreparationHold):
                    _review_q0_session_boundary(writer=self.writer, reader=self.reader)
            cursor.fetchone.return_value = original

    def test_wrong_alias_shared_session_nested_or_non_pg_rejected_before_probe(self):
        for connection in (self.writer, self.reader):
            for attribute, value in (("alias", "default"), ("vendor", "sqlite"), ("in_atomic_block", True)):
                original = getattr(connection, attribute)
                setattr(connection, attribute, value)
                with self.subTest(attribute=attribute), self.assertRaises(PreparationHold):
                    _review_q0_session_boundary(writer=self.writer, reader=self.reader)
                setattr(connection, attribute, original)
            connection.get_autocommit.return_value = False
            with self.assertRaises(PreparationHold):
                _review_q0_session_boundary(writer=self.writer, reader=self.reader)
            connection.get_autocommit.return_value = True
        with self.assertRaises(PreparationHold):
            _review_q0_session_boundary(writer=self.writer, reader=self.writer)
        self.writer.cursor.assert_not_called()
        self.reader.cursor.assert_not_called()

    def test_shared_probe_preserves_exact_rollback_identity_tuple(self):
        cursor = MagicMock()
        cursor.fetchone.return_value = ("oes_qprep_login", "oes_sandbox", "off")
        self.assertEqual(postgres_session_identity(cursor), cursor.fetchone.return_value)
        cursor.execute.assert_called_once_with("SELECT current_user,current_database(),current_setting('transaction_read_only')")


class ReconciliationD2Tests(SimpleTestCase):
    def setUp(self):
        self.command = QuestionCommand("request", "OES-SYNTH-D2", 0, "Synthetic?")
        self.expected = Receipt("actor", "request", command_fingerprint(self.command), "OES-SYNTH-D2", 1, "REGISTER_Q0")

    def classify(self, **evidence):
        result = _classify_q0_commit_observation(expected_receipt=self.expected, **evidence)
        self.assertIs(result["automatic_retry"], False)
        return result["outcome"]

    def test_pre_transaction_absence_is_scoped_to_this_attempt(self):
        result = _classify_q0_commit_observation(expected_receipt=self.expected, boundary="NOT_STARTED")
        self.assertEqual(result, {"outcome": "ABSENT", "scope": "THIS_ATTEMPT", "automatic_retry": False})
        self.assertEqual(self.classify(boundary="NOT_STARTED", observed_receipt=self.expected), "INDETERMINATE")

    def test_lost_commit_ack_reconciles_positive_only_with_all_evidence(self):
        self.assertEqual(self.classify(observed_receipt=self.expected, writer_finished=True,
            consistent_read=True, readback_verified=True), "PERSISTED")
        self.assertEqual(self.classify(boundary="COMMIT_ACKNOWLEDGED", observed_receipt=self.expected,
            writer_finished=True, consistent_read=True, readback_verified=True), "PERSISTED")

    def test_missing_receipt_alone_never_proves_absence(self):
        for boundary in ("UNKNOWN", "ROLLED_BACK", "COMMIT_ACKNOWLEDGED"):
            with self.subTest(boundary=boundary):
                self.assertEqual(self.classify(boundary=boundary, writer_finished=True, consistent_read=True), "INDETERMINATE")
        for evidence in ({"all_records_absent": True}, {"all_records_absent": True, "writer_finished": True}, {"all_records_absent": True, "consistent_read": True}):
            with self.subTest(evidence=evidence):
                self.assertEqual(self.classify(**evidence), "INDETERMINATE")

    def test_consistent_absence_requires_finished_writer_and_all_records(self):
        for boundary in ("UNKNOWN", "ROLLED_BACK"):
            self.assertEqual(self.classify(boundary=boundary, writer_finished=True,
                consistent_read=True, all_records_absent=True), "ABSENT")
        self.assertEqual(self.classify(boundary="COMMIT_ACKNOWLEDGED", writer_finished=True,
            consistent_read=True, all_records_absent=True), "INDETERMINATE")

    def test_divergent_unavailable_or_inconsistent_readback_is_indeterminate(self):
        for evidence in (
                {}, {"readback_verified": False}, {"readback_verified": True, "consistent_read": False},
                {"readback_verified": True, "writer_finished": False},
                {"readback_verified": True, "all_records_absent": True},
                {"readback_verified": True, "boundary": "ROLLED_BACK"}):
            args = dict(observed_receipt=self.expected, writer_finished=True, consistent_read=True)
            args.update(evidence)
            with self.subTest(evidence=evidence):
                self.assertEqual(self.classify(**args), "INDETERMINATE")

    def test_same_fingerprint_replay_needs_matching_full_receipt_and_readback(self):
        for changes in ({"actor_id": "other"}, {"request_id": "other"}, {"question_id": "other"},
                        {"version": 2}, {"version": True}, {"command_kind": "PROPOSE_Q1"}, {"justification": "unexpected"}):
            with self.subTest(changes=changes):
                self.assertEqual(self.classify(observed_receipt=replace(self.expected, **changes),
                    writer_finished=True, consistent_read=True, readback_verified=True), "INDETERMINATE")

    def test_conflicting_fingerprint_preserves_conflict_contract(self):
        with self.assertRaises(PreparationConflict):
            self.classify(observed_receipt=replace(self.expected, fingerprint="b" * 64), writer_finished=True, consistent_read=True)
        self.assertEqual(self.classify(observed_receipt=replace(self.expected, fingerprint="b" * 64)), "INDETERMINATE")

    def test_invalid_expected_identity_or_boundary_rejected(self):
        for changes in ({"fingerprint": "bad"}, {"version": True}, {"request_id": ""}, {"command_kind": "PROPOSE_Q1"}):
            with self.subTest(changes=changes), self.assertRaises(PreparationHold):
                _classify_q0_commit_observation(expected_receipt=replace(self.expected, **changes))
        with self.assertRaises(PreparationHold):
            self.classify(boundary="not-evidence")

    def make_port(self, failure=None):
        repo = Mock()
        repo.find_receipt.return_value = None
        repo.current_question.return_value = None
        if failure and failure.startswith("insert_"):
            getattr(repo, failure).side_effect = RuntimeError("synthetic write failure")
        @contextmanager
        def atomic():
            if failure == "before":
                raise PreparationHold("HOLD: synthetic preflight")
            yield
            if failure == "exit":
                raise RuntimeError("synthetic lost commit ack")
        @contextmanager
        def repository():
            yield repo
        verifier = Mock(return_value={"readback_verified": True})
        if failure == "readback":
            verifier.side_effect = RuntimeError("synthetic read unavailable")
        port = DormantQ0OrmPort(atomic_factory=atomic, repository_factory=repository,
            readback_verifier=verifier, writer_alias="oes_q0_writer", read_alias="oes_synthetic_reader")
        return port, repo, verifier

    def execute(self, port):
        return OfflineQuestionUnitOfWork(port).execute(command=self.command, actor_id="actor", fingerprint=self.expected.fingerprint)

    def test_preflight_failure_has_no_writes_or_candidate(self):
        port, repo, verifier = self.make_port("before")
        with self.assertRaises(PreparationHold):
            self.execute(port)
        self.assertIsNone(port.last_uncertain_q0)
        repo.insert_entity.assert_not_called()
        verifier.assert_not_called()

    def test_each_insert_failure_retains_keys_and_prevents_port_reuse(self):
        for failure in ("insert_entity", "insert_question", "insert_entity_version", "insert_question_version", "insert_receipt"):
            port, repo, verifier = self.make_port(failure)
            with self.subTest(failure=failure), self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
                self.execute(port)
            candidate = port.last_uncertain_q0
            self.assertEqual(candidate["request_id"], self.command.request_id)
            self.assertEqual(candidate["fingerprint"], self.expected.fingerprint)
            self.assertNotEqual(candidate["entity_uuid"], candidate["version_uuid"])
            self.assertEqual(port.review_uncertain_q0()["outcome"], "INDETERMINATE")
            with self.assertRaisesRegex(PreparationHold, "already started"):
                port.review_uncertain_q0(boundary="NOT_STARTED")
            with self.assertRaisesRegex(PreparationHold, "no automatic retry"):
                self.execute(port)
            getattr(repo, failure).assert_called_once()
            verifier.assert_not_called()

    def test_exit_and_readback_failure_are_reconcilable_without_rearming_port(self):
        for failure in ("exit", "readback"):
            port, repo, verifier = self.make_port(failure)
            with self.subTest(failure=failure), self.assertRaises(PreparationHold):
                self.execute(port)
            for evidence, outcome in (({}, "INDETERMINATE"),
                    ({"writer_finished": True, "consistent_read": True, "all_records_absent": True}, "ABSENT"),
                    ({"writer_finished": True, "consistent_read": True, "observed_receipt": self.expected, "readback_verified": True}, "PERSISTED")):
                result = port.review_uncertain_q0(**evidence)
                self.assertEqual(result["outcome"], outcome)
                self.assertIs(result["automatic_retry"], False)
                with self.assertRaisesRegex(PreparationHold, "no automatic retry"):
                    self.execute(port)
            repo.insert_receipt.assert_called_once()

    def test_positive_mock_readback_keeps_current_service_semantics(self):
        port, repo, verifier = self.make_port()
        self.assertEqual(self.execute(port), {"status": "PREPARATORY_ONLY", "question_id": self.command.question_id, "version": 1})
        verifier.assert_called_once()
        self.assertIsNone(port.last_uncertain_q0)
        with self.assertRaises(PreparationHold):
            port.review_uncertain_q0()

    def test_replay_and_fingerprint_conflict_perform_no_write(self):
        for mismatch in (False, True):
            port, repo, verifier = self.make_port()
            repo.find_receipt.return_value = replace(self.expected, fingerprint="b" * 64) if mismatch else self.expected
            repo.can_access_question.return_value = True
            if mismatch:
                with self.assertRaises(PreparationConflict):
                    self.execute(port)
            else:
                self.assertEqual(self.execute(port)["version"], 1)
                repo.can_access_question.assert_called_once()
            repo.insert_entity.assert_not_called()
            repo.insert_receipt.assert_not_called()
            verifier.assert_not_called()


class GatesD2Tests(SimpleTestCase):
    def test_existing_real_gates_hold_without_factories_or_session_access(self):
        with patch("evidence.question_orm_q0_connected_recipe_dormant.connections") as connections:
            with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
                DjangoQ0Repository(alias="oes_q0_writer")
            with self.assertRaises(PreparationHold):
                execute_connected_q0()
            with self.assertRaises(PreparationHold):
                _review_authenticated_q0_composition(user=None, command=None,
                    writer_alias="oes_q0_writer", read_alias="oes_synthetic_reader")
            user = Mock(pk=42, is_authenticated=True, is_active=True, is_staff=False, is_superuser=False)
            user.has_perm.return_value = True
            identity = SimpleNamespace(actor_uuid=UUID("12345678-1234-4234-8234-123456789abc"))
            with patch("preparer_identity.resolver.PreparerIdentity.objects.using") as lookup:
                lookup.return_value.get.return_value = identity
                with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
                    _review_q0_persistence_d1(user=user,
                        command=QuestionCommand("request", "OES-SYNTH-D2", 0, "Synthetic?"))
            connections.assert_not_called()
            connections.__getitem__.assert_not_called()
