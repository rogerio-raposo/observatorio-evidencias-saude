-- OES Fase 3 — Evidence Monitor contract tests B
-- Negative guards and non-regression semantics.

-- MON-T13 — MonitorDefinition is immutable.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        UPDATE maintenance.monitor_definition
           SET cadence_policy_payload='{"mutated":true}'::jsonb
         WHERE monitor_product_version_uuid=
               'e5100000-0000-0000-0000-000000000005';
    EXCEPTION WHEN others THEN
        blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T13 FAIL — MonitorDefinition mutation accepted';
    END IF;
END;
$t$;

-- MON-T14 — MonitorTarget is immutable.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        UPDATE maintenance.monitor_target
           SET rationale='mutated'
         WHERE monitor_product_version_uuid=
               'e5100000-0000-0000-0000-000000000005';
    EXCEPTION WHEN others THEN
        blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T14 FAIL — MonitorTarget mutation accepted';
    END IF;
END;
$t$;

-- MON-T15 — terminal cycles cannot be materially mutated.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        UPDATE maintenance.monitor_cycle
           SET decision_rationale='retroactive mutation'
         WHERE cycle_uuid='e5420000-0000-0000-0000-000000000002';
    EXCEPTION WHEN others THEN
        blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T15 FAIL — terminal cycle mutation accepted';
    END IF;
END;
$t$;

-- MON-T16 — Search cannot be appended to a terminal cycle.
BEGIN;
INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,
    executed_at,result_count,strategy_version,operator,status
) VALUES (
    'e55f0000-0000-0000-0000-000000000016',
    'OES-SEARCH-2026-MON-T16',
    'e5100000-0000-0000-0000-000000000004',
    'Embase','Embase','fixture',
    '{"source_class":"bibliographic"}'::jsonb,
    CURRENT_TIMESTAMP,0,'test','test','completed'
);
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.cycle_search(
            cycle_uuid,search_uuid,search_role,sequence_no
        ) VALUES (
            'e5420000-0000-0000-0000-000000000002',
            'e55f0000-0000-0000-0000-000000000016',
            'supplementary',2
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T16 FAIL — Search appended after cycle completion';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T17 — CandidateAssessment cannot be appended to terminal cycle.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.candidate_assessment(
            candidate_assessment_uuid,cycle_uuid,origin_type,
            origin_search_hit_uuid,candidate_kind,decision,
            impact_class,impact_payload,assessed_by,actor_type,
            verification_status
        ) VALUES (
            'e55f0000-0000-0000-0000-000000000017',
            'e5420000-0000-0000-0000-000000000002',
            'search_hit','e5510000-0000-0000-0000-000000000002',
            'new_study','retained_for_impact',
            'quantitative','{}'::jsonb,'test','ai_system','unverified'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T17 FAIL — candidate appended after cycle completion';
    END IF;
END;
$t$;

-- MON-T18 — EvidenceEvent cannot be appended to terminal cycle.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.evidence_event(
            evidence_event_uuid,cycle_uuid,event_type,source_uri,
            description,detected_by,actor_type,verification_status
        ) VALUES (
            'e55f0000-0000-0000-0000-000000000018',
            'e5420000-0000-0000-0000-000000000002',
            'regulatory_update','https://example.invalid/t18',
            'late event','test','ai_system','unverified'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T18 FAIL — event appended after cycle completion';
    END IF;
END;
$t$;

-- MON-T19 — one Search execution cannot belong to two cycles.
BEGIN;
INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES
('e55f0000-0000-0000-0000-000000000191',
 'e5100000-0000-0000-0000-000000000005',91,
 DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
 'running','not_assessed'),
('e55f0000-0000-0000-0000-000000000192',
 'e5100000-0000-0000-0000-000000000005',92,
 DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
 'running','not_assessed');

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,executed_at,result_count,status
) VALUES (
    'e55f0000-0000-0000-0000-000000000193',
    'OES-SEARCH-2026-MON-T19',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}',
    CURRENT_TIMESTAMP,0,'completed'
);
INSERT INTO maintenance.cycle_search VALUES (
    'e55f0000-0000-0000-0000-000000000191',
    'e55f0000-0000-0000-0000-000000000193','primary',1
);
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.cycle_search VALUES (
            'e55f0000-0000-0000-0000-000000000192',
            'e55f0000-0000-0000-0000-000000000193','primary',1
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T19 FAIL — Search assigned to two cycles';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T20 — Search from scientific target Investigation cannot be appropriated.
BEGIN;
INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000201',
    'e5100000-0000-0000-0000-000000000005',93,
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);
INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,executed_at,result_count,status
) VALUES (
    'e55f0000-0000-0000-0000-000000000202',
    'OES-SEARCH-2026-MON-T20',
    'e5100000-0000-0000-0000-000000000002',
    'PubMed','fixture','{"source_class":"bibliographic"}',
    CURRENT_TIMESTAMP,0,'completed'
);
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.cycle_search VALUES (
            'e55f0000-0000-0000-0000-000000000201',
            'e55f0000-0000-0000-0000-000000000202','primary',1
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION
            'MON-T20 FAIL — scientific target Search was appropriated by Monitor';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T21 — incomplete cycle cannot assert no_update_needed.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.monitor_cycle(
            cycle_uuid,monitor_product_version_uuid,cycle_no,
            window_start_date,window_end_date,started_at,completed_at,
            execution_status,completeness_status,maintenance_decision,
            decision_rationale,decided_by,actor_type
        ) VALUES (
            'e55f0000-0000-0000-0000-000000000210',
            'e5100000-0000-0000-0000-000000000005',94,
            DATE '2026-10-07',DATE '2026-10-07',
            CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,
            'incomplete','partial','no_update_needed',
            'invalid test','test','ai_system'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T21 FAIL — incomplete no_update accepted';
    END IF;
END;
$t$;

-- MON-T22 — paused Monitor cannot start a running cycle.
BEGIN;
UPDATE maintenance.monitor_state
   SET record_status='superseded'
 WHERE monitor_state_uuid='e5410000-0000-0000-0000-000000000001';

INSERT INTO maintenance.monitor_state(
    monitor_state_uuid,monitor_product_version_uuid,operational_status,
    effective_at,rationale,changed_by,actor_type,
    supersedes_monitor_state_uuid
) VALUES (
    'e55f0000-0000-0000-0000-000000000221',
    'e5100000-0000-0000-0000-000000000005','paused',
    CURRENT_TIMESTAMP,'test pause','test','system',
    'e5410000-0000-0000-0000-000000000001'
);
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.monitor_cycle(
            cycle_uuid,monitor_product_version_uuid,cycle_no,
            window_start_date,window_end_date,started_at,
            execution_status,completeness_status
        ) VALUES (
            'e55f0000-0000-0000-0000-000000000222',
            'e5100000-0000-0000-0000-000000000005',95,
            DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
            'running','not_assessed'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T22 FAIL — paused Monitor started running cycle';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T23 — AI cannot be recorded as human verifier for a candidate.
BEGIN;
INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000231',
    'e5100000-0000-0000-0000-000000000005',96,
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);
INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,executed_at,result_count,status
) VALUES (
    'e55f0000-0000-0000-0000-000000000232',
    'OES-SEARCH-2026-MON-T23',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}',
    CURRENT_TIMESTAMP,1,'completed'
);
INSERT INTO maintenance.cycle_search VALUES (
    'e55f0000-0000-0000-0000-000000000231',
    'e55f0000-0000-0000-0000-000000000232','primary',1
);
INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,
    source_record_id,raw_title,source_rank,resolution_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000233',
    'OES-HIT-2026-MON-T23',
    'e55f0000-0000-0000-0000-000000000232',
    't23','fixture',1,'unresolved'
);
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.candidate_assessment(
            candidate_assessment_uuid,cycle_uuid,origin_type,
            origin_search_hit_uuid,candidate_kind,decision,
            impact_class,assessed_by,actor_type,verification_status,
            verified_by,verifier_actor_type,verified_at
        ) VALUES (
            'e55f0000-0000-0000-0000-000000000234',
            'e55f0000-0000-0000-0000-000000000231',
            'search_hit','e55f0000-0000-0000-0000-000000000233',
            'new_report','retained_for_impact','quantitative',
            'test','ai_system','human_verified',
            'ai-test','ai_system',CURRENT_TIMESTAMP
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T23 FAIL — AI accepted as human candidate verifier';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T24 — pending candidate blocks cycle completion.
BEGIN;
INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000241',
    'e5100000-0000-0000-0000-000000000005',97,
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);
INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,executed_at,result_count,status
) VALUES (
    'e55f0000-0000-0000-0000-000000000242',
    'OES-SEARCH-2026-MON-T24',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}',
    CURRENT_TIMESTAMP,1,'completed'
);
INSERT INTO maintenance.cycle_search VALUES (
    'e55f0000-0000-0000-0000-000000000241',
    'e55f0000-0000-0000-0000-000000000242','primary',1
);
INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,
    source_record_id,raw_title,source_rank,resolution_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000243',
    'OES-HIT-2026-MON-T24',
    'e55f0000-0000-0000-0000-000000000242',
    't24','fixture',1,'unresolved'
);
INSERT INTO maintenance.candidate_assessment(
    candidate_assessment_uuid,cycle_uuid,origin_type,
    origin_search_hit_uuid,candidate_kind,decision,
    assessed_by,actor_type,verification_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000244',
    'e55f0000-0000-0000-0000-000000000241',
    'search_hit','e55f0000-0000-0000-0000-000000000243',
    'new_report','pending','test','ai_system','unverified'
);
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        UPDATE maintenance.monitor_cycle
           SET completed_at=CURRENT_TIMESTAMP,
               execution_status='completed',
               completeness_status='complete',
               maintenance_decision='evaluate_update',
               decision_rationale='test',
               decided_by='test',
               actor_type='ai_system'
         WHERE cycle_uuid='e55f0000-0000-0000-0000-000000000241';
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T24 FAIL — cycle closed with pending candidate';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T25 — unassessed active EvidenceEvent blocks cycle completion.
BEGIN;
INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000251',
    'e5100000-0000-0000-0000-000000000005',98,
    DATE '2026-10-07',DATE '2026-10-07',CURRENT_TIMESTAMP,
    'running','not_assessed'
);
INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,exact_strategy,filters_payload,executed_at,result_count,status
) VALUES (
    'e55f0000-0000-0000-0000-000000000252',
    'OES-SEARCH-2026-MON-T25',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','fixture','{"source_class":"bibliographic"}',
    CURRENT_TIMESTAMP,0,'completed'
);
INSERT INTO maintenance.cycle_search VALUES (
    'e55f0000-0000-0000-0000-000000000251',
    'e55f0000-0000-0000-0000-000000000252','primary',1
);
INSERT INTO maintenance.evidence_event(
    evidence_event_uuid,cycle_uuid,event_type,source_uri,
    description,detected_by,actor_type,verification_status
) VALUES (
    'e55f0000-0000-0000-0000-000000000253',
    'e55f0000-0000-0000-0000-000000000251',
    'regulatory_update','https://example.invalid/t25',
    'unassessed event','test','ai_system','unverified'
);
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        UPDATE maintenance.monitor_cycle
           SET completed_at=CURRENT_TIMESTAMP,
               execution_status='completed',
               completeness_status='complete',
               maintenance_decision='evaluate_update',
               decision_rationale='test',
               decided_by='test',
               actor_type='ai_system'
         WHERE cycle_uuid='e55f0000-0000-0000-0000-000000000251';
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T25 FAIL — cycle closed with unassessed event';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T26 — declared source policy, not a hidden global rule, drives coverage.
BEGIN;
UPDATE investigation.search
   SET source_name='Embase'
 WHERE search_uuid='e5500000-0000-0000-0000-000000000002';
DO $t$
BEGIN
    IF maintenance.monitor_cycle_source_coverage(
           'e5420000-0000-0000-0000-000000000002'
       )
       OR NOT EXISTS (
            SELECT 1
              FROM maintenance.monitor_cycle_issues(
                   'e5420000-0000-0000-0000-000000000002'
              )
             WHERE issue_code='INCOMPLETE_REQUIRED_SOURCE_COVERAGE'
               AND severity='error'
       ) THEN
        RAISE EXCEPTION
            'MON-T26 FAIL — declared PubMed source policy was not enforced';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T27 — A1 alone does not publish formal M2.
BEGIN;
UPDATE product.assurance_record
   SET status='superseded'
 WHERE assurance_uuid='e5600000-0000-0000-0000-000000000002';
DO $t$
BEGIN
    IF product.assurance_level(
           'e5100000-0000-0000-0000-000000000005'
       )<>'A1'
       OR product.evidence_monitor_is_publishable(
           'e5100000-0000-0000-0000-000000000005'
       )
       OR NOT EXISTS (
            SELECT 1
              FROM product.evidence_monitor_publication_issues(
                   'e5100000-0000-0000-0000-000000000005'
              )
             WHERE issue_code='MISSING_OWNER_APPROVAL'
               AND severity='error'
       ) THEN
        RAISE EXCEPTION 'MON-T27 FAIL — A1 improperly published M2';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T28 — dynamic target invalidation is detected after linkage.
BEGIN;
UPDATE core.entity_version
   SET version_status='invalidated'
 WHERE version_uuid='e5100000-0000-0000-0000-000000000003';
DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_monitor_publication_issues(
               'e5100000-0000-0000-0000-000000000005'
          )
         WHERE issue_code='TARGET_INVALIDATED'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'MON-T28 FAIL — target invalidation not detected';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T29 — missing active target dependency is detected.
BEGIN;
UPDATE provenance.dependency_edge
   SET status='superseded'
 WHERE source_version_uuid='e5100000-0000-0000-0000-000000000003'
   AND target_version_uuid='e5100000-0000-0000-0000-000000000005'
   AND dependency_type='maintenance_surveillance_target';
DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.evidence_monitor_publication_issues(
               'e5100000-0000-0000-0000-000000000005'
          )
         WHERE issue_code='MISSING_TARGET_DEPENDENCY'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION 'MON-T29 FAIL — missing target dependency not detected';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T30 — invalidated upstream provenance blocks publication.
BEGIN;
INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,
    source_location,process_type,process_record_uuid,
    actor,status,invalidated_at,invalidation_reason
) VALUES (
    'e55f0000-0000-0000-0000-000000000300',
    'e5100000-0000-0000-0000-000000000003',
    'monitor_test','synthetic','monitor_cycle',
    'e5420000-0000-0000-0000-000000000002',
    'test','invalidated',CURRENT_TIMESTAMP,'synthetic invalidation test'
);
DO $t$
BEGIN
    IF product.evidence_monitor_is_publishable(
           'e5100000-0000-0000-0000-000000000005'
       )
       OR NOT EXISTS (
            SELECT 1
              FROM product.evidence_monitor_publication_issues(
                   'e5100000-0000-0000-0000-000000000005'
              )
             WHERE issue_code='INVALIDATED_DEPENDENCY'
               AND severity='error'
       ) THEN
        RAISE EXCEPTION
            'MON-T30 FAIL — invalidated dependency did not block publication';
    END IF;
END;
$t$;
ROLLBACK;

-- MON-T31 — Product-target currency mapping cannot point to Monitor currency.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.cycle_currency_state(
            cycle_uuid,currency_state_uuid
        ) VALUES (
            'e5420000-0000-0000-0000-000000000003',
            'e5300000-0000-0000-0000-000000000011'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION
            'MON-T31 FAIL — Investigation-target cycle accepted Product currency linkage';
    END IF;
END;
$t$;

-- MON-T32 — a second active MonitorState is rejected.
DO $t$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO maintenance.monitor_state(
            monitor_state_uuid,monitor_product_version_uuid,
            operational_status,rationale,changed_by,actor_type
        ) VALUES (
            'e55f0000-0000-0000-0000-000000000320',
            'e5100000-0000-0000-0000-000000000005',
            'active','duplicate active test','test','system'
        );
    EXCEPTION WHEN others THEN blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'MON-T32 FAIL — second active MonitorState accepted';
    END IF;
END;
$t$;

SELECT 'MON-T13–T32 PASS — Evidence Monitor negative guards validated'
AS evidence_monitor_tests_b_status;
