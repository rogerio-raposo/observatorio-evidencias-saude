-- OES Fase 4 — B1R1 PubMed first-measurement pre-check
-- READ ONLY. Intended immediately before the first factual PubMed attempt.
-- Running before activation is harmless and should report NOT_READY.

\set ON_ERROR_STOP on

BEGIN TRANSACTION READ ONLY;

SELECT CURRENT_TIMESTAMP AS observed_at;

WITH opp AS (
  SELECT
    o.measurement_opportunity_uuid,
    o.epoch_source_uuid,
    o.opportunity_no,
    o.planned_for,
    es.observation_epoch_uuid
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE o.measurement_opportunity_uuid='b3140000-0000-0000-0000-000000000015'
),
state AS (
  SELECT
    e.epoch_status,
    e.started_at,
    maintenance.temporal_target_is_current(e.observation_plan_uuid) AS target_current,
    maintenance.temporal_observation_authority_state(
      e.observation_epoch_uuid,
      'operational_execution',
      CURRENT_TIMESTAMP
    ) AS authority_state,
    EXISTS(
      SELECT 1
      FROM maintenance.temporal_measurement_opportunity_resolution r
      WHERE r.measurement_opportunity_uuid='b3140000-0000-0000-0000-000000000015'
    ) AS opportunity_resolved,
    COALESCE((
      SELECT max(attempt_no)
      FROM maintenance.temporal_measurement_event
      WHERE measurement_opportunity_uuid='b3140000-0000-0000-0000-000000000015'
    ),0) AS prior_attempt_count,
    COALESCE((
      SELECT count(*)
      FROM maintenance.temporal_measurement_event me
      JOIN maintenance.temporal_measurement_opportunity o2 USING(measurement_opportunity_uuid)
      WHERE o2.epoch_source_uuid='b3130000-0000-0000-0000-000000000003'
        AND me.execution_status='completed'
    ),0) AS prior_completed_source_count,
    EXISTS(
      SELECT 1 FROM maintenance.temporal_observation_deviation d
      WHERE d.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
        AND d.materiality IN ('new_epoch_required','invalidating')
        AND d.recorded_at<=CURRENT_TIMESTAMP
    ) AS blocking_deviation
  FROM maintenance.temporal_observation_epoch e
  WHERE e.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
)
SELECT
  opp.measurement_opportunity_uuid,
  opp.epoch_source_uuid,
  opp.opportunity_no,
  opp.planned_for,
  state.epoch_status,
  state.started_at,
  state.target_current,
  state.authority_state,
  state.opportunity_resolved,
  state.prior_attempt_count,
  state.prior_completed_source_count,
  state.blocking_deviation,
  CASE
    WHEN state.epoch_status='active'
     AND state.started_at IS NOT NULL
     AND state.target_current
     AND state.authority_state='approved'
     AND NOT state.opportunity_resolved
     AND NOT state.blocking_deviation
     AND CURRENT_TIMESTAMP>=opp.planned_for
    THEN 'READY'
    ELSE 'NOT_READY'
  END AS first_pubmed_attempt_readiness,
  CASE
    WHEN state.prior_completed_source_count=0 THEN 'BASELINE_IF_COMPLETED'
    ELSE 'SUBSEQUENT_COMPLETED_SEMANTICS'
  END AS completed_semantics_if_this_attempt_completes,
  state.prior_attempt_count+1 AS expected_attempt_no
FROM opp CROSS JOIN state;

SELECT
  count(*) AS existing_measurement_event_count
FROM maintenance.temporal_measurement_event
WHERE measurement_opportunity_uuid='b3140000-0000-0000-0000-000000000015';

SELECT
  count(*) AS existing_resolution_count
FROM maintenance.temporal_measurement_opportunity_resolution
WHERE measurement_opportunity_uuid='b3140000-0000-0000-0000-000000000015';

SELECT
  count(*) AS prior_completed_pubmed_events
FROM maintenance.temporal_measurement_event me
JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
WHERE o.epoch_source_uuid='b3130000-0000-0000-0000-000000000003'
  AND me.execution_status='completed';

ROLLBACK;
