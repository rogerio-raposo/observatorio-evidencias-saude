-- Synthetic-only behavioral fixture; dummy "human_reviewer" record is NOT human approval.
-- Executed exclusively in disposable PG18 GitHub Actions databases after 001-036.
\set ON_ERROR_STOP on
\ir ../f4-grandfathering-032/seed.sql
BEGIN;
INSERT INTO artifact.artifact(artifact_uuid,artifact_type,storage_key,content_hash,created_by)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-000000000172','synthetic_ci','oes-ci-temporal-172','synthetic-sha256-not-real','synthetic_ci');

INSERT INTO maintenance.temporal_observation_plan(
 observation_plan_uuid,plan_code,plan_version,target_product_version_uuid,
 calibration_object,readiness_scope,specification_artifact_uuid,prepared_at,created_by,actor_type)
VALUES (
 'bbbbbbbb-bbbb-4bbb-8bbb-000000000172','SYNTHETIC-CI-PLAN-172',1,
 '22222222-2222-4222-8222-000000000171','cadence','source_specific',
 'aaaaaaaa-aaaa-4aaa-8aaa-000000000172','2026-01-01T00:00:00Z','ci_only','ai_system'
);

INSERT INTO maintenance.temporal_observation_source(
 observation_source_uuid,observation_plan_uuid,source_code,source_name,source_class,
 inclusion_status,access_mode,runtime_connectivity_required,time_semantics_payload,
 inclusion_rationale,created_by
) VALUES (
 'cccccccc-cccc-4ccc-8ccc-000000000172',
 'bbbbbbbb-bbbb-4bbb-8bbb-000000000172',
 'CI-SOURCE','SYNTHETIC CI SOURCE','synthetic','included','manual',false,
 '{"schema_version":"0.1","semantic_codes":["synthetic_id"],"identifier_semantic":"synthetic_id","source_class":"synthetic"}',
 'Only a disposable database test','ci_only'
);

INSERT INTO maintenance.temporal_observation_epoch(
 observation_epoch_uuid,observation_plan_uuid,epoch_code,epoch_status,
 measurement_design_artifact_uuid,start_boundary_at,review_boundary_at,created_at,created_by
) VALUES (
 'dddddddd-dddd-4ddd-8ddd-000000000172',
 'bbbbbbbb-bbbb-4bbb-8bbb-000000000172',
 'CI-EPOCH','draft','aaaaaaaa-aaaa-4aaa-8aaa-000000000172',
 '2030-01-01T00:00:00Z','2030-01-05T00:00:00Z',
 '2026-01-01T00:00:00Z','ci_only'
);

INSERT INTO maintenance.temporal_observation_epoch_source(
 epoch_source_uuid,observation_epoch_uuid,observation_source_uuid,
 schedule_definition_artifact_uuid,runtime_interface_code,
 measurement_schedule_payload,runtime_connectivity_status,created_at
) VALUES (
 'eeeeeeee-eeee-4eee-8eee-000000000172',
 'dddddddd-dddd-4ddd-8ddd-000000000172',
 'cccccccc-cccc-4ccc-8ccc-000000000172',
 'aaaaaaaa-aaaa-4aaa-8aaa-000000000172',
 'SYNTHETIC-LOCAL-NO-REAL-CONNECTION',
 '{"schema":"oes.temporal_opportunity_set/0.1","non_normative":true,
   "schedule_kind":"finite_opportunity_set","rationale":"synthetic_only",
   "opportunities":[
      {"opportunity_no":1,"planned_for":"2030-01-02T00:00:00Z"},
      {"opportunity_no":2,"planned_for":"2030-01-03T00:00:00Z"}]}',
 'unverified','2026-01-01T00:00:00Z'
);

INSERT INTO maintenance.temporal_measurement_opportunity(
 measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,
 opportunity_origin,created_at)
VALUES
 ('11111111-0000-4111-8111-000000000172',
  'eeeeeeee-eeee-4eee-8eee-000000000172',1,'2030-01-02T00:00:00Z',
  'frozen_opportunity_set','2026-01-01T00:00:00Z'),
 ('22222222-0000-4222-8222-000000000172',
  'eeeeeeee-eeee-4eee-8eee-000000000172',2,'2030-01-03T00:00:00Z',
  'frozen_opportunity_set','2026-01-01T00:00:00Z');

-- Artificial authority record to exercise logic; no person made an approval.
INSERT INTO maintenance.temporal_observation_authority(
 observation_authority_uuid,observation_plan_uuid,observation_epoch_uuid,
 authority_domain,decision,actor,actor_type,decision_artifact_uuid,decided_at
) VALUES (
 'ffffffff-ffff-4fff-8fff-000000000172',
 'bbbbbbbb-bbbb-4bbb-8bbb-000000000172',
 'dddddddd-dddd-4ddd-8ddd-000000000172',
 'operational_execution','approved','SYNTHETIC-FAKE-AUTHORITY-NOT-A-HUMAN',
 'human_reviewer','aaaaaaaa-aaaa-4aaa-8aaa-000000000172',
 '2026-06-01T00:00:00Z'
);
COMMIT;
