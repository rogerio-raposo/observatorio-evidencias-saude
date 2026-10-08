# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — TOPI-N2-DCBTI-01 Phase A Characterization

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP114  
**Checkpoint anterior:** CP113  
**Status:** artefato de continuidade; não normativo  
**Escopo:** registro da authority explícita e conclusão da Phase A da primeira Temporal Observation Plan Instance

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **AUTHORITY_DECISION = APPROVED_FOR_PHASE_A**

> **PHASE_A_OPERATIONAL_EXECUTION_AUTHORITY = GRANTED**

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

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP113 foi confirmado:

- branch `main`;
- HEAD inicial `7f6ea93e311d5f43615bc7a7b98585ebda8a9e95`;
- CP113 vigente;
- nenhum avanço concorrente;
- Documento 56 aguardando decisão explícita;
- TOPI-N2-DCBTI-01 selecionada e target-specific gate = PASS_FOR_AUTHORITY_REQUEST_ONLY.

## 3. Decisão de authority

O proprietário respondeu explicitamente:

> **Approved - phase A / documento 56 / TOPI-N2-DCBTI-01**

A decisão foi registrada em:

`docs/governance/57-registro-decisao-authority-phase-a-topi-n2-dcbti-01.md`

Commit:

`9270c3835e588405293b9ca1fe9637ae4a58ad87`

Escopo da approval:

- source characterization;
- source-access/data-governance review;
- semantic storage confirmation;
- UpdateRiskProfile evidence preparation;
- characterization effort logging;
- provenance/locator preservation.

Não autorizou Phase B ou qualquer regra temporal normativa.

## 4. Phase A Characterization Package

Arquivo:

`docs/governance/58-topi-n2-dcbti-phase-a-characterization-package.md`

Commit:

`a8315e67ad1917c92d3c0141abd1d61b4a13adb0`

STATE:

`1d8f90e1aa1eca8bff0b1226005977e852443378`

CHANGELOG:

`793fbae0b785fe9027e199c026b98318600f0553`

## 5. Método preservado

A Phase A:

- não executou busca científica target-specific nova;
- não criou Search;
- não criou SearchHit;
- não criou ScreeningDecision;
- não criou MonitoringCycle;
- não criou CadenceObservation;
- não iniciou polling repetido;
- não selecionou measurement interval.

Foram usados documentação oficial, páginas oficiais e probes mínimos compatíveis com characterization.

Falhas de acesso mediadas pelas ferramentas foram classificadas como:

> **TOOL_MEDIATED / FAILURE_ATTRIBUTION_UNKNOWN**

e não como source outage.

## 6. PubMed/MEDLINE

Achados principais:

- interface web oficial;
- E-utilities público;
- ESearch/EInfo/ESummary/EFetch;
- updates de corpus documentados como diários;
- CRDT, EDAT, MHDA e publication-date fields disponíveis;
- NLM informa que publication-to-PubMed availability varia conforme publisher deposit;
- EDAT tipicamente é definido dentro de 24h da disponibilidade da citation no PubMed;
- usage guidance e rate limits são explicitamente documentados.

Conclusão:

> **PUBMED_SOURCE_CHARACTERIZATION = SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_CONTROLS**

Isso não autoriza Phase B.

## 7. BVS/LILACS

Achados principais:

- BVS Regional Portal gratuito;
- IAHx = integrated multilingual search interface;
- FI-Admin gerencia LILACS e outras sources;
- modelo LILACS contém record creation, transfer e change dates;
- páginas de resultados BVS/LILACS são observáveis;
- current stable public programmatic API contract para o intended OES path não foi estabelecido;
- direct tool access apresentou 403/timeout em algumas tentativas, sem causal attribution à source.

Conclusão:

> **BVS_LILACS_SOURCE_CHARACTERIZATION = PARTIAL**

> **BVS_LILACS_PHASE_B_USE = BLOCKED_PENDING_REPRODUCIBLE_ACCESS_PATH_OR_EXPLICIT_MANUAL_DESIGN**

## 8. ClinicalTrials.gov

Achados principais:

- modernized API v2 documentada pela NLM;
- REST;
- OpenAPI 3.0;
- JSON primary response;
- current web/download interfaces;
- CSV/JSON/RIS/FHIR;
- record fields incluem First Posted, Last Update Posted e related QC submission dates;
- esses campos permitem observar registry posting process, não article-publication latency;
- direct API probe não foi possível pelo current retrieval channel, sem inferir API/source failure.

Conclusão:

> **CLINICALTRIALS_GOV_SOURCE_CHARACTERIZATION = SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_RUNTIME_CONNECTIVITY_CHECK**

## 9. Latency discipline

PubMed:
- publication/create/entry dates podem permitir bounded/date-level analysis;
- não transformar date precision em timestamp exato.

BVS/LILACS:
- record-date model existe;
- public reproducible operational path ainda insuficiente.

ClinicalTrials.gov:
- registry posting intervals são observáveis via record fields;
- não confundir posting latency com OES detection latency.

Nenhuma numeric latency foi calibrada.

## 10. Semantic storage result

Phase A confirma:

- source documentation fact → repository artifact/documentation;
- source access probe → audit log/artifact;
- scientific retrieval → `investigation.search` somente se for Search científica real;
- latency observation → artifact/log enquanto não houver event object específico;
- characterization effort → operational artifact/log;
- pre-calibration measurement != CadenceObservation.

## 11. UpdateRiskProfile preparation

Nenhum rating authoritative foi emitido.

Estado consolidado:

- A1 = evidence prepared; human judgment required;
- A2 = evidence prepared; volatility not rated;
- A3 = evidence prepared; human judgment required;
- A4 = evidence prepared; no rating;
- A5 = dependency reach not established;
- B1 = source heterogeneity material;
- B2 = evidence prepared; no rating;
- B3 = insufficient for rating;
- B4 = insufficient for rating;
- B5 = missing.

Logo:

> **UPDATE_RISK_PROFILE = EVIDENCE_PREPARATION_ONLY**

## 12. Data governance

PubMed:

> PASS_WITH_CONTROLS

BVS/LILACS:

> PASS_FOR_METADATA_CHARACTERIZATION / PHASE_B_ACCESS_UNRESOLVED

ClinicalTrials.gov:

> PASS_WITH_CONTROLS

Nenhum patient-level data é necessário.

Secrets/credentials não devem ser armazenados em audit artifacts.

## 13. Measurement schedule

> **NOT_SELECTED**

A Phase A não sustenta ainda um único intervalo experimental multi-source sem risco de anchoring/falsa precisão.

PubMed daily corpus update não determina schedule do OES.

ClinicalTrials.gov posting semantics são distintas de PubMed indexing.

BVS access debt permanece aberto.

## 14. Physical-contract finding

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = NOT_REQUIRED_FOR_PHASE_A**

Necessidade de event object dedicado para Phase B permanece:

> **UNRESOLVED**

Nenhuma migration autorizada.

## 15. Phase A boundary

PubMed:

> sufficiently characterized

ClinicalTrials.gov:

> sufficiently characterized

BVS/LILACS:

> sufficient to conclude partial/not fully characterizable for programmatic Phase B under current access path

Logo:

> **PHASE_A = COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS**

## 16. Próximo passo exato

Após a pausa obrigatória:

> **especificar Plan Amendment v0.2 da TOPI-N2-DCBTI-01.**

O amendment deverá decidir explicitamente:

1. source inclusion para Phase B;
2. tratamento de BVS/LILACS:
   - exclude from initial repeated measurement; ou
   - manual/non-programmatic track; ou
   - additional access-resolution sub-block;
3. event model da Phase B;
4. storage mapping;
5. necessidade ou não de dedicated physical event object;
6. measurement schedule non-normative somente se metodologicamente justificável;
7. review boundary;
8. target-specific recheck;
9. nova explicit authority antes de qualquer Phase B.

## 17. Disciplina de modo

A execução documental da Phase A pôde ser conduzida em complexidade média.

Porém o próximo bloco volta a conter decisão metodológica difícil de reverter:

- source inclusion;
- eventual numeric measurement schedule;
- possível physical-event gap.

> **Modo alto é recomendado novamente para o Plan Amendment v0.2.**

## 18. Regra de parada

Após ativação do CP114:

> **parar e aguardar “Prossiga” explícito do usuário.**

## 19. HEAD antes da criação do CP114

`793fbae0b785fe9027e199c026b98318600f0553`

**Fim do CP114**
