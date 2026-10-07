-- OES Fase 3 — Evidence Monitor projection-hardening tests
-- Requires migrations through 022 + f3-evidence-monitor-fixtures.sql.

-- MONH-T01 — one candidate preserves multiple impact dimensions.
DO $t$
BEGIN
    IF (
        SELECT count(*)
          FROM maintenance.candidate_impact
         WHERE candidate_assessment_uuid=
               'e5530000-0000-0000-0000-000000000002'
    )<>2
       OR NOT EXISTS (
            SELECT 1 FROM maintenance.candidate_impact
             WHERE candidate_assessment_uuid=
                   'e5530000-0000-0000-0000-000000000002'
               AND impact_class='quantitative'
       )
       OR NOT EXISTS (
            SELECT 1 FROM maintenance.candidate_impact
             WHERE candidate_assessment_uuid=
                   'e5530000-0000-0000-0000-000000000002'
               AND impact_class='certainty'
       ) THEN
        RAISE EXCEPTION 'MONH-T01 FAIL — multi-impact cardinality lost';
    END IF;
END;
$t$;

-- MONH-T02 — retained candidate has exactly one primary impact.
DO $t$
BEGIN
    IF (
        SELECT count(*)
          FROM maintenance.candidate_impact
         WHERE candidate_assessment_uuid=
               'e5530000-0000-0000-0000-000000000002'
           AND is_primary
    )<>1 THEN
        RAISE EXCEPTION 'MONH-T02 FAIL — primary impact cardinality invalid';
    END IF;
END;
$t$;

-- MONH-T03 — normalized primary impact matches legacy primary summary.
DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.candidate_assessment ca
          JOIN maintenance.candidate_impact ci
            ON ci.candidate_assessment_uuid=ca.candidate_assessment_uuid
           AND ci.is_primary
         WHERE ca.candidate_assessment_uuid=
               'e5530000-0000-0000-0000-000000000002'
           AND ca.impact_class=ci.impact_class
    ) THEN
        RAISE EXCEPTION 'MONH-T03 FAIL — primary impact summary drift';
    END IF;
END;
$t$;

-- MONH-T04 — duplicate impact class is rejected.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.candidate_impact(
            candidate_impact_uuid,candidate_assessment_uuid,
            impact_class,is_primary
        ) VALUES (
            'e56f0000-0000-0000-0000-000000000004',
            'e5530000-0000-0000-0000-000000000002',
            'quantitative',false
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MONH-T04 FAIL — duplicate impact class accepted';
    END IF;
END;
$t$;

-- MONH-T05 — impact cannot be appended after cycle completion.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.candidate_impact(
            candidate_impact_uuid,candidate_assessment_uuid,
            impact_class,is_primary
        ) VALUES (
            'e56f0000-0000-0000-0000-000000000005',
            'e5530000-0000-0000-0000-000000000002',
            'applicability',false
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MONH-T05 FAIL — terminal-cycle impact accepted';
    END IF;
END;
$t$;

-- MONH-T06/T08 — unknown requirement kind is rejected and
-- unnormalized policy is detected.
BEGIN;

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('e56f0000-0000-0000-0000-000000000061','OES-I-2026-MONH061','Investigation','monh'),
('e56f0000-0000-0000-0000-000000000062','OES-P-2026-MONH062','Product','monh');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('e56f1000-0000-0000-0000-000000000061',
 'e56f0000-0000-0000-0000-000000000061',
 1,'current','monh','initial','Temporary MONH Investigation'),
('e56f1000-0000-0000-0000-000000000062',
 'e56f0000-0000-0000-0000-000000000062',
 1,'current','monh','initial','Temporary MONH Product');

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('e56f0000-0000-0000-0000-000000000061');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,
    objective,protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'e56f1000-0000-0000-0000-000000000061',
    'e56f0000-0000-0000-0000-000000000061',
    'e5000000-0000-0000-0000-000000000001',
    'evidence_monitoring','N2','M2',
    'Temporary MONH policy fixture',
    'e5200000-0000-0000-0000-000000000001',
    DATE '2026-10-02',DATE '2026-10-01','active'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'e56f1000-0000-0000-0000-000000000061',
    'e5100000-0000-0000-0000-000000000001',
    'primary',1
);

INSERT INTO product.product(entity_uuid)
VALUES ('e56f0000-0000-0000-0000-000000000062');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,status,limitations_summary
) VALUES (
    'e56f1000-0000-0000-0000-000000000062',
    'e56f0000-0000-0000-0000-000000000062',
    'evidence_monitor','Temporary MONH Monitor','architecture_validation',
    DATE '2026-10-01','draft','temporary'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    'e56f1000-0000-0000-0000-000000000062',
    'e56f1000-0000-0000-0000-000000000061','primary',1
);

INSERT INTO maintenance.monitor_definition(
    monitor_product_version_uuid,
    surveillance_scope_payload,source_policy_payload,
    strategy_policy_payload,cadence_policy_payload,
    impact_policy_payload,escalation_policy_payload
) VALUES (
    'e56f1000-0000-0000-0000-000000000062',
    '{}'::jsonb,
    '{"required_source_names":["PubMed"]}'::jsonb,
    '{}'::jsonb,'{}'::jsonb,'{}'::jsonb,'{}'::jsonb
);

DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_source_policy_issues(
               'e56f1000-0000-0000-0000-000000000062'
          )
         WHERE issue_code='MISSING_NORMALIZED_SOURCE_REQUIREMENTS'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'MONH-T08 FAIL — unnormalized policy not detected';
    END IF;
END;
$t$;

DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.monitor_source_requirement(
            source_requirement_uuid,monitor_product_version_uuid,
            requirement_code,requirement_kind,required_value,
            allow_exception,rationale
        ) VALUES (
            'e56f2000-0000-0000-0000-000000000061',
            'e56f1000-0000-0000-0000-000000000062',
            'unknown','unknown_requirement','x',true,'test'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MONH-T06 FAIL — unknown requirement kind accepted';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T07 — normalized source requirements are evaluated as fulfilled.
DO $t$
BEGIN
    IF (
        SELECT count(*)
          FROM maintenance.monitor_cycle_source_requirement_status(
               'e5420000-0000-0000-0000-000000000002'
          )
    )<>3
       OR EXISTS (
            SELECT 1
              FROM maintenance.monitor_cycle_source_requirement_status(
                   'e5420000-0000-0000-0000-000000000002'
              )
             WHERE NOT fulfilled
                OR exception_applied
                OR NOT satisfied
       ) THEN
        RAISE EXCEPTION
            'MONH-T07 FAIL — normalized source requirements not fulfilled normally';
    END IF;
END;
$t$;

-- MONH-T09 — accepted source exception satisfies without pretending fulfilled.
BEGIN;

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000091',
    'e5100000-0000-0000-0000-000000000005',91,
    'e5420000-0000-0000-0000-000000000002',
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,
    decision_type,stage,decision_code,planned_flag,
    rationale,impact_payload,resolution_status,decided_by
) VALUES (
    'e56f4000-0000-0000-0000-000000000091',
    'e5100000-0000-0000-0000-000000000004',
    'other','search','monitor_source_requirement_exception',false,
    'Synthetic accepted source exception',
    '{"cycle_uuid":"e56f3000-0000-0000-0000-000000000091",
      "requirement_code":"pubmed_required"}'::jsonb,
    'accepted','monh'
);

DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle_source_requirement_status(
               'e56f3000-0000-0000-0000-000000000091'
          )
         WHERE requirement_code='pubmed_required'
           AND fulfilled=false
           AND exception_applied=true
           AND satisfied=true
           AND exception_method_decision_uuid=
               'e56f4000-0000-0000-0000-000000000091'
    ) THEN
        RAISE EXCEPTION
            'MONH-T09 FAIL — accepted source exception semantics incorrect';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T10 — open source exception does not satisfy requirement.
BEGIN;

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000101',
    'e5100000-0000-0000-0000-000000000005',92,
    'e5420000-0000-0000-0000-000000000002',
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,
    decision_type,stage,decision_code,planned_flag,
    rationale,impact_payload,resolution_status,decided_by
) VALUES (
    'e56f4000-0000-0000-0000-000000000101',
    'e5100000-0000-0000-0000-000000000004',
    'other','search','monitor_source_requirement_exception',false,
    'Synthetic open source exception',
    '{"cycle_uuid":"e56f3000-0000-0000-0000-000000000101",
      "requirement_code":"pubmed_required"}'::jsonb,
    'open','monh'
);

DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle_source_requirement_status(
               'e56f3000-0000-0000-0000-000000000101'
          )
         WHERE requirement_code='pubmed_required'
           AND fulfilled=false
           AND exception_applied=false
           AND satisfied=false
    ) THEN
        RAISE EXCEPTION
            'MONH-T10 FAIL — open source exception incorrectly satisfied requirement';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T11 — Search outside cycle window is detected.
BEGIN;

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000111',
    'e5100000-0000-0000-0000-000000000005',93,
    'e5420000-0000-0000-0000-000000000002',
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,
    executed_at,result_count,status
) VALUES (
    'e56f5000-0000-0000-0000-000000000111',
    'OES-SEARCH-2026-MONH111',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-08 12:00:00+00',0,'completed'
);

INSERT INTO maintenance.cycle_search VALUES (
    'e56f3000-0000-0000-0000-000000000111',
    'e56f5000-0000-0000-0000-000000000111','primary',1
);

DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle_temporal_issues(
               'e56f3000-0000-0000-0000-000000000111'
          )
         WHERE issue_code='SEARCH_OUTSIDE_CYCLE_WINDOW'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'MONH-T11 FAIL — outside-window Search not detected';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T12 — accepted temporal exception is explicit and removes the error.
BEGIN;

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000121',
    'e5100000-0000-0000-0000-000000000005',94,
    'e5420000-0000-0000-0000-000000000002',
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,
    executed_at,result_count,status
) VALUES (
    'e56f5000-0000-0000-0000-000000000121',
    'OES-SEARCH-2026-MONH121',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-08 12:00:00+00',0,'completed'
);

INSERT INTO maintenance.cycle_search VALUES (
    'e56f3000-0000-0000-0000-000000000121',
    'e56f5000-0000-0000-0000-000000000121','primary',1
);

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,
    decision_type,stage,decision_code,planned_flag,
    rationale,impact_payload,resolution_status,decided_by
) VALUES (
    'e56f4000-0000-0000-0000-000000000121',
    'e5100000-0000-0000-0000-000000000004',
    'other','search','monitor_search_temporal_exception',false,
    'Synthetic historical-import exception',
    '{"cycle_uuid":"e56f3000-0000-0000-0000-000000000121",
      "search_uuid":"e56f5000-0000-0000-0000-000000000121"}'::jsonb,
    'accepted','monh'
);

DO $t$
BEGIN
    IF NOT maintenance.monitor_search_temporally_acceptable(
           'e56f3000-0000-0000-0000-000000000121',
           'e56f5000-0000-0000-0000-000000000121'
       )
       OR EXISTS (
            SELECT 1
              FROM maintenance.monitor_cycle_temporal_issues(
                   'e56f3000-0000-0000-0000-000000000121'
              )
             WHERE issue_code='SEARCH_OUTSIDE_CYCLE_WINDOW'
       ) THEN
        RAISE EXCEPTION
            'MONH-T12 FAIL — accepted temporal exception not honored';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T13 — Search Investigation drift is detected dynamically.
BEGIN;

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000131',
    'e5100000-0000-0000-0000-000000000005',95,
    'e5420000-0000-0000-0000-000000000002',
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,
    executed_at,result_count,status
) VALUES (
    'e56f5000-0000-0000-0000-000000000131',
    'OES-SEARCH-2026-MONH131',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-07 12:00:00+00',0,'completed'
);

INSERT INTO maintenance.cycle_search VALUES (
    'e56f3000-0000-0000-0000-000000000131',
    'e56f5000-0000-0000-0000-000000000131','primary',1
);

UPDATE investigation.search
   SET investigation_version_uuid=
       'e5100000-0000-0000-0000-000000000002'
 WHERE search_uuid='e56f5000-0000-0000-0000-000000000131';

DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle_temporal_issues(
               'e56f3000-0000-0000-0000-000000000131'
          )
         WHERE issue_code='SEARCH_INVESTIGATION_DRIFT'
    ) THEN
        RAISE EXCEPTION 'MONH-T13 FAIL — Search Investigation drift not detected';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T14 — Search status drift is detected dynamically.
BEGIN;

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000141',
    'e5100000-0000-0000-0000-000000000005',96,
    'e5420000-0000-0000-0000-000000000002',
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,
    executed_at,result_count,status
) VALUES (
    'e56f5000-0000-0000-0000-000000000141',
    'OES-SEARCH-2026-MONH141',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-07 12:00:00+00',0,'completed'
);

INSERT INTO maintenance.cycle_search VALUES (
    'e56f3000-0000-0000-0000-000000000141',
    'e56f5000-0000-0000-0000-000000000141','primary',1
);

UPDATE investigation.search
   SET status='failed'
 WHERE search_uuid='e56f5000-0000-0000-0000-000000000141';

DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle_temporal_issues(
               'e56f3000-0000-0000-0000-000000000141'
          )
         WHERE issue_code='SEARCH_NOT_COMPLETED'
    ) THEN
        RAISE EXCEPTION 'MONH-T14 FAIL — Search status drift not detected';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T15 — cycle window before baseline is rejected.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.monitor_cycle(
            cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
            window_start_date,window_end_date,started_at,
            execution_status,completeness_status
        ) VALUES (
            'e56f3000-0000-0000-0000-000000000151',
            'e5100000-0000-0000-0000-000000000005',97,
            'e5420000-0000-0000-0000-000000000002',
            DATE '2026-09-30',DATE '2026-10-01',CURRENT_TIMESTAMP,
            'running','not_assessed'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MONH-T15 FAIL — pre-baseline window accepted';
    END IF;
END;
$t$;

-- MONH-T16 — unexplained cycle gap is rejected.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.monitor_cycle(
            cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
            window_start_date,window_end_date,started_at,
            execution_status,completeness_status
        ) VALUES (
            'e56f3000-0000-0000-0000-000000000161',
            'e5100000-0000-0000-0000-000000000005',98,
            'e5420000-0000-0000-0000-000000000002',
            DATE '2026-10-08',DATE '2026-10-08',CURRENT_TIMESTAMP,
            'running','not_assessed'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MONH-T16 FAIL — unexplained cycle gap accepted';
    END IF;
END;
$t$;

-- MONH-T17 — accepted gap exception permits the documented gap.
BEGIN;

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,
    decision_type,stage,decision_code,planned_flag,
    rationale,impact_payload,resolution_status,decided_by
) VALUES (
    'e56f4000-0000-0000-0000-000000000171',
    'e5100000-0000-0000-0000-000000000004',
    'other','search','monitor_cycle_window_gap_exception',false,
    'Synthetic accepted surveillance gap',
    '{"cycle_uuid":"e56f3000-0000-0000-0000-000000000171",
      "previous_cycle_uuid":"e5420000-0000-0000-0000-000000000002"}'::jsonb,
    'accepted','monh'
);

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000171',
    'e5100000-0000-0000-0000-000000000005',99,
    'e5420000-0000-0000-0000-000000000002',
    DATE '2026-10-08',DATE '2026-10-08',CURRENT_TIMESTAMP,
    'running','not_assessed'
);

DO $t$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM maintenance.monitor_cycle_temporal_issues(
               'e56f3000-0000-0000-0000-000000000171'
          )
         WHERE issue_code='UNEXPLAINED_CYCLE_WINDOW_GAP'
    ) THEN
        RAISE EXCEPTION 'MONH-T17 FAIL — accepted gap exception ignored';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T18 — CycleCurrencyState UPDATE is blocked.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        UPDATE maintenance.cycle_currency_state
           SET linked_at=linked_at + interval '1 second'
         WHERE cycle_uuid='e5420000-0000-0000-0000-000000000002';
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MONH-T18 FAIL — CycleCurrencyState update accepted';
    END IF;
END;
$t$;

-- MONH-T19 — CycleCurrencyState DELETE is blocked.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        DELETE FROM maintenance.cycle_currency_state
         WHERE cycle_uuid='e5420000-0000-0000-0000-000000000002';
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MONH-T19 FAIL — CycleCurrencyState delete accepted';
    END IF;
END;
$t$;

-- MONH-T20 — drift in a completed historical cycle reaches product hardening.
BEGIN;

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e56f3000-0000-0000-0000-000000000201',
    'e5100000-0000-0000-0000-000000000007',2,
    'e5420000-0000-0000-0000-000000000003',
    DATE '2026-10-07',DATE '2026-10-07',
    TIMESTAMPTZ '2026-10-07 07:00:00+00',
    'running','not_assessed'
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,
    executed_at,result_count,status
) VALUES (
    'e56f5000-0000-0000-0000-000000000201',
    'OES-SEARCH-2026-MONH201',
    'e5100000-0000-0000-0000-000000000006',
    'PubMed','fixture','{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-07 07:10:00+00',0,'completed'
);

INSERT INTO maintenance.cycle_search VALUES (
    'e56f3000-0000-0000-0000-000000000201',
    'e56f5000-0000-0000-0000-000000000201','primary',1
);

UPDATE maintenance.monitor_cycle
   SET completed_at=TIMESTAMPTZ '2026-10-07 07:30:00+00',
       execution_status='completed',
       completeness_status='complete',
       maintenance_decision='no_update_needed',
       decision_rationale='Synthetic historical-cycle drift test',
       decided_by='monh',
       actor_type='ai_system'
 WHERE cycle_uuid='e56f3000-0000-0000-0000-000000000201';

UPDATE investigation.search
   SET investigation_version_uuid=
       'e5100000-0000-0000-0000-000000000002'
 WHERE search_uuid='e56f5000-0000-0000-0000-000000000201';

DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_monitor_projection_hardening_issues(
               'e5100000-0000-0000-0000-000000000007'
          )
         WHERE issue_code='SEARCH_INVESTIGATION_DRIFT'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION
            'MONH-T20 FAIL — historical Search drift did not reach product hardening gate';
    END IF;
END;
$t$;

ROLLBACK;

-- MONH-T21 — valid M2 fixture remains publishable after hardening.
DO $t$
BEGIN
    IF NOT product.evidence_monitor_is_publishable(
           'e5100000-0000-0000-0000-000000000005'
       )
       OR EXISTS (
            SELECT 1
              FROM product.evidence_monitor_projection_hardening_issues(
                   'e5100000-0000-0000-0000-000000000005'
              )
             WHERE severity='error'
       ) THEN
        RAISE EXCEPTION
            'MONH-T21 FAIL — valid M2 fixture regressed under hardening';
    END IF;
END;
$t$;

-- MONH-T22 — M3 Phase-4 blocker remains intact after hardening.
DO $t$
BEGIN
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
       ) THEN
        RAISE EXCEPTION
            'MONH-T22 FAIL — M3 Phase-4 blocker regressed';
    END IF;
END;
$t$;

SELECT 'MONH-T01–T22 PASS — Evidence Monitor projection hardening semantics validated'
AS evidence_monitor_hardening_tests_status;
