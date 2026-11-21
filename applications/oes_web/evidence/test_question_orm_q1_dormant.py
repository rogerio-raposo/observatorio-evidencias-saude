"""Offline ORM composition tests. No QuerySet reaches PostgreSQL."""
from contextlib import contextmanager
from dataclasses import replace
from types import SimpleNamespace
from unittest.mock import MagicMock, patch
from uuid import UUID

from django.test import SimpleTestCase

from . import question_orm_q1_dormant as q1
from . import question_orm_q0_repository_dormant as repo
from .question_preparation import PreparationConflict, PreparationHold, QuestionCommand, command_fingerprint


class Q1OrmTests(SimpleTestCase):
    def setUp(self):
        self.command = QuestionCommand("offline-r", "offline-q", 1, "Original", "Normalized", "Reason")
        self.user = SimpleNamespace(is_authenticated=True, is_active=True, is_staff=False,
                                    is_superuser=False, has_perm=MagicMock(return_value=True))
        self.actor = "offline-actor"
        self.entity, self.previous = UUID(int=1), UUID(int=2)
        self.events = []
        self.writer = MagicMock(alias=q1.WRITER, vendor="postgresql", in_atomic_block=False,
                                atomic_blocks=[], needs_rollback=False, closed_in_transaction=False)
        self.reader = MagicMock(alias=q1.READER, vendor="postgresql", in_atomic_block=False)
        self.writer.get_autocommit.side_effect = lambda: not self.writer.in_atomic_block
        self.reader.get_autocommit.return_value = True
        self.connections = MagicMock()
        self.auth = MagicMock(in_atomic_block=False)
        self.auth.close.side_effect = lambda: self.events.append("auth closed")
        self.connections.__getitem__.side_effect = {
            "default": self.auth, q1.WRITER: self.writer, q1.READER: self.reader,
        }.__getitem__
        self.enterContext(patch.object(q1, "connections", self.connections))
        self.enterContext(patch("django.db.connections", self.connections))
        self.enterContext(patch.object(q1, "_review_q0_database_configuration"))
        self.enterContext(patch.object(q1, "_review_q0_reader_configuration"))
        self.enterContext(patch.object(q1, "_review_q0_session_boundary"))
        self.acl = self.enterContext(patch.object(q1, "_review_q0_privileges", return_value=("verified",)))
        self.enterContext(patch("preparer_identity.resolver.persisted_preparer_actor_id", return_value=self.actor))
        self.writer.cursor.return_value.__enter__.return_value.fetchone.side_effect = (
            lambda: ("100",) if self.writer.cursor.return_value.__enter__.return_value.execute.call_args.args[0].startswith("SELECT pg_current_xact_id")
            else ("oes_qprep_login", "oes_sandbox", "off")
        )
        self.writer.cursor.return_value.__enter__.return_value.execute.side_effect = (
            lambda sql, params=None: self.events.append(params[0]) if params else None
        )
        self.reader.cursor.return_value.__enter__.return_value.fetchone.return_value = (
            "oes_pg_a4_reader", "oes_sandbox", "on", False)
        self.lose_ack = False
        self.record = None

        @contextmanager
        def atomic(*, using, durable):
            self.assertTrue(durable)
            connection = self.connections[using]
            connection.in_atomic_block = True
            connection.atomic_blocks = [object()]
            old_record = self.record
            try:
                yield
            except Exception:
                if using == q1.WRITER:
                    self.record = old_record
                    self.events.append("rollback")
                raise
            else:
                if using == q1.WRITER and self.lose_ack:
                    raise RuntimeError("lost commit acknowledgement")
            finally:
                connection.atomic_blocks.clear()
                connection.in_atomic_block = False

        self.atomic = self.enterContext(patch.object(q1.transaction, "atomic", side_effect=atomic))
        self.current = self.enterContext(patch.object(repo, "scoped_current_question"))
        versions = self.current.return_value.using.return_value
        versions.values.return_value.first.return_value = {"version_no": 1, "q0_original_text": "Original"}
        self.prior = versions.filter.return_value.select_for_update.return_value.values.return_value
        self.prior.first.return_value = {"entity_uuid": self.entity, "version_uuid": self.previous}
        self.transition = self.enterContext(patch.object(repo, "q1_version_transition"))
        self.update = self.transition.return_value.using.return_value.update
        self.update.return_value = 1
        self.create_version = self.enterContext(patch.object(repo.OesEntityVersion.objects, "using")).return_value
        self.create_question_version = self.enterContext(patch.object(repo.OesQuestionVersion.objects, "using")).return_value
        self.create_version.filter.return_value.exists.return_value = True
        self.create_question_version.filter.return_value.exists.return_value = True
        self.enterContext(patch.object(repo.DjangoQ0Repository, "can_access_question", return_value=True))
        self.ledger = self.enterContext(patch.object(repo.OesQuestionCommandReceipt.objects, "using")).return_value

        def save_receipt(**fields):
            self.events.append("receipt insert")
            self.record = SimpleNamespace(**fields)
            self.create_version.filter.return_value.first.return_value = SimpleNamespace(
                entity_uuid=self.entity, version_uuid=fields["resulting_version_uuid"],
                supersedes_version_uuid=self.previous)

        self.ledger.create.side_effect = save_receipt
        for module in (q1, repo):
            lookup = self.enterContext(patch.object(module, "request_receipt"))
            lookup.return_value.using.return_value.first.side_effect = self.lookup

    def lookup(self):
        self.events.append("receipt lookup")
        return self.record

    def activate(self):
        for module in (q1, repo):
            self.enterContext(patch.object(module, "_require_q1_source_activation", return_value=self.actor))

    def test_supervised_context_requires_source_release_and_binds_operation(self):
        with self.assertRaises(PreparationHold):
            with repo._supervised_q1_trial(user=self.user, command=self.command, actor=self.actor, write=True):
                self.fail("source gate opened")
        with patch.object(repo, "_require_q1_trial_release"), patch(
            "scripts.pf_i04_a44_trial._require_operation", return_value=self.actor
        ):
            with repo._supervised_q1_trial(user=self.user, command=self.command, actor=self.actor, write=False):
                self.assertEqual(repo._require_q1_source_activation(user=self.user, command=self.command), self.actor)
                for user, command, write in (
                    (self.user, self.command, True),
                    (self.user, replace(self.command, justification="different"), False),
                    (object(), self.command, False),
                ):
                    with self.assertRaises(PreparationHold):
                        repo._require_q1_source_activation(user=user, command=command, write=write)
            with self.assertRaises(PreparationHold):
                repo._require_q1_source_activation(user=self.user, command=self.command)

    def test_cli_context_and_source_hold_precede_auth_store(self):
        from scripts import pf_i04_a44_trial as trial

        run_id = "af0d0d21-285b-42be-a5da-0f3b25bc8173"
        args = ["propose", "--run-id", run_id, "--user-id", "42", "--actor", self.actor]
        with patch.dict("os.environ", {"OES_PF_I04_A44_TRIAL": ""}), patch("django.setup") as setup:
            self.assertEqual(trial.main(args), 2)
            setup.assert_not_called()
        with patch.dict("os.environ", {"OES_PF_I04_A44_TRIAL": run_id,
                                       "DJANGO_SETTINGS_MODULE": "config.settings_mb_oc1"}), \
                patch("django.setup"), patch("django.contrib.auth.get_user_model") as users:
            self.assertEqual(trial.main(args), 1)
            users.assert_not_called()
        self.connections.__getitem__.assert_not_called()

    def test_readback_requires_current_open_version_and_noncyclic_link(self):
        self.activate()
        self.submit()
        query = self.create_version.filter.call_args_list[0].kwargs
        self.assertEqual(query["version_status"], "current")
        self.assertIs(query["valid_to__isnull"], True)
        self.assertEqual(query["version_uuid"], self.record.resulting_version_uuid)
        self.connections.reset_mock()
        for version in (None, SimpleNamespace(version_uuid=self.record.resulting_version_uuid,
                                               supersedes_version_uuid=self.record.resulting_version_uuid)):
            self.create_version.filter.return_value.first.return_value = version
            with self.assertRaisesRegex(PreparationHold, "Q1 version not verified"):
                q1.review_authenticated_q1(user=self.user, command=self.command)
        self.assertTrue(all(call.args == (q1.READER,) for call in self.connections.__getitem__.call_args_list))
        self.ledger.create.assert_called_once()

    def submit(self, command=None):
        return q1.propose_authenticated_q1_orm(user=self.user, command=command or self.command)

    def test_source_gate_precedes_database_even_with_valid_command(self):
        with self.assertRaises(PreparationHold):
            self.submit()
        with self.assertRaises(PreparationHold):
            q1.review_authenticated_q1(user=self.user, command=self.command)
        self.connections.__getitem__.assert_not_called()

    def test_request_lock_precedes_empty_receipt_lookup_and_replay(self):
        self.activate()
        self.assertEqual(self.submit()["version"], 2)
        self.assertEqual(self.events[:4], [
            "auth closed", "13:offline-actor:9:offline-r", "receipt lookup", "oes:question:offline-q",
        ])
        sql = [call.args[0] for call in self.writer.cursor.return_value.__enter__.return_value.execute.call_args_list]
        self.assertEqual(sql[0], "SET TRANSACTION ISOLATION LEVEL READ COMMITTED")
        self.update.assert_called_once()
        self.assertEqual(self.update.call_args.kwargs["version_status"], "superseded")
        self.assertIn("valid_to", self.update.call_args.kwargs)
        fields = self.create_version.create.call_args.kwargs
        self.assertEqual((fields["version_no"], fields["created_by"], fields["supersedes_version_uuid"]),
                         (2, self.actor, self.previous))
        question = self.create_question_version.create.call_args.kwargs
        self.assertEqual((question["original_text"], question["normalized_text"], question["preparation_stage"]),
                         ("Original", "Normalized", "q1_proposed"))
        self.assertEqual(self.record.resulting_version_uuid, fields["version_uuid"])
        self.assertEqual(self.record.command_kind, "PROPOSE_Q1")
        self.assertEqual(self.submit()["version"], 2)
        with self.assertRaises(PreparationConflict):
            self.submit(replace(self.command, justification="Changed"))
        self.ledger.create.assert_called_once()
        self.update.assert_called_once()
        self.assertEqual([call.kwargs["using"] for call in self.atomic.call_args_list],
                         [q1.WRITER, q1.READER, q1.WRITER, q1.READER, q1.WRITER])

    def test_incompatible_draft_or_missing_prior_stops_before_update(self):
        self.activate()
        self.prior.first.return_value = None
        with self.assertRaises(PreparationConflict):
            self.submit()
        self.update.assert_not_called()
        self.ledger.create.assert_not_called()

    def test_insert_failure_rolls_back_and_skips_readback(self):
        self.activate()
        self.create_question_version.create.side_effect = RuntimeError("simulated insert error")
        with self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
            self.submit()
        self.assertIn("rollback", self.events)
        self.ledger.create.assert_not_called()
        self.assertEqual([call.kwargs["using"] for call in self.atomic.call_args_list], [q1.WRITER])

    def test_lost_ack_requires_separate_reader_recovery_without_write(self):
        self.activate()
        self.lose_ack = True
        with self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
            self.submit()
        self.assertEqual(self.atomic.call_count, 1)
        self.connections.reset_mock()
        observed = q1.review_authenticated_q1(user=self.user, command=self.command)
        self.assertEqual(observed.fingerprint, command_fingerprint(self.command))
        self.assertTrue(self.connections.__getitem__.call_args_list)
        self.assertTrue(all(call.args == (q1.READER,) for call in self.connections.__getitem__.call_args_list))
        self.ledger.create.assert_called_once()
        self.update.assert_called_once()

    def test_stale_version_conflicts_before_update(self):
        self.activate()
        with self.assertRaises(PreparationConflict):
            self.submit(replace(self.command, expected_version=2))
        self.update.assert_not_called()
        self.ledger.create.assert_not_called()

    def test_acl_failure_stops_before_writes(self):
        self.activate()
        self.acl.side_effect = [("reader verified",), PreparationHold("HOLD: writer ACL")]
        with self.assertRaisesRegex(PreparationHold, "writer ACL"):
            self.submit()
        self.update.assert_not_called()
        self.ledger.create.assert_not_called()

    def test_absent_receipt_is_unconfirmed_and_never_written_by_recovery(self):
        self.activate()
        with self.assertRaisesRegex(PreparationHold, "receipt not verified"):
            q1.review_authenticated_q1(user=self.user, command=self.command)
        self.atomic.assert_called_once_with(using=q1.READER, durable=True)
        self.ledger.create.assert_not_called()
        self.update.assert_not_called()
