-- Migration 032 fragment D — SLA resolver, instance/pause hardening, readiness

CREATE OR REPLACE FUNCTION maintenance.sla_rule_effective_until(p_rule uuid)
RETURNS timestamptz LANGUAGE sql STABLE AS $q$
SELECT min(n.effective_at)
FROM maintenance.sla_rule r
JOIN maintenance.sla_rule n
  ON n.supersedes_sla_rule_uuid=r.sla_rule_uuid
 AND n.update_policy_uuid=r.update_policy_uuid
 AND n.rule_code=r.rule_code
WHERE r.sla_rule_uuid=p_rule;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_raw_causal_start_at(
 p_signal uuid,p_clock text,p_round uuid DEFAULT NULL
)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $fn$
DECLARE t timestamptz;
BEGIN
 IF p_clock='SLA1_DETECTION_TO_TRIAGE' THEN
   SELECT detected_at INTO t FROM maintenance.update_signal WHERE update_signal_uuid=p_signal;
 ELSIF p_clock='SLA2_TRIAGE_TO_MATERIALITY' THEN
   SELECT triaged_at INTO t FROM maintenance.update_triage
    WHERE update_signal_uuid=p_signal AND authority_status='authoritative' AND record_status='active'
      AND disposition='accepted_for_materiality'
    ORDER BY triaged_at LIMIT 1;
 ELSIF p_clock='SLA3_MATERIALITY_TO_DECISION' THEN
   SELECT verified_at INTO t FROM maintenance.materiality_assessment
    WHERE update_signal_uuid=p_signal AND record_status='active'
      AND verification_status IN ('human_verified','human_consensus')
    ORDER BY verified_at LIMIT 1;
 ELSIF p_clock='SLA4_DECISION_TO_WORKFLOW_START' THEN
   SELECT GREATEST(decided_at,verified_at) INTO t FROM maintenance.update_decision
    WHERE update_signal_uuid=p_signal AND record_status='active'
      AND authority_status='authoritative'
      AND verification_status IN ('human_verified','human_consensus')
    ORDER BY GREATEST(decided_at,verified_at) LIMIT 1;
 ELSIF p_clock='SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION' THEN
   SELECT COALESCE(qualified_at,occurred_at) INTO t FROM maintenance.workflow_milestone
    WHERE workflow_round_uuid=p_round AND record_status='active' AND authority_status='authoritative'
      AND milestone_type IN ('scientific_workflow_started','methodological_workflow_started')
    ORDER BY COALESCE(qualified_at,occurred_at) LIMIT 1;
 ELSIF p_clock='SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT' THEN
   SELECT COALESCE(qualified_at,occurred_at) INTO t FROM maintenance.workflow_milestone
    WHERE workflow_round_uuid=p_round AND record_status='active' AND authority_status='authoritative'
      AND milestone_type='scientific_workflow_completed'
    ORDER BY COALESCE(qualified_at,occurred_at) LIMIT 1;
 END IF;
 RETURN t;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_context_priority_at(
 p_signal uuid,p_start timestamptz
)
RETURNS uuid LANGUAGE sql STABLE AS $q$
SELECT priority_assessment_uuid
FROM maintenance.priority_assessment
WHERE update_signal_uuid=p_signal
  AND authority_status='authoritative'
  AND record_status='active'
  AND assessed_at<=p_start
ORDER BY assessed_at DESC,recorded_at DESC,priority_assessment_uuid DESC
LIMIT 1;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_rule_matches_context(
 p_rule uuid,p_signal uuid,p_start timestamptz
)
RETURNS boolean LANGUAGE plpgsql STABLE AS $fn$
DECLARE r maintenance.sla_rule%ROWTYPE; s maintenance.update_signal%ROWTYPE;
 pa maintenance.priority_assessment%ROWTYPE; ma text; dt text;
BEGIN
 SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=p_rule;
 SELECT * INTO s FROM maintenance.update_signal WHERE update_signal_uuid=p_signal;
 IF NOT FOUND THEN RETURN false; END IF;
 IF r.signal_class_filter IS NOT NULL AND r.signal_class_filter<>s.signal_class THEN RETURN false; END IF;
 IF r.trigger_class_filter IS NOT NULL AND r.trigger_class_filter<>s.trigger_class THEN RETURN false; END IF;

 IF r.response_class_filter IS NOT NULL THEN
   SELECT * INTO pa FROM maintenance.priority_assessment
    WHERE priority_assessment_uuid=maintenance.sla_context_priority_at(p_signal,p_start);
   IF NOT FOUND OR pa.response_class<>r.response_class_filter THEN RETURN false; END IF;
 END IF;

 IF r.materiality_outcome_filter IS NOT NULL THEN
   SELECT outcome INTO ma FROM maintenance.materiality_assessment
    WHERE update_signal_uuid=p_signal AND record_status='active'
      AND assessed_at<=p_start
    ORDER BY assessed_at DESC LIMIT 1;
   IF ma IS DISTINCT FROM r.materiality_outcome_filter THEN RETURN false; END IF;
 END IF;

 IF r.decision_type_filter IS NOT NULL THEN
   SELECT decision_type INTO dt FROM maintenance.update_decision
    WHERE update_signal_uuid=p_signal AND record_status='active'
      AND decided_at<=p_start
    ORDER BY decided_at DESC LIMIT 1;
   IF dt IS DISTINCT FROM r.decision_type_filter THEN RETURN false; END IF;
 END IF;
 RETURN true;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.resolve_sla_rule(
 p_signal uuid,p_clock text,p_round uuid DEFAULT NULL,p_endpoint text DEFAULT NULL
)
RETURNS TABLE(
 resolution_status text,
 sla_rule_uuid uuid,
 raw_causal_start_at timestamptz,
 contractual_start_at timestamptz,
 start_priority_assessment_uuid uuid,
 selection_trace jsonb
)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE pol maintenance.update_policy%ROWTYPE; raw_start timestamptz; candidate_start timestamptz;
 matches uuid[]; chosen uuid; min_rule_at timestamptz; n integer;
BEGIN
 SELECT p.* INTO pol FROM maintenance.update_policy p
 JOIN maintenance.update_signal s ON s.update_policy_uuid=p.update_policy_uuid
 WHERE s.update_signal_uuid=p_signal;
 IF NOT FOUND THEN
   RETURN QUERY SELECT 'not_configured',NULL::uuid,NULL::timestamptz,NULL::timestamptz,NULL::uuid,
    jsonb_build_object('reason','signal_or_policy_missing'); RETURN;
 END IF;
 raw_start:=maintenance.sla_raw_causal_start_at(p_signal,p_clock,p_round);
 IF raw_start IS NULL THEN
   RETURN QUERY SELECT 'not_configured',NULL::uuid,NULL::timestamptz,NULL::timestamptz,NULL::uuid,
    jsonb_build_object('reason','causal_start_missing'); RETURN;
 END IF;

 SELECT min(sr.effective_at) INTO min_rule_at FROM maintenance.sla_rule sr
 WHERE sr.update_policy_uuid=pol.update_policy_uuid AND sr.clock_code=p_clock
   AND (p_endpoint IS NULL OR sr.endpoint_type=p_endpoint);
 IF min_rule_at IS NULL THEN
   RETURN QUERY SELECT 'not_configured',NULL::uuid,raw_start,NULL::timestamptz,NULL::uuid,
    jsonb_build_object('reason','no_rule_for_policy_clock'); RETURN;
 END IF;

 candidate_start:=GREATEST(raw_start,pol.effective_at,min_rule_at);

 SELECT array_agg(x.sla_rule_uuid ORDER BY x.selection_precedence),count(*)
 INTO matches,n
 FROM maintenance.sla_rule x
 WHERE x.update_policy_uuid=pol.update_policy_uuid
   AND x.clock_code=p_clock
   AND (p_endpoint IS NULL OR x.endpoint_type=p_endpoint)
   AND x.effective_at<=candidate_start
   AND (maintenance.sla_rule_effective_until(x.sla_rule_uuid) IS NULL
        OR candidate_start<maintenance.sla_rule_effective_until(x.sla_rule_uuid))
   AND NOT (
     x.record_status='superseded'
     AND maintenance.sla_rule_effective_until(x.sla_rule_uuid) IS NULL
   )
   AND maintenance.sla_rule_filter_domains_are_valid(
     x.trigger_class_filter,x.decision_type_filter,x.materiality_outcome_filter)
   AND maintenance.sla_rule_filters_are_causally_valid(
     x.clock_code,x.response_class_filter,x.materiality_outcome_filter,x.decision_type_filter)
   AND maintenance.sla_rule_matches_context(x.sla_rule_uuid,p_signal,candidate_start);

 IF n=0 THEN
   RETURN QUERY SELECT 'no_matching_rule',NULL::uuid,raw_start,candidate_start,
     maintenance.sla_context_priority_at(p_signal,candidate_start),
     jsonb_build_object('candidate_start',candidate_start,'match_count',0); RETURN;
 END IF;

 chosen:=matches[1];
 IF EXISTS (
   SELECT 1 FROM maintenance.sla_rule a JOIN maintenance.sla_rule b
    ON a.update_policy_uuid=b.update_policy_uuid AND a.clock_code=b.clock_code
   AND a.selection_precedence=b.selection_precedence AND a.sla_rule_uuid<>b.sla_rule_uuid
   WHERE a.sla_rule_uuid=ANY(matches) AND b.sla_rule_uuid=ANY(matches)
 ) THEN
   RETURN QUERY SELECT 'ambiguous_invalid',NULL::uuid,raw_start,candidate_start,
    maintenance.sla_context_priority_at(p_signal,candidate_start),
    jsonb_build_object('matches',to_jsonb(matches),'reason','duplicate_precedence'); RETURN;
 END IF;

 RETURN QUERY SELECT 'selected',chosen,raw_start,candidate_start,
   maintenance.sla_context_priority_at(p_signal,candidate_start),
   jsonb_build_object('matches',to_jsonb(matches),'selected',chosen,'candidate_start',candidate_start);
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_rule_snapshot(
 p_rule uuid,p_signal uuid,p_start timestamptz,p_trace jsonb
)
RETURNS jsonb LANGUAGE sql STABLE AS $q$
SELECT jsonb_strip_nulls(jsonb_build_object(
 'schema_version','oes.sla_rule_snapshot/0.1',
 'sla_rule_uuid',r.sla_rule_uuid,
 'update_policy_uuid',r.update_policy_uuid,
 'target_product_version_uuid',p.target_product_version_uuid,
 'target_investigation_version_uuid',p.target_investigation_version_uuid,
 'clock_code',r.clock_code,
 'selection_precedence',r.selection_precedence,
 'filters',jsonb_strip_nulls(jsonb_build_object(
   'response_class',r.response_class_filter,'signal_class',r.signal_class_filter,
   'trigger_class',r.trigger_class_filter,'decision_type',r.decision_type_filter,
   'materiality_outcome',r.materiality_outcome_filter)),
 'endpoint_type',r.endpoint_type,'time_basis',r.time_basis,
 'target_duration_seconds',CASE WHEN r.target_duration IS NULL THEN NULL ELSE extract(epoch from r.target_duration) END,
 'fixed_deadline_source_uuid',r.fixed_deadline_source_uuid,
 'sla_calendar_version_uuid',r.sla_calendar_version_uuid,
 'pause_policy',r.pause_policy_payload,'warning_policy',r.warning_policy_payload,
 'breach_policy',r.breach_policy_payload,'escalation_policy',r.escalation_policy_payload,
 'start_priority_assessment_uuid',maintenance.sla_context_priority_at(p_signal,p_start),
 'update_risk_profile_uuid',(
   SELECT pa.update_risk_profile_uuid
   FROM maintenance.priority_assessment pa
   WHERE pa.priority_assessment_uuid=maintenance.sla_context_priority_at(p_signal,p_start)
 ),
 'temporal_calibration_dossier_uuid',r.temporal_calibration_dossier_uuid,
 'selection_trace',p_trace))
FROM maintenance.sla_rule r
JOIN maintenance.update_policy p ON p.update_policy_uuid=r.update_policy_uuid
WHERE r.sla_rule_uuid=p_rule;
$q$;

ALTER TABLE maintenance.sla_instance
 ADD COLUMN IF NOT EXISTS due_calculation_payload jsonb;
ALTER TABLE maintenance.sla_pause
 ADD COLUMN IF NOT EXISTS due_extension_eligible boolean;
ALTER TABLE maintenance.sla_pause
 ADD COLUMN IF NOT EXISTS accountable_pause_seconds numeric;

CREATE OR REPLACE FUNCTION maintenance.sla_due_calculation_payload(
 p_rule uuid,p_signal uuid,p_raw timestamptz,p_start timestamptz,p_calculated_at timestamptz
)
RETURNS jsonb LANGUAGE sql STABLE AS $q$
SELECT jsonb_strip_nulls(jsonb_build_object(
 'schema_version','oes.sla_due_calculation/0.1',
 'calculator_version','0.1',
 'calculated_at',p_calculated_at,
 'raw_causal_start_at',p_raw,
 'contractual_start_at',p_start,
 'time_basis',r.time_basis,
 'sla_calendar_version_uuid',r.sla_calendar_version_uuid,
 'fixed_deadline_source_uuid',r.fixed_deadline_source_uuid,
 'nominal_due_at',maintenance.sla_nominal_due_at(r.sla_rule_uuid,p_start)))
FROM maintenance.sla_rule r WHERE r.sla_rule_uuid=p_rule;
$q$;

CREATE OR REPLACE FUNCTION maintenance.assert_sla_instance_temporal_v01()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE r maintenance.sla_rule%ROWTYPE; res record; snap jsonb; duep jsonb; expected_due timestamptz;
BEGIN
 SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=NEW.sla_rule_uuid;
 IF NOT FOUND OR maintenance.temporal_object_is_grandfathered('sla_rule',r.sla_rule_uuid) THEN RETURN NEW; END IF;

 SELECT * INTO res FROM maintenance.resolve_sla_rule(
   NEW.update_signal_uuid,NEW.clock_code,NEW.workflow_round_uuid,NEW.endpoint_type);
 IF res.resolution_status<>'selected' OR res.sla_rule_uuid<>NEW.sla_rule_uuid THEN
   RAISE EXCEPTION 'SLAInstance rule must equal canonical resolver result';
 END IF;
 IF NEW.start_at IS DISTINCT FROM res.contractual_start_at
    OR NEW.start_priority_assessment_uuid IS DISTINCT FROM res.start_priority_assessment_uuid THEN
   RAISE EXCEPTION 'SLAInstance start/priority must equal canonical context';
 END IF;
 snap:=maintenance.sla_rule_snapshot(NEW.sla_rule_uuid,NEW.update_signal_uuid,NEW.start_at,res.selection_trace);
 IF NEW.rule_snapshot_payload IS DISTINCT FROM snap THEN
   RAISE EXCEPTION 'SLAInstance rule snapshot mismatch';
 END IF;
 expected_due:=maintenance.sla_nominal_due_at(NEW.sla_rule_uuid,NEW.start_at);
 IF NEW.nominal_due_at IS DISTINCT FROM expected_due THEN RAISE EXCEPTION 'SLAInstance nominal due mismatch'; END IF;
 IF NEW.due_calculation_payload IS NULL OR jsonb_typeof(NEW.due_calculation_payload)<>'object'
    OR NEW.due_calculation_payload->>'schema_version'<>'oes.sla_due_calculation/0.1'
    OR (NEW.due_calculation_payload->>'nominal_due_at')::timestamptz IS DISTINCT FROM expected_due
    OR (NEW.due_calculation_payload->>'contractual_start_at')::timestamptz IS DISTINCT FROM NEW.start_at THEN
   RAISE EXCEPTION 'SLAInstance due calculation snapshot invalid';
 END IF;
 RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_sla_instance_temporal_v01 ON maintenance.sla_instance;
CREATE TRIGGER tr_sla_instance_temporal_v01
BEFORE INSERT ON maintenance.sla_instance
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_instance_temporal_v01();

CREATE OR REPLACE FUNCTION maintenance.assert_sla_pause_temporal_v01()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE i maintenance.sla_instance%ROWTYPE; r maintenance.sla_rule%ROWTYPE; due_before timestamptz;
BEGIN
 SELECT * INTO i FROM maintenance.sla_instance WHERE sla_instance_uuid=NEW.sla_instance_uuid;
 SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=i.sla_rule_uuid;
 IF maintenance.temporal_object_is_grandfathered('sla_rule',r.sla_rule_uuid) THEN RETURN NEW; END IF;
 IF EXISTS (
   SELECT 1 FROM maintenance.sla_pause p
    WHERE p.sla_instance_uuid=NEW.sla_instance_uuid
      AND p.record_status='active'
      AND p.sla_pause_uuid<>NEW.sla_pause_uuid
      AND tstzrange(p.started_at,COALESCE(p.ended_at,'infinity'::timestamptz),'[)')
          && tstzrange(NEW.started_at,COALESCE(NEW.ended_at,'infinity'::timestamptz),'[)')
 ) THEN RAISE EXCEPTION 'Overlapping SLA pauses are prohibited'; END IF;

 due_before:=maintenance.sla_effective_due_at(NEW.sla_instance_uuid);
 NEW.due_extension_eligible := (
   r.time_basis<>'fixed_deadline'
   AND i.first_breached_at IS NULL
   AND NEW.started_at<due_before
 );
 IF NEW.ended_at IS NULL THEN
   NEW.accountable_pause_seconds:=NULL;
 ELSE
   IF NOT NEW.due_extension_eligible THEN NEW.accountable_pause_seconds:=0;
   ELSIF r.time_basis='elapsed_time' THEN
     NEW.accountable_pause_seconds:=extract(epoch from (NEW.ended_at-NEW.started_at));
   ELSE
     NEW.accountable_pause_seconds:=maintenance.sla_calendar_open_seconds_between(
       r.sla_calendar_version_uuid,NEW.started_at,NEW.ended_at);
   END IF;
 END IF;
 RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_sla_pause_temporal_v01 ON maintenance.sla_pause;
CREATE TRIGGER tr_sla_pause_temporal_v01
BEFORE INSERT OR UPDATE OF ended_at ON maintenance.sla_pause
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_pause_temporal_v01();

CREATE OR REPLACE FUNCTION maintenance.sla_effective_due_at(p uuid)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $fn$
DECLARE i maintenance.sla_instance%ROWTYPE; r maintenance.sla_rule%ROWTYPE; secs numeric:=0;
BEGIN
 SELECT * INTO i FROM maintenance.sla_instance WHERE sla_instance_uuid=p;
 IF NOT FOUND THEN RETURN NULL; END IF;
 SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=i.sla_rule_uuid;
 IF r.time_basis='fixed_deadline' THEN RETURN i.nominal_due_at; END IF;

 SELECT COALESCE(sum(
   CASE
    WHEN sp.ended_at IS NOT NULL THEN COALESCE(sp.accountable_pause_seconds,0)
    WHEN NOT COALESCE(sp.due_extension_eligible,false) THEN 0
    WHEN r.time_basis='elapsed_time' THEN extract(epoch from (CURRENT_TIMESTAMP-sp.started_at))
    ELSE maintenance.sla_calendar_open_seconds_between(r.sla_calendar_version_uuid,sp.started_at,CURRENT_TIMESTAMP)
   END),0)
 INTO secs
 FROM maintenance.sla_pause sp
 WHERE sp.sla_instance_uuid=p AND sp.record_status='active';

 IF maintenance.temporal_object_is_grandfathered('sla_rule',r.sla_rule_uuid) THEN
   RETURN i.nominal_due_at + make_interval(secs=>secs::double precision);
 END IF;
 IF r.time_basis='elapsed_time' THEN
   RETURN i.nominal_due_at + make_interval(secs=>secs::double precision);
 END IF;
 RETURN maintenance.sla_calendar_add_open_seconds(r.sla_calendar_version_uuid,i.nominal_due_at,secs);
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_warning_at(p uuid)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $fn$
DECLARE i maintenance.sla_instance%ROWTYPE; r maintenance.sla_rule%ROWTYPE; due_at timestamptz; lead numeric; basis text;
BEGIN
 SELECT * INTO i FROM maintenance.sla_instance WHERE sla_instance_uuid=p;
 IF NOT FOUND THEN RETURN NULL; END IF;
 SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=i.sla_rule_uuid;
 IF r.warning_policy_payload->>'mode'<>'lead_time' THEN RETURN NULL; END IF;
 lead:=(r.warning_policy_payload->>'lead_seconds')::numeric;
 basis:=r.warning_policy_payload->>'time_basis';
 due_at:=maintenance.sla_effective_due_at(p);
 IF basis='same_as_sla' AND r.time_basis='business_calendar' THEN
   RETURN maintenance.sla_calendar_subtract_open_seconds(r.sla_calendar_version_uuid,due_at,lead);
 END IF;
 RETURN due_at-make_interval(secs=>lead::double precision);
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_calibration_dossier_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE d maintenance.temporal_calibration_dossier%ROWTYPE;
BEGIN
 SELECT * INTO d FROM maintenance.temporal_calibration_dossier WHERE temporal_calibration_dossier_uuid=p;
 IF NOT FOUND THEN RETURN QUERY SELECT 'DOSSIER_MISSING','error','Temporal calibration dossier missing'; RETURN; END IF;
 IF d.decision_status='approved_for_normative_activation' THEN
   IF NOT EXISTS (SELECT 1 FROM maintenance.temporal_calibration_candidate c
      WHERE c.temporal_calibration_dossier_uuid=p AND c.disposition='selected') THEN
     RETURN QUERY SELECT 'SELECTED_CANDIDATE_REQUIRED','error','Approved dossier requires selected candidate'; END IF;
   IF NOT EXISTS (SELECT 1 FROM maintenance.temporal_calibration_evaluation e
      JOIN maintenance.temporal_calibration_candidate c USING(temporal_calibration_candidate_uuid)
      WHERE c.temporal_calibration_dossier_uuid=p AND e.evaluation_type='capacity_analysis') THEN
     RETURN QUERY SELECT 'CAPACITY_EVALUATION_REQUIRED','error','Approved dossier requires capacity analysis'; END IF;
 END IF;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.cadence_contract_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE c maintenance.cadence_contract%ROWTYPE; ec integer; rc integer;
BEGIN
 SELECT * INTO c FROM maintenance.cadence_contract WHERE cadence_contract_uuid=p;
 IF NOT FOUND THEN RETURN QUERY SELECT 'CADENCE_CONTRACT_MISSING','error','CadenceContract missing'; RETURN; END IF;
 SELECT count(*) FILTER(WHERE timing_mode='event_driven'),
        count(*) FILTER(WHERE timing_mode IN ('fixed_elapsed','calendar_recurrence'))
 INTO ec,rc FROM maintenance.cadence_obligation WHERE cadence_contract_uuid=p;
 IF (c.cadence_mode='event_driven' AND (ec<1 OR rc<>0))
  OR (c.cadence_mode='periodic' AND (rc<1 OR ec<>0))
  OR (c.cadence_mode='hybrid' AND (ec<1 OR rc<1)) THEN
   RETURN QUERY SELECT 'CADENCE_COMPOSITION_INVALID','error','Cadence obligation composition invalid'; END IF;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_rule_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE r maintenance.sla_rule%ROWTYPE;
BEGIN
 SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=p;
 IF NOT FOUND THEN RETURN QUERY SELECT 'SLA_RULE_MISSING','error','SLARule missing'; RETURN; END IF;
 IF NOT maintenance.sla_rule_filter_domains_are_valid(r.trigger_class_filter,r.decision_type_filter,r.materiality_outcome_filter)
   OR NOT maintenance.sla_rule_filters_are_causally_valid(r.clock_code,r.response_class_filter,r.materiality_outcome_filter,r.decision_type_filter) THEN
  RETURN QUERY SELECT 'SLA_FILTER_INVALID','error','SLARule filter domain/causal matrix invalid'; END IF;
 IF r.record_status='superseded' AND maintenance.sla_rule_effective_until(r.sla_rule_uuid) IS NULL THEN
  RETURN QUERY SELECT 'SLA_RULE_LINEAGE_INCOMPLETE','error','Superseded SLARule has no successor'; END IF;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_operational_readiness(p_policy uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE p maintenance.update_policy%ROWTYPE;
BEGIN
 SELECT * INTO p FROM maintenance.update_policy WHERE update_policy_uuid=p_policy;
 IF NOT FOUND THEN RETURN QUERY SELECT 'UPDATE_POLICY_MISSING','error','UpdatePolicy missing'; RETURN; END IF;
 IF p.effective_maintenance_level='M3' OR p.cadence_mode='continuous' THEN
   RETURN QUERY SELECT 'M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL','blocker','M3 remains formally blocked'; END IF;
 IF NOT maintenance.temporal_object_is_grandfathered('update_policy',p.update_policy_uuid)
    AND p.cadence_mode<>'none' AND p.cadence_contract_uuid IS NULL THEN
   RETURN QUERY SELECT 'CADENCE_CONTRACT_REQUIRED','error','v0.1 policy requires CadenceContract'; END IF;
 RETURN QUERY
 SELECT 'SLA_RULE_ISSUE:'||i.issue_code,i.severity,i.message
 FROM maintenance.sla_rule r CROSS JOIN LATERAL maintenance.sla_rule_issues(r.sla_rule_uuid) i
 WHERE r.update_policy_uuid=p_policy;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.guard_update_policy_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'UpdatePolicy is append-preserving and cannot be deleted'; END IF;
 IF OLD.record_status='active' AND NEW.record_status='superseded'
  AND NEW.update_policy_uuid=OLD.update_policy_uuid
  AND NEW.target_product_version_uuid IS NOT DISTINCT FROM OLD.target_product_version_uuid
  AND NEW.target_investigation_version_uuid IS NOT DISTINCT FROM OLD.target_investigation_version_uuid
  AND NEW.effective_maintenance_level=OLD.effective_maintenance_level
  AND NEW.cadence_mode=OLD.cadence_mode
  AND NEW.cadence_contract_uuid IS NOT DISTINCT FROM OLD.cadence_contract_uuid
  AND NEW.cadence_policy_payload=OLD.cadence_policy_payload
  AND NEW.trigger_policy_payload=OLD.trigger_policy_payload
  AND NEW.materiality_policy_payload=OLD.materiality_policy_payload
  AND NEW.escalation_policy_payload=OLD.escalation_policy_payload
  AND NEW.governance_policy_payload=OLD.governance_policy_payload
  AND NEW.governing_monitor_product_version_uuid IS NOT DISTINCT FROM OLD.governing_monitor_product_version_uuid
  AND NEW.effective_at=OLD.effective_at AND NEW.rationale=OLD.rationale
  AND NEW.created_by=OLD.created_by AND NEW.actor_type=OLD.actor_type
  AND NEW.supersedes_update_policy_uuid IS NOT DISTINCT FROM OLD.supersedes_update_policy_uuid
 THEN RETURN NEW; END IF;
 RAISE EXCEPTION 'UpdatePolicy material fields are immutable; supersede and append';
END
$guard$;

CREATE OR REPLACE FUNCTION maintenance.guard_sla_rule_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'SLARule cannot be deleted'; END IF;
 IF OLD.record_status='active' AND NEW.record_status='superseded'
  AND (to_jsonb(NEW)-'record_status')=(to_jsonb(OLD)-'record_status')
 THEN RETURN NEW; END IF;
 RAISE EXCEPTION 'SLARule material fields are immutable; supersede and append';
END
$guard$;


-- Freeze all causal and calculation snapshot fields added/used by temporal v0.1.
CREATE OR REPLACE FUNCTION maintenance.guard_sla_instance_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
DECLARE ok boolean;
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'SLAInstance cannot be deleted'; END IF;

  ok := (OLD.execution_status=NEW.execution_status)
    OR (OLD.execution_status='pending' AND NEW.execution_status IN ('running','not_applicable','cancelled_invalidated'))
    OR (OLD.execution_status='running' AND NEW.execution_status IN ('paused','satisfied','terminated_by_authority','cancelled_invalidated'))
    OR (OLD.execution_status='paused' AND NEW.execution_status IN ('running','satisfied','terminated_by_authority','cancelled_invalidated'));

  IF NOT ok THEN RAISE EXCEPTION 'Invalid SLAInstance execution transition'; END IF;

  IF OLD.sla_rule_uuid<>NEW.sla_rule_uuid
     OR OLD.obligation_uuid<>NEW.obligation_uuid
     OR OLD.update_signal_uuid<>NEW.update_signal_uuid
     OR OLD.update_triage_uuid IS DISTINCT FROM NEW.update_triage_uuid
     OR OLD.materiality_assessment_uuid IS DISTINCT FROM NEW.materiality_assessment_uuid
     OR OLD.update_decision_uuid IS DISTINCT FROM NEW.update_decision_uuid
     OR OLD.workflow_round_uuid IS DISTINCT FROM NEW.workflow_round_uuid
     OR OLD.start_priority_assessment_uuid IS DISTINCT FROM NEW.start_priority_assessment_uuid
     OR OLD.clock_code<>NEW.clock_code
     OR OLD.endpoint_type<>NEW.endpoint_type
     OR OLD.time_basis<>NEW.time_basis
     OR OLD.rule_snapshot_payload<>NEW.rule_snapshot_payload
     OR OLD.due_calculation_payload IS DISTINCT FROM NEW.due_calculation_payload
     OR OLD.source_detected_at IS DISTINCT FROM NEW.source_detected_at
     OR OLD.pre_policy_age IS DISTINCT FROM NEW.pre_policy_age
     OR OLD.start_at<>NEW.start_at
     OR OLD.nominal_due_at<>NEW.nominal_due_at
  THEN
    RAISE EXCEPTION 'SLAInstance causal/snapshot fields are immutable under temporal v0.1';
  END IF;

  IF OLD.first_breached_at IS NOT NULL
     AND NEW.first_breached_at IS DISTINCT FROM OLD.first_breached_at THEN
    RAISE EXCEPTION 'SLA first_breached_at is immutable once set';
  END IF;

  RETURN NEW;
END
$guard$;
