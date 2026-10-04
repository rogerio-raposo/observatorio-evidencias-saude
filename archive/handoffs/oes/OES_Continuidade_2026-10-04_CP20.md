# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP20  
**Checkpoint anterior:** CP19  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 3 — EvidenceSheetView validado e transição para template operacional  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP20

Estado formal:

> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Documento 41 — Especificação Científica/Funcional da Ficha: CONSOLIDADO**  
> **Documento 42 — Contrato de Dados da Ficha: CONSOLIDADO**  
> **Documento 43 — Validação do Contrato da Ficha: PASS**  
> **Documento 44 — EvidenceSheetView: CONSOLIDADO**  
> **Documento 45 — Validação do EvidenceSheetView: PASS**  
> **Migration 006 — PASS**  
> **Migration 007 — PASS / idempotente por desenho**  
> **Próxima etapa: ESPECIFICAÇÃO DO TEMPLATE OPERACIONAL DA FICHA**

Base documental anterior à criação deste checkpoint:

`main @ e0274d6349d8c605ae6f76d28966a164e4da7354`

---

# 2. Evidência de validação do EvidenceSheetView

GitHub Actions:

- run: **37191973078**
- commit: `568591cfa0aceb332f4eca6ac33cee97fe3701ae`
- PostgreSQL: **18.6**
- F3-VIEW-T01–T16: **PASS**
- regressão F2-B: PASS
- regressão S4: PASS
- regressão S5: PASS
- regressão contrato da Ficha: PASS
- rebuild até migration 007: PASS

Artifact:

- ID: **11298729618**
- digest: `sha256:d3e53b35bccf3a89e5ee8621ff2d3fc5501d56b56e4a22b5aa8993e9897cbef9`

---

# 3. Contrato de renderização consolidado

Função de referência:

`product.evidence_sheet_view(uuid) RETURNS jsonb`

Schema:

`oes.evidence_sheet_view/0.1`

Blocos:

- identity;
- question;
- routing;
- method;
- evidence_base;
- priority_results;
- risk_of_bias;
- certainty_assessments;
- safety;
- limitations;
- applicability;
- conclusion;
- update_history;
- references;
- audit.

---

# 4. Decisões estruturais

1. EvidenceSheetView é projeção derivada.
2. Não é nova fonte canônica.
3. Não recalcula ciência.
4. Não atribui certainty.
5. Não produz recomendação.
6. Respeita versões concretas vinculadas ao ProductVersion.
7. N/M são derivados da Investigation.
8. Results/Synthesis/Certainty permanecem em suas entidades próprias.
9. Atualidade, mudanças e revisão chegam ao template sem duplicação.
10. Referências são derivadas de ResultSource.
11. Ordenação é determinística.
12. ProductVersion inexistente retorna NULL.
13. Migration 007 é idempotente por desenho.
14. O template pode ser construído sem nova persistência científica.

---

# 5. Ponto exato de retomada

## Especificação do Template Operacional da Ficha de Evidência

Próximas tarefas:

1. definir hierarquia de informação;
2. separar leitura rápida e auditabilidade;
3. definir ordem das seções;
4. definir apresentação de resultados prioritários;
5. definir representação visual/narrativa de certainty;
6. definir regras para no-evidence e certainty não avaliada;
7. definir segurança/danos;
8. definir limitações;
9. definir aplicabilidade;
10. definir atualidade e histórico;
11. definir referências e audit links;
12. definir regras de omissão, NULL e NA;
13. adotar Markdown como primeira saída operacional;
14. preservar equivalência futura para HTML/PDF/DOCX;
15. somente depois criar o arquivo de template.

---

# 6. Regra para retomada

1. consultar ponteiro;
2. ler CP20;
3. aplicar Freshness Gate;
4. consultar Documentos 40–45;
5. não alterar o contrato científico para resolver problema meramente visual;
6. definir template como transformação do EvidenceSheetView;
7. validar o template contra a fixture antes de caso real.

---

**Fim do CP20**
