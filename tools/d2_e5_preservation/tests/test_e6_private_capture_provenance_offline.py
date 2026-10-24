"""Offline-only contract cases for the capture-to-private provenance adapter."""
import hashlib
import unittest
from datetime import datetime, timezone

from e6_private_pg_offline import PersistenceHold
from e6_private_capture_provenance_offline import (
    SOURCE_NAME, ACTIVITY_ID, prepare_capture_for_private_storage,
)

RAW = b'{"synthetic":true}'


def args():
    return {
        "observation_id": "SYNTH-E6-PROV",
        "repository_commit_sha": "a" * 40,
        "github_run_id": 42,
        "run_attempt": 1,
        "requested_url_exact": "https://example.invalid/synthetic",
        "started_at_utc": "2026-10-24T10:00:00+00:00",
        "completed_at_utc": "2026-10-24T10:00:01+00:00",
        "response_content_type": "application/json",
    }


class CaptureProvenanceContractTests(unittest.TestCase):
    def test_iso_timestamps_converted_to_aware_utc_without_changing_bytes(self):
        prepared = prepare_capture_for_private_storage(RAW, **args())
        self.assertEqual(prepared.parameters[5], SOURCE_NAME)
        self.assertEqual(prepared.parameters[1], ACTIVITY_ID)
        self.assertEqual(prepared.parameters[7].tzinfo, timezone.utc)
        self.assertEqual(prepared.parameters[8].tzinfo, timezone.utc)
        self.assertEqual(prepared.parameters[-1], RAW)
        self.assertEqual(prepared.sha256, hashlib.sha256(RAW).hexdigest())

    def test_timezone_offsets_normalize_to_utc(self):
        meta = args()
        meta["started_at_utc"] = "2026-10-24T07:00:00-03:00"
        p = prepare_capture_for_private_storage(RAW, **meta)
        self.assertEqual(p.parameters[7], datetime(2026, 10, 24, 10, 0, tzinfo=timezone.utc))

    def test_missing_or_naive_timestamp_rejected(self):
        for value in ("", "not-a-date", "2026-10-24T10:00:00", None):
            with self.subTest(value=value):
                meta = args()
                meta["started_at_utc"] = value
                with self.assertRaises(PersistenceHold):
                    prepare_capture_for_private_storage(RAW, **meta)

    def test_reversed_times_and_invalid_status_fail_closed(self):
        meta = args()
        meta["completed_at_utc"] = "2026-10-24T09:59:59+00:00"
        with self.assertRaises(PersistenceHold):
            prepare_capture_for_private_storage(RAW, **meta)

    def test_metadata_failure_does_not_echo_payload(self):
        meta = args()
        meta["response_content_type"] = "text/plain"
        with self.assertRaises(PersistenceHold) as err:
            prepare_capture_for_private_storage(RAW, **meta)
        self.assertNotIn("synthetic", str(err.exception))


if __name__ == "__main__":
    unittest.main()
