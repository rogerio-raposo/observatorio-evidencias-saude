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

    def test_local_q0_contract_shows_request_id_question_id_and_revision(self):
        response = self.client.get(reverse("q0-synthetic-preview"))
        self.assertContains(response, 'id="q0-local-request"')
        self.assertContains(response, 'id="q0-local-question"')
        self.assertContains(response, 'maxlength="128"')
        self.assertContains(response, "Versão esperada do comando Q0")
        self.assertContains(response, 'questionId.value.startsWith("OES-SYNTH-Q0-")')
        self.assertContains(response, "identificador de solicitação inválido")
        self.assertNotContains(response, "<form")

    def test_sequence_preserves_original_and_uses_existing_proposal_contract(self):
        from evidence.pf_i03_q2_routing_offline import Q2RoutingProposal, METHODS, DEPTHS, MAINTENANCE
        response = self.client.get(reverse("q0-synthetic-preview"))
        q0, q1, q2 = (response.context[key] for key in ("q0", "q1", "q2"))
        self.assertEqual(q0.original_text, q1.original_text)
        self.assertNotEqual(q1.normalized_text, q0.original_text)
        self.assertTrue(q1.justification.strip())
        self.assertEqual(q0.question_id, q1.question_id)
        self.assertEqual(q1.question_id, q2.question_id)
        self.assertEqual(q1.expected_version, q0.expected_version + 1)
        self.assertEqual(q2.q1_version, q1.expected_version + 1)
        self.assertIsInstance(q2, Q2RoutingProposal)
        self.assertEqual(q2.operational_question, q1.normalized_text)
        self.assertIn(q2.methodological_class, METHODS)
        self.assertIn(q2.depth, DEPTHS)
        self.assertIn(q2.maintenance, MAINTENANCE)
        for value in (q0.original_text, q1.normalized_text, q1.justification,
                      q2.population, q2.exposure_or_intervention, q2.comparator,
                      *q2.outcomes, q2.routing_justification):
            self.assertContains(response, value)
        for stage in ("q0", "q1", "q2"):
            self.assertContains(response, f'href="#{stage}-title"')
            self.assertContains(response, f'id="{stage}-title"')

    def test_sequence_is_fixed_and_has_no_scientific_or_persisted_result(self):
        response = self.client.get(reverse("q0-synthetic-preview"), {"original_text": "UNTRUSTED_OVERRIDE"})
        self.assertNotContains(response, "UNTRUSTED_OVERRIDE")
        for text in ("não uma decisão científica", "NOT_DECIDED", "NOT_PERFORMED",
                     "NOT_OPENED", "Q0 HARD HOLD", "E9 NO-GO", "Fase 5 NOT_STARTED",
                     "sem submissão ou persistência", "editar os campos não modifica"):
            self.assertContains(response, text)
        for method in ("put", "patch", "delete"):
            self.assertEqual(getattr(self.client, method)(reverse("q0-synthetic-preview")).status_code, 404)
