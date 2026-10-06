-- OES Fase 3 — Evidence Map source-corpus support tests
-- Requires migrations 016–018 + formal synthetic Evidence Map fixture.
-- All identity changes are transactional and rolled back.

-- EMVSC-T01/T02 — a non-systematic Map may own its mapping question while
-- inheriting Search/Screening from source_corpus without duplication.
BEGIN;

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('b4e00000-0000-0000-0000-000000000001','OES-Q-2026-MAP-SRC-T','Question','map-source-test'),
('b4e00000-0000-0000-0000-000000000002','OES-I-2026-MAP-SRC-T','Investigation','map-source-test');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('b4e10000-0000-0000-0000-000000000001','b4e00000-0000-0000-0000-000000000001',1,'current','map-source-test','initial','Synthetic mapping question for source-corpus test'),
('b4e10000-0000-0000-0000-000000000002','b4e00000-0000-0000-0000-000000000002',1,'current','map-source-test','initial','Synthetic mapping investigation for source-corpus test');

INSERT INTO investigation.question(entity_uuid)
VALUES ('b4e00000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload
) VALUES (
    'b4e10000-0000-0000-0000-000000000001',
    'b4e00000-0000-0000-0000-000000000001',
    'Como o corpus sintético se distribui?',
    'Como as unidades do corpus sintético se distribuem no framework de mapeamento?',
    'mapping','PCC','{"fixture":true,"purpose":"source_corpus_test"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('b4e00000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'b4e10000-0000-0000-0000-000000000002',
    'b4e00000-0000-0000-0000-000000000002',
    'b4e00000-0000-0000-0000-000000000001',
    'evidence_mapping','N3','M0',
    'Validate source-corpus inheritance without duplicating Search/Screening.',
    'b4900000-0000-0000-0000-000000000001',
    DATE '2026-10-06',DATE '2026-10-06','completed'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'b4e10000-0000-0000-0000-000000000002',
    'b4e10000-0000-0000-0000-000000000001','primary',1
);

DELETE FROM product.investigation_link
 WHERE product_version_uuid='b4100000-0000-0000-0000-000000000020'
   AND role='primary';

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES
('b4100000-0000-0000-0000-000000000020','b4e10000-0000-0000-0000-000000000002','primary',1),
('b4100000-0000-0000-0000-000000000020','b4100000-0000-0000-0000-000000000002','source_corpus',1);

UPDATE mapping.framework_version
   SET investigation_version_uuid='b4e10000-0000-0000-0000-000000000002',
       mapping_subtype='descriptive_mapping_review',
       coverage_claim='structured_non_exhaustive',
       gap_claim_mode='apparent_only'
 WHERE version_uuid='b4100000-0000-0000-0000-000000000010';

DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');

    IF v#>>'{question,normalized_text}' <>
       'Como as unidades do corpus sintético se distribuem no framework de mapeamento?'
    THEN
        RAISE EXCEPTION 'EMVSC-T01 FAIL — MAP question did not come from primary mapping Investigation';
    END IF;

    IF jsonb_array_length(v->'source_investigations')<>1 THEN
        RAISE EXCEPTION 'EMVSC-T01 FAIL — expected one source_corpus Investigation';
    END IF;

    IF jsonb_array_length(v->'searches')<>2 THEN
        RAISE EXCEPTION 'EMVSC-T01 FAIL — inherited searches were not projected';
    END IF;

    IF EXISTS (
        SELECT 1 FROM jsonb_array_elements(v->'searches') x
         WHERE x->>'investigation_role'<>'source_corpus'
    ) THEN
        RAISE EXCEPTION 'EMVSC-T01 FAIL — inherited search origin not marked source_corpus';
    END IF;

    IF (v#>>'{selection_flow,search_hits}')::integer<>4
       OR (v#>>'{selection_flow,screening_decisions}')::integer<>8
       OR (v#>>'{selection_flow,source_investigation_count}')::integer<>1
    THEN
        RAISE EXCEPTION 'EMVSC-T01 FAIL — inherited selection flow incorrect: %',v->'selection_flow';
    END IF;

    IF (v#>>'{audit,source_corpus_count}')::integer<>1 THEN
        RAISE EXCEPTION 'EMVSC-T01 FAIL — audit source_corpus_count incorrect';
    END IF;
END;
$test$;

DO $test$
BEGIN
    IF NOT product.evidence_map_is_publishable('b4100000-0000-0000-0000-000000000020') THEN
        RAISE EXCEPTION 'EMVSC-T02 FAIL — non-systematic map did not accept completed source_corpus Search: %',
            (SELECT jsonb_agg(to_jsonb(x))
               FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020') x
              WHERE severity='error');
    END IF;
END;
$test$;

-- EMVSC-T03 — source_corpus must NOT satisfy formal/systematic coverage.
UPDATE mapping.framework_version
   SET mapping_subtype='evidence_gap_map',
       coverage_claim='systematic_comprehensive',
       gap_claim_mode='formal_within_scope'
 WHERE version_uuid='b4100000-0000-0000-0000-000000000010';

DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_SEARCH_RECORD'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'EMVSC-T03 FAIL — source_corpus incorrectly bypassed formal primary-Search requirement';
    END IF;

    IF product.evidence_map_is_publishable('b4100000-0000-0000-0000-000000000020') THEN
        RAISE EXCEPTION 'EMVSC-T03 FAIL — formal map became publishable using only source_corpus Search';
    END IF;
END;
$test$;

ROLLBACK;

-- EMVSC-T04 — legacy fixture remains unchanged after rollback.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF v#>>'{question,normalized_text}' <>
       'Quais estudos e sínteses elegíveis ocupam as células intervenção × desfecho no escopo sintético definido?'
       OR jsonb_array_length(v->'source_investigations')<>0
       OR jsonb_array_length(v->'searches')<>2
       OR COALESCE((v#>>'{audit,publishable}')::boolean,false)<>true
    THEN
        RAISE EXCEPTION 'EMVSC-T04 FAIL — legacy fixture changed after source-corpus tests';
    END IF;
END;
$test$;

SELECT 'EMVSC-T01–T04 PASS — source-corpus inheritance preserves map identity without bypassing formal coverage'
AS evidence_map_source_corpus_tests_status;
