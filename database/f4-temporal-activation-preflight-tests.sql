-- OES Fase 4 — activation preflight deterministic tests
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.apf_assert(p_name text,p_condition boolean,p_detail text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT COALESCE(p_condition,false) THEN
    RAISE EXCEPTION '% FAIL: %',p_name,COALESCE(p_detail,'assertion failed');
  END IF;
  RAISE NOTICE '% PASS',p_name;
END $$;

SELECT pg_temp.apf_assert(
  'APF-T01',
  to_regprocedure('maintenance.temporal_activation_preflight(uuid,timestamptz)') IS NOT NULL
);

SELECT pg_temp.apf_assert(
  'APF-T02',
  to_regprocedure('maintenance.temporal_activation_preflight_state(uuid,timestamptz)') IS NOT NULL
);

-- Real B1 before the start boundary must be diagnostic WAIT, not PASS.
SELECT pg_temp.apf_assert(
  'APF-T03',
  maintenance.temporal_activation_preflight_state(
    'b3120000-0000-0000-0000-000000000001',
    TIMESTAMPTZ '2026-10-08 14:47:00-03'
  )='WAIT'
);

SELECT pg_temp.apf_assert(
  'APF-T04',
  EXISTS(
    SELECT 1
    FROM maintenance.temporal_activation_preflight(
      'b3120000-0000-0000-0000-000000000001',
      TIMESTAMPTZ '2026-10-08 14:47:00-03'
    )
    WHERE check_code='ACTIVATION_WINDOW'
      AND check_status='WAIT'
      AND detail LIKE 'NOT_IN_ACTIVATION_WINDOW:%'
  )
);

-- Exact start boundary is eligible.
SELECT pg_temp.apf_assert(
  'APF-T05',
  maintenance.temporal_activation_preflight_state(
    'b3120000-0000-0000-0000-000000000001',
    TIMESTAMPTZ '2026-10-19 08:00:00-03'
  )='PASS'
);

-- A point inside the activation interval is eligible.
SELECT pg_temp.apf_assert(
  'APF-T06',
  maintenance.temporal_activation_preflight_state(
    'b3120000-0000-0000-0000-000000000001',
    TIMESTAMPTZ '2026-10-19 08:30:00-03'
  )='PASS'
);

-- The first opportunity itself is too late for activation.
SELECT pg_temp.apf_assert(
  'APF-T07',
  maintenance.temporal_activation_preflight_state(
    'b3120000-0000-0000-0000-000000000001',
    TIMESTAMPTZ '2026-10-19 09:00:00-03'
  )='FAIL'
);

SELECT pg_temp.apf_assert(
  'APF-T08',
  EXISTS(
    SELECT 1
    FROM maintenance.temporal_activation_preflight(
      'b3120000-0000-0000-0000-000000000001',
      TIMESTAMPTZ '2026-10-19 09:00:00-03'
    )
    WHERE check_code='ACTIVATION_WINDOW'
      AND check_status='FAIL'
      AND detail LIKE 'EXPIRED_NOT_EXECUTED:%'
  )
);

-- All non-window checks for the real B1 are clean at the eligible synthetic as-of time.
SELECT pg_temp.apf_assert(
  'APF-T09',
  NOT EXISTS(
    SELECT 1
    FROM maintenance.temporal_activation_preflight(
      'b3120000-0000-0000-0000-000000000001',
      TIMESTAMPTZ '2026-10-19 08:30:00-03'
    )
    WHERE check_status='FAIL'
  )
);

SELECT pg_temp.apf_assert(
  'APF-T10',
  EXISTS(
    SELECT 1
    FROM maintenance.temporal_activation_preflight(
      'b3120000-0000-0000-0000-000000000001',
      TIMESTAMPTZ '2026-10-19 08:30:00-03'
    )
    WHERE check_code='SOURCE_DEBT_VISIBILITY'
      AND check_status='INFO'
      AND detail LIKE 'deferred source debt remains visible%'
  )
);

-- Missing epoch is fail-closed.
SELECT pg_temp.apf_assert(
  'APF-T11',
  maintenance.temporal_activation_preflight_state(
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    TIMESTAMPTZ '2026-10-19 08:30:00-03'
  )='FAIL'
);

-- Preflight must not mutate the real epoch.
SELECT pg_temp.apf_assert(
  'APF-T12',
  (SELECT epoch_status='authorized_non_normative'
      AND started_at IS NULL
   FROM maintenance.temporal_observation_epoch
   WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001')
);

SELECT pg_temp.apf_assert(
  'APF-T13',
  NOT EXISTS(
    SELECT 1
    FROM maintenance.temporal_measurement_event me
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  )
);

SELECT 'APF-T01-T13 PASS' AS result;
