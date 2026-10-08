# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — B1 Activation Preflight Ready / Awaiting Live Window

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP124  
**Checkpoint anterior:** CP123  
**Status:** artefato de continuidade; não normativo  
**Escopo:** preparação e validação do live activation preflight do Epoch B1, sem ativação antecipada

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **LIVE_PREFLIGHT_IMPLEMENTATION = VALIDATED**

> **ACTIVATION_NOW = WAIT / NOT_IN_ACTIVATION_WINDOW**

> **ACTIVATION_SQL = NOT_YET_CREATED**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Freshness Gate de entrada

Na retomada do CP123:

- HEAD inicial `b79019866ee725ea43890e18e180dc7e3f27d997`;
- CP123 vigente;
- B1 = `authorized_non_normative`;
- started_at = NULL;
- zero MeasurementEvent;
- zero OpportunityResolution;
- nenhum commit concorrente posterior.

O usuário autorizou continuidade genérica:

> **Prossiga**

Essa autorização permitiu preparação técnica adicional, mas não altera o boundary temporal do B1.

## 3. Migration 035

Arquivo:

`database/035_temporal_observation_activation_preflight.sql`

Commit:

`47025ef369b0f33bf42c0689e4e7c4042c887622`

Objeto:

> **deterministic read-only activation preflight**

Funções:

- `maintenance.temporal_activation_preflight(epoch_uuid, as_of)`;
- `maintenance.temporal_activation_preflight_state(epoch_uuid, as_of)`.

A função não modifica estado.

## 4. Checks consolidados

O preflight verifica:

1. Epoch existence;
2. exact epoch status = authorized_non_normative;
3. exact target currentness;
4. operational execution authority state;
5. controlling Artifact activity;
6. frozen runtime connectivity state;
7. payload↔Opportunity equality;
8. material/invalidating deviations;
9. zero pre-activation MeasurementEvent/OpportunityResolution;
10. activation window;
11. deferred source debt visibility.

Aggregate states:

- PASS;
- WAIT;
- FAIL.

## 5. Testes APF

Arquivo:

`database/f4-temporal-activation-preflight-tests.sql`

Commit:

`4e6e6c06f5b44dd4ff1e4408495fd102d2bc9d84`

Result:

> **APF-T01–T13 = PASS**

Deterministic scenarios:

### Current/pre-start diagnostic

As-of:

`2026-10-08T14:47:00-03:00`

Result:

> **WAIT**

Detail:

> **NOT_IN_ACTIVATION_WINDOW**

### Exact start boundary

As-of:

`2026-10-19T08:00:00-03:00`

Result:

> **PASS**

### Eligible interior time

As-of:

`2026-10-19T08:30:00-03:00`

Result:

> **PASS**

### First Opportunity boundary

As-of:

`2026-10-19T09:00:00-03:00`

Result:

> **FAIL / EXPIRED_NOT_EXECUTED**

## 6. Non-mutation proof

Preflight validation confirmed:

- B1 remains authorized_non_normative;
- started_at remains NULL;
- MeasurementEvent count remains 0;
- OpportunityResolution count remains 0.

Therefore:

> **PREFLIGHT = READ_ONLY**

## 7. Canonical CI

Workflow commit:

`830fcad1e79b237c5c672c5bf8e19aad66d2711f`

Workflow run:

`37819755672`

Run number:

`219`

Conclusion:

> **success**

Created:

`2026-10-08T17:51:14Z`

Completed:

`2026-10-08T17:52:05Z`

Validated:

- migration 035 install;
- migration 035 re-apply;
- APF-T01–T13;
- real B1 authority state;
- current WAIT behavior;
- eligible-window PASS behavior;
- expiry FAIL behavior;
- prior regressions;
- rebuild-from-zero;
- Final S5 status.

## 8. Evidence artifact

Artifact ID:

`11568343046`

Name:

`oes-s5-evidence-37819755672`

Size:

`263399 bytes`

Digest:

`sha256:73f147fca89833f944b1bbb55fda324afa005bd0f17e9ea3b29fdc46810d906b`

Expiry:

`2026-11-07T17:51:58Z`

## 9. Documento 77

Path:

`docs/governance/77-runbook-activation-preflight-b1-topi-n2-dcbti.md`

Commit:

`ed2d43a1b537e02d1c277e878c3560365d83ff89`

Status:

> **READY_FOR_LIVE_PREFLIGHT — ACTIVATION_NOT_YET_ALLOWED**

The runbook defines the exact activation procedure for 2026-10-19.

## 10. Why no activation SQL exists yet

`started_at` is a factual operational timestamp.

Therefore:

> **ACTIVATION_SQL = DEFERRED_UNTIL_LIVE_PREFLIGHT_PASS**

No file will predeclare a future started_at.

On the activation date, after live preflight PASS:

1. capture actual observed activation timestamp;
2. create activation Artifact/document;
3. create factual activation SQL with that actual timestamp;
4. validate physical transition;
5. preserve zero MeasurementEvent at activation.

## 11. Activation interval

Start boundary:

`2026-10-19T08:00:00-03:00`

First PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Required:

> **start_boundary <= actual started_at < first Opportunity**

If the first Opportunity boundary is reached without valid activation:

> **EXPIRED_NOT_EXECUTED**

No timestamp shifting.

No automatic extension.

## 12. First real measurement

PubMed Opportunity #1:

`2026-10-19T09:00:00-03:00`

First successful observation semantics:

> **OBSERVED_EPOCH_BASELINE_ACQUISITION**

Aggregate:

- novelty_state = not_applicable;
- new_identifier_count = NULL.

No automatic scientific novelty claim.

## 13. Scientific boundary

Incidental potentially relevant finding:

> observation → provenance → canonical triage/update workflow.

Never:

> observation → automatic conclusion/currentness/assurance update.

## 14. Mode

> **HIGH MODE REQUIRED**

for:

- live activation;
- first PubMed measurement;
- first ClinicalTrials.gov measurement;
- first source-timepoint interpretation;
- first failure attribution;
- baseline semantics verification.

Medium mode may only be reconsidered after the first real execution path is validated.

## 15. Next exact act

No further physical activation step is valid on 2026-10-08.

Next exact act:

> **on 2026-10-19, at/after 08:00 -03 and before 09:00 -03, perform Freshness Gate + live activation preflight.**

Only if:

> **temporal_activation_preflight_state = PASS**

may activation materialization be created.

## 16. Mandatory pause

After CP124 activation:

> **stop.**

Do not create future started_at.

Do not activate B1.

Do not create MeasurementEvent.

## 17. HEAD before CP124 creation

`edc25c591d2c779099a8eaa332636af49c79f2a5`

**Fim do CP124**
