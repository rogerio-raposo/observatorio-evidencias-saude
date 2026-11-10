"""P2 document/ORM consistency only; no database or new runtime verifier."""
import json
from pathlib import Path
import re
from unittest.mock import MagicMock

from django.test import SimpleTestCase

from config.mb_oc1 import private_configuration
from evidence import models
from evidence import test_mb_oc1_offline as mb_fixture
from evidence.question_orm_q0_evidence_dormant import TABLES, _review_q0_privileges


ROOT = Path(__file__).resolve().parents[3]
MANIFEST = ROOT / "docs/architecture/oes-q0-physical-contract.json"
OPERATIONS = ROOT / "docs/governance/OES_Q0_OPERATIONAL_CONTRACT_P2.md"


def matrix_rows(marker):
    text = OPERATIONS.read_text()
    block = text.split(f"<!-- {marker} -->", 1)[1].split(f"<!-- /{marker} -->", 1)[0]
    lines = [line for line in block.splitlines() if line.startswith("|")]
    return [[cell.strip() for cell in line.strip("|").split("|")] for line in lines[2:]]


class P2OperationalContractTests(SimpleTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.contract = json.loads(MANIFEST.read_text())

    def test_columns_and_primary_keys_match_unmanaged_models(self):
        types = {"uuid": "UUIDField", "text": "TextField", "integer": "IntegerField",
                 "jsonb": "JSONField", "timestamp with time zone": "DateTimeField",
                 "character varying(64)": "CharField"}
        declared_models = {model for model in vars(models).values()
                           if isinstance(model, type) and model.__module__ == models.__name__}
        self.assertEqual(declared_models, {getattr(models, t["django_model"]) for t in self.contract["tables"]})
        self.assertEqual(len(self.contract["tables"]), 5)
        self.assertEqual(sum(len(t["columns"]) for t in self.contract["tables"]), 39)
        for table in self.contract["tables"]:
            model = getattr(models, table["django_model"])
            self.assertIs(model._meta.managed, False)
            self.assertEqual(model._meta.db_table, table["db_table"])
            fields = {f.column: f for f in model._meta.concrete_fields}
            self.assertEqual(set(fields), {c["name"] for c in table["columns"]})
            pk = model._meta.pk
            self.assertEqual(tuple(table["primary_key"]), getattr(pk, "field_names", (pk.name,)))
            for column in table["columns"]:
                field = fields[column["name"]]
                with self.subTest(table=table["table"], column=column["name"]):
                    self.assertEqual(field.get_internal_type(), types[column["pg_type"]])
                    self.assertEqual(field.null, column["nullable"])
                    if column["pg_type"] == "character varying(64)":
                        self.assertEqual(field.max_length, 64)
        self.assertTrue(models.OesEntity._meta.get_field("oes_id").unique)

    def test_constraint_references_and_declarations_are_traceable(self):
        tables = {t["table"]: t for t in self.contract["tables"]}
        sources = {key: re.sub(r"\s+", "", (ROOT / s["path"]).read_text())
                   for key, s in self.contract["sources"].items()}
        foreign_keys = 0
        for table in tables.values():
            columns = {c["name"] for c in table["columns"]}
            self.assertTrue(set(table["primary_key"]) <= columns)
            for constraint in table["constraints"]:
                self.assertTrue(set(constraint["columns"]) <= columns)
                source = sources[constraint["declared_by"]]
                if constraint["kind"] == "check":
                    self.assertIn(re.sub(r"\s+", "", constraint["expression"]), source)
                elif constraint["kind"] == "foreign_key":
                    foreign_keys += 1
                    reference = constraint["references"]
                    target = tables[reference["table"]]
                    keys = [target["primary_key"], *[c["columns"] for c in target["constraints"] if c["kind"] == "unique"]]
                    self.assertIn(reference["columns"], keys)
                    declaration = "REFERENCES" + reference["table"] + "(" + ",".join(reference["columns"]) + ")"
                    self.assertIn(declaration, source)
            for index in table["indexes"]:
                source = sources[index["declared_by"]]
                self.assertIn(index["name"], source)
                if "predicate" in index:
                    self.assertIn(re.sub(r"\s+", "", index["predicate"]), source)
        self.assertEqual(foreign_keys, 8)  # Also the delimited historical CP336 inventory.

    def test_sources_and_evidence_are_delimited_without_catalog_claim(self):
        self.assertEqual(self.contract["status"], "OFFLINE_REFERENCE_NOT_CATALOG_ATTESTATION")
        self.assertEqual(self.contract["checkpoint"], "CP348")
        for source in self.contract["sources"].values():
            self.assertIn(source["anchor"], (ROOT / source["path"]).read_text())
        completed = set()
        for evolution in self.contract["documented_evolution"]:
            self.assertTrue(set(evolution["depends_on"]) <= completed)
            self.assertIn(evolution["declared_by"], self.contract["sources"])
            completed.add(evolution["step"])
        for table in self.contract["tables"]:
            self.assertEqual(table["current_catalog"], "NOT_RECONFIRMED")
            for column in table["columns"]:
                self.assertIn(column["declared_by"], self.contract["sources"])
            for observation in table["historical_evidence"]:
                self.assertIn("scope", observation)
                self.assertIn(observation["source"], self.contract["sources"])
        self.assertTrue((ROOT / self.contract["connected_acceptance"].split("#")[0]).is_file())

    def test_document_profile_matrix_matches_existing_configuration(self):
        rows = matrix_rows("q0-profile-matrix")
        for profile in ("A", "B"):
            expected = {alias: (role, mode) for p, alias, role, mode in rows if p == profile}
            configuration = private_configuration(profile, mb_fixture.PrivateProfileTests().env(profile))
            self.assertEqual(set(configuration["DATABASES"]), set(expected))
            for alias, database in configuration["DATABASES"].items():
                role, mode = expected[alias]
                self.assertEqual(database["USER"], role)
                self.assertEqual("default_transaction_read_only=on" in database["OPTIONS"]["options"], mode == "READ_ONLY")
        self.assertNotIn("oes_q0_writer", {alias for p, alias, _, _ in rows if p == "B"})

    def test_document_acl_matrix_matches_single_p1_verifier(self):
        self.assertEqual(set(TABLES), {t["table"] for t in self.contract["tables"]})
        rows = matrix_rows("q0-acl-matrix")
        self.assertEqual(len(rows), 2)
        self.assertEqual({row[0] for row in rows}, {"oes_q0_writer", "oes_synthetic_reader"})
        for alias, role, *values in rows:
            self.assertEqual(len(values), 5)
            self.assertTrue(all(v in ("true", "false") for v in values))
            row = tuple(v == "true" for v in values)
            connection = MagicMock(alias=alias)
            cursor = connection.cursor.return_value.__enter__.return_value
            cursor.fetchone.side_effect = [(True,), (True,), *[row for _ in TABLES]]
            observed = _review_q0_privileges(connection)
            self.assertEqual(len(observed), 7)
            self.assertEqual({r for _, r in observed[2:]}, {row})
            self.assertEqual(role, "oes_qprep_login" if alias == "oes_q0_writer" else "oes_pg_a4_reader")
