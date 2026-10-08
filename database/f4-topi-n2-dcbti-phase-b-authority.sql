-- OES Fase 4 — TOPI-N2-DCBTI-01 Phase B execution authority materialization
-- Owner decision recorded in Document 75.
-- This file authorizes the frozen B1 only. It does NOT activate the epoch.

\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
  frozen_at timestamptz;
  first_opportunity_at timestamptz;
BEGIN
  IF NOT maintenance.temporal_target_is_current('b3100000-0000-0000-0000-000000000001') THEN
    RAISE EXCEPTION 'TOPI B1 target is not current';
  END IF;

  SELECT maintenance.temporal_observation_design_frozen_at(
    'b3120000-0000-0000-0000-000000000001'
  )
  INTO frozen_at;

  IF frozen_at IS DISTINCT FROM TIMESTAMPTZ '2026-10-08 13:12:23-03' THEN
    RAISE EXCEPTION 'unexpected B1 design_frozen_at: %',frozen_at;
  END IF;

  SELECT min(o.planned_for)
    INTO first_opportunity_at
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001';

  IF first_opportunity_at IS DISTINCT FROM TIMESTAMPTZ '2026-10-19 09:00:00-03' THEN
    RAISE EXCEPTION 'unexpected first B1 opportunity: %',first_opportunity_at;
  END IF;

  IF TIMESTAMPTZ '2026-10-08 13:31:42-03' < frozen_at THEN
    RAISE EXCEPTION 'owner execution decision predates design freeze';
  END IF;

  IF TIMESTAMPTZ '2026-10-08 13:31:42-03' >= first_opportunity_at THEN
    RAISE EXCEPTION 'owner execution decision is not before first opportunity';
  END IF;

  IF EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_authority
    WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
      AND authority_domain='operational_execution'
  ) THEN
    RAISE EXCEPTION 'operational execution authority already exists for B1';
  END IF;

  IF EXISTS(
    SELECT 1
    FROM maintenance.temporal_measurement_event me
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  ) THEN
    RAISE EXCEPTION 'B1 already has MeasurementEvent rows';
  END IF;
END $$;

INSERT INTO artifact.artifact(
  artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,mime_type,
  source_uri,created_at,created_by,status
) VALUES (
  'b3000000-0000-0000-0000-000000000012',
  'decision',
  'docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md',
  'de2629cfecb32a547f8f0e566698ee336130abbe',
  'git_blob_sha1',
  'text/markdown',
  'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md',
  TIMESTAMPTZ '2026-10-08 14:11:45-03',
  'OES_PROJECT_OWNER',
  'active'
);

INSERT INTO maintenance.temporal_observation_authority(
  observation_authority_uuid,observation_plan_uuid,observation_epoch_uuid,
  authority_domain,decision,actor,actor_type,decision_artifact_uuid,decided_at,
  limitations_payload,created_at
) VALUES (
  'b3150000-0000-0000-0000-000000000001',
  'b3100000-0000-0000-0000-000000000001',
  'b3120000-0000-0000-0000-000000000001',
  'operational_execution',
  'approved',
  'OES_PROJECT_OWNER',
  'owner',
  'b3000000-0000-0000-0000-000000000012',
  TIMESTAMPTZ '2026-10-08 13:31:42-03',
  '{
    "non_normative": true,
    "scope": "TOPI-N2-DCBTI-01 / Epoch B1 frozen design only",
    "document": 75,
    "pubmed_opportunities": 8,
    "clinicaltrials_gov_opportunities": 6,
    "bvs_lilacs": "deferred_source_debt",
    "activation_requires_separate_start_boundary_preflight": true
  }'::jsonb,
  TIMESTAMPTZ '2026-10-08 14:11:45-03'
);

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='authorized_non_normative'
WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  AND epoch_status='draft';

DO $
BEGIN
  IF NOT EXISTS(
    SELECT 1
    FROM maintenance.temporal_observation_epoch
    WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
      AND epoch_status='authorized_non_normative'
      AND started_at IS NULL
  ) THEN
    RAISE EXCEPTION 'B1 draft -> authorized_non_normative transition did not occur';
  END IF;
END $;

COMMIT;
