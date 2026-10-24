"""Local unit tests; never connect to Neon."""
from unittest.mock import MagicMock, patch
from uuid import UUID
from django.test import SimpleTestCase
from django.test.utils import override_settings
from evidence.synthetic_pg_reader import list_synthetic_study_report_links, ALIAS

class SyntheticReaderTests(SimpleTestCase):
    @override_settings(DATABASES={})
    def test_disabled_by_default(self):
        with self.assertRaisesRegex(RuntimeError, "disabled"):
            list_synthetic_study_report_links()

    @override_settings(DATABASES={ALIAS: {"ENGINE": "django.db.backends.postgresql", "NAME": "test"}})
    def test_projection_and_parameterized_read(self):
        cursor = MagicMock()
        uid = [UUID(f"10000000-0000-4000-8000-{i:012d}") for i in range(1, 6)]
        cursor.fetchall.return_value = [(uid[0], uid[1], uid[2], uid[3], "reports", uid[4], "title")]
        connection = MagicMock()
        connection.cursor.return_value.__enter__.return_value = cursor
        with patch("evidence.synthetic_pg_reader.connections") as connections:
            connections.__getitem__.return_value = connection
            links = list_synthetic_study_report_links()
        self.assertEqual(len(links), 1)
        self.assertEqual(links[0].study_entity_uuid, uid[0])
        self.assertEqual(links[0].provenance_field_path, "title")
        self.assertEqual(links[0].evidence_boundary, "SYNTHETIC_TECHNICAL_ONLY")
        args = cursor.execute.call_args.args
        self.assertEqual(args[1], ["active"])
        self.assertTrue(args[0].lstrip().startswith("SELECT"))
