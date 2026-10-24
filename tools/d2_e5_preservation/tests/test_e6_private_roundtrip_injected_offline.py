"""Offline synthetic end-to-end injection tests: no database or HTTP."""
import hashlib
import unittest
from datetime import datetime, timezone

from e6_private_pg_offline import PersistenceHold
from e6_private_reader_offline import READ_SQL
from e6_private_roundtrip_injected_offline import synthetic_roundtrip_with_private_reader

RAW = b'{"synthetic":true}'


def provenance():
    t = datetime(2026, 10, 24, tzinfo=timezone.utc)
    return dict(observation_id="SYNTH-G1-A7", activity_id="OES/SYNTHETIC",
                repository_commit_sha="a" * 40, github_run_id=1, run_attempt=1,
                source_name="ClinicalTrials.gov API v2",
                requested_url_exact="https://example.invalid/synthetic",
                started_at_utc=t, completed_at_utc=t,
                source_http_status=200, response_content_type="application/json")


class WriterCursor:
    def __init__(self, writer):
        self.writer = writer

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, statement, params):
        if self.writer.reject:
            raise RuntimeError("SENSITIVE_WRITE_FAILURE")
        self.writer.pending = (params[0], params[-3], params[-2], params[-1])


class Writer:
    autocommit = False

    def __init__(self, reject=False):
        self.reject = reject
        self.pending = None
        self.committed = None
        self.rollbacks = 0

    def cursor(self):
        return WriterCursor(self)

    def commit(self):
        self.committed = self.pending

    def rollback(self):
        self.pending = None
        self.rollbacks += 1


class VerifierCursor:
    def __init__(self, verifier):
        self.verifier = verifier

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, statement, params):
        if self.verifier.denied:
            raise RuntimeError("SENSITIVE_PRIVATE_READ")
        self.verifier.query = (statement, params)

    def fetchone(self):
        row = self.verifier.writer.committed
        if row is None:
            return None
        if self.verifier.corrupt:
            return row[:-1] + (b"corrupted",)
        return row


class Verifier:
    def __init__(self, writer, *, denied=False, corrupt=False):
        self.writer = writer
        self.denied = denied
        self.corrupt = corrupt
        self.query = None

    def cursor(self):
        return VerifierCursor(self)


class InjectedTests(unittest.TestCase):
    def test_complete_synthetic_roundtrip_with_parameterized_private_read(self):
        writer = Writer()
        verifier = Verifier(writer)
        out = synthetic_roundtrip_with_private_reader(RAW, provenance(), writer, verifier)
        self.assertEqual(out["status"], "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE")
        self.assertEqual(out["sha256"], hashlib.sha256(RAW).hexdigest())
        self.assertEqual(out["payload_bytes"], len(RAW))
        self.assertEqual(verifier.query, (READ_SQL, ("SYNTH-G1-A7",)))
        self.assertNotIn("synthetic", str(out))

    def test_same_object_rejected_before_write(self):
        writer = Writer()
        with self.assertRaisesRegex(PersistenceHold, "distinct objects"):
            synthetic_roundtrip_with_private_reader(RAW, provenance(), writer, writer)
        self.assertIsNone(writer.committed)

    def test_missing_verifier_rejected_before_write(self):
        writer = Writer()
        with self.assertRaises(PersistenceHold):
            synthetic_roundtrip_with_private_reader(RAW, provenance(), writer, None)
        self.assertIsNone(writer.committed)

    def test_write_error_rolls_back_without_leak(self):
        writer = Writer(reject=True)
        with self.assertRaises(PersistenceHold) as e:
            synthetic_roundtrip_with_private_reader(RAW, provenance(), writer, Verifier(writer))
        self.assertEqual(writer.rollbacks, 1)
        self.assertIsNone(writer.committed)
        self.assertNotIn("SENSITIVE", str(e.exception))

    def test_verifier_denial_after_commit_is_hold(self):
        writer = Writer()
        with self.assertRaisesRegex(PersistenceHold, "write may be committed") as e:
            synthetic_roundtrip_with_private_reader(RAW, provenance(), writer,
                                                    Verifier(writer, denied=True))
        self.assertEqual(writer.committed[-1], RAW)
        self.assertNotIn("SENSITIVE", str(e.exception))

    def test_corrupt_bytes_after_commit_is_hold(self):
        writer = Writer()
        with self.assertRaisesRegex(PersistenceHold, "write may be committed"):
            synthetic_roundtrip_with_private_reader(RAW, provenance(), writer,
                                                    Verifier(writer, corrupt=True))
        self.assertEqual(writer.committed[-1], RAW)


if __name__ == "__main__":
    unittest.main()
