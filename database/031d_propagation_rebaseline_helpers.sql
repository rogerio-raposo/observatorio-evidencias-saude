-- Migration 031 fragment D — issue/readiness helpers + preserved M3 blocker
-- Loaded by 031_propagation_rebaseline_contract.sql.

CREATE OR REPLACE FUNCTION maintenance.propagation_candidate_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
  c maintenance.propagation_candidate%ROWTYPE;
  a maintenance.propagation_assessment%ROWTYPE;
BEGIN
  SELECT * INTO c
    FROM maintenance.propagation_candidate
   WHERE propagation_candidate_uuid=p;

  IF NOT FOUND THEN
    RETURN QUERY SELECT
      'MISSING_PROPAGATION_CANDIDATE','error',
      'PropagationCandidate missing';
    RETURN;
  END IF;

  SELECT * INTO a
    FROM maintenance.propagation_assessment
   WHERE propagation_assessment_uuid=c.propagation_assessment_uuid;

  IF c.target_class<>maintenance.propagation_target_class(c.impacted_version_uuid) THEN
    RETURN QUERY SELECT
      'PROPAGATION_TARGET_CLASS_MISMATCH','error',
      'Target classification mismatch';
  END IF;

  IF c.disposition='no_action_supported'
     AND (
       a.lineage_validation_status<>'validated_against_canonical_relations'
       OR NOT EXISTS (
         SELECT 1
           FROM maintenance.propagation_path x
          WHERE x.propagation_candidate_uuid=p
            AND x.path_status='complete'
       )
       OR EXISTS (
         SELECT 1
           FROM maintenance.propagation_path x
          WHERE x.propagation_candidate_uuid=p
            AND x.path_status IN (
              'cycle_detected','depth_limit_reached',
              'projection_divergence','incomplete_unknown'
            )
       )
     ) THEN
    RETURN QUERY SELECT
      'PROPAGATION_NO_ACTION_LINEAGE_INCOMPLETE','error',
      'No-action cannot rely on incomplete lineage';
  END IF;

  IF c.disposition='open_update_signal'
     AND maintenance.active_update_policy_for_version(c.impacted_version_uuid) IS NULL THEN
    RETURN QUERY SELECT
      'PROPAGATION_OPEN_SIGNAL_POLICY_MISSING','error',
      'open_update_signal requires active exact-target policy';
  END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.propagation_assessment_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
  a maintenance.propagation_assessment%ROWTYPE;
  x record;
BEGIN
  SELECT * INTO a
    FROM maintenance.propagation_assessment
   WHERE propagation_assessment_uuid=p;

  IF NOT FOUND THEN
    RETURN QUERY SELECT
      'MISSING_PROPAGATION_ASSESSMENT','error',
      'PropagationAssessment missing';
    RETURN;
  END IF;

  FOR x IN
    SELECT propagation_candidate_uuid
      FROM maintenance.propagation_candidate
     WHERE propagation_assessment_uuid=p
       AND record_status='active'
  LOOP
    RETURN QUERY
    SELECT *
      FROM maintenance.propagation_candidate_issues(
        x.propagation_candidate_uuid
      );
  END LOOP;
END;
$fn$;

CREATE OR REPLACE FUNCTION maintenance.rebaseline_decision_issues(p uuid)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE
  d maintenance.rebaseline_decision%ROWTYPE;
  ns text;
  last_to uuid;
  n integer;
  pl maintenance.rebaseline_policy_link%ROWTYPE;
  np maintenance.update_policy%ROWTYPE;
  ms text;
  mt maintenance.monitor_target%ROWTYPE;
BEGIN
  SELECT * INTO d
    FROM maintenance.rebaseline_decision
   WHERE rebaseline_decision_uuid=p;

  IF NOT FOUND THEN
    RETURN QUERY SELECT
      'MISSING_REBASELINE_DECISION','error',
      'RebaselineDecision missing';
    RETURN;
  END IF;

  SELECT version_status
    INTO ns
    FROM core.entity_version
   WHERE version_uuid=COALESCE(
     d.new_target_product_version_uuid,
     d.new_target_investigation_version_uuid
   );

  SELECT count(*)
    INTO n
    FROM maintenance.rebaseline_version_chain_step
   WHERE rebaseline_decision_uuid=p;

  SELECT to_version_uuid
    INTO last_to
    FROM maintenance.rebaseline_version_chain_step
   WHERE rebaseline_decision_uuid=p
   ORDER BY step_no DESC
   LIMIT 1;

  IF n=0
     OR last_to IS DISTINCT FROM COALESCE(
       d.new_target_product_version_uuid,
       d.new_target_investigation_version_uuid
     ) THEN
    RETURN QUERY SELECT
      'REBASELINE_VERSION_CHAIN_MISMATCH','error',
      'Version chain incomplete';
  END IF;

  SELECT * INTO pl
    FROM maintenance.rebaseline_policy_link
   WHERE rebaseline_decision_uuid=p;

  IF d.decision_stage='activated' THEN
    IF ns<>'current' THEN
      RETURN QUERY SELECT
        'REBASELINE_NEW_TARGET_NOT_CURRENT','error',
        'Activated rebaseline requires current new target';
    END IF;

    IF pl.rebaseline_decision_uuid IS NULL THEN
      RETURN QUERY SELECT
        'REBASELINE_MISSING_POLICY_LINK','error',
        'Activated rebaseline requires policy disposition';
    ELSIF pl.policy_disposition IN ('pending','maintenance_policy_required') THEN
      RETURN QUERY SELECT
        'REBASELINE_POLICY_UNRESOLVED','error',
        'Policy disposition unresolved';
    END IF;

    IF EXISTS (
      SELECT 1
        FROM maintenance.rebaseline_risk_profile_link r
       WHERE r.rebaseline_decision_uuid=p
         AND r.profile_disposition='pending'
    ) THEN
      RETURN QUERY SELECT
        'REBASELINE_PROFILE_PENDING','error',
        'Risk-profile disposition pending';
    END IF;

    IF pl.new_update_policy_uuid IS NOT NULL THEN
      SELECT * INTO np
        FROM maintenance.update_policy
       WHERE update_policy_uuid=pl.new_update_policy_uuid;

      IF np.effective_maintenance_level IN ('M2','M3') THEN
        SELECT * INTO mt
          FROM maintenance.monitor_target
         WHERE monitor_product_version_uuid=
               np.governing_monitor_product_version_uuid;

        SELECT operational_status
          INTO ms
          FROM maintenance.monitor_state
         WHERE monitor_product_version_uuid=
               np.governing_monitor_product_version_uuid
           AND record_status='active';

        IF np.governing_monitor_product_version_uuid IS NULL
           OR mt.monitor_product_version_uuid IS NULL
           OR COALESCE(
                mt.target_product_version_uuid,
                mt.target_investigation_version_uuid
              ) IS DISTINCT FROM COALESCE(
                d.new_target_product_version_uuid,
                d.new_target_investigation_version_uuid
              )
           OR ms IS DISTINCT FROM 'active'
           OR NOT EXISTS (
             SELECT 1
               FROM core.entity_version ev
              WHERE ev.version_uuid=
                    np.governing_monitor_product_version_uuid
                AND ev.version_status='current'
           ) THEN
          RETURN QUERY SELECT
            'REBASELINE_MONITOR_NOT_READY','error',
            'New governing Monitor not ready';
        END IF;
      END IF;

      IF np.effective_maintenance_level='M3' THEN
        RETURN QUERY SELECT
          'M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL','error',
          'M3 remains formally blocked';
      END IF;
    END IF;
  END IF;
END;
$fn$;

-- Preserve the M3 blocker explicitly in integrated readiness.
CREATE OR REPLACE FUNCTION maintenance.operational_control_readiness(
  p_update_policy_uuid uuid
)
RETURNS TABLE(issue_code text,severity text,message text)
LANGUAGE plpgsql
STABLE
AS $fn$
DECLARE p maintenance.update_policy%ROWTYPE;
BEGIN
  SELECT * INTO p
    FROM maintenance.update_policy
   WHERE update_policy_uuid=p_update_policy_uuid;

  IF NOT FOUND THEN
    RETURN QUERY SELECT
      'MISSING_UPDATE_POLICY','error','UpdatePolicy missing';
    RETURN;
  END IF;

  IF p.effective_maintenance_level='M3' THEN
    RETURN QUERY SELECT
      'M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL','error',
      'M3 remains formally blocked';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM maintenance.sla_rule r
     WHERE r.update_policy_uuid=p_update_policy_uuid
       AND r.record_status='active'
     GROUP BY r.clock_code,r.selection_precedence
    HAVING count(*)>1
  ) THEN
    RETURN QUERY SELECT
      'AMBIGUOUS_SLA_RULE_SELECTION','error',
      'Active SLA rule selection is ambiguous';
  END IF;
END;
$fn$;
