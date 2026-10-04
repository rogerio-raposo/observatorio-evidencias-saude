# OES — Registro de Verificação Metodológica Assistida por IA

**Tipo de garantia:** `ai_methodological_verification`  
**Natureza:** verificação metodológica interna assistida por IA  
**Independência:** não deve ser classificada como revisão independente  
**Decisões possíveis:** `passed` / `revise` / `failed`

---

## 1. Identificação

**Product ID:**  
**ProductVersion UUID:**  
**Investigation ID:**  
**Data de corte da evidência:**  
**Data da verificação:**  
**Modelo/sistema de IA:**  
**Versão/configuração, quando disponível:**  
**Agente que produziu a análise inicial:**  
**A mesma instância produziu a análise inicial?** sim / não / desconhecido

> Mesmo quando executada em nova passagem, esta verificação não será descrita como peer review ou revisão especializada independente.

---

## 2. Materiais revisados

Registrar documentos, registros e fontes utilizados:

- [ ] pergunta/PICO;
- [ ] protocolo/roteamento;
- [ ] buscas;
- [ ] decisões de elegibilidade;
- [ ] estudos/reports;
- [ ] RiskAssessment;
- [ ] Results;
- [ ] Synthesis;
- [ ] CertaintyAssessment;
- [ ] conclusão;
- [ ] limitações;
- [ ] aplicabilidade;
- [ ] segurança, quando aplicável;
- [ ] provenance/lineage;
- [ ] conflitos de interesse relevantes.

**Materiais adicionais:**

---

## 3. Verificação adversarial

### 3.1 Pergunta e escopo

- A pergunta foi preservada?
- O PICO/estrutura está coerente?
- Houve expansão ou restrição não justificada?

**Achados:**

### 3.2 Busca e seleção

- As fontes são compatíveis com N2?
- Há estudo-semente importante não recuperado?
- Restrições estão justificadas?
- Há evidência de seleção guiada pelo resultado?

**Achados:**

### 3.3 Appraisal

- O instrumento é adequado ao desenho?
- Os julgamentos citam evidência observável?
- Informação ausente foi tratada como ausência de relato, e não como método adequado?
- Há julgamento excessivamente favorável ou desfavorável?

**Achados:**

### 3.4 Síntese

- Os estudos/resultados são combináveis?
- Há dupla contagem?
- A síntese adotada está claramente separada da síntese produzida pelo OES?
- Alguma estimativa foi apresentada como calculada pelo OES sem ter sido recalculada?
- Heterogeneidade e incerteza estão representadas?

**Achados:**

### 3.5 Certeza/confiança

- A unidade de certainty está correta?
- Cada downgrade/upgrade possui justificativa?
- Magnitude e direção foram distinguidas quando necessário?
- Aplicabilidade foi indevidamente convertida em certainty?
- O nível final é coerente com os domínios?

**Achados:**

### 3.6 Conclusão

- Responde à pergunta?
- É compatível com a certainty?
- Evita recomendação não autorizada?
- Evita linguagem de prova/certeza superior à evidência?
- Preserva limitações materiais?

**Achados:**

### 3.7 Segurança e conflitos

- Ausência de dano foi indevidamente inferida?
- COI foi confundido com risco de viés?
- Sinais materiais foram omitidos?

**Achados:**

### 3.8 Rastreabilidade

- Conclusion → Synthesis → Result → Study/Report → fonte é reconstruível?
- Há dependência invalidada/retratada?
- O cutoff está coerente?

**Achados:**

---

## 4. Contra-argumento obrigatório

Registrar a melhor razão encontrada para **não** aceitar a conclusão atual:

> 

Registrar por que essa razão:

- [ ] altera materialmente a conclusão;
- [ ] exige revisão, mas não invalida o produto;
- [ ] foi considerada e não altera materialmente a conclusão.

**Justificativa:**

---

## 5. Questões não resolvidas

1.  
2.  
3.  

---

## 6. Decisão

Escolher uma:

- [ ] **PASSED** — não foi identificado erro material não resolvido incompatível com publicação A2.
- [ ] **REVISE** — alterações são necessárias antes de nova verificação.
- [ ] **FAILED** — há problema metodológico material que impede avanço.

**Justificativa:**

---

## 7. Registro no OES

Se `PASSED`, criar `product.assurance_record`:

- assurance_type = `ai_methodological_verification`;
- actor_type = `ai_system`;
- independent_flag = `false`;
- decision = `passed`;
- evidence_payload = resumo estruturado desta verificação.

Este registro:

> **não equivale a expert review.**
