-- OES Fase 3 — Overview of Reviews adversarial reanalysis tests
-- OV-T27 and OV-T29.

-- OV-T27 — supplemental primary Result in new Overview synthesis is rejected.
BEGIN;

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,
    mime_type,original_filename,created_at,created_by,status
) VALUES
('f9900000-0000-0000-0000-000000001027','analysis_code','fixtures/overview/test-code.R','test-code','sha256','text/plain','test-code.R',TIMESTAMPTZ '2026-10-06 13:10:00-03','overview-test','active'),
('f9900000-0000-0000-0000-000000002027','analysis_dataset','fixtures/overview/test-data.csv','test-data','sha256','text/csv','test-data.csv',TIMESTAMPTZ '2026-10-06 13:10:00-03','overview-test','active');

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f9300000-0000-0000-0000-000000001027','OES-RSLT-2026-001527','Result','overview-test'),
('f9300000-0000-0000-0000-000000002027','OES-SY-2026-001527','Synthesis','overview-test');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('f9310000-0000-0000-0000-000000001027','f9300000-0000-0000-0000-000000001027',1,'current','overview-test','initial','Primary-study Result test'),
('f9310000-0000-0000-0000-000000002027','f9300000-0000-0000-0000-000000002027',1,'current','overview-test','initial','Overview reanalysis test');

INSERT INTO evidence.result(entity_uuid,study_entity_uuid)
VALUES (
    'f9300000-0000-0000-0000-000000001027',
    'f9300000-0000-0000-0000-000000000201'
);

INSERT INTO evidence.result_version(
    version_uuid,entity_uuid,outcome_entity_uuid,estimand,measure,
    reported_value,status
) VALUES (
    'f9310000-0000-0000-0000-000000001027',
    'f9300000-0000-0000-0000-000000001027',
    'f9300000-0000-0000-0000-000000000301',
    'relative effect','risk_ratio','{"value":0.9}'::jsonb,'active'
);

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('f9300000-0000-0000-0000-000000002027');

INSERT INTO synthesis.synthesis_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    outcome_entity_uuid,comparison_payload,timepoint_payload,
    estimand,synthesis_type,synthesis_origin,method,model,
    code_artifact_uuid,analysis_dataset_artifact_uuid,
    result_summary,status,executed_at
) VALUES (
    'f9310000-0000-0000-0000-000000002027',
    'f9300000-0000-0000-0000-000000002027',
    'f9100000-0000-0000-0000-000000000002',
    'f9300000-0000-0000-0000-000000000301',
    '{"intervention":"X","comparator":"control"}'::jsonb,
    '{"label":"test"}'::jsonb,
    'relative effect','meta_analysis','oes_generated',
    'test','random',
    'f9900000-0000-0000-0000-000000001027',
    'f9900000-0000-0000-0000-000000002027',
    '{"value":0.9}'::jsonb,'active',
    TIMESTAMPTZ '2026-10-06 13:11:00-03'
);

INSERT INTO synthesis.contribution(
    synthesis_version_uuid,result_version_uuid,contribution_role,
    included_main_analysis
) VALUES (
    'f9310000-0000-0000-0000-000000002027',
    'f9310000-0000-0000-0000-000000001027',
    'primary',true
);

INSERT INTO product.synthesis_link(
    product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES (
    'f9100000-0000-0000-0000-000000000020',
    'f9310000-0000-0000-0000-000000002027',
    'test',99
);

DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.overview_of_reviews_publication_issues(
              'f9100000-0000-0000-0000-000000000020'
          )
         WHERE issue_code='SUPPLEMENTAL_PRIMARY_STUDY_NOT_SUPPORTED_V01'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T27 FAIL';
    END IF;
END;
$test$;

ROLLBACK;

-- OV-T29 — reanalysis without code/dataset/statistical review closes gate.
BEGIN;

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES (
    'f9300000-0000-0000-0000-000000002029',
    'OES-SY-2026-001529','Synthesis','overview-test'
);

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
    'f9310000-0000-0000-0000-000000002029',
    'f9300000-0000-0000-0000-000000002029',
    1,'current','overview-test','initial',
    'Uncontrolled Overview reanalysis test'
);

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('f9300000-0000-0000-0000-000000002029');

INSERT INTO synthesis.synthesis_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    outcome_entity_uuid,comparison_payload,timepoint_payload,
    estimand,synthesis_type,synthesis_origin,method,model,
    result_summary,status,executed_at
) VALUES (
    'f9310000-0000-0000-0000-000000002029',
    'f9300000-0000-0000-0000-000000002029',
    'f9100000-0000-0000-0000-000000000002',
    'f9300000-0000-0000-0000-000000000301',
    '{"intervention":"X","comparator":"control"}'::jsonb,
    '{"label":"test"}'::jsonb,
    'relative effect','meta_analysis','oes_generated',
    'test','random','{"value":0.8}'::jsonb,
    'active',TIMESTAMPTZ '2026-10-06 13:20:00-03'
);

INSERT INTO product.synthesis_link(
    product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES (
    'f9100000-0000-0000-0000-000000000020',
    'f9310000-0000-0000-0000-000000002029',
    'test',98
);

DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='REANALYSIS_WITHOUT_CODE' AND severity='error'
    ) OR NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='REANALYSIS_WITHOUT_DATASET' AND severity='error'
    ) OR NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='REANALYSIS_WITHOUT_STATISTICAL_REVIEW'
          AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T29 FAIL';
    END IF;
END;
$test$;

ROLLBACK;

SELECT 'OV-T27 + OV-T29 PASS' AS overview_tests_b3_status;
