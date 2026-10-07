-- OES-DBM-2026-0024
-- Fase 3 — Evidence Alert contract v0.1
-- Depends on: migrations 002–023
-- Date: 2026-10-06
-- Scope: persistence, integrity and publication gate only. No Phase-4 thresholds.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

-- ---------------------------------------------------------------------------
-- EVIDENCE ALERT
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.evidence_alert (
    alert_product_version_uuid uuid PRIMARY KEY
        REFERENCES product.product_version(version_uuid),
    target_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),
    target_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    headline text NOT NULL CHECK (length(btrim(headline))>0),
    summary text NOT NULL CHECK (length(btrim(summary))>0),
    signal_date date,
    detected_at timestamptz NOT NULL,
    classification text NOT NULL CHECK (
        classification IN ('informational','relevant','critical')
    ),
    reassessment_priority text NOT NULL CHECK (
        reassessment_priority IN ('routine','priority','urgent')
    ),
    lifecycle_status text NOT NULL CHECK (
        lifecycle_status IN ('triage','evaluation','incorporated','discarded')
    ),
    justification text NOT NULL CHECK (length(btrim(justification))>0),
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
    issued_at timestamptz,
    resolution_rationale text,
    incorporated_version_uuid uuid
        REFERENCES core.entity_version(version_uuid),
    incorporated_currency_state_uuid uuid
        REFERENCES product.currency_state(currency_state_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        num_nonnulls(
            target_product_version_uuid,
            target_investigation_version_uuid
        )=1
    )
);

CREATE INDEX IF NOT EXISTS ix_evidence_alert_target_product
    ON maintenance.evidence_alert(target_product_version_uuid);
CREATE INDEX IF NOT EXISTS ix_evidence_alert_target_investigation
    ON maintenance.evidence_alert(target_investigation_version_uuid);
CREATE INDEX IF NOT EXISTS ix_evidence_alert_lifecycle
    ON maintenance.evidence_alert(lifecycle_status,classification);

CREATE OR REPLACE FUNCTION maintenance.alert_context_investigation(
    p_alert_product_version_uuid uuid
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
     WHERE il.product_version_uuid=p_alert_product_version_uuid
       AND il.role='source_context';
$q$;

CREATE OR REPLACE FUNCTION maintenance.assert_evidence_alert_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    pv product.product_version%ROWTYPE;
    context_count integer;
    context_uuid uuid;
    context_status text;
    target_uuid uuid;
    target_status text;
    target_entity uuid;
    incorporated_entity uuid;
    incorporation_currency_product uuid;
BEGIN
    SELECT * INTO pv
      FROM product.product_version
     WHERE version_uuid=NEW.alert_product_version_uuid;

    IF NOT FOUND OR pv.product_type<>'evidence_alert' THEN
        RAISE EXCEPTION
            'EvidenceAlert requires product_type=evidence_alert';
    END IF;

    IF pv.conclusion_text IS NOT NULL THEN
        RAISE EXCEPTION
            'Evidence Alert cannot carry a scientific conclusion_text';
    END IF;

    SELECT count(*),(array_agg(il.investigation_version_uuid))[1]
      INTO context_count,context_uuid
      FROM product.investigation_link il
     WHERE il.product_version_uuid=NEW.alert_product_version_uuid
       AND il.role='source_context';

    IF context_count<>1 THEN
        RAISE EXCEPTION
            'Evidence Alert requires exactly one source_context Investigation';
    END IF;

    SELECT ev.version_status INTO context_status
      FROM core.entity_version ev
     WHERE ev.version_uuid=context_uuid;

    IF context_status IN ('invalidated','archived') THEN
        RAISE EXCEPTION
            'Evidence Alert source_context cannot be invalidated or archived';
    END IF;

    target_uuid:=COALESCE(
        NEW.target_product_version_uuid,
        NEW.target_investigation_version_uuid
    );

    IF target_uuid=NEW.alert_product_version_uuid THEN
        RAISE EXCEPTION 'Evidence Alert cannot target itself';
    END IF;

    SELECT ev.version_status,ev.entity_uuid
      INTO target_status,target_entity
      FROM core.entity_version ev
     WHERE ev.version_uuid=target_uuid;

    IF target_status IS NULL THEN
        RAISE EXCEPTION 'Evidence Alert target version does not exist';
    END IF;

    IF target_status IN ('invalidated','archived') THEN
        RAISE EXCEPTION
            'Evidence Alert target cannot be invalidated or archived at creation';
    END IF;

    IF NEW.signal_date IS NOT NULL
       AND NEW.signal_date>pv.evidence_cutoff_date THEN
        RAISE EXCEPTION
            'Alert signal_date cannot be after Alert evidence_cutoff_date';
    END IF;

    IF NEW.issued_at IS NOT NULL
       AND NEW.issued_at<NEW.detected_at THEN
        RAISE EXCEPTION
            'Alert issued_at cannot precede detected_at';
    END IF;

    IF NEW.lifecycle_status='triage'
       AND NEW.issued_at IS NOT NULL THEN
        RAISE EXCEPTION
            'Triage AlertVersion cannot have issued_at';
    END IF;

    IF NEW.lifecycle_status='incorporated' THEN
        IF num_nonnulls(
            NEW.incorporated_version_uuid,
            NEW.incorporated_currency_state_uuid
        )=0 THEN
            RAISE EXCEPTION
                'Incorporated AlertVersion requires incorporation linkage';
        END IF;
    ELSE
        IF NEW.incorporated_version_uuid IS NOT NULL
           OR NEW.incorporated_currency_state_uuid IS NOT NULL THEN
            RAISE EXCEPTION
                'Only incorporated AlertVersion may carry incorporation linkage';
        END IF;
    END IF;

    IF NEW.lifecycle_status='discarded'
       AND btrim(COALESCE(NEW.resolution_rationale,''))='' THEN
        RAISE EXCEPTION
            'Discarded AlertVersion requires resolution_rationale';
    END IF;

    IF NEW.incorporated_version_uuid IS NOT NULL THEN
        IF NEW.incorporated_version_uuid=NEW.alert_product_version_uuid THEN
            RAISE EXCEPTION
                'Alert cannot incorporate into itself';
        END IF;
        SELECT ev.entity_uuid INTO incorporated_entity
          FROM core.entity_version ev
         WHERE ev.version_uuid=NEW.incorporated_version_uuid;
        IF incorporated_entity IS DISTINCT FROM target_entity THEN
            RAISE EXCEPTION
                'Incorporated version must version the same target entity';
        END IF;
    END IF;

    IF NEW.incorporated_currency_state_uuid IS NOT NULL THEN
        IF NEW.target_product_version_uuid IS NULL THEN
            RAISE EXCEPTION
                'CurrencyState incorporation requires ProductVersion target';
        END IF;
        SELECT cs.product_version_uuid
          INTO incorporation_currency_product
          FROM product.currency_state cs
         WHERE cs.currency_state_uuid=NEW.incorporated_currency_state_uuid;
        IF incorporation_currency_product IS DISTINCT FROM
           NEW.target_product_version_uuid THEN
            RAISE EXCEPTION
                'Incorporated CurrencyState must belong to target ProductVersion';
        END IF;
    END IF;

    IF NEW.verification_status='unverified' THEN
        IF NEW.verified_by IS NOT NULL
           OR NEW.verifier_actor_type IS NOT NULL
           OR NEW.verified_at IS NOT NULL THEN
            RAISE EXCEPTION
                'Unverified Alert cannot contain verifier metadata';
        END IF;
    ELSIF NEW.verification_status='ai_verified' THEN
        IF NEW.verifier_actor_type<>'ai_system'
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'AI-verified Alert requires AI verifier metadata';
        END IF;
    ELSIF NEW.verification_status IN ('human_verified','human_consensus') THEN
        IF NEW.verifier_actor_type NOT IN ('human_reviewer','human_expert')
           OR NEW.verified_by IS NULL
           OR NEW.verified_at IS NULL THEN
            RAISE EXCEPTION
                'Human-verified Alert requires human verifier metadata';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_evidence_alert_consistency
    ON maintenance.evidence_alert;
CREATE TRIGGER tr_evidence_alert_consistency
BEFORE INSERT ON maintenance.evidence_alert
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_evidence_alert_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_evidence_alert_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION
        'EvidenceAlert is version-preserving and immutable; create a new Alert ProductVersion';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_evidence_alert_immutable
    ON maintenance.evidence_alert;
CREATE TRIGGER tr_evidence_alert_immutable
BEFORE UPDATE OR DELETE ON maintenance.evidence_alert
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_evidence_alert_mutation();

-- ---------------------------------------------------------------------------
-- ALERT SOURCES
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.alert_source (
    alert_source_uuid uuid PRIMARY KEY,
    alert_product_version_uuid uuid NOT NULL
        REFERENCES maintenance.evidence_alert(alert_product_version_uuid),
    source_role text NOT NULL CHECK (
        source_role IN ('primary','supporting')
    ),
    source_type text NOT NULL CHECK (
        source_type IN (
            'candidate_assessment','evidence_event',
            'entity_version','artifact','uri'
        )
    ),
    candidate_assessment_uuid uuid
        REFERENCES maintenance.candidate_assessment(candidate_assessment_uuid),
    evidence_event_uuid uuid
        REFERENCES maintenance.evidence_event(evidence_event_uuid),
    source_entity_version_uuid uuid
        REFERENCES core.entity_version(version_uuid),
    source_artifact_uuid uuid
        REFERENCES artifact.artifact(artifact_uuid),
    source_uri text,
    source_date date,
    description text NOT NULL CHECK (length(btrim(description))>0),
    sequence_no integer CHECK (sequence_no IS NULL OR sequence_no>0),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        num_nonnulls(
            candidate_assessment_uuid,
            evidence_event_uuid,
            source_entity_version_uuid,
            source_artifact_uuid,
            source_uri
        )=1
    ),
    CHECK (source_uri IS NULL OR length(btrim(source_uri))>0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_alert_one_primary_source
    ON maintenance.alert_source(alert_product_version_uuid)
    WHERE source_role='primary';
CREATE INDEX IF NOT EXISTS ix_alert_source_alert
    ON maintenance.alert_source(alert_product_version_uuid,source_role);

CREATE OR REPLACE FUNCTION maintenance.assert_alert_source_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    pv product.product_version%ROWTYPE;
    source_status text;
    candidate_status text;
    event_status text;
    artifact_status text;
    source_monitor uuid;
    source_context uuid;
    source_monitor_inv uuid;
BEGIN
    SELECT pv0.* INTO pv
      FROM maintenance.evidence_alert ea
      JOIN product.product_version pv0
        ON pv0.version_uuid=ea.alert_product_version_uuid
     WHERE ea.alert_product_version_uuid=NEW.alert_product_version_uuid;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'AlertSource requires existing EvidenceAlert';
    END IF;

    IF (NEW.source_type='candidate_assessment') IS DISTINCT FROM
       (NEW.candidate_assessment_uuid IS NOT NULL) THEN
        RAISE EXCEPTION 'candidate_assessment source_type/locator mismatch';
    END IF;
    IF (NEW.source_type='evidence_event') IS DISTINCT FROM
       (NEW.evidence_event_uuid IS NOT NULL) THEN
        RAISE EXCEPTION 'evidence_event source_type/locator mismatch';
    END IF;
    IF (NEW.source_type='entity_version') IS DISTINCT FROM
       (NEW.source_entity_version_uuid IS NOT NULL) THEN
        RAISE EXCEPTION 'entity_version source_type/locator mismatch';
    END IF;
    IF (NEW.source_type='artifact') IS DISTINCT FROM
       (NEW.source_artifact_uuid IS NOT NULL) THEN
        RAISE EXCEPTION 'artifact source_type/locator mismatch';
    END IF;
    IF (NEW.source_type='uri') IS DISTINCT FROM
       (NEW.source_uri IS NOT NULL) THEN
        RAISE EXCEPTION 'uri source_type/locator mismatch';
    END IF;

    IF NEW.source_date IS NOT NULL
       AND NEW.source_date>pv.evidence_cutoff_date THEN
        RAISE EXCEPTION
            'AlertSource source_date cannot exceed Alert evidence cutoff';
    END IF;

    source_context:=maintenance.alert_context_investigation(
        NEW.alert_product_version_uuid
    );

    IF NEW.candidate_assessment_uuid IS NOT NULL THEN
        SELECT ca.record_status,mc.monitor_product_version_uuid
          INTO candidate_status,source_monitor
          FROM maintenance.candidate_assessment ca
          JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ca.cycle_uuid
         WHERE ca.candidate_assessment_uuid=NEW.candidate_assessment_uuid;
        IF candidate_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION
                'Alert source CandidateAssessment must be active';
        END IF;
        source_monitor_inv:=maintenance.monitor_primary_investigation(source_monitor);
        IF source_context IS DISTINCT FROM source_monitor_inv THEN
            RAISE EXCEPTION
                'Alert source_context must match source Monitor Investigation';
        END IF;
    ELSIF NEW.evidence_event_uuid IS NOT NULL THEN
        SELECT ee.status,mc.monitor_product_version_uuid
          INTO event_status,source_monitor
          FROM maintenance.evidence_event ee
          JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ee.cycle_uuid
         WHERE ee.evidence_event_uuid=NEW.evidence_event_uuid;
        IF event_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION
                'Alert source EvidenceEvent must be active';
        END IF;
        source_monitor_inv:=maintenance.monitor_primary_investigation(source_monitor);
        IF source_context IS DISTINCT FROM source_monitor_inv THEN
            RAISE EXCEPTION
                'Alert source_context must match source Monitor Investigation';
        END IF;
    ELSIF NEW.source_entity_version_uuid IS NOT NULL THEN
        SELECT ev.version_status INTO source_status
          FROM core.entity_version ev
         WHERE ev.version_uuid=NEW.source_entity_version_uuid;
        IF source_status='invalidated' THEN
            RAISE EXCEPTION
                'Invalidated EntityVersion cannot be attached as active Alert source';
        END IF;
    ELSIF NEW.source_artifact_uuid IS NOT NULL THEN
        SELECT a.status INTO artifact_status
          FROM artifact.artifact a
         WHERE a.artifact_uuid=NEW.source_artifact_uuid;
        IF artifact_status IS DISTINCT FROM 'active' THEN
            RAISE EXCEPTION
                'Alert source Artifact must be active';
        END IF;
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_alert_source_consistency
    ON maintenance.alert_source;
CREATE TRIGGER tr_alert_source_consistency
BEFORE INSERT ON maintenance.alert_source
FOR EACH ROW EXECUTE FUNCTION maintenance.assert_alert_source_consistency();

CREATE OR REPLACE FUNCTION maintenance.guard_alert_source_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    RAISE EXCEPTION
        'AlertSource is immutable; create a new Alert ProductVersion for material changes';
END;
$guard$;

DROP TRIGGER IF EXISTS tr_alert_source_immutable
    ON maintenance.alert_source;
CREATE TRIGGER tr_alert_source_immutable
BEFORE UPDATE OR DELETE ON maintenance.alert_source
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_alert_source_mutation();

-- ---------------------------------------------------------------------------
-- AFFECTED DIMENSIONS
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS maintenance.alert_affected_dimension (
    alert_product_version_uuid uuid NOT NULL
        REFERENCES maintenance.evidence_alert(alert_product_version_uuid),
    dimension_code text NOT NULL CHECK (
        dimension_code IN (
            'benefit','harm','magnitude','precision','certainty',
            'applicability','conclusion','regulatory_status',
            'validity','scope','other'
        )
    ),
    rationale text,
    sequence_no integer CHECK (sequence_no IS NULL OR sequence_no>0),
    PRIMARY KEY (alert_product_version_uuid,dimension_code)
);

CREATE OR REPLACE FUNCTION maintenance.guard_alert_dimension_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' OR TG_OP='UPDATE' THEN
        RAISE EXCEPTION
            'Alert affected dimensions are immutable within an AlertVersion';
    END IF;
    RETURN NEW;
END;
$guard$;

DROP TRIGGER IF EXISTS tr_alert_dimension_immutable
    ON maintenance.alert_affected_dimension;
CREATE TRIGGER tr_alert_dimension_immutable
BEFORE UPDATE OR DELETE ON maintenance.alert_affected_dimension
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_alert_dimension_mutation();

-- ---------------------------------------------------------------------------
-- ASSURANCE WRAPPER
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_alert_assurance_level(
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

CREATE OR REPLACE FUNCTION product.evidence_alert_publication_issues(
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
    a maintenance.evidence_alert%ROWTYPE;
    context_count integer;
    context_uuid uuid;
    context_status text;
    primary_source_count integer;
    primary_source maintenance.alert_source%ROWTYPE;
    target_uuid uuid;
    target_status text;
    target_currency text;
    target_assurance text;
    expert_present boolean;
BEGIN
    SELECT * INTO pv
      FROM product.product_version
     WHERE version_uuid=p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_PRODUCT_VERSION','error','ProductVersion does not exist';
        RETURN;
    END IF;

    IF pv.product_type<>'evidence_alert' THEN
        RETURN QUERY SELECT
            'WRONG_PRODUCT_TYPE','error',
            format('Expected evidence_alert, found %s',pv.product_type);
        RETURN;
    END IF;

    SELECT * INTO a
      FROM maintenance.evidence_alert
     WHERE alert_product_version_uuid=p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_ALERT_RECORD','error',
            'Evidence Alert requires specialized maintenance.evidence_alert record';
        RETURN;
    END IF;

    IF pv.conclusion_text IS NOT NULL THEN
        RETURN QUERY SELECT
            'ALERT_CONCLUSION_NOT_NULL','error',
            'Evidence Alert cannot carry its own scientific conclusion';
    END IF;

    SELECT count(*),(array_agg(il.investigation_version_uuid))[1]
      INTO context_count,context_uuid
      FROM product.investigation_link il
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='source_context';

    IF context_count=0 THEN
        RETURN QUERY SELECT
            'MISSING_SOURCE_CONTEXT','error',
            'Evidence Alert requires one source_context Investigation';
    ELSIF context_count>1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_SOURCE_CONTEXTS','error',
            'Evidence Alert cannot have multiple source_context Investigations';
    ELSE
        SELECT ev.version_status INTO context_status
          FROM core.entity_version ev
         WHERE ev.version_uuid=context_uuid;
        IF context_status IS DISTINCT FROM 'current' THEN
            RETURN QUERY SELECT
                'SOURCE_CONTEXT_INVALID','error',
                format('source_context version_status is %s',context_status);
        END IF;
    END IF;

    target_uuid:=COALESCE(
        a.target_product_version_uuid,
        a.target_investigation_version_uuid
    );

    IF target_uuid IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_TARGET','error','Evidence Alert requires a target version';
    ELSE
        SELECT ev.version_status INTO target_status
          FROM core.entity_version ev
         WHERE ev.version_uuid=target_uuid;
        IF target_status IS NULL OR target_status IN ('invalidated','archived') THEN
            RETURN QUERY SELECT
                'INVALID_TARGET','error',
                'Evidence Alert target is missing, invalidated or archived';
        END IF;
    END IF;

    SELECT count(*) INTO primary_source_count
      FROM maintenance.alert_source s
     WHERE s.alert_product_version_uuid=p_product_version_uuid
       AND s.source_role='primary';

    IF primary_source_count=0 THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_SOURCE','error',
            'Evidence Alert requires one primary source';
    ELSIF primary_source_count>1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_PRIMARY_SOURCES','error',
            'Evidence Alert has multiple primary sources';
    ELSE
        SELECT * INTO primary_source
          FROM maintenance.alert_source s
         WHERE s.alert_product_version_uuid=p_product_version_uuid
           AND s.source_role='primary';

        IF (
            primary_source.candidate_assessment_uuid IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 FROM maintenance.candidate_assessment ca
                 WHERE ca.candidate_assessment_uuid=primary_source.candidate_assessment_uuid
                   AND ca.record_status='active'
            )
        ) OR (
            primary_source.evidence_event_uuid IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 FROM maintenance.evidence_event ee
                 WHERE ee.evidence_event_uuid=primary_source.evidence_event_uuid
                   AND ee.status='active'
            )
        ) OR (
            primary_source.source_entity_version_uuid IS NOT NULL
            AND EXISTS (
                SELECT 1 FROM core.entity_version ev
                 WHERE ev.version_uuid=primary_source.source_entity_version_uuid
                   AND ev.version_status='invalidated'
            )
        ) OR (
            primary_source.source_artifact_uuid IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 FROM artifact.artifact ar
                 WHERE ar.artifact_uuid=primary_source.source_artifact_uuid
                   AND ar.status='active'
            )
        ) THEN
            RETURN QUERY SELECT
                'INVALID_PRIMARY_SOURCE','error',
                'Evidence Alert primary source is no longer valid';
        END IF;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.alert_affected_dimension d
         WHERE d.alert_product_version_uuid=p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'MISSING_AFFECTED_DIMENSION','error',
            'Evidence Alert requires at least one affected dimension';
    END IF;

    IF btrim(COALESCE(a.headline,''))='' THEN
        RETURN QUERY SELECT 'MISSING_HEADLINE','error','Alert headline is required';
    END IF;
    IF btrim(COALESCE(a.summary,''))='' THEN
        RETURN QUERY SELECT 'MISSING_SUMMARY','error','Alert summary is required';
    END IF;
    IF btrim(COALESCE(a.justification,''))='' THEN
        RETURN QUERY SELECT 'MISSING_JUSTIFICATION','error','Alert justification is required';
    END IF;

    IF a.lifecycle_status='triage' THEN
        RETURN QUERY SELECT
            'ALERT_STILL_IN_TRIAGE','error',
            'Triage AlertVersion is not formally publishable';
    END IF;

    IF a.verification_status NOT IN ('human_verified','human_consensus') THEN
        RETURN QUERY SELECT
            'MISSING_HUMAN_VERIFICATION','error',
            'Formal Evidence Alert requires explicit human verification';
    END IF;

    IF product.assurance_level(p_product_version_uuid) NOT IN ('A2','A3') THEN
        RETURN QUERY SELECT
            'ASSURANCE_BELOW_A2','error',
            format(
                'Formal Evidence Alert requires at least A2; current assurance is %s',
                product.assurance_level(p_product_version_uuid)
            );
    END IF;

    IF pv.status<>'published' THEN
        RETURN QUERY SELECT
            'PRODUCT_NOT_PUBLISHED','error',
            'Formal Evidence Alert ProductVersion status must be published';
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PUBLICATION_DATE','error',
            'Formal Evidence Alert requires publication_date';
    END IF;

    IF a.issued_at IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_ISSUED_AT','error',
            'Formal Evidence Alert requires issued_at';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM core.entity_version ev
         WHERE ev.version_uuid=p_product_version_uuid
           AND ev.version_status='current'
    ) THEN
        RETURN QUERY SELECT
            'NOT_CURRENT_ENTITY_VERSION','error',
            'Published Evidence Alert must be the current Alert ProductVersion';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM provenance.dependency_edge de
         WHERE de.source_version_uuid=target_uuid
           AND de.target_version_uuid=p_product_version_uuid
           AND de.dependency_type='maintenance_alert_target'
           AND de.status='active'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_TARGET_DEPENDENCY','error',
            'Evidence Alert target requires active maintenance_alert_target dependency';
    END IF;

    IF a.lifecycle_status='incorporated' THEN
        IF a.incorporated_version_uuid IS NULL
           AND a.incorporated_currency_state_uuid IS NULL THEN
            RETURN QUERY SELECT
                'INCORPORATED_WITHOUT_LINEAGE','error',
                'Incorporated Alert requires incorporation linkage';
        END IF;
        IF a.incorporated_version_uuid IS NOT NULL
           AND NOT EXISTS (
                SELECT 1 FROM provenance.dependency_edge de
                 WHERE de.source_version_uuid=p_product_version_uuid
                   AND de.target_version_uuid=a.incorporated_version_uuid
                   AND de.dependency_type='maintenance_alert_incorporation'
                   AND de.status='active'
           ) THEN
            RETURN QUERY SELECT
                'INCORPORATED_WITHOUT_LINEAGE','error',
                'Incorporated Alert version linkage requires dependency edge';
        END IF;
    END IF;

    IF a.lifecycle_status='discarded'
       AND btrim(COALESCE(a.resolution_rationale,''))='' THEN
        RETURN QUERY SELECT
            'DISCARDED_WITHOUT_RATIONALE','error',
            'Discarded Alert requires resolution rationale';
    END IF;

    IF EXISTS (
        WITH RECURSIVE deps(version_uuid,path) AS (
            SELECT p_product_version_uuid,
                   ARRAY[p_product_version_uuid]::uuid[]
            UNION ALL
            SELECT de.source_version_uuid,d.path||de.source_version_uuid
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
            'Invalidated upstream provenance blocks formal Alert publication';
    END IF;

    expert_present:=EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='expert_independent_review'
           AND ar.decision='approved'
    );

    IF NOT expert_present THEN
        RETURN QUERY SELECT
            'NO_EXPERT_REVIEW_OF_ALERT','warning',
            'Evidence Alert v0.1 does not require expert independent review, and none is recorded';
    END IF;

    IF a.classification='critical' AND NOT expert_present THEN
        RETURN QUERY SELECT
            'CRITICAL_WITHOUT_EXPERT_REVIEW','warning',
            'Critical classification is preliminary and has no expert independent review recorded';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.alert_source s
         WHERE s.alert_product_version_uuid=p_product_version_uuid
           AND s.source_type IN ('candidate_assessment','evidence_event')
    ) THEN
        RETURN QUERY SELECT
            'ALERT_SOURCE_OUTSIDE_MONITOR','warning',
            'Alert source is not derived from a persisted Monitor CandidateAssessment or EvidenceEvent';
    END IF;

    IF a.target_product_version_uuid IS NOT NULL THEN
        SELECT cs.currency_status INTO target_currency
          FROM product.currency_state cs
         WHERE cs.product_version_uuid=a.target_product_version_uuid
           AND cs.record_status='active';

        IF target_currency='under_evaluation' THEN
            RETURN QUERY SELECT
                'TARGET_CURRENCY_UNDER_EVALUATION','warning',
                'Target evidence is under evaluation';
        ELSIF target_currency='update_recommended' THEN
            RETURN QUERY SELECT
                'TARGET_CURRENCY_UPDATE_RECOMMENDED','warning',
                'Target evidence has update recommended';
        ELSIF target_currency='outdated' THEN
            RETURN QUERY SELECT
                'TARGET_CURRENCY_OUTDATED','warning',
                'Target evidence is outdated';
        END IF;

        target_assurance:=product.assurance_level(a.target_product_version_uuid);
        IF target_assurance NOT IN ('A2','A3') THEN
            RETURN QUERY SELECT
                'TARGET_ASSURANCE_BELOW_A2','warning',
                format(
                    'Target ProductVersion assurance is %s; Alert assurance is independent',
                    target_assurance
                );
        END IF;
    END IF;
END;
$gate$;

CREATE OR REPLACE FUNCTION product.evidence_alert_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $q$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.evidence_alert_publication_issues(
               p_product_version_uuid
          )
         WHERE severity='error'
    );
$q$;

COMMIT;
