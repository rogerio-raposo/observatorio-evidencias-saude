from django.test import SimpleTestCase
from django.urls import reverse
from evidence.domain import from_record
from evidence.services import get_signal

class TrajectoryTests(SimpleTestCase):
    def test_order_and_sources(self):
        signal = get_signal("NCT01438697")
        self.assertEqual([m.event_type for m in signal.milestones],
            ["SOURCE_RETRIEVAL", "DOCUMENTARY_CROSSWALK", "DOCUMENTED_REPORT_LINK"])
        self.assertTrue(all(m.source_ref and m.certainty_boundary for m in signal.milestones))

    def test_dates_remain_absent(self):
        self.assertTrue(all(m.event_date is None for m in get_signal("NCT01438697").milestones))

    def test_unreconciled_has_no_study_report(self):
        signal = get_signal("NCT07836491")
        self.assertIsNone(signal.study_label)
        self.assertFalse(signal.reports)
        self.assertNotIn("DOCUMENTED_REPORT_LINK", [m.event_type for m in signal.milestones])

    def test_unknown_report_milestone_rejected(self):
        data = {"nct":"NCT00000001","identity_state":"NOT_IDENTIFIED_IN_SCOPED_INVENTORY",
            "study_label":None,"reports":[],"provenance":"document","limitation":"no assessment",
            "milestones":[{"event_type":"DOCUMENTED_REPORT_LINK","source_ref":"document",
                "description":"unproven linkage","event_date":None,"certainty_boundary":"not assessed"}]}
        with self.assertRaises(ValueError):
            from_record(data)

    def test_unverified_date_rejected(self):
        data = {"nct":"NCT00000001","identity_state":"NOT_IDENTIFIED_IN_SCOPED_INVENTORY",
            "study_label":None,"reports":[],"provenance":"document","limitation":"no assessment",
            "milestones":[{"event_type":"SOURCE_RETRIEVAL","source_ref":"document",
                "description":"retrieved","event_date":"2026-10-23","certainty_boundary":"not assessed"}]}
        with self.assertRaises(ValueError):
            from_record(data)

    def test_unordered_milestones_rejected(self):
        data = {"nct":"NCT00000001","identity_state":"KNOWN_DOCUMENTED",
            "study_label":"one study","reports":[],"provenance":"document","limitation":"no assessment",
            "milestones":[{"event_type":e,"source_ref":"document","description":"known",
                "event_date":None,"certainty_boundary":"not assessed"} for e in
                ("DOCUMENTARY_CROSSWALK","SOURCE_RETRIEVAL")]}
        with self.assertRaises(ValueError):
            from_record(data)

    def test_page_renders_trajectory_and_boundary(self):
        response = self.client.get(reverse("signal-detail",args=["NCT01438697"]))
        self.assertEqual(response.status_code,200)
        self.assertContains(response,"Trajetória documental retrospectiva")
        self.assertContains(response,"Documento 247")
        self.assertContains(response,"Nenhuma avaliação científica nova")

    def test_unreconciled_page_does_not_claim_reports(self):
        response = self.client.get(reverse("signal-detail",args=["NCT07836491"]))
        self.assertEqual(response.status_code,200)
        self.assertContains(response,"Nenhum vínculo estabelecido")
        self.assertNotContains(response,"Ritterband 2017")
