-- Migration 031 fragment C — rebaseline header, normalized chain and child snapshots
-- Loaded by 031_propagation_rebaseline_contract.sql.

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_decision (
  rebaseline_decision_uuid uuid PRIMARY KEY,
  old_target_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  old_target_investigation_version_uuid uuid REFERENCES investigation.investigation_version(version_uuid),
  new_target_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  new_target_investigation_version_uuid uuid REFERENCES investigation.investigation_version(version_uuid),
  decision_stage text NOT NULL CHECK(decision_stage IN ('planned','activated','cancelled_invalidated')),
  transition_basis_type text NOT NULL CHECK(transition_basis_type IN (
    'update_decision','workflow_round','result_product_version',
    'result_investigation_version','governance_decision',
    'propagation_candidate','other')),
  update_decision_uuid uuid REFERENCES maintenance.update_decision(update_decision_uuid),
  workflow_round_uuid uuid REFERENCES maintenance.workflow_round(workflow_round_uuid),
  result_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  result_investigation_version_uuid uuid REFERENCES investigation.investigation_version(version_uuid),
  propagation_candidate_uuid uuid REFERENCES maintenance.propagation_candidate(propagation_candidate_uuid),
  basis_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
  external_basis_payload jsonb,
  version_chain_summary_payload jsonb NOT NULL DEFAULT '{}'::jsonb
    CHECK(jsonb_typeof(version_chain_summary_payload)='object'),
  authority_domain text NOT NULL CHECK(authority_domain IN ('operational','scientific','methodological','mixed')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  decided_by text NOT NULL CHECK(length(btrim(decided_by))>0),
  actor_type text NOT NULL CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')),
  verification_status text NOT NULL CHECK(verification_status IN ('unverified','ai_verified','human_verified','human_consensus')),
  verified_by text,
  verifier_actor_type text CHECK(verifier_actor_type IN ('ai_system','human_reviewer','human_expert')),
  verified_at timestamptz,
  authority_status text NOT NULL CHECK(authority_status IN ('proposal','authoritative')),
  decided_at timestamptz NOT NULL,
  activated_at timestamptz,
  recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  record_status text NOT NULL DEFAULT 'active' CHECK(record_status IN ('active','superseded')),
  supersedes_rebaseline_decision_uuid uuid REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  CHECK(num_nonnulls(old_target_product_version_uuid,old_target_investigation_version_uuid)=1),
  CHECK(num_nonnulls(new_target_product_version_uuid,new_target_investigation_version_uuid)=1),
  CHECK(
    (old_target_product_version_uuid IS NOT NULL AND new_target_product_version_uuid IS NOT NULL)
    OR (old_target_investigation_version_uuid IS NOT NULL AND new_target_investigation_version_uuid IS NOT NULL)
  ),
  CHECK(
    (transition_basis_type='update_decision'
      AND update_decision_uuid IS NOT NULL
      AND num_nonnulls(workflow_round_uuid,result_product_version_uuid,
        result_investigation_version_uuid,propagation_candidate_uuid,
        basis_artifact_uuid,external_basis_payload)=0)
    OR
    (transition_basis_type='workflow_round'
      AND workflow_round_uuid IS NOT NULL
      AND num_nonnulls(update_decision_uuid,result_product_version_uuid,
        result_investigation_version_uuid,propagation_candidate_uuid,
        basis_artifact_uuid,external_basis_payload)=0)
    OR
    (transition_basis_type='result_product_version'
      AND result_product_version_uuid IS NOT NULL
      AND num_nonnulls(update_decision_uuid,workflow_round_uuid,
        result_investigation_version_uuid,propagation_candidate_uuid,
        basis_artifact_uuid,external_basis_payload)=0)
    OR
    (transition_basis_type='result_investigation_version'
      AND result_investigation_version_uuid IS NOT NULL
      AND num_nonnulls(update_decision_uuid,workflow_round_uuid,
        result_product_version_uuid,propagation_candidate_uuid,
        basis_artifact_uuid,external_basis_payload)=0)
    OR
    (transition_basis_type='propagation_candidate'
      AND propagation_candidate_uuid IS NOT NULL
      AND num_nonnulls(update_decision_uuid,workflow_round_uuid,
        result_product_version_uuid,result_investigation_version_uuid,
        basis_artifact_uuid,external_basis_payload)=0)
    OR
    (transition_basis_type IN ('governance_decision','other')
      AND num_nonnulls(basis_artifact_uuid,external_basis_payload)=1
      AND num_nonnulls(update_decision_uuid,workflow_round_uuid,
        result_product_version_uuid,result_investigation_version_uuid,
        propagation_candidate_uuid)=0)
  ),
  CHECK(
    (decision_stage='activated' AND activated_at IS NOT NULL)
    OR (decision_stage<>'activated' AND activated_at IS NULL)
  )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_rebaseline_authoritative_activated_product
  ON maintenance.rebaseline_decision(old_target_product_version_uuid)
  WHERE record_status='active'
    AND decision_stage='activated'
    AND authority_status='authoritative'
    AND old_target_product_version_uuid IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_rebaseline_authoritative_activated_investigation
  ON maintenance.rebaseline_decision(old_target_investigation_version_uuid)
  WHERE record_status='active'
    AND decision_stage='activated'
    AND authority_status='authoritative'
    AND old_target_investigation_version_uuid IS NOT NULL;

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_version_chain_step (
  rebaseline_decision_uuid uuid NOT NULL
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  step_no integer NOT NULL CHECK(step_no>0),
  from_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
  to_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
  relationship_type text NOT NULL DEFAULT 'supersedes'
    CHECK(relationship_type='supersedes'),
  PRIMARY KEY(rebaseline_decision_uuid,step_no),
  CHECK(from_version_uuid<>to_version_uuid)
);

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_decision()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
  oe core.entity_version%ROWTYPE;
  ne core.entity_version%ROWTYPE;
  prior maintenance.rebaseline_decision%ROWTYPE;
  pt text;
  it text;
  old_target uuid;
  basis_target uuid;
  d maintenance.update_decision%ROWTYPE;
  wr maintenance.workflow_round%ROWTYPE;
  pc maintenance.propagation_candidate%ROWTYPE;
BEGIN
  IF NOT maintenance.assert_verification_metadata(
    NEW.verification_status,NEW.verified_by,
    NEW.verifier_actor_type,NEW.verified_at
  ) THEN
    RAISE EXCEPTION 'RebaselineDecision verification metadata mismatch';
  END IF;

  IF NEW.authority_status='authoritative'
     AND NEW.actor_type IN ('system','ai_system') THEN
    RAISE EXCEPTION 'System/AI cannot create authoritative RebaselineDecision';
  END IF;

  IF NEW.authority_status='authoritative'
     AND NEW.authority_domain IN ('scientific','methodological','mixed')
     AND (
       NEW.actor_type NOT IN ('human_reviewer','human_expert')
       OR NEW.verification_status NOT IN ('human_verified','human_consensus')
     ) THEN
    RAISE EXCEPTION 'Qualified human required for authoritative rebaseline';
  END IF;

  old_target:=COALESCE(
    NEW.old_target_product_version_uuid,
    NEW.old_target_investigation_version_uuid
  );

  SELECT * INTO oe
    FROM core.entity_version
   WHERE version_uuid=old_target;

  SELECT * INTO ne
    FROM core.entity_version
   WHERE version_uuid=COALESCE(
     NEW.new_target_product_version_uuid,
     NEW.new_target_investigation_version_uuid
   );

  IF oe.version_uuid IS NULL
     OR ne.version_uuid IS NULL
     OR oe.entity_uuid<>ne.entity_uuid
     OR ne.version_no<=oe.version_no
     OR ne.valid_from<oe.valid_from THEN
    RAISE EXCEPTION 'Rebaseline requires later version of same entity';
  END IF;

  IF NEW.old_target_product_version_uuid IS NOT NULL THEN
    SELECT product_type INTO pt
      FROM product.product_version
     WHERE version_uuid=NEW.old_target_product_version_uuid;
    IF pt IN ('evidence_monitor','evidence_alert') THEN
      RAISE EXCEPTION 'Old Product target not maintainable';
    END IF;

    SELECT product_type INTO pt
      FROM product.product_version
     WHERE version_uuid=NEW.new_target_product_version_uuid;
    IF pt IN ('evidence_monitor','evidence_alert') THEN
      RAISE EXCEPTION 'New Product target not maintainable';
    END IF;
  ELSE
    SELECT investigation_type INTO it
      FROM investigation.investigation_version
     WHERE version_uuid=NEW.old_target_investigation_version_uuid;
    IF it='evidence_monitoring' THEN
      RAISE EXCEPTION 'Old Investigation target not maintainable';
    END IF;

    SELECT investigation_type INTO it
      FROM investigation.investigation_version
     WHERE version_uuid=NEW.new_target_investigation_version_uuid;
    IF it='evidence_monitoring' THEN
      RAISE EXCEPTION 'New Investigation target not maintainable';
    END IF;
  END IF;

  IF NEW.decision_stage='activated'
     AND (
       NEW.authority_status<>'authoritative'
       OR ne.version_status<>'current'
     ) THEN
    RAISE EXCEPTION
      'Activated rebaseline requires authoritative decision and current new target';
  END IF;

  IF NEW.transition_basis_type='result_product_version'
     AND NEW.result_product_version_uuid
       IS DISTINCT FROM NEW.new_target_product_version_uuid THEN
    RAISE EXCEPTION 'Result ProductVersion basis must equal new target';
  END IF;

  IF NEW.transition_basis_type='result_investigation_version'
     AND NEW.result_investigation_version_uuid
       IS DISTINCT FROM NEW.new_target_investigation_version_uuid THEN
    RAISE EXCEPTION 'Result InvestigationVersion basis must equal new target';
  END IF;

  IF NEW.transition_basis_type='update_decision' THEN
    SELECT * INTO d
      FROM maintenance.update_decision
     WHERE update_decision_uuid=NEW.update_decision_uuid;

    SELECT COALESCE(
             p.target_product_version_uuid,
             p.target_investigation_version_uuid
           )
      INTO basis_target
      FROM maintenance.update_signal s
      JOIN maintenance.update_policy p USING(update_policy_uuid)
     WHERE s.update_signal_uuid=d.update_signal_uuid;

    IF basis_target IS DISTINCT FROM old_target
       OR (
         NEW.authority_status='authoritative'
         AND d.authority_status<>'authoritative'
       ) THEN
      RAISE EXCEPTION
        'UpdateDecision basis must belong to old target and be authoritative when required';
    END IF;

  ELSIF NEW.transition_basis_type='workflow_round' THEN
    SELECT * INTO wr
      FROM maintenance.workflow_round
     WHERE workflow_round_uuid=NEW.workflow_round_uuid;

    IF COALESCE(
         wr.target_product_version_uuid,
         wr.target_investigation_version_uuid
       ) IS DISTINCT FROM old_target THEN
      RAISE EXCEPTION 'Workflow basis target must equal old target';
    END IF;

    IF COALESCE(
         wr.result_product_version_uuid,
         wr.result_investigation_version_uuid
       ) IS NOT NULL
       AND COALESCE(
         wr.result_product_version_uuid,
         wr.result_investigation_version_uuid
       ) IS DISTINCT FROM COALESCE(
         NEW.new_target_product_version_uuid,
         NEW.new_target_investigation_version_uuid
       ) THEN
      RAISE EXCEPTION 'Workflow result must equal new target when present';
    END IF;

  ELSIF NEW.transition_basis_type='propagation_candidate' THEN
    SELECT * INTO pc
      FROM maintenance.propagation_candidate
     WHERE propagation_candidate_uuid=NEW.propagation_candidate_uuid;

    IF pc.impacted_version_uuid IS DISTINCT FROM old_target
       OR pc.assessment_status<>'assessed'
       OR pc.disposition<>'rebaseline_required'
       OR (
         NEW.authority_status='authoritative'
         AND pc.authority_status<>'authoritative'
       ) THEN
      RAISE EXCEPTION 'PropagationCandidate basis mismatch';
    END IF;
  END IF;

  IF NEW.supersedes_rebaseline_decision_uuid IS NOT NULL THEN
    SELECT * INTO prior
      FROM maintenance.rebaseline_decision
     WHERE rebaseline_decision_uuid=NEW.supersedes_rebaseline_decision_uuid;

    IF NOT FOUND
       OR prior.old_target_product_version_uuid
            IS DISTINCT FROM NEW.old_target_product_version_uuid
       OR prior.old_target_investigation_version_uuid
            IS DISTINCT FROM NEW.old_target_investigation_version_uuid
       OR prior.new_target_product_version_uuid
            IS DISTINCT FROM NEW.new_target_product_version_uuid
       OR prior.new_target_investigation_version_uuid
            IS DISTINCT FROM NEW.new_target_investigation_version_uuid
       OR NEW.decided_at<prior.decided_at
       OR prior.decision_stage='cancelled_invalidated'
       OR (
         prior.decision_stage='activated'
         AND NEW.decision_stage<>'activated'
       ) THEN
      RAISE EXCEPTION 'Invalid RebaselineDecision supersession/lifecycle';
    END IF;
  END IF;

  RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_rebaseline_decision_consistency
  ON maintenance.rebaseline_decision;
CREATE TRIGGER tr_rebaseline_decision_consistency
BEFORE INSERT ON maintenance.rebaseline_decision
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_decision();

DROP TRIGGER IF EXISTS tr_rebaseline_decision_guard
  ON maintenance.rebaseline_decision;
CREATE TRIGGER tr_rebaseline_decision_guard
BEFORE UPDATE OR DELETE ON maintenance.rebaseline_decision
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_append_snapshot();

CREATE OR REPLACE FUNCTION maintenance.assert_rebaseline_chain_step()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
  d maintenance.rebaseline_decision%ROWTYPE;
  f core.entity_version%ROWTYPE;
  t core.entity_version%ROWTYPE;
  prev uuid;
BEGIN
  SELECT * INTO d
    FROM maintenance.rebaseline_decision
   WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid;

  SELECT * INTO f
    FROM core.entity_version
   WHERE version_uuid=NEW.from_version_uuid;

  SELECT * INTO t
    FROM core.entity_version
   WHERE version_uuid=NEW.to_version_uuid;

  IF f.entity_uuid<>t.entity_uuid
     OR t.supersedes_version_uuid IS DISTINCT FROM f.version_uuid THEN
    RAISE EXCEPTION
      'Chain step must follow actual same-entity supersession';
  END IF;

  IF NEW.step_no=1
     AND NEW.from_version_uuid IS DISTINCT FROM COALESCE(
       d.old_target_product_version_uuid,
       d.old_target_investigation_version_uuid
     ) THEN
    RAISE EXCEPTION 'First chain step must start at old target';
  END IF;

  IF NEW.step_no>1 THEN
    SELECT to_version_uuid
      INTO prev
      FROM maintenance.rebaseline_version_chain_step
     WHERE rebaseline_decision_uuid=NEW.rebaseline_decision_uuid
       AND step_no=NEW.step_no-1;

    IF prev IS NULL OR prev<>NEW.from_version_uuid THEN
      RAISE EXCEPTION 'Chain steps must be contiguous';
    END IF;
  END IF;

  RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_rebaseline_chain_step_consistency
  ON maintenance.rebaseline_version_chain_step;
CREATE TRIGGER tr_rebaseline_chain_step_consistency
BEFORE INSERT ON maintenance.rebaseline_version_chain_step
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_rebaseline_chain_step();

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_policy_link (
  rebaseline_decision_uuid uuid PRIMARY KEY
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  old_update_policy_uuid uuid REFERENCES maintenance.update_policy(update_policy_uuid),
  new_update_policy_uuid uuid REFERENCES maintenance.update_policy(update_policy_uuid),
  policy_disposition text NOT NULL CHECK(policy_disposition IN (
    'replace_with_new_policy','stop_maintenance',
    'maintenance_policy_required','not_applicable','pending')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  linked_at timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_monitor_link (
  rebaseline_decision_uuid uuid PRIMARY KEY
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  old_monitor_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  new_monitor_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
  monitor_disposition text NOT NULL CHECK(monitor_disposition IN (
    'continue_same_monitor_lineage','replace_with_new_monitor_entity',
    'stop_monitoring','not_applicable','pending')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  linked_at timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_risk_profile_link (
  rebaseline_decision_uuid uuid PRIMARY KEY
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  source_update_risk_profile_uuid uuid
    REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
  target_update_risk_profile_uuid uuid
    REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
  profile_disposition text NOT NULL CHECK(profile_disposition IN (
    'target_profile_available','carry_forward_authorized',
    'new_assessment_required','target_reassessment_required',
    'not_applicable','pending')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  linked_at timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_coverage_item (
  rebaseline_decision_uuid uuid NOT NULL
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  coverage_code text NOT NULL CHECK(coverage_code IN (
    'incorporated_through_new_target_cutoff',
    'post_cutoff_pending_assessment',
    'known_gap_carried_forward',
    'source_recheck_required',
    'no_carry_forward_supported')),
  source_monitor_product_version_uuid uuid
    REFERENCES product.product_version(version_uuid),
  source_cycle_uuid uuid REFERENCES maintenance.monitor_cycle(cycle_uuid),
  window_start_date date,
  window_end_date date,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb
    CHECK(jsonb_typeof(payload)='object'),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  sequence_no integer NOT NULL CHECK(sequence_no>0),
  PRIMARY KEY(rebaseline_decision_uuid,coverage_code,sequence_no),
  CHECK(
    window_end_date IS NULL
    OR window_start_date IS NULL
    OR window_end_date>=window_start_date
  )
);

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_sla_rule_link (
  rebaseline_decision_uuid uuid NOT NULL
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  old_sla_rule_uuid uuid REFERENCES maintenance.sla_rule(sla_rule_uuid),
  new_sla_rule_uuid uuid REFERENCES maintenance.sla_rule(sla_rule_uuid),
  rule_code text NOT NULL CHECK(length(btrim(rule_code))>0),
  rule_disposition text NOT NULL CHECK(rule_disposition IN (
    'adopt_new_rule','not_configured',
    'retire_without_successor','not_applicable','pending')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  PRIMARY KEY(rebaseline_decision_uuid,rule_code)
);

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_sla_instance_disposition (
  rebaseline_decision_uuid uuid NOT NULL
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  old_sla_instance_uuid uuid NOT NULL
    REFERENCES maintenance.sla_instance(sla_instance_uuid),
  new_sla_instance_uuid uuid REFERENCES maintenance.sla_instance(sla_instance_uuid),
  instance_disposition text NOT NULL CHECK(instance_disposition IN (
    'finish_on_old_obligation','terminate_or_cancel_with_rationale',
    'supersede_operational_obligation_with_linkage',
    'open_new_obligation_independently',
    'governance_review_required')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  decided_at timestamptz NOT NULL,
  PRIMARY KEY(rebaseline_decision_uuid,old_sla_instance_uuid),
  CHECK(
    new_sla_instance_uuid IS NULL
    OR new_sla_instance_uuid<>old_sla_instance_uuid
  )
);

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_open_signal_disposition (
  rebaseline_decision_uuid uuid NOT NULL
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  old_update_signal_uuid uuid NOT NULL
    REFERENCES maintenance.update_signal(update_signal_uuid),
  new_update_signal_uuid uuid REFERENCES maintenance.update_signal(update_signal_uuid),
  signal_disposition text NOT NULL CHECK(signal_disposition IN (
    'retain_historical_no_transfer','resolve_on_old_target',
    'continue_old_target_workflow','create_new_signal_on_new_target',
    'governance_review_required')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  PRIMARY KEY(rebaseline_decision_uuid,old_update_signal_uuid),
  CHECK(
    new_update_signal_uuid IS NULL
    OR new_update_signal_uuid<>old_update_signal_uuid
  )
);

CREATE TABLE IF NOT EXISTS maintenance.rebaseline_workflow_link (
  rebaseline_decision_uuid uuid NOT NULL
    REFERENCES maintenance.rebaseline_decision(rebaseline_decision_uuid),
  old_workflow_round_uuid uuid NOT NULL
    REFERENCES maintenance.workflow_round(workflow_round_uuid),
  new_workflow_round_uuid uuid
    REFERENCES maintenance.workflow_round(workflow_round_uuid),
  workflow_disposition text NOT NULL CHECK(workflow_disposition IN (
    'complete_old_round','terminate_old_round',
    'old_round_produced_new_target',
    'open_new_round_independently','not_applicable')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  PRIMARY KEY(rebaseline_decision_uuid,old_workflow_round_uuid),
  CHECK(
    new_workflow_round_uuid IS NULL
    OR new_workflow_round_uuid<>old_workflow_round_uuid
  )
);

DO $do$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'rebaseline_version_chain_step',
    'rebaseline_policy_link',
    'rebaseline_monitor_link',
    'rebaseline_risk_profile_link',
    'rebaseline_coverage_item',
    'rebaseline_sla_rule_link',
    'rebaseline_sla_instance_disposition',
    'rebaseline_open_signal_disposition',
    'rebaseline_workflow_link'
  ]
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS tr_%s_immutable ON maintenance.%I',
      t,t
    );
    EXECUTE format(
      'CREATE TRIGGER tr_%s_immutable BEFORE UPDATE OR DELETE ON maintenance.%I FOR EACH ROW EXECUTE FUNCTION maintenance.guard_immutable_snapshot()',
      t,t
    );
  END LOOP;
END;
$do$;
