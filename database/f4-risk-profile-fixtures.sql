-- F4 UpdateRiskProfile synthetic fixtures
-- Requires migrations through 030 + F3 Monitor/Alert + F4 update-protocol fixtures.
-- All records are synthetic test data. No normative policy defaults.
-- Date: 2026-10-07

BEGIN;

INSERT INTO maintenance.update_risk_profile(
    update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
    recommended_maintenance_level,recommended_cadence_mode,
    event_driven_surveillance_required,feasibility_status,
    priority_implications_payload,rationale,
    profiled_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    authority_status,assessed_at,effective_at
) VALUES (
    'f6000000-0000-0000-0000-000000000001',
    'e5100000-0000-0000-0000-000000000003',
    'initial','M2','periodic',true,'adequate',
    '{
      "schema_version":"oes.priority_implications/0.1",
      "dominance_notes":["high conclusion sensitivity"],
      "coordination_notes":["broad dependency reach"],
      "feasibility_notes":["capacity adequate"],
      "rationale":"Synthetic fixture only; no response class encoded"
    }'::jsonb,
    'Synthetic baseline risk profile for the monitored ProductVersion',
    'fixture-reviewer','human_reviewer','human_verified',
    'fixture-reviewer-2','human_reviewer',
    TIMESTAMPTZ '2026-10-06 23:52:00+00',
    'authoritative',
    TIMESTAMPTZ '2026-10-06 23:50:00+00',
    TIMESTAMPTZ '2026-10-06 23:55:00+00'
);

INSERT INTO maintenance.update_risk_profile_dimension(
    update_risk_profile_uuid,dimension_code,value_code,assessment_mode,
    rationale,assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,authority_status,assessed_at
) VALUES
('f6000000-0000-0000-0000-000000000001','A1','moderate','assessed',
 'Synthetic decision criticality','fixture-reviewer','human_reviewer','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:50:10+00'),
('f6000000-0000-0000-0000-000000000001','A2','moderate','assessed',
 'Synthetic evidence volatility','fixture-reviewer','human_reviewer','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:50:20+00'),
('f6000000-0000-0000-0000-000000000001','A3','high','assessed',
 'Synthetic conclusion sensitivity','fixture-reviewer','human_reviewer','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:50:30+00'),
('f6000000-0000-0000-0000-000000000001','A4','moderate','assessed',
 'Synthetic safety/integrity exposure','fixture-reviewer','human_reviewer','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:50:40+00'),
('f6000000-0000-0000-0000-000000000001','A5','broad','assessed',
 'Synthetic downstream dependency reach','fixture-owner','owner','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:50:50+00'),
('f6000000-0000-0000-0000-000000000001','B1','high','assessed',
 'Synthetic source observability','fixture-owner','owner','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:51:00+00'),
('f6000000-0000-0000-0000-000000000001','B2','short','assessed',
 'Synthetic detection latency','fixture-owner','owner','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:10+00','authoritative',TIMESTAMPTZ '2026-10-06 23:51:05+00'),
('f6000000-0000-0000-0000-000000000001','B3','moderate','assessed',
 'Synthetic surveillance load','fixture-owner','owner','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:20+00','authoritative',TIMESTAMPTZ '2026-10-06 23:51:10+00'),
('f6000000-0000-0000-0000-000000000001','B4','moderate','assessed',
 'Synthetic incorporation cost','fixture-owner','owner','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:30+00','authoritative',TIMESTAMPTZ '2026-10-06 23:51:20+00'),
('f6000000-0000-0000-0000-000000000001','B5','adequate','assessed',
 'Synthetic sustainable institutional capacity','fixture-owner','owner','unverified',
 NULL,NULL,NULL,'authoritative',TIMESTAMPTZ '2026-10-06 23:51:30+00');

INSERT INTO maintenance.update_risk_profile_dimension_basis(
    update_risk_profile_uuid,dimension_code,source_type,
    monitor_cycle_uuid,observation_payload,rationale,sequence_no
) VALUES
('f6000000-0000-0000-0000-000000000001','A2','monitor_cycle',
 'e5420000-0000-0000-0000-000000000002',
 '{"fixture":true,"observation":"recent retained candidate"}'::jsonb,
 'Synthetic MonitorCycle evidence for volatility assessment',1),
('f6000000-0000-0000-0000-000000000001','B1','monitor_cycle',
 'e5420000-0000-0000-0000-000000000002',
 '{"fixture":true,"observation":"structured monitored sources"}'::jsonb,
 'Synthetic MonitorCycle evidence for observability assessment',1);

INSERT INTO maintenance.update_risk_profile_dimension_basis(
    update_risk_profile_uuid,dimension_code,source_type,
    candidate_assessment_uuid,observation_payload,rationale,sequence_no
) VALUES (
 'f6000000-0000-0000-0000-000000000001','A3','candidate_assessment',
 'e5530000-0000-0000-0000-000000000002',
 '{"fixture":true,"possible_effect_change":true}'::jsonb,
 'Synthetic CandidateAssessment evidence for conclusion sensitivity',1
);

INSERT INTO maintenance.update_risk_profile_trigger(
    update_risk_profile_uuid,trigger_code,source_type,rationale,sequence_no
) VALUES (
    'f6000000-0000-0000-0000-000000000001',
    'initial_baseline','none',
    'Synthetic initial risk-profile baseline',1
);

INSERT INTO maintenance.update_policy_risk_profile_basis(
    update_policy_risk_profile_basis_uuid,update_policy_uuid,
    update_risk_profile_uuid,basis_role,linked_at,linked_by,actor_type,rationale
) VALUES (
    'f6100000-0000-0000-0000-000000000001',
    'f4000000-0000-0000-0000-000000000001',
    'f6000000-0000-0000-0000-000000000001',
    'governing',TIMESTAMPTZ '2026-10-07 00:00:00+00',
    'fixture-owner','owner',
    'Synthetic governing risk-profile basis predating the synthetic policy'
);


-- Auxiliary complete profiles used only to preserve pre-030 operational-control tests.

-- Policy 2 / Investigation target: complete proposal, serializer-eligible.
INSERT INTO maintenance.update_risk_profile(
    update_risk_profile_uuid,target_investigation_version_uuid,assessment_kind,
    recommended_maintenance_level,recommended_cadence_mode,
    event_driven_surveillance_required,feasibility_status,
    priority_implications_payload,rationale,
    profiled_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    authority_status,assessed_at,effective_at
) VALUES (
    'f6000000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000002',
    'initial','M2','periodic',true,'adequate',
    '{"schema_version":"oes.priority_implications/0.1","dominance_notes":[],"coordination_notes":[],"feasibility_notes":[],"rationale":"Synthetic proposal only"}'::jsonb,
    'Synthetic complete proposal for policy-2 operational tests',
    'fixture-ai','ai_system','ai_verified',
    'fixture-ai-check','ai_system',TIMESTAMPTZ '2026-10-06 23:52:00+00',
    'proposal',TIMESTAMPTZ '2026-10-06 23:50:00+00',
    TIMESTAMPTZ '2026-10-06 23:55:00+00'
);

INSERT INTO maintenance.update_risk_profile_dimension(
    update_risk_profile_uuid,dimension_code,value_code,assessment_mode,
    rationale,assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,authority_status,assessed_at
)
SELECT
    'f6000000-0000-0000-0000-000000000002',
    d.dimension_code,d.value_code,'assessed',
    'Synthetic cloned proposal dimension',
    'fixture-ai','ai_system','ai_verified',
    'fixture-ai-check','ai_system',TIMESTAMPTZ '2026-10-06 23:53:00+00',
    'proposal',TIMESTAMPTZ '2026-10-06 23:52:30+00'
FROM maintenance.update_risk_profile_dimension d
WHERE d.update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001';

INSERT INTO maintenance.update_risk_profile_trigger(
    update_risk_profile_uuid,trigger_code,source_type,rationale,sequence_no
) VALUES (
    'f6000000-0000-0000-0000-000000000002',
    'initial_baseline','none','Synthetic initial proposal baseline',1
);

-- Same ProductVersion, authoritative historical profile with A1 high.
INSERT INTO maintenance.update_risk_profile(
    update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
    recommended_maintenance_level,recommended_cadence_mode,
    event_driven_surveillance_required,feasibility_status,
    priority_implications_payload,rationale,
    profiled_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    authority_status,assessed_at,effective_at,record_status
)
SELECT
    'f6000000-0000-0000-0000-000000000003',
    target_product_version_uuid,'initial',
    recommended_maintenance_level,recommended_cadence_mode,
    event_driven_surveillance_required,feasibility_status,
    priority_implications_payload,
    'Synthetic historical high-criticality profile',
    profiled_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    'authoritative',
    TIMESTAMPTZ '2026-10-06 23:40:00+00',
    TIMESTAMPTZ '2026-10-06 23:45:00+00',
    'superseded'
FROM maintenance.update_risk_profile
WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001';

INSERT INTO maintenance.update_risk_profile_dimension(
    update_risk_profile_uuid,dimension_code,value_code,assessment_mode,
    rationale,assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,authority_status,assessed_at
)
SELECT
    'f6000000-0000-0000-0000-000000000003',
    dimension_code,
    CASE WHEN dimension_code='A1' THEN 'high' ELSE value_code END,
    'assessed','Synthetic high-criticality test profile',
    assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,authority_status,
    TIMESTAMPTZ '2026-10-06 23:41:00+00'
FROM maintenance.update_risk_profile_dimension
WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001';

INSERT INTO maintenance.update_risk_profile_trigger(
    update_risk_profile_uuid,trigger_code,source_type,rationale,sequence_no
) VALUES (
    'f6000000-0000-0000-0000-000000000003',
    'initial_baseline','none','Synthetic historical high-criticality baseline',1
);

-- Same ProductVersion, authoritative historical profile with B5 unavailable.
INSERT INTO maintenance.update_risk_profile(
    update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
    recommended_maintenance_level,recommended_cadence_mode,
    event_driven_surveillance_required,feasibility_status,
    priority_implications_payload,rationale,
    profiled_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    authority_status,assessed_at,effective_at,record_status
)
SELECT
    'f6000000-0000-0000-0000-000000000004',
    target_product_version_uuid,'initial',
    recommended_maintenance_level,recommended_cadence_mode,
    event_driven_surveillance_required,'unavailable',
    priority_implications_payload,
    'Synthetic historical unavailable-capacity profile',
    profiled_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    'authoritative',
    TIMESTAMPTZ '2026-10-06 23:30:00+00',
    TIMESTAMPTZ '2026-10-06 23:35:00+00',
    'superseded'
FROM maintenance.update_risk_profile
WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001';

INSERT INTO maintenance.update_risk_profile_dimension(
    update_risk_profile_uuid,dimension_code,value_code,assessment_mode,
    rationale,assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,authority_status,assessed_at
)
SELECT
    'f6000000-0000-0000-0000-000000000004',
    dimension_code,
    CASE WHEN dimension_code='B5' THEN 'unavailable' ELSE value_code END,
    'assessed','Synthetic unavailable-capacity test profile',
    assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,authority_status,
    TIMESTAMPTZ '2026-10-06 23:31:00+00'
FROM maintenance.update_risk_profile_dimension
WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001';

INSERT INTO maintenance.update_risk_profile_trigger(
    update_risk_profile_uuid,trigger_code,source_type,rationale,sequence_no
) VALUES (
    'f6000000-0000-0000-0000-000000000004',
    'initial_baseline','none','Synthetic historical unavailable-capacity baseline',1
);

COMMIT;
