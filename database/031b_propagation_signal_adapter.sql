-- Migration 031 fragment B — PropagationCandidate -> UpdateSignalSource adapter
-- Loaded by 031_propagation_rebaseline_contract.sql.

ALTER TABLE maintenance.update_signal_source
  ADD COLUMN IF NOT EXISTS propagation_candidate_uuid uuid;

DO $do$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname='fk_update_signal_source_propagation_candidate'
       AND conrelid='maintenance.update_signal_source'::regclass
  ) THEN
    ALTER TABLE maintenance.update_signal_source
      ADD CONSTRAINT fk_update_signal_source_propagation_candidate
      FOREIGN KEY(propagation_candidate_uuid)
      REFERENCES maintenance.propagation_candidate(propagation_candidate_uuid);
  END IF;
END;
$do$;

DO $do$
DECLARE c record;
BEGIN
  FOR c IN
    SELECT conname
      FROM pg_constraint
     WHERE conrelid='maintenance.update_signal_source'::regclass
       AND contype='c'
       AND (
         pg_get_constraintdef(oid) ILIKE '%source_type%'
         OR (
           pg_get_constraintdef(oid) ILIKE '%monitor_cycle_uuid%'
           AND pg_get_constraintdef(oid) ILIKE '%source_uri%'
         )
       )
  LOOP
    EXECUTE format(
      'ALTER TABLE maintenance.update_signal_source DROP CONSTRAINT %I',
      c.conname
    );
  END LOOP;
END;
$do$;

ALTER TABLE maintenance.update_signal_source
  ADD CONSTRAINT update_signal_source_type_v031_check CHECK (
    source_type IN (
      'monitor_cycle','candidate_assessment','evidence_event',
      'alert_product_version','search_hit','entity_version',
      'artifact','uri','propagation_candidate'
    )
  );

ALTER TABLE maintenance.update_signal_source
  ADD CONSTRAINT update_signal_source_locator_v031_check CHECK (
    num_nonnulls(
      monitor_cycle_uuid,candidate_assessment_uuid,evidence_event_uuid,
      alert_product_version_uuid,search_hit_uuid,source_entity_version_uuid,
      source_artifact_uuid,source_uri,propagation_candidate_uuid
    )=1
    AND (
      (source_type='monitor_cycle' AND monitor_cycle_uuid IS NOT NULL)
      OR (source_type='candidate_assessment' AND candidate_assessment_uuid IS NOT NULL)
      OR (source_type='evidence_event' AND evidence_event_uuid IS NOT NULL)
      OR (source_type='alert_product_version' AND alert_product_version_uuid IS NOT NULL)
      OR (source_type='search_hit' AND search_hit_uuid IS NOT NULL)
      OR (source_type='entity_version' AND source_entity_version_uuid IS NOT NULL)
      OR (source_type='artifact' AND source_artifact_uuid IS NOT NULL)
      OR (source_type='uri' AND source_uri IS NOT NULL)
      OR (source_type='propagation_candidate' AND propagation_candidate_uuid IS NOT NULL)
    )
  );

CREATE OR REPLACE FUNCTION maintenance.assert_update_signal_source_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
    s maintenance.update_signal%ROWTYPE;
    p maintenance.update_policy%ROWTYPE;
    pc maintenance.propagation_candidate%ROWTYPE;
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

    IF NEW.propagation_candidate_uuid IS NOT NULL THEN
        SELECT * INTO pc
          FROM maintenance.propagation_candidate
         WHERE propagation_candidate_uuid=NEW.propagation_candidate_uuid;

        IF NOT FOUND
           OR pc.record_status<>'active'
           OR pc.assessment_status<>'assessed'
           OR pc.disposition<>'open_update_signal'
           OR pc.authority_status<>'authoritative' THEN
            RAISE EXCEPTION
              'Propagation candidate source must be active authoritative assessed/open_update_signal';
        END IF;

        IF pc.impacted_version_uuid IS DISTINCT FROM
           COALESCE(
             p.target_product_version_uuid,
             p.target_investigation_version_uuid
           ) THEN
            RAISE EXCEPTION
              'Propagation candidate target must match UpdatePolicy target';
        END IF;

        RETURN NEW;
    END IF;

    IF NEW.monitor_cycle_uuid IS NOT NULL THEN
        SELECT mc.monitor_product_version_uuid
          INTO source_monitor
          FROM maintenance.monitor_cycle mc
         WHERE mc.cycle_uuid=NEW.monitor_cycle_uuid;

    ELSIF NEW.candidate_assessment_uuid IS NOT NULL THEN
        SELECT ca.record_status,mc.monitor_product_version_uuid
          INTO source_status,source_monitor
          FROM maintenance.candidate_assessment ca
          JOIN maintenance.monitor_cycle mc
            ON mc.cycle_uuid=ca.cycle_uuid
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
        SELECT a.target_product_version_uuid,
               a.target_investigation_version_uuid
          INTO alert_target_product,alert_target_inv
          FROM maintenance.evidence_alert a
         WHERE a.alert_product_version_uuid=NEW.alert_product_version_uuid;

        IF alert_target_product IS DISTINCT FROM p.target_product_version_uuid
           OR alert_target_inv IS DISTINCT FROM
              p.target_investigation_version_uuid THEN
            RAISE EXCEPTION 'Alert source target must match UpdatePolicy target';
        END IF;

    ELSIF NEW.source_entity_version_uuid IS NOT NULL THEN
        SELECT ev.version_status
          INTO source_status
          FROM core.entity_version ev
         WHERE ev.version_uuid=NEW.source_entity_version_uuid;

        IF source_status IN ('invalidated','archived')
           OR source_status IS NULL THEN
            RAISE EXCEPTION 'EntityVersion source is invalid/archived/missing';
        END IF;

    ELSIF NEW.source_artifact_uuid IS NOT NULL THEN
        SELECT a.status
          INTO source_status
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
    pc maintenance.propagation_candidate%ROWTYPE;
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
            src.source_uri,
            src.propagation_candidate_uuid
        );

        IF locator_count<>1 THEN
            RETURN QUERY SELECT
              'UPDATE_SIGNAL_SOURCE_LOCATOR_COUNT','error',
              'UpdateSignalSource must have exactly one locator';
            CONTINUE;
        END IF;

        IF src.propagation_candidate_uuid IS NOT NULL THEN
            SELECT * INTO pc
              FROM maintenance.propagation_candidate
             WHERE propagation_candidate_uuid=src.propagation_candidate_uuid;

            IF pc.record_status IS DISTINCT FROM 'active'
               OR pc.assessment_status IS DISTINCT FROM 'assessed'
               OR pc.disposition IS DISTINCT FROM 'open_update_signal'
               OR pc.authority_status IS DISTINCT FROM 'authoritative' THEN
                RETURN QUERY SELECT
                  'UPDATE_SIGNAL_PROPAGATION_SOURCE_INVALID','error',
                  'PropagationCandidate source is not active authoritative assessed/open_update_signal';
            END IF;

            IF pc.impacted_version_uuid IS DISTINCT FROM
               COALESCE(
                 p.target_product_version_uuid,
                 p.target_investigation_version_uuid
               ) THEN
                RETURN QUERY SELECT
                  'UPDATE_SIGNAL_PROPAGATION_TARGET_MISMATCH','error',
                  'PropagationCandidate source target differs from UpdatePolicy target';
            END IF;

            CONTINUE;
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
               OR alert_target_inv IS DISTINCT FROM p.target_investigation_version_uuid THEN
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
