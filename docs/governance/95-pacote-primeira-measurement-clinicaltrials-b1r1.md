# 95 — Pacote Operacional da Primeira Measurement Real ClinicalTrials.gov do B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data de preparação:** 8 de outubro de 2026  
**Status:** **READY_FOR_FIRST_REAL_CLINICALTRIALS_OPPORTUNITY — NO_SOURCE_QUERY_EXECUTED**  
**Modo de preparação:** médio  
**Modo de execução factual:** alto  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 78, 82, 88, 90, 92–94; migration 036; CP138  
**Objeto:** preparar a primeira Opportunity real ClinicalTrials.gov sem executar consulta target-specific nem criar MeasurementEvent antecipado.

## 1. Opportunity controladora

Opportunity UUID:

`b3140000-0000-0000-0000-000000000023`

EpochSource UUID:

`b3130000-0000-0000-0000-000000000004`

Timestamp:

`2026-10-19T10:30:00-03:00`

## 2. Pré-condições

Antes de qualquer source request:

- B1R1 = active;
- started_at factual e válido;
- current time >= planned_for;
- target current;
- authority approved;
- Opportunity unresolved;
- zero blocking material deviation;
- frozen ClinicalTrials.gov query/interface artifacts ativos;
- precheck read-only = READY.

## 3. Precheck read-only

Arquivo:

`database/f4-topi-n2-dcbti-b1r1-first-clinicaltrials-precheck-readonly.sql`

Ele captura:

- epoch status;
- started_at;
- target currentness;
- authority state;
- resolution state;
- prior attempt count;
- prior completed ClinicalTrials.gov count;
- blocking deviations;
- expected attempt_no;
- baseline/subsequent semantics if completed.

Antes da activation ou antes de 10:30, o esperado é:

> **NOT_READY**

Após activation válida e às/apos 10:30, sem blockers:

> **READY**

## 4. Frozen ClinicalTrials.gov request

Endpoint:

`https://clinicaltrials.gov/api/v2/studies`

Method:

`GET`

Normalized parameters:

- `query.cond=insomnia`;
- `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
- `format=json`;
- `pageSize=10`.

Proibido adicionar:

- status filter;
- phase filter;
- location filter;
- intervention filter;
- sort;
- date filter;
- termo científico adicional.

## 5. Pagination contract

Primeira página:

- sem `pageToken`.

Para cada resposta com `nextPageToken`:

- usar exatamente o token retornado em `pageToken`;
- preservar os mesmos parâmetros científicos;
- continuar até ausência de novo token.

Completed somente se:

- todas as páginas forem obtidas;
- todas forem parseadas;
- nenhum token esperado ficar sem seguimento;
- o conjunto final de NCT IDs estiver materializado.

## 6. Evidence a preservar antes da escrita no banco

Registrar factualmente:

- request started_at;
- request completed_at;
- normalized request parameters;
- page sequence;
- page tokens não sensíveis;
- HTTP/runtime status;
- raw page/result snapshots;
- NCT ID identifier set;
- parse/completeness evidence;
- minimal record extraction;
- operator/machine timing;
- retry count;
- failure evidence, se houver.

## 7. Minimal record contract

Quando disponíveis, preservar:

- NCTId;
- BriefTitle;
- OverallStatus;
- StudyFirstPostDate;
- ResultsFirstPostDate;
- LastUpdatePostDate.

Não exigir payload clínico integral para validade temporal.

## 8. Decision table de status

### completed

Somente se:

- paginação terminou normalmente;
- todas as páginas foram parseadas;
- identifier set completo foi materializado.

### partial

Se:

- records/identifiers factuais foram obtidos;
- uma página posterior falhou ou completude não foi alcançada.

### failed

Se a tentativa falhou factualmente sem execução completa.

### indeterminate

Se não for possível classificar honestamente como completed/partial/failed.

## 9. First completed ClinicalTrials.gov semantics

Se esta for a primeira ClinicalTrials.gov observation `completed`:

- `novelty_state=not_applicable`;
- `new_identifier_count=NULL`;
- `failure_attribution=not_applicable`.

Migration 036 impõe isso fisicamente.

A existência de uma PubMed baseline anterior não altera essa regra.

## 10. Zero results

Se a paginação completa comprovar conjunto vazio:

- `raw_result_count_status=known`;
- `raw_result_count=0`;
- `materialized_identifier_count=0`.

Se for a primeira completed ClinicalTrials.gov observation:

- novelty_state = not_applicable;
- new_identifier_count = NULL.

Zero results não é falha.

## 11. Página intermediária falha

Se páginas anteriores geraram NCT IDs factuais e auditáveis:

> **execution_status=partial**

Normalmente:

- raw_result_count_status = unknown;
- raw_result_count = NULL;
- materialized_identifier_count = quantidade factual obtida;
- items podem ser persistidos;
- successful source baseline não é estabelecida.

## 12. Token repetido/ciclo

Se `nextPageToken` repetir de forma anômala:

- interromper loop;
- preservar sequence evidence;
- não marcar completed;
- classificar partial/failed/indeterminate conforme dados factuais;
- avaliar deviation `runtime_change` ou `interface_change`.

## 13. Schema/runtime drift

Se o payload mudar de modo que impeça:

- parser;
- identifier extraction;
- pagination semantics;
- minimal record extraction;

não adaptar silenciosamente durante a Opportunity.

Preservar evidence e aplicar Documento 90.

## 14. MeasurementEvent template

Campos a preencher factualmente:

- measurement_event_uuid;
- measurement_opportunity_uuid = Opportunity #1 ClinicalTrials.gov;
- attempt_no = expected_attempt_no do precheck;
- execution_status;
- execution_started_at;
- execution_completed_at;
- novelty_state;
- raw_result_count;
- raw_result_count_status;
- materialized_identifier_count;
- new_identifier_count;
- failure_attribution;
- failure_evidence_artifact_uuid;
- scientific_search_uuid, somente se houver Search canônica aplicável;
- effort_payload;
- operator;
- actor_type;
- created_at factual/default.

## 15. Campos que não podem ser pré-preenchidos

- measurement_event_uuid factual;
- execution timestamps;
- counts;
- page count factual;
- identifier set;
- novelty state factual quando não completed;
- failure attribution;
- effort;
- failure Artifact.

## 16. Items

Se execution_status = completed ou partial:

- NCT ID como `source_identifier`;
- source locator quando disponível;
- `oes_detected_at` factual;
- item_state segundo histórico do Epoch;
- source record Artifact quando preservado.

Na primeira successful ClinicalTrials.gov observation, NCT IDs inéditos no Epoch serão normalmente `new_to_epoch`, desde que o histórico confirme ausência anterior.

## 17. Timepoints

Usar apenas semantic codes declarados pela source.

Para datas da ClinicalTrials.gov:

- preservar raw value;
- precisão adequada, normalmente day quando date-only;
- não fabricar horário exato;
- preservar `oes_detected_at` separadamente.

## 18. Event Artifacts

Roles físicos:

- query_snapshot;
- result_snapshot;
- identifier_set;
- failure_evidence;
- source_documentation;
- other.

Páginas podem ser sequenciadas com `sequence_no`.

## 19. OpportunityResolution

Se completed:

- resolution_status = completed;
- terminal event = completed event.

Se failed e factual closure:

- failed_closed.

Se indeterminate e factual closure:

- indeterminate_closed.

Se partial sem completed posterior:

> **do not invent partial_closed**

Retornar a modo alto se fechamento definitivo for necessário.

## 20. Post-measurement readout mínimo

Após qualquer tentativa:

- Opportunity UUID;
- attempt_no;
- execution_status;
- request timestamps;
- page count factual;
- pagination completion;
- raw_result_count/status;
- materialized_identifier_count;
- novelty_state;
- new_identifier_count;
- failure_attribution;
- item count;
- timepoint count;
- Artifact count;
- deviation count;
- resolution state.

## 21. Scientific boundary

Mesmo que novos NCT IDs apareçam:

> **new_to_epoch ≠ scientific materiality**

Fluxo:

> **provenance → canonical triage/update workflow**

Sem UpdateSignal automático.

## 22. Clock discipline

Não usar planned_for como execution_started_at.

Não backdate.

Se execução começar depois de 10:30:

- manter planned_for;
- registrar horário real;
- avaliar `execution_delay` deviation conforme o fato.

## 23. Factual SQL

Este pacote não contém SQL factual de MeasurementEvent.

Razão:

> **EVENT SQL MUST BE GENERATED FROM REAL SOURCE EVIDENCE**

Só criar SQL após a request factual e classificação honesta do resultado.

## 24. Estado

> **FIRST_CLINICALTRIALS_OPERATOR_PACKET = READY**

> **FIRST_CLINICALTRIALS_PRECHECK_READONLY = READY**

> **CLINICALTRIALS_TARGET_QUERY = NOT_EXECUTED**

> **FIRST_CLINICALTRIALS_MEASUREMENT_EVENT = NOT_CREATED**

**Fim do Documento 95**
