# 58 — TOPI-N2-DCBTI-01 Phase A Characterization Package

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Instância:** TOPI-N2-DCBTI-01 v0.1  
**Phase:** A — source characterization / access / storage / risk-profile evidence preparation  
**Status:** **COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS — NO_PHASE_B_AUTHORIZED**  
**Authority basis:** Documento 57 / owner APPROVED  
**Target:** ProductVersion `81000000-0000-0000-0000-000000000701`  
**Calibration object:** cadence readiness  
**Natureza:** não normativa

## 1. Finalidade

Este pacote registra a execução autorizada da Phase A da TOPI-N2-DCBTI-01.

A Phase A não executa surveillance longitudinal e não seleciona cadence.

Ela caracteriza:

- PubMed/MEDLINE;
- BVS/LILACS;
- ClinicalTrials.gov;

e prepara:

- source observability;
- access/data-governance findings;
- semantic storage mapping;
- latency observability;
- inputs preliminares para UpdateRiskProfile;
- blockers para eventual Phase B.

## 2. Freshness / authority

Antes da Phase A:

- HEAD confirmado: `7f6ea93e311d5f43615bc7a7b98585ebda8a9e95`;
- CP113 vigente;
- nenhum avanço concorrente;
- Documento 56 aguardava decisão explícita;
- owner respondeu explicitamente `Approved - phase A / documento 56 / TOPI-N2-DCBTI-01`;
- decisão registrada no Documento 57;
- commit de authority: `9270c3835e588405293b9ca1fe9637ae4a58ad87`.

Estado:

> **PHASE_A_OPERATIONAL_EXECUTION_AUTHORITY = GRANTED**

## 3. Método da Phase A

Foram examinados apenas fatos necessários à characterization.

Não foi executada busca científica target-specific nova.

Não foi iniciado polling repetido.

Não foi criada Search, SearchHit, ScreeningDecision, MonitoringCycle ou CadenceObservation.

Foram usados:

- documentação oficial;
- páginas oficiais de ajuda;
- páginas oficiais de interface;
- documentação institucional da BIREME/OPAS/OMS;
- documentação institucional NLM/NCBI;
- tentativas mínimas de acesso mediadas pelas ferramentas disponíveis.

Quando uma ferramenta não conseguiu abrir diretamente um endpoint:

> o resultado foi classificado como limitação do canal de acesso / causalidade desconhecida, não como source failure.

## 4. Locators externos examinados

### PubMed / NCBI

1. PubMed User Guide  
   `https://pubmed.ncbi.nlm.nih.gov/help/`

2. NCBI APIs / E-utilities  
   `https://www.ncbi.nlm.nih.gov/home/develop/api/`

3. Entrez Programming Utilities Help  
   `https://www.ncbi.nlm.nih.gov/books/NBK25497/`

4. NCBI Policies / scripting guidance  
   `https://www.ncbi.nlm.nih.gov/home/about/policies/`

### BVS / LILACS

1. Tutorial de Pesquisa no Portal da BVS  
   `https://bvsalud.org/searchtutorial/documents/BIREME-OMS-PT-Aula_2-Tutorial_de_Pesquisa.pdf`

2. Guia da BVS / IAHx / FI-Admin  
   `https://red.bvsalud.org/wp-content/uploads/2021/11/opas-guia-bvs-2021-p4-v3-1.pdf`

3. Correspondência de campos LILACS ↔ MARC21  
   `https://docs.bvsalud.org/biblioref/2024/02/1436056/conversao_lilacs_marc_en_fev06.pdf`

4. Portal Regional de Pesquisa BVS  
   `https://busqueda.bvsalud.org/portal/`

### ClinicalTrials.gov / NLM

1. NLM Technical Bulletin — ClinicalTrials.gov API v2  
   `https://www.nlm.nih.gov/pubs/techbull/ma24/ma24_clinicaltrials_api.html`

2. NLM Technical Bulletin — modernized website  
   `https://www.nlm.nih.gov/pubs/techbull/mj24/mj24_Modern_Clinical_Trials_Website.html`

3. ClinicalTrials.gov current site  
   `https://clinicaltrials.gov/`

4. ClinicalTrials.gov CSV/Data fields  
   `https://clinicaltrials.gov/data-about-studies/csv-download`

5. NLM guidance against screen scraping / API example  
   `https://www.nlm.nih.gov/pubs/techbull/ja25/ja25_clinical_trials_screen-scraping.html`

## 5. PubMed/MEDLINE characterization

### 5.1 Identity / operator

- source: PubMed;
- operator: U.S. National Library of Medicine / NCBI;
- source class: bibliographic discovery/indexing database.

### 5.2 Interfaces

Documented:

- web interface;
- Entrez E-utilities public API;
- ESearch;
- EInfo;
- ESummary;
- EFetch;
- history/batch mechanisms;
- XML and selected JSON outputs depending on utility.

### 5.3 Update behavior

PubMed documents:

- annual baseline files;
- daily incremental update files;
- new MEDLINE-journal citations appearing in PubMed daily.

Interpretation:

> **corpus update behavior is documented as daily at system level.**

This does not mean each article becomes available exactly one day after publication.

### 5.4 Date/timestamp semantics

Relevant searchable dates include:

- Publication Date `[dp]`;
- Electronic Publication Date `[epdat]`;
- Print Publication Date `[ppdat]`;
- Entry Date `[edat]`;
- Create Date `[crdt]`;
- MeSH Date `[mhda]`.

Important documented semantics:

- CRDT = date citation record was first created in PubMed;
- EDAT = processing/entry date;
- EDAT is typically set within 24 hours of citation availability in PubMed;
- publication-to-PubMed-availability lag varies depending on publisher deposit;
- NLM explicitly notes CRDT may be preferable to publication date for regularly checking newly added citations.

### 5.5 Latency observability

Potentially observable with caveats:

- article publication/e-publication date;
- PubMed CRDT;
- PubMed EDAT.

Therefore:

> **publication → PubMed creation/entry delay can sometimes be bounded/estimated at date precision.**

However:

- publication date precision varies;
- online-first versus print dates differ;
- CRDT/EDAT are PubMed processing dates, not direct publisher-deposit timestamps;
- no exact source-availability timestamp should be fabricated where only dates exist.

Status:

> **PUBMED_LATENCY_OBSERVABILITY = PARTIAL_BUT_METHODICALLY_USABLE**

### 5.6 Access / rate constraints

NCBI documents:

- use E-utilities endpoint;
- no more than 3 requests/second without API key;
- up to 10 requests/second by default with API key;
- large retrieval jobs should use off-peak/weekend guidance;
- tool/email identification is part of scripting guidance.

Phase B implication:

> access design must respect NCBI usage limits and cannot treat rate-limit errors as evidence of source publication failure.

### 5.7 Data governance / copyright

NCBI states that PubMed abstracts may contain copyrighted material owned by publishers/authors.

Implication:

- store minimal bibliographic metadata/PMID/locator where sufficient;
- do not duplicate full abstracts unnecessarily;
- preserve NCBI disclaimer/copyright requirements where applicable;
- do not treat public access as unrestricted content redistribution permission.

### 5.8 Characterization state

> **PUBMED_SOURCE_CHARACTERIZATION = SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_CONTROLS**

No Phase B is authorized by this state.

## 6. BVS/LILACS characterization

### 6.1 Identity / operator

- source environment: Biblioteca Virtual em Saúde — BVS;
- relevant database: LILACS;
- coordination/technology: BIREME / OPAS / OMS;
- source class: regional bibliographic discovery/indexing environment.

### 6.2 Interfaces

Official BVS materials document:

- Regional BVS Portal;
- integrated multilingual search interface IAHx;
- integrated retrieval from multiple information sources;
- filters/clusters;
- DeCS/MeSH navigation;
- FI-Admin as management/indexing system for LILACS and other sources.

The Portal is documented as freely accessible in Portuguese, Spanish, English and French.

### 6.3 Public retrieval observation

Current search indexing exposed BVS Regional search result pages containing:

- source/base labels including LILACS;
- record IDs such as `biblio-...` / `lil-...`;
- bibliographic metadata;
- language;
- source/journal;
- publication year/date when available;
- subject descriptors;
- result filters.

A direct open attempt against some BVS/LILACS URLs through the current retrieval tool produced 403/timeout behavior.

Interpretation:

> **TOOL_MEDIATED_ACCESS_LIMITATION — NOT_SOURCE_FAILURE**

The same source environment was retrievable through indexed BVS result pages, so no liveness-failure claim is made.

### 6.4 LILACS record-date model

Official LILACS↔MARC documentation includes fields such as:

- Transfer Date to Database;
- Record Creation Date;
- Date and Time of Latest Transaction;
- Last Change Date.

This demonstrates that the LILACS data model contains operational record dates.

It does not yet demonstrate that all required fields are exposed through a stable public programmatic retrieval interface available to OES.

### 6.5 Programmatic interface

A current, stable, public API contract for the integrated BVS/LILACS search was **not established** from the controlling official materials reviewed in this Phase A.

Older/secondary BIREME material references REST-related LILACS initiatives, but this package does not treat those references as proof of a currently supported operational API.

Therefore:

> **BVS_LILACS_PROGRAMMATIC_ACCESS = NOT_ESTABLISHED**

### 6.6 Latency observability

Potential data-model endpoints exist:

- publication date;
- record creation;
- transfer;
- latest transaction/change.

But public reproducible access to those operational fields was not established for the intended OES workflow.

Therefore:

> **BVS_LILACS_INDEXING_LATENCY = NOT_YET_OBSERVABLE_UNDER_CURRENT_ACCESS_PATH**

No numeric latency is inferred.

### 6.7 Data governance

BVS is a federated/integrated information environment.

Implications:

- rights/availability may differ by underlying source/full-text provider;
- characterization should retain metadata/identifiers/locators rather than duplicate full content;
- source-specific rights/terms must be respected;
- free portal access does not imply unrestricted redistribution of all linked content.

### 6.8 Characterization state

> **BVS_LILACS_SOURCE_CHARACTERIZATION = PARTIAL**

> **BVS_LILACS_PHASE_B_USE = BLOCKED_PENDING_REPRODUCIBLE_ACCESS_PATH_OR_EXPLICIT_MANUAL_DESIGN**

This is an access/observability blocker, not a claim that BVS/LILACS is unsuitable scientifically.

## 7. ClinicalTrials.gov characterization

### 7.1 Identity / operator

- source: ClinicalTrials.gov;
- operator: U.S. National Library of Medicine;
- source class: clinical study and results registry.

### 7.2 Modernized API

NLM documents:

- API v2 available since 2024;
- REST architecture;
- OpenAPI Specification 3.0;
- JSON as primary response data;
- ISO 8601 date standardization;
- modernized API replacing the retired classic API.

NLM materials document endpoints conceptually for:

- studies;
- single study by NCT ID;
- study metadata;
- search areas;
- enums;
- statistics/version.

### 7.3 Web/download interfaces

Current ClinicalTrials.gov pages expose:

- search;
- record history;
- CSV;
- JSON;
- RIS;
- FHIR download options.

### 7.4 Date semantics

Current study records expose, depending on record:

- First Submitted;
- First Submitted that Met QC Criteria;
- First Posted;
- Last Update Submitted that Met QC Criteria;
- Last Update Posted;
- Last Verified.

API/download field model includes:

- StudyFirstPostDate;
- ResultsFirstPostDate;
- LastUpdatePostDate.

### 7.5 Latency observability

For registry posting behavior, potentially observable intervals include:

- submitted-that-met-QC → first posted;
- update-submitted-that-met-QC → last update posted.

These are registry posting-process intervals.

They are not:

- article publication latency;
- trial event occurrence latency;
- OES detection latency.

For OES detection, future Phase B would separately record:

- source posted date;
- OES observation/detection time.

Status:

> **CTG_POSTING_LATENCY_OBSERVABILITY = STRONG_FOR_REGISTRY_POSTING_FIELDS**

### 7.6 API access probe limitation

Direct API URLs were not retrievable through the current web retrieval channel.

Because official NLM documentation confirms the API and provides current examples, this is classified as:

> **TOOL_MEDIATED_API_PROBE_UNAVAILABLE**

not:

> source/API failure.

Before automated Phase B execution, the actual runtime/client intended for OES must confirm API connectivity.

### 7.7 Data governance

ClinicalTrials.gov is publicly searchable and supports structured data download/API access.

Study record submitters remain responsible for submitted content; NLM performs specified QC before posting.

For OES:

- store NCT ID and relevant registry metadata;
- avoid unnecessary study-document payload retention;
- treat submitted study information as source data, not as NLM scientific endorsement;
- do not collect IPD.

### 7.8 Characterization state

> **CLINICALTRIALS_GOV_SOURCE_CHARACTERIZATION = SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_RUNTIME_CONNECTIVITY_CHECK**

No Phase B is authorized by this state.

## 8. Comparative observability matrix

| Domain | PubMed | BVS/LILACS | ClinicalTrials.gov |
|---|---|---|---|
| Public web access documented | yes | yes | yes |
| Structured programmatic interface established | yes — E-utilities | not established for intended integrated path | yes — REST API v2 |
| Stable identifier | PMID | LILACS/BVS record ID | NCT ID |
| Source operational dates useful for monitoring | CRDT/EDAT/MHDA + publication fields | model contains creation/change dates; public path unresolved | first/last posted + QC submission dates |
| Exact timestamp precision | mostly date-level for relevant PubMed dates | not established | mostly date-level in public fields |
| Publication/indexing delay directly measurable | partially/bounded | not yet under current path | not analogous; posting delay measurable |
| OES detection latency measurable prospectively | yes, if OES logs detection | yes only after access path defined | yes, if OES logs detection |
| Current Phase B design readiness | conditional yes | no / partial | conditional yes |

## 9. Semantic storage map — Phase A result

### 9.1 Source documentation fact

Store as:

> repository Artifact/documentation record

Required fields:

- source;
- locator;
- retrieval date/session;
- documented/observed/inferred;
- interpretation;
- version/effective date if available.

### 9.2 Source access probe

Store as:

> audit log / Artifact

Not Search.

Include:

- attempted interface;
- result;
- tool/runtime;
- failure attribution;
- causal certainty.

### 9.3 Scientific retrieval

Only when a real scientific search is executed:

> `investigation.search`

No scientific target-specific search was executed in this Phase A.

### 9.4 Latency observation

Until a dedicated physical event object exists:

> audit Artifact/log

Do not use CadenceObservation.

### 9.5 Characterization effort

Store as:

> operational audit Artifact/log

No sustainable-capacity claim.

## 10. UpdateRiskProfile evidence-preparation matrix

No authoritative ratings are assigned.

### A1 — decision criticality

Available evidence:

- target is an evidence sheet intended for technical/evidence users;
- question concerns treatment of insomnia;
- product communicates evidence, not direct clinical prescription.

Still needed:

- qualified human assessment of consequences of outdated information in intended use.

State:

> **EVIDENCE_PREPARED — HUMAN_JUDGMENT_REQUIRED**

### A2 — evidence-base volatility

Available evidence:

- historical case included systematic reviews/meta-analyses and multiple RCTs;
- ClinicalTrials.gov was used to identify trial activity;
- PubMed and registry sources are actively updated systems.

Not established:

- target-specific rate of materially relevant new evidence over time.

State:

> **EVIDENCE_PREPARED — VOLATILITY_NOT_RATED**

### A3 — conclusion sensitivity

Published conclusion:

- benefit direction probably favorable;
- magnitude varies.

Potentially material new evidence classes include:

- high-quality contradictory RCT;
- updated systematic review/meta-analysis;
- material safety evidence;
- evidence changing applicability or certainty.

Rating still requires qualified scientific judgment.

State:

> **EVIDENCE_PREPARED — HUMAN_JUDGMENT_REQUIRED**

### A4 — safety/integrity exposure

Current product notes safety is less systematically characterized than efficacy.

No active safety signal is inferred.

State:

> **EVIDENCE_PREPARED — NO_RATING**

### A5 — dependency reach

Repository search did not establish explicit downstream product dependency from this ProductVersion beyond its own documented lineage.

Absence of an indexed hit is not proof of no dependency.

State:

> **DEPENDENCY_REACH_NOT_YET_ESTABLISHED**

### B1 — observability

Evidence:

- PubMed = strong documented API/date observability;
- ClinicalTrials.gov = strong documented API/posting-date observability;
- BVS/LILACS = partial; public programmatic access path unresolved.

State:

> **EVIDENCE_PREPARED — SOURCE_HETEROGENEITY_MATERIAL**

### B2 — detection latency

Evidence:

- PubMed allows creation/entry-date based monitoring;
- ClinicalTrials.gov exposes posted/update dates;
- BVS/LILACS operational public endpoint remains unresolved;
- OES detection latency has not yet been prospectively measured.

State:

> **EVIDENCE_PREPARED — NO_RATING**

### B3 — surveillance burden

Phase A demonstrates that source-specific characterization is heterogeneous.

No reliable effort series was measured.

State:

> **INSUFFICIENT_FOR_RATING**

### B4 — incorporation cost

Original N2 pipeline required search, screening, appraisal, synthesis/certainty/product work.

No maintenance-specific incorporation-time distribution exists.

State:

> **INSUFFICIENT_FOR_RATING**

### B5 — sustainable capacity

No institutional sustainable-capacity evidence was created.

State:

> **MISSING**

## 11. Data-governance findings

### PubMed

> **PASS_WITH_CONTROLS**

Controls:

- respect NCBI request limits;
- use appropriate tool/email identification for scripted use;
- minimize abstract/full-text copying;
- preserve locators/PMIDs.

### BVS/LILACS

> **PASS_FOR_METADATA_CHARACTERIZATION / PHASE_B_ACCESS_UNRESOLVED**

Controls:

- minimal metadata;
- source-specific rights;
- no claim of API support without current contract;
- no automated Phase B use until access path is reproducible or explicitly manual.

### ClinicalTrials.gov

> **PASS_WITH_CONTROLS**

Controls:

- use documented API/download mechanisms;
- store identifiers and relevant metadata;
- do not interpret registry presence as scientific endorsement;
- avoid unnecessary document payload/IPD.

## 12. Access/liveness observations

No source is classified as failed.

Observed environment limitations:

- direct API endpoint opening through the current retrieval channel was unavailable for NCBI/ClinicalTrials.gov;
- direct BVS portal/LILACS opens showed 403/timeout in some attempts;
- indexed/current official pages remained retrievable.

Therefore:

> **FAILURE_ATTRIBUTION = UNKNOWN / TOOL_MEDIATED**

No source-side outage is inferred.

## 13. Phase A completion decision

Review-boundary test:

### PubMed

Characterization sufficient to decide observability:

> **YES**

### ClinicalTrials.gov

Characterization sufficient to decide observability:

> **YES**

### BVS/LILACS

Sufficient to decide current limitation:

> **YES — NOT_FULLY_CHARACTERIZABLE_FOR_PROGRAMMATIC_PHASE_B_UNDER_CURRENT_ACCESS_PATH**

Thus the Phase A boundary is met without pretending that BVS is fully characterized.

> **PHASE_A = COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS**

## 14. Recommended Phase B design direction

No schedule is selected.

Recommended direction for Plan Amendment v0.2:

1. use PubMed and ClinicalTrials.gov as the two sources currently eligible for structured prospective measurement design;
2. keep BVS/LILACS as:
   - excluded from initial automated/repeated measurement, or
   - explicitly manual characterization track,
   until a reproducible access path is established;
3. define OES detection timestamps separately from source dates;
4. use date precision honestly;
5. separate source-specific measurement events;
6. do not aggregate source debt under a policy-aggregate “completed” flag;
7. keep all measurement non-normative;
8. require target-specific recheck and explicit Phase B authority.

## 15. Measurement schedule

> **NOT_SELECTED**

Reason:

Although PubMed documents daily corpus updates and ClinicalTrials.gov exposes update dates/API, a common experimental interval has not yet been justified across source classes.

Choosing a number now would risk:

- privileging PubMed behavior;
- masking BVS access debt;
- conflating registry posting with bibliographic indexing;
- anchoring future calibration.

A numeric non-normative schedule, if any, belongs in Plan Amendment v0.2 after deciding source inclusion and event semantics.

## 16. Physical-contract finding

The Phase A did not demonstrate need for a new migration merely to preserve characterization.

Current approach is sufficient:

- repository documents/artifacts for source facts/access/probes;
- existing Search only for future genuine scientific searches.

State:

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = NOT_REQUIRED_FOR_PHASE_A**

Whether Phase B needs a dedicated event object remains:

> **UNRESOLVED — TO_BE_DECIDED_FROM_V0_2_EVENT_MODEL**

No migration is authorized.

## 17. Result Package status

This document is:

> **TOPI-N2-DCBTI-01 PHASE A CHARACTERIZATION PACKAGE**

It is not:

- Evidence Readiness Assessment;
- UpdateRiskProfile approval;
- Calibration Dossier;
- UpdatePolicy;
- CadenceContract;
- Monitor.

## 18. State after Phase A

> **AUTHORITY_DECISION = APPROVED_FOR_PHASE_A**

> **PHASE_A = COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS**

> **PUBMED_SOURCE_CHARACTERIZATION = SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_CONTROLS**

> **BVS_LILACS_SOURCE_CHARACTERIZATION = PARTIAL**

> **CLINICALTRIALS_GOV_SOURCE_CHARACTERIZATION = SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_RUNTIME_CONNECTIVITY_CHECK**

> **UPDATE_RISK_PROFILE = EVIDENCE_PREPARATION_ONLY**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B = NOT_AUTHORIZED**

> **REAL_PROSPECTIVE_MEASUREMENT = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 19. Próximo passo exato

> **Especificar Plan Amendment v0.2 para a TOPI-N2-DCBTI-01 com source inclusion explícita, event model da Phase B, proposta de measurement schedule non-normative somente se justificável, storage mapping e authority package; depois executar novo target-specific gate antes de qualquer Phase B.**

A seleção de um numeric measurement schedule é nova decisão metodológica e deve ser tratada separadamente.

**Fim do Documento 58**
