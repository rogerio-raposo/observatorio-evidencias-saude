-- F4-TCAL-PH smoke tests for migration 032
BEGIN;

DO $t$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n
  FROM information_schema.tables
  WHERE table_schema='maintenance'
    AND table_name IN (
      'temporal_contract_grandfathered_object',
      'temporal_calibration_dossier',
      'temporal_calibration_authority',
      'temporal_calibration_basis',
      'temporal_calibration_candidate',
      'temporal_calibration_evaluation',
      'cadence_contract','cadence_obligation','cadence_observation',
      'fixed_deadline_source'
    );
  IF n<>10 THEN RAISE EXCEPTION 'F4-TCAL-PH-SMOKE FAIL: expected 10 new tables, got %',n; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM maintenance.contract_epoch
    WHERE contract_code='TEMPORAL_CALIBRATION_V01' AND schema_version='0.1' AND migration_id='032'
  ) THEN RAISE EXCEPTION 'F4-TCAL-PH-SMOKE FAIL: contract epoch missing'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='maintenance' AND table_name='update_policy' AND column_name='cadence_contract_uuid'
  ) OR NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='maintenance' AND table_name='sla_instance' AND column_name='due_calculation_payload'
  ) OR NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='maintenance' AND table_name='sla_pause' AND column_name='accountable_pause_seconds'
  ) THEN RAISE EXCEPTION 'F4-TCAL-PH-SMOKE FAIL: extension columns missing'; END IF;

  IF to_regprocedure('maintenance.resolve_sla_rule(uuid,text,uuid,text)') IS NULL
     OR to_regprocedure('maintenance.sla_nominal_due_at(uuid,timestamp with time zone)') IS NULL
     OR to_regprocedure('maintenance.sla_calendar_add_open_seconds(uuid,timestamp with time zone,numeric)') IS NULL
     OR to_regprocedure('maintenance.cadence_occurrence_due_at(uuid,integer)') IS NULL THEN
    RAISE EXCEPTION 'F4-TCAL-PH-SMOKE FAIL: core helper missing';
  END IF;

  RAISE NOTICE 'F4-TCAL-PH-SMOKE PASS';
END
$t$;

ROLLBACK;
