-- CI-integrated post-activation read-only capture
-- OES Fase 4 — B1R1 post-activation validation capture
-- READ ONLY. Intended only after a valid factual activation.
-- Running before activation is harmless and will report the current state.

\set ON_ERROR_STOP on

BEGIN TRANSACTION READ ONLY;

SELECT CURRENT_TIMESTAMP AS observed_at;

SELECT
  e.observation_epoch_uuid,
  e.epoch_code,
  e.epoch_status,
  e.start_boundary_at,
  e.review_boundary_at,
  e.started_at,
  CASE
    WHEN e.epoch_status='active'
     AND e.started_at IS NOT NULL
     AND e.started_at>=e.start_boundary_at
     AND e.started_at<(
       SELECT min(o.planned_for)
       FROM maintenance.temporal_measurement_opportunity o
       JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
       WHERE es.observation_epoch_uuid=e.observation_epoch_uuid
     )
    THEN 'PASS'
    ELSE 'NOT_YET_PASS'
  END AS activation_state_check,
  maintenance.temporal_target_is_current(e.observation_plan_uuid) AS target_current,
  maintenance.temporal_observation_authority_state(
    e.observation_epoch_uuid,
    'operational_execution',
    COALESCE(e.started_at,CURRENT_TIMESTAMP)
  ) AS authority_state_at_activation_or_now
FROM maintenance.temporal_observation_epoch e
WHERE e.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002';

SELECT
  es.epoch_source_uuid,
  s.source_code,
  es.runtime_connectivity_status,
  maintenance.temporal_epoch_opportunity_set_matches_schedule(es.epoch_source_uuid) AS opportunity_set_matches_schedule,
  count(o.measurement_opportunity_uuid) AS opportunity_count
FROM maintenance.temporal_observation_epoch_source es
JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
LEFT JOIN maintenance.temporal_measurement_opportunity o USING(epoch_source_uuid)
WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
GROUP BY es.epoch_source_uuid,s.source_code,es.runtime_connectivity_status
ORDER BY s.source_code;

SELECT
  count(*) AS measurement_event_count
FROM maintenance.temporal_measurement_event me
JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002';

SELECT
  count(*) AS opportunity_resolution_count
FROM maintenance.temporal_measurement_opportunity_resolution r
JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002';

SELECT
  count(*) AS material_deviation_count
FROM maintenance.temporal_observation_deviation
WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
  AND materiality IN ('new_epoch_required','invalidating')
  AND recorded_at<=CURRENT_TIMESTAMP;

SELECT
  min(planned_for) AS first_pubmed_opportunity
FROM maintenance.temporal_measurement_opportunity
WHERE epoch_source_uuid='b3130000-0000-0000-0000-000000000003';

ROLLBACK;
