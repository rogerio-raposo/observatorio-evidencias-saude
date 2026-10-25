"""PF-I01 offline-only Django regression tests."""
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch
from django.test import SimpleTestCase
from django.urls import reverse
from evidence import n2_historical


class PF_I01_N2Tests(SimpleTestCase):
    url = "/evidence-sheets/OES-P-2026-000401/"

    def test_historical_n2_get(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "OES — Ficha de Evidência N2 histórica")
        self.assertContains(response, "A2")
        self.assertContains(response, "A3 não realizada")
        self.assertContains(response, "insônia")

    def test_other_product_404(self):
        self.assertEqual(self.client.get("/evidence-sheets/OES-P-2026-999999/").status_code, 404)

    def test_write_methods_denied(self):
        for method in ("post", "put", "patch", "delete"):
            with self.subTest(method=method):
                self.assertEqual(getattr(self.client, method)(self.url).status_code, 404)

    def test_missing_snapshot_holds(self):
        with patch.object(n2_historical, "SOURCE", Path("/nonexistent/oes/n2.json")):
            response = self.client.get(self.url)
        self.assertEqual(response.status_code, 503)
        self.assertContains(response, "HOLD", status_code=503)

    def test_tampered_snapshot_holds(self):
        with TemporaryDirectory() as td:
            path = Path(td) / "n2.json"
            path.write_bytes(n2_historical.SOURCE.read_bytes() + b" ")
            with patch.object(n2_historical, "SOURCE", path):
                response = self.client.get(self.url)
        self.assertEqual(response.status_code, 503)
        self.assertNotContains(response, "insônia", status_code=503)

    def test_existing_pages_unchanged(self):
        for path in ("/", "/signals/NCT01438697/", "/synthetic-path/"):
            with self.subTest(path=path):
                self.assertEqual(self.client.get(path).status_code, 200)
