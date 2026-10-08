# 63 — Recheck Final do Contrato Físico v0.1 de Aquisição Temporal Não Normativa

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — MIGRATION_NOT_AUTHORIZED**  
**Modo:** alto  
**Objeto:** recheck final do Documento 61 após o gate adversarial do Documento 62

## 1. Resultado

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHYSICAL_SCHEMA = READY_FOR_MIGRATION_DECISION**

> **TEST_PLAN = READY_FOR_IMPLEMENTATION_IF_MIGRATION_AUTHORIZED**

> **MIGRATION_033 = ELIGIBLE_FOR_SEPARATE_AUTHORIZATION**

> **MIGRATION_033 = NOT_YET_AUTHORIZED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

## 2. TNO-G01 — multi-item temporal granularity

O contrato revisado separa:

- execution-level MeasurementEvent;
- record-level MeasurementItem;
- endpoint-level MeasurementItemTimepoint.

Resultado:

> **PASS**

Não existe mais necessidade de colapsar múltiplos source dates em uma única row de execução.

## 3. TNO-G02 / G18 — count/novelty semantics

O contrato separa:

- raw_result_count;
- materialized_identifier_count;
- new_identifier_count;
- MeasurementItems;
- novelty_state.

`zero_new` significa zero novos IDs em relação ao baseline/epoch, não zero resultados brutos.

Resultado:

> **PASS_WITH_DEFERRED_CROSS_ROW_CHECK**

A igualdade entre declared counts e child rows deve ser verificada por constraint trigger deferred ou closure/issue function.

## 4. TNO-G03 — failure evidence ordering

`failure_evidence_artifact_uuid` foi promovido para a row do MeasurementEvent.

Junction table continua para artifacts suplementares.

Resultado:

> **PASS**

## 5. TNO-G04 — review-boundary dual truth

`review_boundary_at` existe apenas no Epoch.

Schedule payload não o duplica.

Resultado:

> **PASS**

## 6. TNO-G05 — nested normative leakage

O contrato exige recursive forbidden-key validator.

Resultado:

> **PASS**

Forbidden semantics incluem cadence, due, overdue, breach, grace, SLA, compliance, penalty e escalation em qualquer profundidade.

## 7. TNO-G06 — source-specific hard-code

Runtime connectivity é data-driven por:

- access_mode;
- runtime_connectivity_required;
- runtime_connectivity_status.

Nenhum source brand é branch estrutural.

Resultado:

> **PASS**

## 8. TNO-G07 — source time semantics

Cada ObservationSource define `time_semantics_payload`.

MeasurementItemTimepoint semantic_code precisa pertencer à definição da source.

Resultado:

> **PASS**

Nova source não exige migration apenas para novo semantic code.

## 9. TNO-G08 / G09 — retry e opportunity closure

O contrato agora possui:

- MeasurementOpportunity;
- MeasurementEvent attempts;
- OpportunityResolution.

Regras:

- attempt_no contíguo;
- retry apenas após failed/partial/indeterminate;
- completed não admite novo attempt;
- absence of execution é `OpportunityResolution.not_executed`, não fake event;
- persistent failure pode ser fechado como `failed_closed`;
- one resolution per opportunity.

Resultado:

> **PASS**

## 10. TNO-G10 — favorable stopping

Epoch completed exige:

> **completed_at >= review_boundary_at**

Não existe early completion no v0.1.

Antes disso, mudança material leva a invalidation/new epoch, não “stop por suficiência”.

Resultado:

> **PASS**

## 11. TNO-G11 — target drift

Target non-current durante epoch:

- bloqueia novas opportunities;
- bloqueia novos attempts;
- bloqueia completion;
- exige invalidation;
- preserva histórico.

Resultado:

> **PASS**

## 12. TNO-G12 / G13 — authority state

Authority:

- human-only actors;
- decision Artifact;
- append-only;
- resolver as-of;
- withdrawal;
- conflict detection.

Activation/execution exige current operational_execution state = approved.

Resultado:

> **PASS**

Artifact drift aparece em issues; não reescreve authority history.

## 13. TNO-G14 — plan/source snapshot

EpochSource referencia immutable source row da exact PlanVersion.

Supersession futura não reparenta epoch.

Resultado:

> **PASS**

## 14. TNO-G15 — scientific Search scope

EpochSource congela:

> **measurement_investigation_version_uuid**

Search, quando realmente científica, deve pertencer a esse exact Investigation.

Para Product target, Investigation precisa estar linked ao ProductVersion.

Resultado:

> **PASS**

## 15. TNO-G16 — query/interface snapshot

EpochSource congela:

- query strategy Artifact;
- interface config Artifact;
- runtime interface code;
- baseline Artifact;
- source semantics;
- schedule definition Artifact.

Mudança material exige novo epoch/plan version.

Resultado:

> **PASS**

## 16. TNO-G17 — baseline/novelty

MeasurementItem item_state:

- new_to_epoch;
- reobserved;
- updated_record;
- indeterminate.

Baseline Artifact é congelado no EpochSource.

Resultado:

> **PASS**

“new_to_epoch” não é claim de novidade científica global.

## 17. TNO-G19–G21 — timepoints / latency / detection

Timepoints são item-level.

OES detection é item-level.

Latency não é persistida como segunda verdade material; é derivada por versioned helper.

Resultado:

> **PASS**

Date-only não é promovida artificialmente a second precision.

## 18. TNO-G22 — effort payload

Effort payload usa allowed-key validator estrito e sem arbitrary nested JSON.

Resultado:

> **PASS**

Pilot effort continua distinto de sustainable capacity.

## 19. TNO-G23 — deviation scope

Event determina opportunity/epoch quando presente.

Cross-reference inconsistency é inválida.

Material deviation permanece append-only e bloqueia continuidade no mesmo epoch.

Resultado:

> **PASS**

## 20. TNO-G24 — execution completion versus source debt

Readiness evidence distingue:

- epoch_execution_completed;
- candidate_source_debt_present.

Não há global `coverage_complete`.

Resultado:

> **PASS**

BVS/LILACS deferred permanece visível após eventual B1 completion.

## 21. TNO-G25 — readiness scope

v0.1 aceita somente:

- policy_aggregate;
- source_specific.

Resultado:

> **PASS**

TOPI-N2 permanece policy_aggregate no plan e source-specific nos measurement facts.

## 22. TNO-G26 — contract_epoch

O contrato revisado explicitamente:

> **não reutiliza maintenance.contract_epoch**

porque o objeto atual pertence ao contrato temporal normativo 032.

Resultado:

> **PASS**

Se marker persistido for necessário, deve ser explicitamente não normativo.

## 23. TNO-G27 — Artifact status drift

Creation/activation exige controlling Artifacts active.

Drift posterior:

- não apaga rows;
- aparece em issue functions;
- pode invalidar epoch conforme papel causal.

Resultado:

> **PASS**

## 24. TNO-G28 — schedule reproducibility

O v0.1 foi estreitado.

Não existe schedule generator no banco.

Cada EpochSource usa:

> **finite_opportunity_set**

congelado por `schedule_definition_artifact_uuid`.

Opportunity rows devem igual exatamente o frozen Artifact.

Resultado:

> **PASS**

Isso reduz scheduler leakage.

## 25. TNO-G29 — schedule não selecionado

O physical contract define estrutura sem escolher timestamps reais.

Resultado:

> **PASS**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

## 26. TNO-G30 — migration scope

Candidate migration 033:

- schema/functions/views/triggers only;
- zero real plan;
- zero real source instance;
- zero authority;
- zero epoch;
- zero opportunity;
- zero event;
- zero numeric schedule.

Synthetic fixtures ficam separados e test-only.

Resultado:

> **PASS**

## 27. Root physical objects aprovados para specification

1. `maintenance.temporal_observation_plan`;
2. `maintenance.temporal_observation_source`;
3. `maintenance.temporal_observation_epoch`;
4. `maintenance.temporal_observation_epoch_source`;
5. `maintenance.temporal_observation_authority`;
6. `maintenance.temporal_measurement_opportunity`;
7. `maintenance.temporal_measurement_event`;
8. `maintenance.temporal_measurement_opportunity_resolution`;
9. `maintenance.temporal_measurement_item`;
10. `maintenance.temporal_measurement_item_timepoint`;
11. `maintenance.temporal_measurement_event_artifact`;
12. `maintenance.temporal_observation_deviation`.

## 28. Derived helpers/views aprovados para implementation planning

- recursive forbidden temporal-key validator;
- schedule-payload validator;
- effort-payload validator;
- source-semantics validator;
- authority-state resolver;
- epoch activation guard;
- epoch completion guard;
- event append/retry guard;
- opportunity status resolver;
- item-state validator;
- item-latency derived helper;
- schedule/opportunity equality helper;
- replay view;
- readiness-evidence view;
- plan/epoch/event issue functions.

## 29. Deferred transactional consistency

Algumas invariantes dependem de parent + child inserts.

Implementação deverá usar:

- DEFERRABLE INITIALLY DEFERRED constraint triggers; ou
- explicit closure validator antes de OpportunityResolution/Epoch completion.

Não é permitido enfraquecer a invariável apenas por ordem de INSERT.

Resultado:

> **PASS_WITH_IMPLEMENTATION_DECISION**

A escolha técnica exata será fechada na migration implementation/review.

## 30. No normative linkage

O contract não depende causalmente de:

- UpdatePolicy;
- CadenceContract;
- CadenceObligation;
- CadenceObservation;
- SLARule;
- SLAInstance;
- Monitor ProductVersion;
- MonitoringCycle.

Resultado:

> **PASS**

Scientific Search/Artifact/target linkages permanecem permitidos sob semântica correta.

## 31. Test plan

O Documento 61 define TNO-T01–T90.

Cobertura inclui:

- target/source;
- authority;
- schedule snapshot;
- opportunity/retry/resolution;
- item/timepoint;
- Artifact drift;
- target drift;
- source debt;
- replay/readiness;
- anti-laundering;
- no real seed;
- rebuild/regression.

Resultado:

> **TEST_PLAN = PASS_FOR_IMPLEMENTATION**

Ainda não executado.

## 32. Migration readiness

O contrato está suficientemente fechado para considerar uma migration de infraestrutura.

Isso não significa que a migration já está autorizada.

Estado:

> **MIGRATION_033 = ELIGIBLE_FOR_SEPARATE_AUTHORIZATION**

A próxima decisão deve avaliar:

- migration scope final;
- file decomposition;
- fixture/test files;
- CI integration;
- whether one migration or fragments are preferable;
- no-seed guarantee;
- rollback/rebuild behavior.

## 33. Measurement schedule continua fora deste bloco

O PASS físico não autoriza selecionar:

- interval;
- opportunity timestamps;
- observation duration;
- number of opportunities.

Esses valores continuam:

> **NOT_SELECTED**

Eles devem vir depois da infraestrutura física e continuar explicitamente não normativos.

## 34. Phase B continua bloqueada

Ainda faltam:

1. migration decision + implementation, se autorizada;
2. technical validation;
3. Plan v0.2 final materialization;
4. finite opportunity set;
5. target-specific gate;
6. explicit Phase B authority.

Logo:

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

## 35. Estado final

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

> **PHASE_5 = NOT_STARTED**

## 36. Próximo passo exato

> **Após checkpoint, em modo alto, decidir a autorização e o boundary técnico da candidate migration 033 para implementar somente a infraestrutura do contrato v0.1, sem seed real e sem measurement schedule.**

**Fim do Documento 63**
