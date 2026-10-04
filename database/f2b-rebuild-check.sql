-- OES F2-B rebuild check after fresh installation.
DO $rebuild$
DECLARE tables integer; views integer; hits integer; chain_count integer;
BEGIN
    SELECT count(*) INTO tables
    FROM information_schema.tables
    WHERE table_schema IN (
      'core','investigation','evidence','synthesis',
      'appraisal','product','provenance','artifact'
    ) AND table_type='BASE TABLE';

    SELECT count(*) INTO views
    FROM information_schema.views
    WHERE table_schema IN ('core','evidence','synthesis','appraisal','product');

    SELECT count(*) INTO hits
    FROM investigation.search_hit
    WHERE dedup_cluster_uuid='41000000-0000-0000-0000-000000000001';

    SELECT count(*) INTO chain_count
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

    IF tables <> 39 OR views <> 5 OR hits <> 2 OR chain_count <> 1 THEN
      RAISE EXCEPTION 'T14 FAIL: tables %, views %, hits %, chain %',
        tables,views,hits,chain_count;
    END IF;
    RAISE NOTICE 'T14 PASS — rebuild from zero reproduced expected state';
END
$rebuild$;
