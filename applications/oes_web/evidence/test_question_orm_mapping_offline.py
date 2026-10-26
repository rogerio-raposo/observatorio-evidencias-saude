"""PF-I02: offline Django ORM schema mapping smoke tests (no DB connection)."""
from django.test import SimpleTestCase
from django.db.backends.postgresql.base import DatabaseWrapper

from evidence.models import (
    OesEntity, OesEntityVersion, OesQuestion,
    OesQuestionVersion, OesQuestionCommandReceipt,
)


class UnmanagedMappingTests(SimpleTestCase):
    models_and_tables = (
        (OesEntity, '"core"."entity"'),
        (OesEntityVersion, '"core"."entity_version"'),
        (OesQuestion, '"investigation"."question"'),
        (OesQuestionVersion, '"investigation"."question_version"'),
        (OesQuestionCommandReceipt, '"investigation"."question_command_receipt"'),
    )

    def test_unmanaged_and_exact_schema_table(self):
        for model, table in self.models_and_tables:
            with self.subTest(model=model.__name__):
                self.assertFalse(model._meta.managed)
                self.assertEqual(model._meta.db_table, table)

    def test_physical_keys(self):
        self.assertEqual(OesEntity._meta.pk.name, "entity_uuid")
        self.assertEqual(OesEntityVersion._meta.pk.name, "version_uuid")
        self.assertEqual(OesQuestion._meta.pk.name, "entity_uuid")
        self.assertEqual(OesQuestionVersion._meta.pk.name, "version_uuid")
        ledger_pk = OesQuestionCommandReceipt._meta.pk
        self.assertEqual(tuple(ledger_pk.field_names), ("actor_id", "request_id"))

    def test_nullable_and_immutable_identifier_fields(self):
        self.assertTrue(OesQuestion._meta.get_field("responsible_actor_id").null)
        self.assertTrue(OesQuestionVersion._meta.get_field("normalized_text").null)
        self.assertTrue(OesEntity._meta.get_field("oes_id").unique)
        self.assertFalse(OesQuestionVersion._meta.get_field("original_text").null)

    def test_postgresql_select_compiles_without_connecting(self):
        # Compile with an unconnected backend object, not a configured DB alias.
        connection = DatabaseWrapper({"ENGINE": "django.db.backends.postgresql",
                                      "NAME": "offline"}, alias="offline")
        for model, table in self.models_and_tables:
            with self.subTest(model=model.__name__):
                query = model.objects.all().query
                sql, params = query.get_compiler(connection=connection).as_sql()
                self.assertIn(table, sql)
                self.assertEqual(params, ())
        self.assertIsNone(connection.connection)
