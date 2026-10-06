-- OES-DBM-2026-0017
-- Fase 3 — EvidenceMapView rendering-readiness projection extension
-- Depends on: baseline + migrations 002–016
-- Date: 2026-10-06
-- Additive/idempotent projection migration. Does not alter mapping persistence.

BEGIN;

-- ---------------------------------------------------------------------------
-- EVIDENCE MAP REFERENCE REPORTS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_map_reference_reports(
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
WITH fw AS (
    SELECT de.source_version_uuid AS framework_version_uuid
      FROM provenance.dependency_edge de
      JOIN mapping.framework_version mfv
        ON mfv.version_uuid=de.source_version_uuid
     WHERE de.target_version_uuid=p_product_version_uuid
       AND de.dependency_type='map_framework_informs_product'
       AND de.status='active'
     LIMIT 1
),
map_targets AS (
    SELECT
        mi.target_version_uuid,
        ev.entity_uuid AS target_entity_uuid,
        e.entity_type
      FROM fw
      JOIN mapping.map_item mi
        ON mi.framework_version_uuid=fw.framework_version_uuid
       AND mi.status='active'
      JOIN core.entity_version ev
        ON ev.version_uuid=mi.target_version_uuid
      JOIN core.entity e
        ON e.entity_uuid=ev.entity_uuid
),
source_rows AS (
    -- Explicit Report MapItems preserve their concrete ReportVersion.
    SELECT
        mt.target_version_uuid AS report_version_uuid,
        'map_item:report'::text AS source_location
      FROM map_targets mt
     WHERE mt.entity_type='Report'

    UNION ALL

    -- Study MapItems expose their canonically linked report entities.
    -- v0.1 resolves the current ReportVersion for the linked Report entity.
    SELECT
        rv.version_uuid AS report_version_uuid,
        ('study_report_link:' || srl.relation_type)::text AS source_location
      FROM map_targets mt
      JOIN evidence.study_version sv
        ON sv.version_uuid=mt.target_version_uuid
      JOIN evidence.study_report_link srl
        ON srl.study_entity_uuid=sv.entity_uuid
       AND srl.status='active'
      JOIN core.entity_version rev
        ON rev.entity_uuid=srl.report_entity_uuid
       AND rev.version_status='current'
      JOIN evidence.report_version rv
        ON rv.version_uuid=rev.version_uuid
     WHERE mt.entity_type='Study'

    UNION ALL

    -- Reuse generic provenance traversal for reports supporting upstream
    -- Syntheses/Results/provenance records reachable from the Product.
    SELECT
        pr.report_version_uuid,
        loc.source_location
      FROM product.product_reference_reports(p_product_version_uuid) pr
      CROSS JOIN LATERAL (
          SELECT value::text AS source_location
            FROM jsonb_array_elements_text(
                COALESCE(pr.source_locations,'[]'::jsonb)
            )
      ) loc
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
    e.oes_id AS report_id,
    rv.entity_uuid AS report_entity_uuid,
    rv.version_uuid AS report_version_uuid,
    rv.title,
    rv.publication_date,
    rv.publication_status,
    g.source_locations
  FROM grouped g
  JOIN evidence.report_version rv
    ON rv.version_uuid=g.report_version_uuid
  JOIN core.entity e
    ON e.entity_uuid=rv.entity_uuid
 ORDER BY rv.publication_date NULLS LAST,e.oes_id;
$refs$;

-- ---------------------------------------------------------------------------
-- EVIDENCE MAP VIEW — ADDITIVE PRESENTATION PROJECTION
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_map_view(
    p_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $view$
WITH pv AS (
    SELECT
        pv.*,
        e.oes_id AS product_id,
        ev.version_no,
        ev.version_status,
        ccs.currency_status,
        ccs.assessed_at AS currency_assessed_at,
        ccs.assessed_by AS currency_assessed_by,
        ccs.rationale AS currency_rationale
      FROM product.product_version pv
      JOIN core.entity e
        ON e.entity_uuid=pv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=pv.version_uuid
      LEFT JOIN product.current_currency_state ccs
        ON ccs.product_version_uuid=pv.version_uuid
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
fw AS (
    SELECT
        mfv.*,
        me.oes_id AS framework_id,
        ev.version_no AS framework_version_no,
        ev.version_status AS framework_version_status
      FROM provenance.dependency_edge de
      JOIN mapping.framework_version mfv
        ON mfv.version_uuid=de.source_version_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=mfv.version_uuid
      JOIN core.entity me
        ON me.entity_uuid=mfv.entity_uuid
     WHERE de.target_version_uuid=p_product_version_uuid
       AND de.dependency_type='map_framework_informs_product'
       AND de.status='active'
     LIMIT 1
),
issues AS (
    SELECT *
      FROM product.evidence_map_publication_issues(p_product_version_uuid)
),
refs AS (
    SELECT *
      FROM product.evidence_map_reference_reports(p_product_version_uuid)
)
SELECT jsonb_build_object(
    'schema_version','oes.evidence_map_view/0.1',

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
        )
          FROM pv
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
        )
          FROM q
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
        )
          FROM inv
    ),'{}'::jsonb),

    'protocol',COALESCE((
        SELECT jsonb_build_object(
            'artifact_uuid',a.artifact_uuid,
            'artifact_type',a.artifact_type,
            'storage_key',a.storage_key,
            'content_hash',a.content_hash,
            'hash_algorithm',a.hash_algorithm,
            'mime_type',a.mime_type,
            'status',a.status
        )
          FROM inv
          JOIN artifact.artifact a
            ON a.artifact_uuid=inv.protocol_artifact_uuid
    ),'{}'::jsonb),

    'mapping_method',COALESCE((
        SELECT jsonb_build_object(
            'mapping_subtype',mapping_subtype,
            'coverage_claim',coverage_claim,
            'gap_claim_mode',gap_claim_mode,
            'counting_unit_policy',counting_unit_policy,
            'classification_policy',classification_policy_payload,
            'coverage_policy',coverage_policy_payload,
            'gap_rules',gap_rules_payload
        )
          FROM fw
    ),'{}'::jsonb),

    'framework',COALESCE((
        SELECT jsonb_build_object(
            'framework_id',framework_id,
            'framework_entity_uuid',entity_uuid,
            'framework_version_uuid',version_uuid,
            'framework_version_no',framework_version_no,
            'framework_version_status',framework_version_status,
            'codebook_artifact_uuid',codebook_artifact_uuid,
            'primary_row_dimension_code',primary_row_dimension_code,
            'primary_column_dimension_code',primary_column_dimension_code,
            'visualization',visualization_payload,
            'status',status
        )
          FROM fw
    ),'{}'::jsonb),

    'codebook',COALESCE((
        SELECT jsonb_build_object(
            'artifact_uuid',a.artifact_uuid,
            'artifact_type',a.artifact_type,
            'storage_key',a.storage_key,
            'content_hash',a.content_hash,
            'hash_algorithm',a.hash_algorithm,
            'mime_type',a.mime_type,
            'status',a.status
        )
          FROM fw
          JOIN artifact.artifact a
            ON a.artifact_uuid=fw.codebook_artifact_uuid
    ),'{}'::jsonb),

    'dimensions',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'dimension_uuid',d.dimension_uuid,
                'code',d.dimension_code,
                'label',d.label,
                'description',d.description,
                'role',d.dimension_role,
                'multi_valued',d.multi_valued,
                'required',d.required_flag,
                'sequence_no',d.sequence_no,
                'metadata',d.metadata_payload
            )
            ORDER BY d.sequence_no,d.dimension_code
        )
          FROM mapping.dimension d,fw
         WHERE d.framework_version_uuid=fw.version_uuid
           AND d.status='active'
    ),'[]'::jsonb),

    'categories',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'category_uuid',c.category_uuid,
                'dimension_uuid',c.dimension_uuid,
                'dimension_code',d.dimension_code,
                'parent_category_uuid',c.parent_category_uuid,
                'code',c.category_code,
                'label',c.label,
                'definition',c.definition,
                'sequence_no',c.sequence_no,
                'metadata',c.metadata_payload
            )
            ORDER BY d.sequence_no,c.sequence_no,c.category_code
        )
          FROM mapping.category c
          JOIN mapping.dimension d
            ON d.dimension_uuid=c.dimension_uuid
          JOIN fw
            ON fw.version_uuid=d.framework_version_uuid
         WHERE c.status='active'
    ),'[]'::jsonb),

    'searches',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'search_uuid',s.search_uuid,
                'source_name',s.source_name,
                'platform',s.platform,
                'executed_at',s.executed_at,
                'result_count',s.result_count,
                'source_class',s.filters_payload->>'source_class',
                'strategy_version',s.strategy_version,
                'export_artifact_uuid',s.export_artifact_uuid,
                'export_artifact',CASE
                    WHEN a.artifact_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'storage_key',a.storage_key,
                        'content_hash',a.content_hash,
                        'hash_algorithm',a.hash_algorithm,
                        'status',a.status
                    )
                END,
                'status',s.status
            )
            ORDER BY s.executed_at,s.search_uuid
        )
          FROM investigation.search s
          JOIN inv
            ON s.investigation_version_uuid=inv.version_uuid
          LEFT JOIN artifact.artifact a
            ON a.artifact_uuid=s.export_artifact_uuid
    ),'[]'::jsonb),

    'selection_flow',COALESCE((
        SELECT jsonb_build_object(
            'search_hits',(
                SELECT count(*)
                  FROM investigation.search_hit sh
                  JOIN investigation.search s
                    ON s.search_uuid=sh.search_uuid
                 WHERE s.investigation_version_uuid=inv.version_uuid
            ),
            'unique_report_targets',(
                SELECT count(DISTINCT sh.report_entity_uuid)
                  FROM investigation.search_hit sh
                  JOIN investigation.search s
                    ON s.search_uuid=sh.search_uuid
                 WHERE s.investigation_version_uuid=inv.version_uuid
                   AND sh.report_entity_uuid IS NOT NULL
            ),
            'screening_decisions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                 WHERE sd.investigation_version_uuid=inv.version_uuid
            ),
            'title_abstract_decisions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                 WHERE sd.investigation_version_uuid=inv.version_uuid
                   AND sd.stage='title_abstract'
            ),
            'full_text_decisions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                 WHERE sd.investigation_version_uuid=inv.version_uuid
                   AND sd.stage='full_text'
            ),
            'full_text_exclusions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                 WHERE sd.investigation_version_uuid=inv.version_uuid
                   AND sd.stage='full_text'
                   AND sd.decision='exclude'
            ),
            'adjudications',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                 WHERE sd.investigation_version_uuid=inv.version_uuid
                   AND sd.adjudication_flag=true
            )
        )
          FROM inv
    ),'{}'::jsonb),

    'reviewer_assignments',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'reviewer_assignment_uuid',ra.reviewer_assignment_uuid,
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
          FROM investigation.reviewer_assignment ra,inv
         WHERE ra.investigation_version_uuid=inv.version_uuid
           AND ra.record_status='active'
    ),'[]'::jsonb),

    'method_controls',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'quality_control_uuid',qc.quality_control_uuid,
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
                'performed_at',qc.performed_at,
                'evidence_artifact_uuid',qc.evidence_artifact_uuid,
                'notes',qc.notes
            )
            ORDER BY qc.performed_at,qc.quality_control_uuid
        )
          FROM investigation.quality_control_record qc,inv
         WHERE qc.investigation_version_uuid=inv.version_uuid
           AND qc.record_status='active'
    ),'[]'::jsonb),

    'map_items',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'map_item_uuid',mi.map_item_uuid,
                'target_version_uuid',mi.target_version_uuid,
                'target_id',e.oes_id,
                'target_type',e.entity_type,
                'item_role',mi.item_role,
                'inclusion_basis',mi.inclusion_basis_payload,
                'included_at',mi.included_at,
                'status',mi.status
            )
            ORDER BY e.entity_type,e.oes_id
        )
          FROM mapping.map_item mi
          JOIN fw
            ON fw.version_uuid=mi.framework_version_uuid
          JOIN core.entity_version ev
            ON ev.version_uuid=mi.target_version_uuid
          JOIN core.entity e
            ON e.entity_uuid=ev.entity_uuid
         WHERE mi.status='active'
    ),'[]'::jsonb),

    'assignments',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'assignment_uuid',a.assignment_uuid,
                'map_item_uuid',a.map_item_uuid,
                'category_uuid',a.category_uuid,
                'dimension_code',d.dimension_code,
                'category_code',c.category_code,
                'decision_state',a.decision_state,
                'assigned_by',a.assigned_by,
                'actor_type',a.actor_type,
                'assignment_method',a.assignment_method,
                'verification_status',a.verification_status,
                'verified_by',a.verified_by,
                'verifier_actor_type',a.verifier_actor_type,
                'verified_at',a.verified_at,
                'rationale',a.rationale_payload,
                'assigned_at',a.assigned_at,
                'status',a.status
            )
            ORDER BY a.map_item_uuid,d.sequence_no,a.decision_state,a.assigned_at
        )
          FROM mapping.assignment a
          JOIN mapping.map_item mi
            ON mi.map_item_uuid=a.map_item_uuid
          JOIN mapping.category c
            ON c.category_uuid=a.category_uuid
          JOIN mapping.dimension d
            ON d.dimension_uuid=c.dimension_uuid
          JOIN fw
            ON fw.version_uuid=mi.framework_version_uuid
         WHERE a.status='active'
    ),'[]'::jsonb),

    -- Backward-compatible focused subset.
    'classification_controls',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'quality_control_uuid',qc.quality_control_uuid,
                'control_type',qc.control_type,
                'control_code',qc.scope_payload->>'control_code',
                'actor',qc.actor,
                'actor_type',qc.actor_type,
                'decision',qc.decision,
                'performed_at',qc.performed_at
            )
            ORDER BY qc.performed_at
        )
          FROM investigation.quality_control_record qc,inv
         WHERE qc.investigation_version_uuid=inv.version_uuid
           AND qc.record_status='active'
           AND qc.scope_payload->>'control_code'='map_classification_verification'
    ),'[]'::jsonb),

    'cell_scope',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'cell_scope_uuid',cs.cell_scope_uuid,
                'row_category_uuid',cs.row_category_uuid,
                'column_category_uuid',cs.column_category_uuid,
                'scope_status',cs.scope_status,
                'gap_eligible',cs.gap_eligible,
                'rationale',cs.rationale,
                'metadata',cs.metadata_payload
            )
            ORDER BY rc.category_code,cc.category_code
        )
          FROM mapping.cell_scope cs
          JOIN fw
            ON fw.version_uuid=cs.framework_version_uuid
          JOIN mapping.category rc
            ON rc.category_uuid=cs.row_category_uuid
          JOIN mapping.category cc
            ON cc.category_uuid=cs.column_category_uuid
    ),'[]'::jsonb),

    'cells',COALESCE((
        SELECT jsonb_agg(
            to_jsonb(c)
            ORDER BY c.row_category_code,c.column_category_code
        )
          FROM fw
          CROSS JOIN LATERAL mapping.evidence_map_cells(fw.version_uuid) c
    ),'[]'::jsonb),

    'distributions',COALESCE((
        SELECT jsonb_object_agg(entity_type,item_count)
          FROM (
                SELECT e.entity_type,count(*) AS item_count
                  FROM mapping.map_item mi
                  JOIN fw
                    ON fw.version_uuid=mi.framework_version_uuid
                  JOIN core.entity_version ev
                    ON ev.version_uuid=mi.target_version_uuid
                  JOIN core.entity e
                    ON e.entity_uuid=ev.entity_uuid
                 WHERE mi.status='active'
                 GROUP BY e.entity_type
          ) x
    ),'{}'::jsonb),

    'gaps',COALESCE((
        SELECT jsonb_agg(
            to_jsonb(c)
            ORDER BY c.row_category_code,c.column_category_code
        )
          FROM fw
          CROSS JOIN LATERAL mapping.evidence_map_cells(fw.version_uuid) c
         WHERE c.empty_cell_gap
            OR c.apparent_gap
            OR c.primary_evidence_gap
            OR c.synthesis_gap
    ),'[]'::jsonb),

    'concentrations',COALESCE((
        SELECT jsonb_agg(
            to_jsonb(c)
            ORDER BY c.counted_unit_count DESC,
                     c.row_category_code,
                     c.column_category_code
        )
          FROM fw
          CROSS JOIN LATERAL mapping.evidence_map_cells(fw.version_uuid) c
         WHERE c.counted_unit_count>0
    ),'[]'::jsonb),

    'appraisal','[]'::jsonb,
    'certainty_links','[]'::jsonb,

    'stakeholder_engagement',COALESCE((
        SELECT stakeholder_payload FROM fw
    ),'{}'::jsonb),

    'limitations',COALESCE((
        SELECT jsonb_build_object('summary',limitations_summary)
          FROM pv
    ),'{}'::jsonb),

    'conclusion',COALESCE((
        SELECT jsonb_build_object('text',conclusion_text)
          FROM pv
    ),'{}'::jsonb),

    'references',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'report_id',r.report_id,
                'report_entity_uuid',r.report_entity_uuid,
                'report_version_uuid',r.report_version_uuid,
                'title',r.title,
                'publication_date',r.publication_date,
                'publication_status',r.publication_status,
                'source_locations',r.source_locations
            )
            ORDER BY r.publication_date NULLS LAST,r.report_id
        )
          FROM refs r
    ),'[]'::jsonb),

    'lineage',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'source_version_uuid',de.source_version_uuid,
                'target_version_uuid',de.target_version_uuid,
                'dependency_type',de.dependency_type,
                'derivation_rule',de.derivation_rule,
                'status',de.status
            )
            ORDER BY de.dependency_type,de.source_version_uuid
        )
          FROM provenance.dependency_edge de
         WHERE (
                de.target_version_uuid=p_product_version_uuid
                AND de.dependency_type='map_framework_informs_product'
               )
            OR (
                de.target_version_uuid=(SELECT version_uuid FROM fw)
                AND de.dependency_type='mapped_evidence_informs_framework'
               )
    ),'[]'::jsonb),

    'update_state',COALESCE((
        SELECT jsonb_build_object(
            'currency_status',currency_status,
            'assessed_at',currency_assessed_at,
            'assessed_by',currency_assessed_by,
            'rationale',currency_rationale
        )
          FROM pv
    ),'{}'::jsonb),

    'audit',jsonb_build_object(
        'synthetic_fixture',COALESCE((
            SELECT intended_audience='architecture_validation'
              FROM pv
        ),false),

        'assurance_level',
            product.assurance_level(p_product_version_uuid),

        'required_assurance_level',COALESCE((
            SELECT CASE
                WHEN coverage_claim='systematic_comprehensive'
                  OR gap_claim_mode='formal_within_scope'
                  OR mapping_subtype IN ('systematic_evidence_map','evidence_gap_map')
                THEN 'A3'
                ELSE 'A2'
            END
              FROM fw
        ),'A2'),

        'publishable',
            product.evidence_map_is_publishable(p_product_version_uuid),

        'coverage_claim',(SELECT coverage_claim FROM fw),
        'gap_claim_mode',(SELECT gap_claim_mode FROM fw),
        'framework_version_uuid',(SELECT version_uuid FROM fw),
        'framework_version_no',(SELECT framework_version_no FROM fw),
        'counting_unit_policy',(SELECT counting_unit_policy FROM fw),

        'classification_complete',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                    'MISSING_MAP_ITEM_CLASSIFICATION',
                    'UNVERIFIED_FORMAL_CLASSIFICATION',
                    'INSUFFICIENT_INDEPENDENT_CODING',
                    'UNRESOLVED_CLASSIFICATION_DISAGREEMENT',
                    'MISSING_CLASSIFICATION_QC'
               )
               AND severity='error'
        ),

        'search_controls_satisfied',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                    'MISSING_SEARCH_RECORD',
                    'INSUFFICIENT_DECLARED_COVERAGE',
                    'MISSING_REQUIRED_SEARCH_SOURCE',
                    'MISSING_REQUIRED_SEARCH_SOURCE_CLASS',
                    'MISSING_SEARCH_EXPORT',
                    'MISSING_SEARCH_PEER_REVIEW',
                    'MISSING_SCREENING_CONTROL',
                    'INCOMPLETE_SCREENING',
                    'MISSING_FULLTEXT_EXCLUSION_REASON',
                    'UNRESOLVED_SCREENING_DISAGREEMENT'
               )
               AND severity='error'
        ),

        'classification_controls_satisfied',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                    'MISSING_MAP_ITEM_CLASSIFICATION',
                    'UNVERIFIED_FORMAL_CLASSIFICATION',
                    'INSUFFICIENT_INDEPENDENT_CODING',
                    'UNRESOLVED_CLASSIFICATION_DISAGREEMENT',
                    'MISSING_CLASSIFICATION_QC'
               )
               AND severity='error'
        ),

        'formal_gap_eligible',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                    'MISSING_CELL_SCOPE',
                    'FORMAL_GAP_WITH_NON_SYSTEMATIC_COVERAGE',
                    'GAP_ELIGIBLE_OUTSIDE_SCOPE'
               )
               AND severity='error'
        ),

        'reviewer_assignment_count',COALESCE((
            SELECT count(*)
              FROM investigation.reviewer_assignment ra,inv
             WHERE ra.investigation_version_uuid=inv.version_uuid
               AND ra.record_status='active'
        ),0),

        'expert_independent_reviewed',EXISTS (
            SELECT 1
              FROM product.assurance_record ar
             WHERE ar.product_version_uuid=p_product_version_uuid
               AND ar.status='active'
               AND ar.assurance_type='expert_independent_review'
               AND ar.decision='approved'
        ),

        'lineage_available',(
            EXISTS (
                SELECT 1
                  FROM provenance.dependency_edge de
                 WHERE de.target_version_uuid=p_product_version_uuid
                   AND de.dependency_type='map_framework_informs_product'
                   AND de.status='active'
            )
            AND NOT EXISTS (
                SELECT 1
                  FROM mapping.map_item mi,fw
                 WHERE mi.framework_version_uuid=fw.version_uuid
                   AND mi.status='active'
                   AND NOT EXISTS (
                        SELECT 1
                          FROM provenance.dependency_edge de
                         WHERE de.source_version_uuid=mi.target_version_uuid
                           AND de.target_version_uuid=fw.version_uuid
                           AND de.dependency_type='mapped_evidence_informs_framework'
                           AND de.status='active'
                   )
            )
        ),

        'invalidated_dependencies',EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code='INVALIDATED_DEPENDENCY'
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
                    'performed_at',ar.performed_at,
                    'notes',ar.notes,
                    'evidence',ar.evidence_payload
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
