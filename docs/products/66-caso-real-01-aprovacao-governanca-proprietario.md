# 66 — Caso Real 01: Aprovação de Governança do Proprietário

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Tipo de garantia:** `owner_governance_approval`  
**Status atual:** **A1 — aguardando decisão do proprietário**  
**Data de preparação:** 4 de outubro de 2026  
**Não é:** revisão metodológica especializada  
**Dependências:** Documentos 04, 54, 61–64

---

# 1. Finalidade

Este documento permite ao proprietário do OES decidir se o Caso Real 01 pode avançar de:

> **A1 — verificação metodológica assistida por IA concluída**

para:

> **A2 — A1 + aprovação de governança do proprietário**

A aprovação aqui:

- não valida tecnicamente ROBIS;
- não valida tecnicamente RoB 2;
- não valida tecnicamente GRADE;
- não equivale a peer review;
- não equivale a revisão especializada independente.

---

# 2. Estado atual do produto

Product:

`OES-P-2026-000401`

Estado editorial:

`under_review`

Assurance:

> **A1**

Verificação metodológica:

- primeira passagem adversarial: `REVISE`;
- correções executadas;
- segunda passagem adversarial: `PASSED`.

Expert review:

> **não realizada**

Publication gate:

> **bloqueado**

Motivos principais:

- owner governance approval ainda ausente;
- publication_date ainda ausente.

---

# 3. Pergunta analisada

> Em adultos com insônia, a dCBT-I totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia no pós-tratamento?

### Pergunta ao proprietário

Essa é a pergunta que você entende que o produto deveria responder?

- [ ] Sim.
- [ ] Não.
- [ ] Solicito ajuste de redação.

---

# 4. Conclusão apresentada

Draft atual:

> **A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos.**

### Pergunta ao proprietário

A conclusão está compreensível e responde diretamente à pergunta?

- [ ] Sim.
- [ ] Não.
- [ ] Solicito redação mais clara.

---

# 5. Incerteza e limitações

O produto informa, entre outras limitações:

- magnitude variável entre estudos;
- heterogeneidade relevante na síntese-base;
- alguns estudos com preocupações metodológicas;
- busca N2 sem pretensão de exaustividade N4;
- nova meta-análise não realizada pelo OES;
- segurança menos bem caracterizada;
- ausência de RCT brasileiro diretamente aderente.

### Pergunta ao proprietário

Está claro que a conclusão possui incertezas e limitações, sem aparentar certeza absoluta?

- [ ] Sim.
- [ ] Não.

---

# 6. Transparência sobre o processo

O produto deverá declarar:

> **Verificação metodológica: processo OES assistido por IA.**  
> **Aprovação de governança: proprietário do projeto.**  
> **Revisão especializada independente: não realizada.**

### Pergunta ao proprietário

Essa descrição representa de forma clara e aceitável como o produto foi produzido?

- [ ] Sim.
- [ ] Não.

---

# 7. Ausência de expert review

No nível A2:

- o produto pode ser publicado dentro do OES;
- não pode ser apresentado como expert-reviewed;
- a ausência de revisão especializada permanece visível;
- usos de maior criticidade podem exigir A3.

### Pergunta ao proprietário

Você entende e aceita essa limitação para a publicação padrão N2 do OES?

- [ ] Sim.
- [ ] Não.

---

# 8. Recomendação e escopo de uso

O produto:

- comunica evidência;
- não prescreve tratamento individual;
- não produz recomendação normativa automática;
- não substitui avaliação clínica individual.

### Pergunta ao proprietário

O texto mantém adequadamente essa separação?

- [ ] Sim.
- [ ] Não.

---

# 9. Clareza geral

### Pergunta ao proprietário

Considerando apenas sua função de governança — e não de especialista científico — o produto está suficientemente claro e transparente para ser publicado dentro do OES sob garantia A2?

- [ ] Sim.
- [ ] Não.
- [ ] Solicito ajustes antes de decidir.

---

# 10. Observações do proprietário

> 

---

# 11. Decisão global

Escolher uma:

- [ ] **APPROVED** — autorizo o produto a avançar sob garantia A2, mantendo explícita a ausência de revisão especializada independente.
- [ ] **REVISE** — solicito ajustes antes da aprovação.
- [ ] **REJECTED** — não autorizo publicação na forma atual.

---

# 12. Consequência da decisão

## Se APPROVED

Registrar:

`product.assurance_record`

com:

- `assurance_type = owner_governance_approval`;
- `actor_type = owner`;
- `independent_flag = false`;
- `decision = approved`.

O assurance derivado passa a:

> **A2**

A publicação ainda dependerá de:

- fechamento do conteúdo;
- atribuição explícita de `publication_date`;
- nova execução do publication gate.

## Se REVISE

- assurance permanece A1;
- produto permanece `under_review`;
- registrar pontos solicitados;
- corrigir e reapresentar.

## Se REJECTED

- assurance permanece sem A2;
- publicação continua bloqueada;
- registrar justificativa;
- decidir entre revisão do produto ou arquivamento.

---

# 13. Regra de integridade

Uma resposta genérica anterior como “OK”, “prossiga” ou concordância com o redesenho de governança:

> **não será interpretada retroativamente como owner approval deste produto.**

A decisão do Documento 66 deve ser explícita.

---

**Estado atual:** formulário pronto; decisão do proprietário ainda não registrada.
