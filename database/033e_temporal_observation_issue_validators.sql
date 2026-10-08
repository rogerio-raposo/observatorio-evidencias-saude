-- OES migration 033e — issue validators for non-normative temporal observation

CREATE OR REPLACE FUNCTION maintenance.temporal_observation_plan_issues(p_plan uuid)
RETURNS TABLE(issue_code text,severity text,detail text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE p maintenance.temporal_observation_plan%ROWTYPE;
BEGIN
  SELECT * INTO p FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid=p_plan;
  IF NOT FOUND THEN
    issue_code:='PLAN_NOT_FOUND';severity:='error';detail:='plan does not exist';RETURN NEXT;RETURN;
  END IF;
  IF NOT maintenance.temporal_artifact_is_active(p.specification_artifact_uuid) THEN
    issue_code:='ARTIFACT_INACTIVE';severity:='blocker';detail:='plan specification artifact is not active';RETURN NEXT;
  END IF;
  IF p.record_status='active' AND NOT maintenance.temporal_target_is_current(p_plan) THEN
    issue_code:='TARGET_NOT_CURRENT';severity:='blocker';detail:='exact target is not current';RETURN NEXT;
  END IF;
  IF EXISTS(
    SELECT 1 FROM maintenance.temporal_observation_source
    WHERE observation_plan_uuid=p_plan AND inclusion_status='deferred'
  ) THEN
    issue_code:='SOURCE_DEBT_PRESENT';severity:='info';detail:='candidate source debt is explicitly present';RETURN NEXT;
  END IF;
  RETURN;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_observation_epoch_issues(p_epoch uuid)
RETURNS TABLE(issue_code text,severity text,detail text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE e maintenance.temporal_observation_epoch%ROWTYPE; auth text; mismatch integer; unresolved integer; material_dev integer;
BEGIN
  SELECT * INTO e FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid=p_epoch;
  IF NOT FOUND THEN
    issue_code:='EPOCH_NOT_FOUND';severity:='error';detail:='epoch does not exist';RETURN NEXT;RETURN;
  END IF;

  IF NOT maintenance.temporal_target_is_current(e.observation_plan_uuid) THEN
    issue_code:='TARGET_NOT_CURRENT';severity:='blocker';detail:='target is not current';RETURN NEXT;
  END IF;

  auth:=maintenance.temporal_observation_authority_state(p_epoch,'operational_execution',CURRENT_TIMESTAMP);
  IF e.epoch_status IN ('authorized_non_normative','active') AND auth<>'approved' THEN
    issue_code:=CASE WHEN auth='withdrawn' THEN 'AUTHORITY_WITHDRAWN' WHEN auth='conflict' THEN 'AUTHORITY_CONFLICT' ELSE 'AUTHORITY_MISSING' END;
    severity:='blocker';detail:='operational authority state='||auth;RETURN NEXT;
  END IF;

  IF NOT maintenance.temporal_artifact_is_active(e.measurement_design_artifact_uuid) THEN
    issue_code:='ARTIFACT_INACTIVE';severity:='blocker';detail:='measurement design artifact is not active';RETURN NEXT;
  END IF;

  IF EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_epoch_source es
    JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
    WHERE es.observation_epoch_uuid=p_epoch
      AND s.runtime_connectivity_required
      AND es.runtime_connectivity_status<>'verified'
  ) THEN
    issue_code:='RUNTIME_CONNECTIVITY_UNVERIFIED';severity:='blocker';detail:='source requires verified runtime connectivity';RETURN NEXT;
  END IF;

  SELECT count(*) INTO mismatch
  FROM maintenance.temporal_observation_epoch_source es
  WHERE es.observation_epoch_uuid=p_epoch
    AND NOT maintenance.temporal_epoch_opportunity_set_matches_schedule(es.epoch_source_uuid);
  IF mismatch>0 THEN
    issue_code:='OPPORTUNITY_SET_MISMATCH';severity:='blocker';detail:='canonical payload differs from materialized opportunities';RETURN NEXT;
  END IF;

  SELECT count(*) INTO unresolved
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  LEFT JOIN maintenance.temporal_measurement_opportunity_resolution r USING(measurement_opportunity_uuid)
  WHERE es.observation_epoch_uuid=p_epoch AND r.opportunity_resolution_uuid IS NULL;
  IF unresolved>0 THEN
    issue_code:='OPPORTUNITY_UNRESOLVED';severity:='warning';detail:=unresolved||' opportunity rows unresolved';RETURN NEXT;
  END IF;

  SELECT count(*) INTO material_dev
  FROM maintenance.temporal_observation_deviation
  WHERE observation_epoch_uuid=p_epoch AND materiality IN ('new_epoch_required','invalidating');
  IF material_dev>0 THEN
    issue_code:='MATERIAL_DEVIATION';severity:='blocker';detail:=material_dev||' material deviations';RETURN NEXT;
  END IF;

  IF EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_source s
    JOIN maintenance.temporal_observation_plan p USING(observation_plan_uuid)
    WHERE p.observation_plan_uuid=e.observation_plan_uuid AND s.inclusion_status='deferred'
  ) THEN
    issue_code:='SOURCE_DEBT_PRESENT';severity:='info';detail:='candidate source debt remains visible';RETURN NEXT;
  END IF;
  RETURN;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_measurement_event_issues(p_event uuid)
RETURNS TABLE(issue_code text,severity text,detail text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE me maintenance.temporal_measurement_event%ROWTYPE; item_n integer; new_n integer;
BEGIN
  SELECT * INTO me FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid=p_event;
  IF NOT FOUND THEN
    issue_code:='EVENT_NOT_FOUND';severity:='error';detail:='event does not exist';RETURN NEXT;RETURN;
  END IF;

  IF me.raw_result_count_status='known' AND me.raw_result_count IS NULL THEN
    issue_code:='RAW_RESULT_COUNT_INCONSISTENT';severity:='blocker';detail:='known raw count is null';RETURN NEXT;
  END IF;
  IF me.failure_attribution IN ('source_confirmed','mixed')
     AND (me.failure_evidence_artifact_uuid IS NULL OR NOT maintenance.temporal_artifact_is_active(me.failure_evidence_artifact_uuid)) THEN
    issue_code:='FAILURE_ATTRIBUTION_UNSUPPORTED';severity:='blocker';detail:='source/mixed attribution lacks active evidence artifact';RETURN NEXT;
  END IF;

  SELECT count(*),count(*) FILTER (WHERE item_state='new_to_epoch')
    INTO item_n,new_n
  FROM maintenance.temporal_measurement_item
  WHERE measurement_event_uuid=p_event;

  IF me.materialized_identifier_count IS NOT NULL AND me.materialized_identifier_count<>item_n THEN
    issue_code:='MATERIALIZED_COUNT_INCONSISTENT';severity:='blocker';detail:='materialized count differs from child items';RETURN NEXT;
  END IF;
  IF me.new_identifier_count IS NOT NULL AND me.new_identifier_count<>new_n THEN
    issue_code:='NOVELTY_COUNT_INCONSISTENT';severity:='blocker';detail:='new count differs from child item states';RETURN NEXT;
  END IF;
  IF me.novelty_state='zero_new' AND new_n<>0 THEN
    issue_code:='NOVELTY_COUNT_INCONSISTENT';severity:='blocker';detail:='zero_new event has new_to_epoch items';RETURN NEXT;
  END IF;
  IF me.novelty_state='new_items' AND new_n=0 THEN
    issue_code:='NOVELTY_COUNT_INCONSISTENT';severity:='blocker';detail:='new_items event has zero new_to_epoch items';RETURN NEXT;
  END IF;
  IF maintenance.jsonb_contains_forbidden_temporal_keys(me.effort_payload) THEN
    issue_code:='NORMATIVE_LEAKAGE';severity:='blocker';detail:='effort payload contains forbidden temporal semantics';RETURN NEXT;
  END IF;
  RETURN;
END
$fn$;
