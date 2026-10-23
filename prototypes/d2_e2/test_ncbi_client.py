import io
import json
import unittest
from unittest.mock import patch
from ncbi_client import build_url, esearch, esummary, report, RetrievalError, MAX_RECORDS


class FakeResponse:
    def __init__(self, data):
        self.data = json.dumps(data).encode()
    def __enter__(self): return self
    def __exit__(self, *args): return False
    def read(self): return self.data


class ClientTests(unittest.TestCase):
    def test_url_encoding(self):
        u = build_url("esearch.fcgi", {"term": "insomnia[tiab] AND CBT-I", "retmax": 20})
        self.assertIn("insomnia%5Btiab%5D+AND+CBT-I", u)
    def test_endpoint_guard(self):
        with self.assertRaises(ValueError):
            build_url("efetch.fcgi", {})
    def test_search_mock(self):
        def fake(req, timeout):
            self.assertIn("db=pubmed", req.full_url)
            return FakeResponse({"esearchresult": {
                "count": "51", "idlist": ["123", "456"],
                "querytranslation": "translated",
            }})
        r = esearch("insomnia", opener=fake)
        self.assertEqual(r["count"], 51)
        self.assertEqual(r["pmids"], ["123", "456"])
    def test_search_malformed(self):
        with self.assertRaises(RetrievalError):
            esearch("insomnia", opener=lambda *_a, **_kw:
                FakeResponse({"esearchresult": {"count": "1", "idlist": ["bad"]}}))
    def test_limit(self):
        with self.assertRaises(ValueError):
            esearch("insomnia", retmax=MAX_RECORDS+1)
    def test_summary_mock(self):
        def fake(_req, timeout):
            return FakeResponse({"result": {
                "123": {"title": "Sample", "pubdate": "2026", "articleids": [
                    {"idtype": "doi", "value": "10.0/example"}]},
            }})
        r = esummary(["123"], opener=fake)
        self.assertEqual(r[0]["doi"], "10.0/example")
    def test_report_combined(self):
        responses = iter([
            {"esearchresult": {"count": "1", "idlist": ["123"]}},
            {"result": {"123": {"title": "Example"}}}
        ])
        r = report("insomnia", opener=lambda *_a, **_kw: FakeResponse(next(responses)))
        self.assertEqual(len(r["records"]), 1)
        self.assertEqual(r["status"], "retrieval_only")

if __name__ == "__main__":
    unittest.main()
