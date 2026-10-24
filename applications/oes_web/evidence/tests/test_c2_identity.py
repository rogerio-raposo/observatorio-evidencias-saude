from copy import deepcopy
from django.test import SimpleTestCase
from evidence.domain import from_record, StudyReference, ReportReference, DOCUMENTED_LINK_SOURCE
from evidence.services import get_signal, list_signals

class C2IdentityTests(SimpleTestCase):
    def test_known_study_with_two_distinct_documented_reports(self):
        signal = get_signal("NCT01438697")
        self.assertIsInstance(signal.study_reference, StudyReference)
        self.assertEqual(len(signal.report_links), 2)
        self.assertTrue(all(isinstance(link.report, ReportReference) for link in signal.report_links))
        self.assertEqual({link.report.label for link in signal.report_links}, set(signal.reports))
        self.assertTrue(all(link.source.document_path == DOCUMENTED_LINK_SOURCE for link in signal.report_links))

    def test_unknown_has_no_typed_identity(self):
        signal = get_signal("NCT07836491")
        self.assertIsNone(signal.study_reference)
        self.assertEqual(signal.report_links, ())
        self.assertIsNone(signal.study_label)
        self.assertEqual(signal.reports, ())

    def test_duplicate_or_unverified_report_link_rejected(self):
        from evidence.services import FIXTURE
        import json
        data = json.loads(FIXTURE.read_text(encoding="utf-8"))[0]
        bad = deepcopy(data)
        bad["documentary_identity"]["links"][1]["report_label"] = bad["documentary_identity"]["links"][0]["report_label"]
        with self.assertRaises(ValueError):
            from_record(bad)
        bad = deepcopy(data)
        bad["documentary_identity"]["links"][0]["source"]["document_path"] = "unknown.md"
        with self.assertRaises(ValueError):
            from_record(bad)

    def test_unreconciled_cannot_claim_typed_study(self):
        from evidence.services import FIXTURE
        import json
        data = json.loads(FIXTURE.read_text(encoding="utf-8"))[1]
        data["documentary_identity"]["study"] = {"label": "invented"}
        with self.assertRaises(ValueError):
            from_record(data)

    def test_existing_views_and_catalog_use_legacy_read_model(self):
        from django.urls import reverse
        self.assertEqual(len(list_signals()), 2)
        for url in (reverse("home"), reverse("signal-detail", args=["NCT01438697"]),
                    reverse("signal-detail", args=["NCT07836491"])):
            self.assertEqual(self.client.get(url).status_code, 200)
