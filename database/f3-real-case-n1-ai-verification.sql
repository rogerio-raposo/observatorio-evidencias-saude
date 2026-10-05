-- OES Fase 3 — Real N1-01 AI methodological verification pass 2
-- Moves current ProductVersion 2 from A0 to A1 only.
-- Does NOT create owner approval, expert review, publication date, or A2.

BEGIN;

INSERT INTO product.assurance_record(
    assurance_uuid,
    product_version_uuid,
    assurance_type,
    actor,
    actor_type,
    independent_flag,
    decision,
    performed_at,
    notes,
    evidence_payload,
    status
) VALUES (
    'a3000000-0000-0000-0000-000000000702',
    'a1000000-0000-0000-0000-000000000702',
    'ai_methodological_verification',
    'OES_AI_METHOD_VERIFICATION_N1_PASS_2',
    'ai_system',
    false,
    'passed',
    TIMESTAMPTZ '2026-10-05 16:00:00-03',
    'Second adversarial verification passed after separating meta-analysis estimates and explicitly qualifying the post-cutoff evidence check as selective/non-exhaustive.',
    '{"document":"82-caso-real-n1-verificacao-metodologica-adversarial-02.md","result":"passed","independent_review":false,"expert_review":false,"resolved_issues":["separate_meta_analysis_estimates","qualify_post_cutoff_check_as_selective"]}'::jsonb,
    'active'
);

-- verification_status is lifecycle metadata for the already-current ROBIS assessment.
UPDATE appraisal.risk_assessment_version
   SET verification_status='ai_verified_passed'
 WHERE version_uuid='a1000000-0000-0000-0000-000000000401';

COMMIT;
