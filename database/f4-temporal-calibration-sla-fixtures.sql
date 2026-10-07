-- F4 temporal calibration v0.1 — synthetic SLA/calendar calibration fixtures
-- TEST-ONLY values preserved from historical operational-control fixtures.
-- No OES normative SLA/calendar value is seeded.

BEGIN;

-- ---------------------------------------------------------------------------
-- Synthetic business calendar calibration.
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.temporal_calibration_dossier(
 temporal_calibration_dossier_uuid,scope_type,calibration_kind,calendar_key,
 data_window_start,data_window_end,decision_status,rationale,
 created_by,actor_type,decided_at,decision_recorded_by,decision_actor_type
) VALUES (
 'fc700000-0000-0000-0000-000000000001','calendar','sla_calendar',
 'fixture-business-calendar',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation',
 'TEST-ONLY synthetic business calendar calibration',
 'fixture-owner','owner',TIMESTAMPTZ '2026-10-06 23:55:00+00',
 'fixture-owner','owner'
);

INSERT INTO maintenance.temporal_calibration_authority(
 temporal_calibration_dossier_uuid,authority_domain,actor,actor_type,
 verification_status,rationale,decided_at
) VALUES (
 'fc700000-0000-0000-0000-000000000001','operational_feasibility',
 'fixture-owner','owner','unverified',
 'TEST-ONLY calendar operational authority',TIMESTAMPTZ '2026-10-06 23:54:00+00'
);

INSERT INTO maintenance.temporal_calibration_candidate(
 temporal_calibration_candidate_uuid,temporal_calibration_dossier_uuid,candidate_no,
 candidate_kind,candidate_payload,disposition,rationale
) VALUES (
 'fc710000-0000-0000-0000-000000000001',
 'fc700000-0000-0000-0000-000000000001',1,'sla_calendar',
 jsonb_build_object(
   'schema_version','oes.sla_calendar_candidate/0.1',
   'calendar_key','fixture-business-calendar',
   'timezone_name','America/Recife',
   'weekly_schedule','{
      "1":[{"start":"08:00","end":"17:00"}],
      "2":[{"start":"08:00","end":"17:00"}],
      "3":[{"start":"08:00","end":"17:00"}],
      "4":[{"start":"08:00","end":"17:00"}],
      "5":[{"start":"08:00","end":"17:00"}],
      "6":[],"7":[]
   }'::jsonb,
   'exception_dates','[]'::jsonb,
   'effective_from',TIMESTAMPTZ '2026-10-07 00:00:00+00'
 ),
 'selected','TEST-ONLY selected calendar candidate'
);

INSERT INTO maintenance.temporal_calibration_evaluation(
 temporal_calibration_evaluation_uuid,temporal_calibration_candidate_uuid,
 evaluation_type,result_status,metrics_payload,rationale,evaluated_at
) VALUES (
 'fc711000-0000-0000-0000-000000000001',
 'fc710000-0000-0000-0000-000000000001',
 'capacity_analysis','acceptable','{"fixture":true}'::jsonb,
 'TEST-ONLY calendar capacity evaluation',TIMESTAMPTZ '2026-10-06 23:54:30+00'
);

INSERT INTO maintenance.sla_calendar_version(
 sla_calendar_version_uuid,calendar_key,version_no,timezone_name,
 weekly_schedule_payload,exception_dates_payload,effective_from,
 created_by,actor_type,temporal_calibration_dossier_uuid
) VALUES (
 'f5300000-0000-0000-0000-000000000001',
 'fixture-business-calendar',1,'America/Recife',
 '{
   "1":[{"start":"08:00","end":"17:00"}],
   "2":[{"start":"08:00","end":"17:00"}],
   "3":[{"start":"08:00","end":"17:00"}],
   "4":[{"start":"08:00","end":"17:00"}],
   "5":[{"start":"08:00","end":"17:00"}],
   "6":[],"7":[]
 }'::jsonb,
 '[]'::jsonb,TIMESTAMPTZ '2026-10-07 00:00:00+00',
 'fixture-owner','owner','fc700000-0000-0000-0000-000000000001'
);

-- ---------------------------------------------------------------------------
-- Six test-only SLA calibration dossiers.
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.temporal_calibration_dossier(
 temporal_calibration_dossier_uuid,scope_type,calibration_kind,
 target_product_version_uuid,update_risk_profile_uuid,baseline_update_policy_uuid,
 clock_code,data_window_start,data_window_end,decision_status,rationale,
 created_by,actor_type,decided_at,decision_recorded_by,decision_actor_type
) VALUES
('fc720000-0000-0000-0000-000000000001','target','sla_rule',
 'e5100000-0000-0000-0000-000000000003','f6000000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','SLA1_DETECTION_TO_TRIAGE',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation','TEST-ONLY SLA1 calibration',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:56:00+00','fixture-reviewer','human_reviewer'),
('fc720000-0000-0000-0000-000000000002','target','sla_rule',
 'e5100000-0000-0000-0000-000000000003','f6000000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','SLA2_TRIAGE_TO_MATERIALITY',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation','TEST-ONLY SLA2 calibration',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:56:00+00','fixture-reviewer','human_reviewer'),
('fc720000-0000-0000-0000-000000000003','target','sla_rule',
 'e5100000-0000-0000-0000-000000000003','f6000000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','SLA3_MATERIALITY_TO_DECISION',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation','TEST-ONLY SLA3 calibration',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:56:00+00','fixture-reviewer','human_reviewer'),
('fc720000-0000-0000-0000-000000000004','target','sla_rule',
 'e5100000-0000-0000-0000-000000000003','f6000000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','SLA4_DECISION_TO_WORKFLOW_START',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation','TEST-ONLY SLA4 calibration',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:56:00+00','fixture-reviewer','human_reviewer'),
('fc720000-0000-0000-0000-000000000005','target','sla_rule',
 'e5100000-0000-0000-0000-000000000003','f6000000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation','TEST-ONLY SLA5 calibration',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:56:00+00','fixture-reviewer','human_reviewer'),
('fc720000-0000-0000-0000-000000000006','target','sla_rule',
 'e5100000-0000-0000-0000-000000000003','f6000000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT',
 TIMESTAMPTZ '2026-09-01 00:00:00+00',TIMESTAMPTZ '2026-10-06 23:30:00+00',
 'approved_for_normative_activation','TEST-ONLY SLA6 calibration',
 'fixture-reviewer','human_reviewer',TIMESTAMPTZ '2026-10-06 23:56:00+00','fixture-reviewer','human_reviewer');

INSERT INTO maintenance.temporal_calibration_authority(
 temporal_calibration_dossier_uuid,authority_domain,actor,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,rationale,decided_at
)
SELECT d,'scientific_methodological','fixture-reviewer','human_reviewer',
 'human_verified','fixture-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-06 23:55:00+00',
 'TEST-ONLY scientific SLA authority',TIMESTAMPTZ '2026-10-06 23:55:00+00'
FROM unnest(ARRAY[
 'fc720000-0000-0000-0000-000000000001'::uuid,
 'fc720000-0000-0000-0000-000000000002'::uuid,
 'fc720000-0000-0000-0000-000000000003'::uuid,
 'fc720000-0000-0000-0000-000000000004'::uuid,
 'fc720000-0000-0000-0000-000000000005'::uuid,
 'fc720000-0000-0000-0000-000000000006'::uuid
]) d;

INSERT INTO maintenance.temporal_calibration_authority(
 temporal_calibration_dossier_uuid,authority_domain,actor,actor_type,
 verification_status,rationale,decided_at
)
SELECT d,'operational_feasibility','fixture-owner','owner','unverified',
 'TEST-ONLY operational SLA authority',TIMESTAMPTZ '2026-10-06 23:55:30+00'
FROM unnest(ARRAY[
 'fc720000-0000-0000-0000-000000000001'::uuid,
 'fc720000-0000-0000-0000-000000000002'::uuid,
 'fc720000-0000-0000-0000-000000000003'::uuid,
 'fc720000-0000-0000-0000-000000000004'::uuid,
 'fc720000-0000-0000-0000-000000000005'::uuid,
 'fc720000-0000-0000-0000-000000000006'::uuid
]) d;

-- Candidate payloads exactly match the future SLARule calibration snapshots.
WITH x(dossier,candidate,clock_code,precedence,endpoint,time_basis,duration_seconds,calendar_uuid,pause_policy) AS (
 VALUES
 ('fc720000-0000-0000-0000-000000000001'::uuid,'fc730000-0000-0000-0000-000000000001'::uuid,'SLA1_DETECTION_TO_TRIAGE',1,'triage','elapsed_time',7200::numeric,NULL::uuid,
  '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}'::jsonb),
 ('fc720000-0000-0000-0000-000000000002','fc730000-0000-0000-0000-000000000002','SLA2_TRIAGE_TO_MATERIALITY',1,'materiality','elapsed_time',14400,NULL,
  '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}'::jsonb),
 ('fc720000-0000-0000-0000-000000000003','fc730000-0000-0000-0000-000000000003','SLA3_MATERIALITY_TO_DECISION',1,'update_decision','elapsed_time',14400,NULL,
  '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}'::jsonb),
 ('fc720000-0000-0000-0000-000000000004','fc730000-0000-0000-0000-000000000004','SLA4_DECISION_TO_WORKFLOW_START',1,'workflow_started','elapsed_time',28800,NULL,
  '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}'::jsonb),
 ('fc720000-0000-0000-0000-000000000005','fc730000-0000-0000-0000-000000000005','SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',1,'scientific_completed','business_calendar',57600,'f5300000-0000-0000-0000-000000000001',
  '{"schema_version":"oes.sla_pause_policy/0.1","mode":"allowed_reasons","allowed_reason_codes":["external_dependency"]}'::jsonb),
 ('fc720000-0000-0000-0000-000000000006','fc730000-0000-0000-0000-000000000006','SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT',1,'publication','elapsed_time',28800,NULL,
  '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}'::jsonb)
)
INSERT INTO maintenance.temporal_calibration_candidate(
 temporal_calibration_candidate_uuid,temporal_calibration_dossier_uuid,candidate_no,
 candidate_kind,candidate_payload,disposition,rationale
)
SELECT candidate,dossier,1,'sla_rule',
 jsonb_strip_nulls(jsonb_build_object(
  'schema_version','oes.sla_rule_candidate/0.1',
  'clock_code',clock_code,'selection_precedence',precedence,
  'filters','{}'::jsonb,'endpoint_type',endpoint,'time_basis',time_basis,
  'target_duration_seconds',duration_seconds,
  'sla_calendar_version_uuid',calendar_uuid,
  'pause_policy',pause_policy,
  'warning_policy','{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}'::jsonb,
  'breach_policy','{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}'::jsonb,
  'escalation_policy','{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}'::jsonb,
  'effective_at',TIMESTAMPTZ '2026-10-07 00:00:00+00'
 )),
 'selected','TEST-ONLY selected SLA candidate'
FROM x;

INSERT INTO maintenance.temporal_calibration_evaluation(
 temporal_calibration_evaluation_uuid,temporal_calibration_candidate_uuid,
 evaluation_type,result_status,metrics_payload,rationale,evaluated_at
)
SELECT
 ('fc740000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,
 ('fc730000-0000-0000-0000-'||lpad(n::text,12,'0'))::uuid,
 'capacity_analysis','acceptable','{"fixture":true}'::jsonb,
 'TEST-ONLY SLA capacity evaluation',TIMESTAMPTZ '2026-10-06 23:55:40+00'
FROM generate_series(1,6) n;

-- ---------------------------------------------------------------------------
-- Calibrated synthetic rules preserving historical UUIDs/test durations.
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.sla_rule(
 sla_rule_uuid,rule_code,update_policy_uuid,clock_code,selection_precedence,
 endpoint_type,time_basis,target_duration,sla_calendar_version_uuid,
 pause_allowed,pause_policy_payload,warning_policy_payload,breach_policy_payload,
 escalation_policy_payload,effective_at,rationale,created_by,actor_type,
 temporal_calibration_dossier_uuid
) VALUES
('f5400000-0000-0000-0000-000000000001','fixture-sla1','f4000000-0000-0000-0000-000000000001',
 'SLA1_DETECTION_TO_TRIAGE',1,'triage','elapsed_time',interval '2 hours',NULL,false,
 '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}',
 '{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}',
 TIMESTAMPTZ '2026-10-07 00:00:00+00','TEST-ONLY synthetic duration','fixture-owner','owner',
 'fc720000-0000-0000-0000-000000000001'),
('f5400000-0000-0000-0000-000000000002','fixture-sla2','f4000000-0000-0000-0000-000000000001',
 'SLA2_TRIAGE_TO_MATERIALITY',1,'materiality','elapsed_time',interval '4 hours',NULL,false,
 '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}',
 '{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}',
 TIMESTAMPTZ '2026-10-07 00:00:00+00','TEST-ONLY synthetic duration','fixture-owner','owner',
 'fc720000-0000-0000-0000-000000000002'),
('f5400000-0000-0000-0000-000000000003','fixture-sla3','f4000000-0000-0000-0000-000000000001',
 'SLA3_MATERIALITY_TO_DECISION',1,'update_decision','elapsed_time',interval '4 hours',NULL,false,
 '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}',
 '{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}',
 TIMESTAMPTZ '2026-10-07 00:00:00+00','TEST-ONLY synthetic duration','fixture-owner','owner',
 'fc720000-0000-0000-0000-000000000003'),
('f5400000-0000-0000-0000-000000000004','fixture-sla4','f4000000-0000-0000-0000-000000000001',
 'SLA4_DECISION_TO_WORKFLOW_START',1,'workflow_started','elapsed_time',interval '8 hours',NULL,false,
 '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}',
 '{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}',
 TIMESTAMPTZ '2026-10-07 00:00:00+00','TEST-ONLY synthetic duration','fixture-owner','owner',
 'fc720000-0000-0000-0000-000000000004'),
('f5400000-0000-0000-0000-000000000005','fixture-sla5','f4000000-0000-0000-0000-000000000001',
 'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',1,'scientific_completed','business_calendar',interval '16 hours',
 'f5300000-0000-0000-0000-000000000001',true,
 '{"schema_version":"oes.sla_pause_policy/0.1","mode":"allowed_reasons","allowed_reason_codes":["external_dependency"]}',
 '{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}',
 '{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}',
 TIMESTAMPTZ '2026-10-07 00:00:00+00','TEST-ONLY synthetic duration','fixture-owner','owner',
 'fc720000-0000-0000-0000-000000000005'),
('f5400000-0000-0000-0000-000000000006','fixture-sla6','f4000000-0000-0000-0000-000000000001',
 'SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT',1,'publication','elapsed_time',interval '8 hours',NULL,false,
 '{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}',
 '{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}',
 '{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}',
 TIMESTAMPTZ '2026-10-07 00:00:00+00','TEST-ONLY synthetic duration','fixture-owner','owner',
 'fc720000-0000-0000-0000-000000000006');

COMMIT;
