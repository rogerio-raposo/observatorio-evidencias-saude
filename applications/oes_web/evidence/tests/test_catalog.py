from django.test import SimpleTestCase
from django.urls import reverse
from evidence.services import list_signals

class CatalogTests(SimpleTestCase):
    def test_catalog_has_exact_existing_fixture_ids(self):
        self.assertEqual([signal.nct for signal in list_signals()],
                         ["NCT01438697", "NCT07836491"])

    def test_catalog_get_links_to_two_existing_details(self):
        response = self.client.get(reverse("home"))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, reverse("signal-detail", args=["NCT01438697"]))
        self.assertContains(response, reverse("signal-detail", args=["NCT07836491"]))
        self.assertContains(response, "CATÁLOGO DEMONSTRATIVO")

    def test_catalog_respects_unreconciled_identity(self):
        response = self.client.get(reverse("home"))
        self.assertContains(response, "Não identificado no inventário consultado")
        self.assertContains(response, "nenhum vínculo estabelecido")
        self.assertContains(response, "não é inventário completo")

    def test_catalog_does_not_allow_write(self):
        self.assertEqual(self.client.post(reverse("home")).status_code, 404)

    def test_both_existing_detail_routes_remain_accessible(self):
        for nct in ("NCT01438697", "NCT07836491"):
            with self.subTest(nct=nct):
                response = self.client.get(reverse("signal-detail", args=[nct]))
                self.assertEqual(response.status_code, 200)
                self.assertContains(response, nct)
