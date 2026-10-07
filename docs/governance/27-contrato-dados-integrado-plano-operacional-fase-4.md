# 27 — Contrato de Dados Integrado do Plano Operacional da Fase 4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — aprovado após Documento 28**  
**Dependências:** Documentos 05–09, 16–26; migrations 006, 010, 014–015, 021–028  
**Validado por:** Documento 28  
**Migration:** **não autorizada neste documento**

---

## 1. Finalidade

Transformar as arquiteturas já aprovadas de:

- triage;
- prioridade;
- escalation;
- SLA;
- workflow milestones;

em um **contrato lógico integrado**, history-preserving e compatível com o baseline físico atual.

O contrato deve permitir reconstruir:

> **UpdatePolicy → UpdateSignal → triage → priority → materiality/decision → escalation → workflow round/milestones → SLA instances/pauses → review/publication endpoint**

sem:

- criar currentness paralelo;
- duplicar MethodDecision;
- duplicar ReviewRecord/AssuranceRecord;
- inventar human verification;
- alterar ciência por atraso;
- autorizar auto-escalation;
- autorizar M3;
- fixar durações universais.

---

## 2. Âncora do plano operacional

Não criar uma tabela `operational_plan`.

A âncora normativa continua sendo:

> `maintenance.update_policy`

Motivo:

- já é versionada por supersessão;
- já está ligada ao target concreto;
- já contém regime M, cadence e policy payloads;
- criar outro plano 1:1 duplicaria identidade e lifecycle.

As novas estruturas deverão apontar, direta ou causalmente, para a UpdatePolicy aplicável.

---

## 3. Estruturas candidatas

O contrato lógico v0.1 propõe:

1. `maintenance.update_triage`;
2. `maintenance.priority_assessment`;
3. `maintenance.priority_basis`;
4. `maintenance.escalation_case`;
5. `maintenance.escalation_reason`;
6. `maintenance.escalation_route`;
7. `maintenance.sla_calendar_version`;
8. `maintenance.sla_rule`;
9. `maintenance.sla_instance`;
10. `maintenance.sla_pause`;
11. `maintenance.workflow_round`;
12. `maintenance.workflow_milestone`.

Essas estruturas são candidatas até o Documento 28.

---

# PARTE A — TRIAGE

## 4. maintenance.update_triage

Representa disposição transversal explícita de um UpdateSignal.

Campos mínimos:

- `update_triage_uuid` PK;
- `update_signal_uuid` FK;
- `disposition`;
- `duplicate_of_update_signal_uuid` opcional;
- `routed_to_uri` opcional;
- `routed_to_entity_version_uuid` opcional;
- `rationale`;
- `triaged_by`;
- `actor_type`;
- `verification_status`;
- `verified_by`;
- `verifier_actor_type`;
- `verified_at`;
- `authority_status`;
- `triaged_at`;
- `recorded_at`;
- `record_status`;
- `supersedes_update_triage_uuid`.

Domínio de `disposition`:

- `accepted_for_materiality`;
- `duplicate_or_already_covered`;
- `invalid_signal`;
- `out_of_scope`;
- `routed_elsewhere`.

Domínio de `authority_status`:

- `proposal`;
- `authoritative`.

---

## 5. Triage — cardinalidade

Regra:

> no máximo uma triagem ativa autoritativa por UpdateSignal.

Proposals podem coexistir historicamente, mas um contrato físico deverá impedir ambiguidade sobre a disposição autoritativa vigente.

Correção de triage:

> supersede + append.

Não editar materialmente a triage histórica.

---

## 6. Triage — autoridade

### proposal

Pode ser criado por:

- system;
- ai_system;
- human_reviewer;
- human_expert;
- owner.

### authoritative

Baseline:

#### accepted_for_materiality

Pode ser decidido por:

- human_reviewer;
- human_expert;
- owner.

É roteamento conservador para avaliação, não conclusão científica.

#### duplicate_or_already_covered

Exige:

- ator humano;
- linkage concreto para signal/case coberto;
- rationale.

#### invalid_signal / out_of_scope

Como podem suprimir avaliação científica:

> exigem human_reviewer ou human_expert.

Owner/system/AI não encerram autoritativamente um signal científico como inválido/out_of_scope na baseline.

#### routed_elsewhere

Pode ser:

- human_reviewer;
- human_expert;
- owner;

mas exige destino concreto + rationale.

---

## 7. Triage — efeitos

### accepted_for_materiality

- UpdateSignal continua ativo;
- abre elegibilidade para MaterialityAssessment;
- pode iniciar SLA-2.

### invalid_signal

Após triage autoritativa:

- UpdateSignal deve transitar active → invalidated;
- a triage não apaga o signal;
- SLA-1 pode ser satisfied;
- SLA-2 torna-se not_applicable/cancelled conforme rule.

A consistência física v0.1 será transacional por:

> constraint trigger `DEFERRABLE INITIALLY DEFERRED`

sobre triage autoritativa `invalid_signal`, verificando no COMMIT que o UpdateSignal está `invalidated`.

Uma função helper poderá encapsular a operação, mas não substituirá o guard de banco.

Além disso, `update_triage_issues()` deverá detectar:

> authoritative invalid_signal + UpdateSignal ainda active

sem depender apenas do caminho feliz de escrita.

### duplicate_or_already_covered

Não apaga source.

Deve apontar para:

- outro UpdateSignal; ou
- caso futuro explicitamente identificável.

### routed_elsewhere

Não equivale a resolução científica.

---

# PARTE B — PRIORIDADE

## 8. maintenance.priority_assessment

Representa a prioridade transversal de um caso concreto.

Campos mínimos:

- `priority_assessment_uuid` PK;
- `update_signal_uuid` FK;
- `update_policy_uuid` FK snapshot/reference;
- `stage`;
- `response_class`;
- `authority_scope`;
- `authority_status`;
- `feasibility_status`;
- `triage_uuid` opcional;
- `materiality_assessment_uuid` opcional;
- `update_decision_uuid` opcional;
- `currency_state_uuid` opcional;
- `alert_product_version_uuid` opcional;
- `triggering_sla_instance_uuid` opcional;
- `risk_profile_snapshot` JSONB;
- `dependency_snapshot` JSONB;
- `rationale`;
- `assessed_by`;
- `actor_type`;
- verification metadata;
- `assessed_at`;
- `recorded_at`;
- `record_status`;
- `supersedes_priority_assessment_uuid`.

Domínio `stage`:

- `signal_triage`;
- `materiality_resolution`;
- `update_decision`;
- `execution`;
- `resolution`.

Domínio `response_class`:

- `standard`;
- `expedited`;
- `urgent`;
- `immediate`.

Domínio `authority_scope`:

- `operational`;
- `scientific`;
- `mixed`.

Domínio `authority_status`:

- `proposal`;
- `authoritative`.

Domínio `feasibility_status`:

- `adequate`;
- `strained`;
- `insufficient`;
- `unavailable`.

---

## 9. PriorityAssessment — cardinalidade

Baseline:

> um PriorityAssessment ativo por UpdateSignal.

Novo estágio ou reavaliação:

> supersede + append.

Motivo:

- o objeto representa a disposição vigente do caso;
- os snapshots históricos preservam evolução;
- não criar uma prioridade ativa independente por stage que gere conflito sobre fila atual.

Queue aggregation:

> derivada, não persistida por default.

---

## 10. PriorityAssessment — authority

### proposal

AI/system/humano pode propor.

### authoritative operational

Pode ser owner ou humano qualificado.

Não pode:

- violar dominance floor científico qualificado;
- reinterpretar MaterialityAssessment.

### authoritative scientific/mixed

Exige:

- human_reviewer ou human_expert;
- verification humana;
- qualquer MaterialityAssessment usada como floor/strong scientific modifier deve estar human_verified/human_consensus.

Owner sozinho:

> não cria authoritative scientific/mixed.

---

## 11. maintenance.priority_basis

Normaliza as razões da prioridade sem score.

Campos mínimos:

- `priority_assessment_uuid` FK;
- `basis_code`;
- `basis_effect`;
- `basis_value`;
- `source_type`;
- locators estruturados opcionais;
- `snapshot_payload` JSONB opcional;
- `rationale`;
- `sequence_no`.

Regra de locator:

- `source_type='snapshot'` → nenhum FK locator; `snapshot_payload` obrigatório;
- source estruturado → exatamente um locator coerente com `source_type`;
- source_type/locator mismatch é erro;
- UUID genérico sem FK não é permitido.

Domínio `basis_effect`:

- `dominance_floor`;
- `strong_modifier`;
- `coordination_modifier`;
- `operational_pressure`;
- `feasibility`;
- `context`.

`basis_code` v0.1 pode incluir:

- criticality;
- conclusion_sensitivity;
- safety_integrity;
- materiality;
- currentness;
- alert_classification;
- alert_reassessment_priority;
- dependency_reach;
- sla_warning;
- sla_breach;
- fixed_deadline;
- capacity;
- incorporation_cost;
- regulatory_constraint;
- other.

Não criar pesos.

---

## 12. PriorityBasis — fontes

Quando existir objeto estruturado, usar locator concreto.

Locators candidatos:

- `update_triage_uuid`;
- `materiality_assessment_uuid`;
- `update_decision_uuid`;
- `currency_state_uuid`;
- `alert_product_version_uuid`;
- `sla_instance_uuid`;
- `escalation_case_uuid`;
- `source_entity_version_uuid`;
- external/fixed-deadline payload quando não houver objeto OES.

Para:

- criticality;
- conclusion sensitivity;
- dependency reach;
- feasibility;

enquanto não houver tabela física de UpdateRiskProfile:

> armazenar snapshot explícito + provenance/rationale, sem inventar FK inexistente.

Isso é dívida de normalização, não autorização para duplicar UpdateRiskProfile silenciosamente.

---

## 12.1 Consistência PriorityAssessment × PriorityBasis

Quando PriorityAssessment persistir:

- `risk_profile_snapshot`;
- `dependency_snapshot`;
- `feasibility_status`;

e também existirem PriorityBasis correspondentes, os valores devem ser coerentes.

Regras:

- basis criticality/sensitivity/safety/dependency derivada do risk snapshot deve coincidir com o snapshot;
- basis capacity deve coincidir com `feasibility_status`/B5 quando usada;
- basis materiality/currentness/Alert/SLA usa locator estruturado quando disponível;
- snapshot child não pode contradizer snapshot parent silenciosamente.

---

# PARTE C — ESCALATION

## 13. maintenance.escalation_case

Representa um caso transversal de escalonamento.

Campos mínimos:

- `escalation_case_uuid` PK;
- `update_signal_uuid` FK;
- `priority_assessment_uuid` opcional;
- `status`;
- `opened_at`;
- `activated_at`;
- `acknowledged_at`;
- `resolved_at`;
- `cancelled_at`;
- `opened_by`;
- `actor_type`;
- `activated_by` opcional;
- `activation_actor_type` opcional;
- `resolution_disposition` opcional;
- `resolution_rationale` opcional;
- `resolution_reference_payload` JSONB;
- `recorded_at`;
- `record_status`;
- `supersedes_escalation_case_uuid` opcional.

Domínio `status`:

- `candidate`;
- `active`;
- `acknowledged`;
- `resolved`;
- `cancelled_invalidated`.

Transições permitidas:

- candidate → active | cancelled_invalidated;
- active → acknowledged | resolved | cancelled_invalidated;
- acknowledged → resolved | cancelled_invalidated.

Transições de retorno são proibidas.

A autoridade é inferida pelo ato de activation:

- candidate pode ser system/AI/humano;
- active/acknowledged/resolved exigem `activated_by`, `activation_actor_type`, `activated_at`;
- baseline: activation_actor_type humano.

---

## 14. Escalation — criação e ativação

### candidate

Pode ser criado por:

- system;
- ai_system;
- humano.

### active

Baseline:

> exige ativação humana.

Não permitir system/AI como `activated_by` autoritativo.

Activation não é:

- human scientific verification;
- UpdateDecision;
- currentness change.

---

## 15. maintenance.escalation_reason

1:N por escalation_case.

Campos:

- `escalation_case_uuid`;
- `reason_code`;
- `rationale`;
- locator/source opcional;
- `sequence_no`.

Domínio:

- safety_integrity;
- validity_or_use;
- scientific_materiality;
- current_use_control;
- methodological_reroute;
- operational_delay;
- capacity_constraint;
- dependency_coordination;
- regulatory_external;
- governance_exception.

---

## 16. maintenance.escalation_route

1:N por escalation_case.

Campos:

- `escalation_case_uuid`;
- `route_code`;
- `route_status`;
- `assigned_to`;
- `assigned_actor_type`;
- `requested_at`;
- `acknowledged_at`;
- `resolved_at`;
- `resolution_reference_payload`;
- `sequence_no`.

Domínio `route_code`:

- operational_owner;
- qualified_scientific_review;
- methodological_governance;
- current_use_governance;
- safety_integrity_governance;
- publication_governance;
- dependency_coordination;
- resource_governance.

Domínio `route_status`:

- requested;
- acknowledged;
- resolved;
- cancelled.

---

## 17. Escalation — consistência mínima

Regras:

1. active/acknowledged exige pelo menos um reason;
2. active/acknowledged exige pelo menos uma route;
3. resolved exige todas as rotas obrigatórias terminalizadas ou rationale de encerramento excepcional;
4. cancelled_invalidated exige rationale;
5. safety_integrity exige route safety_integrity_governance;
6. validity_or_use exige current_use_governance e qualified_scientific_review;
7. current_use_control exige current_use_governance;
8. methodological_reroute exige methodological_governance;
9. capacity_constraint exige resource_governance;
10. dependency_coordination exige route homônima.

---

# PARTE D — SLA RULES E CALENDÁRIO

## 18. maintenance.sla_calendar_version

Suporta business_calendar sem depender de configuração mutable externa.

Campos mínimos:

- `sla_calendar_version_uuid` PK;
- `calendar_key`;
- `version_no`;
- `timezone_name`;
- `weekly_schedule_payload` JSONB;
- `exception_dates_payload` JSONB;
- `effective_from`;
- `effective_to`;
- `created_by`;
- `actor_type`;
- `record_status`;
- `supersedes_sla_calendar_version_uuid`.

O calendário deve ser versionado.

Shape lógico fechado:

### weekly_schedule_payload

- chaves weekday 1–7;
- cada dia contém lista ordenada de intervalos `HH:MM-HH:MM`;
- intervalos não podem se sobrepor;
- timezone vem de `timezone_name`.

### exception_dates_payload

Cada entrada contém:

- `date`;
- `mode = closed | custom`;
- custom intervals quando mode=custom;
- rationale opcional.

Migration futura deverá incluir validators para ambos os payloads.

Não alterar calendário histórico usado por SLA Instance.

---

## 19. maintenance.sla_rule

Representa regra normativa versionada por clock.

Campos mínimos:

- `sla_rule_uuid` PK;
- `rule_code` text estável dentro da UpdatePolicy;
- `update_policy_uuid` FK;
- `clock_code`;
- `selection_precedence` integer > 0;
- `response_class_filter` opcional;
- `signal_class_filter` opcional;
- `trigger_class_filter` opcional;
- `decision_type_filter` opcional;
- `materiality_outcome_filter` opcional;
- `endpoint_type`;
- `time_basis`;
- `target_duration` interval opcional;
- `fixed_deadline_rule_payload` JSONB;
- `sla_calendar_version_uuid` opcional;
- `pause_allowed`;
- `pause_policy_payload`;
- `warning_policy_payload`;
- `breach_policy_payload`;
- `escalation_policy_payload`;
- `effective_at`;
- `rationale`;
- `created_by`;
- `actor_type`;
- `record_status`;
- `supersedes_sla_rule_uuid`.

Domínio `clock_code`:

- `SLA1_DETECTION_TO_TRIAGE`;
- `SLA2_TRIAGE_TO_MATERIALITY`;
- `SLA3_MATERIALITY_TO_DECISION`;
- `SLA4_DECISION_TO_WORKFLOW_START`;
- `SLA5_WORKFLOW_START_TO_SCIENTIFIC_COMPLETION`;
- `SLA6_SCIENTIFIC_COMPLETION_TO_ENDPOINT`.

Domínio `time_basis`:

- `elapsed_time`;
- `business_calendar`;
- `fixed_deadline`.

Domínio `endpoint_type`:

- `triage`;
- `materiality`;
- `update_decision`;
- `workflow_started`;
- `scientific_completed`;
- `review_disposition`;
- `publication`.

Matriz obrigatória:

- SLA1 → triage;
- SLA2 → materiality;
- SLA3 → update_decision;
- SLA4 → workflow_started;
- SLA5 → scientific_completed;
- SLA6 → review_disposition | publication.

`not_applicable` pertence à SLA Instance, não à SLA Rule.

---

## 20. SLA Rule — determinismo temporal

Matriz:

### elapsed_time

- `target_duration` obrigatório e > 0;
- calendar NULL;
- fixed deadline payload vazio/NULL.

### business_calendar

- `target_duration` obrigatório e > 0;
- `sla_calendar_version_uuid` obrigatório;
- fixed deadline payload vazio/NULL.

### fixed_deadline

- `target_duration` NULL;
- `fixed_deadline_rule_payload` obrigatório e determinístico;
- non-pausable por default;
- calendar somente quando a regra normativa explicitamente exigir calendar-aware transformation.

Shape mínimo de `fixed_deadline_rule_payload`:

- `deadline_source_type` = external_rule | entity_version | artifact | manual_governance;
- `deadline_at` timestamptz **ou** `deadline_date` date, exatamente um;
- `time_precision` = timestamp | date;
- locator/source_reference compatível;
- rationale;
- timezone quando necessário.

Não fabricar timestamp quando a fonte só possuir data.

Rule operacional ativa sem representação temporal determinística é proibida.

---

## 20.1 SLA Rule — números não definidos

O contrato define **capacidade de representação**, não valores default.

Neste estágio:

> nenhuma duração universal é aprovada.

Logo, até posterior policy calibration:

- `target_duration` pode permanecer NULL em regras não operacionais;
- nenhuma SLA Rule pode ser marcada operacionalmente ativa se não possuir deadline/duração determinística aplicável;
- migration física, se futura, não deverá inserir SLA Rules normativas com números arbitrários.

---

## 21. SLA Rule — seleção determinística

Duas rules ativas para a mesma UpdatePolicy/clock podem possuir filtros diferentes.

Regra v0.1:

> `selection_precedence` menor é avaliada primeiro; a primeira rule cujos filtros fechados casam vence.

Constraints:

- `selection_precedence > 0`;
- `rule_code` não vazio;
- UNIQUE ativo em `update_policy_uuid + rule_code`;
- UNIQUE ativo em `update_policy_uuid + clock_code + selection_precedence`;
- filters devem ser explícitos/fechados;
- fallback, quando necessário, deve ser uma rule explícita;
- não existe score científico de specificity.

`selection_precedence` é ordem operacional de resolução, não prioridade científica.

---

# PARTE E — SLA INSTANCE

## 22. maintenance.sla_instance

Representa obrigação temporal concreta.

Campos mínimos:

- `sla_instance_uuid` PK;
- `sla_rule_uuid` FK;
- `update_signal_uuid` FK;
- `update_triage_uuid` opcional;
- `materiality_assessment_uuid` opcional;
- `update_decision_uuid` opcional;
- `workflow_round_uuid` opcional;
- `start_priority_assessment_uuid` opcional;
- `clock_code` redundante/snapshot;
- `endpoint_type` snapshot;
- `time_basis` snapshot;
- `rule_snapshot_payload`;
- `source_detected_at` opcional;
- `pre_policy_age` interval opcional;
- `start_at`;
- `nominal_due_at`;
- `end_at` opcional;
- `execution_status`;
- `first_breached_at` opcional;
- `satisfied_at` opcional;
- `termination_reason` opcional;
- `created_at`;
- `record_status`;
- `supersedes_sla_instance_uuid` apenas para rebase explícito;
- `rebase_reason` opcional;
- `rebased_by` opcional;
- `rebase_actor_type` opcional;
- `rebased_at` opcional.

Não persistir como fonte autoritativa:

- effective_due_at;
- wall_elapsed;
- accountable_elapsed;
- current compliance status.

Expor por helpers/views determinísticos.

Domínio `execution_status`:

- pending;
- running;
- paused;
- satisfied;
- cancelled_invalidated;
- terminated_by_authority;
- not_applicable.

Compliance atual deverá ser derivada por helper, com domínio:

- not_started;
- within_target;
- satisfied_on_time;
- breached_open;
- breached_then_satisfied;
- not_applicable.

Fatos persistidos que não podem ser perdidos:

- `first_breached_at`;
- `satisfied_at`;
- termination.

Se uma futura implementação optar por cachear compliance, deverá registrar `evaluated_at` e detectar staleness; o cache nunca será a fonte de verdade.

---

## 22.1 SLA Instance — cardinalidade da obrigação

- SLA1–SLA3: no máximo uma instância vigente por UpdateSignal + clock;
- SLA4–SLA6: no máximo uma instância vigente por WorkflowRound + clock.

Para SLA4, o WorkflowRound `planned` deve existir antes/ao nascimento da instância.

Rebase:

- supersede a instância anterior;
- preserva obligation identity;
- exige rebase_reason + rebased_by + rebased_at;
- não apaga first breach histórico;
- não muda target/round causal.

---

## 22.2 SLA Instance — transições de execução

Transições permitidas:

- pending → running | not_applicable | cancelled_invalidated;
- running → paused | satisfied | terminated_by_authority | cancelled_invalidated;
- paused → running | satisfied | terminated_by_authority | cancelled_invalidated.

Estados terminais não retornam a estados ativos.

Pause exige existência de intervalo de `sla_pause` válido.

---

## 23. SLA Instance — rule snapshot

Ao criar instância, congelar:

- SLA Rule UUID;
- rule selectors aplicados;
- UpdatePolicy;
- target version;
- clock;
- endpoint;
- duration/deadline;
- calendar version;
- pause policy;
- escalation policy;
- PriorityAssessment de início;
- demais risk inputs usados.

Mudança posterior:

> não recalcula a instância.

---

## 24. SLA Instance — start/end por clock

### SLA-1

Start:

> primeira detecção auditável pelo OES dentro da cadeia causal, limitada pela vigência/eligibility da rule.

End:

> triage autoritativa qualificante.

### SLA-2

Start:

> triage accepted_for_materiality autoritativa.

End:

> MaterialityAssessment qualificante conforme rule.

### SLA-3

Start:

> materiality_qualified_at.

End:

> decision_qualified_at de UpdateDecision authoritative.

### SLA-4

Start:

> decision_qualified_at quando decision exige workflow.

End:

> workflow_milestone = scientific_workflow_started ou methodological_workflow_started conforme aplicabilidade explícita.

### SLA-5

Start:

> workflow_started milestone.

End:

> scientific_workflow_completed.

### SLA-6

Start:

> scientific_workflow_completed.

End:

> endpoint declarado:
> review_disposition ou publication.

---

## 25. SLA Instance — late normalization

SLA-1 deve preservar:

- upstream detection;
- signal creation;
- triage.

Se signal foi criado tarde:

> não reiniciar o relógio em `update_signal.created_at`.

---

## 26. SLA Instance — pre-policy age

Se detecção precede rule/policy:

- preservar source_detected_at;
- preservar pre_policy_age;
- SLA start contratual = primeiro momento em que obrigação vigente + eligibility coexistem.

Não criar breach retroativo.

---

## 27. SLA Instance — breach

`maintenance.sla_effective_due_at(instance_uuid)` deverá derivar o due efetivo a partir de:

- nominal_due_at;
- calendar snapshot/version;
- pauses válidas.

Ao primeiro breach materializado:

- fixar `first_breached_at`;
- abrir issue;
- criar escalation candidate apenas se rule exigir.

Current compliance é derivada a partir dos fatos.

Conclusão tardia:

> breached_then_satisfied.

Nunca reescrever para satisfied_on_time.

---

# PARTE F — PAUSE

## 28. maintenance.sla_pause

Ledger append-preserving.

Campos:

- `sla_pause_uuid` PK;
- `sla_instance_uuid` FK;
- `reason_code`;
- `rationale`;
- `authorized_by`;
- `actor_type`;
- `authorized_at`;
- `started_at`;
- `ended_at` opcional;
- `closed_by` opcional;
- `closed_at` opcional;
- `recorded_at`;
- `external_event_payload` opcional;
- `record_status`;
- `supersedes_sla_pause_uuid` opcional.

Lifecycle limitado:

- open → closed;
- `ended_at/closed_by/closed_at` podem ser preenchidos uma única vez;
- demais campos materiais permanecem imutáveis;
- correção semântica = supersede + append.

Regras:

- `authorized_by` deve ser humano/owner compatível; AI/system não autoriza pause na baseline;
- rule deve permitir pause;
- fixed_deadline não-pausável por default;
- backlog/capacity não é pause;
- pause pós-breach não apaga first_breached_at;
- backdating sem fonte externa/rationale não altera compliance automaticamente.

---

# PARTE G — WORKFLOW ROUND

## 29. maintenance.workflow_round

Normaliza a unidade causal de trabalho aberta por UpdateDecision.

Não substitui:

- InvestigationVersion;
- ProductVersion;
- MethodDecision;
- ReviewRecord.

Campos mínimos:

- `workflow_round_uuid` PK;
- `update_signal_uuid` FK;
- `update_decision_uuid` FK;
- `round_type`;
- `round_no`;
- `parent_workflow_round_uuid` opcional;
- `opened_by_workflow_milestone_uuid` opcional;
- `target_product_version_uuid` ou `target_investigation_version_uuid`;
- `result_product_version_uuid` opcional;
- `result_investigation_version_uuid` opcional;
- `status`;
- `opened_at`;
- `closed_at` opcional;
- `rationale`;
- `created_by`;
- `actor_type`;
- `record_status`.

Domínio `round_type`:

- `scientific_update`;
- `methodological_reroute`;
- `review_revision`;
- `publication_remediation`;
- `other`.

Domínio `status` do WorkflowRound:

- planned;
- active;
- closed;
- terminated;
- cancelled_invalidated.

Não persistir no status:

- scientific_complete;
- in_review;
- publication_complete.

Esses estados são derivados de WorkflowMilestones, evitando duas fontes de verdade.

---

## 30. Workflow round — identidade

Regras:

1. exatamente um target original;
2. result version é opcional enquanto trabalho está em curso;
3. no máximo um result primário entre ProductVersion/InvestigationVersion;
4. result version, quando existir, deve ser versão científica apropriada;
5. result não é criado pelo round automaticamente;
6. review_revision deve apontar para parent round e `opened_by_workflow_milestone_uuid` do review disposition que gerou retrabalho;
7. novo revise round não sobrescreve round anterior;
8. uma UpdateDecision pode abrir mais de um round apenas quando tipos/razões forem distintos e explicitamente justificados.

---

## 30.1 WorkflowRound — status × milestone

- planned → ainda não existe workflow_started authoritative;
- active → existe workflow_started authoritative;
- closed → existe endpoint terminal aplicável do round;
- terminated → existe workflow_terminated authoritative;
- cancelled_invalidated → base causal cancelada/invalidada.

`scientific_workflow_completed`, review e publication continuam fatos dos milestones e não valores redundantes do status.

---

# PARTE H — WORKFLOW MILESTONE / ADAPTER

## 31. maintenance.workflow_milestone

Normaliza eventos necessários aos clocks sem duplicar a fonte científica original.

Campos mínimos:

- `workflow_milestone_uuid` PK;
- `workflow_round_uuid` FK;
- `milestone_type`;
- `adapter_type`;
- `time_precision = timestamp | date`;
- `occurred_at` opcional;
- `occurred_date` opcional;
- `qualified_at` opcional;
- `recorded_at`;
- `authority_status`;
- `actor`;
- `actor_type`;
- `product_review_uuid` opcional;
- `assurance_uuid` opcional;
- `method_decision_uuid` opcional;
- `product_version_uuid` opcional;
- `investigation_version_uuid` opcional;
- `artifact_uuid` opcional;
- `adapter_payload` JSONB;
- `rationale`;
- `record_status`;
- `supersedes_workflow_milestone_uuid`.

Domínio `milestone_type`:

- `scientific_workflow_started`;
- `methodological_workflow_started`;
- `scientific_workflow_completed`;
- `review_disposition`;
- `publication`;
- `workflow_terminated`.

Domínio `authority_status` do milestone:

- `proposal`;
- `authoritative`.

Domínio `adapter_type`:

- `native_event`;
- `product_review`;
- `assurance_record`;
- `method_decision`;
- `product_version`;
- `investigation_version`;
- `artifact`.

Regras:

- structured adapter → exatamente um locator correspondente;
- native_event → nenhum locator estruturado obrigatório, salvo result/reference específico;
- source/locator mismatch é erro;
- time_precision=timestamp → occurred_at obrigatório e occurred_date NULL;
- time_precision=date → occurred_date obrigatório e occurred_at NULL.

---

## 32. Milestone — fonte de verdade

### scientific_workflow_started

Pode ser evento transversal primário.

Não inferir de:

- ticket;
- branch;
- draft AI;
- scheduler.

Authority baseline:

- authoritative native event exige human_reviewer/human_expert;
- owner pode registrar mobilização operacional, mas não substituir confirmação humana de início científico;
- system/AI pode proposal ou adaptar fonte estruturada qualificante; não inventa start.

### scientific_workflow_completed

É declaração de que conteúdo científico está pronto para review/governance.

Authority baseline:

- authoritative native event exige human_reviewer ou human_expert;
- AI/system pode proposal, não conclusão científica autoritativa.

Não significa:

- approved;
- published;
- assurance.

Quando resultar versão concreta:

> apontar para ProductVersion/InvestigationVersion.

### review_disposition

Adapter matrix v0.1:

- `product_review` → `product.review_record`;
- `assurance_record` → `product.assurance_record`;
- `method_decision` → `investigation.method_decision`, somente para workflow metodológico;
- adapter especializado futuro somente após gate próprio.

O milestone deve herdar/validar a autoridade e disposition do objeto fonte.

Não duplicar decisão narrativa divergente em `adapter_payload`.

### publication

Adapter:

- `adapter_type='product_version'`;
- ProductVersion deve estar efetivamente publicada segundo seu contrato especializado;
- quando existir função `*_is_publishable()`, ela deve ser verdadeira no evento de publicação.

Precisão temporal:

- se houver timestamp editorial auditável, usar `time_precision='timestamp'`;
- se a fonte canônica tiver apenas `publication_date date`, usar `time_precision='date'`;
- não fabricar hora;
- uma SLA Rule que exija granularidade menor que a precisão do endpoint não é aplicável sem fonte temporal mais precisa.

Para objeto sem publicação formal:

> não inventar publication milestone; usar review_disposition/not_applicable.

---

## 32.1 Adapter matrix por família de endpoint

Os produtos atuais não possuem uma única cadeia de review.

Baseline:

- Evidence Sheet pode usar `product.review_record`;
- Evidence Response/Scan podem usar ReviewRecord e AssuranceRecord conforme gate especializado;
- Rapid Evidence Synthesis, Evidence Review, Evidence Map e Overview dependem fortemente de AssuranceRecord/controles especializados;
- MethodDecision é endpoint apenas de workflow metodológico, não publicação científica;
- publicação sempre permanece subordinada ao gate especializado do product_type.

Logo:

> `workflow_milestone` normaliza o evento, mas nunca substitui o objeto/gate especializado quando este existir.

---

## 33. Review rounds

`review_record.decision='revise'`:

- pode encerrar SLA-6 quando endpoint = review_disposition;
- não conclui publicação;
- se gerar retrabalho científico:
  - abrir workflow_round child `review_revision`;
  - novas SLA-4/5/6 conforme aplicabilidade.

`rejected`:

- produz terminalidade explícita;
- não é satisfied publication.

---

# PARTE I — REFERÊNCIAS CIRCULARES E ORDEM

## 34. Ordem causal permitida

Cadeia principal:

```text
UpdatePolicy
  → UpdateSignal
  → UpdateTriage
  → MaterialityAssessment
  → UpdateDecision
  → WorkflowRound
  → WorkflowMilestone
```

PriorityAssessment pode ocorrer em múltiplos pontos e supersede a avaliação anterior.

SLA Instance:

- observa a cadeia;
- não cria ciência.

Escalation:

- pode ser aberta por priority/SLA/decision;
- não cria ciência.

---

## 35. Circularidade Priority × SLA

Permitida apenas de forma temporalmente dirigida:

1. PriorityAssessment vigente pode iniciar SLA Instance;
2. SLA breach posterior pode ser basis de nova PriorityAssessment;
3. nova PriorityAssessment não altera silenciosamente a instância já iniciada.

Guard físico futuro:

> `triggering_sla_instance_uuid` deve apontar para instância criada/iniciada antes do `assessed_at` da nova PriorityAssessment.

Logo:

> FKs podem formar grafo técnico opcional, mas o lifecycle causal não pode formar loop retroativo.

---

## 36. Circularidade Priority × Escalation

1. PriorityAssessment pode exigir escalation assessment/candidate;
2. escalation ativa pode revelar capacity/governance pressure;
3. nova PriorityAssessment pode registrar esse fato;
4. a prioridade anterior permanece histórica.

Guards:

- escalation_case não pode apontar para PriorityAssessment que, por sua vez, use aquele mesmo escalation_case como basis no mesmo snapshot;
- nova PriorityAssessment pode referenciar escalation previamente criada/ativada;
- não atualizar PriorityAssessment antiga in place.

---

# PARTE J — CURRENTNESS / ASSURANCE / PUBLICATION

## 37. Currentness

Nenhuma nova tabela escreve CurrencyState automaticamente.

Priority/SLA/escalation/milestones:

> somente leem/referenciam CurrencyState.

Mudança continua por:

> MaterialityAssessment → UpdateDecision → CurrencyState linkage.

---

## 38. Assurance

Nenhum evento operacional:

- promove A1→A2;
- cria expert review;
- cria owner approval;
- cria human verification.

Workflow milestone pode adaptar AssuranceRecord existente.

---

## 39. Publication

Publication milestone:

- não publica;
- registra/adapta evento já ocorrido.

Publication gate do produto continua soberano.

---

# PARTE K — LIFECYCLE E IMUTABILIDADE

## 40. Append-preserving

Material fields de:

- update_triage;
- priority_assessment;
- escalation_case;
- sla_rule;
- sla_instance;
- sla_pause;
- workflow_round;
- workflow_milestone;

devem ser imutáveis.

Correções:

> supersede + append,

exceto transições lifecycle estritamente definidas em objetos que são, por natureza, stateful.

---

## 40.1 Risk-profile snapshot bridge

Enquanto UpdateRiskProfile não possuir tabela física, `risk_profile_snapshot` deve declarar:

- `schema_version`;
- `assessed_at`;
- A1 criticality;
- A2 evidence_volatility;
- A3 conclusion_sensitivity;
- A4 safety_integrity;
- A5 dependency_reach;
- B1 source_observability;
- B2 detection_latency;
- B3 surveillance_load;
- B4 incorporation_cost;
- B5 sustainable_capacity;
- rationale/reference.

Migration futura deverá possuir validator do snapshot.

---

## 41. Objetos stateful

### escalation_case

Pode avançar:

candidate → active → acknowledged → resolved

ou:

candidate/active/acknowledged → cancelled_invalidated.

Mudanças materiais de reason/route:

> não devem reescrever razões históricas.

### workflow_round

Pode avançar status sem alterar target/decision/result history.

### sla_instance

`execution_status` pode evoluir por transições controladas.

Compliance atual é derivada.

Persistir `first_breached_at` como fato histórico imutável quando materializado.

Não permitir que qualquer cache/projection converta:

- breached_open → within_target;
- breached_then_satisfied → satisfied_on_time.

---

# PARTE L — ISSUES / READINESS

## 42. Helpers futuros

Candidatos:

- `maintenance.update_triage_issues(uuid)`;
- `maintenance.priority_assessment_issues(uuid)`;
- `maintenance.escalation_case_issues(uuid)`;
- `maintenance.sla_rule_issues(uuid)`;
- `maintenance.sla_instance_issues(uuid)`;
- `maintenance.workflow_round_issues(uuid)`;
- `maintenance.workflow_milestone_issues(uuid)`;
- `maintenance.operational_control_readiness(target)`.

Helpers:

- não corrigem dados;
- não mudam currentness;
- não ativam escalation;
- não publicam.

---

## 43. Readiness integrada

Um target só poderá ser considerado operacionalmente pronto para SLA/priority formal quando:

1. UpdatePolicy válida;
2. regras aplicáveis não ambíguas;
3. calendário versionado quando necessário;
4. triage representável;
5. authority semantics implementadas;
6. priority floors testáveis;
7. escalation reasons/routes testáveis;
8. workflow milestones aplicáveis ao produto;
9. endpoint SLA-6 determinístico;
10. issue helpers sem error;
11. M3 blocker tratado separadamente.

Readiness do plano operacional:

> não equivale a M3 readiness.

---

# PARTE M — M3

## 44. M3

Mesmo que todo este contrato seja implementado:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL` não deve desaparecer automaticamente.

M3 readiness exigirá gate específico verificando:

- policy;
- cadence;
- source observability;
- capacity;
- triage;
- priority/escalation;
- SLA;
- workflow;
- publication/update path;
- governance.

---

# PARTE N — TESTES MÍNIMOS FUTUROS

## 45. Triage

Testar:

1. uma authoritative triage ativa/signal;
2. AI proposal permitido;
3. AI authoritative invalid/out_of_scope rejeitado;
4. duplicate exige target/link;
5. routed_elsewhere exige destino;
6. accepted habilita SLA-2/materiality;
7. invalid exige signal invalidated;
8. supersession preserva signal.

## 46. Priority

Testar:

9. uma active PriorityAssessment/signal;
10. proposal AI permitido;
11. authoritative scientific por AI rejeitado;
12. owner scientific/mixed rejeitado;
13. human-qualified materiality exigida para floor científico authoritative;
14. response classes fechadas;
15. immediate não implica route automaticamente;
16. confirmed isolado não força expedited;
17. confirmed+A1 high força urgent;
18. potentially_material+A1/A3 high força expedited;
19. capacity não permite downgrade;
20. Alert sem mapping automático;
21. Alert strong + downgrade exige rationale;
22. breach é operational pressure, não materiality;
23. queue aggregation não substitui casos.

## 47. Escalation

Testar:

24. system candidate permitido;
25. system activation rejeitada;
26. active exige reason;
27. active exige route;
28. safety reason exige safety route;
29. validity reason exige current-use + scientific;
30. capacity exige resource route;
31. resolved exige disposition/rationale;
32. cancelled exige rationale;
33. escalation resolved não muda currentness.

## 48. SLA Calendar/Rule

Testar:

34. business_calendar exige calendar version;
35. fixed_deadline não-pausável por default;
36. active rule exige duração/deadline determinística;
37. rule selector sem ambiguidade;
38. supersession temporal;
39. sem default numérico universal;
40. response_class não embute duração.

## 49. SLA Instance

Testar:

41. rule snapshot congelado;
42. SLA-1 usa upstream detection;
43. pre-policy age sem breach retroativo;
44. SLA-2 só após accepted triage;
45. AI-only assessment não fecha SLA-2 authoritative;
46. decision proposal não fecha SLA-3;
47. qualified_at correto;
48. SLA-4 só se workflow aplicável;
49. SLA-5 usa explicit milestones;
50. SLA-6 endpoint congelado;
51. first breach imutável;
52. breached_then_satisfied preservado;
53. priority posterior não recalcula due silenciosamente;
54. pause pós-breach não apaga breach.

## 50. Workflow

Testar:

55. round target XOR;
56. result version não auto-criada;
57. started não inferido de ticket/draft;
58. scientific_complete != approved/published;
59. review milestone usa adapter estruturado quando objeto existe;
60. revise cria novo round se houver retrabalho;
61. publication milestone exige publicação real;
62. method reroute não vira scientific update automaticamente;
63. round causal não é sobrescrito.

## 51. Regressões

Testar adicionalmente:

64. migration 027–028 semantics intactas;
65. MethodDecision distinct;
66. ReviewRecord/Assurance distinct;
67. CurrencyState unchanged by operational objects;
68. Alert/Monitor semantics intactas;
69. M3 blocker preservado;
70. idempotency;
71. rebuild;
72. F2-B/S4/S5/F3 regressions.

---

# PARTE O — DÍVIDAS EXPLÍCITAS

## 52. UpdateRiskProfile físico

Ainda não existe tabela física normalizada para o perfil do Documento 16.

Este contrato usa:

> snapshot explícito em PriorityAssessment/PriorityBasis

como solução de compatibilidade.

Antes de produção, avaliar se o perfil deve ganhar contrato físico próprio.

Não criar uma pseudo-FK.

---

## 53. Durações SLA

Nenhum número está autorizado.

O schema futuro pode suportar intervalos, mas rules operacionais só devem existir quando calibradas e aprovadas.

---

## 54. Calendários operacionais

O contrato define a necessidade de calendar version.

Timezone/weekly schedule/exceptions precisam de validação física cuidadosa.

---

## 55. Endpoint adapters por produto

Nem todo produto utiliza:

- ReviewRecord;
- AssuranceRecord;
- publication formal;

da mesma forma.

O contrato físico deve definir uma matriz de adapters por product_type/round_type antes de declarar SLA-6 universalmente operacional.

---

# PARTE P — STATUS

## 56. Decisão desta especificação

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **MIGRATION_029 = AUTHORIZED_IN_STRICT_SCOPE_AFTER_DOCUMENT_28**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 57. Próximo passo

> **Implementar migration 029 no escopo estrito autorizado pelo Documento 28 + suíte F4-OC-T01–T72 + integração S5; somente então executar validação técnica.**


---

## 58. Correções decorrentes do Documento 28

Foram incorporadas ao contrato:

1. consistência transacional deferred/helper para invalid triage;
2. PriorityBasis source_type + locator XOR + snapshot;
3. remoção de authority_status redundante de escalation_case;
4. transições fechadas de escalation;
5. selection_precedence determinística de SLA Rule;
6. matriz clock → endpoint;
7. matriz time_basis;
8. schema fechado de calendar payload;
9. effective due derivado por helper;
10. elapsed/compliance atuais derivados;
11. unicidade das SLA obligations;
12. metadata obrigatória de rebase;
13. WorkflowRound planned como âncora de SLA-4;
14. revision round ligado ao milestone que o abriu;
15. milestone adapter_type + locator XOR;
16. authority baseline dos milestones;
17. precisão temporal timestamp/date;
18. adapter matrix por família de endpoint;
19. pause open→closed com mutabilidade limitada;
20. first breach como fato persistido;
21. risk-profile snapshot versionado/validável;
22. guards temporais contra ciclos retroativos;
23. constraint deferred escolhida para invalid triage;
24. `rule_code` estável + precedência determinística de SLA Rule;
25. shape fechado de fixed deadline;
26. WorkflowRound status simplificado para não duplicar milestones;
27. authority_status fechado dos milestones;
28. consistência PriorityAssessment × PriorityBasis;
29. transições fechadas de execution_status;
30. pause authorization humana na baseline.

Estado:

> **READY_FOR_DOCUMENT_28_RECHECK**

> **MIGRATION_029 = NOT_AUTHORIZED_UNTIL_RECHECK**
