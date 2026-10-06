<!--
OES Evidence Map Template
template_version: oes.evidence_map.template/0.1
input_contract: oes.evidence_map_view/0.1
status: provisional-operational
canonical_scientific_source: EvidenceMapView + linked OES entities
presentation_rule: placeholders reference only fields present in EvidenceMapView 0.1
IMPORTANT: this template presents structure, counts, gaps, controls and assurance; it does not create classifications, scientific effects, gaps, certainty, recommendations or research priorities.
-->

{{#if audit.synthetic_fixture}}
> **FIXTURE SINTÉTICA — NÃO REPRESENTA MAPA DE EVIDÊNCIAS REAL**
>
> Codificadores, reviewer assignments, expert review, assurance, gaps e concentrações deste artefato são sintéticos e existem somente para validação do contrato técnico.
>
> **Não utilizar esta fixture como evidência clínica real.**
{{/if}}

{{#if audit.publishable}}
> **Gate de publicação do Mapa: aprovado.**
{{else}}
> **GATE DE PUBLICAÇÃO DO MAPA NÃO APROVADO**
>
> Assurance, inclusive A3, não substitui requisitos de coverage, search, screening, classification e CellScope.
{{/if}}

# {{identity.title}}

**Product ID:** {{identity.product_id}}  
**Versão:** {{identity.version_no}}  
**Subtype:** {{mapping_method.mapping_subtype}}  
**Cobertura:** {{mapping_method.coverage_claim}}  
**Modo de gap:** {{mapping_method.gap_claim_mode}}  
**Unidade principal de contagem:** {{mapping_method.counting_unit_policy}}  
**Profundidade da investigação de suporte:** {{investigation.depth_level}}  
**Manutenção:** {{investigation.maintenance_level}}  
**Estado editorial:** {{identity.editorial_status}}  
**Atualidade:** {{identity.currency_status}}  
**Evidência considerada até:** {{identity.evidence_cutoff_date}}  
**Assurance:** {{audit.assurance_level}}  
**Assurance requerida:** {{audit.required_assurance_level}}
{{#if identity.publication_date}}  
**Data de publicação registrada:** {{identity.publication_date}}
{{/if}}

---

## Pergunta e objetivo

{{question.normalized_text}}

{{#if question.original_text}}
**Pergunta original:** {{question.original_text}}
{{/if}}

**Objetivo da investigação:** {{investigation.objective}}

---

## Conclusão canônica do mapa

{{conclusion.text}}

> **Densidade de evidência não equivale a magnitude de efeito, certeza, qualidade ou benefício.**
>
> **Gap é dependente do framework, escopo, coverage, fontes e data de corte.**

---

## Método do mapa

- **Subtype:** {{mapping_method.mapping_subtype}}
- **Coverage claim:** {{mapping_method.coverage_claim}}
- **Gap claim mode:** {{mapping_method.gap_claim_mode}}
- **Counting unit policy:** {{mapping_method.counting_unit_policy}}
- **Coverage policy:** {{mapping_method.coverage_policy}}
- **Classification policy:** {{mapping_method.classification_policy}}
- **Gap rules:** {{mapping_method.gap_rules}}

{{#if source_investigations}}
### Investigações-fonte do corpus

| Investigation | Papel | Tipo | Profundidade | Cutoff | Estado |
|---|---|---|---|---|---|
{{#each source_investigations}}
| {{investigation_id}} | {{product_role}} | {{investigation_type}} | {{depth_level}} | {{evidence_cutoff_date}} | {{status}} |
{{/each}}

> Investigações-fonte fornecem corpus e rastreabilidade. Elas não substituem a pergunta nem o método da Investigation primária do Mapa.
{{/if}}

---

## Protocolo

{{#if protocol.artifact_uuid}}
- **Artifact:** {{protocol.artifact_uuid}}
- **Tipo:** {{protocol.artifact_type}}
- **Storage key:** {{protocol.storage_key}}
- **Hash:** {{protocol.content_hash}}
- **Algoritmo:** {{protocol.hash_algorithm}}
- **Estado:** {{protocol.status}}
{{else}}
> Protocolo rastreável não projetado.
{{/if}}

## Codebook

{{#if codebook.artifact_uuid}}
- **Artifact:** {{codebook.artifact_uuid}}
- **Tipo:** {{codebook.artifact_type}}
- **Storage key:** {{codebook.storage_key}}
- **Hash:** {{codebook.content_hash}}
- **Algoritmo:** {{codebook.hash_algorithm}}
- **Estado:** {{codebook.status}}
{{else}}
> Codebook rastreável não projetado.
{{/if}}

---

## Framework

- **Framework ID:** {{framework.framework_id}}
- **FrameworkVersion:** {{framework.framework_version_no}}
- **Row axis:** {{framework.primary_row_dimension_code}}
- **Column axis:** {{framework.primary_column_dimension_code}}
- **Visualization policy:** {{framework.visualization}}
- **Estado:** {{framework.status}}

### Dimensões

{{#if dimensions}}
| Código | Rótulo | Papel | Multivalorada | Obrigatória | Ordem |
|---|---|---|---|---|---:|
{{#each dimensions}}
| {{code}} | {{label}} | {{role}} | {{multi_valued}} | {{required}} | {{sequence_no}} |
{{/each}}
{{else}}
Nenhuma dimensão foi projetada.
{{/if}}

### Categorias

{{#if categories}}
| Dimensão | Código | Rótulo | Parent | Ordem |
|---|---|---|---|---:|
{{#each categories}}
| {{dimension_code}} | {{code}} | {{label}} | {{parent_category_uuid}} | {{sequence_no}} |
{{/each}}
{{else}}
Nenhuma categoria foi projetada.
{{/if}}

---

## Composição do corpus mapeado

**Distribuição por tipo de entidade:** {{distributions}}

> Esta distribuição descreve tipos de unidades mapeadas; não é medida de qualidade ou certeza.

---

## Matriz de evidências

{{#if cells}}
| Linha | Coluna | Escopo | Gap elegível | Studies | Reports | Syntheses | Outros | Total | Unidade contada | MapItems | Gap formal | Gap aparente | Gap primário | Gap de síntese |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---|---|---|---|---|
{{#each cells}}
| {{row_label}} | {{column_label}} | {{scope_status}} | {{gap_eligible}} | {{study_count}} | {{report_count}} | {{synthesis_count}} | {{other_count}} | {{total_count}} | {{counted_unit_count}} | {{map_item_uuids}} | {{empty_cell_gap}} | {{apparent_gap}} | {{primary_evidence_gap}} | {{synthesis_gap}} |
{{/each}}
{{else}}
Nenhuma célula foi projetada.
{{/if}}

> Células **não aplicáveis** ou **excluídas pelo framework** não representam gaps.

---

## Gaps derivados

{{#if gaps}}
{{#each gaps}}
### {{row_label}} × {{column_label}}

- **Escopo:** {{scope_status}}
- **Gap elegível:** {{gap_eligible}}
- **Studies:** {{study_count}}
- **Reports:** {{report_count}}
- **Syntheses:** {{synthesis_count}}
- **Unidade contada:** {{counted_unit_count}}
- **MapItems:** {{map_item_uuids}}

{{#if empty_cell_gap}}
> **Gap formal dentro do escopo definido.**
>
> A afirmação é restrita ao framework, fontes, critérios e data de corte deste ProductVersion.
{{/if}}
{{#if apparent_gap}}
> **Gap aparente.**
>
> Nenhuma unidade elegível foi localizada nas fontes consultadas para esta classificação; isso não demonstra ausência universal de evidência.
{{/if}}
{{#if primary_evidence_gap}}
> **Primary-evidence gap:** nenhum Study MapItem foi classificado nesta célula dentro do corpus mapeado. Isso não implica automaticamente prioridade de novo estudo.
{{/if}}
{{#if synthesis_gap}}
> **Synthesis gap:** há evidência primária mapeada, mas nenhuma Synthesis MapItem classificada na célula. Isso não implica automaticamente necessidade de revisão sistemática.
{{/if}}

{{/each}}
{{else}}
Nenhum gap derivado foi projetado.
{{/if}}

---

## Concentrações de evidência

{{#if concentrations}}
| Linha | Coluna | Studies | Reports | Syntheses | Total | Unidade contada |
|---|---|---:|---:|---:|---:|---:|
{{#each concentrations}}
| {{row_label}} | {{column_label}} | {{study_count}} | {{report_count}} | {{synthesis_count}} | {{total_count}} | {{counted_unit_count}} |
{{/each}}
{{else}}
Nenhuma concentração foi projetada.
{{/if}}

> Maior contagem não significa maior efeito, maior certeza ou melhor evidência.

---

## MapItems e drill-down

{{#if map_items}}
| MapItem | Target ID | TargetVersion | Tipo | Papel | Base de inclusão |
|---|---|---|---|---|---|
{{#each map_items}}
| {{map_item_uuid}} | {{target_id}} | {{target_version_uuid}} | {{target_type}} | {{item_role}} | {{inclusion_basis}} |
{{/each}}
{{else}}
Nenhum MapItem foi projetado.
{{/if}}

---

## Classificações

{{#if assignments}}
| MapItem | Dimensão | Categoria | Estado | Ator | Tipo | Método | Verificação | Verificador | Rationale |
|---|---|---|---|---|---|---|---|---|---|
{{#each assignments}}
| {{map_item_uuid}} | {{dimension_code}} | {{category_code}} | {{decision_state}} | {{assigned_by}} | {{actor_type}} | {{assignment_method}} | {{verification_status}} | {{verified_by}} | {{rationale}} |
{{/each}}
{{else}}
Nenhuma classificação foi projetada.
{{/if}}

> Classificações candidatas não alimentam células finais. Uso de IA não equivale a human verification.

---

## Buscas

{{#if searches}}
| Fonte | Plataforma | Classe | Versão | Executada | Resultados | Export | Estado |
|---|---|---|---|---|---:|---|---|
{{#each searches}}
| {{source_name}} | {{platform}} | {{source_class}} | {{strategy_version}} | {{executed_at}} | {{result_count}} | {{export_artifact_uuid}} | {{status}} |
{{/each}}
{{else}}
Nenhuma Search foi projetada.
{{/if}}

### Fluxo de seleção

- Search hits materializados: **{{selection_flow.search_hits}}**
- Reports-alvo únicos: **{{selection_flow.unique_report_targets}}**
- Decisões de screening: **{{selection_flow.screening_decisions}}**
- Título/resumo: **{{selection_flow.title_abstract_decisions}}**
- Texto completo: **{{selection_flow.full_text_decisions}}**
- Exclusões em texto completo: **{{selection_flow.full_text_exclusions}}**
- Adjudicações: **{{selection_flow.adjudications}}**

> Essas contagens não são rotuladas automaticamente como fluxo PRISMA.

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

## Controles metodológicos

{{#if method_controls}}
| Etapa | Controle | Código | Ator | Tipo | Independente | Decisão | Escopo | Data | Artifact |
|---|---|---|---|---|---|---|---|---|---|
{{#each method_controls}}
| {{stage}} | {{control_type}} | {{control_code}} | {{actor}} | {{actor_type}} | {{independent}} | {{decision}} | {{scope}} | {{performed_at}} | {{evidence_artifact_uuid}} |
{{/each}}
{{else}}
Nenhum QualityControlRecord foi projetado.
{{/if}}

---

## Stakeholder engagement

{{stakeholder_engagement}}

> Stakeholder engagement, quando existente, não substitui controles metodológicos.

---

## Appraisal

{{#if appraisal}}
{{#each appraisal}}
- {{this}}
{{/each}}
{{else}}
Nenhuma estrutura de appraisal foi projetada. Isso não deve ser interpretado como baixo risco de viés.
{{/if}}

## Certainty links

{{#if certainty_links}}
{{#each certainty_links}}
- {{this}}
{{/each}}
{{else}}
Nenhuma estrutura de certainty foi projetada. Não existe certainty global automática do Mapa.
{{/if}}

---

## Limitações

{{limitations.summary}}

---

## Referências rastreáveis

{{#if references}}
{{#each references}}
- **{{report_id}}** — {{title}}{{#if publication_date}} ({{publication_date}}){{/if}}{{#if publication_status}} — {{publication_status}}{{/if}}
  - ReportVersion: {{report_version_uuid}}
  - Origem no lineage: {{source_locations}}
{{/each}}
{{else}}
Nenhuma referência rastreável foi projetada.
{{/if}}

---

## Lineage

{{#if lineage}}
| SourceVersion | TargetVersion | Tipo de dependência | Regra | Estado |
|---|---|---|---|---|
{{#each lineage}}
| {{source_version_uuid}} | {{target_version_uuid}} | {{dependency_type}} | {{derivation_rule}} | {{status}} |
{{/each}}
{{else}}
Nenhum dependency edge do Mapa foi projetado.
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
**Gate de publicação do Mapa:** aprovado
{{else}}
**Gate de publicação do Mapa:** não aprovado
{{/if}}  
**Fixture sintética:** {{audit.synthetic_fixture}}  
**Assurance:** {{audit.assurance_level}}  
**Assurance requerida:** {{audit.required_assurance_level}}  
**Coverage:** {{audit.coverage_claim}}  
**Gap mode:** {{audit.gap_claim_mode}}  
**Counting unit:** {{audit.counting_unit_policy}}  
**Classificação completa:** {{audit.classification_complete}}  
**Controles de busca/seleção satisfeitos:** {{audit.search_controls_satisfied}}  
**Controles de classificação satisfeitos:** {{audit.classification_controls_satisfied}}  
**Elegibilidade para formal gap:** {{audit.formal_gap_eligible}}  
**Reviewer assignments ativos:** {{audit.reviewer_assignment_count}}  
**Revisão especializada independente:** {{audit.expert_independent_reviewed}}  
**Lineage disponível:** {{audit.lineage_available}}  
**Dependências invalidadas:** {{audit.invalidated_dependencies}}

{{#if audit.publishable}}
> **Assurance + controles metodológicos + publication gate satisfeitos para esta ProductVersion.**
{{else}}
> **Assurance, inclusive A3, não substitui coverage, stage controls, classification controls nem CellScope.**
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
- InvestigationVersion primária: `{{investigation.investigation_version_uuid}}`
- QuestionVersion primária: `{{question.question_version_uuid}}`
- FrameworkVersion: `{{framework.framework_version_uuid}}`

---

_Produto OES. O Mapa descreve a distribuição do corpus segundo um framework versionado; visualização, densidade e gaps não substituem método nem autorizam inferências de effectiveness._
