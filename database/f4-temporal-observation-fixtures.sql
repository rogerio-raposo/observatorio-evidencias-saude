-- F4 non-normative temporal observation synthetic fixtures
-- Requires migrations through 033 and existing F3 monitor fixtures.
-- SYNTHETIC_TEST_ONLY. No real TOPI/source observation/authority.
-- Date: 2026-10-08

BEGIN;

INSERT INTO artifact.artifact(
  artifact_uuid,artifact_type,storage_key,content_hash,mime_type,created_by,status
) VALUES
('f7000000-0000-0000-0000-000000000001','method','fixtures/tno/plan-v1.md','sha256-tno-plan','text/markdown','f4-tno','active'),
('f7000000-0000-0000-0000-000000000002','method','fixtures/tno/source-pubmed.md','sha256-tno-source-pubmed','text/markdown','f4-tno','active'),
('f7000000-0000-0000-0000-000000000003','method','fixtures/tno/source-bvs.md','sha256-tno-source-bvs','text/markdown','f4-tno','active'),
('f7000000-0000-0000-0000-000000000004','method','fixtures/tno/epoch-b1.md','sha256-tno-epoch','text/markdown','f4-tno','active'),
('f7000000-0000-0000-0000-000000000005','method','fixtures/tno/schedule-pubmed.md','sha256-tno-schedule','text/markdown','f4-tno','active'),
('f7000000-0000-0000-0000-000000000006','query','fixtures/tno/query-pubmed.txt','sha256-tno-query','text/plain','f4-tno','active'),
('f7000000-0000-0000-0000-000000000007','baseline','fixtures/tno/baseline.json','sha256-tno-baseline','application/json','f4-tno','active'),
('f7000000-0000-0000-0000-000000000008','decision','fixtures/tno/authority.md','sha256-tno-authority','text/markdown','f4-tno','active'),
('f7000000-0000-0000-0000-000000000009','source_record','fixtures/tno/item.json','sha256-tno-item','application/json','f4-tno','active');

INSERT INTO maintenance.temporal_observation_plan(
  observation_plan_uuid,plan_code,plan_version,target_product_version_uuid,
  calibration_object,readiness_scope,specification_artifact_uuid,
  prepared_at,created_by,actor_type,record_status,created_at
) VALUES (
  'f7100000-0000-0000-0000-000000000001','TNO-SYNTH-01',1,
  'e5100000-0000-0000-0000-000000000003',
  'cadence','policy_aggregate','f7000000-0000-0000-0000-000000000001',
  TIMESTAMPTZ '2026-10-08 09:00:00+00','f4-tno','ai_system','active',
  TIMESTAMPTZ '2026-10-08 09:00:00+00'
);

INSERT INTO maintenance.temporal_observation_source(
  observation_source_uuid,observation_plan_uuid,source_code,source_name,source_class,
  inclusion_status,interface_code,access_mode,runtime_connectivity_required,
  time_semantics_payload,source_definition_artifact_uuid,inclusion_rationale,
  debt_reason_code,reassessment_trigger,created_at,created_by
) VALUES
(
 'f7110000-0000-0000-0000-000000000001','f7100000-0000-0000-0000-000000000001',
 'PUBMED_SYNTH','PubMed synthetic','bibliographic','included','eutils','programmatic',false,
 '{"schema_version":"0.1","semantic_codes":["create_date","entry_date"],"identifier_semantic":"PMID","source_class":"bibliographic","notes":"synthetic"}'::jsonb,
 'f7000000-0000-0000-0000-000000000002','Synthetic included source',NULL,NULL,
 TIMESTAMPTZ '2026-10-08 09:05:00+00','f4-tno'
),
(
 'f7110000-0000-0000-0000-000000000002','f7100000-0000-0000-0000-000000000001',
 'BVS_SYNTH','BVS synthetic','bibliographic','deferred','iahx','unresolved',false,
 '{"schema_version":"0.1","semantic_codes":["record_creation_date"],"identifier_semantic":"BVS_ID","source_class":"bibliographic","notes":"synthetic"}'::jsonb,
 'f7000000-0000-0000-0000-000000000003','Synthetic deferred source',
 'access_path_not_reproducible','reassess after access characterization',
 TIMESTAMPTZ '2026-10-08 09:06:00+00','f4-tno'
);

INSERT INTO maintenance.temporal_observation_epoch(
  observation_epoch_uuid,observation_plan_uuid,epoch_code,epoch_status,
  measurement_design_artifact_uuid,start_boundary_at,review_boundary_at,
  created_at,created_by
) VALUES (
 'f7120000-0000-0000-0000-000000000001','f7100000-0000-0000-0000-000000000001',
 'B1-SYNTH','draft','f7000000-0000-0000-0000-000000000004',
 TIMESTAMPTZ '2026-10-08 11:00:00+00',TIMESTAMPTZ '2026-10-09 12:00:00+00',
 TIMESTAMPTZ '2026-10-08 09:10:00+00','f4-tno'
);

INSERT INTO maintenance.temporal_observation_epoch_source(
  epoch_source_uuid,observation_epoch_uuid,observation_source_uuid,
  query_strategy_artifact_uuid,baseline_artifact_uuid,
  measurement_investigation_version_uuid,schedule_definition_artifact_uuid,
  runtime_interface_code,measurement_schedule_payload,runtime_connectivity_status,created_at
) VALUES (
 'f7130000-0000-0000-0000-000000000001','f7120000-0000-0000-0000-000000000001',
 'f7110000-0000-0000-0000-000000000001',
 'f7000000-0000-0000-0000-000000000006','f7000000-0000-0000-0000-000000000007',
 'e5100000-0000-0000-0000-000000000002','f7000000-0000-0000-0000-000000000005',
 'eutils',
 '{
   "schema":"oes.temporal_opportunity_set/0.1",
   "non_normative":true,
   "schedule_kind":"finite_opportunity_set",
   "rationale":"Synthetic finite set for contract tests only",
   "opportunities":[
     {"opportunity_no":1,"planned_for":"2026-10-08T12:00:00+00:00"},
     {"opportunity_no":2,"planned_for":"2026-10-09T12:00:00+00:00"}
   ]
 }'::jsonb,
 'verified',TIMESTAMPTZ '2026-10-08 09:15:00+00'
);

INSERT INTO maintenance.temporal_measurement_opportunity(
  measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,
  opportunity_origin,schedule_snapshot_artifact_uuid,created_at
) VALUES
('f7140000-0000-0000-0000-000000000001','f7130000-0000-0000-0000-000000000001',1,
 TIMESTAMPTZ '2026-10-08 12:00:00+00','frozen_opportunity_set',
 'f7000000-0000-0000-0000-000000000005',TIMESTAMPTZ '2026-10-08 09:20:00+00'),
('f7140000-0000-0000-0000-000000000002','f7130000-0000-0000-0000-000000000001',2,
 TIMESTAMPTZ '2026-10-09 12:00:00+00','frozen_opportunity_set',
 'f7000000-0000-0000-0000-000000000005',TIMESTAMPTZ '2026-10-08 09:21:00+00');

INSERT INTO maintenance.temporal_observation_authority(
  observation_authority_uuid,observation_plan_uuid,observation_epoch_uuid,
  authority_domain,decision,actor,actor_type,decision_artifact_uuid,decided_at,
  limitations_payload,created_at
) VALUES (
 'f7150000-0000-0000-0000-000000000001','f7100000-0000-0000-0000-000000000001',
 'f7120000-0000-0000-0000-000000000001','operational_execution','approved',
 'synthetic-owner','owner','f7000000-0000-0000-0000-000000000008',
 TIMESTAMPTZ '2026-10-08 09:30:00+00',
 '{"fixture":true,"scope":"synthetic tests only"}'::jsonb,
 TIMESTAMPTZ '2026-10-08 09:30:00+00'
);

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='authorized_non_normative'
WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001';

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='active',started_at=TIMESTAMPTZ '2026-10-08 11:00:00+00'
WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001';

INSERT INTO maintenance.temporal_measurement_event(
  measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
  execution_started_at,execution_completed_at,novelty_state,
  raw_result_count,raw_result_count_status,materialized_identifier_count,new_identifier_count,
  failure_attribution,scientific_search_uuid,effort_payload,operator,actor_type,created_at
) VALUES (
 'f7160000-0000-0000-0000-000000000001','f7140000-0000-0000-0000-000000000001',
 1,'completed',TIMESTAMPTZ '2026-10-08 12:01:00+00',TIMESTAMPTZ '2026-10-08 12:02:00+00',
 'new_items',1,'known',1,1,'not_applicable',NULL,
 '{"operator_minutes":2,"machine_elapsed_seconds":60,"retry_count":0,"handoff_count":0,"note":"synthetic"}'::jsonb,
 'fixture-runtime','system',TIMESTAMPTZ '2026-10-08 12:02:00+00'
);

INSERT INTO maintenance.temporal_measurement_item(
  measurement_item_uuid,measurement_event_uuid,source_identifier,source_locator,
  item_state,oes_detected_at,source_record_artifact_uuid,created_at
) VALUES (
 'f7170000-0000-0000-0000-000000000001','f7160000-0000-0000-0000-000000000001',
 'PMID-SYNTH-1','https://example.invalid/pmid-synth-1','new_to_epoch',
 TIMESTAMPTZ '2026-10-08 12:01:30+00','f7000000-0000-0000-0000-000000000009',
 TIMESTAMPTZ '2026-10-08 12:01:30+00'
);

INSERT INTO maintenance.temporal_measurement_item_timepoint(
  measurement_item_timepoint_uuid,measurement_item_uuid,semantic_code,source_field,
  raw_value,precision,timezone_name,lower_bound_at,upper_bound_at,observability_status,created_at
) VALUES (
 'f7180000-0000-0000-0000-000000000001','f7170000-0000-0000-0000-000000000001',
 'create_date','CRDT','2026-10-08','day','UTC',
 TIMESTAMPTZ '2026-10-08 00:00:00+00',TIMESTAMPTZ '2026-10-08 23:59:59+00',
 'bounded',TIMESTAMPTZ '2026-10-08 12:01:40+00'
);

INSERT INTO maintenance.temporal_measurement_opportunity_resolution(
  opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,
  terminal_measurement_event_uuid,reason_code,resolved_at,resolved_by,actor_type,created_at
) VALUES (
 'f7190000-0000-0000-0000-000000000001','f7140000-0000-0000-0000-000000000001',
 'completed','f7160000-0000-0000-0000-000000000001','synthetic_completed',
 TIMESTAMPTZ '2026-10-08 12:03:00+00','fixture-runtime','system',
 TIMESTAMPTZ '2026-10-08 12:03:00+00'
);

COMMIT;
