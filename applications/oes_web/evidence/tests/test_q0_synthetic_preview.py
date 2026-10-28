"""Offline GET-only Q0 preview; no database or writer."""
from django.test import SimpleTestCase
from django.urls import reverse

class Q0SyntheticPreviewTests(SimpleTestCase):
    def test_get_renders_clearly_static_synthetic_example(self):
        response = self.client.get(reverse("q0-synthetic-preview"))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "PRÉVIA ESTÁTICA SINTÉTICA")
        self.assertContains(response, "OES-SYNTH-Q0-PREVIEW")
        self.assertContains(response, "não consulta PostgreSQL")
        self.assertNotContains(response, "<form")

    def test_post_is_rejected(self):
        response = self.client.post(reverse("q0-synthetic-preview"), {"original_text": "write"})
        self.assertEqual(response.status_code, 404)

    def test_explains_validation_authorization_and_non_persistent_confirmation(self):
        response = self.client.get(reverse("q0-synthetic-preview"))
        self.assertContains(response, "Fluxo ilustrativo de preparação")
        self.assertContains(response, "Validação:")
        self.assertContains(response, "Autorização:")
        self.assertContains(response, "Confirmação:")
        self.assertContains(response, "não existe commit")
        self.assertNotContains(response, "<form")

    def test_local_validation_has_no_network_submission(self):
        response = self.client.get(reverse("q0-synthetic-preview"))
        self.assertContains(response, 'id="q0-local-text"')
        self.assertContains(response, 'id="q0-local-check" type="button"')
        self.assertContains(response, "Nenhuma autorização ou gravação foi realizada")
        self.assertContains(response, "field.value")
        self.assertNotContains(response, "<form")
        self.assertNotContains(response, "fetch(")
        self.assertNotContains(response, "XMLHttpRequest")
