# 61 — Contrato Físico v0.1 para Aquisição Temporal Não Normativa

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **CANDIDATE_FOR_ADVERSARIAL_GATE — MIGRATION_NOT_AUTHORIZED**  
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
4. `maintenance.temporal_observation_authority`;
5. `maintenance.temporal_measurement_opportunity`;
6. `maintenance.temporal_measurement_event`;
7. `maintenance.temporal_measurement_event_artifact`;
8. `maintenance.temporal_observation_deviation`.

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
- `readiness_scope text NOT NULL`;
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
- source rows são imutáveis;
- mudança de source status exige nova PlanVersion.

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
- schedule payload deve passar validator estrito.

## 8. measurement_schedule_payload

Schema lógico:

> **oes.temporal_measurement_schedule/0.1**

Campos permitidos:

- `schema_version`;
- `non_normative` = true;
- `schedule_kind`;
- `rationale`;
- `generation_payload`;
- `review_boundary_at`.

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

Validator candidato:

> **maintenance.temporal_measurement_schedule_payload_is_valid(jsonb)**

O validator não autoriza nenhum número; apenas define shape.

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

Registro append-only de tentativa/resultado associado a uma opportunity.

Campos:

- `measurement_event_uuid uuid PK`;
- `measurement_opportunity_uuid uuid NOT NULL FK`;
- `attempt_no integer NOT NULL CHECK(attempt_no>=1)`;
- `execution_status text NOT NULL CHECK(execution_status IN ('completed','partial','failed','not_executed','indeterminate'))`;
- `execution_started_at timestamptz NULL`;
- `execution_completed_at timestamptz NULL`;
- `result_state text NOT NULL CHECK(result_state IN ('zero','nonzero','unknown','not_applicable'))`;
- `retrieved_identifier_count integer NULL CHECK(retrieved_identifier_count>=0)`;
- `denominator_status text NOT NULL CHECK(denominator_status IN ('known','unknown','not_applicable'))`;
- `denominator_count bigint NULL CHECK(denominator_count>=0)`;
- `failure_attribution text NOT NULL CHECK(failure_attribution IN ('source_confirmed','oes_confirmed','mixed','unknown','not_applicable'))`;
- `source_time_payload jsonb NOT NULL`;
- `oes_detected_at timestamptz NULL`;
- `latency_status text NOT NULL CHECK(latency_status IN ('observable','bounded','not_observable','not_applicable'))`;
- `latency_bounds_payload jsonb NULL`;
- `scientific_search_uuid uuid NULL FK investigation.search`;
- `effort_payload jsonb NOT NULL DEFAULT '{}'::jsonb`;
- `operator text NOT NULL`;
- `actor_type text NOT NULL CHECK(actor_type IN ('system','ai_system','human_reviewer','human_expert','owner'))`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Constraints:

- `UNIQUE(measurement_opportunity_uuid,attempt_no)`;
- rows imutáveis;
- attempt numbers crescentes sem overwrite;
- `not_executed` exige started/completed NULL, result_state=`not_applicable`, denominator_status=`not_applicable`, failure_attribution=`not_applicable`;
- completed/partial/failed exigem `execution_started_at`;
- `execution_completed_at >= execution_started_at` quando ambos;
- `result_state='zero'` exige execution_status=`completed` e retrieved_identifier_count=0;
- `result_state='nonzero'` exige retrieved_identifier_count>0;
- denominator_status=`known` exige denominator_count não NULL;
- denominator_status != known exige denominator_count NULL;
- failure_attribution source_confirmed exige evidence artifact linkage com role `failure_evidence`;
- completed sem falha exige failure_attribution=`not_applicable`;
- scientific_search_uuid só pode existir para evento que realmente executou Search científica;
- Search deve pertencer à Investigation do exact target;
- nenhum FK para MonitorCycle, UpdatePolicy, CadenceContract ou CadenceObligation.

## 12. source_time_payload

Schema lógico:

> **oes.temporal_measurement_source_time/0.1**

Campos permitidos:

- `schema_version`;
- `status` = observed | bounded | not_observable | not_applicable;
- `semantic_code`;
- `source_field`;
- `raw_value`;
- `precision`;
- `timezone_name`;
- `lower_bound_at`;
- `upper_bound_at`;
- `interpretation`.

Precision:

- second;
- minute;
- hour;
- day;
- month;
- year;
- interval;
- unknown.

Regras:

- not_observable/not_applicable não podem fabricar bounds;
- bounded exige lower + upper e upper>=lower;
- observed com date-only não deve ser convertido em fake exact timestamp;
- raw source value deve ser preservável via Artifact quando necessário.

Source-specific allowed semantics:

### PubMed

- publication_date;
- electronic_publication_date;
- print_publication_date;
- create_date;
- entry_date;
- mesh_date;
- not_observable.

### ClinicalTrials.gov

- first_posted_date;
- results_first_posted_date;
- last_update_posted_date;
- qc_submission_date;
- not_observable.

Validator candidato:

> **maintenance.temporal_measurement_source_time_payload_is_valid(source_code,jsonb)**

## 13. latency_bounds_payload

Schema lógico:

> **oes.temporal_measurement_latency/0.1**

Campos:

- `schema_version`;
- `latency_kind`;
- `start_semantic`;
- `end_semantic`;
- `lower_seconds`;
- `upper_seconds`;
- `precision_note`.

Latency kinds:

- publication_to_source;
- source_posting;
- oes_detection;
- oes_processing.

Regras:

- observable pode ter lower=upper somente se endpoints justificarem precisão;
- bounded exige upper>=lower;
- not_observable/not_applicable exige payload NULL;
- source posting não pode ser rotulado article-publication latency.

## 14. effort_payload

Schema lógico mínimo:

> **oes.temporal_measurement_effort/0.1**

Campos opcionais:

- operator_minutes;
- machine_elapsed_seconds;
- retry_count;
- handoff_count;
- note.

Regras:

- valores >=0;
- effort observado não é sustainable capacity;
- payload não pode conter SLA/capacity rating.

## 15. maintenance.temporal_measurement_event_artifact

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

## 16. maintenance.temporal_observation_deviation

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

- opportunity/event, quando presentes, devem pertencer ao epoch;
- row imutável;
- `new_epoch_required` ou `invalidating` deve aparecer como issue bloqueante em readiness/replay;
- deviation não autoriza continuar no mesmo epoch quando materiality != non_material.

## 17. Epoch activation guard

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
- runtime_connectivity_status != blocked;
- nenhuma authority withdrawal;
- nenhuma invalidating deviation.

Para ClinicalTrials.gov em B1:

> runtime_connectivity_status deve ser `verified`.

## 18. Epoch completion guard

Para completed:

- `completed_at` obrigatório;
- review boundary alcançado, salvo early-stop reason permitido registrado como deviation;
- toda opportunity precisa possuir pelo menos um terminal event;
- opportunity sem execução deve ter event `not_executed`;
- nenhuma material deviation não resolvida no mesmo epoch;
- nenhuma source debt pode ser escondida como included/complete;
- completion não emite `no_update_needed`;
- completion não altera currentness.

## 19. Opportunity resolution

Função candidata:

> **maintenance.temporal_measurement_opportunity_status(opportunity_uuid)**

Retorno conceitual:

- planned;
- attempted_open;
- completed;
- partial;
- failed;
- not_executed;
- indeterminate;
- conflicted.

Regra de retries:

- múltiplos attempts são permitidos;
- o histórico inteiro permanece;
- mais de um terminal success incompatível ou outcomes contraditórios => `conflicted`;
- retry não apaga failure anterior.

## 20. Replay view

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
- result_state;
- retrieved_identifier_count;
- denominator status/count;
- failure attribution;
- source time semantic;
- OES detection;
- latency status/bounds;
- artifact counts;
- effort summary;
- deviation count;
- conflict flag.

A view não calcula overdue/compliance.

## 21. Readiness evidence view

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
- denominator-known proportion;
- latency-observable proportion;
- source-confirmed failure count;
- OES-confirmed failure count;
- conflict count;
- effort summary;
- observation window;
- source debt status.

Proibição:

> a view não retorna READY/NOT READY.

Ela entrega evidência ao Evidence Readiness Assessment.

## 22. Issue functions

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
- RESULT_COUNT_INCONSISTENT;
- DENOMINATOR_INCONSISTENT;
- FAILURE_ATTRIBUTION_UNSUPPORTED;
- SOURCE_TIME_INVALID;
- LATENCY_INVALID;
- SEARCH_SEMANTIC_MISMATCH;
- MATERIAL_DEVIATION;
- CONFLICTED_RETRY_HISTORY;
- ARTIFACT_INACTIVE;
- NORMATIVE_LEAKAGE.

## 23. Imutabilidade

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

## 24. No-normative-link guard

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

## 25. BVS/LILACS debt guard

Para TOPI v0.2:

- source row BVS/LILACS = deferred;
- nenhuma epoch_source B1 pode apontar para ela;
- readiness evidence view deve expor deferred source debt;
- B1 completion não pode emitir claim de complete source universe.

O physical contract deve ser reusable; essa regra deriva do source status, não de hard-code de BVS.

## 26. Physical contract versioning

Contract marker candidato:

> **oes.temporal_observation/0.1**

Se implementado, registrar em `maintenance.contract_epoch` somente se essa tabela for semanticamente apropriada ao novo contrato.

Não registrar como temporal normative epoch sem gate específico.

## 27. Candidate migration boundary

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

## 28. Test plan — estrutura

Testes candidatos devem ser implementados separadamente da migration.

Arquivo candidato:

> `database/f4-non-normative-temporal-observation-tests.sql`

Rebuild/smoke devem incluir migration apenas se migration for autorizada.

## 29. Test plan — Plan / source

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

## 30. Test plan — Epoch / authority

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

## 31. Test plan — Opportunities

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

## 32. Test plan — Events

### TNO-T24
attempt unique e append-only.

### TNO-T25
not_executed com timestamp falha.

### TNO-T26
not_executed com result != not_applicable falha.

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

## 33. Test plan — Artifacts / deviations

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

## 34. Test plan — Completion / replay

### TNO-T45
epoch complete com unresolved opportunity falha.

### TNO-T46
not_executed event resolve missing opportunity sem declarar compliance.

### TNO-T47
contradictory terminal attempts => conflicted.

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

## 35. Test plan — Anti-laundering / regression

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

## 36. Test plan — Authority / lifecycle

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

## 37. Estado

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = CANDIDATE_V0_1**

> **PHYSICAL_SCHEMA = SPECIFIED_NOT_IMPLEMENTED**

> **TEST_PLAN = SPECIFIED_NOT_IMPLEMENTED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MIGRATION_033 = CANDIDATE_NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 38. Próximo passo

> **Executar gate adversarial/físico do contrato v0.1, atacando lifecycle, authority, target drift, source debt, retries, time precision, schedule laundering, Search semantics, Artifact semantics, replay, migration scope e integração com os contratos temporais normativos.**

**Fim do Documento 61**
