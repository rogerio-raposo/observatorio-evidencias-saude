#!/usr/bin/env python3
"""Structural and semantic validation for OES Evidence Monitor renders."""

from __future__ import annotations

import argparse
import copy
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def latest_completed_candidate(payload: dict) -> dict:
    cycles = payload.get("cycles", [])
    completed = [c for c in cycles if c.get("execution", {}).get("status") == "completed"]
    require(completed, "Expected at least one completed cycle")
    latest = sorted(completed, key=lambda x: int(x.get("cycle_no", 0)))[-1]
    candidates = latest.get("candidates", [])
    require(candidates, "Expected candidates in latest completed cycle")
    multi = [c for c in candidates if len(c.get("impacts", [])) >= 2]
    require(multi, "Expected one multi-impact candidate")
    return multi[0]


def validate_m2(template: str, payload: dict, rendered: str) -> None:
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.evidence_monitor.template/0.1" in template,
        "Evidence Monitor template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.evidence_monitor_view/0.1",
        "Unexpected EvidenceMonitorView schema",
    )

    audit = payload["audit"]
    require(audit["synthetic_fixture"] is True, "M2 fixture must be synthetic")
    require(audit["publishable"] is True, "M2 fixture must be publishable")
    require(audit["assurance_level"] == "A2", "M2 Monitor must derive A2")
    require(audit["target_assurance_level"] == "A0", "M2 target must remain A0")
    require(audit["required_assurance_level"] == "A2", "M2 must require A2")
    require(audit["monitor_operational_status"] == "active", "Monitor must be active")
    require(audit["monitor_currency_status"] == "current", "Monitor currency must be current")
    require(
        audit["target_currency_status"] == "under_evaluation",
        "Target currency must be under_evaluation",
    )
    require(audit["maintenance_level"] == "M2", "Expected M2")
    require(
        audit["baseline_evidence_cutoff_date"] == "2026-10-01",
        "Unexpected M2 baseline cutoff",
    )
    require(
        audit["latest_completed_cycle_cutoff_date"] == "2026-10-06",
        "Unexpected latest completed cycle cutoff",
    )
    require(audit["required_source_coverage_satisfied"] is True, "Coverage must pass")
    require(
        len(audit.get("projection_hardening_issues", [])) == 0,
        "Valid M2 fixture must have zero projection hardening errors",
    )

    require(payload["identity"]["editorial_status"] == "published", "M2 must be published")
    require(payload["operational_state"]["status"] == "active", "Operational state mismatch")
    require(payload["monitor_currency"]["status"] == "current", "Monitor currentness mismatch")
    require(payload["target"]["target_type"] == "product_version", "M2 target must be ProductVersion")
    require(payload["target"]["currency"]["status"] == "under_evaluation", "Target currency mismatch")
    require(len(payload["cycles"]) == 2, "Expected two M2 cycles")
    require(payload["latest_completed_cycle"]["cycle_no"] == 2, "Cycle 2 must be latest completed")
    require(len(payload["monitor_plan"]["source_requirements"]) == 3, "Expected 3 source requirements")

    lc = payload["latest_completed_cycle"]
    require(len(lc.get("searches", [])) == 1, "Expected one Search in latest completed cycle")
    require(
        len(lc["searches"][0].get("search_hits", [])) == 1,
        "Expected one SearchHit in latest completed cycle",
    )
    require(len(lc.get("events", [])) == 1, "Expected one EvidenceEvent")
    require(
        lc["events"][0]["event_type"] == "regulatory_update",
        "Expected regulatory EvidenceEvent",
    )
    require(
        lc["verification"]["status"] == "ai_verified"
        and lc["verification"]["verifier_actor_type"] == "ai_system",
        "Latest completed cycle must remain AI verified",
    )

    candidate = latest_completed_candidate(payload)
    impacts = {x["impact_class"]: x for x in candidate["impacts"]}
    require(candidate["primary_impact_class"] == "quantitative", "Primary impact must be quantitative")
    require("quantitative" in impacts and impacts["quantitative"]["is_primary"] is True, "Primary impact row missing")
    require("certainty" in impacts and impacts["certainty"]["is_primary"] is False, "Secondary certainty impact missing")

    require(
        any(c.get("primary_impact_class") == "applicability" for c in lc.get("candidates", [])),
        "Expected applicability candidate from event",
    )

    issue_codes = {x["code"] for x in audit.get("publication_issues", [])}
    for code in [
        "TARGET_CURRENCY_UNDER_EVALUATION",
        "ALERT_EVALUATION_RECOMMENDED",
        "NO_EXPERT_REVIEW_OF_MONITOR",
    ]:
        require(code in issue_codes, f"Expected M2 warning missing: {code}")

    for value in [
        payload["identity"]["title"],
        payload["identity"]["product_id"],
        payload["question"]["normalized_text"],
        payload["target"]["target_product_id"],
        lc["searches"][0]["oes_search_id"],
        lc["searches"][0]["search_hits"][0]["raw_title"],
        "M2 — monitoramento ativo",
        "Verificado por IA",
        "Quantitativo",
        "Certeza",
        "Aplicabilidade",
    ]:
        require(value and value in rendered, f"Required rendered value missing: {value!r}")

    require(
        "FIXTURE SINTÉTICA — NÃO REPRESENTA MONITOR REAL" in rendered,
        "Synthetic Monitor banner missing",
    )
    require(
        "Gate formal do Monitor: aprovado." in rendered,
        "Approved Monitor gate missing",
    )
    require(
        "Monitor currentness e target scientific currentness são estados distintos"
        in rendered,
        "Currentness separation warning missing",
    )
    require(
        "Uma exceção metodológica não equivale à execução da fonte dispensada"
        in rendered,
        "Exception epistemic warning missing",
    )
    require(
        "Nenhum issue de projection hardening ativo." in rendered,
        "Hardening PASS disclosure missing",
    )


def validate_m3(template: str, payload: dict, presentation: dict) -> None:
    require(payload["target"]["target_type"] == "investigation_version", "M3 target must be InvestigationVersion")
    require(payload["audit"]["publishable"] is False, "M3 fixture must be blocked")
    require(payload["audit"]["maintenance_level"] == "M3", "Expected M3 maintenance level")
    require(payload["target"].get("assurance_level") is None, "Investigation target cannot invent assurance")
    require(payload["target"].get("currency") is None, "Investigation target cannot invent Product currency")
    require(payload["target"].get("scientific_conclusion") is None, "Investigation target cannot invent Product conclusion")

    codes = {x["code"] for x in payload["audit"].get("publication_issues", [])}
    require(
        "M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL" in codes,
        "M3 Phase-4 blocker missing",
    )

    rendered = render(template, payload, presentation)
    require(
        "GATE FORMAL DO MONITOR NÃO APROVADO" in rendered,
        "Blocked M3 gate missing",
    )
    require(
        "M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL" in rendered,
        "M3 blocker code not rendered",
    )
    require(
        "M3 — evidência viva" in rendered,
        "M3 presentation label missing",
    )


def validate_exception_scenario(template: str, payload: dict, presentation: dict) -> None:
    p = copy.deepcopy(payload)
    statuses = p["latest_completed_cycle"]["source_requirement_status"]
    require(statuses, "Need at least one source requirement status")
    row = statuses[0]
    row["fulfilled"] = False
    row["exception_applied"] = True
    row["satisfied"] = True
    row["exception_method_decision_uuid"] = "00000000-0000-0000-0000-000000000175"

    cycles = p["cycles"]
    latest_no = p["latest_completed_cycle"]["cycle_no"]
    for cycle in cycles:
        if cycle["cycle_no"] == latest_no:
            cycle["source_requirement_status"] = copy.deepcopy(statuses)

    rendered = render(template, p, presentation)
    require(
        "cumprido por exceção metodológica documentada" in rendered,
        "Exception disclosure missing",
    )
    require(
        "não" in rendered and "sim" in rendered,
        "Fulfilled/exception boolean distinction not rendered",
    )


def validate_running_latest_cycle(template: str, payload: dict, presentation: dict) -> None:
    p = copy.deepcopy(payload)
    running = copy.deepcopy(p["latest_completed_cycle"])
    running["cycle_uuid"] = "00000000-0000-0000-0000-000000000176"
    running["cycle_no"] = int(running["cycle_no"]) + 1
    running["execution"]["status"] = "running"
    running["execution"]["completed_at"] = None
    running["execution"]["completeness_status"] = "not_assessed"
    running["maintenance_decision"]["decision"] = None
    running["maintenance_decision"]["rationale"] = None
    running["resulting_target_currency"] = None
    p["latest_cycle"] = running
    p["cycles"] = list(p["cycles"]) + [running]

    rendered = render(template, p, presentation)
    require(
        "Latest cycle ainda não possui conclusão terminal; não inferir decisão final."
        in rendered,
        "Running-cycle non-final disclosure missing",
    )
    require(
        str(payload["latest_completed_cycle"]["cycle_no"]) in rendered,
        "Latest completed cycle disappeared when latest cycle is running",
    )


def validate_ai_not_human(rendered: str) -> None:
    require("Verificado por IA" in rendered, "AI verification label missing")
    low = rendered.lower()
    require(
        "revisão especializada independente realizada" not in low,
        "Renderer invented expert review",
    )
    require(
        "verificação humana realizada" not in low,
        "Renderer invented human verification",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input-m2", required=True)
    parser.add_argument("--input-m3", required=True)
    parser.add_argument("--rendered-m2", required=True)
    parser.add_argument("--presentation-map", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    m2 = json.loads(Path(args.input_m2).read_text(encoding="utf-8"))
    m3 = json.loads(Path(args.input_m3).read_text(encoding="utf-8"))
    rendered_m2 = Path(args.rendered_m2).read_text(encoding="utf-8")
    presentation = json.loads(Path(args.presentation_map).read_text(encoding="utf-8"))

    validate_m2(template, m2, rendered_m2)
    validate_m3(template, m3, presentation)
    validate_exception_scenario(template, m2, presentation)
    validate_running_latest_cycle(template, m2, presentation)
    validate_ai_not_human(rendered_m2)

    print("F3-MONITOR-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
