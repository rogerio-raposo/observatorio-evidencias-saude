from django.test import SimpleTestCase
from django.urls import reverse
from evidence.presentation import IDENTITY_LABELS, source_links

class PresentationTests(SimpleTestCase):
    def test_display_labels_do_not_modify_domain_state(self):
        self.assertEqual(IDENTITY_LABELS["KNOWN_DOCUMENTED"], "Identidade documentada")
        self.assertEqual(IDENTITY_LABELS["NOT_IDENTIFIED_IN_SCOPED_INVENTORY"],
                         "Não identificado no inventário consultado")

    def test_sources_resolve_only_known_documents(self):
        links = source_links("Documento 248, seção 2; Documento products/154")
        self.assertEqual(len(links), 2)
        self.assertTrue(all(link.url.startswith("https://github.com/rogerio-raposo/") for link in links))
        self.assertEqual(source_links("Documento 999; https://invalid.example"), ())

    def test_known_view_has_accessible_sections_and_references(self):
        page = self.client.get(reverse("signal-detail", args=["NCT01438697"]))
        self.assertContains(page, "Identidade e relatórios")
        self.assertContains(page, "Trajetória documental retrospectiva")
        self.assertContains(page, "Limitações e avaliação científica")
        self.assertContains(page, "Identidade documentada")
        self.assertContains(page, "247-d2-ctgov-e3")
        self.assertContains(page, "248-d2-ctgov-e4")

    def test_unknown_view_uses_human_label_without_inventing_reports(self):
        page = self.client.get(reverse("signal-detail", args=["NCT07836491"]))
        self.assertContains(page, "Não identificado no inventário consultado")
        self.assertContains(page, "Nenhum vínculo estabelecido")
        self.assertNotContains(page, "Ritterband 2017")
