# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP77  
**Checkpoint anterior:** CP76  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Projection Readiness Gate do Monitor de Evidências

## 1. Marco

> **EVIDENCE_MONITOR_PROJECTION_READINESS = NOT_READY.**

Documento:

`docs/products/169-monitor-projection-readiness-gate.md`

## 2. Estado técnico preservado

O contrato técnico permanece validado:

- migration 021 = PASS;
- MON-T01–T33 = PASS;
- rebuild through migration 021 = PASS;
- run final 37553271462 (#122) = success.

O NOT_READY não invalida a migration 021.

Ele indica que a semântica persistida ainda não é suficiente para uma View read-only integral sem risco de perda/interpretação excessiva.

## 3. Blockers de Projection Readiness

### PR-MON-01 — impactos múltiplos

Documento 165 permite que uma evidência ocupe mais de uma categoria de impacto.

`candidate_assessment.impact_class` é singular e `impact_payload` livre não garante cardinalidade completa.

### PR-MON-02 — source policy parcialmente interpretada

O engine atual avalia somente parte dos requisitos que a policy pode declarar.

Uma View não pode afirmar coverage completa se requisitos persistidos forem desconhecidos/não avaliados.

### PR-MON-03 — exceções de cobertura

Documento 167 permite exceção MethodDecision ativa/justificada para requisito de fonte.

O helper atual não integra essa semântica.

### PR-MON-04 — temporal consistency

Ainda faltam checks determinísticos de:

- Search.executed_at versus cycle;
- window anterior ao baseline;
- gaps entre cycles sem justificativa;
- drift posterior da Search vinculada;
- decomposição auditável dos temporal issues.

### PR-MON-05 — Cycle → CurrencyState

O vínculo histórico pode ser atualizado para outra CurrencyState compatível.

Deverá tornar-se imutável.

## 4. Decisão de migrations

Migration 022:

> **Projection Readiness hardening**

Não implementará View.

A EvidenceMonitorView passa a ser candidata para:

> **migration 023**

somente após novo Projection Readiness Gate = READY.

## 5. Limites

Não:

- iniciar Fase 4;
- criar thresholds transversais;
- criar Alert;
- criar template;
- abrir Caso Real do Monitor;
- enfraquecer a migration 021 para obter READY artificial.

## 6. Ponto exato de retomada

> **Especificar e implementar o hardening da migration 022.**

O hardening deverá resolver impactos múltiplos, source requirements/exceptions, temporal consistency/Search drift e imutabilidade de CycleCurrencyState, com testes próprios e regressões MON-T01–T33.

Depois:

> **reexecutar Projection Readiness Gate.**

**Fim do CP77**
