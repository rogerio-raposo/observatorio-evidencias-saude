<!--
OES Evidence Review N4 Template
template_version: oes.evidence_review.template/0.1
input_contract: oes.evidence_review_view/0.1
status: provisional-operational
canonical_scientific_source: EvidenceReviewView + linked OES entities
presentation_rule: placeholders reference only fields present in EvidenceReviewView 0.1
IMPORTANT: this template presents evidence, controls and assurance; it does not create scientific judgements, reviewer qualification or assurance.
-->

{{#if audit.synthetic_fixture}}
> **FIXTURE SINTÉTICA — NÃO REPRESENTA REVISÃO HUMANA REAL**
>
> Revisores, expert review e A3 deste artefato são sintéticos e existem somente para validação do contrato técnico N4.
>
> **Não utilizar os resultados desta fixture como evidência clínica real.**
{{/if}}

{{#if audit.publishable}}
> **Gate de publicação N4: aprovado.**
{{else}}
> **GATE DE PUBLICAÇÃO N4 NÃO APROVADO**
>
> Assurance, inclusive A3, não substitui requisitos de etapa. Esta versão não deve ser apresentada como Revisão de Evidências N4 formal publicada.
{{/if}}

# {{identity.title}}

**Product ID:** {{identity.product_id}}  
**Versão:** {{identity.version_no}}  
**Subtype:** {{subtype}}  
**Profundidade:** {{investigation.depth_level}}  
**Manutenção:** {{investigation.maintenance_level}}  
**Estado editorial:** {{identity.editorial_status}}  
**Atualidade:** {{identity.currency_status}}  
**Evidência considerada até:** {{identity.evidence_cutoff_date}}  
**Assurance:** {{audit.assurance_level}}  
**Readiness:** {{audit.readiness_state}}
{{#if identity.publication_date}}  
**Data de publicação registrada:** {{identity.publication_date}}
{{/if}}

---

## Pergunta

{{question.normalized_text}}

{{#if question.original_text}}
**Pergunta original:** {{question.original_text}}
{{/if}}

**Objetivo da investigação:** {{investigation.objective}}

---

## Conclusão da evidência

{{conclusion.text}}

{{#if audit.publishable}}
> Esta conclusão pertence a uma ProductVersion cujo gate N4 está aprovado.
{{else}}
> **Conclusão de versão não publicável como N4 formal.**
{{/if}}

---

## Certeza/confiança

{{#if certainty}}
| Framework | Nível inicial | Nível final | Estado da evidência | Data | Papel |
|---|---|---|---|---|---|
{{#each certainty}}
| {{framework}}{{#if framework_version}} {{framework_version}}{{/if}} | {{initial_level}} | {{final_level}} | {{evidence_state}} | {{assessment_date}} | {{role}} |
{{/each}}
{{else}}
Nenhuma CertaintyAssessment foi projetada.
{{/if}}

---

## Summary of Findings

{{#if summary_of_findings}}
{{#each summary_of_findings}}
- **Artifact:** {{artifact_uuid}}
  - Storage key: {{storage_key}}
  - Hash: {{content_hash}}
  - MIME: {{mime_type}}
{{/each}}
{{else}}
Nenhum Summary of Findings foi projetado.
{{/if}}

---

## Aplicabilidade

{{applicability.summary}}

---

## Limitações

{{limitations.summary}}

---

## Infrastructure Readiness Gate

**Estado:** {{infrastructure_readiness.state}}  
**Resolução:** {{infrastructure_readiness.resolution_status}}  
**Justificativa:** {{infrastructure_readiness.rationale}}

**Domínios:** {{infrastructure_readiness.domains}}  
**Fontes requeridas:** {{infrastructure_readiness.required_sources}}

---

## Protocolo

{{#if protocol.artifact_uuid}}
**Artifact:** {{protocol.artifact_uuid}}  
**Tipo:** {{protocol.artifact_type}}  
**Storage key:** {{protocol.storage_key}}  
**Hash:** {{protocol.content_hash}}  
**Criado em:** {{protocol.created_at}}  
**Estado:** {{protocol.status}}
{{else}}
> Protocolo rastreável ausente.
{{/if}}

### Registro do protocolo

{{#if registration}}
{{#each registration}}
- {{artifact_uuid}} — {{source_uri}} — {{storage_key}} — hash {{content_hash}}
{{/each}}
{{else}}
Nenhum registro externo do protocolo foi projetado.
{{/if}}

---

## Emendas e desvios

{{#if amendments_and_deviations}}
{{#each amendments_and_deviations}}
### {{decision_type}} — {{stage}} — {{code}}

**Planejado:** {{planned}}  
**Status:** {{resolution_status}}  
**Data:** {{decided_at}}  
**Justificativa:** {{rationale}}  
**Risco:** {{risk}}  
**Mitigação:** {{mitigation}}  
**Impacto:** {{impact}}

{{/each}}
{{else}}
Nenhuma emenda/desvio ativo foi projetado.
{{/if}}

---

## Buscas

{{#if searches}}
| Fonte | Plataforma | Classe | Versão | Executada | Resultados | Hits materializados | Export artifact | Estado |
|---|---|---|---|---|---:|---:|---|---|
{{#each searches}}
| {{source_name}} | {{platform}} | {{source_class}} | {{strategy_version}} | {{executed_at}} | {{result_count}} | {{materialized_hit_count}} | {{export_artifact_uuid}} | {{status}} |
{{/each}}
{{else}}
Nenhuma Search foi projetada.
{{/if}}

### Peer review da estratégia de busca

{{#if search_peer_review}}
| Ator | Tipo | Qualificação | Independente | Decisão | Escopo | Data | Artifact |
|---|---|---|---|---|---|---|---|
{{#each search_peer_review}}
| {{actor}} | {{actor_type}} | {{qualified}} | {{independent}} | {{decision}} | {{scope}} | {{performed_at}} | {{evidence_artifact_uuid}} |
{{/each}}
{{else}}
Nenhum search peer review foi projetado.
{{/if}}

---

## Fluxo de seleção

- Hits materializados: **{{selection_flow.search_hits_materialized}}**
- Reports-alvo únicos: **{{selection_flow.unique_report_targets}}**
- Decisões de screening: **{{selection_flow.screening_decisions}}**
- Título/resumo: **{{selection_flow.title_abstract_decisions}}**
- Texto completo: **{{selection_flow.full_text_decisions}}**
- Exclusões em texto completo: **{{selection_flow.full_text_exclusions}}**
- Adjudicações: **{{selection_flow.adjudications}}**

### Exclusões em texto completo

{{#if excluded_full_text}}
| Target | Revisor | Motivo | Adjudicação | Data |
|---|---|---|---|---|
{{#each excluded_full_text}}
| {{target_entity_uuid}} | {{reviewer}} | {{exclusion_reason}} | {{adjudication}} | {{decided_at}} |
{{/each}}
{{else}}
Nenhuma exclusão full text foi projetada.
{{/if}}

---

## Estudos contribuidores

{{#if study_characteristics}}
| Study ID | Tipo | Design | Rótulo | N | Estado |
|---|---|---|---|---:|---|
{{#each study_characteristics}}
| {{study_id}} | {{study_type}} | {{design}} | {{title_or_label}} | {{sample_size}} | {{status}} |
{{/each}}
{{else}}
Nenhum Study contribuidor foi projetado.
{{/if}}

---

## Extração de dados críticos

### Extrações independentes

{{#if extraction_controls.independent_extractions}}
| ResultVersion | Source ReportVersion | Localização | Ator | Data |
|---|---|---|---|---|
{{#each extraction_controls.independent_extractions}}
| {{target_version_uuid}} | {{source_report_version_uuid}} | {{source_location}} | {{actor}} | {{created_at}} |
{{/each}}
{{else}}
Nenhuma extração independente foi projetada.
{{/if}}

### Controles de verificação

{{#if extraction_controls.verification_controls}}
| Controle | Ator | Decisão | Escopo | Data |
|---|---|---|---|---|
{{#each extraction_controls.verification_controls}}
| {{quality_control_uuid}} | {{actor}} | {{decision}} | {{scope}} | {{performed_at}} |
{{/each}}
{{else}}
Nenhum controle de extração foi projetado.
{{/if}}

---

## Risco de viés dos estudos

{{#if risk_of_bias}}
| Framework | Target | Outcome | Julgamento | Assessor | Verificação | Data |
|---|---|---|---|---|---|---|
{{#each risk_of_bias}}
| {{framework}} | {{target_entity_uuid}} | {{outcome_entity_uuid}} | {{overall_judgement}} | {{assessor}} | {{verification_status}} | {{assessment_date}} |
{{/each}}
{{else}}
Nenhum RiskAssessment de estudo foi projetado.
{{/if}}

---

## Missing evidence / ROB-ME

{{#if missing_evidence}}
| Framework | Target | Outcome | Julgamento | Assessor | Verificação |
|---|---|---|---|---|---|
{{#each missing_evidence}}
| {{framework}} | {{target_entity_uuid}} | {{outcome_entity_uuid}} | {{overall_judgement}} | {{assessor}} | {{verification_status}} |
{{/each}}
{{else}}
Nenhuma avaliação de missing evidence foi projetada.
{{/if}}

---

## Resultados

{{#if results}}
| Medida | Valor reportado | Valor derivado | Variância/SE | IC inferior | IC superior | Unidade |
|---|---|---|---|---:|---:|---|
{{#each results}}
| {{measure}} | {{reported_value}} | {{derived_value}} | {{variance_or_se}} | {{ci_lower}} | {{ci_upper}} | {{unit}} |
{{/each}}
{{else}}
Nenhum Result estruturado foi projetado.
{{/if}}

---

## Sínteses

{{#if syntheses}}
{{#each syntheses}}
### {{synthesis_id}} — {{synthesis_type}}

**Origem:** {{synthesis_origin}}  
**Método:** {{method}}  
**Modelo:** {{model}}  
**Software:** {{software}} {{software_version}}  
**Papel:** {{role}}  
**Code artifact:** {{code_artifact_uuid}}  
**Dataset artifact:** {{analysis_dataset_artifact_uuid}}

**Resumo:** {{result_summary}}

{{/each}}
{{else}}
Nenhuma SynthesisVersion foi projetada.
{{/if}}

### Heterogeneidade

{{#if heterogeneity}}
{{#each heterogeneity}}
- **SynthesisVersion {{synthesis_version_uuid}}:** I²={{i2_percent}}; tau²={{tau2}}; prediction interval={{prediction_interval}}
{{/each}}
{{else}}
Nenhuma métrica de heterogeneidade foi projetada.
{{/if}}

### Sensitivity analyses

{{#if sensitivity_analyses}}
{{#each sensitivity_analyses}}
- SynthesisVersion {{synthesis_version_uuid}} / ResultVersion {{result_version_uuid}} — incluído em sensibilidade: {{included_sensitivity}} — {{notes}}
{{/each}}
{{else}}
Nenhum item de sensitivity analysis foi projetado.
{{/if}}

---

## Reviewer assignments

{{#if reviewer_assignments}}
| Etapa | Papel | Ator | Tipo | Qualificação | Independente | Escopo | Conflito |
|---|---|---|---|---|---|---|---|
{{#each reviewer_assignments}}
| {{stage}} | {{role}} | {{actor}} | {{actor_type}} | {{qualification}} | {{independent}} | {{scope}} | {{conflict}} |
{{/each}}
{{else}}
Nenhum ReviewerAssignment foi projetado.
{{/if}}

---

## Quality controls metodológicos

{{#if method.quality_controls}}
| Etapa | Controle | Ator | Tipo | Independente | Decisão | Escopo | Data | Artifact |
|---|---|---|---|---|---|---|---|---|
{{#each method.quality_controls}}
| {{stage}} | {{control_type}} | {{actor}} | {{actor_type}} | {{independent}} | {{decision}} | {{scope}} | {{performed_at}} | {{evidence_artifact_uuid}} |
{{/each}}
{{else}}
Nenhum QualityControlRecord foi projetado.
{{/if}}

---

## Reprodutibilidade

### Artifacts de análise

{{#if reproducibility.analysis_artifacts}}
{{#each reproducibility.analysis_artifacts}}
- SynthesisVersion {{synthesis_version_uuid}} — code {{code_artifact_uuid}} — dataset {{analysis_dataset_artifact_uuid}} — {{software}} {{software_version}}
{{/each}}
{{else}}
Nenhum artifact de análise foi projetado.
{{/if}}

### Artifacts do produto

{{#if reproducibility.product_artifacts}}
{{#each reproducibility.product_artifacts}}
- **{{role}}** — {{artifact_uuid}} — {{artifact_type}} — {{storage_key}} — hash {{content_hash}}
{{/each}}
{{else}}
Nenhum artifact de produto foi projetado.
{{/if}}

---

## Referências

{{#if references}}
{{#each references}}
- **{{report_id}}** — {{title}}{{#if publication_date}} ({{publication_date}}){{/if}}{{#if publication_status}} — {{publication_status}}{{/if}}
{{/each}}
{{else}}
Nenhuma referência rastreável foi projetada.
{{/if}}

---

## Garantia metodológica e auditoria

{{#if audit.publishable}}
**Gate de publicação N4:** aprovado
{{else}}
**Gate de publicação N4:** não aprovado
{{/if}}  
**Assurance:** {{audit.assurance_level}}  
**Fixture sintética:** {{audit.synthetic_fixture}}  
**Readiness:** {{audit.readiness_state}}  
**Reviewer assignments ativos:** {{audit.reviewer_assignment_count}}  
**Controles qualificados de etapa satisfeitos:** {{audit.qualified_stage_controls_satisfied}}  
**Desvios de protocolo abertos:** {{audit.protocol_deviations_open}}  
**Revisão especializada independente:** {{audit.expert_independent_reviewed}}  
**Lineage disponível:** {{audit.lineage_available}}  
**Dependências invalidadas:** {{audit.invalidated_dependencies}}

{{#if audit.publishable}}
> **A3 + stage controls qualificados + gate N4 satisfeitos.**
{{else}}
> **A3, quando presente, não substitui stage controls nem abre o gate N4 automaticamente.**
{{/if}}

{{#if audit.publication_issues}}
### Issues do gate

{{#each audit.publication_issues}}
- **{{severity}} — {{issue_code}}:** {{message}}
{{/each}}
{{else}}
Nenhuma issue registrada pelo gate.
{{/if}}

{{#if audit.assurance_records}}
### Registros de garantia

| Tipo | Ator | Tipo de ator | Independente | Decisão | Data | Estado |
|---|---|---|---|---|---|---|
{{#each audit.assurance_records}}
| {{assurance_type}} | {{actor}} | {{actor_type}} | {{independent}} | {{decision}} | {{performed_at}} | {{status}} |
{{/each}}
{{/if}}

### Identificadores técnicos

- Schema da view: `oes.evidence_review_view/0.1`
- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- InvestigationVersion primária: `{{investigation.investigation_version_uuid}}`
- QuestionVersion primária: `{{question.question_version_uuid}}`

---

_Produto OES. Uma Revisão de Evidências N4 formal exige método completo, controles humanos qualificados e A3; a apresentação nunca deve inferir esses requisitos._
