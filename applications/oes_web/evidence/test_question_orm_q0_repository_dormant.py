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

    def test_concurrency_and_reads_explicitly_blocked(self):
        # Bypass __init__ for negative path tests only; no DB is touched.
        isolated = object.__new__(DjangoQ0Repository)
        for method, args in (
            ("lock_request", ("a", "r")),
            ("lock_question", ("Q",)),
            ("find_receipt", ("a", "r")),
            ("current_question", ("Q", "a")),
            ("can_access_question", ("Q", "a")),
        ):
            with self.subTest(method=method), self.assertRaises(PreparationHold):
                getattr(isolated, method)(*args)
