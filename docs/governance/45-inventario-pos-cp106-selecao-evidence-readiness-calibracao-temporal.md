# 45 — Inventário Pós-CP106 e Seleção do Próximo Sub-bloco da Fase 4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **NEXT_SUBBLOCK_SELECTED — TEMPORAL_CALIBRATION_EVIDENCE_READINESS**  
**Modo:** alto  
**Dependências:** Documentos 29, 32, 37–44; migration 032; CP106

## 1. Objetivo

Este documento responde à decisão deixada explicitamente aberta pelo CP106:

> após a validação técnica da infraestrutura temporal v0.1, o próximo bloco da Fase 4 deve iniciar calibração normativa temporal real ou deve fechar outro débito metodológico/governamental anterior?

A resposta é:

> **a trilha de calibração temporal continua prioritária, mas a etapa imediatamente seguinte não é definir números; é estabelecer readiness de evidência real para calibração.**

## 2. Freshness Gate

Na abertura deste bloco foi confirmado:

- branch canônica: `main`;
- HEAD: `0d14c747893f4a887c71b79937969891405eea28`;
- checkpoint vigente: **CP106 — 2026-10-07**;
- ponteiro, STATE, CHANGELOG e CP106 coerentes;
- nenhum commit posterior inesperado;
- migration 032 tecnicamente validada;
- S5 canônico do technical HEAD = PASS.

## 3. Inventário atualizado das dívidas abertas

Após CP106 permanecem quatro famílias principais de débito:

1. **calibração temporal normativa real**;
2. **scheduler**;
3. **notifications / auto-escalation**;
4. **M3 readiness / formal operationalization**.

Também permanece a necessidade transversal de operação humana/institucional real para sustentar determinadas decisões de authority, capacity e calendar.

## 4. Ordem de dependência

A ordem arquitetural já estabelecida nos Documentos 38–40 permanece válida:

1. calibração temporal;
2. scheduler, somente após obrigações temporais normativas existirem;
3. notifications, somente após eventos/thresholds aprovados existirem;
4. auto-escalation, somente após gate próprio;
5. M3 readiness, somente após cadence/SLA operacionais coerentes e gate específico.

Logo:

> **scheduler, notifications, auto-escalation e M3 não são candidatos válidos para preceder a calibração temporal.**

Não foi identificado novo débito estrutural anterior com prioridade superior.

## 5. O que mudou com a migration 032

Antes da migration 032, a calibração normativa estava bloqueada por ausência de infraestrutura física determinística.

Esse bloqueio foi removido tecnicamente.

Agora existem, com validação canônica:

- Calibration Dossier;
- authority;
- structured basis;
- candidates;
- evaluations;
- CadenceContract;
- CadenceObligation;
- CadenceObservation;
- source-scope proof;
- calibrated calendar linkage;
- SLARule linkage;
- causal filter guards;
- deterministic resolver;
- rule snapshot;
- nominal due calculator;
- business-calendar arithmetic;
- pause accounting;
- historical/as-of lineage;
- readiness helpers.

Portanto:

> **o principal blocker pós-CP106 deixou de ser físico e passou a ser epistêmico/operacional: ausência de evidência real suficiente para calibrar valores normativos.**

## 6. Auditoria da evidência disponível

### 6.1 Cadence

Os dados disponíveis na trilha F4 são explicitamente:

> **TEST-ONLY / SYNTHETIC**

O arquivo:

`database/f4-temporal-calibration-cadence-fixtures.sql`

declara explicitamente que nenhum valor de cadence normativo OES é seedado.

As dimensões A1–B5 ali usadas também são fixtures sintéticas.

Não há no repositório um Calibration Dossier real contendo, para um target operacional real:

- source latency observada;
- publication/indexing latency;
- source uptime;
- event-channel liveness;
- checks redundantes reais;
- checks sem nova informação reais;
- signal yield real;
- missed/late observations reais;
- workload real;
- capacity real;
- replay histórico real.

### 6.2 SLA

O arquivo:

`database/f4-temporal-calibration-sla-fixtures.sql`

declara explicitamente:

> **TEST-ONLY values preserved from historical operational-control fixtures. No OES normative SLA/calendar value is seeded.**

As durações SLA, calendário e replay da fixture são sintéticos.

Não há no repositório distribuição operacional real para SLA1–SLA6 contendo, de forma suficiente:

- wall time real;
- accountable time real;
- censura/casos incompletos;
- missingness;
- incidentes;
- pause reconstruction;
- backlog pressure;
- throughput;
- capacity context;
- endpoint precision histórica;
- comparação prospectiva de candidatos reais.

### 6.3 Calendário institucional

Existe calendário sintético de teste.

Não existe, como base normativa comprovada no repositório:

- calendário institucional OES aprovado;
- owner/governance provenance real;
- regra real de dias úteis;
- holidays/exceptions reais versionados;
- política institucional de disponibilidade 24/7 versus business-hours.

Portanto nenhum `SLACalendarVersion` real pode ser inferido da fixture.

### 6.4 External constraints

Não foi identificado Calibration Basis real contendo obrigação:

- legal;
- regulatória;
- contratual;
- de financiador;
- institucional formal;

com applicability assessment suficiente para dominar cadence/SLA/fixed deadline.

Ausência de obrigação externa conhecida não deve ser convertida em obrigação inventada.

### 6.5 Authority

As authorities presentes nas fixtures usam atores de teste:

- `fixture-reviewer`;
- `fixture-owner`;
- equivalentes sintéticos.

Elas validam o contrato físico.

Elas **não constituem aprovação humana/institucional real**.

## 7. Aplicação da metodologia do Documento 39

O Documento 39 estabelece três estados de suficiência:

- `sufficient_for_calibration`;
- `provisional_only`;
- `insufficient`.

Também estabelece:

> quando a base é insuficiente, nenhum número normativo é fabricado.

À luz do inventário atual:

> **não é defensável marcar genericamente a calibração temporal real como `sufficient_for_calibration`.**

Isso não significa que todos os objetos futuros necessariamente exigirão o mesmo volume de evidência.

Cada objeto deve ser avaliado separadamente.

Por exemplo:

- uma obrigação externa formal pode determinar fixed deadline sem história operacional longa;
- source characteristics reais podem sustentar parte da análise de cadence;
- um SLA operacional sem história comparável provavelmente exigirá piloto/prospective observation ou ficará provisional/insufficient.

Mas essas bases reais ainda não estão registradas no estado canônico atual.

## 8. Por que não iniciar números agora

Começar agora por valores como:

- “revisar a cada X dias”;
- “SLA1 = Y horas”;
- “grace = Z minutos”;
- “warning = N horas antes”;

produziria um dos seguintes erros:

1. transformar fixture sintética em policy;
2. converter judgment não documentado em suposto dado;
3. usar capacidade hipotética como feasibility real;
4. inventar latência de fonte;
5. inventar calendário institucional;
6. fabricar replay;
7. fabricar aprovação humana/owner;
8. introduzir falsa precisão.

Todos esses resultados violariam a metodologia já aprovada.

## 9. Decisão sobre o próximo bloco

O próximo bloco continua dentro da trilha:

> **TEMPORAL CALIBRATION**

mas seu sub-bloco imediato passa a ser:

> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS**

Esse sub-bloco deve determinar, objeto por objeto, se existe base suficiente para abrir calibração real.

## 10. Escopo do Evidence Readiness

O próximo sub-bloco deverá produzir uma matriz de readiness para, no mínimo:

### 10.1 Cadence

Por target/source scope:

- current maintainable target;
- governing UpdateRiskProfile real;
- source classes/names;
- source characteristics;
- event channels;
- timestamp precision;
- source latency;
- observability;
- failure history;
- operational load;
- capacity;
- historical observations/replay availability;
- authority requirements.

### 10.2 SLA1–SLA6

Para cada clock:

- causal start/end availability;
- endpoint precision;
- comparable case history;
- missingness/censoring;
- pauses reconstructibility;
- operational durations;
- capacity context;
- candidate feasibility;
- external constraints;
- rule-stratifier support;
- scientific/methodological authority;
- operational owner authority.

### 10.3 Calendar

- institutional operating model;
- timezone;
- open/closed periods;
- holidays/exceptions;
- safety/24×7 obligations;
- owner/governance approval;
- effective window;
- versioning trigger.

### 10.4 Warning / post-breach threshold

Separadamente:

- corrective lead time evidence;
- handoff latency;
- operational consequence;
- relation with due;
- evidence that threshold does not launder breach.

## 11. Classes de fonte para o readiness

Cada required input deve ser classificado como:

1. **repository-observable now**;
2. **requires prospective OES observation**;
3. **requires source-specific external measurement/documentation**;
4. **requires external normative artifact**;
5. **requires owner/institutional decision**;
6. **requires qualified scientific/methodological human judgment**;
7. **not applicable**.

Essa classificação evita que ausência de informação seja silenciosamente convertida em default.

## 12. Saída permitida do próximo sub-bloco

Para cada objeto/contexto, o Evidence Readiness poderá concluir:

- `READY_FOR_CALIBRATION`;
- `PROVISIONAL_EVIDENCE_ONLY`;
- `NEEDS_PROSPECTIVE_OBSERVATION`;
- `NEEDS_SOURCE_CHARACTERIZATION`;
- `NEEDS_INSTITUTIONAL_CALENDAR`;
- `NEEDS_EXTERNAL_APPLICABILITY_REVIEW`;
- `NEEDS_HUMAN_AUTHORITY`;
- `INSUFFICIENT_EVIDENCE`;
- `NOT_APPLICABLE`.

Esses estados são readiness, não calibration decisions.

Eles não equivalem a:

- `approved_for_normative_activation`;
- normative cadence;
- normative SLA;
- publication readiness;
- M3 readiness.

## 13. O que o próximo bloco não pode fazer

O Evidence Readiness não pode:

- escolher número normativo;
- copiar valor de fixture;
- criar Calibration Dossier real com base sintética;
- registrar approval humano fictício;
- registrar owner fictício;
- declarar calendário real sem provenance;
- transformar ausência de dados em governance decision silenciosa;
- iniciar scheduler;
- iniciar notification delivery;
- ativar auto-escalation;
- remover blocker M3.

## 14. Relação com casos reais existentes do OES

O repositório contém casos reais de produtos científicos anteriores.

Isso **não basta**, por si só, para calibrar temporalmente a manutenção.

Produto real/publicado não equivale automaticamente a:

- history de MonitorCycle real;
- source latency measurement;
- operational SLA history;
- capacity observation;
- institutional calendar;
- calibration authority.

Casos reais podem futuramente servir como targets/corpus de observação se forem metodologicamente apropriados e explicitamente vinculados, mas essa reutilização deve ser decidida e documentada — não inferida.

## 15. Priority score

O inventário não reabre priority score.

Permanece válida a decisão de que:

> **PRIORITY_SCORE não é requisito para a baseline da Fase 4.**

A prioridade qualitativa/response_class já possui arquitetura suficiente para selecionar regras futuras sem score aditivo universal.

## 16. Scheduler / notifications / auto-escalation

Estado:

> **SCHEDULER = DEFERRED_DEPENDENT_ON_NORMATIVE_TEMPORAL_OBLIGATIONS**

> **NOTIFICATIONS = DEFERRED_DEPENDENT_ON_APPROVED_EVENTS_THRESHOLDS**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

A infraestrutura temporal tecnicamente validada não altera essa ordem.

## 17. M3

Estado:

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Evidence Readiness de calibração não é M3 readiness.

Mesmo futura cadence/SLA calibrada:

> não removerá automaticamente o blocker M3.

## 18. Fase 5

> **PHASE_5 = NOT_STARTED**

Nenhum resultado deste inventário autoriza avanço de fase.

## 19. Estado final da seleção

> **TEMPORAL_CALIBRATION_TRACK = CONTINUES**

> **NORMATIVE_TEMPORAL_CALIBRATION = BLOCKED_PENDING_REAL_EVIDENCE_READINESS**

> **NEXT_PHASE_4_SUBBLOCK = TEMPORAL_CALIBRATION_EVIDENCE_READINESS**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **SCHEDULER = DEFERRED**

> **NOTIFICATIONS = DEFERRED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

## 20. Próximo passo exato

> **Em modo alto, especificar o Protocolo de Evidence Readiness para Calibração Temporal v0.1, definindo a matriz de evidências reais necessárias, fontes possíveis, responsáveis/authority, critérios de readiness e condições para abrir um Calibration Dossier real — sem definir nenhum valor temporal normativo.**

Esse protocolo deverá ser submetido a gate adversarial antes de qualquer coleta tratada como base suficiente ou qualquer calibração numérica.

