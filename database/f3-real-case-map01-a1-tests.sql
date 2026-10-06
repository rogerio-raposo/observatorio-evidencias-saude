-- OES Fase 3 — Real Case MAP-01 post-A1 tests

-- MAP01-A1-T01 — assurance rises exactly to A1.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('c8100000-0000-0000-0000-000000000020');

    IF v#>>'{audit,assurance_level}'<>'A1' THEN
        RAISE EXCEPTION 'MAP01-A1-T01 FAIL — expected A1, found %',v#>>'{audit,assurance_level}';
    END IF;

    IF COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false THEN
        RAISE EXCEPTION 'MAP01-A1-T01 FAIL — internal A1 MAP-01 became publishable';
    END IF;
END;
$test$;

-- MAP01-A1-T02 — no owner approval or expert review was fabricated.
DO $test$
BEGIN
    IF EXISTS (
        SELECT 1 FROM product.assurance_record
         WHERE product_version_uuid='c8100000-0000-0000-0000-000000000020'
           AND status='active'
           AND assurance_type IN ('owner_governance_approval','expert_independent_review')
    ) THEN
        RAISE EXCEPTION 'MAP01-A1-T02 FAIL — higher-level assurance record was fabricated';
    END IF;

    IF EXISTS (
        SELECT 1 FROM investigation.reviewer_assignment
         WHERE investigation_version_uuid='c8100000-0000-0000-0000-000000000002'
    ) THEN
        RAISE EXCEPTION 'MAP01-A1-T02 FAIL — human reviewer assignment was fabricated';
    END IF;
END;
$test$;

-- MAP01-A1-T03 — AI verification does not mutate assignment verification status.
DO $test$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM mapping.assignment a
          JOIN mapping.map_item mi ON mi.map_item_uuid=a.map_item_uuid
         WHERE mi.framework_version_uuid='c8100000-0000-0000-0000-000000000010'
           AND a.verification_status<>'unverified'
    ) THEN
        RAISE EXCEPTION 'MAP01-A1-T03 FAIL — assignment verification status changed';
    END IF;
END;
$test$;

-- MAP01-A1-T04 — publication blockers remain explicit.
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='PRODUCT_NOT_PUBLISHED' AND severity='error'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_OWNER_APPROVAL' AND severity='error'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='ASSURANCE_BELOW_REQUIRED_LEVEL' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'MAP01-A1-T04 FAIL — expected internal/publication blockers not preserved';
    END IF;
END;
$test$;

-- MAP01-A1-T05 — non-exhaustive/apparent-gap warnings remain explicit.
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='NON_EXHAUSTIVE_MAP' AND severity='warning'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='APPARENT_GAPS_ONLY' AND severity='warning'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='AI_ASSISTED_CLASSIFICATION' AND severity='warning'
    ) THEN
        RAISE EXCEPTION 'MAP01-A1-T05 FAIL — required exploratory warnings absent';
    END IF;
END;
$test$;

-- MAP01-A1-T06 — source-corpus identity and selection flow remain intact after A1.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('c8100000-0000-0000-0000-000000000020');

    IF jsonb_array_length(v->'source_investigations')<>1
       OR (v#>>'{selection_flow,search_hits}')::integer<>20
       OR (v#>>'{selection_flow,screening_decisions}')::integer<>34
       OR v#>>'{question,question_id}'<>'OES-Q-2026-001401'
    THEN
        RAISE EXCEPTION 'MAP01-A1-T06 FAIL — source corpus or MAP identity changed';
    END IF;
END;
$test$;

-- MAP01-A1-T07 — N3-01 remains unchanged.
DO $test$
BEGIN
    IF product.assurance_level('e1000000-0000-0000-0000-000000000702')<>'A0' THEN
        RAISE EXCEPTION 'MAP01-A1-T07 FAIL — N3-01 assurance changed';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.product_version pv
          JOIN core.entity_version ev ON ev.version_uuid=pv.version_uuid
         WHERE pv.version_uuid='e1000000-0000-0000-0000-000000000702'
           AND ev.version_status='current'
           AND pv.status='under_review'
    ) THEN
        RAISE EXCEPTION 'MAP01-A1-T07 FAIL — N3-01 current state changed';
    END IF;
END;
$test$;

SELECT 'MAP01-A1-T01–T07 PASS — MAP-01 internal assurance correctly derives A1 without publication or human-verification claims'
AS map01_a1_status;
