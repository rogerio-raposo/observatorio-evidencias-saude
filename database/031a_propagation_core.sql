-- Migration 031 fragment A — contract epoch + propagation core
-- Loaded by 031_propagation_rebaseline_contract.sql inside one transaction.

CREATE TABLE IF NOT EXISTS maintenance.contract_epoch (
  contract_code text PRIMARY KEY,
  schema_version text NOT NULL CHECK(length(btrim(schema_version))>0),
  effective_at timestamptz NOT NULL,
  migration_id text NOT NULL CHECK(length(btrim(migration_id))>0),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO maintenance.contract_epoch(contract_code,schema_version,effective_at,migration_id)
VALUES ('PROPAGATION_REBASELINE_V01','0.1',CURRENT_TIMESTAMP,'031')
ON CONFLICT(contract_code) DO NOTHING;

CREATE TABLE IF NOT EXISTS maintenance.propagation_assessment (
  propagation_assessment_uuid uuid PRIMARY KEY,
  origin_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
  replacement_version_uuid uuid REFERENCES core.entity_version(version_uuid),
  origin_event_class text NOT NULL CHECK(origin_event_class IN (
    'new_version','invalidation','correction','retraction','expression_of_concern',
    'methodological_change','certainty_change','applicability_change',
    'dependency_graph_change','governance_reassessment','other')),
  triggered_at timestamptz NOT NULL,
  dependency_snapshot_at timestamptz NOT NULL,
  max_depth integer NOT NULL CHECK(max_depth>0),
  lineage_validation_status text NOT NULL CHECK(lineage_validation_status IN (
    'validated_against_canonical_relations','projection_only_unverified',
    'projection_divergence_detected','incomplete_or_unknown')),
  lineage_validation_payload jsonb NOT NULL DEFAULT '{}'::jsonb
    CHECK(jsonb_typeof(lineage_validation_payload)='object'),
  assessment_scope text NOT NULL CHECK(assessment_scope IN ('direct_only','transitive')),
  rationale text NOT NULL CHECK(length(btrim(rationale))>0),
  initiated_by text NOT NULL CHECK(length(btrim(initiated_by))>0),
  actor_type text NOT NULL CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')),
  verification_status text NOT NULL CHECK(verification_status IN ('unverified','ai_verified','human_verified','human_consensus')),
  verified_by text,
  verifier_actor_type text CHECK(verifier_actor_type IN ('ai_system','human_reviewer','human_expert')),
  verified_at timestamptz,
  authority_status text NOT NULL CHECK(authority_status IN ('proposal','authoritative')),
  assessed_at timestamptz NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  record_status text NOT NULL DEFAULT 'active' CHECK(record_status IN ('active','superseded')),
  supersedes_propagation_assessment_uuid uuid REFERENCES maintenance.propagation_assessment(propagation_assessment_uuid),
  CHECK(replacement_version_uuid IS NULL OR replacement_version_uuid<>origin_version_uuid),
  CHECK(supersedes_propagation_assessment_uuid IS NULL OR supersedes_propagation_assessment_uuid<>propagation_assessment_uuid)
);
CREATE INDEX IF NOT EXISTS ix_propagation_assessment_origin
  ON maintenance.propagation_assessment(origin_version_uuid,record_status);
CREATE INDEX IF NOT EXISTS ix_propagation_assessment_replacement
  ON maintenance.propagation_assessment(replacement_version_uuid);

CREATE OR REPLACE FUNCTION maintenance.guard_append_snapshot()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Append-preserving snapshot cannot be deleted'; END IF;
  IF OLD.record_status='active' AND NEW.record_status='superseded'
     AND to_jsonb(NEW)-'record_status'-'recorded_at'=to_jsonb(OLD)-'record_status'-'recorded_at'
  THEN RETURN NEW; END IF;
  RAISE EXCEPTION 'Material fields are immutable; supersede and append';
END;$fn$;

CREATE OR REPLACE FUNCTION maintenance.assert_propagation_assessment()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE o core.entity_version%ROWTYPE; r core.entity_version%ROWTYPE; p maintenance.propagation_assessment%ROWTYPE;
BEGIN
  IF NOT maintenance.assert_verification_metadata(NEW.verification_status,NEW.verified_by,NEW.verifier_actor_type,NEW.verified_at)
  THEN RAISE EXCEPTION 'PropagationAssessment verification metadata mismatch'; END IF;
  IF NEW.authority_status='authoritative' AND NEW.actor_type IN ('system','ai_system')
  THEN RAISE EXCEPTION 'System/AI cannot create authoritative PropagationAssessment'; END IF;
  SELECT * INTO o FROM core.entity_version WHERE version_uuid=NEW.origin_version_uuid;
  IF NOT FOUND THEN RAISE EXCEPTION 'PropagationAssessment origin missing'; END IF;
  IF NEW.replacement_version_uuid IS NOT NULL THEN
    SELECT * INTO r FROM core.entity_version WHERE version_uuid=NEW.replacement_version_uuid;
    IF NOT FOUND OR r.entity_uuid<>o.entity_uuid OR r.version_no<=o.version_no OR r.valid_from<o.valid_from
    THEN RAISE EXCEPTION 'Replacement must be later version of same entity'; END IF;
  END IF;
  IF NEW.supersedes_propagation_assessment_uuid IS NOT NULL THEN
    SELECT * INTO p FROM maintenance.propagation_assessment
      WHERE propagation_assessment_uuid=NEW.supersedes_propagation_assessment_uuid;
    IF NOT FOUND OR p.origin_version_uuid<>NEW.origin_version_uuid
       OR p.replacement_version_uuid IS DISTINCT FROM NEW.replacement_version_uuid
       OR NEW.assessed_at<p.assessed_at
    THEN RAISE EXCEPTION 'PropagationAssessment supersession mismatch'; END IF;
  END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_propagation_assessment_consistency ON maintenance.propagation_assessment;
CREATE TRIGGER tr_propagation_assessment_consistency BEFORE INSERT ON maintenance.propagation_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_propagation_assessment();
DROP TRIGGER IF EXISTS tr_propagation_assessment_guard ON maintenance.propagation_assessment;
CREATE TRIGGER tr_propagation_assessment_guard BEFORE UPDATE OR DELETE ON maintenance.propagation_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_append_snapshot();

CREATE TABLE IF NOT EXISTS maintenance.propagation_candidate (
  propagation_candidate_uuid uuid PRIMARY KEY,
  propagation_assessment_uuid uuid NOT NULL REFERENCES maintenance.propagation_assessment(propagation_assessment_uuid),
  impacted_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
  target_class text NOT NULL CHECK(target_class IN ('maintainable_product','maintainable_investigation','nonmaintainable_version')),
  impact_domain text NOT NULL CHECK(impact_domain IN (
    'scientific_content','methodological','certainty','applicability','safety_integrity',
    'currentness_review','maintenance','operational_only','mixed','unknown_pending_review')),
  assessment_status text NOT NULL CHECK(assessment_status IN ('pending','assessed','unresolved')),
  disposition text CHECK(disposition IN (
    'no_action_supported','reassessment_required','maintenance_policy_required','open_update_signal',
    'method_review_required','new_version_workflow_required','rebaseline_required',
    'dependency_correction_required','governance_review_required','unresolved')),
  authority_domain text NOT NULL CHECK(authority_domain IN ('operational','scientific','methodological','mixed')),
  rationale text,
  assessed_by text,
  actor_type text CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')),
  verification_status text NOT NULL CHECK(verification_status IN ('unverified','ai_verified','human_verified','human_consensus')),
  verified_by text,
  verifier_actor_type text CHECK(verifier_actor_type IN ('ai_system','human_reviewer','human_expert')),
  verified_at timestamptz,
  authority_status text NOT NULL CHECK(authority_status IN ('proposal','authoritative')),
  assessed_at timestamptz,
  recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  record_status text NOT NULL DEFAULT 'active' CHECK(record_status IN ('active','superseded')),
  supersedes_propagation_candidate_uuid uuid REFERENCES maintenance.propagation_candidate(propagation_candidate_uuid),
  CHECK((assessment_status='pending' AND disposition IS NULL)
     OR (assessment_status='assessed' AND disposition IS NOT NULL AND disposition<>'unresolved')
     OR (assessment_status='unresolved' AND disposition='unresolved'))
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_propagation_candidate_active_impacted
  ON maintenance.propagation_candidate(propagation_assessment_uuid,impacted_version_uuid)
  WHERE record_status='active';
CREATE INDEX IF NOT EXISTS ix_propagation_candidate_impacted
  ON maintenance.propagation_candidate(impacted_version_uuid,record_status);

CREATE OR REPLACE FUNCTION maintenance.propagation_target_class(p_version uuid)
RETURNS text LANGUAGE plpgsql STABLE AS $fn$
DECLARE pt text; it text;
BEGIN
  SELECT product_type INTO pt FROM product.product_version WHERE version_uuid=p_version;
  IF pt IS NOT NULL THEN
    IF pt IN ('evidence_monitor','evidence_alert') THEN RETURN 'nonmaintainable_version'; END IF;
    RETURN 'maintainable_product';
  END IF;
  SELECT investigation_type INTO it FROM investigation.investigation_version WHERE version_uuid=p_version;
  IF it IS NOT NULL THEN
    IF it='evidence_monitoring' THEN RETURN 'nonmaintainable_version'; END IF;
    RETURN 'maintainable_investigation';
  END IF;
  RETURN 'nonmaintainable_version';
END;$fn$;

CREATE OR REPLACE FUNCTION maintenance.active_update_policy_for_version(p_version uuid)
RETURNS uuid LANGUAGE sql STABLE AS $q$
SELECT update_policy_uuid FROM maintenance.update_policy
WHERE record_status='active'
  AND (target_product_version_uuid=p_version OR target_investigation_version_uuid=p_version)
LIMIT 1;$q$;

CREATE OR REPLACE FUNCTION maintenance.assert_propagation_candidate()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE a maintenance.propagation_assessment%ROWTYPE; prior maintenance.propagation_candidate%ROWTYPE; pol uuid;
BEGIN
  SELECT * INTO a FROM maintenance.propagation_assessment
    WHERE propagation_assessment_uuid=NEW.propagation_assessment_uuid;
  IF NOT FOUND OR a.record_status<>'active' THEN RAISE EXCEPTION 'Candidate requires active assessment'; END IF;
  IF NEW.target_class<>maintenance.propagation_target_class(NEW.impacted_version_uuid)
  THEN RAISE EXCEPTION 'PropagationCandidate target_class mismatch'; END IF;
  IF NOT maintenance.assert_verification_metadata(NEW.verification_status,NEW.verified_by,NEW.verifier_actor_type,NEW.verified_at)
  THEN RAISE EXCEPTION 'PropagationCandidate verification metadata mismatch'; END IF;
  IF NEW.authority_status='authoritative' THEN
    IF NEW.actor_type IN ('system','ai_system') THEN RAISE EXCEPTION 'System/AI cannot create authoritative candidate'; END IF;
    IF NEW.authority_domain IN ('scientific','methodological','mixed')
       AND (NEW.actor_type NOT IN ('human_reviewer','human_expert')
         OR NEW.verification_status NOT IN ('human_verified','human_consensus'))
    THEN RAISE EXCEPTION 'Qualified human required for authoritative candidate'; END IF;
  END IF;
  IF NEW.assessment_status='assessed' AND length(btrim(COALESCE(NEW.rationale,'')))=0
  THEN RAISE EXCEPTION 'Assessed candidate requires rationale'; END IF;
  IF NEW.target_class='nonmaintainable_version'
     AND NEW.disposition IN ('maintenance_policy_required','open_update_signal','rebaseline_required')
  THEN RAISE EXCEPTION 'Nonmaintainable version cannot use maintenance dispositions'; END IF;
  pol:=maintenance.active_update_policy_for_version(NEW.impacted_version_uuid);
  IF NEW.disposition='open_update_signal' AND pol IS NULL
  THEN RAISE EXCEPTION 'open_update_signal requires active exact-target policy'; END IF;
  IF NEW.disposition='maintenance_policy_required' AND pol IS NOT NULL
  THEN RAISE EXCEPTION 'maintenance_policy_required requires no active policy'; END IF;
  IF NEW.supersedes_propagation_candidate_uuid IS NOT NULL THEN
    SELECT * INTO prior FROM maintenance.propagation_candidate
      WHERE propagation_candidate_uuid=NEW.supersedes_propagation_candidate_uuid;
    IF NOT FOUND OR prior.propagation_assessment_uuid<>NEW.propagation_assessment_uuid
       OR prior.impacted_version_uuid<>NEW.impacted_version_uuid
    THEN RAISE EXCEPTION 'Candidate supersession mismatch'; END IF;
  END IF;
  RETURN NEW;
END;$fn$;
DROP TRIGGER IF EXISTS tr_propagation_candidate_consistency ON maintenance.propagation_candidate;
CREATE TRIGGER tr_propagation_candidate_consistency BEFORE INSERT ON maintenance.propagation_candidate
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_propagation_candidate();
DROP TRIGGER IF EXISTS tr_propagation_candidate_guard ON maintenance.propagation_candidate;
CREATE TRIGGER tr_propagation_candidate_guard BEFORE UPDATE OR DELETE ON maintenance.propagation_candidate
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_append_snapshot();

CREATE TABLE IF NOT EXISTS maintenance.propagation_path (
  propagation_path_uuid uuid PRIMARY KEY,
  propagation_candidate_uuid uuid NOT NULL REFERENCES maintenance.propagation_candidate(propagation_candidate_uuid),
  path_no integer NOT NULL CHECK(path_no>0),
  depth integer NOT NULL CHECK(depth>0),
  path_status text NOT NULL CHECK(path_status IN (
    'complete','cycle_detected','depth_limit_reached','projection_divergence','incomplete_unknown')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(propagation_candidate_uuid,path_no)
);
CREATE TABLE IF NOT EXISTS maintenance.propagation_path_step (
  propagation_path_uuid uuid NOT NULL REFERENCES maintenance.propagation_path(propagation_path_uuid),
  step_no integer NOT NULL CHECK(step_no>0),
  source_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
  target_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
  dependency_type text NOT NULL CHECK(length(btrim(dependency_type))>0),
  derivation_rule text NOT NULL CHECK(length(btrim(derivation_rule))>0),
  edge_created_at timestamptz NOT NULL,
  edge_status_at_snapshot text NOT NULL CHECK(length(btrim(edge_status_at_snapshot))>0),
  PRIMARY KEY(propagation_path_uuid,step_no),
  CHECK(source_version_uuid<>target_version_uuid)
);
CREATE INDEX IF NOT EXISTS ix_propagation_path_step_source ON maintenance.propagation_path_step(source_version_uuid);
CREATE INDEX IF NOT EXISTS ix_propagation_path_step_target ON maintenance.propagation_path_step(target_version_uuid);

CREATE OR REPLACE FUNCTION maintenance.guard_immutable_snapshot()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN RAISE EXCEPTION 'Snapshot is immutable'; END;$fn$;
DROP TRIGGER IF EXISTS tr_propagation_path_guard ON maintenance.propagation_path;
CREATE TRIGGER tr_propagation_path_guard BEFORE UPDATE OR DELETE ON maintenance.propagation_path
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_immutable_snapshot();
DROP TRIGGER IF EXISTS tr_propagation_path_step_guard ON maintenance.propagation_path_step;
CREATE TRIGGER tr_propagation_path_step_guard BEFORE UPDATE OR DELETE ON maintenance.propagation_path_step
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_immutable_snapshot();
