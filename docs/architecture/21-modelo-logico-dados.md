# 21 — Modelo Lógico de Dados do OES

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — primeira consolidação lógica  
**Data de consolidação inicial:** 3 de outubro de 2026  
**Dependência:** Documento 20 — Modelo Conceitual de Dados

## 1. Finalidade

Este documento transforma o modelo conceitual do OES em uma estrutura lógica de entidades, chaves, atributos mínimos e relações, ainda **independente de SGBD e stack tecnológica**.

Não define:

- SQL definitivo;
- tecnologia de armazenamento;
- APIs;
- linguagem de programação;
- interface;
- infraestrutura.

Define o contrato lógico que essas implementações deverão preservar.

---

# PARTE I — REGRAS GERAIS

## 2. Chave interna estável

Toda entidade persistente terá:

- `id` interno estável;
- prefixo OES;
- identidade independente de DOI, PMID, NCT ou outro identificador externo.

Identificadores externos serão aliases, nunca chave primária do conhecimento OES.

## 3. Versionamento lógico

Entidades versionáveis deverão suportar:

- `entity_id`;
- `version_no`;
- `status`;
- `valid_from`;
- `valid_to`, quando aplicável;
- `supersedes_version_id`;
- `created_at`;
- `created_by`.

Estado publicado não será sobrescrito silenciosamente.

## 4. Estados básicos

Vocabulário lógico inicial:

- draft;
- active/current;
- superseded;
- archived;
- invalidated.

Nem toda entidade precisará usar todos os estados.

## 5. Proveniência

Dados críticos deverão admitir proveniência em granularidade de campo ou elemento lógico.

O contrato mínimo de proveniência é definido na entidade `ProvenanceRecord`.

---

# PARTE II — ENTIDADES DE PERGUNTA E INVESTIGAÇÃO

## 6. Question

**ID:** `OES-Q-AAAA-NNNNNN`

Atributos mínimos:

- id;
- version_no;
- parent_question_id, opcional;
- original_text;
- normalized_text;
- question_type;
- structure_type;
- context;
- time_horizon;
- status;
- created_at;
- updated_at.

### Hierarquia

Subperguntas utilizarão autorrelacionamento:

`Question.parent_question_id → Question.id`

Não será criada, por enquanto, entidade separada de Subquestion.

## 7. QuestionComponent

Representa componentes estruturados da pergunta.

Campos:

- id;
- question_id;
- component_type;
- concept_id, opcional;
- free_text;
- sequence;
- required_flag.

`component_type` poderá incluir:

- population;
- intervention;
- exposure;
- comparator;
- outcome;
- index_test;
- reference_standard;
- phenomenon;
- context;
- timepoint.

## 8. Concept

Entidade opcional, mas prevista desde o modelo lógico, para normalização semântica.

**ID:** `OES-C-AAAA-NNNNNN`

Campos:

- id;
- domain;
- preferred_label;
- definition;
- status.

Mapeamentos externos ficarão em `ConceptMapping`.

## 9. ConceptMapping

Campos:

- concept_id;
- terminology;
- external_code;
- external_label;
- version;
- mapping_type.

Exemplos futuros:

- MeSH;
- SNOMED CT;
- ICD;
- ATC;
- DeCS.

A escolha de vocabulários oficiais ocorrerá em etapa posterior.

## 10. Investigation

**ID:** `OES-I-AAAA-NNNNNN`

Campos:

- id;
- version_no;
- primary_question_id;
- investigation_type;
- depth_level;
- maintenance_level;
- objective;
- protocol_reference;
- start_date;
- evidence_cutoff_date;
- status;
- created_at;
- updated_at.

Uma Question pode originar múltiplas Investigations.

## 11. InvestigationQuestion

Entidade associativa para subperguntas e investigações complexas.

Campos:

- investigation_id;
- question_id;
- role;
- sequence.

`role`:

- primary;
- secondary;
- subgroup;
- exploratory.

Isso evita limitar uma Investigation a uma única Question lógica.

---

# PARTE III — BUSCA E RECUPERAÇÃO

## 12. Search

**ID:** `OES-S-AAAA-NNNNNN`

Campos:

- id;
- investigation_id;
- source_name;
- platform;
- exact_strategy;
- filters;
- executed_at;
- result_count;
- strategy_version;
- operator;
- export_artifact_ref;
- status.

Cada execução materialmente distinta recebe um novo Search ID ou nova versão conforme regra operacional.

## 13. SearchHit

Representa uma ocorrência de recuperação em uma Search.

**ID:** `OES-SH-AAAA-NNNNNN`

Campos:

- id;
- search_id;
- report_id, opcional até resolução bibliográfica;
- source_record_id;
- raw_title;
- raw_authors;
- raw_year;
- raw_identifier;
- source_rank, opcional;
- imported_at;
- dedup_cluster_id, opcional;
- resolution_status.

SearchHit é imutável como registro de captura; resoluções posteriores não apagam os dados brutos.

## 14. DedupCluster

**ID:** `OES-DC-AAAA-NNNNNN`

Campos:

- id;
- investigation_id;
- canonical_report_id, opcional;
- status;
- confidence;
- method;
- reviewer;
- decision_date.

Permite auditar deduplicação sem apagar ocorrências originais.

---

# PARTE IV — UNIDADES DE EVIDÊNCIA

## 15. Study

**ID:** `OES-ST-AAAA-NNNNNN`

Campos:

- id;
- version_no;
- study_type;
- design;
- title_or_label;
- start_date;
- end_date;
- recruitment_context;
- sample_size;
- status.

`study_type` poderá distinguir:

- primary_study;
- systematic_review;
- qualitative_study;
- diagnostic_study;
- prognostic_study;
- prediction_model_study;
- other.

O uso de `systematic_review` como Study é aceito quando a revisão for uma unidade de análise do OES.

## 16. StudyIdentifier

Campos:

- study_id;
- namespace;
- value;
- normalized_value;
- identifier_type;
- is_primary;
- verified_at.

Exemplos:

- ClinicalTrials.gov NCT;
- WHO ICTRP;
- ReBEC;
- registro de protocolo;
- identificador interno legado.

## 17. Report

**ID:** `OES-RP-AAAA-NNNNNN`

Representa documento ou manifestação bibliográfica.

Campos:

- id;
- version_no;
- report_type;
- title;
- publication_date;
- journal_or_source;
- language;
- publication_status;
- full_text_status;
- status.

Report pode existir antes de sua vinculação definitiva a Study.

## 18. ReportIdentifier

Campos:

- report_id;
- namespace;
- value;
- normalized_value;
- verified_at.

Exemplos:

- DOI;
- PMID;
- PMCID;
- ISBN;
- URL persistente;
- accession number.

## 19. StudyReportLink

Resolve a relação **N:M Study ↔ Report**.

Campos:

- study_id;
- report_id;
- relation_type;
- confidence;
- evidence_note;
- reviewer;
- decision_date;
- status.

`relation_type` poderá incluir:

- primary_report;
- secondary_report;
- protocol;
- follow_up;
- subgroup_report;
- correction;
- multiple_studies_reported.

Esta entidade substitui qualquer suposição rígida de que cada Report pertence a apenas um Study.

---

# PARTE V — OUTCOMES E RESULTS

## 20. Outcome

**ID:** `OES-O-AAAA-NNNNNN`

Outcome será entidade reutilizável.

Campos:

- id;
- preferred_name;
- definition;
- domain;
- direction_of_benefit;
- unit_family;
- status.

A entidade não substitui a definição operacional específica do estudo.

## 21. OutcomeOperationalization

Campos:

- id;
- study_id;
- outcome_id;
- report_id, opcional;
- study_label;
- instrument;
- threshold;
- timepoint_definition;
- unit;
- notes.

Permite mapear diferentes operacionalizações para um mesmo constructo.

## 22. Result

**ID:** `OES-RS-AAAA-NNNNNN`

Campos mínimos:

- id;
- version_no;
- study_id;
- outcome_id;
- operationalization_id, opcional;
- population_descriptor;
- group_a;
- group_b;
- timepoint;
- estimand;
- measure;
- reported_value;
- derived_value;
- variance_or_se;
- confidence_interval_lower;
- confidence_interval_upper;
- unit;
- adjusted_flag;
- analysis_population;
- missing_data_state;
- status.

## 23. ResultSource

Entidade associativa Report ↔ Result.

Campos:

- result_id;
- report_id;
- source_location;
- source_type;
- original_text_or_value;
- extraction_method;
- is_primary_source;
- extractor;
- extracted_at.

Um Result pode possuir múltiplas fontes documentais.

## 24. DerivationRecord

Campos:

- id;
- result_id;
- input_value;
- formula_or_method;
- parameters;
- software;
- software_version;
- code_reference;
- derived_at;
- reviewer.

Nenhum valor derivado deve existir sem DerivationRecord quando a transformação for material.

---

# PARTE VI — TRIAGEM E EXTRAÇÃO

## 25. ScreeningDecision

**ID:** `OES-SC-AAAA-NNNNNN`

Campos:

- id;
- investigation_id;
- report_id;
- stage;
- reviewer;
- decision;
- exclusion_reason;
- decided_at;
- parent_decision_id, opcional;
- adjudication_flag.

Permite múltiplos revisores e decisões independentes.

## 26. ExtractionRecord

**ID:** `OES-DE-AAAA-NNNNNN`

Campos:

- id;
- investigation_id;
- study_id;
- report_id, opcional;
- extractor;
- extraction_date;
- verification_status;
- verifier;
- status;
- version_no.

O conteúdo extraído materializa ou atualiza Study, Report e Result, mantendo ProvenanceRecord.

---

# PARTE VII — AVALIAÇÃO CRÍTICA

## 27. RiskAssessment

**ID:** `OES-RB-AAAA-NNNNNN`

Campos:

- id;
- investigation_id;
- framework;
- framework_version;
- target_type;
- target_id;
- outcome_id, opcional;
- overall_judgement;
- assessor;
- assessment_date;
- verification_status;
- status;
- version_no.

## 28. RiskAssessmentDomain

Campos:

- risk_assessment_id;
- domain_code;
- judgement;
- rationale;
- supporting_reference;
- sequence.

A separação permite preservar a lógica original de cada ferramenta.

---

# PARTE VIII — SÍNTESE

## 29. Synthesis

**ID:** `OES-SY-AAAA-NNNNNN`

Campos:

- id;
- version_no;
- investigation_id;
- outcome_id, opcional;
- population_descriptor;
- comparison;
- timepoint;
- estimand;
- synthesis_type;
- method;
- model;
- software;
- software_version;
- code_reference;
- analysis_dataset_ref;
- result_summary;
- status;
- executed_at.

## 30. SynthesisContribution

Resolve Result N:M Synthesis.

Campos:

- synthesis_id;
- result_id;
- contribution_role;
- transformed_value;
- weight, opcional;
- included_main_analysis;
- included_sensitivity;
- exclusion_reason;
- notes.

## 31. SynthesisStatistic

Campos:

- synthesis_id;
- statistic_name;
- value;
- lower;
- upper;
- scale;
- notes.

Pode armazenar:

- pooled effect;
- tau²;
- tau;
- I²;
- prediction interval;
- incoherence measure;
- outros parâmetros.

## 32. ReviewFinding

**ID:** `OES-RF-AAAA-NNNNNN`

Representa achado de síntese qualitativa ou não numérica.

Campos:

- id;
- synthesis_id;
- finding_text;
- phenomenon;
- supporting_study_count;
- status;
- version_no.

Permite vínculo explícito com GRADE-CERQual.

---

# PARTE IX — CERTEZA/CONFIANÇA

## 33. CertaintyAssessment

**ID:** `OES-CE-AAAA-NNNNNN`

Campos:

- id;
- version_no;
- investigation_id;
- synthesis_id, opcional;
- review_finding_id, opcional;
- outcome_id, opcional;
- framework;
- framework_version;
- initial_level, quando aplicável;
- final_level;
- assessment_date;
- status.

Regra de integridade:

- GRADE quantitativo deverá apontar para Synthesis/outcome;
- CERQual deverá apontar para ReviewFinding;
- ausência de evidência deverá usar estado específico, não forçar `very_low`.

## 34. CertaintyDomainJudgement

Campos:

- certainty_assessment_id;
- domain_code;
- concern_level;
- downgrade_steps;
- upgrade_steps;
- rationale;
- reviewer;
- sequence.

## 35. CertaintyReview

Campos:

- certainty_assessment_id;
- reviewer;
- role;
- independent_flag;
- decision;
- reviewed_at;
- disagreement_note.

---

# PARTE X — PRODUTOS

## 36. Product

**ID:** `OES-P-AAAA-NNNNNN`

Campos:

- id;
- version_no;
- product_type;
- title;
- intended_audience;
- evidence_cutoff_date;
- publication_date;
- status;
- conclusion_text;
- applicability_summary.

`product_type` poderá incluir Ficha de Evidência e demais produtos OES.

## 37. ProductInvestigation

Campos:

- product_id;
- investigation_id;
- role;
- sequence.

## 38. ProductSynthesis

Campos:

- product_id;
- synthesis_id;
- role;
- sequence.

## 39. ProductCertainty

Campos:

- product_id;
- certainty_assessment_id;
- role;
- sequence.

A Ficha de Evidência será, nesta primeira modelagem lógica, tratada como **Product subtype**, preservando possibilidade futura de promoção a Knowledge Object próprio.

Essa decisão é reversível e deverá ser testada na validação.

---

# PARTE XI — PROVENIÊNCIA TRANSVERSAL

## 40. ProvenanceRecord

**ID:** `OES-PV-AAAA-NNNNNN`

Campos:

- id;
- target_entity_type;
- target_entity_id;
- target_version_no;
- field_path;
- source_report_id, opcional;
- source_location, opcional;
- source_value, opcional;
- process_type;
- process_record_id, opcional;
- transformation;
- actor;
- created_at.

## 41. Regra de granularidade

Proveniência por campo será obrigatória para:

- Results;
- julgamentos críticos de avaliação;
- valores derivados;
- conclusões que dependam de transformação;
- dados cuja alteração possa mudar síntese ou certeza.

Para metadados triviais, proveniência agregada poderá ser suficiente.

---

# PARTE XII — IDENTIDADE E DEDUPLICAÇÃO

## 42. Princípios

1. IDs internos nunca serão reutilizados.
2. identificador externo não define sozinho a identidade OES;
3. DOI/PMID identificam primariamente Report;
4. registro de ensaio identifica primariamente Study;
5. título/autor/ano são evidências de identidade, não chave;
6. merges deverão ser auditáveis;
7. split posterior deverá ser possível.

## 43. MergeDecision

**ID:** `OES-MD-AAAA-NNNNNN`

Campos:

- id;
- entity_type;
- candidate_a_id;
- candidate_b_id;
- decision;
- confidence;
- rationale;
- method;
- reviewer;
- decided_at.

## 44. Reversibilidade

Nenhum merge destrutivo deverá apagar:

- IDs anteriores;
- fontes;
- histórico;
- decisões.

Entidades mescladas poderão receber estado `superseded` apontando para a identidade canônica.

---

# PARTE XIII — INTEGRIDADE REFERENCIAL CONCEITUAL

## 45. Regras mínimas

- Result exige Study.
- Result exige Outcome ou justificativa explícita para outcome não estruturado.
- Result derivado exige DerivationRecord.
- Result utilizado em Synthesis exige SynthesisContribution.
- Certainty GRADE exige Synthesis/outcome identificável.
- Certainty CERQual exige ReviewFinding.
- SearchHit exige Search.
- ScreeningDecision exige Investigation e Report.
- RiskAssessment exige target válido.
- Product publicado exige evidence_cutoff_date.
- Product que comunica certeza deve apontar para CertaintyAssessment vigente.
- versão superseded não pode ser tratada como current.

---

# PARTE XIV — FLUXO LÓGICO

## 46. Fluxo principal

```text
Question
  → Investigation
    → Search
      → SearchHit
        → Report
          ↔ Study
            → Result
              → Synthesis
                → CertaintyAssessment
                  → Product
```

Fluxos transversais:

```text
ScreeningDecision → Report
ExtractionRecord → Study/Report/Result
RiskAssessment → Study/Result
ProvenanceRecord → campos críticos
Versioning → entidades persistentes
```

---

# PARTE XV — DECISÕES LÓGICAS CONSOLIDADAS

## 47. Decisões

1. Question terá hierarquia por autorreferência.
2. Investigation poderá vincular múltiplas Questions via InvestigationQuestion.
3. Concept será previsto para normalização semântica, sem fixar ainda vocabulário.
4. Outcome será entidade própria reutilizável.
5. Study ↔ Report será N:M por StudyReportLink.
6. SearchHit será preservado como ocorrência bruta de recuperação.
7. Deduplicação será auditável e reversível.
8. Study e Report terão identificadores externos em tabelas próprias.
9. Result sempre manterá vínculo com Study e proveniência documental.
10. Transformações materiais gerarão DerivationRecord.
11. ScreeningDecision suportará múltiplos revisores.
12. RiskAssessment terá domínios separados.
13. SynthesisContribution materializará Result N:M Synthesis.
14. ReviewFinding suportará síntese qualitativa e CERQual.
15. CertaintyAssessment será explicitamente vinculada à unidade avaliada.
16. Product agregará Investigation/Synthesis/Certainty por relações próprias.
17. Ficha de Evidência será inicialmente modelada como Product subtype.
18. ProvenanceRecord será transversal.
19. MergeDecision preservará identidade e reversibilidade.
20. Nenhuma decisão acima fixa tecnologia física.

---

# PARTE XVI — QUESTÕES PARA VALIDAÇÃO

## 48. Antes do modelo físico

Validar com casos reais:

- ensaio randomizado com artigo principal + follow-up + protocolo;
- coorte com múltiplos outcomes/timepoints;
- revisão sistemática usada como evidência de N1/N2;
- network meta-analysis;
- estudo diagnóstico;
- modelo de predição;
- síntese qualitativa + CERQual;
- Ficha de Evidência atualizada após novo estudo;
- publicação que contém mais de um estudo;
- estudo com relatório sem DOI/PMID;
- guideline/HTA sem Study subjacente direto;
- correção/retração;
- atualização que altera certeza sem alterar estimativa principal.

---

# PARTE XVII — PRÓXIMA ETAPA

A próxima etapa será a **validação arquitetural por casos de uso**, antes do modelo físico.

Objetivos:

1. testar cardinalidades;
2. detectar entidades ausentes;
3. testar proveniência;
4. testar versionamento;
5. testar atualização da Ficha de Evidência;
6. testar documentos não convencionais;
7. revisar o modelo lógico antes de escolher tecnologia.

---

**Documento vivo. Alterações lógicas relevantes deverão ser registradas no CHANGELOG.md.**
