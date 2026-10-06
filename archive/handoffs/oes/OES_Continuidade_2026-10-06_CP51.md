# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP51  
**Checkpoint anterior:** CP50  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento do Contrato de Dados v0.1 do Overview de Revisões  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP50 criado no commit `c52dd10a095566dbc2425efb2e6820df14dc2424`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP50: ahead;
- sem divergência para trás;
- avanço material: Documento 140 + alinhamento de STATE/CHANGELOG/índice.

## 2. Marco do CP51

> **Contrato de Dados v0.1 do Overview de Revisões fechado.**

Documento canônico:

- `docs/products/140-contrato-dados-overview-revisoes.md`

## 3. Estruturas especializadas aprovadas

Schema:

> `overview`

Sete estruturas:

1. `overview.review_item`;
2. `overview.primary_study_membership`;
3. `overview.review_cluster`;
4. `overview.cluster_membership`;
5. `overview.overlap_resolution`;
6. `overview.outcome_evidence`;
7. `overview.concordance_assessment`.

## 4. Invariantes

- systematic review continua Study/StudyVersion;
- membership Review × primary Study é verdade persistida;
- CCA e pairwise overlap são derivados;
- double counting é proibido;
- OutcomeEvidence referencia Result/Synthesis existentes;
- certainty global do Overview é proibida;
- supplemental primary studies não integram o corpus analítico formal v0.1;
- A3 não substitui stage controls;
- IA não satisfaz papel humano qualificado.

## 5. Limitação deliberada v0.1

`include_all_deduplicate_outcomes` permanece no enum, mas:

> **é BLOQUEADA para publicação formal v0.1**

até existir representação relacional outcome-level de primary-study membership.

Formal v0.1 aceita:

- `prioritize_review`;
- `include_all_separate_estimates`.

## 6. Publication gate

Contrato especifica blockers para:

- identidade/Product/Investigation;
- protocolo;
- policies;
- busca;
- screening;
- ReviewItems;
- ROBIS;
- membership;
- clusters;
- overlap strategy;
- OutcomeEvidence;
- concordance;
- certainty;
- supplemental primary studies;
- reanalysis;
- assurance;
- publication/currency.

Formal Overview exige:

- primary Investigation N4;
- A3;
- qualified human controls;
- overlap/membership completos e verificados.

## 7. View

Schema:

> `oes.overview_of_reviews_view/0.1`

Projetará:

- identity/question/investigation;
- method policies;
- searches/flow;
- review_items;
- membership;
- overlap;
- outcome evidence;
- ROBIS;
- concordance;
- audit/publication issues/assurance.

## 8. Testes previstos

OV-T01–T33:

- positivos;
- adversariais;
- overlap/CCA;
- update identity;
- ROBIS;
- assurance;
- double counting;
- reanalysis;
- rebuild;
- regressões N0–N4 + Evidence Map.

## 9. Embargo

> **Nenhum template do Overview antes de PASS técnico da migration 019, fixture, gate, View, rebuild e regressões.**

## 10. Ponto exato de retomada

> **Implementar `database/019_overview_of_reviews_contract.sql`, fixture formal sintética e testes OV-T01–T33, sem criar template.**

**Fim do CP51**
