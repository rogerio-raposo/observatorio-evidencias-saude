# 37 — Resultado da Validação Técnica de Propagation/Re-baselining

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **TECHNICALLY_VALIDATED**  
**Dependências:** Documentos 33–36; migrations 021–031

## Resultado

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_031 = PASS**

> **F4_PRB_T01_T145 = PASS**

> **MIGRATION_031_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_031 = PASS**

> **GLOBAL_REGRESSIONS_AFTER_031 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

## Implementação validada

Migration lógica:

`database/031_propagation_rebaseline_contract.sql`

Fragmentos internos:

- `031a_propagation_core.sql`;
- `031b_propagation_signal_adapter.sql`;
- `031c_rebaseline_core.sql`;
- `031d_propagation_rebaseline_helpers.sql`;
- `031e_rebaseline_child_validators.sql`.

A fragmentação é apenas empacotamento técnico; os fragmentos são carregados pela migration 031 dentro da mesma transação.

Fixtures:

`database/f4-propagation-rebaseline-fixtures.sql`

Testes:

`database/f4-propagation-rebaseline-tests.sql`

## Evidência canônica

Workflow: **OES PoC-S5 PostgreSQL Validation**

- run ID: **37644296649**;
- run number: **#167**;
- technical HEAD: `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- job: `postgres-s5`;
- job ID: **112870931087**;
- run conclusion: **success**;
- job conclusion: **success**;
- artifact ID: **11494595216**;
- artifact: `oes-s5-evidence-37644296649`;
- size: **242298 bytes**;
- digest: `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`.

O log canônico registra:

- F4-PRB-T01–T145 PASS;
- migration 031 idempotency PASS;
- rebuild-from-zero through migration 031 PASS;
- complete regressions after migration 031 PASS;
- M3 blocker preserved.

## Invariantes confirmados

- target classification maintainable/nonmaintainable;
- Monitor/Alert/evidence_monitoring não são maintainable target;
- authoritative AI propagation/rebaseline rejeitado;
- no-action bloqueado por lineage/path incompleto;
- path snapshots imutáveis;
- PropagationCandidate → UpdateSignalSource exige exact target;
- signal causal type é preservado;
- rebaseline exige versões posteriores da mesma entidade;
- version chain segue `supersedes_version_uuid`;
- authoritative activation única por old target;
- child handover validators preservam policy/Monitor/profile/coverage/SLA/signal/workflow targets;
- target supersession não invalida UpdateSignal;
- SLA cross-policy não usa supersession FK;
- first breach permanece preservado;
- currentness não é alterado automaticamente;
- M3 permanece bloqueado.

## Runs diagnósticas

Runs #163–#166 foram intermediárias durante correções locais de fixtures/wiring e não são evidência de PASS.

A evidência canônica é exclusivamente o run #167 no HEAD final validado.

## Limites preservados

A migration 031 não implementa numeric SLA/cadence, scheduler, notifications, auto-escalation, auto-propagation, auto-rebaseline, automatic policy/Monitor/signal creation, automatic currentness write, assurance promotion, publication automation, revisão humana fabricada ou backfill histórico fabricado.

## Decisão

> **PHASE_4_PROPAGATION_REBASELINE_BLOCK = CLOSED_PASS**

## Próximo passo exato

> **Criar checkpoint técnico pós-PASS; depois selecionar explicitamente a próxima dívida aberta da Fase 4, sem iniciar M3, scheduler, notifications, numeric SLA/cadence ou Fase 5 por inferência.**
