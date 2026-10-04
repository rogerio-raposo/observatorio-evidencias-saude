# 58 — Resultado da Validação Ponta a Ponta do Caso Real 01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Status:** PASS técnico/científico de pré-publicação  
**Data:** 4 de outubro de 2026  
**GitHub Actions run:** 37213165321  
**Commit testado:** `d9a2de71c9efed0722f9bf9698a42a374e8cd981`

---

# 1. Resultado

O primeiro caso real da Ficha de Evidência percorreu com sucesso a cadeia OES até o estado de **preview científico sob revisão**.

> **CASO REAL 01 = PASS PARA PRÉ-PUBLICAÇÃO / UNDER REVIEW**

O resultado não significa publicação científica final.

A Ficha permanece deliberadamente:

- `under_review`;
- `publishable=false`;
- sem `review_record approved`;
- sem `publication_date`.

Isso é o comportamento esperado.

---

# 2. Cadeia executada

A validação percorreu:

`Question`
→ `Investigation N2`
→ `Search`
→ `Screening`
→ `Study/Report`
→ `Result`
→ `ROBIS/RoB 2`
→ `Synthesis externa adotada`
→ `Synthesis de atualização OES`
→ `GRADE provisório`
→ `ProductVersion under_review`
→ `Publication Gate`
→ `EvidenceSheetView`
→ `Preview Markdown`

O rebuild executou a mesma cadeia a partir do zero.

---

# 3. Pergunta validada

> Em adultos com insônia, dCBT-I multicomponente totalmente automatizada, comparada à educação digital sobre sono ou higiene do sono, reduz a gravidade da insônia no primeiro pós-tratamento completo?

Nível:

- N2.

Manutenção:

- M1.

Cutoff:

- 4 de outubro de 2026.

---

# 4. Evidência científica modelada

A implementação canônica materializa:

- Hwang et al. 2025 — revisão sistemática/meta-análise;
- Gao et al. 2026 — revisão sistemática/meta-análise corroborativa;
- Sweetman et al. 2024 — RCT;
- SleepioRx / CrEDIT 2025 — RCT;
- SHUTi OASIS 2025 — RCT;
- Somzz 2024 — RCT.

Os estudos e Reports permanecem entidades distintas.

A Ficha não interpreta o número de Studies diretamente modelados como número total de RCTs subjacentes às meta-análises externas.

---

# 5. Sínteses

## 5.1 Source

Meta-análise externa adotada:

- origem: `adopted_external`;
- efeito publicado preservado;
- `recalculated_by_oes=false`;
- k reportado pela fonte preservado separadamente.

## 5.2 Primary

Atualização OES:

- origem: `oes_update`;
- narrativa;
- RCTs recentes usados para atualização/triangulação;
- `pooled_by_oes=false`.

## 5.3 Corroborative

Gao 2026 permanece evidência corroborativa, sem substituir o comparador focal da síntese-base.

Os três papéis permanecem distinguíveis no produto:

- `source`;
- `primary`;
- `corroborative`.

---

# 6. Resultado científico do caso

Síntese draft:

> **A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos; a estimativa quantitativa-base não foi recalculada pelo OES.**

Estimativa externa focal preservada:

- SMD = -0,93;
- IC95% -1,07 a -0,79;
- k=10;
- I²=68%.

Essa estimativa não é apresentada como cálculo do OES.

---

# 7. Certainty

GRADE provisório:

> **moderada**

Estrutura:

- inicial: alta;
- risk of bias: downgrade 1;
- inconsistency: 0;
- indirectness: 0;
- imprecision: 0;
- publication bias: 0.

O julgamento permanece:

> **pendente de revisão humana material.**

A validação não criou aprovação humana artificial.

---

# 8. Risk of Bias / appraisal

A implementação representa:

- ROBIS da síntese-base;
- RoB 2 dos RCTs decisivos.

Os appraisals permanecem explicitamente com estado de verificação humana pendente quando aplicável.

---

# 9. Publication Gate

O gate bloqueou a Ficha exatamente como esperado.

Issues obrigatórias confirmadas:

- `MISSING_APPROVED_REVIEW`;
- ausência de data de publicação no estado under_review.

Resultado:

> `publishable=false`

O preview Markdown apresenta:

> **PREVIEW — NÃO PUBLICÁVEL**

Portanto, o gate não foi contornado para obter um resultado visual.

---

# 10. EvidenceSheetView

O caso real confirmou que a projeção consegue representar:

- Syntheses com papéis distintos;
- meta-análise adotada sem repooling;
- certainty provisória;
- RiskAssessment;
- referências provenance-aware;
- buscas com hit count desconhecido;
- unidades de evidência diretamente modeladas;
- histórico e audit trail;
- bloqueios de publicação.

---

# 11. Busca com contagem bruta indisponível

Quando a interface não forneceu um hit count bruto confiável:

- `result_count` permaneceu NULL;
- os registros materialmente capturados foram registrados separadamente.

O teste confirmou:

> o sistema não inventa contagem de busca.

Essa é uma propriedade importante para auditabilidade.

---

# 12. Testes RC01

## RC01-T01

Meta-análise externa permanece explicitamente adotada e não recalculada.

> PASS

## RC01-T02

Atualização dos RCTs permanece narrativa e sem pooling estatístico OES.

> PASS

## RC01-T03

Studies diretamente modelados permanecem distintos de k=10 reportado pela meta-análise-fonte.

> PASS

## RC01-T04

GRADE provisório moderado está vinculado à síntese OES atualizada.

> PASS

## RC01-T05

Publicação bloqueada por revisão humana e estado não publicado.

> PASS

## RC01-T06

Syntheses `source`, `primary` e `corroborative` permanecem separadas e ordenadas.

> PASS

## RC01-T07

ROBIS/RoB 2 estão representados e seu estado de revisão está explícito.

> PASS

## RC01-T08

Lineage RCT Report → Result → update → certainty/Product é reconstruível.

> PASS

## RC01-T09

Hit counts indisponíveis permanecem NULL; registros capturados são explícitos.

> PASS

## RC01-T10

Rebuild do zero gera novamente o preview real não publicável.

> PASS

---

# 13. Regressões

No mesmo run:

- F2-B: PASS;
- S4: PASS;
- S5: PASS;
- F3-FE: PASS;
- F3-VIEW: PASS;
- F3-PROV: PASS;
- F3-TEMPLATE: PASS;
- migrations 008/009 idempotentes: PASS;
- rebuild through migration 009: PASS.

---

# 14. Artifact

- ID: **11307386757**
- nome: `oes-s5-evidence-37213165321`
- digest: `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`
- tamanho: 24972 bytes
- expiração informada: 3 de novembro de 2026.

O artifact inclui evidência de execução e o preview produzido durante o workflow.

---

# 15. O que este PASS significa

O Caso Real 01 demonstrou que a Ficha consegue, no estado atual:

1. receber uma pergunta real;
2. registrar busca N2 sem inventar completude;
3. distinguir revisão sistemática e estudos primários;
4. adotar uma estimativa externa sem atribuí-la ao OES;
5. incorporar atualização narrativa;
6. representar appraisal;
7. representar certainty provisória;
8. preservar provenance/lineage;
9. gerar produto under_review;
10. bloquear publicação corretamente;
11. produzir preview legível;
12. reconstruir o estado do zero.

---

# 16. O que este PASS não significa

Não significa:

- revisão humana concluída;
- publicação autorizada;
- certeza formalmente aprovada;
- recomendação clínica;
- validação de todos os tipos de Ficha;
- exaustividade N4;
- maturidade final de todos os produtos OES.

---

# 17. Defeito arquitetural crítico

Após o run final:

> **nenhum defeito arquitetural crítico novo foi identificado para este caso.**

As mudanças exigidas pelo caso real foram hardening compatível da projeção:

- referências provenance-aware;
- contagens por study_type;
- semântica explícita de síntese externa/adotada.

---

# 18. Próxima etapa

A próxima etapa não é transformar a Ficha em `published` automaticamente.

É necessário abrir:

> **Gate de Revisão Humana do Caso Real 01**

Esse gate deverá revisar materialmente:

1. ROBIS;
2. julgamentos RoB 2;
3. GRADE;
4. interpretação da heterogeneidade;
5. conclusão;
6. aplicabilidade;
7. linguagem de segurança;
8. clareza do preview.

Somente uma revisão humana real poderá gerar `review_record approved`.

Até lá:

> **Caso Real 01 permanece under_review / não publicável.**

---

**Resultado final:** PASS ponta a ponta no estado de pré-publicação.
