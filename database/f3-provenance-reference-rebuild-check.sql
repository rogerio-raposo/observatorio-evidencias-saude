-- OES Fase 3 — provenance-aware reference rebuild assertion
BEGIN;

INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES
('74300000-0000-0000-0000-000000000001','OES-RP-2026-000402','Report','f3-prov-rebuild'),
('74300000-0000-0000-0000-000000000002','OES-SY-2026-000402','Synthesis','f3-prov-rebuild');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('74400000-0000-0000-0000-000000000001','74300000-0000-0000-0000-000000000001',1,'current','f3-prov-rebuild','initial','External report'),
('74400000-0000-0000-0000-000000000002','74300000-0000-0000-0000-000000000002',1,'current','f3-prov-rebuild','initial','External synthesis');

INSERT INTO evidence.report(entity_uuid)
VALUES ('74300000-0000-0000-0000-000000000001');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,
 publication_status,full_text_status,status
) VALUES (
 '74400000-0000-0000-0000-000000000001',
 '74300000-0000-0000-0000-000000000001',
 'systematic_review','External anchor',DATE '2025-03-12',
 'published','full_text_available','active'
);

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('74300000-0000-0000-0000-000000000002');

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
 estimand,synthesis_type,synthesis_origin,method,result_summary,status
) VALUES (
 '74400000-0000-0000-0000-000000000002',
 '74300000-0000-0000-0000-000000000002',
 '10000000-0000-0000-0000-000000000002',
 '00000000-0000-0000-0000-000000000005',
 'treatment_effect','pairwise_meta_analysis','adopted_external',
 'published_meta_analysis','{"effect":-0.93}'::jsonb,'active'
);

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,
 source_report_version_uuid,source_location,process_type,actor
) VALUES (
 '74500000-0000-0000-0000-000000000001',
 '74400000-0000-0000-0000-000000000002',
 '/result_summary',
 '74400000-0000-0000-0000-000000000001',
 'Published meta-analysis',
 'external_synthesis_adoption',
 'f3-prov-rebuild'
);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES (
 '74400000-0000-0000-0000-000000000002',
 '10000000-0000-0000-0000-000000000007',
 'external_synthesis_informs_update',
 'rebuild assertion'
);

DO $check$
DECLARE v jsonb;
BEGIN
 SELECT product.evidence_sheet_view(
  '71000000-0000-0000-0000-000000000001'
 ) INTO v;

 IF NOT EXISTS (
  SELECT 1
  FROM jsonb_array_elements(v->'references') r
  WHERE r->>'report_id'='OES-RP-2026-000402'
 ) THEN
  RAISE EXCEPTION 'F3-PROV-T06 FAIL: provenance report missing after rebuild';
 END IF;

 RAISE NOTICE 'F3-PROV-T06 PASS — provenance-aware reference survives rebuild';
END
$check$;

ROLLBACK;
