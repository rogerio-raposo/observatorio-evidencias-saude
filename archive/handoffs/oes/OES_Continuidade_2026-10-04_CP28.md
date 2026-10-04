# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP28  
**Checkpoint anterior:** CP27  
**Status:** artefato de continuidade; não normativo  
**Escopo:** owner approval concluída; Caso Real 01 publicado em A2; fechamento da trilha inicial da Ficha de Evidência N2  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP28

> **Caso Real 01: A2 — owner_governance_approved**  
> **Product status: published**  
> **Publication date: 2026-10-04**  
> **Publication gate: PASS / publishable=true**  
> **Expert independent review: NÃO REALIZADA — disclosure obrigatório**

Base técnica validada:

`main @ 9c0257172ad916a13cbb66648bb68621c8b21b1f`

## 2. Decisões e evidências consolidadas desde CP27

### Documento 66

O proprietário registrou decisão explícita **APPROVED**. A aprovação é de governança e não equivale a validação metodológica especializada.

### Transição A1 → A2

- AI methodological verification ativa = `passed`;
- owner governance approval ativa = `approved`;
- expert independent review = não realizada;
- assurance derivado = **A2**;
- `publication_date = 2026-10-04`;
- estado editorial = `published`;
- `publishable=true`;
- warning `NO_EXPERT_INDEPENDENT_REVIEW` preservado.

### Documento 67

`docs/products/67-caso-real-01-resultado-validacao-a2-publicacao.md`

Resultado: **PASS**.

## 3. Evidência técnica final

- GitHub Actions run **37229070210**;
- conclusão **success**;
- commit validado `9c0257172ad916a13cbb66648bb68621c8b21b1f`;
- artifact **11313491459**;
- digest `sha256:81529675c16d85fe28991f7abe3b9594bdc1e99cbcbc3226cb8e3dc0f3b3c1a6`.

PASS confirmado para regressões F2-B e S4, S5 runtime, F3 Evidence Sheet contract, provenance, template, RC01-T01–T10, AG-T01–T07, AV-T01–T02, idempotência e rebuild from zero through migration 011.

Dois runs intermediários falharam por expectativas de teste ainda vinculadas ao estado A1/pré-publicação. As falhas foram preservadas e corrigidas sem relaxamento do publication gate.

## 4. Estado da Ficha de Evidência

A trilha inicial da Ficha de Evidência está consolidada em especificação científica e funcional, contrato de dados, EvidenceSheetView, template operacional, provenance-aware references, contagens por tipo de estudo, governança A0–A3, caso real N2 ponta a ponta, verificação metodológica adversarial, owner approval, publicação A2 validada e rebuild reproduzível.

A2 continua distinto de A3. A ausência de expert review deve permanecer visível.

## 5. Itens que não são reabertos sem motivo

Não reabrir automaticamente:

- baseline arquitetural OES-P1;
- Ficha como unidade persistente central preferencial;
- separação Evidence / Recommendation;
- modelo A0–A3;
- distinção entre owner approval e expert review;
- decisão de não recalcular a meta-análise externa no Caso Real 01;
- conclusão científica e limitações do Caso Real 01 já validadas;
- publicação A2 do Caso Real 01.

Mudanças futuras materiais deverão seguir governança, rastreabilidade e versionamento.

## 6. Reservas ainda abertas no projeto

- ApplicabilityAssessment operacional;
- protocolo de atualização/monitoramento;
- demais produtos da taxonomia;
- automação e IA em escala;
- infraestrutura de produção;
- autenticação/autorização;
- backup/HA.

## 7. Ponto exato de retomada

Conforme a ordem recomendada pelo Documento 40:

> **Fase 3 — iniciar a especificação científica e funcional da Resposta de Evidência (N1).**

Não iniciar por template ou implementação.

Primeiro:

1. recuperar do Documento 40 a função e fronteiras da Resposta de Evidência;
2. compará-la com Ficha de Evidência N2 e Evidence Scan N0 para evitar sobreposição;
3. definir contrato científico/funcional e critérios mínimos de publicação;
4. somente depois avaliar contrato de dados, view e template próprios ou reutilização de estruturas comuns.

**Fim do CP28**
