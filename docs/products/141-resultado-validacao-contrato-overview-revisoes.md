# 141 — Resultado da Validação Técnica do Contrato do Overview de Revisões

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** **PASS técnico**  
**Dependências:** Documentos 138–140; migration 019

---

# 1. Finalidade

Registrar o resultado da implementação e validação do contrato técnico v0.1 do Overview de Revisões antes de qualquer camada de apresentação.

Resultado:

> **Overview of Reviews contract = PASS técnico.**

O PASS é:

- arquitetural;
- sintético;
- baseado em fixture formal controlada;
- não constitui readiness de Caso Real;
- não autoriza publicação de um Overview real.

---

# 2. Migration

Implementada:

`database/019_overview_of_reviews_contract.sql`

A migration cria:

- schema `overview`;
- `overview.review_item`;
- `overview.primary_study_membership`;
- `overview.review_cluster`;
- `overview.cluster_membership`;
- `overview.overlap_resolution`;
- `overview.outcome_evidence`;
- `overview.concordance_assessment`;
- guards;
- métricas derivadas de overlap;
- helper de referências;
- publication gate;
- `OverviewOfReviewsView`.

Nenhum template do Overview foi criado nesta etapa.

---

# 3. Fixture formal sintética

Arquivo:

`database/f3-overview-of-reviews-fixtures.sql`

A fixture contém:

- 3 systematic Review StudyVersions;
- 5 primary Study entities;
- 9 memberships;
- Review A = Studies 1,2,3;
- Review B = Studies 2,3,4;
- Review C = Studies 3,4,5;
- 1 cluster multi-review;
- Review B priorizada;
- strategy `prioritize_review`;
- Review A com original + update Report;
- ROBIS para as três reviews;
- Review C = high ROBIS;
- Result por review;
- certainty reportada em A/B;
- concordance assessment;
- qualified human controls sintéticos;
- synthetic A3.

---

# 4. Overlap matemático

Com:

- c = 3 reviews;
- r = 5 primary Studies únicos;
- N = 9 membership occurrences;

CCA esperado:

`(9 - 5) / (5 × 3 - 5) = 4 / 10 = 0.4`

Resultado:

> **CCA = 0.4 — PASS.**

Pairwise overlap:

- A × B: 2 Studies compartilhados; Jaccard = 0.5;
- A × C: 1 Study compartilhado; Jaccard = 0.2;
- B × C: 2 Studies compartilhados; Jaccard = 0.5.

Os valores são derivados; não são persistidos como verdade primária.

---

# 5. Testes positivos

Arquivo:

`database/f3-overview-of-reviews-tests-a.sql`

Resultado:

> **OV-T01–T13 PASS.**

Cobertura:

- formal fixture publishable A3;
- 3 ReviewItems;
- 5 primary Studies únicos;
- 9 membership occurrences;
- CCA 0.4;
- pairwise overlap correto;
- update Report não duplica ReviewItem;
- ROBIS por Review;
- Review B unicamente priorizada;
- OutcomeEvidence pertence à Review correta;
- certainty preservada;
- concordance projetada;
- referências priorizam Review Reports;
- smoke test da `OverviewOfReviewsView`.

---

# 6. Testes adversariais

Arquivos:

- `database/f3-overview-of-reviews-tests-b1.sql`;
- `database/f3-overview-of-reviews-tests-b2.sql`;
- `database/f3-overview-of-reviews-tests-b3.sql`.

Resultado:

> **OV-T14–T30 PASS.**

Validados:

- multiple Reports/updates não criam Reviews duplicadas;
- duas StudyVersions ativas da mesma Review são rejeitadas;
- shared Studies são de-duplicados nas métricas;
- membership incompleta torna CCA não calculável;
- low-confidence membership fecha gate formal;
- IA não pode preencher papel de human verification;
- missing ROBIS fecha gate;
- Result da Review errada é rejeitado;
- missing overlap resolution fecha gate;
- `include_all_deduplicate_outcomes` é bloqueado formalmente no v0.1;
- A3 não bypassa missing overlap control;
- OutcomeEvidence sem human verification fecha gate;
- global Overview certainty é rejeitada;
- supplemental primary Result é bloqueado no formal v0.1;
- review outdated permanece disclosure;
- reanalysis sem code/dataset/statistical review fecha gate;
- invalidated dependency fecha gate.

---

# 7. Migration/rebuild/regressões

## OV-T31

Migration 019 é one-shot.

Resultado:

> **OV-T31 PASS — duplicate application detectada.**

## OV-T32

Rebuild do zero:

> **PASS.**

A fixture e os testes do Overview foram reaplicados no banco reconstruído.

## OV-T33

Regressões:

- N0 = PASS;
- N1 = PASS;
- N2 = PASS;
- N3 = PASS;
- N4 = PASS;
- Evidence Map = PASS;
- MAP-01 = PASS;
- demais regressões S5 = PASS.

Resultado:

> **OV-T33 PASS.**

---

# 8. OverviewOfReviewsView

Schema:

`oes.overview_of_reviews_view/0.1`

Resultado:

> **PASS.**

A View projeta:

- identity;
- question;
- primary Investigation;
- protocol;
- policies;
- reviewer assignments;
- quality controls;
- Searches;
- selection flow;
- ReviewItems;
- Review Reports;
- ROBIS;
- primary-study membership;
- overlap/CCA/pairwise;
- cluster resolution;
- OutcomeEvidence;
- certainty;
- concordance;
- references;
- currency;
- assurance;
- publication issues.

O renderer futuro não deverá recalcular overlap.

---

# 9. CI final

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

- **37502184404**
- conclusion: **success**
- commit validado: `58326461f4ffb5f23bc908be9f9cbcfb1663e149`.

Artifact:

- ID **11430003081**;
- nome `oes-s5-evidence-37502184404`;
- tamanho **158492 bytes**;
- digest `sha256:94759585098f90d0227a3d4435056807c18e72af1e01a558e7a5dad3267afee3`.

---

# 10. Correções durante a fixture

Duas execuções integradas anteriores falharam exclusivamente por defeitos de dados da fixture:

1. UUID de Primary Study 4 com um grupo ausente;
2. valor de `rationale` omitido no INSERT de `concordance_assessment`.

Ambos foram corrigidos sem alteração da migration 019, do publication gate ou da View.

Isso reforça a distinção entre:

- falha da fixture;
- falha do contrato.

O contrato estrutural já havia passado instalação/rebuild antes dessas correções.

---

# 11. Embargo de template

O embargo definido no Documento 140 pode agora ser encerrado quanto ao requisito técnico.

Portanto:

> **fica autorizada a especificação da camada de renderização/apresentação do Overview.**

Ainda não fica autorizado:

- Caso Real formal;
- publicação real;
- declaração de readiness operacional.

---

# 12. Próxima etapa

> **Definir o contrato de renderização da `OverviewOfReviewsView` antes de criar template operacional.**

O contrato de renderização deverá assegurar, no mínimo:

- distinção Review vs Report;
- visibilidade de update lineage;
- overlap sem double counting;
- CCA como métrica derivada;
- disclosure de membership completeness;
- ROBIS separado de certainty;
- currentness;
- priorização/exclusão por overlap distinta de eligibility;
- concordância/divergência;
- ausência de global Overview certainty;
- nenhuma comparação indireta informal produzida pelo renderer;
- nenhuma reanálise criada pelo renderer.

---

**Resultado final:** contrato técnico do Overview de Revisões v0.1 validado em PASS com fixture formal sintética, OV-T01–T33, rebuild e regressões completas.
