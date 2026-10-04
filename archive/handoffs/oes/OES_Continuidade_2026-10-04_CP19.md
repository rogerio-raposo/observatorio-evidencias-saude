# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP19  
**Checkpoint anterior:** CP18  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 3 — contrato científico e físico da Ficha de Evidência  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP19

Estado formal:

> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Documento 41 — Especificação Científica/Funcional da Ficha: CONSOLIDADO**  
> **Documento 42 — Contrato de Dados da Ficha: CONSOLIDADO**  
> **Documento 43 — Validação do Contrato da Ficha: PASS**  
> **Migration 006 — PASS**  
> **Próxima etapa: EvidenceSheetView**

---

# 2. Evidência de validação

GitHub Actions:

- run: **37191456703**
- commit: `7649546e3e86c4989e26e6c3a381d15e04e22f82`
- PostgreSQL: **18.6**
- F3-FE-T01–T17: **PASS**
- regressão F2-B: PASS
- regressão S4: PASS
- regressão S5: PASS
- rebuild: PASS

Artifact:

- ID: **11299032774**
- digest: `sha256:2e3508b0d876e13e2f6efb367da8e8b308c943560e3d5e978fa293a8a4f851c1`

---

# 3. Contrato científico consolidado

A Ficha:

- é Product subtype;
- possui Product ID estável;
- gera nova ProductVersion para mudança material;
- usa uma Investigation principal;
- pode reutilizar Investigations/Syntheses mais profundas;
- não duplica Study/Report/Result/Synthesis/Certainty;
- exige limitações;
- separa segurança quando aplicável;
- mantém aplicabilidade separada da certainty;
- não produz recomendação normativa;
- é compatível com M0–M3;
- exige gate científico antes de publicação.

---

# 4. Extensões físicas validadas

Migration:

`database/006_product_evidence_sheet_contract.sql`

Adições:

- `ProductVersion.limitations_summary`;
- `product.currency_state`;
- `product.current_currency_state`;
- `product.version_change_class`;
- `product.review_record`;
- unique primary Investigation;
- `product.evidence_sheet_publication_issues(...)`;
- `product.evidence_sheet_is_publishable(...)`.

---

# 5. Decisões de parcimônia

Não implementados nesta etapa:

- ProductRelation;
- ApplicabilityAssessment formal;
- recommendation;
- campos duplicados de N/M;
- certainty global do Product;
- contagens persistidas de Studies/participantes;
- method_summary canônico.

Esses itens permanecem derivados, futuros ou metodologicamente não consolidados.

---

# 6. Ponto exato de retomada

## EvidenceSheetView

Próximas tarefas:

1. definir contrato de renderização;
2. estruturar objeto de saída;
3. mapear cada propriedade para OES-P1;
4. definir campos obrigatórios/condicionais;
5. definir ordenação de resultados;
6. definir representação de certainty e no-evidence;
7. definir atualidade e histórico;
8. definir audit links;
9. decidir implementação como SQL view, função ou view de aplicação;
10. testar contra a fixture validada;
11. somente depois criar template operacional.

---

**Fim do CP19**
