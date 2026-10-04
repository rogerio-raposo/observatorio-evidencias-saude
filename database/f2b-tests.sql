-- OES GATE F2-B runtime tests T03-T13 and T16-T19
-- Run after baseline + migrations + f2b-fixtures.sql.
-- All test-only writes are rolled back at the end.

BEGIN;

-- T03 — second current version must fail.
DO $t03$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO core.entity_version(
            version_uuid, entity_uuid, version_no, version_status,
            created_by, change_type, change_note
        ) VALUES (
            '90000000-0000-0000-0000-000000000301',
            '00000000-0000-0000-0000-000000000006',
            2,'current','f2b','test','T03'
        );
    EXCEPTION WHEN unique_violation THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T03 FAIL: second current version accepted'; END IF;
    RAISE NOTICE 'T03 PASS — current uniqueness enforced';
END
$t03$;

-- T04 — cross-entity supersession must fail.
DO $t04$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO core.entity_version(
            version_uuid, entity_uuid, version_no, version_status,
            supersedes_version_uuid, created_by, change_type
        ) VALUES (
            '90000000-0000-0000-0000-000000000401',
            '00000000-0000-0000-0000-000000000006',
            2,'draft',
            '10000000-0000-0000-0000-000000000004',
            'f2b','test'
        );
    EXCEPTION WHEN foreign_key_violation THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T04 FAIL: cross-entity supersession accepted'; END IF;
    RAISE NOTICE 'T04 PASS — supersession constrained to same entity';
END
$t04$;

-- T05 — incompatible subtype must fail.
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('90000000-0000-0000-0000-000000000500','OES-T05-WRONG','Report','f2b');

DO $t05$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO evidence.study(entity_uuid)
        VALUES ('90000000-0000-0000-0000-000000000500');
    EXCEPTION WHEN raise_exception THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T05 FAIL: incompatible subtype accepted'; END IF;
    RAISE NOTICE 'T05 PASS — subtype integrity enforced';
END
$t05$;

-- T06 — FK to nonexistent ResultVersion must fail.
DO $t06$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO synthesis.contribution(
            synthesis_version_uuid, result_version_uuid, contribution_role
        ) VALUES (
            '10000000-0000-0000-0000-000000000007',
            'ffffffff-ffff-ffff-ffff-ffffffffffff',
            'test'
        );
    EXCEPTION WHEN foreign_key_violation THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T06 FAIL: orphan contribution accepted'; END IF;
    RAISE NOTICE 'T06 PASS — FK integrity enforced';
END
$t06$;

-- T07/T08 fixture result identity.
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('90000000-0000-0000-0000-000000000700','OES-T07-RESULT','Result','f2b');
INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status, created_by, change_type
) VALUES (
    '90000000-0000-0000-0000-000000000701',
    '90000000-0000-0000-0000-000000000700',
    1,'current','f2b','test'
);
INSERT INTO evidence.result(entity_uuid, study_entity_uuid)
VALUES (
    '90000000-0000-0000-0000-000000000700',
    '00000000-0000-0000-0000-000000000003'
);

-- T07 — Result without reported/derived value must fail.
DO $t07$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO evidence.result_version(
            version_uuid, entity_uuid, outcome_entity_uuid,
            measure, reported_value, derived_value, status
        ) VALUES (
            '90000000-0000-0000-0000-000000000701',
            '90000000-0000-0000-0000-000000000700',
            '00000000-0000-0000-0000-000000000005',
            'risk_ratio',NULL,NULL,'active'
        );
    EXCEPTION WHEN check_violation THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T07 FAIL: valueless Result accepted'; END IF;
    RAISE NOTICE 'T07 PASS — Result value invariant enforced';
END
$t07$;

-- T08 — inverted CI must fail.
INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status, created_by, change_type
) VALUES (
    '90000000-0000-0000-0000-000000000802',
    '90000000-0000-0000-0000-000000000700',
    2,'draft','f2b','test'
);

DO $t08$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO evidence.result_version(
            version_uuid, entity_uuid, outcome_entity_uuid,
            measure, reported_value, ci_lower, ci_upper, status
        ) VALUES (
            '90000000-0000-0000-0000-000000000802',
            '90000000-0000-0000-0000-000000000700',
            '00000000-0000-0000-0000-000000000005',
            'risk_ratio','{"value":1.1}'::jsonb,1.2,1.0,'active'
        );
    EXCEPTION WHEN check_violation THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T08 FAIL: inverted confidence interval accepted'; END IF;
    RAISE NOTICE 'T08 PASS — confidence interval invariant enforced';
END
$t08$;

-- T09 — no_evidence cannot carry final certainty.
INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status, created_by, change_type
) VALUES (
    '90000000-0000-0000-0000-000000000902',
    '00000000-0000-0000-0000-000000000008',
    99,'draft','f2b','test'
);

DO $t09$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO appraisal.certainty_assessment_version(
            version_uuid, entity_uuid, investigation_version_uuid,
            framework, final_level, evidence_state, assessment_date, status
        ) VALUES (
            '90000000-0000-0000-0000-000000000902',
            '00000000-0000-0000-0000-000000000008',
            '10000000-0000-0000-0000-000000000002',
            'GRADE','low','no_evidence',DATE '2026-10-04','active'
        );
    EXCEPTION WHEN check_violation THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T09 FAIL: no_evidence accepted with final_level'; END IF;
    RAISE NOTICE 'T09 PASS — no-evidence rule enforced';
END
$t09$;

-- T10 — complete v1 -> v2 chain.
UPDATE core.entity_version
SET version_status='superseded', valid_to=CURRENT_TIMESTAMP
WHERE version_uuid IN (
 '10000000-0000-0000-0000-000000000006',
 '10000000-0000-0000-0000-000000000007',
 '10000000-0000-0000-0000-000000000008',
 '10000000-0000-0000-0000-000000000009'
);

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,supersedes_version_uuid,
 created_by,change_type,change_note
) VALUES
('91000000-0000-0000-0000-000000000006','00000000-0000-0000-0000-000000000006',2,'current','10000000-0000-0000-0000-000000000006','f2b','update','T10'),
('91000000-0000-0000-0000-000000000007','00000000-0000-0000-0000-000000000007',2,'current','10000000-0000-0000-0000-000000000007','f2b','update','T10'),
('91000000-0000-0000-0000-000000000008','00000000-0000-0000-0000-000000000008',2,'current','10000000-0000-0000-0000-000000000008','f2b','update','T10'),
('91000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000009',2,'current','10000000-0000-0000-0000-000000000009','f2b','update','T10');

INSERT INTO evidence.result_version(
 version_uuid,entity_uuid,outcome_entity_uuid,timepoint_value,timepoint_unit,
 estimand,measure,reported_value,ci_lower,ci_upper,status
) VALUES (
 '91000000-0000-0000-0000-000000000006',
 '00000000-0000-0000-0000-000000000006',
 '00000000-0000-0000-0000-000000000005',
 30,'day','treatment_effect','risk_ratio',
 '{"value":0.78}'::jsonb,0.63,0.97,'active'
);

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
 estimand,synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES (
 '91000000-0000-0000-0000-000000000007',
 '00000000-0000-0000-0000-000000000007',
 '10000000-0000-0000-0000-000000000002',
 '00000000-0000-0000-0000-000000000005',
 'treatment_effect','pairwise_meta_analysis','new_calculation',
 'inverse_variance','random_effects',
 '{"effect":0.78,"lower":0.63,"upper":0.97}'::jsonb,
 'active',CURRENT_TIMESTAMP
);

INSERT INTO synthesis.contribution(
 synthesis_version_uuid,result_version_uuid,contribution_role,included_main_analysis
) VALUES (
 '91000000-0000-0000-0000-000000000007',
 '91000000-0000-0000-0000-000000000006',
 'main',true
);

INSERT INTO appraisal.certainty_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,
 outcome_entity_uuid,framework,framework_version,initial_level,final_level,
 evidence_state,assessment_date,status
) VALUES (
 '91000000-0000-0000-0000-000000000008',
 '00000000-0000-0000-0000-000000000008',
 '10000000-0000-0000-0000-000000000002',
 '91000000-0000-0000-0000-000000000007',
 '00000000-0000-0000-0000-000000000005',
 'GRADE','f2b','high','moderate','evidence_available',DATE '2026-10-04','active'
);

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,
 evidence_cutoff_date,status,conclusion_text
) VALUES (
 '91000000-0000-0000-0000-000000000009',
 '00000000-0000-0000-0000-000000000009',
 'evidence_sheet','Ficha F2-B v2','internal_validation',
 DATE '2026-10-04','draft','Conclusão v2.'
);

INSERT INTO product.investigation_link(product_version_uuid,investigation_version_uuid,role,sequence_no)
VALUES ('91000000-0000-0000-0000-000000000009','10000000-0000-0000-0000-000000000002','primary',1);
INSERT INTO product.synthesis_link(product_version_uuid,synthesis_version_uuid,role,sequence_no)
VALUES ('91000000-0000-0000-0000-000000000009','91000000-0000-0000-0000-000000000007','primary',1);
INSERT INTO product.certainty_link(product_version_uuid,certainty_assessment_version_uuid,role,sequence_no)
VALUES ('91000000-0000-0000-0000-000000000009','91000000-0000-0000-0000-000000000008','primary',1);

DO $t10$
DECLARE bad integer;
BEGIN
    SELECT count(*) INTO bad
    FROM core.entity_version
    WHERE entity_uuid IN (
      '00000000-0000-0000-0000-000000000006',
      '00000000-0000-0000-0000-000000000007',
      '00000000-0000-0000-0000-000000000008',
      '00000000-0000-0000-0000-000000000009'
    ) AND version_status='current';
    IF bad <> 4 THEN RAISE EXCEPTION 'T10 FAIL: expected four current v2 records, got %', bad; END IF;

    IF NOT EXISTS (
      SELECT 1 FROM product.certainty_link
      WHERE product_version_uuid='10000000-0000-0000-0000-000000000009'
        AND certainty_assessment_version_uuid='10000000-0000-0000-0000-000000000008'
    ) THEN RAISE EXCEPTION 'T10 FAIL: historical product v1 link lost'; END IF;

    IF NOT EXISTS (
      SELECT 1 FROM product.certainty_link
      WHERE product_version_uuid='91000000-0000-0000-0000-000000000009'
        AND certainty_assessment_version_uuid='91000000-0000-0000-0000-000000000008'
    ) THEN RAISE EXCEPTION 'T10 FAIL: product v2 not linked to certainty v2'; END IF;

    RAISE NOTICE 'T10 PASS — version chain preserves history and current state';
END
$t10$;

-- T11 — provenance correction must preserve history and reject material UPDATE.
DO $t11a$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        UPDATE provenance.record
           SET source_value='{"tampered":true}'::jsonb
         WHERE provenance_uuid='30000000-0000-0000-0000-000000000001';
    EXCEPTION WHEN raise_exception THEN
        caught := true;
    END;
    IF NOT caught THEN RAISE EXCEPTION 'T11 FAIL: destructive provenance UPDATE accepted'; END IF;
    RAISE NOTICE 'T11a PASS — material provenance UPDATE blocked';
END
$t11a$;

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,actor,supersedes_provenance_uuid
) VALUES (
 '30000000-0000-0000-0000-000000000002',
 '10000000-0000-0000-0000-000000000006',
 '/reported_value',
 '10000000-0000-0000-0000-000000000004',
 'Table 2 corrected','{"value":0.79}'::jsonb,
 'manual_correction','f2b',
 '30000000-0000-0000-0000-000000000001'
);

UPDATE provenance.record
SET status='superseded'
WHERE provenance_uuid='30000000-0000-0000-0000-000000000001';

DO $t11b$
BEGIN
    IF (SELECT status FROM provenance.record
        WHERE provenance_uuid='30000000-0000-0000-0000-000000000001') <> 'superseded'
       OR NOT EXISTS (
          SELECT 1 FROM provenance.record
          WHERE provenance_uuid='30000000-0000-0000-0000-000000000002'
            AND supersedes_provenance_uuid='30000000-0000-0000-0000-000000000001'
            AND source_value='{"value":0.79}'::jsonb
       )
    THEN RAISE EXCEPTION 'T11 FAIL: provenance supersession chain invalid'; END IF;
    RAISE NOTICE 'T11b PASS — provenance correction preserves prior record';
END
$t11b$;

-- T12 — canonical lineage and dependency projection.
DO $t12$
DECLARE canonical_count integer; edge_count integer; max_depth integer;
BEGIN
    SELECT count(*) INTO canonical_count
    FROM product.product_version pv
    JOIN product.certainty_link pcl ON pcl.product_version_uuid=pv.version_uuid
    JOIN appraisal.certainty_assessment_version cav
      ON cav.version_uuid=pcl.certainty_assessment_version_uuid
    JOIN synthesis.synthesis_version sv ON sv.version_uuid=cav.synthesis_version_uuid
    JOIN synthesis.contribution sc ON sc.synthesis_version_uuid=sv.version_uuid
    JOIN evidence.result_version rv ON rv.version_uuid=sc.result_version_uuid
    JOIN evidence.result_source rs ON rs.result_version_uuid=rv.version_uuid
    WHERE pv.version_uuid='10000000-0000-0000-0000-000000000009'
      AND rs.report_version_uuid='10000000-0000-0000-0000-000000000004';

    WITH RECURSIVE impact AS (
      SELECT source_version_uuid,target_version_uuid,1 AS depth
      FROM provenance.dependency_edge
      WHERE source_version_uuid='10000000-0000-0000-0000-000000000004'
      UNION ALL
      SELECT d.source_version_uuid,d.target_version_uuid,i.depth+1
      FROM provenance.dependency_edge d
      JOIN impact i ON d.source_version_uuid=i.target_version_uuid
      WHERE i.depth < 10
    )
    SELECT count(*), max(depth) INTO edge_count,max_depth FROM impact;

    IF canonical_count <> 1 OR edge_count <> 4 OR max_depth <> 4 THEN
      RAISE EXCEPTION 'T12 FAIL: canonical %, edges %, depth %',
        canonical_count,edge_count,max_depth;
    END IF;
    RAISE NOTICE 'T12 PASS — canonical and projected lineage reconstruct Report -> Product';
END
$t12$;

-- T13 — rollback/subtransaction.
DO $t13$
DECLARE marker uuid := '90000000-0000-0000-0000-000000001301';
BEGIN
    BEGIN
        INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
        VALUES (marker,'OES-T13-MARKER','Study','f2b');
        INSERT INTO evidence.study(entity_uuid) VALUES (marker);
        INSERT INTO evidence.study(entity_uuid) VALUES (marker); -- duplicate PK
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;

    IF EXISTS (SELECT 1 FROM core.entity WHERE entity_uuid=marker) THEN
        RAISE EXCEPTION 'T13 FAIL: partial subtransaction state remained';
    END IF;
    RAISE NOTICE 'T13 PASS — failed multi-step block rolled back atomically';
END
$t13$;

-- T16 — screening targets and exclusion reason.
INSERT INTO investigation.screening_decision(
 screening_uuid,oes_screening_id,investigation_version_uuid,
 target_entity_uuid,stage,reviewer,decision
) VALUES
('90000000-0000-0000-0000-000000001601','OES-T16-REPORT','10000000-0000-0000-0000-000000000002',
 '00000000-0000-0000-0000-000000000004','title_abstract','f2b','include'),
('90000000-0000-0000-0000-000000001602','OES-T16-STUDY','10000000-0000-0000-0000-000000000002',
 '00000000-0000-0000-0000-000000000003','study_level','f2b','include');

DO $t16$
DECLARE invalid_target boolean:=false; missing_reason boolean:=false;
BEGIN
    BEGIN
      INSERT INTO investigation.screening_decision(
       screening_uuid,oes_screening_id,investigation_version_uuid,
       target_entity_uuid,stage,reviewer,decision
      ) VALUES (
       '90000000-0000-0000-0000-000000001603','OES-T16-RESULT',
       '10000000-0000-0000-0000-000000000002',
       '00000000-0000-0000-0000-000000000006',
       'full_text','f2b','include'
      );
    EXCEPTION WHEN raise_exception THEN invalid_target:=true; END;

    BEGIN
      INSERT INTO investigation.screening_decision(
       screening_uuid,oes_screening_id,investigation_version_uuid,
       target_entity_uuid,stage,reviewer,decision,exclusion_reason
      ) VALUES (
       '90000000-0000-0000-0000-000000001604','OES-T16-NOREASON',
       '10000000-0000-0000-0000-000000000002',
       '00000000-0000-0000-0000-000000000004',
       'full_text','f2b','exclude',NULL
      );
    EXCEPTION WHEN check_violation THEN missing_reason:=true; END;

    IF NOT invalid_target OR NOT missing_reason THEN
      RAISE EXCEPTION 'T16 FAIL: invalid_target %, missing_reason %',invalid_target,missing_reason;
    END IF;
    RAISE NOTICE 'T16 PASS — screening target and exclusion rules enforced';
END
$t16$;

-- T17 — RiskAssessment target and identity types.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('90000000-0000-0000-0000-000000001710','OES-T17-RB-ST','RiskAssessment','f2b'),
('90000000-0000-0000-0000-000000001711','OES-T17-RB-RS','RiskAssessment','f2b'),
('90000000-0000-0000-0000-000000001712','OES-T17-RB-RP','RiskAssessment','f2b'),
('90000000-0000-0000-0000-000000001713','OES-T17-RB-BAD','RiskAssessment','f2b'),
('90000000-0000-0000-0000-000000001714','OES-T17-WRONGTYPE','Study','f2b');

INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type) VALUES
('90000000-0000-0000-0000-000000001720','90000000-0000-0000-0000-000000001710',1,'current','f2b','test'),
('90000000-0000-0000-0000-000000001721','90000000-0000-0000-0000-000000001711',1,'current','f2b','test'),
('90000000-0000-0000-0000-000000001722','90000000-0000-0000-0000-000000001712',1,'current','f2b','test'),
('90000000-0000-0000-0000-000000001723','90000000-0000-0000-0000-000000001713',1,'current','f2b','test');

INSERT INTO appraisal.risk_assessment(entity_uuid) VALUES
('90000000-0000-0000-0000-000000001710'),
('90000000-0000-0000-0000-000000001711'),
('90000000-0000-0000-0000-000000001712'),
('90000000-0000-0000-0000-000000001713');

INSERT INTO appraisal.risk_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,framework,
 target_entity_uuid,assessor,assessment_date,status
) VALUES
('90000000-0000-0000-0000-000000001720','90000000-0000-0000-0000-000000001710',
 '10000000-0000-0000-0000-000000000002','TEST',
 '00000000-0000-0000-0000-000000000003','f2b',DATE '2026-10-04','active'),
('90000000-0000-0000-0000-000000001721','90000000-0000-0000-0000-000000001711',
 '10000000-0000-0000-0000-000000000002','TEST',
 '00000000-0000-0000-0000-000000000006','f2b',DATE '2026-10-04','active'),
('90000000-0000-0000-0000-000000001722','90000000-0000-0000-0000-000000001712',
 '10000000-0000-0000-0000-000000000002','TEST',
 '00000000-0000-0000-0000-000000000004','f2b',DATE '2026-10-04','active');

DO $t17$
DECLARE bad_target boolean:=false; bad_identity boolean:=false;
BEGIN
    BEGIN
      INSERT INTO appraisal.risk_assessment_version(
       version_uuid,entity_uuid,investigation_version_uuid,framework,
       target_entity_uuid,assessor,assessment_date,status
      ) VALUES (
       '90000000-0000-0000-0000-000000001723',
       '90000000-0000-0000-0000-000000001713',
       '10000000-0000-0000-0000-000000000002','TEST',
       '00000000-0000-0000-0000-000000000009',
       'f2b',DATE '2026-10-04','active'
      );
    EXCEPTION WHEN raise_exception THEN bad_target:=true; END;

    BEGIN
      INSERT INTO appraisal.risk_assessment(entity_uuid)
      VALUES ('90000000-0000-0000-0000-000000001714');
    EXCEPTION WHEN raise_exception THEN bad_identity:=true; END;

    IF NOT bad_target OR NOT bad_identity THEN
      RAISE EXCEPTION 'T17 FAIL: bad_target %, bad_identity %',bad_target,bad_identity;
    END IF;
    RAISE NOTICE 'T17 PASS — RiskAssessment identity/target integrity enforced';
END
$t17$;

-- T18 — dedup preserves both SearchHits and raw payloads.
DO $t18$
DECLARE hit_count integer; payload_count integer;
BEGIN
    SELECT count(*), count(raw_payload)
      INTO hit_count,payload_count
    FROM investigation.search_hit
    WHERE dedup_cluster_uuid='41000000-0000-0000-0000-000000000001';

    IF hit_count <> 2 OR payload_count <> 2 THEN
      RAISE EXCEPTION 'T18 FAIL: hits %, payloads %',hit_count,payload_count;
    END IF;
    RAISE NOTICE 'T18 PASS — dedup cluster preserves raw SearchHits';
END
$t18$;

-- T19 — full Search -> Screening -> Report/Study -> Result -> Synthesis -> Certainty -> Product chain.
DO $t19$
DECLARE chain_count integer;
BEGIN
    SELECT count(*) INTO chain_count
    FROM investigation.search_hit sh
    JOIN evidence.study_report_link srl
      ON srl.report_entity_uuid=sh.report_entity_uuid
    JOIN evidence.result r
      ON r.study_entity_uuid=srl.study_entity_uuid
    JOIN evidence.result_version rv
      ON rv.entity_uuid=r.entity_uuid
     AND rv.version_uuid='10000000-0000-0000-0000-000000000006'
    JOIN synthesis.contribution sc
      ON sc.result_version_uuid=rv.version_uuid
    JOIN synthesis.synthesis_version sv
      ON sv.version_uuid=sc.synthesis_version_uuid
    JOIN appraisal.certainty_assessment_version cav
      ON cav.synthesis_version_uuid=sv.version_uuid
    JOIN product.certainty_link pcl
      ON pcl.certainty_assessment_version_uuid=cav.version_uuid
    JOIN investigation.screening_decision sd
      ON sd.investigation_version_uuid=sv.investigation_version_uuid
     AND sd.target_entity_uuid=sh.report_entity_uuid
     AND sd.decision='include'
    WHERE sh.search_uuid='40000000-0000-0000-0000-000000000001'
      AND sv.version_uuid='10000000-0000-0000-0000-000000000007';

    IF chain_count < 1 THEN
      RAISE EXCEPTION 'T19 FAIL: end-to-end chain not reconstructible';
    END IF;
    RAISE NOTICE 'T19 PASS — Search-to-Product chain reconstructible';
END
$t19$;

ROLLBACK;
