-- OES Fase 4 — corrective preparation tests for B1 -> B1R1
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.b1r1_assert(p_name text,p_condition boolean,p_detail text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT COALESCE(p_condition,false) THEN
    RAISE EXCEPTION '% FAIL: %',p_name,COALESCE(p_detail,'assertion failed');
  END IF;
  RAISE NOTICE '% PASS',p_name;
END $$;

SELECT pg_temp.b1r1_assert('B1R1-T01',
 (SELECT epoch_status='invalidated' AND started_at IS NULL AND completed_at IS NULL
  FROM maintenance.temporal_observation_epoch
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'));

SELECT pg_temp.b1r1_assert('B1R1-T02',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_measurement_event me
   JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
   JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
   WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
 )
 AND NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_measurement_opportunity_resolution r
   JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
   JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
   WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
 ));

SELECT pg_temp.b1r1_assert('B1R1-T03',
 (SELECT epoch_status='draft'
      AND start_boundary_at=TIMESTAMPTZ '2026-10-19 08:00:00-03'
      AND review_boundary_at=TIMESTAMPTZ '2026-11-10 18:00:00-03'
      AND started_at IS NULL AND completed_at IS NULL
  FROM maintenance.temporal_observation_epoch
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
    AND epoch_code='B1R1'));

SELECT pg_temp.b1r1_assert('B1R1-T04',
 (SELECT count(*)=2
  FROM maintenance.temporal_observation_epoch_source
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'));

SELECT pg_temp.b1r1_assert('B1R1-T05',
 (SELECT count(*)=2
  FROM maintenance.temporal_observation_epoch_source
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
    AND runtime_connectivity_status='verified'));

SELECT pg_temp.b1r1_assert('B1R1-T06',
 (SELECT query_strategy_artifact_uuid='b3000000-0000-0000-0000-000000000006'
      AND interface_config_artifact_uuid='b3000000-0000-0000-0000-000000000016'
      AND schedule_definition_artifact_uuid='b3000000-0000-0000-0000-000000000008'
  FROM maintenance.temporal_observation_epoch_source
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000003'));

SELECT pg_temp.b1r1_assert('B1R1-T07',
 (SELECT query_strategy_artifact_uuid='b3000000-0000-0000-0000-000000000014'
      AND interface_config_artifact_uuid='b3000000-0000-0000-0000-000000000015'
      AND schedule_definition_artifact_uuid='b3000000-0000-0000-0000-000000000011'
  FROM maintenance.temporal_observation_epoch_source
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000004'));

SELECT pg_temp.b1r1_assert('B1R1-T08',
 (SELECT count(*)=4
  FROM artifact.artifact
  WHERE artifact_uuid IN (
    'b3000000-0000-0000-0000-000000000013',
    'b3000000-0000-0000-0000-000000000014',
    'b3000000-0000-0000-0000-000000000015',
    'b3000000-0000-0000-0000-000000000016'
  ) AND status='active' AND hash_algorithm='git_blob_sha1'));

SELECT pg_temp.b1r1_assert('B1R1-T09',
 (SELECT content_hash='621ed0252c028a33b666494f49a70a62e570a15c'
  FROM artifact.artifact
  WHERE artifact_uuid='b3000000-0000-0000-0000-000000000015'));

SELECT pg_temp.b1r1_assert('B1R1-T10',
 (SELECT count(*)=8 FROM maintenance.temporal_measurement_opportunity
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000003'));

SELECT pg_temp.b1r1_assert('B1R1-T11',
 (SELECT count(*)=6 FROM maintenance.temporal_measurement_opportunity
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000004'));

SELECT pg_temp.b1r1_assert('B1R1-T12',
 NOT EXISTS(
   (SELECT opportunity_no,planned_for
    FROM maintenance.temporal_measurement_opportunity
    WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000003'
    EXCEPT
    VALUES
      (1,TIMESTAMPTZ '2026-10-19 09:00:00-03'),
      (2,TIMESTAMPTZ '2026-10-20 09:00:00-03'),
      (3,TIMESTAMPTZ '2026-10-22 09:00:00-03'),
      (4,TIMESTAMPTZ '2026-10-26 09:00:00-03'),
      (5,TIMESTAMPTZ '2026-10-29 09:00:00-03'),
      (6,TIMESTAMPTZ '2026-11-03 09:00:00-03'),
      (7,TIMESTAMPTZ '2026-11-06 09:00:00-03'),
      (8,TIMESTAMPTZ '2026-11-09 09:00:00-03'))
 ));

SELECT pg_temp.b1r1_assert('B1R1-T13',
 NOT EXISTS(
   (SELECT opportunity_no,planned_for
    FROM maintenance.temporal_measurement_opportunity
    WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000004'
    EXCEPT
    VALUES
      (1,TIMESTAMPTZ '2026-10-19 10:30:00-03'),
      (2,TIMESTAMPTZ '2026-10-22 10:30:00-03'),
      (3,TIMESTAMPTZ '2026-10-27 10:30:00-03'),
      (4,TIMESTAMPTZ '2026-10-30 10:30:00-03'),
      (5,TIMESTAMPTZ '2026-11-04 10:30:00-03'),
      (6,TIMESTAMPTZ '2026-11-09 10:30:00-03'))
 ));

SELECT pg_temp.b1r1_assert('B1R1-T14',
 maintenance.temporal_epoch_opportunity_set_matches_schedule('b3130000-0000-0000-0000-000000000003')
 AND maintenance.temporal_epoch_opportunity_set_matches_schedule('b3130000-0000-0000-0000-000000000004'));

SELECT pg_temp.b1r1_assert('B1R1-T15',
 maintenance.temporal_observation_design_frozen_at('b3120000-0000-0000-0000-000000000002')
   = TIMESTAMPTZ '2026-10-08 19:48:20-03');

SELECT pg_temp.b1r1_assert('B1R1-T16',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_observation_authority
   WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
 ));

SELECT pg_temp.b1r1_assert('B1R1-T17',
 maintenance.temporal_observation_authority_state(
   'b3120000-0000-0000-0000-000000000002',
   'operational_execution',
   CURRENT_TIMESTAMP
 )='missing');

SELECT pg_temp.b1r1_assert('B1R1-T18',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_measurement_event me
   JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
   JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
   WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
 ));

SELECT pg_temp.b1r1_assert('B1R1-T19',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_measurement_opportunity_resolution r
   JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
   JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
   WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
 ));

SELECT pg_temp.b1r1_assert('B1R1-T20',
 EXISTS(
   SELECT 1 FROM maintenance.temporal_observation_plan_issues('b3100000-0000-0000-0000-000000000001')
   WHERE issue_code='SOURCE_DEBT_PRESENT'
 ));

SELECT pg_temp.b1r1_assert('B1R1-T21',
 maintenance.temporal_target_is_current('b3100000-0000-0000-0000-000000000001'));

SELECT pg_temp.b1r1_assert('B1R1-T22',
 EXISTS(
   SELECT 1 FROM maintenance.temporal_observation_authority
   WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
     AND authority_domain='operational_execution'
     AND decision='approved'
 )
 AND NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_observation_authority
   WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
 ));

SELECT pg_temp.b1r1_assert('B1R1-T23',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_observation_epoch_issues('b3120000-0000-0000-0000-000000000002')
   WHERE issue_code='OPPORTUNITY_SET_MISMATCH'
 ));

SELECT pg_temp.b1r1_assert('B1R1-T24',
 (SELECT epoch_status='draft' AND started_at IS NULL
  FROM maintenance.temporal_observation_epoch
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002')
 AND (SELECT epoch_status='invalidated'
  FROM maintenance.temporal_observation_epoch
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'));

SELECT 'B1R1-T01-T24 PASS' AS result;
