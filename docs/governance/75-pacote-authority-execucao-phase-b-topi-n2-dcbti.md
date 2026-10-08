# 75 — Pacote de Decisão de Authority Operacional para Execução da Phase B da TOPI-N2-DCBTI-01 / Epoch B1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **APPROVED — OWNER DECISION RECORDED**  
**Dependências:** Documentos 69–74  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1  
**Objeto:** decisão humana específica sobre execução do frozen non-normative measurement epoch

## 1. Contexto

A preparação autorizada pelo Documento 71 foi concluída.

Documento 74 registra:

> **OBSERVATION_EPOCH_B1 = DRAFT_FROZEN**

> **DESIGN_FROZEN_AT = 2026-10-08T13:12:23-03:00**

> **MEASUREMENT_EVENT_COUNT = 0**

O desenho físico agora existe e é imutável.

Logo, pela primeira vez, uma execution authority pode referenciar o exact frozen design sem ser anterior ao design freeze.

## 2. Exact physical scope

Plan:

- UUID: `b3100000-0000-0000-0000-000000000001`;
- code: `TOPI-N2-DCBTI-01`;
- version: `2`.

Epoch:

- UUID: `b3120000-0000-0000-0000-000000000001`;
- code: `B1`;
- status atual: `draft`.

Target:

- ProductVersion: `81000000-0000-0000-0000-000000000701`;
- InvestigationVersion: `81000000-0000-0000-0000-000000000002`;
- N2 / M1 / A2 / published.

## 3. Included source scope

### PubMed/MEDLINE

ObservationSource:

`b3110000-0000-0000-0000-000000000001`

EpochSource:

`b3130000-0000-0000-0000-000000000001`

Runtime interface:

> **ncbi_eutils**

Connectivity:

> **verified**

Frozen opportunities:

> **8**

### ClinicalTrials.gov

ObservationSource:

`b3110000-0000-0000-0000-000000000002`

EpochSource:

`b3130000-0000-0000-0000-000000000002`

Runtime interface:

> **clinicaltrials_api_v2**

Connectivity:

> **verified**

Frozen opportunities:

> **6**

### BVS/LILACS

ObservationSource:

`b3110000-0000-0000-0000-000000000003`

Status:

> **deferred**

Reason:

> **access_path_not_reproducible**

BVS/LILACS não pertence ao B1 executável.

## 4. Frozen temporal scope

Start boundary:

> **2026-10-19T08:00:00-03:00**

Review boundary:

> **2026-11-10T18:00:00-03:00**

Design freeze:

> **2026-10-08T13:12:23-03:00**

PubMed opportunities:

1. 2026-10-19T09:00:00-03:00
2. 2026-10-20T09:00:00-03:00
3. 2026-10-22T09:00:00-03:00
4. 2026-10-26T09:00:00-03:00
5. 2026-10-29T09:00:00-03:00
6. 2026-11-03T09:00:00-03:00
7. 2026-11-06T09:00:00-03:00
8. 2026-11-09T09:00:00-03:00

ClinicalTrials.gov opportunities:

1. 2026-10-19T10:30:00-03:00
2. 2026-10-22T10:30:00-03:00
3. 2026-10-27T10:30:00-03:00
4. 2026-10-30T10:30:00-03:00
5. 2026-11-04T10:30:00-03:00
6. 2026-11-09T10:30:00-03:00

Os timestamps não podem ser alterados após approval.

## 5. Evidence package

Connectivity:

- run `37806308031` / run 215;
- artifact `11563182298`;
- digest:
  `sha256:7f01b41e7156993c547e936e53d7cf161490d5768b120de5051c4722fd74284f`.

Draft materialization/validation:

- run `37807367640` / run 216;
- validated HEAD `f1034c439082ffdf3f2fbba345daf00b2e2c4a35`;
- artifact `11563323408`;
- digest:
  `sha256:3516f2de565655628ab74ecfe5ad0d48fe33658b7ceb9561e61e1802259b12c8`;
- TOPI-PREP-T01–T30 = PASS;
- rebuild = PASS.

## 6. Decisão solicitada

Solicita-se ao owner decisão exclusivamente sobre:

> **autorizar ou não a execução operacional não normativa da Phase B / Epoch B1 da TOPI-N2-DCBTI-01 exatamente como congelada.**

Uma decisão APPROVED autoriza, após persistência da authority row e guards físicos:

1. transição `draft → authorized_non_normative`;
2. transição separada `authorized_non_normative → active` quando start conditions forem satisfeitas;
3. execução das Opportunities congeladas;
4. criação de MeasurementEvents reais apenas quando uma tentativa realmente ocorrer;
5. criação de MeasurementItems/Timepoints/Artifacts conforme dados realmente observados;
6. OpportunityResolution conforme fatos reais;
7. logging de effort, failures e deviations;
8. preservação de incidental scientific findings para triage canônico separado.

## 7. O que APPROVED não autoriza

Mesmo com APPROVED, não autoriza:

- adicionar/remove source no B1;
- alterar query congelada silenciosamente;
- alterar interface congelada silenciosamente;
- mover timestamps;
- criar novas Opportunities;
- estender o Epoch automaticamente;
- alterar review boundary;
- reinterpretar missed opportunity como compliance breach;
- M1→M2;
- Monitor/MonitoringCycle;
- automatic UpdateSignal;
- automatic scientific update;
- alteração automática de conclusion/currentness/assurance;
- UpdatePolicy;
- CadenceContract;
- CadenceObservation;
- scheduler recorrente;
- SLA;
- notifications/auto-escalation;
- Calibration Dossier;
- normative temporal values;
- M3 formalization.

## 8. Preconditions antes da activation

Mesmo após owner APPROVED, antes de `active` o sistema deve verificar:

- exact target ainda current;
- controlling Artifacts active;
- payload↔Opportunity equality;
- connectivity status ainda válido no frozen EpochSource;
- authority row persistida para exact B1;
- authority state = approved;
- `decided_at >= 2026-10-08T13:12:23-03:00`;
- nenhuma invalidating/material deviation;
- primeira opportunity ainda futura.

Se qualquer precondition falhar:

> **não ativar B1.**

## 9. Schedule expiry

Se authorization/activation não estiver concluída antes da primeira opportunity:

> **não deslocar timestamps.**

B1 deve ser tratado como:

> **EXPIRED_NOT_EXECUTED**

e submetido a novo desenho/version/gate.

## 10. Scientific boundary

A execução produz evidência temporal/operacional.

Ela não produz authoritative UpdateRiskProfile automaticamente.

A1/A3/A4 e demais julgamentos científicos continuam exigindo authority qualificada quando requerida.

Candidate finding científico:

> observation → provenance → triage/update workflow separado.

## 11. Authority freshness

Para ser válida:

> **a decisão precisa ocorrer após o design freeze.**

O design freeze é:

`2026-10-08T13:12:23-03:00`

Este Documento 75 foi criado somente depois desse freeze.

A aprovação anterior do Documento 71:

> **não será reutilizada.**

## 12. Decisão

Escolher explicitamente:

- [ ] **APPROVED** — autorizo a execução operacional não normativa da **Phase B / Epoch B1**, conforme Documento 75, da TOPI-N2-DCBTI-01 exatamente no frozen design.
- [ ] **REVISE** — solicito alteração antes da execução.
- [ ] **REJECTED** — não autorizo a execução.

Para ser válida, a resposta deve vincular explicitamente:

- **Phase B execution**;
- **Documento 75**;
- **TOPI-N2-DCBTI-01**;
- **Epoch B1**.

Exemplo válido:

> **APPROVED — Phase B execution / Documento 75 / TOPI-N2-DCBTI-01 / Epoch B1**

Mensagem genérica como:

- `Prossiga`;
- `Ok`;
- `Pode continuar`;

> **não será interpretada como authority de execução.**

## 13. Estado enquanto não houver decisão

> **PHASE_B_EXECUTION_AUTHORITY = PENDING**

> **OBSERVATION_EPOCH_B1 = DRAFT_FROZEN**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

**Fim do Documento 75**


## 14. Registro da decisão do owner

Decisão recebida em:

`2026-10-08T13:31:42-03:00`

Formulação recebida:

> **APPROVED — Phase B execution / Documento 75 / TOPI-N2-DCBTI-01 / Epoch B1**

A decisão satisfaz o vínculo explícito exigido por este pacote.

Design freeze controlador:

`2026-10-08T13:12:23-03:00`

Resultado de freshness temporal:

> **OWNER_DECISION_AFTER_DESIGN_FREEZE = PASS**

Escopo autorizado:

- persistir authority `operational_execution` para o exact Plan/Epoch;
- transicionar `draft → authorized_non_normative`, sujeito aos guards físicos;
- permitir futura ativação somente quando as preconditions temporais e operacionais forem satisfeitas.

A decisão não autoriza:

- ativação antecipada antes do start boundary;
- criação imediata de MeasurementEvent;
- alteração do frozen opportunity set;
- valores temporais normativos.

Estado após este registro documental:

> **PHASE_B_EXECUTION_AUTHORITY_DECISION = APPROVED**

> **PHYSICAL_AUTHORITY_ROW = PENDING_VALIDATION**

> **EPOCH_B1_PHYSICAL_STATE = DRAFT**

> **MEASUREMENT_EVENT_COUNT = 0**
