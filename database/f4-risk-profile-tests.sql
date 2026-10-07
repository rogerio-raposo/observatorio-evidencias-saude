-- F4 UpdateRiskProfile — physical contract tests
-- T01–T84: SQL contract tests from Documento 30 §§52–59.
-- T85–T87: workflow evidence (migration idempotency, rebuild, regressions).
-- Requires migrations through 030 + Monitor/Alert + F4 update fixtures
-- + f4-risk-profile-fixtures.sql + f4-operational-control-fixtures.sql.
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

CREATE OR REPLACE FUNCTION pg_temp.add_product_version_same_lineage(
  p_uuid uuid,p_version_no integer
)
RETURNS void LANGUAGE plpgsql AS $fn$
DECLARE e uuid;
BEGIN
  SELECT entity_uuid INTO e FROM product.product_version
   WHERE version_uuid='e5100000-0000-0000-0000-000000000003';
  INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
  ) VALUES (
    p_uuid,e,p_version_no,'draft','rp-test','test','Synthetic same-lineage version'
  );
  INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,evidence_cutoff_date,status
  )
  SELECT p_uuid,e,product_type,title||' — RP test',evidence_cutoff_date,'draft'
    FROM product.product_version
   WHERE version_uuid='e5100000-0000-0000-0000-000000000003';
END;
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.add_proposal_profile(
  p_uuid uuid,
  p_product uuid DEFAULT 'e5100000-0000-0000-0000-000000000003',
  p_inv uuid DEFAULT NULL,
  p_kind text DEFAULT 'initial',
  p_supersedes uuid DEFAULT NULL,
  p_carry uuid DEFAULT NULL,
  p_level text DEFAULT 'M2',
  p_cadence text DEFAULT 'periodic',
  p_event boolean DEFAULT true,
  p_feas text DEFAULT 'adequate',
  p_effective timestamptz DEFAULT TIMESTAMPTZ '2026-10-07 03:00:00+00'
)
RETURNS void LANGUAGE sql AS $q$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_product_version_uuid,target_investigation_version_uuid,
 assessment_kind,recommended_maintenance_level,recommended_cadence_mode,
 event_driven_surveillance_required,feasibility_status,priority_implications_payload,
 rationale,profiled_by,actor_type,verification_status,authority_status,
 assessed_at,effective_at,supersedes_update_risk_profile_uuid,
 carried_forward_from_profile_uuid
) VALUES (
 p_uuid,p_product,p_inv,p_kind,p_level,p_cadence,p_event,p_feas,
 '{"schema_version":"oes.priority_implications/0.1","dominance_notes":[],"coordination_notes":[],"feasibility_notes":[],"rationale":"RP test"}'::jsonb,
 'Synthetic RP contract test','rp-test-ai','ai_system','unverified','proposal',
 p_effective-interval '1 minute',p_effective,p_supersedes,p_carry
);
$q$;

CREATE OR REPLACE FUNCTION pg_temp.clone_dimensions(
  p_new uuid,
  p_source uuid DEFAULT 'f6000000-0000-0000-0000-000000000001',
  p_authority text DEFAULT 'proposal',
  p_override_dim text DEFAULT NULL,
  p_override_value text DEFAULT NULL,
  p_mode text DEFAULT 'assessed',
  p_source_profile uuid DEFAULT NULL
)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  INSERT INTO maintenance.update_risk_profile_dimension(
    update_risk_profile_uuid,dimension_code,value_code,assessment_mode,
    source_profile_uuid,rationale,assessed_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,authority_status,assessed_at
  )
  SELECT
    p_new,d.dimension_code,
    CASE WHEN d.dimension_code=p_override_dim THEN p_override_value ELSE d.value_code END,
    p_mode,
    CASE WHEN p_mode='carried_forward' THEN p_source_profile ELSE NULL END,
    'Synthetic cloned RP dimension',
    CASE WHEN p_authority='authoritative' AND d.dimension_code='B5'
         THEN 'rp-test-owner'
         WHEN p_authority='authoritative' THEN 'rp-test-reviewer'
         ELSE 'rp-test-ai' END,
    CASE WHEN p_authority='authoritative' AND d.dimension_code='B5'
         THEN 'owner'
         WHEN p_authority='authoritative' THEN 'human_reviewer'
         ELSE 'ai_system' END,
    CASE WHEN p_authority='authoritative' AND d.dimension_code='B5'
         THEN 'unverified'
         WHEN p_authority='authoritative' THEN 'human_verified'
         ELSE 'ai_verified' END,
    CASE WHEN p_authority='authoritative' AND d.dimension_code='B5'
         THEN NULL
         WHEN p_authority='authoritative' THEN 'rp-test-reviewer-2'
         ELSE 'rp-test-ai-check' END,
    CASE WHEN p_authority='authoritative' AND d.dimension_code='B5'
         THEN NULL
         WHEN p_authority='authoritative' THEN 'human_reviewer'
         ELSE 'ai_system' END,
    CASE WHEN p_authority='authoritative' AND d.dimension_code='B5'
         THEN NULL ELSE TIMESTAMPTZ '2026-10-07 03:01:00+00' END,
    p_authority,TIMESTAMPTZ '2026-10-07 03:00:30+00'
  FROM maintenance.update_risk_profile_dimension d
  WHERE d.update_risk_profile_uuid=p_source;
END;
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.add_historical_authoritative_profile(
  p_uuid uuid,p_level text,p_cadence text,p_event boolean,p_feas text,
  p_override_dim text,p_override_value text
)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  INSERT INTO maintenance.update_risk_profile(
    update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
    recommended_maintenance_level,recommended_cadence_mode,
    event_driven_surveillance_required,feasibility_status,
    priority_implications_payload,rationale,
    profiled_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,
    authority_status,assessed_at,effective_at,record_status
  ) VALUES (
    p_uuid,'e5100000-0000-0000-0000-000000000003','initial',
    p_level,p_cadence,p_event,p_feas,
    '{"schema_version":"oes.priority_implications/0.1","dominance_notes":[],"coordination_notes":[],"feasibility_notes":[],"rationale":"historical test"}'::jsonb,
    'Synthetic historical authoritative profile',
    'rp-test-reviewer','human_reviewer','human_verified',
    'rp-test-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-07 03:01:00+00',
    'authoritative',TIMESTAMPTZ '2026-10-07 03:00:00+00',
    TIMESTAMPTZ '2026-10-07 03:02:00+00','superseded'
  );
  PERFORM pg_temp.clone_dimensions(
    p_uuid,'f6000000-0000-0000-0000-000000000001',
    'authoritative',p_override_dim,p_override_value,'assessed',NULL
  );
END;
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.add_signal(p_uuid uuid,p_policy uuid)
RETURNS void LANGUAGE sql AS $q$
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 p_uuid,p_policy,'scientific_currentness','governance_demand',
 'explicit_reassessment_request',TIMESTAMPTZ '2026-10-07 03:10:00+00',
 'Synthetic RP test signal','Synthetic RP test','rp-test-system','system','unverified'
);
$q$;

-- T01 — target XOR.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,assessment_kind,rationale,profiled_by,actor_type,
 verification_status,authority_status,assessed_at,effective_at
) VALUES (
 'fb010000-0000-0000-0000-000000000001','initial','No target',
 'rp-test-ai','ai_system','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 03:00:00+00',TIMESTAMPTZ '2026-10-07 03:01:00+00'
)$$,'F4-RP-T01');

-- T02 — ProductVersion target valid.
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
   AND target_product_version_uuid='e5100000-0000-0000-0000-000000000003'
),'F4-RP-T02');

-- T03 — InvestigationVersion target valid.
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000002'
   AND target_investigation_version_uuid='e5100000-0000-0000-0000-000000000002'
),'F4-RP-T03');

-- T04 — one active authoritative profile per target.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
 recommended_maintenance_level,recommended_cadence_mode,
 event_driven_surveillance_required,feasibility_status,
 priority_implications_payload,rationale,profiled_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at,effective_at
) VALUES (
 'fb040000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003','initial','M2','periodic',true,'adequate',
 '{"schema_version":"x"}','duplicate','rp-test-reviewer','human_reviewer',
 'human_verified','rp-test-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 03:00:00+00','authoritative',
 TIMESTAMPTZ '2026-10-07 03:00:00+00',TIMESTAMPTZ '2026-10-07 03:01:00+00'
)$$,'F4-RP-T04');

-- T05 — proposals may coexist.
SAVEPOINT t05;
SELECT pg_temp.add_proposal_profile('fb050000-0000-0000-0000-000000000001');
SELECT pg_temp.add_proposal_profile('fb050000-0000-0000-0000-000000000002');
SELECT pg_temp.assert_true((SELECT count(*)=2 FROM maintenance.update_risk_profile
 WHERE update_risk_profile_uuid IN (
 'fb050000-0000-0000-0000-000000000001','fb050000-0000-0000-0000-000000000002'
 )),'F4-RP-T05');
ROLLBACK TO SAVEPOINT t05; RELEASE SAVEPOINT t05;

-- T06 — profile immutable.
SELECT pg_temp.expect_error($$
UPDATE maintenance.update_risk_profile
 SET rationale='mutated'
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
$$,'F4-RP-T06');

-- T07 — reassessment preserves exact target.
SAVEPOINT t07;
SELECT pg_temp.add_proposal_profile(
 'fb070000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',NULL,'reassessment',
 'f6000000-0000-0000-0000-000000000001',NULL
);
SELECT pg_temp.assert_true((SELECT target_product_version_uuid='e5100000-0000-0000-0000-000000000003'
 FROM maintenance.update_risk_profile
 WHERE update_risk_profile_uuid='fb070000-0000-0000-0000-000000000001'),'F4-RP-T07');
ROLLBACK TO SAVEPOINT t07; RELEASE SAVEPOINT t07;

-- T08 — carry-forward same lineage accepted.
SAVEPOINT t08;
SELECT pg_temp.add_product_version_same_lineage('fb080000-0000-0000-0000-000000000001',99);
SELECT pg_temp.add_proposal_profile(
 'fb080000-0000-0000-0000-000000000002',
 'fb080000-0000-0000-0000-000000000001',NULL,'carry_forward',NULL,
 'f6000000-0000-0000-0000-000000000001','M2','periodic',true,'adequate',
 TIMESTAMPTZ '2026-10-07 03:10:00+00'
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.update_risk_profile
 WHERE update_risk_profile_uuid='fb080000-0000-0000-0000-000000000002'),'F4-RP-T08');
ROLLBACK TO SAVEPOINT t08; RELEASE SAVEPOINT t08;

-- T09 — carry-forward cross-lineage rejected.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
 rationale,profiled_by,actor_type,verification_status,authority_status,
 assessed_at,effective_at,carried_forward_from_profile_uuid
) VALUES (
 'fb090000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000005','carry_forward',
 'cross lineage','rp-test-ai','ai_system','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 03:00:00+00',TIMESTAMPTZ '2026-10-07 03:10:00+00',
 'f6000000-0000-0000-0000-000000000001'
)$$,'F4-RP-T09');

-- T10 — cross-type carry-forward rejected.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_investigation_version_uuid,assessment_kind,
 rationale,profiled_by,actor_type,verification_status,authority_status,
 assessed_at,effective_at,carried_forward_from_profile_uuid
) VALUES (
 'fb100000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000002','carry_forward',
 'cross type','rp-test-ai','ai_system','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 03:00:00+00',TIMESTAMPTZ '2026-10-07 03:10:00+00',
 'f6000000-0000-0000-0000-000000000001'
)$$,'F4-RP-T10');

-- T11 — authoritative fixture has exactly ten authoritative dimensions.
SELECT pg_temp.assert_true((SELECT count(*)=10
 FROM maintenance.update_risk_profile_dimension
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
   AND authority_status='authoritative'),'F4-RP-T11');

-- T12 — dimension code closed.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'f6000000-0000-0000-0000-000000000002','C1','low','assessed','bad',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
)$$,'F4-RP-T12');

-- T13–T22 — dimension/value mappings.
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('A1','high'),'F4-RP-T13');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('A2','moderate'),'F4-RP-T14');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('A3','low'),'F4-RP-T15');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('A4','high'),'F4-RP-T16');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('A5','systemic'),'F4-RP-T17');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('B1','very_low'),'F4-RP-T18');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('B2','unpredictable'),'F4-RP-T19');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('B3','extreme'),'F4-RP-T20');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('B4','very_high'),'F4-RP-T21');
SELECT pg_temp.assert_true(maintenance.risk_profile_dimension_value_is_valid('B5','unavailable'),'F4-RP-T22');

-- T23 — duplicate dimension rejected.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'f6000000-0000-0000-0000-000000000001','A1','moderate','assessed','duplicate',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
)$$,'F4-RP-T23');

-- T24 — AI authoritative dimension rejected.
SAVEPOINT t24;
SELECT pg_temp.add_proposal_profile('fb240000-0000-0000-0000-000000000001');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'fb240000-0000-0000-0000-000000000001','A1','moderate','assessed','bad authority',
 'rp-test-ai','ai_system','unverified','authoritative',CURRENT_TIMESTAMP
)$$,'F4-RP-T24');
ROLLBACK TO SAVEPOINT t24; RELEASE SAVEPOINT t24;

-- T25–T27 — owner cannot authoritatively assess A2/A3/A4.
SAVEPOINT t25_27;
SELECT pg_temp.add_proposal_profile('fb250000-0000-0000-0000-000000000001');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at
) VALUES ('fb250000-0000-0000-0000-000000000001','A2','moderate','assessed','bad',
 'rp-test-owner','owner','human_verified','rp-test-reviewer','human_reviewer',CURRENT_TIMESTAMP,
 'authoritative',CURRENT_TIMESTAMP)$$,'F4-RP-T25');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at
) VALUES ('fb250000-0000-0000-0000-000000000001','A3','moderate','assessed','bad',
 'rp-test-owner','owner','human_verified','rp-test-reviewer','human_reviewer',CURRENT_TIMESTAMP,
 'authoritative',CURRENT_TIMESTAMP)$$,'F4-RP-T26');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at
) VALUES ('fb250000-0000-0000-0000-000000000001','A4','moderate','assessed','bad',
 'rp-test-owner','owner','human_verified','rp-test-reviewer','human_reviewer',CURRENT_TIMESTAMP,
 'authoritative',CURRENT_TIMESTAMP)$$,'F4-RP-T27');
ROLLBACK TO SAVEPOINT t25_27; RELEASE SAVEPOINT t25_27;

-- T28 — B5 authoritative requires owner.
SAVEPOINT t28;
SELECT pg_temp.add_proposal_profile('fb280000-0000-0000-0000-000000000001');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at
) VALUES ('fb280000-0000-0000-0000-000000000001','B5','adequate','assessed','bad',
 'rp-test-reviewer','human_reviewer','human_verified','rp-test-reviewer-2','human_reviewer',
 CURRENT_TIMESTAMP,'authoritative',CURRENT_TIMESTAMP)$$,'F4-RP-T28');
ROLLBACK TO SAVEPOINT t28; RELEASE SAVEPOINT t28;

-- T29 — scientific authoritative dimension requires human verification.
SAVEPOINT t29;
SELECT pg_temp.add_proposal_profile('fb290000-0000-0000-0000-000000000001');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,rationale,
 assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES ('fb290000-0000-0000-0000-000000000001','A3','moderate','assessed','bad verify',
 'rp-test-reviewer','human_reviewer','unverified','authoritative',CURRENT_TIMESTAMP)$$,'F4-RP-T29');
ROLLBACK TO SAVEPOINT t29; RELEASE SAVEPOINT t29;

-- T30 — B5 owner declaration may be authoritative without false verifier.
SELECT pg_temp.assert_true((SELECT actor_type='owner' AND authority_status='authoritative'
 AND verification_status='unverified' AND verified_by IS NULL
 FROM maintenance.update_risk_profile_dimension
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
   AND dimension_code='B5'),'F4-RP-T30');

-- T31 — owner cannot author authoritative profile header.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_product_version_uuid,assessment_kind,
 recommended_maintenance_level,recommended_cadence_mode,
 event_driven_surveillance_required,feasibility_status,
 priority_implications_payload,rationale,profiled_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,assessed_at,effective_at,record_status
) VALUES (
 'fb310000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003','initial','M2','periodic',true,'adequate',
 '{"schema_version":"x"}','bad header','rp-test-owner','owner','human_verified',
 'rp-test-reviewer','human_reviewer',CURRENT_TIMESTAMP,'authoritative',
 CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'superseded'
)$$,'F4-RP-T31');

-- T32 — dimension basis locator XOR.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension_basis(
 update_risk_profile_uuid,dimension_code,source_type,candidate_assessment_uuid,
 rationale,sequence_no
) VALUES (
 'f6000000-0000-0000-0000-000000000001','A1','monitor_cycle',
 'e5530000-0000-0000-0000-000000000002','mismatch',99
)$$,'F4-RP-T32');

-- T33 — MonitorCycle basis uses real FK.
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile_dimension_basis b
 JOIN maintenance.monitor_cycle c ON c.cycle_uuid=b.monitor_cycle_uuid
 WHERE b.update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
   AND b.dimension_code='A2' AND b.source_type='monitor_cycle'
),'F4-RP-T33');

-- T34 — external basis needs payload and no OES locator.
SAVEPOINT t34;
INSERT INTO maintenance.update_risk_profile_dimension_basis(
 update_risk_profile_uuid,dimension_code,source_type,external_reference_payload,
 observation_payload,rationale,sequence_no
) VALUES (
 'f6000000-0000-0000-0000-000000000001','A1','external_reference',
 '{"uri":"urn:rp-test:external"}','{"observation":"synthetic"}',
 'External reference without fabricated OES UUID',99
);
SELECT pg_temp.assert_true((SELECT monitor_cycle_uuid IS NULL
 AND candidate_assessment_uuid IS NULL AND update_signal_uuid IS NULL
 AND source_entity_version_uuid IS NULL AND source_artifact_uuid IS NULL
 FROM maintenance.update_risk_profile_dimension_basis
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
 AND dimension_code='A1' AND sequence_no=99),'F4-RP-T34');
ROLLBACK TO SAVEPOINT t34; RELEASE SAVEPOINT t34;

-- T35 — initial dimensions cannot be carried forward.
SAVEPOINT t35;
SELECT pg_temp.add_proposal_profile('fb350000-0000-0000-0000-000000000001');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,source_profile_uuid,
 rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'fb350000-0000-0000-0000-000000000001','A1','moderate','carried_forward',
 'f6000000-0000-0000-0000-000000000001','bad initial carry',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
)$$,'F4-RP-T35');
ROLLBACK TO SAVEPOINT t35; RELEASE SAVEPOINT t35;

-- T36 — reassessment carried dimension source must be superseded profile.
SAVEPOINT t36;
SELECT pg_temp.add_proposal_profile(
 'fb360000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',NULL,'reassessment',
 'f6000000-0000-0000-0000-000000000001'
);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,source_profile_uuid,
 rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'fb360000-0000-0000-0000-000000000001','A1','high','carried_forward',
 'f6000000-0000-0000-0000-000000000003','wrong reassessment source',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
)$$,'F4-RP-T36');
ROLLBACK TO SAVEPOINT t36; RELEASE SAVEPOINT t36;

-- T37 — reassessment carried dimension preserves source value.
SAVEPOINT t37;
SELECT pg_temp.add_proposal_profile(
 'fb370000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',NULL,'reassessment',
 'f6000000-0000-0000-0000-000000000001'
);
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,source_profile_uuid,
 rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'fb370000-0000-0000-0000-000000000001','A1','moderate','carried_forward',
 'f6000000-0000-0000-0000-000000000001','valid carry',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.update_risk_profile_dimension
 WHERE update_risk_profile_uuid='fb370000-0000-0000-0000-000000000001'
 AND dimension_code='A1' AND value_code='moderate'),'F4-RP-T37');
ROLLBACK TO SAVEPOINT t37; RELEASE SAVEPOINT t37;

-- T38–T39 — carry-forward dimension must use header source and preserve value.
SAVEPOINT t38_39;
SELECT pg_temp.add_product_version_same_lineage('fb380000-0000-0000-0000-000000000001',99);
SELECT pg_temp.add_proposal_profile(
 'fb380000-0000-0000-0000-000000000002',
 'fb380000-0000-0000-0000-000000000001',NULL,'carry_forward',NULL,
 'f6000000-0000-0000-0000-000000000001'
);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,source_profile_uuid,
 rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'fb380000-0000-0000-0000-000000000002','A1','high','carried_forward',
 'f6000000-0000-0000-0000-000000000003','wrong header source',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
)$$,'F4-RP-T38');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,source_profile_uuid,
 rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'fb380000-0000-0000-0000-000000000002','A1','high','carried_forward',
 'f6000000-0000-0000-0000-000000000001','value drift',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
)$$,'F4-RP-T39');
ROLLBACK TO SAVEPOINT t38_39; RELEASE SAVEPOINT t38_39;

-- T40 — carried dimension rationale required.
SAVEPOINT t40;
SELECT pg_temp.add_proposal_profile(
 'fb400000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',NULL,'reassessment',
 'f6000000-0000-0000-0000-000000000001'
);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_dimension(
 update_risk_profile_uuid,dimension_code,value_code,assessment_mode,source_profile_uuid,
 rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
) VALUES (
 'fb400000-0000-0000-0000-000000000001','A1','moderate','carried_forward',
 'f6000000-0000-0000-0000-000000000001','',
 'rp-test-ai','ai_system','unverified','proposal',CURRENT_TIMESTAMP
)$$,'F4-RP-T40');
ROLLBACK TO SAVEPOINT t40; RELEASE SAVEPOINT t40;

-- T41 — new scientific version has no silent profile.
SAVEPOINT t41;
SELECT pg_temp.add_product_version_same_lineage('fb410000-0000-0000-0000-000000000001',99);
SELECT pg_temp.assert_true(
 maintenance.current_authoritative_risk_profile(
   'fb410000-0000-0000-0000-000000000001',NULL
 ) IS NULL,'F4-RP-T41');
ROLLBACK TO SAVEPOINT t41; RELEASE SAVEPOINT t41;

-- T42 — carry source must be authoritative and temporal order must hold.
SAVEPOINT t42;
SELECT pg_temp.add_proposal_profile('fb420000-0000-0000-0000-000000000001');
SELECT pg_temp.add_product_version_same_lineage('fb420000-0000-0000-0000-000000000002',99);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_product_version_uuid,assessment_kind,rationale,
 profiled_by,actor_type,verification_status,authority_status,assessed_at,effective_at,
 carried_forward_from_profile_uuid
) VALUES (
 'fb420000-0000-0000-0000-000000000003',
 'fb420000-0000-0000-0000-000000000002','carry_forward','proposal source invalid',
 'rp-test-ai','ai_system','unverified','proposal',
 TIMESTAMPTZ '2026-10-07 03:00:00+00',TIMESTAMPTZ '2026-10-07 03:10:00+00',
 'fb420000-0000-0000-0000-000000000001'
)$$,'F4-RP-T42-source');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile(
 update_risk_profile_uuid,target_product_version_uuid,assessment_kind,rationale,
 profiled_by,actor_type,verification_status,authority_status,assessed_at,effective_at,
 carried_forward_from_profile_uuid
) VALUES (
 'fb420000-0000-0000-0000-000000000004',
 'fb420000-0000-0000-0000-000000000002','carry_forward','temporal invalid',
 'rp-test-ai','ai_system','unverified','proposal',
 TIMESTAMPTZ '2026-10-06 23:40:00+00',TIMESTAMPTZ '2026-10-06 23:50:00+00',
 'f6000000-0000-0000-0000-000000000001'
)$$,'F4-RP-T42-time');
ROLLBACK TO SAVEPOINT t42; RELEASE SAVEPOINT t42;

-- T43–T46 — maintenance/cadence compatibility.
SELECT pg_temp.assert_true(
 maintenance.risk_profile_cadence_is_valid('M0','none')
 AND NOT maintenance.risk_profile_cadence_is_valid('M0','periodic'),'F4-RP-T43');
SELECT pg_temp.assert_true(
 maintenance.risk_profile_cadence_is_valid('M1','event_driven')
 AND maintenance.risk_profile_cadence_is_valid('M1','periodic')
 AND maintenance.risk_profile_cadence_is_valid('M1','hybrid'),'F4-RP-T44');
SELECT pg_temp.assert_true(
 maintenance.risk_profile_cadence_is_valid('M2','periodic')
 AND maintenance.risk_profile_cadence_is_valid('M2','hybrid')
 AND NOT maintenance.risk_profile_cadence_is_valid('M2','continuous'),'F4-RP-T45');
SELECT pg_temp.assert_true(
 maintenance.risk_profile_cadence_is_valid('M3','continuous')
 AND maintenance.risk_profile_cadence_is_valid('M3','hybrid'),'F4-RP-T46');

-- T47 — A4 high requires event-driven surveillance.
SAVEPOINT t47;
SELECT pg_temp.add_historical_authoritative_profile(
 'fb470000-0000-0000-0000-000000000001','M2','periodic',false,'adequate','A4','high');
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile_issues(
 'fb470000-0000-0000-0000-000000000001')
 WHERE issue_code='PROFILE_A4_EVENT_DRIVEN_REQUIRED'),'F4-RP-T47');
ROLLBACK TO SAVEPOINT t47; RELEASE SAVEPOINT t47;

-- T48 — A1 high blocks M0.
SAVEPOINT t48;
SELECT pg_temp.add_historical_authoritative_profile(
 'fb480000-0000-0000-0000-000000000001','M0','none',true,'adequate','A1','high');
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile_issues(
 'fb480000-0000-0000-0000-000000000001')
 WHERE issue_code='PROFILE_HIGH_CRITICALITY_M0_FORBIDDEN'),'F4-RP-T48');
ROLLBACK TO SAVEPOINT t48; RELEASE SAVEPOINT t48;

-- T49 — A4 high blocks M0.
SAVEPOINT t49;
SELECT pg_temp.add_historical_authoritative_profile(
 'fb490000-0000-0000-0000-000000000001','M0','none',true,'adequate','A4','high');
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile_issues(
 'fb490000-0000-0000-0000-000000000001')
 WHERE issue_code='PROFILE_HIGH_CRITICALITY_M0_FORBIDDEN'),'F4-RP-T49');
ROLLBACK TO SAVEPOINT t49; RELEASE SAVEPOINT t49;

-- T50–T52 — non-adequate B5 blocks M3 recommendation.
SAVEPOINT t50_52;
SELECT pg_temp.add_historical_authoritative_profile(
 'fb500000-0000-0000-0000-000000000001','M3','continuous',true,'adequate','B5','strained');
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.update_risk_profile_issues(
 'fb500000-0000-0000-0000-000000000001') WHERE issue_code='PROFILE_M3_CAPACITY_BLOCKED'),'F4-RP-T50');
SELECT pg_temp.add_historical_authoritative_profile(
 'fb510000-0000-0000-0000-000000000001','M3','continuous',true,'adequate','B5','insufficient');
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.update_risk_profile_issues(
 'fb510000-0000-0000-0000-000000000001') WHERE issue_code='PROFILE_M3_CAPACITY_BLOCKED'),'F4-RP-T51');
SELECT pg_temp.add_historical_authoritative_profile(
 'fb520000-0000-0000-0000-000000000001','M3','continuous',true,'adequate','B5','unavailable');
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.update_risk_profile_issues(
 'fb520000-0000-0000-0000-000000000001') WHERE issue_code='PROFILE_M3_CAPACITY_BLOCKED'),'F4-RP-T52');
ROLLBACK TO SAVEPOINT t50_52; RELEASE SAVEPOINT t50_52;

-- T53 — feasibility cannot exceed B5 ceiling.
SELECT pg_temp.assert_true(
 NOT maintenance.feasibility_respects_b5('strained','adequate')
 AND NOT maintenance.feasibility_respects_b5('insufficient','strained')
 AND maintenance.feasibility_respects_b5('unavailable','unavailable'),
 'F4-RP-T53');

-- T54 — no aggregated risk score column.
SELECT pg_temp.assert_true(NOT EXISTS(
 SELECT 1 FROM information_schema.columns
 WHERE table_schema='maintenance' AND table_name='update_risk_profile'
   AND column_name ILIKE '%score%'
),'F4-RP-T54');

-- T55 — priority implications fixture contains no authoritative response class.
SELECT pg_temp.assert_true(
 NOT ((SELECT priority_implications_payload
       FROM maintenance.update_risk_profile
       WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001')
      ? 'response_class'),'F4-RP-T55');

-- T56 — initial profile has initial_baseline trigger.
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile_trigger
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
   AND trigger_code='initial_baseline'),'F4-RP-T56');

-- T57 — reassessment accepts non-initial trigger.
SAVEPOINT t57;
SELECT pg_temp.add_proposal_profile(
 'fb570000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',NULL,'reassessment',
 'f6000000-0000-0000-0000-000000000001'
);
INSERT INTO maintenance.update_risk_profile_trigger(
 update_risk_profile_uuid,trigger_code,source_type,rationale,sequence_no
) VALUES (
 'fb570000-0000-0000-0000-000000000001','capacity_change','none',
 'Synthetic capacity reassessment',1
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.update_risk_profile_trigger
 WHERE update_risk_profile_uuid='fb570000-0000-0000-0000-000000000001'
 AND trigger_code='capacity_change'),'F4-RP-T57');
ROLLBACK TO SAVEPOINT t57; RELEASE SAVEPOINT t57;

-- T58 — carry-forward requires new_scientific_version trigger.
SAVEPOINT t58;
SELECT pg_temp.add_product_version_same_lineage('fb580000-0000-0000-0000-000000000001',99);
SELECT pg_temp.add_proposal_profile(
 'fb580000-0000-0000-0000-000000000002',
 'fb580000-0000-0000-0000-000000000001',NULL,'carry_forward',NULL,
 'f6000000-0000-0000-0000-000000000001'
);
INSERT INTO maintenance.update_risk_profile_trigger(
 update_risk_profile_uuid,trigger_code,source_type,source_entity_version_uuid,
 rationale,sequence_no
) VALUES (
 'fb580000-0000-0000-0000-000000000002','new_scientific_version','entity_version',
 'fb580000-0000-0000-0000-000000000001','Synthetic new version',1
);
SELECT pg_temp.assert_true(EXISTS(SELECT 1 FROM maintenance.update_risk_profile_trigger
 WHERE update_risk_profile_uuid='fb580000-0000-0000-0000-000000000002'
 AND trigger_code='new_scientific_version'),'F4-RP-T58');
ROLLBACK TO SAVEPOINT t58; RELEASE SAVEPOINT t58;

-- T59 — Alert trigger does not define A4 automatically.
SAVEPOINT t59;
SELECT pg_temp.add_proposal_profile('fb590000-0000-0000-0000-000000000001');
INSERT INTO maintenance.update_risk_profile_trigger(
 update_risk_profile_uuid,trigger_code,source_type,alert_product_version_uuid,
 rationale,sequence_no
) VALUES (
 'fb590000-0000-0000-0000-000000000001','policy_regulatory_change',
 'alert_product_version','a7100000-0000-0000-0000-000000000001',
 'Alert can trigger reassessment only',1
);
SELECT pg_temp.assert_true(NOT EXISTS(
 SELECT 1 FROM maintenance.update_risk_profile_dimension
 WHERE update_risk_profile_uuid='fb590000-0000-0000-0000-000000000001'
 AND dimension_code='A4'),'F4-RP-T59');
ROLLBACK TO SAVEPOINT t59; RELEASE SAVEPOINT t59;

-- T60 — capacity_change needs no UpdateSignal.
SAVEPOINT t60;
SELECT pg_temp.add_proposal_profile('fb600000-0000-0000-0000-000000000010');
INSERT INTO maintenance.update_risk_profile_trigger(
 update_risk_profile_uuid,trigger_code,source_type,rationale,sequence_no
) VALUES (
 'fb600000-0000-0000-0000-000000000010','capacity_change','none',
 'Operational capacity reassessment without scientific signal',1
);
SELECT pg_temp.assert_true((SELECT update_signal_uuid IS NULL
 FROM maintenance.update_risk_profile_trigger
 WHERE update_risk_profile_uuid='fb600000-0000-0000-0000-000000000010'
 AND trigger_code='capacity_change'),'F4-RP-T60');
ROLLBACK TO SAVEPOINT t60; RELEASE SAVEPOINT t60;

-- T61 — trigger source_type/locator mismatch rejected.
SAVEPOINT t61;
SELECT pg_temp.add_proposal_profile('fb610000-0000-0000-0000-000000000010');
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_risk_profile_trigger(
 update_risk_profile_uuid,trigger_code,source_type,update_signal_uuid,
 rationale,sequence_no
) VALUES (
 'fb610000-0000-0000-0000-000000000010','capacity_change','monitor_cycle',
 'f4100000-0000-0000-0000-000000000001','mismatch',1
)$$,'F4-RP-T61');
ROLLBACK TO SAVEPOINT t61; RELEASE SAVEPOINT t61;

-- T62 — source_type none has no locator.
SELECT pg_temp.assert_true((SELECT update_signal_uuid IS NULL
 AND alert_product_version_uuid IS NULL AND monitor_cycle_uuid IS NULL
 AND source_entity_version_uuid IS NULL AND source_artifact_uuid IS NULL
 AND external_reference_payload IS NULL
 FROM maintenance.update_risk_profile_trigger
 WHERE update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
 AND trigger_code='initial_baseline'),'F4-RP-T62');

-- T63 — governing profile target equals policy target.
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.update_policy_risk_profile_basis b
 JOIN maintenance.update_policy p USING(update_policy_uuid)
 JOIN maintenance.update_risk_profile r USING(update_risk_profile_uuid)
 WHERE b.update_policy_uuid='f4000000-0000-0000-0000-000000000001'
 AND b.basis_role='governing'
 AND r.target_product_version_uuid=p.target_product_version_uuid
),'F4-RP-T63');

-- T64 — governing profile authoritative.
SELECT pg_temp.assert_true((SELECT r.authority_status='authoritative'
 FROM maintenance.update_policy_risk_profile_basis b
 JOIN maintenance.update_risk_profile r USING(update_risk_profile_uuid)
 WHERE b.update_policy_uuid='f4000000-0000-0000-0000-000000000001'
 AND b.record_status='active' AND b.basis_role='governing'),'F4-RP-T64');

-- T65 — one active governing link per policy.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.update_policy_risk_profile_basis(
 update_policy_risk_profile_basis_uuid,update_policy_uuid,update_risk_profile_uuid,
 basis_role,linked_at,linked_by,actor_type,rationale
) VALUES (
 'fb650000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'f6000000-0000-0000-0000-000000000001','governing',
 TIMESTAMPTZ '2026-10-07 03:00:00+00','rp-test-owner','owner','duplicate governing'
)$$,'F4-RP-T65');

-- T66 — governing-link supersession preserves history.
SAVEPOINT t66;
UPDATE maintenance.update_policy_risk_profile_basis SET record_status='superseded'
 WHERE update_policy_risk_profile_basis_uuid='f6100000-0000-0000-0000-000000000001';
INSERT INTO maintenance.update_policy_risk_profile_basis(
 update_policy_risk_profile_basis_uuid,update_policy_uuid,update_risk_profile_uuid,
 basis_role,linked_at,linked_by,actor_type,rationale,
 supersedes_update_policy_risk_profile_basis_uuid
) VALUES (
 'fb660000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'f6000000-0000-0000-0000-000000000001','governing',
 TIMESTAMPTZ '2026-10-07 03:00:00+00','rp-test-owner','owner','replacement link',
 'f6100000-0000-0000-0000-000000000001'
);
SELECT pg_temp.assert_true(
 EXISTS(SELECT 1 FROM maintenance.update_policy_risk_profile_basis
  WHERE update_policy_risk_profile_basis_uuid='f6100000-0000-0000-0000-000000000001'
  AND record_status='superseded')
 AND EXISTS(SELECT 1 FROM maintenance.update_policy_risk_profile_basis
  WHERE update_policy_risk_profile_basis_uuid='fb660000-0000-0000-0000-000000000001'
  AND record_status='active'),'F4-RP-T66');
ROLLBACK TO SAVEPOINT t66; RELEASE SAVEPOINT t66;

-- T67 — later profile cannot be retroactive governing basis (guard is explicit).
SELECT pg_temp.assert_true(
 pg_get_functiondef('maintenance.assert_policy_risk_profile_basis()'::regprocedure)
 ILIKE '%Later profile cannot become retroactive governing basis%',
 'F4-RP-T67');

-- T68–T69 — recommendation divergence allowed and never auto-mutates policy.
SAVEPOINT t68_69;
SELECT pg_temp.add_proposal_profile(
 'fb680000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',NULL,'initial',NULL,NULL,
 'M1','event_driven',true,'adequate',TIMESTAMPTZ '2026-10-07 03:00:00+00'
);
SELECT pg_temp.assert_true((SELECT recommended_maintenance_level='M1'
 FROM maintenance.update_risk_profile
 WHERE update_risk_profile_uuid='fb680000-0000-0000-0000-000000000001'),'F4-RP-T68');
SELECT pg_temp.assert_true((SELECT effective_maintenance_level='M2'
 FROM maintenance.update_policy
 WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'),'F4-RP-T69');
ROLLBACK TO SAVEPOINT t68_69; RELEASE SAVEPOINT t68_69;

-- T70 — legacy snapshot-only rows remain schema-compatible (nullable FK).
SELECT pg_temp.assert_true((SELECT is_nullable='YES'
 FROM information_schema.columns
 WHERE table_schema='maintenance' AND table_name='priority_assessment'
 AND column_name='update_risk_profile_uuid'),'F4-RP-T70');

-- T71 — incomplete proposal cannot serialize.
SAVEPOINT t71;
SELECT pg_temp.add_proposal_profile('fb710000-0000-0000-0000-000000000001');
SELECT pg_temp.expect_error($$
SELECT maintenance.update_risk_profile_snapshot(
 'fb710000-0000-0000-0000-000000000001'
)$$,'F4-RP-T71');
ROLLBACK TO SAVEPOINT t71; RELEASE SAVEPOINT t71;

-- T72 — new PriorityAssessment without profile FK rejected.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 risk_profile_snapshot,rationale,assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fb720000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','signal_triage',
 'standard','operational','proposal','adequate',
 maintenance.update_risk_profile_snapshot('f6000000-0000-0000-0000-000000000001'),
 'missing profile FK','rp-test-ai','ai_system','unverified',
 TIMESTAMPTZ '2026-10-07 03:20:00+00'
)$$,'F4-RP-T72');

-- T73 — fixture PriorityAssessment snapshot exactly matches serializer.
SELECT pg_temp.assert_true((SELECT pa.risk_profile_snapshot=
 maintenance.update_risk_profile_snapshot(pa.update_risk_profile_uuid)
 FROM maintenance.priority_assessment pa
 WHERE pa.priority_assessment_uuid='f5100000-0000-0000-0000-000000000001'),
 'F4-RP-T73');

-- T74 — snapshot drift rejected.
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 update_risk_profile_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fb740000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001','signal_triage',
 'standard','operational','proposal','adequate',
 'f6000000-0000-0000-0000-000000000001',
 maintenance.update_risk_profile_snapshot('f6000000-0000-0000-0000-000000000001')
 || '{"A1":"high"}'::jsonb,
 'drift','rp-test-ai','ai_system','unverified',TIMESTAMPTZ '2026-10-07 03:20:00+00'
)$$,'F4-RP-T74');

-- T75 — authoritative scientific priority requires authoritative profile.
SAVEPOINT t75;
SELECT pg_temp.add_signal(
 'fb750000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000002'
);
SELECT pg_temp.expect_error($$
INSERT INTO maintenance.priority_assessment(
 priority_assessment_uuid,update_signal_uuid,update_policy_uuid,stage,
 response_class,authority_scope,authority_status,feasibility_status,
 update_risk_profile_uuid,risk_profile_snapshot,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb750000-0000-0000-0000-000000000002',
 'fb750000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000002','signal_triage',
 'expedited','scientific','authoritative','adequate',
 'f6000000-0000-0000-0000-000000000002',
 maintenance.update_risk_profile_snapshot('f6000000-0000-0000-0000-000000000002'),
 'proposal profile cannot support authoritative science',
 'rp-test-reviewer','human_reviewer','human_verified',
 'rp-test-reviewer-2','human_reviewer',TIMESTAMPTZ '2026-10-07 03:19:00+00',
 TIMESTAMPTZ '2026-10-07 03:20:00+00'
)$$,'F4-RP-T75');
ROLLBACK TO SAVEPOINT t75; RELEASE SAVEPOINT t75;

-- T76 — PriorityBasis risk_profile locator is coherent.
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.priority_basis
 WHERE priority_assessment_uuid='f5100000-0000-0000-0000-000000000001'
 AND source_type='risk_profile'
 AND update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
 AND snapshot_payload IS NULL
),'F4-RP-T76');

-- T77 — SLA snapshot freezes profile UUID.
SELECT pg_temp.assert_true((SELECT
 rule_snapshot_payload->>'update_risk_profile_uuid'=
 'f6000000-0000-0000-0000-000000000001'
 FROM maintenance.sla_instance
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000001'),
 'F4-RP-T77');

-- T78 — later profile does not recalculate an existing SLA snapshot.
SAVEPOINT t78;
SELECT pg_temp.add_proposal_profile(
 'fb780000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',NULL,'reassessment',
 'f6000000-0000-0000-0000-000000000001'
);
SELECT pg_temp.assert_true((SELECT
 rule_snapshot_payload->>'update_risk_profile_uuid'=
 'f6000000-0000-0000-0000-000000000001'
 FROM maintenance.sla_instance
 WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000001'),
 'F4-RP-T78');
ROLLBACK TO SAVEPOINT t78; RELEASE SAVEPOINT t78;

-- T79 — profile does not own/change CurrencyState.
SELECT pg_temp.assert_true(NOT EXISTS(
 SELECT 1 FROM information_schema.columns
 WHERE table_schema='maintenance' AND table_name='update_risk_profile'
 AND column_name='currency_state_uuid'),'F4-RP-T79');

-- T80 — profile does not own/promote AssuranceRecord.
SELECT pg_temp.assert_true(NOT EXISTS(
 SELECT 1 FROM information_schema.columns
 WHERE table_schema='maintenance' AND table_name='update_risk_profile'
 AND column_name='assurance_uuid'),'F4-RP-T80');

-- T81 — profile fixtures did not create policies.
SELECT pg_temp.assert_true(
 (SELECT count(*) FROM maintenance.update_policy)=2,'F4-RP-T81');

-- T82 — profile fixtures did not create UpdateSignals.
SELECT pg_temp.assert_true(
 (SELECT count(*) FROM maintenance.update_signal)=3,'F4-RP-T82');

-- T83 — risk-profile triggers do not create Evidence Alerts.
SELECT pg_temp.assert_true(NOT EXISTS(
 SELECT 1
 FROM pg_trigger t JOIN pg_proc p ON p.oid=t.tgfoid
 WHERE t.tgrelid='maintenance.update_risk_profile'::regclass
 AND NOT t.tgisinternal
 AND pg_get_functiondef(p.oid) ILIKE '%INSERT INTO maintenance.evidence_alert%'
),'F4-RP-T83');

-- T84 — M3 blocker preserved.
SELECT pg_temp.assert_true(EXISTS(
 SELECT 1 FROM maintenance.operational_control_readiness(
 'f4000000-0000-0000-0000-000000000002')
 WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL'
),'F4-RP-T84');

ROLLBACK;

SELECT 'F4-RP-T01–T84 PASS' AS result;
