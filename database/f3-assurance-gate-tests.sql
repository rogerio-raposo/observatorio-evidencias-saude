-- OES Fase 3 — Assurance Governance Gate semantics
-- All mutations are transactional and rolled back.

BEGIN;

-- AG-T01 — baseline complete fixture is A2, publishable, with explicit no-expert warning.
DO $t01$
BEGIN
    IF product.evidence_sheet_assurance_level(
        '71000000-0000-0000-0000-000000000001'
    ) <> 'A2' THEN
        RAISE EXCEPTION 'AG-T01 FAIL: baseline fixture is not A2';
    END IF;

    IF NOT product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'AG-T01 FAIL: A2 N2 fixture should be publishable';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        )
        WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW'
          AND severity='warning'
    ) THEN
        RAISE EXCEPTION 'AG-T01 FAIL: no-expert disclosure warning missing';
    END IF;

    RAISE NOTICE 'AG-T01 PASS — A2 is publishable with explicit no-expert warning';
END
$t01$;

-- AG-T02 — expert approval elevates A2 -> A3 and removes no-expert warning.
INSERT INTO product.assurance_record(
    assurance_uuid, product_version_uuid, assurance_type,
    actor, actor_type, independent_flag, decision,
    performed_at, notes, evidence_payload, status
) VALUES (
    '73200000-0000-0000-0000-000000000001',
    '71000000-0000-0000-0000-000000000001',
    'expert_independent_review',
    'TEST_EXPERT',
    'human_expert',
    true,
    'approved',
    TIMESTAMPTZ '2026-10-04 12:10:00-03',
    'Synthetic expert assurance record for CI only',
    '{"test_fixture":true}'::jsonb,
    'active'
);

DO $t02$
BEGIN
    IF product.evidence_sheet_assurance_level(
        '71000000-0000-0000-0000-000000000001'
    ) <> 'A3' THEN
        RAISE EXCEPTION 'AG-T02 FAIL: expert approval did not elevate to A3';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        )
        WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW'
    ) THEN
        RAISE EXCEPTION 'AG-T02 FAIL: no-expert warning remains at A3';
    END IF;

    IF NOT product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'AG-T02 FAIL: A3 fixture unexpectedly blocked';
    END IF;

    RAISE NOTICE 'AG-T02 PASS — expert approval elevates A2 to A3';
END
$t02$;

-- AG-T03 — expert revise blocks publication.
UPDATE product.assurance_record
   SET decision='revise'
 WHERE assurance_uuid='73200000-0000-0000-0000-000000000001';

DO $t03$
BEGIN
    IF product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'AG-T03 FAIL: expert revise did not block publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        )
        WHERE issue_code='ACTIVE_EXPERT_REVISE'
          AND severity='error'
    ) THEN
        RAISE EXCEPTION 'AG-T03 FAIL: ACTIVE_EXPERT_REVISE issue missing';
    END IF;

    IF product.evidence_sheet_assurance_level(
        '71000000-0000-0000-0000-000000000001'
    ) <> 'A2' THEN
        RAISE EXCEPTION 'AG-T03 FAIL: assurance level should fall back to A2';
    END IF;

    RAISE NOTICE 'AG-T03 PASS — expert revise blocks without erasing A2';
END
$t03$;

-- AG-T04 — expert rejection blocks publication.
UPDATE product.assurance_record
   SET decision='rejected'
 WHERE assurance_uuid='73200000-0000-0000-0000-000000000001';

DO $t04$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        )
        WHERE issue_code='ACTIVE_EXPERT_REJECTION'
          AND severity='error'
    ) THEN
        RAISE EXCEPTION 'AG-T04 FAIL: ACTIVE_EXPERT_REJECTION issue missing';
    END IF;

    IF product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'AG-T04 FAIL: expert rejection did not block';
    END IF;

    RAISE NOTICE 'AG-T04 PASS — expert rejection blocks publication';
END
$t04$;

UPDATE product.assurance_record
   SET status='superseded'
 WHERE assurance_uuid='73200000-0000-0000-0000-000000000001';

-- AG-T05 — owner revise removes A2, leaves A1 and blocks.
UPDATE product.assurance_record
   SET decision='revise'
 WHERE assurance_uuid='73100000-0000-0000-0000-000000000002';

DO $t05$
BEGIN
    IF product.evidence_sheet_assurance_level(
        '71000000-0000-0000-0000-000000000001'
    ) <> 'A1' THEN
        RAISE EXCEPTION 'AG-T05 FAIL: owner revise should reduce assurance to A1';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        )
        WHERE issue_code='MISSING_OWNER_APPROVAL'
    ) OR NOT EXISTS (
        SELECT 1
        FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        )
        WHERE issue_code='ACTIVE_OWNER_REVISE'
    ) THEN
        RAISE EXCEPTION 'AG-T05 FAIL: owner revise issues incomplete';
    END IF;

    IF product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'AG-T05 FAIL: owner revise did not block';
    END IF;

    RAISE NOTICE 'AG-T05 PASS — owner revise blocks and reduces assurance to A1';
END
$t05$;

UPDATE product.assurance_record
   SET decision='approved'
 WHERE assurance_uuid='73100000-0000-0000-0000-000000000002';

-- AG-T06 — AI revise/failed blocks and removes A1.
UPDATE product.assurance_record
   SET decision='revise'
 WHERE assurance_uuid='73100000-0000-0000-0000-000000000001';

DO $t06a$
BEGIN
    IF product.evidence_sheet_assurance_level(
        '71000000-0000-0000-0000-000000000001'
    ) <> 'A0' THEN
        RAISE EXCEPTION 'AG-T06a FAIL: AI revise should reduce assurance to A0';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        ) WHERE issue_code='ACTIVE_AI_METHOD_REVISE'
    ) THEN
        RAISE EXCEPTION 'AG-T06a FAIL: ACTIVE_AI_METHOD_REVISE missing';
    END IF;

    RAISE NOTICE 'AG-T06a PASS — AI revise blocks and reduces assurance to A0';
END
$t06a$;

UPDATE product.assurance_record
   SET decision='failed'
 WHERE assurance_uuid='73100000-0000-0000-0000-000000000001';

DO $t06b$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_sheet_publication_issues(
            '71000000-0000-0000-0000-000000000001'
        ) WHERE issue_code='ACTIVE_AI_METHOD_FAILURE'
    ) THEN
        RAISE EXCEPTION 'AG-T06b FAIL: ACTIVE_AI_METHOD_FAILURE missing';
    END IF;

    IF product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) THEN
        RAISE EXCEPTION 'AG-T06b FAIL: failed AI verification did not block';
    END IF;

    RAISE NOTICE 'AG-T06b PASS — failed AI verification blocks publication';
END
$t06b$;

UPDATE product.assurance_record
   SET decision='passed'
 WHERE assurance_uuid='73100000-0000-0000-0000-000000000001';

-- AG-T07 — constraints prevent false role inflation.
DO $t07$
DECLARE caught_owner boolean:=false;
DECLARE caught_ai boolean:=false;
DECLARE caught_expert boolean:=false;
BEGIN
    BEGIN
        INSERT INTO product.assurance_record(
            assurance_uuid,product_version_uuid,assurance_type,
            actor,actor_type,independent_flag,decision,status
        ) VALUES (
            '73200000-0000-0000-0000-000000000011',
            '71000000-0000-0000-0000-000000000001',
            'expert_independent_review',
            'OWNER_AS_EXPERT_TEST',
            'owner',
            true,
            'approved',
            'superseded'
        );
    EXCEPTION WHEN check_violation THEN
        caught_owner:=true;
    END;

    BEGIN
        INSERT INTO product.assurance_record(
            assurance_uuid,product_version_uuid,assurance_type,
            actor,actor_type,independent_flag,decision,status
        ) VALUES (
            '73200000-0000-0000-0000-000000000012',
            '71000000-0000-0000-0000-000000000001',
            'ai_methodological_verification',
            'AI_INDEPENDENCE_TEST',
            'ai_system',
            true,
            'passed',
            'superseded'
        );
    EXCEPTION WHEN check_violation THEN
        caught_ai:=true;
    END;

    BEGIN
        INSERT INTO product.assurance_record(
            assurance_uuid,product_version_uuid,assurance_type,
            actor,actor_type,independent_flag,decision,status
        ) VALUES (
            '73200000-0000-0000-0000-000000000013',
            '71000000-0000-0000-0000-000000000001',
            'owner_governance_approval',
            'EXPERT_AS_OWNER_TEST',
            'human_expert',
            false,
            'approved',
            'superseded'
        );
    EXCEPTION WHEN check_violation THEN
        caught_expert:=true;
    END;

    IF NOT (caught_owner AND caught_ai AND caught_expert) THEN
        RAISE EXCEPTION
            'AG-T07 FAIL: assurance role constraints owner %, ai %, expert %',
            caught_owner,caught_ai,caught_expert;
    END IF;

    RAISE NOTICE 'AG-T07 PASS — constraints prevent false role/independence claims';
END
$t07$;

ROLLBACK;
