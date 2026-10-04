# 56 — Caso Real 01: Reconciliação de Continuidade e Hardening do EvidenceSheetView

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — validação científica ponta a ponta da Ficha  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Data:** 4 de outubro de 2026  
**Status:** decisão de reconciliação consolidada

---

# 1. Contexto

Durante o desenvolvimento paralelo do Caso Real 01 foram criados, quase simultaneamente:

- duas migrations numeradas como 008;
- dois documentos numerados como 55.

As mudanças não eram equivalentes:

1. uma migration 008 tornou as referências da Ficha **provenance-aware**;
2. outra migration 008 adicionou contagem de Studies por `study_type`;
3. um Documento 55 consolidou a representação de síntese externa adotada + atualização OES em duas Syntheses distintas;
4. outro Documento 55 propôs uma representação parcialmente sobreposta.

A coexistência desses pares produziria ambiguidade de continuidade e ordem de migrations.

---

# 2. Regra aplicada

Foi aplicado o princípio:

> **preservar todas as capacidades compatíveis, manter uma única sequência canônica e eliminar duplicidade nominal.**

Nenhuma capacidade validada foi deliberadamente descartada.

---

# 3. Migration canônica 008

Fica preservada como:

`database/008_evidence_sheet_provenance_references.sql`

Funções principais:

- `product.evidence_sheet_reference_reports(...)`;
- EvidenceSheetView com referências derivadas também de provenance/dependency graph;
- inclusão de Reports usados por sínteses externas adotadas mesmo quando não aparecem diretamente como ResultSource da Synthesis prioritária.

Motivo:

> uma síntese externa adotada precisa permanecer visível nas referências da Ficha mesmo quando sua Synthesis não é diretamente vinculada como priority result.

---

# 4. Migration canônica 009

A capacidade de discriminar os tipos de evidência foi renumerada e reconstruída sobre a migration 008.

Arquivo:

`database/009_evidence_sheet_view_evidence_counts.sql`

Ela:

- preserva a lógica provenance-aware da 008;
- adiciona `evidence_base.study_type_counts`;
- mantém `schema_version = oes.evidence_sheet_view/0.1`, pois a mudança é aditiva e compatível.

Exemplo:

```json
[
  {"study_type":"primary_study","count":3},
  {"study_type":"systematic_review","count":1}
]
```

---

# 5. Migration duplicada removida

Foi removido:

`database/008_evidence_sheet_view_evidence_counts.sql`

Motivo:

- duplicava o número 008;
- era baseada na 007;
- se aplicada após a migration provenance-aware, poderia sobrescrever a função EvidenceSheetView e eliminar a melhoria de referências.

A remoção evita regressão silenciosa.

---

# 6. Documento 55 canônico

Fica preservado:

`docs/products/55-caso-real-01-decisao-arquitetural-sintese-adotada.md`

Decisão central:

> representar separadamente a Synthesis quantitativa externa adotada e a Synthesis narrativa de atualização OES.

Estrutura:

## Synthesis externa

- `synthesis_origin = adopted_external`;
- resultado publicado preservado;
- `recalculated_by_oes = false`.

## Synthesis de atualização

- `synthesis_origin = oes_update`;
- sem novo pooling;
- contribuições dos RCTs novos;
- certainty OES vinculada à síntese atualizada.

Essa separação é preferida à mistura de estimativa externa e atualização OES em uma única Synthesis.

---

# 7. Documento 55 duplicado removido

Foi removido:

`docs/products/55-caso-real-01-decisao-sintese-externa.md`

Sua contribuição útil — discriminação das unidades por `study_type` — foi preservada nesta evolução do EvidenceSheetView.

---

# 8. Regra de contagem

A Ficha não deverá apresentar `study_count` isoladamente como:

> total de estudos do corpo de evidências.

Em casos com revisão sistemática adotada:

- uma systematic review é uma Study identity no OES;
- ela pode representar k estudos primários subjacentes não materializados individualmente;
- RCTs novos são Studies adicionais.

O template deverá distinguir:

> **unidades de evidência diretamente modeladas no OES**

e detalhar por `study_type`.

O número k reportado pela meta-análise externa permanece em `result_summary`.

---

# 9. Referências científicas

A função provenance-aware deverá permitir que a Ficha liste:

- Reports diretamente usados como ResultSource;
- Reports que sustentam Synthesis/Certainty/Product via ProvenanceRecord e DependencyEdge.

Isso é necessário para o Caso Real 01, no qual:

> a revisão Hwang é uma âncora quantitativa externa, mas não deve ser indevidamente apresentada como Synthesis prioritária recalculada pelo OES.

---

# 10. Workflow canônico

A sequência de validação passa a ser:

1. baseline;
2. migrations 002–007;
3. migration 008 — provenance-aware references;
4. migration 009 — study type counts;
5. regressões F2-B/S4/S5;
6. contrato da Ficha;
7. EvidenceSheetView;
8. testes provenance-aware;
9. template;
10. rebuild completo.

O run anterior à reconciliação não é considerado evidência final para esta arquitetura.

---

# 11. Critério para prosseguir ao caso real

Somente após PASS do workflow reconciliado será permitido:

- materializar Hwang;
- materializar os RCTs de atualização;
- criar as duas Syntheses;
- registrar GRADE provisório;
- criar ProductVersion `under_review`;
- gerar EvidenceSheetView real;
- renderizar preview.

---

# 12. Conclusão

A atividade paralela revelou um risco real do mecanismo de continuidade:

> numeração concorrente de migrations/documentos pode criar conflito mesmo quando as mudanças são individualmente corretas.

A reconciliação preservou:

- provenance-aware references;
- contagem por tipo de Study;
- separação entre síntese externa e atualização OES;
- sequência única de migrations;
- uma única decisão canônica de Documento 55.

---

**Sequência canônica após reconciliação:** 007 → 008 provenance → 009 evidence counts.
