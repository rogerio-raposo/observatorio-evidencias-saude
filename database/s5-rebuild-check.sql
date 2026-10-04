-- OES PoC-S5 rebuild assertions — S5-T16
DO $s5rebuild$
DECLARE nodes integer; models integer; model_versions integer;
        findings integer; cerqual_domains integer; products integer;
BEGIN
    SELECT count(*) INTO nodes
    FROM synthesis.node
    WHERE synthesis_entity_uuid='60000000-0000-0000-0000-000000000009';

    SELECT count(*) INTO models
    FROM evidence.prediction_model
    WHERE entity_uuid='60000000-0000-0000-0000-000000000024';

    SELECT count(*) INTO model_versions
    FROM evidence.prediction_model_version
    WHERE entity_uuid='60000000-0000-0000-0000-000000000024';

    SELECT count(*) INTO findings
    FROM synthesis.finding_contribution
    WHERE review_finding_version_uuid='61000000-0000-0000-0000-000000000045';

    SELECT count(*) INTO cerqual_domains
    FROM appraisal.certainty_domain
    WHERE certainty_assessment_version_uuid='61000000-0000-0000-0000-000000000046';

    SELECT count(*) INTO products
    FROM product.product_version
    WHERE version_uuid IN (
      '61000000-0000-0000-0000-000000000014',
      '61000000-0000-0000-0000-000000000030',
      '61000000-0000-0000-0000-000000000047'
    );

    IF nodes<>3 OR models<>1 OR model_versions<>2
       OR findings<>2 OR cerqual_domains<>4 OR products<>3 THEN
      RAISE EXCEPTION
        'S5-T16 FAIL: nodes %, models %, model_versions %, findings %, domains %, products %',
        nodes,models,model_versions,findings,cerqual_domains,products;
    END IF;

    RAISE NOTICE
      'S5-T16 PASS — rebuild nodes %, model_versions %, findings %, CERQual domains %, products %',
      nodes,model_versions,findings,cerqual_domains,products;
END
$s5rebuild$;
