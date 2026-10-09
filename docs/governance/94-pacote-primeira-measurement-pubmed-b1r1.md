# 94 — Pacote Operacional da Primeira Measurement Real PubMed do B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data de preparação:** 8 de outubro de 2026  
**Status:** **READY_FOR_FIRST_REAL_PUBMED_OPPORTUNITY — NO_SOURCE_QUERY_EXECUTED**  
**Modo de preparação:** médio  
**Modo de execução factual:** alto  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 78, 88, 90, 92–93; migration 036; CP137  
**Objeto:** preparar a primeira Opportunity real PubMed sem executar consulta target-specific nem criar MeasurementEvent antecipado.

## 1. Opportunity controladora

Opportunity UUID:

`b3140000-0000-0000-0000-000000000015`

EpochSource UUID:

`b3130000-0000-0000-0000-000000000003`

Timestamp:

`2026-10-19T09:00:00-03:00`

## 2. Pré-condições

Antes de qualquer source request:

- B1R1 = active;
- started_at factual e válido;
- current time >= planned_for;
- target current;
- authority approved;
- Opportunity unresolved;
- zero blocking material deviation;
- frozen PubMed interface/query artifacts ativos;
- precheck read-only = READY.

## 3. Precheck read-only

Arquivo:

`database/f4-topi-n2-dcbti-b1r1-first-pubmed-precheck-readonly.sql`

Ele captura:

- epoch status;
- started_at;
- target currentness;
- authority state;
- resolution state;
- prior attempt count;
- prior completed PubMed count;
- blocking deviations;
- expected attempt_no;
- baseline/subsequent semantics if completed.

Antes da activation ou antes de 09:00, o esperado é:

> **NOT_READY**

Após activation válida e às/apos 09:00, sem blockers:

> **READY**

## 4. Frozen PubMed request

Usar:

- ESearch GET;
- db=pubmed;
- term=frozen PubMed query v1;
- retmode=json;
- retmax=10000;
- nenhum relative date filter;
- nenhum termo/filtro adicional.

## 5. Evidence a preservar antes da escrita no banco

Registrar factualmente:

- request started_at;
- request completed_at;
- exact normalized request parameters;
- HTTP/runtime status;
- raw response snapshot;
- raw count;
- PMID idlist;
- parse/completeness result;
- operator/machine timing;
- retry count;
- failure evidence, se houver.

## 6. Decision table de status

### completed

Somente se:

- resposta válida;
- parsing completo;
- count <= 10000;
- PMID set completo/materializado.

### partial

Se:

- parte dos identifiers foi obtida e preservada;
- completude não foi alcançada.

### failed

Se a tentativa falhou factualmente.

### indeterminate

Se não for possível classificar honestamente como completed/partial/failed.

## 7. First completed PubMed semantics

Se esta for a primeira PubMed observation `completed`:

- `novelty_state=not_applicable`;
- `new_identifier_count=NULL`;
- `failure_attribution=not_applicable`.

Migration 036 impõe isso fisicamente.

## 8. Zero results

Se a resposta completa comprovar:

`count=0`

então:

- raw_result_count_status = known;
- raw_result_count = 0;
- materialized_identifier_count = 0.

Se for a primeira completed PubMed observation, ainda assim:

- novelty_state = not_applicable;
- new_identifier_count = NULL.

Zero results não é falha.

## 9. Count > 10000

Ação:

> **FAIL CLOSED**

Não:

- alterar query;
- adicionar data;
- segmentar scope;
- declarar completed.

Registrar evidence e retornar às contingências do Documento 90.

## 10. MeasurementEvent template

Campos a preencher factualmente:

- measurement_event_uuid;
- measurement_opportunity_uuid = Opportunity #1 PubMed;
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

## 11. Campos que não podem ser pré-preenchidos

- measurement_event_uuid factual;
- execution timestamps;
- raw counts;
- identifier counts;
- novelty state factual se a tentativa não completou;
- failure attribution;
- effort;
- failure Artifact.

## 12. Items

Se execution_status = completed ou partial:

- persistir identifiers observados;
- PMID como source_identifier;
- locator quando disponível;
- oes_detected_at factual;
- item_state derivado do histórico do Epoch.

Na primeira successful PubMed observation, todos os PMIDs inéditos no Epoch serão normalmente `new_to_epoch`, desde que o guard/histórico confirme ausência anterior.

## 13. Source timepoints

Somente persistir semantic codes declarados pela source.

Não inferir timestamps não observados.

## 14. Event Artifacts

Roles permitidos e esperados, conforme disponível:

- query_snapshot;
- result_snapshot;
- identifier_set;
- failure_evidence;
- source_documentation;
- other.

## 15. OpportunityResolution

Se completed:

- resolution_status = completed;
- terminal_measurement_event_uuid = completed event.

Se failed e a decisão factual for encerrar:

- failed_closed.

Se indeterminate e encerrar:

- indeterminate_closed.

Se partial sem completed posterior:

> **do not invent partial_closed**

Retornar a modo alto se for necessário fechamento definitivo.

## 16. Post-measurement readout mínimo

Após qualquer tentativa:

- Opportunity UUID;
- attempt_no;
- execution_status;
- timestamps;
- raw_result_count/status;
- materialized_identifier_count;
- novelty_state;
- new_identifier_count;
- failure_attribution;
- item count;
- timepoint count;
- event Artifact count;
- deviation count;
- resolution state.

## 17. Scientific boundary

Mesmo que novos PMIDs apareçam:

> **new_to_epoch ≠ scientific materiality**

A observation deve seguir:

> **provenance → canonical triage/update workflow**

Sem UpdateSignal automático.

## 18. Clock discipline

Não usar planned_for como execution_started_at.

Não backdate.

Se a execução começar depois de 09:00:

- manter planned_for;
- registrar execution_started_at real;
- avaliar execution_delay deviation conforme fato.

## 19. Factual SQL

Este pacote não contém SQL de MeasurementEvent factual.

Razão:

> **EVENT SQL MUST BE GENERATED FROM REAL SOURCE EVIDENCE**

O SQL só pode ser criado após a source request factual e após classificar honestamente o resultado.

## 20. Estado

> **FIRST_PUBMED_OPERATOR_PACKET = READY**

> **FIRST_PUBMED_PRECHECK_READONLY = READY**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **FIRST_MEASUREMENT_EVENT = NOT_CREATED**

**Fim do Documento 94**
