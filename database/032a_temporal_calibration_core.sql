-- Migration 032 fragment A — temporal calibration core + grandfather registry
-- Loaded by 032_temporal_calibration_prerequisites.sql inside one transaction.

DO $epoch$
DECLARE first_install boolean;
BEGIN
  SELECT NOT EXISTS (
    SELECT 1 FROM maintenance.contract_epoch
    WHERE contract_code='TEMPORAL_CALIBRATION_V01'
  ) INTO first_install;

  INSERT INTO maintenance.contract_epoch(contract_code,schema_version,effective_at,migration_id)
  VALUES ('TEMPORAL_CALIBRATION_V01','0.1',CURRENT_TIMESTAMP,'032')
  ON CONFLICT(contract_code) DO NOTHING;

  CREATE TABLE IF NOT EXISTS maintenance.temporal_contract_grandfathered_object (
    object_type text NOT NULL CHECK(object_type IN ('update_policy','sla_rule','sla_calendar_version')),
    object_uuid uuid NOT NULL,
    grandfathered_at timestamptz NOT NULL,
    migration_id text NOT NULL CHECK(migration_id='032'),
    reason_code text NOT NULL CHECK(reason_code='pre_v01_existing_row'),
    PRIMARY KEY(object_type,object_uuid)
  );

  IF first_install THEN
    INSERT INTO maintenance.temporal_contract_grandfathered_object
      (object_type,object_uuid,grandfathered_at,migration_id,reason_code)
    SELECT 'update_policy',update_policy_uuid,CURRENT_TIMESTAMP,'032','pre_v01_existing_row'
    FROM maintenance.update_policy
    ON CONFLICT DO NOTHING;

    INSERT INTO maintenance.temporal_contract_grandfathered_object
      (object_type,object_uuid,grandfathered_at,migration_id,reason_code)
    SELECT 'sla_rule',sla_rule_uuid,CURRENT_TIMESTAMP,'032','pre_v01_existing_row'
    FROM maintenance.sla_rule
    ON CONFLICT DO NOTHING;

    INSERT INTO maintenance.temporal_contract_grandfathered_object
      (object_type,object_uuid,grandfathered_at,migration_id,reason_code)
    SELECT 'sla_calendar_version',sla_calendar_version_uuid,CURRENT_TIMESTAMP,'032','pre_v01_existing_row'
    FROM maintenance.sla_calendar_version
    ON CONFLICT DO NOTHING;
  END IF;
END
$epoch$;

CREATE OR REPLACE FUNCTION maintenance.temporal_object_is_grandfathered(p_type text,p_uuid uuid)
RETURNS boolean LANGUAGE sql STABLE AS $q$
SELECT EXISTS(
  SELECT 1 FROM maintenance.temporal_contract_grandfathered_object g
  WHERE g.object_type=p_type AND g.object_uuid=p_uuid
);
$q$;

CREATE TABLE IF NOT EXISTS maintenance.temporal_calibration_dossier (
  temporal_calibration_dossier_uuid uuid PRIMARY KEY,
  scope_type text NOT NULL CHECK(scope_type IN ('target','calendar')),
  calibration_kind text NOT NULL CHECK(calibration_kind IN ('cadence','sla_rule','sla_calendar')),
  target_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  target_investigation_version_uuid uuid REFERENCES investigation.investigation_version(version_uuid),
  calendar_key text,
  update_risk_profile_uuid uuid REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
  baseline_update_policy_uuid uuid REFERENCES maintenance.update_policy(update_policy_uuid),
  clock_code text,
  data_window_start timestamptz,
  data_window_end timestamptz,
  decision_status text NOT NULL DEFAULT 'draft' CHECK(decision_status IN (
    'draft','approved_for_normative_activation','provisional_requires_reassessment',
    'capacity_conflict','insufficient_evidence','rejected')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  created_by text NOT NULL CHECK(length(btrim(created_by))>0),
  actor_type text NOT NULL CHECK(actor_type IN ('human_reviewer','human_expert','owner')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  decided_at timestamptz,
  decision_recorded_by text,
  decision_actor_type text CHECK(decision_actor_type IN ('human_reviewer','human_expert','owner')),
  record_status text NOT NULL DEFAULT 'active' CHECK(record_status IN ('active','superseded')),
  supersedes_temporal_calibration_dossier_uuid uuid
    REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid),
  CHECK(data_window_end IS NULL OR data_window_start IS NULL OR data_window_end>=data_window_start),
  CHECK(
    (scope_type='target'
      AND num_nonnulls(target_product_version_uuid,target_investigation_version_uuid)=1
      AND calendar_key IS NULL
      AND calibration_kind IN ('cadence','sla_rule')
      AND update_risk_profile_uuid IS NOT NULL
      AND ((calibration_kind='sla_rule' AND clock_code IS NOT NULL)
           OR (calibration_kind='cadence' AND clock_code IS NULL)))
    OR
    (scope_type='calendar'
      AND target_product_version_uuid IS NULL AND target_investigation_version_uuid IS NULL
      AND length(btrim(COALESCE(calendar_key,'')))>0
      AND calibration_kind='sla_calendar'
      AND update_risk_profile_uuid IS NULL
      AND baseline_update_policy_uuid IS NULL
      AND clock_code IS NULL)
  ),
  CHECK(
    (decision_status='draft' AND decided_at IS NULL AND decision_recorded_by IS NULL AND decision_actor_type IS NULL)
    OR
    (decision_status<>'draft' AND decided_at IS NOT NULL AND length(btrim(COALESCE(decision_recorded_by,'')))>0
      AND decision_actor_type IS NOT NULL)
  )
);

CREATE INDEX IF NOT EXISTS ix_temporal_calibration_dossier_target_product
 ON maintenance.temporal_calibration_dossier(target_product_version_uuid,decision_status,record_status);
CREATE INDEX IF NOT EXISTS ix_temporal_calibration_dossier_target_inv
 ON maintenance.temporal_calibration_dossier(target_investigation_version_uuid,decision_status,record_status);

CREATE TABLE IF NOT EXISTS maintenance.temporal_calibration_authority (
  temporal_calibration_dossier_uuid uuid NOT NULL
    REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid),
  authority_domain text NOT NULL CHECK(authority_domain IN (
    'scientific_methodological','operational_feasibility','external_applicability')),
  actor text NOT NULL CHECK(length(btrim(actor))>0),
  actor_type text NOT NULL CHECK(actor_type IN ('human_reviewer','human_expert','owner')),
  verification_status text NOT NULL CHECK(verification_status IN ('unverified','human_verified','human_consensus')),
  verified_by text,
  verifier_actor_type text CHECK(verifier_actor_type IN ('human_reviewer','human_expert')),
  verified_at timestamptz,
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  decided_at timestamptz NOT NULL,
  PRIMARY KEY(temporal_calibration_dossier_uuid,authority_domain),
  CHECK(
    (verification_status='unverified' AND verified_by IS NULL AND verifier_actor_type IS NULL AND verified_at IS NULL)
    OR
    (verification_status IN ('human_verified','human_consensus')
      AND verified_by IS NOT NULL AND verifier_actor_type IS NOT NULL AND verified_at IS NOT NULL)
  )
);

CREATE TABLE IF NOT EXISTS maintenance.temporal_calibration_basis (
  temporal_calibration_basis_uuid uuid PRIMARY KEY,
  temporal_calibration_dossier_uuid uuid NOT NULL
    REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid),
  envelope_domain text NOT NULL CHECK(envelope_domain IN ('need','source_reality','feasibility','external_constraint')),
  basis_type text NOT NULL CHECK(basis_type IN (
    'oes_empirical','source_characteristic','external_normative','methodological_evidence','governance_decision')),
  basis_role text NOT NULL CHECK(basis_role IN ('supporting','controlling','counterevidence')),
  artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
  entity_version_uuid uuid REFERENCES core.entity_version(version_uuid),
  monitor_cycle_uuid uuid REFERENCES maintenance.monitor_cycle(cycle_uuid),
  update_signal_uuid uuid REFERENCES maintenance.update_signal(update_signal_uuid),
  workflow_round_uuid uuid REFERENCES maintenance.workflow_round(workflow_round_uuid),
  sla_instance_uuid uuid REFERENCES maintenance.sla_instance(sla_instance_uuid),
  update_risk_profile_uuid uuid REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
  priority_assessment_uuid uuid REFERENCES maintenance.priority_assessment(priority_assessment_uuid),
  observed_from timestamptz,
  observed_to timestamptz,
  basis_payload jsonb NOT NULL DEFAULT '{}'::jsonb CHECK(jsonb_typeof(basis_payload)='object'),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  created_by text NOT NULL CHECK(length(btrim(created_by))>0),
  actor_type text NOT NULL CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')),
  recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK(num_nonnulls(artifact_uuid,entity_version_uuid,monitor_cycle_uuid,update_signal_uuid,
    workflow_round_uuid,sla_instance_uuid,update_risk_profile_uuid,priority_assessment_uuid)=1),
  CHECK(observed_to IS NULL OR observed_from IS NULL OR observed_to>=observed_from)
);

CREATE TABLE IF NOT EXISTS maintenance.temporal_calibration_candidate (
  temporal_calibration_candidate_uuid uuid PRIMARY KEY,
  temporal_calibration_dossier_uuid uuid NOT NULL
    REFERENCES maintenance.temporal_calibration_dossier(temporal_calibration_dossier_uuid),
  candidate_no integer NOT NULL CHECK(candidate_no>0),
  candidate_kind text NOT NULL CHECK(candidate_kind IN ('cadence','sla_rule','sla_calendar')),
  candidate_payload jsonb NOT NULL CHECK(jsonb_typeof(candidate_payload)='object'),
  disposition text NOT NULL CHECK(disposition IN (
    'considered','dominated','source_ineffective','infeasible','rejected','selected')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(temporal_calibration_dossier_uuid,candidate_no)
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_temporal_calibration_candidate_selected
 ON maintenance.temporal_calibration_candidate(temporal_calibration_dossier_uuid)
 WHERE disposition='selected';

CREATE TABLE IF NOT EXISTS maintenance.temporal_calibration_evaluation (
  temporal_calibration_evaluation_uuid uuid PRIMARY KEY,
  temporal_calibration_candidate_uuid uuid NOT NULL
    REFERENCES maintenance.temporal_calibration_candidate(temporal_calibration_candidate_uuid),
  evaluation_type text NOT NULL CHECK(evaluation_type IN (
    'historical_replay','stress_scenario','sensitivity_analysis','source_latency_analysis','capacity_analysis')),
  result_status text NOT NULL CHECK(result_status IN (
    'acceptable','dominated','source_ineffective','infeasible','indeterminate')),
  metrics_payload jsonb NOT NULL DEFAULT '{}'::jsonb CHECK(jsonb_typeof(metrics_payload)='object'),
  result_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  evaluated_at timestamptz NOT NULL
);

CREATE OR REPLACE FUNCTION maintenance.temporal_candidate_payload_is_valid(p_kind text,p jsonb)
RETURNS boolean LANGUAGE plpgsql STABLE AS $fn$
DECLARE
  item jsonb;
  scope_j jsonb;
  timing_j jsonb;
  anchor_j jsonb;
  mode text;
  recurrence_unit text;
  n numeric;
BEGIN
  IF jsonb_typeof(p)<>'object' OR p->>'schema_version' IS NULL THEN RETURN false; END IF;

  IF p_kind='cadence' THEN
    IF p->>'schema_version'<>'oes.cadence_candidate/0.1'
       OR (p->>'cadence_mode') NOT IN ('event_driven','periodic','hybrid')
       OR NOT (p ? 'effective_at')
       OR jsonb_typeof(p->'obligations')<>'array'
       OR jsonb_array_length(p->'obligations')<1
       OR (p - ARRAY['schema_version','cadence_mode','effective_at',
             'governing_monitor_product_version_uuid','obligations'])<>'{}'::jsonb
    THEN RETURN false; END IF;

    BEGIN PERFORM (p->>'effective_at')::timestamptz;
    EXCEPTION WHEN OTHERS THEN RETURN false; END;

    FOR item IN SELECT value FROM jsonb_array_elements(p->'obligations')
    LOOP
      IF jsonb_typeof(item)<>'object'
         OR (item - ARRAY['obligation_code','scope','timing','anchor','grace_seconds',
              'event_channel_code','satisfaction_event_type','timezone_name',
              'dst_resolution_policy'])<>'{}'::jsonb
         OR length(btrim(COALESCE(item->>'obligation_code','')))=0
         OR jsonb_typeof(item->'scope')<>'object'
         OR jsonb_typeof(item->'timing')<>'object'
         OR NOT (item ? 'satisfaction_event_type')
      THEN RETURN false; END IF;

      scope_j:=item->'scope';
      IF (scope_j - ARRAY['type','source_name','source_class','source_definition_artifact_uuid'])<>'{}'::jsonb
         OR scope_j->>'type' NOT IN ('policy_aggregate','monitor_source_name','monitor_source_class','source_definition_artifact')
      THEN RETURN false; END IF;

      IF (scope_j->>'type'='policy_aggregate'
          AND (scope_j ? 'source_name' OR scope_j ? 'source_class' OR scope_j ? 'source_definition_artifact_uuid'))
         OR (scope_j->>'type'='monitor_source_name'
          AND (length(btrim(COALESCE(scope_j->>'source_name','')))=0 OR scope_j ? 'source_class' OR scope_j ? 'source_definition_artifact_uuid'))
         OR (scope_j->>'type'='monitor_source_class'
          AND (length(btrim(COALESCE(scope_j->>'source_class','')))=0 OR scope_j ? 'source_name' OR scope_j ? 'source_definition_artifact_uuid'))
         OR (scope_j->>'type'='source_definition_artifact'
          AND (NOT(scope_j ? 'source_definition_artifact_uuid') OR scope_j ? 'source_name' OR scope_j ? 'source_class'))
      THEN RETURN false; END IF;

      timing_j:=item->'timing';
      IF (timing_j - ARRAY['mode','fixed_elapsed_seconds','recurrence_count','recurrence_unit','month_roll_policy'])<>'{}'::jsonb
      THEN RETURN false; END IF;
      mode:=timing_j->>'mode';
      IF mode NOT IN ('event_driven','fixed_elapsed','calendar_recurrence') THEN RETURN false; END IF;

      IF item ? 'grace_seconds' THEN
        BEGIN n:=(item->>'grace_seconds')::numeric;
        EXCEPTION WHEN OTHERS THEN RETURN false; END;
        IF n<0 THEN RETURN false; END IF;
      END IF;

      IF mode='event_driven' THEN
        IF timing_j ? 'fixed_elapsed_seconds' OR timing_j ? 'recurrence_count'
           OR timing_j ? 'recurrence_unit' OR timing_j ? 'month_roll_policy'
           OR length(btrim(COALESCE(item->>'event_channel_code','')))=0
           OR item ? 'anchor'
        THEN RETURN false; END IF;
      ELSIF mode='fixed_elapsed' THEN
        BEGIN n:=(timing_j->>'fixed_elapsed_seconds')::numeric;
        EXCEPTION WHEN OTHERS THEN RETURN false; END;
        IF n<=0 OR timing_j ? 'recurrence_count' OR timing_j ? 'recurrence_unit'
           OR timing_j ? 'month_roll_policy' OR item ? 'event_channel_code'
           OR jsonb_typeof(item->'anchor')<>'object'
        THEN RETURN false; END IF;
      ELSE
        BEGIN n:=(timing_j->>'recurrence_count')::numeric;
        EXCEPTION WHEN OTHERS THEN RETURN false; END;
        recurrence_unit:=timing_j->>'recurrence_unit';
        IF n<=0 OR trunc(n)<>n OR recurrence_unit NOT IN ('day','week','month')
           OR timing_j ? 'fixed_elapsed_seconds' OR item ? 'event_channel_code'
           OR jsonb_typeof(item->'anchor')<>'object'
           OR length(btrim(COALESCE(item->>'timezone_name','')))=0
           OR item->>'dst_resolution_policy' NOT IN ('shift_forward_to_first_valid','earliest_occurrence_on_fold')
           OR (recurrence_unit='month' AND timing_j->>'month_roll_policy'<>'preserve_day_or_clamp_last_day')
           OR (recurrence_unit<>'month' AND timing_j ? 'month_roll_policy')
        THEN RETURN false; END IF;
      END IF;

      IF item ? 'anchor' THEN
        anchor_j:=item->'anchor';
        IF (anchor_j - ARRAY['type','fixed_anchor_at'])<>'{}'::jsonb
           OR anchor_j->>'type' NOT IN ('policy_effective_at','fixed_timestamp','last_satisfaction')
           OR (anchor_j->>'type'='fixed_timestamp') IS DISTINCT FROM (anchor_j ? 'fixed_anchor_at')
        THEN RETURN false; END IF;
        IF anchor_j ? 'fixed_anchor_at' THEN
          BEGIN PERFORM (anchor_j->>'fixed_anchor_at')::timestamptz;
          EXCEPTION WHEN OTHERS THEN RETURN false; END;
        END IF;
      END IF;
    END LOOP;

    IF p->>'cadence_mode'='event_driven' AND EXISTS(
      SELECT 1 FROM jsonb_array_elements(p->'obligations') x
      WHERE x->'timing'->>'mode'<>'event_driven'
    ) THEN RETURN false; END IF;
    IF p->>'cadence_mode'='periodic' AND EXISTS(
      SELECT 1 FROM jsonb_array_elements(p->'obligations') x
      WHERE x->'timing'->>'mode'='event_driven'
    ) THEN RETURN false; END IF;
    IF p->>'cadence_mode'='hybrid' AND (
      NOT EXISTS(SELECT 1 FROM jsonb_array_elements(p->'obligations') x WHERE x->'timing'->>'mode'='event_driven')
      OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(p->'obligations') x WHERE x->'timing'->>'mode'<>'event_driven')
    ) THEN RETURN false; END IF;

    RETURN true;

  ELSIF p_kind='sla_rule' THEN
    IF p->>'schema_version'<>'oes.sla_rule_candidate/0.1'
       OR NOT (p ? 'clock_code' AND p ? 'selection_precedence' AND p ? 'filters'
               AND p ? 'endpoint_type' AND p ? 'time_basis' AND p ? 'pause_policy'
               AND p ? 'warning_policy' AND p ? 'breach_policy' AND p ? 'escalation_policy'
               AND p ? 'effective_at')
       OR (p - ARRAY['schema_version','clock_code','selection_precedence','filters','endpoint_type',
         'time_basis','target_duration_seconds','sla_calendar_version_uuid','fixed_deadline_source_snapshot',
         'pause_policy','warning_policy','breach_policy','escalation_policy','effective_at'])<>'{}'::jsonb
       OR p->>'clock_code' NOT IN (
         'SLA1_DETECTION_TO_TRIAGE','SLA2_TRIAGE_TO_MATERIALITY',
         'SLA3_MATERIALITY_TO_DECISION','SLA4_DECISION_TO_WORKFLOW_START',
         'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION','SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT')
       OR jsonb_typeof(p->'filters')<>'object'
       OR (p->'filters' - ARRAY['response_class','signal_class','trigger_class','decision_type','materiality_outcome'])<>'{}'::jsonb
       OR p->>'time_basis' NOT IN ('elapsed_time','business_calendar','fixed_deadline')
    THEN RETURN false; END IF;

    BEGIN
      IF (p->>'selection_precedence')::integer<1 THEN RETURN false; END IF;
      PERFORM (p->>'effective_at')::timestamptz;
    EXCEPTION WHEN OTHERS THEN RETURN false; END;

    IF p ? 'target_duration_seconds' THEN
      BEGIN n:=(p->>'target_duration_seconds')::numeric;
      EXCEPTION WHEN OTHERS THEN RETURN false; END;
      IF n<=0 THEN RETURN false; END IF;
    END IF;

    IF p->>'time_basis'='elapsed_time' THEN
      IF NOT(p ? 'target_duration_seconds') OR p ? 'sla_calendar_version_uuid' OR p ? 'fixed_deadline_source_snapshot' THEN RETURN false; END IF;
    ELSIF p->>'time_basis'='business_calendar' THEN
      IF NOT(p ? 'target_duration_seconds') OR NOT(p ? 'sla_calendar_version_uuid') OR p ? 'fixed_deadline_source_snapshot' THEN RETURN false; END IF;
    ELSE
      IF p ? 'target_duration_seconds' OR p ? 'sla_calendar_version_uuid'
         OR jsonb_typeof(p->'fixed_deadline_source_snapshot')<>'object' THEN RETURN false; END IF;
    END IF;

    RETURN true;

  ELSIF p_kind='sla_calendar' THEN
    IF p->>'schema_version'<>'oes.sla_calendar_candidate/0.1'
       OR NOT (p ? 'calendar_key' AND p ? 'timezone_name' AND p ? 'weekly_schedule'
               AND p ? 'exception_dates' AND p ? 'effective_from')
       OR (p - ARRAY['schema_version','calendar_key','timezone_name','weekly_schedule',
         'exception_dates','effective_from','effective_to'])<>'{}'::jsonb
       OR length(btrim(COALESCE(p->>'calendar_key','')))=0
       OR length(btrim(COALESCE(p->>'timezone_name','')))=0
       OR jsonb_typeof(p->'weekly_schedule')<>'object'
       OR jsonb_typeof(p->'exception_dates')<>'array'
    THEN RETURN false; END IF;

    BEGIN
      PERFORM (p->>'effective_from')::timestamptz;
      IF p ? 'effective_to' THEN
        IF (p->>'effective_to')::timestamptz <= (p->>'effective_from')::timestamptz THEN RETURN false; END IF;
      END IF;
    EXCEPTION WHEN OTHERS THEN RETURN false; END;

    IF NOT EXISTS(SELECT 1 FROM pg_timezone_names WHERE name=p->>'timezone_name') THEN RETURN false; END IF;
    IF to_regprocedure('maintenance.sla_calendar_payload_is_valid(jsonb,jsonb)') IS NOT NULL
       AND NOT maintenance.sla_calendar_payload_is_valid(p->'weekly_schedule',p->'exception_dates')
    THEN RETURN false; END IF;

    RETURN true;
  END IF;

  RETURN false;
END
$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_calibration_candidate()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF NOT maintenance.temporal_candidate_payload_is_valid(NEW.candidate_kind,NEW.candidate_payload) THEN
    RAISE EXCEPTION 'Temporal calibration candidate payload invalid';
  END IF;
  RETURN NEW;
END
$fn$;
DROP TRIGGER IF EXISTS tr_temporal_calibration_candidate ON maintenance.temporal_calibration_candidate;
CREATE TRIGGER tr_temporal_calibration_candidate
BEFORE INSERT ON maintenance.temporal_calibration_candidate
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_calibration_candidate();

CREATE OR REPLACE FUNCTION maintenance.assert_temporal_calibration_dossier_complete()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE p maintenance.update_risk_profile%ROWTYPE; selected_count integer; external_count integer; target_status text; target_type text;
BEGIN
  IF NEW.decision_status='draft' THEN RETURN NULL; END IF;

  IF OLD.decision_status<>'draft' AND NEW.decision_status IS DISTINCT FROM OLD.decision_status THEN
    RAISE EXCEPTION 'Terminal temporal calibration dossier cannot transition';
  END IF;

  IF NEW.scope_type='target' THEN
    SELECT * INTO p FROM maintenance.update_risk_profile
      WHERE update_risk_profile_uuid=NEW.update_risk_profile_uuid;
    IF NOT FOUND OR p.authority_status<>'authoritative'
       OR p.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
       OR p.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid
       OR p.assessed_at>NEW.decided_at OR p.effective_at>NEW.decided_at THEN
      RAISE EXCEPTION 'Approved/terminal target dossier requires temporally valid exact authoritative risk profile';
    END IF;
  END IF;

  IF NEW.decision_status='approved_for_normative_activation' THEN
    IF NEW.scope_type='target' THEN
      IF NEW.target_product_version_uuid IS NOT NULL THEN
        SELECT ev.version_status,pv.product_type INTO target_status,target_type
        FROM core.entity_version ev
        JOIN product.product_version pv ON pv.version_uuid=ev.version_uuid
        WHERE ev.version_uuid=NEW.target_product_version_uuid;
        IF target_status IS DISTINCT FROM 'current'
           OR target_type IN ('evidence_monitor','evidence_alert') THEN
          RAISE EXCEPTION 'Approved calibration dossier requires current maintainable ProductVersion target';
        END IF;
      ELSE
        SELECT ev.version_status,iv.investigation_type INTO target_status,target_type
        FROM core.entity_version ev
        JOIN investigation.investigation_version iv ON iv.version_uuid=ev.version_uuid
        WHERE ev.version_uuid=NEW.target_investigation_version_uuid;
        IF target_status IS DISTINCT FROM 'current'
           OR target_type='evidence_monitoring' THEN
          RAISE EXCEPTION 'Approved calibration dossier requires current maintainable InvestigationVersion target';
        END IF;
      END IF;

      IF EXISTS (
        SELECT 1 FROM maintenance.temporal_calibration_basis b
        WHERE b.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
          AND b.basis_role='controlling'
          AND b.basis_type IN ('external_normative','methodological_evidence','governance_decision')
          AND b.artifact_uuid IS NULL
          AND b.entity_version_uuid IS NULL
      ) THEN
        RAISE EXCEPTION 'Controlling normative/methodological/governance basis requires versioned Artifact or EntityVersion locator';
      END IF;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM maintenance.temporal_calibration_evaluation e
      JOIN maintenance.temporal_calibration_candidate c
        ON c.temporal_calibration_candidate_uuid=e.temporal_calibration_candidate_uuid
      WHERE c.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
        AND e.evaluation_type='historical_replay'
    ) THEN
      RAISE EXCEPTION 'Approved dossier requires historical replay evaluation';
    END IF;

    IF NEW.scope_type='target' THEN
      IF NOT EXISTS (SELECT 1 FROM maintenance.temporal_calibration_authority a
        WHERE a.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
          AND a.authority_domain='scientific_methodological'
          AND a.actor_type IN ('human_reviewer','human_expert')
          AND a.verification_status IN ('human_verified','human_consensus')) THEN
        RAISE EXCEPTION 'Approved target dossier requires scientific/methodological authority';
      END IF;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM maintenance.temporal_calibration_authority a
      WHERE a.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
        AND a.authority_domain='operational_feasibility' AND a.actor_type='owner') THEN
      RAISE EXCEPTION 'Approved dossier requires operational feasibility owner authority';
    END IF;

    SELECT count(*) INTO external_count FROM maintenance.temporal_calibration_basis b
      WHERE b.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
        AND b.basis_type='external_normative' AND b.basis_role='controlling';
    IF external_count>0 AND NOT EXISTS (
      SELECT 1 FROM maintenance.temporal_calibration_authority a
      WHERE a.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
        AND a.authority_domain='external_applicability'
    ) THEN RAISE EXCEPTION 'Controlling external normative basis requires external applicability authority'; END IF;

    SELECT count(*) INTO selected_count FROM maintenance.temporal_calibration_candidate c
      WHERE c.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
        AND c.disposition='selected'
        AND c.candidate_kind=NEW.calibration_kind;
    IF selected_count<>1 THEN RAISE EXCEPTION 'Approved dossier requires exactly one matching selected candidate'; END IF;
    IF NOT EXISTS (SELECT 1 FROM maintenance.temporal_calibration_evaluation e
      JOIN maintenance.temporal_calibration_candidate c
        ON c.temporal_calibration_candidate_uuid=e.temporal_calibration_candidate_uuid
      WHERE c.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
        AND e.evaluation_type='capacity_analysis') THEN
      RAISE EXCEPTION 'Approved dossier requires capacity analysis';
    END IF;
  ELSIF NEW.decision_status IN ('capacity_conflict','insufficient_evidence','rejected') THEN
    IF EXISTS (SELECT 1 FROM maintenance.temporal_calibration_candidate c
      WHERE c.temporal_calibration_dossier_uuid=NEW.temporal_calibration_dossier_uuid
        AND c.disposition='selected') THEN
      RAISE EXCEPTION 'Non-approval terminal dossier cannot have selected candidate';
    END IF;
  END IF;
  RETURN NULL;
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_calibration_dossier_complete
 ON maintenance.temporal_calibration_dossier;
CREATE CONSTRAINT TRIGGER tr_temporal_calibration_dossier_complete
AFTER INSERT OR UPDATE ON maintenance.temporal_calibration_dossier
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_temporal_calibration_dossier_complete();

CREATE OR REPLACE FUNCTION maintenance.guard_temporal_calibration_dossier_mutation()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF TG_OP='DELETE' THEN
    RAISE EXCEPTION 'Temporal calibration dossier cannot be deleted';
  END IF;

  IF OLD.decision_status='draft' THEN
    RETURN NEW;
  END IF;

  IF OLD.record_status='active'
     AND NEW.record_status='superseded'
     AND (to_jsonb(NEW)-'record_status')=(to_jsonb(OLD)-'record_status') THEN
    RETURN NEW;
  END IF;

  IF to_jsonb(NEW)=to_jsonb(OLD) THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'Terminal temporal calibration dossier is immutable; append/supersede instead';
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_calibration_dossier_immutable
 ON maintenance.temporal_calibration_dossier;
CREATE TRIGGER tr_temporal_calibration_dossier_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_calibration_dossier
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_temporal_calibration_dossier_mutation();

CREATE OR REPLACE FUNCTION maintenance.guard_temporal_calibration_child_immutable()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  RAISE EXCEPTION 'Temporal calibration child rows are immutable; append a new dossier';
END
$fn$;

DROP TRIGGER IF EXISTS tr_temporal_calibration_authority_immutable ON maintenance.temporal_calibration_authority;
CREATE TRIGGER tr_temporal_calibration_authority_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_calibration_authority
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_temporal_calibration_child_immutable();

DROP TRIGGER IF EXISTS tr_temporal_calibration_basis_immutable ON maintenance.temporal_calibration_basis;
CREATE TRIGGER tr_temporal_calibration_basis_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_calibration_basis
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_temporal_calibration_child_immutable();

DROP TRIGGER IF EXISTS tr_temporal_calibration_candidate_immutable ON maintenance.temporal_calibration_candidate;
CREATE TRIGGER tr_temporal_calibration_candidate_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_calibration_candidate
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_temporal_calibration_child_immutable();

DROP TRIGGER IF EXISTS tr_temporal_calibration_evaluation_immutable ON maintenance.temporal_calibration_evaluation;
CREATE TRIGGER tr_temporal_calibration_evaluation_immutable
BEFORE UPDATE OR DELETE ON maintenance.temporal_calibration_evaluation
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_temporal_calibration_child_immutable();
