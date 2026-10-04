# OES — Aprovação de Governança do Proprietário

**Tipo de garantia:** `owner_governance_approval`  
**Natureza:** aprovação de escopo, transparência e comunicação  
**Não é:** revisão metodológica especializada  
**Decisões possíveis:** `approved` / `revise` / `rejected`

---

## 1. Identificação

**Product ID:**  
**ProductVersion:**  
**Título:**  
**Data:**  
**Proprietário:**  

---

## 2. Declaração de papel

Ao preencher este formulário, o proprietário **não está validando tecnicamente**:

- ROBIS;
- RoB 2/ROBINS;
- GRADE/CERQual;
- métodos meta-analíticos;
- bioestatística especializada.

Sua decisão significa apenas que o produto pode ou não avançar **dentro da governança declarada do OES**.

---

## 3. Checklist compreensível

### 3.1 Pergunta

A pergunta apresentada corresponde ao que o produto deveria investigar?

- [ ] Sim.
- [ ] Não.
- [ ] Preciso de ajuste de redação.

### 3.2 Conclusão

A conclusão está compreensível e responde diretamente à pergunta?

- [ ] Sim.
- [ ] Não.
- [ ] Requer redação mais clara.

### 3.3 Incerteza

Está claro para um leitor que a conclusão possui incertezas e limitações?

- [ ] Sim.
- [ ] Não.

### 3.4 Limitações

As principais limitações aparecem de forma visível, sem serem escondidas?

- [ ] Sim.
- [ ] Não.

### 3.5 Natureza da revisão

Está explícito que:

- a verificação metodológica foi assistida por IA; e
- **não houve revisão especializada independente**, quando A3 não estiver presente?

- [ ] Sim.
- [ ] Não.

### 3.6 Recomendação

O texto evita transformar evidência em prescrição/recomendação normativa não autorizada?

- [ ] Sim.
- [ ] Não.

### 3.7 Escopo de uso

Você entende que um produto A2:

- pode ser publicado dentro do OES;
- não deve ser apresentado como expert-reviewed;
- não substitui orientação clínica individual;
- pode exigir A3 em usos de maior criticidade?

- [ ] Sim.
- [ ] Não.

---

## 4. Observações do proprietário

> 

---

## 5. Decisão

Escolher uma:

- [ ] **APPROVED** — autorizo a publicação dentro do OES sob o nível de garantia declarado.
- [ ] **REVISE** — solicito ajustes antes da aprovação.
- [ ] **REJECTED** — não autorizo publicação na forma atual.

---

## 6. Registro no OES

Se `APPROVED`, criar `product.assurance_record`:

- assurance_type = `owner_governance_approval`;
- actor_type = `owner`;
- independent_flag = `false`;
- decision = `approved`.

A aprovação:

> **não deverá ser apresentada como revisão metodológica ou científica especializada.**
