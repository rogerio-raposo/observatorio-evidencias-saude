-- OES Fase 4 — B1R1 first-measurement post-readout
-- READ ONLY. Covers first PubMed and first ClinicalTrials.gov Opportunities.
-- Safe before any real measurement; then it should report zero attempts / planned state.

\set ON_ERROR_STOP on

BEGIN TRANSACTION READ ONLY;

SELECT CURRENT_TIMESTAMP AS observed_at;

WITH first_opportunities AS (
  SELECT unnest(ARRAY[
    'b3140000-0000-0000-0000-000000000015'::uuid,
    'b3140000-0000-0000-0000-000000000023'::uuid
  ]) AS measurement_opportunity_uuid
)
SELECT
  rv.source_code,
  rv.measurement_opportunity_uuid,
  rv.opportunity_no,
  rv.planned_for,
  rv.opportunity_status,
  rv.attempt_count,
  rv.first_started_at,
  rv.last_completed_at,
  rv.last_execution_status,
  rv.last_novelty_state,
  rv.measurement_item_count,
  rv.item_timepoint_count,
  rv.event_artifact_count,
  rv.deviation_count,
  rv.resolution_status,
  rv.resolved_at
FROM maintenance.temporal_measurement_replay_v rv
JOIN first_opportunities f USING(measurement_opportunity_uuid)
ORDER BY rv.planned_for;

WITH events AS (
  SELECT
    s.source_code,
    o.measurement_opportunity_uuid,
    me.measurement_event_uuid,
    me.attempt_no,
    me.execution_status,
    me.execution_started_at,
    me.execution_completed_at,
    me.novelty_state,
    me.raw_result_count,
    me.raw_result_count_status,
    me.materialized_identifier_count,
    me.new_identifier_count,
    me.failure_attribution,
    me.failure_evidence_artifact_uuid,
    me.effort_payload,
    me.operator,
    me.actor_type
  FROM maintenance.temporal_measurement_event me
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  WHERE o.measurement_opportunity_uuid IN (
    'b3140000-0000-0000-0000-000000000015',
    'b3140000-0000-0000-0000-000000000023'
  )
)
SELECT *
FROM events
ORDER BY source_code,attempt_no;

SELECT
  me.measurement_opportunity_uuid,
  me.measurement_event_uuid,
  count(DISTINCT mi.measurement_item_uuid) AS item_count,
  count(DISTINCT mt.measurement_item_timepoint_uuid) AS timepoint_count,
  count(DISTINCT ea.artifact_uuid) AS event_artifact_count
FROM maintenance.temporal_measurement_event me
LEFT JOIN maintenance.temporal_measurement_item mi USING(measurement_event_uuid)
LEFT JOIN maintenance.temporal_measurement_item_timepoint mt USING(measurement_item_uuid)
LEFT JOIN maintenance.temporal_measurement_event_artifact ea USING(measurement_event_uuid)
WHERE me.measurement_opportunity_uuid IN (
  'b3140000-0000-0000-0000-000000000015',
  'b3140000-0000-0000-0000-000000000023'
)
GROUP BY me.measurement_opportunity_uuid,me.measurement_event_uuid
ORDER BY me.measurement_opportunity_uuid,me.measurement_event_uuid;

SELECT
  measurement_opportunity_uuid,
  resolution_status,
  terminal_measurement_event_uuid,
  reason_code,
  reason_artifact_uuid,
  resolved_at,
  resolved_by
FROM maintenance.temporal_measurement_opportunity_resolution
WHERE measurement_opportunity_uuid IN (
  'b3140000-0000-0000-0000-000000000015',
  'b3140000-0000-0000-0000-000000000023'
)
ORDER BY measurement_opportunity_uuid;

SELECT
  observation_deviation_uuid,
  measurement_opportunity_uuid,
  measurement_event_uuid,
  deviation_type,
  materiality,
  observed_at,
  recorded_at,
  note
FROM maintenance.temporal_observation_deviation
WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
  AND (
    measurement_opportunity_uuid IN (
      'b3140000-0000-0000-0000-000000000015',
      'b3140000-0000-0000-0000-000000000023'
    )
    OR measurement_opportunity_uuid IS NULL
  )
ORDER BY recorded_at;

ROLLBACK;
