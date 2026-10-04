-- OES Fase 3 — Human Review Gate semantics
-- Test-only decisions are inserted inside a transaction and always rolled back.
-- Requires Real Case 01 dataset already loaded.
-- No real human review is created by this file.

BEGIN;

-- HRG-T01 — baseline real case remains blocked without approved review/publication date.
DO $t01$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'MISSING_APPROVED_REVIEW'
    ) THEN
        RAISE EXCEPTION 'HRG-T01 FAIL: missing approved-review issue not present';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'MISSING_PUBLICATION_DATE'
    ) THEN
        RAISE EXCEPTION 'HRG-T01 FAIL: missing publication-date issue not present';
    END IF;

    IF product.evidence_sheet_is_publishable(
        '81000000-0000-0000-0000-000000000701'
    ) THEN
        RAISE EXCEPTION 'HRG-T01 FAIL: baseline real case unexpectedly publishable';
    END IF;

    RAISE NOTICE 'HRG-T01 PASS — baseline remains blocked';
END
$t01$;

-- Synthetic revise decision: must not satisfy approved-review requirement.
INSERT INTO product.review_record(
    review_uuid, product_version_uuid, reviewer, role,
    independent_flag, decision, reviewed_at, notes, status
) VALUES (
    '87000000-0000-0000-0000-000000000001',
    '81000000-0000-0000-0000-000000000701',
    'TEST_ONLY_SYNTHETIC_REVIEWER',
    'methodological_reviewer_test',
    true,
    'revise',
    TIMESTAMPTZ '2026-10-04 12:30:00-03',
    'Synthetic CI record only; not a real human review.',
    'active'
);

DO $t02$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'MISSING_APPROVED_REVIEW'
    ) THEN
        RAISE EXCEPTION 'HRG-T02 FAIL: revise incorrectly satisfied approval requirement';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'ACTIVE_REJECTION'
    ) THEN
        RAISE EXCEPTION 'HRG-T02 FAIL: revise incorrectly treated as rejection';
    END IF;

    IF product.evidence_sheet_is_publishable(
        '81000000-0000-0000-0000-000000000701'
    ) THEN
        RAISE EXCEPTION 'HRG-T02 FAIL: revise made product publishable';
    END IF;

    RAISE NOTICE 'HRG-T02 PASS — revise keeps publication blocked';
END
$t02$;

UPDATE product.review_record
   SET status = 'superseded'
 WHERE review_uuid = '87000000-0000-0000-0000-000000000001';

-- Synthetic rejected decision: must add ACTIVE_REJECTION.
INSERT INTO product.review_record(
    review_uuid, product_version_uuid, reviewer, role,
    independent_flag, decision, reviewed_at, notes, status
) VALUES (
    '87000000-0000-0000-0000-000000000002',
    '81000000-0000-0000-0000-000000000701',
    'TEST_ONLY_SYNTHETIC_REVIEWER',
    'methodological_reviewer_test',
    true,
    'rejected',
    TIMESTAMPTZ '2026-10-04 12:31:00-03',
    'Synthetic CI record only; not a real human review.',
    'active'
);

DO $t03$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'ACTIVE_REJECTION'
    ) THEN
        RAISE EXCEPTION 'HRG-T03 FAIL: active rejection did not block product';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'MISSING_APPROVED_REVIEW'
    ) THEN
        RAISE EXCEPTION 'HRG-T03 FAIL: rejection unexpectedly satisfied approval requirement';
    END IF;

    RAISE NOTICE 'HRG-T03 PASS — rejection creates explicit blocking issue';
END
$t03$;

-- Add an approval while rejection is still active: rejection must continue to block.
INSERT INTO product.review_record(
    review_uuid, product_version_uuid, reviewer, role,
    independent_flag, decision, reviewed_at, notes, status
) VALUES (
    '87000000-0000-0000-0000-000000000003',
    '81000000-0000-0000-0000-000000000701',
    'TEST_ONLY_SYNTHETIC_REVIEWER_2',
    'methodological_reviewer_test',
    true,
    'approved',
    TIMESTAMPTZ '2026-10-04 12:32:00-03',
    'Synthetic CI record only; not a real human review.',
    'active'
);

DO $t04$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'MISSING_APPROVED_REVIEW'
    ) THEN
        RAISE EXCEPTION 'HRG-T04 FAIL: active approval not recognized';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'ACTIVE_REJECTION'
    ) THEN
        RAISE EXCEPTION 'HRG-T04 FAIL: approval incorrectly overrode active rejection';
    END IF;

    IF product.evidence_sheet_is_publishable(
        '81000000-0000-0000-0000-000000000701'
    ) THEN
        RAISE EXCEPTION 'HRG-T04 FAIL: approved + active rejection became publishable';
    END IF;

    RAISE NOTICE 'HRG-T04 PASS — active rejection overrides concurrent approval';
END
$t04$;

-- Resolve the synthetic rejection. Approval remains active.
UPDATE product.review_record
   SET status = 'superseded'
 WHERE review_uuid = '87000000-0000-0000-0000-000000000002';

DO $t05$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code IN ('MISSING_APPROVED_REVIEW','ACTIVE_REJECTION')
    ) THEN
        RAISE EXCEPTION 'HRG-T05 FAIL: review issues remain after resolved rejection + active approval';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '81000000-0000-0000-0000-000000000701'
        )
        WHERE issue_code = 'MISSING_PUBLICATION_DATE'
    ) THEN
        RAISE EXCEPTION 'HRG-T05 FAIL: publication date should still block eligibility';
    END IF;

    IF product.evidence_sheet_is_publishable(
        '81000000-0000-0000-0000-000000000701'
    ) THEN
        RAISE EXCEPTION 'HRG-T05 FAIL: approval alone made product publishable';
    END IF;

    RAISE NOTICE 'HRG-T05 PASS — approval alone is insufficient without publication date';
END
$t05$;

-- Simulate the final publication-date assignment after a real approval.
-- This update is test-only and will be rolled back.
UPDATE product.product_version
   SET publication_date = DATE '2026-10-04'
 WHERE version_uuid = '81000000-0000-0000-0000-000000000701';

DO $t06$
DECLARE issue_count integer;
BEGIN
    SELECT count(*)
      INTO issue_count
      FROM product.evidence_sheet_publication_issues(
        '81000000-0000-0000-0000-000000000701'
      )
     WHERE severity = 'error';

    IF issue_count <> 0 THEN
        RAISE EXCEPTION 'HRG-T06 FAIL: expected zero blocking issues, got %', issue_count;
    END IF;

    IF NOT product.evidence_sheet_is_publishable(
        '81000000-0000-0000-0000-000000000701'
    ) THEN
        RAISE EXCEPTION 'HRG-T06 FAIL: approved + publication date did not satisfy gate';
    END IF;

    RAISE NOTICE 'HRG-T06 PASS — resolved review + publication date satisfies publication gate';
END
$t06$;

-- Critical safety property: nothing above survives this file.
ROLLBACK;
