# 162 — OVR-01: Primeira Verificação Metodológica Adversarial Pós-Persistência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Produto:** Overview de Revisões  
**Caso:** OVR-01 — dCBT-I totalmente automatizada  
**Tipo de garantia:** `ai_methodological_verification`  
**Passagem:** primeira verificação adversarial após persistência A0 e CP71  
**Data:** 6 de outubro de 2026  
**Decisão:** **REVISE**  
**Assurance após esta decisão:** permanece **A0**  
**Publicação:** proibida

---

## 1. Finalidade

Executar uma passagem deliberadamente adversarial sobre o OVR-01 já persistido, confrontando:

- Documento 149 — protocolo developmental;
- Documento 150 — inventário C1–C4;
- Documentos 155–158 — membership, overlap readiness, comparadores, proveniência, certainty e ROBIS;
- Documento 159 — gate pré-persistência;
- Documento 160 — Emenda 01;
- Documento 161 — micro-gate;
- `database/f3-real-case-ovr01-dcbti.sql`;
- `database/f3-real-case-ovr01-tests.sql`;
- `OverviewOfReviewsView`;
- evidência do run 37542350632.

Esta verificação:

> **é AI-only, não independente no sentido de peer review e não constitui expert review.**

Nenhum owner approval ou revisão humana é inferido.

---

## 2. Estado técnico de entrada

O run 37542350632 confirmou:

- OVR01-T01–T14 = PASS;
- 3 ReviewItems;
- memberships 27/15/44;
- 86 occurrences;
- 59 primary Study candidates únicos;
- pairwise overlap derivado = 6/17/9;
- CCA calculável exclusivamente pelo banco;
- `MISSING_LAST_SEARCH_DATE` presente;
- render via `OverviewOfReviewsView` = PASS;
- regressões/idempotência = PASS;
- rebuild-from-zero = PASS;
- assurance = A0;
- `publishable=false`.

Esses PASS técnicos são pré-condição da verificação, mas:

> **não equivalem, por si sós, a PASS metodológico.**

---

## 3. Achado material A — Search execution não sustentada pelo registro canônico

O SQL A0 persiste uma linha real em `investigation.search` com:

- fonte = PubMed/MEDLINE;
- estratégia exata;
- `executed_at = 2026-10-06 17:00:00-03`;
- estado = completed;
- três `search_hit` resolvidos;
- três `screening_decision` de inclusão.

O registro canônico pré-persistência, porém, documenta uma etapa de:

> **structured_non_exhaustive candidate-review discovery**

composta por:

1. PubMed/MEDLINE;
2. referências/citation chaining das Reviews centrais;
3. identificadores já conhecidos no OES;
4. full text/supplementary quando necessário.

O Documento 150 registra ainda que essa discovery identificou também Reviews excluídas por escopo/outcome.

Não existe, no conjunto canônico verificado, um artefato de execução que sustente simultaneamente:

- aquela estratégia exata como Search executada;
- aquele timestamp exato;
- aquele conjunto de apenas três hits como resultado da Search.

Persistir esses elementos como evento de busca executado transforma documentação metodológica preparatória em uma execução operacional mais específica do que a evidência canônica suporta.

Decisão:

> **ACHADO MATERIAL — REVISE.**

Correção exigida:

- não fabricar Search execution;
- remover do caso real as linhas de `investigation.search`, `search_hit` e `screening_decision` que não possuem trilha canônica de execução; ou substituí-las somente se existir evidência exata e rastreável da execução;
- manter a discovery como política/documentação metodológica, sem convertê-la em Search formal inexistente.

---

## 4. Achado material B — política de cobertura contraditória com o protocolo

O SQL persiste no `overview_search_coverage_policy`:

`"minimum_bibliographic_sources": 2`

O Documento 149 não exige duas bases bibliográficas para esta rota developmental.

A política prospectiva é:

- PubMed/MEDLINE;
- citation chaining;
- identificadores já conhecidos;
- full text/supplementary;
- sem alegação de exaustividade N4.

Portanto, `minimum_bibliographic_sources=2`:

- não deriva do protocolo;
- não é satisfeito pelo próprio estado persistido;
- cria uma regra retrospectiva inexistente.

Decisão:

> **ACHADO MATERIAL — REVISE.**

Correção exigida:

- alinhar o payload da policy literalmente ao Documento 149;
- representar `structured_non_exhaustive`;
- registrar as quatro vias documentadas de discovery;
- não inventar mínimo de duas bases.

---

## 5. Achado de alinhamento — Question persistida não reproduz integralmente a pergunta protocolada

Documento 149 define a pergunta review-level:

> **Como systematic reviews recentes caracterizam o efeito da dCBT-I totalmente automatizada sobre a gravidade da insônia em adultos no pós-tratamento, considerando diferenças de comparador, overlap de estudos primários, currentness, ROBIS e certainty reportada?**

A `question_version.original_text` persistida foi simplificada para:

> O que mostram revisões sistemáticas elegíveis sobre dCBT-I totalmente automatizada para gravidade da insônia em adultos?

O `normalized_text` recupera parte da estrutura, mas ainda não reproduz integralmente:

- pós-tratamento;
- certainty reportada.

A pergunta não muda o corpus material, mas a persistência deve permanecer fiel ao protocolo prospectivo.

Decisão:

> **REVISE de alinhamento sem mudança de escopo.**

Correção exigida:

- usar a pergunta do Documento 149 como `original_text`;
- normalizar sem remover post-treatment, comparator, overlap, currentness, ROBIS ou certainty reportada.

---

## 6. Currentness

### Hwang

- last search = 31/03/2024;
- `possibly_outdated`.

> **PASS.**

### Gao

- `last_search_date=NULL`;
- `currentness_status='unclear'`;
- rationale explícita;
- nenhuma data inferida;
- blocker preservado.

> **PASS sob Emenda 01.**

### Nazari

A fonte documental informa:

> inception até janeiro de 2025.

O SQL não inventa um dia e mantém `last_search_date=NULL`.

Essa escolha é conservadora e mantém publication blocker.

Não há justificativa para inventar `2025-01-01`, `2025-01-31` ou outro dia.

> **PASS_WITH_DOCUMENTED_LIMITATION.**

A granularidade mês-versus-DATE deve permanecer visível; não é motivo para fabricar precisão.

---

## 7. Membership, identity e overlap

Confirmado:

- Hwang 27;
- Gao 15;
- Nazari 44;
- 86 occurrences;
- 59 Study candidates únicos;
- H×G = 6;
- H×N = 17;
- G×N = 9;
- memberships permanecem `unverified`;
- nenhuma linha foi promovida a human verification;
- `membership_completeness='complete'` permanece separada de verification status;
- CCA é derivado pelo banco.

Nenhum valor manual de CCA foi persistido.

> **PASS.**

---

## 8. Comparator e OutcomeEvidence

Confirmado:

- Hwang = `digital_sleep_education_or_hygiene`;
- Gao = `mixed_multiple_controls`;
- Nazari = `mixed_multiple_controls`;
- Hwang/Gao reutilizam Results/Syntheses externas rastreáveis;
- Nazari usa estimate publicado e rastreável;
- `recalculated_by_oes=false`;
- nenhuma Synthesis 503 entra no Overview;
- nenhuma nova meta-analysis OES foi criada;
- concordance de magnitude = `not_comparable`.

> **PASS.**

---

## 9. Certainty

Confirmado:

- Hwang certainty = NULL no Overview;
- Gao certainty = NULL;
- Nazari certainty = NULL;
- CertaintyAssessment N2 não foi reutilizada;
- ROBIS não foi convertido em certainty.

> **PASS.**

---

## 10. ROBIS

Estado OVR-scoped:

- Hwang = unclear;
- Gao = unclear;
- Nazari = high;
- todos AI-assisted;
- todos `verification_status='unverified'`;
- nenhum registro foi apresentado como avaliação humana independente.

> **PASS_WITH_DOCUMENTED_LIMITATIONS.**

---

## 11. Assurance e publication state

Confirmado:

- assurance = A0;
- nenhum `product.assurance_record` ativo;
- nenhum owner approval;
- nenhuma expert independent review;
- nenhum reviewer humano criado;
- `publication_date=NULL`;
- `publishable=false`;
- rota formal permanece NOT_READY.

> **PASS.**

---

## 12. Melhor contra-argumento ao avanço para A1

O melhor argumento contra A1 neste estado é:

> o produto tecnicamente passa todos os testes, mas a trilha persistida de Search contém uma execução específica não suportada pelo registro canônico e uma regra de cobertura que contradiz o protocolo prospectivo. Promover A1 sem corrigir isso premiaria coerência de schema em detrimento de coerência metodológica.

Esse argumento é procedente.

---

## 13. Decisão

> **REVISE**

Motivo:

há inconsistência material, porém corrigível, entre:

- protocolo/discovery documental;
- política de cobertura persistida;
- Search execution persistida.

Há também drift textual da Question.

Não há motivo para classificar como failed porque:

- corpus analítico permanece o mesmo;
- memberships/overlap estão coerentes;
- comparadores estão preservados;
- ROBIS/certainty estão semanticamente corretos;
- Gao permanece sem data inferida;
- nenhuma meta-analysis nova foi criada;
- assurance/publication continuam bloqueadas.

---

## 14. Correções obrigatórias antes da segunda passagem

1. remover Search/search hits/screening decisions sem evidência operacional canônica;
2. alinhar `overview_search_coverage_policy` ao Documento 149;
3. alinhar a Question persistida à pergunta protocolada;
4. adicionar testes que impeçam regressão dessas três condições;
5. rerodar OVR01, regressões, render e rebuild-from-zero;
6. repetir a verificação metodológica adversarial;
7. não criar assurance A1 antes de eventual decisão `passed`.

---

## 15. Assurance

Como a decisão é `REVISE`:

> **não criar `product.assurance_record` de A1.**

O OVR-01 permanece:

- A0;
- `under_review`;
- não publicável.

---

**Resultado final:** **REVISE — correções de fidelidade metodológica são obrigatórias antes de qualquer A1.**
