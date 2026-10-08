-- OES Fase 4 — TOPI-N2-DCBTI-01 Phase B authority tests
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.topi_auth_assert(p_name text,p_condition boolean,p_detail text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT COALESCE(p_condition,false) THEN
    RAISE EXCEPTION '% FAIL: %',p_name,COALESCE(p_detail,'assertion failed');
  END IF;
  RAISE NOTICE '% PASS',p_name;
END $$;

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T01',
  (SELECT count(*)=1
   FROM maintenance.temporal_observation_authority
   WHERE observation_authority_uuid='b3150000-0000-0000-0000-000000000001'
     AND observation_plan_uuid='b3100000-0000-0000-0000-000000000001'
     AND observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
     AND authority_domain='operational_execution'
     AND decision='approved'
     AND actor='OES_PROJECT_OWNER'
     AND actor_type='owner')
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T02',
  (SELECT decided_at=TIMESTAMPTZ '2026-10-08 13:31:42-03'
   FROM maintenance.temporal_observation_authority
   WHERE observation_authority_uuid='b3150000-0000-0000-0000-000000000001')
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T03',
  (SELECT decided_at >= maintenance.temporal_observation_design_frozen_at(observation_epoch_uuid)
   FROM maintenance.temporal_observation_authority
   WHERE observation_authority_uuid='b3150000-0000-0000-0000-000000000001')
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T04',
  maintenance.temporal_observation_authority_state(
    'b3120000-0000-0000-0000-000000000001',
    'operational_execution',
    TIMESTAMPTZ '2026-10-08 13:31:42-03'
  )='approved'
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T05',
  (SELECT epoch_status='authorized_non_normative'
      AND started_at IS NULL
      AND completed_at IS NULL
   FROM maintenance.temporal_observation_epoch
   WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001')
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T06',
  (SELECT maintenance.temporal_artifact_is_active(decision_artifact_uuid)
   FROM maintenance.temporal_observation_authority
   WHERE observation_authority_uuid='b3150000-0000-0000-0000-000000000001')
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T07',
  (SELECT content_hash='de2629cfecb32a547f8f0e566698ee336130abbe'
      AND hash_algorithm='git_blob_sha1'
      AND status='active'
   FROM artifact.artifact
   WHERE artifact_uuid='b3000000-0000-0000-0000-000000000012')
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T08',
  maintenance.temporal_epoch_opportunity_set_matches_schedule(
    'b3130000-0000-0000-0000-000000000001'
  )
  AND maintenance.temporal_epoch_opportunity_set_matches_schedule(
    'b3130000-0000-0000-0000-000000000002'
  )
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T09',
  maintenance.temporal_target_is_current(
    'b3100000-0000-0000-0000-000000000001'
  )
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T10',
  NOT EXISTS(
    SELECT 1
    FROM maintenance.temporal_measurement_event me
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  )
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T11',
  NOT EXISTS(
    SELECT 1
    FROM maintenance.temporal_measurement_opportunity_resolution r
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  )
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T12',
  NOT EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_epoch_issues(
      'b3120000-0000-0000-0000-000000000001'
    )
    WHERE severity='blocker'
  )
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T13',
  EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_epoch_issues(
      'b3120000-0000-0000-0000-000000000001'
    )
    WHERE issue_code='OPPORTUNITY_UNRESOLVED'
      AND severity='warning'
  )
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T14',
  EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_epoch_issues(
      'b3120000-0000-0000-0000-000000000001'
    )
    WHERE issue_code='SOURCE_DEBT_PRESENT'
      AND severity='info'
  )
);

SELECT pg_temp.topi_auth_assert(
  'TOPI-AUTH-T15',
  (SELECT min(planned_for) > TIMESTAMPTZ '2026-10-08 13:31:42-03'
   FROM maintenance.temporal_measurement_opportunity o
   JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
   WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001')
);

SELECT 'TOPI-AUTH-T01-T15 PASS' AS result;
