# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP21  
**Checkpoint anterior:** CP20  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 3 — Template Operacional da Ficha validado; transição para caso real  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP21

Estado formal:

> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Documentos 41–47 — cadeia da Ficha de Evidência consolidada até template operacional**  
> **Evidence Sheet contract — PASS**  
> **EvidenceSheetView — PASS**  
> **Template `oes.evidence_sheet.template/0.1` — PASS estrutural/operacional**  
> **Próxima etapa: VALIDAÇÃO CIENTÍFICA PONTA A PONTA COM CASO REAL N2**

Base documental anterior à criação deste checkpoint:

`main @ 80bf62fe810707f663c0e1e3582da0871db28f10`

---

# 2. Cadeia técnica validada

`Question/Investigation`
→ `Evidence objects`
→ `Synthesis/Certainty`
→ `ProductVersion`
→ `Publication Gate`
→ `EvidenceSheetView`
→ `Template Markdown`

Essa cadeia foi executada com fixture determinística.

---

# 3. Documentos centrais

- `docs/products/41-especificacao-ficha-evidencia.md`
- `docs/products/42-contrato-dados-ficha-evidencia.md`
- `docs/products/43-resultado-validacao-contrato-ficha.md`
- `docs/products/44-evidence-sheet-view.md`
- `docs/products/45-resultado-validacao-evidence-sheet-view.md`
- `docs/products/46-especificacao-template-ficha-evidencia.md`
- `docs/products/47-resultado-validacao-template-ficha.md`

---

# 4. Template operacional

Arquivo:

`templates/evidence-sheet.md`

Versão:

`oes.evidence_sheet.template/0.1`

Input:

`oes.evidence_sheet_view/0.1`

Mapa de apresentação:

`templates/evidence-sheet-presentation-map.json`

Renderer de referência:

`scripts/render_evidence_sheet_reference.py`

Validador:

`scripts/validate_evidence_sheet_render.py`

---

# 5. Resultado final de validação

GitHub Actions:

- run: **37196822297**
- commit: `de824e4c11319e5a08e034895502770afcef18f5`
- PostgreSQL: **18.6**
- F3-TEMPLATE: **PASS**
- Reference Markdown render: **PASS**
- F3-VIEW: PASS
- F3-FE: PASS
- regressão F2-B: PASS
- regressão S4: PASS
- regressão S5: PASS
- rebuild até migration 007: PASS

Artifact:

- ID: **11300953823**
- digest: `sha256:99a1c851678ab5ba005517f793518e13ac708bfea32f756c668135a19b47d09b`

---

# 6. Decisões consolidadas do template

1. Markdown é a primeira saída operacional.
2. O template consome exclusivamente EvidenceSheetView.
3. Campos artificiais `display.*` foram removidos.
4. Traduções de enums pertencem a mapa de apresentação.
5. Renderer Python é implementação de referência.
6. O template não escolhe estudos.
7. O template não recalcula Results.
8. O template não recalcula certainty.
9. O template não cria julgamento de risco de viés.
10. O template não produz recomendação.
11. Produto não publishable pode ser preview interno, mas não publicação externa.
12. Auditabilidade permanece presente no mesmo artefato.
13. O template permanece evolutivo até validação científica/editorial com casos reais.

---

# 7. Limitações ainda abertas

A fixture não testa adequadamente:

- múltiplos outcomes complexos;
- apresentação editorial de `result_summary` quantitativo;
- no-evidence;
- certainty não avaliada;
- safety/harms;
- CERQual em Ficha real;
- diagnóstico;
- PredictionModel;
- atualização com predecessor;
- Ficha não publishable;
- listas extensas.

Essas são lacunas de validação de produto, não defeitos conhecidos do baseline.

---

# 8. Próxima etapa exclusiva

## Validação científica ponta a ponta da Ficha com caso real N2

A próxima execução deverá usar uma pergunta real e percorrer:

1. entrada da pergunta;
2. normalização;
3. classificação;
4. roteamento N2;
5. busca real;
6. triagem;
7. avaliação crítica;
8. extração;
9. síntese;
10. certainty/confiança;
11. aplicabilidade;
12. conclusão;
13. ProductVersion;
14. revisão humana;
15. publication gate;
16. EvidenceSheetView;
17. render Markdown;
18. revisão científica/editorial.

---

# 9. Critérios para escolha do primeiro caso real

Preferir pergunta:

- focal;
- clinicamente relevante;
- com volume de literatura manejável;
- com pelo menos uma síntese ou estudos primários suficientes;
- sem urgência extrema;
- sem necessidade inicial de NMA;
- sem depender de recomendação normativa;
- capaz de testar magnitude de efeito e certainty;
- com utilidade para futura manutenção.

Evitar no primeiro caso:

- pergunta excessivamente ampla;
- tema com literatura massiva;
- cenário em rápida mudança diária;
- questão predominantemente regulatória;
- caso que exija recomendação clínica individual.

---

# 10. Regra para retomada

1. consultar o ponteiro;
2. ler CP21;
3. aplicar Freshness Gate;
4. consultar Documentos 41–47;
5. não alterar o baseline para acomodar peculiaridade do caso sem necessidade demonstrada;
6. escolher um caso real adequado a N2;
7. registrar a Investigation real;
8. executar o pipeline completo;
9. documentar qualquer defeito ou ajuste de produto identificado.

---

**Fim do CP21**
