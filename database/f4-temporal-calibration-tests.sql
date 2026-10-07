-- F4-TCAL-PH-T01–T230 — Temporal calibration prerequisites physical contract
-- Synthetic-only validation. No normative temporal values are created.
BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.assert_true(cond boolean,label text)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  IF cond IS DISTINCT FROM true THEN RAISE EXCEPTION '% FAIL',label; END IF;
  RAISE NOTICE '% PASS',label;
END
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.expect_error(stmt text,label text)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  BEGIN
    EXECUTE stmt;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '% PASS',label;
    RETURN;
  END;
  RAISE EXCEPTION '% FAIL — expected error',label;
END
$fn$;

-- T001 — table temporal_contract_grandfathered_object exists
SELECT pg_temp.assert_true((to_regclass('maintenance.temporal_contract_grandfathered_object') IS NOT NULL),'F4-TCAL-PH-T001');

-- T002 — table temporal_calibration_dossier exists
SELECT pg_temp.assert_true((to_regclass('maintenance.temporal_calibration_dossier') IS NOT NULL),'F4-TCAL-PH-T002');

-- T003 — table temporal_calibration_authority exists
SELECT pg_temp.assert_true((to_regclass('maintenance.temporal_calibration_authority') IS NOT NULL),'F4-TCAL-PH-T003');

-- T004 — table temporal_calibration_basis exists
SELECT pg_temp.assert_true((to_regclass('maintenance.temporal_calibration_basis') IS NOT NULL),'F4-TCAL-PH-T004');

-- T005 — table temporal_calibration_candidate exists
SELECT pg_temp.assert_true((to_regclass('maintenance.temporal_calibration_candidate') IS NOT NULL),'F4-TCAL-PH-T005');

-- T006 — table temporal_calibration_evaluation exists
SELECT pg_temp.assert_true((to_regclass('maintenance.temporal_calibration_evaluation') IS NOT NULL),'F4-TCAL-PH-T006');

-- T007 — table cadence_contract exists
SELECT pg_temp.assert_true((to_regclass('maintenance.cadence_contract') IS NOT NULL),'F4-TCAL-PH-T007');

-- T008 — table cadence_obligation exists
SELECT pg_temp.assert_true((to_regclass('maintenance.cadence_obligation') IS NOT NULL),'F4-TCAL-PH-T008');

-- T009 — table cadence_observation exists
SELECT pg_temp.assert_true((to_regclass('maintenance.cadence_observation') IS NOT NULL),'F4-TCAL-PH-T009');

-- T010 — table fixed_deadline_source exists
SELECT pg_temp.assert_true((to_regclass('maintenance.fixed_deadline_source') IS NOT NULL),'F4-TCAL-PH-T010');

-- T011 — column temporal_calibration_dossier.scope_type exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='scope_type')),'F4-TCAL-PH-T011');

-- T012 — column temporal_calibration_dossier.calibration_kind exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='calibration_kind')),'F4-TCAL-PH-T012');

-- T013 — column temporal_calibration_dossier.target_product_version_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='target_product_version_uuid')),'F4-TCAL-PH-T013');

-- T014 — column temporal_calibration_dossier.target_investigation_version_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='target_investigation_version_uuid')),'F4-TCAL-PH-T014');

-- T015 — column temporal_calibration_dossier.update_risk_profile_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='update_risk_profile_uuid')),'F4-TCAL-PH-T015');

-- T016 — column temporal_calibration_dossier.decision_status exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='decision_status')),'F4-TCAL-PH-T016');

-- T017 — column temporal_calibration_dossier.decided_at exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='decided_at')),'F4-TCAL-PH-T017');

-- T018 — column temporal_calibration_dossier.decision_recorded_by exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='decision_recorded_by')),'F4-TCAL-PH-T018');

-- T019 — column temporal_calibration_dossier.decision_actor_type exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='decision_actor_type')),'F4-TCAL-PH-T019');

-- T020 — column temporal_calibration_dossier.record_status exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_dossier' AND column_name='record_status')),'F4-TCAL-PH-T020');

-- T021 — column temporal_calibration_authority.authority_domain exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_authority' AND column_name='authority_domain')),'F4-TCAL-PH-T021');

-- T022 — column temporal_calibration_authority.actor_type exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_authority' AND column_name='actor_type')),'F4-TCAL-PH-T022');

-- T023 — column temporal_calibration_authority.verification_status exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_authority' AND column_name='verification_status')),'F4-TCAL-PH-T023');

-- T024 — column temporal_calibration_authority.verified_by exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_authority' AND column_name='verified_by')),'F4-TCAL-PH-T024');

-- T025 — column temporal_calibration_authority.rationale exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_authority' AND column_name='rationale')),'F4-TCAL-PH-T025');

-- T026 — column temporal_calibration_candidate.candidate_no exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_candidate' AND column_name='candidate_no')),'F4-TCAL-PH-T026');

-- T027 — column temporal_calibration_candidate.candidate_kind exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_candidate' AND column_name='candidate_kind')),'F4-TCAL-PH-T027');

-- T028 — column temporal_calibration_candidate.candidate_payload exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_candidate' AND column_name='candidate_payload')),'F4-TCAL-PH-T028');

-- T029 — column temporal_calibration_candidate.disposition exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_candidate' AND column_name='disposition')),'F4-TCAL-PH-T029');

-- T030 — column temporal_calibration_candidate.rationale exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='temporal_calibration_candidate' AND column_name='rationale')),'F4-TCAL-PH-T030');

-- T031 — column cadence_contract.temporal_calibration_dossier_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_contract' AND column_name='temporal_calibration_dossier_uuid')),'F4-TCAL-PH-T031');

-- T032 — column cadence_contract.cadence_mode exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_contract' AND column_name='cadence_mode')),'F4-TCAL-PH-T032');

-- T033 — column cadence_contract.governing_monitor_product_version_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_contract' AND column_name='governing_monitor_product_version_uuid')),'F4-TCAL-PH-T033');

-- T034 — column cadence_contract.effective_at exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_contract' AND column_name='effective_at')),'F4-TCAL-PH-T034');

-- T035 — column cadence_contract.record_status exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_contract' AND column_name='record_status')),'F4-TCAL-PH-T035');

-- T036 — column cadence_obligation.scope_type exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='scope_type')),'F4-TCAL-PH-T036');

-- T037 — column cadence_obligation.timing_mode exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='timing_mode')),'F4-TCAL-PH-T037');

-- T038 — column cadence_obligation.fixed_elapsed_interval exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='fixed_elapsed_interval')),'F4-TCAL-PH-T038');

-- T039 — column cadence_obligation.recurrence_count exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='recurrence_count')),'F4-TCAL-PH-T039');

-- T040 — column cadence_obligation.recurrence_unit exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='recurrence_unit')),'F4-TCAL-PH-T040');

-- T041 — column cadence_obligation.month_roll_policy exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='month_roll_policy')),'F4-TCAL-PH-T041');

-- T042 — column cadence_obligation.anchor_type exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='anchor_type')),'F4-TCAL-PH-T042');

-- T043 — column cadence_obligation.timezone_name exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='timezone_name')),'F4-TCAL-PH-T043');

-- T044 — column cadence_obligation.dst_resolution_policy exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='dst_resolution_policy')),'F4-TCAL-PH-T044');

-- T045 — column cadence_obligation.satisfaction_event_type exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_obligation' AND column_name='satisfaction_event_type')),'F4-TCAL-PH-T045');

-- T046 — column cadence_observation.occurrence_no exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='occurrence_no')),'F4-TCAL-PH-T046');

-- T047 — column cadence_observation.observed_at exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='observed_at')),'F4-TCAL-PH-T047');

-- T048 — column cadence_observation.scheduled_due_at exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='scheduled_due_at')),'F4-TCAL-PH-T048');

-- T049 — column cadence_observation.due_calculation_payload exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='due_calculation_payload')),'F4-TCAL-PH-T049');

-- T050 — column cadence_observation.monitor_cycle_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='monitor_cycle_uuid')),'F4-TCAL-PH-T050');

-- T051 — column cadence_observation.search_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='search_uuid')),'F4-TCAL-PH-T051');

-- T052 — column cadence_observation.update_signal_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='update_signal_uuid')),'F4-TCAL-PH-T052');

-- T053 — column cadence_observation.artifact_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='cadence_observation' AND column_name='artifact_uuid')),'F4-TCAL-PH-T053');

-- T054 — column update_policy.cadence_contract_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='update_policy' AND column_name='cadence_contract_uuid')),'F4-TCAL-PH-T054');

-- T055 — column sla_calendar_version.temporal_calibration_dossier_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='sla_calendar_version' AND column_name='temporal_calibration_dossier_uuid')),'F4-TCAL-PH-T055');

-- T056 — column sla_rule.temporal_calibration_dossier_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='sla_rule' AND column_name='temporal_calibration_dossier_uuid')),'F4-TCAL-PH-T056');

-- T057 — column sla_rule.fixed_deadline_source_uuid exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='sla_rule' AND column_name='fixed_deadline_source_uuid')),'F4-TCAL-PH-T057');

-- T058 — column sla_instance.due_calculation_payload exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='sla_instance' AND column_name='due_calculation_payload')),'F4-TCAL-PH-T058');

-- T059 — column sla_pause.due_extension_eligible exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='sla_pause' AND column_name='due_extension_eligible')),'F4-TCAL-PH-T059');

-- T060 — column sla_pause.accountable_pause_seconds exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='maintenance' AND table_name='sla_pause' AND column_name='accountable_pause_seconds')),'F4-TCAL-PH-T060');

-- T061 — function temporal_object_is_grandfathered(text,uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.temporal_object_is_grandfathered(text,uuid)') IS NOT NULL),'F4-TCAL-PH-T061');

-- T062 — function temporal_candidate_payload_is_valid(text,jsonb) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.temporal_candidate_payload_is_valid(text,jsonb)') IS NOT NULL),'F4-TCAL-PH-T062');

-- T063 — function temporal_fixed_interval_is_valid(interval) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.temporal_fixed_interval_is_valid(interval)') IS NOT NULL),'F4-TCAL-PH-T063');

-- T064 — function cadence_occurrence_due_at(uuid,integer) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.cadence_occurrence_due_at(uuid,integer)') IS NOT NULL),'F4-TCAL-PH-T064');

-- T065 — function cadence_contract_snapshot(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.cadence_contract_snapshot(uuid)') IS NOT NULL),'F4-TCAL-PH-T065');

-- T066 — function cadence_obligation_scope_is_valid(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.cadence_obligation_scope_is_valid(uuid)') IS NOT NULL),'F4-TCAL-PH-T066');

-- T067 — function sla_rule_filter_domains_are_valid(text,text,text) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_rule_filter_domains_are_valid(text,text,text)') IS NOT NULL),'F4-TCAL-PH-T067');

-- T068 — function sla_rule_filters_are_causally_valid(text,text,text,text) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_rule_filters_are_causally_valid(text,text,text,text)') IS NOT NULL),'F4-TCAL-PH-T068');

-- T069 — function sla_pause_policy_is_valid(boolean,jsonb) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_pause_policy_is_valid(boolean,jsonb)') IS NOT NULL),'F4-TCAL-PH-T069');

-- T070 — function sla_warning_policy_is_valid(jsonb,interval) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_warning_policy_is_valid(jsonb,interval)') IS NOT NULL),'F4-TCAL-PH-T070');

-- T071 — function sla_breach_policy_is_valid(jsonb) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_breach_policy_is_valid(jsonb)') IS NOT NULL),'F4-TCAL-PH-T071');

-- T072 — function sla_escalation_policy_is_valid(jsonb) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_escalation_policy_is_valid(jsonb)') IS NOT NULL),'F4-TCAL-PH-T072');

-- T073 — function sla_calendar_payload_is_valid(jsonb,jsonb) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_calendar_payload_is_valid(jsonb,jsonb)') IS NOT NULL),'F4-TCAL-PH-T073');

-- T074 — function sla_calendar_open_intervals(uuid,date) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_calendar_open_intervals(uuid,date)') IS NOT NULL),'F4-TCAL-PH-T074');

-- T075 — function sla_calendar_open_seconds_between(uuid,timestamp with time zone,timestamp with time zone) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_calendar_open_seconds_between(uuid,timestamp with time zone,timestamp with time zone)') IS NOT NULL),'F4-TCAL-PH-T075');

-- T076 — function sla_calendar_add_open_seconds(uuid,timestamp with time zone,numeric) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_calendar_add_open_seconds(uuid,timestamp with time zone,numeric)') IS NOT NULL),'F4-TCAL-PH-T076');

-- T077 — function sla_calendar_subtract_open_seconds(uuid,timestamp with time zone,numeric) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_calendar_subtract_open_seconds(uuid,timestamp with time zone,numeric)') IS NOT NULL),'F4-TCAL-PH-T077');

-- T078 — function fixed_deadline_source_snapshot(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.fixed_deadline_source_snapshot(uuid)') IS NOT NULL),'F4-TCAL-PH-T078');

-- T079 — function sla_calendar_calibration_snapshot(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_calendar_calibration_snapshot(uuid)') IS NOT NULL),'F4-TCAL-PH-T079');

-- T080 — function sla_rule_calibration_snapshot(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_rule_calibration_snapshot(uuid)') IS NOT NULL),'F4-TCAL-PH-T080');

-- T081 — function sla_rule_effective_until(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_rule_effective_until(uuid)') IS NOT NULL),'F4-TCAL-PH-T081');

-- T082 — function sla_raw_causal_start_at(uuid,text,uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_raw_causal_start_at(uuid,text,uuid)') IS NOT NULL),'F4-TCAL-PH-T082');

-- T083 — function sla_context_priority_at(uuid,timestamp with time zone) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_context_priority_at(uuid,timestamp with time zone)') IS NOT NULL),'F4-TCAL-PH-T083');

-- T084 — function sla_rule_matches_context(uuid,uuid,timestamp with time zone) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_rule_matches_context(uuid,uuid,timestamp with time zone)') IS NOT NULL),'F4-TCAL-PH-T084');

-- T085 — function resolve_sla_rule(uuid,text,uuid,text) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.resolve_sla_rule(uuid,text,uuid,text)') IS NOT NULL),'F4-TCAL-PH-T085');

-- T086 — function sla_rule_snapshot(uuid,uuid,timestamp with time zone,jsonb) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_rule_snapshot(uuid,uuid,timestamp with time zone,jsonb)') IS NOT NULL),'F4-TCAL-PH-T086');

-- T087 — function sla_due_calculation_payload(uuid,uuid,timestamp with time zone,timestamp with time zone,timestamp with time zone) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_due_calculation_payload(uuid,uuid,timestamp with time zone,timestamp with time zone,timestamp with time zone)') IS NOT NULL),'F4-TCAL-PH-T087');

-- T088 — function sla_nominal_due_at(uuid,timestamp with time zone) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_nominal_due_at(uuid,timestamp with time zone)') IS NOT NULL),'F4-TCAL-PH-T088');

-- T089 — function sla_effective_due_at(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_effective_due_at(uuid)') IS NOT NULL),'F4-TCAL-PH-T089');

-- T090 — function sla_warning_at(uuid) exists
SELECT pg_temp.assert_true((to_regprocedure('maintenance.sla_warning_at(uuid)') IS NOT NULL),'F4-TCAL-PH-T090');

-- T091 — trigger tr_temporal_calibration_dossier_complete exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_calibration_dossier'::regclass AND tgname='tr_temporal_calibration_dossier_complete' AND NOT tgisinternal)),'F4-TCAL-PH-T091');

-- T092 — trigger tr_temporal_calibration_dossier_immutable exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_calibration_dossier'::regclass AND tgname='tr_temporal_calibration_dossier_immutable' AND NOT tgisinternal)),'F4-TCAL-PH-T092');

-- T093 — trigger tr_temporal_calibration_candidate exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_calibration_candidate'::regclass AND tgname='tr_temporal_calibration_candidate' AND NOT tgisinternal)),'F4-TCAL-PH-T093');

-- T094 — trigger tr_temporal_calibration_authority_immutable exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_calibration_authority'::regclass AND tgname='tr_temporal_calibration_authority_immutable' AND NOT tgisinternal)),'F4-TCAL-PH-T094');

-- T095 — trigger tr_temporal_calibration_basis_immutable exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_calibration_basis'::regclass AND tgname='tr_temporal_calibration_basis_immutable' AND NOT tgisinternal)),'F4-TCAL-PH-T095');

-- T096 — trigger tr_temporal_calibration_candidate_immutable exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_calibration_candidate'::regclass AND tgname='tr_temporal_calibration_candidate_immutable' AND NOT tgisinternal)),'F4-TCAL-PH-T096');

-- T097 — trigger tr_temporal_calibration_evaluation_immutable exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.temporal_calibration_evaluation'::regclass AND tgname='tr_temporal_calibration_evaluation_immutable' AND NOT tgisinternal)),'F4-TCAL-PH-T097');

-- T098 — trigger tr_cadence_contract_consistency exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.cadence_contract'::regclass AND tgname='tr_cadence_contract_consistency' AND NOT tgisinternal)),'F4-TCAL-PH-T098');

-- T099 — trigger tr_cadence_contract_complete exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.cadence_contract'::regclass AND tgname='tr_cadence_contract_complete' AND NOT tgisinternal)),'F4-TCAL-PH-T099');

-- T100 — trigger tr_cadence_obligation_scope exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.cadence_obligation'::regclass AND tgname='tr_cadence_obligation_scope' AND NOT tgisinternal)),'F4-TCAL-PH-T100');

-- T101 — trigger tr_cadence_observation exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.cadence_observation'::regclass AND tgname='tr_cadence_observation' AND NOT tgisinternal)),'F4-TCAL-PH-T101');

-- T102 — trigger tr_update_policy_temporal_v01 exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.update_policy'::regclass AND tgname='tr_update_policy_temporal_v01' AND NOT tgisinternal)),'F4-TCAL-PH-T102');

-- T103 — trigger tr_sla_calendar_v01 exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.sla_calendar_version'::regclass AND tgname='tr_sla_calendar_v01' AND NOT tgisinternal)),'F4-TCAL-PH-T103');

-- T104 — trigger tr_sla_rule_v01 exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.sla_rule'::regclass AND tgname='tr_sla_rule_v01' AND NOT tgisinternal)),'F4-TCAL-PH-T104');

-- T105 — trigger tr_sla_instance_temporal_v01 exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.sla_instance'::regclass AND tgname='tr_sla_instance_temporal_v01' AND NOT tgisinternal)),'F4-TCAL-PH-T105');

-- T106 — trigger tr_sla_pause_temporal_v01 exists
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid='maintenance.sla_pause'::regclass AND tgname='tr_sla_pause_temporal_v01' AND NOT tgisinternal)),'F4-TCAL-PH-T106');

-- T107 — v0.1 epoch
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM maintenance.contract_epoch WHERE contract_code='TEMPORAL_CALIBRATION_V01' AND schema_version='0.1' AND migration_id='032')),'F4-TCAL-PH-T107');

-- T108 — nine approved dossiers
SELECT pg_temp.assert_true(((SELECT count(*)=9 FROM maintenance.temporal_calibration_dossier WHERE decision_status='approved_for_normative_activation')),'F4-TCAL-PH-T108');

-- T109 — two cadence dossiers
SELECT pg_temp.assert_true(((SELECT count(*)=2 FROM maintenance.temporal_calibration_dossier WHERE calibration_kind='cadence' AND decision_status='approved_for_normative_activation')),'F4-TCAL-PH-T109');

-- T110 — six SLA dossiers
SELECT pg_temp.assert_true(((SELECT count(*)=6 FROM maintenance.temporal_calibration_dossier WHERE calibration_kind='sla_rule' AND decision_status='approved_for_normative_activation')),'F4-TCAL-PH-T110');

-- T111 — one calendar dossier
SELECT pg_temp.assert_true(((SELECT count(*)=1 FROM maintenance.temporal_calibration_dossier WHERE calibration_kind='sla_calendar' AND decision_status='approved_for_normative_activation')),'F4-TCAL-PH-T111');

-- T112 — nine selected candidates
SELECT pg_temp.assert_true(((SELECT count(*)=9 FROM maintenance.temporal_calibration_candidate WHERE disposition='selected')),'F4-TCAL-PH-T112');

-- T113 — nine capacity analyses
SELECT pg_temp.assert_true(((SELECT count(*)=9 FROM maintenance.temporal_calibration_evaluation WHERE evaluation_type='capacity_analysis' AND result_status='acceptable')),'F4-TCAL-PH-T113');

-- T114 — nine synthetic replays
SELECT pg_temp.assert_true(((SELECT count(*)=9 FROM maintenance.temporal_calibration_evaluation WHERE evaluation_type='historical_replay' AND result_status='acceptable')),'F4-TCAL-PH-T114');

-- T115 — no AI final authority
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.temporal_calibration_authority WHERE actor_type IN ('system','ai_system'))),'F4-TCAL-PH-T115');

-- T116 — two cadence contracts
SELECT pg_temp.assert_true(((SELECT count(*)=2 FROM maintenance.cadence_contract WHERE record_status='active')),'F4-TCAL-PH-T116');

-- T117 — two cadence obligations
SELECT pg_temp.assert_true(((SELECT count(*)=2 FROM maintenance.cadence_obligation)),'F4-TCAL-PH-T117');

-- T118 — no fabricated cadence observation
SELECT pg_temp.assert_true(((SELECT count(*)=0 FROM maintenance.cadence_observation)),'F4-TCAL-PH-T118');

-- T119 — two bound policies
SELECT pg_temp.assert_true(((SELECT count(*)=2 FROM maintenance.update_policy WHERE cadence_contract_uuid IS NOT NULL)),'F4-TCAL-PH-T119');

-- T120 — no unbound non-none policy
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.update_policy WHERE cadence_mode<>'none' AND cadence_contract_uuid IS NULL)),'F4-TCAL-PH-T120');

-- T121 — no post-032 M3 policy
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.update_policy WHERE effective_maintenance_level='M3' AND NOT maintenance.temporal_object_is_grandfathered('update_policy',update_policy_uuid))),'F4-TCAL-PH-T121');

-- T122 — policy1 cadence snapshot
SELECT pg_temp.assert_true(((SELECT cadence_policy_payload=maintenance.cadence_contract_snapshot(cadence_contract_uuid) FROM maintenance.update_policy WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001')),'F4-TCAL-PH-T122');

-- T123 — policy2 cadence snapshot
SELECT pg_temp.assert_true(((SELECT cadence_policy_payload=maintenance.cadence_contract_snapshot(cadence_contract_uuid) FROM maintenance.update_policy WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000002')),'F4-TCAL-PH-T123');

-- T124 — cadence1 candidate equality
SELECT pg_temp.assert_true(((SELECT candidate_payload=maintenance.cadence_contract_snapshot('fc640000-0000-0000-0000-000000000001') FROM maintenance.temporal_calibration_candidate WHERE temporal_calibration_dossier_uuid='fc610000-0000-0000-0000-000000000001' AND disposition='selected')),'F4-TCAL-PH-T124');

-- T125 — cadence2 candidate equality
SELECT pg_temp.assert_true(((SELECT candidate_payload=maintenance.cadence_contract_snapshot('fc640000-0000-0000-0000-000000000002') FROM maintenance.temporal_calibration_candidate WHERE temporal_calibration_dossier_uuid='fc610000-0000-0000-0000-000000000002' AND disposition='selected')),'F4-TCAL-PH-T125');

-- T126 — cadence1 first due
SELECT pg_temp.assert_true((maintenance.cadence_occurrence_due_at('fc650000-0000-0000-0000-000000000001',1)=TIMESTAMPTZ '2026-11-07 00:00:00+00'),'F4-TCAL-PH-T126');

-- T127 — cadence2 first due
SELECT pg_temp.assert_true((maintenance.cadence_occurrence_due_at('fc650000-0000-0000-0000-000000000002',1)=TIMESTAMPTZ '2026-11-07 00:01:00+00'),'F4-TCAL-PH-T127');

-- T128 — cadence1 scope valid
SELECT pg_temp.assert_true((maintenance.cadence_obligation_scope_is_valid('fc650000-0000-0000-0000-000000000001')),'F4-TCAL-PH-T128');

-- T129 — cadence2 scope valid
SELECT pg_temp.assert_true((maintenance.cadence_obligation_scope_is_valid('fc650000-0000-0000-0000-000000000002')),'F4-TCAL-PH-T129');

-- T130 — cadence1 no issues
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.cadence_contract_issues('fc640000-0000-0000-0000-000000000001'))),'F4-TCAL-PH-T130');

-- T131 — cadence2 no issues
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.cadence_contract_issues('fc640000-0000-0000-0000-000000000002'))),'F4-TCAL-PH-T131');

-- T132 — calibration product profile superseded
SELECT pg_temp.assert_true(((SELECT record_status='superseded' FROM maintenance.update_risk_profile WHERE update_risk_profile_uuid='fc600000-0000-0000-0000-000000000001')),'F4-TCAL-PH-T132');

-- T133 — calibration investigation profile superseded
SELECT pg_temp.assert_true(((SELECT record_status='superseded' FROM maintenance.update_risk_profile WHERE update_risk_profile_uuid='fc600000-0000-0000-0000-000000000002')),'F4-TCAL-PH-T133');

-- T134 — six calibrated SLA rules
SELECT pg_temp.assert_true(((SELECT count(*)=6 FROM maintenance.sla_rule WHERE temporal_calibration_dossier_uuid IS NOT NULL)),'F4-TCAL-PH-T134');

-- T135 — one calibrated calendar
SELECT pg_temp.assert_true(((SELECT count(*)=1 FROM maintenance.sla_calendar_version WHERE temporal_calibration_dossier_uuid IS NOT NULL)),'F4-TCAL-PH-T135');

-- T136 — calendar candidate equality
SELECT pg_temp.assert_true(((SELECT maintenance.sla_calendar_calibration_snapshot(c.sla_calendar_version_uuid)=x.candidate_payload FROM maintenance.sla_calendar_version c JOIN maintenance.temporal_calibration_candidate x ON x.temporal_calibration_dossier_uuid=c.temporal_calibration_dossier_uuid AND x.disposition='selected' WHERE c.sla_calendar_version_uuid='f5300000-0000-0000-0000-000000000001')),'F4-TCAL-PH-T136');

-- T137 — SLA candidate equalities
SELECT pg_temp.assert_true(((SELECT bool_and(maintenance.sla_rule_calibration_snapshot(r.sla_rule_uuid)=x.candidate_payload) FROM maintenance.sla_rule r JOIN maintenance.temporal_calibration_candidate x ON x.temporal_calibration_dossier_uuid=r.temporal_calibration_dossier_uuid AND x.disposition='selected' WHERE r.sla_rule_uuid::text LIKE 'f5400000-%')),'F4-TCAL-PH-T137');

-- T138 — five elapsed rules
SELECT pg_temp.assert_true(((SELECT count(*)=5 FROM maintenance.sla_rule WHERE rule_code LIKE 'fixture-sla%' AND time_basis='elapsed_time')),'F4-TCAL-PH-T138');

-- T139 — one business rule
SELECT pg_temp.assert_true(((SELECT count(*)=1 FROM maintenance.sla_rule WHERE rule_code LIKE 'fixture-sla%' AND time_basis='business_calendar')),'F4-TCAL-PH-T139');

-- T140 — SLA5 pause allowed
SELECT pg_temp.assert_true(((SELECT pause_allowed FROM maintenance.sla_rule WHERE sla_rule_uuid='f5400000-0000-0000-0000-000000000005')),'F4-TCAL-PH-T140');

-- T141 — SLA1 pause disallowed
SELECT pg_temp.assert_true(((SELECT NOT pause_allowed FROM maintenance.sla_rule WHERE sla_rule_uuid='f5400000-0000-0000-0000-000000000001')),'F4-TCAL-PH-T141');

-- T142 — SLA1 no issues
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.sla_rule_issues('f5400000-0000-0000-0000-000000000001'))),'F4-TCAL-PH-T142');

-- T143 — SLA5 no issues
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.sla_rule_issues('f5400000-0000-0000-0000-000000000005'))),'F4-TCAL-PH-T143');

-- T144 — calendar open hour
SELECT pg_temp.assert_true((maintenance.sla_calendar_open_seconds_between('f5300000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-07 11:00:00+00',TIMESTAMPTZ '2026-10-07 12:00:00+00')=3600),'F4-TCAL-PH-T144');

-- T145 — calendar add hour
SELECT pg_temp.assert_true((maintenance.sla_calendar_add_open_seconds('f5300000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-07 10:00:00+00',3600)=TIMESTAMPTZ '2026-10-07 12:00:00+00'),'F4-TCAL-PH-T145');

-- T146 — calendar subtract hour
SELECT pg_temp.assert_true((maintenance.sla_calendar_subtract_open_seconds('f5300000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-07 12:00:00+00',3600)=TIMESTAMPTZ '2026-10-07 11:00:00+00'),'F4-TCAL-PH-T146');

-- T147 — SLA1 nominal due
SELECT pg_temp.assert_true((maintenance.sla_nominal_due_at('f5400000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-07 00:30:00+00')=TIMESTAMPTZ '2026-10-07 02:30:00+00'),'F4-TCAL-PH-T147');

-- T148 — SLA5 nominal due
SELECT pg_temp.assert_true((maintenance.sla_nominal_due_at('f5400000-0000-0000-0000-000000000005',TIMESTAMPTZ '2026-10-07 00:45:00+00')=TIMESTAMPTZ '2026-10-08 18:00:00+00'),'F4-TCAL-PH-T148');

-- T149 — SLA5 effective due
SELECT pg_temp.assert_true((maintenance.sla_effective_due_at('f5600000-0000-0000-0000-000000000005')=TIMESTAMPTZ '2026-10-08 18:00:00+00'),'F4-TCAL-PH-T149');

-- T150 — closed-time pause zero accountable
SELECT pg_temp.assert_true(((SELECT due_extension_eligible AND accountable_pause_seconds=0 FROM maintenance.sla_pause WHERE sla_pause_uuid='f5700000-0000-0000-0000-000000000001')),'F4-TCAL-PH-T150');

-- T151 — SLA5 no warning
SELECT pg_temp.assert_true((maintenance.sla_warning_at('f5600000-0000-0000-0000-000000000005') IS NULL),'F4-TCAL-PH-T151');

-- T152 — SLA1 no future priority
SELECT pg_temp.assert_true(((SELECT start_priority_assessment_uuid IS NULL FROM maintenance.sla_instance WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000001')),'F4-TCAL-PH-T152');

-- T153 — SLA5 start priority
SELECT pg_temp.assert_true(((SELECT start_priority_assessment_uuid='f5100000-0000-0000-0000-000000000001' FROM maintenance.sla_instance WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005')),'F4-TCAL-PH-T153');

-- T154 — SLA5 profile snapshot
SELECT pg_temp.assert_true(((SELECT rule_snapshot_payload->>'update_risk_profile_uuid'='f6000000-0000-0000-0000-000000000001' FROM maintenance.sla_instance WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005')),'F4-TCAL-PH-T154');

-- T155 — SLA5 due schema
SELECT pg_temp.assert_true(((SELECT due_calculation_payload->>'schema_version'='oes.sla_due_calculation/0.1' FROM maintenance.sla_instance WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005')),'F4-TCAL-PH-T155');

-- T156 — SLA5 frozen due equality
SELECT pg_temp.assert_true(((SELECT (due_calculation_payload->>'nominal_due_at')::timestamptz=nominal_due_at FROM maintenance.sla_instance WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005')),'F4-TCAL-PH-T156');

-- T157 — resolver SLA1
SELECT pg_temp.assert_true(((SELECT resolution_status='selected' AND sla_rule_uuid='f5400000-0000-0000-0000-000000000001' FROM maintenance.resolve_sla_rule('f4100000-0000-0000-0000-000000000003','SLA1_DETECTION_TO_TRIAGE',NULL,'triage'))),'F4-TCAL-PH-T157');

-- T158 — resolver SLA2
SELECT pg_temp.assert_true(((SELECT resolution_status='selected' AND sla_rule_uuid='f5400000-0000-0000-0000-000000000002' FROM maintenance.resolve_sla_rule('f4100000-0000-0000-0000-000000000003','SLA2_TRIAGE_TO_MATERIALITY',NULL,'materiality'))),'F4-TCAL-PH-T158');

-- T159 — resolver SLA3
SELECT pg_temp.assert_true(((SELECT resolution_status='selected' AND sla_rule_uuid='f5400000-0000-0000-0000-000000000003' FROM maintenance.resolve_sla_rule('f4100000-0000-0000-0000-000000000003','SLA3_MATERIALITY_TO_DECISION',NULL,'update_decision'))),'F4-TCAL-PH-T159');

-- T160 — resolver SLA4
SELECT pg_temp.assert_true(((SELECT resolution_status='selected' AND sla_rule_uuid='f5400000-0000-0000-0000-000000000004' FROM maintenance.resolve_sla_rule('f4100000-0000-0000-0000-000000000003','SLA4_DECISION_TO_WORKFLOW_START','f5500000-0000-0000-0000-000000000001','workflow_started'))),'F4-TCAL-PH-T160');

-- T161 — resolver SLA5
SELECT pg_temp.assert_true(((SELECT resolution_status='selected' AND sla_rule_uuid='f5400000-0000-0000-0000-000000000005' FROM maintenance.resolve_sla_rule('f4100000-0000-0000-0000-000000000003','SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION','f5500000-0000-0000-0000-000000000001','scientific_completed'))),'F4-TCAL-PH-T161');

-- T162 — priority absent at detection
SELECT pg_temp.assert_true((maintenance.sla_context_priority_at('f4100000-0000-0000-0000-000000000003',TIMESTAMPTZ '2026-10-07 00:30:00+00') IS NULL),'F4-TCAL-PH-T162');

-- T163 — priority present at workflow start
SELECT pg_temp.assert_true((maintenance.sla_context_priority_at('f4100000-0000-0000-0000-000000000003',TIMESTAMPTZ '2026-10-07 00:45:00+00')='f5100000-0000-0000-0000-000000000001'),'F4-TCAL-PH-T163');

-- T164 — raw SLA1 start
SELECT pg_temp.assert_true((maintenance.sla_raw_causal_start_at('f4100000-0000-0000-0000-000000000003','SLA1_DETECTION_TO_TRIAGE',NULL)=TIMESTAMPTZ '2026-10-07 00:30:00+00'),'F4-TCAL-PH-T164');

-- T165 — raw SLA4 start
SELECT pg_temp.assert_true((maintenance.sla_raw_causal_start_at('f4100000-0000-0000-0000-000000000003','SLA4_DECISION_TO_WORKFLOW_START','f5500000-0000-0000-0000-000000000001')=TIMESTAMPTZ '2026-10-07 00:41:00+00'),'F4-TCAL-PH-T165');

-- T166 — policy1 temporal ready
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.temporal_operational_readiness('f4000000-0000-0000-0000-000000000001') WHERE severity IN ('error','blocker'))),'F4-TCAL-PH-T166');

-- T167 — policy2 temporal ready
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.temporal_operational_readiness('f4000000-0000-0000-0000-000000000002') WHERE severity IN ('error','blocker'))),'F4-TCAL-PH-T167');

-- T168 — M3 blocker at monitor
SELECT pg_temp.assert_true((EXISTS(SELECT 1 FROM product.evidence_monitor_publication_issues('e5100000-0000-0000-0000-000000000007') WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL' AND severity='error')),'F4-TCAL-PH-T168');

-- T169 — M3 monitor blocked
SELECT pg_temp.assert_true((NOT product.evidence_monitor_is_publishable('e5100000-0000-0000-0000-000000000007')),'F4-TCAL-PH-T169');

-- T170 — M2 monitor publishable
SELECT pg_temp.assert_true((product.evidence_monitor_is_publishable('e5100000-0000-0000-0000-000000000005')),'F4-TCAL-PH-T170');

-- T171 — fixed interval 1s valid
SELECT pg_temp.assert_true((maintenance.temporal_fixed_interval_is_valid(interval '1 second')),'F4-TCAL-PH-T171');

-- T172 — fixed interval day valid
SELECT pg_temp.assert_true((maintenance.temporal_fixed_interval_is_valid(interval '24 hours')),'F4-TCAL-PH-T172');

-- T173 — fixed interval month rejected
SELECT pg_temp.assert_true((NOT maintenance.temporal_fixed_interval_is_valid(interval '1 month')),'F4-TCAL-PH-T173');

-- T174 — fixed interval zero rejected
SELECT pg_temp.assert_true((NOT maintenance.temporal_fixed_interval_is_valid(interval '0')),'F4-TCAL-PH-T174');

-- T175 — filter domains valid
SELECT pg_temp.assert_true((maintenance.sla_rule_filter_domains_are_valid('new_evidence','observe','no_material_change')),'F4-TCAL-PH-T175');

-- T176 — bad trigger rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_rule_filter_domains_are_valid('bad',NULL,NULL)),'F4-TCAL-PH-T176');

-- T177 — bad decision rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_rule_filter_domains_are_valid(NULL,'bad',NULL)),'F4-TCAL-PH-T177');

-- T178 — bad materiality rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_rule_filter_domains_are_valid(NULL,NULL,'bad')),'F4-TCAL-PH-T178');

-- T179 — SLA1 empty causal filters
SELECT pg_temp.assert_true((maintenance.sla_rule_filters_are_causally_valid('SLA1_DETECTION_TO_TRIAGE',NULL,NULL,NULL)),'F4-TCAL-PH-T179');

-- T180 — SLA1 response future leakage rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_rule_filters_are_causally_valid('SLA1_DETECTION_TO_TRIAGE','standard',NULL,NULL)),'F4-TCAL-PH-T180');

-- T181 — SLA2 response filter allowed
SELECT pg_temp.assert_true((maintenance.sla_rule_filters_are_causally_valid('SLA2_TRIAGE_TO_MATERIALITY','standard',NULL,NULL)),'F4-TCAL-PH-T181');

-- T182 — SLA2 materiality future leakage rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_rule_filters_are_causally_valid('SLA2_TRIAGE_TO_MATERIALITY',NULL,'potentially_material',NULL)),'F4-TCAL-PH-T182');

-- T183 — SLA3 materiality allowed
SELECT pg_temp.assert_true((maintenance.sla_rule_filters_are_causally_valid('SLA3_MATERIALITY_TO_DECISION','standard','potentially_material',NULL)),'F4-TCAL-PH-T183');

-- T184 — SLA3 decision future leakage rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_rule_filters_are_causally_valid('SLA3_MATERIALITY_TO_DECISION',NULL,NULL,'observe')),'F4-TCAL-PH-T184');

-- T185 — SLA4 full context allowed
SELECT pg_temp.assert_true((maintenance.sla_rule_filters_are_causally_valid('SLA4_DECISION_TO_WORKFLOW_START','standard','potentially_material','scientific_update_incremental')),'F4-TCAL-PH-T185');

-- T186 — pause none valid
SELECT pg_temp.assert_true((maintenance.sla_pause_policy_is_valid(false,'{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}')),'F4-TCAL-PH-T186');

-- T187 — pause allowed needs reasons
SELECT pg_temp.assert_true((NOT maintenance.sla_pause_policy_is_valid(true,'{"schema_version":"oes.sla_pause_policy/0.1","mode":"none"}')),'F4-TCAL-PH-T187');

-- T188 — pause reason valid
SELECT pg_temp.assert_true((maintenance.sla_pause_policy_is_valid(true,'{"schema_version":"oes.sla_pause_policy/0.1","mode":"allowed_reasons","allowed_reason_codes":["external_dependency"]}')),'F4-TCAL-PH-T188');

-- T189 — warning none valid
SELECT pg_temp.assert_true((maintenance.sla_warning_policy_is_valid('{"schema_version":"oes.sla_warning_policy/0.1","mode":"none"}',interval '2 hours')),'F4-TCAL-PH-T189');

-- T190 — warning lead valid
SELECT pg_temp.assert_true((maintenance.sla_warning_policy_is_valid('{"schema_version":"oes.sla_warning_policy/0.1","mode":"lead_time","time_basis":"elapsed_time","lead_seconds":60}',interval '2 hours')),'F4-TCAL-PH-T190');

-- T191 — warning lead at due rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_warning_policy_is_valid('{"schema_version":"oes.sla_warning_policy/0.1","mode":"lead_time","time_basis":"elapsed_time","lead_seconds":7200}',interval '2 hours')),'F4-TCAL-PH-T191');

-- T192 — breach at due valid
SELECT pg_temp.assert_true((maintenance.sla_breach_policy_is_valid('{"schema_version":"oes.sla_breach_policy/0.1","mode":"at_effective_due"}')),'F4-TCAL-PH-T192');

-- T193 — bad breach mode rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_breach_policy_is_valid('{"schema_version":"oes.sla_breach_policy/0.1","mode":"late"}')),'F4-TCAL-PH-T193');

-- T194 — escalation none valid
SELECT pg_temp.assert_true((maintenance.sla_escalation_policy_is_valid('{"schema_version":"oes.sla_escalation_policy/0.1","mode":"none"}')),'F4-TCAL-PH-T194');

-- T195 — post breach candidate valid
SELECT pg_temp.assert_true((maintenance.sla_escalation_policy_is_valid('{"schema_version":"oes.sla_escalation_policy/0.1","mode":"post_breach_candidate","time_basis":"elapsed_time","after_breach_seconds":0,"reason_code":"operational_delay"}')),'F4-TCAL-PH-T195');

-- T196 — bad escalation reason rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_escalation_policy_is_valid('{"schema_version":"oes.sla_escalation_policy/0.1","mode":"post_breach_candidate","time_basis":"elapsed_time","after_breach_seconds":0,"reason_code":"bad"}')),'F4-TCAL-PH-T196');

-- T197 — cadence candidate valid
SELECT pg_temp.assert_true((maintenance.temporal_candidate_payload_is_valid('cadence',(SELECT candidate_payload FROM maintenance.temporal_calibration_candidate WHERE temporal_calibration_candidate_uuid='fc620000-0000-0000-0000-000000000001'))),'F4-TCAL-PH-T197');

-- T198 — SLA candidate valid
SELECT pg_temp.assert_true((maintenance.temporal_candidate_payload_is_valid('sla_rule',(SELECT candidate_payload FROM maintenance.temporal_calibration_candidate WHERE temporal_calibration_candidate_uuid='fc730000-0000-0000-0000-000000000001'))),'F4-TCAL-PH-T198');

-- T199 — calendar candidate valid
SELECT pg_temp.assert_true((maintenance.temporal_candidate_payload_is_valid('sla_calendar',(SELECT candidate_payload FROM maintenance.temporal_calibration_candidate WHERE temporal_calibration_candidate_uuid='fc710000-0000-0000-0000-000000000001'))),'F4-TCAL-PH-T199');

-- T200 — continuous cadence candidate rejected
SELECT pg_temp.assert_true((NOT maintenance.temporal_candidate_payload_is_valid('cadence','{"schema_version":"oes.cadence_candidate/0.1","cadence_mode":"continuous","effective_at":"2026-10-07T00:00:00Z","obligations":[]}'::jsonb)),'F4-TCAL-PH-T200');

-- T201 — cadence nested extra key rejected
SELECT pg_temp.assert_true((NOT maintenance.temporal_candidate_payload_is_valid('cadence','{"schema_version":"oes.cadence_candidate/0.1","cadence_mode":"periodic","effective_at":"2026-10-07T00:00:00Z","obligations":[{"obligation_code":"x","scope":{"type":"policy_aggregate","extra":1},"timing":{"mode":"calendar_recurrence","recurrence_count":1,"recurrence_unit":"month","month_roll_policy":"preserve_day_or_clamp_last_day"},"anchor":{"type":"policy_effective_at"},"grace_seconds":0,"satisfaction_event_type":"monitor_cycle_completed","timezone_name":"UTC","dst_resolution_policy":"shift_forward_to_first_valid"}]}'::jsonb)),'F4-TCAL-PH-T201');

-- T202 — SLA nested filter extra key rejected
SELECT pg_temp.assert_true((NOT maintenance.temporal_candidate_payload_is_valid('sla_rule','{"schema_version":"oes.sla_rule_candidate/0.1","clock_code":"SLA1_DETECTION_TO_TRIAGE","selection_precedence":1,"filters":{"extra":"x"},"endpoint_type":"triage","time_basis":"elapsed_time","target_duration_seconds":7200,"pause_policy":{},"warning_policy":{},"breach_policy":{},"escalation_policy":{},"effective_at":"2026-10-07T00:00:00Z"}'::jsonb)),'F4-TCAL-PH-T202');

-- T203 — calendar candidate missing keys rejected
SELECT pg_temp.assert_true((NOT maintenance.temporal_candidate_payload_is_valid('sla_calendar','{"schema_version":"oes.sla_calendar_candidate/0.1","calendar_key":"x"}'::jsonb)),'F4-TCAL-PH-T203');

-- T204 — unknown candidate kind rejected
SELECT pg_temp.assert_true((NOT maintenance.temporal_candidate_payload_is_valid('bad','{}'::jsonb)),'F4-TCAL-PH-T204');

-- T205 — fixture calendar structure valid
SELECT pg_temp.assert_true((maintenance.sla_calendar_payload_is_valid((SELECT weekly_schedule_payload FROM maintenance.sla_calendar_version WHERE sla_calendar_version_uuid='f5300000-0000-0000-0000-000000000001'),(SELECT exception_dates_payload FROM maintenance.sla_calendar_version WHERE sla_calendar_version_uuid='f5300000-0000-0000-0000-000000000001'))),'F4-TCAL-PH-T205');

-- T206 — calendar missing weekdays rejected
SELECT pg_temp.assert_true((NOT maintenance.sla_calendar_payload_is_valid('{"1":[]}'::jsonb,'[]'::jsonb)),'F4-TCAL-PH-T206');

-- T207 — closed Saturday zero seconds
SELECT pg_temp.assert_true((maintenance.sla_calendar_open_seconds_between('f5300000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-10 11:00:00+00',TIMESTAMPTZ '2026-10-10 12:00:00+00')=0),'F4-TCAL-PH-T207');

-- T208 — weekend add moves to Monday
SELECT pg_temp.assert_true((maintenance.sla_calendar_add_open_seconds('f5300000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-10 12:00:00+00',3600)=TIMESTAMPTZ '2026-10-12 12:00:00+00'),'F4-TCAL-PH-T208');

-- T209 — Monday open-hour subtraction is local-calendar correct
SELECT pg_temp.assert_true((maintenance.sla_calendar_subtract_open_seconds('f5300000-0000-0000-0000-000000000001',TIMESTAMPTZ '2026-10-12 12:00:00+00',3600)=TIMESTAMPTZ '2026-10-12 11:00:00+00'),'F4-TCAL-PH-T209');

-- T210 — active SLA lineage is open-ended
SELECT pg_temp.assert_true((maintenance.sla_rule_effective_until('f5400000-0000-0000-0000-000000000001') IS NULL),'F4-TCAL-PH-T210');

-- T211 — terminal dossier mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.temporal_calibration_dossier SET rationale='mutated' WHERE temporal_calibration_dossier_uuid='fc610000-0000-0000-0000-000000000001'$q$,'F4-TCAL-PH-T211');

-- T212 — authority mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.temporal_calibration_authority SET rationale='mutated' WHERE temporal_calibration_dossier_uuid='fc610000-0000-0000-0000-000000000001' AND authority_domain='scientific_methodological'$q$,'F4-TCAL-PH-T212');

-- T213 — candidate mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.temporal_calibration_candidate SET rationale='mutated' WHERE temporal_calibration_candidate_uuid='fc620000-0000-0000-0000-000000000001'$q$,'F4-TCAL-PH-T213');

-- T214 — evaluation mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.temporal_calibration_evaluation SET rationale='mutated' WHERE temporal_calibration_evaluation_uuid='fc630000-0000-0000-0000-000000000001'$q$,'F4-TCAL-PH-T214');

-- T215 — cadence contract mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.cadence_contract SET cadence_mode='hybrid' WHERE cadence_contract_uuid='fc640000-0000-0000-0000-000000000001'$q$,'F4-TCAL-PH-T215');

-- T216 — cadence obligation mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.cadence_obligation SET grace_interval=interval '1 hour' WHERE cadence_obligation_uuid='fc650000-0000-0000-0000-000000000001'$q$,'F4-TCAL-PH-T216');

-- T217 — policy cadence binding mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.update_policy SET cadence_contract_uuid=NULL WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'$q$,'F4-TCAL-PH-T217');

-- T218 — SLA rule mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.sla_rule SET target_duration=interval '3 hours' WHERE sla_rule_uuid='f5400000-0000-0000-0000-000000000001'$q$,'F4-TCAL-PH-T218');

-- T219 — SLA due snapshot mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.sla_instance SET due_calculation_payload='{}'::jsonb WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005'$q$,'F4-TCAL-PH-T219');

-- T220 — SLA start priority mutation rejected
SELECT pg_temp.expect_error($q$UPDATE maintenance.sla_instance SET start_priority_assessment_uuid=NULL WHERE sla_instance_uuid='f5600000-0000-0000-0000-000000000005'$q$,'F4-TCAL-PH-T220');

-- T221 — overlapping pause rejected
SELECT pg_temp.expect_error($q$INSERT INTO maintenance.sla_pause(sla_pause_uuid,sla_instance_uuid,reason_code,rationale,authorized_by,actor_type,authorized_at,started_at,ended_at,closed_by,closed_at,external_event_payload) VALUES('fd200000-0000-0000-0000-000000000001','f5600000-0000-0000-0000-000000000005','external_dependency','overlap test','fixture-owner','owner',TIMESTAMPTZ '2026-10-07 01:15:00+00',TIMESTAMPTZ '2026-10-07 01:15:00+00',TIMESTAMPTZ '2026-10-07 01:20:00+00','fixture-owner',TIMESTAMPTZ '2026-10-07 01:20:00+00','{}'::jsonb)$q$,'F4-TCAL-PH-T221');

-- T222 — undeclared cadence source rejected
SELECT pg_temp.expect_error($q$INSERT INTO maintenance.cadence_obligation(cadence_obligation_uuid,cadence_contract_uuid,obligation_code,scope_type,source_name,timing_mode,recurrence_count,recurrence_unit,month_roll_policy,anchor_type,timezone_name,dst_resolution_policy,grace_interval,satisfaction_event_type,effective_at) VALUES('fd200000-0000-0000-0000-000000000002','fc640000-0000-0000-0000-000000000001','bad-source','monitor_source_name','NotDeclared','calendar_recurrence',1,'month','preserve_day_or_clamp_last_day','policy_effective_at','UTC','shift_forward_to_first_valid',interval '0','monitor_cycle_completed',TIMESTAMPTZ '2026-10-07 00:00:00+00')$q$,'F4-TCAL-PH-T222');

-- T223 — unbound post-032 cadence policy rejected
SELECT pg_temp.expect_error($q$INSERT INTO maintenance.update_policy(update_policy_uuid,target_product_version_uuid,effective_maintenance_level,cadence_mode,effective_at,rationale,created_by,actor_type,record_status) VALUES('fd200000-0000-0000-0000-000000000003','e5100000-0000-0000-0000-000000000003','M1','event_driven',TIMESTAMPTZ '2026-10-07 03:00:00+00','unbound cadence','fixture-owner','owner','superseded')$q$,'F4-TCAL-PH-T223');

-- T224 — post-032 M3 policy rejected
SELECT pg_temp.expect_error($q$INSERT INTO maintenance.update_policy(update_policy_uuid,target_investigation_version_uuid,effective_maintenance_level,cadence_mode,governing_monitor_product_version_uuid,effective_at,rationale,created_by,actor_type,record_status) VALUES('fd200000-0000-0000-0000-000000000004','e5100000-0000-0000-0000-000000000002','M3','continuous','e5100000-0000-0000-0000-000000000007',TIMESTAMPTZ '2026-10-07 03:01:00+00','M3 blocked','fixture-owner','owner','superseded')$q$,'F4-TCAL-PH-T224');

-- T225 — no scheduler/notification infrastructure
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema='maintenance' AND table_name IN ('notification','notification_queue','scheduler','scheduled_task'))),'F4-TCAL-PH-T225');

-- T226 — no fixed deadline source fabricated
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.fixed_deadline_source)),'F4-TCAL-PH-T226');

-- T227 — no calibration basis fabricated
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.temporal_calibration_basis)),'F4-TCAL-PH-T227');

-- T228 — no continuous CadenceContract
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.cadence_contract WHERE cadence_mode='continuous')),'F4-TCAL-PH-T228');

-- T229 — no synthetic F4 object grandfathered
SELECT pg_temp.assert_true((NOT EXISTS(SELECT 1 FROM maintenance.temporal_contract_grandfathered_object WHERE object_uuid::text LIKE 'f4%' OR object_uuid::text LIKE 'fc%')),'F4-TCAL-PH-T229');

-- T230 — temporal infrastructure did not alter CurrencyState
SELECT pg_temp.assert_true(((SELECT currency_status='under_evaluation' FROM product.currency_state WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000003')),'F4-TCAL-PH-T230');

SELECT 'F4-TCAL-PH-T01–T230 PASS' AS f4_temporal_calibration_status;
ROLLBACK;
