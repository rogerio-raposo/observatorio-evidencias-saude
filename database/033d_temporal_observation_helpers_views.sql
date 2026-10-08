-- OES migration 033d — helpers and non-normative replay/readiness views

CREATE OR REPLACE FUNCTION maintenance.temporal_measurement_opportunity_status(p_opportunity uuid)
RETURNS text LANGUAGE plpgsql STABLE AS $fn$
DECLARE r text; last_status text; n integer; completed_n integer;
BEGIN
  SELECT resolution_status INTO r
  FROM maintenance.temporal_measurement_opportunity_resolution
  WHERE measurement_opportunity_uuid=p_opportunity;
  IF r IS NOT NULL THEN RETURN r; END IF;

  SELECT count(*),count(*) FILTER (WHERE execution_status='completed')
    INTO n,completed_n
  FROM maintenance.temporal_measurement_event
  WHERE measurement_opportunity_uuid=p_opportunity;

  IF completed_n>1 THEN RETURN 'conflicted'; END IF;
  IF completed_n=1 THEN RETURN 'completed_unresolved'; END IF;
  IF n=0 THEN RETURN 'planned'; END IF;

  SELECT execution_status INTO last_status
  FROM maintenance.temporal_measurement_event
  WHERE measurement_opportunity_uuid=p_opportunity
  ORDER BY attempt_no DESC LIMIT 1;

  IF last_status IN ('failed','partial','indeterminate') THEN RETURN 'retryable'; END IF;
  RETURN 'conflicted';
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_measurement_item_latency(
  p_item uuid,p_semantic_code text
) RETURNS TABLE(
  latency_kind text,
  observability_status text,
  lower_seconds numeric,
  upper_seconds numeric,
  precision_note text,
  calculator_version text
) LANGUAGE plpgsql STABLE AS $fn$
DECLARE tp record; detected timestamptz;
BEGIN
  SELECT oes_detected_at INTO detected
  FROM maintenance.temporal_measurement_item
  WHERE measurement_item_uuid=p_item;
  SELECT * INTO tp
  FROM maintenance.temporal_measurement_item_timepoint
  WHERE measurement_item_uuid=p_item AND semantic_code=p_semantic_code;

  latency_kind:='oes_detection';
  calculator_version:='oes.temporal_latency/0.1';

  IF detected IS NULL OR tp.measurement_item_timepoint_uuid IS NULL
     OR tp.observability_status IN ('not_observable','not_applicable') THEN
    observability_status:='not_observable';
    lower_seconds:=NULL; upper_seconds:=NULL;
    precision_note:='insufficient endpoints';
    RETURN NEXT; RETURN;
  END IF;

  IF tp.lower_bound_at IS NOT NULL AND tp.upper_bound_at IS NOT NULL THEN
    observability_status:=CASE WHEN tp.lower_bound_at=tp.upper_bound_at THEN 'observable' ELSE 'bounded' END;
    lower_seconds:=EXTRACT(EPOCH FROM (detected-tp.upper_bound_at));
    upper_seconds:=EXTRACT(EPOCH FROM (detected-tp.lower_bound_at));
    precision_note:='derived from persisted source bounds and item-level OES detection';
    RETURN NEXT; RETURN;
  END IF;

  observability_status:='not_observable';
  lower_seconds:=NULL; upper_seconds:=NULL;
  precision_note:='raw source value lacks derivable timestamp bounds';
  RETURN NEXT;
END
$fn$;

CREATE OR REPLACE VIEW maintenance.temporal_measurement_replay_v AS
SELECT
  p.observation_plan_uuid,
  p.plan_code,
  p.plan_version,
  COALESCE(p.target_product_version_uuid,p.target_investigation_version_uuid) AS target_version_uuid,
  e.observation_epoch_uuid,
  e.epoch_code,
  e.epoch_status,
  s.observation_source_uuid,
  s.source_code,
  s.source_class,
  s.inclusion_status,
  es.epoch_source_uuid,
  o.measurement_opportunity_uuid,
  o.opportunity_no,
  o.planned_for,
  maintenance.temporal_measurement_opportunity_status(o.measurement_opportunity_uuid) AS opportunity_status,
  count(me.measurement_event_uuid) AS attempt_count,
  min(me.execution_started_at) AS first_started_at,
  max(me.execution_completed_at) AS last_completed_at,
  max(me.attempt_no) AS last_attempt_no,
  (array_agg(me.execution_status ORDER BY me.attempt_no DESC) FILTER (WHERE me.measurement_event_uuid IS NOT NULL))[1] AS last_execution_status,
  (array_agg(me.novelty_state ORDER BY me.attempt_no DESC) FILTER (WHERE me.measurement_event_uuid IS NOT NULL))[1] AS last_novelty_state,
  max(me.raw_result_count) FILTER (WHERE me.raw_result_count_status='known') AS latest_known_raw_result_count,
  max(me.materialized_identifier_count) AS max_materialized_identifier_count,
  max(me.new_identifier_count) AS max_new_identifier_count,
  count(DISTINCT mi.measurement_item_uuid) AS measurement_item_count,
  count(DISTINCT mt.measurement_item_timepoint_uuid) AS item_timepoint_count,
  count(DISTINCT ea.artifact_uuid) AS event_artifact_count,
  count(DISTINCT d.deviation_uuid) AS deviation_count,
  r.resolution_status,
  r.resolved_at
FROM maintenance.temporal_observation_plan p
JOIN maintenance.temporal_observation_epoch e USING(observation_plan_uuid)
JOIN maintenance.temporal_observation_epoch_source es USING(observation_epoch_uuid)
JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
JOIN maintenance.temporal_measurement_opportunity o USING(epoch_source_uuid)
LEFT JOIN maintenance.temporal_measurement_event me USING(measurement_opportunity_uuid)
LEFT JOIN maintenance.temporal_measurement_item mi USING(measurement_event_uuid)
LEFT JOIN maintenance.temporal_measurement_item_timepoint mt USING(measurement_item_uuid)
LEFT JOIN maintenance.temporal_measurement_event_artifact ea USING(measurement_event_uuid)
LEFT JOIN maintenance.temporal_observation_deviation d
  ON d.measurement_opportunity_uuid=o.measurement_opportunity_uuid
LEFT JOIN maintenance.temporal_measurement_opportunity_resolution r USING(measurement_opportunity_uuid)
GROUP BY
  p.observation_plan_uuid,p.plan_code,p.plan_version,
  p.target_product_version_uuid,p.target_investigation_version_uuid,
  e.observation_epoch_uuid,e.epoch_code,e.epoch_status,
  s.observation_source_uuid,s.source_code,s.source_class,s.inclusion_status,
  es.epoch_source_uuid,
  o.measurement_opportunity_uuid,o.opportunity_no,o.planned_for,
  r.resolution_status,r.resolved_at;

CREATE OR REPLACE VIEW maintenance.temporal_measurement_readiness_evidence_v AS
WITH source_debt AS (
  SELECT observation_plan_uuid,
         bool_or(inclusion_status='deferred') AS candidate_source_debt_present,
         count(*) FILTER (WHERE inclusion_status='deferred') AS deferred_source_count
  FROM maintenance.temporal_observation_source
  GROUP BY observation_plan_uuid
), opp AS (
  SELECT
    e.observation_plan_uuid,
    e.observation_epoch_uuid,
    e.epoch_code,
    e.epoch_status,
    s.observation_source_uuid,
    s.source_code,
    count(*) AS planned_opportunities,
    count(*) FILTER (WHERE maintenance.temporal_measurement_opportunity_status(o.measurement_opportunity_uuid)='completed') AS completed_opportunities,
    count(*) FILTER (WHERE maintenance.temporal_measurement_opportunity_status(o.measurement_opportunity_uuid)='failed_closed') AS failed_closed_opportunities,
    count(*) FILTER (WHERE maintenance.temporal_measurement_opportunity_status(o.measurement_opportunity_uuid)='not_executed') AS not_executed_opportunities,
    count(*) FILTER (WHERE maintenance.temporal_measurement_opportunity_status(o.measurement_opportunity_uuid)='indeterminate_closed') AS indeterminate_closed_opportunities,
    count(*) FILTER (WHERE maintenance.temporal_measurement_opportunity_status(o.measurement_opportunity_uuid) IN ('planned','retryable','completed_unresolved','conflicted')) AS unresolved_opportunities,
    min(o.planned_for) AS first_planned_for,
    max(o.planned_for) AS last_planned_for
  FROM maintenance.temporal_observation_epoch e
  JOIN maintenance.temporal_observation_epoch_source es USING(observation_epoch_uuid)
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  JOIN maintenance.temporal_measurement_opportunity o USING(epoch_source_uuid)
  GROUP BY e.observation_plan_uuid,e.observation_epoch_uuid,e.epoch_code,e.epoch_status,
           s.observation_source_uuid,s.source_code
), ev AS (
  SELECT
    es.observation_epoch_uuid,
    s.observation_source_uuid,
    count(*) AS attempt_count,
    count(*) FILTER (WHERE me.raw_result_count_status='known') AS raw_count_known_attempts,
    count(*) FILTER (WHERE me.failure_attribution='source_confirmed') AS source_confirmed_failures,
    count(*) FILTER (WHERE me.failure_attribution='oes_confirmed') AS oes_confirmed_failures,
    sum(COALESCE((me.effort_payload->>'operator_minutes')::numeric,0)) AS operator_minutes_observed
  FROM maintenance.temporal_measurement_event me
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  GROUP BY es.observation_epoch_uuid,s.observation_source_uuid
), items AS (
  SELECT
    es.observation_epoch_uuid,
    s.observation_source_uuid,
    count(DISTINCT mi.measurement_item_uuid) AS item_count,
    count(DISTINCT mi.measurement_item_uuid) FILTER (
      WHERE EXISTS(
        SELECT 1 FROM maintenance.temporal_measurement_item_timepoint tp
        WHERE tp.measurement_item_uuid=mi.measurement_item_uuid
          AND tp.observability_status IN ('observed','bounded')
      )
    ) AS items_with_observable_timepoint
  FROM maintenance.temporal_measurement_item mi
  JOIN maintenance.temporal_measurement_event me USING(measurement_event_uuid)
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  GROUP BY es.observation_epoch_uuid,s.observation_source_uuid
)
SELECT
  opp.observation_plan_uuid,
  opp.observation_epoch_uuid,
  opp.epoch_code,
  opp.epoch_status,
  opp.observation_source_uuid,
  opp.source_code,
  opp.planned_opportunities,
  opp.completed_opportunities,
  opp.failed_closed_opportunities,
  opp.not_executed_opportunities,
  opp.indeterminate_closed_opportunities,
  opp.unresolved_opportunities,
  CASE WHEN opp.planned_opportunities=0 THEN NULL
       ELSE (opp.not_executed_opportunities::numeric/opp.planned_opportunities) END AS descriptive_missingness_proportion,
  COALESCE(ev.attempt_count,0) AS attempt_count,
  COALESCE(ev.raw_count_known_attempts,0) AS raw_count_known_attempts,
  COALESCE(ev.source_confirmed_failures,0) AS source_confirmed_failures,
  COALESCE(ev.oes_confirmed_failures,0) AS oes_confirmed_failures,
  COALESCE(ev.operator_minutes_observed,0) AS operator_minutes_observed,
  COALESCE(items.item_count,0) AS item_count,
  COALESCE(items.items_with_observable_timepoint,0) AS items_with_observable_timepoint,
  opp.first_planned_for,
  opp.last_planned_for,
  (opp.epoch_status='completed') AS epoch_execution_completed,
  COALESCE(sd.candidate_source_debt_present,false) AS candidate_source_debt_present,
  COALESCE(sd.deferred_source_count,0) AS deferred_source_count
FROM opp
LEFT JOIN ev
  ON ev.observation_epoch_uuid=opp.observation_epoch_uuid
 AND ev.observation_source_uuid=opp.observation_source_uuid
LEFT JOIN items
  ON items.observation_epoch_uuid=opp.observation_epoch_uuid
 AND items.observation_source_uuid=opp.observation_source_uuid
LEFT JOIN source_debt sd USING(observation_plan_uuid);
