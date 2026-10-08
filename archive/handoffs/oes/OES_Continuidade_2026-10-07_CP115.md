# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — TOPI Plan Amendment v0.2 / Phase B Boundary

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP115  
**Checkpoint anterior:** CP114  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento do Plan Amendment v0.2 da TOPI-N2-DCBTI-01 e autorização apenas para especificação física do event layer não normativo

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PLAN_VERSION = V0_2_CANDIDATE_RECHECKED**

> **TOPI_N2_DCBTI_V02_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_B_INCLUDED_SOURCES = PUBMED_MEDLINE + CLINICALTRIALS_GOV**

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

> **PHASE_B_EVENT_MODEL = SOURCE_SPECIFIC_NON_NORMATIVE_MEASUREMENT_EVENT**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **MEASUREMENT_SCHEDULE = DEFERRED_PENDING_PHYSICAL_CONTRACT**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MIGRATION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP114 foi confirmado:

- branch `main`;
- HEAD inicial `ab06b0c97a6edcba6d26c00fed44254d01e47e26`;
- CP114 vigente;
- nenhum avanço concorrente;
- Phase A concluída;
- PubMed e ClinicalTrials.gov suficientemente caracterizados para desenho;
- BVS/LILACS parcialmente caracterizado;
- measurement schedule não selecionado;
- Phase B não autorizada.

## 3. Documento 59 — Plan Amendment v0.2

Arquivo:

`docs/governance/59-topi-n2-dcbti-plan-amendment-v02-phase-b-boundary.md`

Commit:

`6f8c9181dd59990c4b6127a9a465f321ee02c7e9`

## 4. Source inclusion

### PubMed/MEDLINE

Estado:

> **INCLUDED_CANDIDATE**

Racional:
- E-utilities;
- stable PMID;
- CRDT/EDAT;
- controls conhecidos;
- observability suficiente.

### ClinicalTrials.gov

Estado:

> **INCLUDED_CANDIDATE_WITH_RUNTIME_CONNECTIVITY_PRECONDITION**

Racional:
- API v2;
- NCT ID;
- posting/update fields;
- source class complementar.

### BVS/LILACS

Estado:

> **DEFERRED_SOURCE_DEBT**

Não significa exclusão científica.

A fonte permanece no candidate universe e exige futuro:
- reproducible access path; ou
- manual explicit design,
ambos re-gated.

Nenhuma completeness claim é permitida.

## 5. Event model

A Phase B candidata usa:

> **SOURCE_SPECIFIC_NON_NORMATIVE_MEASUREMENT_EVENT**

Cada source deve possuir eventos próprios.

Aggregate policy-level só poderá ser derivado posteriormente.

Planned opportunities precisam ser preservadas mesmo quando:

- not_executed;
- failed;
- partial;
- indeterminate.

Isso permite missingness/replay sem criar compliance normativa.

## 6. Lacuna física

Foi examinado o schema existente.

### artifact.artifact

Útil para:
- storage metadata;
- content hash;
- locator;
- payload externalizado.

Insuficiente como único event store porque não normaliza:
- target;
- epoch;
- source;
- planned_for;
- execution/result state;
- denominator;
- failure attribution;
- latency endpoints;
- effort;
- deviations.

### investigation.search

Somente Search científica real.

### maintenance.evidence_event

Monitor-bound e exige MonitoringCycle.

### maintenance.cadence_observation

CadenceObligation-bound e normativa.

Conclusão:

> **PHYSICAL_GAP_CONFIRMED**

## 7. Decisão física

A Phase B requer um contrato físico dedicado para eventos pré-calibração.

Porém:

> **MIGRATION = NOT_AUTHORIZED**

A ordem obrigatória é:

1. physical specification;
2. adversarial gate;
3. test plan;
4. somente depois decidir migration.

## 8. Measurement schedule

> **DEFERRED_PENDING_PHYSICAL_CONTRACT**

Nenhum intervalo experimental foi selecionado.

Motivos:
- missed opportunities precisam ser representáveis;
- schedule precisa ser replayable;
- source precision deve ser preservada;
- daily PubMed updates não determinam OES polling;
- ClinicalTrials.gov posting semantics não determinam OES polling;
- source-specific schedules podem ser necessários.

## 9. Documento 60 — target-specific recheck

Arquivo:

`docs/governance/60-recheck-target-specific-topi-v02-phase-b-boundary.md`

Commit:

`0514da088bf1a55a0de52dec0c0e92631d9329a1`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

O PASS autoriza somente:

> **specification do non-normative physical measurement-event contract.**

## 10. Requisitos derivados para o physical contract

Deve representar, no mínimo:

1. plan/epoch identity;
2. source registry/scope;
3. measurement opportunity identity;
4. planned/executed state;
5. execution timestamps;
6. outcome dimensions;
7. denominator semantics;
8. failure attribution;
9. source temporal endpoints;
10. OES detection timestamp;
11. artifact linkage;
12. effort metrics;
13. deviation/version linkage;
14. immutable/append-preserving lifecycle;
15. target/source/epoch consistency;
16. ausência de normative due/compliance semantics;
17. BVS deferred source debt;
18. replay/readiness queries.

## 11. Estado operacional

Não autorizados:

- Phase B source measurements;
- numeric measurement schedule;
- Phase B authority request;
- migration;
- UpdatePolicy;
- CadenceContract;
- Calibration Dossier;
- normative temporal values;
- scheduler;
- notifications;
- auto-escalation;
- M3 formal.

## 12. CI

Este bloco foi documental/arquitetural.

Nenhuma migration, validator, workflow ou runtime foi alterado.

Não há novo CI técnico a promover.

## 13. Próximo passo exato

Após pausa:

> **em modo alto, especificar o contrato físico v0.1 para ObservationEpoch / TemporalMeasurementEvent não normativos, incluindo schema conceitual/físico, constraints, lifecycle, source debt, artifact linkage, replay/readiness views e test plan.**

Depois:

> **executar gate adversarial desse contrato antes de qualquer migration.**

## 14. Disciplina de modo

> **Modo alto permanece recomendado.**

O próximo bloco define uma nova camada física e invariantes difíceis de reverter.

## 15. Regra de parada

Após ativação do CP115:

> **parar e aguardar “Prossiga” explícito do usuário.**

## 16. HEAD antes da criação do CP115

`52374550223ec0e5edb5f3b964a592e72bf703f6`

**Fim do CP115**
