<!--
OES Overview of Reviews Template
template_version: oes.overview_of_reviews.template/0.1
input_contract: oes.overview_of_reviews_view/0.1
status: provisional-operational
canonical_scientific_source: OverviewOfReviewsView + linked OES entities
presentation_rule: placeholders reference only fields present in OverviewOfReviewsView 0.1
IMPORTANT: this template presents review-level evidence, overlap, appraisal, controls and assurance; it does not create Reviews, estimates, certainty, CCA, pairwise overlap, reanalysis, indirect comparisons, recommendations or publication approval.
-->

{{#if audit.synthetic_fixture}}
> **FIXTURE SINTÉTICA — NÃO REPRESENTA OVERVIEW REAL**
>
> Reviews, primary Studies, reviewers, expert review, ROBIS, certainty, assurance e decisões metodológicas desta fixture são sintéticos e existem exclusivamente para validação do contrato técnico.
>
> **Não utilizar esta fixture como evidência clínica real.**
{{/if}}

{{#if audit.publishable}}
> **Gate de publicação do Overview: aprovado.**
{{else}}
> **GATE DE PUBLICAÇÃO DO OVERVIEW NÃO APROVADO**
>
> Assurance, inclusive A3, não substitui requisitos de search coverage, screening, ROBIS, membership, overlap control, OutcomeEvidence, concordance e controles humanos qualificados.
{{/if}}

# {{identity.title}}

**Product ID:** {{identity.product_id}}  
**Versão:** {{identity.version_no}}  
**Tipo de produto:** {{identity.product_type}}  
**Investigation:** {{investigation.investigation_id}}  
**Profundidade da investigação:** {{investigation.depth_level}}  
**Manutenção:** {{investigation.maintenance_level}}  
**Estado editorial:** {{identity.editorial_status}}  
**Atualidade:** {{identity.currency_status}}  
**Evidência considerada até:** {{identity.evidence_cutoff_date}}  
**Assurance:** {{audit.assurance_level}}  
**Assurance requerida:** {{audit.required_assurance_level}}  
**Publicável:** {{audit.publishable}}
{{#if identity.publication_date}}  
**Data de publicação registrada:** {{identity.publication_date}}
{{/if}}

---

## Pergunta

{{question.normalized_text}}

{{#if question.original_text}}
**Pergunta original:** {{question.original_text}}
{{/if}}

**Estrutura:** {{question.structure_type}}

---

## Conclusão canônica

{{conclusion.text}}

### Aplicabilidade

{{conclusion.applicability_summary}}

### Limitações

{{limitations.summary}}

> **Reviews sobrepostas não constituem observações independentes.**
>
> **CCA e pairwise overlap descrevem redundância estrutural entre Reviews e não representam risco de viés, certeza ou magnitude de efeito.**
>
> **ROBIS, certainty e currentness são dimensões distintas e não devem ser agregadas em um score único.**

---

## Protocolo

{{#if protocol.artifact_uuid}}
- **Artifact:** {{protocol.artifact_uuid}}
- **Tipo:** {{protocol.artifact_type}}
- **Storage key:** {{protocol.storage_key}}
- **Hash:** {{protocol.content_hash}}
- **Algoritmo:** {{protocol.hash_algorithm}}
- **Criado em:** {{protocol.created_at}}
- **Estado:** {{protocol.status}}
{{else}}
> Protocolo rastreável não projetado.
{{/if}}

---

## Decisões metodológicas

{{#if method.policies}}
| Tipo | Etapa | Código | Planejada | Rationale | Risco | Mitigação | Impacto | Resolução | Decidida por | Data | Artifact |
|---|---|---|---|---|---|---|---|---|---|---|---|
{{#each method.policies}}
| {{decision_type}} | {{stage}} | {{decision_code}} | {{planned}} | {{rationale}} | {{risk}} | {{mitigation}} | {{impact}} | {{resolution_status}} | {{decided_by}} | {{decided_at}} | {{linked_artifact_uuid}} |
{{/each}}
{{else}}
Nenhuma decisão metodológica foi projetada.
{{/if}}

> Desvios de protocolo permanecem auditáveis mesmo quando resolvidos.

---

## Buscas

{{#if searches}}
| Search | Fonte | Plataforma | Classe | Executada | Resultados | Versão | Export | Storage key | Hash | Algoritmo | Estado |
|---|---|---|---|---|---:|---|---|---|---|---|---|
{{#each searches}}
| {{oes_search_id}} | {{source_name}} | {{platform}} | {{source_class}} | {{executed_at}} | {{result_count}} | {{strategy_version}} | {{export_artifact_uuid}} | {{#if export_artifact}}{{export_artifact.storage_key}} | {{export_artifact.content_hash}} | {{export_artifact.hash_algorithm}}{{else}}— | — | —{{/if}} | {{status}} |
{{/each}}
{{else}}
Nenhuma Search foi projetada.
{{/if}}

> A presença de Search não equivale a peer review da estratégia.

### Fluxo de seleção

- Search hits: **{{selection_flow.search_hits}}**
- Reports-alvo únicos: **{{selection_flow.unique_report_targets}}**
- Decisões de screening: **{{selection_flow.screening_decisions}}**
- Título/resumo: **{{selection_flow.title_abstract_decisions}}**
- Texto completo: **{{selection_flow.full_text_decisions}}**
- Exclusões em texto completo: **{{selection_flow.full_text_exclusions}}**
- Adjudicações: **{{selection_flow.adjudications}}**
- ReviewItems incluídos: **{{selection_flow.included_review_items}}**

> As contagens não são denominadas automaticamente como fluxo PRISMA.

### Exclusões em texto completo

{{#if excluded_full_text}}
| Target | Reviewer | Decisão | Motivo | Data | Adjudicação |
|---|---|---|---|---|---|
{{#each excluded_full_text}}
| {{target_id}} | {{reviewer}} | {{decision}} | {{exclusion_reason}} | {{decided_at}} | {{adjudication_flag}} |
{{/each}}
{{else}}
Nenhuma exclusão full text foi projetada.
{{/if}}

---

## Reviews incluídas

{{#if review_items}}
{{#each review_items}}
### {{review_study_id}} — {{title}}

- **ReviewItem:** {{review_item_uuid}}
- **StudyVersion:** {{review_study_version_uuid}}
- **Tipo:** {{study_type}}
- **Papel:** {{item_role}}
- **Base de elegibilidade:** {{eligibility_basis}}
- **Última busca da Review:** {{last_search_date}}
- **Atualidade:** {{currentness_status}}
- **Rationale de atualidade:** {{currentness_rationale}}
- **Membership:** {{membership_completeness}}
- **ROBIS:** {{robis.overall_judgement}}
- **ROBIS verification:** {{robis.verification_status}}

{{#if reports}}
**Reports associados**

| Report | Relação | Título | Publicação | ReportVersion |
|---|---|---|---|---|
{{#each reports}}
| {{report_id}} | {{relation_type}} | {{title}} | {{publication_date}} | {{report_version_uuid}} |
{{/each}}
{{/if}}

{{/each}}
{{else}}
Nenhuma Review incluída foi projetada.
{{/if}}

> **Review Study é a unidade científica. Reports associados não constituem Reviews adicionais.**

---

## Lineage de Reports e updates

{{#if report_lineage}}
| Review | Source Report | Target Report | Relação | Data | Notas | Estado |
|---|---|---|---|---|---|---|
{{#each report_lineage}}
| {{review_study_id}} | {{source_report_id}} | {{target_report_id}} | {{relation_type}} | {{relation_date}} | {{notes}} | {{status}} |
{{/each}}
{{else}}
Nenhuma relação explícita entre Reports foi projetada.
{{/if}}

> Update/correction/retraction lineage não é inferida por título, ano ou DOI.

---

## ROBIS

{{#if appraisal}}
{{#each appraisal}}
### ReviewItem {{review_item_uuid}}

- **Framework:** {{framework}}
- **Overall judgement:** {{overall_judgement}}
- **Assessor:** {{assessor}}
- **Data:** {{assessment_date}}
- **Verificação:** {{verification_status}}

{{#if domains}}
| Domínio | Julgamento | Rationale | Ordem |
|---|---|---|---:|
{{#each domains}}
| {{domain_code}} | {{judgement}} | {{rationale}} | {{sequence_no}} |
{{/each}}
{{/if}}

{{/each}}
{{else}}
Nenhum ROBIS foi projetado.
{{/if}}

> ROBIS não é certainty e currentness não é ROBIS.

---

## OutcomeEvidence

{{#if outcome_evidence}}
{{#each outcome_evidence}}
### {{outcome_id}} — ReviewItem {{review_item_uuid}}

- **OutcomeEvidence:** {{outcome_evidence_uuid}}
- **Comparison:** {{comparison}}
- **Timepoint:** {{timepoint}}
- **Papel analítico:** {{analysis_role}}
- **Primary-study set:** {{primary_study_set_status}}
- **Verificação:** {{verification_status}}
- **ResultVersion:** {{result_version_uuid}}
- **SynthesisVersion:** {{synthesis_version_uuid}}
- **CertaintyAssessmentVersion:** {{certainty_assessment_version_uuid}}
- **Extraction payload:** {{extraction}}

{{#if result}}
**Resultado selecionado**

- Measure: {{result.measure}}
- Reported value: {{result.reported_value}}
- Derived value: {{result.derived_value}}
- CI: {{result.ci_lower}} a {{result.ci_upper}}
- Unit: {{result.unit}}
- Estimand: {{result.estimand}}
- Method metadata: {{result.method}}
{{/if}}

{{#if synthesis}}
**Synthesis selecionada**

- Tipo: {{synthesis.synthesis_type}}
- Origem: {{synthesis.synthesis_origin}}
- Método: {{synthesis.method}}
- Modelo: {{synthesis.model}}
- Resultado: {{synthesis.result_summary}}
{{/if}}

{{#if certainty}}
**Certainty reportada pela Review**

- Framework: {{certainty.framework}}
- Initial level: {{certainty.initial_level}}
- Final level: {{certainty.final_level}}
- Evidence state: {{certainty.evidence_state}}
- Data: {{certainty.assessment_date}}
{{else}}
> **Certainty não reportada / não disponível para este OutcomeEvidence.**
{{/if}}

{{#if source_reports}}
**Fonte(s) da extração**

| Report | Local | Tipo | Método | Fonte primária | Extrator | Data |
|---|---|---|---|---|---|---|
{{#each source_reports}}
| {{report_id}} | {{source_location}} | {{source_type}} | {{extraction_method}} | {{is_primary_source}} | {{extractor}} | {{extracted_at}} |
{{/each}}
{{/if}}

{{#if provenance}}
**Provenance**

| Field | Source ReportVersion | Local | Processo | Transformação | Ator | Estado |
|---|---|---|---|---|---|---|
{{#each provenance}}
| {{field_path}} | {{source_report_version_uuid}} | {{source_location}} | {{process_type}} | {{transformation}} | {{actor}} | {{status}} |
{{/each}}
{{/if}}

{{/each}}
{{else}}
Nenhum OutcomeEvidence foi projetado.
{{/if}}

> O renderer não combina estimates nem escolhe Result/Synthesis alternativos.

---

## Membership Review × primary Study

{{#if primary_study_membership}}
| ReviewItem | Primary Study | Source ReportVersion | Local | Confiança de identidade | Verificação | Contexto |
|---|---|---|---|---|---|---|
{{#each primary_study_membership}}
| {{review_item_uuid}} | {{primary_study_id}} | {{source_report_version_uuid}} | {{source_location}} | {{identity_confidence}} | {{verification_status}} | {{context}} |
{{/each}}
{{else}}
Nenhuma membership foi projetada.
{{/if}}

> Membership parcial ou desconhecida limita a interpretação de overlap. O renderer não estima memberships ausentes.

---

## Clusters e overlap

{{#if overlap.clusters}}
{{#each overlap.clusters}}
### {{cluster_code}} — {{label}}

**Escopo:** {{scope}}

#### Membros

{{#if members}}
| ReviewItem | Disposição analítica | Rationale | Ordem |
|---|---|---|---:|
{{#each members}}
| {{review_item_uuid}} | {{analysis_disposition}} | {{rationale}} | {{sequence_no}} |
{{/each}}
{{/if}}

#### Métricas derivadas

- Reviews: **{{metrics.review_count}}**
- Ocorrências de Study: **{{metrics.study_occurrence_count}}**
- Primary Studies únicos: **{{metrics.unique_primary_study_count}}**
- Ocorrências redundantes: **{{metrics.redundant_occurrence_count}}**
- Completeness: **{{metrics.membership_completeness}}**
- CCA: **{{metrics.cca}}**
- CCA calculável: **{{metrics.cca_calculable}}**

{{#if metrics.cca_calculable}}
> CCA é exibido exatamente como derivado pela View.
{{else}}
> **CCA não calculável com a membership disponível.**
{{/if}}

#### Pairwise overlap

{{#if pairwise}}
| Review A | Review B | Studies A | Studies B | Compartilhados | União | Jaccard | A compartilhada | B compartilhada | Calculável | Completeness |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
{{#each pairwise}}
| {{review_item_a}} | {{review_item_b}} | {{studies_a}} | {{studies_b}} | {{shared_studies}} | {{union_studies}} | {{jaccard}} | {{proportion_a_shared}} | {{proportion_b_shared}} | {{calculable}} | {{completeness}} |
{{/each}}
{{/if}}

#### Resolução de overlap

- **Strategy:** {{resolution.strategy}}
- **Decision:** {{resolution.decision}}
- **Rationale:** {{resolution.rationale}}
- **Decidida por:** {{resolution.decided_by}}
- **Actor type:** {{resolution.actor_type}}
- **Verificação:** {{resolution.verification_status}}
- **Data:** {{resolution.decided_at}}

{{/each}}
{{else}}
Nenhum cluster de overlap foi projetado.
{{/if}}

> **Eligibility e overlap disposition são estados distintos.** Uma Review excluída por overlap continua podendo ser elegível.

---

## Concordância e divergência

{{#if concordance}}
| Cluster | Outcome | Comparison | Timepoint | Estado | Dimensões | Rationale | Assessor | Tipo | Verificação | Data |
|---|---|---|---|---|---|---|---|---|---|---|
{{#each concordance}}
| {{cluster_uuid}} | {{outcome_id}} | {{comparison}} | {{timepoint}} | {{state}} | {{dimensions}} | {{rationale}} | {{assessed_by}} | {{actor_type}} | {{verification_status}} | {{assessed_at}} |
{{/each}}
{{else}}
Nenhuma avaliação de concordância foi projetada.
{{/if}}

> Concordância não é votação por maioria. **Not comparable** não pode ser convertido em ranking de eficácia.

---

## Reviewer assignments

{{#if method.reviewer_assignments}}
| Etapa | Papel | Ator | Tipo | Qualificação | Independente | Escopo | Conflito | Início | Fim |
|---|---|---|---|---|---|---|---|---|---|
{{#each method.reviewer_assignments}}
| {{stage}} | {{role}} | {{actor}} | {{actor_type}} | {{qualification}} | {{independent}} | {{scope}} | {{conflict}} | {{assigned_at}} | {{ended_at}} |
{{/each}}
{{else}}
Nenhum ReviewerAssignment foi projetado.
{{/if}}

---

## Quality controls

{{#if method.quality_controls}}
| Etapa | Controle | Código | Ator | Tipo | Qualificação | Independente | Decisão | Escopo | Agreement | Discrepancy | Resolution | Artifact | Notas | Data |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
{{#each method.quality_controls}}
| {{stage}} | {{control_type}} | {{control_code}} | {{actor}} | {{actor_type}} | {{qualification}} | {{independent}} | {{decision}} | {{scope}} | {{agreement}} | {{discrepancy}} | {{resolution}} | {{evidence_artifact_uuid}} | {{notes}} | {{performed_at}} |
{{/each}}
{{else}}
Nenhum QualityControlRecord foi projetado.
{{/if}}

---

## Reanalysis

{{#if audit.reanalysis_present}}
**Nova reanalysis quantitativa presente:** sim  
**Controles estatísticos satisfeitos:** {{audit.statistical_controls_satisfied}}

> O renderer apenas apresenta a reanalysis projetada; não executa cálculos.
{{else}}
> **Nenhuma nova reanálise quantitativa do Overview foi executada.**
{{/if}}

---

## Referências

{{#if references}}
{{#each references}}
- **{{report_id}}** — {{title}}{{#if publication_date}} ({{publication_date}}){{/if}}{{#if publication_status}} — {{publication_status}}{{/if}}
  - Review: {{review_study_id}}
  - Relation type: {{relation_type}}
  - ReportVersion: {{report_version_uuid}}
{{/each}}
{{else}}
Nenhuma referência foi projetada.
{{/if}}

---

## Dependency lineage

{{#if lineage}}
| Source | Tipo | Target | Tipo | Dependência | Regra | Estado | Source invalidada |
|---|---|---|---|---|---|---|---|
{{#each lineage}}
| {{source_entity_id}} | {{source_entity_type}} | {{target_entity_id}} | {{target_entity_type}} | {{dependency_type}} | {{derivation_rule}} | {{dependency_status}} | {{source_invalidated}} |
{{/each}}
{{else}}
Nenhuma dependency lineage foi projetada.
{{/if}}

{{#if invalidated_dependencies_detail}}
### Dependências invalidadas

| Source | Target | Dependência | Motivo(s) de invalidação |
|---|---|---|---|
{{#each invalidated_dependencies_detail}}
| {{source_entity_id}} | {{target_entity_id}} | {{dependency_type}} | {{invalidation_records}} |
{{/each}}
{{/if}}

---

## Atualização

- **Currency:** {{update_state.currency_status}}
- **Avaliada em:** {{update_state.assessed_at}}
- **Por:** {{update_state.assessed_by}}
- **Rationale:** {{update_state.rationale}}

---

## Garantia metodológica e auditoria

{{#if audit.publishable}}
**Gate de publicação do Overview:** aprovado
{{else}}
**Gate de publicação do Overview:** não aprovado
{{/if}}  
**Fixture sintética:** {{audit.synthetic_fixture}}  
**Assurance:** {{audit.assurance_level}}  
**Assurance requerida:** {{audit.required_assurance_level}}  
**Reviews analíticas:** {{audit.review_count}}  
**Membership completa:** {{audit.membership_complete}}  
**Overlap avaliado:** {{audit.overlap_assessed}}  
**Appraisal completo:** {{audit.appraisal_complete}}  
**Extração completa:** {{audit.extraction_complete}}  
**Controles humanos satisfeitos:** {{audit.human_controls_satisfied}}  
**Reanalysis presente:** {{audit.reanalysis_present}}  
**Controles estatísticos satisfeitos:** {{audit.statistical_controls_satisfied}}  
**Lineage disponível:** {{audit.lineage_available}}  
**Dependências invalidadas:** {{audit.invalidated_dependencies}}

{{#if audit.publishable}}
> **Assurance + controles metodológicos + publication gate satisfeitos para esta ProductVersion.**
{{else}}
> **Assurance, inclusive A3, não substitui search coverage, screening, ROBIS, membership, overlap control, OutcomeEvidence, concordance nem controles humanos qualificados.**
{{/if}}

{{#if audit.publication_issues}}
### Issues do gate

{{#each audit.publication_issues}}
- **{{severity}} — {{code}}:** {{message}}
{{/each}}
{{else}}
Nenhuma issue registrada pelo gate.
{{/if}}

{{#if audit.assurance_records}}
### Registros de assurance

| Tipo | Ator | Tipo de ator | Independente | Decisão | Data |
|---|---|---|---|---|---|
{{#each audit.assurance_records}}
| {{assurance_type}} | {{actor}} | {{actor_type}} | {{independent}} | {{decision}} | {{performed_at}} |
{{/each}}
{{/if}}

### Identificadores técnicos

- Schema da view: `{{schema_version}}`
- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- Investigation entity UUID: `{{investigation.investigation_entity_uuid}}`
- InvestigationVersion UUID: `{{investigation.investigation_version_uuid}}`
- Question entity UUID: `{{question.question_entity_uuid}}`
- QuestionVersion UUID: `{{question.question_version_uuid}}`

---

_Produto OES. O Overview sintetiza evidência em nível de revisão sistemática; overlap, ROBIS, certainty e currentness permanecem dimensões distintas, e o renderer não cria inferências científicas adicionais._
