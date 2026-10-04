-- OES-DBM-2026-0010
-- Governance assurance model for N2 publication
-- Depends on: baseline + migrations 002–009
-- Status: assurance governance baseline
-- Date: 2026-10-04

BEGIN;

CREATE TABLE product.assurance_record (
    assurance_uuid uuid PRIMARY KEY,
    product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    assurance_type text NOT NULL CHECK (
        assurance_type IN (
            'ai_methodological_verification',
            'owner_governance_approval',
            'expert_independent_review'
        )
    ),
    actor text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','owner','human_expert')
    ),
    independent_flag boolean NOT NULL DEFAULT false,
    decision text NOT NULL CHECK (
        decision IN (
            'passed',
            'approved',
            'revise',
            'failed',
            'rejected'
        )
    ),
    performed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes text,
    evidence_payload jsonb,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    CHECK (
        (
            assurance_type = 'ai_methodological_verification'
            AND actor_type = 'ai_system'
            AND independent_flag = false
            AND decision IN ('passed','revise','failed')
        )
        OR
        (
            assurance_type = 'owner_governance_approval'
            AND actor_type = 'owner'
            AND independent_flag = false
            AND decision IN ('approved','revise','rejected')
        )
        OR
        (
            assurance_type = 'expert_independent_review'
            AND actor_type = 'human_expert'
            AND independent_flag = true
            AND decision IN ('approved','revise','rejected')
        )
    )
);

CREATE UNIQUE INDEX ux_assurance_one_active_type
    ON product.assurance_record(product_version_uuid, assurance_type)
    WHERE status = 'active';

CREATE INDEX ix_assurance_product
    ON product.assurance_record(product_version_uuid);

CREATE OR REPLACE FUNCTION product.evidence_sheet_assurance_level(
    p_product_version_uuid uuid
)
RETURNS text
LANGUAGE sql
STABLE
AS $assurance$
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM product.assurance_record ar
            WHERE ar.product_version_uuid = p_product_version_uuid
              AND ar.status = 'active'
              AND ar.assurance_type = 'ai_methodological_verification'
              AND ar.decision = 'passed'
        )
        AND EXISTS (
            SELECT 1 FROM product.assurance_record ar
            WHERE ar.product_version_uuid = p_product_version_uuid
              AND ar.status = 'active'
              AND ar.assurance_type = 'owner_governance_approval'
              AND ar.decision = 'approved'
        )
        AND EXISTS (
            SELECT 1 FROM product.assurance_record ar
            WHERE ar.product_version_uuid = p_product_version_uuid
              AND ar.status = 'active'
              AND ar.assurance_type = 'expert_independent_review'
              AND ar.decision = 'approved'
        )
        THEN 'A3'

        WHEN EXISTS (
            SELECT 1 FROM product.assurance_record ar
            WHERE ar.product_version_uuid = p_product_version_uuid
              AND ar.status = 'active'
              AND ar.assurance_type = 'ai_methodological_verification'
              AND ar.decision = 'passed'
        )
        AND EXISTS (
            SELECT 1 FROM product.assurance_record ar
            WHERE ar.product_version_uuid = p_product_version_uuid
              AND ar.status = 'active'
              AND ar.assurance_type = 'owner_governance_approval'
              AND ar.decision = 'approved'
        )
        THEN 'A2'

        WHEN EXISTS (
            SELECT 1 FROM product.assurance_record ar
            WHERE ar.product_version_uuid = p_product_version_uuid
              AND ar.status = 'active'
              AND ar.assurance_type = 'ai_methodological_verification'
              AND ar.decision = 'passed'
        )
        THEN 'A1'

        ELSE 'A0'
    END;
$assurance$;

CREATE OR REPLACE FUNCTION product.evidence_sheet_publication_issues(
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
    primary_investigation_uuid uuid;
    primary_depth text;
    primary_cutoff date;
    primary_entity_status text;
BEGIN
    SELECT *
      INTO pv
      FROM product.product_version
     WHERE version_uuid = p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            'MISSING_PRODUCT_VERSION'::text,
            'error'::text,
            'ProductVersion does not exist'::text;
        RETURN;
    END IF;

    IF pv.product_type <> 'evidence_sheet' THEN
        RETURN QUERY
        SELECT
            'WRONG_PRODUCT_TYPE',
            'error',
            format(
                'Expected product_type=evidence_sheet, found %s',
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
            'MISSING_PRIMARY_INVESTIGATION',
            'error',
            'Evidence Sheet requires one primary Investigation';
    ELSIF primary_count > 1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_PRIMARY_INVESTIGATIONS',
            'error',
            'Evidence Sheet has more than one primary Investigation';
    ELSE
        SELECT
            il.investigation_version_uuid,
            iv.depth_level,
            iv.evidence_cutoff_date,
            ev.version_status
          INTO
            primary_investigation_uuid,
            primary_depth,
            primary_cutoff,
            primary_entity_status
          FROM product.investigation_link il
          JOIN investigation.investigation_version iv
            ON iv.version_uuid = il.investigation_version_uuid
          JOIN core.entity_version ev
            ON ev.version_uuid = iv.version_uuid
         WHERE il.product_version_uuid = p_product_version_uuid
           AND il.role = 'primary';

        IF primary_depth <> 'N2' THEN
            RETURN QUERY SELECT
                'PRIMARY_INVESTIGATION_NOT_N2',
                'error',
                format(
                    'Primary Investigation depth is %s, expected N2',
                    primary_depth
                );
        END IF;

        IF primary_cutoff IS DISTINCT FROM pv.evidence_cutoff_date THEN
            RETURN QUERY SELECT
                'CUTOFF_DATE_MISMATCH',
                'error',
                format(
                    'Product cutoff %s differs from primary Investigation cutoff %s',
                    pv.evidence_cutoff_date,
                    primary_cutoff
                );
        END IF;

        IF primary_entity_status <> 'current' THEN
            RETURN QUERY SELECT
                'PRIMARY_INVESTIGATION_NOT_CURRENT',
                'error',
                format(
                    'Primary Investigation version_status is %s',
                    primary_entity_status
                );
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.investigation_question iq
             WHERE iq.investigation_version_uuid = primary_investigation_uuid
               AND iq.role = 'primary'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_QUESTION',
                'error',
                'Primary Investigation has no primary QuestionVersion link';
        END IF;
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PUBLICATION_DATE',
            'error',
            'Publication date is required for publication';
    END IF;

    IF btrim(coalesce(pv.conclusion_text,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_CONCLUSION',
            'error',
            'Conclusion is required for an Evidence Sheet';
    END IF;

    IF btrim(coalesce(pv.limitations_summary,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_LIMITATIONS',
            'error',
            'Limitations summary is required for an Evidence Sheet';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.currency_state cs
         WHERE cs.product_version_uuid = p_product_version_uuid
           AND cs.record_status = 'active'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CURRENCY_STATE',
            'error',
            'An active currency state is required';
    END IF;

    -- Assurance governance (Document 04).
    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision = 'passed'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_AI_METHODOLOGICAL_VERIFICATION',
            'error',
            'A passed AI methodological verification is required for standard N2 publication';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision = 'revise'
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_AI_METHOD_REVISE',
            'error',
            'Active AI methodological verification requires revision';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision = 'failed'
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_AI_METHOD_FAILURE',
            'error',
            'Active AI methodological verification failed';
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
            'MISSING_OWNER_APPROVAL',
            'error',
            'Owner governance approval is required for standard N2 publication';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'owner_governance_approval'
           AND ar.decision = 'revise'
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_OWNER_REVISE',
            'error',
            'Owner governance approval requires revision';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'owner_governance_approval'
           AND ar.decision = 'rejected'
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_OWNER_REJECTION',
            'error',
            'Active owner governance rejection blocks publication';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'expert_independent_review'
           AND ar.decision = 'revise'
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_EXPERT_REVISE',
            'error',
            'An active expert independent review requires revision';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'expert_independent_review'
           AND ar.decision = 'rejected'
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_EXPERT_REJECTION',
            'error',
            'An active expert independent rejection blocks publication';
    END IF;

    -- Backward-safety: a legacy active rejected review cannot be silently ignored.
    IF EXISTS (
        SELECT 1
          FROM product.review_record rr
         WHERE rr.product_version_uuid = p_product_version_uuid
           AND rr.status = 'active'
           AND rr.decision = 'rejected'
    ) THEN
        RETURN QUERY SELECT
            'LEGACY_ACTIVE_REJECTION',
            'error',
            'An active legacy rejected review blocks publication until explicitly resolved';
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
            'NO_EXPERT_INDEPENDENT_REVIEW',
            'warning',
            'No expert independent review is recorded; output must disclose this assurance limit';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM core.entity_version ev
         WHERE ev.version_uuid = p_product_version_uuid
           AND ev.version_status = 'current'
    ) THEN
        RETURN QUERY SELECT
            'NOT_CURRENT_ENTITY_VERSION',
            'error',
            'ProductVersion must be the current EntityVersion';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.synthesis_link sl
         WHERE sl.product_version_uuid = p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SYNTHESIS',
            'error',
            'Evidence Sheet requires at least one linked SynthesisVersion';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.certainty_link cl
          JOIN appraisal.certainty_assessment_version cav
            ON cav.version_uuid = cl.certainty_assessment_version_uuid
         WHERE cl.product_version_uuid = p_product_version_uuid
           AND cav.synthesis_version_uuid IS NOT NULL
           AND NOT EXISTS (
                SELECT 1
                  FROM product.synthesis_link sl
                 WHERE sl.product_version_uuid = p_product_version_uuid
                   AND sl.synthesis_version_uuid = cav.synthesis_version_uuid
           )
    ) THEN
        RETURN QUERY SELECT
            'UNLINKED_SYNTHESIS',
            'error',
            'A linked CertaintyAssessment points to a Synthesis not linked to this ProductVersion';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.synthesis_link sl
          JOIN core.entity_version ev
            ON ev.version_uuid = sl.synthesis_version_uuid
         WHERE sl.product_version_uuid = p_product_version_uuid
           AND ev.version_status = 'invalidated'
    ) OR EXISTS (
        SELECT 1
          FROM product.certainty_link cl
          JOIN core.entity_version ev
            ON ev.version_uuid = cl.certainty_assessment_version_uuid
         WHERE cl.product_version_uuid = p_product_version_uuid
           AND ev.version_status = 'invalidated'
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_DEPENDENCY',
            'error',
            'A directly linked Synthesis or CertaintyAssessment is invalidated';
    END IF;

    IF EXISTS (
        WITH RECURSIVE upstream(version_uuid, path) AS (
            SELECT
                de.source_version_uuid,
                ARRAY[de.target_version_uuid, de.source_version_uuid]::uuid[]
              FROM provenance.dependency_edge de
             WHERE de.target_version_uuid = p_product_version_uuid
               AND de.status = 'active'

            UNION ALL

            SELECT
                de.source_version_uuid,
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
            'INVALIDATED_UPSTREAM_DEPENDENCY',
            'error',
            'An upstream dependency in the product lineage is invalidated';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.certainty_link cl
         WHERE cl.product_version_uuid = p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'NO_FORMAL_CERTAINTY',
            'warning',
            'No formal CertaintyAssessment is linked; rendered output must state that certainty was not formally assessed';
    END IF;

    RETURN;
END;
$gate$;


CREATE OR REPLACE FUNCTION product.evidence_sheet_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $publishable$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.evidence_sheet_publication_issues(
              p_product_version_uuid
          )
         WHERE severity = 'error'
    );
$publishable$;


COMMIT;
