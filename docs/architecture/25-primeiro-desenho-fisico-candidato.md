# 25 — Primeiro Desenho Físico Candidato

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Candidato de prova arquitetural — não definitivo  
**Data:** 3 de outubro de 2026  
**Arquitetura de referência:** OES-H1  
**Dependências:** Documentos 20–24

## 1. Finalidade

Propor uma primeira tradução física do modelo lógico do OES capaz de testar:

- integridade referencial;
- identidade estável;
- versionamento imutável;
- proveniência;
- relações N:M;
- métodos especializados;
- artefatos externos;
- extensões documentais;
- rastreamento de dependências.

Este documento **não congela schema nem stack**.

A sintaxe de exemplos utiliza PostgreSQL como referência de prova, mas as invariantes deverão permanecer transportáveis.

---

# PARTE I — PADRÃO FÍSICO CENTRAL

## 2. Registry global de entidades

Problema:

o OES precisa referenciar genericamente diferentes tipos de entidade em:

- ProvenanceRecord;
- relações de impacto;
- artefatos;
- auditoria;
- versões;
- dependências.

Usar apenas pares `target_type + target_id` enfraqueceria integridade referencial.

### Solução candidata

Criar um registro global:

`core.entity`

Campos:

- `entity_uuid UUID PRIMARY KEY`;
- `oes_id TEXT UNIQUE NOT NULL`;
- `entity_type TEXT NOT NULL`;
- `created_at TIMESTAMPTZ NOT NULL`;
- `created_by UUID/TEXT`;
- `retired_at TIMESTAMPTZ NULL`.

Exemplos de `oes_id`:

- OES-Q-2026-000001;
- OES-ST-2026-000001;
- OES-SY-2026-000001.

Toda entidade científica persistente possui exatamente um registro global.

## 3. Registry global de versões

Criar:

`core.entity_version`

Campos:

- `version_uuid UUID PRIMARY KEY`;
- `entity_uuid UUID NOT NULL REFERENCES core.entity`;
- `version_no INTEGER NOT NULL`;
- `version_status TEXT NOT NULL`;
- `valid_from TIMESTAMPTZ NOT NULL`;
- `valid_to TIMESTAMPTZ NULL`;
- `supersedes_version_uuid UUID NULL REFERENCES core.entity_version`;
- `created_at TIMESTAMPTZ NOT NULL`;
- `created_by UUID/TEXT`;
- `change_type TEXT NOT NULL`;
- `change_note TEXT NULL`.

Constraint:

`UNIQUE(entity_uuid, version_no)`

### Benefício

Provenance, Product links e auditoria podem apontar para uma **versão concreta com FK real**, sem referência polimórfica não validada.

---

# PARTE II — NAMESPACES CANDIDATOS

## 4. Schemas lógicos

Primeira organização:

- `core` — identidade, versionamento, conceitos;
- `investigation` — perguntas, investigações, busca, triagem;
- `evidence` — Study, Report, Result e extensões;
- `appraisal` — risco de viés e certeza;
- `synthesis` — sínteses quantitativas/qualitativas;
- `product` — produtos OES;
- `provenance` — origem, derivação e auditoria;
- `artifact` — metadados de arquivos externos;
- `ops` — filas/execuções futuras, ainda mínimo.

Esses schemas são organizacionais; não definem microsserviços.

---

# PARTE III — CORE

## 5. core.entity

Tabela de identidade global.

### Regras

- UUID é chave física;
- `oes_id` é identificador público/estável;
- prefixo deve corresponder a `entity_type`;
- ID público nunca é reutilizado.

## 6. core.entity_version

Tabela genérica de versão.

### Estados candidatos

- draft;
- current;
- superseded;
- archived;
- invalidated.

Constraint parcial candidata:

> no máximo uma versão `current` por entidade.

## 7. core.concept

Campos:

- entity_uuid PK/FK → core.entity;
- domain;
- preferred_label;
- definition;
- status.

## 8. core.concept_mapping

Campos:

- concept_entity_uuid;
- terminology;
- external_code;
- external_label;
- terminology_version;
- mapping_type;
- verified_at.

Unique candidato:

`(concept_entity_uuid, terminology, external_code, terminology_version)`

---

# PARTE IV — PERGUNTAS E INVESTIGAÇÕES

## 9. investigation.question

Identidade:

- `entity_uuid PK/FK → core.entity`.

Conteúdo versionado:

`investigation.question_version`

- version_uuid PK/FK → core.entity_version;
- parent_question_entity_uuid NULL;
- original_text;
- normalized_text;
- question_type;
- structure_type;
- context_payload JSONB;
- time_horizon_payload JSONB.

## 10. investigation.question_component

Campos:

- component_uuid PK;
- question_version_uuid FK;
- component_type;
- concept_entity_uuid NULL FK;
- free_text;
- sequence_no;
- required_flag;
- payload JSONB NULL.

Componentes pertencem a uma versão da Question, evitando alteração retroativa.

## 11. investigation.investigation

- entity_uuid PK/FK → core.entity.

`investigation.investigation_version`:

- version_uuid PK/FK;
- primary_question_entity_uuid;
- investigation_type;
- depth_level;
- maintenance_level;
- objective;
- protocol_artifact_uuid NULL;
- start_date;
- evidence_cutoff_date;
- status.

## 12. investigation.investigation_question

- investigation_version_uuid;
- question_version_uuid;
- role;
- sequence_no.

PK candidata:

`(investigation_version_uuid, question_version_uuid, role)`

## 13. investigation.investigation_relation

- source_investigation_entity_uuid;
- target_investigation_entity_uuid;
- relation_type;
- rationale;
- created_at.

---

# PARTE V — BUSCA, CAPTURA E TRIAGEM

## 14. investigation.search

Search é registro de execução, não necessariamente entidade versionável.

Campos:

- search_uuid PK;
- investigation_version_uuid FK;
- source_name;
- platform;
- exact_strategy TEXT;
- filters_payload JSONB;
- executed_at;
- result_count;
- strategy_version;
- operator;
- export_artifact_uuid NULL;
- status.

Uma nova execução recebe novo `search_uuid`.

## 15. investigation.search_hit

Registro imutável da ocorrência recuperada.

Campos:

- search_hit_uuid PK;
- search_uuid FK;
- report_entity_uuid NULL FK;
- source_record_id;
- raw_payload JSONB;
- raw_title;
- raw_authors;
- raw_year;
- raw_identifier;
- source_rank;
- imported_at;
- dedup_cluster_uuid NULL;
- resolution_status.

Regra:

**deduplicação não apaga SearchHit.**

## 16. investigation.dedup_cluster

- dedup_cluster_uuid PK;
- investigation_version_uuid;
- canonical_report_entity_uuid NULL;
- status;
- confidence;
- method;
- reviewer;
- decision_date.

## 17. investigation.screening_decision

Problema lógico:

target pode ser Report ou Study.

### Solução física candidata

Evitar `target_type + target_id`.

Usar:

- target_entity_uuid FK → core.entity;
- constraint/check que limita `entity_type` na camada de trigger/função ou serviço a Report/Study.

Campos:

- screening_uuid PK;
- investigation_version_uuid;
- target_entity_uuid;
- stage;
- reviewer;
- decision;
- exclusion_reason;
- decided_at;
- parent_decision_uuid NULL;
- adjudication_flag.

A FK física é preservada pelo registry global.

---

# PARTE VI — STUDY E REPORT

## 18. evidence.study

- entity_uuid PK/FK → core.entity.

`evidence.study_version`:

- version_uuid PK/FK;
- study_type;
- design;
- title_or_label;
- start_date;
- end_date;
- recruitment_context JSONB;
- sample_size;
- status.

## 19. evidence.study_identifier

- identifier_uuid PK;
- study_entity_uuid FK;
- namespace;
- value;
- normalized_value;
- identifier_type;
- is_primary;
- verified_at.

Unique candidato:

`(namespace, normalized_value)` quando semanticamente seguro.

Não aplicar unicidade universal sem considerar namespaces que admitem múltiplos registros relacionados.

## 20. evidence.report

- entity_uuid PK/FK → core.entity.

`evidence.report_version`:

- version_uuid PK/FK;
- report_type;
- title;
- publication_date;
- journal_or_source;
- language;
- publication_status;
- full_text_status;
- bibliographic_payload JSONB;
- status.

## 21. evidence.report_identifier

- identifier_uuid PK;
- report_entity_uuid;
- namespace;
- value;
- normalized_value;
- verified_at.

## 22. evidence.study_report_link

A relação é versionável porque o vínculo pode ser corrigido.

Campos:

- link_uuid PK;
- study_entity_uuid;
- report_entity_uuid;
- relation_type;
- confidence;
- evidence_note;
- reviewer;
- decision_date;
- valid_from;
- valid_to;
- status.

Não apagar vínculo anterior; encerrar validade.

## 23. evidence.report_relation

- relation_uuid PK;
- source_report_entity_uuid;
- target_report_entity_uuid;
- relation_type;
- relation_date;
- notes.

Tipos incluem:

- correction_of;
- retraction_of;
- expression_of_concern_for;
- update_of;
- supplement_to.

---

# PARTE VII — GRUPOS, OUTCOMES E RESULTS

## 24. evidence.study_group

- entity_uuid PK/FK → core.entity;
- study_entity_uuid FK.

`evidence.study_group_version`:

- version_uuid;
- label;
- group_type;
- n_planned;
- n_analyzed;
- status.

## 25. evidence.group_component

- component_uuid PK;
- study_group_version_uuid;
- component_type;
- concept_entity_uuid NULL;
- label;
- dose_or_intensity JSONB NULL;
- duration JSONB NULL;
- notes.

## 26. evidence.outcome

- entity_uuid PK/FK → core.entity.

`evidence.outcome_version`:

- version_uuid;
- preferred_name;
- definition;
- domain;
- direction_of_benefit;
- unit_family;
- status.

## 27. evidence.outcome_operationalization

- operationalization_uuid PK;
- study_entity_uuid;
- outcome_entity_uuid;
- report_entity_uuid NULL;
- study_label;
- instrument;
- threshold_payload JSONB;
- timepoint_definition;
- unit;
- notes.

## 28. evidence.result

- entity_uuid PK/FK → core.entity;
- study_entity_uuid NOT NULL.

`evidence.result_version`:

- version_uuid PK/FK;
- outcome_entity_uuid NULL;
- operationalization_uuid NULL;
- group_a_entity_uuid NULL;
- group_b_entity_uuid NULL;
- population_descriptor JSONB;
- timepoint_value NUMERIC NULL;
- timepoint_unit TEXT NULL;
- timepoint_label TEXT NULL;
- estimand;
- measure;
- reported_value JSONB NULL;
- derived_value JSONB NULL;
- variance_or_se JSONB NULL;
- ci_lower NUMERIC NULL;
- ci_upper NUMERIC NULL;
- unit;
- adjusted_flag;
- analysis_population;
- missing_data_state;
- method_payload JSONB;
- status.

### Observação

`reported_value` e `derived_value` são JSONB no candidato porque Results podem ser escalares, proporções, vetores ou estruturas especializadas.

Campos usados frequentemente para análise poderão posteriormente ser normalizados em colunas tipadas adicionais.

## 29. evidence.result_source

- result_version_uuid;
- report_version_uuid;
- source_location;
- source_type;
- original_text_or_value JSONB;
- extraction_method;
- is_primary_source;
- extractor;
- extracted_at.

PK candidata composta por IDs + localização.

## 30. evidence.derivation_record

- derivation_uuid PK;
- result_version_uuid;
- input_payload JSONB;
- formula_or_method;
- parameters JSONB;
- software;
- software_version;
- code_artifact_uuid NULL;
- derived_at;
- reviewer.

---

# PARTE VIII — EXTENSÕES ESPECIALIZADAS

## 31. evidence.diagnostic_result_detail

1:1 com Result version quando aplicável.

- result_version_uuid PK/FK;
- index_test_concept_uuid NULL;
- reference_standard_concept_uuid NULL;
- threshold_payload JSONB;
- true_positive;
- false_positive;
- false_negative;
- true_negative;
- sensitivity;
- specificity;
- notes.

## 32. evidence.prediction_model

- entity_uuid PK/FK → core.entity.

`evidence.prediction_model_version`:

- version_uuid;
- name_or_label;
- target_outcome_entity_uuid;
- intended_use;
- model_type;
- development_study_entity_uuid NULL;
- specification_payload JSONB;
- status.

## 33. evidence.prediction_model_identifier

- prediction_model_entity_uuid;
- namespace;
- value;
- normalized_value;
- verified_at.

## 34. evidence.prediction_model_study_role

- prediction_model_entity_uuid;
- study_entity_uuid;
- role;
- notes.

---

# PARTE IX — EXTRAÇÃO E AVALIAÇÃO CRÍTICA

## 35. evidence.extraction_record

- extraction_uuid PK;
- investigation_version_uuid;
- study_entity_uuid;
- report_entity_uuid NULL;
- extractor;
- extraction_date;
- verification_status;
- verifier;
- record_version;
- payload JSONB;
- status.

O payload registra estado operacional; dados canônicos resultantes permanecem nas entidades Study/Report/Result.

## 36. appraisal.risk_assessment

- entity_uuid PK/FK → core.entity.

`appraisal.risk_assessment_version`:

- version_uuid;
- investigation_version_uuid;
- framework;
- framework_version;
- target_entity_uuid FK → core.entity;
- outcome_entity_uuid NULL;
- overall_judgement;
- assessor;
- assessment_date;
- verification_status;
- instrument_payload JSONB;
- status.

## 37. appraisal.risk_domain

- risk_assessment_version_uuid;
- domain_code;
- judgement;
- rationale;
- supporting_reference;
- sequence_no;
- domain_payload JSONB NULL.

---

# PARTE X — SYNTHESIS

## 38. synthesis.synthesis

- entity_uuid PK/FK → core.entity.

`synthesis.synthesis_version`:

- version_uuid;
- investigation_version_uuid;
- outcome_entity_uuid NULL;
- population_descriptor JSONB;
- comparison_payload JSONB;
- timepoint_payload JSONB;
- estimand;
- synthesis_type;
- synthesis_origin;
- source_study_entity_uuid NULL;
- method;
- model;
- software;
- software_version;
- code_artifact_uuid NULL;
- analysis_dataset_artifact_uuid NULL;
- result_summary JSONB;
- status;
- executed_at.

## 39. synthesis.contribution

- synthesis_version_uuid;
- result_version_uuid;
- contribution_role;
- transformed_value JSONB NULL;
- weight NUMERIC NULL;
- included_main_analysis;
- included_sensitivity;
- exclusion_reason;
- notes.

## 40. synthesis.statistic

- statistic_uuid PK;
- synthesis_version_uuid;
- statistic_name;
- value JSONB;
- lower NUMERIC NULL;
- upper NUMERIC NULL;
- scale;
- notes.

## 41. synthesis.node

- entity_uuid PK/FK → core.entity;
- synthesis_entity_uuid.

`synthesis.node_version`:

- version_uuid;
- label;
- concept_entity_uuid NULL;
- node_definition JSONB;
- status.

## 42. synthesis.node_mapping

- synthesis_node_version_uuid;
- study_group_version_uuid;
- mapping_rationale;
- reviewer;
- status.

## 43. synthesis.contrast

- contrast_uuid PK;
- synthesis_version_uuid;
- node_a_version_uuid;
- node_b_version_uuid;
- contrast_type;
- status.

## 44. synthesis.review_finding

- entity_uuid PK/FK → core.entity;
- synthesis_entity_uuid.

`synthesis.review_finding_version`:

- version_uuid;
- finding_text;
- phenomenon;
- supporting_study_count;
- status.

## 45. synthesis.finding_contribution

- review_finding_version_uuid;
- study_entity_uuid;
- report_entity_uuid NULL;
- contribution_role;
- relevance_note;
- adequacy_note;
- notes.

---

# PARTE XI — CERTEZA E APLICABILIDADE

## 46. appraisal.certainty_assessment

- entity_uuid PK/FK → core.entity.

`appraisal.certainty_assessment_version`:

- version_uuid;
- investigation_version_uuid;
- synthesis_version_uuid NULL;
- review_finding_version_uuid NULL;
- outcome_entity_uuid NULL;
- framework;
- framework_version;
- initial_level NULL;
- final_level NULL;
- evidence_state;
- assessment_date;
- status.

Constraint lógica:

- CERQual → ReviewFinding obrigatório;
- GRADE quantitativo → Synthesis/Outcome conforme protocolo;
- `evidence_state = no_evidence` não obriga `final_level = very_low`.

## 47. appraisal.certainty_domain

- certainty_assessment_version_uuid;
- domain_code;
- concern_level;
- downgrade_steps;
- upgrade_steps;
- rationale;
- reviewer;
- sequence_no;
- payload JSONB NULL.

## 48. appraisal.certainty_review

- certainty_assessment_version_uuid;
- reviewer;
- role;
- independent_flag;
- decision;
- reviewed_at;
- disagreement_note.

## 49. appraisal.applicability_assessment

**Interface física reservada; não operacionalizada.**

- entity_uuid PK/FK → core.entity.

`appraisal.applicability_assessment_version`:

- version_uuid;
- investigation_version_uuid;
- target_context JSONB;
- source_context_summary JSONB;
- assessment_status;
- rationale;
- assessor;
- assessed_at;
- status;
- method_payload JSONB NULL.

Não criar enum de classificação até formalização metodológica.

---

# PARTE XII — PRODUCTS

## 50. product.product

- entity_uuid PK/FK → core.entity.

`product.product_version`:

- version_uuid;
- product_type;
- title;
- intended_audience;
- evidence_cutoff_date;
- publication_date NULL;
- status;
- conclusion_text;
- applicability_summary;
- rendered_artifact_uuid NULL.

## 51. product.investigation_link

- product_version_uuid;
- investigation_version_uuid;
- role;
- sequence_no.

## 52. product.synthesis_link

- product_version_uuid;
- synthesis_version_uuid;
- role;
- sequence_no.

## 53. product.certainty_link

- product_version_uuid;
- certainty_assessment_version_uuid;
- role;
- sequence_no.

## 54. product.applicability_link

Reservada:

- product_version_uuid;
- applicability_assessment_version_uuid;
- role.

---

# PARTE XIII — PROVENANCE E ARTIFACTS

## 55. provenance.record

Graças ao registry global de versões, não requer target polimórfico sem FK.

Campos:

- provenance_uuid PK;
- target_version_uuid FK → core.entity_version;
- field_path;
- source_report_version_uuid NULL;
- source_location;
- source_value JSONB NULL;
- process_type;
- process_record_uuid NULL;
- transformation JSONB NULL;
- actor;
- created_at.

## 56. artifact.artifact

Metadados:

- artifact_uuid PK;
- artifact_type;
- storage_key;
- content_hash;
- hash_algorithm;
- mime_type;
- byte_size;
- original_filename;
- created_at;
- created_by;
- source_uri NULL;
- status.

## 57. artifact.entity_link

- artifact_uuid;
- entity_version_uuid;
- role;
- sequence_no.

## 58. Regra

Object storage guarda bytes.

Banco canônico guarda identidade, hash, localização e relações.

O hash permite:

- integridade;
- deduplicação de bytes;
- auditoria;
- detecção de alteração silenciosa.

---

# PARTE XIV — EVENTOS DE IMPACTO

## 59. provenance.dependency_edge

Tabela derivada/canônica auxiliar para navegação de dependências explícitas.

Campos:

- source_version_uuid;
- target_version_uuid;
- dependency_type;
- created_at;
- derivation_rule;
- status.

Exemplos:

- Result → Synthesis;
- Synthesis → Certainty;
- Certainty → Product;
- Report → Result.

Ela não substitui as FKs de domínio; funciona como índice de dependência normalizado.

## 60. Impact analysis

Evento como retração pode consultar:

`Report → Result → Synthesis → Certainty → Product`

A primeira implementação pode gerar essa cadeia:

- por queries relacionais;
- por `dependency_edge`;
- futuramente por projeção de grafo.

---

# PARTE XV — EXTENSÕES JSONB

## 61. Política

Todo payload JSONB deve possuir:

- finalidade definida;
- schema_name;
- schema_version;
- validação;
- documentação;
- limite de uso.

## 62. Não permitido

Não usar JSONB para esconder relações que deveriam ter FK.

Anti-exemplos:

- lista de Study IDs dentro de JSONB;
- lista de Result IDs da síntese;
- Product com IDs de Certainty embutidos;
- histórico de versões em array.

## 63. Permitido

Exemplos:

- parâmetros específicos de ROBINS-I;
- filtros de busca;
- payload bibliográfico bruto;
- especificação de modelo de predição;
- threshold diagnóstico complexo;
- parâmetros estatísticos adicionais.

---

# PARTE XVI — ÍNDICES CANDIDATOS

## 64. Identidade

- unique `core.entity(oes_id)`;
- index `core.entity(entity_type)`;
- unique `core.entity_version(entity_uuid, version_no)`;
- partial unique para uma versão current por entity.

## 65. External IDs

Índices por:

- namespace;
- normalized_value;
- entidade.

## 66. Busca operacional

- SearchHit(search_uuid);
- SearchHit(report_entity_uuid);
- dedup_cluster_uuid;
- screening(investigation_version_uuid, target_entity_uuid).

## 67. Evidence graph

- StudyReportLink(study, report);
- Result(study);
- ResultSource(report, result);
- Contribution(synthesis, result);
- Product links.

## 68. JSONB

GIN somente para payloads com caso de consulta demonstrado.

Não indexar todo JSONB por padrão.

---

# PARTE XVII — VIEWS CANDIDATAS

## 69. core.current_entity_version

View da versão current de cada entidade.

## 70. evidence.current_result

Resultado vigente.

## 71. synthesis.current_synthesis

Síntese vigente.

## 72. appraisal.current_certainty

Avaliação vigente.

## 73. product.current_product

Produto vigente.

## 74. product.evidence_lineage

View materializada ou normal que reconstrói:

`Product → Certainty → Synthesis → Result → Study/Report`

Uso:

- auditoria;
- atualização;
- impacto;
- interface do usuário.

---

# PARTE XVIII — MIGRAÇÕES

## 75. Princípios

1. migração de schema não reescreve histórico sem necessidade;
2. transformação de dados gera log;
3. backfill é reproduzível;
4. migration ID é versionado;
5. mudanças destrutivas exigem etapa de compatibilidade;
6. JSONB promovido a coluna normalizada mantém migração rastreável;
7. nenhum ID público é renumerado.

## 76. Regra expand-contract

Preferir:

1. expandir schema;
2. escrever nos dois formatos quando necessário;
3. backfill;
4. validar;
5. migrar leitores;
6. descontinuar campo antigo;
7. remover apenas em marco controlado.

---

# PARTE XIX — SEGURANÇA E GOVERNANÇA DE DADOS

## 77. Princípio inicial

O modelo de evidências deve evitar armazenar dados pessoais desnecessários.

O OES é primariamente sistema de conhecimento científico, não prontuário.

## 78. Dados sensíveis

Caso datasets individuais sejam incorporados futuramente, deverão existir políticas específicas de:

- base legal;
- minimização;
- controle de acesso;
- criptografia;
- retenção;
- auditoria;
- anonimização/pseudonimização.

Esses requisitos não estão detalhados neste documento.

---

# PARTE XX — DDL MÍNIMO DE PROVA

## 79. Registry

Exemplo ilustrativo:

```sql
CREATE TABLE core.entity (
    entity_uuid uuid PRIMARY KEY,
    oes_id text NOT NULL UNIQUE,
    entity_type text NOT NULL,
    created_at timestamptz NOT NULL,
    created_by text,
    retired_at timestamptz
);

CREATE TABLE core.entity_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES core.entity(entity_uuid),
    version_no integer NOT NULL CHECK (version_no > 0),
    version_status text NOT NULL,
    valid_from timestamptz NOT NULL,
    valid_to timestamptz,
    supersedes_version_uuid uuid REFERENCES core.entity_version(version_uuid),
    created_at timestamptz NOT NULL,
    created_by text,
    change_type text NOT NULL,
    change_note text,
    UNIQUE (entity_uuid, version_no)
);
```

## 80. Exemplo de Result → Synthesis

```sql
CREATE TABLE synthesis.contribution (
    synthesis_version_uuid uuid NOT NULL
      REFERENCES core.entity_version(version_uuid),
    result_version_uuid uuid NOT NULL
      REFERENCES core.entity_version(version_uuid),
    contribution_role text NOT NULL,
    transformed_value jsonb,
    weight numeric,
    included_main_analysis boolean NOT NULL DEFAULT true,
    included_sensitivity boolean NOT NULL DEFAULT false,
    exclusion_reason text,
    notes text,
    PRIMARY KEY (synthesis_version_uuid, result_version_uuid)
);
```

Além da FK genérica, triggers/constraint functions ou a camada de escrita deverão validar que os entity types são, respectivamente, Synthesis e Result.

---

# PARTE XXI — RISCOS DO CANDIDATO

## 81. Registry global

Vantagem:

- resolve generic references.

Risco:

- exige validação adicional de tipo para impedir apontar versão de entidade errada.

Mitigação:

- funções de escrita;
- constraints/triggers quando justificadas;
- testes de integração;
- views tipadas.

## 82. Muitas tabelas de versão

Vantagem:

- histórico explícito.

Risco:

- joins mais extensos.

Mitigação:

- views current;
- query layer;
- materialized views para leitura pesada.

## 83. JSONB excessivo

Risco:

- erosão do modelo lógico.

Mitigação:

- política de JSONB;
- schemas versionados;
- revisão arquitetural para promoção de campos.

## 84. Dependency edge duplicada

Risco:

- divergência em relação às FKs.

Mitigação:

- tratar como projeção derivada;
- regeneração;
- nunca usar como fonte primária de edição.

---

# PARTE XXII — DECISÃO

## 85. Candidato físico

> **OES-P1 — Registry Global + Entidades Tipadas + Version Tables + Núcleo Relacional + JSONB Controlado + Object Storage + Dependency Projection**

Status:

**CANDIDATO PARA PROVA DE CONCEITO**

Não é schema final.

## 86. Critérios para promoção

Antes de qualquer decisão definitiva, OES-P1 deverá ser testado com:

1. criação de Question/Investigation;
2. ingestão de SearchHits;
3. deduplicação;
4. Study com múltiplos Reports;
5. Report com múltiplos Studies;
6. Result com proveniência;
7. síntese quantitativa;
8. NMA;
9. predição;
10. qualitativa/CERQual;
11. certainty;
12. Product/Ficha;
13. nova versão por atualização;
14. retração e impact analysis;
15. reconstrução completa de lineage.

---

# PARTE XXIII — PRÓXIMA ETAPA

Criar uma **Prova de Conceito de Schema (PoC-S1)** limitada ao núcleo necessário para validar OES-P1.

Escopo mínimo sugerido:

- entity/entity_version;
- Question;
- Investigation;
- Study;
- Report;
- StudyReportLink;
- Outcome;
- Result;
- ResultSource;
- Synthesis;
- SynthesisContribution;
- Certainty;
- Product;
- Provenance;
- Artifact metadata.

Não implementar ainda:

- automação de busca;
- IA;
- interface;
- motor de monitoramento;
- stack de produção.

---

**OES-P1 é um desenho físico candidato para validação, não uma decisão tecnológica definitiva.**
