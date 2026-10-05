-- OES Fase 3 — Real N1-01 owner governance approval and A2 publication
-- Applies to current ProductVersion 2 after AI methodological verification PASSED.
-- Owner approval is governance approval, not expert methodological review.

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
    'a3000000-0000-0000-0000-000000000703',
    'a1000000-0000-0000-0000-000000000702',
    'owner_governance_approval',
    'OES_PROJECT_OWNER',
    'owner',
    false,
    'approved',
    TIMESTAMPTZ '2026-10-05 16:30:00-03',
    'Explicit owner governance approval for publication under assurance A2. This is not expert methodological review.',
    '{"document":"84-caso-real-n1-aprovacao-governanca-proprietario.md","result":"approved","methodological_review":false,"expert_review":false,"publication_scope":"OES standard N1"}'::jsonb,
    'active'
);

UPDATE product.product_version
   SET status='published',
       publication_date=DATE '2026-10-05'
 WHERE version_uuid='a1000000-0000-0000-0000-000000000702';

COMMIT;
