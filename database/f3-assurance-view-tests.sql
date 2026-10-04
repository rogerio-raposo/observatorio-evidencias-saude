-- OES Fase 3 — Assurance-aware EvidenceSheetView tests
BEGIN;

DO $v01$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v#>>'{audit,assurance_level}' <> 'A2' THEN
        RAISE EXCEPTION 'AV-T01 FAIL: expected A2 assurance in view';
    END IF;

    IF v#>>'{audit,expert_independent_reviewed}' <> 'false' THEN
        RAISE EXCEPTION 'AV-T01 FAIL: fixture incorrectly claims expert review';
    END IF;

    IF jsonb_array_length(v#>'{audit,assurance_records}') <> 2 THEN
        RAISE EXCEPTION 'AV-T01 FAIL: expected 2 active/historical assurance records in fixture';
    END IF;

    IF position(
        'revisão especializada independente não realizada'
        IN lower(v#>>'{audit,assurance_disclosure}')
    ) = 0 THEN
        RAISE EXCEPTION 'AV-T01 FAIL: no-expert disclosure missing';
    END IF;

    IF v#>>'{audit,publishable}' <> 'true' THEN
        RAISE EXCEPTION 'AV-T01 FAIL: A2 fixture should remain publishable';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
        WHERE i->>'issue_code'='NO_EXPERT_INDEPENDENT_REVIEW'
          AND i->>'severity'='warning'
    ) THEN
        RAISE EXCEPTION 'AV-T01 FAIL: no-expert warning not exposed in view';
    END IF;

    RAISE NOTICE 'AV-T01 PASS — EvidenceSheetView exposes A2 and no-expert disclosure';
END
$v01$;

-- A1 real case after AI methodological verification remains explicit.
DO $v02$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '81000000-0000-0000-0000-000000000701'
    ) INTO v;

    IF v IS NULL THEN
        RAISE NOTICE 'AV-T02 SKIP — real case not loaded in this transaction';
        RETURN;
    END IF;

    IF v#>>'{audit,assurance_level}' <> 'A1' THEN
        RAISE EXCEPTION 'AV-T02 FAIL: AI-verified real case should be A1';
    END IF;

    IF v#>>'{audit,expert_independent_reviewed}' <> 'false' THEN
        RAISE EXCEPTION 'AV-T02 FAIL: unverified real case claims expert review';
    END IF;

    IF jsonb_array_length(v#>'{audit,assurance_records}') <> 2 THEN
        RAISE EXCEPTION 'AV-T02 FAIL: expected superseded REVISE + active PASSED assurance records';
    END IF;

    RAISE NOTICE 'AV-T02 PASS — real case renders A1 with adversarial verification history';
END
$v02$;

ROLLBACK;
