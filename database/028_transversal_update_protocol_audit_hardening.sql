-- OES-DBM-2026-0028
-- Fase 4 — corrective audit hardening of transversal update protocol
-- Depends on: migrations 002–027
-- Date: 2026-10-07
-- Scope: lifecycle guards + dynamic issue helpers only.
-- No priority, SLA persistence, scheduler, notifications, propagation or M3 unblock.

BEGIN;

-- ---------------------------------------------------------------------------
-- HARDENING 1 — UpdateDecision requires an active UpdateSignal at INSERT.
-- Kept as an additive trigger so migration 027 remains historically intact.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.assert_update_decision_signal_active()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    signal_status text;
BEGIN
    SELECT s.status INTO signal_status
      FROM maintenance.update_signal s
     WHERE s.update_signal_uuid=NEW.update_signal_uuid;

    IF signal_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'UpdateDecision requires active UpdateSignal';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_decision_signal_active
    ON maintenance.update_decision;
CREATE TRIGGER tr_update_decision_signal_active
BEFORE INSERT ON maintenance.update_decision
FOR EACH ROW
EXECUTE FUNCTION maintenance.assert_update_decision_signal_active();

-- ---------------------------------------------------------------------------
-- HARDENING 2 — a new CurrencyState linkage requires an active decision.
-- Existing historical linkages remain valid if the decision is superseded later.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.assert_update_decision_link_active()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    decision_status text;
BEGIN
    SELECT d.record_status INTO decision_status
      FROM maintenance.update_decision d
     WHERE d.update_decision_uuid=NEW.update_decision_uuid;

    IF decision_status IS DISTINCT FROM 'active' THEN
        RAISE EXCEPTION 'CurrencyState linkage requires active UpdateDecision';
    END IF;

    RETURN NEW;
END;
$fn$;

DROP TRIGGER IF EXISTS tr_update_decision_link_active
    ON maintenance.update_decision_currency_state;
CREATE TRIGGER tr_update_decision_link_active
BEFORE INSERT ON maintenance.update_decision_currency_state
FOR EACH ROW
EXECUTE FUNCTION maintenance.assert_update_decision_link_active();

-- ---------------------------------------------------------------------------
-- HARDENING 3 — dynamic UpdatePolicy issues.
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
    target_product_type text;
    target_product_status text;
    target_investigation_type text;
    monitor_product_type text;
    monitor_state text;
    mt maintenance.monitor_target%ROWTYPE;
BEGIN
    SELECT * INTO p
      FROM maintenance.update_policy
     WHERE update_policy_uuid=p_update_policy_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_UPDATE_POLICY','error','UpdatePolicy does not exist';
        RETURN;
    END IF;

    SELECT ev.version_status INTO target_state
      FROM core.entity_version ev
     WHERE ev.version_uuid=COALESCE(
        p.target_product_version_uuid,
        p.target_investigation_version_uuid
     );

    IF target_state IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_UPDATE_POLICY_TARGET','error',
            'UpdatePolicy target version does not exist';
    ELSIF target_state<>'current' THEN
        RETURN QUERY SELECT
            'UPDATE_POLICY_TARGET_SUPERSEDED','warning',
            'UpdatePolicy target version is no longer current';
    END IF;

    IF p.target_product_version_uuid IS NOT NULL THEN
        SELECT pv.product_type,pv.status
          INTO target_product_type,target_product_status
          FROM product.product_version pv
         WHERE pv.version_uuid=p.target_product_version_uuid;

        IF target_product_type IS NULL THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_PRODUCT_TARGET_MISSING','error',
                'UpdatePolicy ProductVersion target is missing';
        ELSIF target_product_type IN ('evidence_monitor','evidence_alert') THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_TARGET_TYPE_FORBIDDEN','error',
                'UpdatePolicy target cannot be evidence_monitor/evidence_alert';
        END IF;

        IF target_product_status IN ('superseded','archived') THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_TARGET_EDITORIAL_NOT_CURRENT','warning',
                'UpdatePolicy ProductVersion target is editorially superseded/archived';
        END IF;
    ELSE
        SELECT iv.investigation_type
          INTO target_investigation_type
          FROM investigation.investigation_version iv
         WHERE iv.version_uuid=p.target_investigation_version_uuid;

        IF target_investigation_type IS NULL THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_INVESTIGATION_TARGET_MISSING','error',
                'UpdatePolicy InvestigationVersion target is missing';
        ELSIF target_investigation_type='evidence_monitoring' THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_TARGET_TYPE_FORBIDDEN','error',
                'UpdatePolicy target cannot be evidence_monitoring InvestigationVersion';
        END IF;
    END IF;

    IF NOT (
        (p.effective_maintenance_level='M0' AND p.cadence_mode='none')
        OR
        (p.effective_maintenance_level='M1'
         AND p.cadence_mode IN ('event_driven','periodic','hybrid'))
        OR
        (p.effective_maintenance_level='M2'
         AND p.cadence_mode IN ('periodic','hybrid'))
        OR
        (p.effective_maintenance_level='M3'
         AND p.cadence_mode IN ('continuous','hybrid'))
    ) THEN
        RETURN QUERY SELECT
            'UPDATE_POLICY_MAINTENANCE_CADENCE_MISMATCH','error',
            'UpdatePolicy maintenance level/cadence mode is inconsistent';
    END IF;

    IF p.effective_maintenance_level IN ('M0','M1')
       AND p.governing_monitor_product_version_uuid IS NOT NULL THEN
        RETURN QUERY SELECT
            'UPDATE_POLICY_MONITOR_FORBIDDEN','error',
            'M0/M1 UpdatePolicy cannot have governing Monitor';
    END IF;

    IF p.effective_maintenance_level IN ('M2','M3')
       AND p.governing_monitor_product_version_uuid IS NULL THEN
        RETURN QUERY SELECT
            'UPDATE_POLICY_MONITOR_REQUIRED','error',
            'M2/M3 UpdatePolicy requires governing Monitor';
    END IF;

    IF p.governing_monitor_product_version_uuid IS NOT NULL THEN
        SELECT pv.product_type,ev.version_status
          INTO monitor_product_type,monitor_state
          FROM product.product_version pv
          JOIN core.entity_version ev ON ev.version_uuid=pv.version_uuid
         WHERE pv.version_uuid=p.governing_monitor_product_version_uuid;

        IF monitor_product_type IS DISTINCT FROM 'evidence_monitor' THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_MONITOR_WRONG_TYPE','error',
                'Governing Monitor is missing or is not evidence_monitor';
        END IF;

        IF monitor_state IN ('superseded','archived','invalidated')
           OR monitor_state IS NULL THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_MONITOR_NOT_CURRENT','warning',
                'Governing Monitor version is no longer current';
        END IF;

        SELECT * INTO mt
          FROM maintenance.monitor_target x
         WHERE x.monitor_product_version_uuid=
               p.governing_monitor_product_version_uuid;

        IF NOT FOUND THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_MONITOR_TARGET_MISSING','error',
                'Governing Monitor has no MonitorTarget';
        ELSIF mt.target_product_version_uuid
                  IS DISTINCT FROM p.target_product_version_uuid
              OR mt.target_investigation_version_uuid
                  IS DISTINCT FROM p.target_investigation_version_uuid THEN
            RETURN QUERY SELECT
                'UPDATE_POLICY_MONITOR_TARGET_MISMATCH','error',
                'Governing Monitor target differs from UpdatePolicy target';
        END IF;
    END IF;

    IF p.effective_maintenance_level='M3' THEN
        RETURN QUERY SELECT
            'M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL','error',
            'M3 policy is representable but formal living-evidence operation remains blocked';
    END IF;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- HARDENING 4 — dynamic UpdateSignal/source issues.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.update_signal_issues(
    p_update_signal_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    s maintenance.update_signal%ROWTYPE;
    p maintenance.update_policy%ROWTYPE;
    primary_count integer;
    src record;
    source_monitor uuid;
    source_status text;
    alert_type text;
    alert_target_product uuid;
    alert_target_inv uuid;
    locator_count integer;
BEGIN
    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=p_update_signal_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_UPDATE_SIGNAL','error','UpdateSignal does not exist';
        RETURN;
    END IF;

    SELECT * INTO p
      FROM maintenance.update_policy
     WHERE update_policy_uuid=s.update_policy_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'UPDATE_SIGNAL_POLICY_MISSING','error',
            'UpdateSignal references missing UpdatePolicy';
    ELSIF p.record_status<>'active' THEN
        RETURN QUERY SELECT
            'UPDATE_SIGNAL_POLICY_NOT_ACTIVE','warning',
            'UpdateSignal UpdatePolicy is no longer active';
    END IF;

    IF NOT maintenance.signal_mapping_is_valid(
        s.signal_type,s.signal_class,s.trigger_class,s.rationale
    ) THEN
        RETURN QUERY SELECT
            'UPDATE_SIGNAL_MAPPING_INVALID','error',
            'UpdateSignal type/class/trigger mapping is invalid';
    END IF;

    IF NOT maintenance.assert_verification_metadata(
        s.verification_status,s.verified_by,
        s.verifier_actor_type,s.verified_at
    ) THEN
        RETURN QUERY SELECT
            'UPDATE_SIGNAL_VERIFICATION_INVALID','error',
            'UpdateSignal verification metadata is inconsistent';
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

    FOR src IN
        SELECT *
          FROM maintenance.update_signal_source uss
         WHERE uss.update_signal_uuid=s.update_signal_uuid
    LOOP
        locator_count:=num_nonnulls(
            src.monitor_cycle_uuid,
            src.candidate_assessment_uuid,
            src.evidence_event_uuid,
            src.alert_product_version_uuid,
            src.search_hit_uuid,
            src.source_entity_version_uuid,
            src.source_artifact_uuid,
            src.source_uri
        );

        IF locator_count<>1 THEN
            RETURN QUERY SELECT
                'UPDATE_SIGNAL_SOURCE_LOCATOR_COUNT','error',
                'UpdateSignalSource must have exactly one locator';
            CONTINUE;
        END IF;

        IF (src.source_type='monitor_cycle') IS DISTINCT FROM
              (src.monitor_cycle_uuid IS NOT NULL)
           OR (src.source_type='candidate_assessment') IS DISTINCT FROM
              (src.candidate_assessment_uuid IS NOT NULL)
           OR (src.source_type='evidence_event') IS DISTINCT FROM
              (src.evidence_event_uuid IS NOT NULL)
           OR (src.source_type='alert_product_version') IS DISTINCT FROM
              (src.alert_product_version_uuid IS NOT NULL)
           OR (src.source_type='search_hit') IS DISTINCT FROM
              (src.search_hit_uuid IS NOT NULL)
           OR (src.source_type='entity_version') IS DISTINCT FROM
              (src.source_entity_version_uuid IS NOT NULL)
           OR (src.source_type='artifact') IS DISTINCT FROM
              (src.source_artifact_uuid IS NOT NULL)
           OR (src.source_type='uri') IS DISTINCT FROM
              (src.source_uri IS NOT NULL) THEN
            RETURN QUERY SELECT
                'UPDATE_SIGNAL_SOURCE_TYPE_LOCATOR_MISMATCH','error',
                'UpdateSignalSource source_type/locator mismatch';
        END IF;

        source_monitor:=NULL;
        source_status:=NULL;

        IF src.monitor_cycle_uuid IS NOT NULL THEN
            SELECT mc.monitor_product_version_uuid
              INTO source_monitor
              FROM maintenance.monitor_cycle mc
             WHERE mc.cycle_uuid=src.monitor_cycle_uuid;
            IF source_monitor IS NULL THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_MONITOR_CYCLE_MISSING','error',
                    'MonitorCycle source no longer exists';
            END IF;
        ELSIF src.candidate_assessment_uuid IS NOT NULL THEN
            SELECT ca.record_status,mc.monitor_product_version_uuid
              INTO source_status,source_monitor
              FROM maintenance.candidate_assessment ca
              JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ca.cycle_uuid
             WHERE ca.candidate_assessment_uuid=src.candidate_assessment_uuid;
            IF source_status IS DISTINCT FROM 'active' THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_CANDIDATE_NOT_ACTIVE','error',
                    'CandidateAssessment source is missing or no longer active';
            END IF;
        ELSIF src.evidence_event_uuid IS NOT NULL THEN
            SELECT ee.status,mc.monitor_product_version_uuid
              INTO source_status,source_monitor
              FROM maintenance.evidence_event ee
              JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=ee.cycle_uuid
             WHERE ee.evidence_event_uuid=src.evidence_event_uuid;
            IF source_status IS DISTINCT FROM 'active' THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_EVIDENCE_EVENT_NOT_ACTIVE','error',
                    'EvidenceEvent source is missing or no longer active';
            END IF;
        ELSIF src.search_hit_uuid IS NOT NULL THEN
            SELECT mc.monitor_product_version_uuid
              INTO source_monitor
              FROM investigation.search_hit sh
              JOIN maintenance.cycle_search cs ON cs.search_uuid=sh.search_uuid
              JOIN maintenance.monitor_cycle mc ON mc.cycle_uuid=cs.cycle_uuid
             WHERE sh.search_hit_uuid=src.search_hit_uuid;
            IF source_monitor IS NULL THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_SEARCH_HIT_OUTSIDE_MONITOR','error',
                    'SearchHit source does not belong to a MonitorCycle';
            END IF;
        ELSIF src.alert_product_version_uuid IS NOT NULL THEN
            SELECT pv.product_type
              INTO alert_type
              FROM product.product_version pv
             WHERE pv.version_uuid=src.alert_product_version_uuid;
            IF alert_type IS DISTINCT FROM 'evidence_alert' THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_ALERT_WRONG_TYPE','error',
                    'Alert source is missing or is not evidence_alert';
            END IF;

            SELECT a.target_product_version_uuid,
                   a.target_investigation_version_uuid
              INTO alert_target_product,alert_target_inv
              FROM maintenance.evidence_alert a
             WHERE a.alert_product_version_uuid=src.alert_product_version_uuid;

            IF alert_target_product IS DISTINCT FROM p.target_product_version_uuid
               OR alert_target_inv IS DISTINCT FROM
                  p.target_investigation_version_uuid THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_ALERT_TARGET_DRIFT','error',
                    'Alert source target differs from UpdatePolicy target';
            END IF;
        ELSIF src.source_entity_version_uuid IS NOT NULL THEN
            SELECT ev.version_status
              INTO source_status
              FROM core.entity_version ev
             WHERE ev.version_uuid=src.source_entity_version_uuid;
            IF source_status IN ('invalidated','archived')
               OR source_status IS NULL THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_ENTITY_SOURCE_NOT_ACTIVE','error',
                    'EntityVersion source is invalid, archived or missing';
            END IF;
        ELSIF src.source_artifact_uuid IS NOT NULL THEN
            SELECT a.status
              INTO source_status
              FROM artifact.artifact a
             WHERE a.artifact_uuid=src.source_artifact_uuid;
            IF source_status IS DISTINCT FROM 'active' THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_ARTIFACT_NOT_ACTIVE','error',
                    'Artifact source is missing or not active';
            END IF;
        END IF;

        IF src.source_type IN (
            'monitor_cycle','candidate_assessment','evidence_event','search_hit'
        ) THEN
            IF p.governing_monitor_product_version_uuid IS NULL
               OR source_monitor IS DISTINCT FROM
                  p.governing_monitor_product_version_uuid THEN
                RETURN QUERY SELECT
                    'UPDATE_SIGNAL_SOURCE_MONITOR_MISMATCH','error',
                    'Monitor-derived source differs from governing Monitor';
            END IF;
        END IF;
    END LOOP;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- HARDENING 5 — dynamic MaterialityAssessment issues.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.materiality_assessment_issues(
    p_materiality_assessment_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    ma maintenance.materiality_assessment%ROWTYPE;
    s maintenance.update_signal%ROWTYPE;
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

    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=ma.update_signal_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MATERIALITY_SIGNAL_MISSING','error',
            'MaterialityAssessment UpdateSignal is missing';
    ELSIF s.status<>'active' AND ma.record_status='active' THEN
        RETURN QUERY SELECT
            'ACTIVE_MATERIALITY_SIGNAL_NOT_ACTIVE','warning',
            'Active MaterialityAssessment references non-active UpdateSignal';
    END IF;

    IF NOT maintenance.assert_verification_metadata(
        ma.verification_status,ma.verified_by,
        ma.verifier_actor_type,ma.verified_at
    ) THEN
        RETURN QUERY SELECT
            'MATERIALITY_VERIFICATION_INVALID','error',
            'MaterialityAssessment verification metadata is inconsistent';
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

    IF ma.outcome='potentially_material'
       AND NOT EXISTS (
            SELECT 1 FROM maintenance.materiality_dimension md
             WHERE md.materiality_assessment_uuid=ma.materiality_assessment_uuid
               AND md.dimension_status IN ('potential','uncertain')
       ) THEN
        RETURN QUERY SELECT
            'MISSING_POTENTIAL_DIMENSION','error',
            'Potentially material assessment requires potential/uncertain dimension';
    END IF;

    IF ma.outcome='no_material_change'
       AND EXISTS (
            SELECT 1 FROM maintenance.materiality_dimension md
             WHERE md.materiality_assessment_uuid=ma.materiality_assessment_uuid
               AND md.dimension_status IN ('confirmed','threat')
       ) THEN
        RETURN QUERY SELECT
            'NO_MATERIAL_CHANGE_INCOMPATIBLE_DIMENSION','error',
            'No-material-change assessment cannot contain confirmed/threat dimension';
    END IF;
END;
$fn$;

-- ---------------------------------------------------------------------------
-- HARDENING 6 — dynamic UpdateDecision issues.
-- Historical CurrencyState linkages are checked without requiring the linked
-- CurrencyState to remain active forever.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION maintenance.update_decision_issues(
    p_update_decision_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
    d maintenance.update_decision%ROWTYPE;
    ma maintenance.materiality_assessment%ROWTYPE;
    s maintenance.update_signal%ROWTYPE;
    p maintenance.update_policy%ROWTYPE;
    link_row maintenance.update_decision_currency_state%ROWTYPE;
    cs product.currency_state%ROWTYPE;
    expected_status text;
BEGIN
    SELECT * INTO d
      FROM maintenance.update_decision
     WHERE update_decision_uuid=p_update_decision_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_UPDATE_DECISION','error',
            'UpdateDecision does not exist';
        RETURN;
    END IF;

    SELECT * INTO ma
      FROM maintenance.materiality_assessment
     WHERE materiality_assessment_uuid=d.materiality_assessment_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'UPDATE_DECISION_ASSESSMENT_MISSING','error',
            'UpdateDecision MaterialityAssessment is missing';
    ELSE
        IF ma.update_signal_uuid<>d.update_signal_uuid THEN
            RETURN QUERY SELECT
                'UPDATE_DECISION_SIGNAL_ASSESSMENT_MISMATCH','error',
                'UpdateDecision signal differs from MaterialityAssessment signal';
        END IF;
        IF d.record_status='active' AND ma.record_status<>'active' THEN
            RETURN QUERY SELECT
                'ACTIVE_DECISION_ASSESSMENT_SUPERSEDED','warning',
                'Active UpdateDecision references superseded MaterialityAssessment';
        END IF;
    END IF;

    SELECT * INTO s
      FROM maintenance.update_signal
     WHERE update_signal_uuid=d.update_signal_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'UPDATE_DECISION_SIGNAL_MISSING','error',
            'UpdateDecision UpdateSignal is missing';
    ELSIF d.record_status='active' AND s.status<>'active' THEN
        RETURN QUERY SELECT
            'ACTIVE_DECISION_SIGNAL_NOT_ACTIVE','warning',
            'Active UpdateDecision references non-active UpdateSignal';
    END IF;

    IF NOT maintenance.assert_verification_metadata(
        d.verification_status,d.verified_by,
        d.verifier_actor_type,d.verified_at
    ) THEN
        RETURN QUERY SELECT
            'UPDATE_DECISION_VERIFICATION_INVALID','error',
            'UpdateDecision verification metadata is inconsistent';
    END IF;

    IF d.authority_status='authoritative' THEN
        IF d.actor_type='ai_system' THEN
            RETURN QUERY SELECT
                'UPDATE_DECISION_AI_AUTHORITATIVE','error',
                'AI cannot be authoritative UpdateDecision actor';
        END IF;
        IF d.verification_status NOT IN ('human_verified','human_consensus') THEN
            RETURN QUERY SELECT
                'UPDATE_DECISION_AUTHORITY_NOT_HUMAN_VERIFIED','error',
                'Authoritative UpdateDecision requires human verification';
        END IF;
        IF ma.materiality_assessment_uuid IS NOT NULL
           AND ma.verification_status NOT IN (
               'human_verified','human_consensus'
           ) THEN
            RETURN QUERY SELECT
                'UPDATE_DECISION_ASSESSMENT_NOT_HUMAN_VERIFIED','error',
                'Authoritative UpdateDecision requires human-verified assessment';
        END IF;
    END IF;

    IF s.update_signal_uuid IS NOT NULL THEN
        SELECT * INTO p
          FROM maintenance.update_policy
         WHERE update_policy_uuid=s.update_policy_uuid;
    END IF;

    IF p.target_investigation_version_uuid IS NOT NULL
       AND d.currency_action<>'no_change' THEN
        RETURN QUERY SELECT
            'UPDATE_DECISION_INVESTIGATION_CURRENCY_ACTION','error',
            'InvestigationVersion target cannot receive CurrencyState action';
    END IF;

    SELECT * INTO link_row
      FROM maintenance.update_decision_currency_state l
     WHERE l.update_decision_uuid=d.update_decision_uuid;

    IF d.currency_action='no_change' THEN
        IF FOUND THEN
            RETURN QUERY SELECT
                'UPDATE_DECISION_NO_CHANGE_HAS_CURRENCY_LINK','error',
                'no_change decision cannot have CurrencyState linkage';
        END IF;
        RETURN;
    END IF;

    IF d.authority_status='authoritative' AND NOT FOUND THEN
        RETURN QUERY SELECT
            'UPDATE_DECISION_CURRENCY_LINK_MISSING','warning',
            'Authoritative currency action has no CurrencyState linkage';
        RETURN;
    END IF;

    IF FOUND THEN
        SELECT * INTO cs
          FROM product.currency_state
         WHERE currency_state_uuid=link_row.currency_state_uuid;

        expected_status:=CASE d.currency_action
            WHEN 'set_current' THEN 'current'
            WHEN 'set_under_evaluation' THEN 'under_evaluation'
            WHEN 'set_update_recommended' THEN 'update_recommended'
            WHEN 'set_outdated' THEN 'outdated'
            ELSE NULL
        END;

        IF cs.currency_state_uuid IS NULL THEN
            RETURN QUERY SELECT
                'UPDATE_DECISION_CURRENCY_STATE_MISSING','error',
                'Linked CurrencyState no longer exists';
        ELSE
            IF p.target_product_version_uuid IS NULL
               OR cs.product_version_uuid<>p.target_product_version_uuid THEN
                RETURN QUERY SELECT
                    'UPDATE_DECISION_CURRENCY_TARGET_MISMATCH','error',
                    'Linked CurrencyState target does not match UpdatePolicy target';
            END IF;
            IF expected_status IS NULL
               OR cs.currency_status<>expected_status THEN
                RETURN QUERY SELECT
                    'UPDATE_DECISION_CURRENCY_STATUS_MISMATCH','error',
                    'Linked CurrencyState status does not match decision action';
            END IF;
        END IF;
    END IF;
END;
$fn$;

COMMIT;
