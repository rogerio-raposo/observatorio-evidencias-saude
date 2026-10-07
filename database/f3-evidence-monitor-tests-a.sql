-- OES Fase 3 — Evidence Monitor contract tests A
-- Positive semantics. Requires migration 021 + f3-evidence-monitor-fixtures.sql.

-- MON-T01 — formal M2 fixture is A2 and publishable.
DO $t$
DECLARE errs jsonb;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(x)),'[]'::jsonb)
      INTO errs
      FROM product.evidence_monitor_publication_issues(
           'e5100000-0000-0000-0000-000000000005'
      ) x
     WHERE severity='error';

    IF jsonb_array_length(errs)<>0
       OR product.assurance_level(
            'e5100000-0000-0000-0000-000000000005'
          )<>'A2'
       OR NOT product.evidence_monitor_is_publishable(
            'e5100000-0000-0000-0000-000000000005'
          ) THEN
        RAISE EXCEPTION
            'MON-T01 FAIL — M2 fixture expected A2/publishable; errors=%',
            errs;
    END IF;
END;
$t$;

-- MON-T02 — target assurance is not inherited by the Monitor.
DO $t$
BEGIN
    IF product.assurance_level(
           'e5100000-0000-0000-0000-000000000003'
       )<>'A0'
       OR product.assurance_level(
           'e5100000-0000-0000-0000-000000000005'
       )<>'A2' THEN
        RAISE EXCEPTION
            'MON-T02 FAIL — target/Monitor assurance separation lost';
    END IF;
END;
$t$;

-- MON-T03 — baseline cutoff stays fixed while cycles advance surveillance time.
DO $t$
DECLARE baseline date; latest_cutoff date;
BEGIN
    SELECT pv.evidence_cutoff_date INTO baseline
      FROM product.product_version pv
     WHERE pv.version_uuid='e5100000-0000-0000-0000-000000000005';

    SELECT max(mc.window_end_date) INTO latest_cutoff
      FROM maintenance.monitor_cycle mc
     WHERE mc.monitor_product_version_uuid=
           'e5100000-0000-0000-0000-000000000005'
       AND mc.execution_status='completed';

    IF baseline<>DATE '2026-10-01'
       OR latest_cutoff<>DATE '2026-10-06' THEN
        RAISE EXCEPTION
            'MON-T03 FAIL — baseline=% latest=%',
            baseline,latest_cutoff;
    END IF;
END;
$t$;

-- MON-T04 — Monitor Product currency and target scientific currency remain distinct.
DO $t$
DECLARE monitor_currency text; target_currency text;
BEGIN
    SELECT currency_status INTO monitor_currency
      FROM product.currency_state
     WHERE product_version_uuid=
           'e5100000-0000-0000-0000-000000000005'
       AND record_status='active';

    SELECT currency_status INTO target_currency
      FROM product.currency_state
     WHERE product_version_uuid=
           'e5100000-0000-0000-0000-000000000003'
       AND record_status='active';

    IF monitor_currency<>'current'
       OR target_currency<>'under_evaluation' THEN
        RAISE EXCEPTION
            'MON-T04 FAIL — monitor currency=% target currency=%',
            monitor_currency,target_currency;
    END IF;
END;
$t$;

-- MON-T05 — cycle decisions map to historical/current target CurrencyState without new ProductVersion.
DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.cycle_currency_state ccs
          JOIN product.currency_state cs
            ON cs.currency_state_uuid=ccs.currency_state_uuid
         WHERE ccs.cycle_uuid=
               'e5420000-0000-0000-0000-000000000001'
           AND cs.currency_status='current'
           AND cs.record_status='superseded'
    ) OR NOT EXISTS (
        SELECT 1
          FROM maintenance.cycle_currency_state ccs
          JOIN product.currency_state cs
            ON cs.currency_state_uuid=ccs.currency_state_uuid
         WHERE ccs.cycle_uuid=
               'e5420000-0000-0000-0000-000000000002'
           AND cs.currency_status='under_evaluation'
           AND cs.record_status='active'
    ) OR (
        SELECT count(*)
          FROM core.entity_version
         WHERE entity_uuid='e5000000-0000-0000-0000-000000000003'
    )<>1 THEN
        RAISE EXCEPTION
            'MON-T05 FAIL — currency history or ProductVersion count mismatch';
    END IF;
END;
$t$;

-- MON-T06 — Monitor Searches belong to the Monitor Investigation, not the scientific target.
DO $t$
BEGIN
    IF (
        SELECT count(*)
          FROM investigation.search s
         WHERE s.investigation_version_uuid=
               'e5100000-0000-0000-0000-000000000004'
    )<>2
       OR EXISTS (
            SELECT 1
              FROM maintenance.cycle_search cs
              JOIN investigation.search s
                ON s.search_uuid=cs.search_uuid
             WHERE cs.cycle_uuid IN (
                   'e5420000-0000-0000-0000-000000000001',
                   'e5420000-0000-0000-0000-000000000002'
             )
               AND s.investigation_version_uuid<>
                   'e5100000-0000-0000-0000-000000000004'
       ) THEN
        RAISE EXCEPTION
            'MON-T06 FAIL — Search isolation from target Investigation failed';
    END IF;
END;
$t$;

-- MON-T07 — declared source policy is satisfied for both M2 cycles.
DO $t$
BEGIN
    IF NOT maintenance.monitor_cycle_source_coverage(
           'e5420000-0000-0000-0000-000000000001'
       )
       OR NOT maintenance.monitor_cycle_source_coverage(
           'e5420000-0000-0000-0000-000000000002'
       ) THEN
        RAISE EXCEPTION
            'MON-T07 FAIL — declared source coverage not satisfied';
    END IF;
END;
$t$;

-- MON-T08 — completed M2 cycles have no contract errors.
DO $t$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
      FROM (
        SELECT * FROM maintenance.monitor_cycle_issues(
            'e5420000-0000-0000-0000-000000000001'
        )
        UNION ALL
        SELECT * FROM maintenance.monitor_cycle_issues(
            'e5420000-0000-0000-0000-000000000002'
        )
      ) x
     WHERE severity='error';

    IF n<>0 THEN
        RAISE EXCEPTION
            'MON-T08 FAIL — completed cycles have % contract errors',n;
    END IF;
END;
$t$;

-- MON-T09 — M2 can be formal without expert review, but absence is disclosed.
DO $t$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM product.assurance_record
         WHERE product_version_uuid=
               'e5100000-0000-0000-0000-000000000005'
           AND assurance_type='expert_independent_review'
           AND status='active'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.evidence_monitor_publication_issues(
               'e5100000-0000-0000-0000-000000000005'
          )
         WHERE issue_code='NO_EXPERT_REVIEW_OF_MONITOR'
           AND severity='warning'
    ) OR NOT product.evidence_monitor_is_publishable(
        'e5100000-0000-0000-0000-000000000005'
    ) THEN
        RAISE EXCEPTION
            'MON-T09 FAIL — expert-review semantics for M2 mismatch';
    END IF;
END;
$t$;

-- MON-T10 — target under evaluation and alert candidacy are warnings, not silent state changes.
DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_monitor_publication_issues(
            'e5100000-0000-0000-0000-000000000005'
        )
        WHERE issue_code='TARGET_CURRENCY_UNDER_EVALUATION'
          AND severity='warning'
    ) OR NOT EXISTS (
        SELECT 1 FROM product.evidence_monitor_publication_issues(
            'e5100000-0000-0000-0000-000000000005'
        )
        WHERE issue_code='ALERT_EVALUATION_RECOMMENDED'
          AND severity='warning'
    ) THEN
        RAISE EXCEPTION
            'MON-T10 FAIL — target/alert warning disclosure missing';
    END IF;
END;
$t$;

-- MON-T11 — target dependency is explicit and active.
DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM provenance.dependency_edge
         WHERE source_version_uuid=
               'e5100000-0000-0000-0000-000000000003'
           AND target_version_uuid=
               'e5100000-0000-0000-0000-000000000005'
           AND dependency_type='maintenance_surveillance_target'
           AND status='active'
    ) THEN
        RAISE EXCEPTION 'MON-T11 FAIL — target dependency absent';
    END IF;
END;
$t$;

-- MON-T12 — M3 is technically representable but formally blocked until Phase 4.
DO $t$
DECLARE errors jsonb;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(x)),'[]'::jsonb)
      INTO errors
      FROM product.evidence_monitor_publication_issues(
           'e5100000-0000-0000-0000-000000000007'
      ) x
     WHERE severity='error';

    IF product.evidence_monitor_is_publishable(
           'e5100000-0000-0000-0000-000000000007'
       )
       OR NOT EXISTS (
            SELECT 1
              FROM product.evidence_monitor_publication_issues(
                   'e5100000-0000-0000-0000-000000000007'
              )
             WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL'
               AND severity='error'
       )
       OR EXISTS (
            SELECT 1
              FROM maintenance.cycle_currency_state
             WHERE cycle_uuid=
                   'e5420000-0000-0000-0000-000000000003'
       ) THEN
        RAISE EXCEPTION
            'MON-T12 FAIL — M3 Phase-4 boundary failed: %',errors;
    END IF;
END;
$t$;

SELECT 'MON-T01–T12 PASS — Evidence Monitor positive contract semantics validated'
AS evidence_monitor_tests_a_status;
