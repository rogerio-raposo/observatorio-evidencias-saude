"""D1 logical composition only: SimpleTestCase forbids database access."""
from contextlib import contextmanager
from dataclasses import replace
from types import SimpleNamespace
from uuid import UUID
from unittest.mock import Mock, patch

from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from preparer_identity.models import PreparerIdentity
from evidence.question_preparation import (
    QuestionCommand, PreparationHold, PreparationConflict, command_fingerprint,
)
from evidence.question_uow_offline import Receipt
from evidence.question_orm_q0_connected_recipe_dormant import _review_q0_persistence_d1

MODULE = "evidence.question_orm_q0_connected_recipe_dormant."


class PersistenceD1OfflineTests(SimpleTestCase):
    def setUp(self):
        self.user = Mock(pk=42, is_authenticated=True, is_active=True,
                         is_staff=False, is_superuser=False)
        self.user.has_perm.return_value = True
        self.command = QuestionCommand("request", "OES-SYNTH-D1", 0, "Synthetic?")
        self.actor = "oes:actor:12345678-1234-4234-8234-123456789abc"
        self.events = []
        self.repo = Mock()
        self.repo.find_receipt.return_value = None
        self.repo.current_question.return_value = None
        self.repo.can_access_question.return_value = True
        self.exit_failure = False
        self.writer = Mock(vendor="postgresql", in_atomic_block=False)
        self.writer.get_autocommit.return_value = True
        self.enterContext(patch(MODULE + "connections", {"oes_q0_writer": self.writer}))

        @contextmanager
        def atomic(**kwargs):
            self.assertEqual(kwargs, {"using": "oes_q0_writer", "savepoint": False})
            self.events.append("enter")
            try:
                yield
            except Exception:
                self.events.append("rollback simulated")
                raise
            self.events.append("commit simulated")
            if self.exit_failure:
                raise RuntimeError("lost acknowledgement")

        def readback(**kwargs):
            self.writer.close.assert_called_once()
            self.assertEqual(self.events[-1], "commit simulated")
            self.assertEqual(kwargs["writer_alias"], "oes_q0_writer")
            self.assertEqual(kwargs["read_alias"], "oes_synthetic_reader")
            self.events.append("readback simulated")
            return {"readback_verified": True}

        self.atomic = self.enterContext(patch(MODULE + "transaction.atomic", side_effect=atomic))
        self.readback = self.enterContext(patch(MODULE + "_verify_committed_q0_readback", side_effect=readback))
        self.lookup = self.enterContext(patch(
            "preparer_identity.resolver.PreparerIdentity.objects.using"))
        self.lookup.return_value.get.return_value = SimpleNamespace(
            actor_uuid=UUID(self.actor.removeprefix("oes:actor:")))

    def run_command(self, command=None):
        return _review_q0_persistence_d1(user=self.user, command=command or self.command)

    def fake_repository(self):
        return self.enterContext(patch(MODULE + "DjangoQ0Repository", return_value=self.repo))

    def test_real_constructor_remains_blocked_before_transaction(self):
        with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
            self.run_command()
        self.atomic.assert_not_called()
        self.readback.assert_not_called()

    def test_nested_or_non_postgresql_boundary_is_rejected(self):
        self.fake_repository()
        for vendor, nested, autocommit in (("sqlite", False, True), ("postgresql", True, False), ("postgresql", False, False)):
            self.writer.vendor = vendor
            self.writer.in_atomic_block = nested
            self.writer.get_autocommit.return_value = autocommit
            with self.subTest(vendor=vendor, nested=nested), self.assertRaises(PreparationHold):
                self.run_command()
        self.atomic.assert_not_called()
        self.repo.insert_entity.assert_not_called()

    def test_close_failure_is_uncertain_and_prevents_readback(self):
        self.fake_repository()
        self.writer.close.side_effect = RuntimeError("synthetic close failure")
        with self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
            self.run_command()
        self.atomic.assert_called_once()
        self.readback.assert_not_called()

    def test_five_operations_use_persisted_actor_and_one_boundary(self):
        constructor = self.fake_repository()
        result = self.run_command()
        self.assertEqual(result, {"status": "PREPARATORY_ONLY", "question_id": self.command.question_id, "version": 1})
        constructor.assert_called_once_with(alias="oes_q0_writer")
        self.lookup.assert_called_once_with("default")
        self.lookup.return_value.get.assert_called_once_with(user_id=42)
        self.repo.lock_request.assert_called_once_with(self.actor, "request")
        names = [c[0] for c in self.repo.method_calls if c[0].startswith("insert_")]
        self.assertEqual(names, ["insert_entity", "insert_question", "insert_entity_version", "insert_question_version", "insert_receipt"])
        receipt, entity, version = self.repo.insert_receipt.call_args.args
        self.assertEqual(receipt, self.receipt())
        self.assertNotEqual(entity, version)
        self.assertEqual(self.repo.insert_entity.call_args.args, (entity, self.command.question_id, self.actor))
        self.assertEqual(self.repo.insert_question_version.call_args.args, (version, entity, "Synthetic?"))
        args = self.readback.call_args.kwargs
        self.assertEqual((args["entity_uuid"], args["version_uuid"]), (entity, version))
        self.assertEqual(args["fingerprint"], receipt.fingerprint)
        self.assertEqual(self.events, ["enter", "commit simulated", "readback simulated"])
        self.atomic.assert_called_once()

    def receipt(self, **changes):
        return replace(Receipt(self.actor, "request", command_fingerprint(self.command), self.command.question_id, 1, "REGISTER_Q0"), **changes)

    def test_authorization_denied_before_lookup_and_writer(self):
        constructor = self.fake_repository()
        for attribute in ("is_authenticated", "is_active", "is_staff", "is_superuser"):
            original = getattr(self.user, attribute)
            setattr(self.user, attribute, not original)
            with self.subTest(attribute=attribute), self.assertRaises(PermissionDenied):
                self.run_command()
            setattr(self.user, attribute, original)
        self.user.has_perm.return_value = False
        with self.assertRaises(PermissionDenied):
            self.run_command()
        constructor.assert_not_called()
        self.lookup.assert_not_called()

    def test_missing_persisted_binding_never_falls_back_to_pk(self):
        constructor = self.fake_repository()
        self.lookup.return_value.get.side_effect = PreparerIdentity.DoesNotExist
        with self.assertRaisesRegex(PreparationHold, "persistent preparer identity"):
            self.run_command()
        constructor.assert_not_called()

    def test_invalid_commands_and_q1_stop_before_writer(self):
        constructor = self.fake_repository()
        for command in (replace(self.command, expected_version=True), replace(self.command, expected_version=1), replace(self.command, normalized_text="Q1", justification="reason"), replace(self.command, justification="unexpected"), replace(self.command, original_text=""), replace(self.command, request_id="")):
            with self.subTest(command=command), self.assertRaises(PreparationHold):
                self.run_command(command)
        constructor.assert_not_called()
        self.atomic.assert_not_called()

    def test_replay_checks_access_without_second_insert(self):
        self.fake_repository()
        self.repo.find_receipt.return_value = self.receipt()
        self.assertEqual(self.run_command()["version"], 1)
        self.repo.can_access_question.assert_called_once_with(self.command.question_id, self.actor)
        self.repo.insert_entity.assert_not_called()
        self.repo.insert_receipt.assert_not_called()
        self.readback.assert_not_called()  # Existing receipt, not a new commit claim.

    def test_receipt_conflicts_and_revoked_access_fail_closed(self):
        self.fake_repository()
        for changes in ({"fingerprint": "b" * 64}, {"actor_id": "other"}, {"question_id": "other"}, {}):
            self.repo.find_receipt.return_value = self.receipt(**changes)
            self.repo.can_access_question.return_value = False
            with self.subTest(changes=changes), self.assertRaises(PreparationConflict):
                self.run_command()
        self.repo.insert_entity.assert_not_called()
        self.readback.assert_not_called()

    def test_occupied_question_conflict(self):
        self.fake_repository()
        self.repo.current_question.return_value = {"version": 1, "original_text": "existing"}
        with self.assertRaises(PreparationConflict):
            self.run_command()
        self.repo.insert_entity.assert_not_called()
        self.readback.assert_not_called()

    def test_each_write_failure_stops_without_retry_or_readback(self):
        self.fake_repository()
        for name in ("insert_entity", "insert_question", "insert_entity_version", "insert_question_version", "insert_receipt"):
            self.repo.reset_mock()
            getattr(self.repo, name).side_effect = RuntimeError("synthetic write error")
            before = self.atomic.call_count
            with self.subTest(name=name), self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
                self.run_command()
            self.assertEqual(self.atomic.call_count, before + 1)
            getattr(self.repo, name).assert_called_once()
            getattr(self.repo, name).side_effect = None
        self.readback.assert_not_called()

    def test_context_exit_failure_is_uncertain_without_retry(self):
        self.fake_repository()
        self.exit_failure = True
        with self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
            self.run_command()
        self.atomic.assert_called_once()
        self.repo.insert_receipt.assert_called_once()
        self.readback.assert_not_called()

    def test_readback_failure_does_not_attempt_compensation_or_retry(self):
        self.fake_repository()
        for result in (False, None, {}, {"readback_verified": False}):
            self.readback.side_effect = None
            self.readback.return_value = result
            with self.subTest(result=result), self.assertRaises(PreparationHold):
                self.run_command()
        self.assertEqual(self.atomic.call_count, 4)
        self.assertEqual(self.repo.insert_receipt.call_count, 4)
        self.assertFalse(any("delete" in c[0] for c in self.repo.method_calls))

    def test_readback_exception_is_uncertain(self):
        self.fake_repository()
        self.readback.side_effect = TimeoutError("synthetic reader failure")
        with self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
            self.run_command()
        self.readback.assert_called_once()
        self.repo.insert_receipt.assert_called_once()
