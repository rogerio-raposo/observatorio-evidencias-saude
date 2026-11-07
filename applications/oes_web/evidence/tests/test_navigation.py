"""Navigation regression coverage without any database access."""
from unittest.mock import patch

from django.test import SimpleTestCase
from django.urls import reverse


class NavigationTests(SimpleTestCase):
    destinations = (
        ("home", (), "Catálogo documental"),
        ("synthetic-path", (), "Percurso sintético"),
        ("synthetic-pg-links", (), "Leitura sintética (pode estar HOLD)"),
        ("q0-synthetic-preview", (), "Prévia Q0 sintética"),
        ("evidence-sheet-n2", ("OES-P-2026-000401",), "Ficha N2 histórica (A2)"),
    )

    def assert_navigation(self, response, status=200):
        self.assertContains(response, 'aria-label="Funcionalidades do demonstrador"', status_code=status)
        for name, args, label in self.destinations:
            self.assertContains(response, f'href="{reverse(name, args=args)}"', status_code=status)
            self.assertContains(response, label, status_code=status)
        self.assertContains(response, 'id="conteudo"', status_code=status)
        self.assertContains(response, 'aria-label="Navegação documental"', status_code=status)
        self.assertContains(response, 'name="viewport"', status_code=status)
        self.assertNotContains(response, '<form', status_code=status)

    def test_shared_navigation_and_current_page_on_every_html_destination(self):
        with patch("evidence.synthetic_pg_presentation.list_synthetic_study_report_links", return_value=()):
            for name, args, _ in self.destinations:
                with self.subTest(name=name):
                    response = self.client.get(reverse(name, args=args))
                    self.assert_navigation(response)
                    self.assertContains(response, f'href="{reverse(name, args=args)}" aria-current="page"')
            for nct in ("NCT01438697", "NCT07836491"):
                self.assert_navigation(self.client.get(reverse("signal-detail", args=[nct])))

    def test_home_explains_documentary_synthetic_historical_and_hold_boundaries(self):
        response = self.client.get(reverse("home"))
        for text in ("Explore o demonstrador", "sem envio ou gravação", "exibe HOLD", "sem revisão científica independente A3"):
            self.assertContains(response, text)
        for nct in ("NCT01438697", "NCT07836491"):
            self.assertContains(response, reverse("signal-detail", args=[nct]))

    def test_hold_pages_keep_navigation_and_return_links(self):
        from evidence.p2_presentation import SyntheticPresentationHold
        from evidence.n2_historical import N2Hold
        cases = (
            ("synthetic-pg-links", (), "evidence.synthetic_pg_presentation.list_synthetic_study_report_links", RuntimeError),
            ("synthetic-path", (), "evidence.p2_presentation.load_example", SyntheticPresentationHold),
            ("evidence-sheet-n2", ("OES-P-2026-000401",), "evidence.n2_historical.load_historical_n2", N2Hold),
        )
        for name, args, target, error in cases:
            with self.subTest(name=name), patch(target, side_effect=error("unavailable")):
                response = self.client.get(reverse(name, args=args))
                self.assert_navigation(response, status=503)
                self.assertContains(response, "HOLD", status_code=503)
                self.assertContains(response, "demo-state-unavailable", status_code=503)
                self.assertContains(response, "Indisponibilidade técnica" if name == "evidence-sheet-n2" else "indisponibilidade técnica", status_code=503)

    def test_navigation_destinations_still_reject_write_methods(self):
        for name, args, _ in self.destinations:
            for method in ("post", "put", "patch", "delete"):
                with self.subTest(name=name, method=method):
                    self.assertEqual(getattr(self.client, method)(reverse(name, args=args)).status_code, 404)
