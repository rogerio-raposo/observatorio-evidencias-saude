# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP50  
**Checkpoint anterior:** CP49  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação científica e decisão arquitetural do Overview de Revisões  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP49 criado no commit `a7493caf6541eb7ef2a54a7f67dc20d5bc39d8a4`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP49: `ahead`;
- commits à frente: **11**;
- commits atrás: **0**.

Avanço material:

- Documento 138 — Especificação Científica e Funcional do Overview de Revisões;
- Documento 139 — Revisão de Coerência e Decisão Arquitetural;
- atualização de STATE, CHANGELOG e índice de produtos.

## 2. Marco do CP50

> **Overview de Revisões cientificamente especificado e arquitetura especializada mínima definida.**

Nenhuma migration ou template do Overview foi criado até este checkpoint.

## 3. Escopo formal v0.1

- systematic reviews quantitativas de intervenções em saúde;
- unidade principal = Review StudyVersion;
- supplemental primary studies fora do corpus analítico formal;
- ROBIS como default de risk of bias;
- formal Overview exige Investigation depth N4;
- formal publication exige A3 + qualified human controls.

## 4. Reuse de OES-P1

Reutilizar:

- Study/StudyVersion;
- StudyReportLink;
- ReportRelation;
- Result;
- RiskAssessment/ROBIS;
- Synthesis;
- CertaintyAssessment;
- Search/SearchHit/ScreeningDecision;
- ReviewerAssignment/QualityControlRecord;
- Product/Assurance;
- Artifact/Provenance.

Não criar entidade paralela Review ou Overview.

## 5. Camada especializada aprovada

Schema candidato:

`overview`

Sete estruturas:

1. `overview.review_item`;
2. `overview.primary_study_membership`;
3. `overview.review_cluster`;
4. `overview.cluster_membership`;
5. `overview.overlap_resolution`;
6. `overview.outcome_evidence`;
7. `overview.concordance_assessment`.

## 6. Invariantes centrais

- ReviewItem aponta para StudyVersion concreta;
- overlap é Study-level, não citation-level;
- membership é verdade persistida;
- CCA/pairwise overlap são derivados;
- eligibility é distinta de overlap disposition;
- OutcomeEvidence seleciona Result/Synthesis existente e não copia estimate;
- certainty global do Overview é proibida;
- meta-analysis de review estimates sobrepostos como independentes é proibida;
- A3 não substitui stage controls;
- IA não satisfaz papel humano qualificado.

## 7. Ponto exato de retomada

> **Criar o Contrato de Dados v0.1 do Overview de Revisões, fechando DDL lógico, guards, overlap derivado, publication gate e OverviewOfReviewsView antes de qualquer template.**

## 8. Sequência

1. Documento 140 — contrato de dados;
2. migration;
3. fixture formal sintética;
4. testes positivos/adversariais;
5. OverviewOfReviewsView;
6. rebuild/regressões;
7. PASS técnico;
8. somente então contrato de renderização/template;
9. Infrastructure Readiness Gate pré-caso real.

**Fim do CP50**
