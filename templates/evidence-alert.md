<!--
OES Evidence Alert Template
template_version: oes.evidence_alert.template/0.1
input_contract: oes.evidence_alert_view/0.1
status: provisional-operational
presentation_rule: placeholders reference only EvidenceAlertView 0.1
IMPORTANT: presentation only. No classification, urgency, SLA, currentness, assurance
or scientific conclusion is calculated here.
-->

{{#if audit.synthetic_fixture}}
> **FIXTURE SINTÉTICA — NÃO REPRESENTA ALERTA REAL**
>
> Este conteúdo existe exclusivamente para validação técnica da arquitetura do OES.
{{/if}}

{{#if audit.publishable}}
> **Gate formal do Alerta: aprovado.**
{{else}}
> **GATE FORMAL DO ALERTA NÃO APROVADO**
>
> O Alerta não deve ser tratado como comunicação formal publicável enquanto houver blockers ativos.
{{/if}}

# {{identity.title}}

**Product ID:** {{identity.product_id}}  
**Versão:** {{identity.version_no}}  
**Tipo:** {{identity.product_type}}  
**Estado editorial:** {{identity.editorial_status}}  
**Data de publicação:** {{identity.publication_date}}  
**Informação considerada até:** {{identity.information_cutoff_date}}  
**Assurance do Alerta:** {{audit.assurance_level}}  
**Assurance do target:** {{audit.target_assurance_level}}

---

## Alerta

### {{alert.headline}}

{{alert.summary}}

- **Classificação preliminar:** {{alert.classification}}
- **Prioridade de reavaliação:** {{alert.reassessment_priority}}
- **Lifecycle:** {{alert.lifecycle_status}}
- **Signal date:** {{alert.signal_date}}
- **Detectado em:** {{alert.detected_at}}
- **Emitido em:** {{alert.issued_at}}

> **Classificação preliminar de comunicação; não constitui atualização automática da conclusão científica.**
>
> **A prioridade de reavaliação é qualitativa; nenhum prazo/SLA está embutido nesta categoria na Fase 3.**
>
> **Mesmo quando classificado como crítico/urgente, o Alerta não cria auto-update, auto-publicação ou expert review.**

### Justificativa

{{alert.justification}}

---

## Contexto de origem

- **Investigation:** {{source_context.investigation_id}}
- **Versão:** {{source_context.version_no}}
- **Tipo:** {{source_context.investigation_type}}
- **Profundidade:** {{source_context.depth_level}}
- **Manutenção:** {{source_context.maintenance_level}}
- **Objetivo:** {{source_context.objective}}
- **Cutoff:** {{source_context.evidence_cutoff_date}}
- **Estado:** {{source_context.status}}

> **Source context e target são relações distintas.**

---

## Target potencialmente afetado

**Tipo de target:** {{target.target_type}}

{{#if target.target_product_id}}
- **Product ID:** {{target.target_product_id}}
- **Tipo de produto:** {{target.product_type}}
- **Título:** {{target.title}}
- **Versão:** {{target.version_no}}
- **Estado editorial:** {{target.editorial_status}}
- **Cutoff:** {{target.evidence_cutoff_date}}
- **Profundidade:** {{target.depth_level}}
- **Manutenção:** {{target.maintenance_level}}
- **Assurance:** {{target.assurance_level}}
- **Currentness:** {{target.currency.status}}
- **Conclusão científica do target:** {{target.scientific_conclusion}}
- **Aplicabilidade:** {{target.applicability_summary}}
- **Limitações:** {{target.limitations_summary}}
{{/if}}

{{#if target.target_investigation_id}}
- **Investigation ID:** {{target.target_investigation_id}}
- **Tipo de investigação:** {{target.investigation_type}}
- **Versão:** {{target.version_no}}
- **Profundidade:** {{target.depth_level}}
- **Manutenção:** {{target.maintenance_level}}
- **Objetivo:** {{target.objective}}
- **Cutoff:** {{target.evidence_cutoff_date}}
- **Estado:** {{target.status}}
- **Assurance de Product:** não aplicável
- **Currentness de Product:** não aplicável
- **Conclusão de Product:** não aplicável
{{/if}}

> **A conclusão científica exibida, quando houver, pertence ao target. O Alerta não cria nova conclusão científica.**
>
> **O currentness científico exibido, quando houver, pertence ao target. O Alerta não possui currentness científico próprio.**

---

## Fontes do Alerta

{{#if sources}}
{{#each sources}}
### {{source_role}} — {{source_type}}

- **AlertSource:** {{alert_source_uuid}}
- **Data:** {{source_date}}
- **Descrição:** {{description}}
- **CandidateAssessment:** {{candidate_assessment_uuid}}
- **EvidenceEvent:** {{evidence_event_uuid}}
- **EntityVersion:** {{source_entity_version_uuid}}
- **Artifact:** {{source_artifact_uuid}}
- **URI:** {{source_uri}}

{{#if source_entity}}
**Entity source:** {{source_entity.entity_id}} ({{source_entity.entity_type}})  
**Version status:** {{source_entity.version_status}}  
**Dependency ativa:** {{source_entity.dependency_active}}
{{/if}}

{{#if monitor_origin}}
**Origem em Monitor**

- Monitor Product ID: {{monitor_origin.monitor_product_id}}
- Monitor ProductVersion: {{monitor_origin.monitor_product_version_uuid}}
- Cycle: {{monitor_origin.cycle_no}}
- Cycle UUID: {{monitor_origin.cycle_uuid}}
{{#if candidate_assessment_uuid}}
- Candidate decision: {{monitor_origin.candidate_decision}}
- Candidate record status: {{monitor_origin.candidate_record_status}}
{{/if}}
{{#if evidence_event_uuid}}
- Event type: {{monitor_origin.event_type}}
- Event status: {{monitor_origin.event_status}}
{{/if}}
{{else}}
> **Fonte direta: este AlertSource não deriva de CandidateAssessment/EvidenceEvent persistido em Monitor.**
{{/if}}

{{#if issues}}
**Issues da fonte**

{{#each issues}}
- **{{severity}} — {{code}}:** {{message}}
{{/each}}
{{else}}
Nenhum issue ativo nesta fonte.
{{/if}}

{{/each}}
{{else}}
Nenhuma fonte projetada.
{{/if}}

---

## Dimensões potencialmente afetadas

{{#if affected_dimensions}}
| Dimensão | Rationale |
|---|---|
{{#each affected_dimensions}}
| {{dimension_code}} | {{rationale}} |
{{/each}}
{{else}}
Nenhuma dimensão projetada.
{{/if}}

> **As dimensões permanecem múltiplas; o template não calcula score agregado.**

---

## Verificação

- **Status:** {{alert.verification.status}}
- **Verificado por:** {{alert.verification.verified_by}}
- **Tipo do verificador:** {{alert.verification.verifier_actor_type}}
- **Data:** {{alert.verification.verified_at}}

> **Verificação por IA não equivale a verificação humana.**

---

## Lifecycle e incorporação

- **Lifecycle:** {{alert.lifecycle_status}}
- **Resolution rationale:** {{alert.resolution_rationale}}
- **Incorporated version UUID:** {{alert.incorporated_version_uuid}}
- **Incorporated CurrencyState UUID:** {{alert.incorporated_currency_state_uuid}}

> **Incorporação registrada não implica, por si só, mudança de conclusão científica.**

---

## Limitações

{{limitations.summary}}

---

## Assurance e auditoria

- **Fixture sintética:** {{audit.synthetic_fixture}}
- **Assurance do Alerta:** {{audit.assurance_level}}
- **Assurance do target:** {{audit.target_assurance_level}}
- **Verification status:** {{audit.verification_status}}
- **Verifier actor type:** {{audit.verifier_actor_type}}
- **Expert independent review presente:** {{audit.expert_independent_review_present}}
- **Publicável:** {{audit.publishable}}

> **A2 do Alerta não significa A2 do target e não significa expert review.**

### Publication issues

{{#if audit.publication_issues}}
{{#each audit.publication_issues}}
- **{{severity}} — {{code}}:** {{message}}
{{/each}}
{{else}}
Nenhuma publication issue registrada.
{{/if}}

### Projection hardening issues

{{#if audit.projection_hardening_issues}}
{{#each audit.projection_hardening_issues}}
- **{{severity}} — {{code}}:** {{message}}
{{/each}}
{{else}}
**Nenhum issue de projection hardening ativo.**
{{/if}}

{{#if audit.assurance_records}}
### Registros de assurance

| Tipo | Ator | Tipo de ator | Independente | Decisão | Data |
|---|---|---|---|---|---|
{{#each audit.assurance_records}}
| {{assurance_type}} | {{actor}} | {{actor_type}} | {{independent}} | {{decision}} | {{performed_at}} |
{{/each}}
{{/if}}

---

## Lineage

{{#if lineage.dependencies}}
| Source version | Target version | Dependency | Estado |
|---|---|---|---|
{{#each lineage.dependencies}}
| {{source_version_uuid}} | {{target_version_uuid}} | {{dependency_type}} | {{status}} |
{{/each}}
{{else}}
Nenhuma dependency projetada.
{{/if}}

---

## Identificadores técnicos

- Schema: `{{schema_version}}`
- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- Source-context InvestigationVersion: `{{source_context.investigation_version_uuid}}`

---

_Produto OES. Alerta comunica um sinal potencialmente material; atualização científica do target permanece processo separado e rastreável._
