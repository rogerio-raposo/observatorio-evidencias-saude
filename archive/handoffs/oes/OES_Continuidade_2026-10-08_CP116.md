# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Contrato Físico v0.1 de Aquisição Temporal Não Normativa

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP116  
**Checkpoint anterior:** CP115  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento do contrato físico v0.1, gate adversarial e elegibilidade da candidate migration 033 para decisão separada

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHYSICAL_SCHEMA = READY_FOR_MIGRATION_DECISION**

> **TEST_PLAN = READY_FOR_IMPLEMENTATION_IF_MIGRATION_AUTHORIZED**

> **MIGRATION_033 = ELIGIBLE_FOR_SEPARATE_AUTHORIZATION**

> **MIGRATION_033 = NOT_YET_AUTHORIZED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP115 foi confirmado:

- branch `main`;
- HEAD inicial `c6069e5751563a92e8df861ddaa96273b972aa7a`;
- CP115 vigente;
- nenhum avanço concorrente;
- Plan Amendment v0.2 rechecked;
- PubMed + ClinicalTrials.gov = Phase B candidate sources;
- BVS/LILACS = deferred source debt;
- physical gap confirmado;
- migration não autorizada.

## 3. Documento 61 — physical contract

Arquivo:

`docs/governance/61-contrato-fisico-aquisicao-temporal-nao-normativa-v01.md`

Commits:
- candidate inicial: `d67e6a7d60cbffa71285d2cc9853065b5a9a6902`;
- hardening principal: `6eb810942ed875d2861a3aedc9348fb83f66284a`;
- OpportunityResolution/transactional consistency: `5d868bce080ab7b2f8178dc2bedae5baa33f2d0e`;
- finite frozen opportunity set: `a14b1847de1681592e2a169a43b3e0b726112e25`;
- remoção de ambiguidade residual de schedule: `6b8de532d078fac9c199463315101ee18280aad0`.

## 4. Documento 62 — first adversarial pass

Arquivo:

`docs/governance/62-gate-adversarial-contrato-fisico-aquisicao-temporal-v01.md`

Commit:

`9ad62cbc28d11bc25db32448f69575158791b11c`

Resultado:

> **FIRST_PASS = REVISE**

Principais problemas identificados:

- execução multi-item colapsada em event;
- count/novelty ambíguos;
- failure-evidence child-order paradox;
- review boundary duplicado;
- nested normative leakage;
- source hard-code;
- retry/closure insuficiente;
- favorable stopping;
- authority resolution;
- target drift;
- scientific Search scope ambíguo;
- source semantics hard-coded;
- latency dual truth;
- OES detection no nível errado;
- Artifact drift;
- schedule reproducibility;
- migration scope creep.

## 5. Hardening final

O contrato revisado separa:

### Plan / scope
- TemporalObservationPlan;
- TemporalObservationSource.

### Execution design
- TemporalObservationEpoch;
- TemporalObservationEpochSource;
- TemporalObservationAuthority.

### Planned measurement
- TemporalMeasurementOpportunity.

### Attempts/results
- TemporalMeasurementEvent;
- TemporalMeasurementOpportunityResolution.

### Record-level evidence
- TemporalMeasurementItem;
- TemporalMeasurementItemTimepoint.

### Supporting evidence / governance
- TemporalMeasurementEventArtifact;
- TemporalObservationDeviation.

## 6. Opportunity / attempt / resolution

A opportunity representa o ato planejado.

MeasurementEvent representa tentativa realmente iniciada.

OpportunityResolution representa closure append-only:

- completed;
- failed_closed;
- not_executed;
- indeterminate_closed;
- invalidated.

Ausência de execução não é fabricada como event.

Retries preservam histórico.

## 7. Item / timepoint

MeasurementItem representa source identifier/record observado.

ItemTimepoint representa endpoints temporais distintos.

Isso permite:

- múltiplos PMIDs/NCTs no mesmo event;
- múltiplos source dates por item;
- latency derivada por endpoint;
- preservação de date precision;
- no fake second timestamp.

## 8. Latency

Latency não é persistida como segunda verdade material.

É derivada por helper versionado a partir de:

- MeasurementItemTimepoint;
- item-level OES detection timestamp.

Sem endpoints suficientes:

> **LATENCY_NOT_OBSERVABLE**

## 9. Schedule

O v0.1 não implementa scheduler nem recurrence generator.

Cada EpochSource usa:

> **finite_opportunity_set**

congelado em `schedule_definition_artifact_uuid`.

Opportunity rows devem igual exatamente o Artifact.

Logo:

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

O contrato suporta a futura materialização de um conjunto finito, mas não escolhe nenhum número ou timestamp real.

## 10. Source semantics

Source behavior é data-driven.

ObservationSource define:

- source_code;
- source_class;
- access_mode;
- runtime_connectivity_required;
- time_semantics_payload.

Nenhum trigger hard-code PubMed/ClinicalTrials.gov.

## 11. Authority

Authority é append-only e resolvida as-of.

Operational execution requer human actor e active decision Artifact.

Withdrawal/conflict bloqueiam activation/execution.

AI/system não satisfaz authority.

## 12. Target drift

Target leaving current:

- bloqueia novas opportunities;
- bloqueia novos attempts;
- bloqueia completion;
- exige epoch invalidation.

Histórico é preservado.

## 13. Source debt

BVS/LILACS deferred permanece visível no candidate source universe.

Readiness evidence separa:

- epoch_execution_completed;
- candidate_source_debt_present.

Não existe global coverage_complete.

## 14. contract_epoch

O physical contract v0.1:

> **não reutiliza `maintenance.contract_epoch`**

porque o objeto atual pertence à infraestrutura temporal normativa da migration 032.

## 15. No normative linkage

O novo layer não possui vínculo causal obrigatório com:

- UpdatePolicy;
- CadenceContract;
- CadenceObligation;
- CadenceObservation;
- SLARule;
- SLAInstance;
- Monitor;
- MonitoringCycle.

Search real e Artifact podem ser vinculados apenas sob semântica correta.

## 16. Test plan

Documento 61 especifica:

> **TNO-T01–T90**

Cobertura:

- targets;
- source scope;
- source debt;
- authority;
- schedule snapshot;
- opportunity;
- retry;
- resolution;
- item/timepoint;
- count/novelty;
- Artifact liveness;
- target drift;
- replay;
- readiness evidence;
- anti-laundering;
- no real seed;
- rebuild;
- regressions.

## 17. Documento 63 — final recheck

Arquivo:

`docs/governance/63-recheck-final-contrato-fisico-aquisicao-temporal-v01.md`

Commit:

`6b10f9ce9c8f46fc1cdecea918860401fd424df1`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Conclusão:

> **PHYSICAL_SCHEMA = READY_FOR_MIGRATION_DECISION**

## 18. Candidate migration 033

Nome candidato:

`033_non_normative_temporal_observation.sql`

Estado:

> **ELIGIBLE_FOR_SEPARATE_AUTHORIZATION**

> **NOT_YET_AUTHORIZED**

Se futuramente autorizada, boundary máximo:

- schema;
- constraints;
- triggers;
- helpers;
- replay/readiness views.

Proibido na migration:

- real TOPI plan;
- real sources;
- real authority;
- real epoch;
- real opportunity;
- real event;
- numeric measurement schedule;
- normative temporal values.

Fixtures synthetic devem ficar separadas.

## 19. CI / technical execution

Nenhum SQL foi implementado neste bloco.

Nenhum workflow/validator/runtime foi alterado.

Não há novo CI técnico a promover.

## 20. Commits de estado

- STATE: `b1322e881106b70442cab848b8411e8ffc515785`;
- CHANGELOG: `657dcf6c24cb36769967274f901c50528bb3453d`.

## 21. Próximo passo exato

Após a pausa obrigatória, em modo alto:

> **decidir a autorização e o boundary técnico da candidate migration 033.**

Essa decisão deve fechar:

1. migration authorization yes/no/revise;
2. one-file versus fragments;
3. exact DDL boundary;
4. fixture/test separation;
5. test-file names;
6. rebuild/smoke integration;
7. CI workflow impact;
8. no-seed guarantee;
9. migration rollback/rebuild expectations.

Somente depois de uma autorização explícita do bloco:

> implementar SQL.

## 22. Disciplina de modo

> **Modo alto permanece recomendado para a decisão de migration.**

Após o boundary técnico e autorização, a implementação mecânica pode voltar a modo médio, salvo issue arquitetural durante coding/gate.

## 23. Regra de parada

Após ativação do CP116:

> **parar e aguardar “Prossiga” explícito do usuário.**

## 24. HEAD antes da criação do CP116

`657dcf6c24cb36769967274f901c50528bb3453d`

**Fim do CP116**
