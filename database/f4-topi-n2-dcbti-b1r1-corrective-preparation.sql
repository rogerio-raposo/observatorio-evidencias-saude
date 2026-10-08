-- OES Fase 4 — TOPI-N2-DCBTI-01 corrective preparation: B1 -> B1R1
-- Authority: Documento 83, based on Documento 82.
-- Connectivity evidence: run 37855302262 / run 224 / job 113577921135.
-- This file invalidates the non-executed B1 and materializes B1R1 as draft only.
-- It does NOT create B1R1 execution authority, activation, MeasurementEvent or real source execution.

\set ON_ERROR_STOP on

BEGIN;

DO $pre$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM maintenance.temporal_observation_epoch
    WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
      AND epoch_status='authorized_non_normative'
      AND started_at IS NULL
      AND completed_at IS NULL
  ) THEN
    RAISE EXCEPTION 'corrective preparation requires non-executed authorized B1';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM maintenance.temporal_measurement_event me
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  ) THEN
    RAISE EXCEPTION 'cannot replace B1 after MeasurementEvent exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM maintenance.temporal_measurement_opportunity_resolution r
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE es.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  ) THEN
    RAISE EXCEPTION 'cannot replace B1 after OpportunityResolution exists';
  END IF;

  IF EXISTS (
    SELECT 1 FROM maintenance.temporal_observation_epoch
    WHERE observation_plan_uuid='b3100000-0000-0000-0000-000000000001'
      AND epoch_code='B1R1'
  ) THEN
    RAISE EXCEPTION 'B1R1 already exists';
  END IF;
END
$pre$;

INSERT INTO artifact.artifact(
  artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,mime_type,
  source_uri,created_at,created_by,status
) VALUES
(
 'b3000000-0000-0000-0000-000000000013','method',
 'artifacts/topi-n2-dcbti-01/phase-b/measurement-design-b1r1.md',
 'b3dfe5f2c6509cd66941e5c8d422a7a8c49cdfcd','git_blob_sha1','text/markdown',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/measurement-design-b1r1.md',
 TIMESTAMPTZ '2026-10-08 19:48:00-03','OES_CORRECTIVE_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000014','query',
 'artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-query-v2.txt',
 'e02987ce16c10cbb915499621de05fbfaee49930','git_blob_sha1','text/plain',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-query-v2.txt',
 TIMESTAMPTZ '2026-10-08 19:48:01-03','OES_CORRECTIVE_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000015','method',
 'artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-interface-v2.json',
 '621ed0252c028a33b666494f49a70a62e570a15c','git_blob_sha1','application/json',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/37855302262',
 TIMESTAMPTZ '2026-10-08 19:48:02-03','OES_CORRECTIVE_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000016','method',
 'artifacts/topi-n2-dcbti-01/phase-b/pubmed-interface-v2.json',
 '8f61b25c3bca5bb4f4da38867371955aec0e05e4','git_blob_sha1','application/json',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/37855302262',
 TIMESTAMPTZ '2026-10-08 19:48:03-03','OES_CORRECTIVE_PREPARATION','active'
);

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='invalidated'
WHERE observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
  AND epoch_status='authorized_non_normative'
  AND started_at IS NULL;

INSERT INTO maintenance.temporal_observation_epoch(
 observation_epoch_uuid,observation_plan_uuid,epoch_code,epoch_status,
 measurement_design_artifact_uuid,start_boundary_at,review_boundary_at,
 started_at,completed_at,created_at,created_by
) VALUES (
 'b3120000-0000-0000-0000-000000000002',
 'b3100000-0000-0000-0000-000000000001',
 'B1R1','draft',
 'b3000000-0000-0000-0000-000000000013',
 TIMESTAMPTZ '2026-10-19 08:00:00-03',
 TIMESTAMPTZ '2026-11-10 18:00:00-03',
 NULL,NULL,
 TIMESTAMPTZ '2026-10-08 19:48:04-03',
 'OES_CORRECTIVE_PREPARATION'
);

INSERT INTO maintenance.temporal_observation_epoch_source(
 epoch_source_uuid,observation_epoch_uuid,observation_source_uuid,
 query_strategy_artifact_uuid,interface_config_artifact_uuid,baseline_artifact_uuid,
 measurement_investigation_version_uuid,schedule_definition_artifact_uuid,
 runtime_interface_code,measurement_schedule_payload,runtime_connectivity_status,created_at
) VALUES
(
 'b3130000-0000-0000-0000-000000000003',
 'b3120000-0000-0000-0000-000000000002',
 'b3110000-0000-0000-0000-000000000001',
 'b3000000-0000-0000-0000-000000000006',
 'b3000000-0000-0000-0000-000000000016',
 NULL,
 '81000000-0000-0000-0000-000000000002',
 'b3000000-0000-0000-0000-000000000008',
 'ncbi_eutils',
 '{
   "schema":"oes.temporal_opportunity_set/0.1",
   "non_normative":true,
   "schedule_kind":"finite_opportunity_set",
   "rationale":"Finite stepped PubMed measurement design for repeated-source execution, identifier comparison, temporal endpoint observability and pilot effort.",
   "timezone_name":"America/Recife",
   "opportunities":[
     {"opportunity_no":1,"planned_for":"2026-10-19T09:00:00-03:00"},
     {"opportunity_no":2,"planned_for":"2026-10-20T09:00:00-03:00"},
     {"opportunity_no":3,"planned_for":"2026-10-22T09:00:00-03:00"},
     {"opportunity_no":4,"planned_for":"2026-10-26T09:00:00-03:00"},
     {"opportunity_no":5,"planned_for":"2026-10-29T09:00:00-03:00"},
     {"opportunity_no":6,"planned_for":"2026-11-03T09:00:00-03:00"},
     {"opportunity_no":7,"planned_for":"2026-11-06T09:00:00-03:00"},
     {"opportunity_no":8,"planned_for":"2026-11-09T09:00:00-03:00"}
   ]
 }'::jsonb,
 'verified',
 TIMESTAMPTZ '2026-10-08 19:48:05-03'
),
(
 'b3130000-0000-0000-0000-000000000004',
 'b3120000-0000-0000-0000-000000000002',
 'b3110000-0000-0000-0000-000000000002',
 'b3000000-0000-0000-0000-000000000014',
 'b3000000-0000-0000-0000-000000000015',
 NULL,
 '81000000-0000-0000-0000-000000000002',
 'b3000000-0000-0000-0000-000000000011',
 'clinicaltrials_api_v2',
 '{
   "schema":"oes.temporal_opportunity_set/0.1",
   "non_normative":true,
   "schedule_kind":"finite_opportunity_set",
   "rationale":"Finite stepped ClinicalTrials.gov measurement design for registry identifier/update comparison, temporal endpoint observability and pilot effort.",
   "timezone_name":"America/Recife",
   "opportunities":[
     {"opportunity_no":1,"planned_for":"2026-10-19T10:30:00-03:00"},
     {"opportunity_no":2,"planned_for":"2026-10-22T10:30:00-03:00"},
     {"opportunity_no":3,"planned_for":"2026-10-27T10:30:00-03:00"},
     {"opportunity_no":4,"planned_for":"2026-10-30T10:30:00-03:00"},
     {"opportunity_no":5,"planned_for":"2026-11-04T10:30:00-03:00"},
     {"opportunity_no":6,"planned_for":"2026-11-09T10:30:00-03:00"}
   ]
 }'::jsonb,
 'verified',
 TIMESTAMPTZ '2026-10-08 19:48:06-03'
);

INSERT INTO maintenance.temporal_measurement_opportunity(
 measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,
 opportunity_origin,schedule_snapshot_artifact_uuid,created_at
) VALUES
('b3140000-0000-0000-0000-000000000015','b3130000-0000-0000-0000-000000000003',1,TIMESTAMPTZ '2026-10-19 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:07-03'),
('b3140000-0000-0000-0000-000000000016','b3130000-0000-0000-0000-000000000003',2,TIMESTAMPTZ '2026-10-20 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:08-03'),
('b3140000-0000-0000-0000-000000000017','b3130000-0000-0000-0000-000000000003',3,TIMESTAMPTZ '2026-10-22 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:09-03'),
('b3140000-0000-0000-0000-000000000018','b3130000-0000-0000-0000-000000000003',4,TIMESTAMPTZ '2026-10-26 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:10-03'),
('b3140000-0000-0000-0000-000000000019','b3130000-0000-0000-0000-000000000003',5,TIMESTAMPTZ '2026-10-29 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:11-03'),
('b3140000-0000-0000-0000-000000000020','b3130000-0000-0000-0000-000000000003',6,TIMESTAMPTZ '2026-11-03 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:12-03'),
('b3140000-0000-0000-0000-000000000021','b3130000-0000-0000-0000-000000000003',7,TIMESTAMPTZ '2026-11-06 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:13-03'),
('b3140000-0000-0000-0000-000000000022','b3130000-0000-0000-0000-000000000003',8,TIMESTAMPTZ '2026-11-09 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 19:48:14-03'),
('b3140000-0000-0000-0000-000000000023','b3130000-0000-0000-0000-000000000004',1,TIMESTAMPTZ '2026-10-19 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 19:48:15-03'),
('b3140000-0000-0000-0000-000000000024','b3130000-0000-0000-0000-000000000004',2,TIMESTAMPTZ '2026-10-22 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 19:48:16-03'),
('b3140000-0000-0000-0000-000000000025','b3130000-0000-0000-0000-000000000004',3,TIMESTAMPTZ '2026-10-27 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 19:48:17-03'),
('b3140000-0000-0000-0000-000000000026','b3130000-0000-0000-0000-000000000004',4,TIMESTAMPTZ '2026-10-30 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 19:48:18-03'),
('b3140000-0000-0000-0000-000000000027','b3130000-0000-0000-0000-000000000004',5,TIMESTAMPTZ '2026-11-04 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 19:48:19-03'),
('b3140000-0000-0000-0000-000000000028','b3130000-0000-0000-0000-000000000004',6,TIMESTAMPTZ '2026-11-09 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 19:48:20-03');

COMMIT;
