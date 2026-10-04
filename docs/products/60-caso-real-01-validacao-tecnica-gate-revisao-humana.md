# 60 — Caso Real 01: Validação Técnica do Gate de Revisão Humana

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Status:** PASS histórico do gate inicial; sem expert review real. A semântica de publicação N2 foi posteriormente substituída pelo modelo de garantia do Documento 04.  
**Data:** 4 de outubro de 2026  
**GitHub Actions run:** 37213717492  
**Commit testado:** `876f7b1deac0909e8475c1fb6f15902edf83bb0b`

---

# 1. Finalidade

Validar a semântica operacional do **Gate de Revisão Humana** antes de qualquer decisão real de um revisor.

O teste deveria demonstrar que:

- `revise` não satisfaz a exigência de aprovação;
- `rejected` bloqueia explicitamente a publicação;
- uma aprovação concorrente não anula uma rejeição ativa;
- `approved` sem `publication_date` ainda não torna a Ficha publicável;
- somente a combinação de condições obrigatórias permite `publishable=true`;
- nenhum registro sintético de revisão persiste após o teste.

---

# 2. Regra de segurança

O arquivo:

`database/f3-human-review-gate-tests.sql`

utiliza exclusivamente revisores identificados como:

`TEST_ONLY_SYNTHETIC_REVIEWER`

e executa todas as inserções dentro de:

`BEGIN ... ROLLBACK`

Portanto:

> **nenhuma aprovação humana foi criada ou persistida pelo teste.**

Após o teste, o Caso Real 01 continua:

- `under_review`;
- sem `review_record approved` real;
- sem `publication_date`;
- `publishable=false`.

---

# 3. Testes executados

## HRG-T01 — baseline bloqueado

Condição inicial:

- sem revisão aprovada;
- sem data de publicação.

Esperado:

- `MISSING_APPROVED_REVIEW`;
- `MISSING_PUBLICATION_DATE`;
- `publishable=false`.

Resultado:

> **PASS**

## HRG-T02 — decisão REVISE

Foi inserida, apenas dentro da transação de teste, decisão:

`revise`

Esperado:

- continua `MISSING_APPROVED_REVIEW`;
- não surge `ACTIVE_REJECTION`;
- produto continua não publicável.

Resultado:

> **PASS**

## HRG-T03 — decisão REJECTED

Foi inserida decisão sintética:

`rejected`

Esperado:

- `ACTIVE_REJECTION`;
- continua sem aprovação válida;
- publicação bloqueada.

Resultado:

> **PASS**

## HRG-T04 — APPROVED concorrente com REJECTED ativo

Foi inserida aprovação sintética enquanto a rejeição permanecia ativa.

Esperado:

- aprovação é reconhecida;
- rejeição ativa continua bloqueando;
- `publishable=false`.

Resultado:

> **PASS**

## HRG-T05 — APPROVED sem publication_date

A rejeição sintética foi superseded, mantendo a aprovação sintética ativa.

Esperado:

- desaparecem issues de revisão;
- permanece `MISSING_PUBLICATION_DATE`;
- `publishable=false`.

Resultado:

> **PASS**

## HRG-T06 — condições finais completas

Somente para testar a função do gate, foi atribuída uma `publication_date` sintética dentro da transação.

Esperado:

- zero erros bloqueantes;
- `publishable=true`.

Resultado:

> **PASS**

Em seguida:

> **ROLLBACK**

restaurou integralmente o estado real.

---

# 4. Resultado consolidado

> **HRG-T01–T06 = PASS**

A semântica validada é:

`REVISE → bloqueia por falta de aprovação`

`REJECTED → bloqueia explicitamente`

`APPROVED + REJECTED ativo → continua bloqueado`

`APPROVED sem publication_date → continua bloqueado`

`APPROVED + rejeições resolvidas + demais requisitos + publication_date → gate pode liberar`

---

# 5. Integração ao pipeline

O teste foi incorporado ao workflow:

`.github/workflows/validate-s5.yml`

na etapa específica do Caso Real 01.

Ordem relevante:

1. carregar RC01;
2. executar RC01-T01–T09;
3. executar HRG-T01–T06;
4. fazer ROLLBACK dos registros sintéticos;
5. exportar EvidenceSheetView real;
6. renderizar preview;
7. confirmar que continua **PREVIEW — NÃO PUBLICÁVEL**;
8. executar regressões e rebuild.

Essa ordem testa também ausência de vazamento de uma aprovação sintética para o produto real.

---

# 6. Evidência de execução

GitHub Actions:

- run: **37213717492**;
- conclusão: **success**;
- commit: `876f7b1deac0909e8475c1fb6f15902edf83bb0b`.

Artifact:

- ID: **11306934256**;
- nome: `oes-s5-evidence-37213717492`;
- tamanho: 25497 bytes;
- digest: `sha256:81578896ae97f582bd3029c4f276303e0208067b0cdcf053b0bb46f764b3a51f`;
- retenção informada: 30 dias.

No mesmo run:

- F2-B: PASS;
- S4: PASS;
- S5-T01–T17: PASS;
- F3-FE-T01–T17: PASS;
- F3-VIEW-T01–T17: PASS;
- F3-PROV-T01–T06: PASS;
- F3-TEMPLATE: PASS;
- RC01-T01–T10: PASS;
- HRG-T01–T06: PASS;
- rebuild through migration 009: PASS.

---

# 7. Implicação arquitetural — atualização de governança

Este documento validou corretamente a **mecânica do gate inicial baseado em `product.review_record`**.

Posteriormente, identificou-se que o único humano do projeto não possui qualificação metodológica para funcionar como revisor especializado. Por isso, o Documento 04 substituiu a premissa operacional do gate N2 por:

- AI methodological verification;
- owner governance approval;
- expert independent review opcional/condicional.

Os testes HRG-T01–T06 permanecem evidência histórica válida da semântica do gate inicial, mas não definem mais sozinhos o gate vigente.

Campos atuais suportam:

- reviewer;
- role;
- independent_flag;
- decision;
- reviewed_at;
- notes;
- status.

Decisões:

- `approved`;
- `revise`;
- `rejected`.

Nenhuma migration adicional é necessária para executar a primeira revisão humana real.

---

# 8. Limite da validação

Este PASS valida:

> **a mecânica do gate**

e não:

> **o julgamento humano do conteúdo científico.**

Continuam pendentes:

- confirmação humana do ROBIS;
- confirmação humana dos RoB 2;
- confirmação humana da estratégia de síntese;
- confirmação humana do GRADE;
- confirmação humana da conclusão;
- confirmação humana de limitações, segurança e aplicabilidade.

---

# 9. Próxima etapa

O pacote está preparado em:

`docs/products/59-caso-real-01-pacote-revisao-humana.md`

A próxima transição do Caso Real 01 exige:

> **revisão humana real e identificável.**

Somente após essa revisão deverá ser criado um `product.review_record` persistente.

---

**Resultado final:** Gate de Revisão Humana tecnicamente validado; nenhuma aprovação humana real registrada.
