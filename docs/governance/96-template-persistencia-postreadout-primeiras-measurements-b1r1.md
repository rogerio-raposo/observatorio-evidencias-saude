# 96 — Template de Persistência e Pós-Readout das Primeiras Measurements do B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data de preparação:** 9 de outubro de 2026  
**Status:** **TEMPLATE_ONLY — NO_FACTUAL_MEASUREMENT_DATA**  
**Modo de preparação:** médio  
**Modo de uso factual:** alto  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 88, 90, 94–95; migration 036; CP139  
**Objeto:** fornecer estrutura comum para persistir e auditar as primeiras measurements reais de PubMed e ClinicalTrials.gov somente após evidence factual da source.

## 1. Regra principal

Este documento não contém:

- MeasurementEvent UUID factual;
- execution timestamps;
- source counts;
- identifier sets;
- failure attribution factual;
- Resolution factual.

Somente pode ser instanciado após uma source request real e classificação honesta do resultado.

## 2. Opportunities abrangidas

PubMed #1:

`b3140000-0000-0000-0000-000000000015`

ClinicalTrials.gov #1:

`b3140000-0000-0000-0000-000000000023`

## 3. Ordem factual de persistência

Após preservar evidence externa:

1. criar/registrar Artifacts necessários;
2. inserir MeasurementEvent;
3. inserir MeasurementItems aplicáveis;
4. inserir item timepoints aplicáveis;
5. ligar event Artifacts;
6. inserir deviation quando factual;
7. inserir OpportunityResolution somente quando terminal/factual;
8. executar post-readout read-only.

## 4. MeasurementEvent — campos factual-only

Preencher somente após a tentativa:

- measurement_event_uuid;
- measurement_opportunity_uuid;
- attempt_no;
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
- scientific_search_uuid, quando aplicável;
- effort_payload;
- operator;
- actor_type.

## 5. Baseline semantics

Se for o primeiro `completed` da source:

- novelty_state = not_applicable;
- new_identifier_count = NULL;
- failure_attribution = not_applicable.

PubMed e ClinicalTrials.gov possuem baselines independentes.

## 6. Non-completed semantics

Para failed/partial/indeterminate:

- novelty_state deve refletir incerteza/fato segundo guards;
- não estabelecer successful baseline;
- preservar identifiers factuais somente quando permitidos;
- não inventar raw count completo.

## 7. MeasurementItems

Para completed/partial quando existirem identifiers:

- source_identifier factual;
- item_state conforme histórico;
- oes_detected_at factual;
- source locator;
- source record Artifact quando aplicável.

## 8. Timepoints

Persistir somente quando a source efetivamente fornecer campo semanticamente reconhecido.

Preservar:

- semantic_code;
- raw_value;
- precision;
- lower/upper bounds quando justificáveis;
- observability_status.

Não inferir horário exato de date-only.

## 9. Event Artifacts

Roles físicos permitidos:

- query_snapshot;
- result_snapshot;
- identifier_set;
- failure_evidence;
- source_documentation;
- other.

ClinicalTrials.gov pode usar sequence_no para páginas.

## 10. Resolution

Usar apenas quando terminal/factual:

- completed;
- failed_closed;
- indeterminate_closed;
- not_executed;
- invalidated.

Não existe `partial_closed`.

## 11. Deviations

Registrar somente se factual.

Possíveis tipos existentes incluem:

- execution_delay;
- source_access;
- runtime_change;
- query_change;
- interface_change;
- source_scope_change;
- authority_change;
- data_governance;
- other.

Não criar deviation artificial para "documentar normalidade".

## 12. Pós-readout comum

Arquivo:

`database/f4-topi-n2-dcbti-b1r1-first-measurements-postreadout-readonly.sql`

Ele reconcilia, para as duas primeiras Opportunities:

- replay status;
- attempt count;
- execution status;
- novelty;
- items;
- timepoints;
- Artifacts;
- deviations;
- Resolution;
- timestamps.

Antes de measurement real, o esperado é:

- attempt_count = 0;
- opportunity_status = planned;
- zero rows em event detail;
- zero Resolution.

## 13. Critérios de pós-validação

Após persistência factual, confirmar:

- Opportunity correta;
- attempt_no contíguo;
- status coerente;
- baseline semantics correta;
- counts coerentes;
- item count coerente;
- timepoints coerentes;
- required failure Artifact presente;
- Resolution compatível com terminal event;
- no UpdateSignal automático;
- no cadence/SLA mutation.

## 14. Erro de persistência

Se SQL factual falhar em guard:

> **DO NOT DISABLE GUARD**

Preservar erro e retornar à classificação/evidence.

Guard failure pode indicar:

- attempt sequence incorreta;
- baseline semantics incorreta;
- resolved Opportunity;
- invalid item_state;
- invalid Resolution;
- incoerência de timepoint.

## 15. Reexecução

Não reaplicar SQL factual de forma cega.

Antes de qualquer retry de persistência:

- inspecionar quais rows realmente commitadas;
- se transação foi rollback, confirmar zero mutation;
- se houve commit parcial impossível sob transação atômica, investigar infraestrutura;
- gerar novo script somente se necessário e provenance-preserving.

## 16. Template de evidence summary

Para cada tentativa factual registrar:

- source;
- Opportunity UUID;
- planned_for;
- attempt_no;
- request start/end;
- execution_status;
- completeness rationale;
- raw count/status;
- materialized count;
- novelty state;
- new count;
- failure attribution;
- item count;
- timepoint count;
- Artifact locators;
- deviation;
- resolution;
- operator effort.

## 17. Scientific boundary

Nenhum pós-readout pode transformar measurement em conclusão científica automática.

Fluxo permanece:

> **measurement → provenance → triage/update workflow**

## 18. Estado

> **FIRST_MEASUREMENTS_PERSISTENCE_TEMPLATE = READY**

> **FIRST_MEASUREMENTS_POSTREADOUT_READONLY = READY**

> **FACTUAL_MEASUREMENT_DATA = NONE**

> **MEASUREMENT_EVENT_SQL_FACTUAL = NOT_CREATED**

**Fim do Documento 96**
