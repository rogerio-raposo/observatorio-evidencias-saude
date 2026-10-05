-- OES Fase 3 — Real N0-01 AI methodological verification
-- Advances ProductVersion 1 from A0 to A1.
-- Does not create owner approval, expert review or publication date.

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
 'c4000000-0000-0000-0000-000000000301',
 'c1000000-0000-0000-0000-000000000301',
 'ai_methodological_verification',
 'OES_AI_METHOD_VERIFICATION_N0_PASS_1',
 'ai_system',
 false,
 'passed',
 TIMESTAMPTZ '2026-10-05 19:05:00-03',
 'Adversarial methodological verification PASSED for real Evidence Scan N0-01. Internal A1 only; no owner approval or expert review.',
 '{"document":"97-caso-real-n0-verificacao-metodologica-adversarial.md","result":"passed","scientific_correction_required":false,"routing":"N2","requires_question_reformulation":true,"expert_review":false}'::jsonb,
 'active'
);

COMMIT;
