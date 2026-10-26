"""G2-gated concrete ORM Q0 repository: offline structural validation only."""
from unittest.mock import patch
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
from evidence.models import (
    OesEntity, OesQuestion, OesEntityVersion,
    OesQuestionVersion, OesQuestionCommandReceipt,
)


class DormantConcreteOrmRepositoryTests(SimpleTestCase):
    def test_instantiation_rejected_with_and_without_alias(self):
        with self.assertRaisesRegex(PreparationHold, "G2 not authorized"):
            DjangoQ0Repository()
        with self.assertRaisesRegex(PreparationHold, "G2 not authorized"):
            DjangoQ0Repository(alias="anything")

    def test_five_write_methods_map_to_real_orm_models_without_execution(self):
        source = __import__("inspect").getsource(DjangoQ0Repository)
        for model in (OesEntity, OesQuestion, OesEntityVersion,
                      OesQuestionVersion, OesQuestionCommandReceipt):
            with self.subTest(model=model.__name__):
                self.assertIn(model.__name__ + ".objects.using(self.alias).create(", source)

    def test_invalid_lock_identity_fails_before_db(self):
        isolated = object.__new__(DjangoQ0Repository)
        with self.assertRaises(PreparationHold):
            isolated.lock_request("", "r")
        with self.assertRaises(PreparationHold):
            isolated.lock_question("")

    def test_advisory_lock_namespace_without_connection(self):
        isolated = object.__new__(DjangoQ0Repository)
        with patch.object(isolated, "_advisory_lock") as lock:
            isolated.lock_request("actor", "r1")
            lock.assert_called_once_with("5:actor:2:r1")
            isolated.lock_question("Q")
            lock.assert_called_with("oes:question:Q")

    def test_lookup_methods_defined_but_instantiation_still_blocked(self):
        source = __import__("inspect").getsource(DjangoQ0Repository)
        self.assertIn("scoped_current_question(", source)
        self.assertIn("request_receipt(", source)
        self.assertIn("responsible_actor_id=actor_id", source)
        with self.assertRaises(PreparationHold):
            DjangoQ0Repository(alias="default")
