-- OES Fase 3 — Evidence Scan N0 rebuild assertion
DO $esrebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('b1000000-0000-0000-0000-000000000301') INTO v;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-001001'
     OR v#>>'{identity,product_type}' <> 'evidence_scan'
     OR v#>>'{investigation,depth_level}' <> 'N0'
     OR v#>>'{audit,assurance_level}' <> 'A2'
     OR v#>>'{audit,publishable}' <> 'true'
     OR v#>>'{maturity,category}' <> 'well_synthesized'
     OR v#>>'{routing_recommendation,recommendation,target}' <> 'N1'
     OR jsonb_array_length(v->'central_sources') <> 2
     OR jsonb_array_length(v->'references') <> 2
  THEN
    RAISE EXCEPTION 'ES-T15 FAIL: rebuilt EvidenceScanView contract invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='NO_EXPERT_INDEPENDENT_REVIEW'
  ) THEN
    RAISE EXCEPTION 'ES-T15 FAIL: rebuilt view missing no-expert disclosure';
  END IF;

  RAISE NOTICE 'ES-T15 PASS — rebuild produced publishable A2 N0 EvidenceScanView';
END
$esrebuild$;

-- ---------------------------------------------------------------------------
-- REAL N0-01 — rebuild from zero
-- ---------------------------------------------------------------------------
\ir f3-real-case-n0-genai-mental-health.sql
\ir f3-real-case-n0-rebuild-check.sql
