# 73 — Resultado dos Probes de Conectividade para Preparação da Phase B da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Authority:** Documento 72 / owner APPROVED  
**Natureza:** preparation-only; não normativa  
**Status:** **CONNECTIVITY_PASS — DRAFT_MATERIALIZATION_ELIGIBLE**

## 1. Escopo

Foram executados somente probes mínimos de conectividade autorizados pelo Documento 71.

Não houve:

- query científica target-specific;
- Search;
- SearchHit;
- ScreeningDecision;
- MeasurementEvent;
- MonitoringCycle;
- CadenceObservation.

## 2. Runtime canônico observado

GitHub Actions:

- workflow: OES PoC-S5 PostgreSQL Validation;
- run: `37806308031`;
- run number: `215`;
- head: `05de3cc6af8f393e2bd6ac524f14c310cc755aa0`;
- job: `113411379827`;
- runner OS: Linux;
- runner architecture: X64;
- curl: 8.5.0.

Probe started:

`2026-10-08T16:07:48Z`

Probe completed:

`2026-10-08T16:07:49Z`

## 3. PubMed E-utilities

Endpoint:

`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed&retmode=json`

Result:

> **PUBMED_EUTILS_CONNECTIVITY = VERIFIED**

Validation:

- HTTP request completed successfully;
- response payload parsed as JSON;
- EInfo payload identified database `pubmed`.

No search term was submitted.

## 4. ClinicalTrials.gov API v2

Endpoint:

`https://clinicaltrials.gov/api/v2/version`

Result:

> **CLINICALTRIALS_GOV_API_V2_CONNECTIVITY = VERIFIED**

Observed:

- `apiVersion = 2.0.5`.

No trial query was executed.

## 5. CI integrity

Run 215 completed:

> **success**

The full prior regression chain also remained green.

Evidence artifact:

- ID: `11563182298`;
- name: `oes-s5-evidence-37806308031`;
- size: `261870 bytes`;
- digest: `sha256:7f01b41e7156993c547e936e53d7cf161490d5768b120de5051c4722fd74284f`;
- expires at: `2026-11-07T16:08:07Z`.

## 6. Interpretation

The probes support:

> **RUNTIME_CONNECTIVITY_STATUS = VERIFIED**

for the candidate B1 interfaces:

- PubMed / E-utilities;
- ClinicalTrials.gov / API v2.

This result is limited to:

- connectivity from the observed GitHub Actions runtime;
- the exact probe endpoints;
- the probe interval above.

It does not prove future availability.

## 7. Consequence

The condition in Documento 71 for real draft materialization is satisfied, subject to the target-current recheck already completed.

Authorized next act:

> **materialize TOPI-N2-DCBTI-01 v0.2-final + Epoch B1 as draft only.**

Still prohibited:

- Phase B MeasurementEvent;
- target-specific measurement query execution;
- operational execution authority inference;
- activation.

**Fim do Documento 73**
