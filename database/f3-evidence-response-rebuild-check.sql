-- OES Fase 3 — Evidence Response N1 rebuild assertion
DO $errebuild$
DECLARE v jsonb; ok boolean;
BEGIN
  SELECT product.evidence_response_view('91000000-0000-0000-0000-000000000301') INTO v;
  SELECT product.evidence_response_is_publishable('91000000-0000-0000-0000-000000000301') INTO ok;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000901'
     OR v#>>'{identity,product_type}' <> 'evidence_response'
     OR v#>>'{routing,depth_level}' <> 'N1'
     OR v#>>'{audit,assurance_level}' <> 'A2'
     OR v#>>'{audit,expert_independent_reviewed}' <> 'false'
     OR jsonb_array_length(v->'key_sources') <> 1
     OR jsonb_array_length(v->'key_results') <> 1
     OR NOT ok
  THEN
      RAISE EXCEPTION 'ER-T14 FAIL: rebuilt N1 EvidenceResponseView contract invalid';
  END IF;

  IF NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
      WHERE i->>'issue_code'='NO_EXPERT_INDEPENDENT_REVIEW'
  ) THEN
      RAISE EXCEPTION 'ER-T14 FAIL: rebuilt view missing no-expert disclosure';
  END IF;

  RAISE NOTICE 'ER-T14 PASS — rebuild produced publishable A2 N1 EvidenceResponseView';
END
$errebuild$;

-- Real N1-01 must also rebuild from zero in its intended A0/under_review state.
\ir f3-real-case-n1-music-anxiety.sql
\ir f3-real-case-n1-rebuild-check.sql
