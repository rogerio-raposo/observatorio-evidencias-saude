-- F4 Integrated Operational Control synthetic fixtures
-- Requires migrations through 029 + F3 Monitor/Alert + F4 update fixtures.
-- All SLA durations below are TEST-ONLY synthetic values, never normative defaults.
-- Date: 2026-10-07

BEGIN;

-- ---------------------------------------------------------------------------
-- Complete existing Alert-derived signal 3 into a scientific update workflow.
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.update_triage(
    update_triage_uuid,update_signal_uuid,disposition,rationale,
    triaged_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    authority_status,triaged_at
) VALUES (
    'f5000000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000003',
    'accepted_for_materiality',
    'Synthetic accepted triage for integrated operational-control validation',
    'fixture-reviewer','human_reviewer','human_verified',
    'fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:33:00+00',
    'authoritative',TIMESTAMPTZ '2026-10-07 00:32:00+00'
);

INSERT INTO maintenance.materiality_assessment(
    materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
    assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
    'f4310000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000003',
    'potentially_material',
    'Synthetic Alert-derived signal warrants incremental scientific update',
    'fixture-reviewer','human_reviewer','human_verified',
    'fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:37:00+00',
    TIMESTAMPTZ '2026-10-07 00:36:00+00'
);

INSERT INTO maintenance.materiality_dimension(
    materiality_assessment_uuid,dimension_code,dimension_status,rationale,sequence_no
) VALUES (
    'f4310000-0000-0000-0000-000000000001',
    'magnitude','potential',
    'Synthetic potential magnitude change for operational-control fixture',1
);

INSERT INTO maintenance.update_decision(
    update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
    decision_type,authority_status,currency_action,rationale,
    decided_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
    'f4410000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000003',
    'f4310000-0000-0000-0000-000000000001',
    'scientific_update_incremental','authoritative','no_change',
    'Open an incremental scientific workflow without inferring a new CurrencyState',
    'fixture-reviewer','human_reviewer','human_verified',
    'fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:41:00+00',
    TIMESTAMPTZ '2026-10-07 00:40:00+00'
);

INSERT INTO maintenance.priority_assessment(
    priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
    stage,response_class,authority_scope,authority_status,feasibility_status,
    triage_uuid,materiality_assessment_uuid,update_decision_uuid,
    alert_product_version_uuid,update_risk_profile_uuid,
    risk_profile_snapshot,dependency_snapshot,rationale,
    assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
    'f5100000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000003',
    'f4000000-0000-0000-0000-000000000001',
    'update_decision','expedited','scientific','authoritative','adequate',
    'f5000000-0000-0000-0000-000000000001',
    'f4310000-0000-0000-0000-000000000001',
    'f4410000-0000-0000-0000-000000000001',
    'a7100000-0000-0000-0000-000000000001',
    'f6000000-0000-0000-0000-000000000001',
    maintenance.update_risk_profile_snapshot(
      'f6000000-0000-0000-0000-000000000001'
    ),
    '{"reach":"broad","fixture":true}'::jsonb,
    'Potential materiality plus high conclusion sensitivity supports expedited response',
    'fixture-reviewer','human_reviewer','human_verified',
    'fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:42:30+00',
    TIMESTAMPTZ '2026-10-07 00:42:00+00'
);

INSERT INTO maintenance.priority_basis(
    priority_assessment_uuid,basis_code,basis_effect,basis_value,
    source_type,materiality_assessment_uuid,rationale,sequence_no
) VALUES (
    'f5100000-0000-0000-0000-000000000001',
    'materiality','strong_modifier','potentially_material',
    'materiality_assessment','f4310000-0000-0000-0000-000000000001',
    'Qualified materiality input',1
);

INSERT INTO maintenance.priority_basis(
    priority_assessment_uuid,basis_code,basis_effect,basis_value,
    source_type,update_risk_profile_uuid,rationale,sequence_no
) VALUES (
    'f5100000-0000-0000-0000-000000000001',
    'conclusion_sensitivity','dominance_floor','high',
    'risk_profile','f6000000-0000-0000-0000-000000000001',
    'High conclusion sensitivity plus potentially material signal sets expedited floor',2
);

-- ---------------------------------------------------------------------------
-- Escalation example: active scientific-materiality route.
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.escalation_case(
    escalation_case_uuid,update_signal_uuid,priority_assessment_uuid,
    status,opened_at,activated_at,opened_by,actor_type,
    activated_by,activation_actor_type
) VALUES (
    'f5200000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000003',
    'f5100000-0000-0000-0000-000000000001',
    'active',TIMESTAMPTZ '2026-10-07 00:43:00+00',
    TIMESTAMPTZ '2026-10-07 00:44:00+00',
    'fixture-system','system','fixture-owner','owner'
);

INSERT INTO maintenance.escalation_reason(
    escalation_case_uuid,reason_code,rationale,source_payload,sequence_no
) VALUES (
    'f5200000-0000-0000-0000-000000000001',
    'scientific_materiality',
    'Synthetic escalation to coordinate qualified review',
    '{"fixture":true}'::jsonb,1
);

INSERT INTO maintenance.escalation_route(
    escalation_case_uuid,route_code,route_status,
    assigned_to,assigned_actor_type,requested_at,sequence_no
) VALUES (
    'f5200000-0000-0000-0000-000000000001',
    'qualified_scientific_review','requested',
    'fixture-reviewer','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:44:00+00',1
);

-- ---------------------------------------------------------------------------
-- Synthetic test calendar and SLA rules are loaded by
-- f4-temporal-calibration-sla-fixtures.sql under temporal v0.1.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Workflow round and milestones.
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.workflow_round(
    workflow_round_uuid,update_signal_uuid,update_decision_uuid,
    round_type,round_no,target_product_version_uuid,status,
    opened_at,rationale,created_by,actor_type
) VALUES (
    'f5500000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000003',
    'f4410000-0000-0000-0000-000000000001',
    'scientific_update',1,
    'e5100000-0000-0000-0000-000000000003',
    'planned',TIMESTAMPTZ '2026-10-07 00:41:00+00',
    'Synthetic incremental scientific workflow round',
    'fixture-owner','owner'
);

WITH res AS (
  SELECT * FROM maintenance.resolve_sla_rule(
    'f4100000-0000-0000-0000-000000000003',
    'SLA1_DETECTION_TO_TRIAGE',NULL,'triage'
  )
)
INSERT INTO maintenance.sla_instance(
    sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
    update_triage_uuid,start_priority_assessment_uuid,
    clock_code,endpoint_type,time_basis,rule_snapshot_payload,
    due_calculation_payload,source_detected_at,start_at,nominal_due_at,end_at,
    execution_status,satisfied_at
)
SELECT
    'f5600000-0000-0000-0000-000000000001',
    'f56f0000-0000-0000-0000-000000000001',
    res.sla_rule_uuid,
    'f4100000-0000-0000-0000-000000000003',
    'f5000000-0000-0000-0000-000000000001',
    res.start_priority_assessment_uuid,
    'SLA1_DETECTION_TO_TRIAGE','triage','elapsed_time',
    maintenance.sla_rule_snapshot(
      res.sla_rule_uuid,'f4100000-0000-0000-0000-000000000003',
      res.contractual_start_at,res.selection_trace
    ),
    maintenance.sla_due_calculation_payload(
      res.sla_rule_uuid,'f4100000-0000-0000-0000-000000000003',
      res.raw_causal_start_at,res.contractual_start_at,
      TIMESTAMPTZ '2026-10-07 00:30:00+00'
    ),
    res.raw_causal_start_at,
    res.contractual_start_at,
    maintenance.sla_nominal_due_at(res.sla_rule_uuid,res.contractual_start_at),
    TIMESTAMPTZ '2026-10-07 00:32:00+00',
    'satisfied',TIMESTAMPTZ '2026-10-07 00:32:00+00'
FROM res
WHERE res.resolution_status='selected';

WITH res AS (
  SELECT * FROM maintenance.resolve_sla_rule(
    'f4100000-0000-0000-0000-000000000003',
    'SLA4_DECISION_TO_WORKFLOW_START',
    'f5500000-0000-0000-0000-000000000001',
    'workflow_started'
  )
)
INSERT INTO maintenance.sla_instance(
    sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
    update_decision_uuid,workflow_round_uuid,start_priority_assessment_uuid,
    clock_code,endpoint_type,time_basis,rule_snapshot_payload,
    due_calculation_payload,start_at,nominal_due_at,execution_status
)
SELECT
    'f5600000-0000-0000-0000-000000000004',
    'f56f0000-0000-0000-0000-000000000004',
    res.sla_rule_uuid,
    'f4100000-0000-0000-0000-000000000003',
    'f4410000-0000-0000-0000-000000000001',
    'f5500000-0000-0000-0000-000000000001',
    res.start_priority_assessment_uuid,
    'SLA4_DECISION_TO_WORKFLOW_START','workflow_started','elapsed_time',
    maintenance.sla_rule_snapshot(
      res.sla_rule_uuid,'f4100000-0000-0000-0000-000000000003',
      res.contractual_start_at,res.selection_trace
    ),
    maintenance.sla_due_calculation_payload(
      res.sla_rule_uuid,'f4100000-0000-0000-0000-000000000003',
      res.raw_causal_start_at,res.contractual_start_at,
      TIMESTAMPTZ '2026-10-07 00:41:00+00'
    ),
    res.contractual_start_at,
    maintenance.sla_nominal_due_at(res.sla_rule_uuid,res.contractual_start_at),
    'running'
FROM res
WHERE res.resolution_status='selected';

INSERT INTO maintenance.workflow_milestone(
    workflow_milestone_uuid,workflow_round_uuid,milestone_type,adapter_type,
    time_precision,occurred_at,qualified_at,authority_status,
    actor,actor_type,rationale
) VALUES (
    'f5800000-0000-0000-0000-000000000001',
    'f5500000-0000-0000-0000-000000000001',
    'scientific_workflow_started','native_event','timestamp',
    TIMESTAMPTZ '2026-10-07 00:45:00+00',
    TIMESTAMPTZ '2026-10-07 00:45:00+00',
    'authoritative','fixture-reviewer','human_reviewer',
    'Synthetic qualified start of scientific work'
);

UPDATE maintenance.workflow_round
   SET status='active'
 WHERE workflow_round_uuid='f5500000-0000-0000-0000-000000000001';

UPDATE maintenance.sla_instance
   SET execution_status='satisfied',
       end_at=TIMESTAMPTZ '2026-10-07 00:45:00+00',
       satisfied_at=TIMESTAMPTZ '2026-10-07 00:45:00+00'
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000004';

WITH res AS (
  SELECT * FROM maintenance.resolve_sla_rule(
    'f4100000-0000-0000-0000-000000000003',
    'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',
    'f5500000-0000-0000-0000-000000000001',
    'scientific_completed'
  )
)
INSERT INTO maintenance.sla_instance(
    sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
    workflow_round_uuid,start_priority_assessment_uuid,
    clock_code,endpoint_type,time_basis,rule_snapshot_payload,
    due_calculation_payload,start_at,nominal_due_at,execution_status
)
SELECT
    'f5600000-0000-0000-0000-000000000005',
    'f56f0000-0000-0000-0000-000000000005',
    res.sla_rule_uuid,
    'f4100000-0000-0000-0000-000000000003',
    'f5500000-0000-0000-0000-000000000001',
    res.start_priority_assessment_uuid,
    'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',
    'scientific_completed','business_calendar',
    maintenance.sla_rule_snapshot(
      res.sla_rule_uuid,'f4100000-0000-0000-0000-000000000003',
      res.contractual_start_at,res.selection_trace
    ),
    maintenance.sla_due_calculation_payload(
      res.sla_rule_uuid,'f4100000-0000-0000-0000-000000000003',
      res.raw_causal_start_at,res.contractual_start_at,
      TIMESTAMPTZ '2026-10-07 00:45:00+00'
    ),
    res.contractual_start_at,
    maintenance.sla_nominal_due_at(res.sla_rule_uuid,res.contractual_start_at),
    'running'
FROM res
WHERE res.resolution_status='selected';

INSERT INTO maintenance.sla_pause(
    sla_pause_uuid,sla_instance_uuid,reason_code,rationale,
    authorized_by,actor_type,authorized_at,started_at,
    ended_at,closed_by,closed_at,external_event_payload
) VALUES (
    'f5700000-0000-0000-0000-000000000001',
    'f5600000-0000-0000-0000-000000000005',
    'external_dependency',
    'Synthetic closed pause to validate due derivation',
    'fixture-owner','owner',
    TIMESTAMPTZ '2026-10-07 01:00:00+00',
    TIMESTAMPTZ '2026-10-07 01:00:00+00',
    TIMESTAMPTZ '2026-10-07 01:30:00+00',
    'fixture-owner',TIMESTAMPTZ '2026-10-07 01:30:00+00',
    '{"fixture":true}'::jsonb
);

COMMIT;
