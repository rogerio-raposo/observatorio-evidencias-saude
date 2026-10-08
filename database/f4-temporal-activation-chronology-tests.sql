-- F4 temporal activation chronology hardening tests
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.tact_assert(p_name text,p_condition boolean,p_detail text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT COALESCE(p_condition,false) THEN
    RAISE EXCEPTION '% FAIL: %',p_name,COALESCE(p_detail,'assertion failed');
  END IF;
  RAISE NOTICE '% PASS',p_name;
END $$;

SELECT pg_temp.tact_assert(
  'TACT-T01',
  to_regprocedure('maintenance.assert_temporal_epoch_activation_chronology()') IS NOT NULL
);

SELECT pg_temp.tact_assert(
  'TACT-T02',
  (SELECT count(*)=1
   FROM pg_trigger
   WHERE tgrelid='maintenance.temporal_observation_epoch'::regclass
     AND tgname='tr_temporal_epoch_activation_chronology'
     AND NOT tgisinternal)
);

-- Existing synthetic fixture proves a valid chronology still activates:
-- authority 09:30Z, start boundary/started_at 11:00Z, first opportunity 12:00Z.
SELECT pg_temp.tact_assert(
  'TACT-T03',
  (SELECT epoch_status='active'
      AND started_at>=start_boundary_at
   FROM maintenance.temporal_observation_epoch
   WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001')
);

SELECT pg_temp.tact_assert(
  'TACT-T04',
  (SELECT e.started_at < min(o.planned_for)
   FROM maintenance.temporal_observation_epoch e
   JOIN maintenance.temporal_observation_epoch_source es USING(observation_epoch_uuid)
   JOIN maintenance.temporal_measurement_opportunity o USING(epoch_source_uuid)
   WHERE e.observation_epoch_uuid='f7120000-0000-0000-0000-000000000001'
   GROUP BY e.started_at)
);

SELECT pg_temp.tact_assert(
  'TACT-T05',
  maintenance.temporal_observation_authority_state(
    'f7120000-0000-0000-0000-000000000001',
    'operational_execution',
    TIMESTAMPTZ '2026-10-08 11:00:00+00'
  )='approved'
);

BEGIN;

INSERT INTO maintenance.temporal_observation_epoch(
  observation_epoch_uuid,observation_plan_uuid,epoch_code,epoch_status,
  measurement_design_artifact_uuid,start_boundary_at,review_boundary_at,
  created_at,created_by
) VALUES (
  'f7120000-0000-0000-0000-000000000099',
  'f7100000-0000-0000-0000-000000000001',
  'TACT-B2','draft',
  'f7000000-0000-0000-0000-000000000004',
  TIMESTAMPTZ '2026-10-08 11:00:00+00',
  TIMESTAMPTZ '2026-10-08 15:00:00+00',
  TIMESTAMPTZ '2026-10-08 10:00:00+00',
  'tact-fixture'
);

INSERT INTO maintenance.temporal_observation_epoch_source(
  epoch_source_uuid,observation_epoch_uuid,observation_source_uuid,
  query_strategy_artifact_uuid,baseline_artifact_uuid,
  measurement_investigation_version_uuid,schedule_definition_artifact_uuid,
  runtime_interface_code,measurement_schedule_payload,runtime_connectivity_status,created_at
) VALUES (
  'f7130000-0000-0000-0000-000000000099',
  'f7120000-0000-0000-0000-000000000099',
  'f7110000-0000-0000-0000-000000000001',
  'f7000000-0000-0000-0000-000000000006',
  'f7000000-0000-0000-0000-000000000007',
  'e5100000-0000-0000-0000-000000000002',
  'f7000000-0000-0000-0000-000000000005',
  'eutils',
  '{
    "schema":"oes.temporal_opportunity_set/0.1",
    "non_normative":true,
    "schedule_kind":"finite_opportunity_set",
    "rationale":"Synthetic activation chronology test only",
    "opportunities":[
      {"opportunity_no":1,"planned_for":"2026-10-08T12:00:00+00:00"}
    ]
  }'::jsonb,
  'verified',
  TIMESTAMPTZ '2026-10-08 10:01:00+00'
);

INSERT INTO maintenance.temporal_measurement_opportunity(
  measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,
  opportunity_origin,schedule_snapshot_artifact_uuid,created_at
) VALUES (
  'f7140000-0000-0000-0000-000000000099',
  'f7130000-0000-0000-0000-000000000099',
  1,TIMESTAMPTZ '2026-10-08 12:00:00+00',
  'frozen_opportunity_set',
  'f7000000-0000-0000-0000-000000000005',
  TIMESTAMPTZ '2026-10-08 10:02:00+00'
);

INSERT INTO maintenance.temporal_observation_authority(
  observation_authority_uuid,observation_plan_uuid,observation_epoch_uuid,
  authority_domain,decision,actor,actor_type,decision_artifact_uuid,decided_at,
  limitations_payload,created_at
) VALUES (
  'f7150000-0000-0000-0000-000000000099',
  'f7100000-0000-0000-0000-000000000001',
  'f7120000-0000-0000-0000-000000000099',
  'operational_execution','approved',
  'synthetic-owner','owner',
  'f7000000-0000-0000-0000-000000000008',
  TIMESTAMPTZ '2026-10-08 11:30:00+00',
  '{"fixture":true,"purpose":"activation chronology test"}'::jsonb,
  TIMESTAMPTZ '2026-10-08 11:30:00+00'
);

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='authorized_non_normative'
WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000099';

DO $$
BEGIN
  BEGIN
    UPDATE maintenance.temporal_observation_epoch
    SET epoch_status='active',
        started_at=TIMESTAMPTZ '2026-10-08 11:15:00+00'
    WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000099';
    RAISE EXCEPTION 'TACT-T06 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='TACT-T06 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'TACT-T06 PASS';
END $$;

DO $$
BEGIN
  BEGIN
    UPDATE maintenance.temporal_observation_epoch
    SET epoch_status='active',
        started_at=TIMESTAMPTZ '2026-10-08 12:00:00+00'
    WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000099';
    RAISE EXCEPTION 'TACT-T07 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='TACT-T07 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'TACT-T07 PASS';
END $$;

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='active',
    started_at=TIMESTAMPTZ '2026-10-08 11:45:00+00'
WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000099';

SELECT pg_temp.tact_assert(
  'TACT-T08',
  (SELECT epoch_status='active'
      AND started_at=TIMESTAMPTZ '2026-10-08 11:45:00+00'
   FROM maintenance.temporal_observation_epoch
   WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000099')
);

ROLLBACK;

SELECT 'TACT-T01-T08 PASS' AS result;
