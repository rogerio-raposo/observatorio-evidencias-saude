-- OES migration 036 — first-measurement aggregate semantics hardening
-- Additive/idempotent hardening authorized by Documento 79 / CP126.

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_first_measurement_semantics()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE
  src_uuid uuid;
  prior_completed integer;
BEGIN
  SELECT o.epoch_source_uuid INTO src_uuid
  FROM maintenance.temporal_measurement_opportunity o
  WHERE o.measurement_opportunity_uuid=NEW.measurement_opportunity_uuid;

  IF src_uuid IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.execution_status='completed' THEN
    SELECT count(*) INTO prior_completed
    FROM maintenance.temporal_measurement_event me
    JOIN maintenance.temporal_measurement_opportunity o
      ON o.measurement_opportunity_uuid=me.measurement_opportunity_uuid
    WHERE o.epoch_source_uuid=src_uuid
      AND me.execution_status='completed';

    IF prior_completed=0 THEN
      IF NEW.novelty_state<>'not_applicable' THEN
        RAISE EXCEPTION 'first completed event for epoch source requires novelty_state=not_applicable';
      END IF;
      IF NEW.new_identifier_count IS NOT NULL THEN
        RAISE EXCEPTION 'first completed event for epoch source requires new_identifier_count NULL';
      END IF;
      IF NEW.failure_attribution<>'not_applicable' THEN
        RAISE EXCEPTION 'completed event requires failure_attribution=not_applicable';
      END IF;
    ELSE
      IF NEW.novelty_state='not_applicable' THEN
        RAISE EXCEPTION 'subsequent completed event for epoch source cannot use novelty_state=not_applicable';
      END IF;
      IF NEW.failure_attribution<>'not_applicable' THEN
        RAISE EXCEPTION 'completed event requires failure_attribution=not_applicable';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_event_first_measurement_semantics
  ON maintenance.temporal_measurement_event;

CREATE TRIGGER tr_temporal_event_first_measurement_semantics
BEFORE INSERT ON maintenance.temporal_measurement_event
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_first_measurement_semantics();
