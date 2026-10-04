<!--
OES Evidence Sheet Template
template_version: oes.evidence_sheet.template/0.1
input_contract: oes.evidence_sheet_view/0.1
status: provisional-operational
canonical_scientific_source: EvidenceSheetView + linked OES entities
IMPORTANT: this template renders evidence; it is not a scientific source and must not make scientific decisions.
-->

{{#if audit.publishable}}
<!-- Gate de publicação aprovado -->
{{else}}
> **PREVIEW — NÃO PUBLICÁVEL**
>
> Este conteúdo é uma prévia interna. O gate de publicação contém pendências bloqueantes.
{{/if}}

# {{identity.title}}

**Product ID:** {{identity.product_id}}  
**Versão:** {{identity.version_no}}  
**Profundidade:** {{routing.depth_level}}  
**Manutenção:** {{routing.maintenance_level}}  
**Estado editorial:** {{identity.editorial_status}}  
**Atualidade:** {{display.currency_status}}  
**Evidência considerada até:** {{identity.evidence_cutoff_date}}
{{#if identity.publication_date}}  
**Publicação:** {{identity.publication_date}}
{{/if}}

---

## Pergunta

{{question.normalized_text}}

{{#if question.context}}
**Contexto:** {{question.context}}
{{/if}}

---

## Conclusão da evidência

{{#if conclusion.text}}
{{conclusion.text}}
{{else}}
> **Conclusão ainda não disponível — produto não publicado.**
{{/if}}

---

## Resultados e achados prioritários

{{#if priority_results}}
| Desfecho / achado | Resultado | Estudos | Certeza / confiança |
|---|---|---:|---|
{{#each priority_results}}
| {{display.outcome_or_finding}} | {{display.result}} | {{contributing_studies}} | {{display.certainty}} |
{{/each}}
{{else}}
Nenhum resultado ou achado prioritário foi registrado para esta versão.
{{/if}}

### Detalhamento

{{#each priority_results}}
#### {{display.outcome_or_finding}}

{{#if synthesis.population}}
**População:** {{synthesis.population}}  
{{/if}}
{{#if synthesis.comparison}}
**Comparação:** {{synthesis.comparison}}  
{{/if}}
{{#if synthesis.timepoint}}
**Tempo de avaliação:** {{synthesis.timepoint}}  
{{/if}}
{{#if synthesis.estimand}}
**Estimando:** {{synthesis.estimand}}  
{{/if}}

**Resultado:** {{display.result}}  
**Studies contribuintes:** {{contributing_studies}}  
**Results contribuintes:** {{contributing_results}}

{{#if certainty.formal_assessment}}
{{#if certainty.is_no_evidence}}
> **Não foram identificadas evidências elegíveis para esta unidade.**
{{else}}
**Certeza/confiança:** {{certainty.display_level}} ({{certainty.framework}})
{{/if}}

{{#if certainty.domains}}
**Razões principais:**
{{#each certainty.domains}}
- **{{domain_code}}:** {{rationale}}
{{/each}}
{{/if}}
{{else}}
> **Certeza/confiança: não avaliada formalmente.**
{{/if}}

{{/each}}

---

## Principais limitações

{{#if limitations.present}}
{{limitations.summary}}
{{else}}
> Limitações não registradas. Esta condição é incompatível com publicação da Ficha.
{{/if}}

---

## Aplicabilidade

{{#if applicability.summary}}
{{applicability.summary}}

{{#unless applicability.formal_assessment}}
_Avaliação formal de aplicabilidade ainda não implementada; análise descritiva._
{{/unless}}
{{else}}
Aplicabilidade não descrita para esta versão.
{{/if}}

---

{{#if safety}}
## Segurança e danos

{{#each safety}}
### {{role}}

{{display.result}}
{{/each}}

---
{{/if}}

## Método em resumo

**Última busca:** {{method.last_search_at}}

{{#if method.searches}}
### Fontes pesquisadas

| Fonte | Plataforma | Execução | Registros | Estado |
|---|---|---|---:|---|
{{#each method.searches}}
| {{source_name}} | {{platform}} | {{executed_at}} | {{result_count}} | {{status}} |
{{/each}}
{{/if}}

{{#if method.synthesis_methods}}
### Métodos de síntese

{{#each method.synthesis_methods}}
- **{{synthesis_type}}** — método: {{method}}{{#if model}}; modelo: {{model}}{{/if}}{{#if software}}; software: {{software}} {{software_version}}{{/if}}
{{/each}}
{{/if}}

{{#if method.certainty_frameworks}}
**Frameworks de certeza/confiança:** {{display.certainty_frameworks}}
{{/if}}

---

## Base de evidências

**Studies:** {{evidence_base.study_count}}  
**Reports:** {{evidence_base.report_count}}

{{#if evidence_base.study_designs}}
**Desenhos identificados:** {{display.study_designs}}
{{/if}}

{{#if evidence_base.included_studies}}
### Studies incluídos

| Study | Desenho | Amostra | Identificação |
|---|---|---:|---|
{{#each evidence_base.included_studies}}
| {{study_id}} | {{design}} | {{sample_size}} | {{title_or_label}} |
{{/each}}
{{/if}}

---

{{#if risk_of_bias.assessment_count}}
## Risco de viés / qualidade metodológica

**Avaliações:** {{risk_of_bias.assessment_count}}  
**Frameworks:** {{display.risk_frameworks}}  
**Julgamentos identificados:** {{display.risk_judgements}}

{{#if risk_of_bias.assessments}}
### Avaliações registradas

| ID | Framework | Julgamento | Data | Verificação |
|---|---|---|---|---|
{{#each risk_of_bias.assessments}}
| {{risk_assessment_id}} | {{framework}} | {{overall_judgement}} | {{assessment_date}} | {{verification_status}} |
{{/each}}
{{/if}}

---
{{/if}}

## Certeza/confiança — registros vinculados

{{#if certainty_assessments}}
{{#each certainty_assessments}}
### {{certainty_id}}

- **Framework:** {{framework}}{{#if framework_version}} — {{framework_version}}{{/if}}
- **Estado da evidência:** {{evidence_state}}
{{#if final_level}}
- **Nível final:** {{final_level}}
{{else}}
- **Nível final:** não aplicável / não estimado
{{/if}}
- **Data da avaliação:** {{assessment_date}}

{{#if domains}}
**Domínios:**
{{#each domains}}
- **{{domain_code}}:** {{concern_level}} — {{rationale}}
{{/each}}
{{/if}}

{{/each}}
{{else}}
> **Certeza/confiança: não avaliada formalmente.**
{{/if}}

---

## Atualidade e histórico

**Estado atual:** {{display.currency_status}}  
**Última avaliação de atualidade:** {{identity.currency_assessed_at}}  
**Versão atual:** {{update_history.current_version_no}}

{{#if update_history.predecessor_version_uuid}}
**Versão predecessora:** {{update_history.predecessor_version_uuid}}
{{else}}
**Histórico:** versão inicial.
{{/if}}

{{#if update_history.change_classes}}
### Classes de mudança

{{#each update_history.change_classes}}
- {{display.change_class}}{{#if rationale}} — {{rationale}}{{/if}}
{{/each}}
{{/if}}

{{#if update_history.currency_history}}
### Histórico de atualidade

| Estado | Avaliado em | Responsável | Situação do registro | Justificativa |
|---|---|---|---|---|
{{#each update_history.currency_history}}
| {{display.currency_status}} | {{assessed_at}} | {{assessed_by}} | {{record_status}} | {{rationale}} |
{{/each}}
{{/if}}

---

## Referências utilizadas

{{#if references}}
{{#each references}}
- **{{report_id}}** — {{title}}{{#if publication_date}} ({{publication_date}}){{/if}}{{#if publication_status}} — {{publication_status}}{{/if}}
  {{#if source_locations}}
  - Localização(ões) utilizada(s): {{display.source_locations}}
  {{/if}}
{{/each}}
{{else}}
Nenhuma referência derivada foi localizada no EvidenceSheetView.
{{/if}}

---

## Auditoria e rastreabilidade

**Gate de publicação:** {{display.publication_gate}}  
**Lineage disponível:** {{audit.lineage_available}}

{{#if audit.publication_issues}}
### Issues do gate

{{#each audit.publication_issues}}
- **{{severity}} — {{issue_code}}:** {{message}}
{{/each}}
{{else}}
Nenhuma issue registrada pelo gate.
{{/if}}

{{#if audit.reviews}}
### Revisões humanas

| Papel | Revisor | Independente | Decisão | Data | Estado |
|---|---|---|---|---|---|
{{#each audit.reviews}}
| {{role}} | {{reviewer}} | {{independent}} | {{decision}} | {{reviewed_at}} | {{status}} |
{{/each}}
{{/if}}

{{#if audit.linked_investigations}}
### Investigations vinculadas

{{#each audit.linked_investigations}}
- {{investigation_id}} — papel: {{role}} — versão: `{{investigation_version_uuid}}`
{{/each}}
{{/if}}

{{#if audit.linked_syntheses}}
### Syntheses vinculadas

{{#each audit.linked_syntheses}}
- {{synthesis_id}} — papel: {{role}} — versão: `{{synthesis_version_uuid}}`
{{/each}}
{{/if}}

{{#if audit.linked_certainty_assessments}}
### Certainty Assessments vinculados

{{#each audit.linked_certainty_assessments}}
- {{certainty_id}} — papel: {{role}} — versão: `{{certainty_version_uuid}}`
{{/each}}
{{/if}}

### Identificadores técnicos

- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- InvestigationVersion primária: `{{routing.investigation_version_uuid}}`
- QuestionVersion primária: `{{question.question_version_uuid}}`

---

_Produto OES. Este documento comunica evidência estruturada e não constitui, por si só, recomendação clínica ou normativa._
