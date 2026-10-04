-- OES Fase 3 — Evidence Sheet contract tests
-- Run after f2b-fixtures.sql + f3-evidence-sheet-fixtures.sql.

BEGIN;

-- F3-FE-T02 — limitations_summary is persisted.
DO $t02$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.product_version
         WHERE version_uuid='71000000-0000-0000-0000-000000000001'
           AND btrim(coalesce(limitations_summary,'')) <> ''
    ) THEN
        RAISE EXCEPTION 'F3-FE-T02 FAIL: limitations_summary missing';
    END IF;
    RAISE NOTICE 'F3-FE-T02 PASS — limitations summary persisted';
END
$t02$;

-- F3-FE-T03 — invalid editorial status must fail.
DO $t03$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
        UPDATE product.product_version
           SET status='invalid_editorial_state'
         WHERE version_uuid='71000000-0000-0000-0000-000000000001';
    EXCEPTION WHEN check_violation THEN
        caught:=true;
    END;

    IF NOT caught THEN
        RAISE EXCEPTION 'F3-FE-T03 FAIL: invalid editorial status accepted';
    END IF;

    RAISE NOTICE 'F3-FE-T03 PASS — editorial vocabulary enforced';
END
$t03$;

-- F3-FE-T04 — only one active currency state per ProductVersion.
DO $t04$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
        INSERT INTO product.currency_state(
            currency_state_uuid, product_version_uuid,
            currency_status, assessed_by, rationale, record_status
        ) VALUES (
            '72000000-0000-0000-0000-000000000004',
            '71000000-0000-0000-0000-000000000001',
            'under_evaluation','f3',
            'Attempted duplicate active state','active'
        );
    EXCEPTION WHEN unique_violation THEN
        caught:=true;
    END;

    IF NOT caught THEN
        RAISE EXCEPTION 'F3-FE-T04 FAIL: two active currency states accepted';
    END IF;

    RAISE NOTICE 'F3-FE-T04 PASS — one active currency state enforced';
END
$t04$;

-- F3-FE-T05 — currency history preserved through supersession.
UPDATE product.currency_state
   SET record_status='superseded'
 WHERE currency_state_uuid='72000000-0000-0000-0000-000000000001';

INSERT INTO product.currency_state(
    currency_state_uuid, product_version_uuid,
    currency_status, assessed_by, rationale,
    supersedes_currency_state_uuid, record_status
) VALUES (
    '72000000-0000-0000-0000-000000000005',
    '71000000-0000-0000-0000-000000000001',
    'under_evaluation',
    'f3',
    'New evidence detected; evaluation underway',
    '72000000-0000-0000-0000-000000000001',
    'active'
);

DO $t05$
DECLARE total integer; active_n integer;
BEGIN
    SELECT
        count(*),
        count(*) FILTER (WHERE record_status='active')
      INTO total,active_n
      FROM product.currency_state
     WHERE product_version_uuid='71000000-0000-0000-0000-000000000001';

    IF total<>2 OR active_n<>1 THEN
        RAISE EXCEPTION
            'F3-FE-T05 FAIL: total %, active %',
            total,active_n;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.current_currency_state
         WHERE product_version_uuid='71000000-0000-0000-0000-000000000001'
           AND currency_status='under_evaluation'
    ) THEN
        RAISE EXCEPTION 'F3-FE-T05 FAIL: current currency projection incorrect';
    END IF;

    RAISE NOTICE 'F3-FE-T05 PASS — currency history and current projection preserved';
END
$t05$;

-- F3-FE-T06 — multiple change classes coexist.
DO $t06$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
      FROM product.version_change_class
     WHERE product_version_uuid='71000000-0000-0000-0000-000000000001';

    IF n<>2 THEN
        RAISE EXCEPTION 'F3-FE-T06 FAIL: change classes %',n;
    END IF;

    RAISE NOTICE 'F3-FE-T06 PASS — multiple change classes coexist';
END
$t06$;

-- F3-FE-T07 — A2 assurance persists; legacy review remains audit-only.
DO $t07$
BEGIN
    IF product.evidence_sheet_assurance_level(
        '71000000-0000-0000-0000-000000000001'
    ) <> 'A2' THEN
        RAISE EXCEPTION 'F3-FE-T07 FAIL: expected assurance A2';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record
         WHERE product_version_uuid='71000000-0000-0000-0000-000000000001'
           AND status='active'
           AND assurance_type='ai_methodological_verification'
           AND decision='passed'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.assurance_record
         WHERE product_version_uuid='71000000-0000-0000-0000-000000000001'
           AND status='active'
           AND assurance_type='owner_governance_approval'
           AND decision='approved'
    ) THEN
        RAISE EXCEPTION 'F3-FE-T07 FAIL: A2 assurance records missing';
    END IF;

    RAISE NOTICE 'F3-FE-T07 PASS — A2 assurance persisted without expert review';
END
$t07$;

-- F3-FE-T08 — second primary Investigation must fail.
DO $t08$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
        INSERT INTO product.investigation_link(
            product_version_uuid, investigation_version_uuid, role, sequence_no
        ) VALUES (
            '71000000-0000-0000-0000-000000000001',
            '71000000-0000-0000-0000-000000000050',
            'primary',
            99
        );
    EXCEPTION WHEN unique_violation THEN
        caught:=true;
    END;

    IF NOT caught THEN
        RAISE EXCEPTION 'F3-FE-T08 FAIL: second primary Investigation accepted';
    END IF;

    RAISE NOTICE 'F3-FE-T08 PASS — one primary Investigation enforced';
END
$t08$;

-- F3-FE-T09 — an incomplete legacy fixture returns publication issues.
DO $t09$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
      FROM product.evidence_sheet_publication_issues(
          '10000000-0000-0000-0000-000000000009'
      )
     WHERE severity='error';

    IF n < 3 THEN
        RAISE EXCEPTION
            'F3-FE-T09 FAIL: expected multiple errors for incomplete legacy fixture, got %',
            n;
    END IF;

    RAISE NOTICE 'F3-FE-T09 PASS — incomplete Evidence Sheet exposes % blocking issues',n;
END
$t09$;

-- F3-FE-T10 — complete fixture is publishable.
DO $t10$
DECLARE ok boolean; errors integer;
BEGIN
    SELECT product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) INTO ok;

    SELECT count(*) INTO errors
      FROM product.evidence_sheet_publication_issues(
          '71000000-0000-0000-0000-000000000001'
      )
     WHERE severity='error';

    IF NOT ok OR errors<>0 THEN
        RAISE EXCEPTION
            'F3-FE-T10 FAIL: publishable %, errors %',
            ok,errors;
    END IF;

    RAISE NOTICE 'F3-FE-T10 PASS — complete Evidence Sheet is publishable';
END
$t10$;

-- F3-FE-T11 — active rejection blocks publication.
INSERT INTO product.review_record(
    review_uuid, product_version_uuid, reviewer, role,
    independent_flag, decision, notes, status
) VALUES (
    '73000000-0000-0000-0000-000000000011',
    '71000000-0000-0000-0000-000000000001',
    'f3-rejector',
    'methodological_reviewer',
    true,
    'rejected',
    'Temporary rejection fixture',
    'active'
);

DO $t11a$
BEGIN
    IF product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'F3-FE-T11 FAIL: active rejection did not block publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_sheet_publication_issues(
              '71000000-0000-0000-0000-000000000001'
          )
         WHERE issue_code='LEGACY_ACTIVE_REJECTION'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'F3-FE-T11 FAIL: LEGACY_ACTIVE_REJECTION issue missing';
    END IF;

    RAISE NOTICE 'F3-FE-T11a PASS — active rejection blocks publication';
END
$t11a$;

UPDATE product.review_record
   SET status='superseded'
 WHERE review_uuid='73000000-0000-0000-0000-000000000011';

DO $t11b$
BEGIN
    IF NOT product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'F3-FE-T11 FAIL: superseded rejection still blocks publication';
    END IF;

    RAISE NOTICE 'F3-FE-T11b PASS — superseded rejection no longer blocks publication';
END
$t11b$;

-- F3-FE-T12 — inconsistent cutoff is detected.
UPDATE product.product_version
   SET evidence_cutoff_date=DATE '2026-10-03'
 WHERE version_uuid='71000000-0000-0000-0000-000000000001';

DO $t12a$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_sheet_publication_issues(
              '71000000-0000-0000-0000-000000000001'
          )
         WHERE issue_code='CUTOFF_DATE_MISMATCH'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'F3-FE-T12 FAIL: cutoff mismatch not detected';
    END IF;

    RAISE NOTICE 'F3-FE-T12a PASS — cutoff mismatch detected';
END
$t12a$;

UPDATE product.product_version
   SET evidence_cutoff_date=DATE '2026-10-04'
 WHERE version_uuid='71000000-0000-0000-0000-000000000001';

DO $t12b$
BEGIN
    IF NOT product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'F3-FE-T12 FAIL: restored cutoff did not restore publishability';
    END IF;

    RAISE NOTICE 'F3-FE-T12b PASS — restored cutoff restores publishability';
END
$t12b$;

ROLLBACK;
