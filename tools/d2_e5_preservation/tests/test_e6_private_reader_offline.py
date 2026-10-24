"""Synthetic-only contract tests for the injected private DB-API reader."""
import unittest

from e6_private_pg_offline import PersistenceHold
from e6_private_reader_offline import READ_SQL, read_private_observation


class Cursor:
    def __init__(self, row=None, failure=None):
        self.row, self.failure = row, failure
        self.executed = None

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, sql, params):
        self.executed = (sql, params)
        if self.failure:
            raise RuntimeError("PRIVATE_PAYLOAD_MUST_NOT_ESCAPE")

    def fetchone(self):
        return self.row


class VerifierConnection:
    def __init__(self, row=None, failure=None):
        self.cursor_object = Cursor(row, failure)

    def cursor(self):
        return self.cursor_object


class ReaderTests(unittest.TestCase):
    def test_parameterized_success_keeps_bytes_private(self):
        raw = b'{"synthetic":true}'
        row = ("SYNTH-01", "a" * 64, len(raw), raw)
        connection = VerifierConnection(row)
        result = read_private_observation(connection, "SYNTH-01")
        self.assertEqual(result, row)
        self.assertEqual(connection.cursor_object.executed,
                         (READ_SQL, ("SYNTH-01",)))
        self.assertIn("%s", READ_SQL)
        self.assertNotIn("SYNTH-01", READ_SQL)

    def test_invalid_identifier_fails_before_query(self):
        for value in (None, "", "  ", 7):
            with self.subTest(value=value):
                connection = VerifierConnection()
                with self.assertRaises(PersistenceHold):
                    read_private_observation(connection, value)
                self.assertIsNone(connection.cursor_object.executed)

    def test_missing_or_malformed_readback_fail_closed(self):
        for row in (None, (), ("SYNTH-01", "a"*64, 18, "not-bytes"),
                    ("OTHER", "a"*64, 18, b'x'),
                    ("SYNTH-01", "a"*64, True, b'x')):
            with self.subTest(row=row):
                with self.assertRaises(PersistenceHold):
                    read_private_observation(VerifierConnection(row), "SYNTH-01")

    def test_database_exception_is_sanitized(self):
        with self.assertRaises(PersistenceHold) as err:
            read_private_observation(
                VerifierConnection(failure=True), "SYNTH-01")
        self.assertNotIn("PRIVATE_PAYLOAD", str(err.exception))
        self.assertIsNone(err.exception.__cause__)

    def test_missing_connection_fails_closed(self):
        with self.assertRaises(PersistenceHold):
            read_private_observation(None, "SYNTH-01")


if __name__ == "__main__":
    unittest.main()
