-- F4 Integrated Operational Control — mirrored contract tests
-- T01–T69 are SQL-contract tests from Documento 27 §§45–51.
-- T70–T72 are workflow evidence: migration idempotency, rebuild, regressions.
-- Requires migrations through 029 + F3 Monitor/Alert + F4 update fixtures
-- + f4-operational-control-fixtures.sql.
-- Date: 2026-10-07

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.assert_true(p boolean,p_label text)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  IF p IS DISTINCT FROM true THEN RAISE EXCEPTION '% FAIL',p_label; END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.expect_error(p_sql text,p_label text)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  BEGIN
    EXECUTE p_sql;
  EXCEPTION WHEN OTHERS THEN
    RETURN;
  END;
  RAISE EXCEPTION '% FAIL — expected error was not raised',p_label;
END;
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.risk(
  p_a1 text DEFAULT 'moderate',
  p_a3 text DEFAULT 'moderate',
  p_b5 text DEFAULT 'adequate',
  p_a4 text DEFAULT 'moderate'
)
RETURNS jsonb LANGUAGE sql AS $q$
SELECT jsonb_build_object(
  'schema_version','oes.update_risk_profile/0.1',
  'assessed_at','2026-10-07T02:00:00Z',
  'A1',p_a1,'A2','moderate','A3',p_a3,'A4',p_a4,'A5','moderate',
  'B1','high','B2','short','B3','moderate','B4','moderate','B5',p_b5,
  'rationale','Synthetic contract test snapshot'
);
$q$;

CREATE OR REPLACE FUNCTION pg_temp.add_signal(p_uuid uuid,p_policy uuid,p_at timestamptz DEFAULT TIMESTAMPTZ '2026-10-07 02:00:00+00')
RETURNS void LANGUAGE sql AS $q$
INSERT INTO maintenance.update_signal(
  update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
  detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
  p_uuid,p_policy,'scientific_currentness','governance_demand',
  'explicit_reassessment_request',p_at,
  'Synthetic governance-demand signal','Synthetic contract test',
  'oc-test-system','system','unverified'
);
$q$;

CREATE OR REPLACE FUNCTION pg_temp.add_materiality(
  p_uuid uuid,p_signal uuid,p_outcome text,p_verification text DEFAULT 'human_verified'
)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  IF p_verification='ai_verified' THEN
    INSERT INTO maintenance.materiality_assessment(
      materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
      assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
      verified_at,assessed_at
    ) VALUES (
      p_uuid,p_signal,p_outcome,'Synthetic materiality assessment',
      'oc-test-ai','ai_system','ai_verified','oc-test-ai-check','ai_system',
      TIMESTAMPTZ '2026-10-07 02:04:00+00',
      TIMESTAMPTZ '2026-10-07 02:03:00+00'
    );
  ELSE
    INSERT INTO maintenance.materiality_assessment(
      materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
      assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
      verified_at,assessed_at
    ) VALUES (
      p_uuid,p_signal,p_outcome,'Synthetic materiality assessment',
      'oc-test-reviewer','human_reviewer','human_verified',
      'oc-test-reviewer-2','human_reviewer',
      TIMESTAMPTZ '2026-10-07 02:04:00+00',
      TIMESTAMPTZ '2026-10-07 02:03:00+00'
    );
  END IF;
END;
$fn$;

-- T01 — one active authoritative triage per signal.
SELECT pg_temp.assert_true(
  (SELECT count(*)=1 FROM maintenance.update_triage
    WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000003'
      AND record_status='active' AND authority_status='authoritative'),
  'F4-OC-T01'
);

-- T02 — AI proposal triage allowed.
SAVEPOINT t02;
INSERT INTO maintenance.update_triage(
 update_triage_uuid,update_signal_uuid,disposition,rationale,
 triaged_by,actor_type,verification_status,authority_status,triaged_at
) VALUES (
 'fa020000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'accepted_for_materiality','AI proposal only',
 'oc-test-ai','ai_system','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 02:01:00+00'
);
SELECT pg_temp.assert_true(
 EXISTS(SELECT 1 FROM maintenance.update_triage
  WHERE update_triage_uuid='fa020000-0000-0000-0000-000000000001'
    AND authority_status='proposal'),'F4-OC-T02');
ROLLBACK TO SAVEPOINT t02; RELEASE SAVEPOINT t02;

-- T03 — AI cannot authoritatively close invalid/out_of_scope.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_triage(
 update_triage_uuid,update_signal_uuid,disposition,rationale,
 triaged_by,actor_type,verification_status,authority_status,triaged_at
) VALUES (
 'fa030000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'out_of_scope','AI cannot close','oc-test-ai','ai_system',
 'unverified','authoritative',TIMESTAMPTZ '2026-10-07 02:01:00+00'
)$$,'F4-OC-T03');

-- T04 — duplicate requires explicit covered signal.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_triage(
 update_triage_uuid,update_signal_uuid,disposition,rationale,
 triaged_by,actor_type,verification_status,authority_status,triaged_at
) VALUES (
 'fa040000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'duplicate_or_already_covered','Missing duplicate target',
 'oc-test-reviewer','human_reviewer','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 02:01:00+00'
)$$,'F4-OC-T04');

-- T05 — routed_elsewhere requires one concrete destination.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_triage(
 update_triage_uuid,update_signal_uuid,disposition,rationale,
 triaged_by,actor_type,verification_status,authority_status,triaged_at
) VALUES (
 'fa050000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'routed_elsewhere','Missing destination',
 'oc-test-owner','owner','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 02:01:00+00'
)$$,'F4-OC-T05');

-- T06 — accepted triage can anchor SLA-2.
SAVEPOINT t06;
INSERT INTO maintenance.sla_instance(
 sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
 update_triage_uuid,clock_code,endpoint_type,time_basis,rule_snapshot_payload,
 start_at,nominal_due_at,execution_status
) VALUES (
 'fa060000-0000-0000-0000-000000000001',
 'fa06f000-0000-0000-0000-000000000001',
 'f5400000-0000-0000-0000-000000000002',
 'f4100000-0000-0000-0000-000000000003',
 'f5000000-0000-0000-0000-000000000001',
 'SLA2_TRIAGE_TO_MATERIALITY','materiality','elapsed_time',
 '{"fixture":true}'::jsonb,
 TIMESTAMPTZ '2026-10-07 00:32:00+00',
 TIMESTAMPTZ '2026-10-07 04:32:00+00','running'
);
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.sla_instance
 WHERE sla_instance_uuid='fa060000-0000-0000-0000-000000000001'
),'F4-OC-T06');
ROLLBACK TO SAVEPOINT t06; RELEASE SAVEPOINT t06;

-- T07 — invalid triage drift is detectable and guarded deferred.
SAVEPOINT t07;
INSERT INTO maintenance.update_triage(
 update_triage_uuid,update_signal_uuid,disposition,rationale,
 triaged_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,authority_status,triaged_at
) VALUES (
 'fa070000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'invalid_signal','Synthetic invalid disposition before signal invalidation',
 'oc-test-reviewer','human_reviewer','human_verified',
 'oc-test-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-07 02:02:00+00',
 'authoritative',TIMESTAMPTZ '2026-10-07 02:01:00+00'
);
SELECT pg_temp.assert_true(
 EXISTS(SELECT 1 FROM maintenance.update_triage_issues(
  'fa070000-0000-0000-0000-000000000001'
 ) WHERE issue_code='INVALID_TRIAGE_SIGNAL_STILL_ACTIVE')
 AND EXISTS(
   SELECT 1 FROM pg_trigger
    WHERE tgname='tr_update_triage_invalid_signal_deferred'
      AND tgdeferrable
 ),'F4-OC-T07');
ROLLBACK TO SAVEPOINT t07; RELEASE SAVEPOINT t07;

-- T08 — triage supersession preserves signal.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_triage(
 update_triage_uuid,update_signal_uuid,disposition,rationale,
 triaged_by,actor_type,verification_status,authority_status,triaged_at,
 record_status,supersedes_update_triage_uuid
) VALUES (
 'fa080000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'accepted_for_materiality','Wrong-signal supersession',
 'oc-test-reviewer','human_reviewer','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 02:05:00+00','superseded',
 'f5000000-0000-0000-0000-000000000001'
)$$,'F4-OC-T08');

-- T09 — one active priority per signal.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
 stage,response_class,authority_scope,authority_status,feasibility_status,
 risk_profile_snapshot,rationale,assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa090000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000003',
 'f4000000-0000-0000-0000-000000000001',
 'execution','standard','operational','proposal','adequate',
 pg_temp.risk(),'Duplicate active priority','oc-test-ai','ai_system',
 'unverified',TIMESTAMPTZ '2026-10-07 02:10:00+00'
)$$,'F4-OC-T09');

-- T10 — AI priority proposal allowed.
SAVEPOINT t10;
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
 stage,response_class,authority_scope,authority_status,feasibility_status,
 risk_profile_snapshot,rationale,assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa100000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'signal_triage','standard','operational','proposal','adequate',
 pg_temp.risk(),'AI proposal','oc-test-ai','ai_system','unverified',
 TIMESTAMPTZ '2026-10-07 02:10:00+00'
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.priority_assessment
 WHERE priority_assessment_uuid='fa100000-0000-0000-0000-000000000001'
 AND authority_status='proposal'),'F4-OC-T10');
ROLLBACK TO SAVEPOINT t10; RELEASE SAVEPOINT t10;

-- T11 — AI authoritative scientific priority rejected.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
 stage,response_class,authority_scope,authority_status,feasibility_status,
 risk_profile_snapshot,rationale,assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa110000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'signal_triage','expedited','scientific','authoritative','adequate',
 pg_temp.risk(),'AI authoritative invalid','oc-test-ai','ai_system','unverified',
 TIMESTAMPTZ '2026-10-07 02:10:00+00'
)$$,'F4-OC-T11');

-- T12 — owner cannot author authoritative scientific/mixed priority.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
 stage,response_class,authority_scope,authority_status,feasibility_status,
 risk_profile_snapshot,rationale,assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa120000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'signal_triage','expedited','mixed','authoritative','adequate',
 pg_temp.risk(),'Owner scientific priority invalid','oc-test-owner','owner','unverified',
 TIMESTAMPTZ '2026-10-07 02:10:00+00'
)$$,'F4-OC-T12');

-- T13 — AI-only materiality cannot support authoritative scientific priority.
SAVEPOINT t13;
SELECT pg_temp.add_signal('fa130000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001');
SELECT pg_temp.add_materiality('fa131000-0000-0000-0000-000000000001',
 'fa130000-0000-0000-0000-000000000001','potentially_material','ai_verified');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
 stage,response_class,authority_scope,authority_status,feasibility_status,
 materiality_assessment_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fa132000-0000-0000-0000-000000000001',
 'fa130000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'materiality_resolution','expedited','scientific','authoritative','adequate',
 'fa131000-0000-0000-0000-000000000001',pg_temp.risk(),
 'AI-only materiality invalid for authoritative priority',
 'oc-test-reviewer','human_reviewer','human_verified',
 'oc-test-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-07 02:05:00+00',
 TIMESTAMPTZ '2026-10-07 02:06:00+00'
)$$,'F4-OC-T13');
ROLLBACK TO SAVEPOINT t13; RELEASE SAVEPOINT t13;

-- T14 — response class domain closed.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
 stage,response_class,authority_scope,authority_status,feasibility_status,
 risk_profile_snapshot,rationale,assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa140000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'signal_triage','critical','operational','proposal','adequate',
 pg_temp.risk(),'Invalid class','oc-test-ai','ai_system','unverified',
 TIMESTAMPTZ '2026-10-07 02:10:00+00'
)$$,'F4-OC-T14');

-- T15 — immediate priority does not auto-create escalation.
SAVEPOINT t15;
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,
 stage,response_class,authority_scope,authority_status,feasibility_status,
 risk_profile_snapshot,rationale,assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa150000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'signal_triage','immediate','operational','proposal','adequate',
 pg_temp.risk(),'Immediate proposal without auto escalation',
 'oc-test-ai','ai_system','unverified',TIMESTAMPTZ '2026-10-07 02:10:00+00'
);
SELECT pg_temp.assert_true(
 NOT EXISTS(SELECT 1 FROM maintenance.escalation_case
  WHERE priority_assessment_uuid='fa150000-0000-0000-0000-000000000001'),
 'F4-OC-T15');
ROLLBACK TO SAVEPOINT t15; RELEASE SAVEPOINT t15;

-- T16–T19 — floor/non-compensation issue helpers.
SAVEPOINT t16_19;
SELECT pg_temp.add_signal('fa160000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
SELECT pg_temp.add_materiality('fa161000-0000-0000-0000-000000000001','fa160000-0000-0000-0000-000000000001','material_change_confirmed');
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 materiality_assessment_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'fa162000-0000-0000-0000-000000000001','fa160000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','materiality_resolution',
 'standard','scientific','authoritative','adequate','fa161000-0000-0000-0000-000000000001',
 pg_temp.risk('moderate','moderate','adequate'),'Confirmed isolated is modifier, not floor',
 'oc-test-reviewer','human_reviewer','human_verified','oc-test-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:05:00+00',TIMESTAMPTZ '2026-10-07 02:06:00+00'
);
SELECT pg_temp.assert_true(NOT EXISTS(
 SELECT 1 FROM maintenance.priority_assessment_issues('fa162000-0000-0000-0000-000000000001')
 WHERE issue_code='CONFIRMED_HIGH_CRITICALITY_FLOOR_VIOLATION'),'F4-OC-T16');

SELECT pg_temp.add_signal('fa170000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
SELECT pg_temp.add_materiality('fa171000-0000-0000-0000-000000000001','fa170000-0000-0000-0000-000000000001','material_change_confirmed');
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 materiality_assessment_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'fa172000-0000-0000-0000-000000000001','fa170000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','materiality_resolution',
 'standard','scientific','authoritative','adequate','fa171000-0000-0000-0000-000000000001',
 pg_temp.risk('high','moderate','adequate'),'Deliberate floor violation for issue helper',
 'oc-test-reviewer','human_reviewer','human_verified','oc-test-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:05:00+00',TIMESTAMPTZ '2026-10-07 02:06:00+00'
);
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.priority_assessment_issues('fa172000-0000-0000-0000-000000000001')
 WHERE issue_code='CONFIRMED_HIGH_CRITICALITY_FLOOR_VIOLATION'),'F4-OC-T17');

SELECT pg_temp.add_signal('fa180000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
SELECT pg_temp.add_materiality('fa181000-0000-0000-0000-000000000001','fa180000-0000-0000-0000-000000000001','potentially_material');
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 materiality_assessment_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'fa182000-0000-0000-0000-000000000001','fa180000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','materiality_resolution',
 'standard','scientific','authoritative','adequate','fa181000-0000-0000-0000-000000000001',
 pg_temp.risk('moderate','high','adequate'),'Deliberate potential/high-sensitivity floor violation',
 'oc-test-reviewer','human_reviewer','human_verified','oc-test-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:05:00+00',TIMESTAMPTZ '2026-10-07 02:06:00+00'
);
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.priority_assessment_issues('fa182000-0000-0000-0000-000000000001')
 WHERE issue_code='POTENTIAL_HIGH_RISK_FLOOR_VIOLATION'),'F4-OC-T18');

SELECT pg_temp.add_signal('fa190000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
SELECT pg_temp.add_materiality('fa191000-0000-0000-0000-000000000001','fa190000-0000-0000-0000-000000000001','validity_or_use_threat');
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 materiality_assessment_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'fa192000-0000-0000-0000-000000000001','fa190000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','materiality_resolution',
 'standard','scientific','authoritative','unavailable','fa191000-0000-0000-0000-000000000001',
 pg_temp.risk('moderate','moderate','unavailable'),'Capacity cannot reduce validity threat floor',
 'oc-test-reviewer','human_reviewer','human_verified','oc-test-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:05:00+00',TIMESTAMPTZ '2026-10-07 02:06:00+00'
);
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.priority_assessment_issues('fa192000-0000-0000-0000-000000000001')
 WHERE issue_code='VALIDITY_PRIORITY_FLOOR_VIOLATION'),'F4-OC-T19');
ROLLBACK TO SAVEPOINT t16_19; RELEASE SAVEPOINT t16_19;

-- T20 — Alert does not map automatically to transversal response class.
SAVEPOINT t20;
SELECT pg_temp.add_signal('fa200000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 alert_product_version_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa201000-0000-0000-0000-000000000001','fa200000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','signal_triage',
 'standard','operational','proposal','adequate',
 'a7100000-0000-0000-0000-000000000001',pg_temp.risk(),
 'Alert is an input; no automatic mapping',
 'oc-test-ai','ai_system','unverified',TIMESTAMPTZ '2026-10-07 02:10:00+00'
);
SELECT pg_temp.assert_true((SELECT response_class='standard'
 FROM maintenance.priority_assessment
 WHERE priority_assessment_uuid='fa201000-0000-0000-0000-000000000001'),'F4-OC-T20');
ROLLBACK TO SAVEPOINT t20; RELEASE SAVEPOINT t20;

-- T21 — strong Alert downgrade is allowed only with explicit rationale, no mapping.
SAVEPOINT t21;
SELECT pg_temp.add_signal('fa210000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000002');
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 alert_product_version_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fa211000-0000-0000-0000-000000000001','fa210000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000002','signal_triage',
 'standard','operational','proposal','adequate',
 'a7100000-0000-0000-0000-000000000003',pg_temp.risk(),
 'Explicit reconciliation rationale: Alert urgency is communicational, materiality unresolved',
 'oc-test-ai','ai_system','unverified',TIMESTAMPTZ '2026-10-07 02:10:00+00'
);
SELECT pg_temp.assert_true(
 (SELECT classification='critical' AND reassessment_priority='urgent'
    FROM maintenance.evidence_alert
   WHERE alert_product_version_uuid='a7100000-0000-0000-0000-000000000003')
 AND
 (SELECT response_class='standard' AND length(btrim(rationale))>0
    FROM maintenance.priority_assessment
   WHERE priority_assessment_uuid='fa211000-0000-0000-0000-000000000001'),
 'F4-OC-T21');
ROLLBACK TO SAVEPOINT t21; RELEASE SAVEPOINT t21;

-- T22 — SLA breach basis is operational pressure, not materiality.
SAVEPOINT t22;
INSERT INTO maintenance.priority_basis(
 priority_assessment_uuid,basis_code,basis_effect,basis_value,
 source_type,sla_instance_uuid,rationale,sequence_no
) VALUES (
 'f5100000-0000-0000-0000-000000000001',
 'sla_breach','operational_pressure','breached_open',
 'sla_instance','f5600000-0000-0000-0000-000000000001',
 'Breach changes operational pressure only',3
);
SELECT pg_temp.assert_true(
 (SELECT basis_effect='operational_pressure' FROM maintenance.priority_basis
  WHERE priority_assessment_uuid='f5100000-0000-0000-0000-000000000001'
    AND basis_code='sla_breach')
 AND
 (SELECT outcome='potentially_material' FROM maintenance.materiality_assessment
  WHERE materiality_assessment_uuid='f4310000-0000-0000-0000-000000000001'),
 'F4-OC-T22');
ROLLBACK TO SAVEPOINT t22; RELEASE SAVEPOINT t22;

-- T23 — queue aggregation is derived: no aggregate priority table and active case remains per signal.
SELECT pg_temp.assert_true(
 NOT EXISTS(SELECT 1 FROM information_schema.tables
  WHERE table_schema='maintenance' AND table_name IN ('priority_queue','aggregate_priority'))
 AND EXISTS(SELECT 1 FROM pg_indexes
  WHERE schemaname='maintenance' AND indexname='ux_priority_assessment_active_signal'),
 'F4-OC-T23');

-- T24–T30 — escalation lifecycle/routes.
SAVEPOINT t24_30;
INSERT INTO maintenance.escalation_case(
 escalation_case_uuid,update_signal_uuid,status,opened_at,opened_by,actor_type
) VALUES (
 'fa240000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'candidate',TIMESTAMPTZ '2026-10-07 02:20:00+00','oc-test-system','system'
);
SELECT pg_temp.assert_true((SELECT status='candidate' FROM maintenance.escalation_case
 WHERE escalation_case_uuid='fa240000-0000-0000-0000-000000000001'),'F4-OC-T24');

SELECT pg_temp.expect_error($$
INSERT INTO maintenance.escalation_case(
 escalation_case_uuid,update_signal_uuid,status,opened_at,activated_at,
 opened_by,actor_type,activated_by,activation_actor_type
) VALUES (
 'fa250000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'active',TIMESTAMPTZ '2026-10-07 02:20:00+00',
 TIMESTAMPTZ '2026-10-07 02:21:00+00',
 'oc-test-system','system','oc-test-system','system'
)$$,'F4-OC-T25');

INSERT INTO maintenance.escalation_case(
 escalation_case_uuid,update_signal_uuid,status,opened_at,activated_at,
 opened_by,actor_type,activated_by,activation_actor_type
) VALUES (
 'fa260000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'active',TIMESTAMPTZ '2026-10-07 02:20:00+00',
 TIMESTAMPTZ '2026-10-07 02:21:00+00',
 'oc-test-system','system','oc-test-owner','owner'
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.escalation_case_issues(
 'fa260000-0000-0000-0000-000000000001') WHERE issue_code='ESCALATION_REASON_REQUIRED'),'F4-OC-T26');
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.escalation_case_issues(
 'fa260000-0000-0000-0000-000000000001') WHERE issue_code='ESCALATION_ROUTE_REQUIRED'),'F4-OC-T27');

INSERT INTO maintenance.escalation_reason(
 escalation_case_uuid,reason_code,rationale,sequence_no
) VALUES
('fa260000-0000-0000-0000-000000000001','safety_integrity','Safety reason',1),
('fa260000-0000-0000-0000-000000000001','validity_or_use','Validity reason',2),
('fa260000-0000-0000-0000-000000000001','capacity_constraint','Capacity reason',3);
INSERT INTO maintenance.escalation_route(
 escalation_case_uuid,route_code,route_status,requested_at,sequence_no
) VALUES (
 'fa260000-0000-0000-0000-000000000001',
 'current_use_governance','requested',TIMESTAMPTZ '2026-10-07 02:22:00+00',1
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.escalation_case_issues(
 'fa260000-0000-0000-0000-000000000001') WHERE issue_code='SAFETY_ROUTE_REQUIRED'),'F4-OC-T28');
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.escalation_case_issues(
 'fa260000-0000-0000-0000-000000000001') WHERE issue_code='VALIDITY_ROUTES_REQUIRED'),'F4-OC-T29');
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.escalation_case_issues(
 'fa260000-0000-0000-0000-000000000001') WHERE issue_code='RESOURCE_ROUTE_REQUIRED'),'F4-OC-T30');
ROLLBACK TO SAVEPOINT t24_30; RELEASE SAVEPOINT t24_30;

-- T31 — resolved requires disposition/rationale.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.escalation_case(
 escalation_case_uuid,update_signal_uuid,status,opened_at,activated_at,resolved_at,
 opened_by,actor_type,activated_by,activation_actor_type
) VALUES (
 'fa310000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'resolved',TIMESTAMPTZ '2026-10-07 02:20:00+00',
 TIMESTAMPTZ '2026-10-07 02:21:00+00',TIMESTAMPTZ '2026-10-07 02:30:00+00',
 'oc-test-system','system','oc-test-owner','owner'
)$$,'F4-OC-T31');

-- T32 — cancelled requires rationale.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.escalation_case(
 escalation_case_uuid,update_signal_uuid,status,opened_at,activated_at,cancelled_at,
 opened_by,actor_type,activated_by,activation_actor_type
) VALUES (
 'fa320000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'cancelled_invalidated',TIMESTAMPTZ '2026-10-07 02:20:00+00',
 TIMESTAMPTZ '2026-10-07 02:21:00+00',TIMESTAMPTZ '2026-10-07 02:30:00+00',
 'oc-test-system','system','oc-test-owner','owner'
)$$,'F4-OC-T32');

-- T33 — escalation resolution does not change CurrencyState.
SAVEPOINT t33;
INSERT INTO maintenance.escalation_case(
 escalation_case_uuid,update_signal_uuid,status,opened_at,activated_at,resolved_at,
 opened_by,actor_type,activated_by,activation_actor_type,
 resolution_disposition,resolution_rationale
) VALUES (
 'fa330000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'resolved',TIMESTAMPTZ '2026-10-07 02:20:00+00',
 TIMESTAMPTZ '2026-10-07 02:21:00+00',TIMESTAMPTZ '2026-10-07 02:30:00+00',
 'oc-test-system','system','oc-test-owner','owner',
 'review_coordinated','Operational escalation resolved'
);
SELECT pg_temp.assert_true((SELECT currency_status='under_evaluation'
 FROM product.currency_state WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000003'),'F4-OC-T33');
ROLLBACK TO SAVEPOINT t33; RELEASE SAVEPOINT t33;

-- T34 — business calendar rule requires calendar version.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_rule(
 sla_rule_uuid,rule_code,update_policy_uuid,clock_code,selection_precedence,
 endpoint_type,time_basis,target_duration,pause_allowed,effective_at,
 rationale,created_by,actor_type,record_status
) VALUES (
 'fa340000-0000-0000-0000-000000000001','t34',
 'f4000000-0000-0000-0000-000000000001','SLA1_DETECTION_TO_TRIAGE',99,
 'triage','business_calendar',interval '1 hour',true,
 TIMESTAMPTZ '2026-10-07 02:00:00+00','Missing calendar',
 'oc-test-owner','owner','superseded'
)$$,'F4-OC-T34');

-- T35 — fixed deadline non-pausable by default.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_rule(
 sla_rule_uuid,rule_code,update_policy_uuid,clock_code,selection_precedence,
 endpoint_type,time_basis,fixed_deadline_rule_payload,pause_allowed,effective_at,
 rationale,created_by,actor_type,record_status
) VALUES (
 'fa350000-0000-0000-0000-000000000001','t35',
 'f4000000-0000-0000-0000-000000000001','SLA1_DETECTION_TO_TRIAGE',98,
 'triage','fixed_deadline',
 '{"deadline_source_type":"manual_governance","deadline_at":"2026-10-08T00:00:00Z","time_precision":"timestamp","rationale":"test"}'::jsonb,
 true,TIMESTAMPTZ '2026-10-07 02:00:00+00','Pausable fixed deadline invalid',
 'oc-test-owner','owner','superseded'
)$$,'F4-OC-T35');

-- T36 — operational rule requires deterministic duration/deadline.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_rule(
 sla_rule_uuid,rule_code,update_policy_uuid,clock_code,selection_precedence,
 endpoint_type,time_basis,pause_allowed,effective_at,rationale,created_by,actor_type,record_status
) VALUES (
 'fa360000-0000-0000-0000-000000000001','t36',
 'f4000000-0000-0000-0000-000000000001','SLA1_DETECTION_TO_TRIAGE',97,
 'triage','elapsed_time',false,TIMESTAMPTZ '2026-10-07 02:00:00+00',
 'Missing duration','oc-test-owner','owner','superseded'
)$$,'F4-OC-T36');

-- T37 — active rule selection precedence cannot be ambiguous.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_rule(
 sla_rule_uuid,rule_code,update_policy_uuid,clock_code,selection_precedence,
 endpoint_type,time_basis,target_duration,pause_allowed,effective_at,
 rationale,created_by,actor_type
) VALUES (
 'fa370000-0000-0000-0000-000000000001','t37',
 'f4000000-0000-0000-0000-000000000001','SLA1_DETECTION_TO_TRIAGE',1,
 'triage','elapsed_time',interval '1 hour',false,
 TIMESTAMPTZ '2026-10-07 02:00:00+00','Duplicate precedence',
 'oc-test-owner','owner'
)$$,'F4-OC-T37');

-- T38 — supersession must preserve temporal order.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_rule(
 sla_rule_uuid,rule_code,update_policy_uuid,clock_code,selection_precedence,
 endpoint_type,time_basis,target_duration,pause_allowed,effective_at,
 rationale,created_by,actor_type,record_status,supersedes_sla_rule_uuid
) VALUES (
 'fa380000-0000-0000-0000-000000000001','fixture-sla1',
 'f4000000-0000-0000-0000-000000000001','SLA1_DETECTION_TO_TRIAGE',9,
 'triage','elapsed_time',interval '3 hours',false,
 TIMESTAMPTZ '2026-10-06 23:00:00+00','Backdated supersession',
 'oc-test-owner','owner','superseded','f5400000-0000-0000-0000-000000000001'
)$$,'F4-OC-T38');

-- T39 — no normative numeric defaults exist outside explicit test fixtures.
SELECT pg_temp.assert_true(
 NOT EXISTS(SELECT 1 FROM maintenance.sla_rule
  WHERE created_by<>'fixture-owner' AND record_status='active'),
 'F4-OC-T39');

-- T40 — response class does not carry duration.
SELECT pg_temp.assert_true(
 NOT EXISTS(SELECT 1 FROM information_schema.columns
  WHERE table_schema='maintenance' AND table_name='priority_assessment'
    AND column_name IN ('target_duration','due_at','sla_hours','sla_days')),
 'F4-OC-T40');

-- T41 — SLA rule snapshot frozen in instance.
SELECT pg_temp.expect_error($$
UPDATE maintenance.sla_instance
   SET rule_snapshot_payload='{"mutated":true}'::jsonb
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000001'
$$,'F4-OC-T41');

-- T42 — SLA1 fixture starts from upstream detection.
SELECT pg_temp.assert_true(
 (SELECT i.source_detected_at=s.detected_at AND i.start_at=s.detected_at
    FROM maintenance.sla_instance i
    JOIN maintenance.update_signal s USING(update_signal_uuid)
   WHERE i.sla_instance_uuid='f5600000-0000-0000-0000-000000000001'),
 'F4-OC-T42');

-- T43 — pre-policy age preserved without retroactive breach.
SAVEPOINT t43;
SELECT pg_temp.add_signal('fa430000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-06 23:00:00+00');
INSERT INTO maintenance.sla_instance(
 sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
 clock_code,endpoint_type,time_basis,rule_snapshot_payload,
 source_detected_at,pre_policy_age,start_at,nominal_due_at,execution_status
) VALUES (
 'fa431000-0000-0000-0000-000000000001',
 'fa43f000-0000-0000-0000-000000000001',
 'f5400000-0000-0000-0000-000000000001',
 'fa430000-0000-0000-0000-000000000001',
 'SLA1_DETECTION_TO_TRIAGE','triage','elapsed_time','{"fixture":true}'::jsonb,
 TIMESTAMPTZ '2026-10-06 23:00:00+00',interval '1 hour',
 TIMESTAMPTZ '2026-10-07 00:00:00+00',TIMESTAMPTZ '2026-10-07 02:00:00+00','pending'
);
SELECT pg_temp.assert_true(
 (SELECT pre_policy_age=interval '1 hour' AND first_breached_at IS NULL
  FROM maintenance.sla_instance
  WHERE sla_instance_uuid='fa431000-0000-0000-0000-000000000001'),
 'F4-OC-T43');
ROLLBACK TO SAVEPOINT t43; RELEASE SAVEPOINT t43;

-- T44 — SLA2 requires accepted authoritative triage.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_instance(
 sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
 clock_code,endpoint_type,time_basis,rule_snapshot_payload,
 start_at,nominal_due_at,execution_status
) VALUES (
 'fa440000-0000-0000-0000-000000000001',
 'fa44f000-0000-0000-0000-000000000001',
 'f5400000-0000-0000-0000-000000000002',
 'f4100000-0000-0000-0000-000000000002',
 'SLA2_TRIAGE_TO_MATERIALITY','materiality','elapsed_time','{"fixture":true}'::jsonb,
 TIMESTAMPTZ '2026-10-07 02:00:00+00',TIMESTAMPTZ '2026-10-07 06:00:00+00','running'
)$$,'F4-OC-T44');

-- T45 — AI-only materiality cannot satisfy SLA2.
SAVEPOINT t45;
SELECT pg_temp.add_signal('fa450000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
INSERT INTO maintenance.update_triage(
 update_triage_uuid,update_signal_uuid,disposition,rationale,
 triaged_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,triaged_at
) VALUES (
 'fa451000-0000-0000-0000-000000000001','fa450000-0000-0000-0000-000000000001',
 'accepted_for_materiality','Accepted','oc-test-reviewer','human_reviewer',
 'human_verified','oc-test-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:02:00+00','authoritative',
 TIMESTAMPTZ '2026-10-07 02:01:00+00'
);
SELECT pg_temp.add_materiality('fa452000-0000-0000-0000-000000000001',
 'fa450000-0000-0000-0000-000000000001','potentially_material','ai_verified');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_instance(
 sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
 update_triage_uuid,materiality_assessment_uuid,
 clock_code,endpoint_type,time_basis,rule_snapshot_payload,
 start_at,nominal_due_at,end_at,execution_status,satisfied_at
) VALUES (
 'fa453000-0000-0000-0000-000000000001','fa45f000-0000-0000-0000-000000000001',
 'f5400000-0000-0000-0000-000000000002','fa450000-0000-0000-0000-000000000001',
 'fa451000-0000-0000-0000-000000000001','fa452000-0000-0000-0000-000000000001',
 'SLA2_TRIAGE_TO_MATERIALITY','materiality','elapsed_time','{"fixture":true}'::jsonb,
 TIMESTAMPTZ '2026-10-07 02:01:00+00',TIMESTAMPTZ '2026-10-07 06:01:00+00',
 TIMESTAMPTZ '2026-10-07 02:04:00+00','satisfied',TIMESTAMPTZ '2026-10-07 02:04:00+00'
)$$,'F4-OC-T45');
ROLLBACK TO SAVEPOINT t45; RELEASE SAVEPOINT t45;

-- T46 — proposal UpdateDecision cannot satisfy SLA3.
SAVEPOINT t46;
SELECT pg_temp.add_signal('fa460000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
SELECT pg_temp.add_materiality('fa461000-0000-0000-0000-000000000001',
 'fa460000-0000-0000-0000-000000000001','no_material_change');
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,decided_at
) VALUES (
 'fa462000-0000-0000-0000-000000000001','fa460000-0000-0000-0000-000000000001',
 'fa461000-0000-0000-0000-000000000001','no_scientific_update','proposal','no_change',
 'Proposal only','oc-test-ai','ai_system','unverified',TIMESTAMPTZ '2026-10-07 02:06:00+00'
);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_instance(
 sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
 materiality_assessment_uuid,update_decision_uuid,
 clock_code,endpoint_type,time_basis,rule_snapshot_payload,
 start_at,nominal_due_at,end_at,execution_status,satisfied_at
) VALUES (
 'fa463000-0000-0000-0000-000000000001','fa46f000-0000-0000-0000-000000000001',
 'f5400000-0000-0000-0000-000000000003','fa460000-0000-0000-0000-000000000001',
 'fa461000-0000-0000-0000-000000000001','fa462000-0000-0000-0000-000000000001',
 'SLA3_MATERIALITY_TO_DECISION','update_decision','elapsed_time','{"fixture":true}'::jsonb,
 TIMESTAMPTZ '2026-10-07 02:04:00+00',TIMESTAMPTZ '2026-10-07 06:04:00+00',
 TIMESTAMPTZ '2026-10-07 02:06:00+00','satisfied',TIMESTAMPTZ '2026-10-07 02:06:00+00'
)$$,'F4-OC-T46');
ROLLBACK TO SAVEPOINT t46; RELEASE SAVEPOINT t46;

-- T47 — SLA3 endpoint uses qualified decision timestamp.
SAVEPOINT t47;
INSERT INTO maintenance.sla_instance(
 sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,
 materiality_assessment_uuid,update_decision_uuid,
 clock_code,endpoint_type,time_basis,rule_snapshot_payload,
 start_at,nominal_due_at,end_at,execution_status,satisfied_at
) VALUES (
 'fa470000-0000-0000-0000-000000000001','fa47f000-0000-0000-0000-000000000001',
 'f5400000-0000-0000-0000-000000000003','f4100000-0000-0000-0000-000000000003',
 'f4310000-0000-0000-0000-000000000001','f4410000-0000-0000-0000-000000000001',
 'SLA3_MATERIALITY_TO_DECISION','update_decision','elapsed_time','{"fixture":true}'::jsonb,
 TIMESTAMPTZ '2026-10-07 00:37:00+00',TIMESTAMPTZ '2026-10-07 04:37:00+00',
 TIMESTAMPTZ '2026-10-07 00:41:00+00','satisfied',TIMESTAMPTZ '2026-10-07 00:41:00+00'
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.sla_instance
 WHERE sla_instance_uuid='fa470000-0000-0000-0000-000000000001'),'F4-OC-T47');
ROLLBACK TO SAVEPOINT t47; RELEASE SAVEPOINT t47;

-- T48 — SLA4/workflow only when decision is workflow-applicable.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.workflow_round(
 workflow_round_uuid,update_signal_uuid,update_decision_uuid,round_type,round_no,
 target_product_version_uuid,status,opened_at,rationale,created_by,actor_type
) VALUES (
 'fa480000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4400000-0000-0000-0000-000000000001',
 'scientific_update',9,'e5100000-0000-0000-0000-000000000003',
 'planned',TIMESTAMPTZ '2026-10-07 02:00:00+00',
 'currentness-only decision cannot open scientific round','oc-test-owner','owner'
)$$,'F4-OC-T48');

-- T49 — SLA5 requires explicit authoritative workflow start.
SAVEPOINT t49;
INSERT INTO maintenance.workflow_round(
 workflow_round_uuid,update_signal_uuid,update_decision_uuid,round_type,round_no,
 target_product_version_uuid,status,opened_at,rationale,created_by,actor_type
) VALUES (
 'fa490000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000003',
 'f4410000-0000-0000-0000-000000000001',
 'scientific_update',2,'e5100000-0000-0000-0000-000000000003',
 'planned',TIMESTAMPTZ '2026-10-07 02:00:00+00',
 'Second test round without start milestone','oc-test-owner','owner'
);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.sla_instance(
 sla_instance_uuid,obligation_uuid,sla_rule_uuid,update_signal_uuid,workflow_round_uuid,
 clock_code,endpoint_type,time_basis,rule_snapshot_payload,
 start_at,nominal_due_at,execution_status
) VALUES (
 'fa491000-0000-0000-0000-000000000001','fa49f000-0000-0000-0000-000000000001',
 'f5400000-0000-0000-0000-000000000005','f4100000-0000-0000-0000-000000000003',
 'fa490000-0000-0000-0000-000000000001',
 'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION','scientific_completed','business_calendar',
 '{"fixture":true}'::jsonb,TIMESTAMPTZ '2026-10-07 02:00:00+00',
 TIMESTAMPTZ '2026-10-08 18:00:00+00','running'
)$$,'F4-OC-T49');
ROLLBACK TO SAVEPOINT t49; RELEASE SAVEPOINT t49;

-- T50 — SLA endpoint snapshot cannot change after start.
SELECT pg_temp.expect_error($$
UPDATE maintenance.sla_instance
   SET endpoint_type='publication'
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000001'
$$,'F4-OC-T50');

-- T51 — first breach is immutable once materialized.
SAVEPOINT t51;
UPDATE maintenance.sla_instance
   SET first_breached_at=TIMESTAMPTZ '2026-10-07 01:00:00+00'
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005';
SELECT pg_temp.expect_error($$
UPDATE maintenance.sla_instance
   SET first_breached_at=TIMESTAMPTZ '2026-10-07 01:05:00+00'
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005'
$$,'F4-OC-T51');
ROLLBACK TO SAVEPOINT t51; RELEASE SAVEPOINT t51;

-- T52 — late satisfaction preserves breached_then_satisfied.
SAVEPOINT t52;
UPDATE maintenance.sla_instance
   SET first_breached_at=TIMESTAMPTZ '2026-10-07 00:31:00+00'
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000001';
SELECT pg_temp.assert_true(
 maintenance.sla_compliance_status('f5600000-0000-0000-0000-000000000001')='breached_then_satisfied',
 'F4-OC-T52');
ROLLBACK TO SAVEPOINT t52; RELEASE SAVEPOINT t52;

-- T53 — later priority does not recalculate existing SLA due.
SAVEPOINT t53;
UPDATE maintenance.priority_assessment SET record_status='superseded'
 WHERE priority_assessment_uuid='f5100000-0000-0000-0000-000000000001';
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 triggering_sla_instance_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,assessed_at,
 supersedes_priority_assessment_uuid
) VALUES (
 'fa530000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000003',
 'f4000000-0000-0000-0000-000000000001','execution',
 'urgent','operational','authoritative','adequate',
 'f5600000-0000-0000-0000-000000000001',pg_temp.risk(),
 'Later SLA-informed priority','oc-test-owner','owner','unverified',
 TIMESTAMPTZ '2026-10-07 03:00:00+00',
 'f5100000-0000-0000-0000-000000000001'
);
SELECT pg_temp.assert_true(
 (SELECT nominal_due_at=TIMESTAMPTZ '2026-10-07 02:30:00+00'
  FROM maintenance.sla_instance
  WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000001'),
 'F4-OC-T53');
ROLLBACK TO SAVEPOINT t53; RELEASE SAVEPOINT t53;

-- T54 — pause after breach does not erase first breach.
SAVEPOINT t54;
UPDATE maintenance.sla_instance
   SET first_breached_at=TIMESTAMPTZ '2026-10-07 02:00:00+00'
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005';
INSERT INTO maintenance.sla_pause(
 sla_pause_uuid,sla_instance_uuid,reason_code,rationale,
 authorized_by,actor_type,authorized_at,started_at,
 ended_at,closed_by,closed_at
) VALUES (
 'fa540000-0000-0000-0000-000000000001',
 'f5600000-0000-0000-0000-000000000005',
 'external_dependency','Post-breach pause test','oc-test-owner','owner',
 TIMESTAMPTZ '2026-10-07 02:05:00+00',TIMESTAMPTZ '2026-10-07 02:05:00+00',
 TIMESTAMPTZ '2026-10-07 02:10:00+00','oc-test-owner',
 TIMESTAMPTZ '2026-10-07 02:10:00+00'
);
SELECT pg_temp.assert_true(
 (SELECT first_breached_at=TIMESTAMPTZ '2026-10-07 02:00:00+00'
  FROM maintenance.sla_instance
  WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005'),
 'F4-OC-T54');
ROLLBACK TO SAVEPOINT t54; RELEASE SAVEPOINT t54;

-- T55 — WorkflowRound target XOR.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.workflow_round(
 workflow_round_uuid,update_signal_uuid,update_decision_uuid,round_type,round_no,
 target_product_version_uuid,target_investigation_version_uuid,status,opened_at,
 rationale,created_by,actor_type
) VALUES (
 'fa550000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000003','f4410000-0000-0000-0000-000000000001',
 'scientific_update',9,'e5100000-0000-0000-0000-000000000003',
 'e5100000-0000-0000-0000-000000000002','planned',
 TIMESTAMPTZ '2026-10-07 02:00:00+00','Two targets invalid','oc-test-owner','owner'
)$$,'F4-OC-T55');

-- T56 — WorkflowRound does not auto-create result versions.
SELECT pg_temp.assert_true(
 (SELECT result_product_version_uuid IS NULL AND result_investigation_version_uuid IS NULL
  FROM maintenance.workflow_round
  WHERE workflow_round_uuid='f5500000-0000-0000-0000-000000000001'),
 'F4-OC-T56');

-- T57 — planned round does not infer a start from ticket/draft.
SAVEPOINT t57;
INSERT INTO maintenance.workflow_round(
 workflow_round_uuid,update_signal_uuid,update_decision_uuid,round_type,round_no,
 target_product_version_uuid,status,opened_at,rationale,created_by,actor_type
) VALUES (
 'fa570000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000003','f4410000-0000-0000-0000-000000000001',
 'scientific_update',3,'e5100000-0000-0000-0000-000000000003','planned',
 TIMESTAMPTZ '2026-10-07 02:00:00+00','Planned only','oc-test-owner','owner'
);
SELECT pg_temp.assert_true(NOT EXISTS(
 SELECT 1 FROM maintenance.workflow_milestone
 WHERE workflow_round_uuid='fa570000-0000-0000-0000-000000000001'
 AND milestone_type IN ('scientific_workflow_started','methodological_workflow_started')
),'F4-OC-T57');
ROLLBACK TO SAVEPOINT t57; RELEASE SAVEPOINT t57;

-- T58 — scientific completion milestone is not review/publication.
SAVEPOINT t58;
INSERT INTO maintenance.workflow_milestone(
 workflow_milestone_uuid,workflow_round_uuid,milestone_type,adapter_type,
 time_precision,occurred_at,qualified_at,authority_status,actor,actor_type,rationale
) VALUES (
 'fa580000-0000-0000-0000-000000000001',
 'f5500000-0000-0000-0000-000000000001','scientific_workflow_completed',
 'native_event','timestamp',TIMESTAMPTZ '2026-10-07 03:00:00+00',
 TIMESTAMPTZ '2026-10-07 03:00:00+00','authoritative',
 'oc-test-reviewer','human_reviewer','Scientific completion only'
);
SELECT pg_temp.assert_true(
 NOT EXISTS(SELECT 1 FROM product.review_record WHERE reviewer='oc-test-reviewer')
 AND NOT EXISTS(SELECT 1 FROM product.assurance_record WHERE actor='oc-test-reviewer'),
 'F4-OC-T58');
ROLLBACK TO SAVEPOINT t58; RELEASE SAVEPOINT t58;

-- T59 — review milestone can adapt an existing structured assurance record.
SAVEPOINT t59;
INSERT INTO maintenance.workflow_milestone(
 workflow_milestone_uuid,workflow_round_uuid,milestone_type,adapter_type,
 time_precision,occurred_at,authority_status,actor,actor_type,
 assurance_uuid,rationale
) VALUES (
 'fa590000-0000-0000-0000-000000000001',
 'f5500000-0000-0000-0000-000000000001','review_disposition',
 'assurance_record','timestamp',TIMESTAMPTZ '2026-10-07 03:10:00+00',
 'authoritative','fixture-owner','owner',
 'e5600000-0000-0000-0000-000000000002','Structured assurance adapter'
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.workflow_milestone
 WHERE workflow_milestone_uuid='fa590000-0000-0000-0000-000000000001'
 AND adapter_type='assurance_record' AND assurance_uuid IS NOT NULL),'F4-OC-T59');
ROLLBACK TO SAVEPOINT t59; RELEASE SAVEPOINT t59;

-- T60 — revise disposition may open a child review_revision round.
SAVEPOINT t60;
INSERT INTO product.review_record(
 review_uuid,product_version_uuid,reviewer,role,independent_flag,
 decision,reviewed_at,notes,status
) VALUES (
 'fa600000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',
 'oc-test-reviewer','synthetic_test',false,'revise',
 TIMESTAMPTZ '2026-10-07 03:20:00+00','TEST-ONLY review fixture','active'
);
INSERT INTO maintenance.workflow_milestone(
 workflow_milestone_uuid,workflow_round_uuid,milestone_type,adapter_type,
 time_precision,occurred_at,authority_status,actor,actor_type,
 product_review_uuid,rationale
) VALUES (
 'fa601000-0000-0000-0000-000000000001',
 'f5500000-0000-0000-0000-000000000001','review_disposition',
 'product_review','timestamp',TIMESTAMPTZ '2026-10-07 03:20:00+00',
 'authoritative','oc-test-reviewer','human_reviewer',
 'fa600000-0000-0000-0000-000000000001','Revise disposition'
);
INSERT INTO maintenance.workflow_round(
 workflow_round_uuid,update_signal_uuid,update_decision_uuid,round_type,round_no,
 parent_workflow_round_uuid,opened_by_workflow_milestone_uuid,
 target_product_version_uuid,status,opened_at,rationale,created_by,actor_type
) VALUES (
 'fa602000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000003','f4410000-0000-0000-0000-000000000001',
 'review_revision',2,'f5500000-0000-0000-0000-000000000001',
 'fa601000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003','planned',
 TIMESTAMPTZ '2026-10-07 03:21:00+00','Revision round after review disposition',
 'oc-test-owner','owner'
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.workflow_round
 WHERE workflow_round_uuid='fa602000-0000-0000-0000-000000000001'
 AND parent_workflow_round_uuid='f5500000-0000-0000-0000-000000000001'),'F4-OC-T60');
ROLLBACK TO SAVEPOINT t60; RELEASE SAVEPOINT t60;

-- T61 — publication milestone requires real publication date.
SAVEPOINT t61;
INSERT INTO maintenance.workflow_milestone(
 workflow_milestone_uuid,workflow_round_uuid,milestone_type,adapter_type,
 time_precision,occurred_date,authority_status,actor,actor_type,
 product_version_uuid,rationale
) VALUES (
 'fa610000-0000-0000-0000-000000000001',
 'f5500000-0000-0000-0000-000000000001','publication','product_version',
 'date',DATE '2026-10-01','authoritative','oc-test-owner','owner',
 'e5100000-0000-0000-0000-000000000003','Publication adapter to real published fixture'
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.workflow_milestone
 WHERE workflow_milestone_uuid='fa610000-0000-0000-0000-000000000001'),'F4-OC-T61');
ROLLBACK TO SAVEPOINT t61; RELEASE SAVEPOINT t61;

-- T62 — reroute_method cannot masquerade as scientific_update.
SAVEPOINT t62;
SELECT pg_temp.add_signal('fa620000-0000-0000-0000-000000000001','f4000000-0000-0000-0000-000000000001');
SELECT pg_temp.add_materiality('fa621000-0000-0000-0000-000000000001',
 'fa620000-0000-0000-0000-000000000001','potentially_material');
INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale,sequence_no
) VALUES (
 'fa621000-0000-0000-0000-000000000001',
 'method','potential','Synthetic methodological dimension required by existing F4 contract',1
);
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,decided_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'fa622000-0000-0000-0000-000000000001','fa620000-0000-0000-0000-000000000001',
 'fa621000-0000-0000-0000-000000000001','reroute_method','authoritative','no_change',
 'Method reroute','oc-test-reviewer','human_reviewer','human_verified',
 'oc-test-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-07 02:07:00+00',
 TIMESTAMPTZ '2026-10-07 02:06:00+00'
);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.workflow_round(
 workflow_round_uuid,update_signal_uuid,update_decision_uuid,round_type,round_no,
 target_product_version_uuid,status,opened_at,rationale,created_by,actor_type
) VALUES (
 'fa623000-0000-0000-0000-000000000001','fa620000-0000-0000-0000-000000000001',
 'fa622000-0000-0000-0000-000000000001','scientific_update',1,
 'e5100000-0000-0000-0000-000000000003','planned',
 TIMESTAMPTZ '2026-10-07 02:08:00+00','Wrong round type','oc-test-owner','owner'
)$$,'F4-OC-T62');
ROLLBACK TO SAVEPOINT t62; RELEASE SAVEPOINT t62;

-- T63 — WorkflowRound causal fields cannot be overwritten.
SELECT pg_temp.expect_error($$
UPDATE maintenance.workflow_round
   SET round_no=99
 WHERE workflow_round_uuid='f5500000-0000-0000-0000-000000000001'
$$,'F4-OC-T63');

-- T64 — migration 027/028 update semantics remain intact.
SELECT pg_temp.assert_true(
 (SELECT authority_status='authoritative' AND currency_action='set_under_evaluation'
  FROM maintenance.update_decision
  WHERE update_decision_uuid='f4400000-0000-0000-0000-000000000001')
 AND
 (SELECT currency_status='under_evaluation'
  FROM product.currency_state
  WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000003'),
 'F4-OC-T64');

-- T65 — MethodDecision remains a distinct investigation object.
SELECT pg_temp.assert_true(
 EXISTS(SELECT 1 FROM information_schema.tables
  WHERE table_schema='investigation' AND table_name='method_decision')
 AND EXISTS(SELECT 1 FROM information_schema.tables
  WHERE table_schema='maintenance' AND table_name='update_decision'),
 'F4-OC-T65');

-- T66 — ReviewRecord and AssuranceRecord remain distinct.
SELECT pg_temp.assert_true(
 EXISTS(SELECT 1 FROM information_schema.tables
  WHERE table_schema='product' AND table_name='review_record')
 AND EXISTS(SELECT 1 FROM information_schema.tables
  WHERE table_schema='product' AND table_name='assurance_record'),
 'F4-OC-T66');

-- T67 — operational-control objects do not change CurrencyState.
SELECT pg_temp.assert_true(
 (SELECT currency_status='under_evaluation' AND record_status='active'
  FROM product.currency_state
  WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000003'),
 'F4-OC-T67');

-- T68 — Monitor and Alert publication semantics intact.
SELECT pg_temp.assert_true(
 product.evidence_monitor_is_publishable('e5100000-0000-0000-0000-000000000005')
 AND product.evidence_alert_is_publishable('a7100000-0000-0000-0000-000000000001'),
 'F4-OC-T68');

-- T69 — M3 blocker preserved.
SELECT pg_temp.assert_true(
 EXISTS(SELECT 1 FROM maintenance.operational_control_readiness(
  'f4000000-0000-0000-0000-000000000002'
 ) WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL' AND severity='error')
 AND NOT product.evidence_monitor_is_publishable('e5100000-0000-0000-0000-000000000007'),
 'F4-OC-T69');

SELECT 'F4-OC-T01–T69 PASS — integrated operational-control SQL contract validated'
AS f4_operational_control_sql_status;

-- T70 — migration 029 idempotency: workflow evidence.
-- T71 — rebuild-from-zero through 029: workflow evidence.
-- T72 — complete regressions: workflow evidence.

ROLLBACK;
