-- F4 first-measurement synthetic harness — FM-T01–T24
-- Requires migrations through 036 and baseline F2/F3 data.
-- Entire harness is synthetic and rolled back. No real source/network execution.

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.fm_assert(test_name text, ok boolean)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT ok THEN RAISE EXCEPTION '% FAIL',test_name; END IF;
  RAISE NOTICE '% PASS',test_name;
END $$;

CREATE TEMP TABLE fm_before_counts AS
SELECT
  (SELECT count(*) FROM maintenance.update_signal) AS update_signal_n,
  (SELECT count(*) FROM maintenance.cadence_observation) AS cadence_observation_n,
  (SELECT count(*) FROM maintenance.monitor_cycle) AS monitor_cycle_n;

INSERT INTO artifact.artifact(
  artifact_uuid,artifact_type,storage_key,content_hash,mime_type,created_by,status
) VALUES
('fa000000-0000-0000-0000-000000000001','method','fixtures/fm/plan.md','sha256-fm-plan','text/markdown','fm-harness','active'),
('fa000000-0000-0000-0000-000000000002','method','fixtures/fm/source.md','sha256-fm-source','text/markdown','fm-harness','active'),
('fa000000-0000-0000-0000-000000000003','method','fixtures/fm/epoch.md','sha256-fm-epoch','text/markdown','fm-harness','active'),
('fa000000-0000-0000-0000-000000000004','method','fixtures/fm/schedule.md','sha256-fm-schedule','text/markdown','fm-harness','active'),
('fa000000-0000-0000-0000-000000000005','query','fixtures/fm/query.txt','sha256-fm-query','text/plain','fm-harness','active'),
('fa000000-0000-0000-0000-000000000006','decision','fixtures/fm/authority.md','sha256-fm-authority','text/markdown','fm-harness','active'),
('fa000000-0000-0000-0000-000000000007','source_record','fixtures/fm/item.json','sha256-fm-item','application/json','fm-harness','active'),
('fa000000-0000-0000-0000-000000000008','other','fixtures/fm/failure.json','sha256-fm-failure','application/json','fm-harness','active');

INSERT INTO maintenance.temporal_observation_plan(
  observation_plan_uuid,plan_code,plan_version,target_product_version_uuid,
  calibration_object,readiness_scope,specification_artifact_uuid,
  prepared_at,created_by,actor_type,record_status,created_at
) VALUES (
  'fa100000-0000-0000-0000-000000000001','FM-SYNTH-01',1,
  'e5100000-0000-0000-0000-000000000003',
  'cadence','policy_aggregate','fa000000-0000-0000-0000-000000000001',
  TIMESTAMPTZ '2026-10-08 09:00:00+00','fm-harness','ai_system','active',
  TIMESTAMPTZ '2026-10-08 09:00:00+00'
);

INSERT INTO maintenance.temporal_observation_source(
  observation_source_uuid,observation_plan_uuid,source_code,source_name,source_class,
  inclusion_status,interface_code,access_mode,runtime_connectivity_required,
  time_semantics_payload,source_definition_artifact_uuid,inclusion_rationale,
  created_at,created_by
) VALUES (
  'fa110000-0000-0000-0000-000000000001','fa100000-0000-0000-0000-000000000001',
  'FM_SOURCE','FM synthetic source','bibliographic','included','synthetic','programmatic',false,
  '{"schema_version":"0.1","semantic_codes":["create_date","entry_date"],"identifier_semantic":"FM_ID","source_class":"bibliographic"}'::jsonb,
  'fa000000-0000-0000-0000-000000000002','Synthetic first-measurement harness',
  TIMESTAMPTZ '2026-10-08 09:05:00+00','fm-harness'
);

INSERT INTO maintenance.temporal_observation_epoch(
  observation_epoch_uuid,observation_plan_uuid,epoch_code,epoch_status,
  measurement_design_artifact_uuid,start_boundary_at,review_boundary_at,
  created_at,created_by
) VALUES (
  'fa120000-0000-0000-0000-000000000001','fa100000-0000-0000-0000-000000000001',
  'FM-B1','draft','fa000000-0000-0000-0000-000000000003',
  TIMESTAMPTZ '2026-10-08 11:00:00+00',TIMESTAMPTZ '2026-10-10 18:00:00+00',
  TIMESTAMPTZ '2026-10-08 09:10:00+00','fm-harness'
);

INSERT INTO maintenance.temporal_observation_epoch_source(
  epoch_source_uuid,observation_epoch_uuid,observation_source_uuid,
  query_strategy_artifact_uuid,measurement_investigation_version_uuid,
  schedule_definition_artifact_uuid,runtime_interface_code,
  measurement_schedule_payload,runtime_connectivity_status,created_at
) VALUES (
  'fa130000-0000-0000-0000-000000000001','fa120000-0000-0000-0000-000000000001',
  'fa110000-0000-0000-0000-000000000001','fa000000-0000-0000-0000-000000000005',
  'e5100000-0000-0000-0000-000000000002','fa000000-0000-0000-0000-000000000004',
  'synthetic',
  '{
    "schema":"oes.temporal_opportunity_set/0.1",
    "non_normative":true,
    "schedule_kind":"finite_opportunity_set",
    "rationale":"FM synthetic finite set",
    "opportunities":[
      {"opportunity_no":1,"planned_for":"2026-10-08T12:00:00+00:00"},
      {"opportunity_no":2,"planned_for":"2026-10-08T13:00:00+00:00"},
      {"opportunity_no":3,"planned_for":"2026-10-08T14:00:00+00:00"},
      {"opportunity_no":4,"planned_for":"2026-10-08T15:00:00+00:00"}
    ]
  }'::jsonb,
  'verified',TIMESTAMPTZ '2026-10-08 09:15:00+00'
);

INSERT INTO maintenance.temporal_measurement_opportunity(
  measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,
  opportunity_origin,schedule_snapshot_artifact_uuid,created_at
) VALUES
('fa140000-0000-0000-0000-000000000001','fa130000-0000-0000-0000-000000000001',1,TIMESTAMPTZ '2026-10-08 12:00:00+00','frozen_opportunity_set','fa000000-0000-0000-0000-000000000004',TIMESTAMPTZ '2026-10-08 09:20:00+00'),
('fa140000-0000-0000-0000-000000000002','fa130000-0000-0000-0000-000000000001',2,TIMESTAMPTZ '2026-10-08 13:00:00+00','frozen_opportunity_set','fa000000-0000-0000-0000-000000000004',TIMESTAMPTZ '2026-10-08 09:21:00+00'),
('fa140000-0000-0000-0000-000000000003','fa130000-0000-0000-0000-000000000001',3,TIMESTAMPTZ '2026-10-08 14:00:00+00','frozen_opportunity_set','fa000000-0000-0000-0000-000000000004',TIMESTAMPTZ '2026-10-08 09:22:00+00'),
('fa140000-0000-0000-0000-000000000004','fa130000-0000-0000-0000-000000000001',4,TIMESTAMPTZ '2026-10-08 15:00:00+00','frozen_opportunity_set','fa000000-0000-0000-0000-000000000004',TIMESTAMPTZ '2026-10-08 09:23:00+00');

INSERT INTO maintenance.temporal_observation_authority(
  observation_authority_uuid,observation_plan_uuid,observation_epoch_uuid,
  authority_domain,decision,actor,actor_type,decision_artifact_uuid,decided_at,
  limitations_payload,created_at
) VALUES (
  'fa150000-0000-0000-0000-000000000001','fa100000-0000-0000-0000-000000000001',
  'fa120000-0000-0000-0000-000000000001','operational_execution','approved',
  'fm-owner','owner','fa000000-0000-0000-0000-000000000006',
  TIMESTAMPTZ '2026-10-08 09:30:00+00','{"synthetic":true}'::jsonb,
  TIMESTAMPTZ '2026-10-08 09:30:00+00'
);

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='authorized_non_normative'
WHERE observation_epoch_uuid='fa120000-0000-0000-0000-000000000001';

-- FM-T01: measurement before active epoch is rejected.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
      execution_started_at,novelty_state,raw_result_count_status,failure_attribution,
      effort_payload,operator,actor_type
    ) VALUES (
      'fa160000-0000-0000-0000-000000000001','fa140000-0000-0000-0000-000000000001',
      1,'failed',TIMESTAMPTZ '2026-10-08 11:30:00+00','unknown','unknown','unknown','{}','fm','system'
    );
    RAISE EXCEPTION 'FM-T01 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T01 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T01 PASS';
END $$;

-- FM-T02: nonexistent opportunity is rejected.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
      execution_started_at,novelty_state,raw_result_count_status,failure_attribution,
      effort_payload,operator,actor_type
    ) VALUES (
      'fa160000-0000-0000-0000-000000000002','fa140000-0000-0000-0000-000000000099',
      1,'failed',TIMESTAMPTZ '2026-10-08 11:30:00+00','unknown','unknown','unknown','{}','fm','system'
    );
    RAISE EXCEPTION 'FM-T02 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T02 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T02 PASS';
END $$;

UPDATE maintenance.temporal_observation_epoch
SET epoch_status='active',started_at=TIMESTAMPTZ '2026-10-08 11:00:00+00'
WHERE observation_epoch_uuid='fa120000-0000-0000-0000-000000000001';

-- FM-T06 before the valid baseline: non-NULL new_identifier_count is rejected.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
      execution_started_at,execution_completed_at,novelty_state,
      raw_result_count,raw_result_count_status,materialized_identifier_count,new_identifier_count,
      failure_attribution,effort_payload,operator,actor_type
    ) VALUES (
      'fa160000-0000-0000-0000-000000000006','fa140000-0000-0000-0000-000000000001',
      1,'completed',TIMESTAMPTZ '2026-10-08 12:01:00+00',TIMESTAMPTZ '2026-10-08 12:02:00+00',
      'not_applicable',1,'known',1,1,'not_applicable','{}','fm','system'
    );
    RAISE EXCEPTION 'FM-T06 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T06 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T06 PASS';
END $$;

-- FM-T05: first completed event is a baseline aggregate.
INSERT INTO maintenance.temporal_measurement_event(
  measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
  execution_started_at,execution_completed_at,novelty_state,
  raw_result_count,raw_result_count_status,materialized_identifier_count,new_identifier_count,
  failure_attribution,effort_payload,operator,actor_type,created_at
) VALUES (
  'fa160000-0000-0000-0000-000000000005','fa140000-0000-0000-0000-000000000001',
  1,'completed',TIMESTAMPTZ '2026-10-08 12:01:00+00',TIMESTAMPTZ '2026-10-08 12:02:00+00',
  'not_applicable',1,'known',1,NULL,'not_applicable',
  '{"operator_minutes":1,"machine_elapsed_seconds":60,"retry_count":0}'::jsonb,'fm','system',
  TIMESTAMPTZ '2026-10-08 12:02:00+00'
);
SELECT pg_temp.fm_assert('FM-T05',(SELECT novelty_state='not_applicable' AND new_identifier_count IS NULL FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='fa160000-0000-0000-0000-000000000005'));

-- FM-T07: new_to_epoch does not alter aggregate baseline semantics.
INSERT INTO maintenance.temporal_measurement_item(
  measurement_item_uuid,measurement_event_uuid,source_identifier,source_locator,item_state,
  oes_detected_at,source_record_artifact_uuid
) VALUES (
  'fa170000-0000-0000-0000-000000000001','fa160000-0000-0000-0000-000000000005',
  'FM-ID-1','https://example.invalid/fm/1','new_to_epoch',
  TIMESTAMPTZ '2026-10-08 12:01:30+00','fa000000-0000-0000-0000-000000000007'
);
SELECT pg_temp.fm_assert('FM-T07',(SELECT mi.item_state='new_to_epoch' AND me.novelty_state='not_applicable' AND me.new_identifier_count IS NULL FROM maintenance.temporal_measurement_item mi JOIN maintenance.temporal_measurement_event me USING(measurement_event_uuid) WHERE mi.measurement_item_uuid='fa170000-0000-0000-0000-000000000001'));

-- FM-T08: subsequent completed event cannot use not_applicable.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
      execution_started_at,execution_completed_at,novelty_state,
      raw_result_count,raw_result_count_status,materialized_identifier_count,new_identifier_count,
      failure_attribution,effort_payload,operator,actor_type
    ) VALUES (
      'fa160000-0000-0000-0000-000000000008','fa140000-0000-0000-0000-000000000002',
      1,'completed',TIMESTAMPTZ '2026-10-08 13:01:00+00',TIMESTAMPTZ '2026-10-08 13:02:00+00',
      'not_applicable',1,'known',1,NULL,'not_applicable','{}','fm','system'
    );
    RAISE EXCEPTION 'FM-T08 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T08 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T08 PASS';
END $$;

INSERT INTO maintenance.temporal_measurement_event(
  measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
  execution_started_at,execution_completed_at,novelty_state,
  raw_result_count,raw_result_count_status,materialized_identifier_count,new_identifier_count,
  failure_attribution,effort_payload,operator,actor_type
) VALUES (
  'fa160000-0000-0000-0000-000000000009','fa140000-0000-0000-0000-000000000002',
  1,'completed',TIMESTAMPTZ '2026-10-08 13:01:00+00',TIMESTAMPTZ '2026-10-08 13:02:00+00',
  'zero_new',1,'known',1,0,'not_applicable','{}','fm','system'
);

-- FM-T09–T14: count/failure constraints, all rejected without leaving an attempt.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,execution_started_at,novelty_state,raw_result_count_status,failure_attribution,effort_payload,operator,actor_type)
    VALUES('fa160000-0000-0000-0000-000000000019','fa140000-0000-0000-0000-000000000003',1,'failed',TIMESTAMPTZ '2026-10-08 14:01+00','unknown','known','unknown','{}','fm','system');
    RAISE EXCEPTION 'FM-T09 expected failure';
  EXCEPTION WHEN others THEN IF SQLERRM='FM-T09 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'FM-T09 PASS';

  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,execution_started_at,novelty_state,raw_result_count,raw_result_count_status,failure_attribution,effort_payload,operator,actor_type)
    VALUES('fa160000-0000-0000-0000-000000000020','fa140000-0000-0000-0000-000000000003',1,'failed',TIMESTAMPTZ '2026-10-08 14:01+00','unknown',1,'unknown','unknown','{}','fm','system');
    RAISE EXCEPTION 'FM-T10 expected failure';
  EXCEPTION WHEN others THEN IF SQLERRM='FM-T10 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'FM-T10 PASS';

  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,execution_started_at,novelty_state,raw_result_count_status,new_identifier_count,failure_attribution,effort_payload,operator,actor_type)
    VALUES('fa160000-0000-0000-0000-000000000021','fa140000-0000-0000-0000-000000000003',1,'failed',TIMESTAMPTZ '2026-10-08 14:01+00','zero_new','unknown',1,'unknown','{}','fm','system');
    RAISE EXCEPTION 'FM-T11 expected failure';
  EXCEPTION WHEN others THEN IF SQLERRM='FM-T11 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'FM-T11 PASS';

  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,execution_started_at,novelty_state,raw_result_count_status,new_identifier_count,failure_attribution,effort_payload,operator,actor_type)
    VALUES('fa160000-0000-0000-0000-000000000022','fa140000-0000-0000-0000-000000000003',1,'failed',TIMESTAMPTZ '2026-10-08 14:01+00','new_items','unknown',0,'unknown','{}','fm','system');
    RAISE EXCEPTION 'FM-T12 expected failure';
  EXCEPTION WHEN others THEN IF SQLERRM='FM-T12 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'FM-T12 PASS';

  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,execution_started_at,novelty_state,raw_result_count_status,failure_attribution,effort_payload,operator,actor_type)
    VALUES('fa160000-0000-0000-0000-000000000023','fa140000-0000-0000-0000-000000000003',1,'failed',TIMESTAMPTZ '2026-10-08 14:01+00','unknown','unknown','source_confirmed','{}','fm','system');
    RAISE EXCEPTION 'FM-T13 expected failure';
  EXCEPTION WHEN others THEN IF SQLERRM='FM-T13 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'FM-T13 PASS';

  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,execution_started_at,novelty_state,raw_result_count_status,failure_attribution,effort_payload,operator,actor_type)
    VALUES('fa160000-0000-0000-0000-000000000024','fa140000-0000-0000-0000-000000000003',1,'failed',TIMESTAMPTZ '2026-10-08 14:01+00','unknown','unknown','mixed','{}','fm','system');
    RAISE EXCEPTION 'FM-T14 expected failure';
  EXCEPTION WHEN others THEN IF SQLERRM='FM-T14 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'FM-T14 PASS';
END $$;

-- FM-T15: failed + unknown attribution is representable.
INSERT INTO maintenance.temporal_measurement_event(
  measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
  execution_started_at,execution_completed_at,novelty_state,raw_result_count_status,
  failure_attribution,effort_payload,operator,actor_type
) VALUES (
  'fa160000-0000-0000-0000-000000000015','fa140000-0000-0000-0000-000000000003',
  1,'failed',TIMESTAMPTZ '2026-10-08 14:01:00+00',TIMESTAMPTZ '2026-10-08 14:02:00+00',
  'unknown','unknown','unknown','{}','fm','system'
);
SELECT pg_temp.fm_assert('FM-T15',(SELECT execution_status='failed' AND failure_attribution='unknown' FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='fa160000-0000-0000-0000-000000000015'));

-- FM-T04: duplicate/non-contiguous attempt number is rejected.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
      execution_started_at,novelty_state,raw_result_count_status,failure_attribution,
      effort_payload,operator,actor_type
    ) VALUES (
      'fa160000-0000-0000-0000-000000000004','fa140000-0000-0000-0000-000000000003',
      1,'failed',TIMESTAMPTZ '2026-10-08 14:03:00+00','unknown','unknown','unknown','{}','fm','system'
    );
    RAISE EXCEPTION 'FM-T04 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T04 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T04 PASS';
END $$;

-- FM-T16: completed event cannot carry failure attribution.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
      execution_started_at,execution_completed_at,novelty_state,raw_result_count_status,
      failure_attribution,effort_payload,operator,actor_type
    ) VALUES (
      'fa160000-0000-0000-0000-000000000016','fa140000-0000-0000-0000-000000000004',
      1,'completed',TIMESTAMPTZ '2026-10-08 15:01:00+00',TIMESTAMPTZ '2026-10-08 15:02:00+00',
      'unknown','unknown','unknown','{}','fm','system'
    );
    RAISE EXCEPTION 'FM-T16 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T16 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T16 PASS';
END $$;

-- FM-T17: duplicate source identifier within the same event is rejected.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_item(
      measurement_item_uuid,measurement_event_uuid,source_identifier,item_state,oes_detected_at
    ) VALUES (
      'fa170000-0000-0000-0000-000000000017','fa160000-0000-0000-0000-000000000005',
      'FM-ID-1','new_to_epoch',TIMESTAMPTZ '2026-10-08 12:01:40+00'
    );
    RAISE EXCEPTION 'FM-T17 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T17 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T17 PASS';
END $$;

-- FM-T18/F19/F20: item timepoint precision/observability/detection semantics.
INSERT INTO maintenance.temporal_measurement_item_timepoint(
  measurement_item_timepoint_uuid,measurement_item_uuid,semantic_code,source_field,
  raw_value,precision,timezone_name,lower_bound_at,upper_bound_at,observability_status,
  source_artifact_uuid
) VALUES (
  'fa180000-0000-0000-0000-000000000018','fa170000-0000-0000-0000-000000000001',
  'create_date','CRDT','2026-10-08','day','UTC',
  TIMESTAMPTZ '2026-10-08 00:00:00+00',TIMESTAMPTZ '2026-10-08 23:59:59+00',
  'bounded','fa000000-0000-0000-0000-000000000007'
);
SELECT pg_temp.fm_assert('FM-T18',(SELECT precision='day' AND observability_status='bounded' AND lower_bound_at<>upper_bound_at FROM maintenance.temporal_measurement_item_timepoint WHERE measurement_item_timepoint_uuid='fa180000-0000-0000-0000-000000000018'));

DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_item_timepoint(
      measurement_item_timepoint_uuid,measurement_item_uuid,semantic_code,precision,
      lower_bound_at,upper_bound_at,observability_status
    ) VALUES (
      'fa180000-0000-0000-0000-000000000019','fa170000-0000-0000-0000-000000000001',
      'entry_date','day',TIMESTAMPTZ '2026-10-08 00:00+00',TIMESTAMPTZ '2026-10-08 23:59+00','not_observable'
    );
    RAISE EXCEPTION 'FM-T19 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T19 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T19 PASS';
END $$;

SELECT pg_temp.fm_assert('FM-T20',(
  SELECT mi.oes_detected_at<>tp.lower_bound_at
  FROM maintenance.temporal_measurement_item mi
  JOIN maintenance.temporal_measurement_item_timepoint tp USING(measurement_item_uuid)
  WHERE mi.measurement_item_uuid='fa170000-0000-0000-0000-000000000001'
    AND tp.semantic_code='create_date'
));

-- FM-T21: missed opportunity resolves not_executed with zero MeasurementEvent.
INSERT INTO maintenance.temporal_measurement_opportunity_resolution(
  opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,
  reason_code,resolved_at,resolved_by,actor_type
) VALUES (
  'fa190000-0000-0000-0000-000000000021','fa140000-0000-0000-0000-000000000004',
  'not_executed','synthetic_missed',TIMESTAMPTZ '2026-10-08 16:00:00+00','fm','system'
);
SELECT pg_temp.fm_assert('FM-T21',(
  SELECT r.resolution_status='not_executed' AND NOT EXISTS(
    SELECT 1 FROM maintenance.temporal_measurement_event me
    WHERE me.measurement_opportunity_uuid=r.measurement_opportunity_uuid
  )
  FROM maintenance.temporal_measurement_opportunity_resolution r
  WHERE r.opportunity_resolution_uuid='fa190000-0000-0000-0000-000000000021'
));

-- FM-T22: completed resolution references its terminal completed event.
INSERT INTO maintenance.temporal_measurement_opportunity_resolution(
  opportunity_resolution_uuid,measurement_opportunity_uuid,resolution_status,
  terminal_measurement_event_uuid,reason_code,resolved_at,resolved_by,actor_type
) VALUES (
  'fa190000-0000-0000-0000-000000000022','fa140000-0000-0000-0000-000000000001',
  'completed','fa160000-0000-0000-0000-000000000005','synthetic_completed',
  TIMESTAMPTZ '2026-10-08 12:03:00+00','fm','system'
);
SELECT pg_temp.fm_assert('FM-T22',(SELECT resolution_status='completed' AND terminal_measurement_event_uuid='fa160000-0000-0000-0000-000000000005' FROM maintenance.temporal_measurement_opportunity_resolution WHERE opportunity_resolution_uuid='fa190000-0000-0000-0000-000000000022'));

-- FM-T03: resolved opportunity cannot receive another attempt.
DO $$ BEGIN
  BEGIN
    INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,
      execution_started_at,novelty_state,raw_result_count_status,failure_attribution,
      effort_payload,operator,actor_type
    ) VALUES (
      'fa160000-0000-0000-0000-000000000003','fa140000-0000-0000-0000-000000000001',
      2,'failed',TIMESTAMPTZ '2026-10-08 12:04:00+00','unknown','unknown','unknown','{}','fm','system'
    );
    RAISE EXCEPTION 'FM-T03 expected failure';
  EXCEPTION WHEN others THEN
    IF SQLERRM='FM-T03 expected failure' THEN RAISE; END IF;
  END;
  RAISE NOTICE 'FM-T03 PASS';
END $$;

-- FM-T23: no normative/monitoring objects are created by the harness.
SELECT pg_temp.fm_assert('FM-T23',(
  SELECT
    b.update_signal_n=(SELECT count(*) FROM maintenance.update_signal)
    AND b.cadence_observation_n=(SELECT count(*) FROM maintenance.cadence_observation)
    AND b.monitor_cycle_n=(SELECT count(*) FROM maintenance.monitor_cycle)
  FROM fm_before_counts b
));

-- FM-T24: real B1 is untouched.
SELECT pg_temp.fm_assert('FM-T24',(
  SELECT e.epoch_status='authorized_non_normative'
     AND e.started_at IS NULL
     AND (SELECT count(*) FROM maintenance.temporal_measurement_event me
          JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
          JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
          WHERE es.observation_epoch_uuid=e.observation_epoch_uuid)=0
     AND (SELECT count(*) FROM maintenance.temporal_measurement_opportunity_resolution r
          JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
          JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
          WHERE es.observation_epoch_uuid=e.observation_epoch_uuid)=0
  FROM maintenance.temporal_observation_epoch e
  WHERE e.observation_epoch_uuid='b3120000-0000-0000-0000-000000000001'
));

SELECT 'FM-T01-T24 PASS' AS result;

ROLLBACK;
