-- OES-DBM-2026-0025
-- Fase 3 — Evidence Alert projection hardening
-- Depends on: migrations 002–024
-- Date: 2026-10-06
-- Scope: published-version sealing and dynamic source-lineage validation.

BEGIN;

-- ---------------------------------------------------------------------------
-- PUBLISHED ALERT SEALING
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.evidence_alert_version_is_sealed(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $q$
    SELECT COALESCE((
        SELECT pv.status='published' OR pv.publication_date IS NOT NULL
          FROM product.product_version pv
         WHERE pv.version_uuid=p_product_version_uuid
           AND pv.product_type='evidence_alert'
    ),false);
$q$;

CREATE OR REPLACE FUNCTION maintenance.guard_alert_child_insert_after_publication()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF maintenance.evidence_alert_version_is_sealed(
        NEW.alert_product_version_uuid
    ) THEN
        RAISE EXCEPTION
            'Published Evidence Alert is sealed; create a new Alert ProductVersion';
    END IF;
    RETURN NEW;
END;
$guard$;

DROP TRIGGER IF EXISTS tr_alert_source_no_postpublication_insert
    ON maintenance.alert_source;
CREATE TRIGGER tr_alert_source_no_postpublication_insert
BEFORE INSERT ON maintenance.alert_source
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_alert_child_insert_after_publication();

DROP TRIGGER IF EXISTS tr_alert_dimension_no_postpublication_insert
    ON maintenance.alert_affected_dimension;
CREATE TRIGGER tr_alert_dimension_no_postpublication_insert
BEFORE INSERT ON maintenance.alert_affected_dimension
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_alert_child_insert_after_publication();

CREATE OR REPLACE FUNCTION maintenance.guard_alert_context_after_publication()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    pv_uuid uuid;
    relevant boolean:=false;
    ptype text;
BEGIN
    pv_uuid:=CASE WHEN TG_OP='DELETE' THEN OLD.product_version_uuid ELSE NEW.product_version_uuid END;

    IF TG_OP='INSERT' THEN
        relevant:=NEW.role='source_context';
    ELSIF TG_OP='DELETE' THEN
        relevant:=OLD.role='source_context';
    ELSE
        relevant:=OLD.role='source_context' OR NEW.role='source_context';
    END IF;

    IF NOT relevant THEN RETURN COALESCE(NEW,OLD); END IF;

    SELECT pv.product_type INTO ptype
      FROM product.product_version pv
     WHERE pv.version_uuid=pv_uuid;

    IF ptype='evidence_alert'
       AND maintenance.evidence_alert_version_is_sealed(pv_uuid) THEN
        RAISE EXCEPTION
            'Published Evidence Alert source_context is sealed; create a new Alert ProductVersion';
    END IF;

    RETURN COALESCE(NEW,OLD);
END;
$guard$;

DROP TRIGGER IF EXISTS tr_alert_context_no_postpublication_mutation
    ON product.investigation_link;
CREATE TRIGGER tr_alert_context_no_postpublication_mutation
BEFORE INSERT OR UPDATE OR DELETE ON product.investigation_link
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_alert_context_after_publication();

CREATE OR REPLACE FUNCTION maintenance.guard_alert_product_version_after_publication()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF OLD.product_type<>'evidence_alert' THEN
        RETURN CASE WHEN TG_OP='DELETE' THEN OLD ELSE NEW END;
    END IF;

    IF TG_OP='DELETE' THEN
        IF OLD.status='published' OR OLD.publication_date IS NOT NULL THEN
            RAISE EXCEPTION
                'Published Evidence Alert ProductVersion is history-preserving';
        END IF;
        RETURN OLD;
    END IF;

    IF OLD.status='published' OR OLD.publication_date IS NOT NULL THEN
        IF NEW.version_uuid=OLD.version_uuid
           AND NEW.entity_uuid=OLD.entity_uuid
           AND NEW.product_type=OLD.product_type
           AND NEW.title=OLD.title
           AND NEW.intended_audience IS NOT DISTINCT FROM OLD.intended_audience
           AND NEW.evidence_cutoff_date IS NOT DISTINCT FROM OLD.evidence_cutoff_date
           AND NEW.publication_date IS NOT DISTINCT FROM OLD.publication_date
           AND NEW.conclusion_text IS NOT DISTINCT FROM OLD.conclusion_text
           AND NEW.applicability_summary IS NOT DISTINCT FROM OLD.applicability_summary
           AND NEW.limitations_summary IS NOT DISTINCT FROM OLD.limitations_summary
           AND (
                NEW.status=OLD.status
                OR (OLD.status='published' AND NEW.status='superseded')
                OR (OLD.status='superseded' AND NEW.status='archived')
           )
        THEN
            RETURN NEW;
        END IF;

        RAISE EXCEPTION
            'Published Evidence Alert ProductVersion material fields are sealed';
    END IF;

    RETURN NEW;
END;
$guard$;

DROP TRIGGER IF EXISTS tr_alert_product_version_postpublication_guard
    ON product.product_version;
CREATE TRIGGER tr_alert_product_version_postpublication_guard
BEFORE UPDATE OR DELETE ON product.product_version
FOR EACH ROW EXECUTE FUNCTION maintenance.guard_alert_product_version_after_publication();

-- ---------------------------------------------------------------------------
-- DYNAMIC SOURCE VALIDITY / LINEAGE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.evidence_alert_source_issues(
    p_alert_product_version_uuid uuid
)
RETURNS TABLE (
    alert_source_uuid uuid,
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    s maintenance.alert_source%ROWTYPE;
    source_context uuid;
    monitor_product uuid;
    monitor_inv uuid;
    source_state text;
BEGIN
    source_context:=maintenance.alert_context_investigation(
        p_alert_product_version_uuid
    );

    FOR s IN
        SELECT *
          FROM maintenance.alert_source x
         WHERE x.alert_product_version_uuid=p_alert_product_version_uuid
         ORDER BY x.sequence_no NULLS LAST,x.alert_source_uuid
    LOOP
        IF s.candidate_assessment_uuid IS NOT NULL THEN
            SELECT ca.record_status,mc.monitor_product_version_uuid
              INTO source_state,monitor_product
              FROM maintenance.candidate_assessment ca
              JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ca.cycle_uuid
             WHERE ca.candidate_assessment_uuid=s.candidate_assessment_uuid;

            IF source_state IS DISTINCT FROM 'active' THEN
                RETURN QUERY SELECT s.alert_source_uuid,
                    'ALERT_SOURCE_CANDIDATE_NOT_ACTIVE','error',
                    'AlertSource CandidateAssessment is no longer active';
            END IF;

            monitor_inv:=maintenance.monitor_primary_investigation(monitor_product);
            IF monitor_inv IS DISTINCT FROM source_context THEN
                RETURN QUERY SELECT s.alert_source_uuid,
                    'ALERT_SOURCE_MONITOR_CONTEXT_DRIFT','error',
                    'Monitor-derived AlertSource no longer matches source_context Investigation';
            END IF;

        ELSIF s.evidence_event_uuid IS NOT NULL THEN
            SELECT ee.status,mc.monitor_product_version_uuid
              INTO source_state,monitor_product
              FROM maintenance.evidence_event ee
              JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ee.cycle_uuid
             WHERE ee.evidence_event_uuid=s.evidence_event_uuid;

            IF source_state IS DISTINCT FROM 'active' THEN
                RETURN QUERY SELECT s.alert_source_uuid,
                    'ALERT_SOURCE_EVENT_NOT_ACTIVE','error',
                    'AlertSource EvidenceEvent is no longer active';
            END IF;

            monitor_inv:=maintenance.monitor_primary_investigation(monitor_product);
            IF monitor_inv IS DISTINCT FROM source_context THEN
                RETURN QUERY SELECT s.alert_source_uuid,
                    'ALERT_SOURCE_MONITOR_CONTEXT_DRIFT','error',
                    'Monitor-derived AlertSource no longer matches source_context Investigation';
            END IF;

        ELSIF s.source_entity_version_uuid IS NOT NULL THEN
            SELECT ev.version_status INTO source_state
              FROM core.entity_version ev
             WHERE ev.version_uuid=s.source_entity_version_uuid;

            IF source_state IN ('invalidated','archived') OR source_state IS NULL THEN
                RETURN QUERY SELECT s.alert_source_uuid,
                    'ALERT_SOURCE_ENTITY_INVALID','error',
                    'AlertSource EntityVersion is missing, invalidated or archived';
            END IF;

            IF NOT EXISTS (
                SELECT 1
                  FROM provenance.dependency_edge de
                 WHERE de.source_version_uuid=s.source_entity_version_uuid
                   AND de.target_version_uuid=p_alert_product_version_uuid
                   AND de.dependency_type='maintenance_alert_source'
                   AND de.status='active'
            ) THEN
                RETURN QUERY SELECT s.alert_source_uuid,
                    'MISSING_ALERT_SOURCE_DEPENDENCY','error',
                    'EntityVersion AlertSource requires active maintenance_alert_source dependency';
            END IF;

        ELSIF s.source_artifact_uuid IS NOT NULL THEN
            SELECT a.status INTO source_state
              FROM artifact.artifact a
             WHERE a.artifact_uuid=s.source_artifact_uuid;

            IF source_state IS DISTINCT FROM 'active' THEN
                RETURN QUERY SELECT s.alert_source_uuid,
                    'ALERT_SOURCE_ARTIFACT_NOT_ACTIVE','error',
                    'AlertSource Artifact is no longer active';
            END IF;
        END IF;
    END LOOP;
END;
$fn$;

CREATE OR REPLACE FUNCTION product.evidence_alert_projection_hardening_issues(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE sql
STABLE
AS $q$
    SELECT si.issue_code,si.severity,
           format('%s [AlertSource %s]',si.message,si.alert_source_uuid)
      FROM maintenance.evidence_alert_source_issues(
           p_product_version_uuid
      ) si
    UNION ALL
    SELECT 'ALERT_SOURCE_CONTEXT_CARDINALITY','error',
           'Evidence Alert must retain exactly one source_context Investigation'
     WHERE (
        SELECT count(*)
          FROM product.investigation_link il
         WHERE il.product_version_uuid=p_product_version_uuid
           AND il.role='source_context'
     )<>1;
$q$;

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
    )
    AND NOT EXISTS (
        SELECT 1
          FROM product.evidence_alert_projection_hardening_issues(
               p_product_version_uuid
          )
         WHERE severity='error'
    );
$q$;

COMMIT;
