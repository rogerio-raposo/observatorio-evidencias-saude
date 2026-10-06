# 163 — OVR-01: Segunda Verificação Metodológica Adversarial Pós-Correção

**Projeto:** Observatório de Evidências em Saúde — OES  
**Produto:** Overview de Revisões  
**Caso:** OVR-01 — dCBT-I totalmente automatizada  
**Tipo de garantia avaliado:** `ai_methodological_verification`  
**Passagem:** segunda verificação adversarial, após correções exigidas pelo Documento 162  
**Data:** 6 de outubro de 2026  
**Decisão:** **PASS**  
**Assurance no momento desta decisão documental:** permanece **A0** até persistência explícita do registro de assurance  
**Elegibilidade decorrente:** **A1 interno**, condicionada à persistência controlada e validação pós-A1  
**Publicação:** proibida

---

## 1. Finalidade

Executar a segunda passagem metodológica adversarial do OVR-01 após a decisão `REVISE` do Documento 162 e verificar se:

1. os três achados obrigatórios foram corrigidos;
2. as correções não introduziram drift metodológico;
3. os limites epistemológicos do protocolo, Emenda 01 e micro-gate continuam preservados;
4. o estado corrigido permanece tecnicamente reproduzível;
5. existe base suficiente para registrar **A1 — verificação metodológica por IA**, sem qualquer alegação de revisão humana, owner approval, expert review ou publicabilidade.

Esta passagem é:

> **AI-only, não independente no sentido de peer review, não human-verified e não constitui expert review.**

---

## 2. Fontes confrontadas

Foram confrontados:

- Documento 149 — protocolo developmental;
- Documento 150 — inventário C1–C4 e discovery anti-cherry-picking;
- Documento 155 — matriz canônica C5–C6;
- Documento 156 — C7–C8 membership completeness / CCA readiness;
- Documento 157 — C9/C11/C12 comparator, provenance e certainty;
- Documento 158 — C10 ROBIS;
- Documento 159 — gate pré-persistência;
- Documento 160 — Emenda 01;
- Documento 161 — micro-gate;
- Documento 162 — primeira verificação adversarial, decisão REVISE;
- `database/f3-real-case-ovr01-dcbti.sql`;
- `database/f3-real-case-ovr01-tests.sql`;
- migrations 019–020 e `OverviewOfReviewsView`;
- run GitHub Actions **37543166213**, HEAD `49b567720dd24dd718e3c140eba659c26554efb1`.

---

## 3. Estado técnico de entrada da segunda passagem

O run **37543166213** concluiu com **success** e confirmou, no estado corrigido:

- OVR01-T01–T16 = PASS;
- render real via `OverviewOfReviewsView` = PASS;
- 3 ReviewItems analíticos;
- memberships = 27 / 15 / 44;
- 86 occurrences;
- 59 primary Study candidates únicos;
- pairwise overlap derivado = 6 / 17 / 9;
- CCA calculado apenas pelo mecanismo derivado do banco;
- `MISSING_LAST_SEARCH_DATE` preservado;
- regressões e idempotência = PASS;
- rebuild-from-zero = PASS;
- assurance = A0;
- `publishable=false`.

Artifact do run:

- id **11449428162**;
- nome `oes-s5-evidence-37543166213`;
- digest `sha256:5fed94df2b2d2c37e6280b899bbf8f8826e90ca7b2c978dfe83a14772bee2a40`.

---

## 4. Rechecagem do Achado A do Documento 162 — Search execution não sustentada

### Estado anterior

A primeira passagem identificou uma Search persistida com estratégia, timestamp, hits e screening decisions mais específicos do que o registro documental canônico sustentava.

### Estado corrigido

O SQL atual:

- não materializa `investigation.search` para o OVR-01;
- não materializa `search_hit` decorrente dessa execução inexistente;
- não materializa `screening_decision` com timestamps inventados;
- preserva discovery como decisão metodológica documental;
- registra explicitamente `search_execution_materialized=false`.

O teste OVR01-T16 exige ausência de Search e screening decision operacionais para a Investigation OVR-01.

### Decisão

> **PASS — achado material corrigido.**

Não existe mais conversão indevida de documentação metodológica em evento operacional fabricado.

---

## 5. Rechecagem do Achado B — política de cobertura contraditória

### Estado anterior

O payload continha `minimum_bibliographic_sources=2`, regra inexistente no protocolo prospectivo.

### Estado corrigido

`overview_search_coverage_policy` registra:

- `PubMed/MEDLINE`;
- `citation_chaining`;
- `known_OES_identifiers`;
- `full_text_or_supplementary_as_needed`;
- `coverage_claim=structured_non_exhaustive`;
- `formal_route_satisfied=false`;
- nenhuma propriedade `minimum_bibliographic_sources`.

Essa estrutura reproduz a política do Documento 149 e referencia o inventário do Documento 150.

### Decisão

> **PASS — política realinhada ao protocolo prospectivo.**

---

## 6. Rechecagem do Achado C — drift da Question

A `question_version.original_text` atual reproduz a pergunta protocolada:

> **Como systematic reviews recentes caracterizam o efeito da dCBT-I totalmente automatizada sobre a gravidade da insônia em adultos no pós-tratamento, considerando diferenças de comparador, overlap de estudos primários, currentness, ROBIS e certainty reportada?**

O `normalized_text` mantém:

- pós-tratamento;
- comparador;
- overlap;
- currentness;
- ROBIS;
- certainty reportada.

OVR01-T15 protege essa fidelidade contra regressão.

### Decisão

> **PASS — drift corrigido sem mudança de escopo.**

---

## 7. Discovery e regra anti-cherry-picking

O Documento 150 mantém inventário prospectivo que:

- inclui Hwang 2025;
- inclui Gao 2026;
- inclui Nazari 2025 após screening;
- registra Reviews adicionais avaliadas e mantidas fora do núcleo analítico por escopo/outcome;
- não reivindica busca sistemática formal ou exaustiva.

A remoção de Search execution fabricada:

> **não apaga a trilha documental de discovery.**

Ela apenas impede que a trilha seja representada com precisão operacional inexistente.

### Decisão

> **PASS para a rota developmental.**

A ausência de Search formal continua incompatível com a rota formal, como deve ser.

---

## 8. Currentness e Emenda 01

### Hwang

- last search = 31/03/2024;
- `possibly_outdated`.

> **PASS.**

### Gao

- `last_search_date=NULL`;
- `currentness_status='unclear'`;
- rationale explícita;
- nenhuma data inferida;
- C2 permanece **BLOCKED / NOT_VERIFIED**;
- `MISSING_LAST_SEARCH_DATE` permanece publication blocker.

> **PASS sob a Emenda 01, exclusivamente para A0/A1 developmental.**

### Nazari

- cobertura informada até janeiro de 2025;
- nenhum dia exato é inventado;
- granularidade mensal permanece disclosure.

> **PASS_WITH_DOCUMENTED_LIMITATION.**

A Emenda 01 não foi usada para enfraquecer a rota formal.

---

## 9. Membership, identidade e overlap

Estado confirmado:

- Hwang = 27 memberships;
- Gao = 15;
- Nazari = 44;
- occurrences = 86;
- unique Study candidates = 59;
- Hwang × Gao = 6;
- Hwang × Nazari = 17;
- Gao × Nazari = 9;
- `membership_completeness='complete'` permanece dimensão estrutural;
- verification status permanece `unverified`;
- nenhum verifier humano foi fabricado;
- nenhuma linha foi convertida em `human_verified`.

CCA:

- não foi persistido manualmente;
- não foi transcrito como valor documental canônico;
- permanece derivado por `overview.overlap_metrics`.

### Decisão

> **PASS.**

A distinção entre completeness estrutural e verificação humana permanece intacta.

---

## 10. Comparator, OutcomeEvidence e reanalysis

Confirmado:

- Hwang = `digital_sleep_education_or_hygiene`;
- Gao = `mixed_multiple_controls`;
- Nazari = `mixed_multiple_controls`;
- magnitudes não são tratadas como estimando idêntico;
- Hwang/Gao reutilizam Results/Syntheses externas rastreáveis;
- Nazari utiliza estimate publicado com ResultSource;
- `recalculated_by_oes=false`;
- Synthesis 503 do N2 não entra no Overview;
- nenhuma nova meta-analysis OES foi criada;
- nenhuma combinação quantitativa Hwang + Gao + Nazari foi realizada.

### Decisão

> **PASS.**

---

## 11. Certainty

Confirmado:

- Hwang = NULL;
- Gao = NULL;
- Nazari = NULL;
- GRADE da Evidence Sheet N2 não é reutilizado;
- ROBIS não é convertido em certainty;
- ausência de certainty permanece ausência.

### Decisão

> **PASS_WITH_DOCUMENTED_LIMITATION.**

A limitação é metodologicamente explícita e não foi convertida em evidência positiva.

---

## 12. ROBIS

Estado OVR-scoped:

- Hwang = unclear;
- Gao = unclear;
- Nazari = high;
- avaliações AI-assisted;
- `verification_status='unverified'`;
- nenhuma avaliação é apresentada como human-verified ou expert independent review.

### Decisão

> **PASS_WITH_DOCUMENTED_LIMITATIONS.**

Essas limitações bloqueiam claims formais mais fortes, mas não impedem A1 interno.

---

## 13. Assurance, controles humanos e rota formal

No estado avaliado antes da promoção:

- assurance = A0;
- nenhum `product.assurance_record` ativo do OVR-01;
- nenhum owner approval;
- nenhuma expert independent review;
- nenhum ReviewerAssignment humano;
- nenhum quality control humano;
- `status='under_review'`;
- `publication_date=NULL`;
- `publishable=false`;
- rota formal = NOT_READY.

O contrato formal do Overview continua exigindo A3 e controles humanos qualificados para publicação.

### Decisão

> **PASS — fronteira developmental/formal preservada.**

---

## 14. Renderização e projeção

O run 37543166213 confirmou que o estado corrigido:

- é projetado pela `OverviewOfReviewsView`;
- renderiza sem exigir Search/export artifact inexistente;
- mantém audit state não resolvido;
- mantém publication blockers;
- não recalcula CCA/pairwise no renderer;
- não cria certainty global;
- não cria reanalysis;
- não eleva assurance por renderização.

### Decisão

> **PASS.**

---

## 15. Melhor contra-argumento ao A1 após as correções

O argumento mais forte contra A1 é:

> o OVR-01 ainda possui discovery não exaustiva, Gao sem last-search date verificável, memberships sem verificação humana e ROBIS AI-only.

Esse argumento é correto quanto às limitações, porém:

1. essas limitações são declaradas prospectivamente para a rota developmental;
2. C2 permanece blocker de publicação;
3. completeness e human verification permanecem dimensões separadas;
4. A1 significa apenas **verificação metodológica por IA**;
5. A1 não satisfaz os requisitos formais A3;
6. o publication gate continua fechado;
7. nenhuma limitação é mascarada ou reinterpretada como controle humano.

Portanto:

> essas limitações impedem promoção formal/publicação, mas **não constituem blocker para A1 interno nos termos do protocolo developmental vigente**.

---

## 16. Decisão adversarial final

> **PASS**

A segunda passagem não encontrou inconsistência material remanescente que exija nova revisão antes de A1.

Os achados do Documento 162 foram corrigidos de forma verificável e os guards adicionados impedem regressão direta.

A decisão significa exclusivamente:

> **metodologicamente elegível para persistir `ai_methodological_verification=passed` e atingir A1 interno.**

Ela **não** significa:

- owner approval;
- expert review;
- human verification;
- A2;
- A3;
- readiness formal;
- autorização de publicação.

---

## 17. Ação autorizada após este PASS

Fica autorizada a próxima operação atômica:

1. persistir quality control AI-only da segunda passagem;
2. persistir `product.assurance_record` de tipo `ai_methodological_verification`, decisão `passed`;
3. manter `independent_flag=false`;
4. manter todas as memberships e ROBIS como unverified;
5. manter `under_review` e `publication_date=NULL`;
6. manter todos os publication blockers formais;
7. executar testes A1 específicos;
8. renderizar novamente via `OverviewOfReviewsView`;
9. executar regressões e rebuild-from-zero;
10. somente após PASS técnico consolidar o novo checkpoint.

---

## 18. Limites pós-A1 que continuarão obrigatórios

Mesmo após eventual persistência A1:

- não inferir last-search date de Gao;
- não calcular/persistir CCA manualmente;
- não criar nova meta-analysis;
- não colapsar comparadores;
- não marcar memberships como human-verified;
- não converter ROBIS AI-only em avaliação humana;
- não criar owner approval;
- não criar expert review fictícia;
- não promover para A2/A3;
- não publicar;
- preservar a rota formal separada da developmental.

---

**Resultado final:** **PASS metodológico na segunda passagem adversarial; OVR-01 elegível para promoção controlada a A1 interno, permanecendo não publicável e sem controles humanos.**
