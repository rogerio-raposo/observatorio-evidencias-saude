# 69 — Desenho Experimental Finito da Phase B da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **CANDIDATE_FOR_TARGET_SPECIFIC_RECHECK — NO_REAL_MATERIALIZATION_AUTHORIZED**  
**Modo:** alto  
**Dependências:** Documentos 51–68; CP120  
**Instância:** TOPI-N2-DCBTI-01  
**Objeto:** fechar o finite non-normative opportunity set da primeira Phase B sem autorizar execução

## 1. Decisão

A Phase B candidata adota:

> **PHASE_B_EXPERIMENTAL_DESIGN = FINITE_IRREGULAR_SOURCE_SPECIFIC_OPPORTUNITY_SET**

> **PLAN_SPECIFICATION = TOPI-N2-DCBTI-01 v0.2-final candidate**

> **OBSERVATION_EPOCH = B1**

> **PHASE_B_INCLUDED_SOURCES = PUBMED_MEDLINE + CLINICALTRIALS_GOV**

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

> **MEASUREMENT_SCHEDULE_STATUS = NON_NORMATIVE_CANDIDATE**

> **REAL_TOPI_MATERIALIZATION = NOT_AUTHORIZED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

O desenho não usa regra de recorrência.

Ele congela apenas timestamps concretos, finitos e source-specific.

## 2. Freshness Gate

Antes desta decisão foi confirmado:

- branch `main`;
- HEAD `592ccba83079c6608c1891f44c155ac4a71df7ce`;
- checkpoint vigente CP120;
- nenhuma alteração concorrente posterior;
- migration 033 tecnicamente validada;
- TOPI real ainda não materializada;
- Phase B authority ainda não solicitada;
- schedule real ainda não selecionado.

## 3. Target

Exact target:

- Product: `OES-P-2026-000401`;
- ProductVersion: `81000000-0000-0000-0000-000000000701`;
- version: 1;
- product_type: `evidence_sheet`;
- assurance: A2;
- publication status: published;
- Investigation: `OES-I-2026-000401`;
- InvestigationVersion: `81000000-0000-0000-0000-000000000002`;
- depth: N2;
- maintenance level histórico: M1.

O caso continua tratado como M1.

Phase B não é Monitor nem MonitoringCycle.

## 4. Fatos externos rechecados em 2026-10-08

Esta decisão não executou busca científica target-specific nem API probe operacional.

Foi feita apenas verificação documental oficial.

### 4.1 PubMed

Locator:

`https://pubmed.ncbi.nlm.nih.gov/help/`

Fatos controlling para o desenho:

- PubMed User Guide atualizado em 2026-09-30;
- incremental update files são disponibilizados diariamente;
- novas citations de periódicos MEDLINE aparecem em PubMed diariamente;
- Create Date `[crdt]` representa a criação inicial do record em PubMed;
- Entry Date `[edat]` é usada para processamento/Most Recent;
- EDAT é tipicamente definida dentro de 24 horas da disponibilidade da citation em PubMed;
- CRDT é recomendado pelo próprio guia para checagens regulares de citations adicionadas.

E-utilities:

`https://www.ncbi.nlm.nih.gov/books/NBK25497/`

Controles de acesso conhecidos:

- até 3 requests/s sem API key;
- até 10 requests/s por default com API key;
- jobs grandes devem minimizar requests e seguir guidance de uso.

O piloto previsto usa carga muito abaixo desses limites.

### 4.2 ClinicalTrials.gov

Locators:

- `https://clinicaltrials.gov/data-about-studies/csv-download`;
- `https://www.nlm.nih.gov/pubs/techbull/ma24/ma24_clinicaltrials_api.html`.

Fatos controlling:

- API v2 é REST/OpenAPI 3.0;
- JSON é formato primário;
- datas são padronizadas em ISO 8601;
- campos públicos incluem `StudyFirstPostDate`, `ResultsFirstPostDate` e `LastUpdatePostDate`.

Isso sustenta source-date observability.

Não prova runtime connectivity do ambiente OES.

## 5. Alternativas consideradas

### A — regular e densa

Exemplo conceitual:

- daily PubMed;
- daily ClinicalTrials.gov.

Rejeitada porque:

- aproxima o piloto de uma cadence implícita;
- produz polling excessivo em relação à precisão predominantemente diária dos source dates;
- aumenta burden sem ganho proporcional;
- cria risco de anchoring futuro.

### B — regular e esparsa

Exemplo conceitual:

- weekly para ambas as sources.

Rejeitada porque:

- reduz informação sobre repeatability;
- reduz oportunidade de observar missingness/failure;
- produz bounds de OES detection excessivamente largos;
- também parece policy interval.

### C — mesmo desenho para ambas as sources

Rejeitada porque:

- mascara heterogeneidade source-specific;
- PubMed e registry possuem semânticas distintas;
- burden e novelty behavior não são comparáveis por simples identidade de intervalo.

### D — conjunto finito irregular e source-specific

Selecionada.

Racional:

- reduz risco de virar cadence por inércia;
- permite amostrar gaps curtos e maiores;
- preserva source heterogeneity;
- limita burden;
- produz planned opportunities suficientes para replay/missingness;
- permite concluir que evidência continua insuficiente sem prolongar automaticamente o piloto.

## 6. Observation Epoch B1

Candidate boundaries:

> **START_BOUNDARY_AT = 2026-10-19T08:00:00-03:00**

> **REVIEW_BOUNDARY_AT = 2026-11-10T18:00:00-03:00**

Timezone operacional:

> **America/Recife**

Essas boundaries pertencem ao piloto.

Elas não são prazo de policy nem SLA.

O epoch não pode ser concluído antes de review boundary.

## 7. PubMed opportunity set

Objetivo experimental:

- testar execução repetida;
- source-result reproducibility;
- identifier-set comparison;
- source date observability;
- OES detection timestamping;
- operational effort;
- missingness/failure/retry;
- replay.

Opportunity set:

| No. | planned_for |
|---|---|
| 1 | 2026-10-19T09:00:00-03:00 |
| 2 | 2026-10-20T09:00:00-03:00 |
| 3 | 2026-10-22T09:00:00-03:00 |
| 4 | 2026-10-26T09:00:00-03:00 |
| 5 | 2026-10-29T09:00:00-03:00 |
| 6 | 2026-11-03T09:00:00-03:00 |
| 7 | 2026-11-06T09:00:00-03:00 |
| 8 | 2026-11-09T09:00:00-03:00 |

Total:

> **8 opportunities**

O padrão é deliberadamente irregular.

Não existe regra runtime que gere a sequência.

### 7.1 Canonical payload candidate

```json
{
  "schema": "oes.temporal_opportunity_set/0.1",
  "non_normative": true,
  "schedule_kind": "finite_opportunity_set",
  "rationale": "Finite stepped PubMed measurement design for repeated-source execution, identifier comparison, temporal endpoint observability and pilot effort.",
  "timezone_name": "America/Recife",
  "opportunities": [
    {"opportunity_no": 1, "planned_for": "2026-10-19T09:00:00-03:00"},
    {"opportunity_no": 2, "planned_for": "2026-10-20T09:00:00-03:00"},
    {"opportunity_no": 3, "planned_for": "2026-10-22T09:00:00-03:00"},
    {"opportunity_no": 4, "planned_for": "2026-10-26T09:00:00-03:00"},
    {"opportunity_no": 5, "planned_for": "2026-10-29T09:00:00-03:00"},
    {"opportunity_no": 6, "planned_for": "2026-11-03T09:00:00-03:00"},
    {"opportunity_no": 7, "planned_for": "2026-11-06T09:00:00-03:00"},
    {"opportunity_no": 8, "planned_for": "2026-11-09T09:00:00-03:00"}
  ]
}
```

## 8. PubMed measurement strategy

Strategy code candidate:

> **TOPI-N2-DCBTI-PUBMED-B1-V1**

O measurement query será uma união explícita dos dois escopos PubMed históricos do caso N2:

- systematic review/meta-analysis;
- randomized controlled trial/update.

Base exact strategy candidate:

```
(insomnia[Title/Abstract])
AND
(
  "digital cognitive behavioral therapy"[Title/Abstract]
  OR "digital cognitive behavioural therapy"[Title/Abstract]
  OR "internet cognitive behavioral therapy"[Title/Abstract]
  OR "internet cognitive behavioural therapy"[Title/Abstract]
  OR dCBT-I[Title/Abstract]
  OR "fully automated"[Title/Abstract]
)
AND
(
  systematic review[Publication Type]
  OR meta-analysis[Publication Type]
  OR systematic review[Title/Abstract]
  OR meta-analysis[Title/Abstract]
  OR randomized controlled trial[Publication Type]
  OR randomized[Title/Abstract]
  OR randomised[Title/Abstract]
)
```

Não aplicar filtro temporal relativo como `last X days`.

Razão:

> query dinâmica por relative date alteraria semanticamente o measurement a cada oportunidade.

A mesma query será repetida.

Comparação temporal ocorre pelo identifier set + source timepoints.

Comparator específico continua aplicado em downstream eligibility/triage, não como false-precision do query.

## 9. PubMed source time semantics

Candidate semantic codes:

- `pubmed_crdt`;
- `pubmed_edat`;
- `pubmed_epdat`;
- `pubmed_publication_date`;
- `pubmed_last_revision_date`, quando exposta e interpretável.

Precision deve refletir o source field real.

Date-only field:

> não será convertido em exact source timestamp fictício.

## 10. ClinicalTrials.gov opportunity set

Objetivo experimental:

- repeatable registry retrieval;
- NCT identifier comparison;
- first/update posting date observability;
- OES detection timestamping;
- update-record detection;
- effort;
- runtime/access reliability;
- replay.

Opportunity set:

| No. | planned_for |
|---|---|
| 1 | 2026-10-19T10:30:00-03:00 |
| 2 | 2026-10-22T10:30:00-03:00 |
| 3 | 2026-10-27T10:30:00-03:00 |
| 4 | 2026-10-30T10:30:00-03:00 |
| 5 | 2026-11-04T10:30:00-03:00 |
| 6 | 2026-11-09T10:30:00-03:00 |

Total:

> **6 opportunities**

As datas são mais esparsas que PubMed de forma deliberada.

O registry não recebe daily polling somente porque possui API.

### 10.1 Canonical payload candidate

```json
{
  "schema": "oes.temporal_opportunity_set/0.1",
  "non_normative": true,
  "schedule_kind": "finite_opportunity_set",
  "rationale": "Finite stepped ClinicalTrials.gov measurement design for registry identifier/update comparison, temporal endpoint observability and pilot effort.",
  "timezone_name": "America/Recife",
  "opportunities": [
    {"opportunity_no": 1, "planned_for": "2026-10-19T10:30:00-03:00"},
    {"opportunity_no": 2, "planned_for": "2026-10-22T10:30:00-03:00"},
    {"opportunity_no": 3, "planned_for": "2026-10-27T10:30:00-03:00"},
    {"opportunity_no": 4, "planned_for": "2026-10-30T10:30:00-03:00"},
    {"opportunity_no": 5, "planned_for": "2026-11-04T10:30:00-03:00"},
    {"opportunity_no": 6, "planned_for": "2026-11-09T10:30:00-03:00"}
  ]
}
```

## 11. ClinicalTrials.gov measurement strategy

Strategy code candidate:

> **TOPI-N2-DCBTI-CTG-B1-V1**

Query semantics:

> **insomnia AND (digital CBT OR digital CBT-I OR internet CBT-I)**

A actual API request/parameterization deverá ser congelada em `query_strategy_artifact_uuid` após connectivity verification e antes de materialização do EpochSource.

Required retrieval fields, quando disponíveis:

- NCT ID;
- StudyFirstPostDate;
- ResultsFirstPostDate;
- LastUpdatePostDate;
- minimal study status/identity metadata necessário para replay.

Não reter document payload desnecessário.

## 12. First-opportunity baseline semantics

Nenhuma das duas sources possui complete trustworthy epoch baseline materializado no OES.

Logo:

> **PRE_B1_BASELINE_ARTIFACT = NOT_AVAILABLE**

A primeira opportunity completed de cada source será:

> **OBSERVED_EPOCH_BASELINE_ACQUISITION**

Regras:

- first-event `novelty_state = not_applicable`;
- `new_identifier_count = NULL` no aggregate event;
- retrieved records podem ser structurally `new_to_epoch`;
- `new_to_epoch` significa apenas novo em relação ao epoch;
- não significa “novo na ciência”;
- não significa “novo desde evidence cutoff”;
- não dispara scientific update automaticamente.

A partir da segunda successful observation:

- `new_to_epoch`;
- `reobserved`;
- `updated_record`;

são avaliados contra observations anteriores do mesmo epoch.

## 13. Denominator semantics

### PubMed

ESearch normalmente fornece source result count.

Se a execução preservar trustworthy count:

> `raw_result_count_status = known`.

Se o runtime não puder provar o count:

> `unknown`.

### ClinicalTrials.gov

Se API response fornecer trustworthy total count para a query:

> `known`.

Caso contrário:

> `unknown`.

Em nenhuma source:

> NULL = zero.

## 14. Execution-time deviation semantics

`planned_for` é timestamp de desenho experimental.

Não é:

- due time;
- compliance deadline;
- SLA.

A diferença entre `planned_for` e `execution_started_at`:

- permanece dado operacional;
- pode gerar `execution_delay` deviation;
- não produz overdue/breach;
- não é automaticamente invalidante.

Materialidade depende do impacto sobre o measurement design.

Não existe tolerance/grace normativa oculta.

## 15. Fixed review rule

O B1:

> **não será estendido automaticamente se não houver new items.**

No review boundary:

- todas opportunities devem possuir resolution;
- ausência de target-specific novelty é resultado admissível;
- ausência de temporal endpoints observáveis é resultado admissível;
- insufficiency permanece insufficiency;
- nenhum schedule adicional nasce automaticamente.

Qualquer extensão exige:

- novo epoch ou nova plan version;
- novo frozen opportunity set;
- novo recheck;
- nova authority apropriada.

## 16. Early stop

Somente por blocker material:

- target deixa de current;
- source/API/interface muda materialmente;
- query strategy precisa mudar materialmente;
- runtime connectivity se perde de forma material;
- authority é retirada;
- data-governance blocker;
- security/safety incident;
- purpose drift;
- semantic storage failure;
- inability to preserve provenance.

Não existe early stop por:

- “já apareceu evidência”;
- “nenhuma evidência apareceu”;
- “parece suficiente”.

## 17. Information-gain claim

Este desenho pretende informar:

- B1 observability;
- B2 OES detection process;
- B3 pilot burden;
- parte de A2/volatility evidence;
- replay feasibility;
- missingness/failure behavior.

Ele não pretende estimar com precisão:

- incidence rate de novos estudos;
- stable source failure probability;
- sustainable capacity;
- normative cadence interval.

> **NO_STATISTICAL_POWER_CLAIM**

> **NO_MINIMUM_N_CLAIM**

## 18. Runtime connectivity ordering

A migration 033 tornou `temporal_observation_epoch_source` imutável.

O campo:

> `runtime_connectivity_status`

não pode ser atualizado depois.

Portanto, para B1:

> **RUNTIME_CONNECTIVITY_MUST_BE_VERIFIED_BEFORE_EPOCH_SOURCE_MATERIALIZATION**

Isso se aplica a:

- PubMed E-utilities;
- ClinicalTrials.gov API v2.

Nenhuma dessas verificações é scientific measurement.

São preparation probes limitados.

Se qualquer source falhar ou ficar causalmente indeterminada:

> B1 não deve ser materializado com falsa `verified`.

Não reduzir source scope silenciosamente.

## 19. Authority ordering

A migration 033 também exige:

> `operational authority decided_at >= design_frozen_at`.

Como `design_frozen_at` depende de:

- Epoch.created_at;
- EpochSource.created_at;
- Opportunity.created_at;

a Phase B execution authority final:

> **não pode ser validamente emitida antes da real draft materialization.**

Fluxo correto:

1. design documental + target-specific recheck;
2. explicit authority para preparation limitada;
3. runtime connectivity probes;
4. real draft materialization;
5. payload↔Opportunity equality;
6. calcular/preservar design_frozen_at;
7. emitir novo Phase B execution authority package para exact frozen Epoch;
8. owner/institutional decision posterior ao freeze;
9. persistir authority row;
10. transition `draft → authorized_non_normative`;
11. transition separada `authorized_non_normative → active`;
12. executar opportunities.

Isso não exige mudança de schema.

## 20. Schedule expiry rule

Se o B1 não estiver corretamente materializado, re-gated e autorizado antes da primeira opportunity:

> **não deslizar os timestamps.**

Não “empurrar” datas para frente.

Nesse caso:

> **B1_CANDIDATE_SCHEDULE = EXPIRED_NOT_EXECUTED**

e deve ser produzido novo frozen opportunity set em novo documento/epoch.

Isso é necessário para impedir post-hoc schedule rewriting.

## 21. BVS/LILACS debt

BVS/LILACS permanece no Plan candidate universe como:

> **deferred**

Reason:

> `access_path_not_reproducible`

Reassessment trigger:

- stable programmatic access path estabelecido; ou
- explicit manual measurement design versionado/re-gated.

BVS não possui Opportunity no B1.

Completion do B1:

> **não significa complete source coverage.**

## 22. Materialização física candidate

Se futuramente autorizada, a primeira physical Plan row deve representar a specification v0.2-final.

Recomendação:

- `plan_code = TOPI-N2-DCBTI-01`;
- `plan_version = 2`;
- exact ProductVersion target;
- `calibration_object = cadence`;
- `readiness_scope = policy_aggregate`;
- physical v0.1 documental nunca foi materializada, portanto `supersedes_observation_plan_uuid` pode permanecer NULL com rationale explícito.

Epoch:

- `epoch_code = B1`;
- initial state = `draft`;
- start/review boundaries conforme seção 6.

Nenhum UUID é reservado neste documento.

## 23. Estado candidato

> **TOPI_N2_DCBTI_V02_FINAL_DESIGN = SPECIFIED_CANDIDATE**

> **PHASE_B_EXPERIMENTAL_DESIGN = FINITE_IRREGULAR_SOURCE_SPECIFIC**

> **PUBMED_OPPORTUNITIES = 8**

> **CLINICALTRIALS_GOV_OPPORTUNITIES = 6**

> **OBSERVATION_WINDOW = 2026-10-19_TO_2026-11-10**

> **BVS_LILACS = DEFERRED_SOURCE_DEBT**

> **RUNTIME_CONNECTIVITY = REQUIRED_BEFORE_EPOCH_SOURCE_MATERIALIZATION**

> **DRAFT_MATERIALIZATION = NOT_AUTHORIZED**

> **PHASE_B_EXECUTION_AUTHORITY = CANNOT_BE_VALIDLY_REQUESTED_BEFORE_DESIGN_FREEZE**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 24. Próximo passo

> **Executar target-specific adversarial recheck deste desenho.**

Se PASS:

> **emitir pacote explícito para autorizar somente preparation probes + draft materialization.**

Esse pacote não será Phase B execution authority.

**Fim do Documento 69**
