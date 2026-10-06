# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP42  
**Checkpoint anterior:** CP41  
**Status:** artefato de continuidade; não normativo  
**Escopo:** contrato de renderização do Mapa de Evidências e Projection Readiness Gate  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP41 criado no commit `b65d55478db4eebb7d319772aab4fafd4fc67cf5`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP41: `ahead`;
- commits à frente: **7**;
- commits atrás: **0**.

Avanço material:

- Documento 127 — EvidenceMapView: Contrato de Renderização;
- atualização de STATE, CHANGELOG e índice de produtos;
- identificação de Projection Readiness Gap antes do template.

## 2. Marco do CP42

> **Contrato de renderização do Mapa de Evidências definido.**

Entretanto:

> **Projection Readiness Gate = NOT_READY para template.**

A causa não é falha do contrato de dados validado no Documento 126.

A causa é que a `EvidenceMapView 0.1` ainda não projeta explicitamente todos os elementos necessários à apresentação segura e auditável.

## 3. Extensões aditivas requeridas

Antes do template, a view deve passar a expor:

1. `audit.synthetic_fixture`;
2. `conclusion.text`;
3. metadados de protocolo;
4. metadados de codebook;
5. reviewer assignments;
6. method controls de search/screening/classification;
7. lineage;
8. `audit.lineage_available`;
9. `audit.invalidated_dependencies`;
10. referências alcançáveis por Study MapItems via Study–Report linkage.

## 4. Regra arquitetural

> **Não reabrir `database/016_evidence_map_contract.sql`.**

As mudanças deverão ser implementadas em migration de projeção aditiva subsequente.

Como os campos existentes da view não terão semântica alterada, o schema poderá permanecer:

`oes.evidence_map_view/0.1`

salvo descoberta posterior de mudança incompatível.

## 5. Regras de renderização consolidadas

- density != effect;
- density != certainty;
- concentration != better evidence;
- formal gap != universal absence of evidence;
- apparent gap deve carregar disclosure de cobertura;
- `not_applicable` e `excluded_by_framework` nunca são gaps;
- counting unit deve ficar visível;
- renderer não recalcula cells/counts/gaps;
- candidate assignment não alimenta célula final;
- IA não recebe aparência de human verification;
- A3 não substitui publication gate;
- conclusão deve ser canônica e não gerada a partir de counts;
- gap não vira research priority automaticamente.

## 6. Ponto exato de retomada

> **Implementar migration aditiva da EvidenceMapView 0.1, testes da projeção ampliada e rebuild; obter Projection Readiness Gate = READY antes de especificar o template operacional.**

## 7. Sequência seguinte

1. migration aditiva de projeção;
2. testes positivos/adversariais da view ampliada;
3. rebuild/regressões;
4. Projection Readiness Gate = READY;
5. especificação do template operacional;
6. template/presentation map/renderer/validator;
7. validação adversarial da apresentação;
8. readiness para eventual Caso Real.

**Fim do CP42**
