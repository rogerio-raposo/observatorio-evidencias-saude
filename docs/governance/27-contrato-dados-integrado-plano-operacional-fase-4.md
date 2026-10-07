# 27 — Contrato de Dados Integrado do Plano Operacional da Fase 4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **DATA_CONTRACT_CANDIDATE — requer gate físico adversarial**  
**Dependências:** Documentos 05–09, 16–26; migrations 006, 010, 014–015, 021–028  
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

A persistência futura deve impedir:

> authoritative invalid_signal + UpdateSignal ainda active indefinidamente.

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
- locators opcionais;
- `rationale`;
- `sequence_no`.

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

# PARTE C — ESCALATION

## 13. maintenance.escalation_case

Representa um caso transversal de escalonamento.

Campos mínimos:

- `escalation_case_uuid` PK;
- `update_signal_uuid` FK;
- `priority_assessment_uuid` opcional;
- `status`;
- `authority_status`;
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

Não alterar calendário histórico usado por SLA Instance.

---

## 19. maintenance.sla_rule

Representa regra normativa versionada por clock.

Campos mínimos:

- `sla_rule_uuid` PK;
- `update_policy_uuid` FK;
- `clock_code`;
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
- `publication`;
- `not_applicable`.

---

## 20. SLA Rule — números não definidos

O contrato define **capacidade de representação**, não valores default.

Neste estágio:

> nenhuma duração universal é aprovada.

Logo, até posterior policy calibration:

- `target_duration` pode permanecer NULL em regras não operacionais;
- nenhuma SLA Rule pode ser marcada operacionalmente ativa se não possuir deadline/duração determinística aplicável;
- migration física, se futura, não deverá inserir SLA Rules normativas com números arbitrários.

---

## 21. SLA Rule — selector ambiguity

Duas rules ativas para a mesma UpdatePolicy/clock podem possuir filtros diferentes.

O contrato deverá proibir:

> ambiguidade não resolvida de rule selection.

Opções físicas futuras:

- precedência explícita;
- specificity rank não numérico?; ou
- exclusividade por combinação fechada de selectors.

Baseline preferida:

> não introduzir score de specificity.

O gate físico deverá decidir o mecanismo determinístico.

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
- `effective_due_at`;
- `end_at` opcional;
- `wall_elapsed_seconds` derivável/não persistir como autoridade;
- `accountable_elapsed_seconds` derivável/não persistir como autoridade;
- `execution_status`;
- `compliance_status`;
- `first_breached_at` opcional;
- `satisfied_at` opcional;
- `termination_reason` opcional;
- `created_at`;
- `record_status`;
- `supersedes_sla_instance_uuid` apenas para rebase explícito.

Domínio `execution_status`:

- pending;
- running;
- paused;
- satisfied;
- cancelled_invalidated;
- terminated_by_authority;
- not_applicable.

Domínio `compliance_status`:

- not_started;
- within_target;
- satisfied_on_time;
- breached_open;
- breached_then_satisfied;
- not_applicable.

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

Ao primeiro breach:

- fixar `first_breached_at`;
- compliance = breached_open;
- abrir issue;
- criar escalation candidate apenas se rule exigir.

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
- `recorded_at`;
- `external_event_payload` opcional;
- `record_status`;
- `supersedes_sla_pause_uuid` opcional.

Regras:

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

Domínio `status`:

- planned;
- active;
- scientific_complete;
- in_review;
- completed;
- terminated;
- cancelled_invalidated.

---

## 30. Workflow round — identidade

Regras:

1. exatamente um target original;
2. result version é opcional enquanto trabalho está em curso;
3. result version, quando existir, deve ser versão científica apropriada;
4. result não é criado pelo round automaticamente;
5. review_revision deve apontar para parent round;
6. novo revise round não sobrescreve round anterior;
7. uma UpdateDecision pode abrir mais de um round apenas quando tipos/razões forem distintos e explicitamente justificados.

---

# PARTE H — WORKFLOW MILESTONE / ADAPTER

## 31. maintenance.workflow_milestone

Normaliza eventos necessários aos clocks sem duplicar a fonte científica original.

Campos mínimos:

- `workflow_milestone_uuid` PK;
- `workflow_round_uuid` FK;
- `milestone_type`;
- `occurred_at`;
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

---

## 32. Milestone — fonte de verdade

### scientific_workflow_started

Pode ser evento transversal primário.

Não inferir de:

- ticket;
- branch;
- draft AI;
- scheduler.

### scientific_workflow_completed

É declaração de que conteúdo científico está pronto para review/governance.

Não significa:

- approved;
- published;
- assurance.

Quando resultar versão concreta:

> apontar para ProductVersion/InvestigationVersion.

### review_disposition

Quando existir objeto canônico:

- `product.review_record`;
- `product.assurance_record`;
- `investigation.method_decision`;

o milestone deve atuar como **adapter** e possuir locator correspondente.

Não duplicar decisão narrativa divergente em `adapter_payload`.

### publication

Para ProductVersion:

- deve apontar para ProductVersion publicada;
- `occurred_at` deve corresponder à semântica de publication_date/issued_at aplicável.

Para objeto sem publicação formal:

> não inventar publication milestone; usar review_disposition/not_applicable.

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

Logo:

> FKs podem formar grafo técnico opcional, mas o lifecycle causal não pode formar loop retroativo.

---

## 36. Circularidade Priority × Escalation

1. PriorityAssessment pode exigir escalation assessment/candidate;
2. escalation ativa pode revelar capacity/governance pressure;
3. nova PriorityAssessment pode registrar esse fato;
4. a prioridade anterior permanece histórica.

Não atualizar PriorityAssessment antiga in place.

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

execution/compliance podem evoluir de forma monotônica.

Não permitir:

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

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = CANDIDATE**

> **MIGRATION_029 = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 57. Próximo passo

> **Executar gate adversarial de coerência física do contrato integrado, incluindo cardinalidades, authority, adapter matrix, rule selection, lifecycle e riscos de circularidade.**

Somente após esse gate:

> decidir se migration 029 pode ser autorizada ou se o contrato requer revisão adicional.
