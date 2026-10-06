-- OES Fase 3 — Real Case MAP-01
-- Exploratory descriptive evidence map of the accumulated N3-01 corpus.
-- Requires baseline + migrations 002–018 + N3-01 base/revision data.
-- Pre-specified by Documents 132–135. Starts at A0; no assurance is granted here.

BEGIN;

-- ---------------------------------------------------------------------------
-- TRACEABLE PROTOCOL / CODEBOOK ARTIFACTS
-- ---------------------------------------------------------------------------

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,
    mime_type,original_filename,source_uri,created_at,created_by,status
) VALUES
(
    'c8900000-0000-0000-0000-000000000001','protocol',
    'docs/products/132-caso-real-map01-ambient-ai-scribes-protocolo.md',
    '9d1aa55c9d89ba72157d03476f25c4ca5806719a','git-blob-sha1',
    'text/markdown','132-caso-real-map01-ambient-ai-scribes-protocolo.md',NULL,
    TIMESTAMPTZ '2026-10-06 11:35:00-03','oes-real-map01','active'
),
(
    'c8900000-0000-0000-0000-000000000002','codebook',
    'docs/products/134-caso-real-map01-codebook-v01.md',
    '7e03592bf22b2cd009e07436bf710c81656b6469','git-blob-sha1',
    'text/markdown','134-caso-real-map01-codebook-v01.md',NULL,
    TIMESTAMPTZ '2026-10-06 11:36:00-03','oes-real-map01','active'
);

-- ---------------------------------------------------------------------------
-- MAP-SPECIFIC QUESTION / INVESTIGATION / FRAMEWORK / PRODUCT IDENTITIES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('c8000000-0000-0000-0000-000000000001','OES-Q-2026-001401','Question','oes-real-map01'),
('c8000000-0000-0000-0000-000000000002','OES-I-2026-001401','Investigation','oes-real-map01'),
('c8000000-0000-0000-0000-000000000010','OES-MF-2026-001401','MapFramework','oes-real-map01'),
('c8000000-0000-0000-0000-000000000020','OES-P-2026-001401','Product','oes-real-map01');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('c8100000-0000-0000-0000-000000000001','c8000000-0000-0000-0000-000000000001',1,'current','oes-real-map01','initial','MAP-01 mapping question'),
('c8100000-0000-0000-0000-000000000002','c8000000-0000-0000-0000-000000000002',1,'current','oes-real-map01','initial','MAP-01 evidence-mapping investigation'),
('c8100000-0000-0000-0000-000000000010','c8000000-0000-0000-0000-000000000010',1,'current','oes-real-map01','initial','MAP-01 framework v0.1'),
('c8100000-0000-0000-0000-000000000020','c8000000-0000-0000-0000-000000000020',1,'current','oes-real-map01','initial','MAP-01 exploratory internal product A0');

INSERT INTO investigation.question(entity_uuid)
VALUES ('c8000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload,time_horizon_payload
) VALUES (
    'c8100000-0000-0000-0000-000000000001',
    'c8000000-0000-0000-0000-000000000001',
    'Como as unidades de evidência do corpus N3-01 sobre ambient AI scribes estão distribuídas?',
    'Como as unidades de evidência recuperadas no corpus N3-01 sobre ambient AI scribes se distribuem por papel da evidência e domínio de outcome?',
    'mapping','PCC',
    '{"population":"outpatient clinicians and mapped contextual evidence","concept":"distribution of accumulated N3-01 evidence","context":"internal exploratory descriptive mapping","source_corpus":"OES-I-2026-000701"}'::jsonb,
    '{"evidence_cutoff":"2026-10-05","mapping_execution":"2026-10-06"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('c8000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'c8100000-0000-0000-0000-000000000002',
    'c8000000-0000-0000-0000-000000000002',
    'c8000000-0000-0000-0000-000000000001',
    'evidence_mapping','N3','M0',
    'Describe how the accumulated N3-01 corpus is distributed by evidence role and outcome domain without claiming systematic completeness.',
    'c8900000-0000-0000-0000-000000000001',
    DATE '2026-10-06',DATE '2026-10-05','completed'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'c8100000-0000-0000-0000-000000000002',
    'c8100000-0000-0000-0000-000000000001','primary',1
);

INSERT INTO artifact.entity_link(artifact_uuid,entity_version_uuid,role,sequence_no)
VALUES
('c8900000-0000-0000-0000-000000000001','c8100000-0000-0000-0000-000000000002','protocol',1),
('c8900000-0000-0000-0000-000000000002','c8100000-0000-0000-0000-000000000010','codebook',1);

-- Explicit provenance for inherited corpus, without copying Search/Screening.
INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
    'e1000000-0000-0000-0000-000000000002',
    'c8100000-0000-0000-0000-000000000002',
    'source_corpus_informs_mapping_investigation',
    'MAP-01 inherits the accumulated N3-01 corpus; no Search/Screening records are duplicated.',
    'active'
);

-- ---------------------------------------------------------------------------
-- FRAMEWORK v0.1
-- ---------------------------------------------------------------------------

INSERT INTO mapping.framework(entity_uuid)
VALUES ('c8000000-0000-0000-0000-000000000010');

INSERT INTO mapping.framework_version(
    version_uuid,entity_uuid,investigation_version_uuid,mapping_subtype,
    coverage_claim,gap_claim_mode,counting_unit_policy,codebook_artifact_uuid,
    primary_row_dimension_code,primary_column_dimension_code,
    classification_policy_payload,coverage_policy_payload,gap_rules_payload,
    visualization_payload,stakeholder_payload,status
) VALUES (
    'c8100000-0000-0000-0000-000000000010',
    'c8000000-0000-0000-0000-000000000010',
    'c8100000-0000-0000-0000-000000000002',
    'descriptive_mapping_review','structured_non_exhaustive','apparent_only','study',
    'c8900000-0000-0000-0000-000000000002',
    'evidence_role','outcome_domain',
    '{"independent_coding":false,"actor_model":"ai_system","final_assignment_verification":"unverified","codebook":"MAP-01 v0.1"}'::jsonb,
    '{"source_mode":"inherited_corpus","source_corpus_investigation_id":"OES-I-2026-000701","completeness_claim":false,"known_limitations":["single reproducible bibliographic database","supplementary discovery channels","new eligible studies found during corrective search"]}'::jsonb,
    '{"derive_synthesis_gap":true,"apparent_gap_language":"no eligible counted unit located in consulted sources for this classification"}'::jsonb,
    '{"default":"matrix","display_counts_by_type":true,"show_source_corpus":true}'::jsonb,
    '{"engaged":false,"reason":"internal methodological validation case"}'::jsonb,
    'active'
);

INSERT INTO mapping.dimension(
    dimension_uuid,framework_version_uuid,dimension_code,label,description,
    dimension_role,multi_valued,required_flag,sequence_no,metadata_payload,status
) VALUES
('c8400000-0000-0000-0000-000000000001','c8100000-0000-0000-0000-000000000010','evidence_role','Evidence role','Primary role of the mapped unit in MAP-01','row_axis',false,true,1,'{"codebook":"134"}'::jsonb,'active'),
('c8400000-0000-0000-0000-000000000002','c8100000-0000-0000-0000-000000000010','outcome_domain','Outcome domain','Outcome or broad implementation domain represented by the mapped unit','column_axis',true,true,2,'{"codebook":"134"}'::jsonb,'active'),
('c8400000-0000-0000-0000-000000000003','c8100000-0000-0000-0000-000000000010','evidence_context','Evidence context','Comparator or contextual role filter','filter',true,false,3,'{"codebook":"134"}'::jsonb,'active');

INSERT INTO mapping.category(
    category_uuid,dimension_uuid,parent_category_uuid,category_code,label,
    definition,sequence_no,metadata_payload,status
) VALUES
('c8410000-0000-0000-0000-000000000001','c8400000-0000-0000-0000-000000000001',NULL,'comparative_randomized_study','Comparative randomized study','Randomized comparative StudyVersion in the N3-01 comparative set.',1,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000002','c8400000-0000-0000-0000-000000000001',NULL,'contextual_primary_study','Contextual primary study','Primary StudyVersion used contextually rather than as equivalent randomized causal evidence.',2,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000003','c8400000-0000-0000-0000-000000000001',NULL,'contextual_secondary_report','Contextual secondary report','Included ReportVersion without a selected Study MapItem, used for context or secondary evidence.',3,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000004','c8400000-0000-0000-0000-000000000001',NULL,'synthesis','Synthesis','Existing N3-01 SynthesisVersion.',4,'{}'::jsonb,'active'),

('c8410000-0000-0000-0000-000000000011','c8400000-0000-0000-0000-000000000002',NULL,'documentation_time','Documentation time','Time devoted to documentation or directly equivalent EHR note-time measures.',1,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000012','c8400000-0000-0000-0000-000000000002',NULL,'workload_work_exhaustion','Workload / work exhaustion','Workload, work exhaustion, burnout or documentation-burden outcomes.',2,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000013','c8400000-0000-0000-0000-000000000002',NULL,'work_outside_work','Work outside work','Documentation work outside scheduled work or directly equivalent after-hours measures.',3,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000014','c8400000-0000-0000-0000-000000000002',NULL,'note_quality_safety','Note quality / safety','Note quality, accuracy, omissions, hallucinations or potentially harmful errors.',4,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000015','c8400000-0000-0000-0000-000000000002',NULL,'broader_implementation_context','Broader implementation context','Implementation, adoption, acceptability, workflow or broad secondary-review context.',5,'{}'::jsonb,'active'),

('c8410000-0000-0000-0000-000000000021','c8400000-0000-0000-0000-000000000003',NULL,'ambient_vs_usual_care','Ambient vs usual care','Ambient-scribe comparison with usual documentation/usual care.',1,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000022','c8400000-0000-0000-0000-000000000003',NULL,'head_to_head_vendor','Head-to-head vendor','Comparison between ambient-scribe technologies/vendors.',2,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000023','c8400000-0000-0000-0000-000000000003',NULL,'implementation_context','Implementation context','Real-world implementation/experience context.',3,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000024','c8400000-0000-0000-0000-000000000003',NULL,'secondary_review_context','Secondary review context','Secondary review used for context/non-duplication/citation chasing.',4,'{}'::jsonb,'active'),
('c8410000-0000-0000-0000-000000000025','c8400000-0000-0000-0000-000000000003',NULL,'quality_safety_context','Quality / safety context','Specific context of note quality or safety evaluation.',5,'{}'::jsonb,'active');

-- ---------------------------------------------------------------------------
-- 17 MAP ITEMS + PROVENANCE
-- ---------------------------------------------------------------------------

INSERT INTO mapping.map_item(
    map_item_uuid,framework_version_uuid,target_version_uuid,item_role,
    inclusion_basis_payload,included_at,status
) VALUES
('c8500000-0000-0000-0000-000000000101','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000101','primary_evidence','{"basis":"eligible StudyVersion; randomized comparative N3-01","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000102','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000102','primary_evidence','{"basis":"eligible StudyVersion; randomized comparative N3-01","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000103','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000103','primary_evidence','{"basis":"eligible StudyVersion; randomized comparative N3-01","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000104','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000104','primary_evidence','{"basis":"eligible contextual primary StudyVersion from N3-01","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000105','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000105','primary_evidence','{"basis":"eligible contextual primary StudyVersion from N3-01","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000206','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000206','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000211','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000211','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000212','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000212','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000213','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000213','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000214','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000214','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000215','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000215','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000216','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000216','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000217','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000217','contextual','{"basis":"full-text included contextual secondary ReportVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000501','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000501','synthesis','{"basis":"existing N3-01 narrative SynthesisVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000502','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000502','synthesis','{"basis":"existing N3-01 narrative SynthesisVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000503','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000503','synthesis','{"basis":"existing N3-01 narrative SynthesisVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active'),
('c8500000-0000-0000-0000-000000000504','c8100000-0000-0000-0000-000000000010','e1000000-0000-0000-0000-000000000504','synthesis','{"basis":"existing N3-01 narrative SynthesisVersion","source":"N3-01 corpus","inventory_document":"133"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:40:00-03','active');

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES
('e1000000-0000-0000-0000-000000000101','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000102','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000103','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000104','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000105','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000206','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000211','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000212','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000213','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000214','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000215','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000216','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000217','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000501','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000502','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000503','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active'),
('e1000000-0000-0000-0000-000000000504','c8100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MAP-01 inventory and codebook inclusion','active');

-- ---------------------------------------------------------------------------
-- 67 FINAL AI/UNVERIFIED ASSIGNMENTS
-- ---------------------------------------------------------------------------

INSERT INTO mapping.assignment(
    assignment_uuid,map_item_uuid,category_uuid,decision_state,
    assigned_by,actor_type,assignment_method,verification_status,
    verified_by,verifier_actor_type,verified_at,rationale_payload,assigned_at,status
) VALUES
('c8600000-0000-0000-0000-000000000001','c8500000-0000-0000-0000-000000000101','c8410000-0000-0000-0000-000000000001','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"101","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000002','c8500000-0000-0000-0000-000000000101','c8410000-0000-0000-0000-000000000011','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"101","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000003','c8500000-0000-0000-0000-000000000101','c8410000-0000-0000-0000-000000000012','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"101","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000004','c8500000-0000-0000-0000-000000000101','c8410000-0000-0000-0000-000000000014','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"101","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000005','c8500000-0000-0000-0000-000000000101','c8410000-0000-0000-0000-000000000021','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"101","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000006','c8500000-0000-0000-0000-000000000102','c8410000-0000-0000-0000-000000000001','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"102","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000007','c8500000-0000-0000-0000-000000000102','c8410000-0000-0000-0000-000000000011','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"102","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000008','c8500000-0000-0000-0000-000000000102','c8410000-0000-0000-0000-000000000012','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"102","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000009','c8500000-0000-0000-0000-000000000102','c8410000-0000-0000-0000-000000000013','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"102","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000010','c8500000-0000-0000-0000-000000000102','c8410000-0000-0000-0000-000000000014','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"102","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000011','c8500000-0000-0000-0000-000000000102','c8410000-0000-0000-0000-000000000021','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"102","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000012','c8500000-0000-0000-0000-000000000103','c8410000-0000-0000-0000-000000000001','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"103","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000013','c8500000-0000-0000-0000-000000000103','c8410000-0000-0000-0000-000000000011','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"103","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000014','c8500000-0000-0000-0000-000000000103','c8410000-0000-0000-0000-000000000012','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"103","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000015','c8500000-0000-0000-0000-000000000103','c8410000-0000-0000-0000-000000000013','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"103","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000016','c8500000-0000-0000-0000-000000000103','c8410000-0000-0000-0000-000000000022','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"103","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000017','c8500000-0000-0000-0000-000000000104','c8410000-0000-0000-0000-000000000002','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"104","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000018','c8500000-0000-0000-0000-000000000104','c8410000-0000-0000-0000-000000000011','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"104","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000019','c8500000-0000-0000-0000-000000000104','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"104","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000020','c8500000-0000-0000-0000-000000000104','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"104","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000021','c8500000-0000-0000-0000-000000000105','c8410000-0000-0000-0000-000000000002','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"105","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000022','c8500000-0000-0000-0000-000000000105','c8410000-0000-0000-0000-000000000014','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"105","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000023','c8500000-0000-0000-0000-000000000105','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 outcome coverage","source_entity_id":"105","rule_code":"OUTCOME_FROM_N3_COVERAGE","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000024','c8500000-0000-0000-0000-000000000105','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"105","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000025','c8500000-0000-0000-0000-000000000105','c8410000-0000-0000-0000-000000000025','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"105","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000026','c8500000-0000-0000-0000-000000000206','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"206","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000027','c8500000-0000-0000-0000-000000000206','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"206","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000028','c8500000-0000-0000-0000-000000000206','c8410000-0000-0000-0000-000000000024','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"206","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000029','c8500000-0000-0000-0000-000000000211','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"211","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000030','c8500000-0000-0000-0000-000000000211','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"211","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000031','c8500000-0000-0000-0000-000000000211','c8410000-0000-0000-0000-000000000024','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"211","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000032','c8500000-0000-0000-0000-000000000212','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"212","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000033','c8500000-0000-0000-0000-000000000212','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"212","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000034','c8500000-0000-0000-0000-000000000212','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"212","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000035','c8500000-0000-0000-0000-000000000213','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"213","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000036','c8500000-0000-0000-0000-000000000213','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"213","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000037','c8500000-0000-0000-0000-000000000213','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"213","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000038','c8500000-0000-0000-0000-000000000214','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"214","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000039','c8500000-0000-0000-0000-000000000214','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"214","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000040','c8500000-0000-0000-0000-000000000214','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"214","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000041','c8500000-0000-0000-0000-000000000215','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"215","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000042','c8500000-0000-0000-0000-000000000215','c8410000-0000-0000-0000-000000000012','final','OES_MAP01_AI','ai_system','ai_assisted','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"215","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000043','c8500000-0000-0000-0000-000000000215','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"215","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000044','c8500000-0000-0000-0000-000000000215','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"215","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000045','c8500000-0000-0000-0000-000000000216','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"216","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000046','c8500000-0000-0000-0000-000000000216','c8410000-0000-0000-0000-000000000012','final','OES_MAP01_AI','ai_system','ai_assisted','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"216","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000047','c8500000-0000-0000-0000-000000000216','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"216","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000048','c8500000-0000-0000-0000-000000000216','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"216","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000049','c8500000-0000-0000-0000-000000000217','c8410000-0000-0000-0000-000000000003','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"217","rule_code":"ROLE_FROM_SCREENING_CONTEXT","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000050','c8500000-0000-0000-0000-000000000217','c8410000-0000-0000-0000-000000000012','final','OES_MAP01_AI','ai_system','ai_assisted','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"217","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000051','c8500000-0000-0000-0000-000000000217','c8410000-0000-0000-0000-000000000015','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Report title/bibliographic role","source_entity_id":"217","rule_code":"OUTCOME_FROM_REPORT_METADATA","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000052','c8500000-0000-0000-0000-000000000217','c8410000-0000-0000-0000-000000000023','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"bibliographic role/title","source_entity_id":"217","rule_code":"CONTEXT_FROM_REPORT_ROLE","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000053','c8500000-0000-0000-0000-000000000501','c8410000-0000-0000-0000-000000000004','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"501","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000054','c8500000-0000-0000-0000-000000000501','c8410000-0000-0000-0000-000000000011','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Synthesis outcome identity","source_entity_id":"501","rule_code":"OUTCOME_FROM_SYNTHESIS_TARGET","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000055','c8500000-0000-0000-0000-000000000501','c8410000-0000-0000-0000-000000000021','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"501","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000056','c8500000-0000-0000-0000-000000000501','c8410000-0000-0000-0000-000000000022','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"501","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000057','c8500000-0000-0000-0000-000000000502','c8410000-0000-0000-0000-000000000004','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"502","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000058','c8500000-0000-0000-0000-000000000502','c8410000-0000-0000-0000-000000000012','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Synthesis outcome identity","source_entity_id":"502","rule_code":"OUTCOME_FROM_SYNTHESIS_TARGET","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000059','c8500000-0000-0000-0000-000000000502','c8410000-0000-0000-0000-000000000021','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"502","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000060','c8500000-0000-0000-0000-000000000502','c8410000-0000-0000-0000-000000000022','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"502","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000061','c8500000-0000-0000-0000-000000000503','c8410000-0000-0000-0000-000000000004','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"503","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000062','c8500000-0000-0000-0000-000000000503','c8410000-0000-0000-0000-000000000013','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Synthesis outcome identity","source_entity_id":"503","rule_code":"OUTCOME_FROM_SYNTHESIS_TARGET","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000063','c8500000-0000-0000-0000-000000000503','c8410000-0000-0000-0000-000000000021','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"503","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000064','c8500000-0000-0000-0000-000000000503','c8410000-0000-0000-0000-000000000022','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"503","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000065','c8500000-0000-0000-0000-000000000504','c8410000-0000-0000-0000-000000000004','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"entity type/design + N3-01 role","source_entity_id":"504","rule_code":"ROLE_FROM_ENTITY_AND_DESIGN","reason":"Single primary evidence-role category defined by MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000066','c8500000-0000-0000-0000-000000000504','c8410000-0000-0000-0000-000000000014','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"Synthesis outcome identity","source_entity_id":"504","rule_code":"OUTCOME_FROM_SYNTHESIS_TARGET","reason":"Outcome-domain assignment pre-specified in Documents 133–134."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active'),
('c8600000-0000-0000-0000-000000000067','c8500000-0000-0000-0000-000000000504','c8410000-0000-0000-0000-000000000025','final','OES_MAP01_AI','ai_system','rule_based','unverified',NULL,NULL,NULL,'{"source_document":"docs/products/134-caso-real-map01-codebook-v01.md","source_field":"N3-01 comparator/context","source_entity_id":"504","rule_code":"CONTEXT_FROM_COMPARATOR","reason":"Evidence-context assignment pre-specified in MAP-01 codebook."}'::jsonb,TIMESTAMPTZ '2026-10-06 11:45:00-03','active');

-- ---------------------------------------------------------------------------
-- 20 CELL-SCOPE RECORDS
-- ---------------------------------------------------------------------------

INSERT INTO mapping.cell_scope(
    cell_scope_uuid,framework_version_uuid,row_category_uuid,column_category_uuid,
    scope_status,gap_eligible,rationale,metadata_payload
) VALUES
('c8700000-0000-0000-0000-000000000001','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000001','c8410000-0000-0000-0000-000000000011','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000002','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000001','c8410000-0000-0000-0000-000000000012','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000003','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000001','c8410000-0000-0000-0000-000000000013','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000004','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000001','c8410000-0000-0000-0000-000000000014','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000005','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000001','c8410000-0000-0000-0000-000000000015','excluded_by_framework',false,'Broader implementation context is excluded from the primary randomized-study role in MAP-01.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000006','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000002','c8410000-0000-0000-0000-000000000011','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000007','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000002','c8410000-0000-0000-0000-000000000012','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000008','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000002','c8410000-0000-0000-0000-000000000013','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000009','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000002','c8410000-0000-0000-0000-000000000014','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000010','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000002','c8410000-0000-0000-0000-000000000015','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000011','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000003','c8410000-0000-0000-0000-000000000011','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000012','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000003','c8410000-0000-0000-0000-000000000012','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000013','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000003','c8410000-0000-0000-0000-000000000013','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000014','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000003','c8410000-0000-0000-0000-000000000014','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000015','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000003','c8410000-0000-0000-0000-000000000015','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000016','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000004','c8410000-0000-0000-0000-000000000011','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000017','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000004','c8410000-0000-0000-0000-000000000012','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000018','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000004','c8410000-0000-0000-0000-000000000013','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000019','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000004','c8410000-0000-0000-0000-000000000014','in_scope',true,'Cell is in scope for exploratory mapping.','{"source":"Documents 133-134"}'::jsonb),
('c8700000-0000-0000-0000-000000000020','c8100000-0000-0000-0000-000000000010','c8410000-0000-0000-0000-000000000004','c8410000-0000-0000-0000-000000000015','not_applicable',false,'N3-01 contains four outcome-specific Syntheses and no broad implementation Synthesis.','{"source":"Documents 133-134"}'::jsonb);

-- ---------------------------------------------------------------------------
-- INTERNAL A0 PRODUCT — NO ASSURANCE RECORD CREATED HERE
-- ---------------------------------------------------------------------------

INSERT INTO product.product(entity_uuid)
VALUES ('c8000000-0000-0000-0000-000000000020');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,conclusion_text,
    applicability_summary,limitations_summary
) VALUES (
    'c8100000-0000-0000-0000-000000000020',
    'c8000000-0000-0000-0000-000000000020',
    'evidence_map',
    'Mapa Exploratório — Ambient AI Scribes: distribuição do corpus N3-01',
    'OES internal methodological validation',
    DATE '2026-10-05',
    NULL,
    'under_review',
    'No corpus estruturado, porém não exaustivo, herdado do N3-01, os estudos comparativos randomizados se concentram em tempo de documentação, carga/exaustão e trabalho fora do horário, com cobertura também de qualidade/segurança; estudos e relatórios contextuais ampliam sobretudo o domínio de implementação, e quatro sínteses existentes correspondem aos quatro outcomes críticos. Células sem Study contado representam apenas gaps aparentes dentro das fontes consultadas.',
    'Mapa interno e exploratório do corpus N3-01; não representa toda a literatura sobre ambient AI scribes e não deve ser interpretado como recomendação clínica ou avaliação de eficácia.',
    'Cobertura não exaustiva herdada do N3-01: PubMed/MEDLINE foi a única base bibliográfica reproduzivelmente executada; Europe PMC e OpenAlex direto não foram operacionais; Embase/Scopus/CINAHL não foram pesquisados; discovery suplementar não equivale a segunda base; classificações do MAP-01 são realizadas por IA e permanecem unverified; nenhum controle humano qualificado ou A3 é alegado; gaps são exclusivamente aparentes e dependentes do framework/corpus/cutoff.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES
('c8100000-0000-0000-0000-000000000020','c8100000-0000-0000-0000-000000000002','primary',1),
('c8100000-0000-0000-0000-000000000020','e1000000-0000-0000-0000-000000000002','source_corpus',1);

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
    'c8100000-0000-0000-0000-000000000010',
    'c8100000-0000-0000-0000-000000000020',
    'map_framework_informs_product',
    'Exact MAP-01 FrameworkVersion used by exploratory Evidence Map product',
    'active'
);

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'c8800000-0000-0000-0000-000000000001',
    'c8100000-0000-0000-0000-000000000020',
    'current',TIMESTAMPTZ '2026-10-06 11:50:00-03','OES_MAP01_AI',
    'MAP-01 reuses the N3-01 corpus with evidence cutoff 2026-10-05; mapping executed on 2026-10-06 without extending that scientific cutoff.',
    'active'
);

COMMIT;
