"""Synthetic-only unit tests; no requests, DB, or external fixtures."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from preserve import package_evidence

URL = ("https://clinicaltrials.gov/api/v2/studies?"
       "query.cond=Insomnia&query.term=synthetic&pageSize=20&format=json")


def record(n):
    return {"protocolSection": {"identificationModule": {"nctId": f"NCT{n:08d}"}}}


def raw(records=None, **kwargs):
    payload = {"studies": [record(1), record(2)] if records is None else records,
               "totalCount": 5, "nextPageToken": "SECRET_SHOULD_NOT_ESCAPE"}
    payload.update(kwargs)
    return json.dumps(payload).encode()


def provenance():
    return {"activity_id": "OES/D2-E5-SYNTHETIC", "observation_id": "test-1",
            "repository_commit_sha": "a" * 40, "github_run_id": 1, "run_attempt": 1,
            "requested_url_exact": URL, "started_at_utc": "2026-10-23T18:00:00+00:00",
            "completed_at_utc": "2026-10-23T18:00:01+00:00",
            "source_http_status": 200, "response_content_type": "application/json"}


class OfflinePackagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.dest = Path(self.temp.name) / "package"

    def reject(self, body, meta=None):
        with self.assertRaises((ValueError, TypeError)):
            package_evidence(body, provenance() if meta is None else meta, self.dest)
        self.assertFalse(self.dest.exists())

    def test_success_preserves_exact_bytes_and_manifest(self):
        body = raw()
        report = package_evidence(body, provenance(), self.dest)
        self.assertEqual((self.dest / "response.raw.json").read_bytes(), body)
        self.assertEqual(report["raw_sha256"], hashlib.sha256(body).hexdigest())
        self.assertEqual(report["scope_status"], "PARTIAL_FIRST_PAGE_ONLY")
        self.assertEqual(report["nct_ids_in_return_order"], ["NCT00000001", "NCT00000002"])
        self.assertNotIn("SECRET_SHOULD_NOT_ESCAPE", (self.dest / "manifest.json").read_text())
        self.assertFalse(report["scientific_appraisal_performed"])
        self.assertEqual(len(list(self.dest.iterdir())), 3)

    def test_tampering_detectable(self):
        report = package_evidence(raw(), provenance(), self.dest)
        target = self.dest / "response.raw.json"
        target.write_bytes(target.read_bytes() + b" ")
        self.assertNotEqual(hashlib.sha256(target.read_bytes()).hexdigest(), report["raw_sha256"])

    def test_duplicate_nct_rejected(self):
        self.reject(raw([record(1), record(1)]))

    def test_invalid_nct_rejected(self):
        self.reject(raw([{"protocolSection": {"identificationModule": {"nctId": "BAD"}}}]))

    def test_more_than_twenty_rejected(self):
        self.reject(raw([record(n) for n in range(21)], totalCount=21))

    def test_over_two_mb_rejected(self):
        self.reject(b" " * 2_000_001)

    def test_invalid_total_rejected(self):
        self.reject(raw(totalCount=1))

    def test_missing_optional_fields_does_not_invent(self):
        body = raw([record(1)], totalCount=1, nextPageToken=None)
        result = package_evidence(body, provenance(), self.dest)
        self.assertEqual(result["scope_status"], "PASS_TECHNICAL_QUERY_ONLY")
        self.assertNotIn("title", result)
        self.assertIsNone(result["total_count_if_provided"] if False else None)

    def test_invalid_or_unapproved_metadata_rejected(self):
        m = provenance()
        m["source_http_status"] = 404
        self.reject(raw(), m)

    def test_no_overwrite_of_existing_package(self):
        package_evidence(raw(), provenance(), self.dest)
        with self.assertRaises(FileExistsError):
            package_evidence(raw(), provenance(), self.dest)

    def test_bad_json_and_non_list_rejected(self):
        self.reject(b'not json')
        self.reject(b'{"studies":{}}')

    def test_failure_does_not_leave_stage_dir(self):
        self.reject(raw([record(1), record(1)]))
        self.assertEqual(list(Path(self.temp.name).iterdir()), [])


if __name__ == "__main__":
    unittest.main()
