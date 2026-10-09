-- F4 ISE: isolated integrated synthetic dual-source exercise, Doc 99 / CP143.
-- SYNTHETIC_TEST_ONLY. Never run against live source endpoints or as a factual B1R1 operation.
-- Requires F3 synthetic target, migrations 033-036, existing test fixtures, and B1R1 authority fixtures.
\set ON_ERROR_STOP on
BEGIN;
CREATE TEMP TABLE ise_passed (test_name text PRIMARY KEY) ON COMMIT DROP;
CREATE OR REPLACE FUNCTION pg_temp.ise_assert(p_name text,p_ok boolean)
RETURNS void LANGUAGE plpgsql AS $ise$
BEGIN
  IF NOT COALESCE(p_ok,false) THEN RAISE EXCEPTION '% FAIL',p_name; END IF;
  INSERT INTO ise_passed VALUES(p_name);
  RAISE NOTICE '% PASS',p_name;
END $ise$;
CREATE OR REPLACE FUNCTION pg_temp.ise_expect_reject(p_sql text,p_error_fragment text)
RETURNS boolean LANGUAGE plpgsql AS $ise$
BEGIN
  BEGIN
    EXECUTE p_sql;
  EXCEPTION WHEN OTHERS THEN
    IF position(p_error_fragment IN SQLERRM)>0 THEN RETURN true; END IF;
    RAISE EXCEPTION 'Unexpected exception: % (expected fragment: %)',SQLERRM,p_error_fragment;
  END;
  RETURN false;
END $ise$;
CREATE TEMP TABLE ise_before AS
SELECT
  (SELECT count(*) FROM maintenance.update_signal) AS signals,
  (SELECT count(*) FROM maintenance.cadence_observation) AS cadence_observations,
  (SELECT count(*) FROM maintenance.monitor_cycle) AS monitor_cycles,
  (SELECT count(*) FROM maintenance.temporal_measurement_event) AS global_events,
  (SELECT count(*) FROM maintenance.temporal_measurement_opportunity_resolution) AS global_resolutions,
  (SELECT md5(string_agg(e.observation_epoch_uuid::text||':'||e.epoch_status||':'||COALESCE(e.started_at::text,'NULL')||':'||COALESCE(e.completed_at::text,'NULL'), '|' ORDER BY e.observation_epoch_uuid))
   FROM maintenance.temporal_observation_epoch e
   WHERE e.observation_epoch_uuid IN ('b3120000-0000-0000-0000-000000000001','b3120000-0000-0000-0000-000000000002')) AS b1_epoch_fingerprint;


INSERT INTO artifact.artifact(artifact_uuid,artifact_type,storage_key,content_hash,mime_type,created_by,status)
VALUES
('f7400000-0000-0000-0000-000000000001','method','fixtures/f4-ise/synthetic-1.json','ise-synthetic-hash-1','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000002','method','fixtures/f4-ise/synthetic-2.json','ise-synthetic-hash-2','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000003','method','fixtures/f4-ise/synthetic-3.json','ise-synthetic-hash-3','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000004','method','fixtures/f4-ise/synthetic-4.json','ise-synthetic-hash-4','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000005','method','fixtures/f4-ise/synthetic-5.json','ise-synthetic-hash-5','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000006','query','fixtures/f4-ise/synthetic-6.json','ise-synthetic-hash-6','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000007','query','fixtures/f4-ise/synthetic-7.json','ise-synthetic-hash-7','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000008','decision','fixtures/f4-ise/synthetic-8.json','ise-synthetic-hash-8','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000009','source_record','fixtures/f4-ise/synthetic-9.json','ise-synthetic-hash-9','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000010','source_record','fixtures/f4-ise/synthetic-10.json','ise-synthetic-hash-10','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000011','source_record','fixtures/f4-ise/synthetic-11.json','ise-synthetic-hash-11','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000012','source_record','fixtures/f4-ise/synthetic-12.json','ise-synthetic-hash-12','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000013','source_record','fixtures/f4-ise/synthetic-13.json','ise-synthetic-hash-13','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active'),
('f7400000-0000-0000-0000-000000000014','source_record','fixtures/f4-ise/synthetic-14.json','ise-synthetic-hash-14','application/json','F4-ISE-SYNTHETIC_TEST_ONLY','active');

INSERT INTO maintenance.temporal_observation_plan(
 observation_plan_uuid,plan_code,plan_version,target_product_version_uuid,
 calibration_object,readiness_scope,specification_artifact_uuid,prepared_at,
 created_by,actor_type,record_status,created_at)
VALUES ('f7410000-0000-0000-0000-000000000001','F4-ISE-SYNTHETIC-01',1,'e5100000-0000-0000-0000-000000000003',
'cadence','policy_aggregate','f7400000-0000-0000-0000-000000000001','2026-10-08 08:00+00',
'F4-ISE-SYNTHETIC_TEST_ONLY','ai_system','active','2026-10-08 08:00+00');

INSERT INTO maintenance.temporal_observation_source(
 observation_source_uuid,observation_plan_uuid,source_code,source_name,source_class,inclusion_status,
 interface_code,access_mode,runtime_connectivity_required,time_semantics_payload,
 source_definition_artifact_uuid,inclusion_rationale,created_at,created_by)
VALUES
('f7420000-0000-0000-0000-000000000001','f7410000-0000-0000-0000-000000000001','PUBMED_ISE_SYNTH','PubMed artificial','bibliographic','included','eutils_fixture','programmatic',false,
 '{"schema_version":"0.1","semantic_codes":["create_date"],"identifier_semantic":"PMID","source_class":"bibliographic"}',
 'f7400000-0000-0000-0000-000000000002','SYNTHETIC_TEST_ONLY','2026-10-08 08:01+00','F4-ISE'),
('f7420000-0000-0000-0000-000000000002','f7410000-0000-0000-0000-000000000001','CTG_ISE_SYNTH','ClinicalTrials artificial','registry','included','ctg_fixture','programmatic',false,
 '{"schema_version":"0.1","semantic_codes":["last_update_posted"],"identifier_semantic":"NCT_ID","source_class":"registry"}',
 'f7400000-0000-0000-0000-000000000003','SYNTHETIC_TEST_ONLY','2026-10-08 08:01+00','F4-ISE');

INSERT INTO maintenance.temporal_observation_epoch(
 observation_epoch_uuid,observation_plan_uuid,epoch_code,epoch_status,measurement_design_artifact_uuid,
 start_boundary_at,review_boundary_at,created_at,created_by)
VALUES('f7430000-0000-0000-0000-000000000001','f7410000-0000-0000-0000-000000000001','ISE-B1-SYNTH','draft','f7400000-0000-0000-0000-000000000004',
'2026-10-08 08:30+00','2026-10-08 12:00+00','2026-10-08 08:02+00','F4-ISE');

INSERT INTO maintenance.temporal_observation_epoch_source(
 epoch_source_uuid,observation_epoch_uuid,observation_source_uuid,query_strategy_artifact_uuid,
 interface_config_artifact_uuid,measurement_investigation_version_uuid,schedule_definition_artifact_uuid,
 runtime_interface_code,measurement_schedule_payload,runtime_connectivity_status,created_at)
VALUES
('f7440000-0000-0000-0000-000000000001','f7430000-0000-0000-0000-000000000001','f7420000-0000-0000-0000-000000000001','f7400000-0000-0000-0000-000000000006','f7400000-0000-0000-0000-000000000011',
'e5100000-0000-0000-0000-000000000002','f7400000-0000-0000-0000-000000000005','eutils_fixture',
'{"schema":"oes.temporal_opportunity_set/0.1","non_normative":true,"schedule_kind":"finite_opportunity_set","rationale":"SYNTHETIC_TEST_ONLY: dual-source integrated SQL contract","opportunities":[{"opportunity_no":1,"planned_for":"2026-10-08T09:00:00+00:00"},{"opportunity_no":2,"planned_for":"2026-10-08T10:00:00+00:00"}]}'::jsonb,'verified','2026-10-08 08:03+00'),
('f7440000-0000-0000-0000-000000000002','f7430000-0000-0000-0000-000000000001','f7420000-0000-0000-0000-000000000002','f7400000-0000-0000-0000-000000000007','f7400000-0000-0000-0000-000000000012',
'e5100000-0000-0000-0000-000000000002','f7400000-0000-0000-0000-000000000013','ctg_fixture',
'{"schema":"oes.temporal_opportunity_set/0.1","non_normative":true,"schedule_kind":"finite_opportunity_set","rationale":"SYNTHETIC_TEST_ONLY: dual-source integrated SQL contract","opportunities":[{"opportunity_no":1,"planned_for":"2026-10-08T09:30:00+00:00"},{"opportunity_no":2,"planned_for":"2026-10-08T10:30:00+00:00"}]}'::jsonb,'verified','2026-10-08 08:03+00');

INSERT INTO maintenance.temporal_measurement_opportunity(
 measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,opportunity_origin,schedule_snapshot_artifact_uuid,created_at)
VALUES
('f7450000-0000-0000-0000-000000000001','f7440000-0000-0000-0000-000000000001',1,'2026-10-08 09:00+00','frozen_opportunity_set','f7400000-0000-0000-0000-000000000005','2026-10-08 08:04+00'),
('f7450000-0000-0000-0000-000000000002','f7440000-0000-0000-0000-000000000001',2,'2026-10-08 10:00+00','frozen_opportunity_set','f7400000-0000-0000-0000-000000000005','2026-10-08 08:04+00'),
('f7450000-0000-0000-0000-000000000003','f7440000-0000-0000-0000-000000000002',1,'2026-10-08 09:30+00','frozen_opportunity_set','f7400000-0000-0000-0000-000000000013','2026-10-08 08:04+00'),
('f7450000-0000-0000-0000-000000000004','f7440000-0000-0000-0000-000000000002',2,'2026-10-08 10:30+00','frozen_opportunity_set','f7400000-0000-0000-0000-000000000013','2026-10-08 08:04+00');

SELECT pg_temp.ise_assert('ISE-T01', (SELECT count(*)=2 FROM maintenance.temporal_observation_epoch_source WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001'));

SELECT pg_temp.ise_assert('ISE-T02', maintenance.temporal_epoch_opportunity_set_matches_schedule('f7440000-0000-0000-0000-000000000001') AND maintenance.temporal_epoch_opportunity_set_matches_schedule('f7440000-0000-0000-0000-000000000002'));

SELECT pg_temp.ise_assert('ISE-T03', maintenance.temporal_observation_design_frozen_at('f7430000-0000-0000-0000-000000000001')='2026-10-08 08:04+00'::timestamptz);

INSERT INTO maintenance.temporal_observation_authority(
 observation_authority_uuid,observation_plan_uuid,observation_epoch_uuid,authority_domain,decision,
 actor,actor_type,decision_artifact_uuid,decided_at,limitations_payload,created_at)
VALUES('f7460000-0000-0000-0000-000000000001','f7410000-0000-0000-0000-000000000001','f7430000-0000-0000-0000-000000000001','operational_execution','approved','synthetic-owner','owner','f7400000-0000-0000-0000-000000000008',
'2026-10-08 08:10+00','{"synthetic_test_only":true}'::jsonb,'2026-10-08 08:10+00');

SELECT pg_temp.ise_assert('ISE-T04', maintenance.temporal_observation_authority_state('f7430000-0000-0000-0000-000000000001','operational_execution','2026-10-08 08:30+00')='approved');

UPDATE maintenance.temporal_observation_epoch SET epoch_status='authorized_non_normative' WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001';

SELECT pg_temp.ise_assert('ISE-T05', maintenance.temporal_activation_preflight_state('f7430000-0000-0000-0000-000000000001','2026-10-08 08:29+00')='WAIT');

SELECT pg_temp.ise_assert('ISE-T06', maintenance.temporal_activation_preflight_state('f7430000-0000-0000-0000-000000000001','2026-10-08 08:30+00')='PASS');

SELECT pg_temp.ise_assert('ISE-T07', maintenance.temporal_activation_preflight_state('f7430000-0000-0000-0000-000000000001','2026-10-08 09:00+00')='FAIL');

SELECT pg_temp.ise_assert('ISE-T08', (SELECT epoch_status='authorized_non_normative' AND started_at IS NULL FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001'));

UPDATE maintenance.temporal_observation_epoch SET epoch_status='active',started_at='2026-10-08 08:30+00' WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001';

SELECT pg_temp.ise_assert('ISE-T09', (SELECT epoch_status='active' AND started_at='2026-10-08 08:30+00'::timestamptz FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001'));

INSERT INTO maintenance.temporal_measurement_event(
 measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
 execution_started_at,execution_completed_at,novelty_state,raw_result_count,raw_result_count_status,
 materialized_identifier_count,new_identifier_count,failure_attribution,failure_evidence_artifact_uuid,
 effort_payload,operator,actor_type)
VALUES('f7470000-0000-0000-0000-000000000001','f7450000-0000-0000-0000-000000000001',1,'completed','2026-10-08 09:01+00','2026-10-08 09:01+00'::timestamptz + interval '1 minute',
'not_applicable',1,'known',1,NULL,
'not_applicable',NULL,'{"operator_minutes":1,"retry_count":0,"note":"SYNTHETIC_TEST_ONLY"}'::jsonb,'F4-ISE','system');

INSERT INTO maintenance.temporal_measurement_item(
 measurement_item_uuid,measurement_event_uuid,source_identifier,source_locator,item_state,oes_detected_at,source_record_artifact_uuid)
VALUES('f7480000-0000-0000-0000-000000000001','f7470000-0000-0000-0000-000000000001','PMID-ISE-SYNTH-1','https://example.invalid/f4-ise/PMID-ISE-SYNTH-1','new_to_epoch',
'2026-10-08 09:01:30+00','f7400000-0000-0000-0000-000000000009');

INSERT INTO maintenance.temporal_measurement_item_timepoint(
 measurement_item_timepoint_uuid,measurement_item_uuid,semantic_code,source_field,raw_value,precision,timezone_name,
 lower_bound_at,upper_bound_at,observability_status,source_artifact_uuid)
VALUES('f7490000-0000-0000-0000-000000000001','f7480000-0000-0000-0000-000000000001','create_date','CRDT','2026-10-08','day','UTC',
'2026-10-08 00:00+00','2026-10-08 23:59:59+00','bounded','f7400000-0000-0000-0000-000000000009');

INSERT INTO maintenance.temporal_measurement_event_artifact(measurement_event_uuid,artifact_uuid,artifact_role,sequence_no)
VALUES('f7470000-0000-0000-0000-000000000001','f7400000-0000-0000-0000-000000000006','query_snapshot',1),('f7470000-0000-0000-0000-000000000001','f7400000-0000-0000-0000-000000000010','result_snapshot',1);

INSERT INTO maintenance.temporal_measurement_opportunity_resolution(
 opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,terminal_measurement_event_uuid,
 reason_code,resolved_at,resolved_by,actor_type)
VALUES('f74a0000-0000-0000-0000-000000000001','f7450000-0000-0000-0000-000000000001','completed','f7470000-0000-0000-0000-000000000001','synthetic_complete','2026-10-08 09:05+00','F4-ISE','system');

SELECT pg_temp.ise_assert('ISE-T10', (SELECT novelty_state='not_applicable' AND new_identifier_count IS NULL AND raw_result_count=1 FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7470000-0000-0000-0000-000000000001'));

SELECT pg_temp.ise_assert('ISE-T11', (SELECT item_state='new_to_epoch' FROM maintenance.temporal_measurement_item WHERE measurement_item_uuid='f7480000-0000-0000-0000-000000000001') AND (SELECT observability_status='bounded' AND precision='day' FROM maintenance.temporal_measurement_item_timepoint WHERE measurement_item_timepoint_uuid='f7490000-0000-0000-0000-000000000001'));

SELECT pg_temp.ise_assert('ISE-T12', (SELECT count(*)=2 FROM maintenance.temporal_measurement_event_artifact WHERE measurement_event_uuid='f7470000-0000-0000-0000-000000000001') AND (SELECT resolution_status='completed' FROM maintenance.temporal_measurement_opportunity_resolution WHERE opportunity_resolution_uuid='f74a0000-0000-0000-0000-000000000001'));

INSERT INTO maintenance.temporal_measurement_event(
 measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
 execution_started_at,execution_completed_at,novelty_state,raw_result_count,raw_result_count_status,
 materialized_identifier_count,new_identifier_count,failure_attribution,failure_evidence_artifact_uuid,
 effort_payload,operator,actor_type)
VALUES('f7470000-0000-0000-0000-000000000002','f7450000-0000-0000-0000-000000000002',1,'completed','2026-10-08 10:01+00','2026-10-08 10:01+00'::timestamptz + interval '1 minute',
'zero_new',1,'known',1,0,
'not_applicable',NULL,'{"operator_minutes":1,"retry_count":0,"note":"SYNTHETIC_TEST_ONLY"}'::jsonb,'F4-ISE','system');

INSERT INTO maintenance.temporal_measurement_item(
 measurement_item_uuid,measurement_event_uuid,source_identifier,source_locator,item_state,oes_detected_at,source_record_artifact_uuid)
VALUES('f7480000-0000-0000-0000-000000000002','f7470000-0000-0000-0000-000000000002','PMID-ISE-SYNTH-1','https://example.invalid/f4-ise/PMID-ISE-SYNTH-1','reobserved',
'2026-10-08 10:01:30+00','f7400000-0000-0000-0000-000000000009');

INSERT INTO maintenance.temporal_measurement_opportunity_resolution(
 opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,terminal_measurement_event_uuid,
 reason_code,resolved_at,resolved_by,actor_type)
VALUES('f74a0000-0000-0000-0000-000000000002','f7450000-0000-0000-0000-000000000002','completed','f7470000-0000-0000-0000-000000000002','synthetic_complete','2026-10-08 10:05+00','F4-ISE','system');

SELECT pg_temp.ise_assert('ISE-T13', (SELECT novelty_state='zero_new' AND new_identifier_count=0 FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7470000-0000-0000-0000-000000000002'));

INSERT INTO maintenance.temporal_measurement_event(
 measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
 execution_started_at,execution_completed_at,novelty_state,raw_result_count,raw_result_count_status,
 materialized_identifier_count,new_identifier_count,failure_attribution,failure_evidence_artifact_uuid,
 effort_payload,operator,actor_type)
VALUES('f7470000-0000-0000-0000-000000000003','f7450000-0000-0000-0000-000000000003',1,'failed','2026-10-08 09:31+00','2026-10-08 09:31+00'::timestamptz + interval '1 minute',
'unknown',NULL,'unknown',NULL,NULL,
'source_confirmed','f7400000-0000-0000-0000-000000000014','{"operator_minutes":1,"retry_count":0,"note":"SYNTHETIC_TEST_ONLY"}'::jsonb,'F4-ISE','system');

SELECT pg_temp.ise_assert('ISE-T14', (SELECT execution_status='failed' AND failure_evidence_artifact_uuid='f7400000-0000-0000-0000-000000000014' FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7470000-0000-0000-0000-000000000003'));

SELECT pg_temp.ise_assert('ISE-T15', (SELECT count(*)=0 FROM maintenance.temporal_measurement_event me JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid) WHERE o.epoch_source_uuid='f7440000-0000-0000-0000-000000000002' AND me.execution_status='completed'));

INSERT INTO maintenance.temporal_measurement_event(
 measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
 execution_started_at,execution_completed_at,novelty_state,raw_result_count,raw_result_count_status,
 materialized_identifier_count,new_identifier_count,failure_attribution,failure_evidence_artifact_uuid,
 effort_payload,operator,actor_type)
VALUES('f7470000-0000-0000-0000-000000000004','f7450000-0000-0000-0000-000000000003',2,'completed','2026-10-08 09:33+00','2026-10-08 09:33+00'::timestamptz + interval '1 minute',
'not_applicable',0,'known',0,NULL,
'not_applicable',NULL,'{"operator_minutes":1,"retry_count":0,"note":"SYNTHETIC_TEST_ONLY"}'::jsonb,'F4-ISE','system');

INSERT INTO maintenance.temporal_measurement_opportunity_resolution(
 opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,terminal_measurement_event_uuid,
 reason_code,resolved_at,resolved_by,actor_type)
VALUES('f74a0000-0000-0000-0000-000000000003','f7450000-0000-0000-0000-000000000003','completed','f7470000-0000-0000-0000-000000000004','synthetic_complete','2026-10-08 09:35+00','F4-ISE','system');

SELECT pg_temp.ise_assert('ISE-T16', (SELECT attempt_no=2 AND raw_result_count=0 AND novelty_state='not_applicable' AND new_identifier_count IS NULL FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7470000-0000-0000-0000-000000000004'));

INSERT INTO maintenance.temporal_measurement_event(
 measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
 execution_started_at,execution_completed_at,novelty_state,raw_result_count,raw_result_count_status,
 materialized_identifier_count,new_identifier_count,failure_attribution,failure_evidence_artifact_uuid,
 effort_payload,operator,actor_type)
VALUES('f7470000-0000-0000-0000-000000000005','f7450000-0000-0000-0000-000000000004',1,'partial','2026-10-08 10:31+00','2026-10-08 10:31+00'::timestamptz + interval '1 minute',
'unknown',NULL,'unknown',1,NULL,
'unknown',NULL,'{"operator_minutes":1,"retry_count":0,"note":"SYNTHETIC_TEST_ONLY"}'::jsonb,'F4-ISE','system');

INSERT INTO maintenance.temporal_measurement_item(
 measurement_item_uuid,measurement_event_uuid,source_identifier,source_locator,item_state,oes_detected_at,source_record_artifact_uuid)
VALUES('f7480000-0000-0000-0000-000000000003','f7470000-0000-0000-0000-000000000005','NCT-ISE-SYNTH-1','https://example.invalid/f4-ise/NCT-ISE-SYNTH-1','new_to_epoch',
'2026-10-08 10:31:30+00','f7400000-0000-0000-0000-000000000009');

SELECT pg_temp.ise_assert('ISE-T17', (SELECT execution_status='partial' AND raw_result_count IS NULL FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7470000-0000-0000-0000-000000000005') AND (SELECT count(*)=0 FROM maintenance.temporal_measurement_opportunity_resolution WHERE measurement_opportunity_uuid='f7450000-0000-0000-0000-000000000004'));

INSERT INTO maintenance.temporal_measurement_event(
 measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
 execution_started_at,execution_completed_at,novelty_state,raw_result_count,raw_result_count_status,
 materialized_identifier_count,new_identifier_count,failure_attribution,failure_evidence_artifact_uuid,
 effort_payload,operator,actor_type)
VALUES('f7470000-0000-0000-0000-000000000006','f7450000-0000-0000-0000-000000000004',2,'completed','2026-10-08 10:33+00','2026-10-08 10:33+00'::timestamptz + interval '1 minute',
'zero_new',1,'known',1,0,
'not_applicable',NULL,'{"operator_minutes":1,"retry_count":0,"note":"SYNTHETIC_TEST_ONLY"}'::jsonb,'F4-ISE','system');

INSERT INTO maintenance.temporal_measurement_item(
 measurement_item_uuid,measurement_event_uuid,source_identifier,source_locator,item_state,oes_detected_at,source_record_artifact_uuid)
VALUES('f7480000-0000-0000-0000-000000000004','f7470000-0000-0000-0000-000000000006','NCT-ISE-SYNTH-1','https://example.invalid/f4-ise/NCT-ISE-SYNTH-1','reobserved',
'2026-10-08 10:33:30+00','f7400000-0000-0000-0000-000000000009');

INSERT INTO maintenance.temporal_measurement_item_timepoint(
 measurement_item_timepoint_uuid,measurement_item_uuid,semantic_code,source_field,raw_value,precision,timezone_name,
 lower_bound_at,upper_bound_at,observability_status,source_artifact_uuid)
VALUES('f7490000-0000-0000-0000-000000000002','f7480000-0000-0000-0000-000000000004','last_update_posted','lastUpdatePostDate','2026-10-07','day','UTC',
'2026-10-07 00:00+00','2026-10-07 23:59:59+00','bounded','f7400000-0000-0000-0000-000000000009');

INSERT INTO maintenance.temporal_measurement_event_artifact(measurement_event_uuid,artifact_uuid,artifact_role,sequence_no)
VALUES('f7470000-0000-0000-0000-000000000006','f7400000-0000-0000-0000-000000000007','query_snapshot',1),('f7470000-0000-0000-0000-000000000006','f7400000-0000-0000-0000-000000000010','result_snapshot',1);

SELECT pg_temp.ise_assert('ISE-T18', (SELECT novelty_state='zero_new' AND new_identifier_count=0 FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7470000-0000-0000-0000-000000000006') AND (SELECT item_state='reobserved' FROM maintenance.temporal_measurement_item WHERE measurement_item_uuid='f7480000-0000-0000-0000-000000000004'));

SELECT pg_temp.ise_assert('ISE-T19', (SELECT count(*)=4 FROM maintenance.temporal_measurement_replay_v WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001') AND (SELECT count(*)=6 FROM maintenance.temporal_measurement_event me JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid) JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid) WHERE es.observation_epoch_uuid='f7430000-0000-0000-0000-000000000001'));

SELECT pg_temp.ise_assert('ISE-T20', (SELECT count(*)=0 FROM maintenance.temporal_measurement_event_issues('f7470000-0000-0000-0000-000000000006') WHERE severity='blocker') AND (SELECT count(*)=0 FROM maintenance.temporal_measurement_event_issues('f7470000-0000-0000-0000-000000000004') WHERE severity='blocker'));

SELECT pg_temp.ise_assert('ISE-T21', pg_temp.ise_expect_reject('INSERT INTO maintenance.temporal_measurement_opportunity_resolution(opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,reason_code,resolved_at,resolved_by,actor_type) VALUES(''f74a0000-0000-0000-0000-000000000007'',''f7450000-0000-0000-0000-000000000004'',''not_executed'',''synthetic_invalid'',''2026-10-08 11:00+00'',''F4-ISE'',''system'')','not_executed requires zero attempts'));

SELECT pg_temp.ise_assert('ISE-T22', pg_temp.ise_expect_reject('UPDATE maintenance.temporal_observation_epoch SET epoch_status=''completed'',completed_at=''2026-10-08 12:01+00'' WHERE observation_epoch_uuid=''f7430000-0000-0000-0000-000000000001''','unresolved opportunities'));

INSERT INTO maintenance.temporal_measurement_opportunity_resolution(
 opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,terminal_measurement_event_uuid,
 reason_code,resolved_at,resolved_by,actor_type)
VALUES('f74a0000-0000-0000-0000-000000000004','f7450000-0000-0000-0000-000000000004','completed','f7470000-0000-0000-0000-000000000006','synthetic_complete','2026-10-08 10:36+00','F4-ISE','system');

SELECT pg_temp.ise_assert('ISE-T23', (SELECT count(*)=4 FROM maintenance.temporal_measurement_opportunity_resolution r JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid) JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid) WHERE es.observation_epoch_uuid='f7430000-0000-0000-0000-000000000001') AND pg_temp.ise_expect_reject('UPDATE maintenance.temporal_observation_epoch SET epoch_status=''completed'',completed_at=''2026-10-08 11:59+00'' WHERE observation_epoch_uuid=''f7430000-0000-0000-0000-000000000001''','completion requires completed_at at/after review boundary'));

UPDATE maintenance.temporal_observation_epoch SET epoch_status='completed',completed_at='2026-10-08 12:01+00' WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001';

SELECT pg_temp.ise_assert('ISE-T24', (SELECT epoch_status='completed' FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='f7430000-0000-0000-0000-000000000001')
AND (SELECT signals=(SELECT count(*) FROM maintenance.update_signal)
 AND cadence_observations=(SELECT count(*) FROM maintenance.cadence_observation)
 AND monitor_cycles=(SELECT count(*) FROM maintenance.monitor_cycle)
 AND b1_epoch_fingerprint=(SELECT md5(string_agg(e.observation_epoch_uuid::text||':'||e.epoch_status||':'||COALESCE(e.started_at::text,'NULL')||':'||COALESCE(e.completed_at::text,'NULL'), '|' ORDER BY e.observation_epoch_uuid)) FROM maintenance.temporal_observation_epoch e WHERE e.observation_epoch_uuid IN ('b3120000-0000-0000-0000-000000000001','b3120000-0000-0000-0000-000000000002')) FROM ise_before)
AND (SELECT count(*)=0 FROM maintenance.temporal_measurement_event me JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid) JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid) WHERE es.observation_epoch_uuid IN ('b3120000-0000-0000-0000-000000000001','b3120000-0000-0000-0000-000000000002')));

DO $ise$ BEGIN
  IF (SELECT count(*) FROM ise_passed)<>24 THEN RAISE EXCEPTION 'Expected exactly 24 verified ISE tests'; END IF;
END $ise$;
SELECT 'F4-ISE-T01-T24 PASS' AS result;
ROLLBACK;
