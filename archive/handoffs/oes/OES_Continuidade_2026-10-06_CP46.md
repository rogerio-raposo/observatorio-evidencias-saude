# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP46  
**Checkpoint anterior:** CP45  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento pré-persistência do Caso Real MAP-01  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP45 criado no commit `d9911b51fb0ce5b3cf23729580c4c6388b01f079`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP45: `ahead`;
- commits à frente: **9**;
- commits atrás: **0**.

Avanço material:

- Documento 132 — protocolo MAP-01;
- Documento 133 — inventário formal do corpus/MapItems;
- Documento 134 — codebook v0.1;
- atualização de STATE, CHANGELOG e índice de produtos.

## 2. Marco do CP46

> **MAP-01 está metodologicamente pré-especificado antes da persistência.**

Ainda não existem Framework/Product/MapItems do caso no banco.

## 3. Inventário fechado

- 5 StudyVersions;
- 8 contextual ReportVersions;
- 4 SynthesisVersions;
- total = **17 MapItems**.

Células previstas:

- 20 combinações `evidence_role × outcome_domain`;
- 18 `in_scope`;
- 1 `excluded_by_framework`;
- 1 `not_applicable`.

## 4. Configuração autorizada

- subtype = `descriptive_mapping_review`;
- coverage = `structured_non_exhaustive`;
- gap mode = `apparent_only`;
- counting unit = `study`;
- interno/experimental;
- inicialmente A0;
- A1 apenas após AI methodological verification = passed;
- não publicado.

## 5. Decisão arquitetural

> **Reutilizar a InvestigationVersion N3-01 `e1000000-0000-0000-0000-000000000002` como primary Investigation do MAP-01.**

Motivo:

- preserva Searches/Screening canônicos;
- evita duplicação artificial;
- é consistente com a natureza transversal do Mapa;
- depth N3 descreve a investigação de suporte, não o nível do Mapa.

## 6. Regras de classificação

- actor_type = `ai_system`;
- rule_based ou ai_assisted;
- decision_state final permitido;
- verification_status = `unverified`;
- nenhum human_verified;
- nenhum ReviewerAssignment humano novo.

## 7. Ponto exato de retomada

> **Persistir o MAP-01 usando protocolo, inventário e codebook como artifacts, sem duplicar Search/Screening e sem alterar o N3-01.**

## 8. Sequência

1. artifacts protocolo/codebook;
2. Framework/FrameworkVersion;
3. dimensions/categories;
4. 17 MapItems;
5. assignments;
6. 20 CellScope;
7. Product/links;
8. testes de integridade;
9. render;
10. AI methodological verification/adversarial layer;
11. encerramento com assurance real.

**Fim do CP46**
