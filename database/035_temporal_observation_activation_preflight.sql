-- OES migration 035 — temporal observation activation preflight
-- Date: 2026-10-08
-- Purpose: provide a deterministic, read-only activation preflight for a
-- non-normative observation epoch. This does not activate an epoch and does
-- not create any MeasurementEvent or schedule semantics.

CREATE OR REPLACE FUNCTION maintenance.temporal_activation_preflight(
  p_epoch uuid,
  p_as_of timestamptz DEFAULT CURRENT_TIMESTAMP
)
RETURNS TABLE(
  check_code text,
  check_status text,
  detail text
)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
  e maintenance.temporal_observation_epoch%ROWTYPE;
  p maintenance.temporal_observation_plan%ROWTYPE;
  first_opportunity_at timestamptz;
  auth_state text;
  bad_artifacts integer;
  bad_connectivity integer;
  mismatch_count integer;
  material_deviation_count integer;
  event_count integer;
  resolution_count integer;
BEGIN
  SELECT * INTO e
  FROM maintenance.temporal_observation_epoch
  WHERE observation_epoch_uuid=p_epoch;

  IF NOT FOUND THEN
    check_code:='EPOCH_EXISTS';
    check_status:='FAIL';
    detail:='epoch not found';
    RETURN NEXT;
    RETURN;
  END IF;

  SELECT * INTO p
  FROM maintenance.temporal_observation_plan
  WHERE observation_plan_uuid=e.observation_plan_uuid;

  check_code:='EPOCH_EXISTS';
  check_status:='PASS';
  detail:='epoch exists';
  RETURN NEXT;

  check_code:='EPOCH_STATUS';
  IF e.epoch_status='authorized_non_normative' THEN
    check_status:='PASS';
    detail:='epoch is authorized_non_normative';
  ELSE
    check_status:='FAIL';
    detail:='expected authorized_non_normative, observed '||e.epoch_status;
  END IF;
  RETURN NEXT;

  check_code:='TARGET_CURRENT';
  IF maintenance.temporal_target_is_current(e.observation_plan_uuid) THEN
    check_status:='PASS';
    detail:='exact target is current';
  ELSE
    check_status:='FAIL';
    detail:='exact target is not current';
  END IF;
  RETURN NEXT;

  auth_state:=maintenance.temporal_observation_authority_state(
    p_epoch,'operational_execution',p_as_of
  );

  check_code:='AUTHORITY_STATE';
  IF auth_state='approved' THEN
    check_status:='PASS';
    detail:='operational execution authority approved as of preflight time';
  ELSE
    check_status:='FAIL';
    detail:='operational execution authority state='||auth_state;
  END IF;
  RETURN NEXT;

  SELECT count(*) INTO bad_artifacts
  FROM (
    SELECT p.specification_artifact_uuid AS artifact_uuid
    UNION ALL
    SELECT e.measurement_design_artifact_uuid
    UNION ALL
    SELECT s.source_definition_artifact_uuid
    FROM maintenance.temporal_observation_source s
    WHERE s.observation_plan_uuid=e.observation_plan_uuid
      AND s.inclusion_status IN ('included','deferred')
      AND s.source_definition_artifact_uuid IS NOT NULL
    UNION ALL
    SELECT es.schedule_definition_artifact_uuid
    FROM maintenance.temporal_observation_epoch_source es
    WHERE es.observation_epoch_uuid=p_epoch
    UNION ALL
    SELECT es.query_strategy_artifact_uuid
    FROM maintenance.temporal_observation_epoch_source es
    WHERE es.observation_epoch_uuid=p_epoch
      AND es.query_strategy_artifact_uuid IS NOT NULL
    UNION ALL
    SELECT es.interface_config_artifact_uuid
    FROM maintenance.temporal_observation_epoch_source es
    WHERE es.observation_epoch_uuid=p_epoch
      AND es.interface_config_artifact_uuid IS NOT NULL
    UNION ALL
    SELECT es.baseline_artifact_uuid
    FROM maintenance.temporal_observation_epoch_source es
    WHERE es.observation_epoch_uuid=p_epoch
      AND es.baseline_artifact_uuid IS NOT NULL
    UNION ALL
    SELECT a.decision_artifact_uuid
    FROM maintenance.temporal_observation_authority a
    WHERE a.observation_epoch_uuid=p_epoch
      AND a.authority_domain='operational_execution'
      AND a.decided_at<=p_as_of
  ) x
  WHERE x.artifact_uuid IS NULL
     OR NOT maintenance.temporal_artifact_is_active(x.artifact_uuid);

  check_code:='CONTROLLING_ARTIFACTS';
  IF bad_artifacts=0 THEN
    check_status:='PASS';
    detail:='all controlling artifacts are active';
  ELSE
    check_status:='FAIL';
    detail:=bad_artifacts||' controlling artifacts are missing/inactive';
  END IF;
  RETURN NEXT;

  SELECT count(*) INTO bad_connectivity
  FROM maintenance.temporal_observation_epoch_source es
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  WHERE es.observation_epoch_uuid=p_epoch
    AND s.runtime_connectivity_required
    AND es.runtime_connectivity_status<>'verified';

  check_code:='RUNTIME_CONNECTIVITY';
  IF bad_connectivity=0 THEN
    check_status:='PASS';
    detail:='all required frozen runtime connectivity statuses are verified';
  ELSE
    check_status:='FAIL';
    detail:=bad_connectivity||' required source interfaces are not verified';
  END IF;
  RETURN NEXT;

  SELECT count(*) INTO mismatch_count
  FROM maintenance.temporal_observation_epoch_source es
  WHERE es.observation_epoch_uuid=p_epoch
    AND NOT maintenance.temporal_epoch_opportunity_set_matches_schedule(es.epoch_source_uuid);

  check_code:='OPPORTUNITY_SET';
  IF mismatch_count=0 THEN
    check_status:='PASS';
    detail:='materialized opportunities exactly match frozen schedule payloads';
  ELSE
    check_status:='FAIL';
    detail:=mismatch_count||' epoch source opportunity sets mismatch';
  END IF;
  RETURN NEXT;

  SELECT count(*) INTO material_deviation_count
  FROM maintenance.temporal_observation_deviation
  WHERE observation_epoch_uuid=p_epoch
    AND materiality IN ('new_epoch_required','invalidating')
    AND recorded_at<=p_as_of;

  check_code:='MATERIAL_DEVIATIONS';
  IF material_deviation_count=0 THEN
    check_status:='PASS';
    detail:='no material or invalidating deviation exists as of preflight time';
  ELSE
    check_status:='FAIL';
    detail:=material_deviation_count||' material/invalidating deviations exist';
  END IF;
  RETURN NEXT;

  SELECT count(*) INTO event_count
  FROM maintenance.temporal_measurement_event me
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE es.observation_epoch_uuid=p_epoch;

  SELECT count(*) INTO resolution_count
  FROM maintenance.temporal_measurement_opportunity_resolution r
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE es.observation_epoch_uuid=p_epoch;

  check_code:='PRESTART_EVENT_STATE';
  IF event_count=0 AND resolution_count=0 THEN
    check_status:='PASS';
    detail:='zero MeasurementEvent and zero OpportunityResolution before activation';
  ELSE
    check_status:='FAIL';
    detail:='pre-activation event/resolution rows already exist';
  END IF;
  RETURN NEXT;

  SELECT min(o.planned_for) INTO first_opportunity_at
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE es.observation_epoch_uuid=p_epoch;

  check_code:='ACTIVATION_WINDOW';
  IF first_opportunity_at IS NULL THEN
    check_status:='FAIL';
    detail:='no first opportunity exists';
  ELSIF p_as_of<e.start_boundary_at THEN
    check_status:='WAIT';
    detail:='NOT_IN_ACTIVATION_WINDOW: preflight time precedes start boundary';
  ELSIF p_as_of>=first_opportunity_at THEN
    check_status:='FAIL';
    detail:='EXPIRED_NOT_EXECUTED: preflight time is at/after first opportunity';
  ELSE
    check_status:='PASS';
    detail:='preflight time is within factual activation interval';
  END IF;
  RETURN NEXT;

  check_code:='SOURCE_DEBT_VISIBILITY';
  IF EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_source s
    WHERE s.observation_plan_uuid=e.observation_plan_uuid
      AND s.inclusion_status='deferred'
  ) THEN
    check_status:='INFO';
    detail:='deferred source debt remains visible and is not silently resolved';
  ELSE
    check_status:='INFO';
    detail:='no deferred source debt is recorded';
  END IF;
  RETURN NEXT;

  RETURN;
END
$fn$;


CREATE OR REPLACE FUNCTION maintenance.temporal_activation_preflight_state(
  p_epoch uuid,
  p_as_of timestamptz DEFAULT CURRENT_TIMESTAMP
)
RETURNS text
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
  fail_n integer;
  wait_n integer;
BEGIN
  SELECT count(*) FILTER (WHERE check_status='FAIL'),
         count(*) FILTER (WHERE check_status='WAIT')
    INTO fail_n,wait_n
  FROM maintenance.temporal_activation_preflight(p_epoch,p_as_of);

  IF fail_n>0 THEN
    RETURN 'FAIL';
  END IF;

  IF wait_n>0 THEN
    RETURN 'WAIT';
  END IF;

  RETURN 'PASS';
END
$fn$;
