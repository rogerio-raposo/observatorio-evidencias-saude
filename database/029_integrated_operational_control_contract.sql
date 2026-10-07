-- OES-DBM-2026-0029
-- Fase 4 — Integrated operational control infrastructure
-- Depends on: migrations 002–028
-- Date: 2026-10-07
-- Scope: triage + priority/escalation + SLA + workflow infrastructure only.
-- No normative SLA durations, priority scores, auto-escalation, scheduler,
-- notifications, scientific propagation, assurance promotion or M3 unblock.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

-- ---------------------------------------------------------------------------
-- VALIDATION HELPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.risk_profile_snapshot_is_valid(p jsonb)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
SELECT
    jsonb_typeof(p)='object'
    AND length(btrim(COALESCE(p->>'schema_version','')))>0
    AND length(btrim(COALESCE(p->>'assessed_at','')))>0
    AND p ?& ARRAY['A1','A2','A3','A4','A5','B1','B2','B3','B4','B5']
    AND (p->>'A1') IN ('low','moderate','high')
    AND (p->>'A2') IN ('low','moderate','high')
    AND (p->>'A3') IN ('low','moderate','high')
    AND (p->>'A4') IN ('low','moderate','high')
    AND (p->>'A5') IN ('restricted','moderate','broad','systemic')
    AND (p->>'B1') IN ('high','moderate','low','very_low')
    AND (p->>'B2') IN ('short','moderate','long','unpredictable')
    AND (p->>'B3') IN ('low','moderate','high','extreme')
    AND (p->>'B4') IN ('low','moderate','high','very_high')
    AND (p->>'B5') IN ('adequate','strained','insufficient','unavailable')
    AND length(btrim(COALESCE(p->>'rationale','')))>0;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_calendar_payload_is_valid(
    p_weekly jsonb,
    p_exceptions jsonb
)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $fn$
DECLARE
    k text;
    v jsonb;
    item jsonb;
    d integer;
    a text;
    b text;
BEGIN
    IF jsonb_typeof(p_weekly)<>'object'
       OR jsonb_typeof(p_exceptions)<>'array' THEN
        RETURN false;
    END IF;

    FOR k,v IN SELECT * FROM jsonb_each(p_weekly)
    LOOP
        BEGIN d:=k::integer; EXCEPTION WHEN OTHERS THEN RETURN false; END;
        IF d<1 OR d>7 OR jsonb_typeof(v)<>'array' THEN RETURN false; END IF;
        FOR item IN SELECT * FROM jsonb_array_elements(v)
        LOOP
            IF jsonb_typeof(item)<>'object'
               OR NOT (item ? 'start' AND item ? 'end') THEN RETURN false; END IF;
            a:=item->>'start'; b:=item->>'end';
            IF a !~ '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$'
               OR b !~ '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$'
               OR a>=b THEN RETURN false; END IF;
        END LOOP;
    END LOOP;

    FOR item IN SELECT * FROM jsonb_array_elements(p_exceptions)
    LOOP
        IF jsonb_typeof(item)<>'object'
           OR length(btrim(COALESCE(item->>'date','')))=0
           OR (item->>'mode') NOT IN ('closed','custom') THEN RETURN false; END IF;
        IF item->>'mode'='custom'
           AND jsonb_typeof(item->'intervals')<>'array' THEN RETURN false; END IF;
    END LOOP;
    RETURN true;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.fixed_deadline_payload_is_valid(p jsonb)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
SELECT
    jsonb_typeof(p)='object'
    AND (p->>'deadline_source_type') IN
        ('external_rule','entity_version','artifact','manual_governance')
    AND (p->>'time_precision') IN ('timestamp','date')
    AND (
        ((p ? 'deadline_at')::int + (p ? 'deadline_date')::int)=1
    )
    AND (
        ((p->>'time_precision')='timestamp' AND p ? 'deadline_at')
        OR ((p->>'time_precision')='date' AND p ? 'deadline_date')
    )
    AND length(btrim(COALESCE(p->>'rationale','')))>0;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_clock_endpoint_is_valid(
    p_clock text,
    p_endpoint text
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
SELECT CASE p_clock
    WHEN 'SLA1_DETECTION_TO_TRIAGE' THEN p_endpoint='triage'
    WHEN 'SLA2_TRIAGE_TO_MATERIALITY' THEN p_endpoint='materiality'
    WHEN 'SLA3_MATERIALITY_TO_DECISION' THEN p_endpoint='update_decision'
    WHEN 'SLA4_DECISION_TO_WORKFLOW_START' THEN p_endpoint='workflow_started'
    WHEN 'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION'
        THEN p_endpoint='scientific_completed'
    WHEN 'SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT'
        THEN p_endpoint IN ('review_disposition','publication')
    ELSE false
END;
$q$;

-- ---------------------------------------------------------------------------
-- TRIAGE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_triage (
    update_triage_uuid uuid PRIMARY KEY,
    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),
    disposition text NOT NULL CHECK (
        disposition IN (
            'accepted_for_materiality','duplicate_or_already_covered',
            'invalid_signal','out_of_scope','routed_elsewhere'
        )
    ),
    duplicate_of_update_signal_uuid uuid
        REFERENCES maintenance.update_signal(update_signal_uuid),
    routed_to_uri text,
    routed_to_entity_version_uuid uuid
        REFERENCES core.entity_version(version_uuid),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    triaged_by text NOT NULL CHECK (length(btrim(triaged_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN (
            'system','ai_system','human_reviewer','human_expert','owner'
        )
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    authority_status text NOT NULL CHECK (
        authority_status IN ('proposal','authoritative')
    ),
    triaged_at timestamptz NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_update_triage_uuid uuid
        REFERENCES maintenance.update_triage(update_triage_uuid),
    CHECK (
        supersedes_update_triage_uuid IS NULL
        OR supersedes_update_triage_uuid<>update_triage_uuid
    ),
    CHECK (
        disposition<>'duplicate_or_already_covered'
        OR duplicate_of_update_signal_uuid IS NOT NULL
    ),
    CHECK (
        disposition<>'routed_elsewhere'
        OR num_nonnulls(routed_to_uri,routed_to_entity_version_uuid)=1
    ),
    CHECK (
        disposition='routed_elsewhere'
        OR num_nonnulls(routed_to_uri,routed_to_entity_version_uuid)=0
    ),
    CHECK (
        disposition='duplicate_or_already_covered'
        OR duplicate_of_update_signal_uuid IS NULL
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_update_triage_authoritative_active
    ON maintenance.update_triage(update_signal_uuid)
    WHERE record_status='active' AND authority_status='authoritative';

CREATE INDEX IF NOT EXISTS ix_update_triage_signal
    ON maintenance.update_triage(update_signal_uuid,record_status);

CREATE OR REPLACE FUNCTION maintenance.assert_update_triage_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    s maintenance.update_signal%ROWTYPE;
    prior maintenance.update_triage%ROWTYPE;
BEGIN
    SELECT * INTO s FROM maintenance.update_signal
     WHERE update_signal_uuid=NEW.update_signal_uuid;
    IF NOT FOUND THEN RAISE EXCEPTION 'UpdateTriage requires UpdateSignal'; END IF;

    IF NOT maintenance.assert_verification_metadata(
        NEW.verification_status,NEW.verified_by,
        NEW.verifier_actor_type,NEW.verified_at
    ) THEN
        RAISE EXCEPTION 'UpdateTriage verification metadata mismatch';
    END IF;

    IF NEW.authority_status='authoritative' THEN
        IF NEW.actor_type IN ('system','ai_system') THEN
            RAISE EXCEPTION 'System/AI cannot create authoritative UpdateTriage';
        END IF;
        IF NEW.disposition IN ('invalid_signal','out_of_scope')
           AND NEW.actor_type NOT IN ('human_reviewer','human_expert') THEN
            RAISE EXCEPTION 'Invalid/out-of-scope authoritative triage requires qualified human';
        END IF;
    END IF;

    IF NEW.disposition='duplicate_or_already_covered'
       AND NEW.duplicate_of_update_signal_uuid=NEW.update_signal_uuid THEN
        RAISE EXCEPTION 'UpdateSignal cannot be duplicate of itself';
    END IF;

    IF NEW.supersedes_update_triage_uuid IS NOT NULL THEN
        SELECT * INTO prior FROM maintenance.update_triage
         WHERE update_triage_uuid=NEW.supersedes_update_triage_uuid;
        IF NOT FOUND OR prior.update_signal_uuid<>NEW.update_signal_uuid THEN
            RAISE EXCEPTION 'UpdateTriage supersession must preserve signal';
        END IF;
        IF NEW.triaged_at<prior.triaged_at THEN
            RAISE EXCEPTION 'UpdateTriage supersession violates temporal order';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_triage_consistency ON maintenance.update_triage;
CREATE TRIGGER tr_update_triage_consistency
BEFORE INSERT ON maintenance.update_triage
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_triage_consistency();

CREATE OR REPLACE FUNCTION maintenance.assert_invalid_triage_signal_state()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    signal_status text;
BEGIN
    IF NEW.authority_status='authoritative'
       AND NEW.record_status='active'
       AND NEW.disposition='invalid_signal' THEN
        SELECT status INTO signal_status FROM maintenance.update_signal
         WHERE update_signal_uuid=NEW.update_signal_uuid;
        IF signal_status IS DISTINCT FROM 'invalidated' THEN
            RAISE EXCEPTION 'Authoritative invalid_signal triage requires invalidated UpdateSignal at commit';
        END IF;
    END IF;
    RETURN NULL;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_triage_invalid_signal_deferred
    ON maintenance.update_triage;
CREATE CONSTRAINT TRIGGER tr_update_triage_invalid_signal_deferred
AFTER INSERT OR UPDATE ON maintenance.update_triage
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_invalid_triage_signal_state();

CREATE OR REPLACE FUNCTION maintenance.guard_update_triage_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'UpdateTriage is append-preserving and cannot be deleted';
    END IF;
    IF OLD.record_status='active' AND NEW.record_status='superseded'
       AND NEW.update_triage_uuid=OLD.update_triage_uuid
       AND NEW.update_signal_uuid=OLD.update_signal_uuid
       AND NEW.disposition=OLD.disposition
       AND NEW.duplicate_of_update_signal_uuid IS NOT DISTINCT FROM OLD.duplicate_of_update_signal_uuid
       AND NEW.routed_to_uri IS NOT DISTINCT FROM OLD.routed_to_uri
       AND NEW.routed_to_entity_version_uuid IS NOT DISTINCT FROM OLD.routed_to_entity_version_uuid
       AND NEW.rationale=OLD.rationale
       AND NEW.triaged_by=OLD.triaged_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.verification_status=OLD.verification_status
       AND NEW.verified_by IS NOT DISTINCT FROM OLD.verified_by
       AND NEW.verifier_actor_type IS NOT DISTINCT FROM OLD.verifier_actor_type
       AND NEW.verified_at IS NOT DISTINCT FROM OLD.verified_at
       AND NEW.authority_status=OLD.authority_status
       AND NEW.triaged_at=OLD.triaged_at
       AND NEW.supersedes_update_triage_uuid IS NOT DISTINCT FROM OLD.supersedes_update_triage_uuid
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'UpdateTriage material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_update_triage_append_preserving
    ON maintenance.update_triage;
CREATE TRIGGER tr_update_triage_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.update_triage
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_update_triage_mutation();

-- ---------------------------------------------------------------------------
-- PRIORITY
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.priority_assessment (
    priority_assessment_uuid uuid PRIMARY KEY,
    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),
    update_policy_uuid uuid NOT NULL
        REFERENCES maintenance.update_policy(update_policy_uuid),
    stage text NOT NULL CHECK (
        stage IN (
            'signal_triage','materiality_resolution',
            'update_decision','execution','resolution'
        )
    ),
    response_class text NOT NULL CHECK (
        response_class IN ('standard','expedited','urgent','immediate')
    ),
    authority_scope text NOT NULL CHECK (
        authority_scope IN ('operational','scientific','mixed')
    ),
    authority_status text NOT NULL CHECK (
        authority_status IN ('proposal','authoritative')
    ),
    feasibility_status text NOT NULL CHECK (
        feasibility_status IN ('adequate','strained','insufficient','unavailable')
    ),
    triage_uuid uuid REFERENCES maintenance.update_triage(update_triage_uuid),
    materiality_assessment_uuid uuid
        REFERENCES maintenance.materiality_assessment(materiality_assessment_uuid),
    update_decision_uuid uuid
        REFERENCES maintenance.update_decision(update_decision_uuid),
    currency_state_uuid uuid REFERENCES product.currency_state(currency_state_uuid),
    alert_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    triggering_sla_instance_uuid uuid,
    risk_profile_snapshot jsonb NOT NULL,
    dependency_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    assessed_by text NOT NULL CHECK (length(btrim(assessed_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    assessed_at timestamptz NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_priority_assessment_uuid uuid
        REFERENCES maintenance.priority_assessment(priority_assessment_uuid),
    CHECK (jsonb_typeof(dependency_snapshot)='object'),
    CHECK (
        supersedes_priority_assessment_uuid IS NULL
        OR supersedes_priority_assessment_uuid<>priority_assessment_uuid
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_priority_assessment_active_signal
    ON maintenance.priority_assessment(update_signal_uuid)
    WHERE record_status='active';

CREATE INDEX IF NOT EXISTS ix_priority_assessment_policy
    ON maintenance.priority_assessment(update_policy_uuid,response_class);

CREATE OR REPLACE FUNCTION maintenance.assert_priority_assessment_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    s maintenance.update_signal%ROWTYPE;
    pol maintenance.update_policy%ROWTYPE;
    ma maintenance.materiality_assessment%ROWTYPE;
    prior maintenance.priority_assessment%ROWTYPE;
    alert_type text;
    alert_target_product uuid;
    alert_target_inv uuid;
    currency_product uuid;
    sla_start timestamptz;
BEGIN
    SELECT * INTO s FROM maintenance.update_signal
     WHERE update_signal_uuid=NEW.update_signal_uuid;
    IF NOT FOUND THEN RAISE EXCEPTION 'PriorityAssessment requires UpdateSignal'; END IF;
    IF s.update_policy_uuid<>NEW.update_policy_uuid THEN
        RAISE EXCEPTION 'PriorityAssessment policy must match UpdateSignal policy';
    END IF;

    SELECT * INTO pol FROM maintenance.update_policy
     WHERE update_policy_uuid=NEW.update_policy_uuid;

    IF NOT maintenance.risk_profile_snapshot_is_valid(NEW.risk_profile_snapshot) THEN
        RAISE EXCEPTION 'PriorityAssessment risk_profile_snapshot invalid';
    END IF;

    IF NOT maintenance.assert_verification_metadata(
        NEW.verification_status,NEW.verified_by,
        NEW.verifier_actor_type,NEW.verified_at
    ) THEN
        RAISE EXCEPTION 'PriorityAssessment verification metadata mismatch';
    END IF;

    IF NEW.authority_status='authoritative' THEN
        IF NEW.actor_type IN ('system','ai_system') THEN
            RAISE EXCEPTION 'System/AI cannot create authoritative PriorityAssessment';
        END IF;
        IF NEW.authority_scope IN ('scientific','mixed')
           AND NEW.actor_type NOT IN ('human_reviewer','human_expert') THEN
            RAISE EXCEPTION 'Scientific/mixed authoritative priority requires qualified human';
        END IF;
        IF NEW.authority_scope IN ('scientific','mixed')
           AND NEW.verification_status NOT IN ('human_verified','human_consensus') THEN
            RAISE EXCEPTION 'Scientific/mixed authoritative priority requires human verification';
        END IF;
    END IF;

    IF NEW.triage_uuid IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM maintenance.update_triage t
         WHERE t.update_triage_uuid=NEW.triage_uuid
           AND t.update_signal_uuid=NEW.update_signal_uuid
    ) THEN RAISE EXCEPTION 'PriorityAssessment triage must belong to signal'; END IF;

    IF NEW.materiality_assessment_uuid IS NOT NULL THEN
        SELECT * INTO ma FROM maintenance.materiality_assessment
         WHERE materiality_assessment_uuid=NEW.materiality_assessment_uuid;
        IF NOT FOUND OR ma.update_signal_uuid<>NEW.update_signal_uuid THEN
            RAISE EXCEPTION 'PriorityAssessment materiality must belong to signal';
        END IF;
        IF NEW.authority_status='authoritative'
           AND NEW.authority_scope IN ('scientific','mixed')
           AND ma.verification_status NOT IN ('human_verified','human_consensus') THEN
            RAISE EXCEPTION 'Authoritative scientific priority requires human-qualified materiality';
        END IF;
    END IF;

    IF NEW.update_decision_uuid IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM maintenance.update_decision d
         WHERE d.update_decision_uuid=NEW.update_decision_uuid
           AND d.update_signal_uuid=NEW.update_signal_uuid
    ) THEN RAISE EXCEPTION 'PriorityAssessment decision must belong to signal'; END IF;

    IF NEW.currency_state_uuid IS NOT NULL THEN
        SELECT product_version_uuid INTO currency_product
          FROM product.currency_state
         WHERE currency_state_uuid=NEW.currency_state_uuid;
        IF pol.target_product_version_uuid IS NULL
           OR currency_product IS DISTINCT FROM pol.target_product_version_uuid THEN
            RAISE EXCEPTION 'PriorityAssessment CurrencyState must belong to policy target';
        END IF;
    END IF;

    IF NEW.alert_product_version_uuid IS NOT NULL THEN
        SELECT pv.product_type,a.target_product_version_uuid,
               a.target_investigation_version_uuid
          INTO alert_type,alert_target_product,alert_target_inv
          FROM product.product_version pv
          JOIN maintenance.evidence_alert a
            ON a.alert_product_version_uuid=pv.version_uuid
         WHERE pv.version_uuid=NEW.alert_product_version_uuid;
        IF alert_type IS DISTINCT FROM 'evidence_alert' THEN
            RAISE EXCEPTION 'PriorityAssessment alert reference must be evidence_alert';
        END IF;
        IF alert_target_product IS DISTINCT FROM pol.target_product_version_uuid
           OR alert_target_inv IS DISTINCT FROM pol.target_investigation_version_uuid THEN
            RAISE EXCEPTION 'PriorityAssessment Alert target must match UpdatePolicy target';
        END IF;
    END IF;

    IF NEW.triggering_sla_instance_uuid IS NOT NULL THEN
        SELECT start_at INTO sla_start FROM maintenance.sla_instance
         WHERE sla_instance_uuid=NEW.triggering_sla_instance_uuid
           AND update_signal_uuid=NEW.update_signal_uuid;
        IF sla_start IS NULL OR sla_start>NEW.assessed_at THEN
            RAISE EXCEPTION 'Triggering SLA must belong to signal and precede PriorityAssessment';
        END IF;
    END IF;

    IF NEW.supersedes_priority_assessment_uuid IS NOT NULL THEN
        SELECT * INTO prior FROM maintenance.priority_assessment
         WHERE priority_assessment_uuid=NEW.supersedes_priority_assessment_uuid;
        IF NOT FOUND OR prior.update_signal_uuid<>NEW.update_signal_uuid THEN
            RAISE EXCEPTION 'PriorityAssessment supersession must preserve signal';
        END IF;
        IF NEW.assessed_at<prior.assessed_at THEN
            RAISE EXCEPTION 'PriorityAssessment supersession violates temporal order';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_priority_assessment_consistency
    ON maintenance.priority_assessment;
CREATE TRIGGER tr_priority_assessment_consistency
BEFORE INSERT ON maintenance.priority_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_priority_assessment_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_priority_assessment_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'PriorityAssessment is append-preserving and cannot be deleted';
    END IF;
    IF OLD.record_status='active' AND NEW.record_status='superseded'
       AND to_jsonb(NEW)-'record_status'-'recorded_at'
           = to_jsonb(OLD)-'record_status'-'recorded_at'
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'PriorityAssessment material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_priority_assessment_append_preserving
    ON maintenance.priority_assessment;
CREATE TRIGGER tr_priority_assessment_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.priority_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_priority_assessment_mutation();

CREATE TABLE IF NOT EXISTS maintenance.priority_basis (
    priority_assessment_uuid uuid NOT NULL
        REFERENCES maintenance.priority_assessment(priority_assessment_uuid),
    basis_code text NOT NULL CHECK (
        basis_code IN (
            'criticality','conclusion_sensitivity','safety_integrity',
            'materiality','currentness','alert_classification',
            'alert_reassessment_priority','dependency_reach',
            'sla_warning','sla_breach','fixed_deadline',
            'capacity','incorporation_cost','regulatory_constraint','other'
        )
    ),
    basis_effect text NOT NULL CHECK (
        basis_effect IN (
            'dominance_floor','strong_modifier','coordination_modifier',
            'operational_pressure','feasibility','context'
        )
    ),
    basis_value text NOT NULL CHECK (length(btrim(basis_value))>0),
    source_type text NOT NULL CHECK (
        source_type IN (
            'snapshot','triage','materiality_assessment','update_decision',
            'currency_state','alert_product_version','sla_instance',
            'escalation_case','entity_version','artifact'
        )
    ),
    update_triage_uuid uuid REFERENCES maintenance.update_triage(update_triage_uuid),
    materiality_assessment_uuid uuid
        REFERENCES maintenance.materiality_assessment(materiality_assessment_uuid),
    update_decision_uuid uuid
        REFERENCES maintenance.update_decision(update_decision_uuid),
    currency_state_uuid uuid REFERENCES product.currency_state(currency_state_uuid),
    alert_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    sla_instance_uuid uuid,
    escalation_case_uuid uuid,
    source_entity_version_uuid uuid REFERENCES core.entity_version(version_uuid),
    source_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    snapshot_payload jsonb,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    sequence_no integer,
    PRIMARY KEY(priority_assessment_uuid,basis_code,sequence_no),
    CHECK (
        (
            source_type='snapshot'
            AND num_nonnulls(
                update_triage_uuid,materiality_assessment_uuid,update_decision_uuid,
                currency_state_uuid,alert_product_version_uuid,sla_instance_uuid,
                escalation_case_uuid,source_entity_version_uuid,source_artifact_uuid
            )=0
            AND snapshot_payload IS NOT NULL
        )
        OR
        (
            source_type<>'snapshot'
            AND num_nonnulls(
                update_triage_uuid,materiality_assessment_uuid,update_decision_uuid,
                currency_state_uuid,alert_product_version_uuid,sla_instance_uuid,
                escalation_case_uuid,source_entity_version_uuid,source_artifact_uuid
            )=1
            AND snapshot_payload IS NULL
        )
    )
);

CREATE OR REPLACE FUNCTION maintenance.assert_priority_basis_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
    IF (NEW.source_type='triage') IS DISTINCT FROM (NEW.update_triage_uuid IS NOT NULL)
       OR (NEW.source_type='materiality_assessment') IS DISTINCT FROM (NEW.materiality_assessment_uuid IS NOT NULL)
       OR (NEW.source_type='update_decision') IS DISTINCT FROM (NEW.update_decision_uuid IS NOT NULL)
       OR (NEW.source_type='currency_state') IS DISTINCT FROM (NEW.currency_state_uuid IS NOT NULL)
       OR (NEW.source_type='alert_product_version') IS DISTINCT FROM (NEW.alert_product_version_uuid IS NOT NULL)
       OR (NEW.source_type='sla_instance') IS DISTINCT FROM (NEW.sla_instance_uuid IS NOT NULL)
       OR (NEW.source_type='escalation_case') IS DISTINCT FROM (NEW.escalation_case_uuid IS NOT NULL)
       OR (NEW.source_type='entity_version') IS DISTINCT FROM (NEW.source_entity_version_uuid IS NOT NULL)
       OR (NEW.source_type='artifact') IS DISTINCT FROM (NEW.source_artifact_uuid IS NOT NULL)
       OR (NEW.source_type='snapshot') IS DISTINCT FROM (NEW.snapshot_payload IS NOT NULL) THEN
        RAISE EXCEPTION 'PriorityBasis source_type/locator mismatch';
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_priority_basis_consistency ON maintenance.priority_basis;
CREATE TRIGGER tr_priority_basis_consistency
BEFORE INSERT ON maintenance.priority_basis
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_priority_basis_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_priority_basis_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    RAISE EXCEPTION 'PriorityBasis is immutable; supersede PriorityAssessment instead';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_priority_basis_immutable ON maintenance.priority_basis;
CREATE TRIGGER tr_priority_basis_immutable
BEFORE UPDATE OR DELETE ON maintenance.priority_basis
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_priority_basis_mutation();

-- ---------------------------------------------------------------------------
-- ESCALATION
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.escalation_case (
    escalation_case_uuid uuid PRIMARY KEY,
    update_signal_uuid uuid NOT NULL REFERENCES maintenance.update_signal(update_signal_uuid),
    priority_assessment_uuid uuid
        REFERENCES maintenance.priority_assessment(priority_assessment_uuid),
    status text NOT NULL CHECK (
        status IN ('candidate','active','acknowledged','resolved','cancelled_invalidated')
    ),
    opened_at timestamptz NOT NULL,
    activated_at timestamptz,
    acknowledged_at timestamptz,
    resolved_at timestamptz,
    cancelled_at timestamptz,
    opened_by text NOT NULL CHECK (length(btrim(opened_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')
    ),
    activated_by text,
    activation_actor_type text CHECK (
        activation_actor_type IN ('human_reviewer','human_expert','owner')
    ),
    resolution_disposition text,
    resolution_rationale text,
    resolution_reference_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_escalation_case_uuid uuid
        REFERENCES maintenance.escalation_case(escalation_case_uuid),
    CHECK (jsonb_typeof(resolution_reference_payload)='object'),
    CHECK (
        (status='candidate' AND activated_at IS NULL AND activated_by IS NULL
            AND activation_actor_type IS NULL)
        OR
        (status<>'candidate' AND activated_at IS NOT NULL
            AND activated_by IS NOT NULL AND activation_actor_type IS NOT NULL)
    ),
    CHECK (
        status<>'acknowledged' OR acknowledged_at IS NOT NULL
    ),
    CHECK (
        status<>'resolved'
        OR (resolved_at IS NOT NULL
            AND length(btrim(COALESCE(resolution_disposition,'')))>0
            AND length(btrim(COALESCE(resolution_rationale,'')))>0)
    ),
    CHECK (
        status<>'cancelled_invalidated'
        OR (cancelled_at IS NOT NULL
            AND length(btrim(COALESCE(resolution_rationale,'')))>0)
    )
);

CREATE INDEX IF NOT EXISTS ix_escalation_signal
    ON maintenance.escalation_case(update_signal_uuid,status);

CREATE TABLE IF NOT EXISTS maintenance.escalation_reason (
    escalation_case_uuid uuid NOT NULL
        REFERENCES maintenance.escalation_case(escalation_case_uuid),
    reason_code text NOT NULL CHECK (
        reason_code IN (
            'safety_integrity','validity_or_use','scientific_materiality',
            'current_use_control','methodological_reroute','operational_delay',
            'capacity_constraint','dependency_coordination',
            'regulatory_external','governance_exception'
        )
    ),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    source_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    sequence_no integer NOT NULL,
    PRIMARY KEY(escalation_case_uuid,reason_code,sequence_no)
);

CREATE TABLE IF NOT EXISTS maintenance.escalation_route (
    escalation_case_uuid uuid NOT NULL
        REFERENCES maintenance.escalation_case(escalation_case_uuid),
    route_code text NOT NULL CHECK (
        route_code IN (
            'operational_owner','qualified_scientific_review',
            'methodological_governance','current_use_governance',
            'safety_integrity_governance','publication_governance',
            'dependency_coordination','resource_governance'
        )
    ),
    route_status text NOT NULL CHECK (
        route_status IN ('requested','acknowledged','resolved','cancelled')
    ),
    assigned_to text,
    assigned_actor_type text CHECK (
        assigned_actor_type IN ('human_reviewer','human_expert','owner')
    ),
    requested_at timestamptz NOT NULL,
    acknowledged_at timestamptz,
    resolved_at timestamptz,
    resolution_reference_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    sequence_no integer NOT NULL,
    PRIMARY KEY(escalation_case_uuid,route_code,sequence_no)
);

CREATE OR REPLACE FUNCTION maintenance.guard_escalation_case_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
DECLARE ok boolean;
BEGIN
    IF TG_OP='DELETE' THEN RAISE EXCEPTION 'EscalationCase cannot be deleted'; END IF;
    ok := (OLD.status=NEW.status)
       OR (OLD.status='candidate' AND NEW.status IN ('active','cancelled_invalidated'))
       OR (OLD.status='active' AND NEW.status IN ('acknowledged','resolved','cancelled_invalidated'))
       OR (OLD.status='acknowledged' AND NEW.status IN ('resolved','cancelled_invalidated'));
    IF NOT ok THEN RAISE EXCEPTION 'Invalid EscalationCase status transition'; END IF;
    IF OLD.update_signal_uuid<>NEW.update_signal_uuid
       OR OLD.priority_assessment_uuid IS DISTINCT FROM NEW.priority_assessment_uuid
       OR OLD.opened_at<>NEW.opened_at OR OLD.opened_by<>NEW.opened_by
       OR OLD.actor_type<>NEW.actor_type
       OR OLD.supersedes_escalation_case_uuid IS DISTINCT FROM NEW.supersedes_escalation_case_uuid
    THEN RAISE EXCEPTION 'EscalationCase causal fields are immutable'; END IF;
    RETURN NEW;
END;
$guard$;

DROP TRIGGER IF EXISTS tr_escalation_case_guard ON maintenance.escalation_case;
CREATE TRIGGER tr_escalation_case_guard
BEFORE UPDATE OR DELETE ON maintenance.escalation_case
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_escalation_case_mutation();

CREATE OR REPLACE FUNCTION maintenance.escalation_case_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE e maintenance.escalation_case%ROWTYPE;
BEGIN
    SELECT * INTO e FROM maintenance.escalation_case WHERE escalation_case_uuid=p;
    IF NOT FOUND THEN RETURN QUERY SELECT 'MISSING_ESCALATION_CASE','error','EscalationCase missing'; RETURN; END IF;
    IF e.status IN ('active','acknowledged') AND NOT EXISTS (
        SELECT 1 FROM maintenance.escalation_reason r WHERE r.escalation_case_uuid=p
    ) THEN RETURN QUERY SELECT 'ESCALATION_REASON_REQUIRED','error','Active escalation requires reason'; END IF;
    IF e.status IN ('active','acknowledged') AND NOT EXISTS (
        SELECT 1 FROM maintenance.escalation_route r WHERE r.escalation_case_uuid=p
    ) THEN RETURN QUERY SELECT 'ESCALATION_ROUTE_REQUIRED','error','Active escalation requires route'; END IF;
    IF EXISTS (SELECT 1 FROM maintenance.escalation_reason r
        WHERE r.escalation_case_uuid=p AND r.reason_code='safety_integrity')
       AND NOT EXISTS (SELECT 1 FROM maintenance.escalation_route r
        WHERE r.escalation_case_uuid=p AND r.route_code='safety_integrity_governance') THEN
        RETURN QUERY SELECT 'SAFETY_ROUTE_REQUIRED','error','Safety escalation requires safety governance route';
    END IF;
    IF EXISTS (SELECT 1 FROM maintenance.escalation_reason r
        WHERE r.escalation_case_uuid=p AND r.reason_code='validity_or_use')
       AND (
         NOT EXISTS (SELECT 1 FROM maintenance.escalation_route r
          WHERE r.escalation_case_uuid=p AND r.route_code='current_use_governance')
         OR NOT EXISTS (SELECT 1 FROM maintenance.escalation_route r
          WHERE r.escalation_case_uuid=p AND r.route_code='qualified_scientific_review')
       ) THEN RETURN QUERY SELECT 'VALIDITY_ROUTES_REQUIRED','error','Validity/use escalation requires current-use and scientific routes'; END IF;
    IF EXISTS (SELECT 1 FROM maintenance.escalation_reason r
        WHERE r.escalation_case_uuid=p AND r.reason_code='capacity_constraint')
       AND NOT EXISTS (SELECT 1 FROM maintenance.escalation_route r
        WHERE r.escalation_case_uuid=p AND r.route_code='resource_governance') THEN
        RETURN QUERY SELECT 'RESOURCE_ROUTE_REQUIRED','error','Capacity escalation requires resource governance'; END IF;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- SLA CALENDAR / RULE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.sla_calendar_version (
    sla_calendar_version_uuid uuid PRIMARY KEY,
    calendar_key text NOT NULL CHECK (length(btrim(calendar_key))>0),
    version_no integer NOT NULL CHECK (version_no>0),
    timezone_name text NOT NULL CHECK (length(btrim(timezone_name))>0),
    weekly_schedule_payload jsonb NOT NULL,
    exception_dates_payload jsonb NOT NULL DEFAULT '[]'::jsonb,
    effective_from timestamptz NOT NULL,
    effective_to timestamptz,
    created_by text NOT NULL CHECK (length(btrim(created_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('human_reviewer','human_expert','owner')
    ),
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_sla_calendar_version_uuid uuid
        REFERENCES maintenance.sla_calendar_version(sla_calendar_version_uuid),
    UNIQUE(calendar_key,version_no),
    CHECK (effective_to IS NULL OR effective_to>=effective_from)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_sla_calendar_active
    ON maintenance.sla_calendar_version(calendar_key)
    WHERE record_status='active';

CREATE OR REPLACE FUNCTION maintenance.assert_sla_calendar_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
    IF NOT maintenance.sla_calendar_payload_is_valid(
        NEW.weekly_schedule_payload,NEW.exception_dates_payload
    ) THEN RAISE EXCEPTION 'SLA calendar payload invalid'; END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_sla_calendar_consistency ON maintenance.sla_calendar_version;
CREATE TRIGGER tr_sla_calendar_consistency
BEFORE INSERT ON maintenance.sla_calendar_version
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_calendar_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_sla_calendar_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN RAISE EXCEPTION 'SLACalendarVersion cannot be deleted'; END IF;
    IF OLD.record_status='active' AND NEW.record_status='superseded'
       AND NEW.sla_calendar_version_uuid=OLD.sla_calendar_version_uuid
       AND NEW.calendar_key=OLD.calendar_key AND NEW.version_no=OLD.version_no
       AND NEW.timezone_name=OLD.timezone_name
       AND NEW.weekly_schedule_payload=OLD.weekly_schedule_payload
       AND NEW.exception_dates_payload=OLD.exception_dates_payload
       AND NEW.effective_from=OLD.effective_from
       AND NEW.effective_to IS NOT DISTINCT FROM OLD.effective_to
       AND NEW.created_by=OLD.created_by AND NEW.actor_type=OLD.actor_type
       AND NEW.supersedes_sla_calendar_version_uuid
            IS NOT DISTINCT FROM OLD.supersedes_sla_calendar_version_uuid
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'SLACalendarVersion material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_sla_calendar_guard ON maintenance.sla_calendar_version;
CREATE TRIGGER tr_sla_calendar_guard
BEFORE UPDATE OR DELETE ON maintenance.sla_calendar_version
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_sla_calendar_mutation();

CREATE TABLE IF NOT EXISTS maintenance.sla_rule (
    sla_rule_uuid uuid PRIMARY KEY,
    rule_code text NOT NULL CHECK (length(btrim(rule_code))>0),
    update_policy_uuid uuid NOT NULL
        REFERENCES maintenance.update_policy(update_policy_uuid),
    clock_code text NOT NULL CHECK (
        clock_code IN (
            'SLA1_DETECTION_TO_TRIAGE','SLA2_TRIAGE_TO_MATERIALITY',
            'SLA3_MATERIALITY_TO_DECISION','SLA4_DECISION_TO_WORKFLOW_START',
            'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',
            'SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT'
        )
    ),
    selection_precedence integer NOT NULL CHECK (selection_precedence>0),
    response_class_filter text CHECK (
        response_class_filter IN ('standard','expedited','urgent','immediate')
    ),
    signal_class_filter text CHECK (
        signal_class_filter IN ('scientific_currentness','operational')
    ),
    trigger_class_filter text,
    decision_type_filter text,
    materiality_outcome_filter text,
    endpoint_type text NOT NULL CHECK (
        endpoint_type IN (
            'triage','materiality','update_decision','workflow_started',
            'scientific_completed','review_disposition','publication'
        )
    ),
    time_basis text NOT NULL CHECK (
        time_basis IN ('elapsed_time','business_calendar','fixed_deadline')
    ),
    target_duration interval,
    fixed_deadline_rule_payload jsonb,
    sla_calendar_version_uuid uuid
        REFERENCES maintenance.sla_calendar_version(sla_calendar_version_uuid),
    pause_allowed boolean NOT NULL DEFAULT false,
    pause_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    warning_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    breach_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    escalation_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    effective_at timestamptz NOT NULL,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    created_by text NOT NULL CHECK (length(btrim(created_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('human_reviewer','human_expert','owner')
    ),
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_sla_rule_uuid uuid REFERENCES maintenance.sla_rule(sla_rule_uuid)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_sla_rule_active_code
    ON maintenance.sla_rule(update_policy_uuid,rule_code)
    WHERE record_status='active';

CREATE UNIQUE INDEX IF NOT EXISTS ux_sla_rule_active_precedence
    ON maintenance.sla_rule(update_policy_uuid,clock_code,selection_precedence)
    WHERE record_status='active';

CREATE OR REPLACE FUNCTION maintenance.assert_sla_rule_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE prior maintenance.sla_rule%ROWTYPE;
BEGIN
    IF NOT maintenance.sla_clock_endpoint_is_valid(NEW.clock_code,NEW.endpoint_type) THEN
        RAISE EXCEPTION 'SLA Rule clock/endpoint mismatch';
    END IF;
    IF NEW.time_basis='elapsed_time' THEN
        IF NEW.target_duration IS NULL OR NEW.target_duration<=interval '0'
           OR NEW.sla_calendar_version_uuid IS NOT NULL
           OR NEW.fixed_deadline_rule_payload IS NOT NULL THEN
            RAISE EXCEPTION 'elapsed_time SLA Rule invalid';
        END IF;
    ELSIF NEW.time_basis='business_calendar' THEN
        IF NEW.target_duration IS NULL OR NEW.target_duration<=interval '0'
           OR NEW.sla_calendar_version_uuid IS NULL
           OR NEW.fixed_deadline_rule_payload IS NOT NULL THEN
            RAISE EXCEPTION 'business_calendar SLA Rule invalid';
        END IF;
    ELSE
        IF NEW.target_duration IS NOT NULL
           OR NOT maintenance.fixed_deadline_payload_is_valid(NEW.fixed_deadline_rule_payload)
           OR NEW.pause_allowed THEN
            RAISE EXCEPTION 'fixed_deadline SLA Rule invalid';
        END IF;
    END IF;
    IF NEW.supersedes_sla_rule_uuid IS NOT NULL THEN
        SELECT * INTO prior FROM maintenance.sla_rule
         WHERE sla_rule_uuid=NEW.supersedes_sla_rule_uuid;
        IF NOT FOUND OR prior.update_policy_uuid<>NEW.update_policy_uuid
           OR prior.rule_code<>NEW.rule_code THEN
            RAISE EXCEPTION 'SLA Rule supersession must preserve policy/rule_code';
        END IF;
        IF NEW.effective_at<prior.effective_at THEN
            RAISE EXCEPTION 'SLA Rule supersession violates temporal order';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_sla_rule_consistency ON maintenance.sla_rule;
CREATE TRIGGER tr_sla_rule_consistency
BEFORE INSERT ON maintenance.sla_rule
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_rule_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_sla_rule_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN RAISE EXCEPTION 'SLARule cannot be deleted'; END IF;
    IF OLD.record_status='active' AND NEW.record_status='superseded'
       AND NEW.sla_rule_uuid=OLD.sla_rule_uuid
       AND NEW.rule_code=OLD.rule_code
       AND NEW.update_policy_uuid=OLD.update_policy_uuid
       AND NEW.clock_code=OLD.clock_code
       AND NEW.selection_precedence=OLD.selection_precedence
       AND NEW.response_class_filter IS NOT DISTINCT FROM OLD.response_class_filter
       AND NEW.signal_class_filter IS NOT DISTINCT FROM OLD.signal_class_filter
       AND NEW.trigger_class_filter IS NOT DISTINCT FROM OLD.trigger_class_filter
       AND NEW.decision_type_filter IS NOT DISTINCT FROM OLD.decision_type_filter
       AND NEW.materiality_outcome_filter IS NOT DISTINCT FROM OLD.materiality_outcome_filter
       AND NEW.endpoint_type=OLD.endpoint_type
       AND NEW.time_basis=OLD.time_basis
       AND NEW.target_duration IS NOT DISTINCT FROM OLD.target_duration
       AND NEW.fixed_deadline_rule_payload IS NOT DISTINCT FROM OLD.fixed_deadline_rule_payload
       AND NEW.sla_calendar_version_uuid IS NOT DISTINCT FROM OLD.sla_calendar_version_uuid
       AND NEW.pause_allowed=OLD.pause_allowed
       AND NEW.pause_policy_payload=OLD.pause_policy_payload
       AND NEW.warning_policy_payload=OLD.warning_policy_payload
       AND NEW.breach_policy_payload=OLD.breach_policy_payload
       AND NEW.escalation_policy_payload=OLD.escalation_policy_payload
       AND NEW.effective_at=OLD.effective_at
       AND NEW.rationale=OLD.rationale
       AND NEW.created_by=OLD.created_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.supersedes_sla_rule_uuid IS NOT DISTINCT FROM OLD.supersedes_sla_rule_uuid
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'SLARule material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_sla_rule_guard ON maintenance.sla_rule;
CREATE TRIGGER tr_sla_rule_guard
BEFORE UPDATE OR DELETE ON maintenance.sla_rule
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_sla_rule_mutation();

-- ---------------------------------------------------------------------------
-- WORKFLOW ROUND (before SLA instance)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.workflow_round (
    workflow_round_uuid uuid PRIMARY KEY,
    update_signal_uuid uuid NOT NULL REFERENCES maintenance.update_signal(update_signal_uuid),
    update_decision_uuid uuid NOT NULL
        REFERENCES maintenance.update_decision(update_decision_uuid),
    round_type text NOT NULL CHECK (
        round_type IN (
            'scientific_update','methodological_reroute','review_revision',
            'publication_remediation','other'
        )
    ),
    round_no integer NOT NULL CHECK (round_no>0),
    parent_workflow_round_uuid uuid REFERENCES maintenance.workflow_round(workflow_round_uuid),
    opened_by_workflow_milestone_uuid uuid,
    target_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    target_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    result_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    result_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    status text NOT NULL CHECK (
        status IN ('planned','active','closed','terminated','cancelled_invalidated')
    ),
    opened_at timestamptz NOT NULL,
    closed_at timestamptz,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    created_by text NOT NULL CHECK (length(btrim(created_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('human_reviewer','human_expert','owner')
    ),
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    UNIQUE(update_signal_uuid,round_no),
    CHECK (num_nonnulls(target_product_version_uuid,target_investigation_version_uuid)=1),
    CHECK (num_nonnulls(result_product_version_uuid,result_investigation_version_uuid)<=1),
    CHECK (
        round_type<>'review_revision'
        OR (parent_workflow_round_uuid IS NOT NULL
            AND opened_by_workflow_milestone_uuid IS NOT NULL)
    ),
    CHECK (closed_at IS NULL OR closed_at>=opened_at)
);

CREATE OR REPLACE FUNCTION maintenance.assert_workflow_round_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE d maintenance.update_decision%ROWTYPE; p maintenance.update_policy%ROWTYPE;
BEGIN
    SELECT * INTO d FROM maintenance.update_decision
     WHERE update_decision_uuid=NEW.update_decision_uuid;
    IF NOT FOUND OR d.update_signal_uuid<>NEW.update_signal_uuid
       OR d.authority_status<>'authoritative' THEN
        RAISE EXCEPTION 'WorkflowRound requires authoritative UpdateDecision for same signal';
    END IF;
    SELECT pol.* INTO p
      FROM maintenance.update_signal s
      JOIN maintenance.update_policy pol ON pol.update_policy_uuid=s.update_policy_uuid
     WHERE s.update_signal_uuid=NEW.update_signal_uuid;
    IF p.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
       OR p.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid THEN
        RAISE EXCEPTION 'WorkflowRound target must match UpdatePolicy target';
    END IF;
    IF NEW.round_type='scientific_update'
       AND d.decision_type NOT IN ('scientific_update_incremental','scientific_update_broad') THEN
        RAISE EXCEPTION 'scientific_update round requires scientific update decision';
    END IF;
    IF NEW.round_type='methodological_reroute' AND d.decision_type<>'reroute_method' THEN
        RAISE EXCEPTION 'methodological_reroute round requires reroute_method decision';
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_workflow_round_consistency ON maintenance.workflow_round;
CREATE TRIGGER tr_workflow_round_consistency
BEFORE INSERT ON maintenance.workflow_round
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_workflow_round_consistency();

-- ---------------------------------------------------------------------------
-- SLA INSTANCE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.sla_instance (
    sla_instance_uuid uuid PRIMARY KEY,
    obligation_uuid uuid NOT NULL,
    sla_rule_uuid uuid NOT NULL REFERENCES maintenance.sla_rule(sla_rule_uuid),
    update_signal_uuid uuid NOT NULL REFERENCES maintenance.update_signal(update_signal_uuid),
    update_triage_uuid uuid REFERENCES maintenance.update_triage(update_triage_uuid),
    materiality_assessment_uuid uuid
        REFERENCES maintenance.materiality_assessment(materiality_assessment_uuid),
    update_decision_uuid uuid REFERENCES maintenance.update_decision(update_decision_uuid),
    workflow_round_uuid uuid REFERENCES maintenance.workflow_round(workflow_round_uuid),
    start_priority_assessment_uuid uuid
        REFERENCES maintenance.priority_assessment(priority_assessment_uuid),
    clock_code text NOT NULL,
    endpoint_type text NOT NULL,
    time_basis text NOT NULL,
    rule_snapshot_payload jsonb NOT NULL,
    source_detected_at timestamptz,
    pre_policy_age interval,
    start_at timestamptz NOT NULL,
    nominal_due_at timestamptz NOT NULL,
    end_at timestamptz,
    execution_status text NOT NULL CHECK (
        execution_status IN (
            'pending','running','paused','satisfied',
            'cancelled_invalidated','terminated_by_authority','not_applicable'
        )
    ),
    first_breached_at timestamptz,
    satisfied_at timestamptz,
    termination_reason text,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_sla_instance_uuid uuid
        REFERENCES maintenance.sla_instance(sla_instance_uuid),
    rebase_reason text,
    rebased_by text,
    rebase_actor_type text CHECK (
        rebase_actor_type IN ('human_reviewer','human_expert','owner')
    ),
    rebased_at timestamptz,
    CHECK (jsonb_typeof(rule_snapshot_payload)='object'),
    CHECK (nominal_due_at>=start_at),
    CHECK (
        supersedes_sla_instance_uuid IS NULL
        OR (
            length(btrim(COALESCE(rebase_reason,'')))>0
            AND rebased_by IS NOT NULL
            AND rebase_actor_type IS NOT NULL
            AND rebased_at IS NOT NULL
        )
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_sla_instance_active_signal_clock
    ON maintenance.sla_instance(update_signal_uuid,clock_code)
    WHERE record_status='active'
      AND clock_code IN (
        'SLA1_DETECTION_TO_TRIAGE','SLA2_TRIAGE_TO_MATERIALITY',
        'SLA3_MATERIALITY_TO_DECISION'
      );

CREATE UNIQUE INDEX IF NOT EXISTS ux_sla_instance_active_round_clock
    ON maintenance.sla_instance(workflow_round_uuid,clock_code)
    WHERE record_status='active'
      AND workflow_round_uuid IS NOT NULL
      AND clock_code IN (
        'SLA4_DECISION_TO_WORKFLOW_START',
        'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',
        'SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT'
      );

CREATE OR REPLACE FUNCTION maintenance.assert_sla_instance_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE
    r maintenance.sla_rule%ROWTYPE;
    prior maintenance.sla_instance%ROWTYPE;
    t maintenance.update_triage%ROWTYPE;
    ma maintenance.materiality_assessment%ROWTYPE;
    d maintenance.update_decision%ROWTYPE;
    milestone_time timestamptz;
BEGIN
    SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=NEW.sla_rule_uuid;
    IF NOT FOUND THEN RAISE EXCEPTION 'SLAInstance requires SLARule'; END IF;
    IF r.clock_code<>NEW.clock_code OR r.endpoint_type<>NEW.endpoint_type
       OR r.time_basis<>NEW.time_basis THEN
        RAISE EXCEPTION 'SLAInstance snapshot fields must match SLARule';
    END IF;
    IF r.update_policy_uuid<>(SELECT update_policy_uuid FROM maintenance.update_signal
        WHERE update_signal_uuid=NEW.update_signal_uuid) THEN
        RAISE EXCEPTION 'SLAInstance rule policy must match signal policy';
    END IF;
    IF NEW.clock_code IN (
        'SLA4_DECISION_TO_WORKFLOW_START',
        'SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION',
        'SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT'
    ) THEN
        IF NEW.workflow_round_uuid IS NULL THEN
            RAISE EXCEPTION 'SLA4-6 require WorkflowRound';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM maintenance.workflow_round w
            WHERE w.workflow_round_uuid=NEW.workflow_round_uuid
              AND w.update_signal_uuid=NEW.update_signal_uuid) THEN
            RAISE EXCEPTION 'SLA WorkflowRound must belong to signal';
        END IF;
    ELSE
        IF NEW.workflow_round_uuid IS NOT NULL THEN
            RAISE EXCEPTION 'SLA1-3 cannot bind WorkflowRound';
        END IF;
    END IF;
    IF NEW.clock_code='SLA2_TRIAGE_TO_MATERIALITY' THEN
        IF NOT EXISTS (SELECT 1 FROM maintenance.update_triage t
            WHERE t.update_triage_uuid=NEW.update_triage_uuid
              AND t.update_signal_uuid=NEW.update_signal_uuid
              AND t.authority_status='authoritative'
              AND t.disposition='accepted_for_materiality') THEN
            RAISE EXCEPTION 'SLA2 requires authoritative accepted triage';
        END IF;
    END IF;
    IF NEW.execution_status='satisfied' THEN
        IF NEW.satisfied_at IS NULL OR NEW.end_at IS NULL
           OR NEW.satisfied_at<>NEW.end_at THEN
            RAISE EXCEPTION 'Satisfied SLA requires matching end_at/satisfied_at';
        END IF;

        IF NEW.clock_code='SLA1_DETECTION_TO_TRIAGE' THEN
            SELECT * INTO t FROM maintenance.update_triage
             WHERE update_triage_uuid=NEW.update_triage_uuid;
            IF NOT FOUND OR t.update_signal_uuid<>NEW.update_signal_uuid
               OR t.authority_status<>'authoritative'
               OR NEW.end_at<>t.triaged_at THEN
                RAISE EXCEPTION 'Satisfied SLA1 requires authoritative triage endpoint';
            END IF;

        ELSIF NEW.clock_code='SLA2_TRIAGE_TO_MATERIALITY' THEN
            SELECT * INTO ma FROM maintenance.materiality_assessment
             WHERE materiality_assessment_uuid=NEW.materiality_assessment_uuid;
            IF NOT FOUND OR ma.update_signal_uuid<>NEW.update_signal_uuid
               OR ma.verification_status NOT IN ('human_verified','human_consensus')
               OR ma.verified_at IS NULL
               OR NEW.end_at<>ma.verified_at THEN
                RAISE EXCEPTION 'Satisfied SLA2 requires human-qualified materiality endpoint';
            END IF;

        ELSIF NEW.clock_code='SLA3_MATERIALITY_TO_DECISION' THEN
            SELECT * INTO d FROM maintenance.update_decision
             WHERE update_decision_uuid=NEW.update_decision_uuid;
            IF NOT FOUND OR d.update_signal_uuid<>NEW.update_signal_uuid
               OR d.authority_status<>'authoritative'
               OR d.verification_status NOT IN ('human_verified','human_consensus')
               OR NEW.end_at<>GREATEST(d.decided_at,d.verified_at) THEN
                RAISE EXCEPTION 'Satisfied SLA3 requires authoritative qualified decision endpoint';
            END IF;

        ELSIF NEW.clock_code='SLA4_DECISION_TO_WORKFLOW_START' THEN
            SELECT COALESCE(m.qualified_at,m.occurred_at)
              INTO milestone_time
              FROM maintenance.workflow_milestone m
             WHERE m.workflow_round_uuid=NEW.workflow_round_uuid
               AND m.milestone_type IN (
                    'scientific_workflow_started','methodological_workflow_started'
               )
               AND m.authority_status='authoritative'
               AND m.record_status='active'
             ORDER BY COALESCE(m.qualified_at,m.occurred_at)
             LIMIT 1;
            IF milestone_time IS NULL OR NEW.end_at<>milestone_time THEN
                RAISE EXCEPTION 'Satisfied SLA4 requires authoritative workflow-start milestone';
            END IF;

        ELSIF NEW.clock_code='SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION' THEN
            SELECT COALESCE(m.qualified_at,m.occurred_at)
              INTO milestone_time
              FROM maintenance.workflow_milestone m
             WHERE m.workflow_round_uuid=NEW.workflow_round_uuid
               AND m.milestone_type='scientific_workflow_completed'
               AND m.authority_status='authoritative'
               AND m.record_status='active'
             ORDER BY COALESCE(m.qualified_at,m.occurred_at)
             LIMIT 1;
            IF milestone_time IS NULL OR NEW.end_at<>milestone_time THEN
                RAISE EXCEPTION 'Satisfied SLA5 requires authoritative scientific-completion milestone';
            END IF;

        ELSIF NEW.clock_code='SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT' THEN
            SELECT COALESCE(m.qualified_at,m.occurred_at)
              INTO milestone_time
              FROM maintenance.workflow_milestone m
             WHERE m.workflow_round_uuid=NEW.workflow_round_uuid
               AND (
                    (NEW.endpoint_type='review_disposition'
                     AND m.milestone_type='review_disposition')
                    OR
                    (NEW.endpoint_type='publication'
                     AND m.milestone_type='publication')
               )
               AND m.authority_status='authoritative'
               AND m.record_status='active'
               AND m.time_precision='timestamp'
             ORDER BY COALESCE(m.qualified_at,m.occurred_at)
             LIMIT 1;
            IF milestone_time IS NULL OR NEW.end_at<>milestone_time THEN
                RAISE EXCEPTION 'Satisfied SLA6 requires authoritative timestamp-precision endpoint milestone';
            END IF;
        END IF;
    END IF;

    IF NEW.clock_code='SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION'
       AND NEW.execution_status IN ('running','paused','satisfied') THEN
        IF NOT EXISTS (
            SELECT 1 FROM maintenance.workflow_milestone m
             WHERE m.workflow_round_uuid=NEW.workflow_round_uuid
               AND m.milestone_type IN (
                    'scientific_workflow_started','methodological_workflow_started'
               )
               AND m.authority_status='authoritative'
               AND m.record_status='active'
        ) THEN
            RAISE EXCEPTION 'SLA5 requires explicit authoritative workflow-start milestone';
        END IF;
    END IF;

    IF NEW.supersedes_sla_instance_uuid IS NOT NULL THEN
        SELECT * INTO prior FROM maintenance.sla_instance
         WHERE sla_instance_uuid=NEW.supersedes_sla_instance_uuid;
        IF NOT FOUND OR prior.obligation_uuid<>NEW.obligation_uuid
           OR prior.update_signal_uuid<>NEW.update_signal_uuid
           OR prior.clock_code<>NEW.clock_code
           OR prior.workflow_round_uuid IS DISTINCT FROM NEW.workflow_round_uuid THEN
            RAISE EXCEPTION 'SLA rebase must preserve obligation identity and causal target';
        END IF;
        IF prior.first_breached_at IS NOT NULL
           AND NEW.first_breached_at IS DISTINCT FROM prior.first_breached_at THEN
            RAISE EXCEPTION 'SLA rebase must preserve first breach';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_sla_instance_consistency ON maintenance.sla_instance;
CREATE TRIGGER tr_sla_instance_consistency
BEFORE INSERT OR UPDATE ON maintenance.sla_instance
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_instance_consistency();

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
       OR OLD.workflow_round_uuid IS DISTINCT FROM NEW.workflow_round_uuid
       OR OLD.clock_code<>NEW.clock_code OR OLD.endpoint_type<>NEW.endpoint_type
       OR OLD.time_basis<>NEW.time_basis OR OLD.rule_snapshot_payload<>NEW.rule_snapshot_payload
       OR OLD.start_at<>NEW.start_at OR OLD.nominal_due_at<>NEW.nominal_due_at
    THEN RAISE EXCEPTION 'SLAInstance causal/snapshot fields are immutable'; END IF;
    IF OLD.first_breached_at IS NOT NULL
       AND NEW.first_breached_at IS DISTINCT FROM OLD.first_breached_at THEN
        RAISE EXCEPTION 'SLA first_breached_at is immutable once set';
    END IF;
    RETURN NEW;
END;
$guard$;

DROP TRIGGER IF EXISTS tr_sla_instance_guard ON maintenance.sla_instance;
CREATE TRIGGER tr_sla_instance_guard
BEFORE UPDATE OR DELETE ON maintenance.sla_instance
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_sla_instance_mutation();

-- ---------------------------------------------------------------------------
-- SLA PAUSE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.sla_pause (
    sla_pause_uuid uuid PRIMARY KEY,
    sla_instance_uuid uuid NOT NULL REFERENCES maintenance.sla_instance(sla_instance_uuid),
    reason_code text NOT NULL CHECK (
        reason_code IN (
            'external_dependency','awaiting_authoritative_source',
            'governance_hold','legal_regulatory_hold','other'
        )
    ),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    authorized_by text NOT NULL CHECK (length(btrim(authorized_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('human_reviewer','human_expert','owner')
    ),
    authorized_at timestamptz NOT NULL,
    started_at timestamptz NOT NULL,
    ended_at timestamptz,
    closed_by text,
    closed_at timestamptz,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    external_event_payload jsonb,
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_sla_pause_uuid uuid REFERENCES maintenance.sla_pause(sla_pause_uuid),
    CHECK (
        (ended_at IS NULL AND closed_by IS NULL AND closed_at IS NULL)
        OR
        (ended_at IS NOT NULL AND closed_by IS NOT NULL AND closed_at IS NOT NULL
         AND ended_at>=started_at AND closed_at>=ended_at)
    )
);

CREATE OR REPLACE FUNCTION maintenance.assert_sla_pause_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE i maintenance.sla_instance%ROWTYPE; r maintenance.sla_rule%ROWTYPE;
BEGIN
    SELECT * INTO i FROM maintenance.sla_instance WHERE sla_instance_uuid=NEW.sla_instance_uuid;
    SELECT * INTO r FROM maintenance.sla_rule WHERE sla_rule_uuid=i.sla_rule_uuid;
    IF NOT FOUND OR NOT r.pause_allowed OR r.time_basis='fixed_deadline' THEN
        RAISE EXCEPTION 'SLA pause not allowed by rule';
    END IF;
    IF NEW.started_at<i.start_at THEN RAISE EXCEPTION 'SLA pause cannot start before SLA'; END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_sla_pause_consistency ON maintenance.sla_pause;
CREATE TRIGGER tr_sla_pause_consistency
BEFORE INSERT ON maintenance.sla_pause
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_sla_pause_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_sla_pause_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN RAISE EXCEPTION 'SLAPause cannot be deleted'; END IF;
    IF OLD.ended_at IS NULL AND NEW.ended_at IS NOT NULL
       AND OLD.sla_pause_uuid=NEW.sla_pause_uuid
       AND OLD.sla_instance_uuid=NEW.sla_instance_uuid
       AND OLD.reason_code=NEW.reason_code
       AND OLD.rationale=NEW.rationale
       AND OLD.authorized_by=NEW.authorized_by
       AND OLD.actor_type=NEW.actor_type
       AND OLD.authorized_at=NEW.authorized_at
       AND OLD.started_at=NEW.started_at
       AND NEW.closed_by IS NOT NULL AND NEW.closed_at IS NOT NULL
       AND OLD.external_event_payload IS NOT DISTINCT FROM NEW.external_event_payload
       AND OLD.record_status=NEW.record_status
       AND OLD.supersedes_sla_pause_uuid IS NOT DISTINCT FROM NEW.supersedes_sla_pause_uuid
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'SLAPause material fields are immutable; only open-to-closed transition is allowed';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_sla_pause_guard ON maintenance.sla_pause;
CREATE TRIGGER tr_sla_pause_guard
BEFORE UPDATE OR DELETE ON maintenance.sla_pause
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_sla_pause_mutation();

CREATE OR REPLACE FUNCTION maintenance.sla_effective_due_at(p uuid)
RETURNS timestamptz LANGUAGE sql STABLE AS $q$
SELECT i.nominal_due_at
       + COALESCE((
          SELECT sum(COALESCE(sp.ended_at,CURRENT_TIMESTAMP)-sp.started_at)
            FROM maintenance.sla_pause sp
           WHERE sp.sla_instance_uuid=i.sla_instance_uuid
             AND sp.record_status='active'
       ),interval '0')
  FROM maintenance.sla_instance i
 WHERE i.sla_instance_uuid=p;
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_compliance_status(p uuid)
RETURNS text LANGUAGE plpgsql STABLE AS $fn$
DECLARE i maintenance.sla_instance%ROWTYPE; due_at timestamptz;
BEGIN
    SELECT * INTO i FROM maintenance.sla_instance WHERE sla_instance_uuid=p;
    IF NOT FOUND THEN RETURN NULL; END IF;
    IF i.execution_status='not_applicable' THEN RETURN 'not_applicable'; END IF;
    due_at:=maintenance.sla_effective_due_at(p);
    IF i.first_breached_at IS NOT NULL THEN
        IF i.satisfied_at IS NOT NULL THEN RETURN 'breached_then_satisfied'; END IF;
        RETURN 'breached_open';
    END IF;
    IF i.satisfied_at IS NOT NULL THEN
        IF i.satisfied_at<=due_at THEN RETURN 'satisfied_on_time'; END IF;
        RETURN 'breached_then_satisfied';
    END IF;
    IF CURRENT_TIMESTAMP<=due_at THEN RETURN 'within_target'; END IF;
    RETURN 'breached_open';
END;
$fn$;

-- ---------------------------------------------------------------------------
-- WORKFLOW MILESTONE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.workflow_milestone (
    workflow_milestone_uuid uuid PRIMARY KEY,
    workflow_round_uuid uuid NOT NULL REFERENCES maintenance.workflow_round(workflow_round_uuid),
    milestone_type text NOT NULL CHECK (
        milestone_type IN (
            'scientific_workflow_started','methodological_workflow_started',
            'scientific_workflow_completed','review_disposition',
            'publication','workflow_terminated'
        )
    ),
    adapter_type text NOT NULL CHECK (
        adapter_type IN (
            'native_event','product_review','assurance_record','method_decision',
            'product_version','investigation_version','artifact'
        )
    ),
    time_precision text NOT NULL CHECK (time_precision IN ('timestamp','date')),
    occurred_at timestamptz,
    occurred_date date,
    qualified_at timestamptz,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    authority_status text NOT NULL CHECK (
        authority_status IN ('proposal','authoritative')
    ),
    actor text NOT NULL CHECK (length(btrim(actor))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')
    ),
    product_review_uuid uuid REFERENCES product.review_record(review_uuid),
    assurance_uuid uuid REFERENCES product.assurance_record(assurance_uuid),
    method_decision_uuid uuid REFERENCES investigation.method_decision(method_decision_uuid),
    product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    adapter_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_workflow_milestone_uuid uuid
        REFERENCES maintenance.workflow_milestone(workflow_milestone_uuid),
    CHECK (
        (time_precision='timestamp' AND occurred_at IS NOT NULL AND occurred_date IS NULL)
        OR
        (time_precision='date' AND occurred_date IS NOT NULL AND occurred_at IS NULL)
    ),
    CHECK (
        (adapter_type='native_event' AND num_nonnulls(
            product_review_uuid,assurance_uuid,method_decision_uuid,
            product_version_uuid,investigation_version_uuid,artifact_uuid
        )=0)
        OR
        (adapter_type<>'native_event' AND num_nonnulls(
            product_review_uuid,assurance_uuid,method_decision_uuid,
            product_version_uuid,investigation_version_uuid,artifact_uuid
        )=1)
    )
);

CREATE INDEX IF NOT EXISTS ix_workflow_milestone_round
    ON maintenance.workflow_milestone(workflow_round_uuid,milestone_type);

CREATE OR REPLACE FUNCTION maintenance.assert_workflow_milestone_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE rr product.review_record%ROWTYPE; ar product.assurance_record%ROWTYPE;
    md investigation.method_decision%ROWTYPE; pv product.product_version%ROWTYPE;
BEGIN
    IF (NEW.adapter_type='product_review') IS DISTINCT FROM (NEW.product_review_uuid IS NOT NULL)
       OR (NEW.adapter_type='assurance_record') IS DISTINCT FROM (NEW.assurance_uuid IS NOT NULL)
       OR (NEW.adapter_type='method_decision') IS DISTINCT FROM (NEW.method_decision_uuid IS NOT NULL)
       OR (NEW.adapter_type='product_version') IS DISTINCT FROM (NEW.product_version_uuid IS NOT NULL)
       OR (NEW.adapter_type='investigation_version') IS DISTINCT FROM (NEW.investigation_version_uuid IS NOT NULL)
       OR (NEW.adapter_type='artifact') IS DISTINCT FROM (NEW.artifact_uuid IS NOT NULL)
       OR (NEW.adapter_type='native_event') IS DISTINCT FROM (
           num_nonnulls(NEW.product_review_uuid,NEW.assurance_uuid,NEW.method_decision_uuid,
             NEW.product_version_uuid,NEW.investigation_version_uuid,NEW.artifact_uuid)=0
       ) THEN RAISE EXCEPTION 'WorkflowMilestone adapter_type/locator mismatch'; END IF;

    IF NEW.authority_status='authoritative'
       AND NEW.adapter_type='native_event'
       AND NEW.milestone_type IN (
         'scientific_workflow_started','scientific_workflow_completed'
       )
       AND NEW.actor_type NOT IN ('human_reviewer','human_expert') THEN
        RAISE EXCEPTION 'Authoritative native scientific milestone requires qualified human';
    END IF;

    IF NEW.milestone_type='review_disposition' THEN
        IF NEW.adapter_type='product_review' THEN
            SELECT * INTO rr FROM product.review_record WHERE review_uuid=NEW.product_review_uuid;
            IF NOT FOUND THEN RAISE EXCEPTION 'Review adapter missing'; END IF;
        ELSIF NEW.adapter_type='assurance_record' THEN
            SELECT * INTO ar FROM product.assurance_record WHERE assurance_uuid=NEW.assurance_uuid;
            IF NOT FOUND THEN RAISE EXCEPTION 'Assurance adapter missing'; END IF;
        ELSIF NEW.adapter_type='method_decision' THEN
            SELECT * INTO md FROM investigation.method_decision WHERE method_decision_uuid=NEW.method_decision_uuid;
            IF NOT FOUND THEN RAISE EXCEPTION 'MethodDecision adapter missing'; END IF;
            IF NOT EXISTS (SELECT 1 FROM maintenance.workflow_round w
                WHERE w.workflow_round_uuid=NEW.workflow_round_uuid
                  AND w.round_type='methodological_reroute') THEN
                RAISE EXCEPTION 'MethodDecision review adapter requires methodological workflow';
            END IF;
        ELSE
            RAISE EXCEPTION 'review_disposition requires review/assurance/method adapter';
        END IF;
    END IF;

    IF NEW.milestone_type='publication' THEN
        IF NEW.adapter_type<>'product_version' THEN
            RAISE EXCEPTION 'Publication milestone requires ProductVersion adapter';
        END IF;
        SELECT * INTO pv FROM product.product_version WHERE version_uuid=NEW.product_version_uuid;
        IF NOT FOUND OR pv.publication_date IS NULL THEN
            RAISE EXCEPTION 'Publication milestone requires published ProductVersion';
        END IF;
        IF NEW.time_precision='date' AND NEW.occurred_date<>pv.publication_date THEN
            RAISE EXCEPTION 'Publication date milestone must match ProductVersion publication_date';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_workflow_milestone_consistency
    ON maintenance.workflow_milestone;
CREATE TRIGGER tr_workflow_milestone_consistency
BEFORE INSERT ON maintenance.workflow_milestone
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_workflow_milestone_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_workflow_milestone_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'WorkflowMilestone is append-preserving and cannot be deleted';
    END IF;
    IF OLD.record_status='active' AND NEW.record_status='superseded'
       AND to_jsonb(NEW)-'record_status'-'recorded_at'
           = to_jsonb(OLD)-'record_status'-'recorded_at'
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'WorkflowMilestone material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_workflow_milestone_guard
    ON maintenance.workflow_milestone;
CREATE TRIGGER tr_workflow_milestone_guard
BEFORE UPDATE OR DELETE ON maintenance.workflow_milestone
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_workflow_milestone_mutation();

-- Add circular FKs after both sides exist.
DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname='fk_priority_triggering_sla'
           AND conrelid='maintenance.priority_assessment'::regclass
    ) THEN
        ALTER TABLE maintenance.priority_assessment
        ADD CONSTRAINT fk_priority_triggering_sla
        FOREIGN KEY (triggering_sla_instance_uuid)
        REFERENCES maintenance.sla_instance(sla_instance_uuid);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname='fk_priority_basis_sla'
           AND conrelid='maintenance.priority_basis'::regclass
    ) THEN
        ALTER TABLE maintenance.priority_basis
        ADD CONSTRAINT fk_priority_basis_sla
        FOREIGN KEY (sla_instance_uuid)
        REFERENCES maintenance.sla_instance(sla_instance_uuid);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname='fk_priority_basis_escalation'
           AND conrelid='maintenance.priority_basis'::regclass
    ) THEN
        ALTER TABLE maintenance.priority_basis
        ADD CONSTRAINT fk_priority_basis_escalation
        FOREIGN KEY (escalation_case_uuid)
        REFERENCES maintenance.escalation_case(escalation_case_uuid);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname='fk_workflow_round_opened_by_milestone'
           AND conrelid='maintenance.workflow_round'::regclass
    ) THEN
        ALTER TABLE maintenance.workflow_round
        ADD CONSTRAINT fk_workflow_round_opened_by_milestone
        FOREIGN KEY (opened_by_workflow_milestone_uuid)
        REFERENCES maintenance.workflow_milestone(workflow_milestone_uuid);
    END IF;
END;
$do$;

CREATE OR REPLACE FUNCTION maintenance.guard_workflow_round_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
DECLARE ok boolean;
BEGIN
    IF TG_OP='DELETE' THEN RAISE EXCEPTION 'WorkflowRound cannot be deleted'; END IF;
    ok := (OLD.status=NEW.status)
      OR (OLD.status='planned' AND NEW.status IN ('active','terminated','cancelled_invalidated'))
      OR (OLD.status='active' AND NEW.status IN ('closed','terminated','cancelled_invalidated'));
    IF NOT ok THEN RAISE EXCEPTION 'Invalid WorkflowRound status transition'; END IF;
    IF OLD.update_signal_uuid<>NEW.update_signal_uuid
       OR OLD.update_decision_uuid<>NEW.update_decision_uuid
       OR OLD.round_type<>NEW.round_type OR OLD.round_no<>NEW.round_no
       OR OLD.parent_workflow_round_uuid IS DISTINCT FROM NEW.parent_workflow_round_uuid
       OR OLD.opened_by_workflow_milestone_uuid IS DISTINCT FROM NEW.opened_by_workflow_milestone_uuid
       OR OLD.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
       OR OLD.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid
       OR OLD.result_product_version_uuid IS DISTINCT FROM NEW.result_product_version_uuid
       OR OLD.result_investigation_version_uuid IS DISTINCT FROM NEW.result_investigation_version_uuid
    THEN RAISE EXCEPTION 'WorkflowRound causal fields are immutable'; END IF;
    RETURN NEW;
END;
$guard$;

DROP TRIGGER IF EXISTS tr_workflow_round_guard ON maintenance.workflow_round;
CREATE TRIGGER tr_workflow_round_guard
BEFORE UPDATE OR DELETE ON maintenance.workflow_round
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_workflow_round_mutation();

CREATE OR REPLACE FUNCTION maintenance.update_triage_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE t maintenance.update_triage%ROWTYPE; s maintenance.update_signal%ROWTYPE;
BEGIN
    SELECT * INTO t FROM maintenance.update_triage WHERE update_triage_uuid=p;
    IF NOT FOUND THEN RETURN QUERY SELECT 'MISSING_UPDATE_TRIAGE','error','UpdateTriage missing'; RETURN; END IF;
    SELECT * INTO s FROM maintenance.update_signal WHERE update_signal_uuid=t.update_signal_uuid;
    IF t.authority_status='authoritative' AND t.disposition='invalid_signal'
       AND s.status<>'invalidated' THEN
        RETURN QUERY SELECT 'INVALID_TRIAGE_SIGNAL_STILL_ACTIVE','error','Authoritative invalid triage requires invalidated signal';
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.priority_assessment_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE pa maintenance.priority_assessment%ROWTYPE; ma maintenance.materiality_assessment%ROWTYPE;
BEGIN
    SELECT * INTO pa FROM maintenance.priority_assessment WHERE priority_assessment_uuid=p;
    IF NOT FOUND THEN RETURN QUERY SELECT 'MISSING_PRIORITY_ASSESSMENT','error','PriorityAssessment missing'; RETURN; END IF;
    IF pa.feasibility_status IN ('insufficient','unavailable')
       AND pa.response_class IN ('urgent','immediate')
       AND NOT EXISTS (
          SELECT 1 FROM maintenance.escalation_case e
          JOIN maintenance.escalation_reason r USING(escalation_case_uuid)
          WHERE e.update_signal_uuid=pa.update_signal_uuid
            AND r.reason_code='capacity_constraint'
            AND e.status IN ('active','acknowledged','resolved')
       ) THEN
        RETURN QUERY SELECT 'CAPACITY_ESCALATION_REQUIRED','warning','Urgent/immediate case with insufficient capacity needs capacity escalation';
    END IF;
    IF pa.materiality_assessment_uuid IS NOT NULL THEN
        SELECT * INTO ma FROM maintenance.materiality_assessment
         WHERE materiality_assessment_uuid=pa.materiality_assessment_uuid;
        IF ma.outcome='validity_or_use_threat'
           AND pa.response_class NOT IN ('urgent','immediate') THEN
            RETURN QUERY SELECT 'VALIDITY_PRIORITY_FLOOR_VIOLATION','error','Validity/use threat requires urgent/immediate priority';
        END IF;
        IF ma.outcome='material_change_confirmed'
           AND pa.risk_profile_snapshot->>'A1'='high'
           AND pa.response_class NOT IN ('urgent','immediate') THEN
            RETURN QUERY SELECT 'CONFIRMED_HIGH_CRITICALITY_FLOOR_VIOLATION','error','Confirmed material change + high criticality requires urgent/immediate';
        END IF;
        IF ma.outcome='potentially_material'
           AND (
              pa.risk_profile_snapshot->>'A1'='high'
              OR pa.risk_profile_snapshot->>'A3'='high'
           )
           AND pa.response_class='standard' THEN
            RETURN QUERY SELECT 'POTENTIAL_HIGH_RISK_FLOOR_VIOLATION','error','Potential materiality + high criticality/sensitivity requires expedited or higher';
        END IF;
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.sla_rule_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE sql STABLE AS $q$
SELECT 'MISSING_SLA_RULE','error','SLARule missing'
WHERE NOT EXISTS (SELECT 1 FROM maintenance.sla_rule WHERE sla_rule_uuid=p)
UNION ALL
SELECT 'AMBIGUOUS_ACTIVE_PRECEDENCE','error','Duplicate active precedence'
WHERE EXISTS (
  SELECT 1 FROM maintenance.sla_rule r
  WHERE r.sla_rule_uuid=p AND EXISTS (
    SELECT 1 FROM maintenance.sla_rule x
    WHERE x.update_policy_uuid=r.update_policy_uuid
      AND x.clock_code=r.clock_code
      AND x.selection_precedence=r.selection_precedence
      AND x.record_status='active' AND r.record_status='active'
      AND x.sla_rule_uuid<>r.sla_rule_uuid
  )
);
$q$;

CREATE OR REPLACE FUNCTION maintenance.sla_instance_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE i maintenance.sla_instance%ROWTYPE; due_at timestamptz;
BEGIN
    SELECT * INTO i FROM maintenance.sla_instance WHERE sla_instance_uuid=p;
    IF NOT FOUND THEN RETURN QUERY SELECT 'MISSING_SLA_INSTANCE','error','SLAInstance missing'; RETURN; END IF;
    due_at:=maintenance.sla_effective_due_at(p);
    IF CURRENT_TIMESTAMP>due_at AND i.first_breached_at IS NULL
       AND i.execution_status NOT IN ('satisfied','not_applicable','cancelled_invalidated','terminated_by_authority') THEN
        RETURN QUERY SELECT 'SLA_BREACH_NOT_MATERIALIZED','warning','Current time exceeds effective due without persisted first breach';
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.workflow_round_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE w maintenance.workflow_round%ROWTYPE;
BEGIN
    SELECT * INTO w FROM maintenance.workflow_round WHERE workflow_round_uuid=p;
    IF NOT FOUND THEN RETURN QUERY SELECT 'MISSING_WORKFLOW_ROUND','error','WorkflowRound missing'; RETURN; END IF;
    IF w.status='active' AND NOT EXISTS (
        SELECT 1 FROM maintenance.workflow_milestone m
        WHERE m.workflow_round_uuid=p
          AND m.milestone_type IN ('scientific_workflow_started','methodological_workflow_started')
          AND m.authority_status='authoritative' AND m.record_status='active'
    ) THEN RETURN QUERY SELECT 'ACTIVE_ROUND_MISSING_START','error','Active WorkflowRound requires authoritative start milestone'; END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.workflow_milestone_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE sql STABLE AS $q$
SELECT 'MISSING_WORKFLOW_MILESTONE','error','WorkflowMilestone missing'
WHERE NOT EXISTS (
  SELECT 1 FROM maintenance.workflow_milestone WHERE workflow_milestone_uuid=p
);
$q$;

CREATE OR REPLACE FUNCTION maintenance.operational_control_readiness(
    p_update_policy_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE p maintenance.update_policy%ROWTYPE;
BEGIN
    SELECT * INTO p FROM maintenance.update_policy WHERE update_policy_uuid=p_update_policy_uuid;
    IF NOT FOUND THEN
        RETURN QUERY SELECT 'MISSING_UPDATE_POLICY','error','UpdatePolicy missing'; RETURN;
    END IF;
    IF p.effective_maintenance_level='M3' THEN
        RETURN QUERY SELECT 'M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL','error','M3 remains formally blocked';
    END IF;
    IF EXISTS (
        SELECT 1 FROM maintenance.sla_rule r
        WHERE r.update_policy_uuid=p_update_policy_uuid
          AND r.record_status='active'
        GROUP BY r.clock_code,r.selection_precedence HAVING count(*)>1
    ) THEN
        RETURN QUERY SELECT 'AMBIGUOUS_SLA_RULE_SELECTION','error','Active SLA rule selection is ambiguous';
    END IF;
END;
$fn$;

COMMIT;
