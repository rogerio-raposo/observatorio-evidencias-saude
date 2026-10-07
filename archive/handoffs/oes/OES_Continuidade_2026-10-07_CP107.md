# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Seleção do Evidence Readiness Temporal

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP107  
**Checkpoint anterior:** CP106  
**Status:** artefato de continuidade; não normativo  
**Escopo:** seleção metodológica do próximo sub-bloco da Fase 4 após validação da migration 032

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **TEMPORAL_CALIBRATION_TRACK = CONTINUES**

> **NORMATIVE_TEMPORAL_CALIBRATION = BLOCKED_PENDING_REAL_EVIDENCE_READINESS**

> **NEXT_PHASE_4_SUBBLOCK = TEMPORAL_CALIBRATION_EVIDENCE_READINESS**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate

Na abertura do bloco foi confirmado:

- branch `main`;
- HEAD inicial: `0d14c747893f4a887c71b79937969891405eea28`;
- CP106 vigente;
- README/STATE/CHANGELOG/CP106 coerentes;
- nenhum commit posterior inesperado;
- migration 032 tecnicamente validada;
- S5 canônico = PASS.

## 3. Documento decisório

`docs/governance/45-inventario-pos-cp106-selecao-evidence-readiness-calibracao-temporal.md`

Commit:

`5850feff2e8c90b4efdb04a8ae99da623125a03f`

## 4. Inventário de dívidas abertas

Permanecem:

1. calibração temporal normativa real;
2. scheduler;
3. notifications / auto-escalation;
4. M3 readiness / formal operationalization;
5. operação humana/institucional real necessária para authority/capacity/calendar em contextos aplicáveis.

## 5. Ordem arquitetural preservada

A ordem permanece:

1. calibração temporal;
2. scheduler;
3. notifications;
4. auto-escalation sob gate próprio;
5. M3 readiness sob gate próprio.

Logo:

- scheduler não precede obrigações temporais normativas;
- notifications não precedem eventos/thresholds aprovados;
- M3 não é desbloqueado por infraestrutura temporal.

## 6. Achado central

A migration 032 removeu o blocker físico.

O blocker atual é:

> **ausência de base real suficiente e authority real para iniciar genericamente calibração normativa temporal.**

No repositório atual:

- cadence calibration fixtures são TEST-ONLY / SYNTHETIC;
- SLA/calendar calibration fixtures são TEST-ONLY / SYNTHETIC;
- Operational Control fixtures são sintéticas;
- UpdateRiskProfile fixtures são sintéticas;
- não há Calibration Dossier real apto a ser tratado como `sufficient_for_calibration`;
- não há institutional calendar real registrado para uso normativo;
- não há distribuição operacional real suficiente de SLA1–SLA6;
- não há source-latency/uptime/capacity history real suficiente registrada para cadence;
- authorities de fixture não equivalem a aprovação humana/institucional real.

## 7. Casos reais científicos não resolvem automaticamente o gap

O OES contém casos reais de produtos científicos.

Porém:

> **produto real/publicado != evidence base temporal operacional real.**

Um caso real científico não fornece automaticamente:

- MonitorCycle history;
- source-latency measurements;
- SLA operational distribution;
- capacity observations;
- institutional calendar;
- calibration authority.

A eventual reutilização de casos reais como targets/corpus de observação deverá ser explicitamente decidida e documentada.

## 8. Próximo sub-bloco

> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS**

O objetivo será determinar, objeto por objeto, se existem condições reais para abrir calibração.

## 9. Escopo mínimo do próximo sub-bloco

Deverá especificar readiness para:

- cadence por target/source scope;
- SLA1–SLA6;
- institutional calendar;
- warning lead;
- post-breach threshold.

Cada input deverá ser classificado como:

- repository-observable now;
- requires prospective OES observation;
- requires source-specific external characterization;
- requires external normative artifact;
- requires owner/institutional decision;
- requires qualified scientific/methodological human judgment;
- not applicable.

## 10. Saídas permitidas

O readiness poderá produzir estados como:

- READY_FOR_CALIBRATION;
- PROVISIONAL_EVIDENCE_ONLY;
- NEEDS_PROSPECTIVE_OBSERVATION;
- NEEDS_SOURCE_CHARACTERIZATION;
- NEEDS_INSTITUTIONAL_CALENDAR;
- NEEDS_EXTERNAL_APPLICABILITY_REVIEW;
- NEEDS_HUMAN_AUTHORITY;
- INSUFFICIENT_EVIDENCE;
- NOT_APPLICABLE.

Esses estados não equivalem a normative activation.

## 11. O que permanece proibido

Antes do protocolo de readiness + gate:

- nenhum cadence interval real;
- nenhuma SLA duration real;
- nenhum grace real;
- nenhum warning lead real;
- nenhum post-breach threshold real;
- nenhum institutional calendar real inferido;
- nenhum normative SLARule;
- nenhum real calibrated UpdatePolicy;
- nenhum approval humano fictício;
- nenhum replay histórico fictício;
- nenhum scheduler;
- nenhuma notification delivery;
- nenhuma auto-escalation;
- nenhum unblock M3.

## 12. Priority score

> **PRIORITY_SCORE continua não requerido para a baseline.**

Não é reaberto por este checkpoint.

## 13. HEAD antes da criação do CP107

`ce55927cd72d9502d7d714e09579047c1892ea83`

## 14. Próximo passo exato

> **Após a pausa obrigatória, executar novo Freshness Gate e, em modo alto, especificar o Protocolo de Evidence Readiness para Calibração Temporal v0.1, seguido de gate adversarial — ainda sem qualquer valor temporal normativo.**

## 15. Regra de parada

Após ativação do CP107:

> **parar e aguardar “Prossiga” explícito do usuário.**

**Fim do CP107**
