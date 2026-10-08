-- OES Fase 4 — TOPI-N2-DCBTI-01 Phase B preparation tests
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.topi_prep_assert(p_name text,p_condition boolean,p_detail text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT COALESCE(p_condition,false) THEN
    RAISE EXCEPTION '% FAIL: %',p_name,COALESCE(p_detail,'assertion failed');
  END IF;
  RAISE NOTICE '% PASS',p_name;
END $$;

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T01',
 (SELECT ev.version_status='current'
  FROM core.entity_version ev
  WHERE ev.version_uuid='81000000-0000-0000-0000-000000000701'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T02',
 (SELECT pv.status='published'
  FROM product.product_version pv
  WHERE pv.version_uuid='81000000-0000-0000-0000-000000000701'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T03',
 EXISTS(SELECT 1 FROM product.investigation_link
        WHERE product_version_uuid='81000000-0000-0000-0000-000000000701'
          AND investigation_version_uuid='81000000-0000-0000-0000-000000000002'
          AND role='primary'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T04',
 (SELECT count(*)=1 FROM maintenance.temporal_observation_plan
  WHERE observation_plan_uuid='b3100000-0000-0000-0000-000000000001'
    AND plan_code='TOPI-N2-DCBTI-01' AND plan_version=2
    AND target_product_version_uuid='81000000-0000-0000-0000-000000000701'
    AND record_status='active'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T05',
 NOT EXISTS(SELECT 1 FROM maintenance.temporal_observation_plan
            WHERE plan_code='TOPI-N2-DCBTI-01' AND plan_version=1));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T06',
 (SELECT count(*)=3 FROM maintenance.temporal_observation_source
  WHERE observation_plan_uuid='b3100000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T07',
 (SELECT inclusion_status='included' AND runtime_connectivity_required
  FROM maintenance.temporal_observation_source
  WHERE observation_source_uuid='b3110000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T08',
 (SELECT inclusion_status='included' AND runtime_connectivity_required
  FROM maintenance.temporal_observation_source
  WHERE observation_source_uuid='b3110000-0000-0000-0000-000000000002'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T09',
 (SELECT inclusion_status='deferred'
      AND debt_reason_code='access_path_not_reproducible'
      AND reassessment_trigger IS NOT NULL
  FROM maintenance.temporal_observation_source
  WHERE observation_source_uuid='b3110000-0000-0000-0000-000000000003'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T10',
 (SELECT epoch_status='draft'
      AND start_boundary_at=TIMESTAMPTZ '2026-10-19 08:00:00-03'
      AND review_boundary_at=TIMESTAMPTZ '2026-11-10 18:00:00-03'
      AND started_at IS NULL AND completed_at IS NULL
  FROM maintenance.temporal_observation_epoch
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T11',
 (SELECT count(*)=2 FROM maintenance.temporal_observation_epoch_source
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T12',
 (SELECT runtime_connectivity_status='verified'
  FROM maintenance.temporal_observation_epoch_source
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T13',
 (SELECT runtime_connectivity_status='verified'
  FROM maintenance.temporal_observation_epoch_source
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000002'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T14',
 maintenance.temporal_epoch_opportunity_set_matches_schedule('b3130000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T15',
 maintenance.temporal_epoch_opportunity_set_matches_schedule('b3130000-0000-0000-0000-000000000002'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T16',
 (SELECT count(*)=8 FROM maintenance.temporal_measurement_opportunity
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T17',
 (SELECT count(*)=6 FROM maintenance.temporal_measurement_opportunity
  WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000002'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T18',
 NOT EXISTS(
   (SELECT opportunity_no,planned_for
    FROM maintenance.temporal_measurement_opportunity
    WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000001'
    EXCEPT
    VALUES
      (1,TIMESTAMPTZ '2026-10-19 09:00:00-03'),
      (2,TIMESTAMPTZ '2026-10-20 09:00:00-03'),
      (3,TIMESTAMPTZ '2026-10-22 09:00:00-03'),
      (4,TIMESTAMPTZ '2026-10-26 09:00:00-03'),
      (5,TIMESTAMPTZ '2026-10-29 09:00:00-03'),
      (6,TIMESTAMPTZ '2026-11-03 09:00:00-03'),
      (7,TIMESTAMPTZ '2026-11-06 09:00:00-03'),
      (8,TIMESTAMPTZ '2026-11-09 09:00:00-03')
   )
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T19',
 NOT EXISTS(
   (SELECT opportunity_no,planned_for
    FROM maintenance.temporal_measurement_opportunity
    WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000002'
    EXCEPT
    VALUES
      (1,TIMESTAMPTZ '2026-10-19 10:30:00-03'),
      (2,TIMESTAMPTZ '2026-10-22 10:30:00-03'),
      (3,TIMESTAMPTZ '2026-10-27 10:30:00-03'),
      (4,TIMESTAMPTZ '2026-10-30 10:30:00-03'),
      (5,TIMESTAMPTZ '2026-11-04 10:30:00-03'),
      (6,TIMESTAMPTZ '2026-11-09 10:30:00-03')
   )
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T20',
 maintenance.temporal_target_is_current('b3100000-0000-0000-0000-000000000001'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T21',
 maintenance.temporal_observation_design_frozen_at('b3120000-0000-0000-0000-000000000001')
   = TIMESTAMPTZ '2026-10-08 13:12:23-03');

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T22',
 maintenance.temporal_observation_authority_state(
   'b3120000-0000-0000-0000-000000000001',
   'operational_execution',
   CURRENT_TIMESTAMP
 )='missing');

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T23',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_observation_authority
   WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T24',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_measurement_event me
   JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
   JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
   WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T25',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_measurement_opportunity_resolution r
   JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
   JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
   WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T26',
 NOT EXISTS(
   SELECT 1 FROM maintenance.temporal_observation_deviation
   WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T27',
 (SELECT count(*)=11 FROM artifact.artifact
  WHERE artifact_uuid::text LIKE 'b3000000-0000-0000-0000-0000000000%'
    AND status='active'
    AND hash_algorithm='git_blob_sha1'));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T28',
 NOT EXISTS(
   SELECT 1
   FROM maintenance.temporal_observation_epoch_issues('b3120000-0000-0000-0000-000000000001')
   WHERE issue_code='OPPORTUNITY_SET_MISMATCH'
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T29',
 EXISTS(
   SELECT 1
   FROM maintenance.temporal_observation_plan_issues('b3100000-0000-0000-0000-000000000001')
   WHERE issue_code='SOURCE_DEBT_PRESENT'
 ));

SELECT pg_temp.topi_prep_assert('TOPI-PREP-T30',
 (SELECT epoch_status='draft'
  FROM maintenance.temporal_observation_epoch
  WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001')
 AND maintenance.temporal_observation_authority_state(
   'b3120000-0000-0000-0000-000000000001',
   'operational_execution',
   CURRENT_TIMESTAMP
 )='missing');

SELECT 'TOPI-PREP-T01-T30 PASS' AS result;
