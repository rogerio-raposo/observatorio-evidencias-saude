from django.test import SimpleTestCase
from evidence.domain import from_record
from evidence.services import get_signal

class DomainTests(SimpleTestCase):
    def test_one_study_multiple_reports(self):
        signal = get_signal("NCT01438697")
        self.assertEqual(signal.identity_state, "KNOWN_DOCUMENTED")
        self.assertEqual(len(signal.reports), 2)
        self.assertIn("não contabilizar dois RCTs", signal.study_label)

    def test_unknown_identity_not_scientifically_classified(self):
        signal = get_signal("NCT07836491")
        self.assertIsNone(signal.study_label)
        self.assertEqual(signal.reports, ())
        self.assertIn("NÃO avaliadas", signal.limitation)

    def test_reject_claims_on_unreconciled_identity(self):
        with self.assertRaises(ValueError):
            from_record({"nct": "NCT00000000", "identity_state": "NOT_IDENTIFIED_IN_SCOPED_INVENTORY",
                "study_label": "Invented", "reports": [], "provenance": "source", "limitation": "unknown"})

    def test_unknown_nct_returns_none(self):
        self.assertIsNone(get_signal("NCT99999999"))
