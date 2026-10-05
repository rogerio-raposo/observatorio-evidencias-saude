# 84 — Caso Real N1: Aprovação de Governança do Proprietário

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** N1-01 — música gravada e ansiedade perioperatória  
**Tipo de garantia:** `owner_governance_approval`  
**Status atual:** **PENDENTE — A1 validado**  
**Data de preparação:** 5 de outubro de 2026  
**Não é:** revisão metodológica especializada  
**Dependências:** Documentos 04, 75–83

---

# 1. Finalidade

Este documento permite ao proprietário decidir se o Caso Real N1-01 pode avançar de:

> **A1 — verificação metodológica assistida por IA concluída**

para:

> **A2 — A1 + aprovação de governança do proprietário**

A aprovação:

- não valida tecnicamente ROBIS;
- não valida meta-análise;
- não cria certainty formal;
- não equivale a peer review;
- não equivale a expert independent review.

---

# 2. Estado atual

Product:

`OES-P-2026-000501`

ProductVersion atual:

> **2**

Estado editorial:

`under_review`

Assurance:

> **A1**

Histórico metodológico:

- primeira verificação adversarial: `REVISE`;
- ProductVersion 2 criada com correções;
- segunda verificação adversarial: `PASSED`;
- validação técnica final: PASS.

Expert independent review:

> **não realizada**

Publication gate:

> **bloqueado**

Bloqueios principais:

- owner governance approval ausente;
- publication_date ausente.

---

# 3. Pergunta analisada

> Em adultos submetidos a procedimentos cirúrgicos hospitalares, ouvir música gravada no período perioperatório reduz a ansiedade em comparação ao cuidado usual ou ausência de música?

### Avaliação de governança

A pergunta corresponde ao que o produto pretende responder?

- [ ] Sim.
- [ ] Não.
- [ ] Solicito ajuste.

---

# 4. Conclusão apresentada

> **Sínteses sistemáticas recentes apontam redução média dos escores de ansiedade perioperatória com intervenções de música gravada em comparação ao cuidado usual ou ausência de música. Na meta-análise de Stoop et al. 2026, o efeito agrupado foi SMD aproximadamente -0,73 (IC95% -0,94 a -0,53). Em outra meta-análise de 2026, Yu et al. reportaram SMD -0,50 (IC95% -0,60 a -0,39) na análise principal. As duas sínteses apontam direção favorável, mas as magnitudes não devem ser tratadas como uma única faixa porque diferem em composição e decisões analíticas. A magnitude e a relevância clínica exatas permanecem incertas por limitações metodológicas dos ensaios, heterogeneidade e possível viés de publicação. Na checagem seletiva OES de estudos posteriores ao cutoff da síntese decisiva, os estudos localizados mantiveram direção geral favorável e não foi identificado sinal que exigisse rerroteamento; essa checagem não pretende completude.**

### Avaliação de governança

A conclusão é compreensível e responde diretamente à pergunta sem aparentar certeza maior que a documentada?

- [ ] Sim.
- [ ] Não.
- [ ] Solicito redação mais clara.

---

# 5. Incerteza e limitações

O produto informa, entre outras:

- risco de viés importante nos ensaios;
- ausência prática de cegamento;
- heterogeneidade clínica;
- magnitudes diferentes entre sínteses;
- possível publication/small-study bias;
- relevância clínica exata incerta;
- NNT transformado;
- busca OES seletiva e não exaustiva;
- ausência de certainty formal OES.

### Avaliação de governança

Essas limitações estão suficientemente visíveis?

- [ ] Sim.
- [ ] Não.

---

# 6. Natureza N1

O produto declara explicitamente que:

> **a busca OES é estruturada e seletiva e não pretende demonstrar identificação exaustiva de toda a literatura.**

### Avaliação de governança

Está claro que esta é uma Resposta de Evidência N1 e não uma revisão sistemática completa?

- [ ] Sim.
- [ ] Não.

---

# 7. Transparência sobre a garantia

Se aprovado em A2, o produto deverá declarar:

> **Verificação metodológica:** processo OES assistido por IA.  
> **Aprovação de governança:** realizada pelo proprietário do projeto.  
> **Revisão especializada independente:** não realizada.

### Avaliação de governança

Essa descrição representa de forma clara e aceitável como o produto foi produzido?

- [ ] Sim.
- [ ] Não.

---

# 8. Ausência de expert review

Em A2:

- a Resposta poderá ser publicada dentro do OES;
- não poderá ser apresentada como expert-reviewed;
- a ausência de revisão especializada permanecerá visível;
- usos de maior criticidade podem exigir escalonamento/A3.

### Avaliação de governança

Você entende e aceita essa limitação para publicação padrão N1?

- [ ] Sim.
- [ ] Não.

---

# 9. Recomendação e escopo

O produto:

- comunica evidência;
- não prescreve tratamento;
- não afirma substituição de tratamento farmacológico;
- não produz recomendação normativa;
- não substitui avaliação clínica individual.

### Avaliação de governança

Essa separação está adequada?

- [ ] Sim.
- [ ] Não.

---

# 10. Decisão global

Escolher uma:

- [ ] **APPROVED** — autorizo o produto a avançar sob garantia A2, mantendo explícita a ausência de revisão especializada independente.
- [ ] **REVISE** — solicito ajustes antes da aprovação.
- [ ] **REJECTED** — não autorizo publicação na forma atual.

Uma decisão global explícita é suficiente; não é necessário responder item a item.

---

# 11. Consequência

## Se APPROVED

Registrar `product.assurance_record` com:

- `assurance_type = owner_governance_approval`;
- `actor_type = owner`;
- `independent_flag = false`;
- `decision = approved`.

O assurance derivado passa a:

> **A2**

A publicação ainda dependerá de:

- fechamento editorial;
- atribuição explícita de `publication_date`;
- nova execução do publication gate.

## Se REVISE

- permanece A1;
- permanece `under_review`;
- correções deverão gerar nova ProductVersion quando materiais.

## Se REJECTED

- permanece sem A2;
- publicação continua bloqueada;
- decisão deverá ser preservada.

---

# 12. Regra de integridade

Mensagens anteriores como “prossiga”, “ok” ou aprovação de etapas metodológicas:

> **não serão interpretadas retroativamente como owner approval deste Caso Real N1-01.**

A decisão deve ser explicitamente vinculada a este produto.

---

**Estado atual:** A1 validado; decisão do proprietário pendente.
