# 92 — Resultado da Validação do Template do Evidence Scan — N0

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Evidence Scan — N0  
**Data:** 5 de outubro de 2026  
**Status:** validação de renderização concluída — **PASS**  
**Dependências:** Documentos 86–91; migration 013

---

# 1. Objetivo

Registrar a validação técnica do contrato de renderização e do template operacional do Evidence Scan — N0.

Foram validados:

- EvidenceScanView 0.1;
- template Markdown N0;
- presentation map;
- renderer de referência;
- validator estrutural;
- estado A2/publicável;
- estado A1/preview;
- estado `insufficient` sem Report central;
- regressões N1/N2/OES-P1.

# 2. Artefatos validados

- `templates/evidence-scan.md`;
- `templates/evidence-scan-presentation-map.json`;
- `scripts/render_evidence_scan_reference.py`;
- `scripts/validate_evidence_scan_render.py`;
- integração em `scripts/validate_evidence_sheet_render.py`;
- integração no workflow `validate-s5.yml`.

# 3. Cenários de apresentação validados

## A2 formal

- `publishable=true`;
- gate aprovado;
- ausência de preview;
- assurance A2;
- ausência de expert review explicitamente divulgada.

## A1 interno

- `publishable=false`;
- preview visível;
- blocker `MISSING_OWNER_APPROVAL` visível;
- assurance disclosure de A1 preservado.

## Campo insufficient sem Report central

- `central_sources=[]`;
- `references=[]`;
- `traceable_basis_type=search_only_insufficient`;
- warning `NO_TRACEABLE_CENTRAL_REPORTS` visível;
- ausência de fonte central não é apresentada como ausência definitiva de evidência;
- produto pode permanecer publicável quando o gate científico/técnico estiver satisfeito.

# 4. Evidência de execução

GitHub Actions:

- run **37370645875**;
- attempt **3**;
- conclusion **success**;
- commit validado `2f891bb010a6bddd8982aa09883a8fe53228b5cd`.

Artifact:

- ID **11371185153**;
- nome `oes-s5-evidence-37370645875`;
- digest `sha256:90f69eb5967733dd2149caa81721ea41152d56b7c666123ae120c0b788545adc`.

# 5. Logs confirmados

- `F3-ES-TEMPLATE validation PASS`;
- `F3-ER-TEMPLATE validation PASS`;
- `RN1-TEMPLATE-A2 validation PASS`;
- `F3-TEMPLATE PASS`;
- `ES-T01–T15 PASS`;
- `EvidenceScanView PASS`;
- `Rebuild through migration 013 PASS`.

# 6. Regressões

Permaneceram em PASS:

- F2-B;
- S4;
- S5;
- Ficha N2;
- Resposta N1;
- assurance A0–A3;
- provenance;
- casos reais N1/N2.

# 7. Decisão

> **Template operacional do Evidence Scan — N0: PASS técnico.**

A camada técnica do produto N0 está pronta para validação em caso real.

# 8. Próxima etapa

Iniciar:

> **Caso Real N0 — Evidence Scan**

O caso deverá ser deliberadamente exploratório e adequado para testar:

- terminologia incerta ou evolutiva;
- maturidade do campo;
- presença de sínteses;
- controvérsias/lacunas aparentes;
- recomendação de roteamento.

O caso real não deverá começar com uma pergunta já focalizada o suficiente para N1.

---

**Resultado final:** PASS.