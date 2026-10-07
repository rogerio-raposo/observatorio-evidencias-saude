-- OES-DBM-2026-0027
-- Fase 4 — Transversal Update Protocol contract v0.1
-- Depends on: migrations 002–026
-- Date: 2026-10-07
-- Scope: additive maintenance policy/signal/materiality/decision persistence.
-- No thresholds, SLA durations, automation, propagation or M3 formal unblock.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

-- ---------------------------------------------------------------------------
-- UPDATE POLICY
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_policy (
    update_policy_uuid uuid PRIMARY KEY,
    target_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),
    target_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    effective_maintenance_level text NOT NULL CHECK (
        effective_maintenance_level IN ('M0','M1','M2','M3')
    ),
    cadence_mode text NOT NULL CHECK (
        cadence_mode IN ('none','event_driven','periodic','hybrid','continuous')
    ),
    cadence_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    trigger_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    materiality_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    escalation_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    governance_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    governing_monitor_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),
    effective_at timestamptz NOT NULL,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    created_by text NOT NULL CHECK (length(btrim(created_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('human_reviewer','human_expert','owner')
    ),
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_update_policy_uuid uuid
        REFERENCES maintenance.update_policy(update_policy_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        num_nonnulls(
            target_product_version_uuid,
            target_investigation_version_uuid
        )=1
    ),
    CHECK (jsonb_typeof(cadence_policy_payload)='object'),
    CHECK (jsonb_typeof(trigger_policy_payload)='object'),
    CHECK (jsonb_typeof(materiality_policy_payload)='object'),
    CHECK (jsonb_typeof(escalation_policy_payload)='object'),
    CHECK (jsonb_typeof(governance_policy_payload)='object'),
    CHECK (
        supersedes_update_policy_uuid IS NULL
        OR supersedes_update_policy_uuid<>update_policy_uuid
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_update_policy_active_product
    ON maintenance.update_policy(target_product_version_uuid)
    WHERE record_status='active'
      AND target_product_version_uuid IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_update_policy_active_investigation
    ON maintenance.update_policy(target_investigation_version_uuid)
    WHERE record_status='active'
      AND target_investigation_version_uuid IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_update_policy_monitor
    ON maintenance.update_policy(governing_monitor_product_version_uuid);

CREATE OR REPLACE FUNCTION maintenance.assert_update_policy_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    target_ev_status text;
    target_product_type text;
    target_product_status text;
    target_investigation_type text;
    monitor_product_type text;
    monitor_ev_status text;
    mt maintenance.monitor_target%ROWTYPE;
    prior maintenance.update_policy%ROWTYPE;
    transition_ok boolean;
BEGIN
    IF NEW.target_product_version_uuid IS NOT NULL THEN
        SELECT ev.version_status,pv.product_type,pv.status
          INTO target_ev_status,target_product_type,target_product_status
          FROM product.product_version pv
          JOIN core.entity_version ev ON ev.version_uuid=pv.version_uuid
         WHERE pv.version_uuid=NEW.target_product_version_uuid;

        IF target_ev_status IS NULL OR target_ev_status<>'current' THEN
            RAISE EXCEPTION 'UpdatePolicy ProductVersion target must be current';
        END IF;
        IF target_product_type IN ('evidence_monitor','evidence_alert') THEN
            RAISE EXCEPTION 'UpdatePolicy target cannot be evidence_monitor/evidence_alert';
        END IF;
        IF target_product_status IN ('superseded','archived') THEN
            RAISE EXCEPTION 'UpdatePolicy ProductVersion target cannot be editorially superseded/archived';
        END IF;
    ELSE
        SELECT ev.version_status,iv.investigation_type
          INTO target_ev_status,target_investigation_type
          FROM investigation.investigation_version iv
          JOIN core.entity_version ev ON ev.version_uuid=iv.version_uuid
         WHERE iv.version_uuid=NEW.target_investigation_version_uuid;

        IF target_ev_status IS NULL OR target_ev_status<>'current' THEN
            RAISE EXCEPTION 'UpdatePolicy InvestigationVersion target must be current';
        END IF;
        IF target_investigation_type='evidence_monitoring' THEN
            RAISE EXCEPTION 'UpdatePolicy target cannot be evidence_monitoring InvestigationVersion';
        END IF;
    END IF;

    IF NOT (
        (NEW.effective_maintenance_level='M0' AND NEW.cadence_mode='none')
        OR
        (NEW.effective_maintenance_level='M1'
         AND NEW.cadence_mode IN ('event_driven','periodic','hybrid'))
        OR
        (NEW.effective_maintenance_level='M2'
         AND NEW.cadence_mode IN ('periodic','hybrid'))
        OR
        (NEW.effective_maintenance_level='M3'
         AND NEW.cadence_mode IN ('continuous','hybrid'))
    ) THEN
        RAISE EXCEPTION 'UpdatePolicy maintenance level/cadence mode mismatch';
    END IF;

    IF NEW.effective_maintenance_level IN ('M0','M1') THEN
        IF NEW.governing_monitor_product_version_uuid IS NOT NULL THEN
            RAISE EXCEPTION 'M0/M1 UpdatePolicy cannot have governing Monitor';
        END IF;
    ELSE
        IF NEW.governing_monitor_product_version_uuid IS NULL THEN
            RAISE EXCEPTION 'M2/M3 UpdatePolicy requires governing Monitor';
        END IF;

        SELECT pv.product_type,ev.version_status
          INTO monitor_product_type,monitor_ev_status
          FROM product.product_version pv
          JOIN core.entity_version ev ON ev.version_uuid=pv.version_uuid
         WHERE pv.version_uuid=NEW.governing_monitor_product_version_uuid;

        IF monitor_product_type IS DISTINCT FROM 'evidence_monitor'
           OR monitor_ev_status IN ('invalidated','archived')
           OR monitor_ev_status IS NULL THEN
            RAISE EXCEPTION 'Governing Monitor must be a valid evidence_monitor ProductVersion';
        END IF;

        SELECT * INTO mt
          FROM maintenance.monitor_target x
         WHERE x.monitor_product_version_uuid=
               NEW.governing_monitor_product_version_uuid;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Governing Monitor requires MonitorTarget';
        END IF;

        IF mt.target_product_version_uuid
              IS DISTINCT FROM NEW.target_product_version_uuid
           OR mt.target_investigation_version_uuid
              IS DISTINCT FROM NEW.target_investigation_version_uuid THEN
            RAISE EXCEPTION 'Governing Monitor target must match UpdatePolicy target';
        END IF;
    END IF;

    IF NEW.supersedes_update_policy_uuid IS NOT NULL THEN
        SELECT * INTO prior
          FROM maintenance.update_policy p
         WHERE p.update_policy_uuid=NEW.supersedes_update_policy_uuid;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Superseded UpdatePolicy does not exist';
        END IF;

        IF prior.target_product_version_uuid
              IS DISTINCT FROM NEW.target_product_version_uuid
           OR prior.target_investigation_version_uuid
              IS DISTINCT FROM NEW.target_investigation_version_uuid THEN
            RAISE EXCEPTION 'UpdatePolicy supersession must preserve exact target version';
        END IF;

        IF NEW.effective_at<prior.effective_at THEN
            RAISE EXCEPTION 'UpdatePolicy supersession violates temporal order';
        END IF;

        transition_ok := (
            prior.effective_maintenance_level=NEW.effective_maintenance_level
            OR
            (prior.effective_maintenance_level='M0'
             AND NEW.effective_maintenance_level IN ('M1','M2'))
            OR
            (prior.effective_maintenance_level='M1'
             AND NEW.effective_maintenance_level IN ('M0','M2'))
            OR
            (prior.effective_maintenance_level='M2'
             AND NEW.effective_maintenance_level IN ('M1','M3'))
            OR
            (prior.effective_maintenance_level='M3'
             AND NEW.effective_maintenance_level IN ('M0','M1','M2'))
        );

        IF NOT transition_ok THEN
            RAISE EXCEPTION 'Invalid UpdatePolicy maintenance transition % -> %',
                prior.effective_maintenance_level,
                NEW.effective_maintenance_level;
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_policy_consistency
    ON maintenance.update_policy;
CREATE TRIGGER tr_update_policy_consistency
BEFORE INSERT ON maintenance.update_policy
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_policy_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_update_policy_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'UpdatePolicy is append-preserving and cannot be deleted';
    END IF;

    IF OLD.record_status='active'
       AND NEW.record_status='superseded'
       AND NEW.update_policy_uuid=OLD.update_policy_uuid
       AND NEW.target_product_version_uuid IS NOT DISTINCT FROM OLD.target_product_version_uuid
       AND NEW.target_investigation_version_uuid IS NOT DISTINCT FROM OLD.target_investigation_version_uuid
       AND NEW.effective_maintenance_level=OLD.effective_maintenance_level
       AND NEW.cadence_mode=OLD.cadence_mode
       AND NEW.cadence_policy_payload=OLD.cadence_policy_payload
       AND NEW.trigger_policy_payload=OLD.trigger_policy_payload
       AND NEW.materiality_policy_payload=OLD.materiality_policy_payload
       AND NEW.escalation_policy_payload=OLD.escalation_policy_payload
       AND NEW.governance_policy_payload=OLD.governance_policy_payload
       AND NEW.governing_monitor_product_version_uuid
              IS NOT DISTINCT FROM OLD.governing_monitor_product_version_uuid
       AND NEW.effective_at=OLD.effective_at
       AND NEW.rationale=OLD.rationale
       AND NEW.created_by=OLD.created_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.supersedes_update_policy_uuid
              IS NOT DISTINCT FROM OLD.supersedes_update_policy_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'UpdatePolicy material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_update_policy_append_preserving
    ON maintenance.update_policy;
CREATE TRIGGER tr_update_policy_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.update_policy
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_update_policy_mutation();

-- ---------------------------------------------------------------------------
-- UPDATE SIGNAL
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_signal (
    update_signal_uuid uuid PRIMARY KEY,
    update_policy_uuid uuid NOT NULL
        REFERENCES maintenance.update_policy(update_policy_uuid),
    signal_class text NOT NULL CHECK (
        signal_class IN ('scientific_currentness','operational')
    ),
    trigger_class text NOT NULL CHECK (
        trigger_class IN (
            'new_evidence','integrity_validity','safety_regulatory',
            'temporal_operational','governance_demand',
            'methodological','scope'
        )
    ),
    signal_type text NOT NULL CHECK (
        signal_type IN (
            'new_study','new_review','review_update',
            'estimate_change_signal','safety_signal',
            'new_population_signal','certainty_change_signal',
            'correction','retraction','expression_of_concern',
            'methodology_change','regulatory_change',
            'cadence_due','cycle_incomplete','source_coverage_gap',
            'explicit_reassessment_request','use_context_change',
            'scope_change','other'
        )
    ),
    signal_date date,
    detected_at timestamptz NOT NULL,
    summary text NOT NULL CHECK (length(btrim(summary))>0),
    rationale text,
    detected_by text NOT NULL CHECK (length(btrim(detected_by))>0),
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
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','invalidated')
    ),
    invalidated_at timestamptz,
    invalidation_reason text,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        status<>'invalidated'
        OR (
            invalidated_at IS NOT NULL
            AND length(btrim(COALESCE(invalidation_reason,'')))>0
        )
    )
);

CREATE INDEX IF NOT EXISTS ix_update_signal_policy
    ON maintenance.update_signal(update_policy_uuid,status);

CREATE OR REPLACE FUNCTION maintenance.assert_verification_metadata(
    p_status text,
    p_verified_by text,
    p_verifier_actor_type text,
    p_verified_at timestamptz
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
    SELECT CASE
        WHEN p_status='unverified' THEN
            p_verified_by IS NULL
            AND p_verifier_actor_type IS NULL
            AND p_verified_at IS NULL
        WHEN p_status='ai_verified' THEN
            p_verified_by IS NOT NULL
            AND p_verifier_actor_type='ai_system'
            AND p_verified_at IS NOT NULL
        WHEN p_status IN ('human_verified','human_consensus') THEN
            p_verified_by IS NOT NULL
            AND p_verifier_actor_type IN ('human_reviewer','human_expert')
            AND p_verified_at IS NOT NULL
        ELSE false
    END;
$q$;

CREATE OR REPLACE FUNCTION maintenance.signal_mapping_is_valid(
    p_signal_type text,
    p_signal_class text,
    p_trigger_class text,
    p_rationale text
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $q$
    SELECT CASE p_signal_type
        WHEN 'new_study' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='new_evidence'
        WHEN 'new_review' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='new_evidence'
        WHEN 'review_update' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='new_evidence'
        WHEN 'estimate_change_signal' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='new_evidence'
        WHEN 'safety_signal' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='safety_regulatory'
        WHEN 'new_population_signal' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='new_evidence'
        WHEN 'certainty_change_signal' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='new_evidence'
        WHEN 'correction' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='integrity_validity'
        WHEN 'retraction' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='integrity_validity'
        WHEN 'expression_of_concern' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='integrity_validity'
        WHEN 'methodology_change' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='methodological'
        WHEN 'regulatory_change' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='safety_regulatory'
        WHEN 'cadence_due' THEN
            p_signal_class='operational' AND p_trigger_class='temporal_operational'
        WHEN 'cycle_incomplete' THEN
            p_signal_class='operational' AND p_trigger_class='temporal_operational'
        WHEN 'source_coverage_gap' THEN
            p_signal_class='operational' AND p_trigger_class='temporal_operational'
        WHEN 'explicit_reassessment_request' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='governance_demand'
        WHEN 'use_context_change' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='governance_demand'
        WHEN 'scope_change' THEN
            p_signal_class='scientific_currentness' AND p_trigger_class='scope'
        WHEN 'other' THEN
            length(btrim(COALESCE(p_rationale,'')))>0
        ELSE false
    END;
$q$;

CREATE OR REPLACE FUNCTION maintenance.assert_update_signal_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    policy_status text;
BEGIN
    SELECT p.record_status INTO policy_status
      FROM maintenance.update_policy p
     WHERE p.update_policy_uuid=NEW.update_policy_uuid;

    IF policy_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'UpdateSignal requires active UpdatePolicy at detection';
    END IF;

    IF NOT maintenance.signal_mapping_is_valid(
        NEW.signal_type,NEW.signal_class,NEW.trigger_class,NEW.rationale
    ) THEN
        RAISE EXCEPTION 'UpdateSignal type/class/trigger mapping is invalid';
    END IF;

    IF NEW.signal_date IS NOT NULL
       AND NEW.signal_date>NEW.detected_at::date THEN
        RAISE EXCEPTION 'UpdateSignal signal_date cannot be after detected_at date';
    END IF;

    IF NOT maintenance.assert_verification_metadata(
        NEW.verification_status,NEW.verified_by,
        NEW.verifier_actor_type,NEW.verified_at
    ) THEN
        RAISE EXCEPTION 'UpdateSignal verification metadata mismatch';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_signal_consistency
    ON maintenance.update_signal;
CREATE TRIGGER tr_update_signal_consistency
BEFORE INSERT ON maintenance.update_signal
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_signal_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_update_signal_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'UpdateSignal is immutable and cannot be deleted';
    END IF;

    IF OLD.status='active'
       AND NEW.status='invalidated'
       AND NEW.update_signal_uuid=OLD.update_signal_uuid
       AND NEW.update_policy_uuid=OLD.update_policy_uuid
       AND NEW.signal_class=OLD.signal_class
       AND NEW.trigger_class=OLD.trigger_class
       AND NEW.signal_type=OLD.signal_type
       AND NEW.signal_date IS NOT DISTINCT FROM OLD.signal_date
       AND NEW.detected_at=OLD.detected_at
       AND NEW.summary=OLD.summary
       AND NEW.rationale IS NOT DISTINCT FROM OLD.rationale
       AND NEW.detected_by=OLD.detected_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.verification_status=OLD.verification_status
       AND NEW.verified_by IS NOT DISTINCT FROM OLD.verified_by
       AND NEW.verifier_actor_type IS NOT DISTINCT FROM OLD.verifier_actor_type
       AND NEW.verified_at IS NOT DISTINCT FROM OLD.verified_at
       AND NEW.invalidated_at IS NOT NULL
       AND length(btrim(COALESCE(NEW.invalidation_reason,'')))>0
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'UpdateSignal material fields are immutable; invalidate or append a new signal';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_update_signal_immutable
    ON maintenance.update_signal;
CREATE TRIGGER tr_update_signal_immutable
BEFORE UPDATE OR DELETE ON maintenance.update_signal
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_update_signal_mutation();

-- ---------------------------------------------------------------------------
-- UPDATE SIGNAL SOURCE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_signal_source (
    update_signal_source_uuid uuid PRIMARY KEY,
    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),
    source_role text NOT NULL CHECK (
        source_role IN ('primary','supporting')
    ),
    source_type text NOT NULL CHECK (
        source_type IN (
            'monitor_cycle','candidate_assessment','evidence_event',
            'alert_product_version','search_hit','entity_version',
            'artifact','uri'
        )
    ),
    monitor_cycle_uuid uuid
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    candidate_assessment_uuid uuid
        REFERENCES maintenance.candidate_assessment(candidate_assessment_uuid),
    evidence_event_uuid uuid
        REFERENCES maintenance.evidence_event(evidence_event_uuid),
    alert_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),
    search_hit_uuid uuid
        REFERENCES investigation.search_hit(search_hit_uuid),
    source_entity_version_uuid uuid
        REFERENCES core.entity_version(version_uuid),
    source_artifact_uuid uuid
        REFERENCES artifact.artifact(artifact_uuid),
    source_uri text,
    note text,
    sequence_no integer,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        num_nonnulls(
            monitor_cycle_uuid,
            candidate_assessment_uuid,
            evidence_event_uuid,
            alert_product_version_uuid,
            search_hit_uuid,
            source_entity_version_uuid,
            source_artifact_uuid,
            source_uri
        )=1
    ),
    CHECK (source_uri IS NULL OR length(btrim(source_uri))>0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_update_signal_primary_source
    ON maintenance.update_signal_source(update_signal_uuid)
    WHERE source_role='primary';

CREATE INDEX IF NOT EXISTS ix_update_signal_source_signal
    ON maintenance.update_signal_source(update_signal_uuid);

CREATE OR REPLACE FUNCTION maintenance.assert_update_signal_source_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    s maintenance.update_signal%ROWTYPE;
    p maintenance.update_policy%ROWTYPE;
    source_monitor uuid;
    source_status text;
    alert_target_product uuid;
    alert_target_inv uuid;
BEGIN
    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=NEW.update_signal_uuid;

    IF NOT FOUND OR s.status<>'active' THEN
        RAISE EXCEPTION 'UpdateSignalSource requires active UpdateSignal';
    END IF;

    IF EXISTS (
        SELECT 1 FROM maintenance.materiality_assessment ma
         WHERE ma.update_signal_uuid=NEW.update_signal_uuid
    ) THEN
        RAISE EXCEPTION 'UpdateSignalSource is sealed after MaterialityAssessment';
    END IF;

    SELECT * INTO p
      FROM maintenance.update_policy
     WHERE update_policy_uuid=s.update_policy_uuid;

    IF (NEW.source_type='monitor_cycle') IS DISTINCT FROM
       (NEW.monitor_cycle_uuid IS NOT NULL)
       OR (NEW.source_type='candidate_assessment') IS DISTINCT FROM
       (NEW.candidate_assessment_uuid IS NOT NULL)
       OR (NEW.source_type='evidence_event') IS DISTINCT FROM
       (NEW.evidence_event_uuid IS NOT NULL)
       OR (NEW.source_type='alert_product_version') IS DISTINCT FROM
       (NEW.alert_product_version_uuid IS NOT NULL)
       OR (NEW.source_type='search_hit') IS DISTINCT FROM
       (NEW.search_hit_uuid IS NOT NULL)
       OR (NEW.source_type='entity_version') IS DISTINCT FROM
       (NEW.source_entity_version_uuid IS NOT NULL)
       OR (NEW.source_type='artifact') IS DISTINCT FROM
       (NEW.source_artifact_uuid IS NOT NULL)
       OR (NEW.source_type='uri') IS DISTINCT FROM
       (NEW.source_uri IS NOT NULL) THEN
        RAISE EXCEPTION 'UpdateSignalSource source_type/locator mismatch';
    END IF;

    IF NEW.monitor_cycle_uuid IS NOT NULL THEN
        SELECT mc.monitor_product_version_uuid INTO source_monitor
          FROM maintenance.monitor_cycle mc
         WHERE mc.cycle_uuid=NEW.monitor_cycle_uuid;
    ELSIF NEW.candidate_assessment_uuid IS NOT NULL THEN
        SELECT ca.record_status,mc.monitor_product_version_uuid
          INTO source_status,source_monitor
          FROM maintenance.candidate_assessment ca
          JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ca.cycle_uuid
         WHERE ca.candidate_assessment_uuid=NEW.candidate_assessment_uuid;
        IF source_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION 'CandidateAssessment source must be active';
        END IF;
    ELSIF NEW.evidence_event_uuid IS NOT NULL THEN
        SELECT ee.status,mc.monitor_product_version_uuid
          INTO source_status,source_monitor
          FROM maintenance.evidence_event ee
          JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ee.cycle_uuid
         WHERE ee.evidence_event_uuid=NEW.evidence_event_uuid;
        IF source_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION 'EvidenceEvent source must be active';
        END IF;
    ELSIF NEW.search_hit_uuid IS NOT NULL THEN
        SELECT mc.monitor_product_version_uuid
          INTO source_monitor
          FROM investigation.search_hit sh
          JOIN maintenance.cycle_search cs ON cs.search_uuid=sh.search_uuid
          JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=cs.cycle_uuid
         WHERE sh.search_hit_uuid=NEW.search_hit_uuid;
        IF source_monitor IS NULL THEN
            RAISE EXCEPTION 'SearchHit source must belong to a MonitorCycle';
        END IF;
    ELSIF NEW.alert_product_version_uuid IS NOT NULL THEN
        SELECT pv.product_type INTO source_status
          FROM product.product_version pv
         WHERE pv.version_uuid=NEW.alert_product_version_uuid;
        IF source_status IS DISTINCT FROM 'evidence_alert' THEN
            RAISE EXCEPTION 'Alert source must be evidence_alert ProductVersion';
        END IF;
        SELECT a.target_product_version_uuid,a.target_investigation_version_uuid
          INTO alert_target_product,alert_target_inv
          FROM maintenance.evidence_alert a
         WHERE a.alert_product_version_uuid=NEW.alert_product_version_uuid;
        IF alert_target_product IS DISTINCT FROM p.target_product_version_uuid
           OR alert_target_inv IS DISTINCT FROM p.target_investigation_version_uuid THEN
            RAISE EXCEPTION 'Alert source target must match UpdatePolicy target';
        END IF;
    ELSIF NEW.source_entity_version_uuid IS NOT NULL THEN
        SELECT ev.version_status INTO source_status
          FROM core.entity_version ev
         WHERE ev.version_uuid=NEW.source_entity_version_uuid;
        IF source_status IN ('invalidated','archived') OR source_status IS NULL THEN
            RAISE EXCEPTION 'EntityVersion source is invalid/archived/missing';
        END IF;
    ELSIF NEW.source_artifact_uuid IS NOT NULL THEN
        SELECT a.status INTO source_status
          FROM artifact.artifact a
         WHERE a.artifact_uuid=NEW.source_artifact_uuid;
        IF source_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION 'Artifact source must be active';
        END IF;
    END IF;

    IF NEW.source_type IN (
        'monitor_cycle','candidate_assessment','evidence_event','search_hit'
    ) THEN
        IF p.governing_monitor_product_version_uuid IS NULL
           OR source_monitor IS DISTINCT FROM
              p.governing_monitor_product_version_uuid THEN
            RAISE EXCEPTION 'Monitor-derived source must belong to governing Monitor';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_signal_source_consistency
    ON maintenance.update_signal_source;
CREATE TRIGGER tr_update_signal_source_consistency
BEFORE INSERT ON maintenance.update_signal_source
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_signal_source_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_update_signal_source_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION 'UpdateSignalSource is immutable; create a new signal if sources change';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_update_signal_source_immutable
    ON maintenance.update_signal_source;
CREATE TRIGGER tr_update_signal_source_immutable
BEFORE UPDATE OR DELETE ON maintenance.update_signal_source
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_update_signal_source_mutation();

-- ---------------------------------------------------------------------------
-- MATERIALITY ASSESSMENT
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.materiality_assessment (
    materiality_assessment_uuid uuid PRIMARY KEY,
    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),
    outcome text NOT NULL CHECK (
        outcome IN (
            'no_material_change','potentially_material',
            'material_change_confirmed','validity_or_use_threat',
            'insufficient_to_decide'
        )
    ),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    assessed_by text NOT NULL CHECK (length(btrim(assessed_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
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
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_materiality_assessment_uuid uuid
        REFERENCES maintenance.materiality_assessment(materiality_assessment_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        supersedes_materiality_assessment_uuid IS NULL
        OR supersedes_materiality_assessment_uuid<>materiality_assessment_uuid
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_materiality_assessment_active_signal
    ON maintenance.materiality_assessment(update_signal_uuid)
    WHERE record_status='active';

CREATE OR REPLACE FUNCTION maintenance.assert_materiality_assessment_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    s maintenance.update_signal%ROWTYPE;
    primary_count integer;
    prior maintenance.materiality_assessment%ROWTYPE;
BEGIN
    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=NEW.update_signal_uuid;

    IF NOT FOUND OR s.status<>'active' THEN
        RAISE EXCEPTION 'MaterialityAssessment requires active UpdateSignal';
    END IF;

    SELECT count(*) INTO primary_count
      FROM maintenance.update_signal_source uss
     WHERE uss.update_signal_uuid=NEW.update_signal_uuid
       AND uss.source_role='primary';

    IF NOT (
        s.trigger_class='governance_demand'
        OR s.signal_type='cadence_due'
    ) AND primary_count<>1 THEN
        RAISE EXCEPTION 'MaterialityAssessment requires exactly one primary source';
    END IF;

    IF s.signal_class='operational'
       AND NEW.outcome='material_change_confirmed' THEN
        RAISE EXCEPTION 'Operational signal cannot confirm scientific material change';
    END IF;

    IF NOT maintenance.assert_verification_metadata(
        NEW.verification_status,NEW.verified_by,
        NEW.verifier_actor_type,NEW.verified_at
    ) THEN
        RAISE EXCEPTION 'MaterialityAssessment verification metadata mismatch';
    END IF;

    IF NEW.supersedes_materiality_assessment_uuid IS NOT NULL THEN
        SELECT * INTO prior
          FROM maintenance.materiality_assessment ma
         WHERE ma.materiality_assessment_uuid=
               NEW.supersedes_materiality_assessment_uuid;

        IF NOT FOUND OR prior.update_signal_uuid<>NEW.update_signal_uuid THEN
            RAISE EXCEPTION 'MaterialityAssessment supersession must preserve signal';
        END IF;
        IF NEW.assessed_at<prior.assessed_at THEN
            RAISE EXCEPTION 'MaterialityAssessment supersession violates temporal order';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_materiality_assessment_consistency
    ON maintenance.materiality_assessment;
CREATE TRIGGER tr_materiality_assessment_consistency
BEFORE INSERT ON maintenance.materiality_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_materiality_assessment_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_materiality_assessment_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'MaterialityAssessment is append-preserving and cannot be deleted';
    END IF;

    IF OLD.record_status='active'
       AND NEW.record_status='superseded'
       AND NEW.materiality_assessment_uuid=OLD.materiality_assessment_uuid
       AND NEW.update_signal_uuid=OLD.update_signal_uuid
       AND NEW.outcome=OLD.outcome
       AND NEW.rationale=OLD.rationale
       AND NEW.assessed_by=OLD.assessed_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.verification_status=OLD.verification_status
       AND NEW.verified_by IS NOT DISTINCT FROM OLD.verified_by
       AND NEW.verifier_actor_type IS NOT DISTINCT FROM OLD.verifier_actor_type
       AND NEW.verified_at IS NOT DISTINCT FROM OLD.verified_at
       AND NEW.assessed_at=OLD.assessed_at
       AND NEW.supersedes_materiality_assessment_uuid
              IS NOT DISTINCT FROM OLD.supersedes_materiality_assessment_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'MaterialityAssessment material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_materiality_assessment_append_preserving
    ON maintenance.materiality_assessment;
CREATE TRIGGER tr_materiality_assessment_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.materiality_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_materiality_assessment_mutation();

-- ---------------------------------------------------------------------------
-- MATERIALITY DIMENSION
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.materiality_dimension (
    materiality_assessment_uuid uuid NOT NULL
        REFERENCES maintenance.materiality_assessment(materiality_assessment_uuid),
    dimension_code text NOT NULL CHECK (
        dimension_code IN (
            'benefit','harm','magnitude','precision','certainty',
            'applicability','conclusion','regulatory_status',
            'validity','scope','method','other'
        )
    ),
    dimension_status text NOT NULL CHECK (
        dimension_status IN ('potential','confirmed','threat','uncertain')
    ),
    rationale text,
    sequence_no integer,
    PRIMARY KEY (materiality_assessment_uuid,dimension_code)
);

CREATE OR REPLACE FUNCTION maintenance.assert_materiality_dimension_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    outcome_value text;
BEGIN
    IF EXISTS (
        SELECT 1 FROM maintenance.update_decision d
         WHERE d.materiality_assessment_uuid=NEW.materiality_assessment_uuid
    ) THEN
        RAISE EXCEPTION 'MaterialityDimension is sealed after UpdateDecision';
    END IF;

    SELECT ma.outcome INTO outcome_value
      FROM maintenance.materiality_assessment ma
     WHERE ma.materiality_assessment_uuid=NEW.materiality_assessment_uuid;

    IF outcome_value='no_material_change'
       AND NEW.dimension_status IN ('confirmed','threat') THEN
        RAISE EXCEPTION 'No-material-change assessment cannot contain confirmed/threat dimension';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_materiality_dimension_consistency
    ON maintenance.materiality_dimension;
CREATE TRIGGER tr_materiality_dimension_consistency
BEFORE INSERT ON maintenance.materiality_dimension
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_materiality_dimension_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_materiality_dimension_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION 'MaterialityDimension is immutable; supersede the assessment';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_materiality_dimension_immutable
    ON maintenance.materiality_dimension;
CREATE TRIGGER tr_materiality_dimension_immutable
BEFORE UPDATE OR DELETE ON maintenance.materiality_dimension
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_materiality_dimension_mutation();

-- ---------------------------------------------------------------------------
-- UPDATE DECISION
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_decision (
    update_decision_uuid uuid PRIMARY KEY,
    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),
    materiality_assessment_uuid uuid NOT NULL
        REFERENCES maintenance.materiality_assessment(materiality_assessment_uuid),
    decision_type text NOT NULL CHECK (
        decision_type IN (
            'no_scientific_update','observe','currentness_only',
            'scientific_update_incremental','scientific_update_broad',
            'reroute_method','suspend_current_use'
        )
    ),
    authority_status text NOT NULL CHECK (
        authority_status IN ('proposal','authoritative')
    ),
    currency_action text NOT NULL DEFAULT 'no_change' CHECK (
        currency_action IN (
            'no_change','set_current','set_under_evaluation',
            'set_update_recommended','set_outdated'
        )
    ),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    decided_by text NOT NULL CHECK (length(btrim(decided_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert','owner')
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
    decided_at timestamptz NOT NULL,
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_update_decision_uuid uuid
        REFERENCES maintenance.update_decision(update_decision_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        supersedes_update_decision_uuid IS NULL
        OR supersedes_update_decision_uuid<>update_decision_uuid
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_update_decision_active_signal
    ON maintenance.update_decision(update_signal_uuid)
    WHERE record_status='active';

CREATE OR REPLACE FUNCTION maintenance.assert_update_decision_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    ma maintenance.materiality_assessment%ROWTYPE;
    s maintenance.update_signal%ROWTYPE;
    p maintenance.update_policy%ROWTYPE;
    prior maintenance.update_decision%ROWTYPE;
    dim_ok boolean;
BEGIN
    SELECT * INTO ma
      FROM maintenance.materiality_assessment x
     WHERE x.materiality_assessment_uuid=NEW.materiality_assessment_uuid;

    IF NOT FOUND OR ma.record_status<>'active' THEN
        RAISE EXCEPTION 'UpdateDecision requires active MaterialityAssessment';
    END IF;

    IF ma.update_signal_uuid<>NEW.update_signal_uuid THEN
        RAISE EXCEPTION 'UpdateDecision signal must match MaterialityAssessment signal';
    END IF;

    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=NEW.update_signal_uuid;

    SELECT * INTO p
      FROM maintenance.update_policy
     WHERE update_policy_uuid=s.update_policy_uuid;

    IF NOT maintenance.assert_verification_metadata(
        NEW.verification_status,NEW.verified_by,
        NEW.verifier_actor_type,NEW.verified_at
    ) THEN
        RAISE EXCEPTION 'UpdateDecision verification metadata mismatch';
    END IF;

    IF NEW.authority_status='authoritative' THEN
        IF NEW.actor_type='ai_system' THEN
            RAISE EXCEPTION 'AI cannot create authoritative UpdateDecision';
        END IF;
        IF NEW.verification_status NOT IN ('human_verified','human_consensus') THEN
            RAISE EXCEPTION 'Authoritative UpdateDecision requires human verification';
        END IF;
        IF ma.verification_status NOT IN ('human_verified','human_consensus') THEN
            RAISE EXCEPTION 'Authoritative UpdateDecision requires human-verified materiality assessment';
        END IF;
    END IF;

    IF p.target_investigation_version_uuid IS NOT NULL
       AND NEW.currency_action<>'no_change' THEN
        RAISE EXCEPTION 'InvestigationVersion target cannot receive CurrencyState action';
    END IF;

    IF ma.outcome='material_change_confirmed' THEN
        SELECT EXISTS (
            SELECT 1 FROM maintenance.materiality_dimension md
             WHERE md.materiality_assessment_uuid=ma.materiality_assessment_uuid
               AND md.dimension_status='confirmed'
        ) INTO dim_ok;
        IF NOT dim_ok THEN
            RAISE EXCEPTION 'Confirmed material change requires confirmed dimension';
        END IF;
    ELSIF ma.outcome='validity_or_use_threat' THEN
        SELECT EXISTS (
            SELECT 1 FROM maintenance.materiality_dimension md
             WHERE md.materiality_assessment_uuid=ma.materiality_assessment_uuid
               AND md.dimension_status='threat'
        ) INTO dim_ok;
        IF NOT dim_ok THEN
            RAISE EXCEPTION 'Validity/use threat requires threat dimension';
        END IF;
    ELSIF ma.outcome='potentially_material' THEN
        SELECT EXISTS (
            SELECT 1 FROM maintenance.materiality_dimension md
             WHERE md.materiality_assessment_uuid=ma.materiality_assessment_uuid
               AND md.dimension_status IN ('potential','uncertain')
        ) INTO dim_ok;
        IF NOT dim_ok THEN
            RAISE EXCEPTION 'Potentially material assessment requires potential/uncertain dimension';
        END IF;
    END IF;

    IF NEW.decision_type='no_scientific_update' THEN
        IF ma.outcome<>'no_material_change'
           OR NEW.currency_action NOT IN ('no_change','set_current') THEN
            RAISE EXCEPTION 'no_scientific_update decision/outcome/currency mismatch';
        END IF;
    ELSIF NEW.decision_type='observe' THEN
        IF ma.outcome NOT IN (
            'potentially_material','insufficient_to_decide',
            'validity_or_use_threat'
        ) OR NEW.currency_action NOT IN ('no_change','set_under_evaluation') THEN
            RAISE EXCEPTION 'observe decision/outcome/currency mismatch';
        END IF;
    ELSIF NEW.decision_type='currentness_only' THEN
        IF p.target_product_version_uuid IS NULL THEN
            RAISE EXCEPTION 'currentness_only requires ProductVersion target';
        END IF;
        IF NOT (
            (ma.outcome='no_material_change' AND NEW.currency_action='set_current')
            OR
            (ma.outcome='potentially_material'
             AND NEW.currency_action IN ('set_under_evaluation','set_update_recommended'))
            OR
            (ma.outcome='material_change_confirmed'
             AND NEW.currency_action IN ('set_update_recommended','set_outdated'))
            OR
            (ma.outcome='validity_or_use_threat'
             AND NEW.currency_action IN (
                 'set_under_evaluation','set_update_recommended','set_outdated'
             ))
            OR
            (ma.outcome='insufficient_to_decide'
             AND NEW.currency_action='set_under_evaluation')
        ) THEN
            RAISE EXCEPTION 'currentness_only outcome/currency matrix violation';
        END IF;
    ELSIF NEW.decision_type IN (
        'scientific_update_incremental','scientific_update_broad'
    ) THEN
        IF ma.outcome NOT IN (
            'potentially_material','material_change_confirmed',
            'validity_or_use_threat'
        ) THEN
            RAISE EXCEPTION 'Scientific update requires potentially/confirmed materiality or validity threat';
        END IF;
        IF NEW.currency_action NOT IN (
            'no_change','set_under_evaluation',
            'set_update_recommended','set_outdated'
        ) THEN
            RAISE EXCEPTION 'Scientific update currency action mismatch';
        END IF;
    ELSIF NEW.decision_type='reroute_method' THEN
        IF s.trigger_class NOT IN ('methodological','scope','governance_demand')
           OR NEW.currency_action NOT IN (
               'no_change','set_under_evaluation',
               'set_update_recommended','set_outdated'
           ) THEN
            RAISE EXCEPTION 'reroute_method requires methodological/scope/governance signal';
        END IF;
    ELSIF NEW.decision_type='suspend_current_use' THEN
        IF NEW.authority_status<>'authoritative' THEN
            RAISE EXCEPTION 'suspend_current_use requires authoritative decision';
        END IF;
        IF p.target_product_version_uuid IS NOT NULL
           AND NEW.currency_action<>'set_outdated' THEN
            RAISE EXCEPTION 'Product suspend_current_use requires set_outdated';
        END IF;
        IF p.target_investigation_version_uuid IS NOT NULL
           AND NEW.currency_action<>'no_change' THEN
            RAISE EXCEPTION 'Investigation suspend_current_use cannot create CurrencyState';
        END IF;
    END IF;

    IF NEW.supersedes_update_decision_uuid IS NOT NULL THEN
        SELECT * INTO prior
          FROM maintenance.update_decision d
         WHERE d.update_decision_uuid=NEW.supersedes_update_decision_uuid;

        IF NOT FOUND OR prior.update_signal_uuid<>NEW.update_signal_uuid THEN
            RAISE EXCEPTION 'UpdateDecision supersession must preserve signal';
        END IF;
        IF NEW.decided_at<prior.decided_at THEN
            RAISE EXCEPTION 'UpdateDecision supersession violates temporal order';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_decision_consistency
    ON maintenance.update_decision;
CREATE TRIGGER tr_update_decision_consistency
BEFORE INSERT ON maintenance.update_decision
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_decision_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_update_decision_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'UpdateDecision is append-preserving and cannot be deleted';
    END IF;

    IF OLD.record_status='active'
       AND NEW.record_status='superseded'
       AND NEW.update_decision_uuid=OLD.update_decision_uuid
       AND NEW.update_signal_uuid=OLD.update_signal_uuid
       AND NEW.materiality_assessment_uuid=OLD.materiality_assessment_uuid
       AND NEW.decision_type=OLD.decision_type
       AND NEW.authority_status=OLD.authority_status
       AND NEW.currency_action=OLD.currency_action
       AND NEW.rationale=OLD.rationale
       AND NEW.decided_by=OLD.decided_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.verification_status=OLD.verification_status
       AND NEW.verified_by IS NOT DISTINCT FROM OLD.verified_by
       AND NEW.verifier_actor_type IS NOT DISTINCT FROM OLD.verifier_actor_type
       AND NEW.verified_at IS NOT DISTINCT FROM OLD.verified_at
       AND NEW.decided_at=OLD.decided_at
       AND NEW.supersedes_update_decision_uuid
              IS NOT DISTINCT FROM OLD.supersedes_update_decision_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'UpdateDecision material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_update_decision_append_preserving
    ON maintenance.update_decision;
CREATE TRIGGER tr_update_decision_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.update_decision
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_update_decision_mutation();

-- ---------------------------------------------------------------------------
-- UPDATE DECISION -> CURRENCY STATE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.update_decision_currency_state (
    update_decision_uuid uuid PRIMARY KEY
        REFERENCES maintenance.update_decision(update_decision_uuid),
    currency_state_uuid uuid NOT NULL
        REFERENCES product.currency_state(currency_state_uuid),
    linked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_update_decision_currency_state
    ON maintenance.update_decision_currency_state(currency_state_uuid);

CREATE OR REPLACE FUNCTION maintenance.assert_update_decision_currency_state_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    d maintenance.update_decision%ROWTYPE;
    ma maintenance.materiality_assessment%ROWTYPE;
    s maintenance.update_signal%ROWTYPE;
    p maintenance.update_policy%ROWTYPE;
    cs product.currency_state%ROWTYPE;
    expected_status text;
BEGIN
    SELECT * INTO d
      FROM maintenance.update_decision
     WHERE update_decision_uuid=NEW.update_decision_uuid;

    IF NOT FOUND OR d.authority_status<>'authoritative' THEN
        RAISE EXCEPTION 'CurrencyState linkage requires authoritative UpdateDecision';
    END IF;

    SELECT * INTO ma
      FROM maintenance.materiality_assessment
     WHERE materiality_assessment_uuid=d.materiality_assessment_uuid;
    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=d.update_signal_uuid;
    SELECT * INTO p
      FROM maintenance.update_policy
     WHERE update_policy_uuid=s.update_policy_uuid;

    IF p.target_product_version_uuid IS NULL THEN
        RAISE EXCEPTION 'CurrencyState linkage requires ProductVersion target';
    END IF;

    SELECT * INTO cs
      FROM product.currency_state
     WHERE currency_state_uuid=NEW.currency_state_uuid;

    IF NOT FOUND
       OR cs.product_version_uuid<>p.target_product_version_uuid
       OR cs.record_status<>'active' THEN
        RAISE EXCEPTION 'CurrencyState must be active and belong to UpdatePolicy target ProductVersion';
    END IF;

    expected_status:=CASE d.currency_action
        WHEN 'set_current' THEN 'current'
        WHEN 'set_under_evaluation' THEN 'under_evaluation'
        WHEN 'set_update_recommended' THEN 'update_recommended'
        WHEN 'set_outdated' THEN 'outdated'
        ELSE NULL
    END;

    IF expected_status IS NULL OR cs.currency_status<>expected_status THEN
        RAISE EXCEPTION 'UpdateDecision currency action/status mismatch';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_decision_currency_state_consistency
    ON maintenance.update_decision_currency_state;
CREATE TRIGGER tr_update_decision_currency_state_consistency
BEFORE INSERT ON maintenance.update_decision_currency_state
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_update_decision_currency_state_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_update_decision_currency_state_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION 'UpdateDecisionCurrencyState is immutable';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_update_decision_currency_state_immutable
    ON maintenance.update_decision_currency_state;
CREATE TRIGGER tr_update_decision_currency_state_immutable
BEFORE UPDATE OR DELETE ON maintenance.update_decision_currency_state
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_update_decision_currency_state_mutation();

-- ---------------------------------------------------------------------------
-- READ-ONLY ISSUE HELPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.update_policy_issues(
    p_update_policy_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    p maintenance.update_policy%ROWTYPE;
    target_state text;
    monitor_state text;
BEGIN
    SELECT * INTO p
      FROM maintenance.update_policy
     WHERE update_policy_uuid=p_update_policy_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'MISSING_UPDATE_POLICY','error','UpdatePolicy does not exist';
        RETURN;
    END IF;

    SELECT ev.version_status INTO target_state
      FROM core.entity_version ev
     WHERE ev.version_uuid=COALESCE(
        p.target_product_version_uuid,
        p.target_investigation_version_uuid
     );

    IF target_state IS DISTINCT FROM 'current' THEN
        RETURN QUERY SELECT
            'UPDATE_POLICY_TARGET_SUPERSEDED','warning',
            'UpdatePolicy target version is no longer current';
    END IF;

    IF p.governing_monitor_product_version_uuid IS NOT NULL THEN
        SELECT ev.version_status INTO monitor_state
          FROM core.entity_version ev
         WHERE ev.version_uuid=p.governing_monitor_product_version_uuid;
        IF monitor_state IN ('superseded','archived','invalidated')
           OR monitor_state IS NULL THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_MONITOR_NOT_CURRENT','warning',
                'Governing Monitor version is no longer current';
        END IF;
    END IF;

    IF p.effective_maintenance_level='M3' THEN
        RETURN QUERY SELECT
            'M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL','error',
            'M3 policy is representable but formal living-evidence operation remains blocked';
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.update_signal_issues(
    p_update_signal_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    s maintenance.update_signal%ROWTYPE;
    primary_count integer;
BEGIN
    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=p_update_signal_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'MISSING_UPDATE_SIGNAL','error','UpdateSignal does not exist';
        RETURN;
    END IF;

    SELECT count(*) INTO primary_count
      FROM maintenance.update_signal_source uss
     WHERE uss.update_signal_uuid=s.update_signal_uuid
       AND uss.source_role='primary';

    IF NOT (
        s.trigger_class='governance_demand'
        OR s.signal_type='cadence_due'
    ) AND primary_count<>1 THEN
        RETURN QUERY SELECT
            'UPDATE_SIGNAL_PRIMARY_SOURCE_COUNT','error',
            'UpdateSignal requires exactly one primary source';
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.materiality_assessment_issues(
    p_materiality_assessment_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    ma maintenance.materiality_assessment%ROWTYPE;
BEGIN
    SELECT * INTO ma
      FROM maintenance.materiality_assessment
     WHERE materiality_assessment_uuid=p_materiality_assessment_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_MATERIALITY_ASSESSMENT','error',
            'MaterialityAssessment does not exist';
        RETURN;
    END IF;

    IF ma.outcome='material_change_confirmed'
       AND NOT EXISTS (
            SELECT 1 FROM maintenance.materiality_dimension md
             WHERE md.materiality_assessment_uuid=ma.materiality_assessment_uuid
               AND md.dimension_status='confirmed'
       ) THEN
        RETURN QUERY SELECT
            'MISSING_CONFIRMED_DIMENSION','error',
            'Confirmed material change requires confirmed dimension';
    END IF;

    IF ma.outcome='validity_or_use_threat'
       AND NOT EXISTS (
            SELECT 1 FROM maintenance.materiality_dimension md
             WHERE md.materiality_assessment_uuid=ma.materiality_assessment_uuid
               AND md.dimension_status='threat'
       ) THEN
        RETURN QUERY SELECT
            'MISSING_THREAT_DIMENSION','error',
            'Validity/use threat requires threat dimension';
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.update_decision_issues(
    p_update_decision_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    d maintenance.update_decision%ROWTYPE;
    ma_status text;
BEGIN
    SELECT * INTO d
      FROM maintenance.update_decision
     WHERE update_decision_uuid=p_update_decision_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_UPDATE_DECISION','error','UpdateDecision does not exist';
        RETURN;
    END IF;

    SELECT ma.record_status INTO ma_status
      FROM maintenance.materiality_assessment ma
     WHERE ma.materiality_assessment_uuid=d.materiality_assessment_uuid;

    IF d.record_status='active' AND ma_status IS DISTINCT FROM 'active' THEN
        RETURN QUERY SELECT
            'ACTIVE_DECISION_ASSESSMENT_SUPERSEDED','warning',
            'Active UpdateDecision references superseded MaterialityAssessment';
    END IF;
END;
$fn$;

COMMIT;
