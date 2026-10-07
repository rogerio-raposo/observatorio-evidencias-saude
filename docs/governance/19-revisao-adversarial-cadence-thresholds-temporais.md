# 19 — Revisão Adversarial da Política de Cadence e Thresholds Temporais

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS**  
**Objeto:** Documento 18 pós-hardening  
**Dependências:** Documentos 05–09 e 16–18; migrations 014, 021–022 e 027

---

## 1. Finalidade

Executar revisão adversarial da política temporal da Fase 4 antes de definir SLAs.

O gate verifica se cadence, cobertura, atraso e exceção podem ser usados sem:

- duplicar relógios existentes;
- transformar atraso em estado científico;
- criar Monitoring Cycle para M1;
- permitir schedule drift silencioso;
- apagar dívida operacional por supersessão;
- confundir MethodDecision com UpdateDecision;
- antecipar M3.

---

## 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Estado:

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

Autorizado:

> avançar para arquitetura de SLA.

Não autorizado:

- migration nova;
- duração universal;
- scheduler;
- auto-escalation;
- auto-currentness;
- M3 readiness.

---

## 3. AR-F4-T01 — quatro relógios

O modelo separa corretamente:

1. vigilância;
2. processamento;
3. reassessment de policy/profile;
4. atualização científica.

Nenhum deles será reutilizado como proxy silencioso de outro.

**Resultado:** PASS.

---

## 4. AR-F4-T02 — cadence × coverage

### Risco

Tratar ciclo atrasado como gap de evidência ou, inversamente, tratar execução pontual como garantia de cobertura.

### Decisão

Persistem estados independentes:

- schedule compliance;
- coverage continuity.

Casos válidos:

- late + fully covered;
- on-time + coverage gap;
- late + gap;
- on-time + fully covered.

**Resultado:** PASS.

---

## 5. AR-F4-T03 — M1 periódico

### Risco

M1 possui `cadence_mode='periodic'`, mas o contrato 027 proíbe governing Monitor.

Criar MonitoringCycle em M1 produziria “M2 sem Monitor”.

### Decisão

Em M1:

> periodic = reassessment periódico de elegibilidade/currentness/policy.

Pode resultar em:

- nenhuma ação;
- busca ad hoc;
- abertura de UpdateSignal;
- reroteamento;
- nova UpdatePolicy.

Não produz Monitoring Cycle por default.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 6. AR-F4-T04 — M2 periódico

Em M2:

> periodic = surveillance ativa prospectiva pelo Monitor governante.

Monitoring Cycle continua sendo a unidade física de execução.

**Resultado:** PASS.

---

## 7. AR-F4-T05 — planned_at

### Risco

Reinterpretar `monitor_cycle.planned_at` como deadline final.

A migration 021 já exige:

> `started_at >= planned_at`.

### Decisão

`planned_at` significa:

> instante nominal programado de início.

Limite superior sem atraso formal será conceito separado:

> `grace_until`.

Completion pertence a outro relógio.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 8. AR-F4-T06 — schedule anchor

Foram definidos:

- fixed_anchor;
- rolling_anchor;
- event_anchor.

### Regra

`fixed_anchor` é preferível quando a intenção é manter calendário estável.

`rolling_anchor` exige rationale explícita.

Atraso não pode deslocar silenciosamente a próxima obrigação.

**Resultado:** PASS.

---

## 9. AR-F4-T07 — early execution

### Risco

Executar antecipadamente e consumir automaticamente a obrigação futura.

### Decisão

No Monitor:

> started_at antes de planned_at permanece inválido.

Em futuros mecanismos não-Monitor:

> early fulfillment não é default.

Se permitido, exige regra prospectiva e não pode criar gap.

**Resultado:** PASS.

---

## 10. AR-F4-T08 — grace

Grace é tolerância operacional explícita.

Não:

- altera coverage window;
- altera currentness;
- redefine o schedule anchor;
- apaga atraso histórico.

**Resultado:** PASS.

---

## 11. AR-F4-T09 — overdue derivado

### Risco

Persistir boolean `overdue=true/false` e permitir estado stale.

### Decisão

Preferência arquitetural:

> calcular overdue a partir de regra + tempo + evidência de satisfação.

Incidentes/escalonamentos podem ser persistidos separadamente.

**Resultado:** PASS.

---

## 12. AR-F4-T10 — estados temporais

A arquitetura distingue:

- not_open;
- within_grace;
- satisfied_on_time;
- overdue;
- satisfied_late;
- escalation_overdue;
- suspended_by_authority;
- not_applicable.

Esses estados são operacionais.

Não equivalem a CurrencyState.

**Resultado:** PASS.

---

## 13. AR-F4-T11 — satisfied_late

Execução tardia:

- satisfaz a obrigação de execução;
- mantém histórico de atraso;
- não converte retroativamente o evento em on-time;
- não apaga escalation registrada.

**Resultado:** PASS.

---

## 14. AR-F4-T12 — source latency

Cadence não pode superar magicamente a disponibilidade real da fonte.

Foram separados:

- source availability latency;
- ingestion latency;
- processing latency.

Busca mais frequente reduz potencialmente ingestion latency, não source availability latency.

**Resultado:** PASS.

---

## 15. AR-F4-T13 — multiple-source cadence

Fontes podem ter cadences distintas.

Exemplos:

- bibliographic periódica;
- registry periódica diferente;
- regulatory event-driven;
- validity event-driven/pull;
- citation chaining por ciclo.

Ciclo agregado não pode esconder fonte atrasada.

**Resultado:** PASS.

---

## 16. AR-F4-T14 — event-driven

Event-driven exige mecanismo observável:

- push;
- pull;
- external notice.

Se push estiver indisponível:

> ausência de evento recebido não prova ausência de evento relevante.

Saúde do canal precisa ser observável.

**Resultado:** PASS.

---

## 17. AR-F4-T15 — pause

Pausa operacional não apaga coverage debt.

Dois modos futuros:

- clock_paused;
- clock_continues.

O modo precisa ser explícito.

Atraso acumulado antes da pausa permanece histórico.

**Resultado:** PASS.

---

## 18. AR-F4-T16 — temporal exception

Para Monitor, exceções existentes continuam em:

> `investigation.method_decision`.

Exemplos:

- monitor_cycle_window_gap_exception;
- monitor_search_temporal_exception.

Não estender MethodDecision artificialmente a toda obrigação transversal.

Se futura obrigação sem InvestigationVersion adequada precisar exceção formal:

> considerar registro especializado posterior.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 19. AR-F4-T17 — MethodDecision × UpdateDecision

Fronteira:

- MethodDecision = exceção/decisão metodológica da Investigation;
- UpdateDecision = resposta de atualização/currentness a UpdateSignal.

Uma MethodDecision pode resolver validade metodológica de uma Search fora da janela.

Ela não decide, por si só, se o target continua current.

**Resultado:** PASS.

---

## 20. AR-F4-T18 — policy supersession

### Risco

Trocar policy e “zerar” backlog/atraso.

### Decisão

Supersessão:

- não apaga overdue histórico;
- não apaga gap;
- não apaga incidente;
- não retargeteia obrigação passada.

Outstanding obligation futura deverá ser:

- resolvida;
- transferida;
- encerrada explicitamente.

**Resultado:** PASS.

---

## 21. AR-F4-T19 — timezone/calendar semantics

Regras de calendário deverão declarar timezone.

Persistência usa `timestamptz`.

Calendar rule e elapsed interval não são semanticamente idênticos.

DST/calendário não pode ser resolvido por inferência silenciosa.

**Resultado:** PASS.

---

## 22. AR-F4-T20 — temporal signal

`cadence_due` permanece:

> operational / temporal_operational.

Não deve ser criado para todo tick mecânico.

Preferência:

- issue simples para atraso puramente técnico;
- UpdateSignal quando o atraso precisa entrar em materiality/governance.

**Resultado:** PASS.

---

## 23. AR-F4-T21 — overdue × currentness

Regra proibida:

> overdue → outdated.

Mudança de currentness exige cadeia 027:

1. signal, quando necessário;
2. assessment;
3. decision autoritativa;
4. linkage de CurrencyState quando ProductVersion.

**Resultado:** PASS.

---

## 24. AR-F4-T22 — gap × currentness

Coverage gap não altera currentness automaticamente.

Pode justificar:

- signal operacional;
- validity_or_use_threat;
- under_evaluation;

somente após assessment e decision.

**Resultado:** PASS.

---

## 25. AR-F4-T23 — M3

Cadence M3 pode ser descrita como:

- continuous;
- hybrid.

Mas:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL permanece ativo.**

Nenhuma frequência ou latência, isoladamente, libera M3.

**Resultado:** PASS.

---

## 26. AR-F4-T24 — números universais

O gate rejeita:

- “M2 = mensal”;
- “M3 = semanal”;
- “M1 = anual”;
- grace universal;
- threshold universal de overdue.

Intervalos concretos podem existir por policy individual com rationale.

**Resultado:** PASS.

---

## 27. Compatibilidade com baseline físico

### migration 021

Preservados:

- planned_at;
- started_at;
- completed_at;
- window_start_date;
- window_end_date;
- lifecycle do cycle.

### migration 022

Preservados:

- gap temporal;
- search temporal acceptability;
- MethodDecision exceptions.

### migration 027

Preservados:

- cadence_mode;
- cadence_policy_payload;
- cadence_due;
- separação operational × scientific currentness.

Nenhuma alteração física foi executada neste bloco.

**Resultado:** PASS.

---

## 28. Compatibilidade metodológica externa

A política permanece coerente com princípios metodológicos atuais:

- living surveillance precisa ter frequência/método prospectivamente explícitos;
- não há uma frequência universal aplicável a toda evidência;
- surveillance deve ser proporcional/targeted;
- living mode exige contexto de prioridade, nova evidência esperada e capacidade.

O OES deliberadamente não converte exemplos externos de frequência em defaults.

**Resultado:** PASS.

---

## 29. Estado pós-gate

| Componente | Estado |
|---|---|
| cadence grammar | PASS |
| coverage × schedule separation | PASS |
| M1 periodic semantics | PASS |
| M2 cycle semantics | PASS |
| anchor modes | PASS |
| planned_at semantics | PASS |
| grace semantics | PASS |
| overdue semantics | PASS |
| source latency | PASS |
| event-driven surveillance | PASS |
| temporal exceptions | PASS |
| timezone/calendar semantics | PASS |
| cadence_due semantics | PASS |
| overdue → currentness automation | REJECTED |
| universal numeric cadence | REJECTED |
| new migration | NOT_AUTHORIZED |
| M3 operationalization | BLOCKED |

---

## 30. Decisão

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

O modelo temporal está apto a sustentar definição de SLA sem criar currentness por relógio.

---

## 31. Próximo passo exato

> **Definir a arquitetura transversal de SLAs como contratos operacionais entre eventos claramente definidos, distinguindo triagem, materialidade, decisão, início do workflow científico, conclusão científica e publicação/revisão.**

O bloco de SLA deverá:

1. definir relógios;
2. definir pause/stop conditions;
3. definir prioridade/criticidade como parametrizadores;
4. definir breach semantics;
5. rejeitar `SLA breach → scientific state`;
6. manter números universais fora do baseline até gate próprio.
