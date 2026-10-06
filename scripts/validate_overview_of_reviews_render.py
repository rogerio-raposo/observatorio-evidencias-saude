#!/usr/bin/env python3
"""Structural, semantic and governance validation for OES Overview renders."""

from __future__ import annotations

import argparse
import copy
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def cluster(payload: dict) -> dict:
    clusters = payload.get("overlap", {}).get("clusters", [])
    require(len(clusters) == 1, "Expected one synthetic overlap cluster")
    return clusters[0]


def validate_formal(
    template: str,
    payload: dict,
    rendered: str,
) -> None:
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.overview_of_reviews.template/0.1" in template,
        "Overview template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.overview_of_reviews_view/0.1",
        "Unexpected OverviewOfReviewsView schema",
    )

    audit = payload["audit"]
    require(audit["synthetic_fixture"] is True, "Fixture must be explicitly synthetic")
    require(audit["publishable"] is True, "Formal fixture must be publishable")
    require(audit["assurance_level"] == "A3", "Formal fixture must derive A3")
    require(audit["required_assurance_level"] == "A3", "Formal fixture must require A3")
    require(audit["membership_complete"] is True, "Membership must be complete")
    require(audit["overlap_assessed"] is True, "Overlap must be assessed")
    require(audit["appraisal_complete"] is True, "Appraisal must be complete")
    require(audit["extraction_complete"] is True, "Extraction must be complete")
    require(audit["human_controls_satisfied"] is True, "Human controls must pass")
    require(audit["lineage_available"] is True, "Lineage must be available")
    require(audit["invalidated_dependencies"] is False, "Unexpected invalidated dependency")

    require(len(payload["review_items"]) == 3, "Expected three ReviewItems")
    require(len(payload["primary_study_membership"]) == 9, "Expected nine memberships")
    require(len(payload["appraisal"]) == 3, "Expected three ROBIS assessments")
    require(len(payload["outcome_evidence"]) == 3, "Expected three OutcomeEvidence rows")
    require(len(payload["concordance"]) == 1, "Expected one concordance assessment")
    require(len(payload["method"]["reviewer_assignments"]) == 7, "Expected seven reviewer assignments")
    require(len(payload["method"]["quality_controls"]) == 4, "Expected four quality controls")
    require(len(payload["searches"]) == 2, "Expected two Searches")
    require(len(payload["excluded_full_text"]) == 1, "Expected one full-text exclusion")
    require(len(payload["report_lineage"]) == 1, "Expected one Report lineage relation")
    require(len(payload["lineage"]) == 6, "Expected six dependency lineage edges")
    require(len(payload["references"]) == 4, "Expected four references")

    cl = cluster(payload)
    metrics = cl["metrics"]
    require(metrics["review_count"] == 3, "Expected three Reviews in overlap cluster")
    require(metrics["study_occurrence_count"] == 9, "Expected nine Study occurrences")
    require(metrics["unique_primary_study_count"] == 5, "Expected five unique primary Studies")
    require(metrics["redundant_occurrence_count"] == 4, "Expected four redundant occurrences")
    require(metrics["membership_completeness"] == "complete", "Expected complete membership")
    require(metrics["cca_calculable"] is True, "CCA must be calculable")
    require(abs(float(metrics["cca"]) - 0.4) < 1e-9, "Expected CCA 0.4")

    pairwise = cl["pairwise"]
    require(len(pairwise) == 3, "Expected three pairwise overlap rows")
    jaccards = sorted(round(float(x["jaccard"]), 6) for x in pairwise)
    require(jaccards == [0.2, 0.5, 0.5], f"Unexpected pairwise Jaccards: {jaccards}")

    prioritized = [
        x for x in cl["members"] if x["analysis_disposition"] == "prioritized"
    ]
    require(
        len(prioritized) == 1
        and prioritized[0]["review_item_uuid"]
        == "f9500000-0000-0000-0000-000000000102",
        "Review B must remain uniquely prioritized",
    )

    lineage = payload["report_lineage"][0]
    require(lineage["review_study_id"] == "OES-ST-2026-001501", "Wrong Review A lineage")
    require(lineage["source_report_id"] == "OES-R-2026-001502", "Wrong update source")
    require(lineage["target_report_id"] == "OES-R-2026-001501", "Wrong update target")
    require(lineage["relation_type"] == "update_of", "Expected update_of relation")

    high_robis = [x for x in payload["appraisal"] if x["overall_judgement"] == "high"]
    require(len(high_robis) == 1, "Expected one high ROBIS Review")

    certainty_count = sum(
        1 for x in payload["outcome_evidence"] if x.get("certainty") is not None
    )
    require(certainty_count == 2, "Expected two OutcomeEvidence certainty records")

    require(
        payload["excluded_full_text"][0]["exclusion_reason"]
        == "Not a systematic review",
        "Expected synthetic full-text exclusion reason",
    )

    for search in payload["searches"]:
        export = search.get("export_artifact") or {}
        require(export.get("storage_key"), "Search export storage key missing")
        require(export.get("content_hash"), "Search export hash missing")
        require(export.get("hash_algorithm"), "Search export hash algorithm missing")

    for oe in payload["outcome_evidence"]:
        require(len(oe.get("source_reports", [])) == 1, "OutcomeEvidence source report missing")
        require(len(oe.get("provenance", [])) == 1, "OutcomeEvidence provenance missing")

    for value in [
        payload["identity"]["title"],
        payload["identity"]["product_id"],
        payload["question"]["normalized_text"],
        payload["conclusion"]["text"],
        payload["limitations"]["summary"],
        payload["protocol"]["storage_key"],
        "Synthetic Review B",
        "Not a systematic review",
        "OES-R-2026-001502",
        "OES-R-2026-001501",
    ]:
        require(value and value in rendered, f"Required rendered value missing: {value!r}")

    require(
        "FIXTURE SINTÉTICA — NÃO REPRESENTA OVERVIEW REAL" in rendered,
        "Synthetic Overview banner missing",
    )
    require(
        "Gate de publicação do Overview: aprovado." in rendered,
        "Approved Overview gate banner missing",
    )
    require(
        "**Gate de publicação do Overview:** aprovado" in rendered,
        "Approved audit gate state missing",
    )
    require(
        "Reviews sobrepostas não constituem observações independentes" in rendered,
        "Overlap epistemic warning missing",
    )
    require(
        "CCA e pairwise overlap descrevem redundância estrutural" in rendered,
        "CCA epistemic warning missing",
    )
    require(
        "ROBIS, certainty e currentness são dimensões distintas" in rendered,
        "ROBIS/certainty/currentness warning missing",
    )
    require("CCA: **0.4**" in rendered, "CCA 0.4 not rendered")
    require(
        "Nenhuma nova reanálise quantitativa do Overview foi executada." in rendered,
        "No-reanalysis disclosure missing",
    )
    require(
        "Certainty não reportada / não disponível para este OutcomeEvidence." in rendered,
        "Missing-certainty disclosure absent",
    )
    require(
        "update_of" in rendered,
        "Review update lineage is not rendered",
    )
    require(
        "alto risco" in rendered,
        "High ROBIS label is not rendered",
    )


def validate_a3_blocked(template: str, payload: dict, presentation: dict) -> None:
    blocked = copy.deepcopy(payload)
    blocked["audit"]["publishable"] = False
    blocked["audit"]["assurance_level"] = "A3"
    blocked["audit"]["publication_issues"] = list(
        blocked["audit"].get("publication_issues", [])
    ) + [{
        "code": "MISSING_OVERLAP_CONTROL",
        "severity": "error",
        "message": "Synthetic presentation blocker.",
    }]

    rendered = render(template, blocked, presentation)
    require(
        "GATE DE PUBLICAÇÃO DO OVERVIEW NÃO APROVADO" in rendered,
        "A3-blocked scenario must show blocked top gate",
    )
    require(
        "**Gate de publicação do Overview:** não aprovado" in rendered,
        "A3-blocked audit state missing",
    )
    require(
        "A3 — revisão especializada independente" in rendered,
        "A3 must remain visible in blocked scenario",
    )
    require(
        "MISSING_OVERLAP_CONTROL" in rendered,
        "Synthetic blocker not rendered",
    )
    require(
        "Gate de publicação do Overview: aprovado." not in rendered,
        "Blocked scenario incorrectly shows approved gate",
    )


def validate_incomplete_membership(
    template: str, payload: dict, presentation: dict
) -> None:
    p = copy.deepcopy(payload)
    p["audit"]["publishable"] = False
    p["audit"]["membership_complete"] = False
    p["review_items"][2]["membership_completeness"] = "partial"

    cl = cluster(p)
    cl["metrics"]["membership_completeness"] = "partial"
    cl["metrics"]["cca"] = None
    cl["metrics"]["cca_calculable"] = False
    p["audit"]["publication_issues"] = list(
        p["audit"].get("publication_issues", [])
    ) + [{
        "code": "INCOMPLETE_MEMBERSHIP",
        "severity": "error",
        "message": "Synthetic incomplete membership.",
    }]

    rendered = render(template, p, presentation)
    require("parcial" in rendered, "Partial membership label missing")
    require(
        "CCA não calculável com a membership disponível." in rendered,
        "Non-calculable CCA disclosure missing",
    )
    require("INCOMPLETE_MEMBERSHIP" in rendered, "Membership blocker missing")
    require("CCA: **0.4**" not in rendered, "Renderer retained stale CCA")


def validate_certainty_absent(
    template: str, payload: dict, presentation: dict
) -> None:
    p = copy.deepcopy(payload)
    target = next(
        x for x in p["outcome_evidence"]
        if x["review_item_uuid"] == "f9500000-0000-0000-0000-000000000102"
    )
    target["certainty"] = None
    target["certainty_assessment_version_uuid"] = None

    rendered = render(template, p, presentation)
    require(
        rendered.count(
            "Certainty não reportada / não disponível para este OutcomeEvidence."
        ) >= 2,
        "Missing certainty must be disclosed, not defaulted",
    )
    require(
        "low certainty" not in rendered.lower(),
        "Renderer invented low certainty",
    )


def validate_not_comparable(
    template: str, payload: dict, presentation: dict
) -> None:
    p = copy.deepcopy(payload)
    p["concordance"][0]["state"] = "not_comparable"
    p["concordance"][0]["rationale"] = (
        "Synthetic reviews differ materially in scope and cannot be compared."
    )

    rendered = render(template, p, presentation)
    require("não comparável" in rendered, "Not-comparable state missing")
    require(
        "Synthetic reviews differ materially in scope and cannot be compared."
        in rendered,
        "Not-comparable rationale missing",
    )
    require(
        " é superior a " not in rendered.lower(),
        "Renderer invented superiority statement",
    )


def validate_invalidated_dependency(
    template: str, payload: dict, presentation: dict
) -> None:
    p = copy.deepcopy(payload)
    p["audit"]["publishable"] = False
    p["audit"]["invalidated_dependencies"] = True
    p["invalidated_dependencies_detail"] = [{
        "source_version_uuid": "00000000-0000-0000-0000-000000000001",
        "source_entity_id": "OES-ST-SYN-INVALID",
        "source_entity_type": "Study",
        "target_version_uuid": p["identity"]["product_version_uuid"],
        "target_entity_id": p["identity"]["product_id"],
        "target_entity_type": "Product",
        "dependency_type": "synthetic_dependency",
        "derivation_rule": "Synthetic render validation.",
        "dependency_status": "active",
        "source_invalidated": True,
        "invalidation_records": [{
            "provenance_uuid": "00000000-0000-0000-0000-000000000002",
            "field_path": "synthetic",
            "invalidation_reason": "Synthetic invalidation.",
            "invalidated_at": "2026-10-06T14:00:00-03:00",
        }],
    }]
    p["audit"]["publication_issues"] = list(
        p["audit"].get("publication_issues", [])
    ) + [{
        "code": "INVALIDATED_DEPENDENCY",
        "severity": "error",
        "message": "Synthetic invalidated dependency.",
    }]

    rendered = render(template, p, presentation)
    require(
        "GATE DE PUBLICAÇÃO DO OVERVIEW NÃO APROVADO" in rendered,
        "Invalidated dependency must block gate",
    )
    require(
        "OES-ST-SYN-INVALID" in rendered,
        "Invalidated dependency detail missing",
    )
    require(
        "INVALIDATED_DEPENDENCY" in rendered,
        "Invalidated dependency blocker missing",
    )
    require(
        "A3 — revisão especializada independente" in rendered,
        "A3 must remain visible despite invalidated dependency",
    )


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

    validate_formal(template, payload, rendered)
    validate_a3_blocked(template, payload, presentation)
    validate_incomplete_membership(template, payload, presentation)
    validate_certainty_absent(template, payload, presentation)
    validate_not_comparable(template, payload, presentation)
    validate_invalidated_dependency(template, payload, presentation)

    print("F3-OVERVIEW-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
