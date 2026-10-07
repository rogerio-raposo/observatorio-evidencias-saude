<!--
OES Evidence Monitor Template
template_version: oes.evidence_monitor.template/0.1
input_contract: oes.evidence_monitor_view/0.1
status: provisional-operational
presentation_rule: placeholders reference only EvidenceMonitorView 0.1
IMPORTANT: this template presents monitoring state; it does not search, screen, recalculate currentness, decide updates, create Alerts, alter assurance or start Phase 4.
-->

{{#if audit.synthetic_fixture}}
> **FIXTURE SINTÉTICA — NÃO REPRESENTA MONITOR REAL**
>
> Searches, events, candidates, impacts, reviewers, assurance, currentness e decisões desta fixture existem exclusivamente para validação técnica.
{{/if}}

{{#if audit.publishable}}
> **Gate formal do Monitor: aprovado.**
{{else}}
> **GATE FORMAL DO MONITOR NÃO APROVADO**
>
> Assurance não substitui blockers de coverage, currentness, verificação, hardening ou política transversal.
{{/if}}

# {{identity.title}}

**Product ID:** {{identity.product_id}}  
**Versão:** {{identity.version_no}}  
**Tipo:** {{identity.product_type}}  
**Investigation:** {{monitor_investigation.investigation_id}}  
**Profundidade herdada:** {{monitor_investigation.depth_level}}  
**Manutenção:** {{monitor_investigation.maintenance_level}}  
**Estado editorial:** {{identity.editorial_status}}  
**Estado operacional:** {{operational_state.status}}  
**Currentness do Monitor:** {{monitor_currency.status}}  
**Currentness do target:** {{audit.target_currency_status}}  
**Baseline de evidência:** {{identity.baseline_evidence_cutoff_date}}  
**Último cycle concluído até:** {{audit.latest_completed_cycle_cutoff_date}}  
**Assurance do Monitor:** {{audit.assurance_level}}  
**Assurance do target:** {{audit.target_assurance_level}}  
**Assurance requerida:** {{audit.required_assurance_level}}  
**Publicável:** {{audit.publishable}}

> **O Monitor detecta e avalia sinais de nova evidência; não altera automaticamente a conclusão científica do produto monitorado.**
>
> **Monitor currentness e target scientific currentness são estados distintos.**
>
> **Uma exceção metodológica não equivale à execução da fonte dispensada.**

---

## Pergunta

{{question.normalized_text}}

{{#if question.original_text}}
**Pergunta original:** {{question.original_text}}
{{/if}}

**Estrutura:** {{question.structure_type}}

---

## Alvo monitorado

**Tipo de target:** {{target.target_type}}

{{#if target.target_product_id}}
- **Product ID:** {{target.target_product_id}}
- **Tipo de produto:** {{target.target_product_type}}
- **Título:** {{target.title}}
- **Versão:** {{target.version_no}}
- **Estado editorial:** {{target.editorial_status}}
- **Cutoff:** {{target.baseline_evidence_cutoff_date}}
- **Profundidade:** {{target.depth_level}}
- **Assurance:** {{target.assurance_level}}
- **Currentness:** {{target.currency.status}}
- **Conclusão científica:** {{target.scientific_conclusion}}
- **Aplicabilidade:** {{target.applicability_summary}}
- **Limitações:** {{target.limitations_summary}}
{{/if}}

{{#if target.target_investigation_id}}
- **Investigation ID:** {{target.target_investigation_id}}
- **Tipo de investigação:** {{target.investigation_type}}
- **Versão:** {{target.version_no}}
- **Estado:** {{target.status}}
- **Profundidade:** {{target.depth_level}}
- **Manutenção:** {{target.maintenance_level}}
- **Objetivo:** {{target.objective}}
- **Cutoff:** {{target.baseline_evidence_cutoff_date}}
{{/if}}

---

## Plano de monitoramento

**Escopo:** {{monitor_plan.surveillance_scope}}  
**Política de fontes:** {{monitor_plan.source_policy}}  
**Estratégia:** {{monitor_plan.strategy_policy}}  
**Cadência:** {{monitor_plan.cadence_policy}}  
**Política de impacto:** {{monitor_plan.impact_policy}}  
**Escalonamento:** {{monitor_plan.escalation_policy}}

### Requisitos de fonte

{{#if monitor_plan.source_requirements}}
| Código | Tipo | Valor | Mínimo | Exceção permitida | Rationale |
|---|---|---|---:|---|---|
{{#each monitor_plan.source_requirements}}
| {{requirement_code}} | {{requirement_kind}} | {{required_value}} | {{minimum_count}} | {{allow_exception}} | {{rationale}} |
{{/each}}
{{else}}
Nenhum SourceRequirement normalizado foi projetado.
{{/if}}

---

## Latest cycle

- **Cycle:** {{latest_cycle.cycle_no}}
- **Window:** {{latest_cycle.window.start_date}} a {{latest_cycle.window.end_date}}
- **Execução:** {{latest_cycle.execution.status}}
- **Completude:** {{latest_cycle.execution.completeness_status}}
- **Decisão:** {{latest_cycle.maintenance_decision.decision}}
- **Rationale:** {{latest_cycle.maintenance_decision.rationale}}
- **Verificação:** {{latest_cycle.verification.status}}
- **Verificador:** {{latest_cycle.verification.verified_by}}
- **Tipo do verificador:** {{latest_cycle.verification.verifier_actor_type}}
- **Escalonamento:** {{latest_cycle.escalation_recommendation}}

{{#if latest_cycle.execution.completed_at}}
> Latest cycle possui registro terminal.
{{else}}
> **Latest cycle ainda não possui conclusão terminal; não inferir decisão final.**
{{/if}}

---

## Latest completed cycle

- **Cycle:** {{latest_completed_cycle.cycle_no}}
- **Window:** {{latest_completed_cycle.window.start_date}} a {{latest_completed_cycle.window.end_date}}
- **Decisão:** {{latest_completed_cycle.maintenance_decision.decision}}
- **Rationale:** {{latest_completed_cycle.maintenance_decision.rationale}}
- **Verificação:** {{latest_completed_cycle.verification.status}}
- **Resulting target currentness:** {{latest_completed_cycle.resulting_target_currency.currency_status}}
- **Currency record status:** {{latest_completed_cycle.resulting_target_currency.record_status}}

---

## Histórico de cycles

{{#if cycles}}
{{#each cycles}}
### Cycle {{cycle_no}}

- **Window:** {{window.start_date}} a {{window.end_date}}
- **Execução:** {{execution.status}}
- **Completude:** {{execution.completeness_status}}
- **Decisão:** {{maintenance_decision.decision}}
- **Rationale:** {{maintenance_decision.rationale}}
- **Verificação:** {{verification.status}}
- **Verifier actor type:** {{verification.verifier_actor_type}}
- **Escalonamento:** {{escalation_recommendation}}
- **Resulting target currentness:** {{resulting_target_currency.currency_status}}
- **Currency record status:** {{resulting_target_currency.record_status}}

#### Searches

{{#if searches}}
| Search | Fonte | Plataforma | Classe | Executada | Resultados | Estado | Temporalmente aceitável |
|---|---|---|---|---|---:|---|---|
{{#each searches}}
| {{oes_search_id}} | {{source_name}} | {{platform}} | {{source_class}} | {{executed_at}} | {{result_count}} | {{status}} | {{temporally_acceptable}} |
{{/each}}
{{else}}
Nenhuma Search projetada para este cycle.
{{/if}}

{{#if searches}}
{{#each searches}}
{{#if search_hits}}
**SearchHits de {{oes_search_id}}**

| SearchHit | Report | Source record | Título | Ano | Identificador | Rank | Resolução |
|---|---|---|---|---:|---|---:|---|
{{#each search_hits}}
| {{oes_search_hit_id}} | {{report_id}} | {{source_record_id}} | {{raw_title}} | {{raw_year}} | {{raw_identifier}} | {{source_rank}} | {{resolution_status}} |
{{/each}}
{{/if}}
{{/each}}
{{/if}}

#### Requisitos de fonte

{{#if source_requirement_status}}
| Código | Tipo | Fulfilled | Exception | Satisfied | MethodDecision |
|---|---|---|---|---|---|
{{#each source_requirement_status}}
| {{requirement_code}} | {{requirement_kind}} | {{fulfilled}} | {{exception_applied}} | {{satisfied}} | {{exception_method_decision_uuid}} |
{{/each}}
{{else}}
Nenhum status de requisito projetado.
{{/if}}

{{#if source_requirement_status}}
{{#each source_requirement_status}}
{{#if exception_applied}}
> **{{requirement_code}}: cumprido por exceção metodológica documentada; a fonte não deve ser apresentada como executada por causa disso.**
{{/if}}
{{/each}}
{{/if}}

#### Issues temporais / de cycle

{{#if temporal_issues}}
{{#each temporal_issues}}
- **{{severity}} — {{code}}:** {{message}}
{{/each}}
{{else}}
Nenhum issue temporal projetado.
{{/if}}

{{#if issues}}
{{#each issues}}
- **{{severity}} — {{code}}:** {{message}}
{{/each}}
{{/if}}

#### EvidenceEvents

{{#if events}}
| Evento | Tipo | Data | Fonte | Descrição | Ator | Verificação | Estado |
|---|---|---|---|---|---|---|---|
{{#each events}}
| {{evidence_event_uuid}} | {{event_type}} | {{event_date}} | {{source_uri}} | {{description}} | {{detected_by}} | {{verification_status}} | {{status}} |
{{/each}}
{{else}}
Nenhum EvidenceEvent projetado.
{{/if}}

#### CandidateAssessments

{{#if candidates}}
{{#each candidates}}
**{{candidate_assessment_uuid}}**

- Origin: {{origin_type}}
- Candidate kind: {{candidate_kind}}
- Decision: {{decision}}
- Exclusion reason: {{exclusion_reason}}
- Primary impact: {{primary_impact_class}}
- Actor: {{assessed_by}} ({{actor_type}})
- Verification: {{verification_status}}
- Verifier: {{verified_by}} ({{verifier_actor_type}})
- Assessed at: {{assessed_at}}

{{#if impacts}}
| Impacto | Primário | Rationale |
|---|---|---|
{{#each impacts}}
| {{impact_class}} | {{is_primary}} | {{rationale}} |
{{/each}}
{{/if}}

{{/each}}
{{else}}
Nenhum CandidateAssessment projetado.
{{/if}}

{{/each}}
{{else}}
Nenhum cycle projetado.
{{/if}}

---

## Decisões metodológicas

{{#if method_decisions}}
| Tipo | Etapa | Código | Rationale | Resolução | Decidida por | Data |
|---|---|---|---|---|---|---|
{{#each method_decisions}}
| {{decision_type}} | {{stage}} | {{decision_code}} | {{rationale}} | {{resolution_status}} | {{decided_by}} | {{decided_at}} |
{{/each}}
{{else}}
Nenhuma MethodDecision projetada.
{{/if}}

---

## Quality controls

{{#if quality_controls}}
| Etapa | Controle | Código | Ator | Tipo | Independente | Decisão | Data |
|---|---|---|---|---|---|---|---|
{{#each quality_controls}}
| {{stage}} | {{control_type}} | {{control_code}} | {{actor}} | {{actor_type}} | {{independent}} | {{decision}} | {{performed_at}} |
{{/each}}
{{else}}
Nenhum QualityControlRecord projetado.
{{/if}}

---

## Lineage

**Target dependency:** {{update_lineage.target_dependency}}  
**Derived updates:** {{update_lineage.derived_updates}}

---

## Limitações

**Monitor:** {{limitations.limitations_summary}}  
**Aplicabilidade do Monitor:** {{limitations.applicability_summary}}

{{#if target.limitations_summary}}
**Target:** {{target.limitations_summary}}
{{/if}}

---

## Assurance e auditoria

- **Fixture sintética:** {{audit.synthetic_fixture}}
- **Assurance do Monitor:** {{audit.assurance_level}}
- **Assurance do target:** {{audit.target_assurance_level}}
- **Assurance requerida:** {{audit.required_assurance_level}}
- **Publicável:** {{audit.publishable}}
- **Operational status:** {{audit.monitor_operational_status}}
- **Monitor currentness:** {{audit.monitor_currency_status}}
- **Target currentness:** {{audit.target_currency_status}}
- **Maintenance level:** {{audit.maintenance_level}}
- **Baseline cutoff:** {{audit.baseline_evidence_cutoff_date}}
- **Latest completed cycle:** {{audit.latest_completed_cycle_uuid}}
- **Latest completed cutoff:** {{audit.latest_completed_cycle_cutoff_date}}
- **Latest cycle verification:** {{audit.latest_cycle_verification_status}}
- **Pending candidates:** {{audit.pending_candidate_count}}
- **Active events:** {{audit.active_event_count}}
- **Required source coverage satisfied:** {{audit.required_source_coverage_satisfied}}
- **Invalidated dependencies:** {{audit.invalidated_dependencies}}
- **M3 transversal policy operational:** {{audit.m3_transversal_update_policy_operational}}

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

{{#if audit.publication_issues}}
{{#each audit.publication_issues}}
{{#if code}}
{{#if severity}}
{{/if}}
{{/if}}
{{/each}}
{{/if}}

### Identificadores técnicos

- Schema: `{{schema_version}}`
- Product entity UUID: `{{identity.product_entity_uuid}}`
- ProductVersion UUID: `{{identity.product_version_uuid}}`
- Investigation entity UUID: `{{monitor_investigation.investigation_entity_uuid}}`
- InvestigationVersion UUID: `{{monitor_investigation.investigation_version_uuid}}`
- Question entity UUID: `{{question.question_entity_uuid}}`
- QuestionVersion UUID: `{{question.question_version_uuid}}`

---

_Produto OES. O Monitor comunica vigilância e avaliação de sinais de nova evidência; atualização científica e Alert permanecem processos separados e rastreáveis._
