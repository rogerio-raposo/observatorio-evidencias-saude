# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP25  
**Checkpoint anterior:** CP24  
**Status:** artefato de continuidade; não normativo  
**Escopo:** pacote humano pronto + Gate de Revisão Humana tecnicamente validado  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP25

> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Caso Real 01 — PASS ponta a ponta em pré-publicação**  
> **Pacote de Revisão Humana — PRONTO**  
> **Gate de Revisão Humana — HRG-T01–T06 PASS**  
> **Ficha — under_review / publishable=false**  
> **Próxima dependência: REVISÃO HUMANA REAL**

Base do repositório no fechamento operacional:

`main @ a65098414fc5a15a6ea3fcf282faa37281b19685`

---

# 2. Documentos canônicos do marco

- Documento 58 — Resultado da Validação Ponta a Ponta do Caso Real 01;
- Documento 59 — Pacote de Revisão Humana do Caso Real 01;
- Documento 60 — Validação Técnica do Gate de Revisão Humana.

Arquivos:

- `docs/products/58-resultado-validacao-ponta-a-ponta-caso-real-01.md`;
- `docs/products/59-caso-real-01-pacote-revisao-humana.md`;
- `docs/products/60-caso-real-01-validacao-tecnica-gate-revisao-humana.md`.

---

# 3. Evidência técnica do Gate

GitHub Actions:

- run: **37213717492**;
- commit testado: `876f7b1deac0909e8475c1fb6f15902edf83bb0b`;
- conclusão: **success**;
- PostgreSQL: implementação de referência da PoC.

Artifact:

- ID: **11306934256**;
- nome: `oes-s5-evidence-37213717492`;
- digest: `sha256:81578896ae97f582bd3029c4f276303e0208067b0cdcf053b0bb46f764b3a51f`.

Validações relevantes:

- RC01-T01–T10: PASS;
- HRG-T01–T06: PASS;
- F3-FE-T01–T17: PASS;
- F3-VIEW-T01–T17: PASS;
- F3-PROV-T01–T06: PASS;
- F3-TEMPLATE: PASS;
- rebuild through migration 009: PASS.

---

# 4. Semântica validada do review_record

## REVISE

`decision = revise`

não satisfaz:

`MISSING_APPROVED_REVIEW`

e mantém o produto não publicável.

## REJECTED

`decision = rejected`

gera:

`ACTIVE_REJECTION`

e bloqueia publicação.

## APPROVED concorrente com rejeição ativa

Uma aprovação ativa:

> **não sobrepõe uma rejeição ativa.**

## APPROVED sem publication_date

Mesmo com aprovação válida:

> **a ausência de publication_date mantém o gate bloqueado.**

## Condições finais completas

Somente quando:

- existe aprovação válida;
- não há rejeição ativa;
- publication_date está presente;
- demais requisitos do ProductVersion estão satisfeitos;

o gate pode retornar:

`publishable=true`.

---

# 5. Regra de segurança dos testes

O arquivo:

`database/f3-human-review-gate-tests.sql`

usa apenas revisores sintéticos identificados como teste.

Toda simulação ocorre em:

`BEGIN ... ROLLBACK`

Portanto:

> **nenhum review_record sintético persiste.**

Após os testes, o Caso Real 01 continua sem aprovação humana real.

---

# 6. Estado científico do Caso Real 01

Conclusão draft:

> A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos.

GRADE:

> **moderada — provisória**

Estado:

- `under_review`;
- `publishable=false`;
- `publication_date=NULL`;
- sem `review_record approved` real.

---

# 7. Pacote de revisão

Entrada para o revisor:

`docs/products/59-caso-real-01-pacote-revisao-humana.md`

O pacote permite revisar:

1. PICO;
2. síntese-base;
3. ROBIS;
4. RoB 2;
5. estratégia de atualização;
6. decisão de não realizar pooling;
7. GRADE por domínio;
8. certainty final;
9. conclusão;
10. segurança;
11. aplicabilidade;
12. limitações;
13. conflitos de interesse;
14. decisão global.

Decisões permitidas:

- APPROVED;
- REVISE;
- REJECTED.

---

# 8. Ponto exato de retomada

## Receber e registrar revisão humana real do Caso Real 01

Não há outra transição científica autorizada para este ProductVersion antes disso.

### Se APPROVED

1. verificar eventuais alterações solicitadas;
2. registrar `review_record approved`;
3. atribuir `publication_date` somente quando o conteúdo final estiver fechado;
4. executar publication gate;
5. exigir `publishable=true`;
6. gerar EvidenceSheetView final;
7. renderizar Ficha publicada;
8. registrar o resultado.

### Se REVISE

1. registrar `review_record revise`;
2. manter `under_review`;
3. aplicar alterações;
4. gerar nova ProductVersion quando a mudança for material;
5. repetir a revisão.

### Se REJECTED

1. registrar `review_record rejected`;
2. manter publicação bloqueada;
3. documentar justificativas;
4. decidir entre reanálise, rerroteamento ou arquivamento.

---

# 9. Limite de automação

O OES pode continuar desenvolvendo outros componentes independentes.

Para este ProductVersion:

> **a revisão humana não pode ser simulada, inferida ou criada automaticamente.**

Preparação de pacote, teste de workflow ou uso de revisor sintético em transação:

> **não equivale a revisão humana.**

---

**Fim do CP25**
