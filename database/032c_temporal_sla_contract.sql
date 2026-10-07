-- Migration 032 fragment C — SLA calendar, fixed deadline, rule hardening
-- No normative calendar/rule seed.

CREATE OR REPLACE FUNCTION maintenance.temporal_json_has_only_keys(p jsonb,p_keys text[])
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT jsonb_typeof(p)='object'
 AND NOT EXISTS (SELECT 1 FROM jsonb_object_keys(p) k WHERE NOT (k=ANY(p_keys)));
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_calendar_payload_is_valid(
  p_weekly jsonb,p_exceptions jsonb
)
RETURNS boolean LANGUAGE plpgsql STABLE AS $fn$
DECLARE d integer; v jsonb; item jsonb; prev_end text; a text; b text; ex_date date;
BEGIN
  IF jsonb_typeof(p_weekly)<>'object' OR jsonb_typeof(p_exceptions)<>'array' THEN RETURN false; END IF;
  FOR d IN 1..7 LOOP
    v:=p_weekly->d::text;
    IF v IS NULL OR jsonb_typeof(v)<>'array' THEN RETURN false; END IF;
    prev_end:=NULL;
    FOR item IN SELECT value FROM jsonb_array_elements(v)
    LOOP
      IF jsonb_typeof(item)<>'object'
        OR NOT maintenance.temporal_json_has_only_keys(item,ARRAY['start','end'])
        OR NOT(item ? 'start' AND item ? 'end') THEN RETURN false; END IF;
      a:=item->>'start'; b:=item->>'end';
      IF a !~ '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$'
         OR b !~ '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$' OR a>=b THEN RETURN false; END IF;
      IF prev_end IS NOT NULL AND a<prev_end THEN RETURN false; END IF;
      prev_end:=b;
    END LOOP;
  END LOOP;
  IF (SELECT count(*) FROM jsonb_object_keys(p_weekly))<>7 THEN RETURN false; END IF;

  IF EXISTS (
    SELECT 1 FROM (
      SELECT (x->>'date') AS d,count(*) n
      FROM jsonb_array_elements(p_exceptions) x GROUP BY x->>'date'
    ) q WHERE n>1
  ) THEN RETURN false; END IF;

  FOR item IN SELECT value FROM jsonb_array_elements(p_exceptions)
  LOOP
    IF jsonb_typeof(item)<>'object'
      OR NOT(item ? 'date' AND item ? 'mode')
      OR (item->>'mode') NOT IN ('closed','custom') THEN RETURN false; END IF;
    BEGIN ex_date:=(item->>'date')::date; EXCEPTION WHEN OTHERS THEN RETURN false; END;
    IF item->>'mode'='closed' THEN
      IF NOT maintenance.temporal_json_has_only_keys(item,ARRAY['date','mode']) THEN RETURN false; END IF;
    ELSE
      IF NOT maintenance.temporal_json_has_only_keys(item,ARRAY['date','mode','intervals'])
        OR jsonb_typeof(item->'intervals')<>'array' THEN RETURN false; END IF;
      prev_end:=NULL;
      FOR v IN SELECT value FROM jsonb_array_elements(item->'intervals')
      LOOP
        IF jsonb_typeof(v)<>'object'
          OR NOT maintenance.temporal_json_has_only_keys(v,ARRAY['start','end'])
          OR NOT(v ? 'start' AND v ? 'end') THEN RETURN false; END IF;
        a:=v->>'start'; b:=v->>'end';
        IF a !~ '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$'
          OR b !~ '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$' OR a>=b THEN RETURN false; END IF;
        IF prev_end IS NOT NULL AND a<prev_end THEN RETURN false; END IF;
        prev_end:=b;
      END LOOP;
    END IF;
  END LOOP;
  RETURN true;
END
$fn$;

CREATE TABLE IF NOT EXISTS maintenance.fixed_deadline_source (
  fixed_deadline_source_uuid uuid PRIMARY KEY,
  temporal_calibration_dossier_uuid uuid NOT NULL
    REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid),
  source_type text NOT NULL CHECK(source_type IN ('external_rule','entity_version','artifact','manual_governance')),
  source_entity_version_uuid uuid REFERENCES core.entity_version(version_uuid),
  source_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
  time_precision text NOT NULL CHECK(time_precision IN ('timestamp','date')),
  deadline_at timestamptz,
  deadline_date date,
  timezone_name text,
  date_boundary_policy text CHECK(date_boundary_policy IN ('none','end_of_local_date')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK(
    (source_type='entity_version' AND source_entity_version_uuid IS NOT NULL AND source_artifact_uuid IS NULL)
    OR
    (source_type IN ('external_rule','artifact','manual_governance')
      AND source_entity_version_uuid IS NULL AND source_artifact_uuid IS NOT NULL)
  ),
  CHECK(
    (time_precision='timestamp' AND deadline_at IS NOT NULL AND deadline_date IS NULL
      AND COALESCE(date_boundary_policy,'none')='none')
    OR
    (time_precision='date' AND deadline_at IS NULL AND deadline_date IS NOT NULL)
  )
);

CREATE OR REPLACE FUNCTION maintenance.assert_fixed_deadline_source()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.temporal_calibration_dossier%ROWTYPE; st text;
BEGIN
  SELECT * INTO d FROM maintenance.temporal_calibration_dossier
   WHERE temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid;
  IF NOT FOUND OR d.calibration_kind<>'sla_rule' OR d.decision_status<>'approved_for_normative_activation' THEN
    RAISE EXCEPTION 'FixedDeadlineSource requires approved SLA calibration dossier';
  END IF;
  IF NEW.source_artifact_uuid IS NOT NULL THEN
    SELECT status INTO st FROM artifact.artifact WHERE artifact_uuid=NEW.source_artifact_uuid;
    IF st IS DISTINCT FROM 'active' THEN RAISE EXCEPTION 'Fixed deadline Artifact must be active'; END IF;
  END IF;
  IF NEW.time_precision='date' THEN
    IF NEW.timezone_name IS NULL OR NEW.date_boundary_policy IS DISTINCT FROM 'end_of_local_date' THEN
      RAISE EXCEPTION 'Date-only fixed deadline requires explicit timezone and boundary policy';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_timezone_names WHERE name=NEW.timezone_name) THEN
      RAISE EXCEPTION 'Fixed deadline timezone is invalid';
    END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_fixed_deadline_source ON maintenance.fixed_deadline_source;
CREATE TRIGGER tr_fixed_deadline_source BEFORE INSERT ON maintenance.fixed_deadline_source
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_fixed_deadline_source();

CREATE OR REPLACE FUNCTION maintenance.guard_fixed_deadline_source_immutable()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  RAISE EXCEPTION 'FixedDeadlineSource is immutable; append a new calibrated source';
END
$fn$;

DROP TRIGGER IF EXISTS tr_fixed_deadline_source_immutable
 ON maintenance.fixed_deadline_source;
CREATE TRIGGER tr_fixed_deadline_source_immutable
BEFORE UPDATE OR DELETE ON maintenance.fixed_deadline_source
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_fixed_deadline_source_immutable();

ALTER TABLE maintenance.sla_calendar_version
 ADD COLUMN IF NOT EXISTS temporal_calibration_dossier_uuid uuid
 REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid);

ALTER TABLE maintenance.sla_rule
 ADD COLUMN IF NOT EXISTS temporal_calibration_dossier_uuid uuid
 REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid);
ALTER TABLE maintenance.sla_rule
 ADD COLUMN IF NOT EXISTS fixed_deadline_source_uuid uuid
 REFERENCES maintenance.fixed_deadline_source(fixed_deadline_source_uuid);

CREATE OR REPLACE FUNCTION maintenance.sla_rule_filter_domains_are_valid(
 p_trigger text,p_decision text,p_materiality text
)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT
 (p_trigger IS NULL OR p_trigger IN (
  'new_evidence','integrity_validity','safety_regulatory','temporal_operational',
  'governance_demand','methodological','scope'))
 AND
 (p_decision IS NULL OR p_decision IN (
  'no_scientific_update','observe','currentness_only','scientific_update_incremental',
  'scientific_update_broad','reroute_method','suspend_current_use'))
 AND
 (p_materiality IS NULL OR p_materiality IN (
  'no_material_change','potentially_material','material_change_confirmed',
  'validity_or_use_threat','insufficient_to_decide'));
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_rule_filters_are_causally_valid(
 p_clock text,p_response text,p_materiality text,p_decision text
)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT CASE p_clock
 WHEN 'SLA1_DETECTION_TO_TRIAGE' THEN p_response IS NULL AND p_materiality IS NULL AND p_decision IS NULL
 WHEN 'SLA2_TRIAGE_TO_MATERIALITY' THEN p_materiality IS NULL AND p_decision IS NULL
 WHEN 'SLA3_MATERIALITY_TO_DECISION' THEN p_decision IS NULL
 WHEN 'SLA4_DECISION_TO_WORKFLOW_START' THEN true
 WHEN 'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION' THEN true
 WHEN 'SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT' THEN true
 ELSE false END;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_pause_policy_is_valid(p_allowed boolean,p jsonb)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT jsonb_typeof(p)='object'
 AND maintenance.temporal_json_has_only_keys(p,ARRAY['schema_version','mode','allowed_reason_codes'])
 AND p->>'schema_version'='oes.sla_pause_policy/0.1'
 AND (
  (NOT p_allowed AND p->>'mode'='none' AND NOT(p ? 'allowed_reason_codes'))
  OR
  (p_allowed AND p->>'mode'='allowed_reasons' AND jsonb_typeof(p->'allowed_reason_codes')='array'
   AND jsonb_array_length(p->'allowed_reason_codes')>0
   AND NOT EXISTS (
     SELECT 1 FROM jsonb_array_elements_text(p->'allowed_reason_codes') x
     WHERE x NOT IN ('external_dependency','awaiting_authoritative_source','governance_hold','legal_regulatory_hold','other')
   ))
 );
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_warning_policy_is_valid(p jsonb,p_duration interval)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT jsonb_typeof(p)='object'
 AND maintenance.temporal_json_has_only_keys(p,ARRAY['schema_version','mode','time_basis','lead_seconds'])
 AND p->>'schema_version'='oes.sla_warning_policy/0.1'
 AND (
  (p->>'mode'='none' AND NOT(p ? 'time_basis') AND NOT(p ? 'lead_seconds'))
  OR
  (p->>'mode'='lead_time' AND p->>'time_basis' IN ('elapsed_time','same_as_sla')
    AND (p->>'lead_seconds') ~ '^[0-9]+(?:\.[0-9]+)?$'
    AND (p->>'lead_seconds')::numeric>0
    AND (p_duration IS NULL OR (p->>'lead_seconds')::numeric<extract(epoch from p_duration)))
 );
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_breach_policy_is_valid(p jsonb)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT jsonb_typeof(p)='object'
 AND maintenance.temporal_json_has_only_keys(p,ARRAY['schema_version','mode'])
 AND p->>'schema_version'='oes.sla_breach_policy/0.1'
 AND p->>'mode'='at_effective_due';
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_escalation_policy_is_valid(p jsonb)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT jsonb_typeof(p)='object'
 AND maintenance.temporal_json_has_only_keys(p,ARRAY['schema_version','mode','time_basis','after_breach_seconds','reason_code'])
 AND p->>'schema_version'='oes.sla_escalation_policy/0.1'
 AND (
  (p->>'mode'='none' AND NOT(p ? 'time_basis') AND NOT(p ? 'after_breach_seconds') AND NOT(p ? 'reason_code'))
  OR
  (p->>'mode'='post_breach_candidate'
    AND p->>'time_basis' IN ('elapsed_time','same_as_sla')
    AND (p->>'after_breach_seconds') ~ '^[0-9]+(?:\.[0-9]+)?$'
    AND (p->>'after_breach_seconds')::numeric>=0
    AND p->>'reason_code'='operational_delay')
 );
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_calendar_open_intervals(
 p_calendar uuid,p_date date
)
RETURNS TABLE(open_start timestamptz,open_end timestamptz)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE c maintenance.sla_calendar_version%ROWTYPE; items jsonb; ex jsonb; item jsonb;
BEGIN
 SELECT * INTO c FROM maintenance.sla_calendar_version WHERE sla_calendar_version_uuid=p_calendar;
 IF NOT FOUND THEN RETURN; END IF;
 SELECT value INTO ex FROM jsonb_array_elements(c.exception_dates_payload)
  WHERE value->>'date'=p_date::text LIMIT 1;
 IF ex IS NOT NULL THEN
   IF ex->>'mode'='closed' THEN RETURN; END IF;
   items:=ex->'intervals';
 ELSE
   items:=c.weekly_schedule_payload->extract(isodow from p_date)::int::text;
 END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(COALESCE(items,'[]'::jsonb))
 LOOP
   open_start := (p_date::text||' '||(item->>'start'))::timestamp AT TIME ZONE c.timezone_name;
   open_end := (p_date::text||' '||(item->>'end'))::timestamp AT TIME ZONE c.timezone_name;
   RETURN NEXT;
 END LOOP;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_calendar_open_seconds_between(
 p_calendar uuid,p_start timestamptz,p_end timestamptz
)
RETURNS numeric LANGUAGE plpgsql STABLE AS $fn$
DECLARE c maintenance.sla_calendar_version%ROWTYPE; d date; lastd date; r record;
 s timestamptz; e timestamptz; total numeric:=0;
BEGIN
 IF p_end<=p_start THEN RETURN 0; END IF;
 SELECT * INTO c FROM maintenance.sla_calendar_version WHERE sla_calendar_version_uuid=p_calendar;
 IF NOT FOUND THEN RETURN NULL; END IF;
 d:=(p_start AT TIME ZONE c.timezone_name)::date;
 lastd:=(p_end AT TIME ZONE c.timezone_name)::date;
 WHILE d<=lastd LOOP
   FOR r IN SELECT * FROM maintenance.sla_calendar_open_intervals(p_calendar,d)
   LOOP
     s:=GREATEST(p_start,r.open_start); e:=LEAST(p_end,r.open_end);
     IF e>s THEN total:=total+extract(epoch from (e-s)); END IF;
   END LOOP;
   d:=d+1;
 END LOOP;
 RETURN total;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_calendar_add_open_seconds(
 p_calendar uuid,p_start timestamptz,p_seconds numeric
)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $fn$
DECLARE c maintenance.sla_calendar_version%ROWTYPE; d date; r record; cur timestamptz:=p_start;
 remain numeric:=p_seconds; avail numeric; guard integer:=0; seg_start timestamptz;
BEGIN
 IF p_seconds<0 THEN RAISE EXCEPTION 'Open seconds cannot be negative'; END IF;
 IF p_seconds=0 THEN RETURN p_start; END IF;
 SELECT * INTO c FROM maintenance.sla_calendar_version WHERE sla_calendar_version_uuid=p_calendar;
 IF NOT FOUND THEN RETURN NULL; END IF;
 d:=(cur AT TIME ZONE c.timezone_name)::date;
 WHILE remain>0 LOOP
   guard:=guard+1; IF guard>36600 THEN RAISE EXCEPTION 'Calendar addition exceeded safety horizon'; END IF;
   FOR r IN SELECT * FROM maintenance.sla_calendar_open_intervals(p_calendar,d)
   LOOP
     IF r.open_end<=cur THEN CONTINUE; END IF;
     seg_start:=GREATEST(cur,r.open_start);
     avail:=extract(epoch from (r.open_end-seg_start));
     IF remain<=avail THEN RETURN seg_start+make_interval(secs=>remain::double precision); END IF;
     remain:=remain-avail; cur:=r.open_end;
   END LOOP;
   d:=d+1;
   cur:=(d::text||' 00:00')::timestamp AT TIME ZONE c.timezone_name;
 END LOOP;
 RETURN cur;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_calendar_subtract_open_seconds(
 p_calendar uuid,p_end timestamptz,p_seconds numeric
)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $fn$
DECLARE c maintenance.sla_calendar_version%ROWTYPE; d date; r record; cur timestamptz:=p_end;
 remain numeric:=p_seconds; avail numeric; guard integer:=0; seg_end timestamptz;
BEGIN
 IF p_seconds<0 THEN RAISE EXCEPTION 'Open seconds cannot be negative'; END IF;
 IF p_seconds=0 THEN RETURN p_end; END IF;
 SELECT * INTO c FROM maintenance.sla_calendar_version WHERE sla_calendar_version_uuid=p_calendar;
 IF NOT FOUND THEN RETURN NULL; END IF;
 d:=(cur AT TIME ZONE c.timezone_name)::date;
 WHILE remain>0 LOOP
   guard:=guard+1; IF guard>36600 THEN RAISE EXCEPTION 'Calendar subtraction exceeded safety horizon'; END IF;
   FOR r IN SELECT * FROM maintenance.sla_calendar_open_intervals(p_calendar,d) ORDER BY open_start DESC
   LOOP
     IF r.open_start>=cur THEN CONTINUE; END IF;
     seg_end:=LEAST(cur,r.open_end);
     avail:=extract(epoch from (seg_end-r.open_start));
     IF remain<=avail THEN RETURN seg_end-make_interval(secs=>remain::double precision); END IF;
     remain:=remain-avail; cur:=r.open_start;
   END LOOP;
   d:=d-1;
   cur:=((d+1)::text||' 00:00')::timestamp AT TIME ZONE c.timezone_name;
 END LOOP;
 RETURN cur;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.fixed_deadline_source_snapshot(p uuid)
RETURNS jsonb LANGUAGE sql STABLE AS $q$
SELECT jsonb_strip_nulls(jsonb_build_object(
 'fixed_deadline_source_uuid',f.fixed_deadline_source_uuid,
 'source_type',f.source_type,'source_entity_version_uuid',f.source_entity_version_uuid,
 'source_artifact_uuid',f.source_artifact_uuid,'time_precision',f.time_precision,
 'deadline_at',f.deadline_at,'deadline_date',f.deadline_date,
 'timezone_name',f.timezone_name,'date_boundary_policy',f.date_boundary_policy))
FROM maintenance.fixed_deadline_source f WHERE f.fixed_deadline_source_uuid=p;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_calendar_calibration_snapshot(p uuid)
RETURNS jsonb LANGUAGE sql STABLE AS $q$
SELECT jsonb_strip_nulls(jsonb_build_object(
 'schema_version','oes.sla_calendar_candidate/0.1',
 'calendar_key',c.calendar_key,'timezone_name',c.timezone_name,
 'weekly_schedule',c.weekly_schedule_payload,'exception_dates',c.exception_dates_payload,
 'effective_from',c.effective_from,'effective_to',c.effective_to))
FROM maintenance.sla_calendar_version c WHERE c.sla_calendar_version_uuid=p;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_rule_calibration_snapshot(p uuid)
RETURNS jsonb LANGUAGE sql STABLE AS $q$
SELECT jsonb_strip_nulls(jsonb_build_object(
 'schema_version','oes.sla_rule_candidate/0.1',
 'clock_code',r.clock_code,'selection_precedence',r.selection_precedence,
 'filters',jsonb_strip_nulls(jsonb_build_object(
   'response_class',r.response_class_filter,'signal_class',r.signal_class_filter,
   'trigger_class',r.trigger_class_filter,'decision_type',r.decision_type_filter,
   'materiality_outcome',r.materiality_outcome_filter)),
 'endpoint_type',r.endpoint_type,'time_basis',r.time_basis,
 'target_duration_seconds',CASE WHEN r.target_duration IS NULL THEN NULL ELSE extract(epoch from r.target_duration) END,
 'sla_calendar_version_uuid',r.sla_calendar_version_uuid,
 'fixed_deadline_source_snapshot',CASE WHEN r.fixed_deadline_source_uuid IS NULL THEN NULL
   ELSE maintenance.fixed_deadline_source_snapshot(r.fixed_deadline_source_uuid) END,
 'pause_policy',r.pause_policy_payload,'warning_policy',r.warning_policy_payload,
 'breach_policy',r.breach_policy_payload,'escalation_policy',r.escalation_policy_payload,
 'effective_at',r.effective_at))
FROM maintenance.sla_rule r WHERE r.sla_rule_uuid=p;
$q$;

CREATE OR REPLACE FUNCTION maintenance.assert_sla_calendar_v01()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.temporal_calibration_dossier%ROWTYPE; selected jsonb;
BEGIN
 IF NOT maintenance.sla_calendar_payload_is_valid(NEW.weekly_schedule_payload,NEW.exception_dates_payload)
    OR NOT EXISTS(SELECT 1 FROM pg_timezone_names WHERE name=NEW.timezone_name) THEN
   RAISE EXCEPTION 'SLA calendar v0.1 payload/timezone invalid';
 END IF;
 IF maintenance.temporal_object_is_grandfathered('sla_calendar_version',NEW.sla_calendar_version_uuid) THEN RETURN NEW; END IF;
 SELECT * INTO d FROM maintenance.temporal_calibration_dossier
  WHERE temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid;
 IF NOT FOUND OR d.scope_type<>'calendar' OR d.calibration_kind<>'sla_calendar'
   OR d.decision_status<>'approved_for_normative_activation'
   OR d.calendar_key<>NEW.calendar_key OR d.decided_at>NEW.effective_from THEN
   RAISE EXCEPTION 'New SLA calendar requires approved matching calendar dossier';
 END IF;
 SELECT candidate_payload INTO selected FROM maintenance.temporal_calibration_candidate
  WHERE temporal_calibration_dossier_uuid=d.temporal_calibration_dossier_uuid AND disposition='selected';
 IF selected IS DISTINCT FROM maintenance.sla_calendar_calibration_snapshot(NEW.sla_calendar_version_uuid) THEN
   -- BEFORE INSERT cannot query NEW row via serializer; compare after insert in deferred trigger instead.
   NULL;
 END IF;
 RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_sla_calendar_v01 ON maintenance.sla_calendar_version;
CREATE TRIGGER tr_sla_calendar_v01 BEFORE INSERT ON maintenance.sla_calendar_version
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_calendar_v01();

CREATE OR REPLACE FUNCTION maintenance.assert_sla_calendar_candidate_match()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE selected jsonb;
BEGIN
 IF maintenance.temporal_object_is_grandfathered('sla_calendar_version',NEW.sla_calendar_version_uuid) THEN RETURN NULL; END IF;
 SELECT candidate_payload INTO selected FROM maintenance.temporal_calibration_candidate
  WHERE temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid AND disposition='selected';
 IF selected IS DISTINCT FROM maintenance.sla_calendar_calibration_snapshot(NEW.sla_calendar_version_uuid) THEN
   RAISE EXCEPTION 'SLACalendarVersion must equal selected candidate snapshot';
 END IF;
 RETURN NULL;
END
$fn$;
DROP TRIGGER IF EXISTS tr_sla_calendar_candidate_match ON maintenance.sla_calendar_version;
CREATE CONSTRAINT TRIGGER tr_sla_calendar_candidate_match
AFTER INSERT ON maintenance.sla_calendar_version DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_calendar_candidate_match();

CREATE OR REPLACE FUNCTION maintenance.assert_sla_rule_v01()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.temporal_calibration_dossier%ROWTYPE; p maintenance.update_policy%ROWTYPE;
 cal maintenance.sla_calendar_version%ROWTYPE; f maintenance.fixed_deadline_source%ROWTYPE;
BEGIN
 IF NOT maintenance.sla_rule_filter_domains_are_valid(
    NEW.trigger_class_filter,NEW.decision_type_filter,NEW.materiality_outcome_filter)
    OR NOT maintenance.sla_rule_filters_are_causally_valid(
      NEW.clock_code,NEW.response_class_filter,NEW.materiality_outcome_filter,NEW.decision_type_filter) THEN
   RAISE EXCEPTION 'SLARule filter domains/causal matrix invalid';
 END IF;
 IF maintenance.temporal_object_is_grandfathered('sla_rule',NEW.sla_rule_uuid) THEN RETURN NEW; END IF;
 SELECT * INTO p FROM maintenance.update_policy WHERE update_policy_uuid=NEW.update_policy_uuid;
 SELECT * INTO d FROM maintenance.temporal_calibration_dossier
  WHERE temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid;
 IF NOT FOUND OR d.scope_type<>'target' OR d.calibration_kind<>'sla_rule'
   OR d.decision_status<>'approved_for_normative_activation'
   OR d.target_product_version_uuid IS DISTINCT FROM p.target_product_version_uuid
   OR d.target_investigation_version_uuid IS DISTINCT FROM p.target_investigation_version_uuid
   OR d.clock_code<>NEW.clock_code OR NEW.effective_at<p.effective_at OR NEW.effective_at<d.decided_at THEN
   RAISE EXCEPTION 'New SLARule requires approved exact-target/clock dossier and valid temporal order';
 END IF;
 IF NOT maintenance.sla_pause_policy_is_valid(NEW.pause_allowed,NEW.pause_policy_payload)
   OR NOT maintenance.sla_warning_policy_is_valid(NEW.warning_policy_payload,NEW.target_duration)
   OR NOT maintenance.sla_breach_policy_is_valid(NEW.breach_policy_payload)
   OR NOT maintenance.sla_escalation_policy_is_valid(NEW.escalation_policy_payload) THEN
   RAISE EXCEPTION 'SLARule v0.1 policy payload invalid';
 END IF;
 IF NEW.target_duration IS NOT NULL AND NOT maintenance.temporal_fixed_interval_is_valid(NEW.target_duration) THEN
   RAISE EXCEPTION 'SLARule target duration must be fixed-duration interval';
 END IF;
 IF NEW.time_basis='business_calendar' THEN
   SELECT * INTO cal FROM maintenance.sla_calendar_version WHERE sla_calendar_version_uuid=NEW.sla_calendar_version_uuid;
   IF NOT FOUND OR cal.effective_from>NEW.effective_at
     OR (cal.effective_to IS NOT NULL AND NEW.effective_at>=cal.effective_to) THEN
     RAISE EXCEPTION 'Business-calendar rule requires calendar valid at rule effective_at';
   END IF;
 END IF;
 IF NEW.time_basis='fixed_deadline' THEN
   SELECT * INTO f FROM maintenance.fixed_deadline_source WHERE fixed_deadline_source_uuid=NEW.fixed_deadline_source_uuid;
   IF NOT FOUND OR f.temporal_calibration_dossier_uuid<>NEW.temporal_calibration_dossier_uuid THEN
     RAISE EXCEPTION 'Fixed-deadline rule requires matching structured source';
   END IF;
 ELSE
   IF NEW.fixed_deadline_source_uuid IS NOT NULL THEN RAISE EXCEPTION 'Duration SLA cannot bind fixed deadline source'; END IF;
 END IF;
 RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_sla_rule_v01 ON maintenance.sla_rule;
CREATE TRIGGER tr_sla_rule_v01 BEFORE INSERT ON maintenance.sla_rule
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_rule_v01();

CREATE OR REPLACE FUNCTION maintenance.assert_sla_rule_candidate_match()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE selected jsonb;
BEGIN
 IF maintenance.temporal_object_is_grandfathered('sla_rule',NEW.sla_rule_uuid) THEN RETURN NULL; END IF;
 SELECT candidate_payload INTO selected FROM maintenance.temporal_calibration_candidate
  WHERE temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid AND disposition='selected';
 IF selected IS DISTINCT FROM maintenance.sla_rule_calibration_snapshot(NEW.sla_rule_uuid) THEN
   RAISE EXCEPTION 'SLARule must equal selected candidate snapshot';
 END IF;
 RETURN NULL;
END
$fn$;
DROP TRIGGER IF EXISTS tr_sla_rule_candidate_match ON maintenance.sla_rule;
CREATE CONSTRAINT TRIGGER tr_sla_rule_candidate_match AFTER INSERT ON maintenance.sla_rule
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_rule_candidate_match();

CREATE OR REPLACE FUNCTION maintenance.sla_nominal_due_at(p_rule uuid,p_start timestamptz)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $fn$
DECLARE r maintenance.sla_rule%ROWTYPE; f maintenance.fixed_deadline_source%ROWTYPE; secs numeric;
BEGIN
 SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=p_rule;
 IF NOT FOUND THEN RETURN NULL; END IF;
 IF r.time_basis='elapsed_time' THEN RETURN p_start+r.target_duration; END IF;
 IF r.time_basis='business_calendar' THEN
   secs:=extract(epoch from r.target_duration);
   RETURN maintenance.sla_calendar_add_open_seconds(r.sla_calendar_version_uuid,p_start,secs);
 END IF;
 SELECT * INTO f FROM maintenance.fixed_deadline_source WHERE fixed_deadline_source_uuid=r.fixed_deadline_source_uuid;
 IF f.time_precision='timestamp' THEN RETURN f.deadline_at; END IF;
 IF f.time_precision='date' AND f.timezone_name IS NOT NULL AND f.date_boundary_policy='end_of_local_date' THEN
   RETURN ((f.deadline_date+1)::text||' 00:00')::timestamp AT TIME ZONE f.timezone_name - interval '1 microsecond';
 END IF;
 RAISE EXCEPTION 'FIXED_DEADLINE_DATE_PRECISION_NOT_EXECUTABLE';
END
$fn$;
