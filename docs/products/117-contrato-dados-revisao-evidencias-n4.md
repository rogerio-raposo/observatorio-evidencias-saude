# 117 — Contrato de Dados da Revisão de Evidências — N4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status:** contrato de dados candidato  
**Dependências canônicas:** Documentos 04, 10–15, 20–21, 40, 115–116; migrations 001–014

---

# 1. Finalidade

Formalizar o contrato persistente e os invariantes executáveis da Revisão de Evidências N4 antes da migration 015.

---

# 2. Identidade do produto

Para N4 v0.1:

- `product_type = evidence_review`;
- exactly one primary Investigation;
- `depth_level = N4`;
- Product/Investigation evidence cutoff coerentes;
- ProductVersion current para publicação;
- subtype obrigatório em `investigation_type`.

---

# 3. Subtypes iniciais

Vocabulário inicial:

- `systematic_review_intervention`;
- `systematic_review_diagnostic`;
- `systematic_review_prognosis`;
- `systematic_review_prediction`;
- `systematic_review_prevalence`;
- `qualitative_evidence_synthesis`;
- `mixed_methods_review`;
- `network_meta_analysis_review`;
- `living_systematic_review`;
- `other_n4`.

Fixture inicial:

> `systematic_review_intervention`

---

# 4. Protocolo

`investigation_version.protocol_artifact_uuid` é obrigatório.

Para N4 formal:

- artifact ativo;
- hash disponível;
- created_at anterior à primeira Search definitiva, salvo protocolo de update explicitamente justificado;
- emendas posteriores não substituem silenciosamente o protocolo original.

---

# 5. Protocol registration

Registro externo não é universalmente obrigatório em v0.1.

Entretanto, o contrato exige decisão explícita.

Representação:

- artifact role `protocol_registration`, quando registrado; ou
- MethodDecision `N4_PROTOCOL_REGISTRATION_DECISION` com estado/justificativa quando não registrado/não aplicável.

Ausência completa de registro/decisão gera warning.

---

# 6. Infrastructure Readiness Gate

Obrigatório antes da busca definitiva.

Representação em `investigation.method_decision`:

- `decision_type = other`;
- `stage = cross_cutting`;
- `decision_code = N4_INFRASTRUCTURE_READINESS`;
- `planned_flag = true`;
- `impact_payload.state` em:
  - `ready`;
  - `ready_with_documented_conditions`;
  - `not_ready`;
- domains em `impact_payload.domains`;
- required source names/classes em payload quando aplicável.

Para publicação formal:

> `state = ready`

`ready_with_documented_conditions` permite desenvolvimento/execução condicionada, mas não publicação.

---

# 7. Domínios obrigatórios do readiness

Fixture/contrato devem representar:

- bibliographic_coverage;
- reviewer_availability;
- search_expertise;
- appraisal_expertise;
- certainty_expertise;
- statistical_expertise quando aplicável;
- software_compute;
- artifact_versioning;
- a3_pathway;
- conflicts_governance.

---

# 8. ReviewerAssignment

Nova tabela candidata:

> `investigation.reviewer_assignment`

Campos:

- reviewer_assignment_uuid UUID PK;
- investigation_version_uuid FK;
- stage;
- actor;
- actor_type;
- role;
- qualification_payload JSONB;
- independent_flag BOOLEAN;
- scope_payload JSONB;
- conflict_payload JSONB;
- assigned_at TIMESTAMPTZ;
- ended_at TIMESTAMPTZ NULL;
- record_status active|superseded;
- supersedes_reviewer_assignment_uuid.

Append-preserving.

---

# 9. ReviewerAssignment — actor_type

Permitidos em v0.1:

- `human_reviewer`;
- `human_expert`.

IA não poderá receber assignment que satisfaça controle humano N4.

---

# 10. ReviewerAssignment — stages

- search;
- screening;
- extraction;
- appraisal;
- synthesis;
- certainty;
- reporting;
- cross_cutting.

---

# 11. ReviewerAssignment — roles

- review_lead;
- search_peer_reviewer;
- primary_reviewer;
- secondary_reviewer;
- data_extractor;
- data_verifier;
- appraisal_reviewer;
- certainty_reviewer;
- statistical_reviewer;
- adjudicator;
- reporting_reviewer;
- expert_independent_reviewer;
- other.

---

# 12. Qualification payload

Contrato mínimo:

`qualification_payload.qualified = true` para assignment usado no gate.

Também exigir:

- `basis` não vazio;
- `domain` ou descrição equivalente;
- quando pertinente, framework/tool expertise.

Não inferir qualificação do `actor`.

---

# 13. Conflict payload

Forma mínima:

- `declared` boolean;
- `managed` boolean quando declared=true;
- descrição opcional.

Unmanaged conflict em assignment usado para controle obrigatório:

> error

---

# 14. Assignment válido no tempo

Para uma decisão/controle contar:

- assignment ativo;
- `assigned_at <= performed/decided_at`;
- `ended_at IS NULL` ou data posterior/igual;
- stage/role compatíveis;
- actor idêntico.

---

# 15. QualityControlRecord

Reutilizar migration 014.

Controles N4 usam os tipos existentes:

- search_strategy_peer_review;
- screening_pilot;
- screening_secondary_verification;
- critical_data_verification;
- risk_of_bias_verification;
- synthesis_statistical_review;
- certainty_verification;
- reporting_verification.

Escopo mais forte será codificado em `scope_payload`.

---

# 16. Scope payload N4

Exemplos de campos:

- `coverage = all_records | sample | all_critical_results | all_assessments`;
- `mode = independent_duplicate | independent_verification | adjudication`;
- Search IDs;
- target UUIDs;
- framework;
- outcome scope;
- exception method decision quando aplicável.

---

# 17. Busca — source_class

Cada Search N4 deverá registrar em `filters_payload.source_class` um dos valores:

- bibliographic_database;
- trial_registry;
- grey_literature;
- regulatory;
- regional_database;
- citation_chasing;
- institutional;
- other.

---

# 18. Cobertura bibliográfica mínima

Regra geral N4 v0.1:

> pelo menos duas Searches `completed` com `source_class=bibliographic_database`.

Além disso, o readiness poderá declarar `required_source_names`.

Para publicação:

> todas as required sources declaradas deverão possuir Search completed ou MethodDecision explícita que altere formalmente o protocolo e permaneça metodologicamente aceitável.

Uma única base não pode publicar N4 formal.

---

# 19. Search exports

Search bibliográfica formal deverá possuir:

> `export_artifact_uuid` não nulo

Exceções somente se a plataforma não permitir export, com MethodDecision e artefato equivalente auditável.

---

# 20. Search peer review

Exigir:

- reviewer assignment stage search, role search_peer_reviewer;
- qualified=true;
- independent=true;
- QCR `search_strategy_peer_review`;
- actor correspondente;
- decision=passed;
- evidence artifact quando checklist/relatório existir.

Ausência:

> error

---

# 21. Screening title/abstract

Padrão formal:

- dois reviewers distintos;
- assignments válidos em screening;
- independent=true;
- duas decisões iniciais por target.

Exceção somente se MethodDecision ativa:

> `N4_TITLE_ABSTRACT_SCREENING_EXCEPTION`

com risco/mitigação/justificativa e compatibilidade com subtype.

Fixture formal inicial não utilizará exceção.

---

# 22. Screening full text

Obrigatório:

- dois reviewers distintos;
- duas decisões iniciais;
- assignments qualificados;
- independent=true;
- exclusão com reason;
- discordância resolvida.

Sem exceção geral em v0.1.

---

# 23. Discordâncias

Para target/stage com decisões iniciais diferentes:

exigir um de:

- ScreeningDecision com `adjudication_flag=true`; ou
- QCR com resolution payload rastreável e actor adjudicator válido.

Unresolved disagreement:

> error

---

# 24. PRISMA flow

Não persistir tabela.

Derivar de:

- Searches;
- SearchHits;
- dedup clusters;
- ScreeningDecisions;
- Study/Report links;
- statuses.

View deverá apresentar contagens derivadas.

---

# 25. Critical Result

Para v0.1:

> ResultVersion é crítico quando contribui para SynthesisVersion ligada ao ProductVersion com role `primary` ou `critical`.

---

# 26. Independent extraction

Para cada critical ResultVersion:

exigir pelo menos dois active provenance records:

- `target_version_uuid = result_version_uuid`;
- `process_type = n4_independent_extraction`;
- actors distintos;
- source report/location rastreável;
- actors com reviewer assignments válidos stage extraction;
- independent=true.

---

# 27. Extraction consensus

Se os `source_value` das extrações independentes forem diferentes:

exigir provenance adicional:

> `process_type = n4_extraction_consensus`

com actor/artefato/resolution compatível.

O ResultVersion guarda o valor reconciliado.

---

# 28. Critical data quality control

Exigir QCR:

- `control_type = critical_data_verification`;
- human actor qualificado;
- scope = all_critical_results;
- decision=passed.

Esse QCR não substitui as duas extrações independentes; comprova o fechamento do controle.

---

# 29. RiskAssessment

Evidência material à síntese deverá possuir RiskAssessment apropriada.

Para systematic_review_intervention fixture:

> cada Study que contribui para synthesis primária/crítica deverá ter RiskAssessment.

---

# 30. Independent appraisal judgments

Para cada RiskAssessmentVersion final relevante:

exigir pelo menos dois provenance records:

- `process_type = n4_independent_appraisal_judgement`;
- target = RiskAssessmentVersion;
- actors distintos;
- qualified appraisal assignments;
- independent=true.

Quando julgamentos diferirem:

> exigir `n4_appraisal_consensus` provenance ou resolution QCR.

---

# 31. Risk of bias quality control

Exigir QCR:

- `risk_of_bias_verification`;
- human qualified;
- coverage=all_assessments;
- passed.

---

# 32. Synthesis

N4 formal requer ao menos uma SynthesisVersion ligada ao ProductVersion, salvo estado explicitamente no-evidence/non-estimable suportado por contrato futuro.

Fixture v0.1:

> meta-analysis pairwise de intervenção.

---

# 33. Synthesis artifacts

Para synthesis quantitativa calculada pelo OES:

exigir:

- `code_artifact_uuid`;
- `analysis_dataset_artifact_uuid`;
- software/version;
- executed_at;
- result_summary.

---

# 34. Statistical review

Quando `synthesis_type` indicar método quantitativo complexo ou meta-analysis calculada:

exigir:

- reviewer assignment stage synthesis, role statistical_reviewer;
- qualified=true;
- QCR `synthesis_statistical_review`;
- decision=passed.

Fixture formal exige.

---

# 35. Missing evidence / ROB-ME

Quando aplicável, representar como RiskAssessment:

- target_entity_uuid = Synthesis entity;
- framework = ROB-ME;
- outcome_entity_uuid quando aplicável;
- domains/instrument payload.

Fixture formal de intervenção/meta-analysis deverá incluir ROB-ME sintético.

---

# 36. CertaintyAssessment

Cada synthesis/outcome decisório deverá possuir CertaintyAssessment quando framework aplicável.

Fixture:

> GRADE.

---

# 37. Independent certainty judgments

Para cada CertaintyAssessmentVersion final:

exigir pelo menos dois provenance records:

- `process_type = n4_independent_certainty_judgement`;
- target = CertaintyAssessmentVersion;
- actors distintos;
- valid certainty reviewer assignments;
- independent=true.

Se divergirem:

> `n4_certainty_consensus` ou resolution QCR.

---

# 38. Certainty quality control

Exigir QCR:

- certainty_verification;
- human qualified;
- scope=all_material_certainty_assessments;
- passed.

---

# 39. Summary of Findings

Para systematic_review_intervention com GRADE:

exigir artifact ligado ao ProductVersion ou CertaintyAssessment:

> role `summary_of_findings`

Fixture deverá possuir artifact rastreável.

---

# 40. Reproducibility artifacts

Para fixture formal/meta-analysis:

exigir ao menos:

- protocol;
- search exports das bases;
- search peer review artifact;
- analysis dataset;
- analysis code;
- summary_of_findings.

PRISMA flow pode ser derivado e renderizado; artifact persistido é desejável mas não condição estrutural inicial.

---

# 41. Currency

ProductVersion formal exige active CurrencyState.

Estados seguem contrato comum.

---

# 42. Assurance

Formal N4 exige:

- AI methodological verification = passed;
- owner governance approval = approved;
- expert independent review = approved;
- assurance derivado = A3.

A3 não substitui stage controls.

---

# 43. Expert review assignment

Para coerência operacional, o expert que produz AssuranceRecord A3 deverá possuir assignment:

- stage=cross_cutting;
- role=expert_independent_reviewer;
- qualified=true;
- independent=true.

O AssuranceRecord continua sendo o elemento que eleva assurance.

---

# 44. Publication gate — identidade/protocolo

Errors candidatos:

- MISSING_PRODUCT_VERSION;
- WRONG_PRODUCT_TYPE;
- MISSING_PRIMARY_INVESTIGATION;
- MULTIPLE_PRIMARY_INVESTIGATIONS;
- WRONG_DEPTH_LEVEL;
- MISSING_N4_SUBTYPE;
- CUTOFF_MISMATCH;
- NON_CURRENT_INVESTIGATION;
- MISSING_PROTOCOL;
- PROTOCOL_NOT_PROSPECTIVE;
- INFRASTRUCTURE_NOT_READY.

---

# 45. Publication gate — busca

- INSUFFICIENT_BIBLIOGRAPHIC_COVERAGE;
- MISSING_REQUIRED_SEARCH_SOURCE;
- MISSING_SEARCH_EXPORT;
- MISSING_SEARCH_PEER_REVIEW;
- UNQUALIFIED_SEARCH_PEER_REVIEW;
- OPEN_SEARCH_DEVIATION.

---

# 46. Publication gate — seleção

- MISSING_DUPLICATE_TITLE_ABSTRACT_SCREENING;
- MISSING_DUPLICATE_FULL_TEXT_SCREENING;
- UNQUALIFIED_SCREENING_REVIEWER;
- UNRESOLVED_SCREENING_DISAGREEMENT;
- MISSING_FULLTEXT_EXCLUSION_REASON.

---

# 47. Publication gate — extração/appraisal

- MISSING_CRITICAL_RESULT_DUPLICATE_EXTRACTION;
- UNQUALIFIED_EXTRACTION_REVIEWER;
- UNRESOLVED_EXTRACTION_DISAGREEMENT;
- MISSING_RISK_ASSESSMENT;
- MISSING_DUPLICATE_RISK_OF_BIAS_ASSESSMENT;
- UNQUALIFIED_APPRAISAL_REVIEWER;
- UNRESOLVED_APPRAISAL_DISAGREEMENT.

---

# 48. Publication gate — synthesis/certainty

- MISSING_SYNTHESIS;
- MISSING_REPRODUCIBLE_ANALYSIS_ARTIFACT;
- MISSING_STATISTICAL_REVIEW quando aplicável;
- MISSING_MISSING_EVIDENCE_ASSESSMENT quando aplicável;
- MISSING_CERTAINTY_ASSESSMENT;
- MISSING_DUPLICATE_CERTAINTY_ASSESSMENT;
- UNRESOLVED_CERTAINTY_DISAGREEMENT;
- MISSING_SUMMARY_OF_FINDINGS quando aplicável.

---

# 49. Publication gate — governança

- MISSING_AI_METHODOLOGICAL_VERIFICATION;
- MISSING_OWNER_APPROVAL;
- MISSING_EXPERT_INDEPENDENT_REVIEW;
- UNQUALIFIED_EXPERT_REVIEWER;
- ASSURANCE_BELOW_A3;
- MISSING_PUBLICATION_DATE;
- ACTIVE_REVISE_OR_FAILED_CONTROL;
- INVALIDATED_DEPENDENCY.

---

# 50. Warnings

Candidatos:

- PROTOCOL_NOT_EXTERNALLY_REGISTERED;
- GREY_LITERATURE_LIMITED;
- NO_META_ANALYSIS;
- NO_LOCAL_EVIDENCE;
- HIGH_HETEROGENEITY;
- HIGH_RISK_OF_BIAS_PREDOMINATES;
- SEARCH_UPDATE_RECOMMENDED;
- REPRODUCIBILITY_LIMITED_BY_LICENSE.

---

# 51. EvidenceReviewView

Schema:

> `oes.evidence_review_view/0.1`

Seções:

- schema_version;
- identity;
- question;
- investigation;
- subtype;
- infrastructure_readiness;
- protocol;
- registration;
- amendments_and_deviations;
- reviewer_assignments;
- method;
- searches;
- search_peer_review;
- selection_flow;
- included_studies;
- excluded_full_text;
- extraction_controls;
- study_characteristics;
- risk_of_bias;
- results;
- syntheses;
- heterogeneity;
- sensitivity_analyses;
- missing_evidence;
- certainty;
- summary_of_findings;
- applicability;
- limitations;
- reproducibility;
- references;
- audit.

---

# 52. Audit

Incluir:

- assurance_level;
- publishable;
- publication_issues;
- reviewer_assignment_summary;
- qualified_stage_controls_satisfied;
- readiness_state;
- protocol_deviations_open;
- lineage_available;
- invalidated_dependencies;
- reproducibility_artifacts;
- assurance_records.

---

# 53. Experimental mode

Fixture formal poderá simular humanos qualificados apenas para testar o contrato.

Regra obrigatória:

> **atores sintéticos devem ser explicitamente rotulados synthetic e nunca interpretados como revisão humana real.**

Um Caso Real N4 na configuração atual deverá falhar readiness e permanecer experimental.

---

# 54. Fixture sintética formal

A fixture candidata deverá demonstrar:

- subtype systematic_review_intervention;
- readiness=ready;
- protocolo prospectivo;
- 3 bases bibliográficas sintéticas ou reais de fixture;
- exports rastreáveis;
- PRESS/search peer review sintético;
- dois screeners independentes;
- full-text exclusion com motivo;
- dois RCT Studies;
- duplicate extraction;
- duplicate RoB 2;
- pairwise meta-analysis sintética;
- code + dataset artifacts;
- statistical review;
- ROB-ME;
- duplicate GRADE;
- SoF;
- AI verification;
- owner approval;
- expert independent review;
- A3;
- published=true;
- publication gate aberto.

---

# 55. Testes adversariais mínimos

Deverão provar que publicação fecha quando:

1. readiness != ready;
2. existe apenas uma base bibliográfica;
3. search peer review falta;
4. um screener falta;
5. full-text duplicate screening falta;
6. disagreement não é resolvido;
7. segunda extração crítica falta;
8. segundo appraisal falta;
9. code/dataset de meta-analysis falta;
10. statistical review falta;
11. ROB-ME requerido falta;
12. segundo certainty judgment falta;
13. SoF falta;
14. expert review falta;
15. A3 falta;
16. dependency invalidated.

---

# 56. Critérios de PASS do contrato

PASS exige:

- migration aplicada;
- reviewer_assignment append-preserving;
- fixture formal A3 publishable;
- EvidenceReviewView coerente;
- todos os testes negativos bloqueiam corretamente;
- AI nunca satisfaz reviewer assignment humano;
- A3 não bypassa stage controls;
- PRISMA counts deriváveis;
- rebuild from zero;
- regressões N0–N3/F2-B/S4/S5.

---

# 57. Migration candidata

> `database/015_evidence_review_contract.sql`

DDL:

> `investigation.reviewer_assignment`

Mais:

- mutation guard;
- helper functions;
- publication issues/gate;
- EvidenceReviewView;
- indexes/constraints.

Nenhuma outra tabela nova nesta versão.

---

# 58. Arquivos candidatos

- `database/015_evidence_review_contract.sql`;
- `database/f3-evidence-review-fixtures.sql`;
- `database/f3-evidence-review-tests.sql`;
- `database/f3-evidence-review-rebuild-check.sql`.

---

# 59. Próxima etapa

> **Implementar migration 015, fixture e testes, integrar ao S5 e obter PASS técnico antes de qualquer template N4.**

---

**Resultado:** contrato de dados N4 v0.1 consolidado; implementação autorizada.