#!/usr/bin/env python3
"""Structural, semantic and governance validation for OES Evidence Map renders."""

from __future__ import annotations

import argparse
import copy
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def find_cell(payload: dict, row: str, column: str) -> dict:
    for cell in payload.get("cells", []):
        if (
            cell.get("row_category_code") == row
            and cell.get("column_category_code") == column
        ):
            return cell
    raise AssertionError(f"Cell {row}/{column} not found")


def validate_formal_synthetic(
    template: str,
    payload: dict,
    rendered: str,
) -> None:
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.evidence_map.template/0.1" in template,
        "Evidence Map template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.evidence_map_view/0.1",
        "Unexpected EvidenceMapView schema version",
    )

    identity = payload["identity"]
    method = payload["mapping_method"]
    audit = payload["audit"]

    require(audit["synthetic_fixture"] is True, "Fixture must be explicitly synthetic")
    require(audit["publishable"] is True, "Formal synthetic map must pass publication gate")
    require(audit["assurance_level"] == "A3", "Formal synthetic map must derive A3")
    require(
        audit["required_assurance_level"] == "A3",
        "Formal synthetic map must require A3",
    )
    require(
        method["mapping_subtype"] == "evidence_gap_map",
        "Unexpected mapping subtype",
    )
    require(
        method["coverage_claim"] == "systematic_comprehensive",
        "Formal fixture must use systematic_comprehensive coverage",
    )
    require(
        method["gap_claim_mode"] == "formal_within_scope",
        "Formal fixture must use formal_within_scope gap mode",
    )
    require(
        method["counting_unit_policy"] == "study",
        "Formal fixture must count Studies",
    )

    require(len(payload["dimensions"]) == 3, "Expected three dimensions")
    require(len(payload["categories"]) == 5, "Expected five categories")
    require(len(payload["map_items"]) == 4, "Expected four MapItems")
    require(len(payload["cells"]) == 4, "Expected four cells")
    require(len(payload["reviewer_assignments"]) == 6, "Expected six reviewer assignments")
    require(len(payload["method_controls"]) == 3, "Expected three method controls")
    require(len(payload["lineage"]) == 5, "Expected five lineage edges")
    require(len(payload["references"]) == 2, "Expected two source references")

    ay = find_cell(payload, "A", "Y")
    az = find_cell(payload, "A", "Z")
    by = find_cell(payload, "B", "Y")
    bz = find_cell(payload, "B", "Z")

    require(
        ay["study_count"] == 1
        and ay["report_count"] == 1
        and ay["synthesis_count"] == 1
        and ay["counted_unit_count"] == 1,
        "A/Y count semantics changed",
    )
    require(
        az["scope_status"] == "in_scope"
        and az["empty_cell_gap"] is True
        and az["counted_unit_count"] == 0,
        "A/Z must remain the formal empty-cell gap",
    )
    require(
        bz["scope_status"] == "not_applicable"
        and bz["gap_eligible"] is False
        and bz["empty_cell_gap"] is False
        and bz["apparent_gap"] is False
        and bz["primary_evidence_gap"] is False
        and bz["synthesis_gap"] is False,
        "B/Z not_applicable semantics changed",
    )
    require(
        by["study_count"] == 1
        and by["synthesis_count"] == 0
        and by["synthesis_gap"] is True,
        "B/Y must demonstrate a synthesis gap",
    )

    report_ids = {item["report_id"] for item in payload["references"]}
    require(
        {"OES-RP-2026-001101", "OES-RP-2026-001102"}.issubset(report_ids),
        "Study-linked references are incomplete",
    )

    require(payload["protocol"]["content_hash"], "Protocol hash missing")
    require(payload["codebook"]["content_hash"], "Codebook hash missing")
    require(audit["search_controls_satisfied"] is True, "Search controls must pass")
    require(
        audit["classification_controls_satisfied"] is True,
        "Classification controls must pass",
    )
    require(audit["lineage_available"] is True, "Lineage must be available")
    require(audit["invalidated_dependencies"] is False, "Unexpected invalid dependency")

    for value in [
        identity["title"],
        identity["product_id"],
        payload["question"]["normalized_text"],
        payload["conclusion"]["text"],
        payload["limitations"]["summary"],
        payload["protocol"]["storage_key"],
        payload["codebook"]["storage_key"],
    ]:
        require(value and value in rendered, f"Required rendered value missing: {value!r}")

    require(
        "FIXTURE SINTÉTICA — NÃO REPRESENTA MAPA DE EVIDÊNCIAS REAL" in rendered,
        "Synthetic fixture banner missing",
    )
    require(
        "Gate de publicação do Mapa: aprovado." in rendered,
        "Approved map gate banner missing",
    )
    require(
        "**Gate de publicação do Mapa:** aprovado" in rendered,
        "Approved audit gate state missing",
    )
    require(
        "Densidade de evidência não equivale a magnitude de efeito" in rendered,
        "Density/effect epistemic warning missing",
    )
    require(
        "Gap é dependente do framework, escopo, coverage, fontes e data de corte" in rendered,
        "Gap scope warning missing",
    )
    require(
        "Gap formal dentro do escopo definido." in rendered,
        "Formal gap wording missing",
    )
    require(
        "Synthesis gap:" in rendered,
        "Synthesis-gap wording missing",
    )
    require(
        "| Intervention B | Outcome Z | não aplicável | não | 0 | 0 | 0" in rendered,
        "Not-applicable cell is not visibly distinguished",
    )

    issue_codes = {item["code"] for item in audit["publication_issues"]}
    require(
        "NO_STAKEHOLDER_ENGAGEMENT" in issue_codes,
        "Expected stakeholder warning absent",
    )
    require(
        "NO_STAKEHOLDER_ENGAGEMENT" in rendered,
        "Stakeholder warning not rendered",
    )


def validate_a3_blocked_presentation(
    template: str,
    payload: dict,
    presentation: dict,
) -> None:
    blocked = copy.deepcopy(payload)
    blocked["audit"]["publishable"] = False
    blocked["audit"]["assurance_level"] = "A3"
    blocked["audit"]["search_controls_satisfied"] = False
    blocked["audit"]["publication_issues"] = list(
        blocked["audit"].get("publication_issues", [])
    ) + [
        {
            "code": "MISSING_SEARCH_PEER_REVIEW",
            "severity": "error",
            "message": "Synthetic adversarial map presentation blocker.",
        }
    ]

    rendered = render(template, blocked, presentation)

    require(
        "GATE DE PUBLICAÇÃO DO MAPA NÃO APROVADO" in rendered,
        "A3-blocked map must show blocked top gate",
    )
    require(
        "**Gate de publicação do Mapa:** não aprovado" in rendered,
        "A3-blocked audit state must show gate not approved",
    )
    require(
        "A3 — revisão especializada independente" in rendered,
        "A3 must remain visible in blocked scenario",
    )
    require(
        "Assurance, inclusive A3, não substitui coverage, stage controls, classification controls nem CellScope"
        in rendered,
        "A3 non-bypass disclosure missing",
    )
    require(
        "MISSING_SEARCH_PEER_REVIEW" in rendered,
        "Synthetic gate blocker not rendered",
    )
    require(
        "Gate de publicação do Mapa: aprovado." not in rendered,
        "Blocked scenario incorrectly displays approved top gate",
    )
    require(
        "**Gate de publicação do Mapa:** aprovado" not in rendered,
        "Blocked scenario incorrectly displays approved audit gate",
    )


def validate_apparent_gap_presentation(
    template: str,
    payload: dict,
    presentation: dict,
) -> None:
    apparent = copy.deepcopy(payload)
    apparent["mapping_method"]["coverage_claim"] = "structured_non_exhaustive"
    apparent["mapping_method"]["gap_claim_mode"] = "apparent_only"
    apparent["audit"]["coverage_claim"] = "structured_non_exhaustive"
    apparent["audit"]["gap_claim_mode"] = "apparent_only"
    apparent["audit"]["required_assurance_level"] = "A2"
    apparent["audit"]["publication_issues"] = list(
        apparent["audit"].get("publication_issues", [])
    ) + [
        {
            "code": "NON_EXHAUSTIVE_MAP",
            "severity": "warning",
            "message": "Synthetic apparent-gap presentation scenario.",
        },
        {
            "code": "APPARENT_GAPS_ONLY",
            "severity": "warning",
            "message": "Synthetic apparent gaps only.",
        },
    ]

    for collection in ("cells", "gaps"):
        for cell in apparent.get(collection, []):
            if (
                cell.get("row_category_code") == "A"
                and cell.get("column_category_code") == "Z"
            ):
                cell["empty_cell_gap"] = False
                cell["apparent_gap"] = True

    rendered = render(template, apparent, presentation)

    require(
        "**Cobertura:** estruturada não exaustiva" in rendered,
        "Non-exhaustive coverage label missing",
    )
    require(
        "**Modo de gap:** gaps apenas aparentes" in rendered,
        "Apparent gap mode label missing",
    )
    require("**Gap aparente.**" in rendered, "Apparent-gap label missing")
    require(
        "Nenhuma unidade elegível foi localizada nas fontes consultadas" in rendered,
        "Apparent-gap scoped wording missing",
    )
    require(
        "Gap formal dentro do escopo definido." not in rendered,
        "Apparent scenario incorrectly claims formal gap",
    )
    require("NON_EXHAUSTIVE_MAP" in rendered, "Non-exhaustive warning missing")
    require("APPARENT_GAPS_ONLY" in rendered, "Apparent-gap warning missing")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--rendered", required=True)
    parser.add_argument("--presentation-map", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    rendered = Path(args.rendered).read_text(encoding="utf-8")
    presentation = json.loads(
        Path(args.presentation_map).read_text(encoding="utf-8")
    )

    validate_formal_synthetic(template, payload, rendered)
    validate_a3_blocked_presentation(template, payload, presentation)
    validate_apparent_gap_presentation(template, payload, presentation)

    print("F3-MAP-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
