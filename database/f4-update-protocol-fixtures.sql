-- F4 Transversal Update Protocol synthetic fixtures
-- Requires migrations through 027 plus F3 Monitor and Alert fixtures.
-- Date: 2026-10-07

BEGIN;

-- ---------------------------------------------------------------------------
-- Update policies
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.update_policy(
    update_policy_uuid,
    target_product_version_uuid,
    effective_maintenance_level,cadence_mode,
    cadence_contract_uuid,cadence_policy_payload,trigger_policy_payload,
    materiality_policy_payload,escalation_policy_payload,
    governance_policy_payload,
    governing_monitor_product_version_uuid,
    effective_at,rationale,created_by,actor_type
) VALUES (
    'f4000000-0000-0000-0000-000000000001',
    'e5100000-0000-0000-0000-000000000003',
    'M2','periodic',
    'fc640000-0000-0000-0000-000000000001',
    maintenance.cadence_contract_snapshot('fc640000-0000-0000-0000-000000000001'),
    '{"monitor_cycle":true,"alerts":true}'::jsonb,
    '{"dimensions":["magnitude","certainty","conclusion"]}'::jsonb,
    '{"auto_escalation":false}'::jsonb,
    '{"authoritative_automation":false}'::jsonb,
    'e5100000-0000-0000-0000-000000000005',
    TIMESTAMPTZ '2026-10-07 00:00:00+00',
    'Synthetic M2 transversal policy bound to v0.1 cadence contract',
    'fixture-owner','owner'
);

INSERT INTO maintenance.update_policy(
    update_policy_uuid,
    target_investigation_version_uuid,
    effective_maintenance_level,cadence_mode,
    cadence_contract_uuid,cadence_policy_payload,trigger_policy_payload,
    materiality_policy_payload,escalation_policy_payload,
    governance_policy_payload,
    governing_monitor_product_version_uuid,
    effective_at,rationale,created_by,actor_type
) VALUES (
    'f4000000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000002',
    'M2','periodic',
    'fc640000-0000-0000-0000-000000000002',
    maintenance.cadence_contract_snapshot('fc640000-0000-0000-0000-000000000002'),
    '{"monitor_cycle":true}'::jsonb,
    '{"living_candidate":false}'::jsonb,
    '{"auto_escalation":false}'::jsonb,
    '{"formal_m3_operational":false}'::jsonb,
    'e5100000-0000-0000-0000-000000000007',
    TIMESTAMPTZ '2026-10-07 00:01:00+00',
    'Synthetic M2 investigation policy bound to v0.1 cadence contract; M3 remains blocked',
    'fixture-owner','owner'
);

-- ---------------------------------------------------------------------------
-- Signal 1: scientific signal from Monitor CandidateAssessment
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.update_signal(
    update_signal_uuid,update_policy_uuid,
    signal_class,trigger_class,signal_type,
    signal_date,detected_at,summary,rationale,
    detected_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
    'f4100000-0000-0000-0000-000000000001',
    'f4000000-0000-0000-0000-000000000001',
    'scientific_currentness','new_evidence','new_study',
    DATE '2026-10-06',TIMESTAMPTZ '2026-10-07 00:05:00+00',
    'Retained new-study candidate may affect magnitude and certainty',
    'Normalized transversal signal from Monitor candidate assessment',
    'fixture-ai','ai_system',
    'human_verified','fixture-reviewer','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:06:00+00'
);

INSERT INTO maintenance.update_signal_source(
    update_signal_source_uuid,update_signal_uuid,
    source_role,source_type,candidate_assessment_uuid,
    note,sequence_no
) VALUES (
    'f4200000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000001',
    'primary','candidate_assessment',
    'e5530000-0000-0000-0000-000000000002',
    'Retained candidate from governing M2 Monitor cycle',1
);

INSERT INTO maintenance.materiality_assessment(
    materiality_assessment_uuid,update_signal_uuid,
    outcome,rationale,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    assessed_at
) VALUES (
    'f4300000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000001',
    'potentially_material',
    'Candidate may change magnitude and certainty; reassessment is warranted',
    'fixture-reviewer','human_reviewer',
    'human_verified','fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:10:00+00',
    TIMESTAMPTZ '2026-10-07 00:09:00+00'
);

INSERT INTO maintenance.materiality_dimension(
    materiality_assessment_uuid,dimension_code,
    dimension_status,rationale,sequence_no
) VALUES
(
    'f4300000-0000-0000-0000-000000000001',
    'magnitude','potential','Possible quantitative effect change',1
),
(
    'f4300000-0000-0000-0000-000000000001',
    'certainty','uncertain','Possible certainty change requires reassessment',2
);

INSERT INTO maintenance.update_decision(
    update_decision_uuid,update_signal_uuid,
    materiality_assessment_uuid,
    decision_type,authority_status,currency_action,
    rationale,decided_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    decided_at
) VALUES (
    'f4400000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000001',
    'f4300000-0000-0000-0000-000000000001',
    'currentness_only','authoritative','set_under_evaluation',
    'Maintain target under evaluation while scientific reassessment proceeds',
    'fixture-owner','owner',
    'human_verified','fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:12:00+00',
    TIMESTAMPTZ '2026-10-07 00:11:00+00'
);

INSERT INTO maintenance.update_decision_currency_state(
    update_decision_uuid,currency_state_uuid
) VALUES (
    'f4400000-0000-0000-0000-000000000001',
    'e5300000-0000-0000-0000-000000000003'
);

-- ---------------------------------------------------------------------------
-- Signal 2: cadence due, operational and source-free by contract
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.update_signal(
    update_signal_uuid,update_policy_uuid,
    signal_class,trigger_class,signal_type,
    detected_at,summary,rationale,
    detected_by,actor_type,verification_status
) VALUES (
    'f4100000-0000-0000-0000-000000000002',
    'f4000000-0000-0000-0000-000000000001',
    'operational','temporal_operational','cadence_due',
    TIMESTAMPTZ '2026-10-07 00:20:00+00',
    'Synthetic cadence checkpoint reached',
    'Policy-derived temporal signal; no scientific change is inferred',
    'fixture-system','system','unverified'
);

INSERT INTO maintenance.materiality_assessment(
    materiality_assessment_uuid,update_signal_uuid,
    outcome,rationale,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    assessed_at
) VALUES (
    'f4300000-0000-0000-0000-000000000002',
    'f4100000-0000-0000-0000-000000000002',
    'insufficient_to_decide',
    'Cadence event alone does not establish scientific materiality',
    'fixture-reviewer','human_reviewer',
    'human_verified','fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:23:00+00',
    TIMESTAMPTZ '2026-10-07 00:22:00+00'
);

INSERT INTO maintenance.update_decision(
    update_decision_uuid,update_signal_uuid,
    materiality_assessment_uuid,
    decision_type,authority_status,currency_action,
    rationale,decided_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    decided_at
) VALUES (
    'f4400000-0000-0000-0000-000000000002',
    'f4100000-0000-0000-0000-000000000002',
    'f4300000-0000-0000-0000-000000000002',
    'observe','authoritative','set_under_evaluation',
    'Operational cadence signal sustains observation but not a scientific conclusion change',
    'fixture-owner','owner',
    'human_verified','fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:25:00+00',
    TIMESTAMPTZ '2026-10-07 00:24:00+00'
);

INSERT INTO maintenance.update_decision_currency_state(
    update_decision_uuid,currency_state_uuid
) VALUES (
    'f4400000-0000-0000-0000-000000000002',
    'e5300000-0000-0000-0000-000000000003'
);

-- ---------------------------------------------------------------------------
-- Signal 3: Alert-derived scientific signal, not yet assessed
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.update_signal(
    update_signal_uuid,update_policy_uuid,
    signal_class,trigger_class,signal_type,
    signal_date,detected_at,summary,rationale,
    detected_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
    'f4100000-0000-0000-0000-000000000003',
    'f4000000-0000-0000-0000-000000000001',
    'scientific_currentness','new_evidence','estimate_change_signal',
    DATE '2026-10-06',TIMESTAMPTZ '2026-10-07 00:30:00+00',
    'Published Evidence Alert normalized as transversal update signal',
    'Alert remains a source; it does not determine materiality or currentness',
    'fixture-reviewer','human_reviewer',
    'human_verified','fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-07 00:31:00+00'
);

INSERT INTO maintenance.update_signal_source(
    update_signal_source_uuid,update_signal_uuid,
    source_role,source_type,alert_product_version_uuid,
    note,sequence_no
) VALUES (
    'f4200000-0000-0000-0000-000000000002',
    'f4100000-0000-0000-0000-000000000003',
    'primary','alert_product_version',
    'a7100000-0000-0000-0000-000000000001',
    'Formal Alert A targets the same scientific ProductVersion',1
);

COMMIT;
