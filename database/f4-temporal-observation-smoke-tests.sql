-- F4-TNO migration 033 smoke tests
\set ON_ERROR_STOP on

DO $$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n
  FROM information_schema.tables
  WHERE table_schema='maintenance'
    AND table_name IN (
      'temporal_observation_plan','temporal_observation_source','temporal_observation_epoch',
      'temporal_observation_epoch_source','temporal_observation_authority',
      'temporal_measurement_opportunity','temporal_measurement_event',
      'temporal_measurement_opportunity_resolution','temporal_measurement_item',
      'temporal_measurement_item_timepoint','temporal_measurement_event_artifact',
      'temporal_observation_deviation'
    );
  IF n<>12 THEN RAISE EXCEPTION 'F4-TNO smoke: expected 12 tables, got %',n; END IF;

  IF EXISTS(SELECT 1 FROM maintenance.temporal_observation_plan) THEN
    RAISE EXCEPTION 'F4-TNO smoke: migration 033 must contain zero seed before fixtures';
  END IF;

  IF to_regclass('maintenance.temporal_measurement_replay_v') IS NULL
     OR to_regclass('maintenance.temporal_measurement_readiness_evidence_v') IS NULL THEN
    RAISE EXCEPTION 'F4-TNO smoke: views missing';
  END IF;

  IF to_regprocedure('maintenance.temporal_epoch_opportunity_set_matches_schedule(uuid)') IS NULL THEN
    RAISE EXCEPTION 'F4-TNO smoke: schedule equality helper missing';
  END IF;
END $$;

SELECT 'F4-TNO-SMOKE PASS' AS result;
