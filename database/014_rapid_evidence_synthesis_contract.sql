-- OES-DBM-2026-0014
-- Fase 3 — Rapid Evidence Synthesis N3 contract
-- Depends on: baseline + migrations 002–013
-- Date: 2026-10-05
-- Adds transversal methodological governance structures reusable by N3/N4.

BEGIN;

-- ---------------------------------------------------------------------------
-- METHOD DECISIONS
-- ---------------------------------------------------------------------------

CREATE TABLE investigation.method_decision (
    method_decision_uuid uuid PRIMARY KEY,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    decision_type text NOT NULL CHECK (
        decision_type IN (
            'rapid_restriction',
            'protocol_deviation',
            'method_change',
            'rerouting_trigger',
            'other'
        )
    ),
    stage text NOT NULL CHECK (
        stage IN (
            'question',
            'search',
            'screening',
            'extraction',
            'appraisal',
            'synthesis',
            'certainty',
            'reporting',
            'cross_cutting'
        )
    ),
    decision_code text NOT NULL CHECK (length(btrim(decision_code)) > 0),
    planned_flag boolean NOT NULL DEFAULT false,
    rationale text NOT NULL CHECK (length(btrim(rationale)) > 0),
    risk_payload jsonb,
    mitigation_payload jsonb,
    impact_payload jsonb,
    resolution_status text NOT NULL CHECK (
        resolution_status IN (
            'open',
            'accepted',
            'mitigated',
            'resolved',
            'rerouted',
            'rejected'
        )
    ),
    decided_by text NOT NULL CHECK (length(btrim(decided_by)) > 0),
    decided_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    linked_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_method_decision_uuid uuid,
    UNIQUE (method_decision_uuid, investigation_version_uuid),
    FOREIGN KEY (
        supersedes_method_decision_uuid,
        investigation_version_uuid
    ) REFERENCES investigation.method_decision(
        method_decision_uuid,
        investigation_version_uuid
    ),
    CHECK (
        supersedes_method_decision_uuid IS NULL
        OR supersedes_method_decision_uuid <> method_decision_uuid
    ),
    CHECK (
        decision_type <> 'rapid_restriction'
        OR (risk_payload IS NOT NULL AND mitigation_payload IS NOT NULL)
    ),
    CHECK (
        decision_type <> 'protocol_deviation'
        OR planned_flag = false
    )
);

CREATE INDEX ix_method_decision_investigation
    ON investigation.method_decision(investigation_version_uuid);

CREATE INDEX ix_method_decision_type_stage
    ON investigation.method_decision(
        investigation_version_uuid,
        decision_type,
        stage
    )
    WHERE record_status = 'active';

-- ---------------------------------------------------------------------------
-- QUALITY CONTROL RECORDS
-- ---------------------------------------------------------------------------

CREATE TABLE investigation.quality_control_record (
    quality_control_uuid uuid PRIMARY KEY,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    stage text NOT NULL CHECK (
        stage IN (
            'search',
            'screening',
            'extraction',
            'appraisal',
            'synthesis',
            'certainty',
            'reporting',
            'cross_cutting'
        )
    ),
    control_type text NOT NULL CHECK (
        control_type IN (
            'search_strategy_verification',
            'search_strategy_peer_review',
            'screening_pilot',
            'screening_secondary_verification',
            'critical_data_verification',
            'risk_of_bias_verification',
            'synthesis_statistical_review',
            'certainty_verification',
            'reporting_verification',
            'other'
        )
    ),
    actor text NOT NULL CHECK (length(btrim(actor)) > 0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    qualification_payload jsonb,
    independent_flag boolean NOT NULL DEFAULT false,
    decision text NOT NULL CHECK (
        decision IN ('passed','revise','failed','not_applicable')
    ),
    scope_payload jsonb NOT NULL,
    agreement_payload jsonb,
    discrepancy_payload jsonb,
    resolution_payload jsonb,
    performed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    evidence_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    notes text,
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_quality_control_uuid uuid,
    UNIQUE (quality_control_uuid, investigation_version_uuid),
    FOREIGN KEY (
        supersedes_quality_control_uuid,
        investigation_version_uuid
    ) REFERENCES investigation.quality_control_record(
        quality_control_uuid,
        investigation_version_uuid
    ),
    CHECK (
        supersedes_quality_control_uuid IS NULL
        OR supersedes_quality_control_uuid <> quality_control_uuid
    ),
    CHECK (
        actor_type NOT IN ('human_reviewer','human_expert')
        OR (
            qualification_payload IS NOT NULL
            AND qualification_payload <> '{}'::jsonb
        )
    ),
    CHECK (
        actor_type <> 'ai_system'
        OR independent_flag = false
    )
);

CREATE INDEX ix_quality_control_investigation
    ON investigation.quality_control_record(investigation_version_uuid);

CREATE INDEX ix_quality_control_type
    ON investigation.quality_control_record(
        investigation_version_uuid,
        control_type,
        decision
    )
    WHERE record_status = 'active';

-- ---------------------------------------------------------------------------
-- APPEND-PRESERVING GUARDS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION investigation.guard_method_decision_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'MethodDecision records are append-preserving and cannot be deleted';
    END IF;

    IF OLD.record_status = 'active'
       AND NEW.record_status = 'superseded'
       AND NEW.method_decision_uuid = OLD.method_decision_uuid
       AND NEW.investigation_version_uuid = OLD.investigation_version_uuid
       AND NEW.decision_type = OLD.decision_type
       AND NEW.stage = OLD.stage
       AND NEW.decision_code = OLD.decision_code
       AND NEW.planned_flag = OLD.planned_flag
       AND NEW.rationale = OLD.rationale
       AND NEW.risk_payload IS NOT DISTINCT FROM OLD.risk_payload
       AND NEW.mitigation_payload IS NOT DISTINCT FROM OLD.mitigation_payload
       AND NEW.impact_payload IS NOT DISTINCT FROM OLD.impact_payload
       AND NEW.resolution_status = OLD.resolution_status
       AND NEW.decided_by = OLD.decided_by
       AND NEW.decided_at = OLD.decided_at
       AND NEW.linked_artifact_uuid IS NOT DISTINCT FROM OLD.linked_artifact_uuid
       AND NEW.supersedes_method_decision_uuid
           IS NOT DISTINCT FROM OLD.supersedes_method_decision_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION
        'MethodDecision material fields are immutable; supersede and append a new record';
END;
$guard$;

CREATE TRIGGER tr_method_decision_append_preserving
BEFORE UPDATE OR DELETE ON investigation.method_decision
FOR EACH ROW EXECUTE FUNCTION investigation.guard_method_decision_mutation();


CREATE OR REPLACE FUNCTION investigation.guard_quality_control_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'QualityControl records are append-preserving and cannot be deleted';
    END IF;

    IF OLD.record_status = 'active'
       AND NEW.record_status = 'superseded'
       AND NEW.quality_control_uuid = OLD.quality_control_uuid
       AND NEW.investigation_version_uuid = OLD.investigation_version_uuid
       AND NEW.stage = OLD.stage
       AND NEW.control_type = OLD.control_type
       AND NEW.actor = OLD.actor
       AND NEW.actor_type = OLD.actor_type
       AND NEW.qualification_payload
           IS NOT DISTINCT FROM OLD.qualification_payload
       AND NEW.independent_flag = OLD.independent_flag
       AND NEW.decision = OLD.decision
       AND NEW.scope_payload = OLD.scope_payload
       AND NEW.agreement_payload IS NOT DISTINCT FROM OLD.agreement_payload
       AND NEW.discrepancy_payload IS NOT DISTINCT FROM OLD.discrepancy_payload
       AND NEW.resolution_payload IS NOT DISTINCT FROM OLD.resolution_payload
       AND NEW.performed_at = OLD.performed_at
       AND NEW.evidence_artifact_uuid
           IS NOT DISTINCT FROM OLD.evidence_artifact_uuid
       AND NEW.notes IS NOT DISTINCT FROM OLD.notes
       AND NEW.supersedes_quality_control_uuid
           IS NOT DISTINCT FROM OLD.supersedes_quality_control_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION
        'QualityControl material fields are immutable; supersede and append a new record';
END;
$guard$;

CREATE TRIGGER tr_quality_control_append_preserving
BEFORE UPDATE OR DELETE ON investigation.quality_control_record
FOR EACH ROW EXECUTE FUNCTION investigation.guard_quality_control_mutation();

-- ---------------------------------------------------------------------------
-- QUALIFIED-CONTROL HELPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION investigation.has_qualified_control(
    p_investigation_version_uuid uuid,
    p_control_type text
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $qc$
    SELECT EXISTS (
        SELECT 1
          FROM investigation.quality_control_record q
         WHERE q.investigation_version_uuid = p_investigation_version_uuid
           AND q.record_status = 'active'
           AND q.control_type = p_control_type
           AND q.actor_type IN ('human_reviewer','human_expert')
           AND q.qualification_payload IS NOT NULL
           AND q.qualification_payload <> '{}'::jsonb
           AND q.independent_flag = true
           AND q.decision = 'passed'
    );
$qc$;


CREATE OR REPLACE FUNCTION investigation.has_search_strategy_qualified_control(
    p_investigation_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $qc$
    SELECT
        investigation.has_qualified_control(
            p_investigation_version_uuid,
            'search_strategy_peer_review'
        )
        OR
        investigation.has_qualified_control(
            p_investigation_version_uuid,
            'search_strategy_verification'
        );
$qc$;

-- ---------------------------------------------------------------------------
-- N3 ASSURANCE / REFERENCES WRAPPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.rapid_evidence_synthesis_assurance_level(
    p_product_version_uuid uuid
)
RETURNS text
LANGUAGE sql
STABLE
AS $wrapper$
    SELECT product.assurance_level(p_product_version_uuid);
$wrapper$;


CREATE OR REPLACE FUNCTION product.rapid_evidence_synthesis_reference_reports(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    report_id text,
    report_entity_uuid uuid,
    report_version_uuid uuid,
    title text,
    publication_date date,
    publication_status text,
    source_locations jsonb
)
LANGUAGE sql
STABLE
AS $wrapper$
    SELECT *
      FROM product.product_reference_reports(p_product_version_uuid);
$wrapper$;

-- ---------------------------------------------------------------------------
-- REQUIRED QUALIFIED CONTROLS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.rapid_evidence_synthesis_missing_controls(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    control_code text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $missing$
DECLARE
    inv_uuid uuid;
    hit_count integer := 0;
    no_evidence boolean := false;
    needs_statistical_review boolean := false;
BEGIN
    SELECT il.investigation_version_uuid
      INTO inv_uuid
      FROM product.investigation_link il
     WHERE il.product_version_uuid = p_product_version_uuid
       AND il.role = 'primary'
     LIMIT 1;

    IF inv_uuid IS NULL THEN
        RETURN;
    END IF;

    IF NOT investigation.has_search_strategy_qualified_control(inv_uuid) THEN
        RETURN QUERY SELECT
            'MISSING_SEARCH_STRATEGY_VERIFICATION',
            'No passed qualified human verification/peer review of the search strategy is recorded';
    END IF;

    SELECT count(*)
      INTO hit_count
      FROM investigation.search_hit sh
      JOIN investigation.search s
        ON s.search_uuid = sh.search_uuid
     WHERE s.investigation_version_uuid = inv_uuid;

    IF hit_count > 0 THEN
        IF NOT investigation.has_qualified_control(
            inv_uuid,
            'screening_pilot'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_SCREENING_PILOT',
                'No passed qualified human screening pilot/calibration is recorded';
        END IF;

        IF NOT investigation.has_qualified_control(
            inv_uuid,
            'screening_secondary_verification'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_QUALIFIED_SCREENING_VERIFICATION',
                'No passed qualified human secondary screening verification is recorded';
        END IF;
    END IF;

    SELECT EXISTS (
        SELECT 1
          FROM product.certainty_link cl
          JOIN appraisal.certainty_assessment_version cav
            ON cav.version_uuid = cl.certainty_assessment_version_uuid
         WHERE cl.product_version_uuid = p_product_version_uuid
           AND cav.evidence_state = 'no_evidence'
    )
      INTO no_evidence;

    IF NOT no_evidence THEN
        IF NOT investigation.has_qualified_control(
            inv_uuid,
            'critical_data_verification'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_QUALIFIED_DATA_VERIFICATION',
                'No passed qualified human verification of critical extracted data is recorded';
        END IF;

        IF NOT investigation.has_qualified_control(
            inv_uuid,
            'risk_of_bias_verification'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION',
                'No passed qualified human verification of material risk-of-bias judgements is recorded';
        END IF;

        IF NOT investigation.has_qualified_control(
            inv_uuid,
            'certainty_verification'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_QUALIFIED_CERTAINTY_VERIFICATION',
                'No passed qualified human verification of material certainty judgements is recorded';
        END IF;
    END IF;

    SELECT EXISTS (
        SELECT 1
          FROM product.synthesis_link sl
          JOIN synthesis.synthesis_version sv
            ON sv.version_uuid = sl.synthesis_version_uuid
         WHERE sl.product_version_uuid = p_product_version_uuid
           AND (
                lower(sv.synthesis_type) LIKE '%meta%'
                OR lower(sv.synthesis_type) IN (
                    'network_meta_analysis',
                    'nma',
                    'pairwise_meta_analysis'
                )
           )
    )
      INTO needs_statistical_review;

    IF needs_statistical_review
       AND NOT investigation.has_qualified_control(
            inv_uuid,
            'synthesis_statistical_review'
       )
    THEN
        RETURN QUERY SELECT
            'MISSING_REQUIRED_STATISTICAL_REVIEW',
            'A quantitative meta-analytic synthesis requires passed qualified human statistical review';
    END IF;

    RETURN;
END;
$missing$;

-- ---------------------------------------------------------------------------
-- N3 PUBLICATION GATE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.rapid_evidence_synthesis_publication_issues(
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
    primary_count integer;
    inv_uuid uuid;
    inv_depth text;
    inv_cutoff date;
    inv_status text;
    protocol_uuid uuid;
    search_source_count integer := 0;
    search_hit_count integer := 0;
    screening_count integer := 0;
    reference_count integer := 0;
    no_evidence boolean := false;
    evidence_available boolean := true;
BEGIN
    SELECT *
      INTO pv
      FROM product.product_version
     WHERE version_uuid = p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_PRODUCT_VERSION','error','ProductVersion does not exist';
        RETURN;
    END IF;

    IF pv.product_type <> 'rapid_evidence_synthesis' THEN
        RETURN QUERY SELECT
            'WRONG_PRODUCT_TYPE','error',
            format(
                'Expected product_type=rapid_evidence_synthesis, found %s',
                pv.product_type
            );
    END IF;

    SELECT count(*)
      INTO primary_count
      FROM product.investigation_link
     WHERE product_version_uuid = p_product_version_uuid
       AND role = 'primary';

    IF primary_count = 0 THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_INVESTIGATION','error',
            'Rapid Evidence Synthesis requires one primary Investigation';
    ELSIF primary_count > 1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_PRIMARY_INVESTIGATIONS','error',
            'Rapid Evidence Synthesis has more than one primary Investigation';
    ELSE
        SELECT il.investigation_version_uuid,
               iv.depth_level,
               iv.evidence_cutoff_date,
               ev.version_status,
               iv.protocol_artifact_uuid
          INTO inv_uuid,
               inv_depth,
               inv_cutoff,
               inv_status,
               protocol_uuid
          FROM product.investigation_link il
          JOIN investigation.investigation_version iv
            ON iv.version_uuid = il.investigation_version_uuid
          JOIN core.entity_version ev
            ON ev.version_uuid = iv.version_uuid
         WHERE il.product_version_uuid = p_product_version_uuid
           AND il.role = 'primary';

        IF inv_depth <> 'N3' THEN
            RETURN QUERY SELECT
                'PRIMARY_INVESTIGATION_NOT_N3','error',
                format(
                    'Primary Investigation depth is %s, expected N3',
                    inv_depth
                );
        END IF;

        IF inv_cutoff IS DISTINCT FROM pv.evidence_cutoff_date THEN
            RETURN QUERY SELECT
                'CUTOFF_DATE_MISMATCH','error',
                format(
                    'Product cutoff %s differs from Investigation cutoff %s',
                    pv.evidence_cutoff_date,
                    inv_cutoff
                );
        END IF;

        IF inv_status <> 'current' THEN
            RETURN QUERY SELECT
                'PRIMARY_INVESTIGATION_NOT_CURRENT','error',
                format(
                    'Primary Investigation version_status is %s',
                    inv_status
                );
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.investigation_question iq
             WHERE iq.investigation_version_uuid = inv_uuid
               AND iq.role = 'primary'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_QUESTION','error',
                'Primary Investigation has no primary QuestionVersion link';
        END IF;

        IF protocol_uuid IS NULL
           OR NOT EXISTS (
                SELECT 1
                  FROM artifact.artifact a
                 WHERE a.artifact_uuid = protocol_uuid
                   AND a.status = 'active'
           )
        THEN
            RETURN QUERY SELECT
                'MISSING_PROTOCOL','error',
                'A traceable active protocol artifact is required for N3';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.search s
             WHERE s.investigation_version_uuid = inv_uuid
               AND s.status = 'completed'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_SEARCH_RECORD','error',
                'At least one completed systematic search is required';
        END IF;

        SELECT count(DISTINCT s.source_name)
          INTO search_source_count
          FROM investigation.search s
         WHERE s.investigation_version_uuid = inv_uuid
           AND s.status = 'completed';

        IF search_source_count < 2
           AND NOT EXISTS (
                SELECT 1
                  FROM investigation.method_decision md
                 WHERE md.investigation_version_uuid = inv_uuid
                   AND md.record_status = 'active'
                   AND md.decision_type = 'rapid_restriction'
                   AND md.decision_code = 'single_database_exception'
                   AND md.resolution_status IN ('accepted','mitigated')
           )
        THEN
            RETURN QUERY SELECT
                'INSUFFICIENT_SEARCH_SOURCE_COVERAGE','error',
                'Fewer than two search sources are recorded without an accepted single-database exception';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.method_decision md
             WHERE md.investigation_version_uuid = inv_uuid
               AND md.record_status = 'active'
               AND md.decision_type = 'rapid_restriction'
               AND md.resolution_status IN ('accepted','mitigated')
        ) THEN
            RETURN QUERY SELECT
                'MISSING_RAPID_METHOD_RESTRICTION','error',
                'At least one explicit accepted/mitigated rapid-method restriction is required to characterize N3';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM investigation.method_decision md
             WHERE md.investigation_version_uuid = inv_uuid
               AND md.record_status = 'active'
               AND md.decision_type = 'protocol_deviation'
               AND md.resolution_status = 'open'
        ) THEN
            RETURN QUERY SELECT
                'OPEN_PROTOCOL_DEVIATION','error',
                'An active open protocol deviation blocks publication';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM investigation.quality_control_record q
             WHERE q.investigation_version_uuid = inv_uuid
               AND q.record_status = 'active'
               AND q.decision = 'revise'
        ) THEN
            RETURN QUERY SELECT
                'ACTIVE_QUALITY_CONTROL_REVISE','error',
                'An active quality-control record requires revision';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM investigation.quality_control_record q
             WHERE q.investigation_version_uuid = inv_uuid
               AND q.record_status = 'active'
               AND q.decision = 'failed'
        ) THEN
            RETURN QUERY SELECT
                'ACTIVE_QUALITY_CONTROL_FAILED','error',
                'An active failed quality-control record blocks publication';
        END IF;

        SELECT count(*)
          INTO search_hit_count
          FROM investigation.search_hit sh
          JOIN investigation.search s
            ON s.search_uuid = sh.search_uuid
         WHERE s.investigation_version_uuid = inv_uuid;

        SELECT count(*)
          INTO screening_count
          FROM investigation.screening_decision sd
         WHERE sd.investigation_version_uuid = inv_uuid;

        IF search_hit_count > 0 AND screening_count = 0 THEN
            RETURN QUERY SELECT
                'MISSING_SELECTION_FLOW','error',
                'SearchHits exist but no ScreeningDecision is recorded';
        END IF;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM core.entity_version ev
         WHERE ev.version_uuid = p_product_version_uuid
           AND ev.version_status = 'current'
    ) THEN
        RETURN QUERY SELECT
            'NOT_CURRENT_ENTITY_VERSION','error',
            'ProductVersion must be the current EntityVersion';
    END IF;

    IF btrim(coalesce(pv.title,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_TITLE','error',
            'Title is required for N3';
    END IF;

    IF btrim(coalesce(pv.conclusion_text,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_CONCLUSION','error',
            'Conclusion is required for N3';
    END IF;

    IF btrim(coalesce(pv.limitations_summary,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_LIMITATIONS','error',
            'Rapid-method/evidence limitations must be explicitly recorded';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.currency_state cs
         WHERE cs.product_version_uuid = p_product_version_uuid
           AND cs.record_status = 'active'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CURRENCY_STATE','error',
            'An active currency state is required';
    END IF;

    SELECT EXISTS (
        SELECT 1
          FROM product.certainty_link cl
          JOIN appraisal.certainty_assessment_version cav
            ON cav.version_uuid = cl.certainty_assessment_version_uuid
         WHERE cl.product_version_uuid = p_product_version_uuid
           AND cav.evidence_state = 'no_evidence'
    )
      INTO no_evidence;

    evidence_available := NOT no_evidence;

    SELECT count(*)
      INTO reference_count
      FROM product.product_reference_reports(p_product_version_uuid);

    IF evidence_available THEN
        IF reference_count = 0 THEN
            RETURN QUERY SELECT
                'MISSING_TRACEABLE_SOURCE','error',
                'Evidence-available N3 requires traceable ReportVersion sources';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM appraisal.risk_assessment_version rav
             WHERE rav.investigation_version_uuid = inv_uuid
               AND rav.status = 'active'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_RISK_ASSESSMENT','error',
                'Evidence-available N3 requires formal risk-of-bias/appraisal records';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
             WHERE sl.product_version_uuid = p_product_version_uuid
        ) THEN
            RETURN QUERY SELECT
                'MISSING_SYNTHESIS','error',
                'Evidence-available N3 requires at least one linked SynthesisVersion';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM product.certainty_link cl
             WHERE cl.product_version_uuid = p_product_version_uuid
        ) THEN
            RETURN QUERY SELECT
                'MISSING_CERTAINTY_ASSESSMENT','error',
                'Evidence-available N3 requires linked CertaintyAssessment for critical units';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM artifact.entity_link ael
             WHERE ael.entity_version_uuid = inv_uuid
               AND ael.role = 'summary_of_findings'
        )
        AND NOT EXISTS (
            SELECT 1
              FROM investigation.method_decision md
             WHERE md.investigation_version_uuid = inv_uuid
               AND md.record_status = 'active'
               AND md.decision_code = 'summary_of_findings_not_applicable'
               AND md.resolution_status IN ('accepted','mitigated','resolved')
        )
        THEN
            RETURN QUERY SELECT
                'MISSING_SUMMARY_OF_FINDINGS_DECISION','error',
                'Provide a Summary of Findings artifact or document why it is not applicable';
        END IF;
    ELSE
        IF NOT EXISTS (
            SELECT 1
              FROM product.certainty_link cl
              JOIN appraisal.certainty_assessment_version cav
                ON cav.version_uuid = cl.certainty_assessment_version_uuid
             WHERE cl.product_version_uuid = p_product_version_uuid
               AND cav.evidence_state = 'no_evidence'
               AND cav.final_level IS NULL
        ) THEN
            RETURN QUERY SELECT
                'INVALID_NO_EVIDENCE_STATE','error',
                'No-evidence N3 must preserve evidence_state=no_evidence without artificial certainty level';
        END IF;
    END IF;

    RETURN QUERY
    SELECT mc.control_code, 'error', mc.message
      FROM product.rapid_evidence_synthesis_missing_controls(
          p_product_version_uuid
      ) mc;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision = 'passed'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_AI_METHODOLOGICAL_VERIFICATION','error',
            'A passed AI methodological verification is required';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision IN ('revise','failed')
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_AI_METHOD_BLOCK','error',
            'Active AI methodological verification blocks publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'owner_governance_approval'
           AND ar.decision = 'approved'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OWNER_APPROVAL','error',
            'Owner governance approval is required';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'owner_governance_approval'
           AND ar.decision IN ('revise','rejected')
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_OWNER_BLOCK','error',
            'Active owner governance decision blocks publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'expert_independent_review'
           AND ar.decision = 'approved'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_EXPERT_INDEPENDENT_REVIEW','error',
            'Formal N3 publication requires approved expert independent review';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'expert_independent_review'
           AND ar.decision IN ('revise','rejected')
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_EXPERT_BLOCK','error',
            'Active expert independent review blocks publication';
    END IF;

    IF product.assurance_level(p_product_version_uuid) <> 'A3' THEN
        RETURN QUERY SELECT
            'ASSURANCE_BELOW_A3','error',
            format(
                'Formal N3 publication requires A3; current level is %s',
                product.assurance_level(p_product_version_uuid)
            );
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PUBLICATION_DATE','error',
            'Publication date is required for formal N3 publication';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.product_reference_reports(p_product_version_uuid) prr
          JOIN core.entity_version ev
            ON ev.version_uuid = prr.report_version_uuid
         WHERE ev.version_status = 'invalidated'
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_DEPENDENCY','error',
            'A referenced ReportVersion is invalidated';
    END IF;

    IF EXISTS (
        WITH RECURSIVE upstream(version_uuid, path) AS (
            SELECT de.source_version_uuid,
                   ARRAY[de.target_version_uuid, de.source_version_uuid]::uuid[]
              FROM provenance.dependency_edge de
             WHERE de.target_version_uuid = p_product_version_uuid
               AND de.status = 'active'

            UNION ALL

            SELECT de.source_version_uuid,
                   u.path || de.source_version_uuid
              FROM upstream u
              JOIN provenance.dependency_edge de
                ON de.target_version_uuid = u.version_uuid
               AND de.status = 'active'
             WHERE cardinality(u.path) < 64
               AND NOT de.source_version_uuid = ANY(u.path)
        )
        SELECT 1
          FROM upstream u
          JOIN core.entity_version ev
            ON ev.version_uuid = u.version_uuid
         WHERE ev.version_status = 'invalidated'
         LIMIT 1
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_UPSTREAM_DEPENDENCY','error',
            'An upstream dependency in the N3 lineage is invalidated';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.method_decision md
         WHERE md.investigation_version_uuid = inv_uuid
           AND md.record_status = 'active'
           AND md.decision_type = 'rapid_restriction'
    ) THEN
        RETURN QUERY SELECT
            'RAPID_METHOD_RESTRICTIONS_PRESENT','warning',
            'Rapid-method restrictions are active and must remain visible in the rendered product';
    END IF;

    RETURN;
END;
$gate$;


CREATE OR REPLACE FUNCTION product.rapid_evidence_synthesis_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $publishable$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.rapid_evidence_synthesis_publication_issues(
              p_product_version_uuid
          )
         WHERE severity = 'error'
    );
$publishable$;

-- ---------------------------------------------------------------------------
-- RAPID EVIDENCE SYNTHESIS VIEW
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.rapid_evidence_synthesis_view(
    p_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $view$
DECLARE
    payload jsonb;
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.product_version
         WHERE version_uuid = p_product_version_uuid
    ) THEN
        RETURN NULL;
    END IF;

    WITH primary_inv AS (
        SELECT il.investigation_version_uuid,
               iv.entity_uuid AS investigation_entity_uuid,
               ie.oes_id AS investigation_id,
               iv.investigation_type,
               iv.depth_level,
               iv.maintenance_level,
               iv.objective,
               iv.protocol_artifact_uuid,
               iv.start_date,
               iv.evidence_cutoff_date
          FROM product.investigation_link il
          JOIN investigation.investigation_version iv
            ON iv.version_uuid = il.investigation_version_uuid
          JOIN core.entity ie
            ON ie.entity_uuid = iv.entity_uuid
         WHERE il.product_version_uuid = p_product_version_uuid
           AND il.role = 'primary'
         LIMIT 1
    ),
    primary_q AS (
        SELECT qe.oes_id AS question_id,
               qv.entity_uuid AS question_entity_uuid,
               qv.version_uuid AS question_version_uuid,
               qv.original_text,
               qv.normalized_text,
               qv.question_type,
               qv.structure_type,
               qv.context_payload,
               qv.time_horizon_payload
          FROM primary_inv pi
          JOIN investigation.investigation_question iq
            ON iq.investigation_version_uuid = pi.investigation_version_uuid
           AND iq.role = 'primary'
          JOIN investigation.question_version qv
            ON qv.version_uuid = iq.question_version_uuid
          JOIN core.entity qe
            ON qe.entity_uuid = qv.entity_uuid
         ORDER BY iq.sequence_no NULLS LAST, qv.version_uuid
         LIMIT 1
    ),
    refs AS (
        SELECT *
          FROM product.product_reference_reports(p_product_version_uuid)
    ),
    missing_controls AS (
        SELECT *
          FROM product.rapid_evidence_synthesis_missing_controls(
              p_product_version_uuid
          )
    )
    SELECT jsonb_build_object(
        'schema_version', 'oes.rapid_evidence_synthesis_view/0.1',

        'identity', (
            SELECT jsonb_build_object(
                'product_id', pe.oes_id,
                'product_entity_uuid', pv.entity_uuid,
                'product_version_uuid', pv.version_uuid,
                'version_no', ev.version_no,
                'product_type', pv.product_type,
                'title', pv.title,
                'intended_audience', pv.intended_audience,
                'editorial_status', pv.status,
                'entity_version_status', ev.version_status,
                'publication_date', pv.publication_date,
                'evidence_cutoff_date', pv.evidence_cutoff_date,
                'currency_status', ccs.currency_status
            )
              FROM product.product_version pv
              JOIN core.entity_version ev
                ON ev.version_uuid = pv.version_uuid
              JOIN core.entity pe
                ON pe.entity_uuid = pv.entity_uuid
              LEFT JOIN product.current_currency_state ccs
                ON ccs.product_version_uuid = pv.version_uuid
             WHERE pv.version_uuid = p_product_version_uuid
        ),

        'question', (
            SELECT jsonb_build_object(
                'question_id', pq.question_id,
                'question_entity_uuid', pq.question_entity_uuid,
                'question_version_uuid', pq.question_version_uuid,
                'original_text', pq.original_text,
                'normalized_text', pq.normalized_text,
                'question_type', pq.question_type,
                'structure_type', pq.structure_type,
                'context', pq.context_payload,
                'time_horizon', pq.time_horizon_payload
            )
              FROM primary_q pq
        ),

        'investigation', (
            SELECT jsonb_build_object(
                'investigation_id', pi.investigation_id,
                'investigation_entity_uuid', pi.investigation_entity_uuid,
                'investigation_version_uuid', pi.investigation_version_uuid,
                'investigation_type', pi.investigation_type,
                'depth_level', pi.depth_level,
                'maintenance_level', pi.maintenance_level,
                'objective', pi.objective,
                'start_date', pi.start_date,
                'evidence_cutoff_date', pi.evidence_cutoff_date
            )
              FROM primary_inv pi
        ),

        'decision_context', jsonb_build_object(
            'objective', (SELECT pi.objective FROM primary_inv pi),
            'question_context', (SELECT pq.context_payload FROM primary_q pq),
            'intended_audience', (
                SELECT pv.intended_audience
                  FROM product.product_version pv
                 WHERE pv.version_uuid = p_product_version_uuid
            )
        ),

        'protocol', (
            SELECT CASE
                WHEN a.artifact_uuid IS NULL THEN NULL
                ELSE jsonb_build_object(
                    'artifact_uuid', a.artifact_uuid,
                    'artifact_type', a.artifact_type,
                    'storage_key', a.storage_key,
                    'content_hash', a.content_hash,
                    'mime_type', a.mime_type,
                    'status', a.status
                )
            END
              FROM primary_inv pi
              LEFT JOIN artifact.artifact a
                ON a.artifact_uuid = pi.protocol_artifact_uuid
        ),

        'rapid_method', jsonb_build_object(
            'restrictions', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'decision_uuid', md.method_decision_uuid,
                        'stage', md.stage,
                        'code', md.decision_code,
                        'planned', md.planned_flag,
                        'rationale', md.rationale,
                        'risk', md.risk_payload,
                        'mitigation', md.mitigation_payload,
                        'impact', md.impact_payload,
                        'resolution_status', md.resolution_status
                    )
                    ORDER BY md.decided_at, md.method_decision_uuid
                )
                  FROM investigation.method_decision md
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid =
                       md.investigation_version_uuid
                 WHERE md.record_status = 'active'
                   AND md.decision_type = 'rapid_restriction'
            ), '[]'::jsonb),
            'deviations', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'decision_uuid', md.method_decision_uuid,
                        'stage', md.stage,
                        'code', md.decision_code,
                        'rationale', md.rationale,
                        'impact', md.impact_payload,
                        'mitigation', md.mitigation_payload,
                        'resolution_status', md.resolution_status
                    )
                    ORDER BY md.decided_at, md.method_decision_uuid
                )
                  FROM investigation.method_decision md
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid =
                       md.investigation_version_uuid
                 WHERE md.record_status = 'active'
                   AND md.decision_type = 'protocol_deviation'
            ), '[]'::jsonb)
        ),

        'searches', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'search_id', s.oes_search_id,
                    'source_name', s.source_name,
                    'platform', s.platform,
                    'exact_strategy', s.exact_strategy,
                    'filters', s.filters_payload,
                    'executed_at', s.executed_at,
                    'result_count', s.result_count,
                    'strategy_version', s.strategy_version,
                    'status', s.status,
                    'materialized_hit_count', (
                        SELECT count(*)
                          FROM investigation.search_hit sh
                         WHERE sh.search_uuid = s.search_uuid
                    )
                )
                ORDER BY s.executed_at, s.search_uuid
            )
              FROM investigation.search s
              JOIN primary_inv pi
                ON pi.investigation_version_uuid =
                   s.investigation_version_uuid
        ), '[]'::jsonb),

        'selection_flow', (
            SELECT jsonb_build_object(
                'search_hits_materialized', (
                    SELECT count(*)
                      FROM investigation.search_hit sh
                      JOIN investigation.search s
                        ON s.search_uuid = sh.search_uuid
                      JOIN primary_inv pi
                        ON pi.investigation_version_uuid =
                           s.investigation_version_uuid
                ),
                'screening_decisions', (
                    SELECT count(*)
                      FROM investigation.screening_decision sd
                      JOIN primary_inv pi
                        ON pi.investigation_version_uuid =
                           sd.investigation_version_uuid
                ),
                'title_abstract_decisions', (
                    SELECT count(*)
                      FROM investigation.screening_decision sd
                      JOIN primary_inv pi
                        ON pi.investigation_version_uuid =
                           sd.investigation_version_uuid
                     WHERE lower(sd.stage) IN (
                        'title_abstract',
                        'title/abstract',
                        'abstract'
                     )
                ),
                'full_text_decisions', (
                    SELECT count(*)
                      FROM investigation.screening_decision sd
                      JOIN primary_inv pi
                        ON pi.investigation_version_uuid =
                           sd.investigation_version_uuid
                     WHERE lower(sd.stage) IN (
                        'full_text',
                        'full text'
                     )
                ),
                'full_text_exclusions', (
                    SELECT count(*)
                      FROM investigation.screening_decision sd
                      JOIN primary_inv pi
                        ON pi.investigation_version_uuid =
                           sd.investigation_version_uuid
                     WHERE lower(sd.stage) IN (
                        'full_text',
                        'full text'
                     )
                       AND sd.decision = 'exclude'
                )
            )
        ),

        'included_evidence', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'report_id', r.report_id,
                    'report_entity_uuid', r.report_entity_uuid,
                    'report_version_uuid', r.report_version_uuid,
                    'title', r.title,
                    'publication_date', r.publication_date,
                    'publication_status', r.publication_status,
                    'source_locations', r.source_locations
                )
                ORDER BY r.publication_date NULLS LAST, r.report_id
            )
              FROM refs r
        ), '[]'::jsonb),

        'risk_of_bias', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'risk_assessment_version_uuid', rav.version_uuid,
                    'framework', rav.framework,
                    'framework_version', rav.framework_version,
                    'target_entity_uuid', rav.target_entity_uuid,
                    'outcome_entity_uuid', rav.outcome_entity_uuid,
                    'overall_judgement', rav.overall_judgement,
                    'assessor', rav.assessor,
                    'verification_status', rav.verification_status,
                    'assessment_date', rav.assessment_date
                )
                ORDER BY rav.assessment_date, rav.version_uuid
            )
              FROM appraisal.risk_assessment_version rav
              JOIN primary_inv pi
                ON pi.investigation_version_uuid =
                   rav.investigation_version_uuid
             WHERE rav.status = 'active'
        ), '[]'::jsonb),

        'results', COALESCE((
            SELECT jsonb_agg(DISTINCT jsonb_build_object(
                'result_version_uuid', rv.version_uuid,
                'result_entity_uuid', rv.entity_uuid,
                'outcome_entity_uuid', rv.outcome_entity_uuid,
                'measure', rv.measure,
                'reported_value', rv.reported_value,
                'derived_value', rv.derived_value,
                'ci_lower', rv.ci_lower,
                'ci_upper', rv.ci_upper,
                'unit', rv.unit,
                'status', rv.status
            ))
              FROM product.synthesis_link sl
              JOIN synthesis.contribution sc
                ON sc.synthesis_version_uuid = sl.synthesis_version_uuid
              JOIN evidence.result_version rv
                ON rv.version_uuid = sc.result_version_uuid
             WHERE sl.product_version_uuid = p_product_version_uuid
        ), '[]'::jsonb),

        'syntheses', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'synthesis_id', se.oes_id,
                    'synthesis_entity_uuid', sv.entity_uuid,
                    'synthesis_version_uuid', sv.version_uuid,
                    'outcome_entity_uuid', sv.outcome_entity_uuid,
                    'synthesis_type', sv.synthesis_type,
                    'synthesis_origin', sv.synthesis_origin,
                    'method', sv.method,
                    'model', sv.model,
                    'software', sv.software,
                    'software_version', sv.software_version,
                    'result_summary', sv.result_summary,
                    'status', sv.status,
                    'executed_at', sv.executed_at,
                    'role', sl.role
                )
                ORDER BY sl.sequence_no NULLS LAST, sv.version_uuid
            )
              FROM product.synthesis_link sl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid = sl.synthesis_version_uuid
              JOIN core.entity se
                ON se.entity_uuid = sv.entity_uuid
             WHERE sl.product_version_uuid = p_product_version_uuid
        ), '[]'::jsonb),

        'certainty', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'certainty_id', ce.oes_id,
                    'certainty_entity_uuid', cav.entity_uuid,
                    'certainty_version_uuid', cav.version_uuid,
                    'framework', cav.framework,
                    'framework_version', cav.framework_version,
                    'initial_level', cav.initial_level,
                    'final_level', cav.final_level,
                    'evidence_state', cav.evidence_state,
                    'assessment_date', cav.assessment_date,
                    'role', cl.role
                )
                ORDER BY cl.sequence_no NULLS LAST, cav.version_uuid
            )
              FROM product.certainty_link cl
              JOIN appraisal.certainty_assessment_version cav
                ON cav.version_uuid = cl.certainty_assessment_version_uuid
              JOIN core.entity ce
                ON ce.entity_uuid = cav.entity_uuid
             WHERE cl.product_version_uuid = p_product_version_uuid
        ), '[]'::jsonb),

        'summary_of_findings', (
            SELECT jsonb_build_object(
                'artifact_uuid', a.artifact_uuid,
                'artifact_type', a.artifact_type,
                'storage_key', a.storage_key,
                'content_hash', a.content_hash,
                'mime_type', a.mime_type,
                'status', a.status
            )
              FROM artifact.entity_link ael
              JOIN artifact.artifact a
                ON a.artifact_uuid = ael.artifact_uuid
              JOIN primary_inv pi
                ON pi.investigation_version_uuid =
                   ael.entity_version_uuid
             WHERE ael.role = 'summary_of_findings'
             ORDER BY ael.sequence_no NULLS LAST, a.artifact_uuid
             LIMIT 1
        ),

        'rapid_method_limitations', jsonb_build_object(
            'summary', (
                SELECT pv.limitations_summary
                  FROM product.product_version pv
                 WHERE pv.version_uuid = p_product_version_uuid
            ),
            'restrictions_present', EXISTS (
                SELECT 1
                  FROM investigation.method_decision md
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid =
                       md.investigation_version_uuid
                 WHERE md.record_status = 'active'
                   AND md.decision_type = 'rapid_restriction'
            )
        ),

        'applicability', (
            SELECT jsonb_build_object(
                'summary', pv.applicability_summary,
                'formal_assessment', false
            )
              FROM product.product_version pv
             WHERE pv.version_uuid = p_product_version_uuid
        ),

        'conclusion', (
            SELECT jsonb_build_object(
                'text', pv.conclusion_text
            )
              FROM product.product_version pv
             WHERE pv.version_uuid = p_product_version_uuid
        ),

        'references', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'report_id', r.report_id,
                    'report_entity_uuid', r.report_entity_uuid,
                    'report_version_uuid', r.report_version_uuid,
                    'title', r.title,
                    'publication_date', r.publication_date,
                    'publication_status', r.publication_status,
                    'source_locations', r.source_locations
                )
                ORDER BY r.publication_date NULLS LAST, r.report_id
            )
              FROM refs r
        ), '[]'::jsonb),

        'quality_controls', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'quality_control_uuid', q.quality_control_uuid,
                    'stage', q.stage,
                    'control_type', q.control_type,
                    'actor', q.actor,
                    'actor_type', q.actor_type,
                    'qualified', (
                        q.actor_type IN ('human_reviewer','human_expert')
                        AND q.qualification_payload IS NOT NULL
                        AND q.qualification_payload <> '{}'::jsonb
                    ),
                    'independent', q.independent_flag,
                    'decision', q.decision,
                    'scope', q.scope_payload,
                    'agreement', q.agreement_payload,
                    'discrepancies', q.discrepancy_payload,
                    'resolution', q.resolution_payload,
                    'performed_at', q.performed_at,
                    'notes', q.notes
                )
                ORDER BY q.performed_at, q.quality_control_uuid
            )
              FROM investigation.quality_control_record q
              JOIN primary_inv pi
                ON pi.investigation_version_uuid =
                   q.investigation_version_uuid
             WHERE q.record_status = 'active'
        ), '[]'::jsonb),

        'audit', jsonb_build_object(
            'publishable',
                product.rapid_evidence_synthesis_is_publishable(
                    p_product_version_uuid
                ),
            'assurance_level',
                product.rapid_evidence_synthesis_assurance_level(
                    p_product_version_uuid
                ),
            'expert_independent_reviewed', EXISTS (
                SELECT 1
                  FROM product.assurance_record ar
                 WHERE ar.product_version_uuid = p_product_version_uuid
                   AND ar.status = 'active'
                   AND ar.assurance_type = 'expert_independent_review'
                   AND ar.decision = 'approved'
            ),
            'qualified_controls_satisfied',
                NOT EXISTS (SELECT 1 FROM missing_controls),
            'missing_controls', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'control_code', mc.control_code,
                        'message', mc.message
                    )
                    ORDER BY mc.control_code
                )
                  FROM missing_controls mc
            ), '[]'::jsonb),
            'assurance_records', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'assurance_type', ar.assurance_type,
                        'actor', ar.actor,
                        'actor_type', ar.actor_type,
                        'independent', ar.independent_flag,
                        'decision', ar.decision,
                        'performed_at', ar.performed_at,
                        'status', ar.status
                    )
                    ORDER BY ar.performed_at, ar.assurance_uuid
                )
                  FROM product.assurance_record ar
                 WHERE ar.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb),
            'publication_issues', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'issue_code', i.issue_code,
                        'severity', i.severity,
                        'message', i.message
                    )
                    ORDER BY i.severity, i.issue_code
                )
                  FROM product.rapid_evidence_synthesis_publication_issues(
                      p_product_version_uuid
                  ) i
            ), '[]'::jsonb),
            'protocol_deviations_open', EXISTS (
                SELECT 1
                  FROM investigation.method_decision md
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid =
                       md.investigation_version_uuid
                 WHERE md.record_status = 'active'
                   AND md.decision_type = 'protocol_deviation'
                   AND md.resolution_status = 'open'
            ),
            'lineage_available', EXISTS (
                SELECT 1
                  FROM provenance.dependency_edge de
                 WHERE de.target_version_uuid = p_product_version_uuid
                    OR de.source_version_uuid = p_product_version_uuid
            )
        )
    )
    INTO payload;

    RETURN payload;
END;
$view$;

COMMIT;
