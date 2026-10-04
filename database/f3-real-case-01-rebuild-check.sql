-- OES Fase 3 — Real Case 01 rebuild assertion
DO $rc01rebuild$
DECLARE v jsonb; ok boolean;
BEGIN
  SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000701'
  ) INTO v;

  SELECT product.evidence_sheet_is_publishable(
      '81000000-0000-0000-0000-000000000701'
  ) INTO ok;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000401'
     OR v#>>'{routing,depth_level}' <> 'N2'
     OR jsonb_array_length(v->'priority_results') <> 3
     OR v#>>'{priority_results,0,synthesis,result_summary,reported_study_count}' <> '10'
     OR v#>>'{priority_results,1,certainty,final_level}' <> 'moderate'
     OR v#>>'{audit,assurance_level}' <> 'A1'
     OR v#>>'{audit,expert_independent_reviewed}' <> 'false'
     OR ok
  THEN
      RAISE EXCEPTION 'RC01-T10 FAIL: rebuilt real-case preview contract invalid';
  END IF;

  RAISE NOTICE 'RC01-T10 PASS — rebuild produced non-publishable real-case EvidenceSheetView preview';
END
$rc01rebuild$;
