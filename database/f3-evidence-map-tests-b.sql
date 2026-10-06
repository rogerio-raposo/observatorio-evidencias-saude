-- OES Fase 3 — Evidence Map contract tests B
-- Adversarial publication-gate tests. Each mutation is rolled back.

-- EM-T07 — formal gap + non-systematic coverage combination is blocked at persistence.
DO $test$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        UPDATE mapping.framework_version
           SET coverage_claim='structured_non_exhaustive'
         WHERE version_uuid='b4100000-0000-0000-0000-000000000010';
    EXCEPTION WHEN check_violation THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'EM-T07 FAIL — formal gap with non-systematic coverage was accepted';
    END IF;
END;
$test$;

-- EM-T08 — formal gap without CellScope closes the gate.
BEGIN;
DELETE FROM mapping.cell_scope WHERE framework_version_uuid='b4100000-0000-0000-0000-000000000010';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_CELL_SCOPE' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T08 FAIL — MISSING_CELL_SCOPE not raised'; END IF;
END;
$test$;
ROLLBACK;

-- EM-T09 — missing required final classification closes the gate.
BEGIN;
DELETE FROM mapping.assignment
 WHERE map_item_uuid='b4500000-0000-0000-0000-000000000101'
   AND category_uuid='b4410000-0000-0000-0000-000000000021'
   AND decision_state='final' AND status='active';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_MAP_ITEM_CLASSIFICATION' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T09 FAIL — missing required classification not detected'; END IF;
END;
$test$;
ROLLBACK;

-- EM-T12 — independent coding requires two distinct human candidate coders.
BEGIN;
DELETE FROM mapping.assignment
 WHERE map_item_uuid='b4500000-0000-0000-0000-000000000101'
   AND category_uuid='b4410000-0000-0000-0000-000000000021'
   AND decision_state='candidate'
   AND assigned_by='SYN_MAP_R2';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='INSUFFICIENT_INDEPENDENT_CODING' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T12 FAIL — insufficient independent coding not detected'; END IF;
END;
$test$;
ROLLBACK;

-- EM-T13 — disagreement without consensus resolution closes the gate.
BEGIN;
UPDATE mapping.assignment a
   SET assignment_method='manual',verification_status='human_verified'
  FROM mapping.category c
 WHERE a.category_uuid=c.category_uuid
   AND a.map_item_uuid='b4500000-0000-0000-0000-000000000102'
   AND c.dimension_uuid='b4400000-0000-0000-0000-000000000001'
   AND a.decision_state='final' AND a.status='active';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='UNRESOLVED_CLASSIFICATION_DISAGREEMENT' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T13 FAIL — unresolved classification disagreement not detected'; END IF;
END;
$test$;
ROLLBACK;

-- EM-T15 — missing classification QC closes formal-map gate.
BEGIN;
UPDATE investigation.quality_control_record
   SET record_status='superseded'
 WHERE quality_control_uuid='b4620000-0000-0000-0000-000000000003';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_CLASSIFICATION_QC' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T15 FAIL — missing classification QC not detected'; END IF;
END;
$test$;
ROLLBACK;

-- EM-T16 — missing qualified search peer-review control closes formal-map gate.
BEGIN;
UPDATE investigation.quality_control_record
   SET record_status='superseded'
 WHERE quality_control_uuid='b4620000-0000-0000-0000-000000000001';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_SEARCH_PEER_REVIEW' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T16 FAIL — missing search peer review not detected'; END IF;
END;
$test$;
ROLLBACK;

-- EM-T17 — A3 alone cannot bypass missing stage controls.
BEGIN;
UPDATE investigation.quality_control_record
   SET record_status='superseded'
 WHERE quality_control_uuid='b4620000-0000-0000-0000-000000000002';
DO $test$
BEGIN
    IF product.assurance_level('b4100000-0000-0000-0000-000000000020')<>'A3' THEN
        RAISE EXCEPTION 'EM-T17 setup FAIL — assurance ceased to be A3';
    END IF;
    IF product.evidence_map_is_publishable('b4100000-0000-0000-0000-000000000020') THEN
        RAISE EXCEPTION 'EM-T17 FAIL — A3 bypassed missing screening stage control';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_SCREENING_CONTROL' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T17 FAIL — missing screening control issue absent'; END IF;
END;
$test$;
ROLLBACK;

-- EM-T18 — invalidated active MapItem dependency closes the gate.
BEGIN;
UPDATE core.entity_version
   SET version_status='invalidated'
 WHERE version_uuid='d1000000-0000-0000-0000-000000000101';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='INVALIDATED_DEPENDENCY' AND severity='error'
    ) THEN RAISE EXCEPTION 'EM-T18 FAIL — invalidated MapItem dependency not detected'; END IF;
END;
$test$;
ROLLBACK;

DO $test$
BEGIN
    IF NOT product.evidence_map_is_publishable('b4100000-0000-0000-0000-000000000020') THEN
        RAISE EXCEPTION 'Adversarial rollback FAIL — valid fixture was not restored';
    END IF;
END;
$test$;

SELECT 'EM-T07–T09/T12/T13/T15–T18 PASS' AS evidence_map_tests_b_status;
