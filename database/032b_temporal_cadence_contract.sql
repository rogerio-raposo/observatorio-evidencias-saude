-- Migration 032 fragment B — cadence contract / obligations / observations

CREATE TABLE IF NOT EXISTS maintenance.cadence_contract (
  cadence_contract_uuid uuid PRIMARY KEY,
  target_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  target_investigation_version_uuid uuid REFERENCES investigation.investigation_version(version_uuid),
  temporal_calibration_dossier_uuid uuid NOT NULL
    REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid),
  cadence_mode text NOT NULL CHECK(cadence_mode IN ('event_driven','periodic','hybrid')),
  governing_monitor_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  effective_at timestamptz NOT NULL,
  created_by text NOT NULL CHECK(length(btrim(created_by))>0),
  actor_type text NOT NULL CHECK(actor_type IN ('human_reviewer','human_expert','owner')),
  record_status text NOT NULL DEFAULT 'active' CHECK(record_status IN ('active','superseded')),
  supersedes_cadence_contract_uuid uuid REFERENCES maintenance.cadence_contract(cadence_contract_uuid),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK(num_nonnulls(target_product_version_uuid,target_investigation_version_uuid)=1)
);

CREATE TABLE IF NOT EXISTS maintenance.cadence_obligation (
  cadence_obligation_uuid uuid PRIMARY KEY,
  cadence_contract_uuid uuid NOT NULL REFERENCES maintenance.cadence_contract(cadence_contract_uuid),
  obligation_code text NOT NULL CHECK(length(btrim(obligation_code))>0),
  scope_type text NOT NULL CHECK(scope_type IN (
    'policy_aggregate','monitor_source_name','monitor_source_class','source_definition_artifact')),
  source_name text,
  source_class text,
  source_definition_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
  timing_mode text NOT NULL CHECK(timing_mode IN ('event_driven','fixed_elapsed','calendar_recurrence')),
  fixed_elapsed_interval interval,
  recurrence_count integer,
  recurrence_unit text CHECK(recurrence_unit IN ('day','week','month')),
  month_roll_policy text CHECK(month_roll_policy='preserve_day_or_clamp_last_day'),
  anchor_type text CHECK(anchor_type IN ('policy_effective_at','fixed_timestamp','last_satisfaction')),
  fixed_anchor_at timestamptz,
  timezone_name text,
  dst_resolution_policy text CHECK(dst_resolution_policy IN (
    'shift_forward_to_first_valid','earliest_occurrence_on_fold')),
  grace_interval interval NOT NULL DEFAULT interval '0',
  event_channel_code text,
  satisfaction_event_type text NOT NULL CHECK(satisfaction_event_type IN (
    'monitor_cycle_completed','search_execution','evidence_event','update_signal','artifact_attestation')),
  effective_at timestamptz NOT NULL,
  UNIQUE(cadence_contract_uuid,obligation_code),
  CHECK(grace_interval>=interval '0'),
  CHECK(
    (scope_type='policy_aggregate' AND source_name IS NULL AND source_class IS NULL AND source_definition_artifact_uuid IS NULL)
    OR (scope_type='monitor_source_name' AND source_name IS NOT NULL AND source_class IS NULL AND source_definition_artifact_uuid IS NULL)
    OR (scope_type='monitor_source_class' AND source_name IS NULL AND source_class IS NOT NULL AND source_definition_artifact_uuid IS NULL)
    OR (scope_type='source_definition_artifact' AND source_name IS NULL AND source_class IS NULL AND source_definition_artifact_uuid IS NOT NULL)
  ),
  CHECK(
    (timing_mode='event_driven' AND fixed_elapsed_interval IS NULL AND recurrence_count IS NULL
      AND recurrence_unit IS NULL AND month_roll_policy IS NULL AND anchor_type IS NULL
      AND fixed_anchor_at IS NULL AND event_channel_code IS NOT NULL)
    OR
    (timing_mode='fixed_elapsed' AND fixed_elapsed_interval>interval '0'
      AND date_part('year',fixed_elapsed_interval)=0 AND date_part('month',fixed_elapsed_interval)=0
      AND recurrence_count IS NULL AND recurrence_unit IS NULL AND month_roll_policy IS NULL
      AND anchor_type IS NOT NULL AND event_channel_code IS NULL
      AND (anchor_type='fixed_timestamp')=(fixed_anchor_at IS NOT NULL)
      AND grace_interval<fixed_elapsed_interval)
    OR
    (timing_mode='calendar_recurrence' AND fixed_elapsed_interval IS NULL
      AND recurrence_count>0 AND recurrence_unit IS NOT NULL
      AND (recurrence_unit<>'month' OR month_roll_policy='preserve_day_or_clamp_last_day')
      AND anchor_type IS NOT NULL AND timezone_name IS NOT NULL AND dst_resolution_policy IS NOT NULL
      AND event_channel_code IS NULL
      AND (anchor_type='fixed_timestamp')=(fixed_anchor_at IS NOT NULL))
  )
);

CREATE TABLE IF NOT EXISTS maintenance.cadence_observation (
  cadence_observation_uuid uuid PRIMARY KEY,
  cadence_obligation_uuid uuid NOT NULL REFERENCES maintenance.cadence_obligation(cadence_obligation_uuid),
  occurrence_no integer CHECK(occurrence_no>0),
  outcome text NOT NULL CHECK(outcome IN ('satisfied','partial','failed','unavailable')),
  observed_at timestamptz NOT NULL,
  scheduled_due_at timestamptz,
  due_calculation_payload jsonb CHECK(due_calculation_payload IS NULL OR jsonb_typeof(due_calculation_payload)='object'),
  monitor_cycle_uuid uuid REFERENCES maintenance.monitor_cycle(cycle_uuid),
  search_uuid uuid REFERENCES investigation.search(search_uuid),
  evidence_event_uuid uuid REFERENCES maintenance.evidence_event(evidence_event_uuid),
  update_signal_uuid uuid REFERENCES maintenance.update_signal(update_signal_uuid),
  artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
  observed_by text NOT NULL CHECK(length(btrim(observed_by))>0),
  actor_type text NOT NULL CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK(num_nonnulls(monitor_cycle_uuid,search_uuid,evidence_event_uuid,update_signal_uuid,artifact_uuid)=1)
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_cadence_observation_occurrence
 ON maintenance.cadence_observation(cadence_obligation_uuid,occurrence_no)
 WHERE occurrence_no IS NOT NULL;

CREATE OR REPLACE FUNCTION maintenance.temporal_fixed_interval_is_valid(p interval)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $q$
SELECT p IS NOT NULL AND p>interval '0'
 AND date_part('year',p)=0 AND date_part('month',p)=0;
$q$;

CREATE OR REPLACE FUNCTION maintenance.cadence_occurrence_due_at(p uuid,p_occ integer)
RETURNS timestamptz LANGUAGE plpgsql STABLE AS $fn$
DECLARE o maintenance.cadence_obligation%ROWTYPE; c maintenance.cadence_contract%ROWTYPE;
 base timestamptz; last_at timestamptz; local_base timestamp; local_due timestamp; due_at timestamptz;
BEGIN
  IF p_occ IS NULL OR p_occ<1 THEN RETURN NULL; END IF;
  SELECT * INTO o FROM maintenance.cadence_obligation WHERE cadence_obligation_uuid=p;
  IF NOT FOUND OR o.timing_mode='event_driven' THEN RETURN NULL; END IF;
  SELECT * INTO c FROM maintenance.cadence_contract WHERE cadence_contract_uuid=o.cadence_contract_uuid;

  IF o.anchor_type='policy_effective_at' THEN base:=c.effective_at;
  ELSIF o.anchor_type='fixed_timestamp' THEN base:=o.fixed_anchor_at;
  ELSE
    SELECT observed_at INTO last_at FROM maintenance.cadence_observation
      WHERE cadence_obligation_uuid=p AND outcome='satisfied'
      ORDER BY observed_at DESC LIMIT 1;
    IF last_at IS NULL THEN base:=c.effective_at; ELSE base:=last_at; END IF;
  END IF;

  IF o.timing_mode='fixed_elapsed' THEN
    IF o.anchor_type='last_satisfaction' THEN
      RETURN base + o.fixed_elapsed_interval;
    END IF;
    RETURN base + (p_occ * o.fixed_elapsed_interval);
  END IF;

  local_base := base AT TIME ZONE o.timezone_name;
  IF o.anchor_type='last_satisfaction' THEN
    IF o.recurrence_unit='day' THEN local_due:=local_base + make_interval(days=>o.recurrence_count);
    ELSIF o.recurrence_unit='week' THEN local_due:=local_base + make_interval(days=>7*o.recurrence_count);
    ELSE local_due:=local_base + make_interval(months=>o.recurrence_count); END IF;
  ELSE
    IF o.recurrence_unit='day' THEN local_due:=local_base + make_interval(days=>p_occ*o.recurrence_count);
    ELSIF o.recurrence_unit='week' THEN local_due:=local_base + make_interval(days=>7*p_occ*o.recurrence_count);
    ELSE local_due:=local_base + make_interval(months=>p_occ*o.recurrence_count); END IF;
  END IF;
  due_at := local_due AT TIME ZONE o.timezone_name;
  RETURN due_at;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.cadence_contract_snapshot(p uuid)
RETURNS jsonb LANGUAGE sql STABLE AS $q$
SELECT jsonb_build_object(
 'schema_version','oes.cadence_candidate/0.1',
 'cadence_mode',c.cadence_mode,
 'effective_at',c.effective_at,
 'governing_monitor_product_version_uuid',c.governing_monitor_product_version_uuid,
 'obligations',COALESCE((
   SELECT jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
     'obligation_code',o.obligation_code,
     'scope',jsonb_strip_nulls(jsonb_build_object('type',o.scope_type,'source_name',o.source_name,
       'source_class',o.source_class,'source_definition_artifact_uuid',o.source_definition_artifact_uuid)),
     'timing',jsonb_strip_nulls(jsonb_build_object('mode',o.timing_mode,'fixed_elapsed_seconds',
       CASE WHEN o.fixed_elapsed_interval IS NULL THEN NULL ELSE extract(epoch from o.fixed_elapsed_interval) END,
       'recurrence_count',o.recurrence_count,'recurrence_unit',o.recurrence_unit,'month_roll_policy',o.month_roll_policy)),
     'anchor',jsonb_strip_nulls(jsonb_build_object('type',o.anchor_type,'fixed_anchor_at',o.fixed_anchor_at)),
     'grace_seconds',extract(epoch from o.grace_interval),
     'event_channel_code',o.event_channel_code,
     'satisfaction_event_type',o.satisfaction_event_type,
     'timezone_name',o.timezone_name,'dst_resolution_policy',o.dst_resolution_policy
   )) ORDER BY o.obligation_code)
   FROM maintenance.cadence_obligation o WHERE o.cadence_contract_uuid=c.cadence_contract_uuid
 ),'[]'::jsonb)
)
FROM maintenance.cadence_contract c WHERE c.cadence_contract_uuid=p;
$q$;

CREATE OR REPLACE FUNCTION maintenance.assert_cadence_contract_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.temporal_calibration_dossier%ROWTYPE; p maintenance.update_risk_profile%ROWTYPE;
 target_status text; monitor_target_product uuid; monitor_target_inv uuid;
BEGIN
  SELECT * INTO d FROM maintenance.temporal_calibration_dossier
   WHERE temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid;
  IF NOT FOUND OR d.decision_status<>'approved_for_normative_activation'
     OR d.calibration_kind<>'cadence'
     OR d.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
     OR d.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid
     OR d.decided_at>NEW.effective_at THEN
    RAISE EXCEPTION 'CadenceContract requires approved matching cadence dossier';
  END IF;
  SELECT * INTO p FROM maintenance.update_risk_profile WHERE update_risk_profile_uuid=d.update_risk_profile_uuid;
  IF p.authority_status<>'authoritative' THEN RAISE EXCEPTION 'CadenceContract requires authoritative profile'; END IF;

  SELECT version_status INTO target_status FROM core.entity_version
   WHERE version_uuid=COALESCE(NEW.target_product_version_uuid,NEW.target_investigation_version_uuid);
  IF target_status IS DISTINCT FROM 'current' THEN
    RAISE EXCEPTION 'CadenceContract target must be current at activation';
  END IF;

  IF NEW.governing_monitor_product_version_uuid IS NOT NULL THEN
    SELECT target_product_version_uuid,target_investigation_version_uuid
      INTO monitor_target_product,monitor_target_inv
    FROM maintenance.monitor_target
    WHERE monitor_product_version_uuid=NEW.governing_monitor_product_version_uuid;
    IF NOT FOUND
       OR monitor_target_product IS DISTINCT FROM NEW.target_product_version_uuid
       OR monitor_target_inv IS DISTINCT FROM NEW.target_investigation_version_uuid THEN
      RAISE EXCEPTION 'CadenceContract governing Monitor must target the exact calibrated target';
    END IF;
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_cadence_contract_consistency ON maintenance.cadence_contract;
CREATE TRIGGER tr_cadence_contract_consistency
BEFORE INSERT ON maintenance.cadence_contract
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_cadence_contract_consistency();

CREATE OR REPLACE FUNCTION maintenance.assert_cadence_contract_complete()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE ec integer; rc integer; selected jsonb;
BEGIN
  SELECT count(*) FILTER(WHERE timing_mode='event_driven'),
         count(*) FILTER(WHERE timing_mode IN ('fixed_elapsed','calendar_recurrence'))
    INTO ec,rc FROM maintenance.cadence_obligation WHERE cadence_contract_uuid=NEW.cadence_contract_uuid;
  IF (NEW.cadence_mode='event_driven' AND (ec<1 OR rc<>0))
    OR (NEW.cadence_mode='periodic' AND (rc<1 OR ec<>0))
    OR (NEW.cadence_mode='hybrid' AND (ec<1 OR rc<1)) THEN
    RAISE EXCEPTION 'CadenceContract obligation composition mismatch';
  END IF;
  SELECT candidate_payload INTO selected FROM maintenance.temporal_calibration_candidate
   WHERE temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid AND disposition='selected';
  IF selected IS DISTINCT FROM maintenance.cadence_contract_snapshot(NEW.cadence_contract_uuid) THEN
    RAISE EXCEPTION 'CadenceContract must equal selected candidate snapshot';
  END IF;
  RETURN NULL;
END
$fn$;
DROP TRIGGER IF EXISTS tr_cadence_contract_complete ON maintenance.cadence_contract;
CREATE CONSTRAINT TRIGGER tr_cadence_contract_complete
AFTER INSERT OR UPDATE ON maintenance.cadence_contract
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_cadence_contract_complete();

CREATE OR REPLACE FUNCTION maintenance.guard_cadence_immutable()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Cadence contract rows cannot be deleted'; END IF;
  IF TG_TABLE_NAME='cadence_contract' AND OLD.record_status='active' AND NEW.record_status='superseded'
     AND to_jsonb(NEW)-'record_status'=to_jsonb(OLD)-'record_status' THEN RETURN NEW; END IF;
  RAISE EXCEPTION 'Cadence contract rows are immutable';
END
$fn$;
DROP TRIGGER IF EXISTS tr_cadence_contract_guard ON maintenance.cadence_contract;
CREATE TRIGGER tr_cadence_contract_guard BEFORE UPDATE OR DELETE ON maintenance.cadence_contract
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_cadence_immutable();
DROP TRIGGER IF EXISTS tr_cadence_obligation_guard ON maintenance.cadence_obligation;
CREATE TRIGGER tr_cadence_obligation_guard BEFORE UPDATE OR DELETE ON maintenance.cadence_obligation
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_cadence_immutable();
DROP TRIGGER IF EXISTS tr_cadence_observation_guard ON maintenance.cadence_observation;
CREATE TRIGGER tr_cadence_observation_guard BEFORE UPDATE OR DELETE ON maintenance.cadence_observation
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_cadence_immutable();

CREATE OR REPLACE FUNCTION maintenance.cadence_obligation_scope_is_valid(p uuid)
RETURNS boolean LANGUAGE plpgsql STABLE AS $fn$
DECLARE o maintenance.cadence_obligation%ROWTYPE; c maintenance.cadence_contract%ROWTYPE; st text;
BEGIN
  SELECT * INTO o FROM maintenance.cadence_obligation WHERE cadence_obligation_uuid=p;
  IF NOT FOUND THEN RETURN false; END IF;
  SELECT * INTO c FROM maintenance.cadence_contract WHERE cadence_contract_uuid=o.cadence_contract_uuid;

  IF o.scope_type='policy_aggregate' THEN RETURN true; END IF;

  IF o.scope_type='source_definition_artifact' THEN
    SELECT status INTO st FROM artifact.artifact WHERE artifact_uuid=o.source_definition_artifact_uuid;
    RETURN st='active';
  END IF;

  IF c.governing_monitor_product_version_uuid IS NULL THEN RETURN false; END IF;

  IF o.scope_type='monitor_source_name' THEN
    RETURN EXISTS(
      SELECT 1 FROM maintenance.monitor_source_requirement r
      WHERE r.monitor_product_version_uuid=c.governing_monitor_product_version_uuid
        AND r.requirement_kind='source_name'
        AND r.required_value=o.source_name
    );
  END IF;

  IF o.scope_type='monitor_source_class' THEN
    RETURN EXISTS(
      SELECT 1 FROM maintenance.monitor_source_requirement r
      WHERE r.monitor_product_version_uuid=c.governing_monitor_product_version_uuid
        AND r.requirement_kind='source_class'
        AND r.required_value=o.source_class
    );
  END IF;

  RETURN false;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_cadence_obligation_scope()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF NOT maintenance.cadence_obligation_scope_is_valid(NEW.cadence_obligation_uuid) THEN
    -- NEW is not yet visible to the helper in BEFORE INSERT; validate directly for INSERT below.
    IF NEW.scope_type='policy_aggregate' THEN RETURN NEW; END IF;
    IF NEW.scope_type='source_definition_artifact' THEN
      IF EXISTS(SELECT 1 FROM artifact.artifact a
                WHERE a.artifact_uuid=NEW.source_definition_artifact_uuid AND a.status='active') THEN
        RETURN NEW;
      END IF;
    ELSE
      IF EXISTS(
        SELECT 1 FROM maintenance.cadence_contract cc
        JOIN maintenance.monitor_source_requirement r
          ON r.monitor_product_version_uuid=cc.governing_monitor_product_version_uuid
        WHERE cc.cadence_contract_uuid=NEW.cadence_contract_uuid
          AND ((NEW.scope_type='monitor_source_name' AND r.requirement_kind='source_name' AND r.required_value=NEW.source_name)
            OR (NEW.scope_type='monitor_source_class' AND r.requirement_kind='source_class' AND r.required_value=NEW.source_class))
      ) THEN RETURN NEW; END IF;
    END IF;
    RAISE EXCEPTION 'CadenceObligation source scope is not declared by governing Monitor/artifact';
  END IF;
  RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS tr_cadence_obligation_scope ON maintenance.cadence_obligation;
CREATE TRIGGER tr_cadence_obligation_scope
BEFORE INSERT ON maintenance.cadence_obligation
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_cadence_obligation_scope();

CREATE OR REPLACE FUNCTION maintenance.assert_cadence_observation()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE o maintenance.cadence_obligation%ROWTYPE; c maintenance.cadence_contract%ROWTYPE;
 causal timestamptz; art_type text; art_status text; cyc_status text;
 locator_monitor uuid; locator_source_name text; locator_source_class text;
 search_inv uuid; target_inv uuid;
BEGIN
  SELECT * INTO o FROM maintenance.cadence_obligation WHERE cadence_obligation_uuid=NEW.cadence_obligation_uuid;
  SELECT * INTO c FROM maintenance.cadence_contract WHERE cadence_contract_uuid=o.cadence_contract_uuid;
  IF o.timing_mode='event_driven' THEN
    IF NEW.occurrence_no IS NOT NULL OR NEW.scheduled_due_at IS NOT NULL OR NEW.due_calculation_payload IS NOT NULL THEN
      RAISE EXCEPTION 'Event-driven observation cannot carry recurrence fields';
    END IF;
  ELSE
    IF NEW.occurrence_no IS NULL OR NEW.scheduled_due_at IS NULL
       OR NEW.scheduled_due_at IS DISTINCT FROM maintenance.cadence_occurrence_due_at(o.cadence_obligation_uuid,NEW.occurrence_no)
       OR jsonb_typeof(NEW.due_calculation_payload)<>'object' THEN
      RAISE EXCEPTION 'Recurring observation requires canonical frozen due';
    END IF;
  END IF;

  IF NEW.monitor_cycle_uuid IS NOT NULL THEN
    IF o.satisfaction_event_type<>'monitor_cycle_completed' THEN RAISE EXCEPTION 'Cadence locator/event mismatch'; END IF;
    SELECT completed_at,execution_status,monitor_product_version_uuid
      INTO causal,cyc_status,locator_monitor
    FROM maintenance.monitor_cycle WHERE cycle_uuid=NEW.monitor_cycle_uuid;
    IF cyc_status<>'completed' THEN RAISE EXCEPTION 'Cadence MonitorCycle must be completed'; END IF;
    IF c.governing_monitor_product_version_uuid IS NOT NULL
       AND locator_monitor IS DISTINCT FROM c.governing_monitor_product_version_uuid THEN
      RAISE EXCEPTION 'Cadence MonitorCycle must belong to governing Monitor';
    END IF;
  ELSIF NEW.search_uuid IS NOT NULL THEN
    IF o.satisfaction_event_type<>'search_execution' THEN RAISE EXCEPTION 'Cadence locator/event mismatch'; END IF;
    SELECT s.executed_at,s.source_name,s.source_class,s.investigation_version_uuid
      INTO causal,locator_source_name,locator_source_class,search_inv
    FROM investigation.search s WHERE s.search_uuid=NEW.search_uuid;
    IF c.governing_monitor_product_version_uuid IS NOT NULL THEN
      SELECT maintenance.monitor_primary_investigation(c.governing_monitor_product_version_uuid) INTO target_inv;
      IF search_inv IS DISTINCT FROM target_inv THEN
        RAISE EXCEPTION 'Cadence Search must belong to governing Monitor investigation';
      END IF;
    ELSIF c.target_investigation_version_uuid IS NOT NULL
          AND search_inv IS DISTINCT FROM c.target_investigation_version_uuid THEN
      RAISE EXCEPTION 'Cadence Search must belong to calibrated InvestigationVersion';
    END IF;
    IF o.scope_type='monitor_source_name' AND locator_source_name IS DISTINCT FROM o.source_name THEN
      RAISE EXCEPTION 'Cadence Search does not prove required source name';
    END IF;
    IF o.scope_type='monitor_source_class' AND locator_source_class IS DISTINCT FROM o.source_class THEN
      RAISE EXCEPTION 'Cadence Search does not prove required source class';
    END IF;
  ELSIF NEW.evidence_event_uuid IS NOT NULL THEN
    IF o.satisfaction_event_type<>'evidence_event' OR o.timing_mode<>'event_driven' THEN RAISE EXCEPTION 'Cadence locator/event mismatch'; END IF;
    SELECT detected_at,monitor_product_version_uuid INTO causal,locator_monitor
      FROM maintenance.evidence_event WHERE evidence_event_uuid=NEW.evidence_event_uuid;
    IF c.governing_monitor_product_version_uuid IS NULL
       OR locator_monitor IS DISTINCT FROM c.governing_monitor_product_version_uuid THEN
      RAISE EXCEPTION 'Cadence EvidenceEvent must belong to governing Monitor';
    END IF;
  ELSIF NEW.update_signal_uuid IS NOT NULL THEN
    IF o.satisfaction_event_type<>'update_signal' OR o.timing_mode<>'event_driven' THEN RAISE EXCEPTION 'Cadence locator/event mismatch'; END IF;
    SELECT detected_at INTO causal FROM maintenance.update_signal
      WHERE update_signal_uuid=NEW.update_signal_uuid AND update_policy_uuid IN (
        SELECT p.update_policy_uuid FROM maintenance.update_policy p
        WHERE p.cadence_contract_uuid=c.cadence_contract_uuid);
  ELSE
    IF o.satisfaction_event_type<>'artifact_attestation' THEN RAISE EXCEPTION 'Cadence locator/event mismatch'; END IF;
    SELECT created_at,artifact_type,status INTO causal,art_type,art_status FROM artifact.artifact WHERE artifact_uuid=NEW.artifact_uuid;
    IF art_status<>'active' OR art_type<>'cadence_attestation'
       OR NEW.actor_type NOT IN ('human_reviewer','human_expert','owner') THEN
      RAISE EXCEPTION 'Cadence attestation invalid';
    END IF;
  END IF;
  IF causal IS NULL OR NEW.observed_at IS DISTINCT FROM causal THEN
    RAISE EXCEPTION 'Cadence observed_at must equal causal timestamp';
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_cadence_observation ON maintenance.cadence_observation;
CREATE TRIGGER tr_cadence_observation BEFORE INSERT ON maintenance.cadence_observation
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_cadence_observation();

ALTER TABLE maintenance.update_policy
  ADD COLUMN IF NOT EXISTS cadence_contract_uuid uuid REFERENCES maintenance.cadence_contract(cadence_contract_uuid);

CREATE OR REPLACE FUNCTION maintenance.assert_update_policy_temporal_v01()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE c maintenance.cadence_contract%ROWTYPE;
BEGIN
  IF maintenance.temporal_object_is_grandfathered('update_policy',NEW.update_policy_uuid) THEN RETURN NEW; END IF;
  IF NEW.cadence_mode='none' THEN
    IF NEW.cadence_contract_uuid IS NOT NULL OR NEW.cadence_policy_payload<>'{}'::jsonb THEN
      RAISE EXCEPTION 'v0.1 none cadence cannot bind contract/payload';
    END IF;
    RETURN NEW;
  END IF;
  IF NEW.effective_maintenance_level='M3' OR NEW.cadence_mode='continuous' THEN
    RAISE EXCEPTION 'M3/continuous remains blocked under temporal calibration v0.1';
  END IF;
  SELECT * INTO c FROM maintenance.cadence_contract WHERE cadence_contract_uuid=NEW.cadence_contract_uuid;
  IF NOT FOUND OR c.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
    OR c.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid
    OR c.cadence_mode<>NEW.cadence_mode
    OR c.governing_monitor_product_version_uuid IS DISTINCT FROM NEW.governing_monitor_product_version_uuid
    OR c.effective_at<>NEW.effective_at
    OR NEW.cadence_policy_payload IS DISTINCT FROM maintenance.cadence_contract_snapshot(c.cadence_contract_uuid) THEN
      RAISE EXCEPTION 'UpdatePolicy v0.1 cadence contract mismatch';
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_update_policy_temporal_v01 ON maintenance.update_policy;
CREATE TRIGGER tr_update_policy_temporal_v01
BEFORE INSERT ON maintenance.update_policy
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_policy_temporal_v01();
