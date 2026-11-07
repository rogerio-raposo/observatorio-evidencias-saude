"""PF-I01 offline-only Django regression tests."""
import copy
import json
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

    def test_structured_accessible_reading(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "<article", html=False)
        self.assertContains(response, "<table", html=False)
        self.assertNotContains(response, "<pre>", html=False)

    def test_semantic_inconsistency_holds_even_when_digest_stubbed(self):
        original = json.loads(n2_historical.SOURCE.read_text(encoding="utf-8"))
        mutations = (
            ("question_id", lambda x: x["question"].update(question_id="OES-Q-FAKE")),
            ("linked_investigations", lambda x: x["audit"].update(linked_investigations=[])),
            ("assurance", lambda x: x["audit"].update(assurance_level="A3")),
            ("lineage", lambda x: x["audit"].update(lineage_available=False)),
        )
        for name, mutate in mutations:
            with self.subTest(name=name), TemporaryDirectory() as td:
                payload = copy.deepcopy(original)
                mutate(payload)
                target = Path(td) / "sheet.json"
                target.write_text(json.dumps(payload), encoding="utf-8")
                with patch.object(n2_historical, "SOURCE", target), patch.object(
                    n2_historical.hashlib, "sha256"
                ) as mocked_hash:
                    mocked_hash.return_value.hexdigest.return_value = n2_historical.EXPECTED_SHA256
                    response = self.client.get(self.url)
                self.assertEqual(response.status_code, 503)

    def test_sheet_hierarchy_index_and_historical_text_are_preserved(self):
        import re
        from html.parser import HTMLParser

        class TextReader(HTMLParser):
            def __init__(self):
                super().__init__()
                self.text = []
                self.headings = []
                self.ids = []
                self.anchors = []

            def handle_starttag(self, tag, attrs):
                attrs = dict(attrs)
                if re.fullmatch(r"h[1-6]", tag):
                    self.headings.append(int(tag[1]))
                if "id" in attrs:
                    self.ids.append(attrs["id"])
                if tag == "a" and attrs.get("href", "").startswith("#"):
                    self.anchors.append(attrs["href"][1:])

            def handle_data(self, data):
                self.text.append(data)

        source = n2_historical.load_historical_n2()
        body = n2_historical.present_markdown(source)
        parsed = TextReader()
        parsed.feed(body)
        visible = re.sub(r"\s+", " ", "".join(parsed.text))
        # Every source line/cell survives presentation, apart from Markdown syntax
        # and template comments. No scientific wording or numeric result is rewritten.
        for line in re.sub(r"<!--.*?-->", "", source, flags=re.S).splitlines():
            line = line.strip()
            if not line or re.fullmatch(r"-{3,}", line):
                continue
            values = line[1:-1].split("|") if line.startswith("|") else [line]
            for value in values:
                value = value.strip()
                if re.fullmatch(r":?-{3,}:?", value):
                    continue
                value = re.sub(r"^(?:#{1,6}\s+|>\s+|[-*]\s+)", "", value)
                value = value.replace("**", "").replace("`", "")
                self.assertIn(re.sub(r"\s+", " ", value), visible)
        self.assertNotIn("**", visible)
        self.assertNotIn("template_version", visible)
        self.assertEqual(len(parsed.ids), len(set(parsed.ids)))
        self.assertTrue(set(parsed.anchors).issubset(parsed.ids))
        self.assertIn("sheet-index", parsed.ids)
        self.assertGreater(len(parsed.anchors), 10)
        for previous, current in zip(parsed.headings, parsed.headings[1:]):
            self.assertLessEqual(current, previous + 1)
        response = self.client.get(self.url)
        self.assertContains(response, "<h1>", count=1)

    def test_inline_presentation_escapes_html_and_formats_supported_markdown(self):
        body = n2_historical.present_markdown(
            '# Title\n## Section\n**Label:** <script>alert(1)</script>\n'
            '> **Limit**\n- *Note* and `code`\n'
            '| Heading |\n|---|\n| **Cell** |'
        )
        self.assertIn('<strong>Label:</strong>', body)
        self.assertIn('&lt;script&gt;', body)
        self.assertNotIn('<script>', body)
        self.assertIn('<blockquote>', body)
        self.assertIn('<em>Note</em>', body)
        self.assertIn('<code>code</code>', body)
        self.assertIn('<strong>Cell</strong>', body)
