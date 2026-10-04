# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP26  
**Checkpoint anterior:** CP25  
**Status:** artefato de continuidade; não normativo  
**Escopo:** modelo A0–A3 validado; Caso Real 01 em A1; owner governance approval preparado  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP26

> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Modelo de garantia A0–A3: VALIDADO**  
> **Caso Real 01: A1**  
> **AI methodological verification: PASSED**  
> **Owner governance approval: PENDENTE**  
> **Expert independent review: NÃO REALIZADA**  
> **Product: under_review / publishable=false**

Base do repositório no fechamento:

`main @ 5245c4ba0bc619c87e0daa724b1433f598403d07`

---

# 2. Governança vigente

Documento normativo:

`docs/governance/04-governanca-garantia-revisao.md`

Três funções separadas:

1. `ai_methodological_verification`;
2. `owner_governance_approval`;
3. `expert_independent_review`.

Níveis derivados:

- A0 — sem verificação metodológica aprovada;
- A1 — AI methodological verification passed;
- A2 — A1 + owner governance approval;
- A3 — A2 + expert independent review approved.

---

# 3. Limite de papel do proprietário

O proprietário:

- não é methodological reviewer;
- não valida ROBIS/RoB 2/GRADE;
- não valida bioestatística;
- aprova somente governança, escopo, transparência e comunicação.

A ausência de expert review deve permanecer explícita em A2.

---

# 4. Validação técnica do modelo

Documento:

`docs/products/62-resultado-validacao-modelo-garantia-a0-a3.md`

Run:

- **37225407890**
- migration 010: PASS;
- migration 011: PASS;
- AG-T01–T07: PASS;
- EvidenceSheetView assurance: PASS;
- template v0.2: PASS;
- rebuild: PASS.

---

# 5. Verificação metodológica do Caso Real 01

## Primeira passagem

Documento 63:

> **REVISE**

Achado principal:

- interpretação incorreta da presença de Somzz nas referências de Hwang como prova de inclusão no pooling.

Correções:

- ROBIS ajustado;
- Somzz reclassificado como update pós-cutoff;
- justificativas dependentes corrigidas;
- dataset e documentos atualizados.

## Segunda passagem

Documento 64:

> **PASSED**

Assurance resultante:

> **A1**

---

# 6. Evidência de execução A1

GitHub Actions:

- run: **37226199396**
- commit testado: `860988a16ff9890cf5b8c203e7a648f7d1ba8bb7`
- conclusão: success

Validações:

- RC01-T01–T10: PASS;
- AG-T01–T07: PASS;
- AV-T01–T02: PASS;
- F3-TEMPLATE: PASS;
- rebuild through migration 011: PASS.

Artifact:

- ID: **11311923205**
- digest: `sha256:4450a1eb9cd4e46012b8fecf55fa132a7b13e80af0472a10eaf8d859d12aeeb6`

---

# 7. Documento de decisão do proprietário

Arquivo:

`docs/products/65-caso-real-01-aprovacao-governanca-proprietario.md`

O documento contém apenas perguntas não técnicas sobre:

- adequação da pergunta;
- clareza da conclusão;
- visibilidade de incertezas;
- transparência sobre IA;
- ausência de expert review;
- separação entre evidência e recomendação;
- autorização para publicação sob A2.

---

# 8. Estado atual

Product:

`OES-P-2026-000401`

Estado:

- `under_review`;
- assurance: **A1**;
- owner approval: ausente;
- expert review: ausente;
- `publication_date=NULL`;
- `publishable=false`.

Nenhuma mensagem anterior de “OK” ou “prossiga” foi interpretada como owner approval.

---

# 9. Ponto exato de retomada

## Decisão explícita do proprietário no Documento 65

Decisões possíveis:

### APPROVED

- registrar `owner_governance_approval = approved`;
- assurance passa a A2;
- manter disclosure de ausência de expert review;
- fechar conteúdo;
- definir publication_date;
- reexecutar publication gate;
- validar Ficha final.

### REVISE

- assurance permanece A1;
- registrar ajustes solicitados;
- corrigir;
- reapresentar ao proprietário.

### REJECTED

- publication gate permanece bloqueado;
- registrar decisão;
- decidir entre revisão/arquivamento.

---

# 10. Regra de integridade

A próxima transição exige decisão explícita do proprietário.

> **Não inferir APPROVED de concordância genérica com o projeto ou com o modelo A0–A3.**

---

**Fim do CP26**
