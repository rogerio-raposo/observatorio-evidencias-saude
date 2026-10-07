# 41 — Contrato Físico v0.1 dos Pré-requisitos de Calibração Temporal

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISED_AFTER_DOCUMENT_42 — READY_FOR_RECHECK — NO_NORMATIVE_VALUES_AUTHORIZED**  
**Dependências:** Documentos 18–21, 25–31, 33–40; migrations 027, 029–031  
**Objeto:** especificar o contrato físico necessário para calibrar e futuramente ativar cadence/SLA de forma determinística, sem inserir valores normativos

---

## 1. Estado

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = CANDIDATE**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **SCHEDULER = NOT_AUTHORIZED**

> **NOTIFICATIONS = NOT_AUTHORIZED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A eventual migration 032, se autorizada por gate posterior, deverá criar **infraestrutura e guards**, sem seed de cadence, duração SLA, grace, warning, calendário real ou threshold normativo.

---

# PARTE A — GRANDFATHERING TÉCNICO

## 2. Contract epoch

Reusar `maintenance.contract_epoch`.

Novo registro técnico futuro:

- `contract_code = TEMPORAL_CALIBRATION_V01`;
- `schema_version = 0.1`;
- `migration_id = 032`;
- `effective_at` preservado idempotentemente.

O epoch serve exclusivamente para:

- grandfathering técnico;
- distinguir regras antigas de regras criadas sob o contrato novo.

Não serve como:

- evidence cutoff;
- cadence anchor;
- SLA start;
- deadline;
- currentness timestamp.

---

# PARTE B — CALIBRATION DOSSIER

## 3. maintenance.temporal_calibration_dossier

Representa o pacote auditável de uma calibração.

Campos:

- `temporal_calibration_dossier_uuid` PK;
- `scope_type` = target | calendar;
- `calibration_kind` = cadence | sla_rule | sla_calendar;
- `target_product_version_uuid` opcional;
- `target_investigation_version_uuid` opcional;
- `calendar_key` opcional;
- `update_risk_profile_uuid` opcional;
- `baseline_update_policy_uuid` opcional;
- `clock_code` opcional;
- `data_window_start` opcional;
- `data_window_end` opcional;
- `decision_status` =
  - draft;
  - approved_for_normative_activation;
  - provisional_requires_reassessment;
  - capacity_conflict;
  - insufficient_evidence;
  - rejected;
- `rationale`;
- `created_by`;
- `actor_type`;
- `created_at`;
- `decided_at` opcional;
- `record_status` = active | superseded;
- `supersedes_temporal_calibration_dossier_uuid` opcional.

Regras:

### target scope

- exatamente um target ProductVersion/InvestigationVersion;
- `calendar_key` NULL;
- `calibration_kind` ∈ cadence | sla_rule;
- `update_risk_profile_uuid` obrigatório;
- profile deve apontar para o exact target;
- profile deve ser authoritative para aprovação normativa;
- `clock_code` obrigatório somente para `sla_rule`;
- baseline UpdatePolicy, se existir, deve apontar para o mesmo exact target.

### calendar scope

- targets NULL;
- `calendar_key` não vazio;
- `calibration_kind = sla_calendar`;
- risk profile, baseline policy e clock NULL.

Lifecycle:

- draft → exatamente um estado terminal;
- estado terminal não retorna a draft;
- correção/recalibração substantiva = novo dossier;
- supersession preserva a mesma família de scope/calibration_kind; mudança de target/calendar é novo dossier causal.

---

## 4. Approval não é um único campo de ator

Um dossier approved não será autorizado apenas pelo criador do header.

Criar:

### maintenance.temporal_calibration_authority

Campos:

- `temporal_calibration_dossier_uuid` FK;
- `authority_domain` =
  - scientific_methodological;
  - operational_feasibility;
- `actor`;
- `actor_type`;
- `verification_status`;
- `verified_by`;
- `verifier_actor_type`;
- `verified_at`;
- `rationale`;
- `decided_at`;
- PK dossier + authority_domain.

Para target dossier approved:

- scientific_methodological obrigatório;
- ator human_reviewer | human_expert;
- human_verified | human_consensus;
- operational_feasibility obrigatório;
- ator owner;
- owner pode permanecer unverified ou possuir verificação humana válida.

Para calendar dossier approved:

- operational_feasibility/owner obrigatório;
- scientific_methodological não é exigido por default.

AI/system:

> não pode preencher autoridade final.

Child rows são imutáveis.

---

## 5. maintenance.temporal_calibration_basis

Base estruturada do dossier.

Campos:

- `temporal_calibration_basis_uuid` PK;
- `temporal_calibration_dossier_uuid` FK;
- `envelope_domain` =
  - need;
  - source_reality;
  - feasibility;
  - external_constraint;
- `basis_type` =
  - oes_empirical;
  - source_characteristic;
  - external_normative;
  - methodological_evidence;
  - governance_decision;
- `basis_role` = supporting | controlling | counterevidence;
- locators opcionais:
  - artifact_uuid;
  - entity_version_uuid;
  - monitor_cycle_uuid;
  - update_signal_uuid;
  - workflow_round_uuid;
  - sla_instance_uuid;
  - update_risk_profile_uuid;
  - priority_assessment_uuid;
- `observed_from` opcional;
- `observed_to` opcional;
- `basis_payload` JSONB;
- `rationale`;
- `created_by`;
- `actor_type`;
- `recorded_at`.

Regra:

> exatamente um locator estruturado por row.

Normative approved dossier:

- external_normative/methodological/governance material deve possuir Artifact/EntityVersion ou outro locator versionado compatível;
- URI nua não é locator normativo suficiente;
- `basis_payload` é evidência/metadata, nunca fonte autoritativa do valor selecionado.

---

## 6. maintenance.temporal_calibration_candidate

Registra candidatos comparados.

Campos:

- `temporal_calibration_candidate_uuid` PK;
- dossier FK;
- `candidate_no` integer > 0;
- `candidate_kind` = cadence | sla_rule | sla_calendar;
- `candidate_payload` JSONB;
- `disposition` =
  - considered;
  - dominated;
  - source_ineffective;
  - infeasible;
  - rejected;
  - selected;
- `rationale`;
- `recorded_at`.

UNIQUE dossier + candidate_no.

O payload será validado por:

> `maintenance.temporal_calibration_candidate_payload_is_valid(kind,payload)`

O candidate payload é **analítico**, não normativo.

Dossier `approved_for_normative_activation`:

- exatamente um candidate selected;
- candidate_kind deve casar com calibration_kind.

Dossier `capacity_conflict | insufficient_evidence | rejected`:

- nenhum selected candidate.

---

## 7. maintenance.temporal_calibration_evaluation

Representa replay/stress/sensitivity.

Campos:

- `temporal_calibration_evaluation_uuid` PK;
- candidate FK;
- `evaluation_type` =
  - historical_replay;
  - stress_scenario;
  - sensitivity_analysis;
  - source_latency_analysis;
  - capacity_analysis;
- `result_status` =
  - acceptable;
  - dominated;
  - source_ineffective;
  - infeasible;
  - indeterminate;
- `metrics_payload` JSONB;
- `result_artifact_uuid` opcional;
- `rationale`;
- `evaluated_at`.

Não existe score universal.

Approved dossier requer evidência de:

- replay ou justificativa explícita de impossibilidade;
- feasibility evaluation;
- quando aplicável, source latency evaluation.

---

# PARTE C — CADENCE NORMALIZADA

## 8. Regra de fonte de verdade

`UpdatePolicy.cadence_mode` continua canônico para o modo geral.

Valores temporais e obrigações futuras:

> **não serão mantidos como verdade primária em JSON aberto.**

Criar contrato normalizado independente, criado antes da policy que o vincular.

---

## 9. maintenance.cadence_contract

Campos:

- `cadence_contract_uuid` PK;
- exact target ProductVersion/InvestigationVersion;
- `temporal_calibration_dossier_uuid` FK;
- `cadence_mode` = event_driven | periodic | hybrid | continuous;
- `governing_monitor_product_version_uuid` opcional;
- `effective_at`;
- `created_by`;
- `actor_type`;
- `record_status`;
- `supersedes_cadence_contract_uuid` opcional.

Regras:

- dossier deve ser `approved_for_normative_activation`;
- dossier calibration_kind = cadence;
- exact target igual;
- dossier selected candidate deve corresponder ao snapshot do contract;
- M2/M3 exige Monitor current/coerente com target;
- M0 não possui CadenceContract;
- continuous é representável, mas permanece não operacional enquanto M3 estiver bloqueado;
- supersession preserva exact target.

CadenceContract é imutável; correção = supersede + append.

---

## 10. UpdatePolicy binding

Adicionar futuramente a:

`maintenance.update_policy`

- `cadence_contract_uuid` nullable FK.

Consistency:

- contract target = policy target;
- contract cadence_mode = policy cadence_mode;
- contract Monitor = policy governing Monitor;
- `cadence_mode='none'` exige contract NULL.

Para policy sujeita ao epoch novo e cadence_mode != none:

> contract obrigatório.

Grandfathering usa `effective_at < contract_epoch.effective_at`.

O existing `cadence_policy_payload` passa a ser:

> **canonical snapshot do CadenceContract**, não segunda fonte de verdade.

Helper:

> `maintenance.cadence_contract_snapshot(cadence_contract_uuid)`

Para policy pós-epoch:

> `cadence_policy_payload = cadence_contract_snapshot(...)`.

---

## 11. maintenance.cadence_obligation

Cada CadenceContract possui uma ou mais obrigações.

Campos:

- `cadence_obligation_uuid` PK;
- `cadence_contract_uuid` FK;
- `obligation_code`;
- `scope_type` =
  - policy_aggregate;
  - monitor_source_name;
  - monitor_source_class;
  - source_definition_artifact;
- `source_name` opcional;
- `source_class` opcional;
- `source_definition_artifact_uuid` opcional;
- `timing_mode` =
  - event_driven;
  - fixed_elapsed;
  - calendar_recurrence;
  - hybrid;
- `fixed_elapsed_interval` opcional;
- `recurrence_count` opcional;
- `recurrence_unit` = day | week | month opcional;
- `anchor_type` =
  - policy_effective_at;
  - fixed_timestamp;
  - last_satisfaction;
  - event_occurrence;
- `fixed_anchor_at` opcional;
- `timezone_name` opcional;
- `dst_resolution_policy` opcional;
- `grace_interval` opcional;
- `event_channel_code` opcional;
- `satisfaction_event_type` =
  - monitor_cycle_completed;
  - search_execution;
  - evidence_event;
  - update_signal;
  - artifact_attestation;
- `effective_at`.

Constraints:

### event_driven

- recurrence fields NULL;
- event_channel_code obrigatório;
- anchor event/policy coerente.

### fixed_elapsed

- interval > 0;
- interval sem months;
- recurrence_count/unit NULL.

### calendar_recurrence

- recurrence_count > 0;
- recurrence_unit obrigatório;
- timezone obrigatório;
- DST policy obrigatória;
- fixed_elapsed_interval NULL.

### hybrid

- event_channel obrigatório;
- fallback recurrence definida por fixed_elapsed ou calendar recurrence.

Grace:

- >= 0;
- sem months;
- não pode substituir recurrence.

Source scope:

- exatamente um shape;
- Monitor source name/class só é válido com governing Monitor;
- quando usado, deve existir no `MonitorDefinition.source_policy_payload`;
- source_definition_artifact exige Artifact active;
- policy_aggregate não possui locator.

UNIQUE contract + obligation_code.

---

## 12. DST policy de cadence

Domínio v0.1:

- `shift_forward_to_first_valid`;
- `earliest_occurrence_on_fold`.

Calendar recurrence deve produzir um único instante.

Test vectors obrigatórios para timezone com DST.

---

## 13. maintenance.cadence_observation

Ledger de execução/satisfação; não é scheduler.

Campos:

- `cadence_observation_uuid` PK;
- obligation FK;
- `occurrence_no` opcional;
- `outcome` =
  - satisfied;
  - partial;
  - failed;
  - unavailable;
- `observed_at`;
- locators:
  - monitor_cycle_uuid;
  - search_uuid;
  - evidence_event_uuid;
  - update_signal_uuid;
  - artifact_uuid;
- `observed_by`;
- `actor_type`;
- `rationale`;
- `recorded_at`.

Regras:

- exatamente um locator;
- locator type compatível com `satisfaction_event_type`;
- satisfied precisa provar scope;
- partial/failed/unavailable não avançam a recorrência;
- recurring obligation usa occurrence_no;
- event-only observation não usa occurrence_no;
- ledger imutável.

Isso permite M1 periodic/hybrid sem fabricar MonitorCycle.

---

## 14. Cadence helpers

Especificar:

- `cadence_occurrence_due_at(obligation_uuid,occurrence_no)`;
- `cadence_next_due_at(obligation_uuid,as_of)`;
- `cadence_observation_status(observation_uuid)`;
- `cadence_obligation_status(obligation_uuid,as_of)`;
- `cadence_contract_issues(contract_uuid)`;
- `cadence_policy_readiness(update_policy_uuid)`.

Estados derivados mínimos:

- event_channel_only;
- not_started;
- not_due;
- due;
- in_grace;
- overdue;
- satisfied_on_time;
- satisfied_late;
- unavailable.

Fixed anchor:

> execução tardia não move a sequência.

Rolling/last_satisfaction:

> próxima due deriva da satisfação anterior.

Nenhum helper cria cycle/signal/escalation.

---

# PARTE D — SLA CALIBRADA

## 15. SLACalendarVersion provenance

Adicionar futuramente a `maintenance.sla_calendar_version`:

- `temporal_calibration_dossier_uuid` nullable FK.

Para calendar version pós-epoch:

- dossier obrigatório;
- scope calendar;
- matching calendar_key;
- approved_for_normative_activation;
- owner authority.

Calendar antigo é grandfathered.

---

## 16. Calendar payload hardening

`sla_calendar_payload_is_valid()` deverá exigir, para v0.1:

- weekly keys 1–7 explícitas;
- arrays de intervals ordenados;
- sem overlap;
- `start < end`;
- interval não cruza meia-noite; dividir em dois dias;
- exception date parseável;
- dates únicas;
- closed sem intervals;
- custom com intervals válidos/não sobrepostos;
- timezone existente em `pg_timezone_names`.

Sem seed de calendário real.

---

## 17. Fixed-duration helper

Criar:

> `maintenance.temporal_fixed_interval_is_valid(interval)`

Regras:

- > 0;
- months = 0;
- duração convertível deterministicamente a segundos.

Elapsed SLA e grace temporal usam duração fixa em segundos, não mês civil implícito.

---

## 18. maintenance.fixed_deadline_source

Fonte estruturada para fixed deadline.

Campos:

- `fixed_deadline_source_uuid` PK;
- `temporal_calibration_dossier_uuid` FK;
- `source_type` =
  - external_rule;
  - entity_version;
  - artifact;
  - manual_governance;
- locators:
  - source_entity_version_uuid;
  - source_artifact_uuid;
- `time_precision` = timestamp | date;
- `deadline_at` opcional;
- `deadline_date` opcional;
- `timezone_name` opcional;
- `date_boundary_policy` =
  - none;
  - end_of_local_date;
- `rationale`;
- `recorded_at`.

Regras:

- entity_version → exact entity locator;
- external_rule/artifact/manual_governance → Artifact active;
- timestamp precision → deadline_at only, boundary none;
- date precision → deadline_date only;
- date precision não é executável como SLA até existir timezone + boundary policy explicitamente aprovada no dossier;
- no invented timestamp.

---

## 19. SLARule extensions

Adicionar futuramente a `maintenance.sla_rule`:

- `temporal_calibration_dossier_uuid` nullable FK;
- `fixed_deadline_source_uuid` nullable FK.

Para rule pós-epoch:

- dossier obrigatório;
- dossier approved;
- calibration_kind=sla_rule;
- target do dossier = target da UpdatePolicy;
- clock_code igual;
- selected candidate compatível;
- fixed deadline exige source;
- elapsed/business calendar não pode ter fixed deadline source.

Existing rule é grandfathered pelo effective_at.

---

## 20. Filter-domain hardening

Adicionar checks/validator para:

### trigger_class_filter

- new_evidence;
- integrity_validity;
- safety_regulatory;
- temporal_operational;
- governance_demand;
- methodological;
- scope.

### decision_type_filter

- no_scientific_update;
- observe;
- currentness_only;
- scientific_update_incremental;
- scientific_update_broad;
- reroute_method;
- suspend_current_use.

### materiality_outcome_filter

- no_material_change;
- potentially_material;
- material_change_confirmed;
- validity_or_use_threat;
- insufficient_to_decide.

Não inventar round_type_filter.

Se análise futura demonstrar heterogeneidade material:

> nova decisão física explícita.

---

## 21. Canonical clock start

Criar:

> `maintenance.sla_clock_start_context(signal_uuid,clock_code,workflow_round_uuid)`

Retorna deterministicamente:

- start_at;
- causal triage/materiality/decision/round;
- response-class PriorityAssessment aplicável antes de start;
- source_detected_at/pre-policy age quando aplicável.

Priority selection:

- somente authoritative;
- `assessed_at <= start_at`;
- mais recente por assessed_at/recorded_at/UUID;
- breach posterior nunca participa da seleção da instance existente.

---

## 22. Canonical SLARule resolver

Criar:

> `maintenance.resolve_sla_rule(signal_uuid,clock_code,workflow_round_uuid,endpoint_type)`

O resolver:

1. deriva UpdatePolicy;
2. deriva start context;
3. deriva signal_class/trigger_class;
4. deriva materiality/decision context disponível naquele clock;
5. deriva response_class pré-start;
6. filtra rules da exact policy + clock;
7. valida filtros contra domínios;
8. ordena `selection_precedence ASC`;
9. primeira rule que casa vence;
10. detecta ausência/ambiguidade;
11. gera selection trace.

Caller não fornece response_class/materiality/decision_type arbitrários.

---

## 23. Canonical rule snapshot

Criar:

> `maintenance.sla_rule_snapshot(rule_uuid,context)`

Snapshot mínimo:

- rule UUID;
- UpdatePolicy UUID;
- target version;
- clock;
- filters;
- precedence;
- endpoint;
- time basis;
- duration/deadline;
- CalendarVersion;
- pause policy;
- warning policy;
- breach policy;
- escalation policy;
- start PriorityAssessment;
- Calibration Dossier;
- selection trace.

`SLAInstance.rule_snapshot_payload` deve ser igualdade estrita ao snapshot para rules pós-epoch.

---

## 24. Business-calendar arithmetic

Criar:

- `sla_calendar_open_seconds_between(calendar_uuid,start_at,end_at)`;
- `sla_calendar_add_open_seconds(calendar_uuid,start_at,seconds)`.

Requisitos:

- timezone-aware;
- weekly schedule;
- exceptions;
- start fora da janela;
- interval cruzando dias;
- DST;
- deterministic test vectors;
- não usar cálculo externo opaco.

Target duration business-calendar:

> convertida a segundos por fixed-duration helper e consumida somente dentro de janelas abertas.

---

## 25. Canonical nominal due

Criar:

> `maintenance.sla_nominal_due_at(rule_uuid,start_at)`.

### elapsed_time

- start + fixed seconds.

### business_calendar

- `sla_calendar_add_open_seconds`.

### fixed_deadline timestamp

- deadline_at.

### fixed_deadline date

Somente executável se o approved dossier tiver autorizado:

- timezone;
- `date_boundary_policy=end_of_local_date`.

O timestamp produzido é:

> transformação normativa explícita, não timestamp alegadamente presente na fonte.

Sem boundary policy:

> `FIXED_DEADLINE_DATE_PRECISION_NOT_EXECUTABLE`.

---

## 26. SLAInstance hardening

Para rule pós-epoch:

- resolver result deve igual `sla_rule_uuid`;
- `start_at` deve igual canonical start;
- `start_priority_assessment_uuid` deve igual snapshot pré-start;
- `rule_snapshot_payload` deve igual canonical snapshot;
- `nominal_due_at` deve igual `sla_nominal_due_at()`.

Caller não escolhe due arbitrariamente.

---

## 27. Warning/breach/escalation payload schemas

Para rules pós-epoch, fechar os JSONs.

### warning_policy_payload

Shape:

- schema_version;
- mode = none | lead_time;
- lead_seconds quando lead_time.

Constraints:

- integer > 0;
- para duration SLA, lead < target duration;
- warning não altera due.

### breach_policy_payload

Shape:

- schema_version;
- mode = at_effective_due.

Breach ocorre no effective due.

### escalation_policy_payload

Shape:

- schema_version;
- mode = none | post_breach_candidate;
- after_breach_seconds quando candidate;
- reason_code permitido, baseline `operational_delay`.

Não cria escalation automaticamente.

---

## 28. Pause policy closure

O gate metodológico não autorizou capacity laundering.

Para rule pós-epoch:

### pause_policy_payload

Shape:

- schema_version;
- mode = none | allowed_reasons;
- allowed_reason_codes array.

Reason codes limitados ao domínio atual de `sla_pause`.

`pause_allowed=false` → mode none.

`pause_allowed=true` → allowed_reasons não vazio.

Capacity/backlog continua sem reason code de pause.

---

## 29. SLA pause arithmetic hardening

Adicionar futuramente a `sla_pause`:

- `counts_toward_due` boolean.

Prospectivo:

- pause iniciado antes do effective due e antes de first breach → true;
- pause iniciado após first breach/effective breach boundary → false;
- overlap entre pauses da mesma instance é proibido;
- fixed deadline continua não-pausável.

`sla_effective_due_at()`:

### elapsed_time

- soma somente wall duration de pauses com counts_toward_due=true.

### business_calendar

- soma somente **open-calendar seconds** dentro dos pauses elegíveis;
- não soma fins de semana/closed windows duas vezes.

### fixed_deadline

- nenhuma extensão.

Pause pós-breach:

> nunca apaga first breach nem move o due histórico.

---

# PARTE E — READINESS

## 30. maintenance.temporal_calibration_dossier_issues

Erros mínimos:

- target/scope mismatch;
- risk profile não authoritative/exact target;
- authority incompleta;
- basis insuficiente;
- selected candidate cardinality;
- candidate kind mismatch;
- missing feasibility evaluation;
- external controlling basis sem locator forte;
- temporal order/supersession mismatch.

---

## 31. maintenance.temporal_policy_readiness

Para UpdatePolicy:

- cadence contract presente quando requerido pelo epoch;
- exact target/mode/Monitor;
- approved dossier;
- obligations completas;
- source scopes válidos;
- payload snapshot coerente;
- continuous/M3 sempre blocker.

---

## 32. maintenance.sla_rule_readiness

Para SLARule:

- approved dossier;
- exact target/clock;
- filter domains;
- deterministic temporal basis;
- calendar effective window;
- fixed deadline lineage;
- payload schemas;
- resolver eligibility;
- snapshot serializer;
- due calculator.

---

## 33. maintenance.temporal_operational_readiness

Agrega, por UpdatePolicy:

- temporal policy readiness;
- SLA readiness para clocks configurados;
- calendar readiness;
- issue codes de calibration.

Não equivale a:

- currentness;
- assurance;
- publication readiness;
- M3 readiness.

M3 sempre inclui:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

---

# PARTE F — GRANDFATHERING

## 34. Prospective enforcement

Regras existentes anteriores ao epoch:

- preservadas;
- não recebem dossier fabricado;
- não recebem calendar provenance fabricada;
- não recebem candidate/replay inventado;
- não são reescritas para aparentar compliance com v0.1.

Post-epoch:

- novos calibrated cadence contracts/rules/calendars devem satisfazer o contrato.

Rebuild:

> deve reproduzir o mesmo grandfathering por effective_at, não pela hora em que fixture é inserida.

---

# PARTE G — TEST PLAN

## 35. F4-TCAL-PH-T01–T180

Plano mínimo futuro.

### T01–T20 — Contract epoch / dossier

- epoch idempotente;
- target/calendar scope XOR;
- exact target profile;
- lifecycle;
- supersession;
- no AI final authority.

### T21–T40 — Authority/basis/candidates

- dual authority;
- owner B5/feasibility domain;
- locator XOR;
- no bare URI controlling basis;
- selected cardinality;
- no selected on capacity conflict;
- replay/sensitivity evidence.

### T41–T75 — Cadence contract

- policy/target/mode match;
- M0 no contract;
- M2/M3 Monitor coherence;
- scope validators;
- timing modes;
- fixed interval no months;
- calendar recurrence;
- DST vectors;
- grace;
- snapshot equality.

### T76–T95 — Cadence observations

- locator/event compatibility;
- source scope proof;
- occurrence numbering;
- fixed anchor late execution;
- rolling anchor;
- hybrid fallback;
- historical satisfied_late.

### T96–T115 — Calendar/fixed deadline

- timezone;
- all weekdays;
- overlap rejection;
- exception uniqueness;
- DST;
- fixed source locator;
- date precision boundary;
- effective-window.

### T116–T140 — SLA resolver/snapshot

- filter domains;
- resolver precedence;
- fallback;
- no caller spoofing;
- pre-start Priority snapshot;
- clock-specific context;
- canonical snapshot equality.

### T141–T160 — Due/pause

- elapsed due;
- business-calendar due;
- fixed deadline;
- date boundary;
- pause open seconds;
- overlap rejection;
- post-breach non-extension;
- first breach preservation.

### T161–T175 — payload/readiness

- warning;
- breach;
- escalation candidate only;
- pause reasons;
- policy readiness;
- rule readiness;
- no currentness/assurance mutation.

### T176–T180 — blockers

- M3 blocker;
- scheduler absent;
- notifications absent;
- no normative seed;
- grandfathering without fabricated backfill.

---

# PARTE H — CANDIDATE MIGRATION SCOPE

## 36. Eventual migration 032, se autorizada

Nome candidato:

`database/032_temporal_calibration_prerequisites.sql`

Escopo possível:

1. contract epoch;
2. Calibration Dossier;
3. authority/basis/candidate/evaluation;
4. CadenceContract/Obligation/Observation;
5. UpdatePolicy cadence binding;
6. SLACalendar calibration linkage + validators;
7. FixedDeadlineSource;
8. SLARule calibration linkage/filter hardening;
9. resolver/snapshot/due/calendar helpers;
10. SLAInstance guards;
11. pause arithmetic hardening;
12. payload validators;
13. readiness helpers;
14. synthetic fixtures **sem valor normativo real**;
15. F4-TCAL-PH-T01–T180;
16. idempotency;
17. rebuild/regressions;
18. S5 integration.

---

## 37. Explicitamente proibido na migration 032

Mesmo se o gate físico autorizá-la:

- seed de cadence interval;
- seed de SLA duration;
- seed de grace;
- seed de warning lead;
- seed de post-breach threshold;
- calendário institucional real;
- criação de SLARule normativa real;
- criação de UpdatePolicy real calibrada;
- scheduler;
- notifications;
- auto-escalation;
- auto-currentness;
- assurance promotion;
- M3 unblock;
- fabricated human/expert/owner approval;
- fabricated historical calibration dossier.

---

# PARTE I — ESTADO

## 38. Estado do contrato

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = CANDIDATE_FOR_GATE**

> **F4_TCAL_PH_T01_T180 = CANDIDATE_MINIMUM_TEST_PLAN**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 39. Próximo passo exato

> **Executar gate adversarial/físico deste contrato, atacando dual truth, lifecycle do dossier, authority, cadence recurrence, source-scope proof, resolver SLA, date-only deadlines, calendar/DST arithmetic, pause extension, grandfathering e risco de automação implícita.**


---

# PARTE J — HARDENING PÓS-DOCUMENTO 42

## 40. Dossier decision recorder e completeness deferred

Adicionar ao `temporal_calibration_dossier`:

- `decision_recorded_by` opcional;
- `decision_actor_type` opcional.

Enquanto `decision_status='draft'`:

- decision recorder NULL;
- decided_at NULL.

Na única transição draft → terminal:

- decision_recorded_by obrigatório;
- decision_actor_type ∈ human_reviewer | human_expert | owner;
- decided_at obrigatório;
- filhos necessários devem estar completos.

Criar constraint trigger:

> `assert_temporal_calibration_dossier_complete()`

DEFERRABLE INITIALLY DEFERRED.

Estados terminais permanecem imutáveis; nova calibração = novo dossier/supersession.

---

## 41. External applicability authority

Expandir `authority_domain`:

- scientific_methodological;
- operational_feasibility;
- external_applicability.

Approved dossier com `external_normative + controlling` exige authority row external_applicability.

A row deve registrar:

- compatibilidade do target/context;
- compatibilidade do start;
- compatibilidade do endpoint;
- precision/timezone;
- resolução de conflito com outras constraints.

AI/system não pode ser authority final.

---

## 42. Candidate schemas fechados

Selected candidate payloads têm schemas explícitos, sem keys extras.

### cadence_candidate/0.1

Top-level:

- schema_version;
- cadence_mode;
- effective_at;
- governing_monitor_product_version_uuid opcional;
- obligations array ordenado por obligation_code.

Cada obligation contém apenas:

- obligation_code;
- scope;
- timing;
- anchor;
- grace_seconds;
- event_channel_code quando event-driven;
- satisfaction_event_type;
- timezone/dst/month-roll quando calendar recurrence.

### sla_rule_candidate/0.1

Top-level:

- schema_version;
- clock_code;
- selection_precedence;
- filters;
- endpoint_type;
- time_basis;
- target_duration_seconds opcional;
- sla_calendar_version_uuid opcional;
- fixed_deadline_source_snapshot opcional;
- pause_policy;
- warning_policy;
- breach_policy;
- escalation_policy;
- effective_at.

### sla_calendar_candidate/0.1

Top-level:

- schema_version;
- calendar_key;
- timezone_name;
- weekly_schedule;
- exception_dates;
- effective_from;
- effective_to opcional.

Validators:

- rejeitam keys extras;
- validam tipos/domínios;
- não autorizam valores só porque o JSON é válido.

---

## 43. Exact selected-candidate equality

Criar serializers canônicos:

- `cadence_contract_calibration_snapshot(cadence_contract_uuid)`;
- `sla_rule_calibration_snapshot(sla_rule_uuid)`;
- `sla_calendar_calibration_snapshot(sla_calendar_version_uuid)`.

Normative object pós-v0.1:

> snapshot = selected candidate payload.

Comparação usa JSONB equality após serializer canônico.

UUIDs técnicos do próprio objeto, created_at e audit fields não entram no calibration snapshot.

---

## 44. Risk profile temporal validity

Approved target dossier exige:

- UpdateRiskProfile exact target;
- authority_status=authoritative;
- `profile.assessed_at <= dossier.decided_at`;
- `profile.effective_at <= dossier.decided_at`.

Profile superseded após a decisão não invalida retrospectivamente o dossier.

---

## 45. CadenceContract / UpdatePolicy temporal alignment

Policy que vincula contract exige:

> `update_policy.effective_at = cadence_contract.effective_at`.

Também:

- dossier.decided_at <= contract.effective_at;
- contract target/mode/Monitor = policy target/mode/Monitor;
- UpdatePolicy append-preserving guard inclui cadence_contract_uuid;
- cadence payload snapshot equality obrigatória.

Para M0:

- cadence_contract_uuid NULL;
- cadence_policy_payload = '{}'::jsonb no contrato v0.1.

---

## 46. Hybrid por composição

Remover `timing_mode=hybrid` de CadenceObligation.

CadenceObligation v0.1:

- event_driven;
- fixed_elapsed;
- calendar_recurrence.

CadenceContract:

### event_driven

- >=1 obligation event_driven;
- nenhuma recurring obligation.

### periodic

- >=1 recurring obligation;
- nenhuma event_driven obligation.

### hybrid

- >=1 event_driven obligation;
- >=1 recurring obligation.

Event observation e periodic occurrence mantêm identidades independentes.

---

## 47. Continuous não pertence ao CadenceContract v0.1

CadenceContract v0.1 aceita:

- event_driven;
- periodic;
- hybrid.

Não aceita continuous.

M3/continuous:

> depende de gate M3 futuro.

Isso evita objeto normativo que aparente readiness inexistente.

---

## 48. Recurrence anchors v0.1

Remover `event_occurrence`.

Recurring anchors:

- policy_effective_at;
- fixed_timestamp;
- last_satisfaction.

Event-driven obligation:

- não possui recurrence anchor;
- usa event_channel_code + observations.

---

## 49. Month-roll e DST

Calendar recurrence com `recurrence_unit='month'` exige:

> `month_roll_policy = preserve_day_or_clamp_last_day`.

Timezone recurrence exige:

`dst_resolution_policy`:

- shift_forward_to_first_valid;
- earliest_occurrence_on_fold.

Sem defaults implícitos.

---

## 50. Grace invariant

### fixed_elapsed

- `0 <= grace_interval < fixed_elapsed_interval`.

### calendar_recurrence

Para cada occurrence `n`:

> grace_seconds < due(n+1) - due(n).

O helper de occurrence deve recusar um occurrence cujo gap não satisfaça a invariável.

Não existe um threshold universal/horizon artificial.

---

## 51. Cadence attestation/source proof

`artifact_attestation + satisfied` exige:

- Artifact active;
- actor humano/owner;
- artifact_type permitido por policy/contract;
- rationale;
- prova do source scope declarado.

`update_signal` locator:

- permitido como satisfaction apenas para event_driven obligation;
- signal deve apontar para a mesma UpdatePolicy;
- primary source deve ser coerente com source scope.

Periodic polling:

> nunca é satisfeito apenas pela existência de UpdateSignal.

Search/MonitorCycle locators devem provar target/source consistency.

---

## 52. SLA causal filter matrix

Criar:

> `maintenance.sla_rule_filters_are_causally_valid(rule_uuid)`.

### SLA1

Permitidos:
- signal_class_filter;
- trigger_class_filter.

Devem ser NULL:
- response_class_filter;
- materiality_outcome_filter;
- decision_type_filter.

### SLA2

Permitidos:
- signal_class;
- trigger_class;
- response_class disponível até start.

Devem ser NULL:
- materiality_outcome;
- decision_type.

### SLA3

Permitidos:
- signal_class;
- trigger_class;
- response_class pré-start;
- materiality_outcome.

decision_type deve ser NULL.

### SLA4–SLA6

Todos os filtros atuais podem ser usados, desde que o fato existisse no contractual start.

Nenhuma rule pode selecionar usando futuro.

---

## 53. Historical/as-of SLARule set

Criar:

> `maintenance.sla_rule_effective_until(rule_uuid)`.

Para cada rule_code lineage:

- início = rule.effective_at;
- fim = effective_at da próxima rule que supersede essa lineage;
- intervalo = [start,end).

`record_status='superseded'` não remove validade histórica.

Resolver as-of usa rows cuja effective window contém o instante relevante.

---

## 54. Raw causal start e eligibility

Separar:

### raw_causal_start_at

Derivado exclusivamente do evento causal do clock.

### contractual_start_at

Algoritmo:

1. derive raw causal start;
2. derive UpdatePolicy eligibility;
3. encontre rule-set temporal elegível;
4. contractual start = primeiro instante >= raw start em que policy + uma rule aplicável coexistem;
5. derive filter context usando somente fatos existentes até esse instante;
6. resolva por precedence.

Pre-policy age:

> raw causal start é preservado em source_detected_at/pre_policy_age.

Sem rule elegível:

> não criar breach retroativo.

---

## 55. Resolver result explícito

`resolve_sla_rule(...)` retorna estrutura:

- resolution_status;
- sla_rule_uuid opcional;
- raw_causal_start_at;
- contractual_start_at;
- start_priority_assessment_uuid opcional;
- selection_trace.

`resolution_status`:

- selected;
- not_configured;
- no_matching_rule;
- ambiguous_invalid.

Ausência de rule:

> nunca significa not_applicable.

---

## 56. Date-only fixed deadline

`date_boundary_policy` não tem default.

Date precision executável exige:

- deadline_date;
- timezone_name;
- explicit boundary policy;
- selected candidate contendo essa transformação;
- external_applicability/governance rationale quando aplicável.

Sem transformação aprovada:

> `FIXED_DEADLINE_DATE_PRECISION_NOT_EXECUTABLE`.

---

## 57. Calendar arithmetic reversa

Adicionar:

> `sla_calendar_subtract_open_seconds(calendar_uuid,end_at,seconds)`.

Deve ser inversa consistente de add_open_seconds nos test vectors aplicáveis.

Usada para warnings em same_as_sla/business-calendar.

---

## 58. Warning time basis

warning_policy/0.1:

- schema_version;
- mode = none | lead_time;
- time_basis = elapsed_time | same_as_sla quando lead_time;
- lead_seconds integer > 0.

### same_as_sla

- elapsed SLA → wall seconds;
- business-calendar SLA → subtract_open_seconds;
- fixed deadline → wall seconds, salvo regra externa/calendário explicitamente modelado em versão futura.

Warning não move due.

---

## 59. Post-breach escalation time basis

escalation_policy/0.1:

- schema_version;
- mode = none | post_breach_candidate;
- time_basis = elapsed_time | same_as_sla quando candidate;
- after_breach_seconds integer >= 0;
- reason_code = operational_delay na baseline.

same_as_sla/business-calendar usa open-calendar seconds após breach.

Ainda:

> não abre EscalationCase automaticamente.

---

## 60. Business-calendar pause extension

Para rule business_calendar:

1. compute `paused_open_seconds` somente em intervals elegíveis;
2. effective due =
   `sla_calendar_add_open_seconds(calendar, nominal_due_at, paused_open_seconds)`.

Nunca:

> nominal_due + wall pause duration.

---

## 61. Pause overlap e due_extension_eligible

Renomear campo proposto:

> `due_extension_eligible`.

O caller não controla seu valor.

Trigger deriva no INSERT:

true somente se:

- rule permite pause;
- pause.started_at < effective due calculado antes do novo pause;
- first_breached_at IS NULL;
- não há overlap.

Caso contrário:

- row pode ser registrada quando governance permitir;
- due_extension_eligible=false;
- não move due.

Overlap temporal entre rows válidas da mesma SLAInstance é erro.

---

## 62. Grandfathering não usa backdating

Criar:

### maintenance.temporal_contract_grandfathered_object

Campos:

- `object_type` =
  - update_policy;
  - sla_rule;
  - sla_calendar_version;
- `object_uuid`;
- `grandfathered_at`;
- `migration_id` = 032;
- `reason_code` = pre_v01_existing_row;
- PK object_type + object_uuid.

Migration 032, se autorizada:

> snapshot técnico dos objetos fisicamente existentes naquele momento.

Isso:

- não cria aprovação;
- não cria dossier;
- não cria evidência histórica;
- não reescreve rule.

Nova row após migration:

> não pode virar legacy apenas backdating effective_at.

Rebuild-from-zero:

- migration 032 ocorre antes das fixtures novas;
- fixtures sintéticas devem ser atualizadas para cumprir v0.1;
- não inserir grandfather rows falsos para fixtures posteriores.

---

## 63. Calendar effective window

Business-calendar SLARule v0.1:

- `calendar.effective_from <= rule.effective_at`;
- se effective_to não NULL, `rule.effective_at < effective_to`.

SLAInstance congela a CalendarVersion da rule/snapshot.

Supersession posterior do calendar não recalcula instance.

---

## 64. Calendar candidate equality

CalendarVersion pós-v0.1:

> `sla_calendar_calibration_snapshot(calendar_uuid) = selected candidate payload`.

Timezone/schedule/exceptions/effective window devem coincidir.

---

## 65. Grandfather-aware enforcement

Helpers:

- `temporal_object_is_grandfathered(type,uuid)`;
- `temporal_contract_v01_applies(type,uuid)`.

Novo contract enforcement:

- grandfathered object → legacy semantics preservadas;
- não-grandfathered object → v0.1 obrigatório.

Nenhuma comparação usa apenas effective_at para decidir grandfathering.

---

## 66. Test plan revisado

> **F4-TCAL-PH-T01–T210**

Adicionar aos testes já previstos:

- decision recorder/deferred completion;
- external_applicability;
- closed candidate schemas;
- candidate/object equality;
- profile temporal validity;
- exact policy/contract effective_at;
- hybrid composed obligations;
- continuous rejection;
- month-end recurrence;
- causal filter matrix;
- historical rule-set resolution;
- raw/contractual start;
- resolver failure statuses;
- date-only boundary;
- warning backward calendar arithmetic;
- escalation time basis;
- business pause extension;
- overlap/post-breach pause;
- backdated new object cannot evade v0.1;
- rebuild fixtures comply without fake grandfathering.

---

## 67. Estado após hardening

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = REVISED_READY_FOR_RECHECK**

> **F4_TCAL_PH_T01_T210 = CANDIDATE_MINIMUM_TEST_PLAN**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 68. Próximo passo exato

> **Reexecutar Documento 42. Somente PASS/PASS_WITH_ARCHITECTURAL_DECISIONS poderá autorizar migration 032 no escopo estrito de infraestrutura, sem valores normativos.**

