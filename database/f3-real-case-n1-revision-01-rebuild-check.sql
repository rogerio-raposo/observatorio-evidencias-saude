-- OES Fase 3 — Real N1-01 revision 01 rebuild assertion
DO $rn1r1rebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000501'
     OR v#>>'{identity,version_no}' <> '2'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
     OR jsonb_array_length(v->'key_sources') <> 7
     OR jsonb_array_length(v->'key_results') <> 3
  THEN
    RAISE EXCEPTION 'RN1-R1-T09 FAIL: rebuilt corrected ProductVersion 2 invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM core.entity_version
    WHERE version_uuid='a1000000-0000-0000-0000-000000000702'
      AND supersedes_version_uuid='a1000000-0000-0000-0000-000000000701'
      AND version_status='current'
  ) THEN
    RAISE EXCEPTION 'RN1-R1-T09 FAIL: version lineage missing';
  END IF;

  RAISE NOTICE 'RN1-R1-T09 PASS — rebuild preserves corrected ProductVersion 2 and history';
END
$rn1r1rebuild$;
