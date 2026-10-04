-- OES Fase 3 — Evidence Sheet rebuild assertions
DO $f3rebuild$
DECLARE
    currency_n integer;
    change_n integer;
    review_n integer;
    ok boolean;
BEGIN
    SELECT count(*) INTO currency_n
      FROM product.currency_state
     WHERE product_version_uuid='71000000-0000-0000-0000-000000000001';

    SELECT count(*) INTO change_n
      FROM product.version_change_class
     WHERE product_version_uuid='71000000-0000-0000-0000-000000000001';

    SELECT count(*) INTO review_n
      FROM product.review_record
     WHERE product_version_uuid='71000000-0000-0000-0000-000000000001'
       AND status='active'
       AND decision='approved';

    SELECT product.evidence_sheet_is_publishable(
        '71000000-0000-0000-0000-000000000001'
    ) INTO ok;

    IF currency_n<>1 OR change_n<>2 OR review_n<>1 OR NOT ok THEN
        RAISE EXCEPTION
            'F3-FE-T16 FAIL: currency %, changes %, approved reviews %, publishable %',
            currency_n,change_n,review_n,ok;
    END IF;

    RAISE NOTICE
        'F3-FE-T16 PASS — rebuild currency %, changes %, approved reviews %, publishable %',
        currency_n,change_n,review_n,ok;
END
$f3rebuild$;
