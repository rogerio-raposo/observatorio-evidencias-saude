-- OES-DBM-2026-0018
-- Fase 3 — Evidence Map source-corpus support
-- Depends on: baseline + migrations 002–017
-- Date: 2026-10-06
-- Additive/idempotent projection + publication-gate extension.
-- Enables a Map Product to own its mapping Question/Investigation while
-- inheriting Search/Screening from linked source_corpus Investigations.

BEGIN;

CREATE OR REPLACE FUNCTION product.evidence_map_search_investigations(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    investigation_version_uuid uuid,
    investigation_id text,
    product_role text,
    sequence_no integer
)
LANGUAGE sql
STABLE
AS $src$
    SELECT
        il.investigation_version_uuid,
        e.oes_id AS investigation_id,
        il.role AS product_role,
        COALESCE(il.sequence_no,CASE WHEN il.role='primary' THEN 0 ELSE 1 END) AS sequence_no
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity e
        ON e.entity_uuid=iv.entity_uuid
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role IN ('primary','source_corpus')
     ORDER BY
        CASE WHEN il.role='primary' THEN 0 ELSE 1 END,
        COALESCE(il.sequence_no,0),
        e.oes_id;
$src$;

CREATE OR REPLACE FUNCTION product.evidence_map_publication_issues(
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
    primary_count integer := 0;
    inv_uuid uuid;
    inv_cutoff date;
    inv_status text;
    fw_uuid uuid;
    fw mapping.framework_version%ROWTYPE;
    fw_count integer := 0;
    required_assurance text := 'A2';
    min_biblio integer := 0;
    actual_biblio integer := 0;
    independent_coding boolean := false;
BEGIN
    SELECT * INTO pv
      FROM product.product_version
     WHERE version_uuid=p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'MISSING_PRODUCT_VERSION','error','ProductVersion does not exist';
        RETURN;
    END IF;

    IF pv.product_type <> 'evidence_map' THEN
        RETURN QUERY SELECT
            'WRONG_PRODUCT_TYPE','error',
            format('Expected product_type=evidence_map, found %s',pv.product_type);
        RETURN;
    END IF;

    SELECT count(*) INTO primary_count
      FROM product.investigation_link
     WHERE product_version_uuid=p_product_version_uuid AND role='primary';

    IF primary_count=0 THEN
        RETURN QUERY SELECT 'MISSING_PRIMARY_INVESTIGATION','error','Evidence Map requires one primary Investigation';
        RETURN;
    ELSIF primary_count>1 THEN
        RETURN QUERY SELECT 'MULTIPLE_PRIMARY_INVESTIGATIONS','error','Evidence Map has more than one primary Investigation';
        RETURN;
    END IF;

    SELECT il.investigation_version_uuid,iv.evidence_cutoff_date,ev.version_status
      INTO inv_uuid,inv_cutoff,inv_status
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity_version ev ON ev.version_uuid=iv.version_uuid
     WHERE il.product_version_uuid=p_product_version_uuid AND il.role='primary';

    IF inv_cutoff IS DISTINCT FROM pv.evidence_cutoff_date THEN
        RETURN QUERY SELECT 'CUTOFF_MISMATCH','error','Product and Investigation evidence cutoff dates differ';
    END IF;

    IF inv_status <> 'current' THEN
        RETURN QUERY SELECT 'PRIMARY_INVESTIGATION_NOT_CURRENT','error','Primary Investigation must be current';
    END IF;

    SELECT count(*)
      INTO fw_count
      FROM provenance.dependency_edge de
      JOIN mapping.framework_version mfv ON mfv.version_uuid=de.source_version_uuid
     WHERE de.target_version_uuid=p_product_version_uuid
       AND de.dependency_type='map_framework_informs_product'
       AND de.status='active';

    SELECT de.source_version_uuid
      INTO fw_uuid
      FROM provenance.dependency_edge de
      JOIN mapping.framework_version mfv ON mfv.version_uuid=de.source_version_uuid
     WHERE de.target_version_uuid=p_product_version_uuid
       AND de.dependency_type='map_framework_informs_product'
       AND de.status='active'
     LIMIT 1;

    IF fw_count=0 THEN
        RETURN QUERY SELECT 'MISSING_MAP_FRAMEWORK','error','Evidence Map requires one active FrameworkVersion dependency';
        RETURN;
    ELSIF fw_count>1 THEN
        RETURN QUERY SELECT 'MULTIPLE_MAP_FRAMEWORKS','error','Evidence Map has more than one active FrameworkVersion dependency';
        RETURN;
    END IF;

    SELECT * INTO fw
      FROM mapping.framework_version
     WHERE version_uuid=fw_uuid;

    IF fw.investigation_version_uuid <> inv_uuid THEN
        RETURN QUERY SELECT 'FRAMEWORK_INVESTIGATION_MISMATCH','error','FrameworkVersion and Product use different primary Investigations';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM core.entity_version ev
         WHERE ev.version_uuid=fw_uuid AND ev.version_status='current'
    ) THEN
        RETURN QUERY SELECT 'MAP_FRAMEWORK_NOT_CURRENT','error','FrameworkVersion must be current';
    END IF;

    IF fw.codebook_artifact_uuid IS NULL OR NOT EXISTS (
        SELECT 1 FROM artifact.artifact a
         WHERE a.artifact_uuid=fw.codebook_artifact_uuid
           AND a.status='active'
           AND length(btrim(a.content_hash))>0
    ) THEN
        RETURN QUERY SELECT 'MISSING_CODEBOOK','error','An active hashed codebook artifact is required';
    END IF;

    IF (SELECT count(*) FROM mapping.dimension d
         WHERE d.framework_version_uuid=fw_uuid AND d.status='active' AND d.dimension_role='row_axis') <> 1
    THEN
        RETURN QUERY SELECT 'MISSING_ROW_DIMENSION','error','Exactly one active row_axis dimension is required';
    END IF;

    IF (SELECT count(*) FROM mapping.dimension d
         WHERE d.framework_version_uuid=fw_uuid AND d.status='active' AND d.dimension_role='column_axis') <> 1
    THEN
        RETURN QUERY SELECT 'MISSING_COLUMN_DIMENSION','error','Exactly one active column_axis dimension is required';
    END IF;

    IF fw.primary_row_dimension_code IS NULL OR NOT EXISTS (
        SELECT 1 FROM mapping.dimension d
         WHERE d.framework_version_uuid=fw_uuid
           AND d.status='active' AND d.dimension_role='row_axis'
           AND d.dimension_code=fw.primary_row_dimension_code
    ) THEN
        RETURN QUERY SELECT 'ROW_DIMENSION_CODE_MISMATCH','error','Framework row dimension code does not match active row_axis';
    END IF;

    IF fw.primary_column_dimension_code IS NULL OR NOT EXISTS (
        SELECT 1 FROM mapping.dimension d
         WHERE d.framework_version_uuid=fw_uuid
           AND d.status='active' AND d.dimension_role='column_axis'
           AND d.dimension_code=fw.primary_column_dimension_code
    ) THEN
        RETURN QUERY SELECT 'COLUMN_DIMENSION_CODE_MISMATCH','error','Framework column dimension code does not match active column_axis';
    END IF;

    IF EXISTS (
        SELECT 1 FROM mapping.dimension d
         WHERE d.framework_version_uuid=fw_uuid AND d.status='active'
           AND d.dimension_role IN ('row_axis','column_axis')
           AND NOT EXISTS (
                SELECT 1 FROM mapping.category c
                 WHERE c.dimension_uuid=d.dimension_uuid AND c.status='active'
           )
    ) THEN
        RETURN QUERY SELECT 'MISSING_ACTIVE_CATEGORY','error','Each active matrix axis requires at least one active category';
    END IF;

    IF fw.gap_claim_mode='formal_within_scope'
       AND fw.coverage_claim<>'systematic_comprehensive'
    THEN
        RETURN QUERY SELECT 'FORMAL_GAP_WITH_NON_SYSTEMATIC_COVERAGE','error','Formal gap claims require systematic_comprehensive coverage';
    END IF;

    -- Corpus inheritance is allowed only for non-systematic maps.
    -- Formal/systematic maps must own their Search records in the primary
    -- mapping Investigation and cannot satisfy coverage via source_corpus.
    IF fw.coverage_claim='systematic_comprehensive'
       OR fw.gap_claim_mode='formal_within_scope'
       OR fw.mapping_subtype IN ('systematic_evidence_map','evidence_gap_map')
    THEN
        IF NOT EXISTS (
            SELECT 1
              FROM investigation.search s
             WHERE s.investigation_version_uuid=inv_uuid
               AND s.status='completed'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_SEARCH_RECORD','error',
                'Formal/systematic Evidence Map requires at least one completed Search in its primary Investigation';
        END IF;
    ELSE
        IF NOT EXISTS (
            SELECT 1
              FROM investigation.search s
              JOIN product.investigation_link il
                ON il.investigation_version_uuid=s.investigation_version_uuid
             WHERE il.product_version_uuid=p_product_version_uuid
               AND il.role IN ('primary','source_corpus')
               AND s.status='completed'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_SEARCH_RECORD','error',
                'Evidence Map requires at least one completed Search in the primary or source_corpus Investigation';
        END IF;
    END IF;

    IF fw.coverage_claim='systematic_comprehensive' THEN
        IF fw.coverage_policy_payload='{}'::jsonb THEN
            RETURN QUERY SELECT 'INSUFFICIENT_DECLARED_COVERAGE','error','Systematic comprehensive coverage requires an explicit coverage policy';
        END IF;

        BEGIN
            min_biblio := COALESCE((fw.coverage_policy_payload->>'minimum_bibliographic_sources')::integer,0);
        EXCEPTION WHEN invalid_text_representation THEN
            min_biblio := 0;
        END;

        SELECT count(DISTINCT s.source_name) INTO actual_biblio
          FROM investigation.search s
         WHERE s.investigation_version_uuid=inv_uuid
           AND s.status='completed'
           AND s.filters_payload->>'source_class'='bibliographic_database';

        IF actual_biblio < min_biblio THEN
            RETURN QUERY SELECT
                'INSUFFICIENT_DECLARED_COVERAGE','error',
                format('Coverage policy requires %s bibliographic sources; found %s',min_biblio,actual_biblio);
        END IF;

        IF EXISTS (
            SELECT 1
              FROM jsonb_array_elements_text(COALESCE(fw.coverage_policy_payload->'required_source_names','[]'::jsonb)) req(name)
             WHERE NOT EXISTS (
                SELECT 1 FROM investigation.search s
                 WHERE s.investigation_version_uuid=inv_uuid
                   AND s.status='completed' AND s.source_name=req.name
             )
        ) THEN
            RETURN QUERY SELECT 'MISSING_REQUIRED_SEARCH_SOURCE','error','One or more required search sources are missing';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM jsonb_array_elements_text(COALESCE(fw.coverage_policy_payload->'required_source_classes','[]'::jsonb)) req(class_name)
             WHERE NOT EXISTS (
                SELECT 1 FROM investigation.search s
                 WHERE s.investigation_version_uuid=inv_uuid
                   AND s.status='completed'
                   AND s.filters_payload->>'source_class'=req.class_name
             )
        ) THEN
            RETURN QUERY SELECT 'MISSING_REQUIRED_SEARCH_SOURCE_CLASS','error','One or more required search source classes are missing';
        END IF;

        IF lower(COALESCE(fw.coverage_policy_payload->>'search_export_required','false'))='true'
           AND EXISTS (
                SELECT 1 FROM investigation.search s
                 WHERE s.investigation_version_uuid=inv_uuid
                   AND s.status='completed'
                   AND s.export_artifact_uuid IS NULL
           )
        THEN
            RETURN QUERY SELECT 'MISSING_SEARCH_EXPORT','error','Coverage policy requires an export artifact for every completed Search';
        END IF;

        IF NOT investigation.has_n4_control_with_assignment(
            inv_uuid,'search_strategy_peer_review','search','search_peer_reviewer'
        ) THEN
            RETURN QUERY SELECT 'MISSING_SEARCH_PEER_REVIEW','error','Formal systematic map requires qualified independent search peer review';
        END IF;

        IF NOT investigation.has_n4_control_with_assignment(
            inv_uuid,'screening_secondary_verification','screening','secondary_reviewer'
        ) THEN
            RETURN QUERY SELECT 'MISSING_SCREENING_CONTROL','error','Formal systematic map requires qualified secondary screening control';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM (
                    SELECT DISTINCT sh.report_entity_uuid
                      FROM investigation.search_hit sh
                      JOIN investigation.search s ON s.search_uuid=sh.search_uuid
                     WHERE s.investigation_version_uuid=inv_uuid
                       AND sh.report_entity_uuid IS NOT NULL
              ) h
             WHERE (SELECT count(DISTINCT sd.reviewer)
                      FROM investigation.screening_decision sd
                     WHERE sd.investigation_version_uuid=inv_uuid
                       AND sd.target_entity_uuid=h.report_entity_uuid
                       AND sd.stage='title_abstract') < 2
                OR (SELECT count(DISTINCT sd.reviewer)
                      FROM investigation.screening_decision sd
                     WHERE sd.investigation_version_uuid=inv_uuid
                       AND sd.target_entity_uuid=h.report_entity_uuid
                       AND sd.stage='full_text') < 2
        ) THEN
            RETURN QUERY SELECT 'INCOMPLETE_SCREENING','error','Materialized report hits require duplicate title/abstract and full-text screening';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid=inv_uuid
               AND sd.stage='full_text'
               AND sd.decision='exclude'
               AND btrim(COALESCE(sd.exclusion_reason,''))=''
        ) THEN
            RETURN QUERY SELECT 'MISSING_FULLTEXT_EXCLUSION_REASON','error','Full-text exclusions require an explicit reason';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid=inv_uuid
             GROUP BY sd.target_entity_uuid,sd.stage
            HAVING count(DISTINCT sd.decision)>1
               AND bool_or(sd.adjudication_flag)=false
        ) THEN
            RETURN QUERY SELECT 'UNRESOLVED_SCREENING_DISAGREEMENT','error','Screening disagreement is unresolved';
        END IF;
    END IF;

    independent_coding := lower(COALESCE(fw.classification_policy_payload->>'independent_coding','false'))='true';

    IF fw.coverage_claim='systematic_comprehensive' THEN
        IF EXISTS (
            SELECT 1
              FROM mapping.map_item mi
              CROSS JOIN mapping.dimension d
             WHERE mi.framework_version_uuid=fw_uuid
               AND mi.status='active'
               AND d.framework_version_uuid=fw_uuid
               AND d.status='active'
               AND d.required_flag=true
               AND NOT EXISTS (
                    SELECT 1
                      FROM mapping.assignment a
                      JOIN mapping.category c ON c.category_uuid=a.category_uuid
                     WHERE a.map_item_uuid=mi.map_item_uuid
                       AND c.dimension_uuid=d.dimension_uuid
                       AND a.decision_state='final'
                       AND a.status='active'
               )
        ) THEN
            RETURN QUERY SELECT 'MISSING_MAP_ITEM_CLASSIFICATION','error','Each active MapItem requires a final classification in every required dimension';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM mapping.map_item mi
              CROSS JOIN mapping.dimension d
             WHERE mi.framework_version_uuid=fw_uuid
               AND mi.status='active'
               AND d.framework_version_uuid=fw_uuid
               AND d.status='active'
               AND d.required_flag=true
               AND EXISTS (
                    SELECT 1
                      FROM mapping.assignment a
                      JOIN mapping.category c ON c.category_uuid=a.category_uuid
                     WHERE a.map_item_uuid=mi.map_item_uuid
                       AND c.dimension_uuid=d.dimension_uuid
                       AND a.decision_state='final'
                       AND a.status='active'
                       AND a.verification_status NOT IN ('human_verified','human_consensus')
               )
        ) THEN
            RETURN QUERY SELECT 'UNVERIFIED_FORMAL_CLASSIFICATION','error','Formal required classifications must be human verified or human consensus';
        END IF;

        IF independent_coding AND EXISTS (
            SELECT 1
              FROM mapping.map_item mi
              CROSS JOIN mapping.dimension d
             WHERE mi.framework_version_uuid=fw_uuid
               AND mi.status='active'
               AND d.framework_version_uuid=fw_uuid
               AND d.status='active'
               AND d.required_flag=true
               AND (SELECT count(DISTINCT a.assigned_by)
                      FROM mapping.assignment a
                      JOIN mapping.category c ON c.category_uuid=a.category_uuid
                     WHERE a.map_item_uuid=mi.map_item_uuid
                       AND c.dimension_uuid=d.dimension_uuid
                       AND a.decision_state='candidate'
                       AND a.status='active'
                       AND a.actor_type IN ('human_reviewer','human_expert')) < 2
        ) THEN
            RETURN QUERY SELECT 'INSUFFICIENT_INDEPENDENT_CODING','error','Independent coding requires at least two distinct human candidate coders for each required dimension';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM mapping.map_item mi
              JOIN mapping.dimension d
                ON d.framework_version_uuid=mi.framework_version_uuid
               AND d.status='active' AND d.multi_valued=false
             WHERE mi.framework_version_uuid=fw_uuid AND mi.status='active'
               AND (SELECT count(DISTINCT a.category_uuid)
                      FROM mapping.assignment a
                      JOIN mapping.category c ON c.category_uuid=a.category_uuid
                     WHERE a.map_item_uuid=mi.map_item_uuid
                       AND c.dimension_uuid=d.dimension_uuid
                       AND a.decision_state='candidate'
                       AND a.status='active') > 1
               AND NOT EXISTS (
                    SELECT 1
                      FROM mapping.assignment af
                      JOIN mapping.category cf ON cf.category_uuid=af.category_uuid
                     WHERE af.map_item_uuid=mi.map_item_uuid
                       AND cf.dimension_uuid=d.dimension_uuid
                       AND af.decision_state='final'
                       AND af.status='active'
                       AND af.assignment_method='consensus'
                       AND af.verification_status='human_consensus'
               )
        ) THEN
            RETURN QUERY SELECT 'UNRESOLVED_CLASSIFICATION_DISAGREEMENT','error','Single-valued candidate disagreement requires a human-consensus final assignment';
        END IF;

        IF NOT EXISTS (
            SELECT 1
              FROM investigation.quality_control_record q
             WHERE q.investigation_version_uuid=inv_uuid
               AND q.record_status='active'
               AND q.stage='extraction'
               AND q.control_type='other'
               AND q.scope_payload->>'control_code'='map_classification_verification'
               AND q.decision='passed'
               AND q.actor_type IN ('human_reviewer','human_expert')
               AND q.independent_flag=true
               AND q.qualification_payload IS NOT NULL
               AND q.qualification_payload<>'{}'::jsonb
               AND investigation.has_valid_reviewer_assignment(
                    inv_uuid,q.actor,'extraction','data_verifier',q.performed_at,true
               )
        ) THEN
            RETURN QUERY SELECT 'MISSING_CLASSIFICATION_QC','error','Formal map requires passed qualified independent classification QC';
        END IF;
    END IF;

    IF fw.gap_claim_mode='formal_within_scope'
       AND NOT EXISTS (
            SELECT 1 FROM mapping.cell_scope cs
             WHERE cs.framework_version_uuid=fw_uuid
       )
    THEN
        RETURN QUERY SELECT 'MISSING_CELL_SCOPE','error','Formal gap claims require explicit CellScope';
    END IF;

    IF EXISTS (
        SELECT 1 FROM mapping.cell_scope cs
         WHERE cs.framework_version_uuid=fw_uuid
           AND cs.gap_eligible=true AND cs.scope_status<>'in_scope'
    ) THEN
        RETURN QUERY SELECT 'GAP_ELIGIBLE_OUTSIDE_SCOPE','error','Only in-scope cells may be gap eligible';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM mapping.map_item mi
          JOIN core.entity_version ev ON ev.version_uuid=mi.target_version_uuid
         WHERE mi.framework_version_uuid=fw_uuid
           AND mi.status='active'
           AND ev.version_status='invalidated'
    ) THEN
        RETURN QUERY SELECT 'INVALIDATED_DEPENDENCY','error','An active MapItem targets an invalidated EntityVersion';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM mapping.map_item mi
         WHERE mi.framework_version_uuid=fw_uuid AND mi.status='active'
           AND NOT EXISTS (
                SELECT 1 FROM provenance.dependency_edge de
                 WHERE de.source_version_uuid=mi.target_version_uuid
                   AND de.target_version_uuid=fw_uuid
                   AND de.dependency_type='mapped_evidence_informs_framework'
                   AND de.status='active'
           )
    ) THEN
        RETURN QUERY SELECT 'MISSING_MAP_ITEM_DEPENDENCY_EDGE','error','Every active MapItem requires an active evidence-to-framework dependency edge';
    END IF;

    IF EXISTS (
        SELECT 1 FROM investigation.quality_control_record q
         WHERE q.investigation_version_uuid=inv_uuid
           AND q.record_status='active'
           AND q.decision IN ('revise','failed')
    ) THEN
        RETURN QUERY SELECT 'ACTIVE_REVISE_OR_FAILED_CONTROL','error','An active revise/failed methodological control blocks publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.currency_state cs
         WHERE cs.product_version_uuid=p_product_version_uuid
           AND cs.record_status='active'
           AND cs.currency_status='current'
    ) THEN
        RETURN QUERY SELECT 'MISSING_CURRENCY_STATE','error','Published Evidence Map requires active current CurrencyState';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='ai_methodological_verification'
           AND ar.decision='passed'
    ) THEN
        RETURN QUERY SELECT 'MISSING_AI_METHODOLOGICAL_VERIFICATION','error','Passed AI methodological verification is required';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='owner_governance_approval'
           AND ar.decision='approved'
    ) THEN
        RETURN QUERY SELECT 'MISSING_OWNER_APPROVAL','error','Owner governance approval is required for publication';
    END IF;

    IF fw.coverage_claim='systematic_comprehensive'
       OR fw.gap_claim_mode='formal_within_scope'
       OR fw.mapping_subtype IN ('systematic_evidence_map','evidence_gap_map')
    THEN
        required_assurance := 'A3';
    ELSE
        required_assurance := 'A2';
    END IF;

    IF required_assurance='A3' THEN
        IF NOT EXISTS (
            SELECT 1 FROM product.assurance_record ar
             WHERE ar.product_version_uuid=p_product_version_uuid
               AND ar.status='active'
               AND ar.assurance_type='expert_independent_review'
               AND ar.decision='approved'
        ) THEN
            RETURN QUERY SELECT 'MISSING_EXPERT_INDEPENDENT_REVIEW','error','Formal systematic map requires approved independent expert review';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM investigation.reviewer_assignment ra
             WHERE ra.investigation_version_uuid=inv_uuid
               AND ra.record_status='active'
               AND ra.role='expert_independent_reviewer'
               AND ra.actor_type='human_expert'
               AND ra.independent_flag=true
               AND lower(COALESCE(ra.qualification_payload->>'qualified','false'))='true'
        ) THEN
            RETURN QUERY SELECT 'MISSING_EXPERT_REVIEWER_ASSIGNMENT','error','A3 Evidence Map requires a qualified independent expert reviewer assignment';
        END IF;
    END IF;

    IF product.assurance_level(p_product_version_uuid) <> required_assurance
       AND NOT (required_assurance='A2' AND product.assurance_level(p_product_version_uuid)='A3')
    THEN
        RETURN QUERY SELECT
            'ASSURANCE_BELOW_REQUIRED_LEVEL','error',
            format('Evidence Map requires %s; current assurance is %s',required_assurance,product.assurance_level(p_product_version_uuid));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM core.entity_version ev
         WHERE ev.version_uuid=p_product_version_uuid AND ev.version_status='current'
    ) THEN
        RETURN QUERY SELECT 'NOT_CURRENT_ENTITY_VERSION','error','ProductVersion must be current for publication';
    END IF;

    IF pv.status <> 'published' THEN
        RETURN QUERY SELECT 'PRODUCT_NOT_PUBLISHED','error','Formal publication gate requires status=published';
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT 'MISSING_PUBLICATION_DATE','error','Publication date is required';
    END IF;

    IF btrim(COALESCE(pv.limitations_summary,''))='' THEN
        RETURN QUERY SELECT 'MISSING_LIMITATIONS','error','Evidence Map limitations must be explicit';
    END IF;

    IF fw.coverage_claim<>'systematic_comprehensive' THEN
        RETURN QUERY SELECT 'NON_EXHAUSTIVE_MAP','warning','Map does not claim systematic comprehensive coverage';
    END IF;

    IF fw.gap_claim_mode='apparent_only' THEN
        RETURN QUERY SELECT 'APPARENT_GAPS_ONLY','warning','Any empty-cell gaps are apparent within consulted sources, not formal absence claims';
    END IF;

    IF lower(COALESCE(fw.stakeholder_payload->>'engaged','false'))<>'true' THEN
        RETURN QUERY SELECT 'NO_STAKEHOLDER_ENGAGEMENT','warning','No stakeholder engagement is recorded for this FrameworkVersion';
    END IF;

    IF EXISTS (
        SELECT 1 FROM mapping.assignment a
        JOIN mapping.map_item mi ON mi.map_item_uuid=a.map_item_uuid
         WHERE mi.framework_version_uuid=fw_uuid
           AND a.status='active'
           AND (a.actor_type='ai_system' OR a.assignment_method='ai_assisted')
    ) THEN
        RETURN QUERY SELECT 'AI_ASSISTED_CLASSIFICATION','warning','At least one active classification used AI assistance';
    END IF;

    RETURN;
END;
$gate$;

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
source_inv AS (
    SELECT
        iv.*,
        ie.oes_id AS investigation_id,
        ev.version_status,
        il.role AS product_role,
        il.sequence_no AS product_sequence_no
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity ie
        ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=iv.version_uuid
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='source_corpus'
),
search_invs AS (
    SELECT
        inv.version_uuid,
        inv.entity_uuid,
        inv.investigation_id,
        'primary'::text AS product_role,
        0::integer AS product_sequence_no
      FROM inv
    UNION ALL
    SELECT
        source_inv.version_uuid,
        source_inv.entity_uuid,
        source_inv.investigation_id,
        source_inv.product_role,
        COALESCE(source_inv.product_sequence_no,1)
      FROM source_inv
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

    'source_investigations',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'investigation_id',si.investigation_id,
                'investigation_entity_uuid',si.entity_uuid,
                'investigation_version_uuid',si.version_uuid,
                'investigation_type',si.investigation_type,
                'depth_level',si.depth_level,
                'maintenance_level',si.maintenance_level,
                'objective',si.objective,
                'protocol_artifact_uuid',si.protocol_artifact_uuid,
                'evidence_cutoff_date',si.evidence_cutoff_date,
                'status',si.status,
                'version_status',si.version_status,
                'product_role',si.product_role,
                'sequence_no',si.product_sequence_no
            )
            ORDER BY si.product_sequence_no,si.investigation_id
        )
          FROM source_inv si
    ),'[]'::jsonb),

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
                'status',s.status,
                'investigation_version_uuid',si.version_uuid,
                'investigation_id',si.investigation_id,
                'investigation_role',si.product_role
            )
            ORDER BY si.product_sequence_no,s.executed_at,s.search_uuid
        )
          FROM search_invs si
          JOIN investigation.search s
            ON s.investigation_version_uuid=si.version_uuid
          LEFT JOIN artifact.artifact a
            ON a.artifact_uuid=s.export_artifact_uuid
    ),'[]'::jsonb),

    'selection_flow',jsonb_build_object(
        'search_hits',(
            SELECT count(*)
              FROM investigation.search_hit sh
              JOIN investigation.search s
                ON s.search_uuid=sh.search_uuid
             WHERE s.investigation_version_uuid IN (
                    SELECT version_uuid FROM search_invs
             )
        ),
        'unique_report_targets',(
            SELECT count(DISTINCT sh.report_entity_uuid)
              FROM investigation.search_hit sh
              JOIN investigation.search s
                ON s.search_uuid=sh.search_uuid
             WHERE s.investigation_version_uuid IN (
                    SELECT version_uuid FROM search_invs
             )
               AND sh.report_entity_uuid IS NOT NULL
        ),
        'screening_decisions',(
            SELECT count(*)
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid IN (
                    SELECT version_uuid FROM search_invs
             )
        ),
        'title_abstract_decisions',(
            SELECT count(*)
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid IN (
                    SELECT version_uuid FROM search_invs
             )
               AND sd.stage='title_abstract'
        ),
        'full_text_decisions',(
            SELECT count(*)
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid IN (
                    SELECT version_uuid FROM search_invs
             )
               AND sd.stage='full_text'
        ),
        'full_text_exclusions',(
            SELECT count(*)
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid IN (
                    SELECT version_uuid FROM search_invs
             )
               AND sd.stage='full_text'
               AND sd.decision='exclude'
        ),
        'adjudications',(
            SELECT count(*)
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid IN (
                    SELECT version_uuid FROM search_invs
             )
               AND sd.adjudication_flag=true
        ),
        'source_investigation_count',(
            SELECT count(*) FROM source_inv
        )
    ),

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

        'source_corpus_count',(SELECT count(*) FROM source_inv),

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
