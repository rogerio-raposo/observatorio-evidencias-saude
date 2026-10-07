-- OES-DBM-2026-0030
-- Fase 4 — Physical UpdateRiskProfile normalization
-- Depends on: migrations 001–029
-- Date: 2026-10-07
-- Scope: UpdateRiskProfile normalization only.
-- No risk score, numeric cadence, numeric SLA, auto-policy change or M3 unblock.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

-- ---------------------------------------------------------------------------
-- HELPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.risk_profile_dimension_value_is_valid(
    p_dimension text,
    p_value text
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
SELECT CASE p_dimension
    WHEN 'A1' THEN p_value IN ('low','moderate','high')
    WHEN 'A2' THEN p_value IN ('low','moderate','high')
    WHEN 'A3' THEN p_value IN ('low','moderate','high')
    WHEN 'A4' THEN p_value IN ('low','moderate','high')
    WHEN 'A5' THEN p_value IN ('restricted','moderate','broad','systemic')
    WHEN 'B1' THEN p_value IN ('high','moderate','low','very_low')
    WHEN 'B2' THEN p_value IN ('short','moderate','long','unpredictable')
    WHEN 'B3' THEN p_value IN ('low','moderate','high','extreme')
    WHEN 'B4' THEN p_value IN ('low','moderate','high','very_high')
    WHEN 'B5' THEN p_value IN ('adequate','strained','insufficient','unavailable')
    ELSE false
END;
$q$;

CREATE OR REPLACE FUNCTION maintenance.risk_profile_cadence_is_valid(
    p_level text,
    p_cadence text
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
SELECT CASE p_level
    WHEN 'M0' THEN p_cadence='none'
    WHEN 'M1' THEN p_cadence IN ('event_driven','periodic','hybrid')
    WHEN 'M2' THEN p_cadence IN ('periodic','hybrid')
    WHEN 'M3' THEN p_cadence IN ('continuous','hybrid')
    ELSE false
END;
$q$;

CREATE OR REPLACE FUNCTION maintenance.feasibility_respects_b5(
    p_b5 text,
    p_feasibility text
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
SELECT CASE p_b5
    WHEN 'adequate' THEN p_feasibility IN ('adequate','strained','insufficient','unavailable')
    WHEN 'strained' THEN p_feasibility IN ('strained','insufficient','unavailable')
    WHEN 'insufficient' THEN p_feasibility IN ('insufficient','unavailable')
    WHEN 'unavailable' THEN p_feasibility='unavailable'
    ELSE false
END;
$q$;

-- ---------------------------------------------------------------------------
-- PROFILE HEADER
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_risk_profile (
    update_risk_profile_uuid uuid PRIMARY KEY,
    target_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),
    target_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    assessment_kind text NOT NULL CHECK (
        assessment_kind IN ('initial','reassessment','carry_forward')
    ),
    recommended_maintenance_level text CHECK (
        recommended_maintenance_level IN ('M0','M1','M2','M3')
    ),
    recommended_cadence_mode text CHECK (
        recommended_cadence_mode IN ('none','event_driven','periodic','hybrid','continuous')
    ),
    event_driven_surveillance_required boolean,
    feasibility_status text CHECK (
        feasibility_status IN ('adequate','strained','insufficient','unavailable')
    ),
    priority_implications_payload jsonb,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    profiled_by text NOT NULL CHECK (length(btrim(profiled_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN ('unverified','ai_verified','human_verified','human_consensus')
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    authority_status text NOT NULL CHECK (
        authority_status IN ('proposal','authoritative')
    ),
    assessed_at timestamptz NOT NULL,
    effective_at timestamptz NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_update_risk_profile_uuid uuid
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
    carried_forward_from_profile_uuid uuid
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
    CHECK (
        num_nonnulls(target_product_version_uuid,target_investigation_version_uuid)=1
    ),
    CHECK (effective_at>=assessed_at),
    CHECK (jsonb_typeof(COALESCE(priority_implications_payload,'{}'::jsonb))='object'),
    CHECK (
        supersedes_update_risk_profile_uuid IS NULL
        OR supersedes_update_risk_profile_uuid<>update_risk_profile_uuid
    ),
    CHECK (
        carried_forward_from_profile_uuid IS NULL
        OR carried_forward_from_profile_uuid<>update_risk_profile_uuid
    ),
    CHECK (
        (assessment_kind='initial'
         AND supersedes_update_risk_profile_uuid IS NULL
         AND carried_forward_from_profile_uuid IS NULL)
        OR
        (assessment_kind='reassessment'
         AND supersedes_update_risk_profile_uuid IS NOT NULL
         AND carried_forward_from_profile_uuid IS NULL)
        OR
        (assessment_kind='carry_forward'
         AND supersedes_update_risk_profile_uuid IS NULL
         AND carried_forward_from_profile_uuid IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_update_risk_profile_authoritative_product
    ON maintenance.update_risk_profile(target_product_version_uuid)
    WHERE record_status='active'
      AND authority_status='authoritative'
      AND target_product_version_uuid IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_update_risk_profile_authoritative_investigation
    ON maintenance.update_risk_profile(target_investigation_version_uuid)
    WHERE record_status='active'
      AND authority_status='authoritative'
      AND target_investigation_version_uuid IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_update_risk_profile_product
    ON maintenance.update_risk_profile(target_product_version_uuid,record_status);

CREATE INDEX IF NOT EXISTS ix_update_risk_profile_investigation
    ON maintenance.update_risk_profile(target_investigation_version_uuid,record_status);

CREATE OR REPLACE FUNCTION maintenance.assert_update_risk_profile_header()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    prior maintenance.update_risk_profile%ROWTYPE;
    src maintenance.update_risk_profile%ROWTYPE;
    source_entity uuid;
    target_entity uuid;
BEGIN
    IF NOT maintenance.assert_verification_metadata(
        NEW.verification_status,NEW.verified_by,
        NEW.verifier_actor_type,NEW.verified_at
    ) THEN
        RAISE EXCEPTION 'UpdateRiskProfile verification metadata mismatch';
    END IF;

    IF NEW.authority_status='authoritative' THEN
        IF NEW.actor_type NOT IN ('human_reviewer','human_expert') THEN
            RAISE EXCEPTION 'Authoritative UpdateRiskProfile header requires reviewer/expert';
        END IF;
        IF NEW.verification_status NOT IN ('human_verified','human_consensus') THEN
            RAISE EXCEPTION 'Authoritative UpdateRiskProfile header requires human verification';
        END IF;
        IF NEW.recommended_maintenance_level IS NULL
           OR NEW.recommended_cadence_mode IS NULL
           OR NEW.event_driven_surveillance_required IS NULL
           OR NEW.feasibility_status IS NULL
           OR NEW.priority_implications_payload IS NULL THEN
            RAISE EXCEPTION 'Authoritative UpdateRiskProfile requires complete outputs';
        END IF;
    END IF;

    IF NEW.recommended_maintenance_level IS NOT NULL
       AND NEW.recommended_cadence_mode IS NOT NULL
       AND NOT maintenance.risk_profile_cadence_is_valid(
            NEW.recommended_maintenance_level,NEW.recommended_cadence_mode
       ) THEN
        RAISE EXCEPTION 'UpdateRiskProfile maintenance/cadence mismatch';
    END IF;

    IF NEW.assessment_kind='reassessment' THEN
        SELECT * INTO prior FROM maintenance.update_risk_profile
         WHERE update_risk_profile_uuid=NEW.supersedes_update_risk_profile_uuid;
        IF NOT FOUND THEN RAISE EXCEPTION 'Reassessment source profile missing'; END IF;
        IF prior.target_product_version_uuid IS DISTINCT FROM NEW.target_product_version_uuid
           OR prior.target_investigation_version_uuid IS DISTINCT FROM NEW.target_investigation_version_uuid THEN
            RAISE EXCEPTION 'Reassessment must preserve exact target version';
        END IF;
        IF NEW.assessed_at<prior.assessed_at OR NEW.effective_at<prior.effective_at THEN
            RAISE EXCEPTION 'Reassessment violates temporal order';
        END IF;
    ELSIF NEW.assessment_kind='carry_forward' THEN
        SELECT * INTO src FROM maintenance.update_risk_profile
         WHERE update_risk_profile_uuid=NEW.carried_forward_from_profile_uuid;
        IF NOT FOUND OR src.authority_status<>'authoritative' THEN
            RAISE EXCEPTION 'Carry-forward requires authoritative source profile';
        END IF;
        IF NEW.effective_at<src.effective_at THEN
            RAISE EXCEPTION 'Carry-forward effective_at cannot precede source profile';
        END IF;
        IF src.target_product_version_uuid IS NOT NULL THEN
            IF NEW.target_product_version_uuid IS NULL
               OR NEW.target_product_version_uuid=src.target_product_version_uuid THEN
                RAISE EXCEPTION 'Product carry-forward requires a different ProductVersion';
            END IF;
            SELECT entity_uuid INTO source_entity FROM product.product_version
             WHERE version_uuid=src.target_product_version_uuid;
            SELECT entity_uuid INTO target_entity FROM product.product_version
             WHERE version_uuid=NEW.target_product_version_uuid;
        ELSE
            IF NEW.target_investigation_version_uuid IS NULL
               OR NEW.target_investigation_version_uuid=src.target_investigation_version_uuid THEN
                RAISE EXCEPTION 'Investigation carry-forward requires a different InvestigationVersion';
            END IF;
            SELECT entity_uuid INTO source_entity FROM investigation.investigation_version
             WHERE version_uuid=src.target_investigation_version_uuid;
            SELECT entity_uuid INTO target_entity FROM investigation.investigation_version
             WHERE version_uuid=NEW.target_investigation_version_uuid;
        END IF;
        IF source_entity IS NULL OR target_entity IS NULL OR source_entity<>target_entity THEN
            RAISE EXCEPTION 'Carry-forward requires same underlying scientific entity';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_risk_profile_header
    ON maintenance.update_risk_profile;
CREATE TRIGGER tr_update_risk_profile_header
BEFORE INSERT ON maintenance.update_risk_profile
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_risk_profile_header();

CREATE OR REPLACE FUNCTION maintenance.guard_update_risk_profile_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'UpdateRiskProfile is append-preserving and cannot be deleted';
    END IF;
    IF OLD.record_status='active' AND NEW.record_status='superseded'
       AND to_jsonb(NEW)-'record_status'-'recorded_at'
           = to_jsonb(OLD)-'record_status'-'recorded_at'
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'UpdateRiskProfile material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_update_risk_profile_guard
    ON maintenance.update_risk_profile;
CREATE TRIGGER tr_update_risk_profile_guard
BEFORE UPDATE OR DELETE ON maintenance.update_risk_profile
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_update_risk_profile_mutation();

-- ---------------------------------------------------------------------------
-- DIMENSIONS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_risk_profile_dimension (
    update_risk_profile_uuid uuid NOT NULL
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
    dimension_code text NOT NULL CHECK (
        dimension_code IN ('A1','A2','A3','A4','A5','B1','B2','B3','B4','B5')
    ),
    value_code text NOT NULL,
    assessment_mode text NOT NULL CHECK (
        assessment_mode IN ('assessed','carried_forward')
    ),
    source_profile_uuid uuid
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    assessed_by text NOT NULL CHECK (length(btrim(assessed_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('system','ai_system','human_reviewer','human_expert','owner')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN ('unverified','ai_verified','human_verified','human_consensus')
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    authority_status text NOT NULL CHECK (
        authority_status IN ('proposal','authoritative')
    ),
    assessed_at timestamptz NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(update_risk_profile_uuid,dimension_code),
    CHECK (
        (assessment_mode='assessed' AND source_profile_uuid IS NULL)
        OR
        (assessment_mode='carried_forward' AND source_profile_uuid IS NOT NULL)
    )
);

CREATE OR REPLACE FUNCTION maintenance.assert_risk_profile_dimension()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    p maintenance.update_risk_profile%ROWTYPE;
    src maintenance.update_risk_profile%ROWTYPE;
    source_value text;
BEGIN
    SELECT * INTO p FROM maintenance.update_risk_profile
     WHERE update_risk_profile_uuid=NEW.update_risk_profile_uuid;
    IF NOT FOUND THEN RAISE EXCEPTION 'Risk-profile dimension requires profile'; END IF;

    IF NOT maintenance.risk_profile_dimension_value_is_valid(
        NEW.dimension_code,NEW.value_code
    ) THEN RAISE EXCEPTION 'Risk-profile dimension/value mismatch'; END IF;

    IF NEW.dimension_code='B5'
       AND NEW.authority_status='authoritative' THEN
        IF NEW.actor_type<>'owner' THEN
            RAISE EXCEPTION 'Authoritative B5 requires owner';
        END IF;
        IF NEW.verification_status<>'unverified'
           AND NEW.verification_status NOT IN ('human_verified','human_consensus') THEN
            RAISE EXCEPTION 'Authoritative B5 verification status invalid';
        END IF;
        IF NEW.verification_status IN ('human_verified','human_consensus')
           AND NOT maintenance.assert_verification_metadata(
                NEW.verification_status,NEW.verified_by,
                NEW.verifier_actor_type,NEW.verified_at
           ) THEN
            RAISE EXCEPTION 'B5 verification metadata mismatch';
        END IF;
        IF NEW.verification_status='unverified'
           AND (NEW.verified_by IS NOT NULL OR NEW.verifier_actor_type IS NOT NULL
                OR NEW.verified_at IS NOT NULL) THEN
            RAISE EXCEPTION 'Unverified B5 cannot carry verifier metadata';
        END IF;
    ELSE
        IF NOT maintenance.assert_verification_metadata(
            NEW.verification_status,NEW.verified_by,
            NEW.verifier_actor_type,NEW.verified_at
        ) THEN
            RAISE EXCEPTION 'Risk-profile dimension verification metadata mismatch';
        END IF;
    END IF;

    IF NEW.authority_status='authoritative' THEN
        IF NEW.actor_type IN ('system','ai_system') THEN
            RAISE EXCEPTION 'System/AI cannot create authoritative risk-profile dimension';
        END IF;
        IF NEW.dimension_code IN ('A2','A3','A4')
           AND NEW.actor_type NOT IN ('human_reviewer','human_expert') THEN
            RAISE EXCEPTION 'A2/A3/A4 authoritative dimensions require reviewer/expert';
        END IF;
        IF NEW.dimension_code<>'B5'
           AND NEW.verification_status NOT IN ('human_verified','human_consensus') THEN
            RAISE EXCEPTION 'Authoritative non-B5 dimension requires human verification';
        END IF;
    END IF;

    IF NEW.assessment_mode='carried_forward' THEN
        SELECT * INTO src FROM maintenance.update_risk_profile
         WHERE update_risk_profile_uuid=NEW.source_profile_uuid;
        IF NOT FOUND OR src.authority_status<>'authoritative' THEN
            RAISE EXCEPTION 'Carried dimension requires authoritative source profile';
        END IF;
        IF p.assessment_kind='reassessment'
           AND NEW.source_profile_uuid<>p.supersedes_update_risk_profile_uuid THEN
            RAISE EXCEPTION 'Reassessment carried dimension must use superseded profile';
        END IF;
        IF p.assessment_kind='carry_forward'
           AND NEW.source_profile_uuid<>p.carried_forward_from_profile_uuid THEN
            RAISE EXCEPTION 'Carry-forward dimension must use header source profile';
        END IF;
        SELECT value_code INTO source_value
          FROM maintenance.update_risk_profile_dimension
         WHERE update_risk_profile_uuid=NEW.source_profile_uuid
           AND dimension_code=NEW.dimension_code
           AND authority_status='authoritative';
        IF source_value IS NULL OR source_value<>NEW.value_code THEN
            RAISE EXCEPTION 'Carried dimension value must equal authoritative source value';
        END IF;
    ELSIF p.assessment_kind='initial' AND NEW.assessment_mode<>'assessed' THEN
        RAISE EXCEPTION 'Initial profile dimensions must be assessed';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_risk_profile_dimension
    ON maintenance.update_risk_profile_dimension;
CREATE TRIGGER tr_risk_profile_dimension
BEFORE INSERT ON maintenance.update_risk_profile_dimension
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_risk_profile_dimension();

CREATE OR REPLACE FUNCTION maintenance.guard_risk_profile_dimension_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    RAISE EXCEPTION 'UpdateRiskProfileDimension is immutable; supersede profile instead';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_risk_profile_dimension_immutable
    ON maintenance.update_risk_profile_dimension;
CREATE TRIGGER tr_risk_profile_dimension_immutable
BEFORE UPDATE OR DELETE ON maintenance.update_risk_profile_dimension
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_risk_profile_dimension_mutation();

-- ---------------------------------------------------------------------------
-- DIMENSION BASIS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_risk_profile_dimension_basis (
    update_risk_profile_uuid uuid NOT NULL,
    dimension_code text NOT NULL,
    source_type text NOT NULL CHECK (
        source_type IN (
            'monitor_cycle','candidate_assessment','update_signal',
            'alert_product_version','entity_version','artifact','external_reference'
        )
    ),
    monitor_cycle_uuid uuid REFERENCES maintenance.monitor_cycle(cycle_uuid),
    candidate_assessment_uuid uuid
        REFERENCES maintenance.candidate_assessment(candidate_assessment_uuid),
    update_signal_uuid uuid REFERENCES maintenance.update_signal(update_signal_uuid),
    alert_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    source_entity_version_uuid uuid REFERENCES core.entity_version(version_uuid),
    source_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    external_reference_payload jsonb,
    observation_payload jsonb,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    sequence_no integer NOT NULL CHECK (sequence_no>0),
    PRIMARY KEY(update_risk_profile_uuid,dimension_code,sequence_no),
    FOREIGN KEY(update_risk_profile_uuid,dimension_code)
        REFERENCES maintenance.update_risk_profile_dimension(
            update_risk_profile_uuid,dimension_code
        ),
    CHECK (
        num_nonnulls(
            monitor_cycle_uuid,candidate_assessment_uuid,update_signal_uuid,
            alert_product_version_uuid,source_entity_version_uuid,
            source_artifact_uuid,external_reference_payload
        )=1
    )
);

CREATE OR REPLACE FUNCTION maintenance.assert_risk_profile_dimension_basis()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE pt text;
BEGIN
    IF (NEW.source_type='monitor_cycle') IS DISTINCT FROM (NEW.monitor_cycle_uuid IS NOT NULL)
       OR (NEW.source_type='candidate_assessment') IS DISTINCT FROM (NEW.candidate_assessment_uuid IS NOT NULL)
       OR (NEW.source_type='update_signal') IS DISTINCT FROM (NEW.update_signal_uuid IS NOT NULL)
       OR (NEW.source_type='alert_product_version') IS DISTINCT FROM (NEW.alert_product_version_uuid IS NOT NULL)
       OR (NEW.source_type='entity_version') IS DISTINCT FROM (NEW.source_entity_version_uuid IS NOT NULL)
       OR (NEW.source_type='artifact') IS DISTINCT FROM (NEW.source_artifact_uuid IS NOT NULL)
       OR (NEW.source_type='external_reference') IS DISTINCT FROM (NEW.external_reference_payload IS NOT NULL) THEN
        RAISE EXCEPTION 'Risk-profile dimension basis source_type/locator mismatch';
    END IF;
    IF NEW.source_type='alert_product_version' THEN
        SELECT product_type INTO pt FROM product.product_version
         WHERE version_uuid=NEW.alert_product_version_uuid;
        IF pt IS DISTINCT FROM 'evidence_alert' THEN
            RAISE EXCEPTION 'Risk-profile Alert basis must reference evidence_alert';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_risk_profile_dimension_basis
    ON maintenance.update_risk_profile_dimension_basis;
CREATE TRIGGER tr_risk_profile_dimension_basis
BEFORE INSERT ON maintenance.update_risk_profile_dimension_basis
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_risk_profile_dimension_basis();

CREATE OR REPLACE FUNCTION maintenance.guard_risk_profile_dimension_basis_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    RAISE EXCEPTION 'UpdateRiskProfileDimensionBasis is immutable';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_risk_profile_dimension_basis_immutable
    ON maintenance.update_risk_profile_dimension_basis;
CREATE TRIGGER tr_risk_profile_dimension_basis_immutable
BEFORE UPDATE OR DELETE ON maintenance.update_risk_profile_dimension_basis
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_risk_profile_dimension_basis_mutation();

-- ---------------------------------------------------------------------------
-- PROFILE TRIGGERS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_risk_profile_trigger (
    update_risk_profile_uuid uuid NOT NULL
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
    trigger_code text NOT NULL CHECK (
        trigger_code IN (
            'initial_baseline','new_scientific_version','use_context_change',
            'policy_regulatory_change','evidence_pipeline_change','certainty_change',
            'signal_frequency_change','capacity_change','source_observability_change',
            'maintenance_level_change','dependency_graph_change',
            'explicit_governance_request','other'
        )
    ),
    source_type text NOT NULL CHECK (
        source_type IN (
            'none','update_signal','alert_product_version','monitor_cycle',
            'entity_version','artifact','external_reference'
        )
    ),
    update_signal_uuid uuid REFERENCES maintenance.update_signal(update_signal_uuid),
    alert_product_version_uuid uuid REFERENCES product.product_version(version_uuid),
    monitor_cycle_uuid uuid REFERENCES maintenance.monitor_cycle(cycle_uuid),
    source_entity_version_uuid uuid REFERENCES core.entity_version(version_uuid),
    source_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    external_reference_payload jsonb,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    sequence_no integer NOT NULL CHECK (sequence_no>0),
    PRIMARY KEY(update_risk_profile_uuid,trigger_code,sequence_no),
    CHECK (
        (source_type='none' AND num_nonnulls(
            update_signal_uuid,alert_product_version_uuid,monitor_cycle_uuid,
            source_entity_version_uuid,source_artifact_uuid,
            external_reference_payload
        )=0)
        OR
        (source_type<>'none' AND num_nonnulls(
            update_signal_uuid,alert_product_version_uuid,monitor_cycle_uuid,
            source_entity_version_uuid,source_artifact_uuid,
            external_reference_payload
        )=1)
    )
);

CREATE OR REPLACE FUNCTION maintenance.assert_risk_profile_trigger()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE p maintenance.update_risk_profile%ROWTYPE; pt text;
BEGIN
    SELECT * INTO p FROM maintenance.update_risk_profile
     WHERE update_risk_profile_uuid=NEW.update_risk_profile_uuid;

    IF (NEW.source_type='update_signal') IS DISTINCT FROM (NEW.update_signal_uuid IS NOT NULL)
       OR (NEW.source_type='alert_product_version') IS DISTINCT FROM (NEW.alert_product_version_uuid IS NOT NULL)
       OR (NEW.source_type='monitor_cycle') IS DISTINCT FROM (NEW.monitor_cycle_uuid IS NOT NULL)
       OR (NEW.source_type='entity_version') IS DISTINCT FROM (NEW.source_entity_version_uuid IS NOT NULL)
       OR (NEW.source_type='artifact') IS DISTINCT FROM (NEW.source_artifact_uuid IS NOT NULL)
       OR (NEW.source_type='external_reference') IS DISTINCT FROM (NEW.external_reference_payload IS NOT NULL)
       OR (NEW.source_type='none') IS DISTINCT FROM (
            num_nonnulls(
                NEW.update_signal_uuid,NEW.alert_product_version_uuid,NEW.monitor_cycle_uuid,
                NEW.source_entity_version_uuid,NEW.source_artifact_uuid,
                NEW.external_reference_payload
            )=0
       ) THEN
        RAISE EXCEPTION 'Risk-profile trigger source_type/locator mismatch';
    END IF;

    IF NEW.source_type='alert_product_version' THEN
        SELECT product_type INTO pt FROM product.product_version
         WHERE version_uuid=NEW.alert_product_version_uuid;
        IF pt IS DISTINCT FROM 'evidence_alert' THEN
            RAISE EXCEPTION 'Risk-profile trigger Alert must reference evidence_alert';
        END IF;
    END IF;

    IF p.assessment_kind='initial' AND NEW.trigger_code<>'initial_baseline' THEN
        RAISE EXCEPTION 'Initial profile requires initial_baseline trigger';
    END IF;
    IF p.assessment_kind='reassessment' AND NEW.trigger_code='initial_baseline' THEN
        RAISE EXCEPTION 'Reassessment cannot use initial_baseline trigger';
    END IF;
    IF p.assessment_kind='carry_forward' AND NEW.trigger_code<>'new_scientific_version' THEN
        RAISE EXCEPTION 'Carry-forward requires new_scientific_version trigger';
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_risk_profile_trigger
    ON maintenance.update_risk_profile_trigger;
CREATE TRIGGER tr_risk_profile_trigger
BEFORE INSERT ON maintenance.update_risk_profile_trigger
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_risk_profile_trigger();

CREATE OR REPLACE FUNCTION maintenance.guard_risk_profile_trigger_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    RAISE EXCEPTION 'UpdateRiskProfileTrigger is immutable';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_risk_profile_trigger_immutable
    ON maintenance.update_risk_profile_trigger;
CREATE TRIGGER tr_risk_profile_trigger_immutable
BEFORE UPDATE OR DELETE ON maintenance.update_risk_profile_trigger
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_risk_profile_trigger_mutation();

-- ---------------------------------------------------------------------------
-- POLICY BASIS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_policy_risk_profile_basis (
    update_policy_risk_profile_basis_uuid uuid PRIMARY KEY,
    update_policy_uuid uuid NOT NULL
        REFERENCES maintenance.update_policy(update_policy_uuid),
    update_risk_profile_uuid uuid NOT NULL
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid),
    basis_role text NOT NULL CHECK (basis_role IN ('governing','supporting')),
    linked_at timestamptz NOT NULL,
    linked_by text NOT NULL CHECK (length(btrim(linked_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('human_reviewer','human_expert','owner')
    ),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    record_status text NOT NULL DEFAULT 'active'
        CHECK (record_status IN ('active','superseded')),
    supersedes_update_policy_risk_profile_basis_uuid uuid
        REFERENCES maintenance.update_policy_risk_profile_basis(
            update_policy_risk_profile_basis_uuid
        ),
    CHECK (
        supersedes_update_policy_risk_profile_basis_uuid IS NULL
        OR supersedes_update_policy_risk_profile_basis_uuid
             <>update_policy_risk_profile_basis_uuid
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_policy_risk_profile_governing_active
    ON maintenance.update_policy_risk_profile_basis(update_policy_uuid)
    WHERE record_status='active' AND basis_role='governing';

CREATE OR REPLACE FUNCTION maintenance.assert_policy_risk_profile_basis()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE p maintenance.update_policy%ROWTYPE; rp maintenance.update_risk_profile%ROWTYPE;
    prior maintenance.update_policy_risk_profile_basis%ROWTYPE;
BEGIN
    SELECT * INTO p FROM maintenance.update_policy WHERE update_policy_uuid=NEW.update_policy_uuid;
    SELECT * INTO rp FROM maintenance.update_risk_profile WHERE update_risk_profile_uuid=NEW.update_risk_profile_uuid;
    IF NOT FOUND THEN RAISE EXCEPTION 'Risk profile basis requires profile'; END IF;

    IF rp.target_product_version_uuid IS DISTINCT FROM p.target_product_version_uuid
       OR rp.target_investigation_version_uuid IS DISTINCT FROM p.target_investigation_version_uuid THEN
        RAISE EXCEPTION 'Policy/profile target mismatch';
    END IF;

    IF NEW.basis_role='governing' THEN
        IF rp.authority_status<>'authoritative' OR rp.record_status<>'active' THEN
            RAISE EXCEPTION 'Governing risk profile must be authoritative and active';
        END IF;
        IF rp.effective_at>p.effective_at THEN
            RAISE EXCEPTION 'Later profile cannot become retroactive governing basis';
        END IF;
    END IF;

    IF NEW.supersedes_update_policy_risk_profile_basis_uuid IS NOT NULL THEN
        SELECT * INTO prior FROM maintenance.update_policy_risk_profile_basis
         WHERE update_policy_risk_profile_basis_uuid=
             NEW.supersedes_update_policy_risk_profile_basis_uuid;
        IF NOT FOUND OR prior.update_policy_uuid<>NEW.update_policy_uuid THEN
            RAISE EXCEPTION 'Policy risk-profile basis supersession must preserve policy';
        END IF;
        IF NEW.linked_at<prior.linked_at THEN
            RAISE EXCEPTION 'Policy risk-profile basis supersession violates temporal order';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_policy_risk_profile_basis
    ON maintenance.update_policy_risk_profile_basis;
CREATE TRIGGER tr_policy_risk_profile_basis
BEFORE INSERT ON maintenance.update_policy_risk_profile_basis
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_policy_risk_profile_basis();

CREATE OR REPLACE FUNCTION maintenance.guard_policy_risk_profile_basis_mutation()
RETURNS trigger LANGUAGE plpgsql AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'UpdatePolicyRiskProfileBasis cannot be deleted';
    END IF;
    IF OLD.record_status='active' AND NEW.record_status='superseded'
       AND to_jsonb(NEW)-'record_status'=to_jsonb(OLD)-'record_status'
    THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'Policy risk-profile basis material fields are immutable';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_policy_risk_profile_basis_guard
    ON maintenance.update_policy_risk_profile_basis;
CREATE TRIGGER tr_policy_risk_profile_basis_guard
BEFORE UPDATE OR DELETE ON maintenance.update_policy_risk_profile_basis
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_policy_risk_profile_basis_mutation();

-- ---------------------------------------------------------------------------
-- COMMIT-TIME COMPLETENESS / DOMINANCE GUARD
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.assert_authoritative_risk_profile_complete()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    p maintenance.update_risk_profile%ROWTYPE;
    n integer;
    b5 text;
    a1 text;
    a4 text;
BEGIN
    SELECT * INTO p FROM maintenance.update_risk_profile
     WHERE update_risk_profile_uuid=NEW.update_risk_profile_uuid;
    IF NOT FOUND OR p.authority_status<>'authoritative' OR p.record_status<>'active' THEN
        RETURN NULL;
    END IF;

    SELECT count(*) INTO n
      FROM maintenance.update_risk_profile_dimension d
     WHERE d.update_risk_profile_uuid=p.update_risk_profile_uuid
       AND d.authority_status='authoritative';
    IF n<>10 THEN
        RAISE EXCEPTION 'Authoritative UpdateRiskProfile requires exactly ten authoritative dimensions';
    END IF;

    SELECT value_code INTO a1 FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p.update_risk_profile_uuid AND dimension_code='A1';
    SELECT value_code INTO a4 FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p.update_risk_profile_uuid AND dimension_code='A4';
    SELECT value_code INTO b5 FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p.update_risk_profile_uuid AND dimension_code='B5';

    IF a4='high' AND p.event_driven_surveillance_required IS DISTINCT FROM true THEN
        RAISE EXCEPTION 'A4 high requires event-driven surveillance';
    END IF;
    IF (a1='high' OR a4='high') AND p.recommended_maintenance_level='M0' THEN
        RAISE EXCEPTION 'A1/A4 high cannot recommend M0';
    END IF;
    IF NOT maintenance.feasibility_respects_b5(b5,p.feasibility_status) THEN
        RAISE EXCEPTION 'Profile feasibility exceeds B5 ceiling';
    END IF;
    IF p.recommended_maintenance_level='M3'
       AND (b5<>'adequate' OR p.feasibility_status<>'adequate'
            OR p.recommended_cadence_mode NOT IN ('continuous','hybrid')) THEN
        RAISE EXCEPTION 'M3 recommendation requires adequate capacity/feasibility and continuous/hybrid cadence';
    END IF;

    IF p.assessment_kind='initial' AND NOT EXISTS (
        SELECT 1 FROM maintenance.update_risk_profile_trigger t
        WHERE t.update_risk_profile_uuid=p.update_risk_profile_uuid
          AND t.trigger_code='initial_baseline'
    ) THEN RAISE EXCEPTION 'Initial authoritative profile requires initial_baseline trigger'; END IF;

    IF p.assessment_kind='reassessment' AND NOT EXISTS (
        SELECT 1 FROM maintenance.update_risk_profile_trigger t
        WHERE t.update_risk_profile_uuid=p.update_risk_profile_uuid
          AND t.trigger_code<>'initial_baseline'
    ) THEN RAISE EXCEPTION 'Authoritative reassessment requires reassessment trigger'; END IF;

    IF p.assessment_kind='carry_forward' AND NOT EXISTS (
        SELECT 1 FROM maintenance.update_risk_profile_trigger t
        WHERE t.update_risk_profile_uuid=p.update_risk_profile_uuid
          AND t.trigger_code='new_scientific_version'
    ) THEN RAISE EXCEPTION 'Authoritative carry-forward requires new_scientific_version trigger'; END IF;

    RETURN NULL;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_risk_profile_complete_from_header
    ON maintenance.update_risk_profile;
CREATE CONSTRAINT TRIGGER tr_risk_profile_complete_from_header
AFTER INSERT OR UPDATE ON maintenance.update_risk_profile
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_authoritative_risk_profile_complete();

DROP TRIGGER IF EXISTS tr_risk_profile_complete_from_dimension
    ON maintenance.update_risk_profile_dimension;
CREATE CONSTRAINT TRIGGER tr_risk_profile_complete_from_dimension
AFTER INSERT ON maintenance.update_risk_profile_dimension
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_authoritative_risk_profile_complete();

DROP TRIGGER IF EXISTS tr_risk_profile_complete_from_trigger
    ON maintenance.update_risk_profile_trigger;
CREATE CONSTRAINT TRIGGER tr_risk_profile_complete_from_trigger
AFTER INSERT ON maintenance.update_risk_profile_trigger
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_authoritative_risk_profile_complete();

-- ---------------------------------------------------------------------------
-- SERIALIZER
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.update_risk_profile_snapshot(p uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    rp maintenance.update_risk_profile%ROWTYPE;
    n integer;
    result jsonb;
BEGIN
    SELECT * INTO rp FROM maintenance.update_risk_profile
     WHERE update_risk_profile_uuid=p;
    IF NOT FOUND THEN RAISE EXCEPTION 'UpdateRiskProfile missing'; END IF;

    SELECT count(*) INTO n
      FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p;
    IF n<>10 THEN
        RAISE EXCEPTION 'Incomplete UpdateRiskProfile is not serializer-eligible';
    END IF;

    SELECT jsonb_build_object(
        'schema_version','oes.update_risk_profile/0.1',
        'assessed_at',to_char(rp.assessed_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS"Z"'),
        'A1',max(value_code) FILTER (WHERE dimension_code='A1'),
        'A2',max(value_code) FILTER (WHERE dimension_code='A2'),
        'A3',max(value_code) FILTER (WHERE dimension_code='A3'),
        'A4',max(value_code) FILTER (WHERE dimension_code='A4'),
        'A5',max(value_code) FILTER (WHERE dimension_code='A5'),
        'B1',max(value_code) FILTER (WHERE dimension_code='B1'),
        'B2',max(value_code) FILTER (WHERE dimension_code='B2'),
        'B3',max(value_code) FILTER (WHERE dimension_code='B3'),
        'B4',max(value_code) FILTER (WHERE dimension_code='B4'),
        'B5',max(value_code) FILTER (WHERE dimension_code='B5'),
        'rationale',rp.rationale,
        'update_risk_profile_uuid',rp.update_risk_profile_uuid::text,
        'effective_at',to_char(rp.effective_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS"Z"'),
        'recommended_maintenance_level',rp.recommended_maintenance_level,
        'recommended_cadence_mode',rp.recommended_cadence_mode,
        'feasibility_status',rp.feasibility_status
    ) INTO result
    FROM maintenance.update_risk_profile_dimension
    WHERE update_risk_profile_uuid=p;

    IF NOT maintenance.risk_profile_snapshot_is_valid(result) THEN
        RAISE EXCEPTION 'Serialized UpdateRiskProfile does not satisfy canonical snapshot validator';
    END IF;
    RETURN result;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- PRIORITY ASSESSMENT ADOPTION
-- ---------------------------------------------------------------------------

ALTER TABLE maintenance.priority_assessment
    ADD COLUMN IF NOT EXISTS update_risk_profile_uuid uuid;

DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname='fk_priority_assessment_risk_profile'
           AND conrelid='maintenance.priority_assessment'::regclass
    ) THEN
        ALTER TABLE maintenance.priority_assessment
        ADD CONSTRAINT fk_priority_assessment_risk_profile
        FOREIGN KEY(update_risk_profile_uuid)
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid);
    END IF;
END;
$do$;

CREATE OR REPLACE FUNCTION maintenance.assert_priority_assessment_risk_profile()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    rp maintenance.update_risk_profile%ROWTYPE;
    pol maintenance.update_policy%ROWTYPE;
    expected jsonb;
BEGIN
    IF NEW.update_risk_profile_uuid IS NULL THEN
        RAISE EXCEPTION 'New PriorityAssessment requires physical UpdateRiskProfile';
    END IF;
    SELECT * INTO rp FROM maintenance.update_risk_profile
     WHERE update_risk_profile_uuid=NEW.update_risk_profile_uuid;
    SELECT * INTO pol FROM maintenance.update_policy
     WHERE update_policy_uuid=NEW.update_policy_uuid;

    IF rp.target_product_version_uuid IS DISTINCT FROM pol.target_product_version_uuid
       OR rp.target_investigation_version_uuid IS DISTINCT FROM pol.target_investigation_version_uuid THEN
        RAISE EXCEPTION 'PriorityAssessment risk profile target must match UpdatePolicy';
    END IF;

    IF NEW.authority_status='authoritative'
       AND NEW.authority_scope IN ('scientific','mixed')
       AND rp.authority_status<>'authoritative' THEN
        RAISE EXCEPTION 'Authoritative scientific/mixed priority requires authoritative UpdateRiskProfile';
    END IF;

    expected:=maintenance.update_risk_profile_snapshot(NEW.update_risk_profile_uuid);
    IF NEW.risk_profile_snapshot<>expected THEN
        RAISE EXCEPTION 'PriorityAssessment risk_profile_snapshot must equal canonical profile serializer';
    END IF;
    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_priority_assessment_risk_profile_adoption
    ON maintenance.priority_assessment;
CREATE TRIGGER tr_priority_assessment_risk_profile_adoption
BEFORE INSERT ON maintenance.priority_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_priority_assessment_risk_profile();

-- ---------------------------------------------------------------------------
-- PRIORITY BASIS EXTENSION
-- ---------------------------------------------------------------------------

ALTER TABLE maintenance.priority_basis
    ADD COLUMN IF NOT EXISTS update_risk_profile_uuid uuid;

DO $do$
DECLARE c record;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname='fk_priority_basis_risk_profile'
           AND conrelid='maintenance.priority_basis'::regclass
    ) THEN
        ALTER TABLE maintenance.priority_basis
        ADD CONSTRAINT fk_priority_basis_risk_profile
        FOREIGN KEY(update_risk_profile_uuid)
        REFERENCES maintenance.update_risk_profile(update_risk_profile_uuid);
    END IF;

    FOR c IN
        SELECT conname
          FROM pg_constraint
         WHERE conrelid='maintenance.priority_basis'::regclass
           AND contype='c'
           AND pg_get_constraintdef(oid) ILIKE '%source_type%'
    LOOP
        EXECUTE format(
            'ALTER TABLE maintenance.priority_basis DROP CONSTRAINT %I',c.conname
        );
    END LOOP;
END;
$do$;

ALTER TABLE maintenance.priority_basis
ADD CONSTRAINT priority_basis_source_type_check CHECK (
    source_type IN (
        'snapshot','risk_profile','triage','materiality_assessment','update_decision',
        'currency_state','alert_product_version','sla_instance',
        'escalation_case','entity_version','artifact'
    )
);

ALTER TABLE maintenance.priority_basis
ADD CONSTRAINT priority_basis_source_locator_check CHECK (
    (
        source_type='snapshot'
        AND num_nonnulls(
            update_risk_profile_uuid,update_triage_uuid,materiality_assessment_uuid,
            update_decision_uuid,currency_state_uuid,alert_product_version_uuid,
            sla_instance_uuid,escalation_case_uuid,source_entity_version_uuid,
            source_artifact_uuid
        )=0
        AND snapshot_payload IS NOT NULL
    )
    OR
    (
        source_type<>'snapshot'
        AND num_nonnulls(
            update_risk_profile_uuid,update_triage_uuid,materiality_assessment_uuid,
            update_decision_uuid,currency_state_uuid,alert_product_version_uuid,
            sla_instance_uuid,escalation_case_uuid,source_entity_version_uuid,
            source_artifact_uuid
        )=1
        AND snapshot_payload IS NULL
    )
);

CREATE OR REPLACE FUNCTION maintenance.assert_priority_basis_consistency()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
    IF (NEW.source_type='risk_profile') IS DISTINCT FROM (NEW.update_risk_profile_uuid IS NOT NULL)
       OR (NEW.source_type='triage') IS DISTINCT FROM (NEW.update_triage_uuid IS NOT NULL)
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

    IF NEW.source_type='risk_profile' AND NOT EXISTS (
        SELECT 1
          FROM maintenance.priority_assessment pa
          JOIN maintenance.update_risk_profile rp
            ON rp.update_risk_profile_uuid=NEW.update_risk_profile_uuid
         WHERE pa.priority_assessment_uuid=NEW.priority_assessment_uuid
           AND pa.update_risk_profile_uuid=rp.update_risk_profile_uuid
    ) THEN
        RAISE EXCEPTION 'PriorityBasis risk_profile must match PriorityAssessment profile';
    END IF;
    RETURN NEW;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- ISSUE HELPERS / READINESS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.update_risk_profile_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    rp maintenance.update_risk_profile%ROWTYPE;
    n integer;
    a1 text;
    a4 text;
    b5 text;
BEGIN
    SELECT * INTO rp FROM maintenance.update_risk_profile
     WHERE update_risk_profile_uuid=p;
    IF NOT FOUND THEN
        RETURN QUERY SELECT 'PROFILE_TARGET_MISSING','error','UpdateRiskProfile missing';
        RETURN;
    END IF;

    SELECT count(*) INTO n FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p;
    IF n<>10 THEN
        RETURN QUERY SELECT 'PROFILE_DIMENSION_MISSING','error',
            format('Expected 10 dimensions, found %s',n);
    END IF;

    SELECT value_code INTO a1 FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p AND dimension_code='A1';
    SELECT value_code INTO a4 FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p AND dimension_code='A4';
    SELECT value_code INTO b5 FROM maintenance.update_risk_profile_dimension
     WHERE update_risk_profile_uuid=p AND dimension_code='B5';

    IF rp.authority_status='authoritative' AND a4='high'
       AND rp.event_driven_surveillance_required IS DISTINCT FROM true THEN
        RETURN QUERY SELECT 'PROFILE_A4_EVENT_DRIVEN_REQUIRED','error','A4 high requires event-driven surveillance';
    END IF;

    IF rp.authority_status='authoritative'
       AND (a1='high' OR a4='high')
       AND rp.recommended_maintenance_level='M0' THEN
        RETURN QUERY SELECT 'PROFILE_HIGH_CRITICALITY_M0_FORBIDDEN','error','A1/A4 high cannot recommend M0';
    END IF;

    IF rp.authority_status='authoritative'
       AND b5 IS NOT NULL
       AND NOT maintenance.feasibility_respects_b5(b5,rp.feasibility_status) THEN
        RETURN QUERY SELECT 'PROFILE_FEASIBILITY_EXCEEDS_B5','error','Feasibility exceeds B5 ceiling';
    END IF;

    IF rp.authority_status='authoritative'
       AND rp.recommended_maintenance_level='M3'
       AND (b5 IS DISTINCT FROM 'adequate'
            OR rp.feasibility_status IS DISTINCT FROM 'adequate') THEN
        RETURN QUERY SELECT 'PROFILE_M3_CAPACITY_BLOCKED','error','M3 recommendation lacks adequate capacity/feasibility';
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.update_policy_risk_profile_basis_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE sql
STABLE
AS $q$
SELECT 'PROFILE_POLICY_TARGET_MISMATCH','error','Governing profile target differs from policy'
WHERE EXISTS (
    SELECT 1
      FROM maintenance.update_policy_risk_profile_basis b
      JOIN maintenance.update_policy pol USING(update_policy_uuid)
      JOIN maintenance.update_risk_profile rp USING(update_risk_profile_uuid)
     WHERE b.update_policy_uuid=p
       AND b.record_status='active'
       AND b.basis_role='governing'
       AND (
            rp.target_product_version_uuid IS DISTINCT FROM pol.target_product_version_uuid
            OR rp.target_investigation_version_uuid IS DISTINCT FROM pol.target_investigation_version_uuid
       )
);
$q$;

CREATE OR REPLACE FUNCTION maintenance.current_authoritative_risk_profile(
    p_product_version_uuid uuid DEFAULT NULL,
    p_investigation_version_uuid uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE sql
STABLE
AS $q$
SELECT update_risk_profile_uuid
  FROM maintenance.update_risk_profile
 WHERE record_status='active'
   AND authority_status='authoritative'
   AND target_product_version_uuid IS NOT DISTINCT FROM p_product_version_uuid
   AND target_investigation_version_uuid IS NOT DISTINCT FROM p_investigation_version_uuid
 LIMIT 1;
$q$;

-- Preserve M3 blocker explicitly in integrated readiness.
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
