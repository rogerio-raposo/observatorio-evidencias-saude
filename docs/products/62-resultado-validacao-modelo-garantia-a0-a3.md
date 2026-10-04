# 62 — Resultado da Validação Técnica do Modelo de Garantia A0–A3

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** PASS  
**Data:** 4 de outubro de 2026  
**GitHub Actions run:** 37225407890  
**Commit testado:** `8903a60c60b7f8a43c2a6164015bddc5a03743da`

---

# 1. Resultado

O novo modelo de garantia foi validado integralmente em PostgreSQL.

> **Assurance A0–A3 governance = PASS**

Foram validados:

- migration 010;
- migration 011;
- publication gate A2;
- elevação A2 → A3;
- bloqueios por revise/rejected/failed;
- constraints de papel;
- EvidenceSheetView;
- template v0.2;
- Caso Real 01 em A0;
- rebuild do zero;
- regressões anteriores.

---

# 2. Evidência de execução

Artifact:

- ID: **11312011693**
- nome: `oes-s5-evidence-37225407890`
- digest: `sha256:80aa42319d479e2235f7f9bcb3676c4dda5b522d987873468ed1dc8c2f4e52ef`
- tamanho: 28309 bytes
- retenção: 30 dias.

Hashes principais:

- migration 010: `6556b2ef947e912bc26eb333f40261214a3eb97f4fa3fab89079687bfb6c2625`;
- migration 011: `abded694d63413c283743858e63707643d3a2bf8019e04fcd0f9295049f6d397`;
- assurance gate tests: `242b9d67163b33cdb62a63f1156057a3466a0eaf87cce96685cd4634c84fb955`;
- assurance view tests: `f450dcf4d4d30f54aa526b9096cb4407acc061630fa029559dbfbeda322602fb`.

---

# 3. AG-T01 — A2 publicável sem expert review

Fixture:

- AI verification = passed;
- owner approval = approved;
- expert review ausente.

Resultado:

- assurance = A2;
- publishable = true;
- warning `NO_EXPERT_INDEPENDENT_REVIEW`.

> PASS

---

# 4. AG-T02 — A3

Foi adicionada revisão especializada sintética válida.

Resultado:

- assurance = A3;
- warning de ausência de expert review desapareceu;
- publicação permaneceu elegível.

> PASS

---

# 5. AG-T03 — expert revise

Resultado:

- publication blocked;
- `ACTIVE_EXPERT_REVISE`;
- assurance efetiva retorna A2.

> PASS

---

# 6. AG-T04 — expert rejected

Resultado:

- `ACTIVE_EXPERT_REJECTION`;
- publication blocked.

> PASS

---

# 7. AG-T05 — owner revise

Resultado:

- assurance A1;
- `MISSING_OWNER_APPROVAL`;
- `ACTIVE_OWNER_REVISE`;
- publication blocked.

> PASS

---

# 8. AG-T06 — AI revise / failed

AI `revise`:

- assurance A0;
- `ACTIVE_AI_METHOD_REVISE`.

AI `failed`:

- publication blocked;
- `ACTIVE_AI_METHOD_FAILURE`.

> PASS

---

# 9. AG-T07 — prevenção de falsa qualificação

Constraints rejeitaram:

- owner registrado como expert;
- IA registrada como independente;
- expert registrado como owner.

> PASS

Consequência:

> o banco protege semanticamente a separação entre os três papéis.

---

# 10. EvidenceSheetView

## AV-T01

Fixture A2:

- assurance_level = A2;
- expert_independent_reviewed = false;
- disclosure explícito de ausência de expert review;
- publication warning exposto;
- publishable = true.

> PASS

## AV-T02

Caso Real 01 ainda sem assurance:

- assurance_level = A0;
- expert_independent_reviewed = false.

> PASS

---

# 11. Template

O template v0.2 passou a exigir:

- nível de garantia;
- disclosure de assurance;
- ausência explícita de expert review em A2.

O validador falha se A2 ocultar essa limitação.

> **F3-TEMPLATE PASS**

---

# 12. Migration semantics

## 010

É migration estrutural.

Reaplicação acidental:

> detectada por erro de relação já existente.

**F3-ASSURANCE-T08 PASS**

## 011

É projeção `CREATE OR REPLACE`.

Reaplicação:

> idempotente por desenho.

PASS.

---

# 13. Regressões

No mesmo run:

- F2-B: PASS;
- S4: PASS;
- S5: PASS;
- F3-FE: PASS;
- F3-VIEW: PASS;
- F3-PROV: PASS;
- F3-TEMPLATE: PASS;
- RC01: PASS;
- rebuild through migration 011: PASS.

---

# 14. Consequência metodológica

A arquitetura agora permite afirmar com precisão:

> **“verificação metodológica assistida por IA + aprovação de governança do proprietário”**

sem transformar isso em:

> **“revisão especializada independente”.**

O nível de assurance é uma dimensão própria e não substitui N0–N4.

---

# 15. Próxima etapa

O Caso Real 01 permanece A0.

Próximo passo:

> **executar AI methodological verification adversarial.**

Se `passed`:

- registrar A1;
- renderizar preview A1;
- apresentar owner governance approval ao proprietário.

---

**Resultado final:** PASS.
