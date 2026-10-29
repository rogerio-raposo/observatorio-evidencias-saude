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
        reader.get_autocommit.return_value = True
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
        reader.get_autocommit.return_value = True
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

    def test_persisted_binding_review_requires_permission_and_resolved_actor(self):
        trial, actor = self.trial()
        user = MagicMock()
        with patch.object(candidate, "validate_persisted_actor_trial") as validate, patch(
            "evidence.preparation_auth.require_question_preparer"
        ) as permission, patch(
            "preparer_identity.resolver.persisted_preparer_actor_id", return_value=actor
        ) as resolve:
            self.assertEqual(candidate.review_persisted_actor_binding(user=user, trial=trial),
                             "PERSISTED_ACTOR_BINDING_REVIEW_PASS")
            permission.assert_called_once_with(user)
            resolve.assert_called_once_with(user)
            validate.assert_called_once_with(authenticated_actor_id=actor, trial=trial)

    def test_persisted_binding_review_never_accepts_foreign_actor(self):
        trial, _ = self.trial()
        with patch("evidence.preparation_auth.require_question_preparer"), patch(
            "preparer_identity.resolver.persisted_preparer_actor_id",
            return_value="oes:actor:" + str(uuid4())
        ), self.assertRaises(PreparationHold):
            candidate.review_persisted_actor_binding(user=MagicMock(), trial=trial)

    def _full_transaction_scenario(self, outcome):
        from contextlib import ExitStack
        trial, actor = self.trial()
        writer, reader = MagicMock(), MagicMock()
        writer.vendor = reader.vendor = "postgresql"
        writer.in_atomic_block = reader.in_atomic_block = False
        writer.get_autocommit.return_value = True
        reader.get_autocommit.return_value = True
        writer.cursor.return_value.__enter__.return_value.fetchone.return_value = (
            "oes_qprep_login", "oes_sandbox", "off")
        reader.cursor.return_value.__enter__.return_value.fetchone.return_value = (
            "oes_pg_a4_reader", "oes_sandbox", "on")
        connection_map = {candidate.WRITER: writer, candidate.READER: reader}
        connections = MagicMock()
        connections.__getitem__.side_effect = connection_map.__getitem__
        rollback = MagicMock()

        @contextmanager
        def atomic(*, using, savepoint):
            self.assertEqual((using, savepoint), (candidate.WRITER, False))
            yield
            if outcome == "exit_failure":
                raise RuntimeError("synthetic atomic exit failure")

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
                def outcome_for_alias(alias):
                    manager = MagicMock()
                    manager.filter.return_value.exists.return_value = False
                    manager.filter.return_value.count.return_value = (
                        1 if alias == candidate.WRITER else 0)
                    return manager
                manager.side_effect = outcome_for_alias
            if outcome == "residues":
                managers[0].side_effect = lambda alias: self._residual_manager(alias)
            if outcome == "residues":
                with self.assertRaisesRegex(PreparationHold, "scientific rollback residues"):
                    candidate._perform_rollback_only(trial=trial, verified_actor=actor)
            elif outcome == "exit_failure":
                with self.assertRaisesRegex(PreparationHold, "transaction failed; zero residues"):
                    candidate._perform_rollback_only(trial=trial, verified_actor=actor)
            else:
                self.assertEqual(candidate._perform_rollback_only(
                    trial=trial, verified_actor=actor), "PASS_ROLLBACK_ZERO_RESIDUES")
            rollback.assert_called_once_with(True, using=candidate.WRITER)
            writer.close.assert_called_once()
            reader.close.assert_called()
            for manager in managers:
                self.assertTrue(any(c.args == (candidate.READER,)
                                    for c in manager.call_args_list))

    @staticmethod
    def _residual_manager(alias):
        manager = MagicMock()
        manager.filter.return_value.exists.return_value = (
            alias == candidate.READER)
        manager.filter.return_value.count.return_value = (
            1 if alias == candidate.WRITER else 0)
        return manager

    def test_full_five_inserts_rollback_and_zero_residues(self):
        self._full_transaction_scenario("success")

    def test_five_inserts_with_residues_must_hold(self):
        self._full_transaction_scenario("residues")

    def test_atomic_exit_failure_zero_residues_must_hold(self):
        self._full_transaction_scenario("exit_failure")

    def test_readonly_service_attestation_creates_canonical_trial_without_writer(self):
        actor = "oes:actor:" + str(uuid4())
        with patch(
            "preparer_identity.synthetic_service_readonly.attest_synthetic_identity_readonly",
            return_value=actor,
        ) as attest, patch.object(candidate, "connections") as connections:
            trial, verified = candidate.prepare_persisted_service_trial_readonly()
            self.assertEqual(verified, actor)
            self.assertEqual(trial.actor_id, actor)
            self.assertEqual(trial.target_alias, candidate.WRITER)
            self.assertTrue(trial.question_id.startswith("OES-SYNTH-Q0-"))
            self.assertEqual(trial.expected_insert_count, 5)
            self.assertTrue(trial.rollback_required)
            attest.assert_called_once_with()
            connections.__getitem__.assert_not_called()

    def test_readonly_service_attestation_rejects_noncanonical_actor(self):
        with patch(
            "preparer_identity.synthetic_service_readonly.attest_synthetic_identity_readonly",
            return_value="oes_synthetic_q0",
        ), patch.object(candidate, "connections") as connections:
            with self.assertRaises(ValueError):
                candidate.prepare_persisted_service_trial_readonly()
            connections.__getitem__.assert_not_called()
