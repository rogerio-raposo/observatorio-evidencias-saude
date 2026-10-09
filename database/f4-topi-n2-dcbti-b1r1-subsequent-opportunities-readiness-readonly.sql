-- OES Fase 4 — B1R1 subsequent opportunities readiness matrix
-- READ ONLY. Covers all opportunities except the first PubMed and first ClinicalTrials.gov opportunities.

\set ON_ERROR_STOP on

BEGIN TRANSACTION READ ONLY;

SELECT CURRENT_TIMESTAMP AS observed_at;

WITH opps AS (
  SELECT
    o.measurement_opportunity_uuid,
    o.epoch_source_uuid,
    o.opportunity_no,
    o.planned_for,
    es.observation_epoch_uuid,
    s.source_code
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000002'
    AND o.measurement_opportunity_uuid NOT IN (
      'b3140000-0000-0000-0000-000000000015',
      'b3140000-0000-0000-0000-000000000023'
    )
),
matrix AS (
  SELECT
    o.*,
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
      WHERE r.measurement_opportunity_uuid=o.measurement_opportunity_uuid
    ) AS opportunity_resolved,
    COALESCE((
      SELECT max(me.attempt_no)
      FROM maintenance.temporal_measurement_event me
      WHERE me.measurement_opportunity_uuid=o.measurement_opportunity_uuid
    ),0) AS prior_attempt_count,
    COALESCE((
      SELECT count(*)
      FROM maintenance.temporal_measurement_event me
      JOIN maintenance.temporal_measurement_opportunity po USING(measurement_opportunity_uuid)
      WHERE po.epoch_source_uuid=o.epoch_source_uuid
        AND me.execution_status='completed'
        AND me.execution_started_at < CURRENT_TIMESTAMP
    ),0) AS prior_completed_source_count,
    EXISTS(
      SELECT 1 FROM maintenance.temporal_observation_deviation d
      WHERE d.observation_epoch_uuid=o.observation_epoch_uuid
        AND d.materiality IN ('new_epoch_required','invalidating')
        AND d.recorded_at<=CURRENT_TIMESTAMP
    ) AS blocking_deviation
  FROM opps o
  JOIN maintenance.temporal_observation_epoch e
    ON e.observation_epoch_uuid=o.observation_epoch_uuid
)
SELECT
  source_code,
  measurement_opportunity_uuid,
  opportunity_no,
  planned_for,
  epoch_status,
  started_at,
  target_current,
  authority_state,
  opportunity_resolved,
  prior_attempt_count,
  prior_completed_source_count,
  blocking_deviation,
  prior_attempt_count+1 AS expected_attempt_no,
  CASE
    WHEN prior_completed_source_count=0 THEN 'BASELINE_IF_NO_PRIOR_COMPLETED'
    ELSE 'SUBSEQUENT_COMPLETED'
  END AS completed_semantics_if_attempt_completes,
  CASE
    WHEN epoch_status='active'
     AND started_at IS NOT NULL
     AND target_current
     AND authority_state='approved'
     AND NOT opportunity_resolved
     AND NOT blocking_deviation
     AND CURRENT_TIMESTAMP>=planned_for
    THEN 'READY'
    ELSE 'NOT_READY'
  END AS attempt_readiness
FROM matrix
ORDER BY planned_for,source_code;

ROLLBACK;
