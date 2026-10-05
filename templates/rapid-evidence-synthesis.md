<!--
OES Rapid Evidence Synthesis Template
template_version: oes.rapid_evidence_synthesis.template/0.1
input_contract: oes.rapid_evidence_synthesis_view/0.1
status: provisional-operational
canonical_scientific_source: RapidEvidenceSynthesisView + linked OES entities
presentation_rule: placeholders reference only fields present in RapidEvidenceSynthesisView 0.1
IMPORTANT: this template presents evidence and methodological controls; it does not create scientific judgements or assurance.
-->

{{#if audit.publishable}}
<!-- Gate de publicação N3 aprovado -->
{{else}}
> **EXPERIMENTAL — NÃO PUBLICÁVEL COMO N3 FORMAL**
>
> **PREVIEW — GATE DE PUBLICAÇÃO NÃO APROVADO**
>
> O núcleo científico pode estar estruturado, mas publicação formal N3 exige controles humanos qualificados e garantia A3.
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
**Data registrada:** {{identity.publication_date}}
{{/if}}

---

## Pergunta

{{question.normalized_text}}

{{#if question.original_text}}
**Pergunta original:** {{question.original_text}}
{{/if}}

---

## Contexto decisório

**Objetivo:** {{decision_context.objective}}  
**Público-alvo:** {{decision_context.intended_audience}}

{{#if decision_context.question_context}}
**Contexto:** {{decision_context.question_context}}
{{/if}}

---

## Conclusão da evidência

{{conclusion.text}}

{{#if audit.publishable}}
> **Gate de publicação N3:** aprovado.
{{else}}
> **Esta conclusão permanece em contexto experimental/não publicável como N3 formal.**
{{/if}}

---

## Certeza/confiança

{{#if certainty}}
{{#each certainty}}
- **{{framework}}{{#if framework_version}} — {{framework_version}}{{/if}}**
  - Estado da evidência: {{evidence_state}}
  - Nível inicial: {{initial_level}}
  - Nível final: {{final_level}}
  - Avaliação: {{assessment_date}}
  - Papel: {{role}}
{{/each}}
{{else}}
> Nenhuma CertaintyAssessment foi projetada para esta versão.
{{/if}}

---

## Síntese

{{#if syntheses}}
{{#each syntheses}}
### {{synthesis_id}} — {{synthesis_type}}

**Origem:** {{synthesis_origin}}  
**Método:** {{method}}  
{{#if model}}**Modelo:** {{model}}  {{/if}}
{{#if software}}**Software:** {{software}}{{#if software_version}} {{software_version}}{{/if}}  {{/if}}
**Papel:** {{role}}

**Resumo:** {{result_summary}}

{{/each}}
{{else}}
> Nenhuma SynthesisVersion foi projetada.
{{/if}}

---

## Resultados críticos

{{#if results}}
| Medida | Valor reportado | Valor derivado | IC inferior | IC superior | Unidade |
|---|---|---|---:|---:|---|
{{#each results}}
| {{measure}} | {{reported_value}} | {{derived_value}} | {{ci_lower}} | {{ci_upper}} | {{unit}} |
{{/each}}
{{else}}
Nenhum Result estruturado foi projetado.
{{/if}}

---

## Limitações da evidência

{{#if risk_of_bias}}
### Risco de viés / appraisal

| Framework | Julgamento | Assessor | Verificação | Data |
|---|---|---|---|---|
{{#each risk_of_bias}}
| {{framework}} | {{overall_judgement}} | {{assessor}} | {{verification_status}} | {{assessment_date}} |
{{/each}}

> **O verification status do appraisal não substitui registro de quality control humano qualificado.**
{{else}}
Nenhum RiskAssessment foi projetado.
{{/if}}

{{#if applicability.summary}}
### Aplicabilidade

{{applicability.summary}}

_Avaliação formal de aplicabilidade/transferibilidade: {{applicability.formal_assessment}}._
{{/if}}

---

## Limitações decorrentes do método rápido

{{rapid_method_limitations.summary}}

{{#if rapid_method.restrictions}}
### Restrições planejadas do método rápido

{{#each rapid_method.restrictions}}
#### {{stage}} — {{code}}

**Planejada:** {{planned}}  
**Status:** {{resolution_status}}

**Justificativa:** {{rationale}}  
**Risco adicional:** {{risk}}  
**Mitigação:** {{mitigation}}
{{#if impact}}  
**Impacto esperado:** {{impact}}
{{/if}}

{{/each}}
{{else}}
> Nenhuma rapid restriction foi projetada. Para o contrato N3 v0.1, esta condição exige revisão metodológica.
{{/if}}

{{#if rapid_method.deviations}}
### Desvios do protocolo

{{#each rapid_method.deviations}}
#### {{stage}} — {{code}}

**Status:** {{resolution_status}}  
**Justificativa:** {{rationale}}  
**Impacto:** {{impact}}  
**Mitigação:** {{mitigation}}

{{/each}}
{{else}}
**Desvios do protocolo:** nenhum desvio ativo/projetado nesta versão.
{{/if}}

---

## Protocolo

{{#if protocol.artifact_uuid}}
**Artifact:** {{protocol.artifact_uuid}}  
**Tipo:** {{protocol.artifact_type}}  
**Storage key:** {{protocol.storage_key}}  
**Hash:** {{protocol.content_hash}}  
**Estado:** {{protocol.status}}
{{else}}
> Protocolo rastreável não disponível.
{{/if}}

---

## Busca

{{#if searches}}
| Fonte | Plataforma | Execução | Resultados reportados | Hits materializados | Estado |
|---|---|---|---:|---:|---|
{{#each searches}}
| {{source_name}} | {{platform}} | {{executed_at}} | {{result_count}} | {{materialized_hit_count}} | {{status}} |
{{/each}}
{{else}}
Nenhuma Search foi projetada.
{{/if}}

---

## Fluxo de seleção

- Hits materializados: **{{selection_flow.search_hits_materialized}}**
- Decisões de screening: **{{selection_flow.screening_decisions}}**
- Título/resumo: **{{selection_flow.title_abstract_decisions}}**
- Texto completo: **{{selection_flow.full_text_decisions}}**
- Exclusões em texto completo: **{{selection_flow.full_text_exclusions}}**

_Estes contadores são os elementos materializados no OES e não devem ser tratados automaticamente como diagrama PRISMA completo._

---

## Evidência incluída

{{#if included_evidence}}
{{#each included_evidence}}
- **{{report_id}}** — {{title}}{{#if publication_date}} ({{publication_date}}){{/if}}{{#if publication_status}} — {{publication_status}}{{/if}}
{{/each}}
{{else}}
Nenhuma evidência incluída foi projetada.
{{/if}}

---

## Quality controls

{{#if quality_controls}}
| Etapa | Controle | Ator | Tipo | Qualificado | Independente | Decisão | Data |
|---|---|---|---|---|---|---|---|
{{#each quality_controls}}
| {{stage}} | {{control_type}} | {{actor}} | {{actor_type}} | {{qualified}} | {{independent}} | {{decision}} | {{performed_at}} |
{{/each}}
{{else}}
Nenhum quality control foi registrado.
{{/if}}

> **Um controle executado por IA não equivale a verificação humana qualificada.**

---

{{#if audit.missing_controls}}
## Controles qualificados ainda ausentes — blockers formais

{{#each audit.missing_controls}}
- **{{control_code}}:** {{message}}
{{/each}}

---
{{/if}}

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
**Gate de publicação N3:** aprovado
{{else}}
**Gate de publicação N3:** não aprovado
{{/if}}  
**Assurance:** {{audit.assurance_level}}  
**Revisão especializada independente:** {{audit.expert_independent_reviewed}}  
**Controles qualificados satisfeitos:** {{audit.qualified_controls_satisfied}}  
**Desvio de protocolo aberto:** {{audit.protocol_deviations_open}}  
**Lineage disponível:** {{audit.lineage_available}}

{{#if audit.publishable}}
> **A3 + controles qualificados satisfeitos.**
{{else}}
> **A2 ou nível inferior não autoriza publicação N3 formal.**
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

- Schema da view: `oes.rapid_evidence_synthesis_view/0.1`
- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- InvestigationVersion primária: `{{investigation.investigation_version_uuid}}`
- QuestionVersion primária: `{{question.question_version_uuid}}`

---

_Produto OES. Uma Síntese Rápida N3 utiliza método sistemático abreviado e não pode ser publicada formalmente sem os controles qualificados e assurance exigidos pelo protocolo._
