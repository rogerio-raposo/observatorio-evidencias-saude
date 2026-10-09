# OES — Continuidade CP140

**Data:** 2026-10-09
**Checkpoint:** CP140
**Anterior:** CP139
**Status:** não normativo

## Estado

> PROJECT_STATE = PHASE_4_IN_PROGRESS

> B1 = INVALIDATED

> B1R1 = AUTHORIZED_NON_NORMATIVE

> FIRST_PUBMED_OPERATOR_PACKET = READY

> FIRST_CLINICALTRIALS_OPERATOR_PACKET = READY

> FIRST_MEASUREMENTS_PERSISTENCE_TEMPLATE = READY

> FIRST_MEASUREMENTS_POSTREADOUT_READONLY = READY

> FACTUAL_MEASUREMENT_DATA = NONE

> B1R1_STARTED_AT = NULL

> ACTIVATION = NOT_STARTED

> FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED

> FIRST_MEASUREMENT_EVENT = NOT_CREATED

> MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0

> OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0

> M3_FORMAL_OPERATIONALIZATION = BLOCKED

> PHASE_5 = NOT_STARTED

## Documento 96

`docs/governance/96-template-persistencia-postreadout-primeiras-measurements-b1r1.md`

Status:

> TEMPLATE_ONLY — NO_FACTUAL_MEASUREMENT_DATA

## Post-readout read-only

`database/f4-topi-n2-dcbti-b1r1-first-measurements-postreadout-readonly.sql`

Coverage:

- PubMed #1;
- ClinicalTrials.gov #1;
- replay status;
- attempt detail;
- items;
- timepoints;
- event artifacts;
- deviations;
- resolutions.

Before real measurements:

> planned / zero attempts / zero resolutions

## CI

Canonical run:

`37865666856`

Run number:

`240`

Validated HEAD:

`1b2de6cbdc460aa8fa858a2c23503cadaa327367`

Conclusion:

> success

Artifact:

- ID `11587648764`;
- digest `sha256:e6a6d891c257172a3aafb47e1caf3a31ec77e0636a68f344f6f06b1dd252047d`;
- expiry `2026-12-08T00:37:43Z`.

Proof:

> TOPI-B1R1-FIRST-MEASUREMENTS-POSTREADOUT = PASS

> ZERO MUTATION = PASS

> REBUILD = PASS

## Intermediate run

Run 239 failed only because the read-only deviation query used a non-existent column name.

It is non-canonical.

The read-only query was corrected to the physical schema and run 240 supersedes it.

No mutation occurred in run 239.

## Preservado

- B1R1 not active;
- started_at NULL;
- no target-specific source query;
- no MeasurementEvent;
- no OpportunityResolution;
- no factual persistence SQL generated.

## Próximo ato irreversível

Em 19/10/2026, modo alto:

1. activation 08:00–09:00;
2. PubMed #1 at/after 09:00;
3. classify factual result;
4. generate factual persistence SQL only from real evidence;
5. execute post-readout;
6. ClinicalTrials.gov #1 at/after 10:30;
7. repeat factual evidence/persistence/post-readout path.

## Mandatory pause

After CP140:

> stop and await user “Prossiga”.

Before 19/10, continuation remains preparatory only.

**Fim do CP140**
