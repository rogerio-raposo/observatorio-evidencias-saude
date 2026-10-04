# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP24  
**Checkpoint anterior:** CP23  
**Status:** artefato de continuidade; não normativo  
**Escopo:** pacote de revisão humana do Caso Real 01 concluído  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP24

> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Caso Real 01 — PASS ponta a ponta em pré-publicação**  
> **Pacote de revisão humana — PRONTO**  
> **Ficha — under_review / publishable=false**  
> **Próxima dependência: REVISÃO HUMANA REAL**

Base documental anterior a este checkpoint:

`main @ cb29853a143992c53695e7389df267c4dd7a73a9`

---

# 2. Estado técnico

Validação canônica:

- GitHub Actions run **37213165321**;
- PostgreSQL **18.6**;
- RC01-T01–T10: PASS;
- preview real: PASS;
- publication gate bloqueado como esperado;
- rebuild through migration 009: PASS;
- artifact **11307386757**;
- digest `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`.

---

# 3. Documentação do Caso Real 01

Documentos 48–58 preservam:

- protocolo;
- busca;
- triagem;
- ROBIS;
- RoB 2;
- síntese;
- GRADE provisório;
- draft;
- decisão arquitetural;
- hardening;
- validações;
- resultado end-to-end.

Documento adicional deste marco:

> `docs/products/59-caso-real-01-pacote-revisao-humana.md`

---

# 4. Pacote de revisão humana

O Documento 59 contém formulário estruturado para confirmação ou contestação de:

1. PICO;
2. escolha da síntese-base;
3. ROBIS;
4. RoB 2;
5. estratégia de atualização;
6. decisão de não realizar novo pooling;
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

# 5. Regra de segurança científica

A existência do pacote de revisão:

> **não equivale a revisão humana concluída.**

Até existir uma decisão humana real e identificável:

- não criar `review_record approved`;
- não preencher `publication_date`;
- não alterar ProductVersion para `published`;
- não declarar o GRADE como humanamente aprovado;
- não liberar a Ficha externamente como produto publicado.

---

# 6. Estado científico atual

Conclusão draft:

> A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos.

GRADE:

> **moderada — provisória**

Estado:

> **under_review**

---

# 7. Ponto exato de retomada

## Aguardar/receber revisão humana real do Caso Real 01

Entrada do revisor:

`docs/products/59-caso-real-01-pacote-revisao-humana.md`

Na retomada, verificar se houve decisão humana explícita.

### APPROVED

- registrar review_record;
- aplicar eventuais alterações;
- atribuir publication_date;
- executar publication gate;
- exigir publishable=true;
- gerar Ficha final;
- documentar publicação.

### REVISE

- registrar review_record revise;
- manter under_review;
- aplicar alterações;
- repetir revisão.

### REJECTED

- registrar review_record rejected;
- manter publication gate bloqueado;
- decidir reanálise, rerroteamento ou arquivamento.

---

# 8. Limite de automação

O desenvolvimento automático pode continuar em componentes independentes do Caso Real 01.

Porém, para este ProductVersion específico:

> a próxima transição científica requer uma pessoa revisora real.

---

**Fim do CP24**
