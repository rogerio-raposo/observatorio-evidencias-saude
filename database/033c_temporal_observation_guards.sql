-- OES migration 033c — validators, lifecycle and integrity guards

CREATE OR REPLACE FUNCTION maintenance.jsonb_contains_forbidden_temporal_keys(p_payload jsonb)
RETURNS boolean LANGUAGE plpgsql IMMUTABLE AS $fn$
DECLARE k text; v jsonb; e jsonb;
BEGIN
  IF p_payload IS NULL THEN RETURN false; END IF;
  IF jsonb_typeof(p_payload)='object' THEN
    FOR k,v IN SELECT key,value FROM jsonb_each(p_payload) LOOP
      IF lower(k) IN ('cadence','due','overdue','breach','grace','warning','sla','compliance','penalty','escalation') THEN
        RETURN true;
      END IF;
      IF maintenance.jsonb_contains_forbidden_temporal_keys(v) THEN RETURN true; END IF;
    END LOOP;
  ELSIF jsonb_typeof(p_payload)='array' THEN
    FOR e IN SELECT value FROM jsonb_array_elements(p_payload) LOOP
      IF maintenance.jsonb_contains_forbidden_temporal_keys(e) THEN RETURN true; END IF;
    END LOOP;
  END IF;
  RETURN false;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_measurement_schedule_payload_is_valid(p jsonb)
RETURNS boolean LANGUAGE plpgsql STABLE AS $fn$
DECLARE
  root_key text;
  item jsonb;
  item_key text;
  n integer := 0;
  expected_no integer := 1;
  seen_nos integer[] := ARRAY[]::integer[];
  seen_instants timestamptz[] := ARRAY[]::timestamptz[];
  opp_no integer;
  planned_text text;
  planned_ts timestamptz;
BEGIN
  IF p IS NULL OR jsonb_typeof(p)<>'object' OR maintenance.jsonb_contains_forbidden_temporal_keys(p) THEN RETURN false; END IF;
  IF p->>'schema'<>'oes.temporal_opportunity_set/0.1' THEN RETURN false; END IF;
  IF p->>'schedule_kind'<>'finite_opportunity_set' THEN RETURN false; END IF;
  IF COALESCE((p->>'non_normative')::boolean,false)<>true THEN RETURN false; END IF;
  IF COALESCE(NULLIF(trim(p->>'rationale'),''),'')='' THEN RETURN false; END IF;
  IF jsonb_typeof(p->'opportunities')<>'array' OR jsonb_array_length(p->'opportunities')=0 THEN RETURN false; END IF;

  FOR root_key IN SELECT jsonb_object_keys(p) LOOP
    IF root_key NOT IN ('schema','non_normative','schedule_kind','rationale','opportunities','timezone_name','note') THEN RETURN false; END IF;
  END LOOP;

  FOR item IN SELECT value FROM jsonb_array_elements(p->'opportunities') LOOP
    IF jsonb_typeof(item)<>'object' THEN RETURN false; END IF;
    FOR item_key IN SELECT jsonb_object_keys(item) LOOP
      IF item_key NOT IN ('opportunity_no','planned_for') THEN RETURN false; END IF;
    END LOOP;
    IF NOT (item ? 'opportunity_no') OR NOT (item ? 'planned_for') THEN RETURN false; END IF;
    IF jsonb_typeof(item->'opportunity_no')<>'number' OR jsonb_typeof(item->'planned_for')<>'string' THEN RETURN false; END IF;
    BEGIN
      opp_no := (item->>'opportunity_no')::integer;
    EXCEPTION WHEN others THEN RETURN false;
    END;
    IF opp_no<>expected_no OR opp_no<1 OR opp_no=ANY(seen_nos) THEN RETURN false; END IF;
    planned_text := item->>'planned_for';
    IF planned_text !~ '(Z|[+-][0-9]{2}:[0-9]{2})

CREATE OR REPLACE FUNCTION maintenance.temporal_source_semantics_payload_is_valid(p jsonb)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $fn$
SELECT p IS NOT NULL
   AND jsonb_typeof(p)='object'
   AND p->>'schema_version'='0.1'
   AND jsonb_typeof(p->'semantic_codes')='array'
   AND jsonb_array_length(p->'semantic_codes') > 0
   AND COALESCE(NULLIF(trim(p->>'identifier_semantic'),''),'') <> ''
   AND COALESCE(NULLIF(trim(p->>'source_class'),''),'') <> ''
   AND NOT maintenance.jsonb_contains_forbidden_temporal_keys(p);
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_measurement_effort_payload_is_valid(p jsonb)
RETURNS boolean LANGUAGE plpgsql IMMUTABLE AS $fn$
DECLARE k text; v jsonb;
BEGIN
  IF p IS NULL OR jsonb_typeof(p)<>'object' OR maintenance.jsonb_contains_forbidden_temporal_keys(p) THEN RETURN false; END IF;
  FOR k,v IN SELECT key,value FROM jsonb_each(p) LOOP
    IF k NOT IN ('operator_minutes','machine_elapsed_seconds','retry_count','handoff_count','note') THEN RETURN false; END IF;
    IF k IN ('operator_minutes','machine_elapsed_seconds','retry_count','handoff_count') THEN
      IF jsonb_typeof(v)<>'number' OR (v::text)::numeric < 0 THEN RETURN false; END IF;
    ELSIF k='note' AND jsonb_typeof(v)<>'string' THEN RETURN false;
    END IF;
  END LOOP;
  RETURN true;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_artifact_is_active(p_uuid uuid)
RETURNS boolean LANGUAGE sql STABLE AS $fn$
SELECT EXISTS(SELECT 1 FROM artifact.artifact a WHERE a.artifact_uuid=p_uuid AND a.status='active');
$fn$;

CREATE OR REPLACE FUNCTION maintenance.reject_temporal_row_mutation()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  RAISE EXCEPTION '% is append-only/immutable', TG_TABLE_SCHEMA||'.'||TG_TABLE_NAME;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_plan_write()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE p maintenance.temporal_observation_plan%ROWTYPE;
BEGIN
  IF TG_OP='INSERT' THEN
    IF NOT maintenance.temporal_artifact_is_active(NEW.specification_artifact_uuid) THEN
      RAISE EXCEPTION 'specification artifact must be active';
    END IF;
    IF NEW.supersedes_observation_plan_uuid IS NOT NULL THEN
      SELECT * INTO p FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid=NEW.supersedes_observation_plan_uuid;
      IF NOT FOUND OR p.plan_code<>NEW.plan_code
         OR p.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
         OR p.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid THEN
        RAISE EXCEPTION 'plan supersession must preserve plan family and exact target';
      END IF;
    END IF;
    RETURN NEW;
  END IF;
  IF (to_jsonb(NEW)-'record_status') IS DISTINCT FROM (to_jsonb(OLD)-'record_status') THEN
    RAISE EXCEPTION 'material plan fields are immutable';
  END IF;
  IF NOT (OLD.record_status='active' AND NEW.record_status IN ('superseded','invalidated')) THEN
    RAISE EXCEPTION 'invalid plan lifecycle transition % -> %',OLD.record_status,NEW.record_status;
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_plan_write ON maintenance.temporal_observation_plan;
CREATE TRIGGER tr_temporal_plan_write
BEFORE INSERT OR UPDATE ON maintenance.temporal_observation_plan
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_plan_write();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_source_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF NOT maintenance.temporal_source_semantics_payload_is_valid(NEW.time_semantics_payload) THEN
    RAISE EXCEPTION 'invalid source semantics payload';
  END IF;
  IF NEW.source_definition_artifact_uuid IS NOT NULL
     AND NOT maintenance.temporal_artifact_is_active(NEW.source_definition_artifact_uuid) THEN
    RAISE EXCEPTION 'source definition artifact must be active';
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_source_insert ON maintenance.temporal_observation_source;
CREATE TRIGGER tr_temporal_source_insert
BEFORE INSERT ON maintenance.temporal_observation_source
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_source_insert();

DROP TRIGGER IF EXISTS tr_temporal_source_immutable ON maintenance.temporal_observation_source;
CREATE TRIGGER tr_temporal_source_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_source
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.temporal_observation_authority_state(
  p_epoch uuid,p_domain text,p_as_of timestamptz DEFAULT CURRENT_TIMESTAMP
) RETURNS text LANGUAGE plpgsql STABLE AS $fn$
DECLARE latest_time timestamptz; n integer; latest_decision text;
BEGIN
  SELECT max(decided_at) INTO latest_time
  FROM maintenance.temporal_observation_authority
  WHERE observation_epoch_uuid=p_epoch AND authority_domain=p_domain AND decided_at<=p_as_of;
  IF latest_time IS NULL THEN RETURN 'missing'; END IF;
  SELECT count(*), min(decision) INTO n,latest_decision
  FROM maintenance.temporal_observation_authority
  WHERE observation_epoch_uuid=p_epoch AND authority_domain=p_domain AND decided_at=latest_time;
  IF n<>1 THEN RETURN 'conflict'; END IF;
  RETURN latest_decision;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_authority_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE eplan uuid;
BEGIN
  IF NOT maintenance.temporal_artifact_is_active(NEW.decision_artifact_uuid) THEN
    RAISE EXCEPTION 'authority decision artifact must be active';
  END IF;
  IF NEW.observation_epoch_uuid IS NOT NULL THEN
    SELECT observation_plan_uuid INTO eplan FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid=NEW.observation_epoch_uuid;
    IF eplan IS DISTINCT FROM NEW.observation_plan_uuid THEN RAISE EXCEPTION 'authority epoch/plan scope mismatch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_authority_insert ON maintenance.temporal_observation_authority;
CREATE TRIGGER tr_temporal_authority_insert
BEFORE INSERT ON maintenance.temporal_observation_authority
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_authority_insert();
DROP TRIGGER IF EXISTS tr_temporal_authority_immutable ON maintenance.temporal_observation_authority;
CREATE TRIGGER tr_temporal_authority_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_authority
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_epoch_source_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE ep_plan uuid; src_plan uuid; inc text; req boolean; planrow maintenance.temporal_observation_plan%ROWTYPE;
BEGIN
  SELECT observation_plan_uuid INTO ep_plan FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid=NEW.observation_epoch_uuid;
  SELECT observation_plan_uuid,inclusion_status,runtime_connectivity_required
    INTO src_plan,inc,req
  FROM maintenance.temporal_observation_source WHERE observation_source_uuid=NEW.observation_source_uuid;
  IF ep_plan IS NULL OR src_plan IS NULL OR ep_plan<>src_plan THEN RAISE EXCEPTION 'epoch/source plan mismatch'; END IF;
  IF inc<>'included' THEN RAISE EXCEPTION 'epoch source must be included'; END IF;
  IF NOT maintenance.temporal_artifact_is_active(NEW.schedule_definition_artifact_uuid) THEN RAISE EXCEPTION 'schedule artifact must be active'; END IF;
  IF NEW.query_strategy_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.query_strategy_artifact_uuid) THEN RAISE EXCEPTION 'query artifact must be active'; END IF;
  IF NEW.interface_config_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.interface_config_artifact_uuid) THEN RAISE EXCEPTION 'interface artifact must be active'; END IF;
  IF NEW.baseline_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.baseline_artifact_uuid) THEN RAISE EXCEPTION 'baseline artifact must be active'; END IF;
  IF NOT maintenance.temporal_measurement_schedule_payload_is_valid(NEW.measurement_schedule_payload) THEN RAISE EXCEPTION 'invalid non-normative schedule payload'; END IF;
  SELECT * INTO planrow FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid=ep_plan;
  IF NEW.measurement_investigation_version_uuid IS NOT NULL THEN
    IF planrow.target_investigation_version_uuid IS NOT NULL
       AND NEW.measurement_investigation_version_uuid<>planrow.target_investigation_version_uuid THEN
      RAISE EXCEPTION 'measurement Investigation must equal target Investigation';
    END IF;
    IF planrow.target_product_version_uuid IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM product.investigation_link l
      WHERE l.product_version_uuid=planrow.target_product_version_uuid
        AND l.investigation_version_uuid=NEW.measurement_investigation_version_uuid
    ) THEN RAISE EXCEPTION 'measurement Investigation is not linked to target ProductVersion'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_epoch_source_insert ON maintenance.temporal_observation_epoch_source;
CREATE TRIGGER tr_temporal_epoch_source_insert
BEFORE INSERT ON maintenance.temporal_observation_epoch_source
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_epoch_source_insert();
DROP TRIGGER IF EXISTS tr_temporal_epoch_source_immutable ON maintenance.temporal_observation_epoch_source;
CREATE TRIGGER tr_temporal_epoch_source_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_epoch_source
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.temporal_target_is_current(p_plan uuid)
RETURNS boolean LANGUAGE sql STABLE AS $fn$
SELECT EXISTS(
  SELECT 1 FROM maintenance.temporal_observation_plan p
  JOIN core.entity_version ev
    ON ev.version_uuid=COALESCE(p.target_product_version_uuid,p.target_investigation_version_uuid)
  WHERE p.observation_plan_uuid=p_plan AND ev.version_status='current'
);
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_epoch_opportunity_set_matches_schedule(p_epoch_source uuid)
RETURNS boolean LANGUAGE sql STABLE AS $fn$
WITH es AS (
  SELECT measurement_schedule_payload AS p
  FROM maintenance.temporal_observation_epoch_source
  WHERE epoch_source_uuid=p_epoch_source
), payload AS (
  SELECT (x->>'opportunity_no')::integer AS opportunity_no,
         (x->>'planned_for')::timestamptz AS planned_for
  FROM es CROSS JOIN LATERAL jsonb_array_elements(es.p->'opportunities') x
), rows_ AS (
  SELECT opportunity_no,planned_for
  FROM maintenance.temporal_measurement_opportunity
  WHERE epoch_source_uuid=p_epoch_source
)
SELECT maintenance.temporal_measurement_schedule_payload_is_valid((SELECT p FROM es))
   AND (SELECT count(*) FROM payload)=(SELECT count(*) FROM rows_)
   AND NOT EXISTS(
     (SELECT opportunity_no,planned_for FROM payload EXCEPT SELECT opportunity_no,planned_for FROM rows_)
     UNION ALL
     (SELECT opportunity_no,planned_for FROM rows_ EXCEPT SELECT opportunity_no,planned_for FROM payload)
   );
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_observation_design_frozen_at(p_epoch uuid)
RETURNS timestamptz LANGUAGE sql STABLE AS $fn$
SELECT GREATEST(
  e.created_at,
  COALESCE((SELECT max(es.created_at) FROM maintenance.temporal_observation_epoch_source es WHERE es.observation_epoch_uuid=e.observation_epoch_uuid),e.created_at),
  COALESCE((SELECT max(o.created_at)
            FROM maintenance.temporal_measurement_opportunity o
            JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
            WHERE es.observation_epoch_uuid=e.observation_epoch_uuid),e.created_at)
)
FROM maintenance.temporal_observation_epoch e
WHERE e.observation_epoch_uuid=p_epoch;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_epoch_lifecycle()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE
  req_bad integer;
  src_n integer;
  auth_state text;
  auth_time timestamptz;
  frozen_at timestamptz;
  mismatch_n integer;
  artifact_bad integer;
  unresolved_n integer;
  material_dev_n integer;

BEGIN
  IF TG_OP='INSERT' THEN
    IF NOT maintenance.temporal_artifact_is_active(NEW.measurement_design_artifact_uuid) THEN RAISE EXCEPTION 'measurement design artifact must be active'; END IF;
    IF NEW.epoch_status<>'draft' THEN RAISE EXCEPTION 'epoch must be inserted as draft'; END IF;
    RETURN NEW;
  END IF;
  IF OLD.observation_plan_uuid<>NEW.observation_plan_uuid OR OLD.epoch_code<>NEW.epoch_code
     OR OLD.measurement_design_artifact_uuid<>NEW.measurement_design_artifact_uuid
     OR OLD.start_boundary_at<>NEW.start_boundary_at OR OLD.review_boundary_at<>NEW.review_boundary_at
     OR OLD.created_at<>NEW.created_at OR OLD.created_by<>NEW.created_by THEN
    RAISE EXCEPTION 'epoch design fields are immutable';
  END IF;
  IF NEW.epoch_status=OLD.epoch_status THEN RETURN NEW; END IF;
  IF NEW.epoch_status IN ('authorized_non_normative','active') THEN
    IF NOT maintenance.temporal_target_is_current(NEW.observation_plan_uuid) THEN RAISE EXCEPTION 'target is not current'; END IF;
    SELECT count(*) INTO src_n FROM maintenance.temporal_observation_epoch_source WHERE observation_epoch_uuid=NEW.observation_epoch_uuid;
    IF src_n=0 THEN RAISE EXCEPTION 'epoch requires at least one source'; END IF;
    SELECT count(*) INTO req_bad
    FROM maintenance.temporal_observation_epoch_source es
    JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
    WHERE es.observation_epoch_uuid=NEW.observation_epoch_uuid
      AND s.runtime_connectivity_required AND es.runtime_connectivity_status<>'verified';
    IF req_bad>0 THEN RAISE EXCEPTION 'required runtime connectivity is not verified'; END IF;
    auth_state:=maintenance.temporal_observation_authority_state(NEW.observation_epoch_uuid,'operational_execution',CURRENT_TIMESTAMP);
    IF auth_state<>'approved' THEN RAISE EXCEPTION 'operational execution authority state is %',auth_state; END IF;

    SELECT count(*) INTO artifact_bad
    FROM maintenance.temporal_observation_epoch_source es
    WHERE es.observation_epoch_uuid=NEW.observation_epoch_uuid
      AND (
        NOT maintenance.temporal_artifact_is_active(es.schedule_definition_artifact_uuid)
        OR (es.query_strategy_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(es.query_strategy_artifact_uuid))
        OR (es.interface_config_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(es.interface_config_artifact_uuid))
        OR (es.baseline_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(es.baseline_artifact_uuid))
      );
    IF artifact_bad>0 OR NOT maintenance.temporal_artifact_is_active(NEW.measurement_design_artifact_uuid) THEN
      RAISE EXCEPTION 'controlling artifact is not active';
    END IF;
  END IF;
  IF OLD.epoch_status='draft' AND NEW.epoch_status='authorized_non_normative' THEN
    SELECT count(*) INTO mismatch_n
    FROM maintenance.temporal_observation_epoch_source es
    WHERE es.observation_epoch_uuid=NEW.observation_epoch_uuid
      AND NOT maintenance.temporal_epoch_opportunity_set_matches_schedule(es.epoch_source_uuid);
    IF mismatch_n>0 THEN RAISE EXCEPTION 'frozen opportunity set is not fully materialized'; END IF;
    frozen_at:=maintenance.temporal_observation_design_frozen_at(NEW.observation_epoch_uuid);
    SELECT max(decided_at) INTO auth_time
    FROM maintenance.temporal_observation_authority
    WHERE observation_epoch_uuid=NEW.observation_epoch_uuid
      AND authority_domain='operational_execution'
      AND decided_at<=CURRENT_TIMESTAMP;
    IF auth_time IS NULL OR auth_time<frozen_at THEN
      RAISE EXCEPTION 'operational authority predates design freeze';
    END IF;
    RETURN NEW;
  END IF;
  IF OLD.epoch_status='authorized_non_normative' AND NEW.epoch_status='active' THEN
    IF NEW.started_at IS NULL THEN RAISE EXCEPTION 'active epoch requires started_at'; END IF;
    RETURN NEW;
  END IF;
  IF OLD.epoch_status='active' AND NEW.epoch_status='completed' THEN
    IF NEW.completed_at IS NULL OR NEW.completed_at<NEW.review_boundary_at THEN RAISE EXCEPTION 'completion requires completed_at at/after review boundary'; END IF;
    IF NOT maintenance.temporal_target_is_current(NEW.observation_plan_uuid) THEN RAISE EXCEPTION 'target drift blocks completion'; END IF;
    SELECT count(*) INTO unresolved_n
    FROM maintenance.temporal_measurement_opportunity o
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    LEFT JOIN maintenance.temporal_measurement_opportunity_resolution r USING(measurement_opportunity_uuid)
    WHERE es.observation_epoch_uuid=NEW.observation_epoch_uuid AND r.opportunity_resolution_uuid IS NULL;
    IF unresolved_n>0 THEN RAISE EXCEPTION 'epoch has unresolved opportunities'; END IF;
    SELECT count(*) INTO material_dev_n
    FROM maintenance.temporal_observation_deviation
    WHERE observation_epoch_uuid=NEW.observation_epoch_uuid
      AND materiality IN ('new_epoch_required','invalidating');
    IF material_dev_n>0 THEN RAISE EXCEPTION 'material deviation blocks completion'; END IF;
    RETURN NEW;
  END IF;
  IF OLD.epoch_status IN ('draft','authorized_non_normative','active') AND NEW.epoch_status='invalidated' THEN RETURN NEW; END IF;
  RAISE EXCEPTION 'invalid epoch lifecycle transition % -> %',OLD.epoch_status,NEW.epoch_status;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_epoch_lifecycle ON maintenance.temporal_observation_epoch;
CREATE TRIGGER tr_temporal_epoch_lifecycle
BEFORE INSERT OR UPDATE ON maintenance.temporal_observation_epoch
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_epoch_lifecycle();
DROP TRIGGER IF EXISTS tr_temporal_epoch_no_delete ON maintenance.temporal_observation_epoch;
CREATE TRIGGER tr_temporal_epoch_no_delete
BEFORE DELETE ON maintenance.temporal_observation_epoch
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_opportunity_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE
  e maintenance.temporal_observation_epoch%ROWTYPE;
  payload jsonb;
  expected_ts timestamptz;
BEGIN
  SELECT ep.*,es.measurement_schedule_payload INTO e,payload
  FROM maintenance.temporal_observation_epoch_source es
  JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
  WHERE es.epoch_source_uuid=NEW.epoch_source_uuid;
  IF e.observation_epoch_uuid IS NULL THEN RAISE EXCEPTION 'epoch source missing'; END IF;
  IF e.epoch_status<>'draft' THEN RAISE EXCEPTION 'opportunities may be materialized only while epoch is draft'; END IF;
  IF NOT maintenance.temporal_target_is_current(e.observation_plan_uuid) THEN RAISE EXCEPTION 'target drift blocks opportunity materialization'; END IF;
  SELECT (x->>'planned_for')::timestamptz INTO expected_ts
  FROM jsonb_array_elements(payload->'opportunities') x
  WHERE (x->>'opportunity_no')::integer=NEW.opportunity_no;
  IF expected_ts IS NULL THEN RAISE EXCEPTION 'opportunity number is not present in canonical payload'; END IF;
  IF expected_ts IS DISTINCT FROM NEW.planned_for THEN RAISE EXCEPTION 'opportunity timestamp does not match canonical payload'; END IF;
  IF NEW.planned_for<e.start_boundary_at OR NEW.planned_for>e.review_boundary_at THEN RAISE EXCEPTION 'opportunity outside epoch boundary'; END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_opportunity_insert ON maintenance.temporal_measurement_opportunity;
CREATE TRIGGER tr_temporal_opportunity_insert BEFORE INSERT ON maintenance.temporal_measurement_opportunity
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_opportunity_insert();
DROP TRIGGER IF EXISTS tr_temporal_opportunity_immutable ON maintenance.temporal_measurement_opportunity;
CREATE TRIGGER tr_temporal_opportunity_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_opportunity
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_measurement_event_append()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE max_attempt integer; last_status text; plan_uuid uuid; inv uuid; search_inv uuid;
BEGIN
  SELECT max(attempt_no) INTO max_attempt FROM maintenance.temporal_measurement_event WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid;
  IF NEW.attempt_no<>COALESCE(max_attempt,0)+1 THEN RAISE EXCEPTION 'attempt_no must be contiguous'; END IF;
  IF EXISTS(SELECT 1 FROM maintenance.temporal_measurement_opportunity_resolution WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid) THEN
    RAISE EXCEPTION 'resolved opportunity cannot receive new attempt';
  END IF;
  IF max_attempt IS NOT NULL THEN
    SELECT execution_status INTO last_status FROM maintenance.temporal_measurement_event
    WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid AND attempt_no=max_attempt;
    IF last_status='completed' THEN RAISE EXCEPTION 'completed opportunity cannot be retried'; END IF;
  END IF;
  SELECT ep.observation_plan_uuid,es.measurement_investigation_version_uuid INTO plan_uuid,inv
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
  WHERE o.measurement_opportunity_uuid=NEW.measurement_opportunity_uuid AND ep.epoch_status='active';
  IF plan_uuid IS NULL THEN RAISE EXCEPTION 'attempt requires active epoch'; END IF;
  IF NOT maintenance.temporal_target_is_current(plan_uuid) THEN RAISE EXCEPTION 'target drift blocks new attempt'; END IF;
  IF NOT maintenance.temporal_measurement_effort_payload_is_valid(NEW.effort_payload) THEN RAISE EXCEPTION 'invalid effort payload'; END IF;
  IF NEW.failure_evidence_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.failure_evidence_artifact_uuid) THEN
    RAISE EXCEPTION 'failure evidence artifact must be active';
  END IF;
  IF NEW.scientific_search_uuid IS NOT NULL THEN
    SELECT investigation_version_uuid INTO search_inv FROM investigation.search WHERE search_uuid=NEW.scientific_search_uuid;
    IF inv IS NULL OR search_inv IS DISTINCT FROM inv THEN RAISE EXCEPTION 'scientific Search scope mismatch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_event_append ON maintenance.temporal_measurement_event;
CREATE TRIGGER tr_temporal_event_append BEFORE INSERT ON maintenance.temporal_measurement_event
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_measurement_event_append();
DROP TRIGGER IF EXISTS tr_temporal_event_immutable ON maintenance.temporal_measurement_event;
CREATE TRIGGER tr_temporal_event_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_event
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_resolution_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE st text; event_opp uuid; epoch_status text;
BEGIN
  IF NEW.terminal_measurement_event_uuid IS NOT NULL THEN
    SELECT execution_status,measurement_opportunity_uuid INTO st,event_opp
    FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid=NEW.terminal_measurement_event_uuid;
    IF event_opp IS DISTINCT FROM NEW.measurement_opportunity_uuid THEN RAISE EXCEPTION 'terminal event belongs to different opportunity'; END IF;
  END IF;
  IF NEW.resolution_status='completed' AND st IS DISTINCT FROM 'completed' THEN RAISE EXCEPTION 'completed resolution requires completed event'; END IF;
  IF NEW.resolution_status='failed_closed' AND st IS DISTINCT FROM 'failed' THEN RAISE EXCEPTION 'failed_closed requires failed event'; END IF;
  IF NEW.resolution_status='indeterminate_closed' AND st IS DISTINCT FROM 'indeterminate' THEN RAISE EXCEPTION 'indeterminate_closed requires indeterminate event'; END IF;
  IF NEW.resolution_status='not_executed' THEN
    IF NEW.terminal_measurement_event_uuid IS NOT NULL OR EXISTS(
      SELECT 1 FROM maintenance.temporal_measurement_event WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid
    ) THEN RAISE EXCEPTION 'not_executed requires zero attempts'; END IF;
  END IF;
  IF NEW.resolution_status='invalidated' THEN
    SELECT ep.epoch_status INTO epoch_status
    FROM maintenance.temporal_measurement_opportunity o
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
    WHERE o.measurement_opportunity_uuid=NEW.measurement_opportunity_uuid;
    IF epoch_status<>'invalidated' THEN RAISE EXCEPTION 'invalidated resolution requires invalidated epoch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_resolution_insert ON maintenance.temporal_measurement_opportunity_resolution;
CREATE TRIGGER tr_temporal_resolution_insert BEFORE INSERT ON maintenance.temporal_measurement_opportunity_resolution
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_resolution_insert();
DROP TRIGGER IF EXISTS tr_temporal_resolution_immutable ON maintenance.temporal_measurement_opportunity_resolution;
CREATE TRIGGER tr_temporal_resolution_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_opportunity_resolution
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_item_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE est text; search_uuid uuid; hit_search uuid; epoch_uuid uuid; prior_n integer;
BEGIN
  SELECT execution_status,scientific_search_uuid INTO est,search_uuid
  FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid=NEW.measurement_event_uuid;
  IF est NOT IN ('completed','partial') THEN RAISE EXCEPTION 'items require completed or partial event'; END IF;
  IF NEW.search_hit_uuid IS NOT NULL THEN
    SELECT sh.search_uuid INTO hit_search FROM investigation.search_hit sh WHERE sh.search_hit_uuid=NEW.search_hit_uuid;
    IF search_uuid IS NULL OR hit_search IS DISTINCT FROM search_uuid THEN RAISE EXCEPTION 'SearchHit does not derive from event Search'; END IF;
  END IF;
  SELECT ep.observation_epoch_uuid INTO epoch_uuid
  FROM maintenance.temporal_measurement_event me
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
  WHERE me.measurement_event_uuid=NEW.measurement_event_uuid;
  SELECT count(*) INTO prior_n
  FROM maintenance.temporal_measurement_item mi
  JOIN maintenance.temporal_measurement_event me USING(measurement_event_uuid)
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE es.observation_epoch_uuid=epoch_uuid AND mi.source_identifier=NEW.source_identifier;
  IF NEW.item_state='new_to_epoch' AND prior_n>0 THEN RAISE EXCEPTION 'reobserved identifier cannot be new_to_epoch'; END IF;
  IF NEW.item_state IN ('reobserved','updated_record') AND prior_n=0 THEN RAISE EXCEPTION 'reobserved/updated identifier requires prior observation'; END IF;
  IF NEW.source_record_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.source_record_artifact_uuid) THEN
    RAISE EXCEPTION 'source record artifact must be active';
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_item_insert ON maintenance.temporal_measurement_item;
CREATE TRIGGER tr_temporal_item_insert BEFORE INSERT ON maintenance.temporal_measurement_item
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_item_insert();
DROP TRIGGER IF EXISTS tr_temporal_item_immutable ON maintenance.temporal_measurement_item;
CREATE TRIGGER tr_temporal_item_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_item
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_timepoint_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE semantics jsonb;
BEGIN
  SELECT s.time_semantics_payload INTO semantics
  FROM maintenance.temporal_measurement_item mi
  JOIN maintenance.temporal_measurement_event me USING(measurement_event_uuid)
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  WHERE mi.measurement_item_uuid=NEW.measurement_item_uuid;
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(semantics->'semantic_codes') x WHERE x=NEW.semantic_code) THEN
    RAISE EXCEPTION 'source time semantic % is not declared',NEW.semantic_code;
  END IF;
  IF NEW.source_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.source_artifact_uuid) THEN
    RAISE EXCEPTION 'timepoint artifact must be active';
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_timepoint_insert ON maintenance.temporal_measurement_item_timepoint;
CREATE TRIGGER tr_temporal_timepoint_insert BEFORE INSERT ON maintenance.temporal_measurement_item_timepoint
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_timepoint_insert();
DROP TRIGGER IF EXISTS tr_temporal_timepoint_immutable ON maintenance.temporal_measurement_item_timepoint;
CREATE TRIGGER tr_temporal_timepoint_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_item_timepoint
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_event_artifact_write()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF NOT maintenance.temporal_artifact_is_active(NEW.artifact_uuid) THEN RAISE EXCEPTION 'event artifact must be active'; END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_event_artifact_insert ON maintenance.temporal_measurement_event_artifact;
CREATE TRIGGER tr_temporal_event_artifact_insert BEFORE INSERT ON maintenance.temporal_measurement_event_artifact
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_event_artifact_write();
DROP TRIGGER IF EXISTS tr_temporal_event_artifact_immutable ON maintenance.temporal_measurement_event_artifact;
CREATE TRIGGER tr_temporal_event_artifact_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_event_artifact
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_deviation_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE op_epoch uuid; ev_epoch uuid;
BEGIN
  IF NEW.measurement_opportunity_uuid IS NOT NULL THEN
    SELECT es.observation_epoch_uuid INTO op_epoch
    FROM maintenance.temporal_measurement_opportunity o JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE o.measurement_opportunity_uuid=NEW.measurement_opportunity_uuid;
    IF op_epoch IS DISTINCT FROM NEW.observation_epoch_uuid THEN RAISE EXCEPTION 'deviation opportunity/epoch mismatch'; END IF;
  END IF;
  IF NEW.measurement_event_uuid IS NOT NULL THEN
    SELECT es.observation_epoch_uuid INTO ev_epoch
    FROM maintenance.temporal_measurement_event me
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE me.measurement_event_uuid=NEW.measurement_event_uuid;
    IF ev_epoch IS DISTINCT FROM NEW.observation_epoch_uuid THEN RAISE EXCEPTION 'deviation event/epoch mismatch'; END IF;
    IF NEW.measurement_opportunity_uuid IS NOT NULL AND NOT EXISTS(
      SELECT 1 FROM maintenance.temporal_measurement_event
      WHERE measurement_event_uuid=NEW.measurement_event_uuid AND measurement_opportunity_uuid=NEW.measurement_opportunity_uuid
    ) THEN RAISE EXCEPTION 'deviation event/opportunity mismatch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_deviation_insert ON maintenance.temporal_observation_deviation;
CREATE TRIGGER tr_temporal_deviation_insert BEFORE INSERT ON maintenance.temporal_observation_deviation
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_deviation_insert();
DROP TRIGGER IF EXISTS tr_temporal_deviation_immutable ON maintenance.temporal_observation_deviation;
CREATE TRIGGER tr_temporal_deviation_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_deviation
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();
 THEN RETURN false; END IF;
    BEGIN
      planned_ts := planned_text::timestamptz;
    EXCEPTION WHEN others THEN RETURN false;
    END;
    IF planned_ts=ANY(seen_instants) THEN RETURN false; END IF;
    seen_nos := array_append(seen_nos,opp_no);
    seen_instants := array_append(seen_instants,planned_ts);
    expected_no := expected_no+1;
    n := n+1;
  END LOOP;
  RETURN n=jsonb_array_length(p->'opportunities');
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_source_semantics_payload_is_valid(p jsonb)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $fn$
SELECT p IS NOT NULL
   AND jsonb_typeof(p)='object'
   AND p->>'schema_version'='0.1'
   AND jsonb_typeof(p->'semantic_codes')='array'
   AND jsonb_array_length(p->'semantic_codes') > 0
   AND COALESCE(NULLIF(trim(p->>'identifier_semantic'),''),'') <> ''
   AND COALESCE(NULLIF(trim(p->>'source_class'),''),'') <> ''
   AND NOT maintenance.jsonb_contains_forbidden_temporal_keys(p);
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_measurement_effort_payload_is_valid(p jsonb)
RETURNS boolean LANGUAGE plpgsql IMMUTABLE AS $fn$
DECLARE k text; v jsonb;
BEGIN
  IF p IS NULL OR jsonb_typeof(p)<>'object' OR maintenance.jsonb_contains_forbidden_temporal_keys(p) THEN RETURN false; END IF;
  FOR k,v IN SELECT key,value FROM jsonb_each(p) LOOP
    IF k NOT IN ('operator_minutes','machine_elapsed_seconds','retry_count','handoff_count','note') THEN RETURN false; END IF;
    IF k IN ('operator_minutes','machine_elapsed_seconds','retry_count','handoff_count') THEN
      IF jsonb_typeof(v)<>'number' OR (v::text)::numeric < 0 THEN RETURN false; END IF;
    ELSIF k='note' AND jsonb_typeof(v)<>'string' THEN RETURN false;
    END IF;
  END LOOP;
  RETURN true;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.temporal_artifact_is_active(p_uuid uuid)
RETURNS boolean LANGUAGE sql STABLE AS $fn$
SELECT EXISTS(SELECT 1 FROM artifact.artifact a WHERE a.artifact_uuid=p_uuid AND a.status='active');
$fn$;

CREATE OR REPLACE FUNCTION maintenance.reject_temporal_row_mutation()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  RAISE EXCEPTION '% is append-only/immutable', TG_TABLE_SCHEMA||'.'||TG_TABLE_NAME;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_plan_write()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE p maintenance.temporal_observation_plan%ROWTYPE;
BEGIN
  IF TG_OP='INSERT' THEN
    IF NOT maintenance.temporal_artifact_is_active(NEW.specification_artifact_uuid) THEN
      RAISE EXCEPTION 'specification artifact must be active';
    END IF;
    IF NEW.supersedes_observation_plan_uuid IS NOT NULL THEN
      SELECT * INTO p FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid=NEW.supersedes_observation_plan_uuid;
      IF NOT FOUND OR p.plan_code<>NEW.plan_code
         OR p.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
         OR p.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid THEN
        RAISE EXCEPTION 'plan supersession must preserve plan family and exact target';
      END IF;
    END IF;
    RETURN NEW;
  END IF;
  IF (to_jsonb(NEW)-'record_status') IS DISTINCT FROM (to_jsonb(OLD)-'record_status') THEN
    RAISE EXCEPTION 'material plan fields are immutable';
  END IF;
  IF NOT (OLD.record_status='active' AND NEW.record_status IN ('superseded','invalidated')) THEN
    RAISE EXCEPTION 'invalid plan lifecycle transition % -> %',OLD.record_status,NEW.record_status;
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_plan_write ON maintenance.temporal_observation_plan;
CREATE TRIGGER tr_temporal_plan_write
BEFORE INSERT OR UPDATE ON maintenance.temporal_observation_plan
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_plan_write();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_source_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF NOT maintenance.temporal_source_semantics_payload_is_valid(NEW.time_semantics_payload) THEN
    RAISE EXCEPTION 'invalid source semantics payload';
  END IF;
  IF NEW.source_definition_artifact_uuid IS NOT NULL
     AND NOT maintenance.temporal_artifact_is_active(NEW.source_definition_artifact_uuid) THEN
    RAISE EXCEPTION 'source definition artifact must be active';
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_source_insert ON maintenance.temporal_observation_source;
CREATE TRIGGER tr_temporal_source_insert
BEFORE INSERT ON maintenance.temporal_observation_source
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_source_insert();

DROP TRIGGER IF EXISTS tr_temporal_source_immutable ON maintenance.temporal_observation_source;
CREATE TRIGGER tr_temporal_source_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_source
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.temporal_observation_authority_state(
  p_epoch uuid,p_domain text,p_as_of timestamptz DEFAULT CURRENT_TIMESTAMP
) RETURNS text LANGUAGE plpgsql STABLE AS $fn$
DECLARE latest_time timestamptz; n integer; latest_decision text;
BEGIN
  SELECT max(decided_at) INTO latest_time
  FROM maintenance.temporal_observation_authority
  WHERE observation_epoch_uuid=p_epoch AND authority_domain=p_domain AND decided_at<=p_as_of;
  IF latest_time IS NULL THEN RETURN 'missing'; END IF;
  SELECT count(*), min(decision) INTO n,latest_decision
  FROM maintenance.temporal_observation_authority
  WHERE observation_epoch_uuid=p_epoch AND authority_domain=p_domain AND decided_at=latest_time;
  IF n<>1 THEN RETURN 'conflict'; END IF;
  RETURN latest_decision;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_authority_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE eplan uuid;
BEGIN
  IF NOT maintenance.temporal_artifact_is_active(NEW.decision_artifact_uuid) THEN
    RAISE EXCEPTION 'authority decision artifact must be active';
  END IF;
  IF NEW.observation_epoch_uuid IS NOT NULL THEN
    SELECT observation_plan_uuid INTO eplan FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid=NEW.observation_epoch_uuid;
    IF eplan IS DISTINCT FROM NEW.observation_plan_uuid THEN RAISE EXCEPTION 'authority epoch/plan scope mismatch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_authority_insert ON maintenance.temporal_observation_authority;
CREATE TRIGGER tr_temporal_authority_insert
BEFORE INSERT ON maintenance.temporal_observation_authority
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_authority_insert();
DROP TRIGGER IF EXISTS tr_temporal_authority_immutable ON maintenance.temporal_observation_authority;
CREATE TRIGGER tr_temporal_authority_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_authority
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_epoch_source_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE ep_plan uuid; src_plan uuid; inc text; req boolean; planrow maintenance.temporal_observation_plan%ROWTYPE;
BEGIN
  SELECT observation_plan_uuid INTO ep_plan FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid=NEW.observation_epoch_uuid;
  SELECT observation_plan_uuid,inclusion_status,runtime_connectivity_required
    INTO src_plan,inc,req
  FROM maintenance.temporal_observation_source WHERE observation_source_uuid=NEW.observation_source_uuid;
  IF ep_plan IS NULL OR src_plan IS NULL OR ep_plan<>src_plan THEN RAISE EXCEPTION 'epoch/source plan mismatch'; END IF;
  IF inc<>'included' THEN RAISE EXCEPTION 'epoch source must be included'; END IF;
  IF NOT maintenance.temporal_artifact_is_active(NEW.schedule_definition_artifact_uuid) THEN RAISE EXCEPTION 'schedule artifact must be active'; END IF;
  IF NEW.query_strategy_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.query_strategy_artifact_uuid) THEN RAISE EXCEPTION 'query artifact must be active'; END IF;
  IF NEW.interface_config_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.interface_config_artifact_uuid) THEN RAISE EXCEPTION 'interface artifact must be active'; END IF;
  IF NEW.baseline_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.baseline_artifact_uuid) THEN RAISE EXCEPTION 'baseline artifact must be active'; END IF;
  IF NOT maintenance.temporal_measurement_schedule_payload_is_valid(NEW.measurement_schedule_payload) THEN RAISE EXCEPTION 'invalid non-normative schedule payload'; END IF;
  SELECT * INTO planrow FROM maintenance.temporal_observation_plan WHERE observation_plan_uuid=ep_plan;
  IF NEW.measurement_investigation_version_uuid IS NOT NULL THEN
    IF planrow.target_investigation_version_uuid IS NOT NULL
       AND NEW.measurement_investigation_version_uuid<>planrow.target_investigation_version_uuid THEN
      RAISE EXCEPTION 'measurement Investigation must equal target Investigation';
    END IF;
    IF planrow.target_product_version_uuid IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM product.investigation_link l
      WHERE l.product_version_uuid=planrow.target_product_version_uuid
        AND l.investigation_version_uuid=NEW.measurement_investigation_version_uuid
    ) THEN RAISE EXCEPTION 'measurement Investigation is not linked to target ProductVersion'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_epoch_source_insert ON maintenance.temporal_observation_epoch_source;
CREATE TRIGGER tr_temporal_epoch_source_insert
BEFORE INSERT ON maintenance.temporal_observation_epoch_source
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_epoch_source_insert();
DROP TRIGGER IF EXISTS tr_temporal_epoch_source_immutable ON maintenance.temporal_observation_epoch_source;
CREATE TRIGGER tr_temporal_epoch_source_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_epoch_source
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.temporal_target_is_current(p_plan uuid)
RETURNS boolean LANGUAGE sql STABLE AS $fn$
SELECT EXISTS(
  SELECT 1 FROM maintenance.temporal_observation_plan p
  JOIN core.entity_version ev
    ON ev.version_uuid=COALESCE(p.target_product_version_uuid,p.target_investigation_version_uuid)
  WHERE p.observation_plan_uuid=p_plan AND ev.version_status='current'
);
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_epoch_lifecycle()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE req_bad integer; src_n integer; auth_state text;
BEGIN
  IF TG_OP='INSERT' THEN
    IF NOT maintenance.temporal_artifact_is_active(NEW.measurement_design_artifact_uuid) THEN RAISE EXCEPTION 'measurement design artifact must be active'; END IF;
    IF NEW.epoch_status<>'draft' THEN RAISE EXCEPTION 'epoch must be inserted as draft'; END IF;
    RETURN NEW;
  END IF;
  IF OLD.observation_plan_uuid<>NEW.observation_plan_uuid OR OLD.epoch_code<>NEW.epoch_code
     OR OLD.measurement_design_artifact_uuid<>NEW.measurement_design_artifact_uuid
     OR OLD.start_boundary_at<>NEW.start_boundary_at OR OLD.review_boundary_at<>NEW.review_boundary_at
     OR OLD.created_at<>NEW.created_at OR OLD.created_by<>NEW.created_by THEN
    RAISE EXCEPTION 'epoch design fields are immutable';
  END IF;
  IF NEW.epoch_status=OLD.epoch_status THEN RETURN NEW; END IF;
  IF NEW.epoch_status IN ('authorized_non_normative','active') THEN
    IF NOT maintenance.temporal_target_is_current(NEW.observation_plan_uuid) THEN RAISE EXCEPTION 'target is not current'; END IF;
    SELECT count(*) INTO src_n FROM maintenance.temporal_observation_epoch_source WHERE observation_epoch_uuid=NEW.observation_epoch_uuid;
    IF src_n=0 THEN RAISE EXCEPTION 'epoch requires at least one source'; END IF;
    SELECT count(*) INTO req_bad
    FROM maintenance.temporal_observation_epoch_source es
    JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
    WHERE es.observation_epoch_uuid=NEW.observation_epoch_uuid
      AND s.runtime_connectivity_required AND es.runtime_connectivity_status<>'verified';
    IF req_bad>0 THEN RAISE EXCEPTION 'required runtime connectivity is not verified'; END IF;
    auth_state:=maintenance.temporal_observation_authority_state(NEW.observation_epoch_uuid,'operational_execution',CURRENT_TIMESTAMP);
    IF auth_state<>'approved' THEN RAISE EXCEPTION 'operational execution authority state is %',auth_state; END IF;
  END IF;
  IF OLD.epoch_status='draft' AND NEW.epoch_status='authorized_non_normative' THEN RETURN NEW; END IF;
  IF OLD.epoch_status='authorized_non_normative' AND NEW.epoch_status='active' THEN
    IF NEW.started_at IS NULL THEN RAISE EXCEPTION 'active epoch requires started_at'; END IF;
    RETURN NEW;
  END IF;
  IF OLD.epoch_status='active' AND NEW.epoch_status='completed' THEN
    IF NEW.completed_at IS NULL OR NEW.completed_at<NEW.review_boundary_at THEN RAISE EXCEPTION 'completion requires completed_at at/after review boundary'; END IF;
    IF NOT maintenance.temporal_target_is_current(NEW.observation_plan_uuid) THEN RAISE EXCEPTION 'target drift blocks completion'; END IF;
    RETURN NEW;
  END IF;
  IF OLD.epoch_status IN ('draft','authorized_non_normative','active') AND NEW.epoch_status='invalidated' THEN RETURN NEW; END IF;
  RAISE EXCEPTION 'invalid epoch lifecycle transition % -> %',OLD.epoch_status,NEW.epoch_status;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_epoch_lifecycle ON maintenance.temporal_observation_epoch;
CREATE TRIGGER tr_temporal_epoch_lifecycle
BEFORE INSERT OR UPDATE ON maintenance.temporal_observation_epoch
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_epoch_lifecycle();
DROP TRIGGER IF EXISTS tr_temporal_epoch_no_delete ON maintenance.temporal_observation_epoch;
CREATE TRIGGER tr_temporal_epoch_no_delete
BEFORE DELETE ON maintenance.temporal_observation_epoch
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_opportunity_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE e maintenance.temporal_observation_epoch%ROWTYPE;
BEGIN
  SELECT ep.* INTO e
  FROM maintenance.temporal_observation_epoch_source es
  JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
  WHERE es.epoch_source_uuid=NEW.epoch_source_uuid;
  IF e.observation_epoch_uuid IS NULL THEN RAISE EXCEPTION 'epoch source missing'; END IF;
  IF e.epoch_status<>'active' THEN RAISE EXCEPTION 'opportunity requires active epoch'; END IF;
  IF NOT maintenance.temporal_target_is_current(e.observation_plan_uuid) THEN RAISE EXCEPTION 'target drift blocks new opportunity'; END IF;
  IF NEW.planned_for<e.start_boundary_at OR NEW.planned_for>e.review_boundary_at THEN RAISE EXCEPTION 'opportunity outside epoch boundary'; END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_opportunity_insert ON maintenance.temporal_measurement_opportunity;
CREATE TRIGGER tr_temporal_opportunity_insert BEFORE INSERT ON maintenance.temporal_measurement_opportunity
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_opportunity_insert();
DROP TRIGGER IF EXISTS tr_temporal_opportunity_immutable ON maintenance.temporal_measurement_opportunity;
CREATE TRIGGER tr_temporal_opportunity_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_opportunity
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_measurement_event_append()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE max_attempt integer; last_status text; plan_uuid uuid; inv uuid; search_inv uuid;
BEGIN
  SELECT max(attempt_no) INTO max_attempt FROM maintenance.temporal_measurement_event WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid;
  IF NEW.attempt_no<>COALESCE(max_attempt,0)+1 THEN RAISE EXCEPTION 'attempt_no must be contiguous'; END IF;
  IF EXISTS(SELECT 1 FROM maintenance.temporal_measurement_opportunity_resolution WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid) THEN
    RAISE EXCEPTION 'resolved opportunity cannot receive new attempt';
  END IF;
  IF max_attempt IS NOT NULL THEN
    SELECT execution_status INTO last_status FROM maintenance.temporal_measurement_event
    WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid AND attempt_no=max_attempt;
    IF last_status='completed' THEN RAISE EXCEPTION 'completed opportunity cannot be retried'; END IF;
  END IF;
  SELECT ep.observation_plan_uuid,es.measurement_investigation_version_uuid INTO plan_uuid,inv
  FROM maintenance.temporal_measurement_opportunity o
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
  WHERE o.measurement_opportunity_uuid=NEW.measurement_opportunity_uuid AND ep.epoch_status='active';
  IF plan_uuid IS NULL THEN RAISE EXCEPTION 'attempt requires active epoch'; END IF;
  IF NOT maintenance.temporal_target_is_current(plan_uuid) THEN RAISE EXCEPTION 'target drift blocks new attempt'; END IF;
  IF NOT maintenance.temporal_measurement_effort_payload_is_valid(NEW.effort_payload) THEN RAISE EXCEPTION 'invalid effort payload'; END IF;
  IF NEW.failure_evidence_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.failure_evidence_artifact_uuid) THEN
    RAISE EXCEPTION 'failure evidence artifact must be active';
  END IF;
  IF NEW.scientific_search_uuid IS NOT NULL THEN
    SELECT investigation_version_uuid INTO search_inv FROM investigation.search WHERE search_uuid=NEW.scientific_search_uuid;
    IF inv IS NULL OR search_inv IS DISTINCT FROM inv THEN RAISE EXCEPTION 'scientific Search scope mismatch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_event_append ON maintenance.temporal_measurement_event;
CREATE TRIGGER tr_temporal_event_append BEFORE INSERT ON maintenance.temporal_measurement_event
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_measurement_event_append();
DROP TRIGGER IF EXISTS tr_temporal_event_immutable ON maintenance.temporal_measurement_event;
CREATE TRIGGER tr_temporal_event_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_event
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_resolution_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE st text; event_opp uuid; epoch_status text;
BEGIN
  IF NEW.terminal_measurement_event_uuid IS NOT NULL THEN
    SELECT execution_status,measurement_opportunity_uuid INTO st,event_opp
    FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid=NEW.terminal_measurement_event_uuid;
    IF event_opp IS DISTINCT FROM NEW.measurement_opportunity_uuid THEN RAISE EXCEPTION 'terminal event belongs to different opportunity'; END IF;
  END IF;
  IF NEW.resolution_status='completed' AND st IS DISTINCT FROM 'completed' THEN RAISE EXCEPTION 'completed resolution requires completed event'; END IF;
  IF NEW.resolution_status='failed_closed' AND st IS DISTINCT FROM 'failed' THEN RAISE EXCEPTION 'failed_closed requires failed event'; END IF;
  IF NEW.resolution_status='indeterminate_closed' AND st IS DISTINCT FROM 'indeterminate' THEN RAISE EXCEPTION 'indeterminate_closed requires indeterminate event'; END IF;
  IF NEW.resolution_status='not_executed' THEN
    IF NEW.terminal_measurement_event_uuid IS NOT NULL OR EXISTS(
      SELECT 1 FROM maintenance.temporal_measurement_event WHERE measurement_opportunity_uuid=NEW.measurement_opportunity_uuid
    ) THEN RAISE EXCEPTION 'not_executed requires zero attempts'; END IF;
  END IF;
  IF NEW.resolution_status='invalidated' THEN
    SELECT ep.epoch_status INTO epoch_status
    FROM maintenance.temporal_measurement_opportunity o
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
    WHERE o.measurement_opportunity_uuid=NEW.measurement_opportunity_uuid;
    IF epoch_status<>'invalidated' THEN RAISE EXCEPTION 'invalidated resolution requires invalidated epoch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_resolution_insert ON maintenance.temporal_measurement_opportunity_resolution;
CREATE TRIGGER tr_temporal_resolution_insert BEFORE INSERT ON maintenance.temporal_measurement_opportunity_resolution
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_resolution_insert();
DROP TRIGGER IF EXISTS tr_temporal_resolution_immutable ON maintenance.temporal_measurement_opportunity_resolution;
CREATE TRIGGER tr_temporal_resolution_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_opportunity_resolution
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_item_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE est text; search_uuid uuid; hit_search uuid; epoch_uuid uuid; prior_n integer;
BEGIN
  SELECT execution_status,scientific_search_uuid INTO est,search_uuid
  FROM maintenance.temporal_measurement_event WHERE measurement_event_uuid=NEW.measurement_event_uuid;
  IF est NOT IN ('completed','partial') THEN RAISE EXCEPTION 'items require completed or partial event'; END IF;
  IF NEW.search_hit_uuid IS NOT NULL THEN
    SELECT sh.search_uuid INTO hit_search FROM investigation.search_hit sh WHERE sh.search_hit_uuid=NEW.search_hit_uuid;
    IF search_uuid IS NULL OR hit_search IS DISTINCT FROM search_uuid THEN RAISE EXCEPTION 'SearchHit does not derive from event Search'; END IF;
  END IF;
  SELECT ep.observation_epoch_uuid INTO epoch_uuid
  FROM maintenance.temporal_measurement_event me
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_epoch ep USING(observation_epoch_uuid)
  WHERE me.measurement_event_uuid=NEW.measurement_event_uuid;
  SELECT count(*) INTO prior_n
  FROM maintenance.temporal_measurement_item mi
  JOIN maintenance.temporal_measurement_event me USING(measurement_event_uuid)
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  WHERE es.observation_epoch_uuid=epoch_uuid AND mi.source_identifier=NEW.source_identifier;
  IF NEW.item_state='new_to_epoch' AND prior_n>0 THEN RAISE EXCEPTION 'reobserved identifier cannot be new_to_epoch'; END IF;
  IF NEW.item_state IN ('reobserved','updated_record') AND prior_n=0 THEN RAISE EXCEPTION 'reobserved/updated identifier requires prior observation'; END IF;
  IF NEW.source_record_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.source_record_artifact_uuid) THEN
    RAISE EXCEPTION 'source record artifact must be active';
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_item_insert ON maintenance.temporal_measurement_item;
CREATE TRIGGER tr_temporal_item_insert BEFORE INSERT ON maintenance.temporal_measurement_item
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_item_insert();
DROP TRIGGER IF EXISTS tr_temporal_item_immutable ON maintenance.temporal_measurement_item;
CREATE TRIGGER tr_temporal_item_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_item
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_timepoint_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE semantics jsonb;
BEGIN
  SELECT s.time_semantics_payload INTO semantics
  FROM maintenance.temporal_measurement_item mi
  JOIN maintenance.temporal_measurement_event me USING(measurement_event_uuid)
  JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
  JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
  JOIN maintenance.temporal_observation_source s USING(observation_source_uuid)
  WHERE mi.measurement_item_uuid=NEW.measurement_item_uuid;
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(semantics->'semantic_codes') x WHERE x=NEW.semantic_code) THEN
    RAISE EXCEPTION 'source time semantic % is not declared',NEW.semantic_code;
  END IF;
  IF NEW.source_artifact_uuid IS NOT NULL AND NOT maintenance.temporal_artifact_is_active(NEW.source_artifact_uuid) THEN
    RAISE EXCEPTION 'timepoint artifact must be active';
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_timepoint_insert ON maintenance.temporal_measurement_item_timepoint;
CREATE TRIGGER tr_temporal_timepoint_insert BEFORE INSERT ON maintenance.temporal_measurement_item_timepoint
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_timepoint_insert();
DROP TRIGGER IF EXISTS tr_temporal_timepoint_immutable ON maintenance.temporal_measurement_item_timepoint;
CREATE TRIGGER tr_temporal_timepoint_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_item_timepoint
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_event_artifact_write()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF NOT maintenance.temporal_artifact_is_active(NEW.artifact_uuid) THEN RAISE EXCEPTION 'event artifact must be active'; END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_event_artifact_insert ON maintenance.temporal_measurement_event_artifact;
CREATE TRIGGER tr_temporal_event_artifact_insert BEFORE INSERT ON maintenance.temporal_measurement_event_artifact
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_event_artifact_write();
DROP TRIGGER IF EXISTS tr_temporal_event_artifact_immutable ON maintenance.temporal_measurement_event_artifact;
CREATE TRIGGER tr_temporal_event_artifact_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_measurement_event_artifact
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_deviation_insert()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE op_epoch uuid; ev_epoch uuid;
BEGIN
  IF NEW.measurement_opportunity_uuid IS NOT NULL THEN
    SELECT es.observation_epoch_uuid INTO op_epoch
    FROM maintenance.temporal_measurement_opportunity o JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE o.measurement_opportunity_uuid=NEW.measurement_opportunity_uuid;
    IF op_epoch IS DISTINCT FROM NEW.observation_epoch_uuid THEN RAISE EXCEPTION 'deviation opportunity/epoch mismatch'; END IF;
  END IF;
  IF NEW.measurement_event_uuid IS NOT NULL THEN
    SELECT es.observation_epoch_uuid INTO ev_epoch
    FROM maintenance.temporal_measurement_event me
    JOIN maintenance.temporal_measurement_opportunity o USING(measurement_opportunity_uuid)
    JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
    WHERE me.measurement_event_uuid=NEW.measurement_event_uuid;
    IF ev_epoch IS DISTINCT FROM NEW.observation_epoch_uuid THEN RAISE EXCEPTION 'deviation event/epoch mismatch'; END IF;
    IF NEW.measurement_opportunity_uuid IS NOT NULL AND NOT EXISTS(
      SELECT 1 FROM maintenance.temporal_measurement_event
      WHERE measurement_event_uuid=NEW.measurement_event_uuid AND measurement_opportunity_uuid=NEW.measurement_opportunity_uuid
    ) THEN RAISE EXCEPTION 'deviation event/opportunity mismatch'; END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_deviation_insert ON maintenance.temporal_observation_deviation;
CREATE TRIGGER tr_temporal_deviation_insert BEFORE INSERT ON maintenance.temporal_observation_deviation
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_deviation_insert();
DROP TRIGGER IF EXISTS tr_temporal_deviation_immutable ON maintenance.temporal_observation_deviation;
CREATE TRIGGER tr_temporal_deviation_immutable BEFORE UPDATE OR DELETE ON maintenance.temporal_observation_deviation
FOR EACH ROW EXECUTE FUNCTION maintenance.reject_temporal_row_mutation();
