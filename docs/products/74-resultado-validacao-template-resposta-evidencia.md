# 74 — Resultado da Validação do Template Operacional da Resposta de Evidência — N1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Validação técnica concluída — PASS  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 68–73; migration 012  
**Produto:** OES — Resposta de Evidência  
**Nível:** N1

---

# 1. Objetivo

Registrar a validação do primeiro template operacional da Resposta de Evidência N1, consumindo exclusivamente:

`EvidenceResponseView — oes.evidence_response_view/0.1`

O teste buscou confirmar que a camada de apresentação:

- não cria ciência nova;
- preserva a natureza seletiva/não exaustiva do N1;
- apresenta fontes-chave e resultados rastreáveis;
- comunica ausência de certainty formal sem inventar julgamento;
- expõe assurance e publication issues;
- diferencia corretamente produto publicável de preview;
- não produz regressões na Ficha N2.

---

# 2. Arquivos validados

Template:

`templates/evidence-response.md`

Presentation map:

`templates/evidence-response-presentation-map.json`

Renderer:

`scripts/render_evidence_response_reference.py`

Validator:

`scripts/validate_evidence_response_render.py`

Integração de validação:

`scripts/validate_evidence_sheet_render.py`

A integração utiliza o step de renderização já existente no CI, sem acoplar o conteúdo N1 ao EvidenceSheetView.

---

# 3. Contratos

Template version:

`oes.evidence_response.template/0.1`

Input contract:

`oes.evidence_response_view/0.1`

Regra confirmada:

> **Template apresenta; não decide ciência.**

---

# 4. Comportamentos validados

O template validou:

1. título e identidade;
2. pergunta focal;
3. resposta sintética;
4. key results provenientes de provenance;
5. caráter estruturado e seletivo da busca;
6. declaração explícita de não exaustividade;
7. fontes-chave;
8. referências;
9. ausência de certainty formal;
10. limitações;
11. aplicabilidade descritiva;
12. assurance A2;
13. disclosure de ausência de expert review;
14. publication gate aprovado;
15. comportamento PREVIEW quando `publishable=false`;
16. exibição de publication issues bloqueantes em preview;
17. ausência de tokens de template não resolvidos.

---

# 5. Evidência de execução

GitHub Actions:

- run **37357423887**;
- status: completed;
- conclusion: **success**;
- commit: `68a3d7703c0f88f06419336936cea6007121516a`;
- artifact: **11365292099**;
- artifact name: `oes-s5-evidence-37357423887`.

Logs confirmaram explicitamente:

- `F3-ER-TEMPLATE validation PASS`;
- `Evidence Response N1 contract PASS`;
- `ER-T01–T14 PASS`;
- `Rebuild through migration 012 PASS`.

---

# 6. Regressões

Permaneceram em PASS:

- F2-B;
- S4;
- S5;
- Evidence Sheet contract;
- EvidenceSheetView;
- provenance-aware references;
- assurance;
- template N2;
- Caso Real 01 N2;
- rebuild geral.

---

# 7. Limitações

A validação do template utiliza fixture sintética.

Ainda é necessário testar:

- clareza com conteúdo clínico real;
- fontes múltiplas;
- certainty externa real;
- resultados quantitativos reais;
- limitações reais de busca;
- comportamento editorial real;
- assurance real do produto N1.

---

# 8. Decisão

> **Template operacional N1 v0.1: PASS técnico.**

A Resposta de Evidência possui agora:

- especificação científica;
- decisão arquitetural;
- contrato de dados;
- publication gate;
- EvidenceResponseView;
- template operacional;
- renderer;
- validator;
- regressão e rebuild validados.

---

# 9. Próxima etapa

Executar:

> **Caso Real N1 — validação ponta a ponta da Resposta de Evidência.**

O caso deverá:

1. ser focal;
2. possuir síntese recente e adequada;
3. ter criticidade compatível com N1;
4. não exigir busca exaustiva;
5. permitir busca estruturada seletiva;
6. usar fontes reais;
7. registrar appraisal proporcional;
8. testar provenance real;
9. testar certainty existente ou sua ausência;
10. passar pela verificação metodológica e owner governance approval antes de publicação formal.

---

**Resultado final:** PASS.
