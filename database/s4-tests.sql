-- OES PoC-S4 runtime tests S4-T02 through S4-T13
-- Run after baseline + 002 + 003 + 004 + f2b-fixtures + s4-fixtures.
-- Test-only writes are rolled back.

BEGIN;

-- S4-T02 — Study A has multiple active Reports.
DO $t02$
DECLARE n integer;
BEGIN
    SELECT count(DISTINCT report_entity_uuid) INTO n
    FROM evidence.study_report_link
    WHERE study_entity_uuid='50000000-0000-0000-0000-000000000001'
      AND status='active';
    IF n < 2 THEN RAISE EXCEPTION 'S4-T02 FAIL: Study A report count %',n; END IF;
    RAISE NOTICE 'S4-T02 PASS — Study A linked to % reports',n;
END
$t02$;

-- S4-T03 — Report X represents multiple Studies.
DO $t03$
DECLARE n integer;
BEGIN
    SELECT count(DISTINCT study_entity_uuid) INTO n
    FROM evidence.study_report_link
    WHERE report_entity_uuid='50000000-0000-0000-0000-000000000003'
      AND status='active';
    IF n < 2 THEN RAISE EXCEPTION 'S4-T03 FAIL: Report X study count %',n; END IF;
    RAISE NOTICE 'S4-T03 PASS — Report X linked to % studies',n;
END
$t03$;

-- S4-T04 — Synthesis v1 combines Results from >=2 distinct Studies.
DO $t04$
DECLARE n integer;
BEGIN
    SELECT count(DISTINCT r.study_entity_uuid) INTO n
    FROM synthesis.contribution c
    JOIN evidence.result_version rv ON rv.version_uuid=c.result_version_uuid
    JOIN evidence.result r ON r.entity_uuid=rv.entity_uuid
    WHERE c.synthesis_version_uuid='51000000-0000-0000-0000-000000000009'
      AND c.included_main_analysis=true;
    IF n < 2 THEN RAISE EXCEPTION 'S4-T04 FAIL: distinct studies %',n; END IF;
    RAISE NOTICE 'S4-T04 PASS — synthesis combines % studies',n;
END
$t04$;

-- S4-T05 — unsupported ReportRelation type must fail.
DO $t05$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
        INSERT INTO evidence.report_relation(
            relation_uuid,source_report_entity_uuid,target_report_entity_uuid,
            relation_type,relation_date
        ) VALUES (
            '59000000-0000-0000-0000-000000000005',
            '50000000-0000-0000-0000-000000000005',
            '50000000-0000-0000-0000-000000000004',
            'invented_relation',DATE '2026-10-04'
        );
    EXCEPTION WHEN check_violation THEN caught:=true; END;
    IF NOT caught THEN RAISE EXCEPTION 'S4-T05 FAIL: invalid relation type accepted'; END IF;
    RAISE NOTICE 'S4-T05 PASS — relation vocabulary enforced';
END
$t05$;

-- S4-T06 — self relation must fail.
DO $t06$
DECLARE caught boolean:=false;
BEGIN
    BEGIN
        INSERT INTO evidence.report_relation(
            relation_uuid,source_report_entity_uuid,target_report_entity_uuid,
            relation_type,relation_date
        ) VALUES (
            '59000000-0000-0000-0000-000000000006',
            '50000000-0000-0000-0000-000000000005',
            '50000000-0000-0000-0000-000000000005',
            'correction_of',DATE '2026-10-04'
        );
    EXCEPTION WHEN check_violation THEN caught:=true; END;
    IF NOT caught THEN RAISE EXCEPTION 'S4-T06 FAIL: report self relation accepted'; END IF;
    RAISE NOTICE 'S4-T06 PASS — report self relation rejected';
END
$t06$;

-- S4-T07 — correction/retraction version chain preserves all Report X versions.
DO $t07$
DECLARE n integer; current_n integer;
BEGIN
    SELECT count(*) INTO n
    FROM core.entity_version
    WHERE entity_uuid='50000000-0000-0000-0000-000000000003';

    SELECT count(*) INTO current_n
    FROM core.entity_version
    WHERE entity_uuid='50000000-0000-0000-0000-000000000003'
      AND version_status='current';

    IF n <> 3 OR current_n <> 1 THEN
      RAISE EXCEPTION 'S4-T07 FAIL: versions %, current %',n,current_n;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM core.entity_version
      WHERE version_uuid='52000000-0000-0000-0000-000000000003'
        AND supersedes_version_uuid='51000000-0000-0000-0000-000000000003'
        AND version_status='superseded'
    ) OR NOT EXISTS (
      SELECT 1 FROM core.entity_version
      WHERE version_uuid='53000000-0000-0000-0000-000000000003'
        AND supersedes_version_uuid='52000000-0000-0000-0000-000000000003'
        AND version_status='current'
    ) THEN
      RAISE EXCEPTION 'S4-T07 FAIL: Report X supersession chain invalid';
    END IF;

    RAISE NOTICE 'S4-T07 PASS — Report X v1→v2→v3 history preserved';
END
$t07$;

-- S4-T08 — current Report X is retracted.
DO $t08$
BEGIN
    IF NOT EXISTS (
      SELECT 1
      FROM evidence.report_version rv
      JOIN core.entity_version ev ON ev.version_uuid=rv.version_uuid
      WHERE rv.version_uuid='53000000-0000-0000-0000-000000000003'
        AND rv.publication_status='retracted'
        AND rv.status='invalidated'
        AND ev.version_status='current'
    ) THEN RAISE EXCEPTION 'S4-T08 FAIL: current Report X not retracted'; END IF;
    RAISE NOTICE 'S4-T08 PASS — retracted state represented on current Report version';
END
$t08$;

-- S4-T09 — correction and retraction relations point to Report X.
DO $t09$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
    FROM evidence.report_relation
    WHERE target_report_entity_uuid='50000000-0000-0000-0000-000000000003'
      AND relation_type IN ('correction_of','retraction_of')
      AND status='active';
    IF n <> 2 THEN RAISE EXCEPTION 'S4-T09 FAIL: expected 2 relations, got %',n; END IF;
    RAISE NOTICE 'S4-T09 PASS — correction and retraction relations preserved';
END
$t09$;

-- S4-T10 — report impact reaches both historical and post-retraction Products.
DO $t10$
DECLARE old_product boolean; new_product boolean; max_depth integer;
BEGIN
    SELECT EXISTS(
      SELECT 1 FROM provenance.report_impact('50000000-0000-0000-0000-000000000003')
      WHERE impacted_version_uuid='51000000-0000-0000-0000-000000000011'
    ) INTO old_product;

    SELECT EXISTS(
      SELECT 1 FROM provenance.report_impact('50000000-0000-0000-0000-000000000003')
      WHERE impacted_version_uuid='52000000-0000-0000-0000-000000000011'
    ) INTO new_product;

    SELECT max(depth) INTO max_depth
    FROM provenance.report_impact('50000000-0000-0000-0000-000000000003');

    IF NOT old_product OR NOT new_product OR max_depth < 4 THEN
      RAISE EXCEPTION 'S4-T10 FAIL: old %, new %, depth %',old_product,new_product,max_depth;
    END IF;
    RAISE NOTICE 'S4-T10 PASS — impact traversal reaches historical/current Products; depth %',max_depth;
END
$t10$;

-- S4-T11 — derived entities have preserved v1 and current v2.
DO $t11$
DECLARE bad integer;
BEGIN
    SELECT count(*) INTO bad
    FROM (
      SELECT entity_uuid,
             count(*) FILTER (WHERE version_status='current') AS current_n,
             count(*) AS total_n
      FROM core.entity_version
      WHERE entity_uuid IN (
        '50000000-0000-0000-0000-000000000007',
        '50000000-0000-0000-0000-000000000008',
        '50000000-0000-0000-0000-000000000009',
        '50000000-0000-0000-0000-000000000010',
        '50000000-0000-0000-0000-000000000011'
      )
      GROUP BY entity_uuid
    ) x
    WHERE current_n <> 1 OR total_n <> 2;

    IF bad <> 0 THEN RAISE EXCEPTION 'S4-T11 FAIL: % entities have invalid version history',bad; END IF;
    RAISE NOTICE 'S4-T11 PASS — Result/Synthesis/Certainty/Product v1/v2 history preserved';
END
$t11$;

-- S4-T12 — no-evidence certainty and Product v2 links are coherent.
DO $t12$
BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM appraisal.certainty_assessment_version
      WHERE version_uuid='52000000-0000-0000-0000-000000000010'
        AND evidence_state='no_evidence'
        AND final_level IS NULL
        AND synthesis_version_uuid='52000000-0000-0000-0000-000000000009'
    ) THEN RAISE EXCEPTION 'S4-T12 FAIL: Certainty v2 invalid'; END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM product.synthesis_link sl
      JOIN product.certainty_link cl
        ON cl.product_version_uuid=sl.product_version_uuid
      WHERE sl.product_version_uuid='52000000-0000-0000-0000-000000000011'
        AND sl.synthesis_version_uuid='52000000-0000-0000-0000-000000000009'
        AND cl.certainty_assessment_version_uuid='52000000-0000-0000-0000-000000000010'
    ) THEN RAISE EXCEPTION 'S4-T12 FAIL: Product v2 links invalid'; END IF;

    RAISE NOTICE 'S4-T12 PASS — post-retraction no-evidence chain coherent';
END
$t12$;

-- S4-T13 — both historical and current dependency chains reconstruct to Product.
DO $t13$
DECLARE old_paths integer; new_paths integer;
BEGIN
    WITH RECURSIVE old_chain AS (
      SELECT target_version_uuid,1 AS depth,
             ARRAY[source_version_uuid,target_version_uuid]::uuid[] AS path
      FROM provenance.dependency_edge
      WHERE source_version_uuid='51000000-0000-0000-0000-000000000003'
        AND status='active'
      UNION ALL
      SELECT d.target_version_uuid,c.depth+1,c.path||d.target_version_uuid
      FROM old_chain c
      JOIN provenance.dependency_edge d
        ON d.source_version_uuid=c.target_version_uuid
       AND d.status='active'
      WHERE c.depth < 16 AND NOT d.target_version_uuid=ANY(c.path)
    )
    SELECT count(*) INTO old_paths
    FROM old_chain
    WHERE target_version_uuid='51000000-0000-0000-0000-000000000011';

    WITH RECURSIVE new_chain AS (
      SELECT target_version_uuid,1 AS depth,
             ARRAY[source_version_uuid,target_version_uuid]::uuid[] AS path
      FROM provenance.dependency_edge
      WHERE source_version_uuid='53000000-0000-0000-0000-000000000003'
        AND status='active'
      UNION ALL
      SELECT d.target_version_uuid,c.depth+1,c.path||d.target_version_uuid
      FROM new_chain c
      JOIN provenance.dependency_edge d
        ON d.source_version_uuid=c.target_version_uuid
       AND d.status='active'
      WHERE c.depth < 16 AND NOT d.target_version_uuid=ANY(c.path)
    )
    SELECT count(*) INTO new_paths
    FROM new_chain
    WHERE target_version_uuid='52000000-0000-0000-0000-000000000011';

    IF old_paths < 1 OR new_paths < 1 THEN
      RAISE EXCEPTION 'S4-T13 FAIL: historical paths %, current paths %',old_paths,new_paths;
    END IF;
    RAISE NOTICE 'S4-T13 PASS — historical and post-retraction lineage coexist';
END
$t13$;

ROLLBACK;
