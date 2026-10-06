#!/usr/bin/env python3
"""Validate the rendered real MAP-01 exploratory Evidence Map."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--rendered", required=True)
    args = parser.parse_args()

    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    rendered = Path(args.rendered).read_text(encoding="utf-8")

    require("{{" not in rendered and "}}" not in rendered, "Unresolved template token remains")
    require(payload.get("schema_version") == "oes.evidence_map_view/0.1", "Unexpected view schema")

    identity = payload["identity"]
    method = payload["mapping_method"]
    audit = payload["audit"]

    require(identity["product_id"] == "OES-P-2026-001401", "Wrong MAP-01 product")
    require(identity["editorial_status"] == "under_review", "MAP-01 must remain under_review")
    require(identity.get("publication_date") is None, "MAP-01 must remain unpublished")
    require(method["mapping_subtype"] == "descriptive_mapping_review", "Wrong subtype")
    require(method["coverage_claim"] == "structured_non_exhaustive", "Wrong coverage")
    require(method["gap_claim_mode"] == "apparent_only", "Wrong gap mode")
    require(method["counting_unit_policy"] == "study", "Wrong counting unit")
    require(audit["assurance_level"] == "A1", "MAP-01 must render at A1 after AI verification")
    require(audit["publishable"] is False, "MAP-01 must remain non-publishable")
    require(audit["synthetic_fixture"] is False, "Real MAP-01 cannot be marked synthetic")
    require(audit["source_corpus_count"] == 1, "Expected one source corpus")

    require(len(payload["source_investigations"]) == 1, "Expected one source investigation")
    src = payload["source_investigations"][0]
    require(src["investigation_id"] == "OES-I-2026-000701", "Wrong source corpus investigation")
    require(src["product_role"] == "source_corpus", "Wrong source corpus role")
    require(src["evidence_cutoff_date"] == "2026-10-05", "Wrong inherited cutoff")

    require(len(payload["searches"]) == 3, "Expected three inherited Search records")
    require(payload["selection_flow"]["search_hits"] == 20, "Expected 20 inherited SearchHits")
    require(payload["selection_flow"]["screening_decisions"] == 34, "Expected 34 inherited screening decisions")
    require(len(payload["map_items"]) == 17, "Expected 17 MapItems")
    require(len(payload["cells"]) == 20, "Expected 20 cells")
    require(len(payload["references"]) == 13, "Expected 13 references")

    require(
        all(not cell["empty_cell_gap"] for cell in payload["cells"]),
        "Formal empty-cell gap must not exist in MAP-01",
    )
    require(
        any(cell["apparent_gap"] for cell in payload["cells"]),
        "At least one apparent gap is expected",
    )

    require(
        "FIXTURE SINTÉTICA — NÃO REPRESENTA MAPA DE EVIDÊNCIAS REAL" not in rendered,
        "Real MAP-01 incorrectly displays synthetic fixture banner",
    )
    require(
        "GATE DE PUBLICAÇÃO DO MAPA NÃO APROVADO" in rendered,
        "MAP-01 blocked publication banner missing",
    )
    require(
        "**Assurance:** A1 — verificação metodológica por IA" in rendered,
        "A1 assurance label missing",
    )
    require(
        "**Cobertura:** estruturada não exaustiva" in rendered,
        "Non-exhaustive coverage label missing",
    )
    require(
        "**Modo de gap:** gaps apenas aparentes" in rendered,
        "Apparent-gap mode label missing",
    )
    require(
        "Investigações-fonte do corpus" in rendered,
        "Source-corpus section missing",
    )
    require(
        "OES-I-2026-000701 | corpus fonte | rapid_evidence_synthesis | N3 | 2026-10-05 | completed" in rendered,
        "Source-corpus row missing or incorrectly labeled",
    )
    require(
        payload["question"]["normalized_text"] in rendered,
        "MAP-specific mapping question missing",
    )
    require(
        payload["conclusion"]["text"] in rendered,
        "Canonical MAP-01 conclusion missing",
    )
    require(
        payload["limitations"]["summary"] in rendered,
        "MAP-01 limitations missing",
    )
    require(
        "**Gap aparente.**" in rendered,
        "Apparent-gap wording missing",
    )
    require(
        "Nenhuma unidade elegível foi localizada nas fontes consultadas" in rendered,
        "Scoped apparent-gap disclosure missing",
    )
    require(
        "Gap formal dentro do escopo definido." not in rendered,
        "MAP-01 incorrectly renders a formal gap",
    )
    require(
        "Densidade de evidência não equivale a magnitude de efeito" in rendered,
        "Density/effect warning missing",
    )
    require(
        "NON_EXHAUSTIVE_MAP" in rendered
        and "APPARENT_GAPS_ONLY" in rendered
        and "AI_ASSISTED_CLASSIFICATION" in rendered,
        "Required exploratory warnings not rendered",
    )
    require(
        "MISSING_OWNER_APPROVAL" in rendered
        and "ASSURANCE_BELOW_REQUIRED_LEVEL" in rendered
        and "PRODUCT_NOT_PUBLISHED" in rendered,
        "Expected internal/publication blockers not rendered",
    )
    require(
        "MISSING_AI_METHODOLOGICAL_VERIFICATION" not in rendered,
        "A1 render still claims missing AI methodological verification",
    )

    print("MAP01-RENDER-A1 PASS")


if __name__ == "__main__":
    main()
