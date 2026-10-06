-- OES Fase 3 — Overview of Reviews positive contract tests
-- Requires migration 019 + f3-overview-of-reviews-fixtures.sql.

-- OV-T01 — formal fixture is publishable A3.
DO $test$
DECLARE errs jsonb;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(x)),'[]'::jsonb)
      INTO errs
      FROM product.overview_of_reviews_publication_issues(
          'f9100000-0000-0000-0000-000000000020'
      ) x
     WHERE severity='error';

    IF jsonb_array_length(errs)<>0 THEN
        RAISE EXCEPTION 'OV-T01 FAIL — formal fixture has publication errors: %',errs;
    END IF;

    IF product.assurance_level(
        'f9100000-0000-0000-0000-000000000020'
    )<>'A3'
       OR NOT product.overview_of_reviews_is_publishable(
           'f9100000-0000-0000-0000-000000000020'
       )
    THEN
        RAISE EXCEPTION 'OV-T01 FAIL — expected publishable A3';
    END IF;
END;
$test$;

-- OV-T02 — 3 ReviewItems / 5 unique primary Studies.
DO $test$
DECLARE reviews integer; unique_studies integer;
BEGIN
    SELECT count(*) INTO reviews
      FROM overview.review_item
     WHERE investigation_version_uuid=
           'f9100000-0000-0000-0000-000000000002'
       AND status='active';

    SELECT unique_primary_study_count
      INTO unique_studies
      FROM overview.overlap_metrics(
          'f9100000-0000-0000-0000-000000000002',
          'f9520000-0000-0000-0000-000000000001'
      );

    IF reviews<>3 OR unique_studies<>5 THEN
        RAISE EXCEPTION
            'OV-T02 FAIL — reviews=% unique studies=%',
            reviews,unique_studies;
    END IF;
END;
$test$;

-- OV-T03 — membership occurrence count = 9.
DO $test$
DECLARE n integer;
BEGIN
    SELECT study_occurrence_count
      INTO n
      FROM overview.overlap_metrics(
          'f9100000-0000-0000-0000-000000000002',
          'f9520000-0000-0000-0000-000000000001'
      );

    IF n<>9 THEN
        RAISE EXCEPTION 'OV-T03 FAIL — expected 9 memberships, found %',n;
    END IF;
END;
$test$;

-- OV-T04 — CCA = 0.4.
DO $test$
DECLARE c numeric; calc boolean;
BEGIN
    SELECT cca,cca_calculable
      INTO c,calc
      FROM overview.overlap_metrics(
          'f9100000-0000-0000-0000-000000000002',
          'f9520000-0000-0000-0000-000000000001'
      );

    IF NOT calc OR abs(c-0.4)>0.000001 THEN
        RAISE EXCEPTION 'OV-T04 FAIL — expected calculable CCA 0.4, found % / %',c,calc;
    END IF;
END;
$test$;

-- OV-T05 — pairwise intersections are 2,1,2 with Jaccard 0.5,0.2,0.5.
DO $test$
DECLARE n integer;
BEGIN
    SELECT count(*)
      INTO n
      FROM overview.pairwise_overlap(
          'f9520000-0000-0000-0000-000000000001'
      )
     WHERE
        (
          review_item_a='f9500000-0000-0000-0000-000000000101'
          AND review_item_b='f9500000-0000-0000-0000-000000000102'
          AND shared_studies=2
          AND abs(jaccard-0.5)<0.000001
        )
        OR
        (
          review_item_a='f9500000-0000-0000-0000-000000000101'
          AND review_item_b='f9500000-0000-0000-0000-000000000103'
          AND shared_studies=1
          AND abs(jaccard-0.2)<0.000001
        )
        OR
        (
          review_item_a='f9500000-0000-0000-0000-000000000102'
          AND review_item_b='f9500000-0000-0000-0000-000000000103'
          AND shared_studies=2
          AND abs(jaccard-0.5)<0.000001
        );

    IF n<>3 THEN
        RAISE EXCEPTION 'OV-T05 FAIL — pairwise overlap mismatch; matched % rows',n;
    END IF;
END;
$test$;

-- OV-T06 — Review A has an update Report but only one ReviewItem.
DO $test$
DECLARE items integer; reports integer;
BEGIN
    SELECT count(*)
      INTO items
      FROM overview.review_item ri
      JOIN evidence.study_version sv
        ON sv.version_uuid=ri.review_study_version_uuid
     WHERE sv.entity_uuid='f9300000-0000-0000-0000-000000000101'
       AND ri.status='active';

    SELECT count(*)
      INTO reports
      FROM evidence.study_report_link
     WHERE study_entity_uuid='f9300000-0000-0000-0000-000000000101'
       AND status='active';

    IF items<>1 OR reports<>2 THEN
        RAISE EXCEPTION 'OV-T06 FAIL — Review A items=% reports=%',items,reports;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM evidence.report_relation
         WHERE source_report_entity_uuid='f9300000-0000-0000-0000-000000000402'
           AND target_report_entity_uuid='f9300000-0000-0000-0000-000000000401'
           AND relation_type='update_of'
           AND status='active'
    ) THEN
        RAISE EXCEPTION 'OV-T06 FAIL — update relation absent';
    END IF;
END;
$test$;

-- OV-T07 — one active ROBIS per ReviewItem; Review C high.
DO $test$
DECLARE n integer;
BEGIN
    SELECT count(*)
      INTO n
      FROM overview.review_item ri
      JOIN evidence.study_version sv
        ON sv.version_uuid=ri.review_study_version_uuid
      JOIN appraisal.risk_assessment_version rav
        ON rav.investigation_version_uuid=ri.investigation_version_uuid
       AND rav.target_entity_uuid=sv.entity_uuid
       AND lower(rav.framework)='robis'
       AND rav.status='active'
     WHERE ri.investigation_version_uuid=
           'f9100000-0000-0000-0000-000000000002'
       AND ri.status='active';

    IF n<>3 THEN
        RAISE EXCEPTION 'OV-T07 FAIL — expected 3 ROBIS assessments, found %',n;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM appraisal.risk_assessment_version
         WHERE version_uuid='f9310000-0000-0000-0000-000000000703'
           AND overall_judgement='high'
    ) THEN
        RAISE EXCEPTION 'OV-T07 FAIL — Review C high ROBIS missing';
    END IF;
END;
$test$;

-- OV-T08 — Review B is uniquely prioritized.
DO $test$
BEGIN
    IF (
        SELECT count(*)
          FROM overview.cluster_membership
         WHERE cluster_uuid='f9520000-0000-0000-0000-000000000001'
           AND status='active'
           AND analysis_disposition='prioritized'
    )<>1
       OR NOT EXISTS (
          SELECT 1
            FROM overview.cluster_membership
           WHERE cluster_uuid='f9520000-0000-0000-0000-000000000001'
             AND review_item_uuid='f9500000-0000-0000-0000-000000000102'
             AND analysis_disposition='prioritized'
             AND status='active'
       )
    THEN
        RAISE EXCEPTION 'OV-T08 FAIL — Review B is not uniquely prioritized';
    END IF;
END;
$test$;

-- OV-T09 — OutcomeEvidence Result belongs to each Review Study.
DO $test$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM overview.outcome_evidence oe
          JOIN overview.review_item ri
            ON ri.review_item_uuid=oe.review_item_uuid
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
          JOIN evidence.result_version rv
            ON rv.version_uuid=oe.result_version_uuid
          JOIN evidence.result r
            ON r.entity_uuid=rv.entity_uuid
         WHERE oe.status='active'
           AND r.study_entity_uuid<>sv.entity_uuid
    ) THEN
        RAISE EXCEPTION 'OV-T09 FAIL — OutcomeEvidence review mismatch';
    END IF;
END;
$test$;

-- OV-T10 — certainty links preserved for Reviews A and B only.
DO $test$
BEGIN
    IF (
        SELECT count(*)
          FROM overview.outcome_evidence
         WHERE status='active'
           AND certainty_assessment_version_uuid IS NOT NULL
    )<>2 THEN
        RAISE EXCEPTION 'OV-T10 FAIL — expected two certainty links';
    END IF;
END;
$test$;

-- OV-T11 — concordance assessment projected and human consensus.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF jsonb_array_length(v->'concordance')<>1
       OR v#>>'{concordance,0,state}'<>'magnitude_discordant'
       OR v#>>'{concordance,0,verification_status}'<>'human_consensus'
    THEN
        RAISE EXCEPTION 'OV-T11 FAIL — concordance projection mismatch';
    END IF;
END;
$test$;

-- OV-T12 — reference list privileges Review Reports (4), not primary-study reports.
DO $test$
DECLARE n integer;
BEGIN
    SELECT count(*)
      INTO n
      FROM product.overview_reference_reports(
          'f9100000-0000-0000-0000-000000000020'
      );

    IF n<>4 THEN
        RAISE EXCEPTION 'OV-T12 FAIL — expected 4 review references, found %',n;
    END IF;
END;
$test$;

-- OV-T13 — OverviewOfReviewsView smoke test.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF v->>'schema_version'<>'oes.overview_of_reviews_view/0.1'
       OR v#>>'{identity,product_id}'<>'OES-P-2026-001501'
       OR jsonb_array_length(v->'review_items')<>3
       OR jsonb_array_length(v->'primary_study_membership')<>9
       OR jsonb_array_length(v#>'{overlap,clusters}')<>1
       OR jsonb_array_length(v->'outcome_evidence')<>3
       OR jsonb_array_length(v->'appraisal')<>3
       OR jsonb_array_length(v->'references')<>4
       OR v#>>'{audit,assurance_level}'<>'A3'
       OR COALESCE((v#>>'{audit,publishable}')::boolean,false)<>true
    THEN
        RAISE EXCEPTION 'OV-T13 FAIL — OverviewOfReviewsView smoke mismatch: %',v->'audit';
    END IF;
END;
$test$;

SELECT 'OV-T01–T13 PASS — formal synthetic Overview contract positive path validated'
AS overview_positive_tests_status;
