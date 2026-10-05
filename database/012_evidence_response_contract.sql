-- OES-DBM-2026-0012
-- Fase 3 — Evidence Response N1 contract projection and publication gate
-- Depends on: baseline + migrations 002–011
-- Status: N1 product contract candidate
-- Date: 2026-10-05

BEGIN;

-- ---------------------------------------------------------------------------
-- GENERIC ASSURANCE DERIVATION
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.assurance_level(
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

CREATE OR REPLACE FUNCTION product.evidence_sheet_assurance_level(
    p_product_version_uuid uuid
)
RETURNS text
LANGUAGE sql
STABLE
AS $wrapper$
    SELECT product.assurance_level(p_product_version_uuid);
$wrapper$;

CREATE OR REPLACE FUNCTION product.evidence_response_assurance_level(
    p_product_version_uuid uuid
)
RETURNS text
LANGUAGE sql
STABLE
AS $wrapper$
    SELECT product.assurance_level(p_product_version_uuid);
$wrapper$;

-- ---------------------------------------------------------------------------
-- GENERIC PRODUCT REFERENCE REPORTS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.product_reference_reports(
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
AS $refs$
WITH RECURSIVE seed_versions(version_uuid) AS (
    SELECT p_product_version_uuid

    UNION

    SELECT sl.synthesis_version_uuid
      FROM product.synthesis_link sl
     WHERE sl.product_version_uuid = p_product_version_uuid

    UNION

    SELECT cl.certainty_assessment_version_uuid
      FROM product.certainty_link cl
     WHERE cl.product_version_uuid = p_product_version_uuid
),
upstream(version_uuid, path) AS (
    SELECT sv.version_uuid, ARRAY[sv.version_uuid]::uuid[]
      FROM seed_versions sv

    UNION ALL

    SELECT de.source_version_uuid, u.path || de.source_version_uuid
      FROM upstream u
      JOIN provenance.dependency_edge de
        ON de.target_version_uuid = u.version_uuid
       AND de.status = 'active'
     WHERE cardinality(u.path) < 64
       AND NOT de.source_version_uuid = ANY(u.path)
),
source_rows AS (
    SELECT rs.report_version_uuid, rs.source_location
      FROM upstream u
      JOIN synthesis.contribution c
        ON c.synthesis_version_uuid = u.version_uuid
      JOIN evidence.result_source rs
        ON rs.result_version_uuid = c.result_version_uuid

    UNION ALL

    SELECT pr.source_report_version_uuid,
           COALESCE(NULLIF(btrim(pr.source_location),''),
                    NULLIF(btrim(pr.field_path),''),
                    'provenance') AS source_location
      FROM upstream u
      JOIN provenance.record pr
        ON pr.target_version_uuid = u.version_uuid
       AND pr.status = 'active'
     WHERE pr.source_report_version_uuid IS NOT NULL
),
grouped AS (
    SELECT sr.report_version_uuid,
           jsonb_agg(DISTINCT sr.source_location ORDER BY sr.source_location) AS source_locations
      FROM source_rows sr
     GROUP BY sr.report_version_uuid
)
SELECT re.oes_id AS report_id,
       rv.entity_uuid AS report_entity_uuid,
       rv.version_uuid AS report_version_uuid,
       rv.title,
       rv.publication_date,
       rv.publication_status,
       g.source_locations
  FROM grouped g
  JOIN evidence.report_version rv
    ON rv.version_uuid = g.report_version_uuid
  JOIN core.entity re
    ON re.entity_uuid = rv.entity_uuid
 ORDER BY rv.publication_date NULLS LAST, re.oes_id;
$refs$;

CREATE OR REPLACE FUNCTION product.evidence_response_reference_reports(
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
    SELECT * FROM product.product_reference_reports(p_product_version_uuid);
$wrapper$;

-- ---------------------------------------------------------------------------
-- N1 PUBLICATION GATE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_response_publication_issues(
    p_product_version_uuid uuid
)
RETURNS TABLE (issue_code text, severity text, message text)
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
    reference_count integer;
    search_source_count integer;
BEGIN
    SELECT * INTO pv
      FROM product.product_version
     WHERE version_uuid = p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'MISSING_PRODUCT_VERSION','error','ProductVersion does not exist';
        RETURN;
    END IF;

    IF pv.product_type <> 'evidence_response' THEN
        RETURN QUERY SELECT 'WRONG_PRODUCT_TYPE','error',
            format('Expected product_type=evidence_response, found %s', pv.product_type);
    END IF;

    SELECT count(*) INTO primary_count
      FROM product.investigation_link
     WHERE product_version_uuid = p_product_version_uuid
       AND role = 'primary';

    IF primary_count = 0 THEN
        RETURN QUERY SELECT 'MISSING_PRIMARY_INVESTIGATION','error',
            'Evidence Response requires one primary Investigation';
    ELSIF primary_count > 1 THEN
        RETURN QUERY SELECT 'MULTIPLE_PRIMARY_INVESTIGATIONS','error',
            'Evidence Response has more than one primary Investigation';
    ELSE
        SELECT il.investigation_version_uuid, iv.depth_level, iv.evidence_cutoff_date, ev.version_status
          INTO primary_investigation_uuid, primary_depth, primary_cutoff, primary_entity_status
          FROM product.investigation_link il
          JOIN investigation.investigation_version iv
            ON iv.version_uuid = il.investigation_version_uuid
          JOIN core.entity_version ev
            ON ev.version_uuid = iv.version_uuid
         WHERE il.product_version_uuid = p_product_version_uuid
           AND il.role = 'primary';

        IF primary_depth <> 'N1' THEN
            RETURN QUERY SELECT 'PRIMARY_INVESTIGATION_NOT_N1','error',
                format('Primary Investigation depth is %s, expected N1', primary_depth);
        END IF;

        IF primary_cutoff IS DISTINCT FROM pv.evidence_cutoff_date THEN
            RETURN QUERY SELECT 'CUTOFF_DATE_MISMATCH','error',
                format('Product cutoff %s differs from primary Investigation cutoff %s',
                       pv.evidence_cutoff_date, primary_cutoff);
        END IF;

        IF primary_entity_status <> 'current' THEN
            RETURN QUERY SELECT 'PRIMARY_INVESTIGATION_NOT_CURRENT','error',
                format('Primary Investigation version_status is %s', primary_entity_status);
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM investigation.investigation_question iq
             WHERE iq.investigation_version_uuid = primary_investigation_uuid
               AND iq.role = 'primary'
        ) THEN
            RETURN QUERY SELECT 'MISSING_QUESTION','error',
                'Primary Investigation has no primary QuestionVersion link';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM investigation.search s
             WHERE s.investigation_version_uuid = primary_investigation_uuid
               AND s.status = 'completed'
        ) THEN
            RETURN QUERY SELECT 'MISSING_SEARCH_RECORD','error',
                'At least one completed structured search is required for an Evidence Response';
        END IF;

        SELECT count(DISTINCT s.source_name) INTO search_source_count
          FROM investigation.search s
         WHERE s.investigation_version_uuid = primary_investigation_uuid
           AND s.status = 'completed';

        IF search_source_count = 1 THEN
            RETURN QUERY SELECT 'SINGLE_SEARCH_SOURCE','warning',
                'Only one completed search source is recorded; N1 remains selective and non-exhaustive';
        END IF;
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT 'MISSING_PUBLICATION_DATE','error',
            'Publication date is required for publication';
    END IF;

    IF btrim(coalesce(pv.title,'')) = '' THEN
        RETURN QUERY SELECT 'MISSING_TITLE','error','Title is required for an Evidence Response';
    END IF;

    IF btrim(coalesce(pv.conclusion_text,'')) = '' THEN
        RETURN QUERY SELECT 'MISSING_CONCLUSION','error','Conclusion is required for an Evidence Response';
    END IF;

    IF btrim(coalesce(pv.limitations_summary,'')) = '' THEN
        RETURN QUERY SELECT 'MISSING_LIMITATIONS','error',
            'Limitations summary is required for an Evidence Response';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.currency_state cs
         WHERE cs.product_version_uuid = p_product_version_uuid
           AND cs.record_status = 'active'
    ) THEN
        RETURN QUERY SELECT 'MISSING_CURRENCY_STATE','error','An active currency state is required';
    END IF;

    SELECT count(*) INTO reference_count
      FROM product.product_reference_reports(p_product_version_uuid);

    IF reference_count = 0 THEN
        RETURN QUERY SELECT 'MISSING_TRACEABLE_SOURCE','error',
            'At least one traceable ReportVersion must support the Evidence Response';
    ELSIF reference_count = 1 THEN
        RETURN QUERY SELECT 'SINGLE_REFERENCE_SOURCE','warning',
            'Only one traceable source supports the Evidence Response; limitations must remain explicit';

        IF primary_investigation_uuid IS NOT NULL AND NOT EXISTS (
            SELECT 1
              FROM product.product_reference_reports(p_product_version_uuid) prr
              JOIN appraisal.risk_assessment_version rav
                ON rav.target_entity_uuid = prr.report_entity_uuid
               AND rav.investigation_version_uuid = primary_investigation_uuid
        ) THEN
            RETURN QUERY SELECT 'NO_FORMAL_APPRAISAL_OF_SINGLE_SOURCE','warning',
                'A single source supports the response and no formal appraisal of that source is recorded';
        END IF;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision = 'passed'
    ) THEN
        RETURN QUERY SELECT 'MISSING_AI_METHODOLOGICAL_VERIFICATION','error',
            'A passed AI methodological verification is required for standard N1 publication';
    END IF;

    IF EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision IN ('revise','failed')
    ) THEN
        RETURN QUERY SELECT 'ACTIVE_AI_METHOD_BLOCK','error',
            'Active AI methodological verification blocks publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'owner_governance_approval'
           AND ar.decision = 'approved'
    ) THEN
        RETURN QUERY SELECT 'MISSING_OWNER_APPROVAL','error',
            'Owner governance approval is required for standard N1 publication';
    END IF;

    IF EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'owner_governance_approval'
           AND ar.decision IN ('revise','rejected')
    ) THEN
        RETURN QUERY SELECT 'ACTIVE_OWNER_BLOCK','error',
            'Active owner governance decision blocks publication';
    END IF;

    IF EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'expert_independent_review'
           AND ar.decision IN ('revise','rejected')
    ) THEN
        RETURN QUERY SELECT 'ACTIVE_EXPERT_BLOCK','error',
            'Active expert independent review blocks publication';
    END IF;

    IF EXISTS (
        SELECT 1 FROM product.review_record rr
         WHERE rr.product_version_uuid = p_product_version_uuid
           AND rr.status = 'active'
           AND rr.decision = 'rejected'
    ) THEN
        RETURN QUERY SELECT 'LEGACY_ACTIVE_REJECTION','error',
            'An active legacy rejected review blocks publication until explicitly resolved';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'expert_independent_review'
           AND ar.decision = 'approved'
    ) THEN
        RETURN QUERY SELECT 'NO_EXPERT_INDEPENDENT_REVIEW','warning',
            'No expert independent review is recorded; output must disclose this assurance limit';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM core.entity_version ev
         WHERE ev.version_uuid = p_product_version_uuid
           AND ev.version_status = 'current'
    ) THEN
        RETURN QUERY SELECT 'NOT_CURRENT_ENTITY_VERSION','error',
            'ProductVersion must be the current EntityVersion';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.synthesis_link sl
          JOIN core.entity_version ev ON ev.version_uuid = sl.synthesis_version_uuid
         WHERE sl.product_version_uuid = p_product_version_uuid
           AND ev.version_status = 'invalidated'
    ) OR EXISTS (
        SELECT 1
          FROM product.certainty_link cl
          JOIN core.entity_version ev ON ev.version_uuid = cl.certainty_assessment_version_uuid
         WHERE cl.product_version_uuid = p_product_version_uuid
           AND ev.version_status = 'invalidated'
    ) THEN
        RETURN QUERY SELECT 'INVALIDATED_DEPENDENCY','error',
            'A directly linked Synthesis or CertaintyAssessment is invalidated';
    END IF;

    IF EXISTS (
        WITH RECURSIVE upstream(version_uuid, path) AS (
            SELECT de.source_version_uuid,
                   ARRAY[de.target_version_uuid, de.source_version_uuid]::uuid[]
              FROM provenance.dependency_edge de
             WHERE de.target_version_uuid = p_product_version_uuid
               AND de.status = 'active'
            UNION ALL
            SELECT de.source_version_uuid, u.path || de.source_version_uuid
              FROM upstream u
              JOIN provenance.dependency_edge de
                ON de.target_version_uuid = u.version_uuid
               AND de.status = 'active'
             WHERE cardinality(u.path) < 64
               AND NOT de.source_version_uuid = ANY(u.path)
        )
        SELECT 1 FROM upstream u
        JOIN core.entity_version ev ON ev.version_uuid = u.version_uuid
        WHERE ev.version_status = 'invalidated'
        LIMIT 1
    ) THEN
        RETURN QUERY SELECT 'INVALIDATED_UPSTREAM_DEPENDENCY','error',
            'An upstream dependency in the product lineage is invalidated';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.certainty_link cl
         WHERE cl.product_version_uuid = p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT 'NO_FORMAL_CERTAINTY','warning',
            'No formal CertaintyAssessment is linked; uncertainty must be communicated descriptively';
    END IF;

    RETURN;
END;
$gate$;

CREATE OR REPLACE FUNCTION product.evidence_response_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $publishable$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.evidence_response_publication_issues(p_product_version_uuid)
         WHERE severity = 'error'
    );
$publishable$;

-- ---------------------------------------------------------------------------
-- EVIDENCE RESPONSE VIEW
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_response_view(
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
        SELECT 1 FROM product.product_version
         WHERE version_uuid = p_product_version_uuid
    ) THEN
        RETURN NULL;
    END IF;

    WITH primary_inv AS (
        SELECT il.investigation_version_uuid,
               iv.entity_uuid AS investigation_entity_uuid,
               ie.oes_id AS investigation_id,
               iv.investigation_type, iv.depth_level, iv.maintenance_level,
               iv.objective, iv.start_date, iv.evidence_cutoff_date
          FROM product.investigation_link il
          JOIN investigation.investigation_version iv
            ON iv.version_uuid = il.investigation_version_uuid
          JOIN core.entity ie ON ie.entity_uuid = iv.entity_uuid
         WHERE il.product_version_uuid = p_product_version_uuid
           AND il.role = 'primary'
         LIMIT 1
    ),
    primary_q AS (
        SELECT qe.oes_id AS question_id,
               qv.entity_uuid AS question_entity_uuid,
               qv.version_uuid AS question_version_uuid,
               qv.original_text, qv.normalized_text, qv.question_type,
               qv.structure_type, qv.context_payload, qv.time_horizon_payload
          FROM primary_inv pi
          JOIN investigation.investigation_question iq
            ON iq.investigation_version_uuid = pi.investigation_version_uuid
           AND iq.role = 'primary'
          JOIN investigation.question_version qv
            ON qv.version_uuid = iq.question_version_uuid
          JOIN core.entity qe ON qe.entity_uuid = qv.entity_uuid
         ORDER BY iq.sequence_no NULLS LAST, qv.version_uuid
         LIMIT 1
    ),
    refs AS (
        SELECT * FROM product.evidence_response_reference_reports(p_product_version_uuid)
    )
    SELECT jsonb_build_object(
        'schema_version', 'oes.evidence_response_view/0.1',

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
              JOIN core.entity_version ev ON ev.version_uuid = pv.version_uuid
              JOIN core.entity pe ON pe.entity_uuid = pv.entity_uuid
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
            ) FROM primary_q pq
        ),

        'routing', (
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
            ) FROM primary_inv pi
        ),

        'answer', (
            SELECT jsonb_build_object(
                'text', pv.conclusion_text,
                'recommendation_present', false
            ) FROM product.product_version pv
             WHERE pv.version_uuid = p_product_version_uuid
        ),

        'method', jsonb_build_object(
            'non_exhaustive', true,
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
                        'status', s.status
                    ) ORDER BY s.executed_at, s.search_uuid
                )
                  FROM investigation.search s
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid = s.investigation_version_uuid
            ), '[]'::jsonb)
        ),

        'key_sources', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'report_id', r.report_id,
                    'report_entity_uuid', r.report_entity_uuid,
                    'report_version_uuid', r.report_version_uuid,
                    'title', r.title,
                    'publication_date', r.publication_date,
                    'publication_status', r.publication_status,
                    'source_locations', r.source_locations,
                    'roles', COALESCE((
                        SELECT jsonb_agg(DISTINCT x.role ORDER BY x.role)
                          FROM (
                            SELECT CASE
                                WHEN pr.field_path = 'conclusion_text'
                                  OR pr.field_path LIKE 'key_results.%' THEN 'decisive'
                                WHEN pr.field_path LIKE 'applicability%' THEN 'contextual'
                                ELSE 'supporting'
                            END AS role
                              FROM provenance.record pr
                             WHERE pr.target_version_uuid = p_product_version_uuid
                               AND pr.source_report_version_uuid = r.report_version_uuid
                               AND pr.status = 'active'
                          ) x
                    ), '["linked_evidence"]'::jsonb),
                    'formal_appraisal_count', (
                        SELECT count(*)
                          FROM appraisal.risk_assessment_version rav
                          JOIN primary_inv pi
                            ON rav.investigation_version_uuid = pi.investigation_version_uuid
                         WHERE rav.target_entity_uuid = r.report_entity_uuid
                    )
                ) ORDER BY r.publication_date NULLS LAST, r.report_id
            ) FROM refs r
        ), '[]'::jsonb),

        'key_results', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'field_path', pr.field_path,
                    'source_report_id', re.oes_id,
                    'source_report_version_uuid', pr.source_report_version_uuid,
                    'source_location', pr.source_location,
                    'source_value', pr.source_value,
                    'process_type', pr.process_type,
                    'transformation', pr.transformation
                ) ORDER BY pr.field_path, pr.provenance_uuid
            )
              FROM provenance.record pr
              LEFT JOIN evidence.report_version rv
                ON rv.version_uuid = pr.source_report_version_uuid
              LEFT JOIN core.entity re
                ON re.entity_uuid = rv.entity_uuid
             WHERE pr.target_version_uuid = p_product_version_uuid
               AND pr.status = 'active'
               AND pr.field_path LIKE 'key_results.%'
        ), '[]'::jsonb),

        'certainty', jsonb_build_object(
            'formal_assessment', EXISTS (
                SELECT 1 FROM product.certainty_link cl
                 WHERE cl.product_version_uuid = p_product_version_uuid
            ),
            'assessments', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'certainty_id', ce.oes_id,
                        'version_uuid', cav.version_uuid,
                        'framework', cav.framework,
                        'framework_version', cav.framework_version,
                        'final_level', cav.final_level,
                        'evidence_state', cav.evidence_state,
                        'assessment_date', cav.assessment_date,
                        'role', cl.role
                    ) ORDER BY cl.sequence_no NULLS LAST, cav.version_uuid
                )
                  FROM product.certainty_link cl
                  JOIN appraisal.certainty_assessment_version cav
                    ON cav.version_uuid = cl.certainty_assessment_version_uuid
                  JOIN core.entity ce ON ce.entity_uuid = cav.entity_uuid
                 WHERE cl.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb)
        ),

        'limitations', (
            SELECT jsonb_build_object(
                'summary', pv.limitations_summary,
                'present', btrim(coalesce(pv.limitations_summary,'')) <> ''
            ) FROM product.product_version pv
             WHERE pv.version_uuid = p_product_version_uuid
        ),

        'applicability', (
            SELECT jsonb_build_object(
                'summary', pv.applicability_summary,
                'formal_assessment', false
            ) FROM product.product_version pv
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
                ) ORDER BY r.publication_date NULLS LAST, r.report_id
            ) FROM refs r
        ), '[]'::jsonb),

        'audit', jsonb_build_object(
            'publishable', product.evidence_response_is_publishable(p_product_version_uuid),
            'assurance_level', product.evidence_response_assurance_level(p_product_version_uuid),
            'expert_independent_reviewed', EXISTS (
                SELECT 1 FROM product.assurance_record ar
                 WHERE ar.product_version_uuid = p_product_version_uuid
                   AND ar.status = 'active'
                   AND ar.assurance_type = 'expert_independent_review'
                   AND ar.decision = 'approved'
            ),
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
                    ) ORDER BY ar.performed_at, ar.assurance_uuid
                ) FROM product.assurance_record ar
                 WHERE ar.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb),
            'assurance_disclosure', CASE product.evidence_response_assurance_level(p_product_version_uuid)
                WHEN 'A3' THEN 'Verificação metodológica assistida por IA, aprovação de governança e revisão especializada independente registradas.'
                WHEN 'A2' THEN 'Verificação metodológica assistida por IA e aprovação de governança registradas; revisão especializada independente não realizada.'
                WHEN 'A1' THEN 'Verificação metodológica assistida por IA registrada; aprovação de governança ainda não registrada; revisão especializada independente não realizada.'
                ELSE 'Garantia metodológica formal ainda não concluída.'
            END,
            'publication_issues', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'issue_code', i.issue_code,
                        'severity', i.severity,
                        'message', i.message
                    ) ORDER BY i.severity, i.issue_code
                )
                  FROM product.evidence_response_publication_issues(p_product_version_uuid) i
            ), '[]'::jsonb),
            'lineage_available', EXISTS (
                SELECT 1 FROM provenance.dependency_edge de
                 WHERE de.target_version_uuid = p_product_version_uuid
                    OR de.source_version_uuid = p_product_version_uuid
            )
        )
    ) INTO payload;

    RETURN payload;
END;
$view$;

COMMIT;