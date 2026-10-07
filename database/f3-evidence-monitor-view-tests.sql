-- OES Fase 3 — EvidenceMonitorView 0.1 projection tests
-- Requires migrations through 023 + f3-evidence-monitor-fixtures.sql.

-- MONV-T01 — schema identity and Monitor product identity.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF v->>'schema_version'<>'oes.evidence_monitor_view/0.1'
       OR v#>>'{identity,product_id}'<>'OES-P-2026-MON002'
       OR v#>>'{identity,product_type}'<>'evidence_monitor'
       OR v#>>'{identity,editorial_status}'<>'published'
       OR v#>>'{identity,baseline_evidence_cutoff_date}'<>'2026-10-01' THEN
        RAISE EXCEPTION 'MONV-T01 FAIL — identity/schema projection mismatch: %',v;
    END IF;
END;
$t$;

-- MONV-T02 — four state dimensions remain distinct.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF v#>>'{identity,editorial_status}'<>'published'
       OR v#>>'{operational_state,status}'<>'active'
       OR v#>>'{monitor_currency,status}'<>'current'
       OR v#>>'{target,currency,status}'<>'under_evaluation' THEN
        RAISE EXCEPTION
            'MONV-T02 FAIL — editorial/operational/monitor/target states collapsed: %',
            v;
    END IF;
END;
$t$;

-- MONV-T03 — ProductVersion target projection preserves target science/context.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF v#>>'{target,target_type}'<>'product_version'
       OR v#>>'{target,target_product_id}'<>'OES-P-2026-MON001'
       OR v#>>'{target,depth_level}'<>'N2'
       OR v#>>'{target,baseline_evidence_cutoff_date}'<>'2026-10-01'
       OR v#>>'{target,assurance_level}'<>'A0'
       OR v#>>'{target,scientific_conclusion}'<>'Synthetic target conclusion.'
       OR v#>>'{target,dependency,dependency_type}'<>
          'maintenance_surveillance_target' THEN
        RAISE EXCEPTION 'MONV-T03 FAIL — Product target projection mismatch: %',v->'target';
    END IF;
END;
$t$;

-- MONV-T04 — Monitor plan exposes normalized source requirements.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF jsonb_array_length(v#>'{monitor_plan,source_requirements}')<>3
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{monitor_plan,source_requirements}') x
             WHERE x->>'requirement_kind'='source_name'
               AND x->>'required_value'='PubMed'
       )
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{monitor_plan,source_requirements}') x
             WHERE x->>'requirement_kind'=
                   'minimum_distinct_bibliographic_sources'
               AND x->>'minimum_count'='1'
       ) THEN
        RAISE EXCEPTION 'MONV-T04 FAIL — source requirement projection mismatch';
    END IF;
END;
$t$;

-- MONV-T05 — cycles are deterministic and baseline/latest cutoff stay distinct.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF jsonb_array_length(v->'cycles')<>2
       OR v#>>'{cycles,0,cycle_no}'<>'1'
       OR v#>>'{cycles,1,cycle_no}'<>'2'
       OR v#>>'{audit,baseline_evidence_cutoff_date}'<>'2026-10-01'
       OR v#>>'{audit,latest_completed_cycle_cutoff_date}'<>'2026-10-06'
       OR v#>>'{latest_completed_cycle,cycle_no}'<>'2' THEN
        RAISE EXCEPTION 'MONV-T05 FAIL — cycle ordering/cutoff projection mismatch: %',v->'cycles';
    END IF;
END;
$t$;

-- MONV-T06 — cycle Searches and SearchHits are projected from canonical Search records.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=maintenance.monitor_cycle_projection(
        'e5420000-0000-0000-0000-000000000002'
    );

    IF jsonb_array_length(v->'searches')<>1
       OR v#>>'{searches,0,source_name}'<>'PubMed'
       OR v#>>'{searches,0,source_class}'<>'bibliographic'
       OR v#>>'{searches,0,status}'<>'completed'
       OR v#>>'{searches,0,temporally_acceptable}'<>'true'
       OR jsonb_array_length(v#>'{searches,0,search_hits}')<>1
       OR v#>>'{searches,0,search_hits,0,raw_title}'<>
          'Potentially relevant new trial' THEN
        RAISE EXCEPTION 'MONV-T06 FAIL — Search/SearchHit projection mismatch: %',v->'searches';
    END IF;
END;
$t$;

-- MONV-T07 — source status preserves fulfilled vs exception semantics.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=maintenance.monitor_cycle_projection(
        'e5420000-0000-0000-0000-000000000002'
    );

    IF jsonb_array_length(v->'source_requirement_status')<>3
       OR EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v->'source_requirement_status') x
             WHERE x->>'fulfilled'<>'true'
                OR x->>'exception_applied'<>'false'
                OR x->>'satisfied'<>'true'
       ) THEN
        RAISE EXCEPTION 'MONV-T07 FAIL — requirement status semantics mismatch';
    END IF;
END;
$t$;

-- MONV-T08 — multi-impact candidate is projected without collapsing dimensions.
DO $t$
DECLARE v jsonb;
DECLARE candidate jsonb;
BEGIN
    v:=maintenance.monitor_cycle_projection(
        'e5420000-0000-0000-0000-000000000002'
    );

    SELECT x INTO candidate
      FROM jsonb_array_elements(v->'candidates') x
     WHERE x->>'candidate_assessment_uuid'=
           'e5530000-0000-0000-0000-000000000002';

    IF candidate IS NULL
       OR candidate->>'primary_impact_class'<>'quantitative'
       OR jsonb_array_length(candidate->'impacts')<>2
       OR candidate#>>'{impacts,0,impact_class}'<>'quantitative'
       OR candidate#>>'{impacts,0,is_primary}'<>'true'
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(candidate->'impacts') i
             WHERE i->>'impact_class'='certainty'
               AND i->>'is_primary'='false'
       ) THEN
        RAISE EXCEPTION 'MONV-T08 FAIL — multi-impact projection mismatch: %',candidate;
    END IF;
END;
$t$;

-- MONV-T09 — EvidenceEvent and event-origin CandidateAssessment remain distinct.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=maintenance.monitor_cycle_projection(
        'e5420000-0000-0000-0000-000000000002'
    );

    IF jsonb_array_length(v->'events')<>1
       OR v#>>'{events,0,event_type}'<>'regulatory_update'
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v->'candidates') x
             WHERE x->>'origin_type'='evidence_event'
               AND x#>>'{origin,evidence_event_uuid}'=
                   'e5520000-0000-0000-0000-000000000001'
               AND x->>'primary_impact_class'='applicability'
       ) THEN
        RAISE EXCEPTION 'MONV-T09 FAIL — event/candidate projection mismatch';
    END IF;
END;
$t$;

-- MONV-T10 — resulting target CurrencyState preserves cycle-specific history.
DO $t$
DECLARE c1 jsonb; c2 jsonb;
BEGIN
    c1:=maintenance.monitor_cycle_projection(
        'e5420000-0000-0000-0000-000000000001'
    );
    c2:=maintenance.monitor_cycle_projection(
        'e5420000-0000-0000-0000-000000000002'
    );

    IF c1#>>'{resulting_target_currency,currency_status}'<>'current'
       OR c1#>>'{resulting_target_currency,record_status}'<>'superseded'
       OR c2#>>'{resulting_target_currency,currency_status}'<>'under_evaluation'
       OR c2#>>'{resulting_target_currency,record_status}'<>'active' THEN
        RAISE EXCEPTION
            'MONV-T10 FAIL — historical/current target CurrencyState projection mismatch';
    END IF;
END;
$t$;

-- MONV-T11 — audit exposes Monitor assurance, target assurance and publishability separately.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF v#>>'{audit,assurance_level}'<>'A2'
       OR v#>>'{audit,target_assurance_level}'<>'A0'
       OR v#>>'{audit,required_assurance_level}'<>'A2'
       OR v#>>'{audit,publishable}'<>'true'
       OR v#>>'{audit,maintenance_level}'<>'M2'
       OR v#>>'{audit,required_source_coverage_satisfied}'<>'true' THEN
        RAISE EXCEPTION 'MONV-T11 FAIL — audit assurance/gate projection mismatch: %',v->'audit';
    END IF;
END;
$t$;

-- MONV-T12 — warnings remain visible while hardening issues are empty for valid M2.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF jsonb_array_length(v#>'{audit,projection_hardening_issues}')<>0
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{audit,publication_issues}') x
             WHERE x->>'code'='TARGET_CURRENCY_UNDER_EVALUATION'
               AND x->>'severity'='warning'
       )
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{audit,publication_issues}') x
             WHERE x->>'code'='ALERT_EVALUATION_RECOMMENDED'
               AND x->>'severity'='warning'
       )
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{audit,publication_issues}') x
             WHERE x->>'code'='NO_EXPERT_REVIEW_OF_MONITOR'
               AND x->>'severity'='warning'
       ) THEN
        RAISE EXCEPTION 'MONV-T12 FAIL — warning/hardening issue projection mismatch';
    END IF;
END;
$t$;

-- MONV-T13 — InvestigationVersion target remains explicitly non-product.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000007'
    );

    IF v#>>'{target,target_type}'<>'investigation_version'
       OR v#>>'{target,target_investigation_id}'<>'OES-I-2026-MON001'
       OR v#>>'{target,depth_level}'<>'N2'
       OR (v#>'{target,assurance_level}') IS DISTINCT FROM 'null'::jsonb
       OR (v#>'{target,currency}') IS DISTINCT FROM 'null'::jsonb
       OR (v#>'{target,scientific_conclusion}') IS DISTINCT FROM 'null'::jsonb
       OR v#>>'{audit,publishable}'<>'false'
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{audit,publication_issues}') x
             WHERE x->>'code'='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL'
               AND x->>'severity'='error'
       ) THEN
        RAISE EXCEPTION 'MONV-T13 FAIL — Investigation target/M3 blocker projection mismatch: %',v;
    END IF;
END;
$t$;

-- MONV-T14 — AI verification is not projected as human verification.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF v#>>'{latest_completed_cycle,verification,status}'<>'ai_verified'
       OR v#>>'{latest_completed_cycle,verification,verifier_actor_type}'<>'ai_system'
       OR EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v->'quality_controls') q
             WHERE q->>'actor_type' IN ('human_reviewer','human_expert')
       )
       OR EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{audit,assurance_records}') a
             WHERE a->>'assurance_type'='expert_independent_review'
       ) THEN
        RAISE EXCEPTION 'MONV-T14 FAIL — human verification/expert review was inferred';
    END IF;
END;
$t$;

-- MONV-T15 — View is deterministic for unchanged persisted state.
DO $t$
DECLARE v1 jsonb; v2 jsonb;
BEGIN
    v1:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );
    v2:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000005'
    );

    IF v1 IS DISTINCT FROM v2 THEN
        RAISE EXCEPTION 'MONV-T15 FAIL — View output is not deterministic';
    END IF;
END;
$t$;

-- MONV-T16 — wrong product type remains blocked rather than masquerading as Monitor.
DO $t$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_monitor_view(
        'e5100000-0000-0000-0000-000000000003'
    );

    IF v#>>'{identity,product_type}'<>'evidence_sheet'
       OR v#>>'{audit,publishable}'<>'false'
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(v#>'{audit,publication_issues}') x
             WHERE x->>'code'='WRONG_PRODUCT_TYPE'
               AND x->>'severity'='error'
       ) THEN
        RAISE EXCEPTION 'MONV-T16 FAIL — wrong product type not transparently blocked';
    END IF;
END;
$t$;

-- MONV-T17 — View functions are declared STABLE/read-only projection functions.
DO $t$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_proc p
          JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='product'
           AND p.proname='evidence_monitor_view'
           AND p.provolatile='s'
    ) OR NOT EXISTS (
        SELECT 1
          FROM pg_proc p
          JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='maintenance'
           AND p.proname='monitor_cycle_projection'
           AND p.provolatile='s'
    ) OR NOT EXISTS (
        SELECT 1
          FROM pg_proc p
          JOIN pg_namespace n ON n.oid=p.pronamespace
         WHERE n.nspname='product'
           AND p.proname='evidence_monitor_target_projection'
           AND p.provolatile='s'
    ) THEN
        RAISE EXCEPTION 'MONV-T17 FAIL — projection function volatility is not STABLE';
    END IF;
END;
$t$;

SELECT 'MONV-T01–T17 PASS — EvidenceMonitorView 0.1 projection semantics validated'
AS evidence_monitor_view_tests_status;
