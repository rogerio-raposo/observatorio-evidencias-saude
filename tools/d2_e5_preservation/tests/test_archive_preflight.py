"""Offline E5-A5 preflight tests, all synthetic; no internet/GitHub writes."""
import json
import tempfile
import unittest
from pathlib import Path

from archive_preflight import prepare_archival_plan
from preserve import package_evidence
from test_preserve import provenance, raw


class ArchivalPreflightTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.directory = Path(self.tmp.name) / "package"
        package_evidence(raw(), provenance(), self.directory)

    def test_valid_package_prepares_paths_without_upload(self):
        plan = prepare_archival_plan(self.directory)
        self.assertEqual(plan["classification"], "OFFLINE_PREFLIGHT_PASS_PUBLICATION_NOT_AUTHORIZED")
        self.assertEqual(len(plan["files"]), 3)
        self.assertTrue(all(f["path"].startswith(
            "artifacts/d2/clinicaltrials-gov/observations/test-1/") for f in plan["files"]))
        self.assertFalse(plan["durably_archived"])
        self.assertEqual(plan["content_review"], "REQUIRED_NOT_PERFORMED")

    def test_identical_plan_is_deterministic(self):
        self.assertEqual(prepare_archival_plan(self.directory), prepare_archival_plan(self.directory))

    def test_existing_observation_is_rejected(self):
        with self.assertRaises(FileExistsError):
            prepare_archival_plan(self.directory, [
                "artifacts/d2/clinicaltrials-gov/observations/test-1/existing.txt"])

    def test_invalid_observation_id_is_rejected(self):
        self.edit("manifest.json", lambda x: x.update(observation_id="../escape"))
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def test_missing_file_is_rejected(self):
        (self.directory / "summary.json").unlink()
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def test_extra_file_is_rejected(self):
        (self.directory / "extra").write_text("x")
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def test_altered_raw_bytes_are_rejected(self):
        with (self.directory / "response.raw.json").open("ab") as f:
            f.write(b" ")
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def test_mismatched_manifest_digest_is_rejected(self):
        self.edit("manifest.json", lambda x: x.update(raw_sha256="0" * 64))
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def test_mismatched_summary_is_rejected(self):
        self.edit("summary.json", lambda x: x.update(returned_count=19))
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def test_manifest_nct_tampering_is_rejected(self):
        self.edit("manifest.json", lambda x: x.update(nct_ids_in_return_order=[]))
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def test_symlink_is_rejected(self):
        source = self.directory / "summary.json"
        other = Path(self.tmp.name) / "other.json"
        source.rename(other)
        source.symlink_to(other)
        with self.assertRaises(ValueError):
            prepare_archival_plan(self.directory)

    def edit(self, filename, change):
        file = self.directory / filename
        data = json.loads(file.read_text())
        change(data)
        file.write_text(json.dumps(data))


if __name__ == "__main__":
    unittest.main()
