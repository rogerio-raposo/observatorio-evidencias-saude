-- OES Fase 3 — Real N3-01 tests, part B
-- Requires part A prerequisites and real N3 materialization.

-- RN3-T09 — appraisals are differentiated and explicitly AI-only.
DO $t09$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF jsonb_array_length(v->'risk_of_bias') <> 10 THEN
    RAISE EXCEPTION 'RN3-T09 FAIL: expected 10 appraisal records';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'risk_of_bias') r
    WHERE r->>'overall_judgement'='high' AND r->>'framework'='RoB 2'
  ) OR NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'risk_of_bias') r
    WHERE r->>'overall_judgement'='low' AND r->>'framework'='RoB 2'
  ) THEN
    RAISE EXCEPTION 'RN3-T09 FAIL: differentiated RoB 2 judgements missing';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'risk_of_bias') r
    WHERE r->>'verification_status' <> 'ai_verified_only'
  ) THEN
    RAISE EXCEPTION 'RN3-T09 FAIL: appraisal falsely implies human verification';
  END IF;
  RAISE NOTICE 'RN3-T09 PASS — appraisals differentiated and explicitly AI-only';
END
$t09$;

-- RN3-T10 — four narrative syntheses; no meta-analysis fabricated.
DO $t10$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF jsonb_array_length(v->'syntheses') <> 4 THEN
    RAISE EXCEPTION 'RN3-T10 FAIL: expected four linked syntheses';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'syntheses') s
    WHERE lower(s->>'synthesis_type') LIKE '%meta%'
  ) THEN
    RAISE EXCEPTION 'RN3-T10 FAIL: meta-analysis was fabricated';
  END IF;
  RAISE NOTICE 'RN3-T10 PASS — four narrative syntheses; no artificial meta-analysis';
END
$t10$;

-- RN3-T11 — four experimental GRADE assessments match documented levels.
DO $t11$
DECLARE v jsonb;
DECLARE low_n integer;
DECLARE very_low_n integer;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;

  SELECT count(*) INTO low_n
  FROM jsonb_array_elements(v->'certainty') c
  WHERE c->>'final_level'='low';

  SELECT count(*) INTO very_low_n
  FROM jsonb_array_elements(v->'certainty') c
  WHERE c->>'final_level'='very_low';

  IF jsonb_array_length(v->'certainty') <> 4
     OR low_n <> 3 OR very_low_n <> 1
  THEN
    RAISE EXCEPTION 'RN3-T11 FAIL: expected 3 LOW + 1 VERY LOW GRADE';
  END IF;
  RAISE NOTICE 'RN3-T11 PASS — experimental GRADE is three LOW and one VERY LOW';
END
$t11$;

-- RN3-T12 — SoF artifact is traceable to canonical Document 109 blob.
DO $t12$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF v#>>'{summary_of_findings,artifact_uuid}' <> 'e9000000-0000-0000-0000-000000000002'
     OR v#>>'{summary_of_findings,content_hash}' <> 'a23b6bc0988ae02b42a243a6e462df7c96bd407b'
  THEN
    RAISE EXCEPTION 'RN3-T12 FAIL: SoF artifact/hash mismatch';
  END IF;
  RAISE NOTICE 'RN3-T12 PASS — SoF artifact points to canonical Document 109 blob';
END
$t12$;

-- RN3-T13 — AI quality controls remain unqualified/non-independent.
DO $t13$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF jsonb_array_length(v->'quality_controls') <> 6
     OR v#>>'{audit,qualified_controls_satisfied}' <> 'false'
  THEN
    RAISE EXCEPTION 'RN3-T13 FAIL: AI QC / qualified-control state mismatch';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'quality_controls') q
    WHERE q->>'actor_type' <> 'ai_system'
       OR q->>'qualified' <> 'false'
       OR q->>'independent' <> 'false'
  ) THEN
    RAISE EXCEPTION 'RN3-T13 FAIL: AI QC impersonates human qualification/independence';
  END IF;
  RAISE NOTICE 'RN3-T13 PASS — six AI controls visible; none satisfy human-qualified controls';
END
$t13$;

-- RN3-T14 — conclusion/limitations remain calibrated.
DO $t14$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF position('podem reduzir' in lower(v#>>'{conclusion,text}')) = 0
     OR position('segurança' in lower(v#>>'{conclusion,text}')) = 0
     OR position('europe pmc' in lower(v#>>'{rapid_method_limitations,summary}')) = 0
  THEN
    RAISE EXCEPTION 'RN3-T14 FAIL: calibrated conclusion or method limitation missing';
  END IF;
  RAISE NOTICE 'RN3-T14 PASS — calibrated conclusion and Europe PMC limitation preserved';
END
$t14$;

-- RN3-T15 — no assurance is inferred before adversarial verification.
DO $t15$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='e1000000-0000-0000-0000-000000000701'
  ) THEN
    RAISE EXCEPTION 'RN3-T15 FAIL: assurance was fabricated before verification';
  END IF;
  IF product.rapid_evidence_synthesis_assurance_level(
       'e1000000-0000-0000-0000-000000000701'
     ) <> 'A0'
  THEN
    RAISE EXCEPTION 'RN3-T15 FAIL: expected assurance A0';
  END IF;
  RAISE NOTICE 'RN3-T15 PASS — no owner/expert/AI assurance inferred; case remains A0';
END
$t15$;
