"""M2-A6: deterministic, offline documentary Q-I-P reference checks."""
import hashlib
import re
import unittest
from pathlib import Path

SOURCE = Path(__file__).resolve().parents[1] / "database/f3-real-case-01-dcbti.sql"
IDS = {
    "question": "OES-Q-2026-000401",
    "investigation": "OES-I-2026-000401",
    "product": "OES-P-2026-000401",
}
VERSIONS = {
    "question": "81000000-0000-0000-0000-000000000001",
    "investigation": "81000000-0000-0000-0000-000000000002",
    "product": "81000000-0000-0000-0000-000000000701",
}


def rows_for(sql, relation):
    """Read only simple literal VALUES rows of named historical links; reject ambiguity."""
    pattern = r"INSERT INTO\s+" + re.escape(relation) + r"\s*\([^;]*?\)\s*VALUES\s*\(([^;]*?)\);"
    matches = re.findall(pattern, sql, flags=re.I | re.S)
    if len(matches) != 1:
        raise ValueError("missing or ambiguous link: " + relation)
    return re.findall(r"'([^']*)'", matches[0])


def manifest(sql):
    for name, value in IDS.items():
        pattern = r"'"+ re.escape(value) + r"'\s*,\s*'" + {"question":"Question","investigation":"Investigation","product":"Product"}[name] + r"'"
        if len(re.findall(pattern, sql)) != 1:
            raise ValueError("missing or divergent identifier: " + name)
    qlink = rows_for(sql, "investigation.investigation_question")
    plink = rows_for(sql, "product.investigation_link")
    if qlink != [VERSIONS["investigation"], VERSIONS["question"], "primary"]:
        raise ValueError("wrong question-investigation version link")
    if plink != [VERSIONS["product"], VERSIONS["investigation"], "primary"]:
        raise ValueError("wrong product-investigation version link")
    for version in VERSIONS.values():
        if sql.count("'" + version + "'") < 2:
            raise ValueError("missing version")
    material = "|".join([IDS[k] + ":" + VERSIONS[k] for k in ("question","investigation","product")])
    return hashlib.sha256(material.encode("utf-8")).hexdigest()


class M2A6Offline(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sql = SOURCE.read_text(encoding="utf-8")

    def test_mi08_divergent_identifier_holds(self):
        bad = self.sql.replace("'OES-I-2026-000401'","'OES-I-2026-999999'",1)
        with self.assertRaises(ValueError):
            manifest(bad)

    def test_mi09_missing_link_holds(self):
        bad = self.sql.replace("INSERT INTO product.investigation_link(", "INSERT INTO product.removed_link(", 1)
        with self.assertRaises(ValueError):
            manifest(bad)

    def test_mi10_reproducible(self):
        self.assertEqual(manifest(self.sql), manifest(self.sql))
        self.assertEqual(len(manifest(self.sql)),64)


if __name__ == "__main__":
    unittest.main()
