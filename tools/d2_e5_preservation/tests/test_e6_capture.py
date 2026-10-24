"""E6-A2 integration is exercised with synthetic bytes, never HTTP."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import e6_capture


class E6IntegrationTests(unittest.TestCase):
    def test_e3_parameters_retained(self):
        self.assertEqual([k for k, _ in e6_capture.PARAMS],
            ["query.cond", "query.term", "sort", "pageSize", "countTotal", "format"])
        self.assertIn("pageSize=20", e6_capture.URL)

    def test_exact_url_contract_and_parameter_order(self):
        expected = (
            "https://clinicaltrials.gov/api/v2/studies?"
            "query.cond=Insomnia&"
            "query.term=SHUTi%20OR%20%22internet%20cognitive%20behavioral%20therapy%22"
            "%20OR%20%22digital%20cognitive%20behavioral%20therapy%22&"
            "sort=%40relevance&pageSize=20&countTotal=true&format=json"
        )
        self.assertEqual(e6_capture.URL, expected)

    def test_synthetic_end_to_end_package_and_preflight(self):
        raw = json.dumps({"studies": [
            {"protocolSection": {"identificationModule": {"nctId": "NCT00000001"}}}],
            "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            plan = e6_capture.build_package(
                raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                "application/json", folder, 42, 1, "a" * 40, "synthetic-e6-integration")
            self.assertEqual((folder / "response.raw.json").read_bytes(), raw)
            self.assertEqual(plan["files"][0]["sha256"], hashlib.sha256(raw).hexdigest())
            self.assertEqual(plan["github_publication"], "NOT_PERFORMED")
            self.assertEqual(json.loads((folder / "manifest.json").read_text())["github_run_id"], 42)

    def test_connected_runner_denied_by_default(self):
        with patch("sys.argv", ["e6_capture.py", "--connected"]), patch.dict("os.environ", {}, clear=True):
            with self.assertRaises(SystemExit):
                e6_capture.main()

    def test_failed_json_does_not_leave_package(self):
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            with self.assertRaises(ValueError):
                e6_capture.build_package(b"not-json", "2026-10-24T05:00:00+00:00",
                    "2026-10-24T05:00:01+00:00", "application/json",
                    folder, 42, 1, "a" * 40, "synthetic-e6-integration")
            self.assertFalse(folder.exists())

    def test_structure_gate_accepts_synthetic_known_sections(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {
                "identificationModule": {"nctId": "NCT00000001"},
                "statusModule": {"overallStatus": "RECRUITING"},
                "designModule": {"studyType": "INTERVENTIONAL"},
            },
            "derivedSection": {},
            "hasResults": False,
        }], "totalCount": 1}).encode()
        self.assertIsNone(e6_capture.preupload_structure_gate(raw))

    def test_structure_gate_holds_unexpected_top_level_field(self):
        raw = json.dumps({"studies": [], "unreviewedData": {"x": 1}}).encode()
        with self.assertRaisesRegex(ValueError, "^HOLD: unexpected top-level fields"):
            e6_capture.preupload_structure_gate(raw)

    def test_structure_gate_holds_unexpected_study_field(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {"identificationModule": {"nctId": "NCT00000001"}},
            "privatePayload": "synthetic-secret",
        }]}).encode()
        with self.assertRaisesRegex(ValueError, "^HOLD: unexpected study fields") as caught:
            e6_capture.preupload_structure_gate(raw)
        self.assertNotIn("synthetic-secret", str(caught.exception))

    def test_structure_gate_holds_unexpected_protocol_section(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {
                "identificationModule": {"nctId": "NCT00000001"},
                "unreviewedModule": {},
            },
        }]}).encode()
        with self.assertRaisesRegex(ValueError, "^HOLD: unexpected protocol sections"):
            e6_capture.preupload_structure_gate(raw)

    def test_structure_hold_prevents_package_creation(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {"identificationModule": {"nctId": "NCT00000001"}},
            "unreviewedPayload": True,
        }], "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            destination = Path(td) / "evidence"
            with self.assertRaisesRegex(ValueError, "^HOLD:"):
                e6_capture.build_package(
                    raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                    "application/json", destination, 42, 1, "a" * 40,
                    "synthetic-e6-hold",
                )
            self.assertFalse(destination.exists())

    def test_review_labels_and_second_preupload_verification(self):
        raw = json.dumps({"studies": [
            {"protocolSection": {"identificationModule": {"nctId": "NCT00000001"}}}],
            "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            e6_capture.build_package(
                raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                "application/json", folder, 42, 1, "a" * 40, "synthetic-e6-review")
            for name in ("manifest.json", "summary.json"):
                data = json.loads((folder / name).read_text(encoding="utf-8"))
                self.assertEqual(data["data_classification"], "RAW_SOURCE_DATA")
                self.assertEqual(data["scientific_review_status"], "NOT_SCIENTIFICALLY_REVIEWED")
                self.assertEqual(data["artifact_retention"], "TEMPORARY_ARTIFACT")
            self.assertEqual((folder / "response.raw.json").read_bytes(), raw)
            self.assertEqual(
                e6_capture.verify_upload_package(folder)["github_publication"],
                "NOT_PERFORMED")

    def test_second_preupload_gate_holds_missing_label(self):
        raw = json.dumps({"studies": [
            {"protocolSection": {"identificationModule": {"nctId": "NCT00000001"}}}],
            "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            e6_capture.build_package(
                raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                "application/json", folder, 42, 1, "a" * 40, "synthetic-e6-review")
            summary_path = folder / "summary.json"
            summary = json.loads(summary_path.read_text(encoding="utf-8"))
            summary.pop("scientific_review_status")
            summary_path.write_text(json.dumps(summary), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "^HOLD: missing mandatory review labels"):
                e6_capture.verify_upload_package(folder)

    def test_second_preupload_gate_holds_modified_raw_bytes(self):
        raw = json.dumps({"studies": [
            {"protocolSection": {"identificationModule": {"nctId": "NCT00000001"}}}],
            "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            e6_capture.build_package(
                raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                "application/json", folder, 42, 1, "a" * 40, "synthetic-e6-review")
            (folder / "response.raw.json").write_bytes(raw + b" ")
            with self.assertRaisesRegex(ValueError, "Raw body digest/size mismatch"):
                e6_capture.verify_upload_package(folder)

    def test_second_preupload_gate_holds_unexpected_raw_fields_even_with_updated_digest(self):
        raw = json.dumps({"studies": [
            {"protocolSection": {"identificationModule": {"nctId": "NCT00000001"}}}],
            "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            e6_capture.build_package(
                raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                "application/json", folder, 42, 1, "a" * 40, "synthetic-e6-review")
            # An unexpected field is blocked even if the bundle's checksums
            # are recomputed to be internally self-consistent.
            modified = json.dumps({"studies": [
                {"protocolSection": {"identificationModule": {"nctId": "NCT00000001"}},
                 "unreviewedPayload": True}], "totalCount": 1}).encode()
            (folder / "response.raw.json").write_bytes(modified)
            digest = hashlib.sha256(modified).hexdigest()
            manifest_path = folder / "manifest.json"
            summary_path = folder / "summary.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            summary = json.loads(summary_path.read_text(encoding="utf-8"))
            manifest["response_bytes"] = len(modified)
            manifest["raw_sha256"] = digest
            summary["raw_sha256"] = digest
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            summary_path.write_text(json.dumps(summary), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "^HOLD: unexpected study fields"):
                e6_capture.verify_upload_package(folder)

    def test_structure_gate_accepts_results_and_document_sections(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {"identificationModule": {"nctId": "NCT00000001"}},
            "resultsSection": {"participantFlowModule": {}},
            "documentSection": {"largeDocumentModule": {}},
            "hasResults": True,
        }], "totalCount": 1}).encode()
        self.assertIsNone(e6_capture.preupload_structure_gate(raw))

    def test_results_and_document_sections_survive_package_unchanged(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {"identificationModule": {"nctId": "NCT00000001"}},
            "resultsSection": {"baselineCharacteristicsModule": {}},
            "documentSection": {"largeDocumentModule": {}},
        }], "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            e6_capture.build_package(
                raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                "application/json", folder, 42, 1, "a" * 40, "synthetic-e6-sections")
            self.assertEqual((folder / "response.raw.json").read_bytes(), raw)
            self.assertEqual(
                e6_capture.verify_upload_package(folder)["github_publication"],
                "NOT_PERFORMED")
