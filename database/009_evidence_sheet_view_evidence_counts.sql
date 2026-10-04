-- OES-DBM-2026-0009
-- Fase 3 — EvidenceSheetView evidence-type counts
-- Depends on: baseline + migrations 002–008
-- Status: compatible rendering projection hardening
-- Date: 2026-10-04

BEGIN;

CREATE OR REPLACE FUNCTION product.evidence_sheet_reference_reports(
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
    SELECT
        sv.version_uuid,
        ARRAY[sv.version_uuid]::uuid[]
      FROM seed_versions sv

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
),
source_rows AS (
    -- Reports used by Results contributing to any linked/upstream Synthesis.
    SELECT
        rs.report_version_uuid,
        rs.source_location
      FROM upstream u
      JOIN synthesis.contribution c
        ON c.synthesis_version_uuid = u.version_uuid
      JOIN evidence.result_source rs
        ON rs.result_version_uuid = c.result_version_uuid

    UNION ALL

    -- Reports used directly as provenance for Product/Synthesis/Certainty
    -- or any upstream version reached through the dependency graph.
    SELECT
        pr.source_report_version_uuid,
        COALESCE(
            NULLIF(btrim(pr.source_location),''),
            NULLIF(btrim(pr.field_path),''),
            'provenance'
        ) AS source_location
      FROM upstream u
      JOIN provenance.record pr
        ON pr.target_version_uuid = u.version_uuid
       AND pr.status = 'active'
     WHERE pr.source_report_version_uuid IS NOT NULL
),
grouped AS (
    SELECT
        sr.report_version_uuid,
        jsonb_agg(
            DISTINCT sr.source_location
            ORDER BY sr.source_location
        ) AS source_locations
      FROM source_rows sr
     GROUP BY sr.report_version_uuid
)
SELECT
    re.oes_id AS report_id,
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

CREATE OR REPLACE FUNCTION product.evidence_sheet_view(
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
        SELECT
            il.investigation_version_uuid,
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
        SELECT
            qe.oes_id AS question_id,
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
    linked_synth AS (
        SELECT
            sl.role,
            sl.sequence_no,
            sv.*,
            se.oes_id AS synthesis_id
        FROM product.synthesis_link sl
        JOIN synthesis.synthesis_version sv
          ON sv.version_uuid = sl.synthesis_version_uuid
        JOIN core.entity se
          ON se.entity_uuid = sv.entity_uuid
        WHERE sl.product_version_uuid = p_product_version_uuid
    ),
    linked_cert AS (
        SELECT
            cl.role,
            cl.sequence_no,
            cav.*,
            ce.oes_id AS certainty_id
        FROM product.certainty_link cl
        JOIN appraisal.certainty_assessment_version cav
          ON cav.version_uuid = cl.certainty_assessment_version_uuid
        JOIN core.entity ce
          ON ce.entity_uuid = cav.entity_uuid
        WHERE cl.product_version_uuid = p_product_version_uuid
    ),
    contributed_results AS (
        SELECT DISTINCT
            c.synthesis_version_uuid,
            rv.version_uuid AS result_version_uuid,
            r.entity_uuid AS result_entity_uuid,
            r.study_entity_uuid
        FROM linked_synth ls
        JOIN synthesis.contribution c
          ON c.synthesis_version_uuid = ls.version_uuid
        JOIN evidence.result_version rv
          ON rv.version_uuid = c.result_version_uuid
        JOIN evidence.result r
          ON r.entity_uuid = rv.entity_uuid
    ),
    used_reports AS (
        SELECT DISTINCT
            rs.report_version_uuid,
            rv.entity_uuid AS result_entity_uuid
        FROM contributed_results cr
        JOIN evidence.result_version rv
          ON rv.version_uuid = cr.result_version_uuid
        JOIN evidence.result_source rs
          ON rs.result_version_uuid = rv.version_uuid
    )
    SELECT jsonb_build_object(
        'schema_version', 'oes.evidence_sheet_view/0.1',

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
                'currency_status', ccs.currency_status,
                'currency_assessed_at', ccs.assessed_at
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
            )
            FROM primary_inv pi
        ),

        'method', jsonb_build_object(
            'searches', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'search_id', s.oes_search_id,
                        'source_name', s.source_name,
                        'platform', s.platform,
                        'executed_at', s.executed_at,
                        'result_count', s.result_count,
                        'strategy_version', s.strategy_version,
                        'status', s.status
                    )
                    ORDER BY s.executed_at, s.search_uuid
                )
                FROM investigation.search s
                JOIN primary_inv pi
                  ON pi.investigation_version_uuid = s.investigation_version_uuid
            ), '[]'::jsonb),

            'last_search_at', (
                SELECT max(s.executed_at)
                FROM investigation.search s
                JOIN primary_inv pi
                  ON pi.investigation_version_uuid = s.investigation_version_uuid
            ),

            'screening_summary', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'stage', x.stage,
                        'decision', x.decision,
                        'count', x.n
                    )
                    ORDER BY x.stage, x.decision
                )
                FROM (
                    SELECT sd.stage, sd.decision, count(*) AS n
                    FROM investigation.screening_decision sd
                    JOIN primary_inv pi
                      ON pi.investigation_version_uuid = sd.investigation_version_uuid
                    GROUP BY sd.stage, sd.decision
                ) x
            ), '[]'::jsonb),

            'synthesis_methods', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'synthesis_id', ls.synthesis_id,
                        'synthesis_version_uuid', ls.version_uuid,
                        'synthesis_type', ls.synthesis_type,
                        'synthesis_origin', ls.synthesis_origin,
                        'method', ls.method,
                        'model', ls.model,
                        'software', ls.software,
                        'software_version', ls.software_version
                    )
                    ORDER BY ls.sequence_no NULLS LAST, ls.version_uuid
                )
                FROM linked_synth ls
            ), '[]'::jsonb),

            'certainty_frameworks', COALESCE((
                SELECT jsonb_agg(x.framework ORDER BY x.framework)
                FROM (
                    SELECT DISTINCT lc.framework
                    FROM linked_cert lc
                ) x
            ), '[]'::jsonb)
        ),

        'evidence_base', jsonb_build_object(
            'study_count', (
                SELECT count(DISTINCT cr.study_entity_uuid)
                FROM contributed_results cr
            ),

            'study_type_counts', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'study_type', x.study_type,
                        'count', x.n
                    )
                    ORDER BY x.study_type
                )
                FROM (
                    SELECT
                        sv.study_type,
                        count(DISTINCT st.study_entity_uuid) AS n
                    FROM (
                        SELECT DISTINCT study_entity_uuid
                        FROM contributed_results
                    ) st
                    JOIN core.entity_version cev
                      ON cev.entity_uuid = st.study_entity_uuid
                     AND cev.version_status = 'current'
                    JOIN evidence.study_version sv
                      ON sv.version_uuid = cev.version_uuid
                    GROUP BY sv.study_type
                ) x
            ), '[]'::jsonb),

            'report_count', (
                SELECT count(DISTINCT ur.report_version_uuid)
                FROM used_reports ur
            ),

            'study_designs', COALESCE((
                SELECT jsonb_agg(x.design ORDER BY x.design)
                FROM (
                    SELECT DISTINCT sv.design
                    FROM (
                        SELECT DISTINCT study_entity_uuid
                        FROM contributed_results
                    ) st
                    JOIN core.entity_version cev
                      ON cev.entity_uuid = st.study_entity_uuid
                     AND cev.version_status = 'current'
                    JOIN evidence.study_version sv
                      ON sv.version_uuid = cev.version_uuid
                    WHERE sv.design IS NOT NULL
                ) x
            ), '[]'::jsonb),

            'included_studies', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'study_id', se.oes_id,
                        'study_entity_uuid', st.study_entity_uuid,
                        'study_type', sv.study_type,
                        'design', sv.design,
                        'title_or_label', sv.title_or_label,
                        'sample_size', sv.sample_size
                    )
                    ORDER BY se.oes_id
                )
                FROM (
                    SELECT DISTINCT study_entity_uuid
                    FROM contributed_results
                ) st
                JOIN core.entity se
                  ON se.entity_uuid = st.study_entity_uuid
                JOIN core.entity_version cev
                  ON cev.entity_uuid = st.study_entity_uuid
                 AND cev.version_status = 'current'
                JOIN evidence.study_version sv
                  ON sv.version_uuid = cev.version_uuid
            ), '[]'::jsonb),

            'included_reports', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'report_id', re.oes_id,
                        'report_entity_uuid', rv.entity_uuid,
                        'report_version_uuid', rv.version_uuid,
                        'report_type', rv.report_type,
                        'title', rv.title,
                        'publication_date', rv.publication_date,
                        'publication_status', rv.publication_status
                    )
                    ORDER BY rv.publication_date NULLS LAST, re.oes_id
                )
                FROM (
                    SELECT DISTINCT report_version_uuid
                    FROM used_reports
                ) ur
                JOIN evidence.report_version rv
                  ON rv.version_uuid = ur.report_version_uuid
                JOIN core.entity re
                  ON re.entity_uuid = rv.entity_uuid
            ), '[]'::jsonb)
        ),

        'priority_results', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'role', ls.role,
                    'sequence_no', ls.sequence_no,
                    'synthesis', jsonb_build_object(
                        'synthesis_id', ls.synthesis_id,
                        'synthesis_version_uuid', ls.version_uuid,
                        'synthesis_type', ls.synthesis_type,
                        'synthesis_origin', ls.synthesis_origin,
                        'population', ls.population_descriptor,
                        'comparison', ls.comparison_payload,
                        'timepoint', ls.timepoint_payload,
                        'estimand', ls.estimand,
                        'method', ls.method,
                        'model', ls.model,
                        'result_summary', ls.result_summary
                    ),
                    'outcome', CASE
                        WHEN ls.outcome_entity_uuid IS NULL THEN NULL
                        ELSE (
                            SELECT jsonb_build_object(
                                'outcome_id', oe.oes_id,
                                'outcome_entity_uuid', ov.entity_uuid,
                                'preferred_name', ov.preferred_name,
                                'definition', ov.definition,
                                'direction_of_benefit', ov.direction_of_benefit
                            )
                            FROM core.entity oe
                            JOIN core.entity_version oev
                              ON oev.entity_uuid = oe.entity_uuid
                             AND oev.version_status = 'current'
                            JOIN evidence.outcome_version ov
                              ON ov.version_uuid = oev.version_uuid
                            WHERE oe.entity_uuid = ls.outcome_entity_uuid
                            LIMIT 1
                        )
                    END,
                    'contributing_studies', (
                        SELECT count(DISTINCT cr.study_entity_uuid)
                        FROM contributed_results cr
                        WHERE cr.synthesis_version_uuid = ls.version_uuid
                    ),
                    'contributing_results', (
                        SELECT count(*)
                        FROM contributed_results cr
                        WHERE cr.synthesis_version_uuid = ls.version_uuid
                    ),
                    'certainty', COALESCE((
                        SELECT jsonb_build_object(
                            'formal_assessment', true,
                            'certainty_id', lc.certainty_id,
                            'certainty_version_uuid', lc.version_uuid,
                            'framework', lc.framework,
                            'framework_version', lc.framework_version,
                            'final_level', lc.final_level,
                            'evidence_state', lc.evidence_state,
                            'assessment_date', lc.assessment_date,
                            'domains', COALESCE((
                                SELECT jsonb_agg(
                                    jsonb_build_object(
                                        'domain_code', cd.domain_code,
                                        'concern_level', cd.concern_level,
                                        'downgrade_steps', cd.downgrade_steps,
                                        'upgrade_steps', cd.upgrade_steps,
                                        'rationale', cd.rationale
                                    )
                                    ORDER BY cd.sequence_no NULLS LAST, cd.domain_code
                                )
                                FROM appraisal.certainty_domain cd
                                WHERE cd.certainty_assessment_version_uuid = lc.version_uuid
                            ), '[]'::jsonb)
                        )
                        FROM linked_cert lc
                        WHERE lc.synthesis_version_uuid = ls.version_uuid
                        ORDER BY lc.sequence_no NULLS LAST, lc.version_uuid
                        LIMIT 1
                    ), jsonb_build_object(
                        'formal_assessment', false,
                        'display', 'não avaliada formalmente'
                    ))
                )
                ORDER BY ls.sequence_no NULLS LAST, ls.version_uuid
            )
            FROM linked_synth ls
        ), '[]'::jsonb),

        'risk_of_bias', jsonb_build_object(
            'assessment_count', (
                SELECT count(*)
                FROM appraisal.risk_assessment_version rav
                JOIN primary_inv pi
                  ON pi.investigation_version_uuid = rav.investigation_version_uuid
            ),
            'frameworks', COALESCE((
                SELECT jsonb_agg(x.framework ORDER BY x.framework)
                FROM (
                    SELECT DISTINCT rav.framework
                    FROM appraisal.risk_assessment_version rav
                    JOIN primary_inv pi
                      ON pi.investigation_version_uuid = rav.investigation_version_uuid
                ) x
            ), '[]'::jsonb),
            'overall_judgements', COALESCE((
                SELECT jsonb_agg(x.overall_judgement ORDER BY x.overall_judgement)
                FROM (
                    SELECT DISTINCT rav.overall_judgement
                    FROM appraisal.risk_assessment_version rav
                    JOIN primary_inv pi
                      ON pi.investigation_version_uuid = rav.investigation_version_uuid
                    WHERE rav.overall_judgement IS NOT NULL
                ) x
            ), '[]'::jsonb),
            'assessments', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'risk_assessment_id', re.oes_id,
                        'version_uuid', rav.version_uuid,
                        'framework', rav.framework,
                        'framework_version', rav.framework_version,
                        'target_entity_uuid', rav.target_entity_uuid,
                        'outcome_entity_uuid', rav.outcome_entity_uuid,
                        'overall_judgement', rav.overall_judgement,
                        'assessment_date', rav.assessment_date,
                        'verification_status', rav.verification_status
                    )
                    ORDER BY rav.assessment_date, rav.version_uuid
                )
                FROM appraisal.risk_assessment_version rav
                JOIN core.entity re
                  ON re.entity_uuid = rav.entity_uuid
                JOIN primary_inv pi
                  ON pi.investigation_version_uuid = rav.investigation_version_uuid
            ), '[]'::jsonb)
        ),

        'certainty_assessments', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'certainty_id', lc.certainty_id,
                    'version_uuid', lc.version_uuid,
                    'framework', lc.framework,
                    'framework_version', lc.framework_version,
                    'final_level', lc.final_level,
                    'evidence_state', lc.evidence_state,
                    'synthesis_version_uuid', lc.synthesis_version_uuid,
                    'outcome_entity_uuid', lc.outcome_entity_uuid,
                    'review_finding_version_uuid', to_jsonb(lc)->'review_finding_version_uuid',
                    'assessment_date', lc.assessment_date,
                    'domains', COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'domain_code', cd.domain_code,
                                'concern_level', cd.concern_level,
                                'downgrade_steps', cd.downgrade_steps,
                                'upgrade_steps', cd.upgrade_steps,
                                'rationale', cd.rationale
                            )
                            ORDER BY cd.sequence_no NULLS LAST, cd.domain_code
                        )
                        FROM appraisal.certainty_domain cd
                        WHERE cd.certainty_assessment_version_uuid = lc.version_uuid
                    ), '[]'::jsonb)
                )
                ORDER BY lc.sequence_no NULLS LAST, lc.version_uuid
            )
            FROM linked_cert lc
        ), '[]'::jsonb),

        'safety', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'role', ls.role,
                    'sequence_no', ls.sequence_no,
                    'synthesis_id', ls.synthesis_id,
                    'synthesis_version_uuid', ls.version_uuid,
                    'result_summary', ls.result_summary
                )
                ORDER BY ls.sequence_no NULLS LAST, ls.version_uuid
            )
            FROM linked_synth ls
            WHERE lower(ls.role) IN ('safety','harms','adverse_events')
        ), '[]'::jsonb),

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

        'conclusion', (
            SELECT jsonb_build_object(
                'text', pv.conclusion_text,
                'recommendation_present', false
            )
            FROM product.product_version pv
            WHERE pv.version_uuid = p_product_version_uuid
        ),

        'update_history', jsonb_build_object(
            'change_classes', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'change_class', vc.change_class,
                        'rationale', vc.rationale,
                        'sequence_no', vc.sequence_no
                    )
                    ORDER BY vc.sequence_no NULLS LAST, vc.change_class
                )
                FROM product.version_change_class vc
                WHERE vc.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb),

            'currency_history', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'currency_state_uuid', cs.currency_state_uuid,
                        'currency_status', cs.currency_status,
                        'assessed_at', cs.assessed_at,
                        'assessed_by', cs.assessed_by,
                        'rationale', cs.rationale,
                        'record_status', cs.record_status,
                        'supersedes_currency_state_uuid', cs.supersedes_currency_state_uuid
                    )
                    ORDER BY cs.assessed_at, cs.currency_state_uuid
                )
                FROM product.currency_state cs
                WHERE cs.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb),

            'predecessor_version_uuid', (
                SELECT ev.supersedes_version_uuid
                FROM core.entity_version ev
                WHERE ev.version_uuid = p_product_version_uuid
            ),

            'current_version_no', (
                SELECT ev.version_no
                FROM core.entity_version ev
                WHERE ev.version_uuid = p_product_version_uuid
            )
        ),

        'references', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'report_id', x.report_id,
                    'report_entity_uuid', x.report_entity_uuid,
                    'report_version_uuid', x.report_version_uuid,
                    'title', x.title,
                    'publication_date', x.publication_date,
                    'publication_status', x.publication_status,
                    'source_locations', x.source_locations
                )
                ORDER BY x.publication_date NULLS LAST, x.report_id
            )
            FROM product.evidence_sheet_reference_reports(
                p_product_version_uuid
            ) x
        ), '[]'::jsonb),

        'audit', jsonb_build_object(
            'publishable', product.evidence_sheet_is_publishable(
                p_product_version_uuid
            ),

            'publication_issues', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'issue_code', i.issue_code,
                        'severity', i.severity,
                        'message', i.message
                    )
                    ORDER BY i.severity, i.issue_code
                )
                FROM product.evidence_sheet_publication_issues(
                    p_product_version_uuid
                ) i
            ), '[]'::jsonb),

            'reviews', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'review_uuid', rr.review_uuid,
                        'reviewer', rr.reviewer,
                        'role', rr.role,
                        'independent', rr.independent_flag,
                        'decision', rr.decision,
                        'reviewed_at', rr.reviewed_at,
                        'notes', rr.notes,
                        'status', rr.status
                    )
                    ORDER BY rr.reviewed_at, rr.review_uuid
                )
                FROM product.review_record rr
                WHERE rr.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb),

            'linked_investigations', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'investigation_id', ie.oes_id,
                        'investigation_version_uuid', il.investigation_version_uuid,
                        'role', il.role,
                        'sequence_no', il.sequence_no
                    )
                    ORDER BY il.sequence_no NULLS LAST, il.role, il.investigation_version_uuid
                )
                FROM product.investigation_link il
                JOIN investigation.investigation_version iv
                  ON iv.version_uuid = il.investigation_version_uuid
                JOIN core.entity ie
                  ON ie.entity_uuid = iv.entity_uuid
                WHERE il.product_version_uuid = p_product_version_uuid
            ), '[]'::jsonb),

            'linked_syntheses', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'synthesis_id', ls.synthesis_id,
                        'synthesis_version_uuid', ls.version_uuid,
                        'role', ls.role,
                        'sequence_no', ls.sequence_no
                    )
                    ORDER BY ls.sequence_no NULLS LAST, ls.version_uuid
                )
                FROM linked_synth ls
            ), '[]'::jsonb),

            'linked_certainty_assessments', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'certainty_id', lc.certainty_id,
                        'certainty_version_uuid', lc.version_uuid,
                        'role', lc.role,
                        'sequence_no', lc.sequence_no
                    )
                    ORDER BY lc.sequence_no NULLS LAST, lc.version_uuid
                )
                FROM linked_cert lc
            ), '[]'::jsonb),

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
