"""D2-I-C single-identity E6 composition: offline mock only, no real DB or network."""
import hashlib
import unittest
from datetime import datetime, timezone

from e6_private_pg_offline import prepare_observation, persist_observation, PersistenceHold
from e6_private_reader_offline import read_private_observation
from e6_private_roundtrip_offline import verify_private_readback

RAW = b'{"synthetic":true,"pilot":"D2-I-C"}'


def provenance():
    t = datetime(2026, 10, 25, tzinfo=timezone.utc)
    return dict(observation_id="SYNTH-D2-I-C-LOCAL", activity_id="OES/SYNTHETIC",
                repository_commit_sha="a" * 40, github_run_id=1, run_attempt=1,
                source_name="ClinicalTrials.gov API v2",
                requested_url_exact="https://example.invalid/synthetic",
                started_at_utc=t, completed_at_utc=t, source_http_status=200,
                response_content_type="application/json")


class MemoryCursor:
    def __init__(self, connection):
        self.connection = connection
        self.result = None

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, sql, params):
        c = self.connection
        if sql.startswith("INSERT INTO oes_raw_private.source_observation "):
            c.insert_calls += 1
            if c.fail_write:
                raise RuntimeError("SENSITIVE_WRITE_ERROR")
            c.pending = (params[0], params[-3], params[-2], params[-1])
        elif sql.startswith("SELECT observation_id, payload_sha256, payload_bytes, raw_payload "):
            c.read_calls += 1
            if c.fail_read:
                raise RuntimeError("SENSITIVE_READ_ERROR")
            row = c.committed
            self.result = (row[0], row[1], row[2], b"altered" if c.tamper else row[3]) if row else None
        else:
            raise AssertionError("unexpected SQL")

    def fetchone(self):
        return self.result


class MemoryConnection:
    autocommit = False

    def __init__(self):
        self.pending = self.committed = None
        self.insert_calls = self.read_calls = self.commits = self.rollbacks = 0
        self.fail_write = self.fail_read = self.tamper = False

    def cursor(self):
        return MemoryCursor(self)

    def commit(self):
        self.committed = self.pending
        self.pending = None
        self.commits += 1

    def rollback(self):
        self.pending = None
        self.rollbacks += 1


def direct_single_identity_trial(connection):
    """Test-local composition; intentionally not an application or production API."""
    prepared = prepare_observation(RAW, provenance())
    persist_observation(connection, prepared)
    try:
        result = read_private_observation(connection, prepared.observation_id)
        verify_private_readback(result, prepared.observation_id,
                                prepared.sha256, prepared.byte_count)
    except Exception:
        raise PersistenceHold("HOLD: private verification failed; write may be committed") from None
    return {"status": "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE",
            "observation_id": prepared.observation_id,
            "sha256": prepared.sha256, "payload_bytes": prepared.byte_count}


class SingleIdentityCompositionTests(unittest.TestCase):
    def test_roundtrip_integrity_and_sanitized_result(self):
        connection = MemoryConnection()
        outcome = direct_single_identity_trial(connection)
        self.assertEqual(outcome["sha256"], hashlib.sha256(RAW).hexdigest())
        self.assertEqual(outcome["payload_bytes"], len(RAW))
        self.assertEqual(connection.committed[0], provenance()["observation_id"])
        self.assertEqual(connection.committed[1], outcome["sha256"])
        self.assertEqual(connection.committed[2], len(RAW))
        self.assertEqual(connection.committed[3], RAW)
        self.assertEqual((connection.insert_calls, connection.commits, connection.read_calls), (1, 1, 1))
        self.assertNotIn(RAW, tuple(outcome.values()))

    def test_write_failure_holds_without_commit_or_retry(self):
        connection = MemoryConnection()
        connection.fail_write = True
        with self.assertRaises(PersistenceHold) as ctx:
            direct_single_identity_trial(connection)
        self.assertEqual((connection.insert_calls, connection.commits, connection.read_calls), (1, 0, 0))
        self.assertEqual(connection.rollbacks, 1)
        self.assertNotIn("SENSITIVE", str(ctx.exception))

    def test_corrupt_readback_after_commit_holds_without_retry(self):
        connection = MemoryConnection()
        connection.tamper = True
        with self.assertRaisesRegex(PersistenceHold, "may be committed"):
            direct_single_identity_trial(connection)
        self.assertEqual((connection.insert_calls, connection.commits, connection.read_calls), (1, 1, 1))
        self.assertEqual(connection.committed[3], RAW)

    def test_read_failure_after_commit_holds_and_sanitizes(self):
        connection = MemoryConnection()
        connection.fail_read = True
        with self.assertRaises(PersistenceHold) as ctx:
            direct_single_identity_trial(connection)
        self.assertIn("may be committed", str(ctx.exception))
        self.assertNotIn("SENSITIVE", str(ctx.exception))
        self.assertEqual((connection.insert_calls, connection.commits, connection.read_calls), (1, 1, 1))


if __name__ == "__main__":
    unittest.main()
