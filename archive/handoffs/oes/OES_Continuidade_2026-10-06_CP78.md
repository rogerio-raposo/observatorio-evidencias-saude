# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP78  
**Checkpoint anterior:** CP77  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação do hardening de Projection Readiness do Monitor de Evidências

## 1. Marco

> **PROJECTION_HARDENING_SPEC_READY.**

Documento:

`docs/products/170-monitor-hardening-projection-readiness.md`

## 2. Decisões

Migration 022 será aditiva e não criará View.

Adicionar:

- `maintenance.candidate_impact`;
- `maintenance.monitor_source_requirement`.

Hardening:

- múltiplas impact categories estruturadas;
- primary impact compatível com campo legado;
- requisitos de fonte normalizados;
- exceções de fonte por MethodDecision;
- distinção fulfilled × exception_applied;
- temporal consistency de cycle/Search;
- detecção dinâmica de Search drift;
- avaliação de todos os completed cycles;
- CycleCurrencyState imutável;
- publishability endurecida pela nova camada de issues.

## 3. Limites

Migration 022 não poderá:

- criar EvidenceMonitorView;
- criar template;
- criar Alert;
- definir thresholds/cadências globais;
- iniciar Fase 4.

EvidenceMonitorView permanece candidata à migration 023.

## 4. Próxima etapa

> **Implementar migration 022 + atualizar fixture + executar MONH-T01–T24 + regressões/rebuild.**

Após PASS técnico:

> **reexecutar Projection Readiness Gate.**

**Fim do CP78**
