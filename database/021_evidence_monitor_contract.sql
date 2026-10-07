-- OES-DBM-2026-0021
-- Fase 3 — Evidence Monitor contract v0.1
-- Depends on: baseline + migrations 002–020
-- Date: 2026-10-06
-- Product/process maintenance layer; no Alert implementation.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

-- ---------------------------------------------------------------------------
-- MONITOR DEFINITION
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.monitor_definition (
    monitor_product_version_uuid uuid PRIMARY KEY
        REFERENCES product.product_version(version_uuid),
    surveillance_scope_payload jsonb NOT NULL,
    source_policy_payload jsonb NOT NULL,
    strategy_policy_payload jsonb NOT NULL,
    cadence_policy_payload jsonb NOT NULL,
    impact_policy_payload jsonb NOT NULL,
    escalation_policy_payload jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (jsonb_typeof(surveillance_scope_payload)='object'),
    CHECK (jsonb_typeof(source_policy_payload)='object'),
    CHECK (jsonb_typeof(strategy_policy_payload)='object'),
    CHECK (jsonb_typeof(cadence_policy_payload)='object'),
    CHECK (jsonb_typeof(impact_policy_payload)='object'),
    CHECK (jsonb_typeof(escalation_policy_payload)='object')
);

CREATE OR REPLACE FUNCTION maintenance.assert_monitor_definition()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    pv product.product_version%ROWTYPE;
    inv_count integer;
    iv investigation.investigation_version%ROWTYPE;
BEGIN
    SELECT * INTO pv
      FROM product.product_version
     WHERE version_uuid=NEW.monitor_product_version_uuid;

    IF NOT FOUND OR pv.product_type<>'evidence_monitor' THEN
        RAISE EXCEPTION
            'MonitorDefinition requires product_type=evidence_monitor';
    END IF;

    SELECT count(*) INTO inv_count
      FROM product.investigation_link
     WHERE product_version_uuid=NEW.monitor_product_version_uuid
       AND role='primary';

    IF inv_count<>1 THEN
        RAISE EXCEPTION
            'Evidence Monitor requires exactly one primary Investigation';
    END IF;

    SELECT iv0.* INTO iv
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv0
        ON iv0.version_uuid=il.investigation_version_uuid
     WHERE il.product_version_uuid=NEW.monitor_product_version_uuid
       AND il.role='primary';

    IF iv.investigation_type<>'evidence_monitoring' THEN
        RAISE EXCEPTION
            'Evidence Monitor primary Investigation must have investigation_type=evidence_monitoring';
    END IF;

    IF iv.maintenance_level NOT IN ('M2','M3') THEN
        RAISE EXCEPTION
            'Evidence Monitor maintenance_level must be M2 or M3';
    END IF;

    IF iv.protocol_artifact_uuid IS NULL
       OR NOT EXISTS (
            SELECT 1
              FROM artifact.artifact a
             WHERE a.artifact_uuid=iv.protocol_artifact_uuid
               AND a.status='active'
       ) THEN
        RAISE EXCEPTION
            'Evidence Monitor requires an active monitoring protocol/plan artifact';
    END IF;

    IF NEW.source_policy_payload ? 'required_source_names'
       AND jsonb_typeof(NEW.source_policy_payload->'required_source_names')<>'array' THEN
        RAISE EXCEPTION 'required_source_names must be a JSON array';
    END IF;

    IF NEW.source_policy_payload ? 'required_source_classes'
       AND jsonb_typeof(NEW.source_policy_payload->'required_source_classes')<>'array' THEN
        RAISE EXCEPTION 'required_source_classes must be a JSON array';
    END IF;

    IF NEW.source_policy_payload ? 'minimum_bibliographic_sources' THEN
        BEGIN
            IF (NEW.source_policy_payload->>'minimum_bibliographic_sources')::integer < 0 THEN
                RAISE EXCEPTION 'minimum_bibliographic_sources cannot be negative';
            END IF;
        EXCEPTION WHEN invalid_text_representation THEN
            RAISE EXCEPTION 'minimum_bibliographic_sources must be an integer';
        END;
    END IF;

    IF iv.evidence_cutoff_date IS DISTINCT FROM pv.evidence_cutoff_date THEN
        RAISE EXCEPTION
            'Monitor Product cutoff must equal Monitor Investigation baseline cutoff';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_monitor_definition_consistency
    ON maintenance.monitor_definition;
CREATE TRIGGER tr_monitor_definition_consistency
BEFORE INSERT ON maintenance.monitor_definition
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_monitor_definition();

CREATE OR REPLACE FUNCTION maintenance.guard_monitor_definition_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION
        'MonitorDefinition is immutable within a ProductVersion; create a new Monitor ProductVersion';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_monitor_definition_immutable
    ON maintenance.monitor_definition;
CREATE TRIGGER tr_monitor_definition_immutable
BEFORE UPDATE OR DELETE ON maintenance.monitor_definition
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_monitor_definition_mutation();

-- ---------------------------------------------------------------------------
-- MONITOR TARGET
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.monitor_target (
    monitor_target_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL UNIQUE
        REFERENCES product.product_version(version_uuid),
    target_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),
    target_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    linked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        num_nonnulls(
            target_product_version_uuid,
            target_investigation_version_uuid
        )=1
    )
);

CREATE OR REPLACE FUNCTION maintenance.monitor_primary_investigation(
    p_monitor_product_version_uuid uuid
)
RETURNS uuid
LANGUAGE sql
STABLE
AS $q$
    SELECT CASE
        WHEN count(*)=1 THEN (array_agg(il.investigation_version_uuid))[1]
        ELSE NULL
    END
      FROM product.investigation_link il
     WHERE il.product_version_uuid=p_monitor_product_version_uuid
       AND il.role='primary';
$q$;

CREATE OR REPLACE FUNCTION maintenance.assert_monitor_target_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    monitor_pv product.product_version%ROWTYPE;
    monitor_iv investigation.investigation_version%ROWTYPE;
    monitor_inv_count integer;
    target_pv product.product_version%ROWTYPE;
    target_iv investigation.investigation_version%ROWTYPE;
    target_inv_count integer;
    target_ev_status text;
    target_cutoff date;
    target_depth text;
    target_question uuid;
BEGIN
    SELECT * INTO monitor_pv
      FROM product.product_version
     WHERE version_uuid=NEW.monitor_product_version_uuid;

    IF NOT FOUND OR monitor_pv.product_type<>'evidence_monitor' THEN
        RAISE EXCEPTION
            'MonitorTarget requires an evidence_monitor ProductVersion';
    END IF;

    SELECT count(*) INTO monitor_inv_count
      FROM product.investigation_link
     WHERE product_version_uuid=NEW.monitor_product_version_uuid
       AND role='primary';

    IF monitor_inv_count<>1 THEN
        RAISE EXCEPTION
            'Evidence Monitor requires exactly one primary Investigation';
    END IF;

    SELECT iv.* INTO monitor_iv
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
     WHERE il.product_version_uuid=NEW.monitor_product_version_uuid
       AND il.role='primary';

    IF NEW.target_product_version_uuid IS NOT NULL THEN
        IF NEW.target_product_version_uuid=NEW.monitor_product_version_uuid THEN
            RAISE EXCEPTION 'Evidence Monitor cannot target itself';
        END IF;

        SELECT * INTO target_pv
          FROM product.product_version
         WHERE version_uuid=NEW.target_product_version_uuid;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Target ProductVersion does not exist';
        END IF;

        IF target_pv.product_type='evidence_monitor' THEN
            RAISE EXCEPTION
                'Evidence Monitor cannot target another evidence_monitor in v0.1';
        END IF;

        SELECT ev.version_status INTO target_ev_status
          FROM core.entity_version ev
         WHERE ev.version_uuid=NEW.target_product_version_uuid;

        IF target_ev_status IN ('invalidated','archived') THEN
            RAISE EXCEPTION
                'Target ProductVersion cannot be invalidated or archived at linkage';
        END IF;

        SELECT count(*) INTO target_inv_count
          FROM product.investigation_link
         WHERE product_version_uuid=NEW.target_product_version_uuid
           AND role='primary';

        IF target_inv_count<>1 THEN
            RAISE EXCEPTION
                'Target ProductVersion requires exactly one primary Investigation for monitoring v0.1';
        END IF;

        SELECT iv.* INTO target_iv
          FROM product.investigation_link il
          JOIN investigation.investigation_version iv
            ON iv.version_uuid=il.investigation_version_uuid
         WHERE il.product_version_uuid=NEW.target_product_version_uuid
           AND il.role='primary';

        target_cutoff:=target_pv.evidence_cutoff_date;
        target_depth:=target_iv.depth_level;
        target_question:=target_iv.primary_question_entity_uuid;
    ELSE
        SELECT iv.* INTO target_iv
          FROM investigation.investigation_version iv
         WHERE iv.version_uuid=NEW.target_investigation_version_uuid;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Target InvestigationVersion does not exist';
        END IF;

        IF target_iv.version_uuid=monitor_iv.version_uuid THEN
            RAISE EXCEPTION
                'Monitor Investigation cannot target itself';
        END IF;

        SELECT ev.version_status INTO target_ev_status
          FROM core.entity_version ev
         WHERE ev.version_uuid=NEW.target_investigation_version_uuid;

        IF target_ev_status IN ('invalidated','archived') THEN
            RAISE EXCEPTION
                'Target InvestigationVersion cannot be invalidated or archived at linkage';
        END IF;

        target_cutoff:=target_iv.evidence_cutoff_date;
        target_depth:=target_iv.depth_level;
        target_question:=target_iv.primary_question_entity_uuid;
    END IF;

    IF monitor_iv.investigation_type<>'evidence_monitoring'
       OR monitor_iv.maintenance_level NOT IN ('M2','M3') THEN
        RAISE EXCEPTION
            'Monitor primary Investigation type/maintenance level is invalid';
    END IF;

    IF monitor_iv.depth_level<>target_depth THEN
        RAISE EXCEPTION
            'Monitor depth % must inherit target depth %',
            monitor_iv.depth_level,target_depth;
    END IF;

    IF monitor_iv.primary_question_entity_uuid<>target_question THEN
        RAISE EXCEPTION
            'Monitor primary Question must match target primary Question';
    END IF;

    IF monitor_pv.evidence_cutoff_date IS DISTINCT FROM target_cutoff
       OR monitor_iv.evidence_cutoff_date IS DISTINCT FROM target_cutoff THEN
        RAISE EXCEPTION
            'Monitor baseline cutoff must equal target cutoff';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_monitor_target_consistency
    ON maintenance.monitor_target;
CREATE TRIGGER tr_monitor_target_consistency
BEFORE INSERT ON maintenance.monitor_target
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_monitor_target_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_monitor_target_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION
        'MonitorTarget is immutable within a Monitor ProductVersion';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_monitor_target_immutable
    ON maintenance.monitor_target;
CREATE TRIGGER tr_monitor_target_immutable
BEFORE UPDATE OR DELETE ON maintenance.monitor_target
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_monitor_target_mutation();

-- ---------------------------------------------------------------------------
-- MONITOR OPERATIONAL STATE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.monitor_state (
    monitor_state_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    operational_status text NOT NULL CHECK (
        operational_status IN (
            'planned','active','paused','closed','archived'
        )
    ),
    effective_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rationale text NOT NULL CHECK (length(btrim(rationale))>0),
    changed_by text NOT NULL CHECK (length(btrim(changed_by))>0),
    actor_type text NOT NULL CHECK (
        actor_type IN (
            'system','ai_system','human_reviewer','human_expert','owner'
        )
    ),
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_monitor_state_uuid uuid,
    UNIQUE (monitor_state_uuid,monitor_product_version_uuid),
    FOREIGN KEY (
        supersedes_monitor_state_uuid,
        monitor_product_version_uuid
    ) REFERENCES maintenance.monitor_state(
        monitor_state_uuid,
        monitor_product_version_uuid
    ),
    CHECK (
        supersedes_monitor_state_uuid IS NULL
        OR supersedes_monitor_state_uuid<>monitor_state_uuid
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_monitor_state_active
    ON maintenance.monitor_state(monitor_product_version_uuid)
    WHERE record_status='active';

CREATE OR REPLACE FUNCTION maintenance.assert_monitor_state_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    product_type_value text;
    prior maintenance.monitor_state%ROWTYPE;
BEGIN
    SELECT pv.product_type INTO product_type_value
      FROM product.product_version pv
     WHERE pv.version_uuid=NEW.monitor_product_version_uuid;

    IF product_type_value IS DISTINCT FROM 'evidence_monitor' THEN
        RAISE EXCEPTION 'MonitorState requires an evidence_monitor ProductVersion';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_definition md
         WHERE md.monitor_product_version_uuid=NEW.monitor_product_version_uuid
    ) OR NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_target mt
         WHERE mt.monitor_product_version_uuid=NEW.monitor_product_version_uuid
    ) THEN
        RAISE EXCEPTION 'MonitorState requires MonitorDefinition and MonitorTarget';
    END IF;

    IF NEW.supersedes_monitor_state_uuid IS NOT NULL THEN
        SELECT * INTO prior
          FROM maintenance.monitor_state ms
         WHERE ms.monitor_state_uuid=NEW.supersedes_monitor_state_uuid;

        IF NOT FOUND
           OR prior.monitor_product_version_uuid<>NEW.monitor_product_version_uuid
           OR NEW.effective_at<prior.effective_at THEN
            RAISE EXCEPTION
                'MonitorState supersession must preserve Monitor and temporal order';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_monitor_state_consistency
    ON maintenance.monitor_state;
CREATE TRIGGER tr_monitor_state_consistency
BEFORE INSERT ON maintenance.monitor_state
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_monitor_state_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_monitor_state_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION
            'MonitorState is append-preserving and cannot be deleted';
    END IF;

    IF OLD.record_status='active'
       AND NEW.record_status='superseded'
       AND NEW.monitor_state_uuid=OLD.monitor_state_uuid
       AND NEW.monitor_product_version_uuid=OLD.monitor_product_version_uuid
       AND NEW.operational_status=OLD.operational_status
       AND NEW.effective_at=OLD.effective_at
       AND NEW.rationale=OLD.rationale
       AND NEW.changed_by=OLD.changed_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.supersedes_monitor_state_uuid
           IS NOT DISTINCT FROM OLD.supersedes_monitor_state_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION
        'MonitorState material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_monitor_state_append_preserving
    ON maintenance.monitor_state;
CREATE TRIGGER tr_monitor_state_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.monitor_state
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_monitor_state_mutation();

-- ---------------------------------------------------------------------------
-- MONITOR CYCLE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.monitor_cycle (
    cycle_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    cycle_no integer NOT NULL CHECK (cycle_no>0),
    previous_cycle_uuid uuid
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    window_start_date date NOT NULL,
    window_end_date date NOT NULL,
    planned_at timestamptz,
    started_at timestamptz,
    completed_at timestamptz,
    execution_status text NOT NULL CHECK (
        execution_status IN (
            'planned','running','completed','incomplete','cancelled'
        )
    ),
    completeness_status text NOT NULL CHECK (
        completeness_status IN (
            'not_assessed','complete','partial','failed'
        )
    ),
    maintenance_decision text CHECK (
        maintenance_decision IN (
            'no_update_needed',
            'evaluate_update',
            'update_recommended',
            'outdated'
        )
    ),
    decision_rationale text,
    escalation_recommendation text NOT NULL DEFAULT 'none' CHECK (
        escalation_recommendation IN (
            'none','evaluate_alert','urgent_reassessment'
        )
    ),
    decided_by text,
    actor_type text CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verification_status text NOT NULL DEFAULT 'unverified' CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    execution_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (monitor_product_version_uuid,cycle_no),
    CHECK (window_end_date>=window_start_date),
    CHECK (
        previous_cycle_uuid IS NULL
        OR previous_cycle_uuid<>cycle_uuid
    )
);

CREATE INDEX IF NOT EXISTS ix_monitor_cycle_product
    ON maintenance.monitor_cycle(
        monitor_product_version_uuid,cycle_no
    );

CREATE OR REPLACE FUNCTION maintenance.assert_monitor_cycle_lifecycle()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    prev_monitor uuid;
    prev_no integer;
    active_operational_status text;
    product_type_value text;
BEGIN
    SELECT pv.product_type INTO product_type_value
      FROM product.product_version pv
     WHERE pv.version_uuid=NEW.monitor_product_version_uuid;

    IF product_type_value IS DISTINCT FROM 'evidence_monitor'
       OR NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_definition md
             WHERE md.monitor_product_version_uuid=NEW.monitor_product_version_uuid
       )
       OR NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_target mt
             WHERE mt.monitor_product_version_uuid=NEW.monitor_product_version_uuid
       ) THEN
        RAISE EXCEPTION
            'MonitorCycle requires a configured evidence_monitor ProductVersion';
    END IF;

    IF NEW.started_at IS NOT NULL
       AND NEW.planned_at IS NOT NULL
       AND NEW.started_at<NEW.planned_at THEN
        RAISE EXCEPTION 'MonitorCycle started_at cannot precede planned_at';
    END IF;

    IF NEW.completed_at IS NOT NULL
       AND NEW.started_at IS NOT NULL
       AND NEW.completed_at<NEW.started_at THEN
        RAISE EXCEPTION 'MonitorCycle completed_at cannot precede started_at';
    END IF;
    IF NEW.previous_cycle_uuid IS NOT NULL THEN
        SELECT monitor_product_version_uuid,cycle_no
          INTO prev_monitor,prev_no
          FROM maintenance.monitor_cycle
         WHERE cycle_uuid=NEW.previous_cycle_uuid;

        IF prev_monitor IS NULL
           OR prev_monitor<>NEW.monitor_product_version_uuid
           OR prev_no>=NEW.cycle_no THEN
            RAISE EXCEPTION
                'previous_cycle_uuid must reference an earlier cycle of the same Monitor';
        END IF;
    END IF;

    IF NEW.execution_status='running' AND NEW.started_at IS NULL THEN
        RAISE EXCEPTION 'running cycle requires started_at';
    END IF;

    IF NEW.execution_status IN ('completed','incomplete')
       AND NEW.started_at IS NULL THEN
        RAISE EXCEPTION 'completed/incomplete cycle requires started_at';
    END IF;

    IF NEW.execution_status IN ('completed','incomplete','cancelled')
       AND NEW.completed_at IS NULL THEN
        RAISE EXCEPTION 'terminal cycle requires completed_at';
    END IF;

    IF NEW.execution_status='completed' THEN
        IF NEW.completeness_status<>'complete' THEN
            RAISE EXCEPTION
                'completed cycle requires completeness_status=complete';
        END IF;
        IF NEW.maintenance_decision IS NULL
           OR btrim(COALESCE(NEW.decision_rationale,''))=''
           OR btrim(COALESCE(NEW.decided_by,''))=''
           OR NEW.actor_type IS NULL THEN
            RAISE EXCEPTION
                'completed cycle requires decision, rationale and decision actor';
        END IF;
    END IF;

    IF NEW.maintenance_decision='no_update_needed'
       AND NEW.execution_status<>'completed' THEN
        RAISE EXCEPTION
            'no_update_needed requires a completed cycle';
    END IF;

    IF NEW.execution_status IN ('incomplete','cancelled')
       AND NEW.maintenance_decision='no_update_needed' THEN
        RAISE EXCEPTION
            'incomplete/cancelled cycle cannot assert no_update_needed';
    END IF;

    IF NEW.execution_status='completed' THEN
        IF NOT maintenance.monitor_cycle_source_coverage(NEW.cycle_uuid) THEN
            RAISE EXCEPTION
                'completed cycle does not satisfy declared source coverage';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM maintenance.candidate_assessment ca
             WHERE ca.cycle_uuid=NEW.cycle_uuid
               AND ca.record_status='active'
               AND ca.decision='pending'
        ) THEN
            RAISE EXCEPTION
                'completed cycle cannot retain pending CandidateAssessment';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM maintenance.evidence_event ee
             WHERE ee.cycle_uuid=NEW.cycle_uuid
               AND ee.status='active'
               AND NOT EXISTS (
                    SELECT 1
                      FROM maintenance.candidate_assessment ca
                     WHERE ca.cycle_uuid=NEW.cycle_uuid
                       AND ca.record_status='active'
                       AND ca.origin_type='evidence_event'
                       AND ca.origin_evidence_event_uuid=ee.evidence_event_uuid
               )
        ) THEN
            RAISE EXCEPTION
                'completed cycle cannot contain unassessed active EvidenceEvent';
        END IF;
    END IF;

    IF NEW.verification_status='unverified' THEN
        IF NEW.verified_by IS NOT NULL
           OR NEW.verifier_actor_type IS NOT NULL
           OR NEW.verified_at IS NOT NULL THEN
            RAISE EXCEPTION
                'unverified cycle cannot contain verifier metadata';
        END IF;
    ELSIF NEW.verification_status='ai_verified' THEN
        IF NEW.verifier_actor_type<>'ai_system'
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'ai_verified cycle requires AI verifier metadata';
        END IF;
    ELSIF NEW.verification_status IN ('human_verified','human_consensus') THEN
        IF NEW.verifier_actor_type NOT IN ('human_reviewer','human_expert')
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'human verified cycle requires human verifier metadata';
        END IF;
    END IF;

    IF NEW.execution_status='running' THEN
        SELECT ms.operational_status
          INTO active_operational_status
          FROM maintenance.monitor_state ms
         WHERE ms.monitor_product_version_uuid=NEW.monitor_product_version_uuid
           AND ms.record_status='active';

        IF active_operational_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION
                'Only operationally active Monitor can start a running cycle';
        END IF;
    END IF;

    IF TG_OP='UPDATE' THEN
        IF OLD.execution_status IN ('completed','incomplete','cancelled') THEN
            RAISE EXCEPTION
                'Terminal MonitorCycle is immutable';
        END IF;

        IF OLD.execution_status='planned'
           AND NEW.execution_status NOT IN (
               'planned','running','completed','incomplete','cancelled'
           ) THEN
            RAISE EXCEPTION 'Invalid cycle transition';
        END IF;

        IF OLD.execution_status='running'
           AND NEW.execution_status NOT IN (
               'running','completed','incomplete','cancelled'
           ) THEN
            RAISE EXCEPTION 'Invalid cycle transition';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_monitor_cycle_lifecycle
    ON maintenance.monitor_cycle;
CREATE TRIGGER tr_monitor_cycle_lifecycle
BEFORE INSERT OR UPDATE ON maintenance.monitor_cycle
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_monitor_cycle_lifecycle();

CREATE OR REPLACE FUNCTION maintenance.guard_monitor_cycle_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION 'MonitorCycle cannot be deleted';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_monitor_cycle_no_delete
    ON maintenance.monitor_cycle;
CREATE TRIGGER tr_monitor_cycle_no_delete
BEFORE DELETE ON maintenance.monitor_cycle
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_monitor_cycle_delete();

-- ---------------------------------------------------------------------------
-- CYCLE ↔ SEARCH
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.cycle_search (
    cycle_uuid uuid NOT NULL
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    search_uuid uuid NOT NULL UNIQUE
        REFERENCES investigation.search(search_uuid),
    search_role text NOT NULL CHECK (
        search_role IN (
            'primary','supplementary','registry','citation_chaining','other'
        )
    ),
    sequence_no integer,
    PRIMARY KEY (cycle_uuid,search_uuid)
);

CREATE OR REPLACE FUNCTION maintenance.assert_cycle_search_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    monitor_product uuid;
    monitor_inv uuid;
    search_inv uuid;
BEGIN
    SELECT mc.monitor_product_version_uuid
      INTO monitor_product
      FROM maintenance.monitor_cycle mc
     WHERE mc.cycle_uuid=NEW.cycle_uuid
       AND mc.execution_status IN ('planned','running');

    IF monitor_product IS NULL THEN
        RAISE EXCEPTION
            'Search can be linked only while MonitorCycle is open';
    END IF;

    monitor_inv:=maintenance.monitor_primary_investigation(monitor_product);

    SELECT s.investigation_version_uuid
      INTO search_inv
      FROM investigation.search s
     WHERE s.search_uuid=NEW.search_uuid;

    IF monitor_inv IS NULL OR search_inv IS NULL OR monitor_inv<>search_inv THEN
        RAISE EXCEPTION
            'Cycle Search must belong to the Monitor primary Investigation';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_cycle_search_consistency
    ON maintenance.cycle_search;
CREATE TRIGGER tr_cycle_search_consistency
BEFORE INSERT OR UPDATE ON maintenance.cycle_search
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_cycle_search_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_cycle_search_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    cycle_status text;
BEGIN
    SELECT mc.execution_status INTO cycle_status
      FROM maintenance.monitor_cycle mc
     WHERE mc.cycle_uuid=OLD.cycle_uuid;

    IF cycle_status IN ('completed','incomplete','cancelled') THEN
        RAISE EXCEPTION
            'CycleSearch cannot be deleted after MonitorCycle is terminal';
    END IF;

    RETURN OLD;
END;
$guard$;

DROP TRIGGER IF EXISTS tr_cycle_search_no_terminal_delete
    ON maintenance.cycle_search;
CREATE TRIGGER tr_cycle_search_no_terminal_delete
BEFORE DELETE ON maintenance.cycle_search
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_cycle_search_delete();

-- ---------------------------------------------------------------------------
-- EVIDENCE / VALIDITY EVENTS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.evidence_event (
    evidence_event_uuid uuid PRIMARY KEY,
    cycle_uuid uuid NOT NULL
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    event_type text NOT NULL CHECK (
        event_type IN (
            'correction',
            'retraction',
            'expression_of_concern',
            'report_update',
            'dataset_invalidation',
            'regulatory_update',
            'guidance_update',
            'source_withdrawal',
            'other_validity_event'
        )
    ),
    event_date date,
    detected_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    report_relation_uuid uuid
        REFERENCES evidence.report_relation(relation_uuid),
    affected_version_uuid uuid
        REFERENCES core.entity_version(version_uuid),
    source_artifact_uuid uuid
        REFERENCES artifact.artifact(artifact_uuid),
    source_uri text,
    description text NOT NULL CHECK (length(btrim(description))>0),
    event_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    detected_by text NOT NULL CHECK (length(btrim(detected_by))>0),
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
        verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded','invalidated')
    ),
    CHECK (
        num_nonnulls(
            report_relation_uuid,
            source_artifact_uuid,
            source_uri
        )>=1
    ),
    CHECK (
        source_uri IS NULL OR length(btrim(source_uri))>0
    )
);

CREATE INDEX IF NOT EXISTS ix_evidence_event_cycle
    ON maintenance.evidence_event(cycle_uuid,status);

CREATE OR REPLACE FUNCTION maintenance.assert_evidence_event_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    rr_type text;
    cycle_status text;
BEGIN
    IF TG_OP='INSERT' THEN
        SELECT mc.execution_status INTO cycle_status
          FROM maintenance.monitor_cycle mc
         WHERE mc.cycle_uuid=NEW.cycle_uuid;

        IF cycle_status NOT IN ('planned','running') THEN
            RAISE EXCEPTION
                'EvidenceEvent can be added only while MonitorCycle is open';
        END IF;
    END IF;

    IF NEW.verification_status='unverified' THEN
        IF NEW.verified_by IS NOT NULL
           OR NEW.verifier_actor_type IS NOT NULL
           OR NEW.verified_at IS NOT NULL THEN
            RAISE EXCEPTION
                'unverified EvidenceEvent cannot contain verifier metadata';
        END IF;
    ELSIF NEW.verification_status='ai_verified' THEN
        IF NEW.verifier_actor_type<>'ai_system'
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'ai_verified EvidenceEvent requires AI verifier metadata';
        END IF;
    ELSIF NEW.verification_status IN ('human_verified','human_consensus') THEN
        IF NEW.verifier_actor_type NOT IN ('human_reviewer','human_expert')
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'human verified EvidenceEvent requires human verifier metadata';
        END IF;
    END IF;

    IF NEW.report_relation_uuid IS NOT NULL THEN
        SELECT relation_type INTO rr_type
          FROM evidence.report_relation
         WHERE relation_uuid=NEW.report_relation_uuid;

        IF NEW.event_type='correction' AND rr_type<>'correction_of' THEN
            RAISE EXCEPTION 'Correction event requires correction_of ReportRelation';
        ELSIF NEW.event_type='retraction' AND rr_type<>'retraction_of' THEN
            RAISE EXCEPTION 'Retraction event requires retraction_of ReportRelation';
        ELSIF NEW.event_type='expression_of_concern'
              AND rr_type<>'expression_of_concern_for' THEN
            RAISE EXCEPTION
                'Expression-of-concern event requires matching ReportRelation';
        ELSIF NEW.event_type='report_update' AND rr_type<>'update_of' THEN
            RAISE EXCEPTION 'Report update event requires update_of ReportRelation';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_evidence_event_consistency
    ON maintenance.evidence_event;
CREATE TRIGGER tr_evidence_event_consistency
BEFORE INSERT ON maintenance.evidence_event
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_evidence_event_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_evidence_event_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION
            'EvidenceEvent is append-preserving and cannot be deleted';
    END IF;

    IF OLD.status='active'
       AND NEW.status IN ('superseded','invalidated')
       AND NEW.evidence_event_uuid=OLD.evidence_event_uuid
       AND NEW.cycle_uuid=OLD.cycle_uuid
       AND NEW.event_type=OLD.event_type
       AND NEW.event_date IS NOT DISTINCT FROM OLD.event_date
       AND NEW.detected_at=OLD.detected_at
       AND NEW.report_relation_uuid IS NOT DISTINCT FROM OLD.report_relation_uuid
       AND NEW.affected_version_uuid IS NOT DISTINCT FROM OLD.affected_version_uuid
       AND NEW.source_artifact_uuid IS NOT DISTINCT FROM OLD.source_artifact_uuid
       AND NEW.source_uri IS NOT DISTINCT FROM OLD.source_uri
       AND NEW.description=OLD.description
       AND NEW.event_payload=OLD.event_payload
       AND NEW.detected_by=OLD.detected_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.verification_status=OLD.verification_status
       AND NEW.verified_by IS NOT DISTINCT FROM OLD.verified_by
       AND NEW.verifier_actor_type IS NOT DISTINCT FROM OLD.verifier_actor_type
       AND NEW.verified_at IS NOT DISTINCT FROM OLD.verified_at
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION
        'EvidenceEvent material fields are immutable; only status supersession/invalidation is allowed';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_evidence_event_append_preserving
    ON maintenance.evidence_event;
CREATE TRIGGER tr_evidence_event_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.evidence_event
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_evidence_event_mutation();

-- ---------------------------------------------------------------------------
-- CANDIDATE ASSESSMENT
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.candidate_assessment (
    candidate_assessment_uuid uuid PRIMARY KEY,
    cycle_uuid uuid NOT NULL
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    origin_type text NOT NULL CHECK (
        origin_type IN ('search_hit','entity','evidence_event')
    ),
    origin_search_hit_uuid uuid
        REFERENCES investigation.search_hit(search_hit_uuid),
    origin_entity_uuid uuid
        REFERENCES core.entity(entity_uuid),
    origin_evidence_event_uuid uuid
        REFERENCES maintenance.evidence_event(evidence_event_uuid),
    resolved_target_entity_uuid uuid
        REFERENCES core.entity(entity_uuid),
    candidate_kind text NOT NULL CHECK (
        candidate_kind IN (
            'new_report','new_study','review_update',
            'validity_event','regulatory_signal',
            'scope_change_signal','other'
        )
    ),
    decision text NOT NULL CHECK (
        decision IN ('pending','excluded','retained_for_impact')
    ),
    exclusion_reason text,
    impact_class text CHECK (
        impact_class IN (
            'none','quantitative','certainty','applicability',
            'conclusion','validity','scope'
        )
    ),
    impact_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
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
        verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    assessed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_candidate_assessment_uuid uuid
        REFERENCES maintenance.candidate_assessment(candidate_assessment_uuid),
    CHECK (
        (origin_type='search_hit'
         AND origin_search_hit_uuid IS NOT NULL
         AND origin_entity_uuid IS NULL
         AND origin_evidence_event_uuid IS NULL)
        OR
        (origin_type='entity'
         AND origin_search_hit_uuid IS NULL
         AND origin_entity_uuid IS NOT NULL
         AND origin_evidence_event_uuid IS NULL)
        OR
        (origin_type='evidence_event'
         AND origin_search_hit_uuid IS NULL
         AND origin_entity_uuid IS NULL
         AND origin_evidence_event_uuid IS NOT NULL)
    ),
    CHECK (
        decision<>'excluded'
        OR length(btrim(COALESCE(exclusion_reason,'')))>0
    ),
    CHECK (
        decision<>'retained_for_impact'
        OR (
            impact_class IS NOT NULL
            AND impact_class<>'none'
        )
    ),
    CHECK (
        supersedes_candidate_assessment_uuid IS NULL
        OR supersedes_candidate_assessment_uuid<>candidate_assessment_uuid
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_candidate_active_search_hit
    ON maintenance.candidate_assessment(cycle_uuid,origin_search_hit_uuid)
    WHERE record_status='active' AND origin_search_hit_uuid IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_candidate_active_entity
    ON maintenance.candidate_assessment(cycle_uuid,origin_entity_uuid)
    WHERE record_status='active' AND origin_entity_uuid IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_candidate_active_event
    ON maintenance.candidate_assessment(cycle_uuid,origin_evidence_event_uuid)
    WHERE record_status='active' AND origin_evidence_event_uuid IS NOT NULL;

CREATE OR REPLACE FUNCTION maintenance.assert_candidate_assessment_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    source_cycle uuid;
    actual_type text;
    prior maintenance.candidate_assessment%ROWTYPE;
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle mc
         WHERE mc.cycle_uuid=NEW.cycle_uuid
           AND mc.execution_status IN ('planned','running')
    ) THEN
        RAISE EXCEPTION
            'CandidateAssessment can be added only while MonitorCycle is open';
    END IF;

    IF NEW.origin_type='search_hit' THEN
        SELECT cs.cycle_uuid INTO source_cycle
          FROM investigation.search_hit sh
          JOIN maintenance.cycle_search cs
            ON cs.search_uuid=sh.search_uuid
         WHERE sh.search_hit_uuid=NEW.origin_search_hit_uuid;

        IF source_cycle IS NULL OR source_cycle<>NEW.cycle_uuid THEN
            RAISE EXCEPTION
                'SearchHit candidate must originate from Search linked to the same cycle';
        END IF;
    ELSIF NEW.origin_type='evidence_event' THEN
        SELECT ee.cycle_uuid INTO source_cycle
          FROM maintenance.evidence_event ee
         WHERE ee.evidence_event_uuid=NEW.origin_evidence_event_uuid;

        IF source_cycle IS NULL OR source_cycle<>NEW.cycle_uuid THEN
            RAISE EXCEPTION
                'EvidenceEvent candidate must belong to the same cycle';
        END IF;
    ELSIF NEW.origin_type='entity' THEN
        SELECT e.entity_type INTO actual_type
          FROM core.entity e
         WHERE e.entity_uuid=NEW.origin_entity_uuid;

        IF actual_type NOT IN ('Report','Study') THEN
            RAISE EXCEPTION
                'Direct candidate entity must be Report or Study';
        END IF;
    END IF;

    IF NEW.resolved_target_entity_uuid IS NOT NULL THEN
        SELECT e.entity_type INTO actual_type
          FROM core.entity e
         WHERE e.entity_uuid=NEW.resolved_target_entity_uuid;

        IF actual_type NOT IN ('Report','Study') THEN
            RAISE EXCEPTION
                'Resolved candidate target must be Report or Study';
        END IF;
    END IF;

    IF NEW.verification_status='unverified' THEN
        IF NEW.verified_by IS NOT NULL
           OR NEW.verifier_actor_type IS NOT NULL
           OR NEW.verified_at IS NOT NULL THEN
            RAISE EXCEPTION
                'unverified CandidateAssessment cannot contain verifier metadata';
        END IF;
    ELSIF NEW.verification_status='ai_verified' THEN
        IF NEW.verifier_actor_type<>'ai_system'
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'ai_verified CandidateAssessment requires AI verifier metadata';
        END IF;
    ELSIF NEW.verification_status IN ('human_verified','human_consensus') THEN
        IF NEW.verifier_actor_type NOT IN ('human_reviewer','human_expert')
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'human verified CandidateAssessment requires human verifier metadata';
        END IF;
    END IF;

    IF NEW.supersedes_candidate_assessment_uuid IS NOT NULL THEN
        SELECT * INTO prior
          FROM maintenance.candidate_assessment
         WHERE candidate_assessment_uuid=
               NEW.supersedes_candidate_assessment_uuid;

        IF NOT FOUND
           OR prior.cycle_uuid<>NEW.cycle_uuid
           OR prior.origin_type<>NEW.origin_type
           OR prior.origin_search_hit_uuid
                IS DISTINCT FROM NEW.origin_search_hit_uuid
           OR prior.origin_entity_uuid
                IS DISTINCT FROM NEW.origin_entity_uuid
           OR prior.origin_evidence_event_uuid
                IS DISTINCT FROM NEW.origin_evidence_event_uuid THEN
            RAISE EXCEPTION
                'CandidateAssessment supersession must preserve cycle and logical origin';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_candidate_assessment_consistency
    ON maintenance.candidate_assessment;
CREATE TRIGGER tr_candidate_assessment_consistency
BEFORE INSERT ON maintenance.candidate_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_candidate_assessment_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_candidate_assessment_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION
            'CandidateAssessment is append-preserving and cannot be deleted';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle mc
         WHERE mc.cycle_uuid=OLD.cycle_uuid
           AND mc.execution_status IN ('planned','running')
    ) THEN
        RAISE EXCEPTION
            'CandidateAssessment cannot be superseded after MonitorCycle is terminal';
    END IF;

    IF OLD.record_status='active'
       AND NEW.record_status='superseded'
       AND NEW.candidate_assessment_uuid=OLD.candidate_assessment_uuid
       AND NEW.cycle_uuid=OLD.cycle_uuid
       AND NEW.origin_type=OLD.origin_type
       AND NEW.origin_search_hit_uuid
           IS NOT DISTINCT FROM OLD.origin_search_hit_uuid
       AND NEW.origin_entity_uuid
           IS NOT DISTINCT FROM OLD.origin_entity_uuid
       AND NEW.origin_evidence_event_uuid
           IS NOT DISTINCT FROM OLD.origin_evidence_event_uuid
       AND NEW.resolved_target_entity_uuid
           IS NOT DISTINCT FROM OLD.resolved_target_entity_uuid
       AND NEW.candidate_kind=OLD.candidate_kind
       AND NEW.decision=OLD.decision
       AND NEW.exclusion_reason IS NOT DISTINCT FROM OLD.exclusion_reason
       AND NEW.impact_class IS NOT DISTINCT FROM OLD.impact_class
       AND NEW.impact_payload=OLD.impact_payload
       AND NEW.assessed_by=OLD.assessed_by
       AND NEW.actor_type=OLD.actor_type
       AND NEW.verification_status=OLD.verification_status
       AND NEW.verified_by IS NOT DISTINCT FROM OLD.verified_by
       AND NEW.verifier_actor_type
           IS NOT DISTINCT FROM OLD.verifier_actor_type
       AND NEW.verified_at IS NOT DISTINCT FROM OLD.verified_at
       AND NEW.assessed_at=OLD.assessed_at
       AND NEW.supersedes_candidate_assessment_uuid
           IS NOT DISTINCT FROM OLD.supersedes_candidate_assessment_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION
        'CandidateAssessment material fields are immutable; supersede and append';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_candidate_assessment_append_preserving
    ON maintenance.candidate_assessment;
CREATE TRIGGER tr_candidate_assessment_append_preserving
BEFORE UPDATE OR DELETE ON maintenance.candidate_assessment
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_candidate_assessment_mutation();

-- ---------------------------------------------------------------------------
-- CYCLE ↔ TARGET CURRENCY STATE
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.cycle_currency_state (
    cycle_uuid uuid PRIMARY KEY
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    currency_state_uuid uuid NOT NULL UNIQUE
        REFERENCES product.currency_state(currency_state_uuid),
    linked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION maintenance.assert_cycle_currency_state_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    c maintenance.monitor_cycle%ROWTYPE;
    t maintenance.monitor_target%ROWTYPE;
    cs product.currency_state%ROWTYPE;
    expected_status text;
BEGIN
    SELECT * INTO c
      FROM maintenance.monitor_cycle
     WHERE cycle_uuid=NEW.cycle_uuid;

    IF NOT FOUND OR c.execution_status<>'completed' THEN
        RAISE EXCEPTION
            'CycleCurrencyState requires a completed cycle';
    END IF;

    SELECT * INTO t
      FROM maintenance.monitor_target
     WHERE monitor_product_version_uuid=c.monitor_product_version_uuid;

    IF NOT FOUND OR t.target_product_version_uuid IS NULL THEN
        RAISE EXCEPTION
            'CycleCurrencyState requires a ProductVersion target';
    END IF;

    SELECT * INTO cs
      FROM product.currency_state
     WHERE currency_state_uuid=NEW.currency_state_uuid;

    IF NOT FOUND
       OR cs.product_version_uuid<>t.target_product_version_uuid
       OR cs.record_status<>'active' THEN
        RAISE EXCEPTION
            'CurrencyState must be the active state of the monitored target ProductVersion';
    END IF;

    expected_status:=CASE c.maintenance_decision
        WHEN 'no_update_needed' THEN 'current'
        WHEN 'evaluate_update' THEN 'under_evaluation'
        WHEN 'update_recommended' THEN 'update_recommended'
        WHEN 'outdated' THEN 'outdated'
        ELSE NULL
    END;

    IF expected_status IS NULL
       OR cs.currency_status<>expected_status THEN
        RAISE EXCEPTION
            'Cycle decision % requires target currency status %, found %',
            c.maintenance_decision,expected_status,cs.currency_status;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_cycle_currency_state_consistency
    ON maintenance.cycle_currency_state;
CREATE TRIGGER tr_cycle_currency_state_consistency
BEFORE INSERT OR UPDATE ON maintenance.cycle_currency_state
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_cycle_currency_state_consistency();

-- ---------------------------------------------------------------------------
-- SOURCE COVERAGE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_cycle_source_coverage(
    p_cycle_uuid uuid
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    monitor_uuid uuid;
    policy jsonb;
    required_name text;
    required_class text;
    minimum_bib integer;
    actual_bib integer;
BEGIN
    SELECT mc.monitor_product_version_uuid
      INTO monitor_uuid
      FROM maintenance.monitor_cycle mc
     WHERE mc.cycle_uuid=p_cycle_uuid;

    IF monitor_uuid IS NULL THEN
        RETURN false;
    END IF;

    SELECT md.source_policy_payload
      INTO policy
      FROM maintenance.monitor_definition md
     WHERE md.monitor_product_version_uuid=monitor_uuid;

    IF policy IS NULL THEN
        RETURN false;
    END IF;

    FOR required_name IN
        SELECT jsonb_array_elements_text(
            COALESCE(policy->'required_source_names','[]'::jsonb)
        )
    LOOP
        IF NOT EXISTS (
            SELECT 1
              FROM maintenance.cycle_search cs
              JOIN investigation.search s
                ON s.search_uuid=cs.search_uuid
             WHERE cs.cycle_uuid=p_cycle_uuid
               AND s.status='completed'
               AND s.source_name=required_name
        ) THEN
            RETURN false;
        END IF;
    END LOOP;

    FOR required_class IN
        SELECT jsonb_array_elements_text(
            COALESCE(policy->'required_source_classes','[]'::jsonb)
        )
    LOOP
        IF NOT EXISTS (
            SELECT 1
              FROM maintenance.cycle_search cs
              JOIN investigation.search s
                ON s.search_uuid=cs.search_uuid
             WHERE cs.cycle_uuid=p_cycle_uuid
               AND s.status='completed'
               AND s.filters_payload->>'source_class'=required_class
        ) THEN
            RETURN false;
        END IF;
    END LOOP;

    IF policy ? 'minimum_bibliographic_sources' THEN
        BEGIN
            minimum_bib:=(policy->>'minimum_bibliographic_sources')::integer;
        EXCEPTION WHEN others THEN
            RETURN false;
        END;

        IF minimum_bib<0 THEN
            RETURN false;
        END IF;

        SELECT count(DISTINCT s.source_name)
          INTO actual_bib
          FROM maintenance.cycle_search cs
          JOIN investigation.search s
            ON s.search_uuid=cs.search_uuid
         WHERE cs.cycle_uuid=p_cycle_uuid
           AND s.status='completed'
           AND s.filters_payload->>'source_class'='bibliographic';

        IF actual_bib<minimum_bib THEN
            RETURN false;
        END IF;
    END IF;

    RETURN true;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- CYCLE ISSUES
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.monitor_cycle_issues(
    p_cycle_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    c maintenance.monitor_cycle%ROWTYPE;
    t maintenance.monitor_target%ROWTYPE;
BEGIN
    SELECT * INTO c
      FROM maintenance.monitor_cycle
     WHERE cycle_uuid=p_cycle_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_CYCLE','error','Monitor cycle does not exist';
        RETURN;
    END IF;

    SELECT * INTO t
      FROM maintenance.monitor_target
     WHERE monitor_product_version_uuid=c.monitor_product_version_uuid;

    IF c.execution_status='completed'
       AND NOT maintenance.monitor_cycle_source_coverage(c.cycle_uuid) THEN
        RETURN QUERY SELECT
            'INCOMPLETE_REQUIRED_SOURCE_COVERAGE','error',
            'Completed cycle does not satisfy its declared source policy';
    END IF;

    IF c.execution_status='completed'
       AND EXISTS (
            SELECT 1
              FROM maintenance.candidate_assessment ca
             WHERE ca.cycle_uuid=c.cycle_uuid
               AND ca.record_status='active'
               AND ca.decision='pending'
       ) THEN
        RETURN QUERY SELECT
            'PENDING_CYCLE_CANDIDATE','error',
            'Completed cycle still has pending candidate assessments';
    END IF;

    IF c.execution_status='completed'
       AND EXISTS (
            SELECT 1
              FROM maintenance.evidence_event ee
             WHERE ee.cycle_uuid=c.cycle_uuid
               AND ee.status='active'
               AND NOT EXISTS (
                    SELECT 1
                      FROM maintenance.candidate_assessment ca
                     WHERE ca.cycle_uuid=c.cycle_uuid
                       AND ca.record_status='active'
                       AND ca.origin_type='evidence_event'
                       AND ca.origin_evidence_event_uuid=ee.evidence_event_uuid
               )
       ) THEN
        RETURN QUERY SELECT
            'UNASSESSED_MATERIAL_EVENT','error',
            'Completed cycle contains active EvidenceEvent without CandidateAssessment';
    END IF;

    IF c.execution_status<>'completed'
       AND c.maintenance_decision='no_update_needed' THEN
        RETURN QUERY SELECT
            'NO_UPDATE_FROM_INCOMPLETE_CYCLE','error',
            'Incomplete cycle cannot assert no update needed';
    END IF;

    IF c.execution_status='completed'
       AND t.target_product_version_uuid IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
              FROM maintenance.cycle_currency_state ccs
             WHERE ccs.cycle_uuid=c.cycle_uuid
       ) THEN
        RETURN QUERY SELECT
            'MISSING_CYCLE_CURRENCY_STATE','error',
            'Completed Product-target cycle requires resulting target CurrencyState';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM maintenance.evidence_event ee
          JOIN maintenance.candidate_assessment ca
            ON ca.origin_evidence_event_uuid=ee.evidence_event_uuid
           AND ca.cycle_uuid=ee.cycle_uuid
           AND ca.record_status='active'
         WHERE ee.cycle_uuid=c.cycle_uuid
           AND ee.status='invalidated'
           AND ca.decision='retained_for_impact'
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_EVENT_RETAINED','error',
            'Invalidated EvidenceEvent remains retained for impact';
    END IF;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- ASSURANCE WRAPPER
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_monitor_assurance_level(
    p_product_version_uuid uuid
)
RETURNS text
LANGUAGE sql
STABLE
AS $q$
    SELECT product.assurance_level(p_product_version_uuid);
$q$;

-- ---------------------------------------------------------------------------
-- PUBLICATION ISSUES / GATE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_monitor_publication_issues(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $gate$
DECLARE
    pv product.product_version%ROWTYPE;
    inv_count integer;
    inv_uuid uuid;
    iv investigation.investigation_version%ROWTYPE;
    t maintenance.monitor_target%ROWTYPE;
    latest_cycle maintenance.monitor_cycle%ROWTYPE;
    target_currency text;
    monitor_state_status text;
BEGIN
    SELECT * INTO pv
      FROM product.product_version
     WHERE version_uuid=p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_PRODUCT_VERSION','error',
            'ProductVersion does not exist';
        RETURN;
    END IF;

    IF pv.product_type<>'evidence_monitor' THEN
        RETURN QUERY SELECT
            'WRONG_PRODUCT_TYPE','error',
            format('Expected evidence_monitor, found %s',pv.product_type);
        RETURN;
    END IF;

    SELECT count(*) INTO inv_count
      FROM product.investigation_link
     WHERE product_version_uuid=p_product_version_uuid
       AND role='primary';

    IF inv_count=0 THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_INVESTIGATION','error',
            'Evidence Monitor requires one primary Investigation';
    ELSIF inv_count>1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_PRIMARY_INVESTIGATIONS','error',
            'Evidence Monitor has multiple primary Investigations';
    ELSE
        SELECT il.investigation_version_uuid
          INTO inv_uuid
          FROM product.investigation_link il
         WHERE il.product_version_uuid=p_product_version_uuid
           AND il.role='primary';

        SELECT *
          INTO iv
          FROM investigation.investigation_version
         WHERE version_uuid=inv_uuid;

        IF iv.investigation_type<>'evidence_monitoring' THEN
            RETURN QUERY SELECT
                'PRIMARY_INVESTIGATION_NOT_MONITORING','error',
                'Monitor primary Investigation must be evidence_monitoring';
        END IF;

        IF iv.maintenance_level NOT IN ('M2','M3') THEN
            RETURN QUERY SELECT
                'MONITOR_MAINTENANCE_NOT_M2_M3','error',
                'Evidence Monitor requires maintenance M2 or M3';
        END IF;

        IF iv.protocol_artifact_uuid IS NULL
           OR NOT EXISTS (
                SELECT 1
                  FROM artifact.artifact a
                 WHERE a.artifact_uuid=iv.protocol_artifact_uuid
                   AND a.status='active'
           ) THEN
            RETURN QUERY SELECT
                'MISSING_MONITOR_PROTOCOL','error',
                'Evidence Monitor requires an active protocol/monitoring plan';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.investigation_question iq
             WHERE iq.investigation_version_uuid=inv_uuid
               AND iq.role='primary'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_QUESTION','error',
                'Monitor primary Investigation requires a primary QuestionVersion';
        END IF;

        IF iv.evidence_cutoff_date IS DISTINCT FROM pv.evidence_cutoff_date THEN
            RETURN QUERY SELECT
                'BASELINE_CUTOFF_MISMATCH','error',
                'Monitor Product and Investigation baseline cutoff differ';
        END IF;

        IF iv.maintenance_level='M3' THEN
            RETURN QUERY SELECT
                'M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL','error',
                'Formal M3 living-evidence publication is blocked until Phase 4 transversal update policy is operational';
        END IF;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_definition md
         WHERE md.monitor_product_version_uuid=p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'MISSING_MONITOR_DEFINITION','error',
            'Evidence Monitor requires MonitorDefinition';
    END IF;

    SELECT * INTO t
      FROM maintenance.monitor_target
     WHERE monitor_product_version_uuid=p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_TARGET','error',
            'Evidence Monitor requires exactly one primary target';
    ELSE
        IF (
            t.target_product_version_uuid IS NOT NULL
            AND EXISTS (
                SELECT 1
                  FROM core.entity_version ev
                 WHERE ev.version_uuid=t.target_product_version_uuid
                   AND ev.version_status IN ('invalidated','archived')
            )
        ) OR (
            t.target_investigation_version_uuid IS NOT NULL
            AND EXISTS (
                SELECT 1
                  FROM core.entity_version ev
                 WHERE ev.version_uuid=t.target_investigation_version_uuid
                   AND ev.version_status IN ('invalidated','archived')
            )
        ) THEN
            RETURN QUERY SELECT
                'TARGET_INVALIDATED','error',
                'Monitored target version is invalidated or archived';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM provenance.dependency_edge de
             WHERE de.source_version_uuid=COALESCE(
                       t.target_product_version_uuid,
                       t.target_investigation_version_uuid
                   )
               AND de.target_version_uuid=p_product_version_uuid
               AND de.dependency_type='maintenance_surveillance_target'
               AND de.status='active'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_TARGET_DEPENDENCY','error',
                'Monitor target linkage requires active maintenance_surveillance_target dependency';
        END IF;
    END IF;

    SELECT ms.operational_status INTO monitor_state_status
      FROM maintenance.monitor_state ms
     WHERE ms.monitor_product_version_uuid=p_product_version_uuid
       AND ms.record_status='active';

    IF monitor_state_status IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_MONITOR_STATE','error',
            'Evidence Monitor requires one active operational state';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM core.entity_version ev
         WHERE ev.version_uuid=p_product_version_uuid
           AND ev.version_status='current'
    ) THEN
        RETURN QUERY SELECT
            'MONITOR_PRODUCT_NOT_CURRENT','error',
            'Monitor ProductVersion must be current for formal publication';
    END IF;

    IF pv.status<>'published' THEN
        RETURN QUERY SELECT
            'PRODUCT_NOT_PUBLISHED','error',
            'Formal Evidence Monitor ProductVersion status must be published';
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PUBLICATION_DATE','error',
            'Formal Evidence Monitor requires publication_date';
    END IF;

    IF btrim(COALESCE(pv.limitations_summary,''))='' THEN
        RETURN QUERY SELECT
            'MISSING_LIMITATIONS','error',
            'Evidence Monitor limitations_summary is required';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.currency_state cs
         WHERE cs.product_version_uuid=p_product_version_uuid
           AND cs.record_status='active'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_MONITOR_CURRENCY_STATE','error',
            'Evidence Monitor requires its own active CurrencyState for plan currency';
    END IF;

    SELECT mc.* INTO latest_cycle
      FROM maintenance.monitor_cycle mc
     WHERE mc.monitor_product_version_uuid=p_product_version_uuid
       AND mc.execution_status='completed'
     ORDER BY mc.cycle_no DESC
     LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_COMPLETED_CYCLE','error',
            'Formal Evidence Monitor requires at least one completed cycle';
    ELSE
        RETURN QUERY
        SELECT ci.issue_code,ci.severity,ci.message
          FROM maintenance.monitor_cycle_issues(latest_cycle.cycle_uuid) ci;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.search s
         WHERE s.investigation_version_uuid=inv_uuid
           AND NOT EXISTS (
                SELECT 1
                  FROM maintenance.cycle_search cs
                 WHERE cs.search_uuid=s.search_uuid
           )
    ) THEN
        RETURN QUERY SELECT
            'UNLINKED_MONITOR_SEARCH','error',
            'All Monitor Investigation Searches must be linked to a Monitoring Cycle';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='ai_methodological_verification'
           AND ar.decision='passed'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_AI_METHODOLOGICAL_VERIFICATION','error',
            'Formal Evidence Monitor requires passed AI methodological verification';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='ai_methodological_verification'
           AND ar.decision IN ('revise','failed')
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_AI_METHOD_BLOCK','error',
            'Active AI methodological verification blocks publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='owner_governance_approval'
           AND ar.decision='approved'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OWNER_APPROVAL','error',
            'Formal M2 Evidence Monitor requires owner governance approval';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='owner_governance_approval'
           AND ar.decision IN ('revise','rejected')
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_OWNER_BLOCK','error',
            'Active owner governance decision blocks publication';
    END IF;

    IF product.assurance_level(p_product_version_uuid) NOT IN ('A2','A3') THEN
        RETURN QUERY SELECT
            'ASSURANCE_BELOW_A2','error',
            format(
                'Formal M2 Evidence Monitor requires at least A2; current assurance is %s',
                product.assurance_level(p_product_version_uuid)
            );
    END IF;

    IF EXISTS (
        WITH RECURSIVE deps(version_uuid,path) AS (
            SELECT
                p_product_version_uuid,
                ARRAY[p_product_version_uuid]::uuid[]
            UNION ALL
            SELECT
                de.source_version_uuid,
                d.path||de.source_version_uuid
              FROM deps d
              JOIN provenance.dependency_edge de
                ON de.target_version_uuid=d.version_uuid
               AND de.status='active'
             WHERE cardinality(d.path)<64
               AND NOT de.source_version_uuid=ANY(d.path)
        )
        SELECT 1
          FROM deps d
          JOIN provenance.record pr
            ON pr.target_version_uuid=d.version_uuid
         WHERE pr.status='invalidated'
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_DEPENDENCY','error',
            'Invalidated upstream provenance blocks formal Monitor publication';
    END IF;

    -- Warnings.
    IF monitor_state_status='paused' THEN
        RETURN QUERY SELECT
            'MONITOR_PAUSED','warning',
            'Monitor is operationally paused';
    ELSIF monitor_state_status IN ('closed','archived') THEN
        RETURN QUERY SELECT
            'MONITOR_CLOSED','warning',
            'Monitor is no longer operationally active';
    END IF;

    IF t.target_product_version_uuid IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1
              FROM core.entity_version ev
             WHERE ev.version_uuid=t.target_product_version_uuid
               AND ev.version_status='current'
        ) THEN
            RETURN QUERY SELECT
                'TARGET_VERSION_SUPERSEDED','warning',
                'Monitored target ProductVersion is no longer current; a new Monitor version may be required';
        END IF;

        SELECT cs.currency_status INTO target_currency
          FROM product.currency_state cs
         WHERE cs.product_version_uuid=t.target_product_version_uuid
           AND cs.record_status='active';

        IF target_currency='under_evaluation' THEN
            RETURN QUERY SELECT
                'TARGET_CURRENCY_UNDER_EVALUATION','warning',
                'Target evidence is under evaluation';
        ELSIF target_currency='update_recommended' THEN
            RETURN QUERY SELECT
                'TARGET_UPDATE_RECOMMENDED','warning',
                'Target evidence has update recommended';
        ELSIF target_currency='outdated' THEN
            RETURN QUERY SELECT
                'TARGET_OUTDATED','warning',
                'Target evidence is outdated';
        END IF;
    END IF;

    IF latest_cycle.cycle_uuid IS NOT NULL
       AND latest_cycle.verification_status IN ('unverified','ai_verified') THEN
        RETURN QUERY SELECT
            'AI_ONLY_LATEST_CYCLE','warning',
            'Latest completed cycle lacks human verification';
    END IF;

    IF latest_cycle.cycle_uuid IS NOT NULL
       AND latest_cycle.escalation_recommendation='evaluate_alert' THEN
        RETURN QUERY SELECT
            'ALERT_EVALUATION_RECOMMENDED','warning',
            'Latest cycle recommends evaluation for a future Evidence Alert';
    ELSIF latest_cycle.cycle_uuid IS NOT NULL
       AND latest_cycle.escalation_recommendation='urgent_reassessment' THEN
        RETURN QUERY SELECT
            'URGENT_REASSESSMENT_RECOMMENDED','warning',
            'Latest cycle recommends urgent scientific reassessment';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='expert_independent_review'
           AND ar.decision='approved'
    ) THEN
        RETURN QUERY SELECT
            'NO_EXPERT_REVIEW_OF_MONITOR','warning',
            'M2 Monitor v0.1 does not require expert independent review, and none is recorded';
    END IF;
END;
$gate$;

CREATE OR REPLACE FUNCTION product.evidence_monitor_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $q$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.evidence_monitor_publication_issues(
               p_product_version_uuid
          )
         WHERE severity='error'
    );
$q$;

COMMIT;
