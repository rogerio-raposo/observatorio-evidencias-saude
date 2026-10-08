# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — B1R1 Real Measurement Runbook Ready

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP132  
**Checkpoint anterior:** CP131  
**Status:** artefato de continuidade; não normativo  
**Escopo:** conclusão do runbook operacional das medições reais do B1R1, sem activation e sem execução target-specific.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_REAL_MEASUREMENT_RUNBOOK = READY**

> **B1R1_STARTED_AT = NULL**

> **B1R1_ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Documento 88

Path:

`docs/governance/88-runbook-operacional-medicoes-reais-b1r1.md`

Status:

> **READY_FOR_REAL_OPPORTUNITY_EXECUTION — ACTIVATION_STILL_PENDING**

## 3. Escopo operacional coberto

O runbook formaliza, sem alterar a metodologia:

- preflight por Opportunity;
- início factual de attempt;
- request PubMed congelada;
- completude PubMed;
- request ClinicalTrials.gov congelada;
- paginação ClinicalTrials.gov;
- source identifiers;
- baseline aggregate source-specific;
- completed subsequent novelty semantics;
- raw/materialized/new counts;
- MeasurementItem;
- minimal source record;
- timepoints;
- execution Artifacts;
- failure attribution;
- execution status;
- retries;
- OpportunityResolution;
- delays/deviations;
- runtime/interface drift;
- query drift;
- effort payload;
- sequência transacional;
- pós-validação;
- replay/readiness views;
- scientific triage boundary;
- checklists da primeira PubMed e primeira ClinicalTrials.gov Opportunity;
- missed Opportunity;
- anti-backfill;
- clock discipline;
- failure evidence;
- regra de não improvisação.

## 4. Nenhuma nova decisão arquitetural

> **NEW_ARCHITECTURAL_DECISION = NO**

> **NEW_MIGRATION_REQUIRED = NO**

O Documento 88 deriva de:

- Documento 78;
- Documento 82;
- artifacts v2;
- migrations 033–036;
- physical guards existentes.

## 5. PubMed execution path

Frozen operational contract:

- ESearch GET;
- db=pubmed;
- term=frozen query;
- retmode=json;
- retmax=10000;
- sem relative date filter;
- completed somente com identifier set completo;
- count > 10000 = fail closed / deviation.

## 6. ClinicalTrials.gov execution path

Frozen operational contract:

- GET /api/v2/studies;
- query.cond=insomnia;
- query.term=(digital CBT OR digital CBT-I OR internet CBT-I);
- format=json;
- pageSize=10;
- paginação completa via nextPageToken/pageToken;
- completed somente após todas as páginas serem obtidas e parseadas.

## 7. Primeiras Opportunities

PubMed:

- UUID `b3140000-0000-0000-0000-000000000015`;
- 2026-10-19T09:00:00-03:00.

ClinicalTrials.gov:

- UUID `b3140000-0000-0000-0000-000000000023`;
- 2026-10-19T10:30:00-03:00.

Primeiro completed event de cada source:

- novelty_state=not_applicable;
- new_identifier_count=NULL;
- failure_attribution=not_applicable.

## 8. Estado preservado

Nenhuma source query target-specific foi executada.

Nenhum MeasurementEvent foi criado.

Nenhuma OpportunityResolution foi criada.

B1R1 permanece:

> **authorized_non_normative / started_at NULL**

## 9. Próximo ato irreversível

Em 2026-10-19:

> **modo alto obrigatório**

Sequência:

1. Freshness Gate;
2. hora factual America/Recife;
3. live activation preflight;
4. somente se PASS, persistir started_at factual;
5. provar zero MeasurementEvent pós-activation;
6. checkpoint;
7. primeira PubMed Opportunity às 09:00 -03.

## 10. Mandatory pause

Após ativação do CP132:

> **stop and await user “Prossiga”.**

Antes de 19/10, “Prossiga” pode autorizar apenas trabalho preparatório não irreversível.

## 11. HEAD before CP132 creation

`5e761c25bf1449aa30acfbfe2cbd5130ad47126c`

**Fim do CP132**
