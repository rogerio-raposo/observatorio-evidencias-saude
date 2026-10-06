-- OES-DBM-2026-0020
-- Fase 3 — OverviewOfReviewsView rendering readiness
-- Depends on: baseline + migrations 002–019
-- Date: 2026-10-06
-- Additive/idempotent projection migration.
-- Does not modify Overview scientific persistence or publication semantics.

BEGIN;

CREATE OR REPLACE FUNCTION product.overview_report_lineage(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    review_item_uuid uuid,
    review_study_id text,
    source_report_id text,
    source_report_entity_uuid uuid,
    source_report_version_uuid uuid,
    target_report_id text,
    target_report_entity_uuid uuid,
    target_report_version_uuid uuid,
    relation_type text,
    relation_date date,
    notes text,
    status text
)
LANGUAGE sql
STABLE
AS $report_lineage$
WITH inv AS (
    SELECT il.investigation_version_uuid
      FROM product.investigation_link il
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='primary'
     LIMIT 1
),
reviews AS (
    SELECT
        ri.review_item_uuid,
        sv.entity_uuid AS review_study_entity_uuid,
        se.oes_id AS review_study_id
      FROM inv
      JOIN overview.review_item ri
        ON ri.investigation_version_uuid=inv.investigation_version_uuid
       AND ri.status='active'
      JOIN evidence.study_version sv
        ON sv.version_uuid=ri.review_study_version_uuid
      JOIN core.entity se
        ON se.entity_uuid=sv.entity_uuid
),
relations AS (
    SELECT DISTINCT
        r.review_item_uuid,
        r.review_study_id,
        rr.source_report_entity_uuid,
        rr.target_report_entity_uuid,
        rr.relation_type,
        rr.relation_date,
        rr.notes,
        rr.status
      FROM reviews r
      JOIN evidence.study_report_link srl
        ON srl.study_entity_uuid=r.review_study_entity_uuid
       AND srl.status='active'
      JOIN evidence.report_relation rr
        ON (
             rr.source_report_entity_uuid=srl.report_entity_uuid
             OR rr.target_report_entity_uuid=srl.report_entity_uuid
        )
)
SELECT
    rel.review_item_uuid,
    rel.review_study_id,
    se.oes_id AS source_report_id,
    rel.source_report_entity_uuid,
    srv.version_uuid AS source_report_version_uuid,
    te.oes_id AS target_report_id,
    rel.target_report_entity_uuid,
    trv.version_uuid AS target_report_version_uuid,
    rel.relation_type,
    rel.relation_date,
    rel.notes,
    rel.status
  FROM relations rel
  JOIN core.entity se
    ON se.entity_uuid=rel.source_report_entity_uuid
  JOIN core.entity te
    ON te.entity_uuid=rel.target_report_entity_uuid
  LEFT JOIN LATERAL (
      SELECT rv.version_uuid
        FROM evidence.report_version rv
        JOIN core.entity_version ev
          ON ev.version_uuid=rv.version_uuid
       WHERE rv.entity_uuid=rel.source_report_entity_uuid
         AND ev.version_status='current'
       ORDER BY ev.version_no DESC
       LIMIT 1
  ) srv ON true
  LEFT JOIN LATERAL (
      SELECT rv.version_uuid
        FROM evidence.report_version rv
        JOIN core.entity_version ev
          ON ev.version_uuid=rv.version_uuid
       WHERE rv.entity_uuid=rel.target_report_entity_uuid
         AND ev.version_status='current'
       ORDER BY ev.version_no DESC
       LIMIT 1
  ) trv ON true
 ORDER BY rel.review_item_uuid,rel.relation_date,se.oes_id;
$report_lineage$;

CREATE OR REPLACE FUNCTION product.overview_dependency_lineage(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    source_version_uuid uuid,
    source_entity_id text,
    source_entity_type text,
    target_version_uuid uuid,
    target_entity_id text,
    target_entity_type text,
    dependency_type text,
    derivation_rule text,
    dependency_status text,
    source_invalidated boolean,
    invalidation_records jsonb
)
LANGUAGE sql
STABLE
AS $dependency_lineage$
WITH RECURSIVE walk(version_uuid,path) AS (
    SELECT
        p_product_version_uuid,
        ARRAY[p_product_version_uuid]::uuid[]
    UNION ALL
    SELECT
        de.source_version_uuid,
        w.path||de.source_version_uuid
      FROM walk w
      JOIN provenance.dependency_edge de
        ON de.target_version_uuid=w.version_uuid
       AND de.status='active'
     WHERE cardinality(w.path)<64
       AND NOT de.source_version_uuid=ANY(w.path)
),
edges AS (
    SELECT DISTINCT
        de.source_version_uuid,
        de.target_version_uuid,
        de.dependency_type,
        de.derivation_rule,
        de.status
      FROM walk w
      JOIN provenance.dependency_edge de
        ON de.target_version_uuid=w.version_uuid
)
SELECT
    e.source_version_uuid,
    se.oes_id AS source_entity_id,
    se.entity_type AS source_entity_type,
    e.target_version_uuid,
    te.oes_id AS target_entity_id,
    te.entity_type AS target_entity_type,
    e.dependency_type,
    e.derivation_rule,
    e.status AS dependency_status,
    EXISTS (
        SELECT 1
          FROM provenance.record pr
         WHERE pr.target_version_uuid=e.source_version_uuid
           AND pr.status='invalidated'
    ) AS source_invalidated,
    COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'provenance_uuid',pr.provenance_uuid,
                'field_path',pr.field_path,
                'invalidation_reason',pr.invalidation_reason,
                'invalidated_at',pr.invalidated_at
            )
            ORDER BY pr.invalidated_at,pr.provenance_uuid
        )
          FROM provenance.record pr
         WHERE pr.target_version_uuid=e.source_version_uuid
           AND pr.status='invalidated'
    ),'[]'::jsonb) AS invalidation_records
  FROM edges e
  JOIN core.entity_version sev
    ON sev.version_uuid=e.source_version_uuid
  JOIN core.entity se
    ON se.entity_uuid=sev.entity_uuid
  JOIN core.entity_version tev
    ON tev.version_uuid=e.target_version_uuid
  JOIN core.entity te
    ON te.entity_uuid=tev.entity_uuid
 ORDER BY e.target_version_uuid,e.source_version_uuid,e.dependency_type;
$dependency_lineage$;

CREATE OR REPLACE FUNCTION product.overview_of_reviews_view(
    p_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $view$
WITH
pv AS (
    SELECT
        pv.*,
        pe.oes_id AS product_id,
        ev.version_no,
        ev.version_status,
        cs.currency_status,
        cs.assessed_at AS currency_assessed_at,
        cs.assessed_by AS currency_assessed_by,
        cs.rationale AS currency_rationale
      FROM product.product_version pv
      JOIN core.entity pe
        ON pe.entity_uuid=pv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=pv.version_uuid
      LEFT JOIN LATERAL (
          SELECT *
            FROM product.currency_state cs
           WHERE cs.product_version_uuid=pv.version_uuid
             AND cs.record_status='active'
           ORDER BY cs.assessed_at DESC
           LIMIT 1
      ) cs ON true
     WHERE pv.version_uuid=p_product_version_uuid
),
inv AS (
    SELECT
        iv.*,
        ie.oes_id AS investigation_id,
        ev.version_status
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity ie
        ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=iv.version_uuid
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='primary'
     LIMIT 1
),
q AS (
    SELECT
        qv.*,
        qe.oes_id AS question_id
      FROM inv
      JOIN investigation.investigation_question iq
        ON iq.investigation_version_uuid=inv.version_uuid
       AND iq.role='primary'
      JOIN investigation.question_version qv
        ON qv.version_uuid=iq.question_version_uuid
      JOIN core.entity qe
        ON qe.entity_uuid=qv.entity_uuid
     LIMIT 1
),
issues AS (
    SELECT *
      FROM product.overview_of_reviews_publication_issues(
          p_product_version_uuid
      )
)
SELECT jsonb_build_object(
    'schema_version','oes.overview_of_reviews_view/0.1',

    'identity',COALESCE((
        SELECT jsonb_build_object(
            'product_id',product_id,
            'product_entity_uuid',entity_uuid,
            'product_version_uuid',version_uuid,
            'version_no',version_no,
            'version_status',version_status,
            'product_type',product_type,
            'title',title,
            'intended_audience',intended_audience,
            'editorial_status',status,
            'publication_date',publication_date,
            'evidence_cutoff_date',evidence_cutoff_date,
            'currency_status',currency_status
        ) FROM pv
    ),'{}'::jsonb),

    'question',COALESCE((
        SELECT jsonb_build_object(
            'question_id',question_id,
            'question_entity_uuid',entity_uuid,
            'question_version_uuid',version_uuid,
            'original_text',original_text,
            'normalized_text',normalized_text,
            'question_type',question_type,
            'structure_type',structure_type,
            'context',context_payload,
            'time_horizon',time_horizon_payload
        ) FROM q
    ),'{}'::jsonb),

    'investigation',COALESCE((
        SELECT jsonb_build_object(
            'investigation_id',investigation_id,
            'investigation_entity_uuid',entity_uuid,
            'investigation_version_uuid',version_uuid,
            'investigation_type',investigation_type,
            'depth_level',depth_level,
            'maintenance_level',maintenance_level,
            'objective',objective,
            'protocol_artifact_uuid',protocol_artifact_uuid,
            'start_date',start_date,
            'evidence_cutoff_date',evidence_cutoff_date,
            'status',status,
            'version_status',version_status
        ) FROM inv
    ),'{}'::jsonb),

    'protocol',COALESCE((
        SELECT jsonb_build_object(
            'artifact_uuid',a.artifact_uuid,
            'artifact_type',a.artifact_type,
            'storage_key',a.storage_key,
            'content_hash',a.content_hash,
            'hash_algorithm',a.hash_algorithm,
            'created_at',a.created_at,
            'status',a.status
        )
          FROM inv
          JOIN artifact.artifact a
            ON a.artifact_uuid=inv.protocol_artifact_uuid
    ),'{}'::jsonb),

    'method',jsonb_build_object(
        'policies',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'decision_code',md.decision_code,
                    'decision_type',md.decision_type,
                    'stage',md.stage,
                    'planned',md.planned_flag,
                    'rationale',md.rationale,
                    'risk',md.risk_payload,
                    'mitigation',md.mitigation_payload,
                    'impact',md.impact_payload,
                    'resolution_status',md.resolution_status,
                    'decided_by',md.decided_by,
                    'decided_at',md.decided_at,
                    'linked_artifact_uuid',md.linked_artifact_uuid,
                    'linked_artifact',CASE
                        WHEN md.linked_artifact_uuid IS NULL THEN NULL
                        ELSE (
                            SELECT jsonb_build_object(
                                'artifact_type',a.artifact_type,
                                'storage_key',a.storage_key,
                                'content_hash',a.content_hash,
                                'hash_algorithm',a.hash_algorithm,
                                'status',a.status
                            )
                              FROM artifact.artifact a
                             WHERE a.artifact_uuid=md.linked_artifact_uuid
                        )
                    END
                )
                ORDER BY md.decided_at,md.decision_code
            )
              FROM inv
              JOIN investigation.method_decision md
                ON md.investigation_version_uuid=inv.version_uuid
               AND md.record_status='active'
               AND (
                    md.decision_code LIKE 'overview_%'
                    OR md.decision_type IN ('protocol_deviation','method_change')
               )
        ),'[]'::jsonb),
        'reviewer_assignments',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'stage',ra.stage,
                    'actor',ra.actor,
                    'actor_type',ra.actor_type,
                    'role',ra.role,
                    'qualification',ra.qualification_payload,
                    'independent',ra.independent_flag,
                    'scope',ra.scope_payload,
                    'conflict',ra.conflict_payload,
                    'assigned_at',ra.assigned_at,
                    'ended_at',ra.ended_at
                )
                ORDER BY ra.stage,ra.role,ra.actor
            )
              FROM inv
              JOIN investigation.reviewer_assignment ra
                ON ra.investigation_version_uuid=inv.version_uuid
               AND ra.record_status='active'
        ),'[]'::jsonb),
        'quality_controls',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'stage',qc.stage,
                    'control_type',qc.control_type,
                    'control_code',qc.scope_payload->>'control_code',
                    'actor',qc.actor,
                    'actor_type',qc.actor_type,
                    'qualification',qc.qualification_payload,
                    'independent',qc.independent_flag,
                    'decision',qc.decision,
                    'scope',qc.scope_payload,
                    'agreement',qc.agreement_payload,
                    'discrepancy',qc.discrepancy_payload,
                    'resolution',qc.resolution_payload,
                    'evidence_artifact_uuid',qc.evidence_artifact_uuid,
                    'evidence_artifact',CASE
                        WHEN qc.evidence_artifact_uuid IS NULL THEN NULL
                        ELSE (
                            SELECT jsonb_build_object(
                                'artifact_type',a.artifact_type,
                                'storage_key',a.storage_key,
                                'content_hash',a.content_hash,
                                'hash_algorithm',a.hash_algorithm,
                                'status',a.status
                            )
                              FROM artifact.artifact a
                             WHERE a.artifact_uuid=qc.evidence_artifact_uuid
                        )
                    END,
                    'notes',qc.notes,
                    'performed_at',qc.performed_at
                )
                ORDER BY qc.stage,qc.control_type,qc.performed_at
            )
              FROM inv
              JOIN investigation.quality_control_record qc
                ON qc.investigation_version_uuid=inv.version_uuid
               AND qc.record_status='active'
        ),'[]'::jsonb)
    ),

    'searches',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'search_uuid',s.search_uuid,
                'oes_search_id',s.oes_search_id,
                'source_name',s.source_name,
                'platform',s.platform,
                'source_class',s.filters_payload->>'source_class',
                'executed_at',s.executed_at,
                'result_count',s.result_count,
                'strategy_version',s.strategy_version,
                'export_artifact_uuid',s.export_artifact_uuid,
                'export_artifact',CASE
                    WHEN s.export_artifact_uuid IS NULL THEN NULL
                    ELSE (
                        SELECT jsonb_build_object(
                            'artifact_type',a.artifact_type,
                            'storage_key',a.storage_key,
                            'content_hash',a.content_hash,
                            'hash_algorithm',a.hash_algorithm,
                            'status',a.status
                        )
                          FROM artifact.artifact a
                         WHERE a.artifact_uuid=s.export_artifact_uuid
                    )
                END,
                'status',s.status
            )
            ORDER BY s.executed_at,s.oes_search_id
        )
          FROM inv
          JOIN investigation.search s
            ON s.investigation_version_uuid=inv.version_uuid
    ),'[]'::jsonb),

    'selection_flow',jsonb_build_object(
        'search_hits',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.search s
                ON s.investigation_version_uuid=inv.version_uuid
              JOIN investigation.search_hit sh
                ON sh.search_uuid=s.search_uuid
        ),0),
        'unique_report_targets',COALESCE((
            SELECT count(DISTINCT sh.report_entity_uuid)
              FROM inv
              JOIN investigation.search s
                ON s.investigation_version_uuid=inv.version_uuid
              JOIN investigation.search_hit sh
                ON sh.search_uuid=s.search_uuid
             WHERE sh.report_entity_uuid IS NOT NULL
        ),0),
        'screening_decisions',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
        ),0),
        'title_abstract_decisions',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
             WHERE sd.stage='title_abstract'
        ),0),
        'full_text_decisions',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
             WHERE sd.stage='full_text'
        ),0),
        'full_text_exclusions',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
             WHERE sd.stage='full_text'
               AND sd.decision='exclude'
        ),0),
        'adjudications',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
             WHERE sd.adjudication_flag=true
        ),0),
        'included_review_items',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN overview.review_item ri
                ON ri.investigation_version_uuid=inv.version_uuid
             WHERE ri.status='active'
        ),0)
    ),

    'excluded_full_text',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'screening_uuid',sd.screening_uuid,
                'target_entity_uuid',sd.target_entity_uuid,
                'target_id',te.oes_id,
                'decision',sd.decision,
                'exclusion_reason',sd.exclusion_reason,
                'reviewer',sd.reviewer,
                'decided_at',sd.decided_at,
                'adjudication_flag',sd.adjudication_flag
            )
            ORDER BY sd.decided_at,sd.screening_uuid
        )
          FROM inv
          JOIN investigation.screening_decision sd
            ON sd.investigation_version_uuid=inv.version_uuid
          LEFT JOIN core.entity te
            ON te.entity_uuid=sd.target_entity_uuid
         WHERE sd.stage='full_text'
           AND sd.decision='exclude'
    ),'[]'::jsonb),

    'review_items',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'review_item_uuid',ri.review_item_uuid,
                'review_study_id',se.oes_id,
                'review_study_entity_uuid',sv.entity_uuid,
                'review_study_version_uuid',ri.review_study_version_uuid,
                'study_type',sv.study_type,
                'title',sv.title_or_label,
                'item_role',ri.item_role,
                'eligibility_basis',ri.eligibility_basis_payload,
                'last_search_date',ri.last_search_date,
                'membership_completeness',ri.membership_completeness,
                'currentness_status',ri.currentness_status,
                'currentness_rationale',ri.currentness_rationale,
                'robis',COALESCE((
                    SELECT jsonb_build_object(
                        'risk_assessment_version_uuid',rav.version_uuid,
                        'overall_judgement',rav.overall_judgement,
                        'assessor',rav.assessor,
                        'assessment_date',rav.assessment_date,
                        'verification_status',rav.verification_status
                    )
                      FROM appraisal.risk_assessment_version rav
                     WHERE rav.investigation_version_uuid=ri.investigation_version_uuid
                       AND rav.target_entity_uuid=sv.entity_uuid
                       AND lower(rav.framework)='robis'
                       AND rav.status='active'
                     ORDER BY rav.assessment_date DESC
                     LIMIT 1
                ),'{}'::jsonb),
                'reports',COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'report_id',re.oes_id,
                            'report_entity_uuid',re.entity_uuid,
                            'report_version_uuid',rv.version_uuid,
                            'relation_type',srl.relation_type,
                            'title',rv.title,
                            'publication_date',rv.publication_date
                        )
                        ORDER BY rv.publication_date,re.oes_id
                    )
                      FROM evidence.study_report_link srl
                      JOIN core.entity re
                        ON re.entity_uuid=srl.report_entity_uuid
                      JOIN evidence.report_version rv
                        ON rv.entity_uuid=re.entity_uuid
                      JOIN core.entity_version rev
                        ON rev.version_uuid=rv.version_uuid
                       AND rev.version_status='current'
                     WHERE srl.study_entity_uuid=sv.entity_uuid
                       AND srl.status='active'
                ),'[]'::jsonb)
            )
            ORDER BY ri.included_at,ri.review_item_uuid
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
           AND ri.status='active'
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
          JOIN core.entity se
            ON se.entity_uuid=sv.entity_uuid
    ),'[]'::jsonb),

    'report_lineage',COALESCE((
        SELECT jsonb_agg(
            to_jsonb(rl)
            ORDER BY rl.review_item_uuid,rl.relation_date,rl.source_report_id
        )
          FROM product.overview_report_lineage(
              p_product_version_uuid
          ) rl
    ),'[]'::jsonb),

    'primary_study_membership',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'membership_uuid',psm.membership_uuid,
                'review_item_uuid',psm.review_item_uuid,
                'primary_study_id',pse.oes_id,
                'primary_study_entity_uuid',psm.primary_study_entity_uuid,
                'source_report_version_uuid',psm.source_report_version_uuid,
                'source_location',psm.source_location,
                'identity_confidence',psm.identity_confidence,
                'verification_status',psm.verification_status,
                'context',psm.context_payload
            )
            ORDER BY psm.review_item_uuid,pse.oes_id
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
          JOIN overview.primary_study_membership psm
            ON psm.review_item_uuid=ri.review_item_uuid
           AND psm.status='active'
          JOIN core.entity pse
            ON pse.entity_uuid=psm.primary_study_entity_uuid
         WHERE ri.status='active'
    ),'[]'::jsonb),

    'overlap',jsonb_build_object(
        'clusters',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'cluster_uuid',rc.cluster_uuid,
                    'cluster_code',rc.cluster_code,
                    'label',rc.label,
                    'scope',rc.scope_payload,
                    'metrics',to_jsonb(om),
                    'resolution',COALESCE((
                        SELECT jsonb_build_object(
                            'strategy',ores.strategy,
                            'decision',ores.decision_payload,
                            'rationale',ores.rationale,
                            'decided_by',ores.decided_by,
                            'actor_type',ores.actor_type,
                            'verification_status',ores.verification_status,
                            'decided_at',ores.decided_at
                        )
                          FROM overview.overlap_resolution ores
                         WHERE ores.cluster_uuid=rc.cluster_uuid
                           AND ores.status='active'
                         LIMIT 1
                    ),'{}'::jsonb),
                    'members',COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'review_item_uuid',cm.review_item_uuid,
                                'analysis_disposition',cm.analysis_disposition,
                                'rationale',cm.rationale,
                                'sequence_no',cm.sequence_no
                            )
                            ORDER BY cm.sequence_no,cm.review_item_uuid
                        )
                          FROM overview.cluster_membership cm
                         WHERE cm.cluster_uuid=rc.cluster_uuid
                           AND cm.status='active'
                    ),'[]'::jsonb),
                    'pairwise',COALESCE((
                        SELECT jsonb_agg(to_jsonb(po) ORDER BY po.review_item_a,po.review_item_b)
                          FROM overview.pairwise_overlap(rc.cluster_uuid) po
                    ),'[]'::jsonb)
                )
                ORDER BY rc.cluster_code
            )
              FROM inv
              JOIN overview.review_cluster rc
                ON rc.investigation_version_uuid=inv.version_uuid
               AND rc.status='active'
              LEFT JOIN LATERAL overview.overlap_metrics(
                    inv.version_uuid,rc.cluster_uuid
              ) om ON true
        ),'[]'::jsonb)
    ),

    'outcome_evidence',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'outcome_evidence_uuid',oe.outcome_evidence_uuid,
                'review_item_uuid',oe.review_item_uuid,
                'result_version_uuid',oe.result_version_uuid,
                'synthesis_version_uuid',oe.synthesis_version_uuid,
                'certainty_assessment_version_uuid',
                    oe.certainty_assessment_version_uuid,
                'outcome_id',oeo.oes_id,
                'outcome_entity_uuid',oe.outcome_entity_uuid,
                'comparison',oe.comparison_payload,
                'timepoint',oe.timepoint_payload,
                'analysis_role',oe.analysis_role,
                'primary_study_set_status',oe.primary_study_set_status,
                'extraction',oe.extraction_payload,
                'verification_status',oe.verification_status,
                'source_reports',COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'report_id',re.oes_id,
                            'report_entity_uuid',srv.entity_uuid,
                            'report_version_uuid',srv.version_uuid,
                            'source_location',rs.source_location,
                            'source_type',rs.source_type,
                            'extraction_method',rs.extraction_method,
                            'is_primary_source',rs.is_primary_source,
                            'extractor',rs.extractor,
                            'extracted_at',rs.extracted_at
                        )
                        ORDER BY rs.is_primary_source DESC,rs.source_location
                    )
                      FROM evidence.result_source rs
                      JOIN evidence.report_version srv
                        ON srv.version_uuid=rs.report_version_uuid
                      JOIN core.entity re
                        ON re.entity_uuid=srv.entity_uuid
                     WHERE rs.result_version_uuid=oe.result_version_uuid
                ),'[]'::jsonb),
                'provenance',COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'provenance_uuid',pr.provenance_uuid,
                            'target_version_uuid',pr.target_version_uuid,
                            'field_path',pr.field_path,
                            'source_report_version_uuid',pr.source_report_version_uuid,
                            'source_location',pr.source_location,
                            'process_type',pr.process_type,
                            'transformation',pr.transformation,
                            'actor',pr.actor,
                            'status',pr.status,
                            'invalidated_at',pr.invalidated_at,
                            'invalidation_reason',pr.invalidation_reason
                        )
                        ORDER BY pr.created_at,pr.provenance_uuid
                    )
                      FROM provenance.record pr
                     WHERE (
                            pr.target_version_uuid=oe.result_version_uuid
                            OR pr.target_version_uuid=oe.synthesis_version_uuid
                            OR pr.target_version_uuid=oe.certainty_assessment_version_uuid
                     )
                ),'[]'::jsonb),
                'result',CASE
                    WHEN rv.version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'measure',rv.measure,
                        'reported_value',rv.reported_value,
                        'derived_value',rv.derived_value,
                        'ci_lower',rv.ci_lower,
                        'ci_upper',rv.ci_upper,
                        'unit',rv.unit,
                        'estimand',rv.estimand,
                        'method',rv.method_payload
                    )
                END,
                'synthesis',CASE
                    WHEN sy.version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'synthesis_type',sy.synthesis_type,
                        'synthesis_origin',sy.synthesis_origin,
                        'method',sy.method,
                        'model',sy.model,
                        'result_summary',sy.result_summary
                    )
                END,
                'certainty',CASE
                    WHEN cav.version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'framework',cav.framework,
                        'initial_level',cav.initial_level,
                        'final_level',cav.final_level,
                        'evidence_state',cav.evidence_state,
                        'assessment_date',cav.assessment_date
                    )
                END
            )
            ORDER BY oe.review_item_uuid,oe.outcome_evidence_uuid
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
          JOIN overview.outcome_evidence oe
            ON oe.review_item_uuid=ri.review_item_uuid
           AND oe.status='active'
          LEFT JOIN evidence.result_version rv
            ON rv.version_uuid=oe.result_version_uuid
          LEFT JOIN synthesis.synthesis_version sy
            ON sy.version_uuid=oe.synthesis_version_uuid
          LEFT JOIN appraisal.certainty_assessment_version cav
            ON cav.version_uuid=oe.certainty_assessment_version_uuid
          LEFT JOIN core.entity oeo
            ON oeo.entity_uuid=oe.outcome_entity_uuid
         WHERE ri.status='active'
    ),'[]'::jsonb),

    'appraisal',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'review_item_uuid',ri.review_item_uuid,
                'risk_assessment_version_uuid',rav.version_uuid,
                'framework',rav.framework,
                'overall_judgement',rav.overall_judgement,
                'assessor',rav.assessor,
                'assessment_date',rav.assessment_date,
                'verification_status',rav.verification_status,
                'domains',COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'domain_code',rad.domain_code,
                            'judgement',rad.judgement,
                            'rationale',rad.rationale,
                            'sequence_no',rad.sequence_no
                        )
                        ORDER BY rad.sequence_no,rad.domain_code
                    )
                      FROM appraisal.risk_assessment_domain rad
                     WHERE rad.risk_assessment_version_uuid=rav.version_uuid
                ),'[]'::jsonb)
            )
            ORDER BY ri.review_item_uuid
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
           AND ri.status='active'
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
          JOIN appraisal.risk_assessment_version rav
            ON rav.investigation_version_uuid=inv.version_uuid
           AND rav.target_entity_uuid=sv.entity_uuid
           AND lower(rav.framework)='robis'
           AND rav.status='active'
    ),'[]'::jsonb),

    'concordance',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'concordance_uuid',ca.concordance_uuid,
                'cluster_uuid',ca.cluster_uuid,
                'outcome_id',oe.oes_id,
                'outcome_entity_uuid',ca.outcome_entity_uuid,
                'comparison',ca.comparison_payload,
                'timepoint',ca.timepoint_payload,
                'state',ca.concordance_state,
                'dimensions',ca.dimensions_payload,
                'rationale',ca.rationale,
                'assessed_by',ca.assessed_by,
                'actor_type',ca.actor_type,
                'verification_status',ca.verification_status,
                'assessed_at',ca.assessed_at
            )
            ORDER BY ca.cluster_uuid,ca.assessed_at
        )
          FROM inv
          JOIN overview.review_cluster rc
            ON rc.investigation_version_uuid=inv.version_uuid
           AND rc.status='active'
          JOIN overview.concordance_assessment ca
            ON ca.cluster_uuid=rc.cluster_uuid
           AND ca.status='active'
          LEFT JOIN core.entity oe
            ON oe.entity_uuid=ca.outcome_entity_uuid
    ),'[]'::jsonb),

    'conclusion',COALESCE((
        SELECT jsonb_build_object(
            'text',conclusion_text,
            'applicability_summary',applicability_summary
        ) FROM pv
    ),'{}'::jsonb),

    'limitations',COALESCE((
        SELECT jsonb_build_object(
            'summary',limitations_summary
        ) FROM pv
    ),'{}'::jsonb),

    'references',COALESCE((
        SELECT jsonb_agg(to_jsonb(r) ORDER BY r.publication_date NULLS LAST,r.report_id)
          FROM product.overview_reference_reports(
              p_product_version_uuid
          ) r
    ),'[]'::jsonb),

    'update_state',COALESCE((
        SELECT jsonb_build_object(
            'currency_status',currency_status,
            'assessed_at',currency_assessed_at,
            'assessed_by',currency_assessed_by,
            'rationale',currency_rationale
        ) FROM pv
    ),'{}'::jsonb),

    'lineage',COALESCE((
        SELECT jsonb_agg(
            to_jsonb(dl)
            ORDER BY dl.target_version_uuid,dl.source_version_uuid,dl.dependency_type
        )
          FROM product.overview_dependency_lineage(
              p_product_version_uuid
          ) dl
    ),'[]'::jsonb),

    'invalidated_dependencies_detail',COALESCE((
        SELECT jsonb_agg(
            to_jsonb(dl)
            ORDER BY dl.target_version_uuid,dl.source_version_uuid,dl.dependency_type
        )
          FROM product.overview_dependency_lineage(
              p_product_version_uuid
          ) dl
         WHERE dl.source_invalidated=true
    ),'[]'::jsonb),

    'audit',jsonb_build_object(
        'synthetic_fixture',COALESCE((
            SELECT intended_audience='architecture_validation'
              FROM pv
        ),false),
        'assurance_level',
            product.assurance_level(p_product_version_uuid),
        'required_assurance_level','A3',
        'lineage_available',EXISTS (
            SELECT 1
              FROM product.overview_dependency_lineage(
                  p_product_version_uuid
              )
        ),
        'publishable',
            product.overview_of_reviews_is_publishable(
                p_product_version_uuid
            ),
        'review_count',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN overview.review_item ri
                ON ri.investigation_version_uuid=inv.version_uuid
             WHERE ri.status='active'
               AND ri.item_role IN ('primary','supporting')
        ),0),
        'membership_complete',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_PRIMARY_STUDY_MEMBERSHIP',
                'INCOMPLETE_MEMBERSHIP',
                'LOW_CONFIDENCE_STUDY_IDENTITY',
                'UNVERIFIED_MEMBERSHIP'
             )
               AND severity='error'
        ),
        'overlap_assessed',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'UNCLUSTERED_ANALYTIC_REVIEW',
                'MISSING_OVERLAP_RESOLUTION',
                'MISSING_OVERLAP_CONTROL',
                'OUTCOME_DEDUP_STRATEGY_UNSUPPORTED_V01'
             )
               AND severity='error'
        ),
        'appraisal_complete',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_REVIEW_ROBIS',
                'MISSING_APPRAISAL_CONTROL',
                'UNVERIFIED_REVIEW_APPRAISAL'
             )
               AND severity='error'
        ),
        'extraction_complete',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_OUTCOME_EVIDENCE',
                'INCOMPLETE_OUTCOME_EXTRACTION',
                'UNVERIFIED_OUTCOME_EVIDENCE'
             )
               AND severity='error'
        ),
        'human_controls_satisfied',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_SEARCH_PEER_REVIEW',
                'MISSING_SCREENING_CONTROL',
                'MISSING_APPRAISAL_CONTROL',
                'MISSING_OVERLAP_CONTROL',
                'UNVERIFIED_MEMBERSHIP',
                'UNVERIFIED_OUTCOME_EVIDENCE',
                'UNVERIFIED_CONCORDANCE'
             )
               AND severity='error'
        ),
        'reanalysis_present',EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid=sl.synthesis_version_uuid
             WHERE sl.product_version_uuid=p_product_version_uuid
               AND sv.synthesis_origin NOT IN (
                    'adopted_external','updated_external'
               )
        ),
        'statistical_controls_satisfied',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'REANALYSIS_WITHOUT_POLICY',
                'REANALYSIS_WITHOUT_CODE',
                'REANALYSIS_WITHOUT_DATASET',
                'REANALYSIS_WITHOUT_STATISTICAL_REVIEW'
             )
               AND severity='error'
        ),
        'invalidated_dependencies',EXISTS (
            SELECT 1 FROM issues
             WHERE issue_code IN (
                'INVALIDATED_DEPENDENCY',
                'INVALIDATED_REVIEW_VERSION',
                'INVALIDATED_OUTCOME_DEPENDENCY'
             )
               AND severity='error'
        ),
        'publication_issues',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'code',issue_code,
                    'severity',severity,
                    'message',message
                )
                ORDER BY severity,issue_code
            )
              FROM issues
        ),'[]'::jsonb),
        'assurance_records',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'assurance_type',ar.assurance_type,
                    'actor',ar.actor,
                    'actor_type',ar.actor_type,
                    'independent',ar.independent_flag,
                    'decision',ar.decision,
                    'performed_at',ar.performed_at
                )
                ORDER BY ar.performed_at
            )
              FROM product.assurance_record ar
             WHERE ar.product_version_uuid=p_product_version_uuid
               AND ar.status='active'
        ),'[]'::jsonb)
    )
);
$view$;

COMMIT;
