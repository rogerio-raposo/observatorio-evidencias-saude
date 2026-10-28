"""GET-only technical synthetic PostgreSQL presentation. Mocked, no database access."""
from unittest.mock import patch
from uuid import UUID

from django.test import SimpleTestCase
from django.urls import reverse
from django.db.utils import OperationalError

from evidence.synthetic_pg_reader import SyntheticStudyReportLink


class SyntheticPgPresentationTests(SimpleTestCase):
    def url(self):
        return reverse("synthetic-pg-links")

    def test_disabled_connection_is_hold_503(self):
        response = self.client.get(self.url())
        self.assertEqual(response.status_code, 503)
        self.assertContains(response, "HOLD", status_code=503)

    def test_success_renders_synthetic_links_and_provenance(self):
        uid = [UUID(f"10000000-0000-4000-8000-{i:012d}") for i in range(1, 6)]
        link = SyntheticStudyReportLink(uid[0], uid[1], uid[2], uid[3], "reports", uid[4], "title")
        with patch("evidence.synthetic_pg_presentation.list_synthetic_study_report_links", return_value=(link,)):
            response = self.client.get(self.url())
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, str(uid[0]))
        self.assertContains(response, str(uid[4]))
        self.assertContains(response, "DEMONSTRAÇÃO TÉCNICA SINTÉTICA")

    def test_no_provenance_does_not_claim_scientific_absence(self):
        uid = [UUID(f"10000000-0000-4000-8000-{i:012d}") for i in range(1, 5)]
        link = SyntheticStudyReportLink(*uid, "reports", None, None)
        with patch("evidence.synthetic_pg_presentation.list_synthetic_study_report_links", return_value=(link,)):
            response = self.client.get(self.url())
        self.assertContains(response, "Não vinculada nesta projeção")
        self.assertContains(response, "não implica ausência")

    def test_empty_result_is_not_connection_failure(self):
        with patch("evidence.synthetic_pg_presentation.list_synthetic_study_report_links", return_value=()):
            response = self.client.get(self.url())
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Nenhum vínculo sintético")

    def test_database_failure_is_sanitized(self):
        with patch("evidence.synthetic_pg_presentation.list_synthetic_study_report_links", side_effect=OperationalError("secret-neon-host")):
            response = self.client.get(self.url())
        self.assertEqual(response.status_code, 503)
        self.assertNotContains(response, "secret-neon-host", status_code=503)

    def test_post_disallowed_without_read(self):
        with patch("evidence.synthetic_pg_presentation.list_synthetic_study_report_links") as reader:
            response = self.client.post(self.url())
        self.assertEqual(response.status_code, 404)
        reader.assert_not_called()
