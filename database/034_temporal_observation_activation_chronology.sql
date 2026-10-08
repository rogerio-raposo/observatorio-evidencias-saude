-- OES migration 034 — temporal observation activation chronology hardening
-- Date: 2026-10-08
-- Purpose: preserve the chronology of non-normative epoch activation without
-- introducing normative due/overdue/SLA semantics.

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_epoch_activation_chronology()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
  first_opportunity_at timestamptz;
  authority_state_at_start text;
  material_deviation_count integer;
BEGIN
  IF NOT (
    TG_OP='UPDATE'
    AND OLD.epoch_status='authorized_non_normative'
    AND NEW.epoch_status='active'
  ) THEN
    RETURN NEW;
  END IF;

  IF NEW.started_at IS NULL THEN
    RAISE EXCEPTION 'active epoch requires started_at';
  END IF;

  SELECT min(o.planned_for)
    INTO first_opportunity_at
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE es.observation_epoch_uuid=NEW.observation_epoch_uuid;

  IF first_opportunity_at IS NULL THEN
    RAISE EXCEPTION 'active epoch requires at least one materialized opportunity';
  END IF;

  IF NEW.started_at >= first_opportunity_at THEN
    RAISE EXCEPTION
      'epoch activation started_at (%) must precede first opportunity (%)',
      NEW.started_at,first_opportunity_at;
  END IF;

  authority_state_at_start :=
    maintenance.temporal_observation_authority_state(
      NEW.observation_epoch_uuid,
      'operational_execution',
      NEW.started_at
    );

  IF authority_state_at_start <> 'approved' THEN
    RAISE EXCEPTION
      'operational execution authority was not approved at started_at; state=%',
      authority_state_at_start;
  END IF;

  SELECT count(*)
    INTO material_deviation_count
  FROM maintenance.temporal_observation_deviation
  WHERE observation_epoch_uuid=NEW.observation_epoch_uuid
    AND materiality IN ('new_epoch_required','invalidating')
    AND recorded_at <= NEW.started_at;

  IF material_deviation_count > 0 THEN
    RAISE EXCEPTION
      'material deviation blocks epoch activation at started_at';
  END IF;

  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_epoch_activation_chronology
  ON maintenance.temporal_observation_epoch;

CREATE TRIGGER tr_temporal_epoch_activation_chronology
BEFORE UPDATE OF epoch_status,started_at
ON maintenance.temporal_observation_epoch
FOR EACH ROW
EXECUTE FUNCTION maintenance.assert_temporal_epoch_activation_chronology();
