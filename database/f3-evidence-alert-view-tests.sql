-- F3 EvidenceAlertView 0.1 tests — EAV-T01–T15
-- Requires migrations through 026 + Monitor + Alert fixtures.

-- EAV-T01
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF v->>'schema_version'<>'oes.evidence_alert_view/0.1'
 OR v#>>'{identity,product_id}'<>'OES-P-2026-ALT001'
 OR v#>>'{identity,product_type}'<>'evidence_alert'
 OR v#>>'{identity,editorial_status}'<>'published'
 THEN RAISE EXCEPTION 'EAV-T01 FAIL'; END IF;
END $t$;

-- EAV-T02
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF v#>>'{source_context,investigation_id}'<>'OES-I-2026-MON002'
 OR v#>>'{source_context,investigation_type}'<>'evidence_monitoring'
 OR v#>>'{source_context,maintenance_level}'<>'M2'
 THEN RAISE EXCEPTION 'EAV-T02 FAIL'; END IF;
END $t$;

-- EAV-T03
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF v#>>'{alert,classification}'<>'relevant'
 OR v#>>'{alert,reassessment_priority}'<>'priority'
 OR v#>>'{alert,lifecycle_status}'<>'evaluation'
 OR v#>>'{alert,verification,status}'<>'human_verified'
 OR v#>>'{alert,verification,verifier_actor_type}'<>'human_reviewer'
 THEN RAISE EXCEPTION 'EAV-T03 FAIL'; END IF;
END $t$;

-- EAV-T04
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF v#>>'{target,target_type}'<>'product_version'
 OR v#>>'{target,target_product_id}'<>'OES-P-2026-MON001'
 OR v#>>'{target,assurance_level}'<>'A0'
 OR v#>>'{target,currency,status}'<>'under_evaluation'
 OR v#>>'{target,scientific_conclusion}'<>'Synthetic target conclusion.'
 THEN RAISE EXCEPTION 'EAV-T04 FAIL'; END IF;
END $t$;

-- EAV-T05
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF jsonb_array_length(v->'sources')<>2
 OR v#>>'{sources,0,source_role}'<>'primary'
 OR v#>>'{sources,0,source_type}'<>'candidate_assessment'
 OR v#>>'{sources,0,monitor_origin,cycle_no}'<>'2'
 OR v#>>'{sources,1,source_type}'<>'evidence_event'
 OR v#>>'{sources,1,monitor_origin,event_type}'<>'regulatory_update'
 THEN RAISE EXCEPTION 'EAV-T05 FAIL'; END IF;
END $t$;

-- EAV-T06
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF jsonb_array_length(v->'affected_dimensions')<>2
 OR v#>>'{affected_dimensions,0,dimension_code}'<>'conclusion'
 OR v#>>'{affected_dimensions,1,dimension_code}'<>'certainty'
 THEN RAISE EXCEPTION 'EAV-T06 FAIL'; END IF;
END $t$;

-- EAV-T07
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF v#>>'{audit,assurance_level}'<>'A2'
 OR v#>>'{audit,target_assurance_level}'<>'A0'
 OR v#>>'{audit,publishable}'<>'true'
 OR v#>>'{audit,expert_independent_review_present}'<>'false'
 OR jsonb_array_length(v#>'{audit,projection_hardening_issues}')<>0
 THEN RAISE EXCEPTION 'EAV-T07 FAIL'; END IF;
END $t$;

-- EAV-T08 — warnings remain visible.
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') x WHERE x->>'code'='NO_EXPERT_REVIEW_OF_ALERT')
 OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') x WHERE x->>'code'='TARGET_CURRENCY_UNDER_EVALUATION')
 OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') x WHERE x->>'code'='TARGET_ASSURANCE_BELOW_A2')
 THEN RAISE EXCEPTION 'EAV-T08 FAIL'; END IF;
END $t$;

-- EAV-T09 — AI-only Alert B remains blocked.
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000002');
 IF v#>>'{identity,editorial_status}'<>'under_review'
 OR v#>>'{alert,verification,status}'<>'ai_verified'
 OR v#>>'{audit,assurance_level}'<>'A1'
 OR v#>>'{audit,publishable}'<>'false'
 OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') x WHERE x->>'code'='MISSING_HUMAN_VERIFICATION')
 THEN RAISE EXCEPTION 'EAV-T09 FAIL'; END IF;
END $t$;

-- EAV-T10 — direct critical Alert C keeps Investigation target semantics.
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000003');
 IF v#>>'{target,target_type}'<>'investigation_version'
 OR v#>>'{target,target_investigation_id}'<>'OES-I-2026-MON001'
 OR (v#>'{target,assurance_level}') IS DISTINCT FROM 'null'::jsonb
 OR (v#>'{target,currency}') IS DISTINCT FROM 'null'::jsonb
 OR (v#>'{target,scientific_conclusion}') IS DISTINCT FROM 'null'::jsonb
 OR v#>>'{alert,classification}'<>'critical'
 OR v#>>'{alert,reassessment_priority}'<>'urgent'
 OR v#>>'{audit,publishable}'<>'true'
 THEN RAISE EXCEPTION 'EAV-T10 FAIL'; END IF;
END $t$;

-- EAV-T11 — direct-source warnings are explicit, not automation.
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000003');
 IF v#>>'{sources,0,source_type}'<>'uri'
 OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') x WHERE x->>'code'='ALERT_SOURCE_OUTSIDE_MONITOR')
 OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') x WHERE x->>'code'='CRITICAL_WITHOUT_EXPERT_REVIEW')
 THEN RAISE EXCEPTION 'EAV-T11 FAIL'; END IF;
END $t$;

-- EAV-T12 — lineage exposes target dependencies.
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v#>'{lineage,dependencies}') x
    WHERE x->>'dependency_type'='maintenance_alert_target'
      AND x->>'status'='active')
 THEN RAISE EXCEPTION 'EAV-T12 FAIL'; END IF;
END $t$;

-- EAV-T13 — Alert has no scientific conclusion/currentness of its own.
DO $t$ DECLARE v jsonb; BEGIN
 v:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF EXISTS (SELECT 1 FROM product.currency_state WHERE product_version_uuid='a7100000-0000-0000-0000-000000000001')
 OR EXISTS (SELECT 1 FROM product.product_version WHERE version_uuid='a7100000-0000-0000-0000-000000000001' AND conclusion_text IS NOT NULL)
 THEN RAISE EXCEPTION 'EAV-T13 FAIL'; END IF;
END $t$;

-- EAV-T14 — deterministic output.
DO $t$ DECLARE v1 jsonb; v2 jsonb; BEGIN
 v1:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 v2:=product.evidence_alert_view('a7100000-0000-0000-0000-000000000001');
 IF v1 IS DISTINCT FROM v2 THEN RAISE EXCEPTION 'EAV-T14 FAIL'; END IF;
END $t$;

-- EAV-T15 — function is STABLE.
DO $t$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE n.nspname='product' AND p.proname='evidence_alert_view' AND p.provolatile='s')
 THEN RAISE EXCEPTION 'EAV-T15 FAIL'; END IF;
END $t$;

SELECT 'EAV-T01–T15 PASS — EvidenceAlertView 0.1 projection semantics validated' AS evidence_alert_view_status;
