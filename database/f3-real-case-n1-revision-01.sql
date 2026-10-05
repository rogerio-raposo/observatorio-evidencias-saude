-- OES Fase 3 — Real N1-01 revision 01 after adversarial methodological review
-- Creates ProductVersion 2; preserves Version 1 and records first AI verification as revise.

BEGIN;

-- Preserve the first adversarial verification against ProductVersion 1.
INSERT INTO product.assurance_record(
 assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES (
 'a3000000-0000-0000-0000-000000000701',
 'a1000000-0000-0000-0000-000000000701',
 'ai_methodological_verification','OES_AI_METHOD_VERIFICATION_N1_PASS_1','ai_system',false,'revise',
 TIMESTAMPTZ '2026-10-05 15:20:00-03',
 'First adversarial verification identified two material communication issues: false appearance of a single SMD range and overstrong wording about the selective post-cutoff update.',
 '{"document":"80-caso-real-n1-verificacao-metodologica-adversarial-01.md","result":"revise","issues":["separate_meta_analysis_estimates","qualify_post_cutoff_check_as_selective"],"independent_review":false,"expert_review":false}'::jsonb,
 'active'
);

-- Supersede ProductVersion 1; it remains historically reproducible.
UPDATE product.product_version
   SET status='superseded'
 WHERE version_uuid='a1000000-0000-0000-0000-000000000701';

UPDATE core.entity_version
   SET version_status='superseded',
       valid_to=CURRENT_TIMESTAMP
 WHERE version_uuid='a1000000-0000-0000-0000-000000000701';

-- ProductVersion 2.
INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,valid_from,supersedes_version_uuid,created_by,change_type,change_note
) VALUES (
 'a1000000-0000-0000-0000-000000000702',
 'a0000000-0000-0000-0000-000000000701',
 2,'current',CURRENT_TIMESTAMP,
 'a1000000-0000-0000-0000-000000000701',
 'real-n1-01','scientific_correction',
 'Corrects quantitative communication and explicitly qualifies the post-cutoff update as selective after adversarial verification pass 1'
);

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,evidence_cutoff_date,publication_date,status,conclusion_text,applicability_summary,limitations_summary
) VALUES (
 'a1000000-0000-0000-0000-000000000702',
 'a0000000-0000-0000-0000-000000000701',
 'evidence_response',
 'Música gravada no período perioperatório reduz a ansiedade em adultos submetidos a cirurgia?',
 'technical_and_evidence_users',DATE '2026-10-05',NULL,'under_review',
 'Sínteses sistemáticas recentes apontam redução média dos escores de ansiedade perioperatória com intervenções de música gravada em comparação ao cuidado usual ou ausência de música. Na meta-análise de Stoop et al. 2026, o efeito agrupado foi SMD aproximadamente -0,73 (IC95% -0,94 a -0,53). Em outra meta-análise de 2026, Yu et al. reportaram SMD -0,50 (IC95% -0,60 a -0,39) na análise principal. As duas sínteses apontam direção favorável, mas as magnitudes não devem ser tratadas como uma única faixa porque diferem em composição e decisões analíticas. A magnitude e a relevância clínica exatas permanecem incertas por limitações metodológicas dos ensaios, heterogeneidade e possível viés de publicação. Na checagem seletiva OES de estudos posteriores ao cutoff da síntese decisiva, os estudos localizados mantiveram direção geral favorável e não foi identificado sinal que exigisse rerroteamento; essa checagem não pretende completude.',
 'A intervenção é não farmacológica e conceitualmente simples, mas protocolos, preferências, timing, anestesia e contexto assistencial variam. Não foi realizada avaliação formal de aplicabilidade ao Brasil/SUS.',
 'Ansiedade predominantemente autorreferida e sem cegamento do participante; risco de viés importante em parte dos ensaios; heterogeneidade clínica; magnitudes diferentes entre sínteses; possível publication/small-study bias; relevância clínica exata incerta; NNT transformado e não diretamente observado; busca OES seletiva e não exaustiva; certainty formal OES não realizada.'
);

INSERT INTO product.investigation_link(product_version_uuid,investigation_version_uuid,role,sequence_no)
VALUES ('a1000000-0000-0000-0000-000000000702','a1000000-0000-0000-0000-000000000002','primary',1);

INSERT INTO product.currency_state(currency_state_uuid,product_version_uuid,currency_status,assessed_at,assessed_by,rationale,record_status)
VALUES ('a2400000-0000-0000-0000-000000000702','a1000000-0000-0000-0000-000000000702','current',TIMESTAMPTZ '2026-10-05 15:25:00-03','OES','Evidence cutoff unchanged; revision changes interpretation/communication only.','active');

INSERT INTO product.version_change_class(product_version_uuid,change_class,rationale,sequence_no) VALUES
('a1000000-0000-0000-0000-000000000702','scientific_correction','Separate estimates from distinct meta-analyses rather than presenting an informal range.',1),
('a1000000-0000-0000-0000-000000000702','conclusion_change','Qualify the post-cutoff statement as a selective OES check without completeness claim.',2);

-- Provenance for the corrected version remains source-specific.
INSERT INTO provenance.record(provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,source_value,process_type,transformation,actor,status) VALUES
('a5000000-0000-0000-0000-000000000721','a1000000-0000-0000-0000-000000000702','conclusion_text.stoop','a1000000-0000-0000-0000-000000000201','Meta-analysis primary result','{"measure":"SMD","estimate":-0.73,"lower":-0.94,"upper":-0.53,"participants":2242,"role":"decisive"}'::jsonb,'critical_adoption_of_external_meta_analysis',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000722','a1000000-0000-0000-0000-000000000702','conclusion_text.yu','a1000000-0000-0000-0000-000000000202','Primary meta-analysis after reported outlier handling','{"measure":"SMD","estimate":-0.50,"lower":-0.60,"upper":-0.39,"i2_percent":33.3,"total_rcts":33,"primary_analysis_studies":25,"role":"corroborative"}'::jsonb,'corroborative_synthesis',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000723','a1000000-0000-0000-0000-000000000702','key_results.0.effect_estimate','a1000000-0000-0000-0000-000000000201','Meta-analysis primary result','{"measure":"SMD","estimate":-0.73,"lower":-0.94,"upper":-0.53,"participants":2242,"role":"decisive"}'::jsonb,'direct_extraction',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000724','a1000000-0000-0000-0000-000000000702','key_results.1.effect_estimate','a1000000-0000-0000-0000-000000000202','Primary meta-analysis after reported outlier handling','{"measure":"SMD","estimate":-0.50,"lower":-0.60,"upper":-0.39,"i2_percent":33.3,"total_rcts":33,"primary_analysis_studies":25,"role":"corroborative"}'::jsonb,'direct_extraction',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000725','a1000000-0000-0000-0000-000000000702','key_results.2.transformed_nnt','a1000000-0000-0000-0000-000000000201','NNT transformation section','{"estimate":3.9,"type":"transformed_from_continuous_effect","direct_binary_event_nnt":false,"role":"contextual"}'::jsonb,'reported_transformation',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000726','a1000000-0000-0000-0000-000000000702','supporting_evidence.umbrella','a1000000-0000-0000-0000-000000000203','Results/quality assessment','{"direction":"favors_music","reviews":6,"primary_studies":40,"amstar2":{"high":1,"moderate":4,"low":1}}'::jsonb,'corroborative_synthesis',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000727','a1000000-0000-0000-0000-000000000702','limitations_summary','a1000000-0000-0000-0000-000000000204','Results/Discussion','{"finding":"overall risk of bias high in included trials; anxiety benefit observed in part of the studies"}'::jsonb,'critical_appraisal_support',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000728','a1000000-0000-0000-0000-000000000702','update.selective_post_cutoff.nouri','a1000000-0000-0000-0000-000000000205','Abstract/Results','{"direction":"favors_music","post_cutoff":true,"search_context":"selective_non_exhaustive"}'::jsonb,'selective_update_check',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000729','a1000000-0000-0000-0000-000000000702','update.selective_post_cutoff.hsieh','a1000000-0000-0000-0000-000000000206','Abstract/Results','{"direction":"favors_music","post_cutoff":true,"search_context":"selective_non_exhaustive"}'::jsonb,'selective_update_check',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000730','a1000000-0000-0000-0000-000000000702','update.selective_post_cutoff.li','a1000000-0000-0000-0000-000000000207','Abstract/Results','{"direction":"favors_music","post_cutoff":true,"search_context":"selective_non_exhaustive"}'::jsonb,'selective_update_check',NULL,'OES','active');

INSERT INTO provenance.dependency_edge(source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status) VALUES
('a1000000-0000-0000-0000-000000000201','a1000000-0000-0000-0000-000000000702','decisive_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000202','a1000000-0000-0000-0000-000000000702','corroborative_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000203','a1000000-0000-0000-0000-000000000702','umbrella_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000204','a1000000-0000-0000-0000-000000000702','methodological_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000205','a1000000-0000-0000-0000-000000000702','post_cutoff_trial_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000206','a1000000-0000-0000-0000-000000000702','post_cutoff_trial_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000207','a1000000-0000-0000-0000-000000000702','post_cutoff_trial_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000401','a1000000-0000-0000-0000-000000000702','robis_informs_response','ROBIS','active');

COMMIT;