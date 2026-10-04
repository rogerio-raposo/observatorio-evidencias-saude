-- OES-DBM-2026-0006
-- Fase 3 — Evidence Sheet product contract
-- Depends on: baseline + migrations 002–005
-- Status: experimental baseline extension
-- Date: 2026-10-04

BEGIN;

ALTER TABLE product.product_version
    ADD COLUMN limitations_summary text;

ALTER TABLE product.product_version
    ADD CONSTRAINT ck_product_editorial_status
    CHECK (
        status IN (
            'draft',
            'under_review',
            'published',
            'superseded',
            'archived'
        )
    );

CREATE UNIQUE INDEX ux_product_one_primary_investigation
    ON product.investigation_link(product_version_uuid)
    WHERE role = 'primary';

CREATE TABLE product.currency_state (
    currency_state_uuid uuid PRIMARY KEY,
    product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    currency_status text NOT NULL CHECK (
        currency_status IN (
            'current',
            'under_evaluation',
            'update_recommended',
            'outdated',
            'archived'
        )
    ),
    assessed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assessed_by text,
    rationale text NOT NULL,
    supersedes_currency_state_uuid uuid,
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    UNIQUE (currency_state_uuid, product_version_uuid),
    FOREIGN KEY (
        supersedes_currency_state_uuid,
        product_version_uuid
    ) REFERENCES product.currency_state(
        currency_state_uuid,
        product_version_uuid
    ),
    CHECK (
        supersedes_currency_state_uuid IS NULL
        OR supersedes_currency_state_uuid <> currency_state_uuid
    )
);

CREATE UNIQUE INDEX ux_currency_state_active
    ON product.currency_state(product_version_uuid)
    WHERE record_status = 'active';

CREATE INDEX ix_currency_state_product
    ON product.currency_state(product_version_uuid);

CREATE VIEW product.current_currency_state AS
SELECT
    currency_state_uuid,
    product_version_uuid,
    currency_status,
    assessed_at,
    assessed_by,
    rationale
FROM product.currency_state
WHERE record_status = 'active';

CREATE TABLE product.version_change_class (
    product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    change_class text NOT NULL CHECK (
        change_class IN (
            'editorial',
            'new_evidence',
            'scientific_correction',
            'quantitative_change',
            'certainty_change',
            'applicability_change',
            'conclusion_change'
        )
    ),
    rationale text,
    sequence_no integer,
    PRIMARY KEY (product_version_uuid, change_class)
);

CREATE TABLE product.review_record (
    review_uuid uuid PRIMARY KEY,
    product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    reviewer text NOT NULL,
    role text NOT NULL,
    independent_flag boolean NOT NULL DEFAULT false,
    decision text NOT NULL CHECK (
        decision IN ('approved','revise','rejected')
    ),
    reviewed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes text,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    )
);

CREATE INDEX ix_product_review_version
    ON product.review_record(product_version_uuid);

CREATE INDEX ix_product_review_active_decision
    ON product.review_record(product_version_uuid, decision)
    WHERE status = 'active';

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

    IF NOT EXISTS (
        SELECT 1
          FROM product.review_record rr
         WHERE rr.product_version_uuid = p_product_version_uuid
           AND rr.status = 'active'
           AND rr.decision = 'approved'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_APPROVED_REVIEW',
            'error',
            'At least one active approved human review is required';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.review_record rr
         WHERE rr.product_version_uuid = p_product_version_uuid
           AND rr.status = 'active'
           AND rr.decision = 'rejected'
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_REJECTION',
            'error',
            'An active rejected review blocks publication';
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
