# TOPI-N2-DCBTI-01 — Observation Epoch B1R1

Status at materialization: draft.

Corrective basis:
- Documento 82 — ClinicalTrials.gov request freeze defect reconciliation.
- Documento 83 — owner corrective preparation authority.
- Replacement of non-executed B1.
- B1R1 remains non-normative.

Plan:
TOPI-N2-DCBTI-01 / physical Plan version 2.

Start boundary:
2026-10-19T08:00:00-03:00

Review boundary:
2026-11-10T18:00:00-03:00

Timezone:
America/Recife

Design:
- finite opportunity set;
- source-specific;
- irregular;
- no recurrence generator;
- no scheduler;
- no due/overdue/compliance semantics;
- same 14 planned timestamps as original B1;
- no schedule sliding.

PubMed:
8 opportunities.
Frozen query/interface/schedule semantics reused from B1.

ClinicalTrials.gov:
6 opportunities.
Logical scope unchanged from B1.
Exact normalized request mapping is frozen in:
- clinicaltrials-query-v2.txt
- clinicaltrials-interface-v2.json

BVS/LILACS:
deferred source debt; no B1R1 opportunities.

First successful observation per included source:
OBSERVED_EPOCH_BASELINE_ACQUISITION.

Aggregate baseline semantics:
- novelty_state = not_applicable
- new_identifier_count = NULL
- failure_attribution = not_applicable

Connectivity evidence for B1R1 corrective preparation:
- workflow run 37855302262 / run 224
- job 113577921135
- PubMed E-utilities connectivity verified
- ClinicalTrials.gov API v2 connectivity verified
- ClinicalTrials.gov apiVersion observed: 2.0.5
- probe completed: 2026-10-08T22:45:40Z
- no target-specific query executed

B1R1 draft materialization does not grant execution authority.
A new post-freeze owner execution decision is required before authorized_non_normative.
