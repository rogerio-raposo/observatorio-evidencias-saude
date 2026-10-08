-- F4-TNO full tests TNO-T01–T100
-- Requires migration 033 + f4-temporal-observation-fixtures.sql
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.tno_assert(p_name text,p_condition boolean,p_detail text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT COALESCE(p_condition,false) THEN
    RAISE EXCEPTION '% FAIL: %',p_name,COALESCE(p_detail,'assertion failed');
  END IF;
  RAISE NOTICE '% PASS',p_name;
END $$;

-- T01–T12: physical objects / root constraints
SELECT pg_temp.tno_assert('TNO-T01',to_regclass('maintenance.temporal_observation_plan') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T02',to_regclass('maintenance.temporal_observation_source') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T03',to_regclass('maintenance.temporal_observation_epoch') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T04',to_regclass('maintenance.temporal_observation_epoch_source') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T05',to_regclass('maintenance.temporal_observation_authority') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T06',to_regclass('maintenance.temporal_measurement_opportunity') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T07',to_regclass('maintenance.temporal_measurement_event') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T08',to_regclass('maintenance.temporal_measurement_opportunity_resolution') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T09',to_regclass('maintenance.temporal_measurement_item') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T10',to_regclass('maintenance.temporal_measurement_item_timepoint') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T11',to_regclass('maintenance.temporal_measurement_event_artifact') IS NOT NULL);
SELECT pg_temp.tno_assert('TNO-T12',to_regclass('maintenance.temporal_observation_deviation') IS NOT NULL);

-- T13–T20: canonical fixture / source debt / no normative linkage
SELECT pg_temp.tno_assert('TNO-T13',(SELECT count(*)=1 FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid='f7100000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T14',(SELECT count(*)=2 FROM maintenance.temporal_observation_source WHERE observation_plan_uuid='f7100000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T15',(SELECT inclusion_status='deferred' FROM maintenance.temporal_observation_source WHERE observation_source_uuid='f7110000-0000-0000-0000-000000000002'));
SELECT pg_temp.tno_assert('TNO-T16',(SELECT epoch_status='active' FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T17',(SELECT count(*)=2 FROM maintenance.temporal_measurement_opportunity WHERE epoch_source_uuid='f7130000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T18',maintenance.temporal_epoch_opportunity_set_matches_schedule('f7130000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T19',(SELECT candidate_source_debt_present FROM maintenance.temporal_measurement_readiness_evidence_v WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001' LIMIT 1));
SELECT pg_temp.tno_assert('TNO-T20',NOT EXISTS(
  SELECT 1
  FROM pg_constraint con
  JOIN pg_class src ON src.oid=con.conrelid
  JOIN pg_namespace ns ON ns.oid=src.relnamespace
  JOIN pg_class ref ON ref.oid=con.confrelid
  WHERE con.contype='f'
    AND ns.nspname='maintenance'
    AND src.relname IN (
      'temporal_observation_plan','temporal_observation_source','temporal_observation_epoch',
      'temporal_observation_epoch_source','temporal_observation_authority',
      'temporal_measurement_opportunity','temporal_measurement_event',
      'temporal_measurement_opportunity_resolution','temporal_measurement_item',
      'temporal_measurement_item_timepoint','temporal_measurement_event_artifact',
      'temporal_observation_deviation'
    )
    AND ref.relname IN ('cadence_contract','cadence_obligation','cadence_observation','monitor_cycle','sla_rule','sla_instance')
));

-- T21–T30: payload validators
SELECT pg_temp.tno_assert('TNO-T21',maintenance.temporal_measurement_schedule_payload_is_valid(
'{"schema":"oes.temporal_opportunity_set/0.1","non_normative":true,"schedule_kind":"finite_opportunity_set","rationale":"x","opportunities":[{"opportunity_no":1,"planned_for":"2026-10-08T12:00:00+00:00"}]}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T22',NOT maintenance.temporal_measurement_schedule_payload_is_valid(
'{"schema":"oes.temporal_opportunity_set/0.1","non_normative":false,"schedule_kind":"finite_opportunity_set","rationale":"x","opportunities":[{"opportunity_no":1,"planned_for":"2026-10-08T12:00:00+00:00"}]}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T23',NOT maintenance.temporal_measurement_schedule_payload_is_valid(
'{"schema":"oes.temporal_opportunity_set/0.1","non_normative":true,"schedule_kind":"finite_opportunity_set","rationale":"x","cadence":"weekly","opportunities":[{"opportunity_no":1,"planned_for":"2026-10-08T12:00:00+00:00"}]}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T24',maintenance.jsonb_contains_forbidden_temporal_keys('{"x":{"overdue":true}}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T25',NOT maintenance.jsonb_contains_forbidden_temporal_keys('{"x":{"neutral":true}}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T26',maintenance.temporal_measurement_effort_payload_is_valid('{"operator_minutes":1,"retry_count":0,"note":"x"}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T27',NOT maintenance.temporal_measurement_effort_payload_is_valid('{"operator_minutes":-1}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T28',NOT maintenance.temporal_measurement_effort_payload_is_valid('{"sla":"x"}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T29',maintenance.temporal_source_semantics_payload_is_valid('{"schema_version":"0.1","semantic_codes":["x"],"identifier_semantic":"ID","source_class":"test"}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T30',NOT maintenance.temporal_source_semantics_payload_is_valid('{"schema_version":"0.1","semantic_codes":[],"identifier_semantic":"ID","source_class":"test"}'::jsonb));

-- T31–T38: authority / design freeze
SELECT pg_temp.tno_assert('TNO-T31',maintenance.temporal_observation_authority_state('f7120000-0000-0000-0000-000000000001','operational_execution',CURRENT_TIMESTAMP)='approved');
SELECT pg_temp.tno_assert('TNO-T32',maintenance.temporal_observation_design_frozen_at('f7120000-0000-0000-0000-000000000001')=TIMESTAMPTZ '2026-10-08 09:21:00+00');
SELECT pg_temp.tno_assert('TNO-T33',(SELECT decided_at>=maintenance.temporal_observation_design_frozen_at('f7120000-0000-0000-0000-000000000001') FROM maintenance.temporal_observation_authority WHERE observation_authority_uuid='f7150000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T34',(SELECT actor_type='owner' FROM maintenance.temporal_observation_authority WHERE observation_authority_uuid='f7150000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T35',(SELECT maintenance.temporal_artifact_is_active(decision_artifact_uuid) FROM maintenance.temporal_observation_authority WHERE observation_authority_uuid='f7150000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T36',(SELECT target_product_version_uuid='e5100000-0000-0000-0000-000000000003' FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid='f7100000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T37',maintenance.temporal_target_is_current('f7100000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T38',(SELECT measurement_investigation_version_uuid='e5100000-0000-0000-0000-000000000002' FROM maintenance.temporal_observation_epoch_source WHERE epoch_source_uuid='f7130000-0000-0000-0000-000000000001'));

-- T39–T48: attempts, resolution and item semantics
SELECT pg_temp.tno_assert('TNO-T39',(SELECT attempt_no=1 FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T40',(SELECT execution_status='completed' FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T41',(SELECT novelty_state='new_items' FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T42',(SELECT raw_result_count=1 AND materialized_identifier_count=1 AND new_identifier_count=1 FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T43',maintenance.temporal_measurement_opportunity_status('f7140000-0000-0000-0000-000000000001')='completed');
SELECT pg_temp.tno_assert('TNO-T44',maintenance.temporal_measurement_opportunity_status('f7140000-0000-0000-0000-000000000002')='planned');
SELECT pg_temp.tno_assert('TNO-T45',(SELECT item_state='new_to_epoch' FROM maintenance.temporal_measurement_item WHERE measurement_item_uuid='f7170000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T46',(SELECT observability_status='bounded' FROM maintenance.temporal_measurement_item_timepoint WHERE measurement_item_timepoint_uuid='f7180000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T47',(SELECT count(*)=0 FROM maintenance.temporal_measurement_event_issues('f7160000-0000-0000-0000-000000000001') WHERE severity='blocker'));
SELECT pg_temp.tno_assert('TNO-T48',(SELECT observability_status IN ('bounded','observable') FROM maintenance.temporal_measurement_item_latency('f7170000-0000-0000-0000-000000000001','create_date')));

-- T49–T58: replay/readiness semantics
SELECT pg_temp.tno_assert('TNO-T49',(SELECT count(*)=2 FROM maintenance.temporal_measurement_replay_v WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T50',(SELECT attempt_count=1 FROM maintenance.temporal_measurement_replay_v WHERE measurement_opportunity_uuid='f7140000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T51',(SELECT attempt_count=0 FROM maintenance.temporal_measurement_replay_v WHERE measurement_opportunity_uuid='f7140000-0000-0000-0000-000000000002'));
SELECT pg_temp.tno_assert('TNO-T52',(SELECT planned_opportunities=2 FROM maintenance.temporal_measurement_readiness_evidence_v WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001' AND source_code='PUBMED_SYNTH'));
SELECT pg_temp.tno_assert('TNO-T53',(SELECT completed_opportunities=1 FROM maintenance.temporal_measurement_readiness_evidence_v WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001' AND source_code='PUBMED_SYNTH'));
SELECT pg_temp.tno_assert('TNO-T54',(SELECT unresolved_opportunities=1 FROM maintenance.temporal_measurement_readiness_evidence_v WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001' AND source_code='PUBMED_SYNTH'));
SELECT pg_temp.tno_assert('TNO-T55',(SELECT candidate_source_debt_present FROM maintenance.temporal_measurement_readiness_evidence_v WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001' LIMIT 1));
SELECT pg_temp.tno_assert('TNO-T56',NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_measurement_readiness_evidence_v' AND column_name ILIKE '%ready%'));
SELECT pg_temp.tno_assert('TNO-T57',NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name LIKE 'temporal_%' AND column_name IN ('overdue','breach','compliance_status','next_due_at')));
SELECT pg_temp.tno_assert('TNO-T58',(SELECT epoch_execution_completed=false FROM maintenance.temporal_measurement_readiness_evidence_v WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001' LIMIT 1));

-- T59–T70: immutability / negative lifecycle checks
DO $$ BEGIN
  BEGIN UPDATE maintenance.temporal_measurement_opportunity SET planned_for=planned_for+interval '1 minute' WHERE measurement_opportunity_uuid='f7140000-0000-0000-0000-000000000001'; RAISE EXCEPTION 'TNO-T59 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T59 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T59 PASS';
  BEGIN UPDATE maintenance.temporal_observation_source SET source_name='mutated' WHERE observation_source_uuid='f7110000-0000-0000-0000-000000000001'; RAISE EXCEPTION 'TNO-T60 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T60 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T60 PASS';
  BEGIN DELETE FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001'; RAISE EXCEPTION 'TNO-T61 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T61 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T61 PASS';
  BEGIN INSERT INTO maintenance.temporal_measurement_event(measurement_event_uuid,measurement_opportunity_uuid,attempt_no,execution_status,execution_started_at,novelty_state,raw_result_count_status,failure_attribution,effort_payload,operator,actor_type) VALUES('f7160000-0000-0000-0000-000000000099','f7140000-0000-0000-0000-000000000001',2,'failed',CURRENT_TIMESTAMP,'unknown','unknown','unknown','{}','x','system'); RAISE EXCEPTION 'TNO-T62 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T62 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T62 PASS';
  BEGIN INSERT INTO maintenance.temporal_measurement_opportunity(measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,opportunity_origin) VALUES('f7140000-0000-0000-0000-000000000099','f7130000-0000-0000-0000-000000000001',3,TIMESTAMPTZ '2026-10-09 13:00+00','frozen_opportunity_set'); RAISE EXCEPTION 'TNO-T63 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T63 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T63 PASS';
END $$;
SELECT pg_temp.tno_assert('TNO-T64',(SELECT count(*)=1 FROM maintenance.temporal_measurement_opportunity_resolution WHERE measurement_opportunity_uuid='f7140000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T65',(SELECT count(*)=0 FROM maintenance.temporal_observation_deviation WHERE observation_epoch_uuid='f7120000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T66',(SELECT record_status='active' FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid='f7100000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T67',(SELECT count(*)=0 FROM maintenance.temporal_observation_epoch_issues('f7120000-0000-0000-0000-000000000001') WHERE issue_code='OPPORTUNITY_SET_MISMATCH'));
SELECT pg_temp.tno_assert('TNO-T68',(SELECT count(*)=1 FROM maintenance.temporal_observation_epoch_issues('f7120000-0000-0000-0000-000000000001') WHERE issue_code='OPPORTUNITY_UNRESOLVED'));
SELECT pg_temp.tno_assert('TNO-T69',(SELECT count(*)=1 FROM maintenance.temporal_observation_plan_issues('f7100000-0000-0000-0000-000000000001') WHERE issue_code='SOURCE_DEBT_PRESENT'));
SELECT pg_temp.tno_assert('TNO-T70',NOT EXISTS(SELECT 1 FROM maintenance.temporal_observation_plan_issues('f7100000-0000-0000-0000-000000000001') WHERE severity='blocker'));

-- T71–T80: item/timepoint and source semantics
SELECT pg_temp.tno_assert('TNO-T71',(SELECT count(*)=1 FROM maintenance.temporal_measurement_item WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T72',(SELECT raw_result_count=1 AND new_identifier_count=1 FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T73',NOT EXISTS(SELECT 1 FROM maintenance.temporal_measurement_item WHERE measurement_event_uuid='f7160000-0000-0000-0000-000000000001' AND item_state='reobserved'));
SELECT pg_temp.tno_assert('TNO-T74',(SELECT time_semantics_payload->'semantic_codes' ? 'create_date' FROM maintenance.temporal_observation_source WHERE observation_source_uuid='f7110000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T75',(SELECT maintenance.temporal_artifact_is_active(source_record_artifact_uuid) FROM maintenance.temporal_measurement_item WHERE measurement_item_uuid='f7170000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T76',(SELECT precision='day' FROM maintenance.temporal_measurement_item_timepoint WHERE measurement_item_timepoint_uuid='f7180000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T77',(SELECT lower_bound_at<>upper_bound_at FROM maintenance.temporal_measurement_item_timepoint WHERE measurement_item_timepoint_uuid='f7180000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T78',(SELECT latency_kind='oes_detection' FROM maintenance.temporal_measurement_item_latency('f7170000-0000-0000-0000-000000000001','create_date')));
SELECT pg_temp.tno_assert('TNO-T79',(SELECT calculator_version='oes.temporal_latency/0.1' FROM maintenance.temporal_measurement_item_latency('f7170000-0000-0000-0000-000000000001','create_date')));
SELECT pg_temp.tno_assert('TNO-T80',(SELECT source_class='bibliographic' FROM maintenance.temporal_observation_source WHERE observation_source_uuid='f7110000-0000-0000-0000-000000000001'));

-- T81–T90: anti-laundering / isolation / no real case seed
SELECT pg_temp.tno_assert('TNO-T81',NOT EXISTS(SELECT 1 FROM maintenance.temporal_observation_plan WHERE target_product_version_uuid='81000000-0000-0000-0000-000000000701'));
SELECT pg_temp.tno_assert('TNO-T82',NOT EXISTS(SELECT 1 FROM maintenance.temporal_observation_authority WHERE actor ILIKE '%OES_PROJECT_OWNER%'));
SELECT pg_temp.tno_assert('TNO-T83',NOT EXISTS(SELECT 1 FROM maintenance.temporal_observation_source WHERE source_code IN ('PUBMED','CLINICALTRIALS_GOV','BVS_LILACS')));
SELECT pg_temp.tno_assert('TNO-T84',NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name LIKE 'temporal_%' AND column_name LIKE '%cadence%'));
SELECT pg_temp.tno_assert('TNO-T85',NOT EXISTS(
  SELECT 1 FROM information_schema.columns
  WHERE table_schema='maintenance'
    AND table_name IN (
      'temporal_observation_plan','temporal_observation_source','temporal_observation_epoch',
      'temporal_observation_epoch_source','temporal_observation_authority',
      'temporal_measurement_opportunity','temporal_measurement_event',
      'temporal_measurement_opportunity_resolution','temporal_measurement_item',
      'temporal_measurement_item_timepoint','temporal_measurement_event_artifact',
      'temporal_observation_deviation'
    )
    AND (column_name='sla' OR column_name LIKE 'sla\_%' ESCAPE '\')
));
SELECT pg_temp.tno_assert('TNO-T86',NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name LIKE 'temporal_%' AND column_name LIKE '%overdue%'));
SELECT pg_temp.tno_assert('TNO-T87',NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name LIKE 'temporal_%' AND column_name LIKE '%breach%'));
SELECT pg_temp.tno_assert('TNO-T88',(SELECT maintenance_level='M1' FROM investigation.investigation_version WHERE version_uuid='e5100000-0000-0000-0000-000000000002'));
SELECT pg_temp.tno_assert('TNO-T89',(SELECT count(*)=0 FROM maintenance.cadence_observation WHERE cadence_observation_uuid::text LIKE 'f7%'));
SELECT pg_temp.tno_assert('TNO-T90',NOT EXISTS(
  SELECT 1
  FROM pg_constraint con
  JOIN pg_class src ON src.oid=con.conrelid
  JOIN pg_namespace ns ON ns.oid=src.relnamespace
  JOIN pg_class ref ON ref.oid=con.confrelid
  JOIN pg_namespace rns ON rns.oid=ref.relnamespace
  WHERE con.contype='f'
    AND ns.nspname='maintenance'
    AND src.relname IN (
      'temporal_observation_plan','temporal_observation_source','temporal_observation_epoch',
      'temporal_observation_epoch_source','temporal_observation_authority',
      'temporal_measurement_opportunity','temporal_measurement_event',
      'temporal_measurement_opportunity_resolution','temporal_measurement_item',
      'temporal_measurement_item_timepoint','temporal_measurement_event_artifact',
      'temporal_observation_deviation'
    )
    AND rns.nspname='maintenance'
    AND ref.relname='update_signal'
));

-- T91–T100: CP119 hardening
SELECT pg_temp.tno_assert('TNO-T91',NOT maintenance.temporal_measurement_schedule_payload_is_valid(
'{"schema":"oes.temporal_opportunity_set/0.1","non_normative":true,"schedule_kind":"finite_opportunity_set","rationale":"x","opportunities":[{"opportunity_no":1,"planned_for":"2026-10-08T12:00:00+00:00"},{"opportunity_no":3,"planned_for":"2026-10-09T12:00:00+00:00"}]}'::jsonb));
SELECT pg_temp.tno_assert('TNO-T92',NOT maintenance.temporal_measurement_schedule_payload_is_valid(
'{"schema":"oes.temporal_opportunity_set/0.1","non_normative":true,"schedule_kind":"finite_opportunity_set","rationale":"x","opportunities":[{"opportunity_no":1,"planned_for":"2026-10-08T12:00:00"}]}'::jsonb));
DO $$ BEGIN
  BEGIN INSERT INTO maintenance.temporal_measurement_opportunity(measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,opportunity_origin) VALUES('f7140000-0000-0000-0000-000000000093','f7130000-0000-0000-0000-000000000001',3,TIMESTAMPTZ '2026-10-09 13:00+00','frozen_opportunity_set'); RAISE EXCEPTION 'TNO-T93 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T93 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T93 PASS';
END $$;
SELECT pg_temp.tno_assert('TNO-T94',maintenance.temporal_epoch_opportunity_set_matches_schedule('f7130000-0000-0000-0000-000000000001'));
DO $$ BEGIN
  BEGIN INSERT INTO maintenance.temporal_measurement_opportunity(measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,opportunity_origin) VALUES('f7140000-0000-0000-0000-000000000095','f7130000-0000-0000-0000-000000000001',2,TIMESTAMPTZ '2026-10-09 11:00+00','frozen_opportunity_set'); RAISE EXCEPTION 'TNO-T95 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T95 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T95 PASS';
END $$;
SELECT pg_temp.tno_assert('TNO-T96',(SELECT decided_at>=maintenance.temporal_observation_design_frozen_at(observation_epoch_uuid) FROM maintenance.temporal_observation_authority WHERE observation_authority_uuid='f7150000-0000-0000-0000-000000000001'));
DO $$ BEGIN
  BEGIN INSERT INTO maintenance.temporal_measurement_opportunity(measurement_opportunity_uuid,epoch_source_uuid,opportunity_no,planned_for,opportunity_origin) VALUES('f7140000-0000-0000-0000-000000000097','f7130000-0000-0000-0000-000000000001',1,TIMESTAMPTZ '2026-10-08 12:00+00','frozen_opportunity_set'); RAISE EXCEPTION 'TNO-T97 expected failure'; EXCEPTION WHEN others THEN IF SQLERRM='TNO-T97 expected failure' THEN RAISE; END IF; END;
  RAISE NOTICE 'TNO-T97 PASS';
END $$;
SELECT pg_temp.tno_assert('TNO-T98',(SELECT schedule_definition_artifact_uuid IS NOT NULL AND measurement_schedule_payload->>'schema'='oes.temporal_opportunity_set/0.1' FROM maintenance.temporal_observation_epoch_source WHERE epoch_source_uuid='f7130000-0000-0000-0000-000000000001'));
SELECT pg_temp.tno_assert('TNO-T99',(SELECT count(*)=1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_observation_epoch_source'::regclass AND tgname='tr_temporal_epoch_source_immutable' AND NOT tgisinternal));
SELECT pg_temp.tno_assert('TNO-T100',(SELECT count(*)=2 FROM maintenance.temporal_measurement_opportunity WHERE epoch_source_uuid='f7130000-0000-0000-0000-000000000001'));

SELECT 'F4-TNO-T01-T100 PASS' AS result;
