#!/usr/bin/env python3
"""Validate OES Evidence Alert template rendering against canonical fixtures."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def render_payload(template: str, payload: dict, presentation: dict) -> str:
    out = render(template, payload, presentation)
    require("{{" not in out and "}}" not in out, "Unresolved template token remains")
    return out


def require_codes(payload: dict, *codes: str) -> None:
    present = {
        item.get("code")
        for item in payload.get("audit", {}).get("publication_issues", [])
    }
    for code in codes:
        require(code in present, f"Expected publication issue missing: {code}")


def validate_a(template: str, payload: dict, presentation: dict, rendered: str) -> None:
    require(payload["schema_version"] == "oes.evidence_alert_view/0.1", "A schema mismatch")
    require(payload["audit"]["synthetic_fixture"] is True, "A must be synthetic")
    require(payload["audit"]["publishable"] is True, "A must be publishable")
    require(payload["audit"]["assurance_level"] == "A2", "A Alert assurance must be A2")
    require(payload["audit"]["target_assurance_level"] == "A0", "A target must remain A0")
    require(payload["alert"]["classification"] == "relevant", "A classification mismatch")
    require(payload["alert"]["reassessment_priority"] == "priority", "A priority mismatch")
    require(payload["alert"]["lifecycle_status"] == "evaluation", "A lifecycle mismatch")
    require(payload["alert"]["verification"]["status"] == "human_verified", "A must be human verified")
    require(payload["alert"]["verification"]["verifier_actor_type"] == "human_reviewer", "A verifier type mismatch")
    require(payload["target"]["target_type"] == "product_version", "A target type mismatch")
    require(payload["target"]["currency"]["status"] == "under_evaluation", "A target currency mismatch")
    require(payload["target"]["assurance_level"] == "A0", "A target assurance mismatch")
    require(len(payload["sources"]) == 2, "A must expose both primary and supporting sources")
    require(payload["sources"][0]["source_role"] == "primary", "A primary source ordering mismatch")
    require(payload["sources"][0]["source_type"] == "candidate_assessment", "A primary source type mismatch")
    require(payload["sources"][1]["source_type"] == "evidence_event", "A supporting event missing")
    require(len(payload["affected_dimensions"]) == 2, "A dimensions must remain multiple")
    require(
        {d["dimension_code"] for d in payload["affected_dimensions"]}
        == {"conclusion", "certainty"},
        "A affected dimensions mismatch",
    )
    require(len(payload["audit"]["projection_hardening_issues"]) == 0, "A hardening errors present")
    require_codes(
        payload,
        "NO_EXPERT_REVIEW_OF_ALERT",
        "TARGET_CURRENCY_UNDER_EVALUATION",
        "TARGET_ASSURANCE_BELOW_A2",
    )

    expected = [
        "FIXTURE SINTÉTICA — NÃO REPRESENTA ALERTA REAL",
        "Gate formal do Alerta: aprovado.",
        "Relevante",
        "Prioridade",
        "Em avaliação",
        "Verificado por humano",
        "A2 — IA verificada + aprovação de governança",
        "A0 — não verificada",
        "CandidateAssessment",
        "EvidenceEvent",
        "Conclusão",
        "Certeza",
        "NO_EXPERT_REVIEW_OF_ALERT",
        "TARGET_CURRENCY_UNDER_EVALUATION",
        "TARGET_ASSURANCE_BELOW_A2",
        "Nenhum issue de projection hardening ativo.",
        "O Alerta não possui currentness científico próprio.",
    ]
    for value in expected:
        require(value in rendered, f"A required render content missing: {value}")

    regenerated = render_payload(template, payload, presentation)
    require(regenerated == rendered, "A render is not deterministic")


def validate_b(template: str, payload: dict, presentation: dict) -> None:
    require(payload["identity"]["editorial_status"] == "under_review", "B editorial status mismatch")
    require(payload["alert"]["verification"]["status"] == "ai_verified", "B must remain AI verified")
    require(payload["audit"]["assurance_level"] == "A1", "B must remain A1")
    require(payload["audit"]["publishable"] is False, "B must remain blocked")
    require_codes(payload, "MISSING_HUMAN_VERIFICATION", "ASSURANCE_BELOW_A2")

    rendered = render_payload(template, payload, presentation)
    for value in [
        "GATE FORMAL DO ALERTA NÃO APROVADO",
        "Verificado por IA",
        "A1 — verificação metodológica por IA",
        "MISSING_HUMAN_VERIFICATION",
        "ASSURANCE_BELOW_A2",
    ]:
        require(value in rendered, f"B required render content missing: {value}")
    require("Verificado por humano" not in rendered, "B invented human verification")


def validate_c(template: str, payload: dict, presentation: dict) -> None:
    require(payload["alert"]["classification"] == "critical", "C must remain critical")
    require(payload["alert"]["reassessment_priority"] == "urgent", "C must remain urgent")
    require(payload["target"]["target_type"] == "investigation_version", "C target type mismatch")
    require(payload["target"]["assurance_level"] is None, "C invented Product assurance")
    require(payload["target"]["currency"] is None, "C invented Product currency")
    require(payload["target"]["scientific_conclusion"] is None, "C invented Product conclusion")
    require(payload["sources"][0]["source_type"] == "uri", "C direct URI source missing")
    require(payload["audit"]["publishable"] is True, "C formal gate should pass")
    require_codes(payload, "ALERT_SOURCE_OUTSIDE_MONITOR", "CRITICAL_WITHOUT_EXPERT_REVIEW")

    rendered = render_payload(template, payload, presentation)
    for value in [
        "Crítico",
        "Urgente",
        "InvestigationVersion",
        "URI direta",
        "ALERT_SOURCE_OUTSIDE_MONITOR",
        "CRITICAL_WITHOUT_EXPERT_REVIEW",
        "nenhum prazo/SLA",
        "não cria auto-update",
        "Assurance de Product: não aplicável",
        "Currentness de Product: não aplicável",
        "Conclusão de Product: não aplicável",
    ]:
        require(value in rendered, f"C required render content missing: {value}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input-a", required=True)
    parser.add_argument("--input-b", required=True)
    parser.add_argument("--input-c", required=True)
    parser.add_argument("--rendered-a", required=True)
    parser.add_argument("--presentation-map", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    presentation = json.loads(Path(args.presentation_map).read_text(encoding="utf-8"))
    a = json.loads(Path(args.input_a).read_text(encoding="utf-8"))
    b = json.loads(Path(args.input_b).read_text(encoding="utf-8"))
    c = json.loads(Path(args.input_c).read_text(encoding="utf-8"))
    rendered_a = Path(args.rendered_a).read_text(encoding="utf-8")

    validate_a(template, a, presentation, rendered_a)
    validate_b(template, b, presentation)
    validate_c(template, c, presentation)

    print("F3-ALERT-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
