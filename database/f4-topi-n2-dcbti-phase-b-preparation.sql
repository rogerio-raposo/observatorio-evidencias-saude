-- OES Fase 4 — TOPI-N2-DCBTI-01 Phase B preparation
-- Real draft materialization authorized by Document 71 and owner decision recorded in Document 72.
-- Connectivity evidence: Document 73 / GitHub Actions run 37806308031.
-- IMPORTANT: this file materializes preparation state only.
-- It does NOT create execution authority, MeasurementEvent, Search, UpdateSignal, cadence or normative temporal values.

\set ON_ERROR_STOP on

BEGIN;

DO $$
BEGIN
  IF NOT EXISTS(
    SELECT 1
    FROM product.product_version pv
    JOIN core.entity_version ev ON ev.version_uuid=pv.version_uuid
    WHERE pv.version_uuid='81000000-0000-0000-0000-000000000701'
      AND pv.status='published'
      AND ev.version_status='current'
  ) THEN
    RAISE EXCEPTION 'TOPI preparation target ProductVersion is not current/published';
  END IF;

  IF NOT EXISTS(
    SELECT 1
    FROM investigation.investigation_version iv
    JOIN core.entity_version ev ON ev.version_uuid=iv.version_uuid
    WHERE iv.version_uuid='81000000-0000-0000-0000-000000000002'
      AND iv.status='active'
      AND ev.version_status='current'
      AND iv.depth_level='N2'
      AND iv.maintenance_level='M1'
  ) THEN
    RAISE EXCEPTION 'TOPI preparation target InvestigationVersion is not current/active N2/M1';
  END IF;

  IF NOT EXISTS(
    SELECT 1 FROM product.investigation_link
    WHERE product_version_uuid='81000000-0000-0000-0000-000000000701'
      AND investigation_version_uuid='81000000-0000-0000-0000-000000000002'
      AND role='primary'
  ) THEN
    RAISE EXCEPTION 'TOPI preparation target ProductVersion/InvestigationVersion linkage missing';
  END IF;

  IF EXISTS(
    SELECT 1 FROM maintenance.temporal_observation_plan
    WHERE plan_code='TOPI-N2-DCBTI-01' AND plan_version=2
  ) THEN
    RAISE EXCEPTION 'TOPI-N2-DCBTI-01 physical plan v2 already exists';
  END IF;
END $$;

INSERT INTO artifact.artifact(
  artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,mime_type,
  source_uri,created_at,created_by,status
) VALUES
(
 'b3000000-0000-0000-0000-000000000001','method',
 'artifacts/topi-n2-dcbti-01/phase-b/plan-v02-final.md',
 'e6357c570e768d6c72993a09c4add5d547d54ef2','git_blob_sha1','text/markdown',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/plan-v02-final.md',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000002','method',
 'artifacts/topi-n2-dcbti-01/phase-b/measurement-design-b1.md',
 '818d7d08e8e1beca8441bd8c91c9e973a0d1fc2d','git_blob_sha1','text/markdown',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/measurement-design-b1.md',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000003','method',
 'artifacts/topi-n2-dcbti-01/phase-b/source-pubmed.md',
 'fbc18375da964a7bdbd3a63fb5fb9ee1932686ce','git_blob_sha1','text/markdown',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/source-pubmed.md',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000004','method',
 'artifacts/topi-n2-dcbti-01/phase-b/source-clinicaltrials-gov.md',
 'b528ef4aedc37ab5cddd2adbefbaebe5a7ac4588','git_blob_sha1','text/markdown',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/source-clinicaltrials-gov.md',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000005','method',
 'artifacts/topi-n2-dcbti-01/phase-b/source-bvs-lilacs.md',
 'a39a8f1b2bc0447cee25ba6d495989445c12de13','git_blob_sha1','text/markdown',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/source-bvs-lilacs.md',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000006','query',
 'artifacts/topi-n2-dcbti-01/phase-b/pubmed-query-v1.txt',
 '6f783b731884e95ae92d8239366d9e404dc44310','git_blob_sha1','text/plain',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/pubmed-query-v1.txt',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000007','method',
 'artifacts/topi-n2-dcbti-01/phase-b/pubmed-interface-v1.json',
 'ac43d3fd9bdaac0a0713e103ff156930c60e7dea','git_blob_sha1','application/json',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/37806308031',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000008','method',
 'artifacts/topi-n2-dcbti-01/phase-b/pubmed-schedule-b1.json',
 '1ad47a57c615dd472ade612f5404ef564ea8d780','git_blob_sha1','application/json',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/pubmed-schedule-b1.json',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000009','query',
 'artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-query-v1.txt',
 'e73f0f602cc1f65c874a53841bb9c4b9d2a6d49b','git_blob_sha1','text/plain',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-query-v1.txt',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000010','method',
 'artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-interface-v1.json',
 'c4e1c0b238c52534d9f33d278aca18df8d854f6b','git_blob_sha1','application/json',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/37806308031',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
),
(
 'b3000000-0000-0000-0000-000000000011','method',
 'artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-schedule-b1.json',
 'bbfd4f44c3b1565f9448dbd1f0af415aeb438d0e','git_blob_sha1','application/json',
 'https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/main/artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-schedule-b1.json',
 TIMESTAMPTZ '2026-10-08 13:12:00-03','OES_PHASE_B_PREPARATION','active'
);

INSERT INTO maintenance.temporal_observation_plan(
  observation_plan_uuid,plan_code,plan_version,supersedes_observation_plan_uuid,
  target_product_version_uuid,target_investigation_version_uuid,
  calibration_object,readiness_scope,specification_artifact_uuid,
  prepared_at,created_by,actor_type,record_status,created_at
) VALUES (
  'b3100000-0000-0000-0000-000000000001',
  'TOPI-N2-DCBTI-01',2,NULL,
  '81000000-0000-0000-0000-000000000701',NULL,
  'cadence','policy_aggregate','b3000000-0000-0000-0000-000000000001',
  TIMESTAMPTZ '2026-10-08 13:11:53-03',
  'OES_AI_ASSISTED_PREPARATION','ai_system','active',
  TIMESTAMPTZ '2026-10-08 13:12:01-03'
);

INSERT INTO maintenance.temporal_observation_source(
 observation_source_uuid,observation_plan_uuid,source_code,source_name,source_class,
 inclusion_status,interface_code,access_mode,runtime_connectivity_required,
 time_semantics_payload,source_definition_artifact_uuid,inclusion_rationale,
 debt_reason_code,reassessment_trigger,created_at,created_by
) VALUES
(
 'b3110000-0000-0000-0000-000000000001',
 'b3100000-0000-0000-0000-000000000001',
 'PUBMED_MEDLINE','PubMed/MEDLINE','bibliographic',
 'included','ncbi_eutils','programmatic',true,
 '{
   "schema_version":"0.1",
   "semantic_codes":["pubmed_crdt","pubmed_edat","pubmed_epdat","pubmed_publication_date","pubmed_last_revision_date"],
   "identifier_semantic":"PMID",
   "source_class":"bibliographic",
   "notes":"Date precision must be preserved; no fabricated source hour."
 }'::jsonb,
 'b3000000-0000-0000-0000-000000000003',
 'Included after Phase A characterization and run 215 runtime connectivity verification.',
 NULL,NULL,
 TIMESTAMPTZ '2026-10-08 13:12:02-03','OES_PHASE_B_PREPARATION'
),
(
 'b3110000-0000-0000-0000-000000000002',
 'b3100000-0000-0000-0000-000000000001',
 'CLINICALTRIALS_GOV','ClinicalTrials.gov','registry',
 'included','clinicaltrials_api_v2','programmatic',true,
 '{
   "schema_version":"0.1",
   "semantic_codes":["study_first_post_date","results_first_post_date","last_update_post_date"],
   "identifier_semantic":"NCT_ID",
   "source_class":"registry",
   "notes":"Registry posting dates are not article publication dates."
 }'::jsonb,
 'b3000000-0000-0000-0000-000000000004',
 'Included after Phase A characterization and run 215 runtime connectivity verification.',
 NULL,NULL,
 TIMESTAMPTZ '2026-10-08 13:12:03-03','OES_PHASE_B_PREPARATION'
),
(
 'b3110000-0000-0000-0000-000000000003',
 'b3100000-0000-0000-0000-000000000001',
 'BVS_LILACS','BVS/LILACS','bibliographic',
 'deferred','bvs_unresolved','unresolved',false,
 '{
   "schema_version":"0.1",
   "semantic_codes":["record_creation_date","last_change_date"],
   "identifier_semantic":"BVS_LILACS_RECORD_ID",
   "source_class":"bibliographic",
   "notes":"Operational public programmatic path not established for B1."
 }'::jsonb,
 'b3000000-0000-0000-0000-000000000005',
 'Scientifically relevant source retained in candidate universe but deferred from B1.',
 'access_path_not_reproducible',
 'Reassess when a stable reproducible programmatic access path exists or a versioned manual design is explicitly approved.',
 TIMESTAMPTZ '2026-10-08 13:12:04-03','OES_PHASE_B_PREPARATION'
);

INSERT INTO maintenance.temporal_observation_epoch(
 observation_epoch_uuid,observation_plan_uuid,epoch_code,epoch_status,
 measurement_design_artifact_uuid,start_boundary_at,review_boundary_at,
 started_at,completed_at,created_at,created_by
) VALUES (
 'b3120000-0000-0000-0000-000000000001',
 'b3100000-0000-0000-0000-000000000001',
 'B1','draft',
 'b3000000-0000-0000-0000-000000000002',
 TIMESTAMPTZ '2026-10-19 08:00:00-03',
 TIMESTAMPTZ '2026-11-10 18:00:00-03',
 NULL,NULL,
 TIMESTAMPTZ '2026-10-08 13:12:05-03',
 'OES_PHASE_B_PREPARATION'
);

INSERT INTO maintenance.temporal_observation_epoch_source(
 epoch_source_uuid,observation_epoch_uuid,observation_source_uuid,
 query_strategy_artifact_uuid,interface_config_artifact_uuid,baseline_artifact_uuid,
 measurement_investigation_version_uuid,schedule_definition_artifact_uuid,
 runtime_interface_code,measurement_schedule_payload,runtime_connectivity_status,created_at
) VALUES
(
 'b3130000-0000-0000-0000-000000000001',
 'b3120000-0000-0000-0000-000000000001',
 'b3110000-0000-0000-0000-000000000001',
 'b3000000-0000-0000-0000-000000000006',
 'b3000000-0000-0000-0000-000000000007',
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
 TIMESTAMPTZ '2026-10-08 13:12:06-03'
),
(
 'b3130000-0000-0000-0000-000000000002',
 'b3120000-0000-0000-0000-000000000001',
 'b3110000-0000-0000-0000-000000000002',
 'b3000000-0000-0000-0000-000000000009',
 'b3000000-0000-0000-0000-000000000010',
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
 TIMESTAMPTZ '2026-10-08 13:12:07-03'
);

INSERT INTO maintenance.temporal_measurement_opportunity(
 measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,
 opportunity_origin,schedule_snapshot_artifact_uuid,created_at
) VALUES
('b3140000-0000-0000-0000-000000000001','b3130000-0000-0000-0000-000000000001',1,TIMESTAMPTZ '2026-10-19 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:10-03'),
('b3140000-0000-0000-0000-000000000002','b3130000-0000-0000-0000-000000000001',2,TIMESTAMPTZ '2026-10-20 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:11-03'),
('b3140000-0000-0000-0000-000000000003','b3130000-0000-0000-0000-000000000001',3,TIMESTAMPTZ '2026-10-22 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:12-03'),
('b3140000-0000-0000-0000-000000000004','b3130000-0000-0000-0000-000000000001',4,TIMESTAMPTZ '2026-10-26 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:13-03'),
('b3140000-0000-0000-0000-000000000005','b3130000-0000-0000-0000-000000000001',5,TIMESTAMPTZ '2026-10-29 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:14-03'),
('b3140000-0000-0000-0000-000000000006','b3130000-0000-0000-0000-000000000001',6,TIMESTAMPTZ '2026-11-03 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:15-03'),
('b3140000-0000-0000-0000-000000000007','b3130000-0000-0000-0000-000000000001',7,TIMESTAMPTZ '2026-11-06 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:16-03'),
('b3140000-0000-0000-0000-000000000008','b3130000-0000-0000-0000-000000000001',8,TIMESTAMPTZ '2026-11-09 09:00:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000008',TIMESTAMPTZ '2026-10-08 13:12:17-03'),
('b3140000-0000-0000-0000-000000000009','b3130000-0000-0000-0000-000000000002',1,TIMESTAMPTZ '2026-10-19 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 13:12:18-03'),
('b3140000-0000-0000-0000-000000000010','b3130000-0000-0000-0000-000000000002',2,TIMESTAMPTZ '2026-10-22 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 13:12:19-03'),
('b3140000-0000-0000-0000-000000000011','b3130000-0000-0000-0000-000000000002',3,TIMESTAMPTZ '2026-10-27 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 13:12:20-03'),
('b3140000-0000-0000-0000-000000000012','b3130000-0000-0000-0000-000000000002',4,TIMESTAMPTZ '2026-10-30 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 13:12:21-03'),
('b3140000-0000-0000-0000-000000000013','b3130000-0000-0000-0000-000000000002',5,TIMESTAMPTZ '2026-11-04 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 13:12:22-03'),
('b3140000-0000-0000-0000-000000000014','b3130000-0000-0000-0000-000000000002',6,TIMESTAMPTZ '2026-11-09 10:30:00-03','frozen_opportunity_set','b3000000-0000-0000-0000-000000000011',TIMESTAMPTZ '2026-10-08 13:12:23-03');

COMMIT;
