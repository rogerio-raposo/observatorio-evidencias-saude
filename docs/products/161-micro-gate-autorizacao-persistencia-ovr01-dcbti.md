# 161 — Micro-Gate de Autorização de Persistência — OVR-01 dCBT-I

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Overview de Revisões  
**Caso:** OVR-01 — dCBT-I totalmente automatizada  
**Data:** 6 de outubro de 2026  
**Status:** micro-gate pós-Emenda 01  
**Dependências:** Documentos 149–160; migration 019; CP69

---

## 1. Pergunta do gate

> **Após a Emenda 01, existe base metodológica e arquitetural suficiente para autorizar a primeira persistência real do OVR-01 como produto developmental A0, sem publicação?**

---

## 2. Freshness e ordem prospectiva

A sequência documental foi respeitada:

1. Documento 159 bloqueou a persistência até emenda formal;
2. Documento 160 foi criado antes de qualquer entidade real OVR-01;
3. Documento 149 passou a referenciar a Emenda 01;
4. nenhuma Question/Investigation/Product/ReviewItem/membership real do OVR-01 foi criada antes desta decisão.

Resultado:

> **PASS.**

---

## 3. Compatibilidade com migration 019

Verificação direta do contrato SQL:

- `last_search_date` é nullable;
- `currentness_status` aceita `unclear`;
- rationale é obrigatória quando currentness não é `current`;
- active ReviewItem sem `last_search_date` gera `MISSING_LAST_SEARCH_DATE` com severity `error`.

Portanto, a representação exigida pela Emenda 01 é suportada sem migration corretiva.

Resultado:

> **PASS.**

---

## 4. C2 após a Emenda 01

O estado científico permanece:

> **C2 = BLOCKED / NOT_VERIFIED.**

Para Gao, a persistência deverá usar:

```text
last_search_date = NULL
currentness_status = unclear
currentness_rationale = data exata da última busca não verificável; nenhuma data inferida
```

A Emenda 01 remove apenas o blocker de persistência developmental.

Resultado:

> **PASS_FOR_DEVELOPMENTAL_PERSISTENCE_WITH_UNRESOLVED_CURRENTNESS.**

Esse rótulo não substitui nem reclassifica C2.

---

## 5. Publication gate

A persistência deverá produzir/manter:

> **MISSING_LAST_SEARCH_DATE — error**

enquanto Gao estiver sem `last_search_date`.

Consequências obrigatórias:

- `publishable=false`;
- `publication_date=NULL`;
- nenhuma publicação;
- nenhuma promoção automática de assurance;
- rota formal continua NOT_READY.

Resultado:

> **PASS — blocker preservado.**

---

## 6. Demais condições C1–C12

Estado consolidado:

| Condição | Estado |
|---|---|
| C1 — Gao study list | PASS |
| C2 — Gao last-search date | BLOCKED / NOT_VERIFIED |
| C3 — Nazari eligibility | PASS |
| C4 — review inventory | PASS |
| C5 — Study identity reconciliation | PASS_WITH_DOCUMENTED_UNCERTAINTY |
| C6 — membership matrix | PASS |
| C7 — membership completeness | PASS |
| C8 — CCA readiness | READY_WITH_DOCUMENTED_CONDITIONS |
| C9 — comparator handling | PASS |
| C10 — ROBIS | PASS_WITH_DOCUMENTED_LIMITATIONS |
| C11 — provenance/materialization | PASS_WITH_PREPARED_NAZARI_MATERIALIZATION |
| C12 — certainty handling | PASS_WITH_DOCUMENTED_LIMITATION |

Nenhuma condição adicional exige inferência ou falsificação de verificação humana.

Resultado:

> **PASS_WITH_DOCUMENTED_CONDITIONS.**

---

## 7. Escopo autorizado para a primeira persistência

Fica autorizada, em ordem controlada, a criação do OVR-01 developmental A0 com:

1. Question própria do Overview;
2. Investigation própria;
3. Product/ProductVersion `overview_of_reviews`;
4. materialização rastreável de Nazari como Review Study/StudyVersion e Reports/Results/Sources necessários;
5. ReviewItems analíticos para Hwang, Gao e Nazari;
6. memberships Review × primary Study a partir da matriz canônica preparatória;
7. identidade/membership explicitamente AI-assisted/unverified quando aplicável;
8. comparadores preservados de acordo com C9;
9. ROBIS conforme C10;
10. certainty NULL quando não reportada;
11. overlap strategy `include_all_separate_estimates`;
12. overlap/CCA exclusivamente derivados pelo banco;
13. `publishable=false`;
14. assurance inicial A0;
15. publication issues preservadas.

---

## 8. O que não está autorizado

Este micro-gate não autoriza:

- inferir a data de busca de Gao;
- preencher `last_search_date` aproximada;
- calcular CCA manualmente;
- criar nova meta-analysis;
- colapsar estimates de comparadores diferentes;
- marcar identity como human_verified;
- criar owner approval;
- criar expert review;
- promover para A2/A3;
- publicar;
- alterar a rota formal;
- reutilizar GRADE da Evidence Sheet N2 como certainty do Overview.

---

## 9. Controles pós-persistência obrigatórios

Após a primeira persistência, antes de qualquer A1, deverão ocorrer:

1. rebuild completo through migration 020;
2. regressões existentes;
3. testes específicos do OVR-01 real;
4. validação de 3 ReviewItems analíticos;
5. validação das memberships contra a matriz preparatória;
6. validação das contagens de controle:
   - 86 occurrences;
   - 59 Study candidates;
7. cálculo do CCA somente pelo mecanismo derivado do banco;
8. verificação de `MISSING_LAST_SEARCH_DATE` para Gao;
9. renderização read-only via `OverviewOfReviewsView`;
10. verificação metodológica adversarial por IA antes de eventual A1.

---

## 10. Decisão do micro-gate

> **READY_TO_PERSIST_DEVELOPMENTAL_A0.**

A autorização é estreita:

> **persistir o OVR-01 como caso real developmental interno A0, mantendo explicitamente C2 não resolvido e o publication blocker ativo.**

---

## 11. Próxima etapa

> **Implementar a persistência real controlada do OVR-01 dCBT-I em A0, executar testes/rebuild/render, confirmar overlap derivado e publication issues, sem promover assurance antes da verificação metodológica adversarial.**

---

**Resultado final:** a Emenda 01 é arquiteturalmente compatível e metodologicamente suficiente para remover o blocker de persistência developmental, sem transformar ausência de informação em evidência positiva e sem autorizar publicação.
