-- OES Fase 3 — OVR-01 AI methodological verification / A1 promotion
-- Execute only after OVR01-T01–T16 PASS and Document 163 PASS.
-- This records AI-only methodological verification and may establish A1 only.
-- It does not create owner approval, human verification, expert review or publication eligibility.

BEGIN;

DO $pre$
DECLARE
    v jsonb;
    p jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'd9100000-0000-0000-0000-000000000020'
    );

    IF v#>>'{audit,assurance_level}'<>'A0'
       OR COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false
       OR v#>>'{identity,editorial_status}'<>'under_review'
       OR (v#>>'{audit,review_count}')::integer<>3
       OR jsonb_array_length(v->'review_items')<>3
       OR jsonb_array_length(v->'primary_study_membership')<>86
    THEN
        RAISE EXCEPTION
            'OVR01-A1 precondition FAIL — corrected A0 state not preserved';
    END IF;

    SELECT impact_payload INTO p
      FROM investigation.method_decision
     WHERE investigation_version_uuid=
           'd9100000-0000-0000-0000-000000000002'
       AND decision_code='overview_search_coverage_policy'
       AND record_status='active';

    IF p IS NULL
       OR p->>'coverage_claim'<>'structured_non_exhaustive'
       OR p->>'search_execution_materialized'<>'false'
       OR p ? 'minimum_bibliographic_sources'
       OR jsonb_array_length(p->'discovery_sources')<>4
       OR EXISTS (
            SELECT 1
              FROM investigation.search
             WHERE investigation_version_uuid=
                   'd9100000-0000-0000-0000-000000000002'
       )
       OR EXISTS (
            SELECT 1
              FROM investigation.screening_decision
             WHERE investigation_version_uuid=
                   'd9100000-0000-0000-0000-000000000002'
       )
    THEN
        RAISE EXCEPTION
            'OVR01-A1 precondition FAIL — adversarial Search correction regressed';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.assurance_record
         WHERE product_version_uuid=
               'd9100000-0000-0000-0000-000000000020'
           AND status='active'
    ) THEN
        RAISE EXCEPTION
            'OVR01-A1 precondition FAIL — assurance already active';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.reviewer_assignment
         WHERE investigation_version_uuid=
               'd9100000-0000-0000-0000-000000000002'
           AND record_status='active'
    ) OR EXISTS (
        SELECT 1
          FROM investigation.quality_control_record
         WHERE investigation_version_uuid=
               'd9100000-0000-0000-0000-000000000002'
           AND record_status='active'
           AND actor_type IN ('human_reviewer','human_expert')
    ) THEN
        RAISE EXCEPTION
            'OVR01-A1 precondition FAIL — unexpected human control present';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.overview_of_reviews_publication_issues(
               'd9100000-0000-0000-0000-000000000020'
          )
         WHERE issue_code='MISSING_LAST_SEARCH_DATE'
           AND severity='error'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.overview_of_reviews_publication_issues(
               'd9100000-0000-0000-0000-000000000020'
          )
         WHERE issue_code='UNVERIFIED_MEMBERSHIP'
           AND severity='error'
    ) OR NOT EXISTS (
        SELECT 1
          FROM product.overview_of_reviews_publication_issues(
               'd9100000-0000-0000-0000-000000000020'
          )
         WHERE issue_code='UNVERIFIED_REVIEW_APPRAISAL'
           AND severity='error'
    ) THEN
        RAISE EXCEPTION
            'OVR01-A1 precondition FAIL — required formal blockers are not visible';
    END IF;
END;
$pre$;

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,qualification_payload,independent_flag,decision,
    scope_payload,agreement_payload,discrepancy_payload,resolution_payload,
    performed_at,evidence_artifact_uuid,notes,record_status
) VALUES (
    'd9820000-0000-0000-0000-000000000001',
    'd9100000-0000-0000-0000-000000000002',
    'cross_cutting','other',
    'OES_OVR01_AI_SECOND_PASS','ai_system',NULL,false,'passed',
    '{
      "control_code":"ovr01_ai_methodological_second_pass",
      "case":"OVR-01",
      "scope":"protocol fidelity, documentary discovery, currentness, membership identity, overlap derivation, comparator stratification, provenance, certainty, ROBIS, formal blockers and renderer",
      "first_pass_document":"docs/products/162-verificacao-metodologica-adversarial-01-ovr01-dcbti.md",
      "second_pass_document":"docs/products/163-verificacao-metodologica-adversarial-02-ovr01-dcbti.md",
      "second_pass_blob_sha":"742d1ecc1a0e7875d9de5fbfbc8dcd4367fa24d7",
      "second_pass_commit":"7a63bab3546df7a7cdd95299fb508febbbb67fd5",
      "validated_run":37543166213
    }'::jsonb,
    '{
      "corrected_findings":[
        "unsupported_search_execution_removed",
        "search_coverage_policy_realigned",
        "question_protocol_fidelity_restored"
      ],
      "retained_controls":[
        "gao_date_not_inferred",
        "cca_database_derived",
        "comparators_separate",
        "no_new_meta_analysis",
        "certainty_not_invented",
        "human_verification_not_fabricated"
      ]
    }'::jsonb,
    '{"material_discrepancies":[]}'::jsonb,
    '{
      "result":"passed_with_documented_developmental_limitations",
      "a1_eligible":true,
      "formal_route_ready":false,
      "publication_authorized":false
    }'::jsonb,
    TIMESTAMPTZ '2026-10-06 20:49:58-03',NULL,
    'AI-only second-pass methodological verification documented in Product Document 163. It is not independent peer review, human verification, owner approval or expert review.',
    'active'
);

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
    independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES (
    'd9810000-0000-0000-0000-000000000001',
    'd9100000-0000-0000-0000-000000000020',
    'ai_methodological_verification',
    'OES_OVR01_AI_SECOND_PASS','ai_system',false,'passed',
    TIMESTAMPTZ '2026-10-06 20:49:58-03',
    'OVR-01 passed the second AI-only methodological adversarial verification for internal developmental use. Formal publication blockers, unverified memberships/ROBIS and Gao unresolved currentness remain explicit.',
    '{
      "case":"OVR-01",
      "decision_document":"docs/products/163-verificacao-metodologica-adversarial-02-ovr01-dcbti.md",
      "decision_document_blob_sha":"742d1ecc1a0e7875d9de5fbfbc8dcd4367fa24d7",
      "decision_commit":"7a63bab3546df7a7cdd95299fb508febbbb67fd5",
      "prior_revise_document":"docs/products/162-verificacao-metodologica-adversarial-01-ovr01-dcbti.md",
      "validation_suite":"OVR01-T01-T16",
      "validated_run":37543166213,
      "validated_artifact_id":11449428162,
      "validated_artifact_digest":"sha256:5fed94df2b2d2c37e6280b899bbf8f8826e90ca7b2c978dfe83a14772bee2a40",
      "review_items":3,
      "membership_occurrences":86,
      "unique_primary_studies":59,
      "pairwise_shared_studies":[6,17,9],
      "coverage_claim":"structured_non_exhaustive",
      "gao_last_search_verified":false,
      "human_verification":false,
      "owner_approval":false,
      "expert_review":false,
      "formal_route_ready":false,
      "publication_authorized":false
    }'::jsonb,
    'active'
);

COMMIT;
