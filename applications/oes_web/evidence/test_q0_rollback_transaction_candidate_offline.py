"""Mocked rollback candidate tests; no PostgreSQL connection or real SQL."""
from contextlib import contextmanager
from types import SimpleNamespace
from unittest.mock import MagicMock, patch
from uuid import uuid4
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from scripts.q0_rollback_trial_preflight_offline import prepare_pf_i03_q0_trial
from dataclasses import replace
from scripts import q0_rollback_transaction_candidate as candidate


class RollbackCandidateOfflineTests(SimpleTestCase):
    def trial(self):
        actor = "oes:actor:" + str(uuid4())
        trial = prepare_pf_i03_q0_trial(
            actor_id=actor, request_id="offline-isolated",
            question_id="OES-SYNTH-Q0-isolated", original_text="Synthetic question")
        return replace(trial, target_alias=candidate.WRITER), actor

    def test_entrypoint_remains_closed(self):
        with self.assertRaises(PreparationHold):
            candidate.run_connected()

    def test_rejects_foreign_actor_before_connection(self):
        trial, _ = self.trial()
        with patch.object(candidate, "connections") as connections:
            with self.assertRaises(PreparationHold):
                candidate._perform_rollback_only(
                    trial=trial, verified_actor="oes:actor:" + str(uuid4()))
            connections.__getitem__.assert_not_called()

    def test_failure_during_first_insert_forces_rollback_and_closes_writer(self):
        trial, actor = self.trial()
        writer = MagicMock()
        writer.vendor = "postgresql"
        writer.in_atomic_block = False
        writer.get_autocommit.return_value = True
        cursor = writer.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = ("oes_qprep_login", "oes_sandbox", "off")
        connections = MagicMock()
        reader = MagicMock()
        reader.vendor = "postgresql"
        reader.in_atomic_block = False
        reader.cursor.return_value.__enter__.return_value.fetchone.return_value = ("other_role", "oes_sandbox", "on")
        connections.__getitem__.side_effect = lambda alias: writer if alias == candidate.WRITER else reader
        rollback = MagicMock()

        @contextmanager
        def atomic(*, using, savepoint):
            self.assertEqual((using, savepoint), (candidate.WRITER, False))
            yield

        with patch.object(candidate, "connections", connections), patch.object(
            candidate.transaction, "atomic", atomic
        ), patch.object(candidate.transaction, "set_rollback", rollback), patch.object(
            candidate.OesEntity.objects, "using"
        ) as entities, patch.object(
            candidate.OesQuestionCommandReceipt.objects, "using"
        ) as receipts:
            entities.return_value.filter.return_value.exists.return_value = False
            receipts.return_value.filter.return_value.exists.return_value = False
            entities.return_value.create.side_effect = RuntimeError("injected insert failure")
            with self.assertRaisesRegex(PreparationHold, "independent reconciliation unavailable"):
                candidate._perform_rollback_only(trial=trial, verified_actor=actor)

        rollback.assert_called_once_with(True, using=candidate.WRITER)
        writer.close.assert_called_once()
        self.assertEqual(connections.__getitem__.call_args_list[0].args,
                         (candidate.WRITER,))

    def _exercise_failed_insert_with_reader(self, *, reader_raises=False):
        from contextlib import ExitStack
        trial, actor = self.trial()
        writer, reader = MagicMock(), MagicMock()
        writer.vendor = reader.vendor = "postgresql"
        writer.in_atomic_block = reader.in_atomic_block = False
        writer.get_autocommit.return_value = True
        writer.cursor.return_value.__enter__.return_value.fetchone.return_value = (
            "oes_qprep_login", "oes_sandbox", "off")
        reader.cursor.return_value.__enter__.return_value.fetchone.return_value = (
            "oes_pg_a4_reader", "oes_sandbox", "on")
        if reader_raises:
            reader.cursor.return_value.__enter__.return_value.execute.side_effect = (
                RuntimeError("synthetic reader unavailable"))
        connections = MagicMock()
        connections.__getitem__.side_effect = lambda alias: (
            writer if alias == candidate.WRITER else reader)
        rollback = MagicMock()

        @contextmanager
        def atomic(*, using, savepoint):
            self.assertEqual((using, savepoint), (candidate.WRITER, False))
            yield

        models = (candidate.OesEntity, candidate.OesQuestion,
                  candidate.OesEntityVersion, candidate.OesQuestionVersion,
                  candidate.OesQuestionCommandReceipt)
        with ExitStack() as stack:
            stack.enter_context(patch.object(candidate, "connections", connections))
            stack.enter_context(patch.object(candidate.transaction, "atomic", atomic))
            stack.enter_context(patch.object(candidate.transaction, "set_rollback", rollback))
            managers = [
                stack.enter_context(patch.object(model.objects, "using"))
                for model in models
            ]
            for manager in managers:
                manager.return_value.filter.return_value.exists.return_value = False
            managers[0].return_value.create.side_effect = RuntimeError(
                "synthetic first insert failure")
            expected = ("independent reconciliation unavailable" if reader_raises
                        else "transaction failed; zero residues independently verified")
            with self.assertRaisesRegex(PreparationHold, expected) as raised:
                candidate._perform_rollback_only(trial=trial, verified_actor=actor)
            if not reader_raises:
                self.assertIsInstance(raised.exception.__cause__, RuntimeError)
            rollback.assert_called_once_with(True, using=candidate.WRITER)
            writer.close.assert_called_once()
            reader.close.assert_called()
            if not reader_raises:
                for manager in managers:
                    self.assertTrue(any(
                        call.args == (candidate.READER,) for call in manager.call_args_list))

    def test_failed_insert_with_verified_zero_residues_is_hold(self):
        self._exercise_failed_insert_with_reader(reader_raises=False)

    def test_failed_insert_with_unavailable_reconciliation_is_hold(self):
        self._exercise_failed_insert_with_reader(reader_raises=True)
