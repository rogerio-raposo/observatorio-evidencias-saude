# 44 — Resultado Técnico da Migration 032 e Validação Temporal v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **TECHNICAL_PASS — CANONICAL_S5_VALIDATED**  
**Depende de:** Documentos 39–43  
**Objeto:** implementação e validação técnica da infraestrutura física de calibração temporal v0.1

## 1. Resultado

> **MIGRATION_032 = TECHNICALLY_VALIDATED**

> **F4_TCAL_PH_T01_T230 = PASS**

> **MIGRATION_032_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_032 = PASS**

> **LEGACY_F4_REGRESSIONS = PASS**

> **S5_CANONICAL = PASS**

A validação técnica não autoriza valores temporais normativos reais.

## 2. Head técnico canônico

`657c69024fafb6c2e6311d47091d5897730668fd`

## 3. Workflow canônico

- workflow: `OES PoC-S5 PostgreSQL Validation`;
- run ID: `37690201061`;
- job: `postgres-s5`;
- job ID: `113028117278`;
- conclusion: `success`.

## 4. Artifact canônico

- name: `oes-s5-evidence-37690201061`;
- artifact ID: `11512707774`;
- size: `250711` bytes;
- digest: `sha256:bb145efb29d7c30e607136defa09c828711162e27ac71a307df229449980f826`;
- expired: `false` no momento da validação.

## 5. Escopo implementado

Migration lógica:

`database/032_temporal_calibration_prerequisites.sql`

Fragments:

- `032a_temporal_calibration_core.sql`;
- `032b_temporal_cadence_contract.sql`;
- `032c_temporal_sla_contract.sql`;
- `032d_temporal_sla_runtime.sql`.

A implementação inclui:

1. contract epoch + grandfather registry;
2. TemporalCalibrationDossier;
3. authority/basis/candidate/evaluation;
4. CadenceContract;
5. CadenceObligation;
6. CadenceObservation;
7. UpdatePolicy cadence binding;
8. SLACalendar calibration linkage;
9. FixedDeadlineSource;
10. SLARule calibration linkage/filter guards;
11. historical/as-of rule lineage;
12. causal clock-start context;
13. canonical SLA resolver;
14. canonical rule snapshot;
15. calendar arithmetic;
16. nominal due calculator;
17. SLAInstance due snapshot;
18. SLAPause accountable duration;
19. warning/breach/escalation/pause validators;
20. readiness helpers.

## 6. Hardenings aplicados durante implementação

A implementação foi endurecida para fechar:

- dossier terminal imutável;
- target corrente na ativação;
- basis controlador forte com provenance;
- replay explícito antes de aprovação;
- FixedDeadlineSource append-only;
- SLARule lineage sem reaproveitamento de superseded quebrado;
- SLAInstance causal/snapshot fields imutáveis;
- source-scoped cadence validado contra Monitor real;
- CadenceObservation com causal locator scope;
- candidate payload schemas fechados internamente;
- absence de future leakage em PriorityAssessment;
- ausência de synthetic grandfathering;
- M3/continuous ainda bloqueados.

## 7. Fixtures

Fixtures novas:

- `database/f4-temporal-calibration-cadence-fixtures.sql`;
- `database/f4-temporal-calibration-sla-fixtures.sql`.

Todos os intervalos, calendários e replay usados nessas fixtures são:

> **TEST-ONLY / SYNTHETIC**

Não representam política temporal normativa OES.

## 8. Suite dedicada

Arquivo:

`database/f4-temporal-calibration-tests.sql`

Resultado:

> **F4-TCAL-PH-T01–T230 = PASS**

A suíte cobre:

- schema;
- columns;
- functions;
- triggers;
- dossiers/candidates;
- cadence contracts/obligations;
- SLA resolver/snapshots;
- calendar arithmetic;
- pause accounting;
- causal start;
- provenance;
- immutability;
- negative guards;
- M3/scheduler/notification prohibitions.

## 9. Idempotência

Step:

> **F4-TCAL-PH-IDEM**

Resultado:

> **PASS**

A reaplicação da migration 032:

- não altera contagem de dossiers;
- não altera cadence contracts;
- não altera SLARules;
- não cria grandfathering sintético;
- mantém T01–T230 verde.

## 10. Rebuild from zero

A cadeia de rebuild aplica migrations 001–032 e as fixtures na ordem canônica.

Resultado:

> **REBUILD_THROUGH_032 = PASS**

## 11. Regressões

Continuam verdes:

- F4 Update Protocol;
- F4 UpdateRiskProfile;
- F4 Operational Control;
- F4 Propagation/Re-baselining;
- idempotências anteriores;
- regressões F2-B;
- S4;
- S5;
- F3.

## 12. Restrições preservadas

Continuam não autorizados:

- real cadence interval;
- real SLA duration;
- real grace;
- real warning lead;
- real post-breach threshold;
- real institutional calendar;
- real normative SLARule;
- real calibrated UpdatePolicy;
- scheduler;
- notification delivery;
- automatic escalation;
- automatic Currentness change;
- assurance promotion;
- publication automation;
- M3 formal operationalization;
- fabricated human/expert/owner approval;
- fabricated historical calibration evidence.

## 13. Estado após validação

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = IMPLEMENTED_AND_TECHNICALLY_VALIDATED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 14. Próximo passo

Após checkpoint:

> **retornar ao nível metodológico/governança para decidir, em modo alto, se o próximo bloco da Fase 4 deve iniciar a calibração normativa temporal real ou se há outro débito anterior a fechar.**

Nenhum valor normativo deve ser definido automaticamente apenas porque a infraestrutura técnica passou.

