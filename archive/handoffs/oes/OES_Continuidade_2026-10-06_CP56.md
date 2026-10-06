# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP56  
**Checkpoint anterior:** CP55  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação do Template Operacional do Overview de Revisões  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP56

> **Template Operacional do Overview de Revisões especificado; implementação ainda não iniciada.**

Documento canônico:

`docs/products/144-especificacao-template-overview-revisoes.md`

## 2. Estado da View

- migration 019 = PASS;
- migration 020 = PASS;
- Projection Readiness = READY;
- input contract = `oes.overview_of_reviews_view/0.1`;
- renderer deverá permanecer read-only sobre a View.

## 3. Princípios vinculantes

- Review ≠ Report;
- eligibility ≠ overlap disposition;
- overlap/CCA/pairwise não são recalculados;
- ROBIS ≠ certainty ≠ currentness;
- certainty ausente não vira baixa certainty;
- global Overview certainty é proibida;
- indirect comparison informal é proibida;
- renderer não cria reanalysis;
- assurance e publication gate são dimensões distintas.

## 4. Arquivos previstos

- `templates/overview-of-reviews.md`;
- `templates/overview-of-reviews-presentation-map.json`;
- `scripts/render_overview_of_reviews_reference.py`;
- `scripts/validate_overview_of_reviews_render.py`.

## 5. Cenários de validator

1. formal synthetic fixture;
2. A3 + publishable=false;
3. membership incompleta / CCA não calculável;
4. certainty ausente;
5. concordance = not_comparable;
6. invalidated dependency.

## 6. Critérios de PASS da próxima etapa

- render da fixture;
- validator positivo;
- validators adversariais;
- nenhum token não resolvido;
- nenhuma lógica científica no renderer;
- integração S5;
- regressões;
- rebuild.

## 7. Ponto exato de retomada

> **Implementar os quatro arquivos da camada de apresentação do Overview, integrar ao S5 e validar os cenários definidos no Documento 144.**

**Fim do CP56**
