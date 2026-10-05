-- OES Fase 3 — Evidence Response N1 deterministic fixture
-- Requires baseline + migrations 002–012.
-- Purpose: validate N1 direct-source representation without mandatory Synthesis/Certainty.

BEGIN;

-- Question
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('90000000-0000-0000-0000-000000000001','OES-Q-2026-000901','Question','f3-n1');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '91000000-0000-0000-0000-000000000001',
 '90000000-0000-0000-0000-000000000001',
 1,'current','f3-n1','initial','N1 Evidence Response fixture question'
);

INSERT INTO investigation.question(entity_uuid)
VALUES ('90000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
 version_uuid,entity_uuid,original_text,normalized_text,question_type,structure_type,context_payload
) VALUES (
 '91000000-0000-0000-0000-000000000001',
 '90000000-0000-0000-0000-000000000001',
 'Em uma população-alvo sintética, o que a melhor síntese disponível indica sobre a intervenção de teste?',
 'Qual é o efeito da intervenção de teste na população-alvo sintética segundo a melhor síntese disponível?',
 'intervention','PICO',
 '{"fixture":true,"population":"synthetic target population","intervention":"test intervention","comparator":"test comparator"}'::jsonb
);

-- N1 Investigation
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('90000000-0000-0000-0000-000000000002','OES-I-2026-000901','Investigation','f3-n1');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '91000000-0000-0000-0000-000000000002',
 '90000000-0000-0000-0000-000000000002',
 1,'current','f3-n1','initial','N1 Evidence Response fixture investigation'
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('90000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
 version_uuid,entity_uuid,primary_question_entity_uuid,investigation_type,
 depth_level,maintenance_level,objective,start_date,evidence_cutoff_date,status
) VALUES (
 '91000000-0000-0000-0000-000000000002',
 '90000000-0000-0000-0000-000000000002',
 '90000000-0000-0000-0000-000000000001',
 'focused_evidence_response','N1','M1',
 'Validate a selective N1 response based on one decisive systematic-review report without creating a Synthesis object.',
 DATE '2026-10-05',DATE '2026-10-05','completed'
);

INSERT INTO investigation.investigation_question(
 investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
 '91000000-0000-0000-0000-000000000002',
 '91000000-0000-0000-0000-000000000001',
 'primary',1
);

-- Structured selective search
INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,source_name,platform,
 exact_strategy,filters_payload,executed_at,result_count,strategy_version,operator,status
) VALUES (
 '92000000-0000-0000-0000-000000000001',
 'OES-SRCH-2026-000901',
 '91000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(synthetic condition) AND (test intervention) AND systematic review',
 '{"fixture":true,"language":"any"}'::jsonb,
 TIMESTAMPTZ '2026-10-05 03:30:00-03',1,'n1-fixture-v1','OES','completed'
);

-- Decisive Report without a synthetic Study/Synthesis hierarchy
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('90000000-0000-0000-0000-000000000201','OES-R-2026-000901','Report','f3-n1');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '91000000-0000-0000-0000-000000000201',
 '90000000-0000-0000-0000-000000000201',
 1,'current','f3-n1','initial','Synthetic decisive report for N1 fixture'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('90000000-0000-0000-0000-000000000201');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 '91000000-0000-0000-0000-000000000201',
 '90000000-0000-0000-0000-000000000201',
 'systematic_review',
 'Synthetic decisive systematic review for N1 validation',
 DATE '2026-01-15','Synthetic Journal','en','published','available',
 '{"fixture":true,"identifier":"SYNTH-N1-001"}'::jsonb,'active'
);

INSERT INTO investigation.search_hit(
 search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,source_record_id,
 raw_title,raw_authors,raw_year,raw_identifier,source_rank,resolution_status
) VALUES (
 '92500000-0000-0000-0000-000000000001',
 'OES-HIT-2026-000901',
 '92000000-0000-0000-0000-000000000001',
 '90000000-0000-0000-0000-000000000201',
 'SYNTH-N1-001','Synthetic decisive systematic review for N1 validation',
 'Fixture Author',2026,'SYNTH-N1-001',1,'resolved'
);

INSERT INTO investigation.screening_decision(
 screening_uuid,oes_screening_id,investigation_version_uuid,target_entity_uuid,
 stage,reviewer,decision,decided_at
) VALUES (
 '92600000-0000-0000-0000-000000000001',
 'OES-SCR-2026-000901',
 '91000000-0000-0000-0000-000000000002',
 '90000000-0000-0000-0000-000000000201',
 'full_text','OES','include',TIMESTAMPTZ '2026-10-05 03:35:00-03'
);

-- Evidence Response Product
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('90000000-0000-0000-0000-000000000301','OES-P-2026-000901','Product','f3-n1');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '91000000-0000-0000-0000-000000000301',
 '90000000-0000-0000-0000-000000000301',
 1,'current','f3-n1','initial','Initial Evidence Response N1 fixture'
);

INSERT INTO product.product(entity_uuid)
VALUES ('90000000-0000-0000-0000-000000000301');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,evidence_cutoff_date,
 publication_date,status,conclusion_text,applicability_summary,limitations_summary
) VALUES (
 '91000000-0000-0000-0000-000000000301',
 '90000000-0000-0000-0000-000000000301',
 'evidence_response',
 'Resposta de Evidência N1 — fixture de validação',
 'architecture_validation',
 DATE '2026-10-05',DATE '2026-10-05','published',
 'Conclusão sintética de fixture sustentada diretamente por uma fonte decisiva rastreável.',
 'Aplicabilidade apenas descritiva para validação arquitetural.',
 'Busca seletiva não exaustiva e uma única fonte decisiva; fixture sem finalidade clínica.'
);

INSERT INTO product.investigation_link(
 product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
 '91000000-0000-0000-0000-000000000301',
 '91000000-0000-0000-0000-000000000002',
 'primary',1
);

INSERT INTO product.currency_state(
 currency_state_uuid,product_version_uuid,currency_status,assessed_at,assessed_by,rationale,record_status
) VALUES (
 '93000000-0000-0000-0000-000000000301',
 '91000000-0000-0000-0000-000000000301',
 'current',TIMESTAMPTZ '2026-10-05 03:40:00-03','OES',
 'N1 fixture search current through evidence cutoff.','active'
);

INSERT INTO product.assurance_record(
 assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,independent_flag,
 decision,performed_at,notes,evidence_payload,status
) VALUES
(
 '94000000-0000-0000-0000-000000000301',
 '91000000-0000-0000-0000-000000000301',
 'ai_methodological_verification','N1_TEST_AI','ai_system',false,'passed',
 TIMESTAMPTZ '2026-10-05 03:45:00-03','Synthetic N1 methodological verification',
 '{"fixture":true,"result":"passed"}'::jsonb,'active'
),
(
 '94000000-0000-0000-0000-000000000302',
 '91000000-0000-0000-0000-000000000301',
 'owner_governance_approval','N1_TEST_OWNER','owner',false,'approved',
 TIMESTAMPTZ '2026-10-05 03:46:00-03','Synthetic N1 owner approval',
 '{"fixture":true,"result":"approved","expert_review":false}'::jsonb,'active'
);

-- Direct field-level provenance: no mandatory Synthesis or Certainty object.
INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,
 source_value,process_type,transformation,actor,status
) VALUES
(
 '95000000-0000-0000-0000-000000000301',
 '91000000-0000-0000-0000-000000000301',
 'conclusion_text',
 '91000000-0000-0000-0000-000000000201',
 'Abstract / Results',
 '{"text":"Synthetic conclusion support"}'::jsonb,
 'adopted_external_synthesis',NULL,'OES','active'
),
(
 '95000000-0000-0000-0000-000000000302',
 '91000000-0000-0000-0000-000000000301',
 'key_results.0.effect_estimate',
 '91000000-0000-0000-0000-000000000201',
 'Results / Figure 1',
 '{"measure":"synthetic_effect","estimate":1.0,"unit":"fixture_only"}'::jsonb,
 'direct_extraction',NULL,'OES','active'
),
(
 '95000000-0000-0000-0000-000000000303',
 '91000000-0000-0000-0000-000000000301',
 'limitations_summary',
 '91000000-0000-0000-0000-000000000201',
 'Methods / Limitations',
 '{"text":"Single decisive source in a selective search"}'::jsonb,
 'critical_appraisal_note',NULL,'OES','active'
);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
 '91000000-0000-0000-0000-000000000201',
 '91000000-0000-0000-0000-000000000301',
 'direct_report_informs_evidence_response',
 'provenance.record','active'
);

COMMIT;