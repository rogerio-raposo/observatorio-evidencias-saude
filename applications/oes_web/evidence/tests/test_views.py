from django.test import SimpleTestCase
from django.urls import reverse

class ViewTests(SimpleTestCase):
    def test_known_page(self):
        response = self.client.get(reverse("signal-detail", args=["NCT01438697"]))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Ritterband 2017")
        self.assertContains(response, "Shaffer 2020")
        self.assertContains(response, "Avaliação humana pendente")

    def test_unknown_identity_visible_as_unknown(self):
        response = self.client.get(reverse("signal-detail", args=["NCT07836491"]))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Não reconciliado")

    def test_missing_signal(self):
        self.assertEqual(self.client.get("/signals/NCT99999999/").status_code, 404)

    def test_no_write_route(self):
        self.assertEqual(self.client.post("/signals/NCT01438697/").status_code, 404)
