<!--
OES Evidence Response Template
template_version: oes.evidence_response.template/0.1
input_contract: oes.evidence_response_view/0.1
status: provisional-operational
canonical_scientific_source: EvidenceResponseView + linked OES entities
presentation_rule: placeholders reference only fields present in EvidenceResponseView 0.1
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
**Atualidade:** {{identity.currency_status}}  
**Evidência considerada até:** {{identity.evidence_cutoff_date}}  
**Nível de garantia:** {{audit.assurance_level}}
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

## Resposta da evidência

{{#if answer.text}}
{{answer.text}}
{{else}}
> **Resposta ainda não disponível — produto não publicado.**
{{/if}}

---

## Principais resultados

{{#if key_results}}
{{#each key_results}}
- **Resultado:** {{source_value}}
  - Fonte: {{source_report_id}}
  - Localização: {{source_location}}
  - Proveniência: {{field_path}}
{{/each}}
{{else}}
Nenhum resultado-chave estruturado foi registrado para esta versão. Consulte a resposta sintética e as fontes-chave.
{{/if}}

---

## Certeza/confiança

{{#if certainty.formal_assessment}}
{{#each certainty.assessments}}
- **{{framework}}{{#if framework_version}} — {{framework_version}}{{/if}}:** {{final_level}}{{#if assessment_date}} — avaliação em {{assessment_date}}{{/if}}
{{/each}}
{{else}}
> **Certeza/confiança: não avaliada formalmente pelo OES nesta Resposta de Evidência.**
{{/if}}

---

## Principais limitações

{{#if limitations.present}}
{{limitations.summary}}
{{else}}
> Limitações não registradas. Esta condição é incompatível com publicação da Resposta de Evidência.
{{/if}}

---

{{#if applicability.summary}}
## Aplicabilidade

{{applicability.summary}}

{{#if applicability.formal_assessment}}
{{else}}
_Avaliação formal de aplicabilidade ainda não implementada; análise descritiva._
{{/if}}

---
{{/if}}

## Método em resumo

> **Busca estruturada e seletiva. Esta Resposta de Evidência não pretende demonstrar identificação exaustiva de toda a literatura.**

{{#if method.searches}}
| Fonte | Plataforma | Execução | Registros | Estado |
|---|---|---|---:|---|
{{#each method.searches}}
| {{source_name}} | {{platform}} | {{executed_at}} | {{result_count}} | {{status}} |
{{/each}}
{{else}}
Nenhuma busca estruturada foi projetada para esta versão.
{{/if}}

---

## Fontes-chave

{{#if key_sources}}
{{#each key_sources}}
### {{report_id}} — {{title}}

{{#if publication_date}}**Publicação:** {{publication_date}}  {{/if}}
{{#if publication_status}}**Estado:** {{publication_status}}  {{/if}}
**Appraisal formal registrado:** {{formal_appraisal_count}}

{{#if roles}}
**Papel na resposta:**
{{#each roles}}
- {{this}}
{{/each}}
{{/if}}

{{#if source_locations}}
**Localizações utilizadas:**
{{#each source_locations}}
- {{this}}
{{/each}}
{{/if}}

{{/each}}
{{else}}
Nenhuma fonte-chave rastreável foi projetada.
{{/if}}

---

## Referências

{{#if references}}
{{#each references}}
- **{{report_id}}** — {{title}}{{#if publication_date}} ({{publication_date}}){{/if}}{{#if publication_status}} — {{publication_status}}{{/if}}
{{/each}}
{{else}}
Nenhuma referência rastreável foi localizada.
{{/if}}

---

## Garantia metodológica e auditoria

{{#if audit.publishable}}
**Gate de publicação:** aprovado
{{else}}
**Gate de publicação:** não aprovado
{{/if}}  
**Nível derivado de garantia:** {{audit.assurance_level}}  
**Revisão especializada independente:** {{audit.expert_independent_reviewed}}  
**Lineage disponível:** {{audit.lineage_available}}

{{audit.assurance_disclosure}}

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

- Schema da view: `oes.evidence_response_view/0.1`
- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- InvestigationVersion primária: `{{routing.investigation_version_uuid}}`
- QuestionVersion primária: `{{question.question_version_uuid}}`

---

_Produto OES. Esta Resposta de Evidência usa busca estruturada e seletiva e não constitui, por si só, recomendação clínica ou normativa._
