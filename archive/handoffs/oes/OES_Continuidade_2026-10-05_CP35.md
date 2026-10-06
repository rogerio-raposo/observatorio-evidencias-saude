# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-05  
**Checkpoint:** CP35  
**Checkpoint anterior:** CP34  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento técnico do contrato de renderização e template da Síntese Rápida N3  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP35

> **Síntese Rápida N3: contrato técnico + renderização + template = PASS técnico**

> **F3-RS-TEMPLATE PASS**

> **Próximo estágio: Caso Real N3 experimental**

Base técnica validada:

`main @ da3a4a3d8d18d9ac951ab028fc4249d95e898989`

Run final:

- GitHub Actions **37384841089**;
- conclusion **success**;
- artifact **11378245039**;
- digest `sha256:b94c8b1d4a2428233c01ba7ea40d4b7e720fb1a7e5dc76863a406d2e9959247c`.

## 2. Documentação consolidada desde CP34

- Documento 103 — contrato de renderização N3;
- Documento 104 — especificação do template N3;
- Documento 105 — resultado da validação do template: PASS.

## 3. Artefatos validados

- `templates/rapid-evidence-synthesis.md`;
- `templates/rapid-evidence-synthesis-presentation-map.json`;
- `scripts/render_rapid_evidence_synthesis_reference.py`;
- `scripts/validate_rapid_evidence_synthesis_render.py`.

## 4. Invariantes N3 preservados

- N3 é síntese formal rápida orientada a decisão;
- protocolo obrigatório;
- rapid restrictions explícitas;
- appraisal obrigatório;
- Synthesis esperada;
- certainty formal exigida quando aplicável;
- A3 exigido para publicação formal;
- A3 não substitui controles humanos qualificados;
- IA não satisfaz controle humano qualificado;
- missing controls devem permanecer visíveis;
- estado experimental não pode ser rotulado como quase aprovado.

## 5. Estado experimental validado

Fixture N3:

- assurance A2;
- publishable=false;
- quality controls por IA;
- sem expert independent review;
- sem qualified human controls;
- experimental warning visível.

Esse é o comportamento esperado.

## 6. Estado formal A3

A renderização formal A3 foi testada apenas em memória pelo validator.

A prova persistente do gate permanece transacional no RS-T11.

Nenhum A3 falso foi materializado.

## 7. Validações

- F3-RS-TEMPLATE PASS;
- RS-T01–T15 PASS;
- RapidEvidenceSynthesisView PASS;
- N3 qualified-human-control gate PASS;
- F3-RS-T16 duplicate migration detection PASS;
- rebuild through migration 014 PASS;
- regressões N0–N2/F2-B/S4/S5 PASS.

## 8. Ponto exato de retomada

> **Fase 3 — iniciar Caso Real N3 experimental.**

Ordem:

1. escolher pergunta decisória adequada a N3;
2. justificar N3 versus N1/N2/N4;
3. definir protocolo e rapid restrictions;
4. executar busca reproduzível;
5. seleção/appraisal/síntese/certainty;
6. registrar quality controls disponíveis;
7. manter missing qualified controls explícitos;
8. validar como experimental/non-publishable.

**Fim do CP35**