-- OES Fase 4 — B1R1 pre-day-19 readiness audit
-- READ ONLY. Distinguishes preparatory readiness from the still-future activation window.

\set ON_ERROR_STOP on

BEGIN TRANSACTION READ ONLY;

SELECT CURRENT_TIMESTAMP AS observed_at;

WITH checks AS (
  SELECT *
  FROM maintenance.temporal_activation_preflight(
    'b3120000-0000-0000-0000-000000000002',
    CURRENT_TIMESTAMP
  )
),
non_time AS (
  SELECT count(*) FILTER (
           WHERE check_code <> 'ACTIVATION_WINDOW'
             AND check_state NOT IN ('PASS','INFO')
         ) AS non_time_blocker_count,
         count(*) FILTER (
           WHERE check_code <> 'ACTIVATION_WINDOW'
             AND check_state='PASS'
         ) AS non_time_pass_count,
         count(*) FILTER (
           WHERE check_code <> 'ACTIVATION_WINDOW'
             AND check_state='INFO'
         ) AS info_count
  FROM checks
),
window_state AS (
  SELECT check_state AS activation_window_state
  FROM checks
  WHERE check_code='ACTIVATION_WINDOW'
)
SELECT
  non_time_blocker_count,
  non_time_pass_count,
  info_count,
  activation_window_state,
  CASE
    WHEN non_time_blocker_count=0
     AND activation_window_state IN ('WAIT','PASS')
    THEN 'PREPARATION_READY'
    ELSE 'PREPARATION_NOT_READY'
  END AS pre_day19_readiness
FROM non_time CROSS JOIN window_state;

SELECT
  check_code,
  check_state,
  detail
FROM maintenance.temporal_activation_preflight(
  'b3120000-0000-0000-0000-000000000002',
  CURRENT_TIMESTAMP
)
ORDER BY check_code;

SELECT
  e.observation_epoch_uuid,
  e.epoch_code,
  e.epoch_status,
  e.started_at,
  e.start_boundary_at,
  e.review_boundary_at,
  maintenance.temporal_observation_design_frozen_at(e.observation_epoch_uuid) AS design_frozen_at,
  maintenance.temporal_observation_authority_state(
    e.observation_epoch_uuid,
    'operational_execution',
    CURRENT_TIMESTAMP
  ) AS authority_state,
  maintenance.temporal_target_is_current(e.observation_plan_uuid) AS target_current
FROM maintenance.temporal_observation_epoch e
WHERE e.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002';

SELECT
  s.source_code,
  es.epoch_source_uuid,
  es.runtime_interface_code,
  es.runtime_connectivity_status,
  maintenance.temporal_epoch_opportunity_set_matches_schedule(es.epoch_source_uuid) AS opportunity_set_matches_schedule,
  count(o.measurement_opportunity_uuid) AS opportunity_count,
  min(o.planned_for) AS first_opportunity_at,
  max(o.planned_for) AS last_opportunity_at
FROM maintenance.temporal_observation_epoch_source es
JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
LEFT JOIN maintenance.temporal_measurement_opportunity o USING(epoch_source_uuid)
WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
GROUP BY
  s.source_code,
  es.epoch_source_uuid,
  es.runtime_interface_code,
  es.runtime_connectivity_status
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
  count(*) AS blocking_deviation_count
FROM maintenance.temporal_observation_deviation
WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
  AND materiality IN ('new_epoch_required','invalidating')
  AND recorded_at<=CURRENT_TIMESTAMP;

ROLLBACK;
