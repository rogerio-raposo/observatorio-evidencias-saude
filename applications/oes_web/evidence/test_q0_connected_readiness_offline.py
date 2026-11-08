"""Restricted construction and reader-only recovery. No real connection."""
from unittest.mock import patch

from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase

from evidence.question_preparation import PreparationHold, register_authenticated_q0, review_registered_q0
from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
from evidence.question_orm_q0_connected_recipe_dormant import (
    _review_q0_persistence_d1, _review_q0_reader_configuration, _review_q0_database_configuration,
)
from evidence import test_q0_persistence_d3_offline as d3_fixture
from evidence.test_q0_multi_alias_settings_offline import load_settings, HOST
from preparer_identity.models import PreparerIdentity

R = "evidence.question_orm_q0_repository_dormant."
C, E = d3_fixture.C, d3_fixture.E


class ConnectedReadinessTests(SimpleTestCase):
    def setUp(self):
        # Reuse the existing D3 fake-session/ORM fixture; do not duplicate its
        # collector tests or implement another repository/transaction protocol.
        self.fixture = d3_fixture.EvidenceD3Tests()
        self.fixture.setUp()
        self.addCleanup(self.fixture.doCleanups)

    def test_general_constructor_stays_hold_even_if_restricted_source_gate_were_approved(self):
        with patch(R + "_require_restricted_q0_construction") as guard:
            for alias in (None, "default", "oes_q0_writer", "arbitrary"):
                with self.subTest(alias=alias), self.assertRaises(PreparationHold):
                    DjangoQ0Repository(alias=alias)
            guard.assert_not_called()
        self.fixture.writer.cursor.assert_not_called()

    def test_restricted_factory_and_composition_source_hold_before_connection_or_actor_lookup(self):
        f = self.fixture
        with patch.dict("os.environ", {"OES_Q0_MULTI_ALIAS_ENABLED":"1", "OES_Q0_OPERATIONAL_AUTHORIZATION":"anything"}), patch("django.db.connections") as connections:
            with self.assertRaises(PreparationHold):
                DjangoQ0Repository._from_preflighted_writer(writer=object())
            with self.assertRaises(PreparationHold):
                DjangoQ0Repository(alias="oes_q0_writer", _writer=object())
            with self.assertRaises(PreparationHold):
                _review_q0_persistence_d1(user=f.user, command=f.command)
            connections.__getitem__.assert_not_called()
        f.identity_lookup.assert_not_called()
        f.writer.cursor.assert_not_called()
        f.reader.cursor.assert_not_called()
        f.atomic.assert_not_called()

    def test_prepared_constructor_uses_normal_canonical_class_only_in_validated_atomic(self):
        f = self.fixture
        f.writer.in_atomic_block = True
        with patch(R + "_require_restricted_q0_construction"), patch(R + "_check_trial_binding"), patch("django.db.connections", f.connections):
            repository = DjangoQ0Repository._from_preflighted_writer(writer=f.writer)
        self.assertIs(type(repository), DjangoQ0Repository)
        self.assertEqual(repository.alias, "oes_q0_writer")
        self.assertTrue(any("has_table_privilege" in sql for alias, sql in f.events))
        for model in f.models.values():
            model.objects.using.return_value.create.assert_not_called()
        f.atomic.assert_not_called()  # constructor does not open its own transaction

    def test_prepared_constructor_rejects_wrong_boundary_identity_and_privileges(self):
        f = self.fixture
        with patch(R + "_require_restricted_q0_construction"), patch("django.db.connections", f.connections):
            with self.assertRaises(PreparationHold):
                DjangoQ0Repository._from_preflighted_writer(writer=f.writer)
            f.writer.in_atomic_block = True
            f.bad_writer_identity = True
            with self.assertRaises(PreparationHold):
                DjangoQ0Repository._from_preflighted_writer(writer=f.writer)
            f.bad_writer_identity = False
            f.bad_privileges = True
            with self.assertRaises(PreparationHold):
                DjangoQ0Repository._from_preflighted_writer(writer=f.writer)
        for model in f.models.values():
            model.objects.using.return_value.create.assert_not_called()

    def test_functional_path_preflight_then_xid_then_restricted_construction_then_five_writes(self):
        f = self.fixture
        f.dynamic_ids = True
        def construct(*, writer):
            self.assertIs(writer, f.writer)
            self.assertTrue(writer.in_atomic_block)
            self.assertTrue(any("pg_current_xact_id" in sql for alias, sql in f.events))
            self.assertTrue(any("has_table_privilege" in sql for alias, sql in f.events if alias == "oes_q0_writer"))
            f.events.append(("repository", "constructed"))
            return f.repo
        for name in ("insert_entity", "insert_question", "insert_entity_version", "insert_question_version", "insert_receipt"):
            getattr(f.repo, name).side_effect = lambda *args, name=name: f.events.append(("repository", name))
        with patch(C + "_require_restricted_q0_construction"), patch(R + "DjangoQ0Repository._from_preflighted_writer", side_effect=construct) as factory:
            result = register_authenticated_q0(user=f.user, command=f.command)
        self.assertEqual(result, {"status":"PREPARATORY_ONLY", "question_id":f.command.question_id, "version":1})
        self.assertLess(f.events.index(("repository", "constructed")), f.events.index(("repository", "insert_entity")))
        factory.assert_called_once_with(writer=f.writer)
        self.assertEqual([c.kwargs['using'] for c in f.atomic.call_args_list], ["oes_q0_writer", "oes_synthetic_reader"])
        f.repo.insert_receipt.assert_called_once()

    def reader_only_registry(self):
        f = self.fixture
        reader_config = f.configs["oes_synthetic_reader"]
        f.configs.clear()
        f.configs["oes_synthetic_reader"] = reader_config
        def reader_only(alias):
            self.assertEqual(alias, "oes_synthetic_reader", "recovery requested a writer/auth scientific connection")
            return f.reader
        f.connections.__getitem__.side_effect = reader_only

    def test_read_recovery_has_own_source_hold_before_auth_lookup_and_scientific_access(self):
        f = self.fixture
        self.reader_only_registry()
        with patch(R + "DjangoQ0Repository", side_effect=AssertionError("writer construction")):
            with self.assertRaisesRegex(PreparationHold, "read-only recovery"):
                review_registered_q0(user=f.user, command=f.command)
        f.identity_lookup.assert_not_called()
        f.connections.__getitem__.assert_not_called()
        f.atomic.assert_not_called()

    def test_reader_recovery_needs_no_writer_repository_connection_or_credential(self):
        f = self.fixture
        self.reader_only_registry()
        _review_q0_reader_configuration(f.configs)
        with self.assertRaises(PreparationHold):
            _review_q0_database_configuration(f.configs)
        with patch(E + "_require_q0_read_recovery_source_activation"), patch(R + "DjangoQ0Repository", side_effect=AssertionError("writer construction")):
            observation = review_registered_q0(user=f.user, command=f.command)
        self.assertEqual(observation["outcome"], "PERSISTED")
        self.assertIs(observation["automatic_retry"], False)
        self.assertEqual([c.kwargs['using'] for c in f.atomic.call_args_list], ["oes_synthetic_reader"])
        f.writer.cursor.assert_not_called()
        f.identity_lookup.return_value.get.assert_called_once_with(user_id=42)
        for model in f.models.values():
            for method in ("create", "update", "delete"):
                getattr(model.objects.using.return_value, method).assert_not_called()
                getattr(model.objects.using.return_value.filter.return_value, method).assert_not_called()
        sql = " ".join(s for alias,s in f.events)
        self.assertNotIn("pg_current_xact_id", sql)
        self.assertNotIn("pg_advisory", sql)

    def test_reader_recovery_enforces_permission_and_persistent_binding_without_writer(self):
        f = self.fixture
        self.reader_only_registry()
        with patch(E + "_require_q0_read_recovery_source_activation"):
            f.user.has_perm.return_value = False
            with self.assertRaises(PermissionDenied):
                review_registered_q0(user=f.user, command=f.command)
            f.user.has_perm.return_value = True
            f.identity_lookup.return_value.get.side_effect = PreparerIdentity.DoesNotExist
            with self.assertRaises(PreparationHold):
                review_registered_q0(user=f.user, command=f.command)
        f.reader.cursor.assert_not_called()
        f.writer.cursor.assert_not_called()

    def test_reader_missing_receipt_or_untrusted_snapshot_stays_indeterminate_without_retry(self):
        f = self.fixture
        self.reader_only_registry()
        with patch(E + "_require_q0_read_recovery_source_activation"):
            f.has_receipt = False
            result = review_registered_q0(user=f.user, command=f.command)
            self.assertEqual(result["outcome"], "INDETERMINATE")
            self.assertIs(result["automatic_retry"], False)
            self.assertEqual(f.atomic.call_count, 1)
            f.has_receipt = True
            f.reader_unavailable = True
            result = review_registered_q0(user=f.user, command=f.command)
            self.assertEqual(result["outcome"], "INDETERMINATE")
        f.writer.cursor.assert_not_called()
        f.repo.insert_entity.assert_not_called()


class RecoveryProfileTests(SimpleTestCase):
    def environment(self):
        return {"OES_Q0_RECOVERY_READONLY_ENABLED":"1", "OES_PG_A4_ENABLED":"1",
                "OES_PG_A4_HOST":HOST, "OES_PG_A4_PASSWORD":"offline-reader",
                "OES_Q0_AUTH_PASSWORD":"offline-auth"}

    def test_readonly_profile_has_auth_and_reader_only_without_writer_password(self):
        cfg = load_settings(self.environment())
        self.assertEqual(set(cfg), {"default", "oes_synthetic_reader"})
        self.assertNotIn("oes_q0_writer", cfg)
        self.assertEqual(cfg["default"]["USER"], "oes_auth_trial_login")
        for connection in cfg.values():
            self.assertIn("default_transaction_read_only=on", connection["OPTIONS"]["options"])
        _review_q0_reader_configuration(cfg)
        with self.assertRaises(PreparationHold):
            DjangoQ0Repository(alias="oes_q0_writer")

    def test_readonly_profile_rejects_missing_shared_foreign_or_writer_mode(self):
        for mutation in ({"OES_Q0_AUTH_PASSWORD":""}, {"OES_Q0_AUTH_PASSWORD":"offline-reader"},
                {"OES_PG_A4_ENABLED":"0"}, {"OES_PG_A4_HOST":"other"},
                {"OES_Q0_MULTI_ALIAS_ENABLED":"1"}):
            with self.subTest(mutation=mutation), self.assertRaises(RuntimeError):
                load_settings({**self.environment(), **mutation})
