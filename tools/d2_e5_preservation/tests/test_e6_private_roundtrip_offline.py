"""Purely synthetic writer/verifier separation tests; no network or DB driver."""
import hashlib
import unittest
from datetime import datetime, timezone

from e6_private_pg_offline import PersistenceHold
from e6_private_roundtrip_offline import synthetic_private_roundtrip, verify_private_readback

RAW = b'{"synthetic":true}'


def meta():
    t = datetime(2026, 10, 24, tzinfo=timezone.utc)
    return dict(observation_id="SYNTH-ROUNDTRIP", activity_id="OES/SYNTHETIC",
                repository_commit_sha="a" * 40, github_run_id=1, run_attempt=1,
                source_name="ClinicalTrials.gov API v2",
                requested_url_exact="https://example.invalid/synthetic",
                started_at_utc=t, completed_at_utc=t, source_http_status=200,
                response_content_type="application/json")


class FakeCursor:
    def __init__(self, writer):
        self.writer = writer

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, sql, params):
        if self.writer.reject:
            raise RuntimeError("SENSITIVE: permission denied or duplicate")
        self.writer.staged = (params[0], params[-3], params[-2], params[-1])


class Writer:
    autocommit = False

    def __init__(self, reject=False):
        self.reject = reject
        self.staged = None
        self.committed = None
        self.rollbacks = 0

    def cursor(self):
        return FakeCursor(self)

    def commit(self):
        self.committed = self.staged

    def rollback(self):
        self.staged = None
        self.rollbacks += 1

    def select(self):
        raise PermissionError("writer cannot SELECT")


class Reader:
    def __init__(self, writer, corrupt=None):
        self.writer = writer
        self.corrupt = corrupt

    def __call__(self, observation_id):
        if self.corrupt == "denied":
            raise PermissionError("verifier cannot access")
        if self.writer.committed is None:
            raise LookupError("not committed")
        row = self.writer.committed
        if self.corrupt == "bytes":
            return row[:-1] + (b"x" + row[-1][1:],)
        if self.corrupt == "digest":
            return (row[0], "0"*64, row[2], row[3])
        if self.corrupt == "id":
            return ("DIFFERENT", *row[1:])
        return row

    def insert(self):
        raise PermissionError("verifier cannot INSERT")


class RoundTripTests(unittest.TestCase):
    def test_success_and_sanitized_output(self):
        writer = Writer()
        reader = Reader(writer)
        result = synthetic_private_roundtrip(RAW, meta(), writer, reader)
        self.assertEqual(result["status"], "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE")
        self.assertNotIn("synthetic", str(result))
        self.assertEqual(writer.committed[-1], RAW)
        with self.assertRaises(PermissionError):
            writer.select()
        with self.assertRaises(PermissionError):
            reader.insert()

    def test_no_verifier_fails_before_write(self):
        writer = Writer()
        with self.assertRaises(PersistenceHold):
            synthetic_private_roundtrip(RAW, meta(), writer, None)
        self.assertIsNone(writer.committed)

    def test_write_denied_rolls_back(self):
        writer = Writer(reject=True)
        with self.assertRaises(PersistenceHold) as err:
            synthetic_private_roundtrip(RAW, meta(), writer, Reader(writer))
        self.assertNotIn("SENSITIVE", str(err.exception))
        self.assertIsNone(writer.committed)
        self.assertEqual(writer.rollbacks, 1)

    def test_failed_readback_is_hold_after_commit(self):
        for corruption in ("denied", "bytes", "digest", "id"):
            with self.subTest(corruption=corruption):
                writer = Writer()
                with self.assertRaisesRegex(PersistenceHold, "write may be committed"):
                    synthetic_private_roundtrip(RAW, meta(), writer, Reader(writer, corruption))
                self.assertEqual(writer.committed[-1], RAW)

    def test_malformed_readback(self):
        digest = hashlib.sha256(RAW).hexdigest()
        for value in (None, (), ("SYNTH-ROUNDTRIP", digest, 18, "not bytes")):
            with self.subTest(value=value):
                with self.assertRaises(PersistenceHold):
                    verify_private_readback(value, "SYNTH-ROUNDTRIP", digest, len(RAW))

    def test_size_mismatch(self):
        digest = hashlib.sha256(RAW).hexdigest()
        with self.assertRaises(PersistenceHold):
            verify_private_readback(("SYNTH-ROUNDTRIP", digest, 999, RAW),
                                    "SYNTH-ROUNDTRIP", digest, len(RAW))


if __name__ == "__main__":
    unittest.main()
