-- OES Fase 4 — B1R1 live activation preflight evidence capture
-- READ ONLY by construction. This file MUST NOT activate the epoch.
-- Intended for execution in high mode inside the 2026-10-19 activation window.

\set ON_ERROR_STOP on

BEGIN TRANSACTION READ ONLY;

SELECT CURRENT_TIMESTAMP AS observed_at;

SELECT
  'b3120000-0000-0000-0000-000000000002'::uuid AS epoch_uuid,
  maintenance.temporal_activation_preflight_state(
    'b3120000-0000-0000-0000-000000000002',
    CURRENT_TIMESTAMP
  ) AS aggregate_state;

SELECT *
FROM maintenance.temporal_activation_preflight(
  'b3120000-0000-0000-0000-000000000002',
  CURRENT_TIMESTAMP
)
ORDER BY
  CASE check_code
    WHEN 'EPOCH_EXISTS' THEN 1
    WHEN 'EPOCH_STATUS' THEN 2
    WHEN 'TARGET_CURRENT' THEN 3
    WHEN 'AUTHORITY_STATE' THEN 4
    WHEN 'CONTROLLING_ARTIFACTS' THEN 5
    WHEN 'RUNTIME_CONNECTIVITY' THEN 6
    WHEN 'OPPORTUNITY_SET' THEN 7
    WHEN 'MATERIAL_DEVIATIONS' THEN 8
    WHEN 'PRESTART_EVENT_STATE' THEN 9
    WHEN 'ACTIVATION_WINDOW' THEN 10
    WHEN 'SOURCE_DEBT_VISIBILITY' THEN 11
    ELSE 99
  END;

SELECT
  e.observation_epoch_uuid,
  e.epoch_code,
  e.epoch_status,
  e.start_boundary_at,
  e.review_boundary_at,
  e.started_at,
  maintenance.temporal_observation_design_frozen_at(e.observation_epoch_uuid) AS design_frozen_at,
  maintenance.temporal_observation_authority_state(
    e.observation_epoch_uuid,
    'operational_execution',
    CURRENT_TIMESTAMP
  ) AS authority_state
FROM maintenance.temporal_observation_epoch e
WHERE e.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002';

SELECT
  es.epoch_source_uuid,
  s.source_code,
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
  es.epoch_source_uuid,
  s.source_code,
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
  count(*) AS material_deviation_count
FROM maintenance.temporal_observation_deviation
WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
  AND materiality IN ('new_epoch_required','invalidating')
  AND recorded_at<=CURRENT_TIMESTAMP;

SELECT
  min(o.planned_for) AS first_pubmed_opportunity
FROM maintenance.temporal_measurement_opportunity o
WHERE o.epoch_source_uuid='b3130000-0000-0000-0000-000000000003';

ROLLBACK;
