"""Offline compilation checks for Django ORM DML: NEVER execute SQL."""
from uuid import UUID

from django.db.backends.postgresql.base import DatabaseWrapper
from django.db.models.sql.subqueries import InsertQuery, UpdateQuery
from django.db.models.functions import Now
from django.test import SimpleTestCase

from evidence.models import (
    OesEntity, OesEntityVersion, OesQuestion,
    OesQuestionVersion, OesQuestionCommandReceipt,
)
from evidence.question_orm_transaction_offline import q1_version_transition


class OfflineDmlCompilationTests(SimpleTestCase):
    def setUp(self):
        self.connection = DatabaseWrapper(
            {"ENGINE": "django.db.backends.postgresql", "NAME": "offline"},
            alias="offline",
        )

    def compile_insert(self, model, obj, names):
        fields = [model._meta.get_field(name) for name in names]
        query = InsertQuery(model)
        query.insert_values(fields, [obj])
        return query.get_compiler(connection=self.connection).as_sql()[0]

    def test_timestamp_fields_reflect_server_defaults(self):
        for model, name in (
            (OesEntity, "created_at"),
            (OesEntityVersion, "valid_from"),
            (OesEntityVersion, "created_at"),
            (OesQuestionCommandReceipt, "committed_at"),
        ):
            with self.subTest(model=model.__name__, field=name):
                self.assertIsInstance(model._meta.get_field(name).db_default, Now)

    def test_four_q0_inserts_compile_without_db(self):
        e = UUID(int=1)
        v = UUID(int=2)
        plans = (
            (OesEntity(entity_uuid=e, oes_id="Q", entity_type="Question",
                       created_by="actor"), ("entity_uuid", "oes_id", "entity_type", "created_by")),
            (OesQuestion(entity_uuid=e, responsible_actor_id="actor"),
             ("entity_uuid", "responsible_actor_id")),
            (OesEntityVersion(version_uuid=v, entity_uuid=e, version_no=1,
                              version_status="current", created_by="actor", change_type="initial"),
             ("version_uuid", "entity_uuid", "version_no", "version_status", "created_by", "change_type")),
            (OesQuestionVersion(version_uuid=v, entity_uuid=e, original_text="Original",
                                normalized_text=None, preparation_stage="q0_draft"),
             ("version_uuid", "entity_uuid", "original_text", "normalized_text", "preparation_stage")),
        )
        for obj, fields in plans:
            with self.subTest(model=type(obj).__name__):
                sql, params = self.compile_insert(type(obj), obj, fields)
                self.assertIn(type(obj)._meta.db_table, sql)
                self.assertNotIn('"created_at"', sql)
                self.assertNotIn('"valid_from"', sql)
                self.assertTrue(params)

    def test_ledger_insert_uses_composite_key_without_timestamp_override(self):
        obj = OesQuestionCommandReceipt(
            actor_id="actor", request_id="r1", fingerprint_sha256="a" * 64,
            question_entity_uuid=UUID(int=1), question_id="Q",
            resulting_version_uuid=UUID(int=2), resulting_version_no=1,
            command_kind="REGISTER_Q0", justification="")
        names = ("actor_id", "request_id", "fingerprint_sha256",
                 "question_entity_uuid", "question_id", "resulting_version_uuid",
                 "resulting_version_no", "command_kind", "justification")
        sql, params = self.compile_insert(type(obj), obj, names)
        self.assertIn('"actor_id"', sql)
        self.assertIn('"request_id"', sql)
        self.assertNotIn('"committed_at"', sql)
        self.assertEqual(len(params), len(names))

    def test_q1_conditional_update_compiles_without_db(self):
        plan = q1_version_transition(
            version_uuid=UUID(int=2), entity_uuid=UUID(int=1), expected_version=1)
        query = plan.query.chain(UpdateQuery)
        query.add_update_values({"version_status": "superseded", "valid_to": Now()})
        sql, params = query.get_compiler(connection=self.connection).as_sql()
        self.assertIn('"core"."entity_version"', sql)
        self.assertIn('"version_status"', sql)
        self.assertIn('"valid_to"', sql)
        self.assertIn('"version_no"', sql)
        self.assertIn('"entity_uuid"', sql)
        self.assertIn('"version_uuid"', sql)
        self.assertIn("current", params)
        self.assertIn("superseded", params)
        self.assertIsNone(self.connection.connection)
