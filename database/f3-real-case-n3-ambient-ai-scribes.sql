-- OES Fase 3 — Real Case N3-01
-- Ambient AI scribes in outpatient clinicians
-- Experimental Rapid Evidence Synthesis (A0)
-- Requires baseline + migrations 002–014.

BEGIN;

-- ---------------------------------------------------------------------------
-- TRACEABLE ARTIFACTS
-- ---------------------------------------------------------------------------

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,
    hash_algorithm,mime_type,original_filename,created_by,status
) VALUES
(
    'e9000000-0000-0000-0000-000000000001',
    'protocol',
    'docs/products/106-caso-real-n3-ambient-ai-scribes-protocolo.md',
    '314451f9e07268ac5e7b4752faa07c10599b373f',
    'git-blob-sha1','text/markdown',
    '106-caso-real-n3-ambient-ai-scribes-protocolo.md',
    'oes-real-n3','active'
),
(
    'e9000000-0000-0000-0000-000000000002',
    'summary_of_findings',
    'docs/products/109-caso-real-n3-ambient-ai-scribes-sintese-grade-sof.md',
    'a23b6bc0988ae02b42a243a6e462df7c96bd407b',
    'git-blob-sha1','text/markdown',
    '109-caso-real-n3-ambient-ai-scribes-sintese-grade-sof.md',
    'oes-real-n3','active'
);

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000001','OES-Q-2026-000701','Question','oes-real-n3'),
('e0000000-0000-0000-0000-000000000002','OES-I-2026-000701','Investigation','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
(
 'e1000000-0000-0000-0000-000000000001',
 'e0000000-0000-0000-0000-000000000001',
 1,'current','oes-real-n3','initial',
 'Real N3 question — ambient AI scribes'
),
(
 'e1000000-0000-0000-0000-000000000002',
 'e0000000-0000-0000-0000-000000000002',
 1,'current','oes-real-n3','initial',
 'Real N3 experimental investigation'
);

INSERT INTO investigation.question(entity_uuid)
VALUES ('e0000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload,time_horizon_payload
) VALUES (
    'e1000000-0000-0000-0000-000000000001',
    'e0000000-0000-0000-0000-000000000001',
    'Ambient AI scribes reduzem a carga de documentação clínica sem comprometer a qualidade das notas?',
    'Em clínicos que atuam em atendimento ambulatorial, o uso de ambient AI scribes, comparado à documentação usual sem ambient scribe, reduz o tempo de documentação e a carga/burnout sem degradar materialmente a qualidade ou segurança das notas?',
    'intervention','PICO',
    '{"population":"outpatient clinicians","intervention":"ambient AI scribe","comparator":"usual documentation without ambient scribe","critical_outcomes":["documentation time","workload/work exhaustion","work outside work","note quality/safety"],"case":"real-n3-01"}'::jsonb,
    '{"cutoff":"2026-10-05","update_window_start":"2025-01-01"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('e0000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'e1000000-0000-0000-0000-000000000002',
    'e0000000-0000-0000-0000-000000000002',
    'e0000000-0000-0000-0000-000000000001',
    'rapid_evidence_synthesis','N3','M1',
    'Rapidly update comparative evidence on ambient AI scribes for outpatient clinician documentation burden, workload/burnout and note quality/safety while preserving explicit rapid-method limitations and governance blockers.',
    'e9000000-0000-0000-0000-000000000001',
    DATE '2026-10-05',DATE '2026-10-05','completed'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'e1000000-0000-0000-0000-000000000002',
    'e1000000-0000-0000-0000-000000000001',
    'primary',1
);

INSERT INTO artifact.entity_link(
    artifact_uuid,entity_version_uuid,role,sequence_no
) VALUES
(
    'e9000000-0000-0000-0000-000000000001',
    'e1000000-0000-0000-0000-000000000002',
    'protocol',1
),
(
    'e9000000-0000-0000-0000-000000000002',
    'e1000000-0000-0000-0000-000000000002',
    'summary_of_findings',2
);

-- ---------------------------------------------------------------------------
-- RAPID-METHOD RESTRICTIONS / PROTOCOL DEVIATION
-- ---------------------------------------------------------------------------

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,decision_type,stage,
    decision_code,planned_flag,rationale,risk_payload,mitigation_payload,
    impact_payload,resolution_status,decided_by,decided_at,record_status
) VALUES
(
 'e6000000-0000-0000-0000-000000000001',
 'e1000000-0000-0000-0000-000000000002',
 'rapid_restriction','search','limited_database_coverage',true,
 'The protocol restricts the rapid update to PubMed plus one supplementary source/citation channel instead of a full N4 database set.',
 '{"risk":"missed studies indexed only in other bibliographic databases"}'::jsonb,
 '{"mitigation":"citation chasing of baseline review and key trials; explicit disclosure; reroute to N4 if material uncertainty emerges"}'::jsonb,
 '{"expected_impact":"reduced retrieval completeness"}'::jsonb,
 'accepted','OES_REAL_N3_METHOD',TIMESTAMPTZ '2026-10-05 20:00:00-03','active'
),
(
 'e6000000-0000-0000-0000-000000000002',
 'e1000000-0000-0000-0000-000000000002',
 'rapid_restriction','search','english_portuguese_language_focus',true,
 'The rapid update focuses on English and Portuguese records.',
 '{"risk":"language bias"}'::jsonb,
 '{"mitigation":"disclose restriction and avoid claiming global absence of evidence"}'::jsonb,
 '{"expected_impact":"possible missed non-English/Portuguese evidence"}'::jsonb,
 'accepted','OES_REAL_N3_METHOD',TIMESTAMPTZ '2026-10-05 20:01:00-03','active'
),
(
 'e6000000-0000-0000-0000-000000000003',
 'e1000000-0000-0000-0000-000000000002',
 'rapid_restriction','screening','comparative_effectiveness_priority',true,
 'Randomized/comparative designs are prioritized for effectiveness; prospective noncomparative studies are retained only for contextual implementation/safety.',
 '{"risk":"real-world implementation evidence may be underrepresented in causal synthesis"}'::jsonb,
 '{"mitigation":"contextual evidence is retained in separate strata and never pooled with randomized effects"}'::jsonb,
 '{"expected_impact":"stronger internal validity for comparative claims with narrower implementation coverage"}'::jsonb,
 'accepted','OES_REAL_N3_METHOD',TIMESTAMPTZ '2026-10-05 20:02:00-03','active'
),
(
 'e6000000-0000-0000-0000-000000000004',
 'e1000000-0000-0000-0000-000000000002',
 'rapid_restriction','certainty','focused_critical_outcomes',true,
 'Certainty is restricted to documentation time, workload/work exhaustion, work outside work and note quality/safety.',
 '{"risk":"secondary organizational outcomes are not formally graded"}'::jsonb,
 '{"mitigation":"critical outcomes were pre-specified in the protocol and secondary outcomes remain descriptive"}'::jsonb,
 '{"expected_impact":"certainty statements apply only to critical outcomes"}'::jsonb,
 'accepted','OES_REAL_N3_METHOD',TIMESTAMPTZ '2026-10-05 20:03:00-03','active'
),
(
 'e6000000-0000-0000-0000-000000000005',
 'e1000000-0000-0000-0000-000000000002',
 'rapid_restriction','synthesis','no_new_meta_analysis',true,
 'A structured narrative/SWiM-compatible synthesis is pre-specified because outcomes, units, products and comparator structures are heterogeneous.',
 '{"risk":"no pooled summary estimate"}'::jsonb,
 '{"mitigation":"report study-specific estimates and direction/consistency without vote counting"}'::jsonb,
 '{"expected_impact":"lower quantitative compression but better protection against invalid pooling"}'::jsonb,
 'accepted','OES_REAL_N3_METHOD',TIMESTAMPTZ '2026-10-05 20:04:00-03','active'
),
(
 'e6000000-0000-0000-0000-000000000006',
 'e1000000-0000-0000-0000-000000000002',
 'protocol_deviation','search','EUROPE_PMC_RUNTIME_ACCESS_FAILURE',false,
 'Europe PMC could not be executed/retrieved reproducibly in the available runtime.',
 '{"risk":"reduced retrieval completeness and reproducibility of the planned second bibliographic source"}'::jsonb,
 '{"mitigation":"targeted publisher/DOI-index discovery plus backward/forward citation chasing of the baseline review and major trials"}'::jsonb,
 '{"residual_impact":"a risk of missed records remains and is disclosed as a rapid-method limitation"}'::jsonb,
 'mitigated','OES_REAL_N3_METHOD',TIMESTAMPTZ '2026-10-05 20:20:00-03','active'
);

-- ---------------------------------------------------------------------------
-- SEARCHES
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,executed_at,
    result_count,strategy_version,operator,status
) VALUES
(
 'e2000000-0000-0000-0000-000000000001',
 'OES-SRCH-2026-000701',
 'e1000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '("ambient AI" OR "ambient artificial intelligence" OR "ambient scribe" OR "AI scribe" OR "ambient listening") AND (documentation OR note OR "clinical note" OR EHR OR "electronic health record") AND (physician OR clinician OR provider OR practitioner) AND (time OR workload OR burnout OR quality OR accuracy)',
 '{"date_from":"2025-01-01","date_to":"2026-10-05","language_focus":["English","Portuguese"],"result_count_unavailable":true}'::jsonb,
 TIMESTAMPTZ '2026-10-05 20:10:00-03',
 NULL,'real-n3-v1','OES_REAL_N3_AI','completed'
),
(
 'e2000000-0000-0000-0000-000000000002',
 'OES-SRCH-2026-000702',
 'e1000000-0000-0000-0000-000000000002',
 'Targeted publisher/DOI index + citation chasing','Publisher/DOI/Citation',
 'Targeted discovery of ambient-AI-scribe randomized trials, safety/quality studies, and citations from Bracken 2025 and included trials',
 '{"protocol_substitution_for":"Europe PMC","result_count_unavailable":true,"non_equivalence_disclosed":true}'::jsonb,
 TIMESTAMPTZ '2026-10-05 20:21:00-03',
 NULL,'real-n3-v1','OES_REAL_N3_AI','completed'
);

-- ---------------------------------------------------------------------------
-- OUTCOMES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000010','OES-O-2026-000701','Outcome','oes-real-n3'),
('e0000000-0000-0000-0000-000000000011','OES-O-2026-000702','Outcome','oes-real-n3'),
('e0000000-0000-0000-0000-000000000012','OES-O-2026-000703','Outcome','oes-real-n3'),
('e0000000-0000-0000-0000-000000000013','OES-O-2026-000704','Outcome','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('e1000000-0000-0000-0000-000000000010','e0000000-0000-0000-0000-000000000010',1,'current','oes-real-n3','initial','Documentation time'),
('e1000000-0000-0000-0000-000000000011','e0000000-0000-0000-0000-000000000011',1,'current','oes-real-n3','initial','Clinician workload/work exhaustion'),
('e1000000-0000-0000-0000-000000000012','e0000000-0000-0000-0000-000000000012',1,'current','oes-real-n3','initial','Work outside work / after-hours'),
('e1000000-0000-0000-0000-000000000013','e0000000-0000-0000-0000-000000000013',1,'current','oes-real-n3','initial','Note quality and safety');

INSERT INTO evidence.outcome(entity_uuid)
VALUES
('e0000000-0000-0000-0000-000000000010'),
('e0000000-0000-0000-0000-000000000011'),
('e0000000-0000-0000-0000-000000000012'),
('e0000000-0000-0000-0000-000000000013');

INSERT INTO evidence.outcome_version(
    version_uuid,entity_uuid,preferred_name,definition,
    domain,direction_of_benefit,unit_family,status
) VALUES
('e1000000-0000-0000-0000-000000000010','e0000000-0000-0000-0000-000000000010','Documentation time','Time spent documenting or time in notes attributable to clinical documentation workflow.','efficiency','lower','continuous','active'),
('e1000000-0000-0000-0000-000000000011','e0000000-0000-0000-0000-000000000011','Clinician workload / work exhaustion','Workload, work exhaustion or closely related clinician burden measures.','wellbeing','lower','continuous','active'),
('e1000000-0000-0000-0000-000000000012','e0000000-0000-0000-0000-000000000012','Work outside work','Documentation-related work outside scheduled work or after-hours EHR work.','efficiency','lower','continuous','active'),
('e1000000-0000-0000-0000-000000000013','e0000000-0000-0000-0000-000000000013','Note quality / safety','Documentation quality, inaccuracies, omissions, hallucinations or potentially harmful note errors.','safety','higher_quality_lower_error','mixed','active');

-- ---------------------------------------------------------------------------
-- STUDIES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000101','OES-ST-2026-000701','Study','oes-real-n3'),
('e0000000-0000-0000-0000-000000000102','OES-ST-2026-000702','Study','oes-real-n3'),
('e0000000-0000-0000-0000-000000000103','OES-ST-2026-000703','Study','oes-real-n3'),
('e0000000-0000-0000-0000-000000000104','OES-ST-2026-000704','Study','oes-real-n3'),
('e0000000-0000-0000-0000-000000000105','OES-ST-2026-000705','Study','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('e1000000-0000-0000-0000-000000000101','e0000000-0000-0000-0000-000000000101',1,'current','oes-real-n3','initial','Lukac randomized trial'),
('e1000000-0000-0000-0000-000000000102','e0000000-0000-0000-0000-000000000102',1,'current','oes-real-n3','initial','Afshar stepped-wedge randomized trial'),
('e1000000-0000-0000-0000-000000000103','e0000000-0000-0000-0000-000000000103',1,'current','oes-real-n3','initial','Chowdhury randomized crossover trial'),
('e1000000-0000-0000-0000-000000000104','e0000000-0000-0000-0000-000000000104',1,'current','oes-real-n3','initial','Stults pre-post QI study'),
('e1000000-0000-0000-0000-000000000105','e0000000-0000-0000-0000-000000000105',1,'current','oes-real-n3','initial','Taylor prospective note-quality pilot');

INSERT INTO evidence.study(entity_uuid)
VALUES
('e0000000-0000-0000-0000-000000000101'),
('e0000000-0000-0000-0000-000000000102'),
('e0000000-0000-0000-0000-000000000103'),
('e0000000-0000-0000-0000-000000000104'),
('e0000000-0000-0000-0000-000000000105');

INSERT INTO evidence.study_version(
    version_uuid,entity_uuid,study_type,design,title_or_label,
    sample_size,recruitment_context,status
) VALUES
('e1000000-0000-0000-0000-000000000101','e0000000-0000-0000-0000-000000000101','primary_study','pragmatic_randomized_controlled_trial','Lukac et al. ambient AI scribes randomized trial',238,'{"setting":"outpatient","country":"United States","specialties":14}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000102','e0000000-0000-0000-0000-000000000102','primary_study','stepped_wedge_individually_randomized_pragmatic_trial','Afshar et al. ambient AI well-being trial',66,'{"setting":"ambulatory clinics","country":"United States","states":2}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000103','e0000000-0000-0000-0000-000000000103','primary_study','randomized_crossover_trial','Chowdhury et al. ambient scribe head-to-head crossover trial',160,'{"setting":"outpatient","country":"United States"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000104','e0000000-0000-0000-0000-000000000104','primary_study','before_after_quality_improvement','Stults et al. ambient AI documentation platform evaluation',100,'{"setting":"outpatient health system","country":"United States"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000105','e0000000-0000-0000-0000-000000000105','primary_study','prospective_quality_improvement_pilot','Taylor et al. ambient listening note-quality pilot',31,'{"setting":"ambulatory clinics","country":"United States","notes_generated":7545,"notes_formally_evaluated":356}'::jsonb,'active');

-- ---------------------------------------------------------------------------
-- REPORTS: SIX INCLUDED/CONTEXTUAL + FOUR EXCLUDED
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000201','OES-RP-2026-000701','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000202','OES-RP-2026-000702','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000203','OES-RP-2026-000703','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000204','OES-RP-2026-000704','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000205','OES-RP-2026-000705','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000206','OES-RP-2026-000706','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000207','OES-RP-2026-000707','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000208','OES-RP-2026-000708','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000209','OES-RP-2026-000709','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000210','OES-RP-2026-000710','Report','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
)
SELECT
    ('e1000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
    ('e0000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
    1,'current','oes-real-n3','initial','Real N3 report'
FROM generate_series(201,210) AS g(n);

INSERT INTO evidence.report(entity_uuid)
SELECT ('e0000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid
FROM generate_series(201,210) AS g(n);

INSERT INTO evidence.report_version(
    version_uuid,entity_uuid,report_type,title,publication_date,
    journal_or_source,language,publication_status,full_text_status,
    bibliographic_payload,status
) VALUES
(
 'e1000000-0000-0000-0000-000000000201','e0000000-0000-0000-0000-000000000201',
 'primary_report','Ambient AI Scribes in Clinical Practice: A Randomized Trial',
 DATE '2025-11-26','NEJM AI','en','published','available',
 '{"pmid":"41497288","pmcid":"PMC12768499","doi":"10.1056/aioa2501000","role":"primary comparative RCT"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000202','e0000000-0000-0000-0000-000000000202',
 'primary_report','A Pragmatic Randomized Controlled Trial of Ambient Artificial Intelligence to Improve Health Practitioner Well-Being',
 DATE '2025-11-26','NEJM AI','en','published','available',
 '{"pmid":"41625485","pmcid":"PMC12858090","doi":"10.1056/aioa2500945","trial_registration":"NCT06517082","role":"primary comparative randomized evidence"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000203','e0000000-0000-0000-0000-000000000203',
 'primary_report','Comparing ambient scribes: a randomized crossover clinical trial addressing ambient scribe technologies'' impact on physician burnout',
 DATE '2026-05-01','JAMIA','en','published','available',
 '{"pmid":"41729180","doi":"10.1093/jamia/ocag018","role":"secondary head-to-head randomized stratum"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000204','e0000000-0000-0000-0000-000000000204',
 'primary_report','Evaluation of an Ambient Artificial Intelligence Documentation Platform for Clinicians',
 DATE '2025-05-01','JAMA Network Open','en','published','available',
 '{"pmid":"40314951","pmcid":"PMC12048851","doi":"10.1001/jamanetworkopen.2025.8614","role":"contextual implementation evidence"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000205','e0000000-0000-0000-0000-000000000205',
 'primary_report','Quality of Clinical Notes Created by Ambient Listening Generative AI: Pragmatic Prospective Pilot Study',
 DATE '2026-04-17','JMIR Medical Informatics','en','published','available',
 '{"pmid":"41996389","pmcid":"PMC13089619","doi":"10.2196/86474","role":"contextual note-quality/safety evidence"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000206','e0000000-0000-0000-0000-000000000206',
 'systematic_review','Artificial Intelligence (AI) - Powered Documentation Systems in Healthcare: A Systematic Review',
 DATE '2025-02-18','Journal of Medical Systems','en','published','available',
 '{"pmid":"39966286","pmcid":"PMC11835907","doi":"10.1007/s10916-025-02157-4","included_studies":11,"role":"context/non-duplication/citation chasing"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000207','e0000000-0000-0000-0000-000000000207',
 'preprint','A Randomized-Clinical Trial of Two Ambient Artificial Intelligence Scribes to Reduce Documentation Burden and Improve Physician Well-being',
 DATE '2025-07-10','medRxiv','en','preprint','available',
 '{"pmid":"40672471","doi":"10.1101/2025.07.10.25331333","exclusion_reason":"duplicate_report"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000208','e0000000-0000-0000-0000-000000000208',
 'primary_report','Ambient Artificial Intelligence Scribe Adoption and Documentation Time in the Emergency Department',
 NULL,'Annals of Emergency Medicine','en','published','available',
 '{"pmid":"41665590","doi":"10.1016/j.annemergmed.2025.12.017","exclusion_reason":"wrong_setting"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000209','e0000000-0000-0000-0000-000000000209',
 'primary_report','Ambient Artificial Intelligence Versus Human Scribes in the Emergency Department',
 NULL,'Annals of Emergency Medicine','en','published','available',
 '{"pmid":"41251650","doi":"10.1016/j.annemergmed.2025.10.006","exclusion_reason":"wrong_setting"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000210','e0000000-0000-0000-0000-000000000210',
 'scoping_review','Ambient AI Scribes in the Emergency Department: A Scoping Review of Current Evidence',
 NULL,'Emergency medicine literature','en','published','available',
 '{"pmid":"42585863","exclusion_reason":"wrong_setting + secondary_review_not_update_unit"}'::jsonb,'active'
);

INSERT INTO evidence.study_report_link(
    link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
    confidence,evidence_note,reviewer,decision_date,status
) VALUES
('e2800000-0000-0000-0000-000000000201','e0000000-0000-0000-0000-000000000101','e0000000-0000-0000-0000-000000000201','primary_report','high','Final peer-reviewed report for Lukac trial.','OES_REAL_N3_AI',DATE '2026-10-05','active'),
('e2800000-0000-0000-0000-000000000202','e0000000-0000-0000-0000-000000000102','e0000000-0000-0000-0000-000000000202','primary_report','high','Primary peer-reviewed report for Afshar trial.','OES_REAL_N3_AI',DATE '2026-10-05','active'),
('e2800000-0000-0000-0000-000000000203','e0000000-0000-0000-0000-000000000103','e0000000-0000-0000-0000-000000000203','primary_report','high','Primary peer-reviewed report for Chowdhury crossover trial.','OES_REAL_N3_AI',DATE '2026-10-05','active'),
('e2800000-0000-0000-0000-000000000204','e0000000-0000-0000-0000-000000000104','e0000000-0000-0000-0000-000000000204','primary_report','high','Primary report for contextual QI study.','OES_REAL_N3_AI',DATE '2026-10-05','active'),
('e2800000-0000-0000-0000-000000000205','e0000000-0000-0000-0000-000000000105','e0000000-0000-0000-0000-000000000205','primary_report','high','Primary report for contextual note-quality pilot.','OES_REAL_N3_AI',DATE '2026-10-05','active');

-- ---------------------------------------------------------------------------
-- SEARCH HITS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,
    source_record_id,raw_payload,raw_title,raw_year,raw_identifier,
    source_rank,resolution_status
) VALUES
('e2500000-0000-0000-0000-000000000201','OES-HIT-2026-000701','e2000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000201','PMID:41497288','{"captured":true}'::jsonb,'Ambient AI Scribes in Clinical Practice: A Randomized Trial',2025,'PMID:41497288',1,'linked'),
('e2500000-0000-0000-0000-000000000202','OES-HIT-2026-000702','e2000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000202','PMID:41625485','{"captured":true}'::jsonb,'A Pragmatic Randomized Controlled Trial of Ambient Artificial Intelligence to Improve Health Practitioner Well-Being',2025,'PMID:41625485',2,'linked'),
('e2500000-0000-0000-0000-000000000203','OES-HIT-2026-000703','e2000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000203','PMID:41729180','{"captured":true}'::jsonb,'Comparing ambient scribes: a randomized crossover clinical trial',2026,'PMID:41729180',3,'linked'),
('e2500000-0000-0000-0000-000000000204','OES-HIT-2026-000704','e2000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000204','PMID:40314951','{"captured":true}'::jsonb,'Evaluation of an Ambient Artificial Intelligence Documentation Platform for Clinicians',2025,'PMID:40314951',4,'linked'),
('e2500000-0000-0000-0000-000000000205','OES-HIT-2026-000705','e2000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000205','PMID:41996389','{"captured":true}'::jsonb,'Quality of Clinical Notes Created by Ambient Listening Generative AI',2026,'PMID:41996389',5,'linked'),
('e2500000-0000-0000-0000-000000000206','OES-HIT-2026-000706','e2000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000206','PMID:39966286','{"captured":true}'::jsonb,'Artificial Intelligence Powered Documentation Systems in Healthcare: A Systematic Review',2025,'PMID:39966286',6,'linked'),
('e2500000-0000-0000-0000-000000000207','OES-HIT-2026-000707','e2000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000207','PMID:40672471','{"captured":true,"via":"citation_chasing"}'::jsonb,'A Randomized-Clinical Trial of Two Ambient Artificial Intelligence Scribes',2025,'PMID:40672471',1,'linked'),
('e2500000-0000-0000-0000-000000000208','OES-HIT-2026-000708','e2000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000208','PMID:41665590','{"captured":true,"via":"targeted_discovery"}'::jsonb,'Ambient Artificial Intelligence Scribe Adoption and Documentation Time in the Emergency Department',2026,'PMID:41665590',2,'linked'),
('e2500000-0000-0000-0000-000000000209','OES-HIT-2026-000709','e2000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000209','PMID:41251650','{"captured":true,"via":"targeted_discovery"}'::jsonb,'Ambient Artificial Intelligence Versus Human Scribes in the Emergency Department',2026,'PMID:41251650',3,'linked'),
('e2500000-0000-0000-0000-000000000210','OES-HIT-2026-000710','e2000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000210','PMID:42585863','{"captured":true,"via":"targeted_discovery"}'::jsonb,'Ambient AI Scribes in the Emergency Department: A Scoping Review of Current Evidence',2026,'PMID:42585863',4,'linked');

-- ---------------------------------------------------------------------------
-- SCREENING: TITLE/ABSTRACT + FULL TEXT
-- ---------------------------------------------------------------------------

INSERT INTO investigation.screening_decision(
    screening_uuid,oes_screening_id,investigation_version_uuid,
    target_entity_uuid,stage,reviewer,decision,exclusion_reason,
    decided_at,parent_decision_uuid,adjudication_flag
) VALUES
('e3500000-0000-0000-0000-000000000201','OES-SCR-2026-000701','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000201','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:30:00-03',NULL,false),
('e3500000-0000-0000-0000-000000000202','OES-SCR-2026-000702','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000202','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:30:10-03',NULL,false),
('e3500000-0000-0000-0000-000000000203','OES-SCR-2026-000703','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000203','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:30:20-03',NULL,false),
('e3500000-0000-0000-0000-000000000204','OES-SCR-2026-000704','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000204','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:30:30-03',NULL,false),
('e3500000-0000-0000-0000-000000000205','OES-SCR-2026-000705','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000205','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:30:40-03',NULL,false),
('e3500000-0000-0000-0000-000000000206','OES-SCR-2026-000706','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000206','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:30:50-03',NULL,false),
('e3500000-0000-0000-0000-000000000207','OES-SCR-2026-000707','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000207','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:31:00-03',NULL,false),
('e3500000-0000-0000-0000-000000000208','OES-SCR-2026-000708','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000208','title_abstract','OES_REAL_N3_AI','exclude','wrong_setting',TIMESTAMPTZ '2026-10-05 20:31:10-03',NULL,false),
('e3500000-0000-0000-0000-000000000209','OES-SCR-2026-000709','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000209','title_abstract','OES_REAL_N3_AI','exclude','wrong_setting',TIMESTAMPTZ '2026-10-05 20:31:20-03',NULL,false),
('e3500000-0000-0000-0000-000000000210','OES-SCR-2026-000710','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000210','title_abstract','OES_REAL_N3_AI','exclude','wrong_setting + secondary_review_not_update_unit',TIMESTAMPTZ '2026-10-05 20:31:30-03',NULL,false),
('e3500000-0000-0000-0000-000000000301','OES-SCR-2026-000711','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000201','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:32:00-03','e3500000-0000-0000-0000-000000000201',false),
('e3500000-0000-0000-0000-000000000302','OES-SCR-2026-000712','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000202','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:32:10-03','e3500000-0000-0000-0000-000000000202',false),
('e3500000-0000-0000-0000-000000000303','OES-SCR-2026-000713','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000203','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:32:20-03','e3500000-0000-0000-0000-000000000203',false),
('e3500000-0000-0000-0000-000000000304','OES-SCR-2026-000714','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000204','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:32:30-03','e3500000-0000-0000-0000-000000000204',false),
('e3500000-0000-0000-0000-000000000305','OES-SCR-2026-000715','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000205','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:32:40-03','e3500000-0000-0000-0000-000000000205',false),
('e3500000-0000-0000-0000-000000000306','OES-SCR-2026-000716','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000206','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-05 20:32:50-03','e3500000-0000-0000-0000-000000000206',false),
('e3500000-0000-0000-0000-000000000307','OES-SCR-2026-000717','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000207','full_text','OES_REAL_N3_AI','exclude','duplicate_report',TIMESTAMPTZ '2026-10-05 20:33:00-03','e3500000-0000-0000-0000-000000000207',false);

-- ---------------------------------------------------------------------------
-- RESULTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000301','OES-R-2026-000701','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000302','OES-R-2026-000702','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000303','OES-R-2026-000703','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000304','OES-R-2026-000704','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000305','OES-R-2026-000705','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000306','OES-R-2026-000706','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000307','OES-R-2026-000707','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000308','OES-R-2026-000708','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000309','OES-R-2026-000709','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000310','OES-R-2026-000710','Result','oes-real-n3'),
('e0000000-0000-0000-0000-000000000311','OES-R-2026-000711','Result','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
)
SELECT
    ('e1000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
    ('e0000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
    1,'current','oes-real-n3','initial','Real N3 extracted result'
FROM generate_series(301,311) AS g(n);

INSERT INTO evidence.result(entity_uuid,study_entity_uuid)
VALUES
('e0000000-0000-0000-0000-000000000301','e0000000-0000-0000-0000-000000000101'),
('e0000000-0000-0000-0000-000000000302','e0000000-0000-0000-0000-000000000101'),
('e0000000-0000-0000-0000-000000000303','e0000000-0000-0000-0000-000000000102'),
('e0000000-0000-0000-0000-000000000304','e0000000-0000-0000-0000-000000000102'),
('e0000000-0000-0000-0000-000000000305','e0000000-0000-0000-0000-000000000102'),
('e0000000-0000-0000-0000-000000000306','e0000000-0000-0000-0000-000000000103'),
('e0000000-0000-0000-0000-000000000307','e0000000-0000-0000-0000-000000000103'),
('e0000000-0000-0000-0000-000000000308','e0000000-0000-0000-0000-000000000105'),
('e0000000-0000-0000-0000-000000000309','e0000000-0000-0000-0000-000000000102'),
('e0000000-0000-0000-0000-000000000310','e0000000-0000-0000-0000-000000000101'),
('e0000000-0000-0000-0000-000000000311','e0000000-0000-0000-0000-000000000101');

INSERT INTO evidence.result_version(
    version_uuid,entity_uuid,outcome_entity_uuid,population_descriptor,
    timepoint_label,estimand,measure,reported_value,ci_lower,ci_upper,unit,
    adjusted_flag,analysis_population,missing_data_state,method_payload,status
) VALUES
('e1000000-0000-0000-0000-000000000301','e0000000-0000-0000-0000-000000000301','e0000000-0000-0000-0000-000000000010','{"arm":"Nabla vs usual care","population":"outpatient physicians"}'::jsonb,'trial endpoint','relative change versus control','relative_change_percent','{"value":-9.5}'::jsonb,-17.2,-1.8,'percent',true,'intention_to_treat','reported','{"source":"Lukac 2025"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000302','e0000000-0000-0000-0000-000000000302','e0000000-0000-0000-0000-000000000010','{"arm":"DAX vs usual care","population":"outpatient physicians"}'::jsonb,'trial endpoint','relative change versus control','relative_change_percent','{"value":-1.7}'::jsonb,-9.4,5.9,'percent',true,'intention_to_treat','reported','{"source":"Lukac 2025"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000303','e0000000-0000-0000-0000-000000000303','e0000000-0000-0000-0000-000000000010','{"comparison":"ambient AI vs practice-as-usual","population":"ambulatory health practitioners"}'::jsonb,'24-week trial','mean difference','mean_difference','{"value":-0.36}'::jsonb,-0.55,-0.17,'hours/day',true,'intention_to_treat','reported','{"source":"Afshar 2025"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000304','e0000000-0000-0000-0000-000000000304','e0000000-0000-0000-0000-000000000011','{"comparison":"ambient AI vs practice-as-usual"}'::jsonb,'24-week trial','mean difference','mean_difference','{"value":-0.44}'::jsonb,-0.62,-0.25,'PFI points',true,'intention_to_treat','reported','{"outcome":"work exhaustion/interpersonal disengagement","source":"Afshar 2025"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000305','e0000000-0000-0000-0000-000000000305','e0000000-0000-0000-0000-000000000012','{"comparison":"ambient AI vs practice-as-usual"}'::jsonb,'24-week trial','mean difference','mean_difference','{"value":-0.50}'::jsonb,-0.90,-0.09,'hours/day',true,'intention_to_treat','reported','{"sensitivity":"not robust after excluding top 3% extreme daily observations","source":"Afshar 2025"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000306','e0000000-0000-0000-0000-000000000306','e0000000-0000-0000-0000-000000000010','{"comparison":"Product B vs Product A","population":"outpatient clinicians"}'::jsonb,'crossover endpoint','mean difference','mean_difference','{"value":-3.19}'::jsonb,-4.87,-1.50,'minutes/day',true,'as_analyzed','reported','{"head_to_head":true,"source":"Chowdhury 2026"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000307','e0000000-0000-0000-0000-000000000307','e0000000-0000-0000-0000-000000000012','{"comparison":"Product B vs Product A"}'::jsonb,'crossover endpoint','mean difference','mean_difference','{"value":-2.19}'::jsonb,-4.74,0.37,'minutes/day',true,'as_analyzed','reported','{"head_to_head":true,"source":"Chowdhury 2026"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000308','e0000000-0000-0000-0000-000000000308','e0000000-0000-0000-0000-000000000013','{"population":"AI-generated ambulatory notes formally rated","n_notes":356}'::jsonb,'pilot assessment','proportion','proportion_percent','{"value":5.3,"numerator":19,"denominator":356}'::jsonb,NULL,NULL,'percent',false,'evaluated_notes','reported','{"event":"error posing serious or imminent risk if uncorrected","source":"Taylor 2026"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000309','e0000000-0000-0000-0000-000000000309','e0000000-0000-0000-0000-000000000013','{"comparison":"ambient AI exposure","population":"ambulatory notes"}'::jsonb,'24-week trial','descriptive domain range','mean_domain_range','{"min":3.97,"max":4.99,"scale_max":5}'::jsonb,NULL,NULL,'PDSQI-9 points',false,'trial notes','reported','{"source":"Afshar 2025","interpretation":"high mean documentation-quality scores across domains"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000310','e0000000-0000-0000-0000-000000000310','e0000000-0000-0000-0000-000000000011','{"arm":"DAX vs usual care"}'::jsonb,'trial endpoint','mean difference','mean_difference','{"value":-39.9}'::jsonb,-71.9,-7.9,'PTL points',true,'intention_to_treat','reported','{"outcome":"physician task load","source":"Lukac 2025"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000311','e0000000-0000-0000-0000-000000000311','e0000000-0000-0000-0000-000000000011','{"arm":"Nabla vs usual care"}'::jsonb,'trial endpoint','mean difference','mean_difference','{"value":-31.7}'::jsonb,-63.8,0.4,'PTL points',true,'intention_to_treat','reported','{"outcome":"physician task load","source":"Lukac 2025"}'::jsonb,'active');

INSERT INTO evidence.result_source(
    result_version_uuid,report_version_uuid,source_location,source_type,
    original_text_or_value,extraction_method,is_primary_source,extractor,extracted_at
) VALUES
('e1000000-0000-0000-0000-000000000301','e1000000-0000-0000-0000-000000000201','Abstract/results','text','{"value":-9.5,"ci":[-17.2,-1.8]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:00:00-03'),
('e1000000-0000-0000-0000-000000000302','e1000000-0000-0000-0000-000000000201','Abstract/results','text','{"value":-1.7,"ci":[-9.4,5.9]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:00:10-03'),
('e1000000-0000-0000-0000-000000000303','e1000000-0000-0000-0000-000000000202','Abstract/results','text','{"value":-0.36,"ci":[-0.55,-0.17]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:00:20-03'),
('e1000000-0000-0000-0000-000000000304','e1000000-0000-0000-0000-000000000202','Abstract/results','text','{"value":-0.44,"ci":[-0.62,-0.25]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:00:30-03'),
('e1000000-0000-0000-0000-000000000305','e1000000-0000-0000-0000-000000000202','Abstract/results','text','{"value":-0.50,"ci":[-0.90,-0.09],"sensitivity":"not robust to top-3-percent extreme-value removal"}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:00:40-03'),
('e1000000-0000-0000-0000-000000000306','e1000000-0000-0000-0000-000000000203','Results','text','{"value":-3.19,"ci":[-4.87,-1.50]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:00:50-03'),
('e1000000-0000-0000-0000-000000000307','e1000000-0000-0000-0000-000000000203','Results','text','{"value":-2.19,"ci":[-4.74,0.37]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:01:00-03'),
('e1000000-0000-0000-0000-000000000308','e1000000-0000-0000-0000-000000000205','Abstract/results','text','{"serious_or_imminent_risk_notes":19,"evaluated_notes":356,"percent":5.3}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:01:10-03'),
('e1000000-0000-0000-0000-000000000309','e1000000-0000-0000-0000-000000000202','Abstract/results','text','{"PDSQI9_domain_mean_range":[3.97,4.99]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:01:20-03'),
('e1000000-0000-0000-0000-000000000310','e1000000-0000-0000-0000-000000000201','Abstract/results','text','{"value":-39.9,"ci":[-71.9,-7.9]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:01:30-03'),
('e1000000-0000-0000-0000-000000000311','e1000000-0000-0000-0000-000000000201','Abstract/results','text','{"value":-31.7,"ci":[-63.8,0.4]}'::jsonb,'structured_ai_assisted',true,'OES_REAL_N3_AI',TIMESTAMPTZ '2026-10-05 21:01:40-03');

-- ---------------------------------------------------------------------------
-- RISK OF BIAS / APPRAISAL
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000401','OES-RA-2026-000701','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000402','OES-RA-2026-000702','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000403','OES-RA-2026-000703','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000404','OES-RA-2026-000704','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000405','OES-RA-2026-000705','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000406','OES-RA-2026-000706','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000407','OES-RA-2026-000707','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000408','OES-RA-2026-000708','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000409','OES-RA-2026-000709','RiskAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000410','OES-RA-2026-000710','RiskAssessment','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
)
SELECT
    ('e1000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
    ('e0000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
    1,'current','oes-real-n3','initial','Real N3 appraisal'
FROM generate_series(401,410) AS g(n);

INSERT INTO appraisal.risk_assessment(entity_uuid)
SELECT ('e0000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid
FROM generate_series(401,410) AS g(n);

INSERT INTO appraisal.risk_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    framework,framework_version,target_entity_uuid,outcome_entity_uuid,
    overall_judgement,assessor,assessment_date,verification_status,
    instrument_payload,status
) VALUES
('e1000000-0000-0000-0000-000000000401','e0000000-0000-0000-0000-000000000401','e1000000-0000-0000-0000-000000000002','RoB 2','OES experimental','e0000000-0000-0000-0000-000000000101','e0000000-0000-0000-0000-000000000010','high','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"critical_issue":"time-in-note metric did not capture editing inside scribe platform","late_registration":true}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000402','e0000000-0000-0000-0000-000000000402','e1000000-0000-0000-0000-000000000002','RoB 2','OES experimental','e0000000-0000-0000-0000-000000000101','e0000000-0000-0000-0000-000000000011','some_concerns','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"issues":["open-label self-report","late registration","survey nonresponse"]}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000403','e0000000-0000-0000-0000-000000000403','e1000000-0000-0000-0000-000000000002','RoB 2','OES experimental','e0000000-0000-0000-0000-000000000102','e0000000-0000-0000-0000-000000000010','low','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"strengths":["pretrial registration","prespecified endpoints","ITT","objective EHR metric"]}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000404','e0000000-0000-0000-0000-000000000404','e1000000-0000-0000-0000-000000000002','RoB 2','OES experimental','e0000000-0000-0000-0000-000000000102','e0000000-0000-0000-0000-000000000011','some_concerns','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"issues":["open-label self-report","expectancy/Hawthorne effects"]}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000405','e0000000-0000-0000-0000-000000000405','e1000000-0000-0000-0000-000000000002','RoB 2','OES experimental','e0000000-0000-0000-0000-000000000102','e0000000-0000-0000-0000-000000000012','some_concerns','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"issue":"effect sensitive to removing top 3 percent extreme daily observations"}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000406','e0000000-0000-0000-0000-000000000406','e1000000-0000-0000-0000-000000000002','RoB 2','OES experimental','e0000000-0000-0000-0000-000000000103','e0000000-0000-0000-0000-000000000010','some_concerns','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"issues":["no scribe-free washout","possible carryover","no located public preregistration"]}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000407','e0000000-0000-0000-0000-000000000407','e1000000-0000-0000-0000-000000000002','RoB 2','OES experimental','e0000000-0000-0000-0000-000000000103','e0000000-0000-0000-0000-000000000011','some_concerns','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"issues":["15 percent with no post-product survey","open-label subjective outcomes","possible carryover"]}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000408','e0000000-0000-0000-0000-000000000408','e1000000-0000-0000-0000-000000000002','JBI/QI proportional','OES experimental','e0000000-0000-0000-0000-000000000105','e0000000-0000-0000-0000-000000000013','high','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"issues":["only 4.7 percent of generated notes formally evaluated","project-specific instrument","user physicians rated notes"]}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000409','e0000000-0000-0000-0000-000000000409','e1000000-0000-0000-0000-000000000002','ROBINS-I proportional','OES experimental','e0000000-0000-0000-0000-000000000104','e0000000-0000-0000-0000-000000000010','high','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"issues":["before-after design","secular confounding","early adopter effects","paired survey subset"]}'::jsonb,'active'),
('e1000000-0000-0000-0000-000000000410','e0000000-0000-0000-0000-000000000410','e1000000-0000-0000-0000-000000000002','ROBIS','OES preliminary','e0000000-0000-0000-0000-000000000206',NULL,'some_concerns','OES_REAL_N3_AI',DATE '2026-10-05','ai_verified_only','{"role":"contextual baseline review","issue":"heterogeneous mix of ChatGPT and ambient-AI documentation systems"}'::jsonb,'active');

INSERT INTO appraisal.risk_assessment_domain(
    risk_assessment_version_uuid,domain_code,judgement,rationale,sequence_no
) VALUES
('e1000000-0000-0000-0000-000000000401','D4_measurement','high','Time-in-note did not capture editing within the scribe platform, potentially favoring intervention arms.',4),
('e1000000-0000-0000-0000-000000000402','D4_measurement','some_concerns','Open-label self-reported workload/burnout outcomes may be influenced by expectancy.',4),
('e1000000-0000-0000-0000-000000000403','D4_measurement','low','Objective EHR-derived documentation-time metric with prespecified analysis.',4),
('e1000000-0000-0000-0000-000000000404','D4_measurement','some_concerns','Open-label self-reported well-being outcome.',4),
('e1000000-0000-0000-0000-000000000405','D5_analysis_robustness','some_concerns','WoW result was sensitive to exclusion of extreme observations.',5),
('e1000000-0000-0000-0000-000000000406','D2_carryover','some_concerns','No scribe-free washout; carryover cannot be excluded.',2),
('e1000000-0000-0000-0000-000000000407','D3_missing_outcome','some_concerns','A subset provided no post-product survey data.',3),
('e1000000-0000-0000-0000-000000000408','selection','high','Only a subset of generated notes was formally rated, limiting frequency estimation.',1),
('e1000000-0000-0000-0000-000000000409','confounding','high','Before-after QI design is vulnerable to secular confounding and early-adopter effects.',1),
('e1000000-0000-0000-0000-000000000410','synthesis_interpretation','some_concerns','Broad heterogeneous intervention class limits direct adoption for this focused rapid update.',4);

-- ---------------------------------------------------------------------------
-- FOUR NARRATIVE SYNTHESES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000501','OES-SY-2026-000701','Synthesis','oes-real-n3'),
('e0000000-0000-0000-0000-000000000502','OES-SY-2026-000702','Synthesis','oes-real-n3'),
('e0000000-0000-0000-0000-000000000503','OES-SY-2026-000703','Synthesis','oes-real-n3'),
('e0000000-0000-0000-0000-000000000504','OES-SY-2026-000704','Synthesis','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('e1000000-0000-0000-0000-000000000501','e0000000-0000-0000-0000-000000000501',1,'current','oes-real-n3','initial','Narrative synthesis — documentation time'),
('e1000000-0000-0000-0000-000000000502','e0000000-0000-0000-0000-000000000502',1,'current','oes-real-n3','initial','Narrative synthesis — workload/work exhaustion'),
('e1000000-0000-0000-0000-000000000503','e0000000-0000-0000-0000-000000000503',1,'current','oes-real-n3','initial','Narrative synthesis — work outside work'),
('e1000000-0000-0000-0000-000000000504','e0000000-0000-0000-0000-000000000504',1,'current','oes-real-n3','initial','Narrative synthesis — note quality/safety');

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES
('e0000000-0000-0000-0000-000000000501'),
('e0000000-0000-0000-0000-000000000502'),
('e0000000-0000-0000-0000-000000000503'),
('e0000000-0000-0000-0000-000000000504');

INSERT INTO synthesis.synthesis_version(
    version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
    population_descriptor,comparison_payload,timepoint_payload,estimand,
    synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES
('e1000000-0000-0000-0000-000000000501','e0000000-0000-0000-0000-000000000501','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000010','{"population":"outpatient clinicians"}'::jsonb,'{"primary":"ambient AI vs usual documentation","secondary":"head-to-head ambient-scribe vendors"}'::jsonb,'{"window":"2025-2026 trials"}'::jsonb,'effect on documentation time','narrative_synthesis','new_calculation','structured narrative synthesis / SWiM-compatible rapid update',NULL,'{"direction":"generally favors ambient AI but magnitude varies by product and metric","pooled":false,"usual_care_evidence":["Nabla -9.5% vs control","DAX -1.7% vs control","Afshar -0.36 h/day"],"head_to_head":"Product B vs A -3.19 min/day","contextual":"Stults before-after supports direction but not causal certainty"}'::jsonb,'active',TIMESTAMPTZ '2026-10-05 21:20:00-03'),
('e1000000-0000-0000-0000-000000000502','e0000000-0000-0000-0000-000000000502','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000011','{"population":"outpatient clinicians"}'::jsonb,'{"primary":"ambient AI vs usual documentation"}'::jsonb,'{"window":"trial endpoints"}'::jsonb,'effect on workload/work exhaustion','narrative_synthesis','new_calculation','structured narrative synthesis / SWiM-compatible rapid update',NULL,'{"direction":"favorable in several domains with uncertainty","pooled":false,"evidence":["Afshar work exhaustion -0.44 PFI points","Lukac PTL DAX -39.9","Lukac PTL Nabla -31.7"],"head_to_head_note":"Chowdhury did not show a clear between-product burnout difference"}'::jsonb,'active',TIMESTAMPTZ '2026-10-05 21:21:00-03'),
('e1000000-0000-0000-0000-000000000503','e0000000-0000-0000-0000-000000000503','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000012','{"population":"outpatient clinicians"}'::jsonb,'{"primary":"ambient AI vs usual documentation","secondary":"head-to-head"}'::jsonb,'{"window":"trial endpoints"}'::jsonb,'effect on work outside work','narrative_synthesis','new_calculation','structured narrative synthesis / SWiM-compatible rapid update',NULL,'{"direction":"possible reduction but magnitude is fragile","pooled":false,"usual_care":"Afshar -0.50 h/day, sensitive to extreme-value exclusion","head_to_head":"Chowdhury -2.19 min/day, CI includes no effect"}'::jsonb,'active',TIMESTAMPTZ '2026-10-05 21:22:00-03'),
('e1000000-0000-0000-0000-000000000504','e0000000-0000-0000-0000-000000000504','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000013','{"population":"ambulatory clinical notes"}'::jsonb,'{"exposure":"ambient AI-generated notes"}'::jsonb,'{"window":"trial and prospective pilot"}'::jsonb,'note quality/safety','narrative_synthesis','new_calculation','structured safety narrative synthesis',NULL,'{"direction":"no consistent mean degradation demonstrated, but clinically relevant errors can occur","pooled":false,"evidence":["Afshar PDSQI-9 domain means 3.97-4.99/5","Taylor 5.3% of evaluated notes had serious/imminent-risk errors if uncorrected"],"interpretation":"equivalent safety is not established"}'::jsonb,'active',TIMESTAMPTZ '2026-10-05 21:23:00-03');

INSERT INTO synthesis.contribution(
    synthesis_version_uuid,result_version_uuid,contribution_role,
    included_main_analysis,included_sensitivity,exclusion_reason,notes
) VALUES
('e1000000-0000-0000-0000-000000000501','e1000000-0000-0000-0000-000000000301','usual_care_main',true,false,NULL,'Lukac Nabla arm'),
('e1000000-0000-0000-0000-000000000501','e1000000-0000-0000-0000-000000000302','usual_care_main',true,false,NULL,'Lukac DAX arm'),
('e1000000-0000-0000-0000-000000000501','e1000000-0000-0000-0000-000000000303','usual_care_main',true,false,NULL,'Afshar trial'),
('e1000000-0000-0000-0000-000000000501','e1000000-0000-0000-0000-000000000306','head_to_head_context',false,false,NULL,'Chowdhury product comparison'),
('e1000000-0000-0000-0000-000000000502','e1000000-0000-0000-0000-000000000304','usual_care_main',true,false,NULL,'Afshar work exhaustion'),
('e1000000-0000-0000-0000-000000000502','e1000000-0000-0000-0000-000000000310','usual_care_main',true,false,NULL,'Lukac DAX task load'),
('e1000000-0000-0000-0000-000000000502','e1000000-0000-0000-0000-000000000311','usual_care_main',true,false,NULL,'Lukac Nabla task load'),
('e1000000-0000-0000-0000-000000000503','e1000000-0000-0000-0000-000000000305','usual_care_main',true,false,NULL,'Afshar WoW'),
('e1000000-0000-0000-0000-000000000503','e1000000-0000-0000-0000-000000000307','head_to_head_context',false,false,NULL,'Chowdhury WoW product comparison'),
('e1000000-0000-0000-0000-000000000504','e1000000-0000-0000-0000-000000000308','safety_context',true,false,NULL,'Taylor serious/imminent-risk note errors'),
('e1000000-0000-0000-0000-000000000504','e1000000-0000-0000-0000-000000000309','quality_context',true,false,NULL,'Afshar PDSQI-9 domains');

-- ---------------------------------------------------------------------------
-- FOUR EXPERIMENTAL GRADE CERTAINTY ASSESSMENTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000601','OES-CA-2026-000701','CertaintyAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000602','OES-CA-2026-000702','CertaintyAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000603','OES-CA-2026-000703','CertaintyAssessment','oes-real-n3'),
('e0000000-0000-0000-0000-000000000604','OES-CA-2026-000704','CertaintyAssessment','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('e1000000-0000-0000-0000-000000000601','e0000000-0000-0000-0000-000000000601',1,'current','oes-real-n3','initial','Experimental GRADE — documentation time'),
('e1000000-0000-0000-0000-000000000602','e0000000-0000-0000-0000-000000000602',1,'current','oes-real-n3','initial','Experimental GRADE — workload/work exhaustion'),
('e1000000-0000-0000-0000-000000000603','e0000000-0000-0000-0000-000000000603',1,'current','oes-real-n3','initial','Experimental GRADE — work outside work'),
('e1000000-0000-0000-0000-000000000604','e0000000-0000-0000-0000-000000000604',1,'current','oes-real-n3','initial','Experimental GRADE — note quality/safety');

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES
('e0000000-0000-0000-0000-000000000601'),
('e0000000-0000-0000-0000-000000000602'),
('e0000000-0000-0000-0000-000000000603'),
('e0000000-0000-0000-0000-000000000604');

INSERT INTO appraisal.certainty_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,
    outcome_entity_uuid,framework,framework_version,initial_level,final_level,
    evidence_state,assessment_date,status
) VALUES
('e1000000-0000-0000-0000-000000000601','e0000000-0000-0000-0000-000000000601','e1000000-0000-0000-0000-000000000002','e1000000-0000-0000-0000-000000000501','e0000000-0000-0000-0000-000000000010','GRADE','OES experimental 2026','high','low','evidence_available',DATE '2026-10-05','active'),
('e1000000-0000-0000-0000-000000000602','e0000000-0000-0000-0000-000000000602','e1000000-0000-0000-0000-000000000002','e1000000-0000-0000-0000-000000000502','e0000000-0000-0000-0000-000000000011','GRADE','OES experimental 2026','high','low','evidence_available',DATE '2026-10-05','active'),
('e1000000-0000-0000-0000-000000000603','e0000000-0000-0000-0000-000000000603','e1000000-0000-0000-0000-000000000002','e1000000-0000-0000-0000-000000000503','e0000000-0000-0000-0000-000000000012','GRADE','OES experimental 2026','high','low','evidence_available',DATE '2026-10-05','active'),
('e1000000-0000-0000-0000-000000000604','e0000000-0000-0000-0000-000000000604','e1000000-0000-0000-0000-000000000002','e1000000-0000-0000-0000-000000000504','e0000000-0000-0000-0000-000000000013','GRADE','OES experimental 2026','high','very_low','evidence_available',DATE '2026-10-05','active');

INSERT INTO appraisal.certainty_domain(
    certainty_assessment_version_uuid,domain_code,concern_level,downgrade_steps,
    rationale,reviewer,sequence_no
) VALUES
('e1000000-0000-0000-0000-000000000601','risk_of_bias','serious',1,'Lukac time-in-note has high risk because vendor-platform editing time was not captured.','OES_REAL_N3_AI',1),
('e1000000-0000-0000-0000-000000000601','inconsistency','serious',1,'Effect varies by vendor, metric and study design; DAX versus control did not show a clear reduction while Nabla and Afshar were favorable.','OES_REAL_N3_AI',2),
('e1000000-0000-0000-0000-000000000602','risk_of_bias','serious',1,'Open-label self-reported workload/well-being outcomes are susceptible to expectancy effects.','OES_REAL_N3_AI',1),
('e1000000-0000-0000-0000-000000000602','imprecision_inconsistency','serious',1,'Samples are modest and measures differ; some estimates include no effect.','OES_REAL_N3_AI',2),
('e1000000-0000-0000-0000-000000000603','imprecision_fragility','serious',1,'Afshar WoW estimate was sensitive to removal of extreme observations.','OES_REAL_N3_AI',1),
('e1000000-0000-0000-0000-000000000603','indirectness','serious',1,'Decisive usual-care evidence is concentrated in one system/trial and head-to-head evidence is not equivalent.','OES_REAL_N3_AI',2),
('e1000000-0000-0000-0000-000000000604','risk_of_bias','serious',1,'Safety measurement is heterogeneous and prospective note review sampled only a subset of generated notes.','OES_REAL_N3_AI',1),
('e1000000-0000-0000-0000-000000000604','indirectness','serious',1,'Metrics focus on note quality/errors rather than directly observed patient harm.','OES_REAL_N3_AI',2),
('e1000000-0000-0000-0000-000000000604','imprecision','serious',1,'Potentially serious errors are uncommon and estimates are unstable.','OES_REAL_N3_AI',3);

-- ---------------------------------------------------------------------------
-- PRODUCT — A0 EXPERIMENTAL / UNDER REVIEW
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('e0000000-0000-0000-0000-000000000701','OES-P-2026-000701','Product','oes-real-n3');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
    'e1000000-0000-0000-0000-000000000701',
    'e0000000-0000-0000-0000-000000000701',
    1,'current','oes-real-n3','initial',
    'Real N3-01 experimental product — A0'
);

INSERT INTO product.product(entity_uuid)
VALUES ('e0000000-0000-0000-0000-000000000701');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,conclusion_text,
    applicability_summary,limitations_summary
) VALUES (
    'e1000000-0000-0000-0000-000000000701',
    'e0000000-0000-0000-0000-000000000701',
    'rapid_evidence_synthesis',
    'Síntese Rápida Experimental — Ambient AI Scribes e Carga de Documentação Clínica',
    'OES internal methodological validation',
    DATE '2026-10-05',
    NULL,
    'under_review',
    'Ambient AI scribes podem reduzir o tempo de documentação e alguns componentes de carga/exaustão entre clínicos ambulatoriais, mas o tamanho do benefício varia por produto e contexto. A evidência sobre segurança é muito mais incerta: estudos não demonstram degradação média consistente da qualidade, porém inaccuracies, omissões e erros potencialmente graves foram observados. O corpo atual não sustenta tratar todas as ferramentas como equivalentes nem assumir que ganhos de eficiência implicam segurança equivalente.',
    'A evidência deriva predominantemente de grandes sistemas acadêmicos dos Estados Unidos, early adopters, integrações EHR específicas e versões de produtos em rápida evolução; aplicabilidade formal não avaliada.',
    'Rapid-method limitations: Europe PMC could not be executed reproducibly and was replaced by a less standardized targeted publisher/DOI/citation channel; Embase/Scopus/CINAHL were not searched; result counts are unavailable; English/Portuguese focus; screening, extraction, appraisal and certainty were AI-assisted; qualified human controls and expert review are absent; no new meta-analysis was performed.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    'e1000000-0000-0000-0000-000000000701',
    'e1000000-0000-0000-0000-000000000002',
    'primary',1
);

INSERT INTO product.synthesis_link(
    product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000501','primary',1),
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000502','critical',2),
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000503','critical',3),
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000504','critical',4);

INSERT INTO product.certainty_link(
    product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000601','primary',1),
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000602','critical',2),
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000603','critical',3),
('e1000000-0000-0000-0000-000000000701','e1000000-0000-0000-0000-000000000604','critical',4);

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'e7000000-0000-0000-0000-000000000701',
    'e1000000-0000-0000-0000-000000000701',
    'current',TIMESTAMPTZ '2026-10-05 21:30:00-03',
    'OES_REAL_N3_AI',
    'Rapid update evidence current through the explicit cutoff 2026-10-05.',
    'active'
);

-- Direct contextual provenance for non-effect references.
INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
    source_location,source_value,process_type,transformation,actor,status
) VALUES
(
    'e5000000-0000-0000-0000-000000000701',
    'e1000000-0000-0000-0000-000000000701',
    'context.baseline_review',
    'e1000000-0000-0000-0000-000000000206',
    'Whole report',
    '{"role":"context/non-duplication/citation chasing","adopted_as_effect_source":false}'::jsonb,
    'contextual_reference',
    '{"reason":"baseline systematic review predates key peer-reviewed randomized evidence and is not pooled as an independent effect unit"}'::jsonb,
    'OES_REAL_N3_AI','active'
),
(
    'e5000000-0000-0000-0000-000000000702',
    'e1000000-0000-0000-0000-000000000701',
    'context.implementation_study',
    'e1000000-0000-0000-0000-000000000204',
    'Whole report',
    '{"role":"contextual implementation evidence","adopted_as_causal_effect_source":false}'::jsonb,
    'contextual_reference',
    '{"reason":"before-after/QI evidence supports implementation context but does not enter randomized causal synthesis"}'::jsonb,
    'OES_REAL_N3_AI','active'
);

-- ---------------------------------------------------------------------------
-- AI QUALITY CONTROLS — TRANSPARENT, NEVER HUMAN-QUALIFIED
-- ---------------------------------------------------------------------------

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,independent_flag,decision,scope_payload,
    agreement_payload,discrepancy_payload,resolution_payload,
    performed_at,notes,record_status
) VALUES
(
 'e6500000-0000-0000-0000-000000000001',
 'e1000000-0000-0000-0000-000000000002',
 'search','search_strategy_verification',
 'OES_REAL_N3_AI_SECOND_PASS','ai_system',false,'passed',
 '{"search_ids":["OES-SRCH-2026-000701","OES-SRCH-2026-000702"],"protocol_deviation":"EUROPE_PMC_RUNTIME_ACCESS_FAILURE"}'::jsonb,
 NULL,NULL,NULL,TIMESTAMPTZ '2026-10-05 21:35:00-03',
 'AI-only search strategy check. Does not satisfy qualified human search verification.','active'
),
(
 'e6500000-0000-0000-0000-000000000002',
 'e1000000-0000-0000-0000-000000000002',
 'screening','screening_pilot',
 'OES_REAL_N3_AI_SECOND_PASS','ai_system',false,'passed',
 '{"records_sampled":10,"records_total_materialized":10}'::jsonb,
 '{"agreement":"AI second-pass concordance only"}'::jsonb,
 NULL,NULL,TIMESTAMPTZ '2026-10-05 21:36:00-03',
 'AI-only calibration. Does not satisfy qualified human screening pilot.','active'
),
(
 'e6500000-0000-0000-0000-000000000003',
 'e1000000-0000-0000-0000-000000000002',
 'screening','screening_secondary_verification',
 'OES_REAL_N3_AI_SECOND_PASS','ai_system',false,'passed',
 '{"screening_decision_count":17,"scope":"all materialized decisions"}'::jsonb,
 '{"agreement":"AI second-pass concordance recorded; no human agreement claim"}'::jsonb,
 NULL,NULL,TIMESTAMPTZ '2026-10-05 21:37:00-03',
 'AI secondary screening verification only.','active'
),
(
 'e6500000-0000-0000-0000-000000000004',
 'e1000000-0000-0000-0000-000000000002',
 'extraction','critical_data_verification',
 'OES_REAL_N3_AI_SECOND_PASS','ai_system',false,'passed',
 '{"result_version_count":11,"critical_fields":["reported_value","ci_lower","ci_upper","unit","study/comparator attribution"]}'::jsonb,
 NULL,NULL,NULL,TIMESTAMPTZ '2026-10-05 21:38:00-03',
 'AI critical-data verification only.','active'
),
(
 'e6500000-0000-0000-0000-000000000005',
 'e1000000-0000-0000-0000-000000000002',
 'appraisal','risk_of_bias_verification',
 'OES_REAL_N3_AI_SECOND_PASS','ai_system',false,'passed',
 '{"risk_assessment_count":10,"document":"108-caso-real-n3-ambient-ai-scribes-appraisal.md"}'::jsonb,
 NULL,NULL,NULL,TIMESTAMPTZ '2026-10-05 21:39:00-03',
 'AI RoB/appraisal verification only.','active'
),
(
 'e6500000-0000-0000-0000-000000000006',
 'e1000000-0000-0000-0000-000000000002',
 'certainty','certainty_verification',
 'OES_REAL_N3_AI_SECOND_PASS','ai_system',false,'passed',
 '{"certainty_version_count":4,"document":"109-caso-real-n3-ambient-ai-scribes-sintese-grade-sof.md"}'::jsonb,
 NULL,NULL,NULL,TIMESTAMPTZ '2026-10-05 21:40:00-03',
 'AI GRADE verification only.','active'
);

-- ---------------------------------------------------------------------------
-- LINEAGE
-- ---------------------------------------------------------------------------

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES
('e1000000-0000-0000-0000-000000000201','e1000000-0000-0000-0000-000000000301','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000201','e1000000-0000-0000-0000-000000000302','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000202','e1000000-0000-0000-0000-000000000303','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000202','e1000000-0000-0000-0000-000000000304','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000202','e1000000-0000-0000-0000-000000000305','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000203','e1000000-0000-0000-0000-000000000306','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000203','e1000000-0000-0000-0000-000000000307','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000205','e1000000-0000-0000-0000-000000000308','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000202','e1000000-0000-0000-0000-000000000309','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000201','e1000000-0000-0000-0000-000000000310','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000201','e1000000-0000-0000-0000-000000000311','report_supports_result','result_source','active'),
('e1000000-0000-0000-0000-000000000301','e1000000-0000-0000-0000-000000000501','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000302','e1000000-0000-0000-0000-000000000501','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000303','e1000000-0000-0000-0000-000000000501','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000306','e1000000-0000-0000-0000-000000000501','result_contextual_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000304','e1000000-0000-0000-0000-000000000502','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000310','e1000000-0000-0000-0000-000000000502','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000311','e1000000-0000-0000-0000-000000000502','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000305','e1000000-0000-0000-0000-000000000503','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000307','e1000000-0000-0000-0000-000000000503','result_contextual_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000308','e1000000-0000-0000-0000-000000000504','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000309','e1000000-0000-0000-0000-000000000504','result_contributes_to_synthesis','synthesis.contribution','active'),
('e1000000-0000-0000-0000-000000000501','e1000000-0000-0000-0000-000000000601','synthesis_informs_certainty','certainty.synthesis_version_uuid','active'),
('e1000000-0000-0000-0000-000000000502','e1000000-0000-0000-0000-000000000602','synthesis_informs_certainty','certainty.synthesis_version_uuid','active'),
('e1000000-0000-0000-0000-000000000503','e1000000-0000-0000-0000-000000000603','synthesis_informs_certainty','certainty.synthesis_version_uuid','active'),
('e1000000-0000-0000-0000-000000000504','e1000000-0000-0000-0000-000000000604','synthesis_informs_certainty','certainty.synthesis_version_uuid','active'),
('e1000000-0000-0000-0000-000000000601','e1000000-0000-0000-0000-000000000701','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000602','e1000000-0000-0000-0000-000000000701','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000603','e1000000-0000-0000-0000-000000000701','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000604','e1000000-0000-0000-0000-000000000701','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000206','e1000000-0000-0000-0000-000000000701','contextual_report_informs_product','provenance.record','active');

COMMIT;
