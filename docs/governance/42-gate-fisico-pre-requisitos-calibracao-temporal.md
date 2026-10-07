# 42 — Gate Adversarial/Físico dos Pré-requisitos de Calibração Temporal

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — primeira passagem física**  
**Dependência:** Documento 41  
**Objeto:** atacar o contrato físico antes de qualquer migration 032 ou valor normativo

---

## 1. Resultado da primeira passagem

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = REVISE**

> **F4_TCAL_PH_TEST_PLAN = REVISE**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

O desenho é viável, mas ainda possui ambiguidades que poderiam produzir dual truth, future leakage ou grandfathering indevido.

---

## 2. AR-F4-TCPH01 — lifecycle do dossier não registra quem decidiu

### Ataque

O header possui creator e decided_at, mas não quem materializou a decisão terminal.

### Decisão

Adicionar ao header:

- decision_recorded_by;
- decision_actor_type.

Transição draft → terminal:

- única;
- auditável;
- só após filhos necessários existirem;
- validada por constraint trigger deferred.

**Resultado:** REVISE_REQUIRED.

---

## 3. AR-F4-TCPH02 — external applicability sem authority explícita

### Ataque

Um basis external_normative controlling poderia dominar regra apenas com rationale.

### Decisão

Adicionar authority_domain:

> external_applicability

Quando houver external_normative controlling basis em dossier approved:

- external_applicability obrigatório;
- ator humano/owner qualificado conforme contexto;
- rationale de compatibilidade start/end/precision.

**Resultado:** REVISE_REQUIRED.

---

## 4. AR-F4-TCPH03 — candidate payload ainda aberto demais

### Ataque

O Documento 41 menciona validator, mas não fecha os shapes.

### Decisão

Especificar três schemas canônicos:

- cadence_candidate/0.1;
- sla_rule_candidate/0.1;
- sla_calendar_candidate/0.1.

Keys extras não autorizadas.

Selected candidate deve ser comparável deterministicamente ao objeto normativo futuro.

**Resultado:** PHYSICAL_BLOCKER.

---

## 5. AR-F4-TCPH04 — candidate selecionado ↔ objeto normativo

### Ataque

“Corresponder ao snapshot” não define equality.

### Decisão

Criar serializers:

- cadence_contract_calibration_snapshot();
- sla_rule_calibration_snapshot();
- sla_calendar_calibration_snapshot().

Normative object só é ready se:

> selected candidate payload = canonical calibration snapshot.

**Resultado:** REVISE_REQUIRED.

---

## 6. AR-F4-TCPH05 — risk profile temporal

### Ataque

Profile pode ser authoritative, mas posterior à data em que o dossier afirma ter sido decidido.

### Decisão

Approved target dossier exige:

- profile authoritative;
- exact target;
- profile.assessed_at <= dossier.decided_at;
- profile.effective_at <= dossier.decided_at.

Se profile já foi superseded depois, dossier histórico continua válido.

**Resultado:** REVISE_REQUIRED.

---

## 7. AR-F4-TCPH06 — CadenceContract effective_at e UpdatePolicy

### Ataque

Policy pode apontar para contract cuja vigência começa em outro instante.

### Decisão

Para policy bound:

> policy.effective_at = cadence_contract.effective_at.

Dossier decision deve preceder/igual contract effective_at.

UpdatePolicy append guard deve incluir cadence_contract_uuid.

**Resultado:** REVISE_REQUIRED.

---

## 8. AR-F4-TCPH07 — hybrid obligation mistura dois relógios

### Ataque

Uma row hybrid com event channel + periodic fallback torna ambíguo:

- occurrence numbering;
- satisfaction;
- anchor reset;
- overdue.

### Decisão

Remover timing_mode=hybrid da obrigação.

Hybrid existe apenas no CadenceContract:

> pelo menos uma obrigação event_driven + pelo menos uma obrigação recurring.

Obligation timing modes:

- event_driven;
- fixed_elapsed;
- calendar_recurrence.

**Resultado:** ARCHITECTURAL_REVISION_REQUIRED.

---

## 9. AR-F4-TCPH08 — continuous enquanto M3 bloqueado

### Ataque

Criar CadenceContract normative `continuous` pode ser interpretado como readiness M3.

### Decisão

CadenceContract v0.1 não aceita continuous.

UpdatePolicy/M3 histórico continua representável no schema antigo, mas:

> novo calibrated CadenceContract continuous só poderá ser desenhado após gate M3.

**Resultado:** REVISE_REQUIRED.

---

## 10. AR-F4-TCPH09 — event_occurrence anchor under-specified

### Ataque

Não há identidade física estável do evento âncora para recurrence.

### Decisão

Remover event_occurrence como anchor v0.1.

Recurring anchors:

- policy_effective_at;
- fixed_timestamp;
- last_satisfaction.

Event-driven usa observations/event channel, não recurrence anchor.

**Resultado:** REVISE_REQUIRED.

---

## 11. AR-F4-TCPH10 — monthly recurrence / month end

### Ataque

“1 mês” desde 29/30/31 é ambíguo.

### Decisão

Calendar recurrence com unit=month exige:

> month_roll_policy = preserve_day_or_clamp_last_day.

Sem implicit default.

**Resultado:** REVISE_REQUIRED.

---

## 12. AR-F4-TCPH11 — grace pode engolir cadence

### Ataque

Grace maior/igual à recurrence tornaria obrigação quase sem due útil.

### Decisão

Para fixed_elapsed:

> grace < recurrence.

Para calendar recurrence:

- helper deve comparar grace contra o menor intervalo entre duas occurrences consecutivas no horizon determinístico de validação;
- se não demonstrável, readiness error.

**Resultado:** REVISE_REQUIRED.

---

## 13. AR-F4-TCPH12 — artifact_attestation pode fabricar execução

### Ataque

Artifact qualquer poderia satisfazer cadence.

### Decisão

artifact_attestation satisfied exige:

- Artifact active;
- actor humano/owner;
- artifact_type elegível/documentado;
- rationale;
- não pode satisfazer monitor_source scope se não provar a source declarada.

UpdateSignal pode satisfazer somente event_driven obligation coerente com signal/source, nunca polling periódico por si só.

**Resultado:** REVISE_REQUIRED.

---

## 14. AR-F4-TCPH13 — filtros SLA podem usar informação futura

### Ataque

O schema atual permite materiality_outcome em SLA1 ou decision_type em SLA2.

Isso vaza fatos que só existem após o início do clock.

### Decisão

Adicionar matriz causal de filtros:

### SLA1

Permitidos:
- signal_class;
- trigger_class.

Proibidos:
- response_class;
- materiality_outcome;
- decision_type.

### SLA2

Permitidos:
- signal_class;
- trigger_class;
- response_class disponível até triage/start.

Proibidos:
- materiality_outcome;
- decision_type.

### SLA3

Permitidos:
- signal_class;
- trigger_class;
- response_class pré-start;
- materiality_outcome.

Proibido:
- decision_type.

### SLA4–SLA6

Permitidos:
- signal_class;
- trigger_class;
- response_class pré-start;
- materiality_outcome;
- decision_type.

**Resultado:** CRITICAL_REVISE_REQUIRED.

---

## 15. AR-F4-TCPH14 — resolver não tratou rule effective history

### Ataque

Resolver apenas rules “active” produziria erro em late normalization ou replay histórico.

### Decisão

Definir rule-set as-of:

- rule effective_at;
- same rule_code supersession;
- janela `[effective_at, next_superseding_effective_at)`.

Resolver deve usar regra válida no contractual start.

record_status atual não apaga validade histórica.

**Resultado:** CRITICAL_REVISE_REQUIRED.

---

## 16. AR-F4-TCPH15 — pre-policy age cria circularidade start ↔ rule

### Ataque

Clock raw start pode preceder policy/rule; mas rule selection depende de start.

### Decisão

Algoritmo em duas camadas:

1. derive `raw_causal_start_at` sem rule;
2. determine earliest eligible policy/rule instant >= raw start;
3. contractual start = max(raw causal start, policy effective_at, rule effective_at);
4. derive filter context only with facts available até contractual start;
5. resolver by precedence dentro do rule-set válido naquele instante.

Se nenhuma rule elegível:

> SLA_RULE_NOT_CONFIGURED, sem breach retroativo.

**Resultado:** ARCHITECTURAL_REVISION_REQUIRED.

---

## 17. AR-F4-TCPH16 — ausência de rule ≠ not_applicable

### Ataque

Sem regra, sistema poderia interpretar obrigação como não aplicável.

### Decisão

Resolver retorna estados distintos:

- selected;
- not_configured;
- no_matching_rule;
- ambiguous_invalid.

`not_applicable` continua pertencendo à SLAInstance, nunca inferido de ausência de rule.

**Resultado:** REVISE_REQUIRED.

---

## 18. AR-F4-TCPH17 — fixed deadline date-only

### Ataque

end_of_local_date pode virar default silencioso.

### Decisão

Date precision:

- boundary policy não possui default;
- timezone obrigatório;
- selected candidate deve incluir a transformação;
- external_applicability/governance rationale deve justificar;
- sem isso, não executável.

**Resultado:** PASS_WITH_HARDENING.

---

## 19. AR-F4-TCPH18 — warning business-calendar precisa operação reversa

### Ataque

warning lead não pode ser calculado por wall subtraction quando SLA usa business calendar.

### Decisão

Adicionar:

> `sla_calendar_subtract_open_seconds()`.

Warning payload passa a declarar:

- time_basis = elapsed_time | same_as_sla;
- lead_seconds.

same_as_sla + business-calendar usa subtract_open_seconds.

**Resultado:** REVISE_REQUIRED.

---

## 20. AR-F4-TCPH19 — post-breach escalation basis ambígua

### Ataque

“after N seconds” pode significar wall ou business time.

### Decisão

Escalation payload deve declarar:

- time_basis = elapsed_time | same_as_sla;
- after_breach_seconds.

Não existe default implícito.

**Resultado:** REVISE_REQUIRED.

---

## 21. AR-F4-TCPH20 — pause extension em business calendar

### Ataque

Somar open seconds como wall interval ao nominal due é incorreto.

### Decisão

Para business calendar:

1. calcular paused_open_seconds;
2. effective due =
   `sla_calendar_add_open_seconds(calendar, nominal_due, paused_open_seconds)`.

Open/closed time nunca é contado duas vezes.

**Resultado:** REVISE_REQUIRED.

---

## 22. AR-F4-TCPH21 — pause overlap / post-breach

### Ataque

Pauses sobrepostos duplicam extensão; pause tardio pode apagar breach não materializado.

### Decisão

- adicionar `due_extension_eligible`, derivado por trigger;
- não aceitar valor arbitrário do caller;
- new pause overlap proibido;
- elegível somente se started_at < effective due calculado antes do novo pause e first_breached_at NULL;
- pós-boundary pause pode ser registrado, mas não move due.

**Resultado:** REVISE_REQUIRED.

---

## 23. AR-F4-TCPH22 — grandfathering por effective_at é contornável

### Ataque

Nova row poderia ser inserida após migration 032 com effective_at backdated.

### Decisão

Grandfathering de produção:

> snapshot técnico explícito dos UUIDs existentes no momento da migration.

Criar:

`maintenance.temporal_contract_grandfathered_object`

Campos:

- object_type = update_policy | sla_rule | sla_calendar_version;
- object_uuid;
- grandfathered_at;
- migration_id = 032;
- razão técnica fixa.

Isso não cria calibration dossier nem aprovação retrospectiva.

Rebuild:

- não usar grandfathering fabricado;
- fixtures sintéticas posteriores à migration 032 devem ser adaptadas para cumprir v0.1.

**Resultado:** CRITICAL_REVISE_REQUIRED.

---

## 24. AR-F4-TCPH23 — calendar effective window

### Ataque

Calendar pode ser válido estruturalmente, mas não cobrir rule effective_at.

### Decisão

Business-calendar rule exige:

> calendar.effective_from <= rule.effective_at < effective_to, quando effective_to existir.

Instance congela CalendarVersion.

**Resultado:** PASS_WITH_HARDENING.

---

## 25. AR-F4-TCPH24 — calendar candidate ↔ CalendarVersion

### Ataque

Approved calendar dossier pode não corresponder ao payload efetivamente persistido.

### Decisão

`sla_calendar_calibration_snapshot(calendar_uuid)` deve igual selected candidate payload.

**Resultado:** REVISE_REQUIRED.

---

## 26. AR-F4-TCPH25 — open JSON não normativo

### Ataque

basis_payload/evaluation metrics são JSON.

### Decisão

Aceitável porque:

- não são objetos normativos;
- não alimentam due/cadence diretamente;
- selected candidate é schema-fechado;
- normative object exige exact snapshot equality.

**Resultado:** PASS.

---

## 27. AR-F4-TCPH26 — automação implícita

### Ataque

Cadence status/due helpers poderiam ser usados como scheduler de fato.

### Decisão

Helpers:

- somente leitura/derivação;
- não inserem Cycle, Signal, Escalation, Notification ou Task;
- nenhuma trigger temporal automática.

**Resultado:** PASS.

---

# PARTE B — HARDENING OBRIGATÓRIO

## 28. Documento 41 deve incorporar

1. decision recorder + deferred approval completeness;
2. external_applicability authority;
3. candidate schemas fechados;
4. canonical candidate/object snapshots;
5. profile temporal validity;
6. exact policy/contract effective_at;
7. hybrid por composição de obligations;
8. nenhum continuous CadenceContract v0.1;
9. remover event occurrence anchor;
10. month-roll policy;
11. grace/recurrence relation;
12. attestation/source proof;
13. causal filter matrix;
14. rule effective windows;
15. raw start → eligibility → contractual start;
16. distinct resolver failure states;
17. date-only no-default boundary;
18. calendar subtract helper;
19. warning/escalation time basis;
20. business pause extension;
21. overlap/post-breach pause guards;
22. explicit production grandfather registry;
23. calendar effective window;
24. calendar selected-candidate equality.

---

## 29. Test plan

Expandir para:

> **F4-TCAL-PH-T01–T210**

Novos testes devem cobrir explicitamente:

- causal filter availability;
- historical rule resolution;
- backdated new rule cannot evade v0.1;
- hybrid composed obligations;
- monthly month-end;
- warning subtraction;
- post-breach pause non-extension;
- rebuild without fabricated grandfathering.

---

## 30. Estado

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = REVISE**

> **F4_TCAL_PH_T01_T210 = CANDIDATE_AFTER_HARDENING**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 31. Próximo passo exato

> **Aplicar o hardening ao Documento 41 e reexecutar este gate. Migration 032 só poderá ser autorizada em escopo estrito após PASS/PASS_WITH_ARCHITECTURAL_DECISIONS.**
