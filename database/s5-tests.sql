-- OES PoC-S5 runtime tests S5-T02 through S5-T15
-- Run after baseline + 002 + 003 + 004 + 005 + base/S4/S5 fixtures.

BEGIN;

-- S5-T02 — valid NMA Results use groups from their own Study.
DO $t02$
DECLARE bad integer;
BEGIN
    SELECT count(*) INTO bad
    FROM evidence.result_version rv
    JOIN evidence.result r ON r.entity_uuid=rv.entity_uuid
    LEFT JOIN evidence.study_group ga ON ga.entity_uuid=rv.group_a_entity_uuid
    LEFT JOIN evidence.study_group gb ON gb.entity_uuid=rv.group_b_entity_uuid
    WHERE rv.version_uuid IN (
      '61000000-0000-0000-0000-000000000007',
      '61000000-0000-0000-0000-000000000008'
    )
      AND (
        ga.study_entity_uuid IS DISTINCT FROM r.study_entity_uuid
        OR gb.study_entity_uuid IS DISTINCT FROM r.study_entity_uuid
      );

    IF bad <> 0 THEN RAISE EXCEPTION 'S5-T02 FAIL: % NMA Results have cross-study groups',bad; END IF;
    RAISE NOTICE 'S5-T02 PASS — NMA Result groups belong to their Study';
END
$t02$;

-- S5-T03 — cross-study group reference must fail.
INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type
) VALUES (
 '69000000-0000-0000-0000-000000000003',
 '60000000-0000-0000-0000-000000000007',
 99,'draft','s5','test'
);

DO $t03$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
      INSERT INTO evidence.result_version(
        version_uuid,entity_uuid,outcome_entity_uuid,
        group_a_entity_uuid,group_b_entity_uuid,
        estimand,measure,reported_value,status
      ) VALUES (
        '69000000-0000-0000-0000-000000000003',
        '60000000-0000-0000-0000-000000000007',
        '00000000-0000-0000-0000-000000000005',
        '60000000-0000-0000-0000-000000000003',
        '60000000-0000-0000-0000-000000000004',
        'treatment_effect','risk_ratio','{"value":1.0}'::jsonb,'test'
      );
    EXCEPTION WHEN raise_exception THEN caught:=true; END;

    IF NOT caught THEN RAISE EXCEPTION 'S5-T03 FAIL: cross-study groups accepted'; END IF;
    RAISE NOTICE 'S5-T03 PASS — cross-study group reference rejected';
END
$t03$;

-- S5-T04 — NMA structural coverage.
DO $t04$
DECLARE nodes integer; mappings integer; contrasts integer; studies integer;
BEGIN
    SELECT count(*) INTO nodes
    FROM synthesis.node
    WHERE synthesis_entity_uuid='60000000-0000-0000-0000-000000000009';

    SELECT count(*) INTO mappings
    FROM synthesis.node_mapping nm
    JOIN synthesis.node_version nv ON nv.version_uuid=nm.synthesis_node_version_uuid
    JOIN synthesis.node n ON n.entity_uuid=nv.entity_uuid
    WHERE n.synthesis_entity_uuid='60000000-0000-0000-0000-000000000009';

    SELECT count(*) INTO contrasts
    FROM synthesis.contrast
    WHERE synthesis_version_uuid='61000000-0000-0000-0000-000000000009';

    SELECT count(DISTINCT r.study_entity_uuid) INTO studies
    FROM synthesis.contribution c
    JOIN evidence.result_version rv ON rv.version_uuid=c.result_version_uuid
    JOIN evidence.result r ON r.entity_uuid=rv.entity_uuid
    WHERE c.synthesis_version_uuid='61000000-0000-0000-0000-000000000009';

    IF nodes <> 3 OR mappings <> 4 OR contrasts <> 3 OR studies <> 2 THEN
      RAISE EXCEPTION 'S5-T04 FAIL: nodes %, mappings %, contrasts %, studies %',
        nodes,mappings,contrasts,studies;
    END IF;

    RAISE NOTICE 'S5-T04 PASS — NMA nodes %, mappings %, contrasts %, studies %',
      nodes,mappings,contrasts,studies;
END
$t04$;

-- S5-T05 — contrast cannot mix nodes from another Synthesis.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('69000000-0000-0000-0000-000000000005','OES-S5-T05-NODE','SynthesisNode','s5');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type
) VALUES (
 '69100000-0000-0000-0000-000000000005',
 '69000000-0000-0000-0000-000000000005',
 1,'current','s5','test'
);

INSERT INTO synthesis.node(entity_uuid,synthesis_entity_uuid)
VALUES (
 '69000000-0000-0000-0000-000000000005',
 '60000000-0000-0000-0000-000000000028'
);

INSERT INTO synthesis.node_version(version_uuid,entity_uuid,label,status)
VALUES (
 '69100000-0000-0000-0000-000000000005',
 '69000000-0000-0000-0000-000000000005',
 'Foreign node','active'
);

DO $t05$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
      INSERT INTO synthesis.contrast(
        contrast_uuid,synthesis_version_uuid,
        node_a_version_uuid,node_b_version_uuid,contrast_type,status
      ) VALUES (
        '69200000-0000-0000-0000-000000000005',
        '61000000-0000-0000-0000-000000000009',
        '61000000-0000-0000-0000-000000000010',
        '69100000-0000-0000-0000-000000000005',
        'invalid_cross_synthesis','active'
      );
    EXCEPTION WHEN raise_exception THEN caught:=true; END;

    IF NOT caught THEN RAISE EXCEPTION 'S5-T05 FAIL: cross-synthesis contrast accepted'; END IF;
    RAISE NOTICE 'S5-T05 PASS — contrast node/synthesis integrity enforced';
END
$t05$;

-- Helper pattern: recursive dependency path checks.

-- S5-T06 — NMA Report reaches NMA Product.
DO $t06$
DECLARE n integer;
BEGIN
    WITH RECURSIVE chain AS (
      SELECT target_version_uuid,1 AS depth,
             ARRAY[source_version_uuid,target_version_uuid]::uuid[] AS path
      FROM provenance.dependency_edge
      WHERE source_version_uuid='61000000-0000-0000-0000-000000000005'
        AND status='active'
      UNION ALL
      SELECT d.target_version_uuid,c.depth+1,c.path||d.target_version_uuid
      FROM chain c
      JOIN provenance.dependency_edge d
        ON d.source_version_uuid=c.target_version_uuid
       AND d.status='active'
      WHERE c.depth < 16 AND NOT d.target_version_uuid=ANY(c.path)
    )
    SELECT count(*) INTO n FROM chain
    WHERE target_version_uuid='61000000-0000-0000-0000-000000000014';

    IF n < 1 THEN RAISE EXCEPTION 'S5-T06 FAIL: NMA lineage does not reach Product'; END IF;
    RAISE NOTICE 'S5-T06 PASS — NMA lineage reaches Product';
END
$t06$;

-- S5-T07 — PredictionModel preserves v1 and current v2.
DO $t07$
DECLARE total_n integer; current_n integer;
BEGIN
    SELECT count(*),count(*) FILTER (WHERE version_status='current')
      INTO total_n,current_n
    FROM core.entity_version
    WHERE entity_uuid='60000000-0000-0000-0000-000000000024';

    IF total_n <> 2 OR current_n <> 1 OR NOT EXISTS (
      SELECT 1 FROM core.entity_version
      WHERE version_uuid='62000000-0000-0000-0000-000000000024'
        AND supersedes_version_uuid='61000000-0000-0000-0000-000000000024'
        AND version_status='current'
    ) THEN
      RAISE EXCEPTION 'S5-T07 FAIL: total %, current %',total_n,current_n;
    END IF;

    RAISE NOTICE 'S5-T07 PASS — PredictionModel v1/v2 history preserved';
END
$t07$;

-- S5-T08 — development and external validation roles coexist.
DO $t08$
DECLARE n integer;
BEGIN
    SELECT count(DISTINCT role) INTO n
    FROM evidence.prediction_model_study_role
    WHERE prediction_model_entity_uuid='60000000-0000-0000-0000-000000000024'
      AND role IN ('development','external_validation');

    IF n <> 2 THEN RAISE EXCEPTION 'S5-T08 FAIL: expected two model roles, got %',n; END IF;
    RAISE NOTICE 'S5-T08 PASS — development and external validation roles represented';
END
$t08$;

-- S5-T09 — prediction performance Results from two distinct Studies.
DO $t09$
DECLARE n integer;
BEGIN
    SELECT count(DISTINCT study_entity_uuid) INTO n
    FROM evidence.result
    WHERE prediction_model_entity_uuid='60000000-0000-0000-0000-000000000024';

    IF n <> 2 THEN RAISE EXCEPTION 'S5-T09 FAIL: prediction Result studies %',n; END IF;
    RAISE NOTICE 'S5-T09 PASS — PredictionModel has performance Results from % studies',n;
END
$t09$;

-- S5-T10 — validation Report reaches prediction Product.
DO $t10$
DECLARE n integer;
BEGIN
    WITH RECURSIVE chain AS (
      SELECT target_version_uuid,1 AS depth,
             ARRAY[source_version_uuid,target_version_uuid]::uuid[] AS path
      FROM provenance.dependency_edge
      WHERE source_version_uuid='61000000-0000-0000-0000-000000000023'
        AND status='active'
      UNION ALL
      SELECT d.target_version_uuid,c.depth+1,c.path||d.target_version_uuid
      FROM chain c
      JOIN provenance.dependency_edge d
        ON d.source_version_uuid=c.target_version_uuid
       AND d.status='active'
      WHERE c.depth < 16 AND NOT d.target_version_uuid=ANY(c.path)
    )
    SELECT count(*) INTO n FROM chain
    WHERE target_version_uuid='61000000-0000-0000-0000-000000000030';

    IF n < 1 THEN RAISE EXCEPTION 'S5-T10 FAIL: prediction lineage does not reach Product'; END IF;
    RAISE NOTICE 'S5-T10 PASS — prediction lineage reaches Product';
END
$t10$;

-- S5-T11 — CERQual certainty without ReviewFinding must fail.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('69000000-0000-0000-0000-000000000011','OES-S5-T11-CE','CertaintyAssessment','s5');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type
) VALUES (
 '69100000-0000-0000-0000-000000000011',
 '69000000-0000-0000-0000-000000000011',
 1,'current','s5','test'
);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('69000000-0000-0000-0000-000000000011');

DO $t11$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
      INSERT INTO appraisal.certainty_assessment_version(
        version_uuid,entity_uuid,investigation_version_uuid,
        synthesis_version_uuid,framework,framework_version,
        final_level,evidence_state,assessment_date,status
      ) VALUES (
        '69100000-0000-0000-0000-000000000011',
        '69000000-0000-0000-0000-000000000011',
        '10000000-0000-0000-0000-000000000002',
        '61000000-0000-0000-0000-000000000044',
        'GRADE-CERQual','test','moderate','evidence_available',DATE '2026-10-04','active'
      );
    EXCEPTION WHEN check_violation THEN caught:=true; END;

    IF NOT caught THEN RAISE EXCEPTION 'S5-T11 FAIL: CERQual without ReviewFinding accepted'; END IF;
    RAISE NOTICE 'S5-T11 PASS — CERQual requires ReviewFinding';
END
$t11$;

-- S5-T12 — ReviewFinding has contributions from two Studies.
DO $t12$
DECLARE n integer;
BEGIN
    SELECT count(DISTINCT study_entity_uuid) INTO n
    FROM synthesis.finding_contribution
    WHERE review_finding_version_uuid='61000000-0000-0000-0000-000000000045';

    IF n <> 2 THEN RAISE EXCEPTION 'S5-T12 FAIL: finding study contributions %',n; END IF;
    RAISE NOTICE 'S5-T12 PASS — ReviewFinding supported by % studies',n;
END
$t12$;

-- S5-T13 — CERQual has four components and moderate final confidence.
DO $t13$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
    FROM appraisal.certainty_domain
    WHERE certainty_assessment_version_uuid='61000000-0000-0000-0000-000000000046'
      AND domain_code IN (
        'methodological_limitations','coherence','adequacy','relevance'
      );

    IF n <> 4 OR NOT EXISTS (
      SELECT 1 FROM appraisal.certainty_assessment_version
      WHERE version_uuid='61000000-0000-0000-0000-000000000046'
        AND framework='GRADE-CERQual'
        AND review_finding_version_uuid='61000000-0000-0000-0000-000000000045'
        AND final_level='moderate'
    ) THEN
      RAISE EXCEPTION 'S5-T13 FAIL: CERQual domains % or assessment invalid',n;
    END IF;

    RAISE NOTICE 'S5-T13 PASS — four CERQual components and final confidence represented';
END
$t13$;

-- S5-T14 — qualitative Report reaches CERQual Product.
DO $t14$
DECLARE n integer;
BEGIN
    WITH RECURSIVE chain AS (
      SELECT target_version_uuid,1 AS depth,
             ARRAY[source_version_uuid,target_version_uuid]::uuid[] AS path
      FROM provenance.dependency_edge
      WHERE source_version_uuid='61000000-0000-0000-0000-000000000042'
        AND status='active'
      UNION ALL
      SELECT d.target_version_uuid,c.depth+1,c.path||d.target_version_uuid
      FROM chain c
      JOIN provenance.dependency_edge d
        ON d.source_version_uuid=c.target_version_uuid
       AND d.status='active'
      WHERE c.depth < 16 AND NOT d.target_version_uuid=ANY(c.path)
    )
    SELECT count(*) INTO n FROM chain
    WHERE target_version_uuid='61000000-0000-0000-0000-000000000047';

    IF n < 1 THEN RAISE EXCEPTION 'S5-T14 FAIL: qualitative lineage does not reach Product'; END IF;
    RAISE NOTICE 'S5-T14 PASS — qualitative/CERQual lineage reaches Product';
END
$t14$;

-- S5-T15 — all specialized Products and paths exist.
DO $t15$
DECLARE products integer; linked integer;
BEGIN
    SELECT count(*) INTO products
    FROM product.product_version
    WHERE version_uuid IN (
      '61000000-0000-0000-0000-000000000014',
      '61000000-0000-0000-0000-000000000030',
      '61000000-0000-0000-0000-000000000047'
    );

    SELECT count(*) INTO linked
    FROM product.certainty_link
    WHERE product_version_uuid IN (
      '61000000-0000-0000-0000-000000000014',
      '61000000-0000-0000-0000-000000000030',
      '61000000-0000-0000-0000-000000000047'
    );

    IF products <> 3 OR linked <> 3 THEN
      RAISE EXCEPTION 'S5-T15 FAIL: products %, certainty links %',products,linked;
    END IF;
    RAISE NOTICE 'S5-T15 PASS — all three specialized products reconstructed';
END
$t15$;

ROLLBACK;
