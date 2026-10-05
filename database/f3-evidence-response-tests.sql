-- OES Fase 3 — Evidence Response N1 contract tests

-- ER-T01 — baseline N1 fixture is A2 and publishable.
DO $t01$
BEGIN
  IF product.evidence_response_assurance_level('91000000-0000-0000-0000-000000000301') <> 'A2' THEN
    RAISE EXCEPTION 'ER-T01 FAIL: expected A2';
  END IF;
  IF NOT product.evidence_response_is_publishable('91000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ER-T01 FAIL: A2 N1 fixture unexpectedly blocked';
  END IF;
  RAISE NOTICE 'ER-T01 PASS — N1 fixture is A2 and publishable';
END
$t01$;

-- ER-T02 — Synthesis and Certainty are optional; warnings remain explicit.
DO $t02$
BEGIN
  IF EXISTS (SELECT 1 FROM product.synthesis_link WHERE product_version_uuid='91000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ER-T02 FAIL: fixture unexpectedly has Synthesis link';
  END IF;
  IF EXISTS (SELECT 1 FROM product.certainty_link WHERE product_version_uuid='91000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ER-T02 FAIL: fixture unexpectedly has Certainty link';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('91000000-0000-0000-0000-000000000301')
    WHERE issue_code='NO_FORMAL_CERTAINTY' AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'ER-T02 FAIL: NO_FORMAL_CERTAINTY warning missing';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('91000000-0000-0000-0000-000000000301')
    WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW' AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'ER-T02 FAIL: no-expert warning missing';
  END IF;
  RAISE NOTICE 'ER-T02 PASS — no mandatory Synthesis/Certainty and warnings explicit';
END
$t02$;

-- ER-T03 — direct provenance yields exactly one traceable reference.
DO $t03$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n
    FROM product.evidence_response_reference_reports('91000000-0000-0000-0000-000000000301');
  IF n <> 1 THEN
    RAISE EXCEPTION 'ER-T03 FAIL: expected 1 reference, got %', n;
  END IF;
  RAISE NOTICE 'ER-T03 PASS — direct provenance yields one reference';
END
$t03$;

-- ER-T04 — EvidenceResponseView exposes decisive source and direct key result.
DO $t04$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('91000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{schema_version}' <> 'oes.evidence_response_view/0.1' THEN
    RAISE EXCEPTION 'ER-T04 FAIL: wrong schema version';
  END IF;
  IF v#>>'{routing,depth_level}' <> 'N1' THEN
    RAISE EXCEPTION 'ER-T04 FAIL: view depth is not N1';
  END IF;
  IF jsonb_array_length(v->'key_sources') <> 1 THEN
    RAISE EXCEPTION 'ER-T04 FAIL: expected one key source';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_sources') x
    WHERE x->'roles' ? 'decisive'
  ) THEN
    RAISE EXCEPTION 'ER-T04 FAIL: decisive role not derived';
  END IF;
  IF jsonb_array_length(v->'key_results') <> 1 THEN
    RAISE EXCEPTION 'ER-T04 FAIL: expected one direct key result';
  END IF;
  IF v#>>'{key_results,0,source_value,measure}' <> 'synthetic_effect' THEN
    RAISE EXCEPTION 'ER-T04 FAIL: key result source_value not projected';
  END IF;
  RAISE NOTICE 'ER-T04 PASS — view projects decisive source and direct key result';
END
$t04$;

-- ER-T05 — N1 method explicitly remains selective/non-exhaustive.
DO $t05$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('91000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{method,non_exhaustive}' <> 'true' THEN
    RAISE EXCEPTION 'ER-T05 FAIL: non_exhaustive flag missing';
  END IF;
  IF jsonb_array_length(v#>'{method,searches}') <> 1 THEN
    RAISE EXCEPTION 'ER-T05 FAIL: search not projected';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('91000000-0000-0000-0000-000000000301')
    WHERE issue_code='SINGLE_SEARCH_SOURCE' AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'ER-T05 FAIL: single-search-source warning missing';
  END IF;
  RAISE NOTICE 'ER-T05 PASS — selective search is explicit';
END
$t05$;

-- ER-T06 — generic assurance preserves Evidence Sheet behavior.
DO $t06$
BEGIN
  IF product.assurance_level('71000000-0000-0000-0000-000000000001')
     IS DISTINCT FROM product.evidence_sheet_assurance_level('71000000-0000-0000-0000-000000000001') THEN
    RAISE EXCEPTION 'ER-T06 FAIL: generic assurance diverges from Evidence Sheet wrapper';
  END IF;
  RAISE NOTICE 'ER-T06 PASS — generic assurance is backward-compatible';
END
$t06$;

-- ER-T07 — removing owner approval reduces assurance and blocks.
BEGIN;
UPDATE product.assurance_record
   SET status='superseded'
 WHERE assurance_uuid='94000000-0000-0000-0000-000000000302';
DO $t07$
BEGIN
  IF product.evidence_response_assurance_level('91000000-0000-0000-0000-000000000301') <> 'A1' THEN
    RAISE EXCEPTION 'ER-T07 FAIL: expected A1 without owner approval';
  END IF;
  IF product.evidence_response_is_publishable('91000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ER-T07 FAIL: product publishable without owner approval';
  END IF;
  RAISE NOTICE 'ER-T07 PASS — owner approval required for A2/publication';
END
$t07$;
ROLLBACK;

-- ER-T08 — N1 gate rejects a primary Investigation rerouted to N2.
BEGIN;
UPDATE investigation.investigation_version
   SET depth_level='N2'
 WHERE version_uuid='91000000-0000-0000-0000-000000000002';
DO $t08$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('91000000-0000-0000-0000-000000000301')
    WHERE issue_code='PRIMARY_INVESTIGATION_NOT_N1' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER-T08 FAIL: wrong depth did not block';
  END IF;
  RAISE NOTICE 'ER-T08 PASS — gate enforces N1 routing';
END
$t08$;
ROLLBACK;

-- ER-T09 — active expert rejection blocks without changing derived A2.
BEGIN;
INSERT INTO product.assurance_record(
 assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,independent_flag,decision,performed_at,notes,status
) VALUES (
 '94000000-0000-0000-0000-000000000303',
 '91000000-0000-0000-0000-000000000301',
 'expert_independent_review','N1_TEST_EXPERT','human_expert',true,'rejected',
 TIMESTAMPTZ '2026-10-05 03:50:00-03','Synthetic rejection','active'
);
DO $t09$
BEGIN
  IF product.evidence_response_assurance_level('91000000-0000-0000-0000-000000000301') <> 'A2' THEN
    RAISE EXCEPTION 'ER-T09 FAIL: rejection should not fabricate a lower assurance label';
  END IF;
  IF product.evidence_response_is_publishable('91000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ER-T09 FAIL: active expert rejection did not block';
  END IF;
  RAISE NOTICE 'ER-T09 PASS — expert rejection blocks publication';
END
$t09$;
ROLLBACK;

-- ER-T10 — invalidated upstream decisive report blocks publication.
BEGIN;
UPDATE core.entity_version
   SET version_status='invalidated'
 WHERE version_uuid='91000000-0000-0000-0000-000000000201';
DO $t10$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('91000000-0000-0000-0000-000000000301')
    WHERE issue_code='INVALIDATED_UPSTREAM_DEPENDENCY' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER-T10 FAIL: invalidated source did not block';
  END IF;
  RAISE NOTICE 'ER-T10 PASS — invalidated upstream source blocks publication';
END
$t10$;
ROLLBACK;

-- ER-T11 — missing completed search blocks.
BEGIN;
UPDATE investigation.search SET status='archived'
 WHERE search_uuid='92000000-0000-0000-0000-000000000001';
DO $t11$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('91000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_SEARCH_RECORD' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER-T11 FAIL: missing completed search did not block';
  END IF;
  RAISE NOTICE 'ER-T11 PASS — completed structured search required';
END
$t11$;
ROLLBACK;

-- ER-T12 — removing direct provenance removes the traceable source and blocks.
BEGIN;
UPDATE provenance.record SET status='superseded'
 WHERE target_version_uuid='91000000-0000-0000-0000-000000000301';
DO $t12$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('91000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_TRACEABLE_SOURCE' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER-T12 FAIL: missing traceable source did not block';
  END IF;
  RAISE NOTICE 'ER-T12 PASS — field-level provenance is publication-critical';
END
$t12$;
ROLLBACK;

-- ER-T13 — view audit exposes A2, publishable and no-expert warning.
DO $t13$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('91000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{audit,assurance_level}' <> 'A2' OR v#>>'{audit,publishable}' <> 'true' THEN
    RAISE EXCEPTION 'ER-T13 FAIL: audit state is not A2/publishable';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='NO_EXPERT_INDEPENDENT_REVIEW'
  ) THEN
    RAISE EXCEPTION 'ER-T13 FAIL: no-expert warning absent from view';
  END IF;
  RAISE NOTICE 'ER-T13 PASS — audit state and disclosure projected';
END
$t13$;

-- ---------------------------------------------------------------------------
-- REAL N1-01 — initial A0/under_review integration
-- ---------------------------------------------------------------------------
\ir f3-real-case-n1-music-anxiety.sql
\ir f3-real-case-n1-tests.sql

-- Export the real EvidenceResponseView for the existing renderer validation step.
\copy (SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701')::text) TO 's5-artifacts/real-n1-01-view.json'

-- ---------------------------------------------------------------------------
-- REAL N1-01 — adversarial revision 01 / ProductVersion 2
-- Version lifecycle timestamps are generated at runtime to preserve temporal invariants.
-- ---------------------------------------------------------------------------
\ir f3-real-case-n1-revision-01.sql
\ir f3-real-case-n1-revision-01-tests.sql

-- Replace the renderer snapshot with the current corrected ProductVersion.
\copy (SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702')::text) TO 's5-artifacts/real-n1-01-view.json'
