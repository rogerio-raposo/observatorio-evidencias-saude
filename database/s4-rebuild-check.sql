-- OES PoC-S4 rebuild assertions
DO $s4rebuild$
DECLARE rr integer; multi_study integer; impacted integer; products integer;
BEGIN
    SELECT count(*) INTO rr
    FROM evidence.report_relation
    WHERE target_report_entity_uuid='50000000-0000-0000-0000-000000000003';

    SELECT count(DISTINCT r.study_entity_uuid) INTO multi_study
    FROM synthesis.contribution c
    JOIN evidence.result_version rv ON rv.version_uuid=c.result_version_uuid
    JOIN evidence.result r ON r.entity_uuid=rv.entity_uuid
    WHERE c.synthesis_version_uuid='51000000-0000-0000-0000-000000000009'
      AND c.included_main_analysis=true;

    SELECT count(*) INTO impacted
    FROM provenance.report_impact('50000000-0000-0000-0000-000000000003');

    SELECT count(*) INTO products
    FROM product.product_version
    WHERE entity_uuid='50000000-0000-0000-0000-000000000011';

    IF rr <> 2 OR multi_study <> 2 OR impacted < 10 OR products <> 2 THEN
      RAISE EXCEPTION
        'S4-T14 FAIL: relations %, studies %, impacted %, product_versions %',
        rr,multi_study,impacted,products;
    END IF;

    RAISE NOTICE
      'S4-T14 PASS — rebuild reproduced relations %, studies %, impacted %, product_versions %',
      rr,multi_study,impacted,products;
END
$s4rebuild$;
