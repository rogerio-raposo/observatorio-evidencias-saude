<!--
OES Evidence Scan Template
template_version: oes.evidence_scan.template/0.1
input_contract: oes.evidence_scan_view/0.1
status: provisional-operational
canonical_scientific_source: EvidenceScanView + linked OES entities
presentation_rule: placeholders reference only fields present in EvidenceScanView 0.1
IMPORTANT: this template presents exploratory evidence-field information; it does not make scientific decisions.
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
**Profundidade:** {{investigation.depth_level}}  
**Manutenção:** {{investigation.maintenance_level}}  
**Estado editorial:** {{identity.editorial_status}}  
**Atualidade:** {{identity.currency_status}}  
**Evidência considerada até:** {{identity.evidence_cutoff_date}}  
**Nível de garantia:** {{audit.assurance_level}}
{{#if identity.publication_date}}  
**Publicação:** {{identity.publication_date}}
{{/if}}

---

## Pergunta original

{{question.original_text}}

{{#if question.normalized_text}}
### Formulação exploratória usada no scan

{{question.normalized_text}}
{{/if}}

---

## Objetivo do scan

{{objective}}

---

## Visão geral exploratória do campo

{{#if field_description.text}}
{{field_description.text}}
{{else}}
> Descrição estruturada do campo não disponível.
{{/if}}

---

## Maturidade preliminar

{{#if maturity.category}}
**Categoria:** {{maturity.category}}  
**Qualificador:** {{maturity.confidence_qualifier}}

{{maturity.rationale}}

> **A maturidade é um julgamento operacional para roteamento e não representa certeza/confiança da evidência.**
{{else}}
> Maturidade não registrada.
{{/if}}

---

## Sinais de evidência

{{#if volume_signals}}
### Sinais de volume

| Tipo | Valor | Qualificador | Contexto |
|---|---:|---|---|
{{#each volume_signals}}
| {{signal_type}} | {{value}} | {{qualifier}} | {{context}} |
{{/each}}
{{/if}}

{{#if evidence_types}}
### Tipos de evidência identificados

| Tipo | Sinal | Contagem | Qualificador |
|---|---|---:|---|
{{#each evidence_types}}
| {{evidence_type}} | {{signal}} | {{count}} | {{qualifier}} |
{{/each}}
{{/if}}

{{method.count_disclaimer}}

---

{{#if terminology}}
## Terminologia relevante

{{#each terminology}}
- **{{term}}** → {{normalized_label}} — {{role}}{{#if context}} — {{context}}{{/if}}
{{/each}}

---
{{/if}}

{{#if controversies}}
## Controvérsias aparentes

{{#each controversies}}
- **{{type}} / {{status}}:** {{statement}}{{#if rationale}} — {{rationale}}{{/if}}
{{/each}}

> **Controvérsias registradas em N0 permanecem preliminares e não são resolvidas pelo template.**

---
{{/if}}

{{#if gaps}}
## Lacunas aparentes na busca exploratória

{{#each gaps}}
- **{{scope}}:** {{statement}}
  - Qualificador: {{qualifier}}
  - Limite: {{limitation}}
{{/each}}

> **Uma lacuna registrada em N0 não demonstra ausência definitiva de evidência.**

---
{{/if}}

{{#if candidate_questions}}
## Perguntas candidatas para investigação posterior

{{#each candidate_questions}}
- **{{priority}}:** {{text}}{{#if suggested_question_class}} — classe sugerida: {{suggested_question_class}}{{/if}}
{{/each}}

---
{{/if}}

## Próxima rota metodológica sugerida

{{#if routing_recommendation.recommendation.target}}
**Rota:** {{routing_recommendation.recommendation.target}}  
**Status:** {{routing_recommendation.recommendation.status}}  
**Requer reformulação da pergunta:** {{routing_recommendation.recommendation.requires_question_reformulation}}

{{routing_recommendation.rationale.text}}
{{else}}
> Roteamento não registrado.
{{/if}}

---

## Conclusão exploratória

{{#if conclusion.text}}
{{conclusion.text}}
{{else}}
> Conclusão exploratória não disponível.
{{/if}}

---

## Limitações

{{#if limitations.present}}
{{limitations.summary}}
{{else}}
> Limitações não registradas. Esta condição é incompatível com publicação formal do Evidence Scan.
{{/if}}

---

{{#if applicability.summary}}
## Aplicabilidade

{{applicability.summary}}

_Avaliação formal de aplicabilidade não realizada neste Evidence Scan._

---
{{/if}}

## Método exploratório

> **Busca exploratória e não exaustiva. Este Evidence Scan não pretende demonstrar identificação completa de toda a literatura.**

{{#if method.searches}}
| Fonte | Plataforma | Execução | Registros | Hits materializados | Estado |
|---|---|---|---:|---:|---|
{{#each method.searches}}
| {{source_name}} | {{platform}} | {{executed_at}} | {{result_count}} | {{materialized_hit_count}} | {{status}} |
{{/each}}
{{else}}
Nenhuma Search concluída foi projetada para esta versão.
{{/if}}

{{method.count_disclaimer}}

---

## Fontes centrais

{{#if central_sources}}
{{#each central_sources}}
### {{report_id}} — {{title}}

{{#if publication_date}}**Publicação:** {{publication_date}}  {{/if}}
{{#if publication_status}}**Estado:** {{publication_status}}  {{/if}}
**Papel no scan:** {{component.role}}  
**Razão:** {{component.reason}}
{{#if source_location}}  
**Localização utilizada:** {{source_location}}
{{/if}}

{{/each}}
{{else}}
> **Nenhuma fonte central rastreável foi projetada.**
>
> Quando o campo está validamente classificado como `insufficient`, isso significa apenas que nenhuma fonte central foi localizada nas buscas exploratórias registradas; não demonstra ausência definitiva de evidência.
{{/if}}

---

## Referências

{{#if references}}
{{#each references}}
- **{{report_id}}** — {{title}}{{#if publication_date}} ({{publication_date}}){{/if}}{{#if publication_status}} — {{publication_status}}{{/if}}
{{/each}}
{{else}}
Nenhuma referência central rastreável foi projetada para esta versão.
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
**Base rastreável:** {{audit.traceable_basis_type}}  
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

- Schema da view: `oes.evidence_scan_view/0.1`
- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- InvestigationVersion primária: `{{investigation.investigation_version_uuid}}`
- QuestionVersion primária: `{{question.question_version_uuid}}`

---

_Produto OES. Este Evidence Scan é exploratório, não exaustivo e não constitui, por si só, resposta clínica focal ou recomendação normativa._
