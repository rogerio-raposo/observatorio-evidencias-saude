# OES — Continuidade CP139

**Data:** 2026-10-09
**Checkpoint:** CP139
**Anterior:** CP138
**Status:** não normativo

## Estado

> PROJECT_STATE = PHASE_4_IN_PROGRESS

> B1 = INVALIDATED

> B1R1 = AUTHORIZED_NON_NORMATIVE

> FIRST_PUBMED_OPERATOR_PACKET = READY

> FIRST_CLINICALTRIALS_OPERATOR_PACKET = READY

> FIRST_PUBMED_PRECHECK_READONLY = READY

> FIRST_CLINICALTRIALS_PRECHECK_READONLY = READY

> B1R1_STARTED_AT = NULL

> ACTIVATION = NOT_STARTED

> FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED

> FIRST_MEASUREMENT_EVENT = NOT_CREATED

> MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0

> OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0

> M3_FORMAL_OPERATIONALIZATION = BLOCKED

> PHASE_5 = NOT_STARTED

## Documento 95

`docs/governance/95-pacote-primeira-measurement-clinicaltrials-b1r1.md`

Status:

> READY_FOR_FIRST_REAL_CLINICALTRIALS_OPPORTUNITY — NO_SOURCE_QUERY_EXECUTED

## First ClinicalTrials.gov precheck

`database/f4-topi-n2-dcbti-b1r1-first-clinicaltrials-precheck-readonly.sql`

Propriedades:

- READ ONLY transaction;
- zero mutation;
- before activation / before 10:30 = NOT_READY;
- exposes expected attempt_no;
- exposes prior completed source count;
- exposes BASELINE_IF_COMPLETED when source has no prior completed event.

## CI

Run:

`37865221303`

Run number:

`237`

Validated HEAD:

`42a69dd48b3fcd3d8ffa252017ab120793cb6ede`

Conclusion:

> success

Artifact:

- ID `11588041164`;
- digest `sha256:b001ccb1edcc18a91d7327c9c3298b6355d3a4560e9b50924c2ab07b57a9ef54`;
- expiry `2026-12-08T00:32:24Z`.

Proof:

> TOPI-B1R1-FIRST-CLINICALTRIALS-PRECHECK = PASS

> PRE-ACTIVATION RESULT = NOT_READY

> BASELINE_IF_COMPLETED = VISIBLE

> ZERO MUTATION = PASS

> REBUILD = PASS

## First ClinicalTrials.gov Opportunity

UUID:

`b3140000-0000-0000-0000-000000000023`

Timestamp:

`2026-10-19T10:30:00-03:00`

Frozen request:

- query.cond=insomnia;
- query.term=(digital CBT OR digital CBT-I OR internet CBT-I);
- format=json;
- pageSize=10;
- complete pagination required.

If first completed ClinicalTrials.gov event:

- novelty_state = not_applicable;
- new_identifier_count = NULL;
- failure_attribution = not_applicable.

## Preservado

- no activation;
- started_at NULL;
- no target-specific PubMed query;
- no target-specific ClinicalTrials.gov query;
- no MeasurementEvent;
- no OpportunityResolution.

## Próximo ato irreversível

Em 19/10/2026, modo alto:

1. activation path 08:00–09:00;
2. PubMed first measurement at/after 09:00;
3. ClinicalTrials.gov precheck at/after 10:30;
4. only READY permits factual source attempt;
5. classify real pagination/result;
6. only then generate factual MeasurementEvent SQL.

## Mandatory pause

After CP139:

> stop and await user “Prossiga”.

Before 19/10, continuation remains preparatory only.

**Fim do CP139**
