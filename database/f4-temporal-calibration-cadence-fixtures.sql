-- F4 temporal calibration v0.1 — synthetic cadence prerequisites
-- TEST-ONLY values. No normative OES cadence is seeded.

BEGIN;

-- Calibration-only authoritative profiles, separate from operational F4 profiles.
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
 recommended_maintenance_level,recommended_cadence_mode,
 event_driven_surveillance_required,feasibility_status,
 priority_implications_payload,rationale,profiled_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at,effective_at
) VALUES (
 'fc600000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003','initial','M2','periodic',
 false,'adequate','{"fixture":true}'::jsonb,
 'TEST-ONLY cadence calibration profile for product policy',
 'fixture-reviewer','human_reviewer','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00',
 'authoritative',TIMESTAMPTZ '2026-10-06 23:40:00+00',
 TIMESTAMPTZ '2026-10-06 23:41:00+00'
);

INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_investigation_version_uuid,assessment_kind,
 recommended_maintenance_level,recommended_cadence_mode,
 event_driven_surveillance_required,feasibility_status,
 priority_implications_payload,rationale,profiled_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at,effective_at
) VALUES (
 'fc600000-0000-0000-0000-000000000002',
 'e5100000-0000-0000-0000-000000000002','initial','M2','periodic',
 false,'adequate','{"fixture":true}'::jsonb,
 'TEST-ONLY cadence calibration profile for investigation policy',
 'fixture-reviewer','human_reviewer','human_verified',
 'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00',
 'authoritative',TIMESTAMPTZ '2026-10-06 23:40:00+00',
 TIMESTAMPTZ '2026-10-06 23:41:00+00'
);


-- Complete authoritative dimensions required by migration 030.
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,
 rationale,assessed_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,authority_status,assessed_at
) VALUES
('fc600000-0000-0000-0000-000000000001','A1','moderate','assessed','TEST-ONLY criticality','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:10+00'),
('fc600000-0000-0000-0000-000000000001','A2','moderate','assessed','TEST-ONLY volatility','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:20+00'),
('fc600000-0000-0000-0000-000000000001','A3','moderate','assessed','TEST-ONLY sensitivity','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:30+00'),
('fc600000-0000-0000-0000-000000000001','A4','moderate','assessed','TEST-ONLY safety','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:40+00'),
('fc600000-0000-0000-0000-000000000001','A5','moderate','assessed','TEST-ONLY reach','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:50+00'),
('fc600000-0000-0000-0000-000000000001','B1','high','assessed','TEST-ONLY observability','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:00+00'),
('fc600000-0000-0000-0000-000000000001','B2','short','assessed','TEST-ONLY latency','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:10+00'),
('fc600000-0000-0000-0000-000000000001','B3','moderate','assessed','TEST-ONLY load','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:20+00'),
('fc600000-0000-0000-0000-000000000001','B4','moderate','assessed','TEST-ONLY cost','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:42:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:30+00'),
('fc600000-0000-0000-0000-000000000001','B5','adequate','assessed','TEST-ONLY capacity','fixture-owner','owner','unverified',NULL,NULL,NULL,'authoritative',TIMESTAMPTZ '2026-10-06 23:41:40+00'),
('fc600000-0000-0000-0000-000000000002','A1','moderate','assessed','TEST-ONLY criticality','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:10+00'),
('fc600000-0000-0000-0000-000000000002','A2','moderate','assessed','TEST-ONLY volatility','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:20+00'),
('fc600000-0000-0000-0000-000000000002','A3','moderate','assessed','TEST-ONLY sensitivity','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:30+00'),
('fc600000-0000-0000-0000-000000000002','A4','moderate','assessed','TEST-ONLY safety','fixture-reviewer','human_reviewer','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:40+00'),
('fc600000-0000-0000-0000-000000000002','A5','moderate','assessed','TEST-ONLY reach','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:40:50+00'),
('fc600000-0000-0000-0000-000000000002','B1','high','assessed','TEST-ONLY observability','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:00+00'),
('fc600000-0000-0000-0000-000000000002','B2','short','assessed','TEST-ONLY latency','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:10+00'),
('fc600000-0000-0000-0000-000000000002','B3','moderate','assessed','TEST-ONLY load','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:20+00'),
('fc600000-0000-0000-0000-000000000002','B4','moderate','assessed','TEST-ONLY cost','fixture-owner','owner','human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:43:00+00','authoritative',TIMESTAMPTZ '2026-10-06 23:41:30+00'),
('fc600000-0000-0000-0000-000000000002','B5','adequate','assessed','TEST-ONLY capacity','fixture-owner','owner','unverified',NULL,NULL,NULL,'authoritative',TIMESTAMPTZ '2026-10-06 23:41:40+00');

-- Product cadence dossier.
INSERT INTO maintenance.temporal_calibration_dossier(
 temporal_calibration_dossier_uuid,scope_type,calibration_kind,
 target_product_version_uuid,update_risk_profile_uuid,
 data_window_start,data_window_end,decision_status,rationale,
 created_by,actor_type,decided_at,decision_recorded_by,decision_actor_type
) VALUES (
 'fc610000-0000-0000-0000-000000000001','target','cadence',
 'e5100000-0000-0000-0000-000000000003',
 'fc600000-0000-0000-0000-000000000001',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation',
 'TEST-ONLY approved synthetic cadence calibration; no OES normative value',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:50:00+00',
 'fixture-reviewer','human_reviewer'
);
INSERT INTO maintenance.temporal_calibration_authority VALUES
 ('fc610000-0000-0000-0000-000000000001','scientific_methodological',
  'fixture-reviewer','human_reviewer','human_verified',
  'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:49:00+00',
  'TEST-ONLY scientific authority',TIMESTAMPTZ '2026-10-06 23:49:00+00'),
 ('fc610000-0000-0000-0000-000000000001','operational_feasibility',
  'fixture-owner','owner','unverified',NULL,NULL,NULL,
  'TEST-ONLY operational feasibility authority',TIMESTAMPTZ '2026-10-06 23:49:00+00');

INSERT INTO maintenance.temporal_calibration_candidate(
 temporal_calibration_candidate_uuid,temporal_calibration_dossier_uuid,candidate_no,
 candidate_kind,candidate_payload,disposition,rationale
) VALUES (
 'fc620000-0000-0000-0000-000000000001',
 'fc610000-0000-0000-0000-000000000001',1,'cadence',
 jsonb_build_object(
  'schema_version','oes.cadence_candidate/0.1',
  'cadence_mode','periodic',
  'effective_at',TIMESTAMPTZ '2026-10-07 00:00:00+00',
  'governing_monitor_product_version_uuid','e5100000-0000-0000-0000-000000000005'::uuid,
  'obligations',jsonb_build_array(jsonb_build_object(
    'obligation_code','fixture-monthly-cycle',
    'scope',jsonb_build_object('type','policy_aggregate'),
    'timing',jsonb_build_object(
      'mode','calendar_recurrence','recurrence_count',1,'recurrence_unit','month',
      'month_roll_policy','preserve_day_or_clamp_last_day'),
    'anchor',jsonb_build_object('type','policy_effective_at'),
    'grace_seconds',0,
    'satisfaction_event_type','monitor_cycle_completed',
    'timezone_name','UTC',
    'dst_resolution_policy','shift_forward_to_first_valid'
  ))
 ),
 'selected','TEST-ONLY selected candidate'
);
INSERT INTO maintenance.temporal_calibration_evaluation VALUES (
 'fc630000-0000-0000-0000-000000000001',
 'fc620000-0000-0000-0000-000000000001',
 'capacity_analysis','acceptable','{"fixture":true}'::jsonb,NULL,
 'TEST-ONLY capacity analysis',TIMESTAMPTZ '2026-10-06 23:48:00+00'
);

INSERT INTO maintenance.cadence_contract(
 cadence_contract_uuid,target_product_version_uuid,temporal_calibration_dossier_uuid,
 cadence_mode,governing_monitor_product_version_uuid,effective_at,created_by,actor_type
) VALUES (
 'fc640000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',
 'fc610000-0000-0000-0000-000000000001','periodic',
 'e5100000-0000-0000-0000-000000000005',
 TIMESTAMPTZ '2026-10-07 00:00:00+00','fixture-owner','owner'
);
INSERT INTO maintenance.cadence_obligation(
 cadence_obligation_uuid,cadence_contract_uuid,obligation_code,scope_type,timing_mode,
 recurrence_count,recurrence_unit,month_roll_policy,anchor_type,timezone_name,
 dst_resolution_policy,grace_interval,satisfaction_event_type,effective_at
) VALUES (
 'fc650000-0000-0000-0000-000000000001',
 'fc640000-0000-0000-0000-000000000001','fixture-monthly-cycle',
 'policy_aggregate','calendar_recurrence',1,'month','preserve_day_or_clamp_last_day',
 'policy_effective_at','UTC','shift_forward_to_first_valid',interval '0',
 'monitor_cycle_completed',TIMESTAMPTZ '2026-10-07 00:00:00+00'
);

-- Investigation cadence dossier.
INSERT INTO maintenance.temporal_calibration_dossier(
 temporal_calibration_dossier_uuid,scope_type,calibration_kind,
 target_investigation_version_uuid,update_risk_profile_uuid,
 data_window_start,data_window_end,decision_status,rationale,
 created_by,actor_type,decided_at,decision_recorded_by,decision_actor_type
) VALUES (
 'fc610000-0000-0000-0000-000000000002','target','cadence',
 'e5100000-0000-0000-0000-000000000002',
 'fc600000-0000-0000-0000-000000000002',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation',
 'TEST-ONLY approved synthetic cadence calibration for investigation',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:51:00+00',
 'fixture-reviewer','human_reviewer'
);
INSERT INTO maintenance.temporal_calibration_authority VALUES
 ('fc610000-0000-0000-0000-000000000002','scientific_methodological',
  'fixture-reviewer','human_reviewer','human_verified',
  'fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:50:00+00',
  'TEST-ONLY scientific authority',TIMESTAMPTZ '2026-10-06 23:50:00+00'),
 ('fc610000-0000-0000-0000-000000000002','operational_feasibility',
  'fixture-owner','owner','unverified',NULL,NULL,NULL,
  'TEST-ONLY operational feasibility authority',TIMESTAMPTZ '2026-10-06 23:50:00+00');

INSERT INTO maintenance.temporal_calibration_candidate(
 temporal_calibration_candidate_uuid,temporal_calibration_dossier_uuid,candidate_no,
 candidate_kind,candidate_payload,disposition,rationale
) VALUES (
 'fc620000-0000-0000-0000-000000000002',
 'fc610000-0000-0000-0000-000000000002',1,'cadence',
 jsonb_build_object(
  'schema_version','oes.cadence_candidate/0.1',
  'cadence_mode','periodic',
  'effective_at',TIMESTAMPTZ '2026-10-07 00:01:00+00',
  'governing_monitor_product_version_uuid','e5100000-0000-0000-0000-000000000007'::uuid,
  'obligations',jsonb_build_array(jsonb_build_object(
    'obligation_code','fixture-monthly-cycle',
    'scope',jsonb_build_object('type','policy_aggregate'),
    'timing',jsonb_build_object(
      'mode','calendar_recurrence','recurrence_count',1,'recurrence_unit','month',
      'month_roll_policy','preserve_day_or_clamp_last_day'),
    'anchor',jsonb_build_object('type','policy_effective_at'),
    'grace_seconds',0,
    'satisfaction_event_type','monitor_cycle_completed',
    'timezone_name','UTC',
    'dst_resolution_policy','shift_forward_to_first_valid'
  ))
 ),
 'selected','TEST-ONLY selected candidate'
);
INSERT INTO maintenance.temporal_calibration_evaluation VALUES (
 'fc630000-0000-0000-0000-000000000002',
 'fc620000-0000-0000-0000-000000000002',
 'capacity_analysis','acceptable','{"fixture":true}'::jsonb,NULL,
 'TEST-ONLY capacity analysis',TIMESTAMPTZ '2026-10-06 23:49:00+00'
);
INSERT INTO maintenance.cadence_contract(
 cadence_contract_uuid,target_investigation_version_uuid,temporal_calibration_dossier_uuid,
 cadence_mode,governing_monitor_product_version_uuid,effective_at,created_by,actor_type
) VALUES (
 'fc640000-0000-0000-0000-000000000002',
 'e5100000-0000-0000-0000-000000000002',
 'fc610000-0000-0000-0000-000000000002','periodic',
 'e5100000-0000-0000-0000-000000000007',
 TIMESTAMPTZ '2026-10-07 00:01:00+00','fixture-owner','owner'
);
INSERT INTO maintenance.cadence_obligation(
 cadence_obligation_uuid,cadence_contract_uuid,obligation_code,scope_type,timing_mode,
 recurrence_count,recurrence_unit,month_roll_policy,anchor_type,timezone_name,
 dst_resolution_policy,grace_interval,satisfaction_event_type,effective_at
) VALUES (
 'fc650000-0000-0000-0000-000000000002',
 'fc640000-0000-0000-0000-000000000002','fixture-monthly-cycle',
 'policy_aggregate','calendar_recurrence',1,'month','preserve_day_or_clamp_last_day',
 'policy_effective_at','UTC','shift_forward_to_first_valid',interval '0',
 'monitor_cycle_completed',TIMESTAMPTZ '2026-10-07 00:01:00+00'
);

COMMIT;
