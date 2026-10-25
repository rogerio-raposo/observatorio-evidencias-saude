#!/usr/bin/env python3
"""Offline regressions for N2 editorial fixes E01-E04 (no database/network)."""
import copy
import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from render_evidence_sheet_reference import render, stringify

class EditorialN2Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.template = (ROOT / "templates/evidence-sheet.md").read_text()
        cls.presentation = json.loads((ROOT / "templates/evidence-sheet-presentation-map.json").read_text())

    def test_e01_known_label_and_unknown_object(self):
        self.assertEqual(stringify("synthesis.timepoint", {"label":"post-treatment"}, {}), "post-treatment")
        self.assertEqual(stringify("synthesis.timepoint", {"unverified":1}, {}), '{"unverified":1}')
        self.assertEqual(stringify("synthesis.timepoint", {"label":"x","other":2}, {}), '{"label":"x","other":2}')
        self.assertEqual(stringify("unrelated.field", {"label":"x"}, {}), '{"label":"x"}')
        self.assertEqual(
            stringify("synthesis.population", {"population": "adultos"}, {}),
            "População: adultos",
        )
        self.assertEqual(
            stringify("synthesis.comparison", {"intervention": "I", "comparator": "C"}, {}),
            "Intervenção: I; Comparador: C",
        )
        context = {"population": "P", "intervention": "I", "comparator": "C",
                   "primary_outcome": "D"}
        self.assertEqual(
            stringify("question.context", context, {}),
            "População: P; Intervenção: I; Comparador: C; Desfecho principal: D",
        )
        self.assertEqual(
            stringify("synthesis.comparison", {"intervention":"I", "extra":"?"}, {}),
            '{"extra":"?","intervention":"I"}',
        )
        self.assertEqual(
            stringify("synthesis.population", {"population": "P", "extra": "?"}, {}),
            '{"extra":"?","population":"P"}',
        )

    def test_e02_e03_e04_and_safety(self):
        # Exercise the actual N2 table/heading fragments without fabricating scientific data.
        start = self.template.index("## Resultados e achados prioritários")
        stop = self.template.index("### Detalhamento", start)
        segment = self.template[start:stop]
        payload={"priority_results":[
            {"role":role,"outcome":{"preferred_name":"Achado registrado"},
             "synthesis":{"result_summary":{"summary_text":"Resultado registrado"}},
             "contributing_studies":2,"certainty":{"formal_assessment":False,"display":"não avaliada formalmente"}}
            for role in ("source","primary","corroborative")]}
        frozen=copy.deepcopy(payload)
        result=render("<!-- OES Evidence Sheet Template -->\n"+segment,payload,self.presentation)
        self.assertEqual(payload,frozen)
        self.assertIn("| Papel da síntese |",result)
        for role in ("síntese-fonte","síntese principal","síntese corroborativa"):
            self.assertIn(role,result)
        self.assertNotIn("\n\n|", result)
        self.assertEqual(result.count("Achado registrado"),3)
        self.assertIn("não equivale aos Studies modelados",self.template)
        self.assertIn("não confundir com k",self.template)

    def test_preview_and_assurance_not_removed(self):
        self.assertIn("PREVIEW — NÃO PUBLICÁVEL", self.template)
        self.assertIn("audit.assurance_disclosure",self.template)
        self.assertIn("audit.expert_independent_reviewed",self.template)
        self.assertIn("audit.publishable",self.template)
        self.assertIn("identity.evidence_cutoff_date",self.template)
        self.assertIn("## Referências utilizadas",self.template)
        self.assertIn("## Atualidade e histórico",self.template)

    def test_shared_engine_unchanged_for_other_templates(self):
        template="| x |\\n\\n| y |"
        self.assertEqual(render(template,{},{}),template)
        self.assertEqual(render("{{x}}",{"x":{"label":"untouched"}},{}),'{"label":"untouched"}')

if __name__=="__main__":
    unittest.main()
