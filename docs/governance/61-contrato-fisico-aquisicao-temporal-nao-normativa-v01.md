# 61 — Contrato Físico v0.1 para Aquisição Temporal Não Normativa

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **REVISED_READY_FOR_RECHECK — MIGRATION_NOT_AUTHORIZED**  
**Modo:** alto  
**Dependências:** Documentos 51–60; CP115  
**Objeto:** especificar o contrato físico para ObservationEpoch e measurement events pré-calibração sem introduzir semântica normativa

## 1. Princípio

O contrato físico existe para registrar aquisição experimental de evidência temporal antes de qualquer calibration.

Ele deve ser:

- target-specific;
- source-specific;
- versionado;
- replayable;
- append-preserving;
- explicitamente não normativo;
- separado de Monitor/MonitoringCycle;
- separado de CadenceContract/CadenceObservation;
- separado de UpdatePolicy/UpdateSignal.

> **PRE_CALIBRATION_MEASUREMENT != MONITORING != CADENCE COMPLIANCE**

## 2. Namespace

O contrato candidato usa o schema existente:

> **maintenance**

Novos objetos candidatos:

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

Nenhuma tabela é criada por este documento.

## 3. maintenance.temporal_observation_plan

Raiz versionada da instância metodológica.

Campos candidatos:

- `observation_plan_uuid uuid PK`;
- `plan_code text NOT NULL`;
- `plan_version integer NOT NULL CHECK(plan_version>=1)`;
- `supersedes_observation_plan_uuid uuid NULL FK self`;
- `target_product_version_uuid uuid NULL FK product.product_version`;
- `target_investigation_version_uuid uuid NULL FK investigation.investigation_version`;
- `calibration_object text NOT NULL CHECK(calibration_object='cadence')`;
- `readiness_scope text NOT NULL CHECK(readiness_scope IN ('policy_aggregate','source_specific'))`;
- `specification_artifact_uuid uuid NOT NULL FK artifact.artifact`;
- `prepared_at timestamptz NOT NULL`;
- `created_by text NOT NULL`;
- `actor_type text NOT NULL CHECK(actor_type IN ('ai_system','human_reviewer','human_expert','owner'))`;
- `record_status text NOT NULL DEFAULT 'active' CHECK(record_status IN ('active','superseded','invalidated'))`.

Constraints:

- exatamente um target version;
- `UNIQUE(plan_code,plan_version)`;
- supersession mantém `plan_code` e exact target;
- nova version é obrigatória para mudança material do plano;
- plan version é imutável; única mutação admitida é `active → superseded` sem alterar campos materiais.

v0.1 restringe `calibration_object` a `cadence`.

Razão:

> não generalizar fisicamente para SLA/calendar antes de necessidade real e gate próprio.

## 4. Target guard

Ao criar plan ativo:

- target version deve existir;
- target version não pode estar `invalidated` ou `archived`;
- para ProductVersion, deve existir vínculo primary com Investigation quando a execução usar Search científica;
- target supersession após criação não apaga o plan histórico.

Antes de ativar epoch:

> target deve continuar current.

Se deixar de current:

> epoch não pode iniciar; epoch ativo passa a apresentar issue bloqueante.

## 5. maintenance.temporal_observation_source

Candidate source universe versionado pelo plan.

Campos:

- `observation_source_uuid uuid PK`;
- `observation_plan_uuid uuid NOT NULL FK`;
- `source_code text NOT NULL`;
- `source_name text NOT NULL`;
- `source_class text NOT NULL`;
- `inclusion_status text NOT NULL CHECK(inclusion_status IN ('included','deferred','excluded','unassessed'))`;
- `interface_code text NULL`;
- `access_mode text NOT NULL CHECK(access_mode IN ('programmatic','manual','hybrid','unresolved'))`;
- `runtime_connectivity_required boolean NOT NULL DEFAULT false`;
- `time_semantics_payload jsonb NOT NULL`;
- `source_definition_artifact_uuid uuid NULL FK artifact.artifact`;
- `inclusion_rationale text NOT NULL`;
- `debt_reason_code text NULL`;
- `reassessment_trigger text NULL`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`;
- `created_by text NOT NULL`.

Constraints:

- `UNIQUE(observation_plan_uuid,source_code)`;
- `deferred` exige `debt_reason_code` e `reassessment_trigger`;
- `included` não pode ter `debt_reason_code`;
- `time_semantics_payload` deve usar schema `oes.temporal_source_semantics/0.1` e listar semantic codes permitidos pela source;
- source rows são imutáveis;
- mudança de source status, access mode ou time semantics exige nova PlanVersion.

Para TOPI v0.2:

- PubMed = included;
- ClinicalTrials.gov = included;
- BVS/LILACS = deferred.

## 6. maintenance.temporal_observation_epoch

Um epoch congela um desenho executável.

Campos:

- `observation_epoch_uuid uuid PK`;
- `observation_plan_uuid uuid NOT NULL FK`;
- `epoch_code text NOT NULL`;
- `epoch_status text NOT NULL CHECK(epoch_status IN ('draft','authorized_non_normative','active','completed','invalidated'))`;
- `measurement_design_artifact_uuid uuid NOT NULL FK artifact.artifact`;
- `start_boundary_at timestamptz NOT NULL`;
- `review_boundary_at timestamptz NOT NULL`;
- `started_at timestamptz NULL`;
- `completed_at timestamptz NULL`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`;
- `created_by text NOT NULL`.

Constraints:

- `UNIQUE(observation_plan_uuid,epoch_code)`;
- `review_boundary_at > start_boundary_at`;
- start/review boundaries são imutáveis;
- target deve estar current para `authorized_non_normative` e `active`;
- `started_at` obrigatório a partir de active;
- `completed_at` somente em completed;
- invalidation preserva histórico;
- mudança material de desenho exige novo epoch ou nova PlanVersion, não edição de boundaries.

## 7. Epoch source snapshot

A v0.1 deve criar relação explícita entre epoch e sources incluídas.

Objeto candidato adicional:

> **maintenance.temporal_observation_epoch_source**

Campos:

- `epoch_source_uuid uuid PK`;
- `observation_epoch_uuid uuid NOT NULL FK`;
- `observation_source_uuid uuid NOT NULL FK`;
- `query_strategy_artifact_uuid uuid NULL FK artifact.artifact`;
- `interface_config_artifact_uuid uuid NULL FK artifact.artifact`;
- `baseline_artifact_uuid uuid NULL FK artifact.artifact`;
- `measurement_investigation_version_uuid uuid NULL FK investigation.investigation_version`;
- `runtime_interface_code text NOT NULL`;
- `measurement_schedule_payload jsonb NOT NULL`;
- `runtime_connectivity_status text NOT NULL CHECK(runtime_connectivity_status IN ('unverified','verified','blocked'))`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- `UNIQUE(observation_epoch_uuid,observation_source_uuid)`;
- source precisa pertencer ao mesmo plan;
- source precisa estar `included`;
- row é imutável;
- query artifact obrigatório quando measurement envolver query científica ou registry query;
- `measurement_investigation_version_uuid`, quando presente, deve ser o exact Investigation target ou uma Investigation vinculada ao ProductVersion target;
- baseline artifact congela a referência usada para classificar item como `new_to_epoch`, `reobserved` ou `updated_record`;
- schedule payload deve passar validator estrito;
- se a source tiver `runtime_connectivity_required=true`, activation exige `runtime_connectivity_status='verified'`.

## 8. measurement_schedule_payload

Schema lógico:

> **oes.temporal_measurement_schedule/0.1**

Campos permitidos:

- `schema_version`;
- `non_normative` = true;
- `schedule_kind`;
- `rationale`;
- `generation_payload`.

`schedule_kind`:

- `fixed_elapsed_experimental`;
- `calendar_opportunity_set`;
- `manual_opportunity_set`.

Proibições de chave no payload:

- `cadence`;
- `due`;
- `overdue`;
- `breach`;
- `grace`;
- `warning`;
- `sla`;
- `compliance`;
- `penalty`;
- `escalation`.

Validators candidatos:

> **maintenance.jsonb_contains_forbidden_temporal_keys(jsonb)**

> **maintenance.temporal_measurement_schedule_payload_is_valid(jsonb)**

A proibição de keys normativas é recursiva em qualquer profundidade do JSON.

O validator não autoriza nenhum número; apenas define shape.

O `review_boundary_at` existe somente em `temporal_observation_epoch`; o schedule payload não pode duplicá-lo.

## 9. maintenance.temporal_observation_authority

Authority é append-only e explicitamente scoped.

Campos:

- `observation_authority_uuid uuid PK`;
- `observation_plan_uuid uuid NOT NULL FK`;
- `observation_epoch_uuid uuid NULL FK`;
- `authority_domain text NOT NULL CHECK(authority_domain IN ('operational_execution','data_governance','scientific_methodological'))`;
- `decision text NOT NULL CHECK(decision IN ('approved','revise','rejected','withdrawn'))`;
- `actor text NOT NULL`;
- `actor_type text NOT NULL CHECK(actor_type IN ('human_reviewer','human_expert','owner'))`;
- `decision_artifact_uuid uuid NOT NULL FK artifact.artifact`;
- `decided_at timestamptz NOT NULL`;
- `limitations_payload jsonb NOT NULL DEFAULT '{}'::jsonb`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- epoch, quando informado, deve pertencer ao plan;
- rows imutáveis;
- `authorized_non_normative` exige approved `operational_execution` authority para o exact epoch;
- withdrawal posterior gera issue bloqueante para epoch ativo;
- AI/system não pode ser authority row actor.

## 10. maintenance.temporal_measurement_opportunity

Representa o que estava planejado, inclusive quando nada foi executado.

Campos:

- `measurement_opportunity_uuid uuid PK`;
- `epoch_source_uuid uuid NOT NULL FK`;
- `opportunity_no integer NOT NULL CHECK(opportunity_no>=1)`;
- `planned_for timestamptz NOT NULL`;
- `opportunity_origin text NOT NULL CHECK(opportunity_origin IN ('schedule_generated','manual_protocol'))`;
- `schedule_snapshot_artifact_uuid uuid NULL FK artifact.artifact`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- `UNIQUE(epoch_source_uuid,opportunity_no)`;
- `UNIQUE(epoch_source_uuid,planned_for)`;
- opportunity deve cair dentro de start/review boundary;
- opportunity é imutável;
- retries não criam nova opportunity;
- opportunity não é obligation, due ou compliance item.

## 11. maintenance.temporal_measurement_event

Registro append-only de tentativa de execução associado a uma opportunity.

O event é **query/execution-level**, não item-level.

Campos:

- `measurement_event_uuid uuid PK`;
- `measurement_opportunity_uuid uuid NOT NULL FK`;
- `attempt_no integer NOT NULL CHECK(attempt_no>=1)`;
- `execution_status text NOT NULL CHECK(execution_status IN ('completed','partial','failed','indeterminate'))`;
- `execution_started_at timestamptz NULL`;
- `execution_completed_at timestamptz NULL`;
- `novelty_state text NOT NULL CHECK(novelty_state IN ('zero_new','new_items','unknown','not_applicable'))`;
- `raw_result_count bigint NULL CHECK(raw_result_count>=0)`;
- `raw_result_count_status text NOT NULL CHECK(raw_result_count_status IN ('known','unknown','not_applicable'))`;
- `materialized_identifier_count integer NULL CHECK(materialized_identifier_count>=0)`;
- `new_identifier_count integer NULL CHECK(new_identifier_count>=0)`;
- `failure_attribution text NOT NULL CHECK(failure_attribution IN ('source_confirmed','oes_confirmed','mixed','unknown','not_applicable'))`;
- `failure_evidence_artifact_uuid uuid NULL FK artifact.artifact`;
- `scientific_search_uuid uuid NULL FK investigation.search`;
- `effort_payload jsonb NOT NULL DEFAULT '{}'::jsonb`;
- `operator text NOT NULL`;
- `actor_type text NOT NULL CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner'))`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- `UNIQUE(measurement_opportunity_uuid,attempt_no)`;
- rows imutáveis;
- attempt_no deve ser exatamente o próximo inteiro contíguo da opportunity;
- todo MeasurementEvent representa uma tentativa realmente iniciada e exige `execution_started_at`;
- ausência de execução é registrada em OpportunityResolution, não como MeasurementEvent;
- completed/partial/failed/indeterminate exigem `execution_started_at`;
- `execution_completed_at >= execution_started_at` quando ambos;
- raw_result_count_status=`known` exige raw_result_count não NULL;
- raw_result_count_status != known exige raw_result_count NULL;
- novelty_state=`zero_new` exige new_identifier_count=0;
- novelty_state=`new_items` exige new_identifier_count>0;
- source_confirmed ou mixed exige `failure_evidence_artifact_uuid` active;
- completed sem incidente exige failure_attribution=`not_applicable`;
- scientific_search_uuid só pode existir para Search científica realmente executada;
- Search deve pertencer ao `measurement_investigation_version_uuid` congelado em EpochSource;
- nenhum FK para MonitorCycle, UpdatePolicy, CadenceContract ou CadenceObligation.

### 11.1 Retry/closure guard

Função candidata:

> **maintenance.assert_temporal_measurement_event_append()**

Regras:

- primeiro attempt = 1;
- attempts seguintes são contíguos;
- retry só é permitido após failed, partial ou indeterminate;
- após completed com novelty_state determinado, nenhuma nova tentativa;
- mais de um successful completed é inválido;
- histórico anterior nunca é alterado.

Opportunity resolution é derivada, não armazenada por update.

## 12. maintenance.temporal_measurement_opportunity_resolution

Closure append-only da opportunity, separado dos attempts.

Campos:

- `opportunity_resolution_uuid uuid PK`;
- `measurement_opportunity_uuid uuid NOT NULL UNIQUE FK`;
- `resolution_status text NOT NULL CHECK(resolution_status IN ('completed','failed_closed','not_executed','indeterminate_closed','invalidated'))`;
- `terminal_measurement_event_uuid uuid NULL FK maintenance.temporal_measurement_event`;
- `reason_code text NOT NULL`;
- `reason_artifact_uuid uuid NULL FK artifact.artifact`;
- `resolved_at timestamptz NOT NULL`;
- `resolved_by text NOT NULL`;
- `actor_type text NOT NULL CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner'))`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- row imutável;
- exactly one resolution per opportunity;
- `completed` exige terminal event da mesma opportunity com execution_status=`completed`;
- `failed_closed` exige terminal event da mesma opportunity com execution_status=`failed`;
- `indeterminate_closed` exige terminal event da mesma opportunity com execution_status=`indeterminate`;
- `not_executed` exige ausência de MeasurementEvent para a opportunity e reason_code explícito;
- `invalidated` exige epoch invalidated ou material deviation correspondente;
- resolução não pode ocorrer antes de `planned_for`, exceto invalidation causal anterior explicitamente documentada;
- resolution não representa compliance, overdue ou breach.

A resolução permite fechar missingness/falha sem sobrescrever attempts.

## 13. maintenance.temporal_measurement_item

Representa um identificador/registro observado dentro de um measurement event.

Campos:

- `measurement_item_uuid uuid PK`;
- `measurement_event_uuid uuid NOT NULL FK`;
- `source_identifier text NOT NULL`;
- `source_locator text NULL`;
- `item_state text NOT NULL CHECK(item_state IN ('new_to_epoch','reobserved','updated_record','indeterminate'))`;
- `oes_detected_at timestamptz NOT NULL`;
- `search_hit_uuid uuid NULL FK investigation.search_hit`;
- `source_record_artifact_uuid uuid NULL FK artifact.artifact`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- `UNIQUE(measurement_event_uuid,source_identifier)`;
- source identifier não vazio;
- row imutável;
- event deve estar completed ou partial;
- item source deve corresponder ao EpochSource;
- SearchHit, quando presente, deve derivar da scientific_search_uuid do event;
- `new_to_epoch` significa novo em relação ao baseline/observações anteriores do epoch, nunca “novo na ciência”;
- reobserved/updated_record exigem existência anterior do normalized identifier no mesmo epoch ou baseline.

Helper candidato:

> **maintenance.temporal_measurement_item_state_is_valid(item_uuid)**

## 14. maintenance.temporal_measurement_item_timepoint

Uma row por endpoint temporal source-level do item.

Campos:

- `measurement_item_timepoint_uuid uuid PK`;
- `measurement_item_uuid uuid NOT NULL FK`;
- `semantic_code text NOT NULL`;
- `source_field text NULL`;
- `raw_value text NULL`;
- `precision text NOT NULL CHECK(precision IN ('second','minute','hour','day','month','year','interval','unknown'))`;
- `timezone_name text NULL`;
- `lower_bound_at timestamptz NULL`;
- `upper_bound_at timestamptz NULL`;
- `observability_status text NOT NULL CHECK(observability_status IN ('observed','bounded','not_observable','not_applicable'))`;
- `source_artifact_uuid uuid NULL FK artifact.artifact`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- `UNIQUE(measurement_item_uuid,semantic_code)`;
- semantic_code deve pertencer ao `time_semantics_payload` da ObservationSource;
- bounded exige lower+upper e upper>=lower;
- observed pode preservar raw date sem fake timestamp;
- not_observable/not_applicable não podem fabricar bounds;
- rows imutáveis.

## 15. Latency é derivada, não persistida como verdade material

No v0.1 não existe `latency_bounds_payload` na event/item row.

Helper candidato:

> **maintenance.temporal_measurement_item_latency(item_uuid,semantic_code,as_of_detected_at)**

Retorna:

- latency_kind;
- observability_status;
- lower_seconds;
- upper_seconds;
- precision_note;
- calculator_version.

A função deriva bounds a partir de:

- MeasurementItemTimepoint;
- `MeasurementItem.oes_detected_at`.

Se os endpoints não suportarem derivação:

> **LATENCY_NOT_OBSERVABLE**

Isso elimina dual truth entre endpoint persistido e latency calculada.

## 15A. effort_payload

Schema lógico:

> **oes.temporal_measurement_effort/0.1**

Allowed keys, sem nested arbitrary payload:

- `operator_minutes`;
- `machine_elapsed_seconds`;
- `retry_count`;
- `handoff_count`;
- `note`.

Regras:

- números >=0;
- note text;
- nenhuma key adicional;
- nenhuma rating de B5/SLA/capacity;
- forbidden temporal keys recursivos continuam bloqueados.

Validator candidato:

> **maintenance.temporal_measurement_effort_payload_is_valid(jsonb)**

## 16. maintenance.temporal_measurement_event_artifact

Permite múltiplos Artifacts por event sem inflar a row principal.

Campos:

- `measurement_event_uuid uuid NOT NULL FK`;
- `artifact_uuid uuid NOT NULL FK artifact.artifact`;
- `artifact_role text NOT NULL CHECK(artifact_role IN ('query_snapshot','result_snapshot','identifier_set','failure_evidence','source_documentation','other'))`;
- `sequence_no integer NULL`;
- PK composta `(measurement_event_uuid,artifact_uuid,artifact_role)`.

Constraints:

- Artifact deve estar active;
- link imutável;
- payload sensível/secret é proibido por governance, não apenas por tipo.

## 17. maintenance.temporal_observation_deviation

Registra desvio sem editar design original.

Campos:

- `deviation_uuid uuid PK`;
- `observation_epoch_uuid uuid NOT NULL FK`;
- `measurement_opportunity_uuid uuid NULL FK`;
- `measurement_event_uuid uuid NULL FK`;
- `deviation_type text NOT NULL CHECK(deviation_type IN ('execution_delay','source_access','runtime_change','query_change','interface_change','source_scope_change','authority_change','data_governance','other'))`;
- `materiality text NOT NULL CHECK(materiality IN ('non_material','new_epoch_required','invalidating'))`;
- `description text NOT NULL`;
- `evidence_artifact_uuid uuid NULL FK artifact.artifact`;
- `recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`;
- `recorded_by text NOT NULL`.

Constraints:

- event, quando presente, determina sua opportunity e epoch;
- opportunity, quando presente, deve pertencer ao epoch;
- se event e opportunity forem ambos informados, devem ser causalmente consistentes;
- row imutável;
- `new_epoch_required` ou `invalidating` deve aparecer como issue bloqueante em readiness/replay;
- deviation não autoriza continuar no mesmo epoch quando materiality != non_material.

## 18. Epoch activation guard

Função candidata:

> **maintenance.assert_temporal_observation_epoch_activation()**

Para `authorized_non_normative` / `active`, exigir:

- plan ativo;
- exact target current;
- approved operational_execution authority para epoch;
- pelo menos uma epoch_source;
- todas epoch_sources pertencem ao plan e são included;
- measurement design Artifact active;
- schedule payloads válidos;
- para toda source com `runtime_connectivity_required=true`, runtime_connectivity_status = verified;
- controlling authority state = approved via resolver;
- nenhum authority conflict/withdrawal;
- nenhuma invalidating deviation.

Não existe hard-code de source brand no activation guard.

## 19. Epoch completion guard

Para completed:

- `completed_at` obrigatório;
- `completed_at >= review_boundary_at`;
- não existe early completion no v0.1;
- toda opportunity precisa possuir exatamente uma OpportunityResolution;
- nenhuma deviation `new_epoch_required` ou `invalidating` no epoch;
- nenhuma source debt pode ser escondida como included/complete;
- completion não emite `no_update_needed`;
- completion não altera currentness.

## 20. Opportunity resolution

Função candidata:

> **maintenance.temporal_measurement_opportunity_status(opportunity_uuid)**

Retorno a partir de OpportunityResolution:

- planned;
- retryable;
- completed;
- failed_closed;
- not_executed;
- indeterminate_closed;
- invalidated;
- conflicted.

Regras:

- sem resolution, failed/partial/indeterminate attempts permanecem retryable enquanto epoch ativo;
- completed MeasurementEvent deve ser seguido por resolution `completed`;
- persistent failure pode ser encerrada por `failed_closed`;
- ausência total de attempt pode ser encerrada por `not_executed`;
- history de attempts permanece;
- mais de uma resolution é impossível por UNIQUE;
- mismatch entre terminal event e resolution => `conflicted`.

## 21. Replay view

View candidata:

> **maintenance.temporal_measurement_replay_v**

Uma linha por opportunity com:

- plan;
- epoch;
- target;
- source;
- planned_for;
- attempt_count;
- terminal_status derivado;
- first_started_at;
- last_completed_at;
- novelty_state;
- raw result count/status;
- materialized/new identifier counts;
- measurement item count;
- failure attribution;
- per-item OES detection;
- per-item timepoints;
- derived latency observability;
- artifact counts;
- effort summary;
- deviation count;
- conflict flag.

A view não calcula overdue/compliance.

## 22. Readiness evidence view

View candidata:

> **maintenance.temporal_measurement_readiness_evidence_v**

Agrega por plan/epoch/source:

- planned opportunities;
- completed;
- partial;
- failed;
- not_executed;
- indeterminate;
- missingness proportion descritiva;
- raw-count-known proportion;
- item-level latency-observable proportion;
- source-confirmed failure count;
- OES-confirmed failure count;
- conflict count;
- effort summary;
- observation window;
- source debt status.

Proibição:

> a view não retorna READY/NOT READY.

Ela entrega evidência ao Evidence Readiness Assessment.

## 23. Issue functions

Funções candidatas:

- `maintenance.temporal_observation_plan_issues(plan_uuid)`;
- `maintenance.temporal_observation_epoch_issues(epoch_uuid)`;
- `maintenance.temporal_measurement_event_issues(event_uuid)`.

Issue classes mínimas:

- TARGET_NOT_CURRENT;
- SOURCE_SCOPE_MISMATCH;
- SOURCE_DEBT_HIDDEN;
- AUTHORITY_MISSING;
- AUTHORITY_WITHDRAWN;
- RUNTIME_CONNECTIVITY_UNVERIFIED;
- INVALID_SCHEDULE_PAYLOAD;
- OPPORTUNITY_OUTSIDE_BOUNDARY;
- OPPORTUNITY_UNRESOLVED;
- EVENT_TIME_INCONSISTENT;
- RAW_RESULT_COUNT_INCONSISTENT;
- NOVELTY_COUNT_INCONSISTENT;
- FAILURE_ATTRIBUTION_UNSUPPORTED;
- SOURCE_TIME_SEMANTIC_INVALID;
- ITEM_STATE_INVALID;
- LATENCY_NOT_DERIVABLE;
- SEARCH_SEMANTIC_MISMATCH;
- MATERIAL_DEVIATION;
- CONFLICTED_RETRY_HISTORY;
- ARTIFACT_INACTIVE;
- NORMATIVE_LEAKAGE.

## 24. Imutabilidade

Imutáveis:

- plan material fields;
- source rows;
- epoch boundaries/design;
- epoch_source rows;
- authority rows;
- opportunities;
- measurement events;
- artifact links;
- deviations.

Mutação permitida:

### plan

- active → superseded somente, sem material-field changes.

### epoch

transições lifecycle controladas:

- draft → authorized_non_normative;
- authorized_non_normative → active;
- active → completed;
- draft/authorized/active → invalidated.

Somente campos lifecycle correspondentes podem mudar.

Nenhum DELETE em objetos causais.

## 25. No-normative-link guard

A migration futura deve provar que nenhum novo objeto possui FK obrigatório ou semântica de satisfação para:

- UpdatePolicy;
- CadenceContract;
- CadenceObligation;
- CadenceObservation;
- SLARule;
- SLAInstance;
- Monitor ProductVersion;
- MonitoringCycle.

Links científicos opcionais permitidos:

- exact target;
- Investigation Search real;
- Artifact.

## 26. BVS/LILACS debt guard

Para TOPI v0.2:

- source row BVS/LILACS = deferred;
- nenhuma epoch_source B1 pode apontar para ela;
- readiness evidence view deve expor deferred source debt;
- B1 completion não pode emitir claim de complete source universe.

O physical contract deve ser reusable; essa regra deriva do source status, não de hard-code de BVS.

## 27. Physical contract versioning

Contract marker lógico candidato:

> **oes.temporal_observation/0.1**

O v0.1 **não reutiliza `maintenance.contract_epoch`**, pois o marker existente pertence à infraestrutura temporal normativa da migration 032.

Se a implementação precisar de marker persistido, a migration specification deverá propor um marker explicitamente não normativo e submetê-lo ao gate físico.

## 28. Candidate migration boundary

Se futuro gate autorizar implementação:

candidate migration:

> **033_non_normative_temporal_observation.sql**

Escopo máximo:

- tabelas/constraints/triggers/views/functions deste contrato;
- zero seed de schedule;
- zero plan real;
- zero authority real;
- zero measurement opportunity real;
- zero event real;
- zero normative temporal value.

O número/nome é candidato, não autorizado por este documento.

## 29. Test plan — estrutura

Testes candidatos devem ser implementados separadamente da migration.

Arquivo candidato:

> `database/f4-non-normative-temporal-observation-tests.sql`

Rebuild/smoke devem incluir migration apenas se migration for autorizada.

## 30. Test plan — Plan / source

### TNO-T01
XOR exact target.

### TNO-T02
plan_code/version unique.

### TNO-T03
supersession mantém family/target.

### TNO-T04
material plan mutation bloqueada.

### TNO-T05
source unique por plan.

### TNO-T06
deferred exige debt reason + reassessment trigger.

### TNO-T07
included proíbe debt reason.

### TNO-T08
source row immutable.

## 31. Test plan — Epoch / authority

### TNO-T09
review boundary > start boundary.

### TNO-T10
epoch source deve ser included.

### TNO-T11
cross-plan epoch/source bloqueado.

### TNO-T12
authorized epoch sem operational authority falha.

### TNO-T13
AI actor não cria authority.

### TNO-T14
withdrawn authority gera blocking issue.

### TNO-T15
target non-current bloqueia activation.

### TNO-T16
CTG runtime unverified bloqueia B1 activation.

### TNO-T17
invalidating deviation bloqueia activation/completion.

### TNO-T18
schedule payload com normative key é rejeitado.

## 32. Test plan — Opportunities

### TNO-T19
opportunity unique por source/no.

### TNO-T20
duplicate planned_for na mesma source bloqueada.

### TNO-T21
planned_for fora do epoch bloqueado.

### TNO-T22
opportunity immutable.

### TNO-T23
retry não cria nova opportunity automaticamente.

## 33. Test plan — Events

### TNO-T24
attempt unique e append-only.

### TNO-T25
OpportunityResolution `not_executed` com MeasurementEvent existente falha.

### TNO-T26
OpportunityResolution terminal event cross-opportunity falha.

### TNO-T27
completed sem start falha.

### TNO-T28
completed_at < started_at falha.

### TNO-T29
zero com retrieved count !=0 falha.

### TNO-T30
nonzero com count <=0 falha.

### TNO-T31
denominator known sem count falha.

### TNO-T32
denominator unknown com count preenchido falha.

### TNO-T33
source_confirmed sem failure evidence falha.

### TNO-T34
completed success com failure attribution material falha.

### TNO-T35
invalid source time payload falha.

### TNO-T36
invalid latency payload falha.

### TNO-T37
date-only não é automaticamente promoted a exact second timestamp.

### TNO-T38
scientific_search cross-investigation falha.

### TNO-T39
probe sem Search aceita scientific_search_uuid NULL.

## 34. Test plan — Artifacts / deviations

### TNO-T40
inactive artifact link falha.

### TNO-T41
artifact link immutable.

### TNO-T42
deviation cross-epoch falha.

### TNO-T43
material deviation aparece em issue function.

### TNO-T44
deviation immutable.

## 35. Test plan — Completion / replay

### TNO-T45
epoch complete com unresolved opportunity falha.

### TNO-T46
OpportunityResolution `not_executed` fecha missing opportunity sem declarar compliance.

### TNO-T47
resolution/event mismatch => conflicted.

### TNO-T48
retry preserva failure anterior.

### TNO-T49
replay view mantém source-specific rows.

### TNO-T50
readiness view expõe deferred source debt.

### TNO-T51
readiness view não retorna READY flag.

### TNO-T52
completion não altera CurrencyState.

### TNO-T53
completion não cria UpdateSignal.

### TNO-T54
completion não cria CadenceObservation.

## 36. Test plan — Anti-laundering / regression

### TNO-T55
nenhum FK causal obrigatório para CadenceContract/Obligation.

### TNO-T56
nenhum FK causal obrigatório para MonitorCycle.

### TNO-T57
nenhum schedule payload aceita overdue/breach/grace/SLA.

### TNO-T58
M1 target permanece M1.

### TNO-T59
BVS deferred não pode ser silently included no B1.

### TNO-T60
no seed real após migration.

### TNO-T61
idempotência.

### TNO-T62
rebuild completo continua PASS.

### TNO-T63
regressões F2–F4 continuam PASS.

## 37. Test plan — Authority / lifecycle

### TNO-T64
approval da Phase A não autoriza epoch B1.

### TNO-T65
authority artifact obrigatório.

### TNO-T66
epoch authority scope mismatch falha.

### TNO-T67
authority withdrawal não apaga execução histórica.

### TNO-T68
epoch invalidation não apaga events.

### TNO-T69
plan supersession não reparenta epoch antigo.

### TNO-T70
new plan version não reutiliza schedule snapshot por inferência.


## 38A. Authority state resolver

Resolver candidato:

> **maintenance.temporal_observation_authority_state(epoch_uuid,authority_domain,as_of)**

Regras:

- somente authority rows do exact plan/epoch;
- decision Artifact deve existir e estar active no momento de activation;
- decisões ordenadas por `decided_at`;
- approved seguido de withdrawn => withdrawn;
- decisões concorrentes/ambíguas => conflict;
- activation/execution exige current state = approved para `operational_execution`;
- historical events não são apagados por withdrawal posterior.

## 38B. Target drift guard

Se exact target deixar de current durante epoch ativo:

- nenhuma nova opportunity pode ser criada;
- nenhum novo attempt operacional pode iniciar;
- epoch não pode completed;
- issue `TARGET_NOT_CURRENT` é bloqueante;
- epoch deve ser invalidated;
- dados históricos permanecem.

## 38C. Source semantics registry

Schema lógico:

> **oes.temporal_source_semantics/0.1**

Campos:

- schema_version;
- semantic_codes[];
- identifier_semantic;
- source_class;
- notes.

Nenhuma source brand é hard-coded em trigger.

PubMed e ClinicalTrials.gov serão configurados por rows/artifacts de source, não por branches específicos no schema.

## 38D. Schedule reproducibility

Helper candidato:

> **maintenance.temporal_epoch_opportunity_set_matches_schedule(epoch_uuid)**

Regras:

- deterministic schedule generator => opportunity rows devem reproduzir exatamente o generator snapshot;
- manual_opportunity_set => frozen Artifact deve enumerar timestamps e rows devem ser iguais ao Artifact;
- nenhuma oportunidade extra silenciosa;
- nenhuma opportunity faltante silenciosa.

## 38E. Artifact liveness

Em criação/activation:

- controlling plan/design/authority/query/baseline Artifact deve estar active.

Drift posterior:

- não reescreve rows;
- aparece em issue functions;
- pode invalidar epoch conforme papel do Artifact.

## 38F. Epoch completion versus source-universe debt

A view deve distinguir:

- `epoch_execution_completed`;
- `candidate_source_debt_present`.

O v0.1 não expõe `coverage_complete` global.

BVS/LILACS deferred continua visível mesmo quando B1 execution for completed.

## 38G. contract_epoch

O contrato v0.1 **não reutiliza** `maintenance.contract_epoch`.

Razão:

> seu significado atual pertence à infraestrutura temporal normativa da migration 032.

Se futura migration precisar de marker próprio, criar mecanismo explicitamente não normativo ou justificar extensão por gate separado.

## 38H. Migration/fixture separation

Candidate migration 033, se autorizada:

- cria apenas schema/functions/views/triggers;
- zero real plan/source/authority/epoch/opportunity/event;
- zero numeric schedule.

Synthetic tests/fixtures:

- ficam em arquivo separado;
- identificados como synthetic/test-only;
- não podem ser usados como readiness evidence real.

## 38I. Testes adicionais pós-gate

Adicionar:

- **TNO-T71** multi-item event preserva timepoints por item;
- **TNO-T72** raw_result_count e new_identifier_count não se confundem;
- **TNO-T73** reobserved item não conta como new_to_epoch;
- **TNO-T74** source semantic não declarado é rejeitado;
- **TNO-T75** authority resolver approved→withdrawn;
- **TNO-T76** authority conflict bloqueia activation;
- **TNO-T77** schedule deterministic mismatch bloqueia activation/completion;
- **TNO-T78** manual opportunity set deve igual snapshot;
- **TNO-T79** retry attempt number gap é rejeitado;
- **TNO-T80** retry após completed é rejeitado;
- **TNO-T81** attempt após not_executed é rejeitado;
- **TNO-T82** target drift bloqueia novas opportunities/attempts;
- **TNO-T83** Artifact controlling drift aparece em issues;
- **TNO-T84** epoch_execution_completed não oculta source debt;
- **TNO-T85** source connectivity rule é data-driven, não hard-coded;
- **TNO-T86** latency é derivada de item timepoints;
- **TNO-T87** fake second precision a partir de date-only é rejeitada;
- **TNO-T88** scientific Search deve usar frozen measurement Investigation;
- **TNO-T89** migration não contém seed real;
- **TNO-T90** synthetic fixtures não entram em real readiness evidence.


## 38J. Cross-row deferred consistency

Relações em que o pai precisa existir antes dos filhos devem usar validação transacional apropriada.

Casos:

- Event counts versus MeasurementItems;
- completed event versus item materialization;
- failure evidence liveness;
- schedule snapshot versus opportunity set.

Quando a consistência só puder ser validada após múltiplos INSERTs da mesma transação, usar:

> **DEFERRABLE INITIALLY DEFERRED constraint trigger**

ou issue/closure function acionada antes de resolution/epoch completion.

Não exigir child pré-existente no INSERT do parent.

## 39. Estado

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = REVISED_V0_1_READY_FOR_RECHECK**

> **PHYSICAL_SCHEMA = REVISED_NOT_IMPLEMENTED**

> **TEST_PLAN = SPECIFIED_NOT_IMPLEMENTED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MIGRATION_033 = CANDIDATE_NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 40. Próximo passo

> **Executar recheck adversarial/físico final do contrato revisado v0.1. Somente um PASS poderá abrir decisão separada sobre autorização da migration 033.**

**Fim do Documento 61**
