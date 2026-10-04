# 67 — Caso Real 01: Resultado da Validação A2 e Publicação

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Produto:** `OES-P-2026-000401`  
**Data:** 4 de outubro de 2026  
**Resultado:** **PASS**  
**Assurance final desta etapa:** **A2 — owner_governance_approved**  
**Estado editorial:** **published**  
**Expert independent review:** **não realizada**

## 1. Finalidade

Este documento registra o fechamento técnico e documental da transição do Caso Real 01 de A1 para A2 após decisão explícita **APPROVED** do proprietário no Documento 66.

A aprovação do proprietário é uma aprovação de governança. Ela não constitui validação técnica especializada de ROBIS, RoB 2, GRADE ou meta-análise.

## 2. Decisão do proprietário

Documento canônico: `docs/products/66-caso-real-01-aprovacao-governanca-proprietario.md`.

Decisão: **APPROVED**.

Consequência autorizada: registrar `owner_governance_approval = approved`, avançar de A1 para A2, atribuir `publication_date`, fechar o estado editorial como `published`, reexecutar o publication gate e manter explícita a ausência de revisão especializada independente.

## 3. Estado materializado

- `ai_methodological_verification = passed`;
- `owner_governance_approval = approved`;
- expert independent review: ausente;
- `publication_date = 2026-10-04`;
- `status = published`;
- assurance derivado = **A2**;
- `publishable = true`.

A ausência de expert review permanece representada por `NO_EXPERT_INDEPENDENT_REVIEW` como **warning**, e não como erro bloqueante para publicação N2 padrão sob A2.

## 4. Histórico da validação

A transição foi validada iterativamente, preservando as falhas intermediárias para auditoria.

- Run **37228886260**: FAIL porque uma asserção de renderização ainda exigia a marca histórica `PREVIEW — NÃO PUBLICÁVEL`. Os testes de assurance já demonstravam A2.
- Run **37228948598**: FAIL após o RC01 e a renderização A2 passarem; o rebuild `RC01-T10` ainda esperava A1 e `publishable=false`.
- Run **37229070210**: **PASS** após reconciliação das expectativas antigas de pré-publicação com o estado A2, sem remoção ou relaxamento de controles metodológicos.

## 5. Evidência final de execução

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37229070210**;
- conclusão: **success**;
- commit validado: `9c0257172ad916a13cbb66648bb68621c8b21b1f`;
- artifact: **11313491459**;
- digest: `sha256:81529675c16d85fe28991f7abe3b9594bdc1e99cbcbc3226cb8e3dc0f3b3c1a6`.

Validações materiais:

- regressão F2-B: PASS;
- regressão S4: PASS;
- S5 runtime: PASS;
- F3 Evidence Sheet contract: PASS;
- provenance-aware references: PASS;
- F3-TEMPLATE: PASS;
- RC01-T01–T10: PASS;
- AG-T01–T07: PASS;
- AV-T01–T02: PASS;
- idempotência: PASS;
- rebuild from zero through migration 011: PASS;
- RC01-T10: PASS em A2, publicável e com warning explícito de ausência de expert review.

## 6. Interpretação

O Caso Real 01 demonstrou que uma Ficha de Evidência N2 pode percorrer de ponta a ponta:

`pergunta → busca → seleção → appraisal → extração/síntese → certainty → draft → verificação metodológica adversarial por IA → owner governance approval → publication gate → publicação A2`

sem fabricar revisão especializada, apresentar owner approval como expert review, apagar incerteza, suprimir limitações, transformar evidência em recomendação clínica individual ou perder provenance/lineage na reconstrução.

## 7. Estado científico e de garantia

A conclusão científica permanece:

> **A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos.**

Permanece obrigatório declarar a verificação metodológica assistida por IA, a aprovação de governança pelo proprietário, a ausência de revisão especializada independente, as limitações e incertezas documentadas e a ausência de recomendação clínica individual automática.

A2 não deve ser apresentado como A3.

## 8. Decisão de fechamento

> **PASS — Caso Real 01 publicado no estado A2 dentro do modelo de governança do OES.**

A trilha inicial de especificação, implementação e validação ponta a ponta da **Ficha de Evidência N2** está suficientemente consolidada para permitir o avanço da Fase 3 ao próximo produto da ordem definida no Documento 40.

## 9. Próxima etapa

Conforme a ordem recomendada do Documento 40:

> **formalizar individualmente a Resposta de Evidência — N1.**

A especificação deverá preceder qualquer template próprio ou automação específica desse produto.

**Status final deste documento:** PASS.
