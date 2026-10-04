# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP23  
**Checkpoint anterior:** CP22  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Caso Real 01 validado ponta a ponta em pré-publicação  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP23

> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Caso Real 01 — PASS ponta a ponta no estado under_review**  
> **Preview real — PASS**  
> **Publication gate — BLOQUEADO COMO ESPERADO**  
> **GRADE provisório — MODERADA, pendente de revisão humana**  
> **Próxima etapa: GATE DE REVISÃO HUMANA**

---

# 2. Evidência técnica final do caso real

GitHub Actions run:

- **37213165321**
- commit: `d9a2de71c9efed0722f9bf9698a42a374e8cd981`
- resultado: **success**

Artifact:

- ID: **11307386757**
- digest: `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`

Validações:

- RC01-T01–T10: PASS;
- F3-TEMPLATE: PASS;
- F3-PROV: PASS;
- F3-VIEW: PASS;
- F3-FE: PASS;
- regressões F2-B/S4/S5: PASS;
- rebuild through migration 009: PASS.

---

# 3. Dataset canônico do Caso Real 01

- `database/f3-real-case-01-dcbti.sql`
- `database/f3-real-case-01-tests.sql`
- `database/f3-real-case-01-rebuild-check.sql`

Arquivos paralelos/duplicados foram removidos.

---

# 4. Cadeia científica validada

`Question`
→ `Investigation N2`
→ `Search`
→ `Screening`
→ `Study/Report`
→ `Result`
→ `ROBIS/RoB 2`
→ `Synthesis source`
→ `Synthesis primary OES update`
→ `Synthesis corroborative`
→ `GRADE provisório`
→ `ProductVersion under_review`
→ `Publication Gate`
→ `EvidenceSheetView`
→ `Preview Markdown`

---

# 5. Resultado científico provisório

Conclusão draft:

> **A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos; a estimativa quantitativa-base não foi recalculada pelo OES.**

Certainty provisória:

> **moderada**

---

# 6. Bloqueio de publicação

O produto está corretamente:

- `under_review`;
- sem publication_date;
- sem review_record approved;
- `publishable=false`.

Issue obrigatória:

- `MISSING_APPROVED_REVIEW`.

Nenhuma aprovação humana foi simulada ou criada automaticamente.

---

# 7. Decisão sobre Syntheses

O produto mantém três papéis explícitos:

- `source` — estimativa quantitativa externa adotada;
- `primary` — atualização narrativa OES, sem novo pooling;
- `corroborative` — síntese externa adicional de triangulação.

A certainty OES está ligada à atualização primária, não é herdada automaticamente da fonte externa.

---

# 8. Arquitetura de projeção vigente

Sequência canônica:

- 007 — EvidenceSheetView;
- 008 — provenance-aware references;
- 009 — study-type counts.

Schema científico canônico não precisou de nova entidade para o caso real.

---

# 9. Documentação do Caso Real 01

- Documento 48 — protocolo;
- 49 — busca/triagem;
- 50 — ROBIS;
- 51 — RoB 2;
- 52 — síntese atualizada;
- 53 — GRADE provisório;
- 54 — draft científico;
- 55 — arquitetura de síntese adotada;
- 56 — reconciliação;
- 57 — validação do hardening;
- 58 — resultado ponta a ponta.

---

# 10. Ponto exato de retomada

## Gate de Revisão Humana do Caso Real 01

Preparar um pacote de revisão contendo:

1. pergunta e escopo;
2. síntese de busca;
3. ROBIS;
4. RoB 2;
5. síntese quantitativa-base;
6. atualização OES;
7. GRADE por domínio;
8. conclusão draft;
9. limitações;
10. aplicabilidade;
11. segurança;
12. preview da Ficha;
13. formulário de decisão do revisor.

O revisor humano deverá poder:

- aprovar;
- solicitar revisão;
- rejeitar;

com justificativa.

---

# 11. Regra de segurança científica

Até revisão humana real:

> **não criar `review_record approved`.**

Não alterar o produto para `published`.

Não preencher publication_date.

Não declarar certainty final formalmente aprovada.

---

# 12. Próxima ação autorizada

O OES pode:

- preparar checklist/formulário de revisão;
- preparar pacote documental para revisor;
- testar o fluxo técnico de uma decisão `revise` em fixture separada;
- aperfeiçoar apresentação.

O OES não pode:

- inventar identidade de revisor;
- aprovar em nome do usuário;
- converter o caso real em publicação sem revisão real.

---

**Fim do CP23**
