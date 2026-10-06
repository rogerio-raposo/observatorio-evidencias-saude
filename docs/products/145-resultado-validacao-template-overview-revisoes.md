# 145 — Resultado da Validação do Template Operacional do Overview de Revisões

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** **PASS da camada de apresentação**  
**Dependências:** Documentos 138–144; migrations 019–020

---

# 1. Finalidade

Registrar o resultado da implementação e validação da primeira camada operacional de apresentação do Overview de Revisões.

Resultado:

> **Template Operacional do Overview = PASS.**

Este PASS é técnico e sintético.

Não equivale a:

- readiness de Caso Real;
- autorização de publicação real;
- validação clínica;
- readiness operacional final.

---

# 2. Arquivos implementados

- `templates/overview-of-reviews.md`;
- `templates/overview-of-reviews-presentation-map.json`;
- `scripts/render_overview_of_reviews_reference.py`;
- `scripts/validate_overview_of_reviews_render.py`.

O renderer reutiliza o engine neutro já validado no OES.

---

# 3. Regras preservadas

A apresentação validada:

- consome somente `OverviewOfReviewsView`;
- não consulta banco diretamente;
- não recalcula CCA;
- não recalcula pairwise overlap;
- não cria certainty;
- não cria global Overview certainty;
- não cria reanalysis;
- não cria indirect comparison;
- não cria recommendation;
- não altera assurance;
- não altera publication gate;
- não converte Report em Review;
- não confunde eligibility com overlap disposition;
- não confunde ROBIS, certainty e currentness.

---

# 4. Cenário formal sintético

O validator confirma:

- schema `oes.overview_of_reviews_view/0.1`;
- synthetic banner;
- gate aprovado;
- A3;
- 3 ReviewItems;
- 5 primary Studies únicos;
- 9 memberships;
- CCA = 0,4;
- pairwise Jaccard = 0,5 / 0,2 / 0,5;
- Review B priorizada;
- Review A com update lineage explícita;
- 3 ROBIS;
- Review C high ROBIS;
- 3 OutcomeEvidence;
- 2 certainty links;
- certainty ausente explicitamente declarada quando aplicável;
- 1 concordance assessment;
- 7 reviewer assignments;
- 4 quality controls;
- 2 Searches com exports auditáveis;
- 1 full-text exclusion;
- 6 dependency lineage edges;
- 4 referências;
- conclusion/limitations;
- ausência de tokens não resolvidos.

---

# 5. Cenários adversariais de apresentação

O validator exercita em memória:

## 5.1 A3 bloqueado

Mantém:

- A3 visível;
- `publishable=false`;
- blocker explícito;
- gate visual bloqueado.

Resultado:

> PASS.

## 5.2 Membership incompleta

Simula:

- `membership_completeness=partial`;
- CCA = null;
- `cca_calculable=false`.

Exige:

> **CCA não calculável com a membership disponível.**

O renderer não estima valor substituto.

Resultado:

> PASS.

## 5.3 Certainty ausente

Remove certainty de OutcomeEvidence que originalmente a possuía.

Exige:

> **Certainty não reportada / não disponível para este OutcomeEvidence.**

Não permite default “low certainty”.

Resultado:

> PASS.

## 5.4 Not comparable

Simula:

- `concordance.state=not_comparable`;
- rationale explícito.

O renderer não produz ranking ou superioridade.

Resultado:

> PASS.

## 5.5 Invalidated dependency

Mantém:

- A3;
- `publishable=false`;
- invalidated dependency detail;
- blocker do gate.

Resultado:

> PASS.

---

# 6. Integration S5

O workflow foi ampliado para:

1. gerar `overview-of-reviews-view.json`;
2. renderizar `overview-of-reviews-fixture.md`;
3. executar o validator positivo/adversarial;
4. preservar OVR-T01–T12;
5. executar regressões;
6. executar rebuild.

---

# 7. CI final

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

- **37506526884**
- conclusion: **success**
- commit validado: `cfda31ae84eba16b0608ea01490049ad8590ec7b`.

Artifact:

- ID **11431539311**;
- nome `oes-s5-evidence-37506526884`;
- tamanho **167936 bytes**;
- digest `sha256:4ddfff2d14f9b8892611199cdade932f7825d2615f76610518a63499c2a58770`.

O log registra:

> `F3-OVERVIEW-TEMPLATE validation PASS`

e:

> `OV-T01–T30 + OVR-T01–T10 + F3-OVERVIEW-TEMPLATE PASS — Overview contract, projection and presentation validated`

e:

> `Rebuild through migration 020 + Overview fixture + MAP-01 A1 regressions PASS`

---

# 8. Estado da camada de apresentação

Com este resultado:

> **a camada de apresentação técnica do Overview v0.1 está validada.**

A cadeia agora está completa em fixture sintética:

- especificação científica;
- decisão arquitetural;
- contrato de dados;
- publication gate;
- View;
- Projection Readiness;
- contrato de renderização;
- template;
- presentation map;
- renderer;
- validator;
- CI;
- rebuild.

---

# 9. Limite do marco

Ainda não foi demonstrado:

- disponibilidade de corpus real adequado;
- controles humanos reais;
- Review-level membership real completa;
- ROBIS real completo;
- overlap real verificável;
- OutcomeEvidence real completo;
- readiness para Caso Real formal.

Portanto:

> **não abrir Caso Real antes de um Infrastructure/Case Readiness Gate específico do Overview.**

---

# 10. Próxima etapa

> **Executar o readiness pré-caso real do Overview de Revisões, identificando requisitos reais de corpus, fontes, controles humanos, overlap/membership, ROBIS, OutcomeEvidence e assurance antes de autorizar qualquer caso real.**

---

**Resultado final:** camada de apresentação do Overview de Revisões v0.1 validada em PASS.
