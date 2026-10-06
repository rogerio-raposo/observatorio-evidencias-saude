# 143 — Resultado do Projection Readiness Gate do Overview de Revisões

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** **Projection Readiness = READY**  
**Dependências:** Documentos 138–142; migrations 019–020

---

# 1. Finalidade

Registrar o resultado da extensão aditiva da `OverviewOfReviewsView` para suportar renderização auditável e somente leitura.

Resultado:

> **Projection Readiness Gate = READY para especificação do template operacional.**

Este resultado não equivale a:

- readiness de Caso Real;
- autorização de publicação real;
- validação clínica;
- readiness operacional completa do produto.

---

# 2. Migration 020

Arquivo:

`database/020_overview_of_reviews_view_rendering_readiness.sql`

Natureza:

> **aditiva e idempotente.**

A migration 019 permanece fechada.

A migration 020 amplia a projeção sem alterar:

- as sete estruturas `overview`;
- overlap math;
- publication semantics;
- assurance semantics;
- scientific source-of-truth tables.

---

# 3. Lacunas do Documento 142 resolvidas

A projeção ampliada passa a expor os elementos auditáveis necessários ao renderer:

1. method decisions completos;
2. reviewer conflicts e metadata de assignment;
3. quality-control audit payloads;
4. search export artifact metadata;
5. selection/exclusion details;
6. Review Report lineage;
7. OutcomeEvidence ResultSource/provenance;
8. dependency lineage e invalidation detail.

O renderer futuro poderá permanecer read-only sobre a View.

---

# 4. Testes

Arquivo:

`database/f3-overview-view-rendering-readiness-tests.sql`

Resultado:

> **OVR-T01–T12 PASS.**

Cobertura:

- OVR-T01 — schema version preservado;
- OVR-T02 — method decisions completos;
- OVR-T03 — reviewer conflict/assignment metadata;
- OVR-T04 — quality-control audit payloads;
- OVR-T05 — search export hash/storage metadata;
- OVR-T06 — selection/exclusion details;
- OVR-T07 — Review A update lineage explícita;
- OVR-T08 — OutcomeEvidence ResultSource/provenance;
- OVR-T09 — dependency lineage/invalidation detail;
- OVR-T10 — overlap/CCA/publication/assurance semantics preservadas;
- OVR-T11 — migration 020 idempotent reapply;
- OVR-T12 — rebuild/regressions PASS.

---

# 5. CI

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

- **37503751486**
- conclusion: **success**
- commit validado: `2d57aae08afe4c797841844c188f9f516faefdcb`.

Artifact:

- ID **11430083884**;
- nome `oes-s5-evidence-37503751486`;
- tamanho **160462 bytes**;
- digest `sha256:f599426adb3afd5cc28066c00eb0de73c6d18dd734f622d58e9f0f5f9be418a5`.

---

# 6. Evidência de validação

O log final registra:

- `OVR-T01–T10 PASS`;
- `OVR-T11 PASS`;
- `OVR-T01–T12 PASS`;
- `Overview projection-readiness PASS`;
- rebuild through migration 020 = PASS.

As regressões permaneceram verdes para:

- N0;
- N1;
- N2;
- N3;
- N4;
- Evidence Map;
- MAP-01;
- Overview technical contract.

---

# 7. Decisão

Com a migration 020 validada:

> **a OverviewOfReviewsView está READY para servir como única fonte do renderer.**

Isso encerra o embargo técnico que impedia a especificação do template por insuficiência da projeção.

Ainda permanece obrigatório:

- definir template contract antes de implementação;
- não acessar tabelas diretamente no renderer;
- não recalcular CCA/pairwise;
- não criar certainty;
- não criar reanalysis;
- não criar comparação indireta informal;
- manter eligibility separada de overlap disposition;
- manter ROBIS separado de certainty/currentness.

---

# 8. Próxima etapa

> **Especificar o Template Operacional do Overview de Revisões a partir do contrato de renderização do Documento 142 e da View ampliada validada pela migration 020.**

Sequência recomendada:

1. especificação formal do template;
2. presentation map;
3. renderer;
4. validator;
5. fixture renderizada;
6. testes de apresentação;
7. resultado da validação da camada de apresentação;
8. readiness pré-caso real.

---

**Resultado final:** `OverviewOfReviewsView` com Projection Readiness **READY** para template operacional.
