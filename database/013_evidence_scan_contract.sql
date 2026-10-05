-- OES-DBM-2026-0013
-- Fase 3 — Evidence Scan N0 contract projection and publication gate
-- Depends on: baseline + migrations 002–012
-- Status: N0 product contract candidate
-- Date: 2026-10-05
-- This migration intentionally creates no table and adds no column.

BEGIN;

-- ---------------------------------------------------------------------------
-- N0 WRAPPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_scan_assurance_level(
    p_product_version_uuid uuid
)
RETURNS text
LANGUAGE sql
STABLE
AS $wrapper$
    SELECT product.assurance_level(p_product_version_uuid);
$wrapper$;

CREATE OR REPLACE FUNCTION product.evidence_scan_reference_reports(
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
-- N0 PUBLICATION GATE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_scan_publication_issues(
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
    search_source_count integer;
    reference_count integer;
    maturity_category text;
    routing_target text;
    routing_reformulation boolean;
    insufficient_search_basis boolean := false;
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

    IF pv.product_type <> 'evidence_scan' THEN
        RETURN QUERY SELECT
            'WRONG_PRODUCT_TYPE','error',
            format('Expected product_type=evidence_scan, found %s', pv.product_type);
    END IF;

    SELECT count(*)
      INTO primary_count
      FROM product.investigation_link
     WHERE product_version_uuid = p_product_version_uuid
       AND role = 'primary';

    IF primary_count = 0 THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_INVESTIGATION','error',
            'Evidence Scan requires one primary Investigation';
    ELSIF primary_count > 1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_PRIMARY_INVESTIGATIONS','error',
            'Evidence Scan has more than one primary Investigation';
    ELSE
        SELECT il.investigation_version_uuid,
               iv.depth_level,
               iv.evidence_cutoff_date,
               ev.version_status
          INTO primary_investigation_uuid,
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

        IF primary_depth <> 'N0' THEN
            RETURN QUERY SELECT
                'PRIMARY_INVESTIGATION_NOT_N0','error',
                format('Primary Investigation depth is %s, expected N0', primary_depth);
        END IF;

        IF primary_cutoff IS DISTINCT FROM pv.evidence_cutoff_date THEN
            RETURN QUERY SELECT
                'CUTOFF_DATE_MISMATCH','error',
                format(
                    'Product cutoff %s differs from primary Investigation cutoff %s',
                    pv.evidence_cutoff_date, primary_cutoff
                );
        END IF;

        IF primary_entity_status <> 'current' THEN
            RETURN QUERY SELECT
                'PRIMARY_INVESTIGATION_NOT_CURRENT','error',
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
                'MISSING_QUESTION','error',
                'Primary Investigation has no primary QuestionVersion link';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.search s
             WHERE s.investigation_version_uuid = primary_investigation_uuid
               AND s.status = 'completed'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_SEARCH_RECORD','error',
                'At least one completed exploratory Search is required for a formal Evidence Scan';
        END IF;

        SELECT count(DISTINCT s.source_name)
          INTO search_source_count
          FROM investigation.search s
         WHERE s.investigation_version_uuid = primary_investigation_uuid
           AND s.status = 'completed';

        IF search_source_count = 1 THEN
            RETURN QUERY SELECT
                'SINGLE_SEARCH_SOURCE','warning',
                'Only one completed search source is recorded; N0 remains exploratory and non-exhaustive';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.search_hit sh
              JOIN investigation.search s
                ON s.search_uuid = sh.search_uuid
             WHERE s.investigation_version_uuid = primary_investigation_uuid
        ) THEN
            RETURN QUERY SELECT
                'NO_STRUCTURED_SEARCH_HITS','warning',
                'No SearchHit is materialized; the scan must not imply complete screening of retrieved records';
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

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PUBLICATION_DATE','error',
            'Publication date is required for formal Evidence Scan publication';
    END IF;

    IF btrim(coalesce(pv.title,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_TITLE','error','Title is required for an Evidence Scan';
    END IF;

    IF btrim(coalesce(pv.conclusion_text,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_EXPLORATORY_CONCLUSION','error',
            'Exploratory conclusion is required for a formal Evidence Scan';
    END IF;

    IF btrim(coalesce(pv.limitations_summary,'')) = '' THEN
        RETURN QUERY SELECT
            'MISSING_LIMITATIONS','error',
            'Limitations summary is required for a formal Evidence Scan';
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

    IF NOT EXISTS (
        SELECT 1
          FROM provenance.record pr
         WHERE pr.target_version_uuid = p_product_version_uuid
           AND pr.status = 'active'
           AND pr.field_path = 'scan.field_description'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_FIELD_DESCRIPTION','error',
            'Evidence Scan requires a structured field description';
    END IF;

    SELECT pr.source_value->>'category'
      INTO maturity_category
      FROM provenance.record pr
     WHERE pr.target_version_uuid = p_product_version_uuid
       AND pr.status = 'active'
       AND pr.field_path = 'scan.maturity'
     ORDER BY pr.created_at DESC, pr.provenance_uuid
     LIMIT 1;

    IF maturity_category IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_MATURITY_JUDGEMENT','error',
            'Evidence Scan requires a maturity judgement';
    ELSIF maturity_category NOT IN (
        'well_synthesized',
        'partially_synthesized',
        'fragmented',
        'emerging',
        'saturated',
        'insufficient'
    ) THEN
        RETURN QUERY SELECT
            'INVALID_MATURITY_JUDGEMENT','error',
            format('Invalid Evidence Scan maturity category: %s', maturity_category);
    END IF;

    SELECT pr.source_value->>'target',
           COALESCE((pr.source_value->>'requires_question_reformulation')::boolean,false)
      INTO routing_target, routing_reformulation
      FROM provenance.record pr
     WHERE pr.target_version_uuid = p_product_version_uuid
       AND pr.status = 'active'
       AND pr.field_path = 'scan.routing.recommendation'
     ORDER BY pr.created_at DESC, pr.provenance_uuid
     LIMIT 1;

    IF routing_target IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_ROUTING_RECOMMENDATION','error',
            'Evidence Scan requires a routing recommendation';
    ELSIF routing_target NOT IN (
        'stop_after_scan',
        'repeat_n0',
        'N1',
        'N2',
        'N3',
        'N4',
        'evidence_map',
        'overview',
        'other'
    ) THEN
        RETURN QUERY SELECT
            'INVALID_ROUTING_TARGET','error',
            format('Invalid Evidence Scan routing target: %s', routing_target);
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM provenance.record pr
         WHERE pr.target_version_uuid = p_product_version_uuid
           AND pr.status = 'active'
           AND pr.field_path = 'scan.routing.rationale'
           AND btrim(coalesce(pr.source_value->>'text','')) <> ''
    ) THEN
        RETURN QUERY SELECT
            'MISSING_ROUTING_RATIONALE','error',
            'Evidence Scan requires a rationale for the routing recommendation';
    END IF;

    IF routing_reformulation THEN
        RETURN QUERY SELECT
            'ROUTING_REQUIRES_REFORMULATION','warning',
            'Routing recommendation indicates that the question should be reformulated';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM provenance.record pr
         WHERE pr.target_version_uuid = p_product_version_uuid
           AND pr.status = 'active'
           AND pr.field_path LIKE 'scan.gaps.%'
    ) THEN
        RETURN QUERY SELECT
            'APPARENT_EVIDENCE_GAP','warning',
            'One or more apparent evidence gaps are recorded; these remain exploratory findings';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM provenance.record pr
         WHERE pr.target_version_uuid = p_product_version_uuid
           AND pr.status = 'active'
           AND pr.field_path LIKE 'scan.terminology.%'
           AND pr.source_value->>'role' = 'ambiguous'
    ) THEN
        RETURN QUERY SELECT
            'FIELD_TERMINOLOGY_UNSTABLE','warning',
            'Ambiguous terminology is recorded in the Evidence Scan';
    END IF;

    SELECT count(*)
      INTO reference_count
      FROM product.product_reference_reports(p_product_version_uuid);

    IF primary_investigation_uuid IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1
              FROM provenance.record pr
              JOIN investigation.search s
                ON s.search_uuid = pr.process_record_uuid
             WHERE pr.target_version_uuid = p_product_version_uuid
               AND pr.status = 'active'
               AND (
                    pr.field_path = 'scan.field_description'
                    OR pr.field_path LIKE 'scan.gaps.%'
               )
               AND pr.process_type IN (
                    'search_signal',
                    'oes_exploratory_judgement'
               )
               AND s.investigation_version_uuid = primary_investigation_uuid
               AND s.status = 'completed'
        )
          INTO insufficient_search_basis;
    END IF;

    IF reference_count = 0 THEN
        IF maturity_category = 'insufficient' AND insufficient_search_basis THEN
            RETURN QUERY SELECT
                'NO_TRACEABLE_CENTRAL_REPORTS','warning',
                'No central ReportVersion was identified; the insufficient-field judgement is based on recorded exploratory Searches';
        ELSE
            RETURN QUERY SELECT
                'MISSING_TRACEABLE_BASIS','error',
                'No traceable ReportVersion supports the scan and the search-only insufficient-field exception is not satisfied';
        END IF;
    ELSIF reference_count = 1 THEN
        IF primary_investigation_uuid IS NOT NULL
           AND EXISTS (
                SELECT 1
                  FROM provenance.record pr
                 WHERE pr.target_version_uuid = p_product_version_uuid
                   AND pr.status = 'active'
                   AND pr.field_path LIKE 'scan.central_sources.%'
           )
           AND NOT EXISTS (
                SELECT 1
                  FROM product.product_reference_reports(p_product_version_uuid) prr
                  JOIN appraisal.risk_assessment_version rav
                    ON rav.target_entity_uuid = prr.report_entity_uuid
                   AND rav.investigation_version_uuid = primary_investigation_uuid
           )
        THEN
            RETURN QUERY SELECT
                'NO_FORMAL_APPRAISAL','warning',
                'A single central source is recorded without formal appraisal; N0 must remain exploratory';
        END IF;
    END IF;

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
            'A passed AI methodological verification is required for formal Evidence Scan publication';
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
            'Owner governance approval is required for formal persistent Evidence Scan publication';
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

    IF EXISTS (
        SELECT 1
          FROM product.review_record rr
         WHERE rr.product_version_uuid = p_product_version_uuid
           AND rr.status = 'active'
           AND rr.decision = 'rejected'
    ) THEN
        RETURN QUERY SELECT
            'LEGACY_ACTIVE_REJECTION','error',
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
            'NO_EXPERT_INDEPENDENT_REVIEW','warning',
            'No expert independent review is recorded; output must disclose this assurance limit';
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
            'A directly referenced ReportVersion is invalidated';
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
            'An upstream dependency in the Evidence Scan lineage is invalidated';
    END IF;

    RETURN;
END;
$gate$;

CREATE OR REPLACE FUNCTION product.evidence_scan_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $publishable$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.evidence_scan_publication_issues(p_product_version_uuid)
         WHERE severity = 'error'
    );
$publishable$;

-- ---------------------------------------------------------------------------
-- EVIDENCE SCAN VIEW
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_scan_view(
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
          FROM product.evidence_scan_reference_reports(p_product_version_uuid)
    ),
    scan_prov AS (
        SELECT pr.*
          FROM provenance.record pr
         WHERE pr.target_version_uuid = p_product_version_uuid
           AND pr.status = 'active'
           AND pr.field_path LIKE 'scan.%'
    )
    SELECT jsonb_build_object(
        'schema_version', 'oes.evidence_scan_view/0.1',

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

        'objective', (
            SELECT pi.objective
              FROM primary_inv pi
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
                    ON pi.investigation_version_uuid = s.investigation_version_uuid
            ), '[]'::jsonb),
            'count_disclaimer',
            'Search result counts are execution-specific operational signals and are not the total size of the evidence field.'
        ),

        'field_description', (
            SELECT sp.source_value
              FROM scan_prov sp
             WHERE sp.field_path = 'scan.field_description'
             ORDER BY sp.created_at DESC, sp.provenance_uuid
             LIMIT 1
        ),

        'terminology', COALESCE((
            SELECT jsonb_agg(
                sp.source_value
                ORDER BY COALESCE(
                    NULLIF(substring(sp.field_path from '([0-9]+)$'),'')::integer,
                    2147483647
                ),
                sp.provenance_uuid
            )
              FROM scan_prov sp
             WHERE sp.field_path ~ '^scan[.]terminology[.][0-9]+$'
        ), '[]'::jsonb),

        'volume_signals', COALESCE((
            SELECT jsonb_agg(
                sp.source_value
                ORDER BY COALESCE(
                    NULLIF(substring(sp.field_path from '([0-9]+)$'),'')::integer,
                    2147483647
                ),
                sp.provenance_uuid
            )
              FROM scan_prov sp
             WHERE sp.field_path ~ '^scan[.]volume_signals[.][0-9]+$'
        ), '[]'::jsonb),

        'evidence_types', COALESCE((
            SELECT jsonb_agg(
                sp.source_value
                ORDER BY COALESCE(
                    NULLIF(substring(sp.field_path from '([0-9]+)$'),'')::integer,
                    2147483647
                ),
                sp.provenance_uuid
            )
              FROM scan_prov sp
             WHERE sp.field_path ~ '^scan[.]evidence_types[.][0-9]+$'
        ), '[]'::jsonb),

        'central_sources', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'report_id', re.oes_id,
                    'report_entity_uuid', rv.entity_uuid,
                    'report_version_uuid', rv.version_uuid,
                    'title', rv.title,
                    'publication_date', rv.publication_date,
                    'publication_status', rv.publication_status,
                    'source_location', sp.source_location,
                    'component', sp.source_value
                )
                ORDER BY COALESCE(
                    NULLIF(substring(sp.field_path from '([0-9]+)$'),'')::integer,
                    2147483647
                ),
                sp.provenance_uuid
            )
              FROM scan_prov sp
              JOIN evidence.report_version rv
                ON rv.version_uuid = sp.source_report_version_uuid
              JOIN core.entity re
                ON re.entity_uuid = rv.entity_uuid
             WHERE sp.field_path ~ '^scan[.]central_sources[.][0-9]+$'
        ), '[]'::jsonb),

        'maturity', (
            SELECT sp.source_value
              FROM scan_prov sp
             WHERE sp.field_path = 'scan.maturity'
             ORDER BY sp.created_at DESC, sp.provenance_uuid
             LIMIT 1
        ),

        'controversies', COALESCE((
            SELECT jsonb_agg(
                sp.source_value
                ORDER BY COALESCE(
                    NULLIF(substring(sp.field_path from '([0-9]+)$'),'')::integer,
                    2147483647
                ),
                sp.provenance_uuid
            )
              FROM scan_prov sp
             WHERE sp.field_path ~ '^scan[.]controversies[.][0-9]+$'
        ), '[]'::jsonb),

        'gaps', COALESCE((
            SELECT jsonb_agg(
                sp.source_value
                ORDER BY COALESCE(
                    NULLIF(substring(sp.field_path from '([0-9]+)$'),'')::integer,
                    2147483647
                ),
                sp.provenance_uuid
            )
              FROM scan_prov sp
             WHERE sp.field_path ~ '^scan[.]gaps[.][0-9]+$'
        ), '[]'::jsonb),

        'candidate_questions', COALESCE((
            SELECT jsonb_agg(
                sp.source_value
                ORDER BY COALESCE(
                    NULLIF(substring(sp.field_path from '([0-9]+)$'),'')::integer,
                    2147483647
                ),
                sp.provenance_uuid
            )
              FROM scan_prov sp
             WHERE sp.field_path ~ '^scan[.]subquestions[.][0-9]+$'
        ), '[]'::jsonb),

        'routing_recommendation', jsonb_build_object(
            'recommendation', (
                SELECT sp.source_value
                  FROM scan_prov sp
                 WHERE sp.field_path = 'scan.routing.recommendation'
                 ORDER BY sp.created_at DESC, sp.provenance_uuid
                 LIMIT 1
            ),
            'rationale', (
                SELECT sp.source_value
                  FROM scan_prov sp
                 WHERE sp.field_path = 'scan.routing.rationale'
                 ORDER BY sp.created_at DESC, sp.provenance_uuid
                 LIMIT 1
            )
        ),

        'conclusion', (
            SELECT jsonb_build_object(
                'text', pv.conclusion_text,
                'type', 'exploratory'
            )
              FROM product.product_version pv
             WHERE pv.version_uuid = p_product_version_uuid
        ),

        'limitations', (
            SELECT jsonb_build_object(
                'summary', pv.limitations_summary,
                'present', btrim(coalesce(pv.limitations_summary,'')) <> ''
            )
              FROM product.product_version pv
             WHERE pv.version_uuid = p_product_version_uuid
        ),

        'applicability', (
            SELECT jsonb_build_object(
                'summary', pv.applicability_summary,
                'formal_assessment', false
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

        'audit', jsonb_build_object(
            'publishable',
                product.evidence_scan_is_publishable(p_product_version_uuid),
            'assurance_level',
                product.evidence_scan_assurance_level(p_product_version_uuid),
            'expert_independent_reviewed', EXISTS (
                SELECT 1
                  FROM product.assurance_record ar
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
                    )
                    ORDER BY ar.performed_at, ar.assurance_uuid
                )
                  FROM product.assurance_record ar
                 WHERE ar.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb),
            'assurance_disclosure',
                CASE product.evidence_scan_assurance_level(p_product_version_uuid)
                    WHEN 'A3' THEN
                        'Verificação metodológica assistida por IA, aprovação de governança e revisão especializada independente registradas.'
                    WHEN 'A2' THEN
                        'Verificação metodológica assistida por IA e aprovação de governança registradas; revisão especializada independente não realizada.'
                    WHEN 'A1' THEN
                        'Verificação metodológica assistida por IA registrada; aprovação de governança ainda não registrada; revisão especializada independente não realizada.'
                    ELSE
                        'Garantia metodológica formal ainda não concluída.'
                END,
            'publication_issues', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'issue_code', i.issue_code,
                        'severity', i.severity,
                        'message', i.message
                    )
                    ORDER BY i.severity, i.issue_code
                )
                  FROM product.evidence_scan_publication_issues(
                      p_product_version_uuid
                  ) i
            ), '[]'::jsonb),
            'lineage_available', EXISTS (
                SELECT 1
                  FROM provenance.dependency_edge de
                 WHERE de.target_version_uuid = p_product_version_uuid
                    OR de.source_version_uuid = p_product_version_uuid
            ),
            'traceable_basis_type',
                CASE
                    WHEN EXISTS (SELECT 1 FROM refs)
                     AND EXISTS (
                        SELECT 1
                          FROM scan_prov sp
                         WHERE sp.process_record_uuid IS NOT NULL
                           AND sp.process_type IN (
                               'search_signal',
                               'oes_exploratory_judgement'
                           )
                     )
                    THEN 'mixed'
                    WHEN EXISTS (SELECT 1 FROM refs)
                    THEN 'reports'
                    WHEN (
                        SELECT sp.source_value->>'category'
                          FROM scan_prov sp
                         WHERE sp.field_path = 'scan.maturity'
                         ORDER BY sp.created_at DESC, sp.provenance_uuid
                         LIMIT 1
                    ) = 'insufficient'
                    THEN 'search_only_insufficient'
                    ELSE 'none'
                END
        )
    )
    INTO payload;

    RETURN payload;
END;
$view$;

COMMIT;
