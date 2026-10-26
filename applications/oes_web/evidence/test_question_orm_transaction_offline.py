"""No-DB tests for candidate ORM Q0/Q1 transactional query shapes."""
from uuid import UUID
from django.test import SimpleTestCase
from django.db.backends.postgresql.base import DatabaseWrapper
from evidence.question_orm_transaction_offline import (
    scoped_current_question, request_receipt, q1_version_transition,
    required_atomic_contract,
)


class OrmTransactionBlueprintTests(SimpleTestCase):
    def setUp(self):
        self.connection = DatabaseWrapper(
            {"ENGINE": "django.db.backends.postgresql", "NAME": "offline"},
            alias="offline",
        )

    def compile(self, queryset):
        return queryset.query.get_compiler(connection=self.connection).as_sql()

    def test_scoped_current_filters_actor_and_current_version(self):
        sql, params = self.compile(scoped_current_question(
            question_id="OES-Q-SYN", actor_id="synthetic-actor"))
        self.assertIn('"core"."entity_version"', sql)
        self.assertIn('"investigation"."question"', sql)
        self.assertIn('"core"."entity"', sql)
        self.assertIn("responsible_actor_id", sql)
        self.assertIn("version_status", sql)
        self.assertIn("valid_to", sql)
        self.assertIn("synthetic-actor", params)
        self.assertIn("OES-Q-SYN", params)

    def test_receipt_lookup_compiles_composite_identity(self):
        sql, params = self.compile(request_receipt(
            actor_id="synthetic-actor", request_id="request-1"))
        self.assertIn('"investigation"."question_command_receipt"', sql)
        self.assertIn("actor_id", sql)
        self.assertIn("request_id", sql)
        self.assertEqual(params, ("synthetic-actor", "request-1"))

    def test_conditional_q1_version_update_target_compiles(self):
        sql, params = self.compile(q1_version_transition(
            version_uuid=UUID(int=1), entity_uuid=UUID(int=2), expected_version=1))
        self.assertIn("version_status", sql)
        self.assertIn("valid_to", sql)
        self.assertIn("version_no", sql)
        self.assertIn('"core"."entity_version"', sql)
        self.assertIn(1, params)

    def test_atomic_contract_is_explicit_and_no_connection(self):
        requirements = required_atomic_contract()
        self.assertIn("transaction.atomic(using=approved_writer_alias)", requirements)
        self.assertIn("Q0_Q1_ledger_single_commit_or_rollback", requirements)
        self.assertIsNone(self.connection.connection)
