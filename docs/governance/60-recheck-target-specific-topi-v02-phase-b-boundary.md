# 60 — Recheck Target-Specific do Plan Amendment v0.2 da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — PHASE_B_EXECUTION_NOT_AUTHORIZED**  
**Modo:** alto  
**Objeto:** recheck do Documento 59 antes de physical-contract specification

## 1. Resultado

> **TOPI_N2_DCBTI_V02_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_B_SOURCE_SELECTION = PASS**

> **PHASE_B_EVENT_MODEL = PASS_FOR_PHYSICAL_SPECIFICATION**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **MEASUREMENT_SCHEDULE = NOT_AUTHORIZED_FOR_SELECTION_YET**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MIGRATION = NOT_AUTHORIZED**

## 2. Source inclusion — PubMed

PubMed foi caracterizado na Phase A com:

- interface programática documentada;
- identifiers e date fields úteis;
- controls de acesso conhecidos;
- observability suficiente para desenho.

Resultado:

> **PASS — INCLUDED_CANDIDATE**

## 3. Source inclusion — ClinicalTrials.gov

ClinicalTrials.gov foi caracterizado com:

- API v2 documentada;
- stable NCT identifiers;
- posting/update fields;
- structured download/API model.

A runtime connectivity ainda precisa ser confirmada antes da execução.

Resultado:

> **PASS_WITH_PRECONDITION — INCLUDED_CANDIDATE**

## 4. BVS/LILACS como deferred source debt

Ataque:

Excluir BVS/LILACS do B1 poderia ser interpretado como:

- abandono da fonte regional;
- claim implícito de completeness com duas fontes;
- source laundering por conveniência técnica.

Recheck:

O Documento 59:

- mantém BVS/LILACS no candidate universe;
- registra exclusion/defer rationale;
- proíbe completeness claim;
- exige reassessment trigger;
- permite futuro epoch programmatic ou manual explicitamente re-gated.

Resultado:

> **PASS**

Estado:

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

## 5. Event model source-specific

Ataque:

Um único event agregado poderia esconder:

- uma source não executada;
- falha de interface;
- result state distinto;
- latency semantics diferentes.

O Documento 59 exige event source-specific e só permite aggregate derivado.

Resultado:

> **PASS**

## 6. Planned opportunities

Ataque:

Registrar apenas execuções efetivas eliminaria do dataset:

- missed opportunities;
- not_executed events;
- reasons for non-execution;
- operational missingness.

O event model preserva planned opportunities individualmente.

Resultado:

> **PASS**

Importante:

> planned opportunity não é obligation normativa.

## 7. Artifact-only storage attack

Ataque:

Usar somente `artifact.artifact` + arquivos JSON poderia parecer suficiente.

Recheck físico:

`artifact.artifact` normaliza metadados de arquivo, mas não normaliza:

- exact target;
- epoch;
- source;
- planned_for;
- execution status;
- result state;
- denominator;
- failure attribution;
- temporal endpoints;
- effort;
- deviation linkage.

Para repeated measurement, depender exclusivamente de parsing de artifact payload reduz queryability, replay e controles relacionais.

Resultado:

> **PHYSICAL_GAP_CONFIRMED**

## 8. Existing-object reuse attack

### investigation.search

Não é event store genérico.

> **PASS — reuse prohibited except genuine scientific Search**

### maintenance.evidence_event

É Monitor-bound e exige MonitoringCycle.

> **PASS — reuse prohibited**

### maintenance.cadence_observation

É CadenceObligation-bound.

> **PASS — reuse prohibited**

### UpdateSignal

Pertence a policy/trigger semantics.

> **PASS — reuse prohibited**

Conclusão:

> **dedicated non-normative event contract is justified.**

## 9. Overbuilding attack

Ataque:

Uma nova estrutura física antes de pilot data poderia ser overengineering.

Recheck:

A lacuna é material porque a Phase B já exige, por contrato metodológico:

- planned opportunities;
- actual executions;
- missingness;
- source-specific outcomes;
- failure attribution;
- replay;
- versioned epochs.

Esses requisitos não são apenas conveniência.

Resultado:

> **PHYSICAL_SPECIFICATION_JUSTIFIED**

Ainda assim:

> migration só poderá ser autorizada após specification + adversarial gate + test plan.

## 10. Measurement schedule deferral

Ataque:

Postergar schedule poderia impedir fechar o physical contract.

Recheck:

O contrato físico pode ser especificado sem escolher intervalo, desde que suporte:

- source-specific schedule;
- planned_for;
- execution windows se futuramente necessárias;
- no normative due semantics;
- missed/not-executed opportunities;
- plan/epoch version.

Escolher número agora criaria anchoring antes de garantir representação correta.

Resultado:

> **PASS — SCHEDULE_DEFERRAL_REQUIRED**

## 11. Normative leakage

O Documento 59 preserva:

- no cadence;
- no overdue;
- no breach;
- no compliance;
- no scheduler;
- no notifications;
- no auto-escalation;
- no currentness automation.

Resultado:

> **PASS**

## 12. M1 / shadow-M2

B1 continua measurement experimental:

- não Monitor;
- não MonitoringCycle;
- não coverage guarantee;
- não M2.

Source-specific repetition não altera maintenance level.

Resultado:

> **PASS**

## 13. UpdateRiskProfile boundary

A Phase B pode gerar evidence inputs para A2/B1/B2/B3/B5.

Não pode fechar ratings authoritative automaticamente.

Resultado:

> **PASS**

## 14. Authority boundary

A approval da Phase A não é transportável para B1.

Nova approval futura deve referenciar:

- plan v0.2 final;
- epoch B1;
- included sources;
- event contract version;
- measurement schedule;
- review boundary.

Resultado:

> **PASS**

## 15. Data-governance boundary

Physical contract deve suportar:

- minimal metadata;
- artifact locators para raw payload;
- ausência de secrets;
- source-access incidents;
- deletion/retention apenas no payload layer quando permitido;
- append-preserving event history.

Resultado:

> **PASS_FOR_PHYSICAL_SPECIFICATION**

## 16. Physical contract requirements derivados

O próximo contrato deve fechar, no mínimo:

1. plan/epoch identity;
2. source registry/scope;
3. measurement opportunity identity;
4. planned versus executed state;
5. execution timestamps;
6. outcome dimensions;
7. denominator semantics;
8. failure attribution + evidence;
9. source temporal endpoint semantics;
10. OES detection timestamp;
11. artifact locator linkage;
12. effort metrics;
13. deviation/version linkage;
14. immutable/append-preserving lifecycle;
15. target/source/epoch consistency;
16. no normative due/compliance semantics;
17. BVS deferred source debt representation;
18. queries/views suficientes para replay/readiness analysis.

## 17. O que este PASS autoriza

Autoriza somente:

> **especificar o contrato físico do non-normative measurement event layer.**

Pode incluir:

- conceptual tables;
- columns/types;
- constraints;
- triggers;
- views/functions;
- test plan;
- migration boundary candidate.

Não autoriza:

- criar migration;
- implementar schema;
- executar source measurements;
- escolher numeric schedule;
- solicitar Phase B authority;
- criar UpdatePolicy/CadenceContract.

## 18. Estado

> **PLAN_VERSION = V0_2_CANDIDATE_RECHECKED**

> **TOPI_N2_DCBTI_V02_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_B_INCLUDED_SOURCES = PUBMED_MEDLINE + CLINICALTRIALS_GOV**

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **MEASUREMENT_SCHEDULE = DEFERRED_PENDING_PHYSICAL_CONTRACT**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MIGRATION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 19. Próximo passo exato

> **Após checkpoint, em modo alto, especificar o contrato físico v0.1 para TemporalMeasurementEvent/ObservationEpoch não normativos, incluindo test plan e gate adversarial antes de qualquer migration.**

**Fim do Documento 60**
