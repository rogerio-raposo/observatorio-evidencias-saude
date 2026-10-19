# OES — Continuidade CP164

**Data:** 2026-10-19  
**Checkpoint:** CP164  
**Anterior:** CP163  
**HEAD de entrada (Freshness Gate):** `4a2d9d2e60c2b86ca789944dd69a343c8fb4ee01`  
**Status:** ensaio de controles de ledger e advisory lock PG18 sintético concluído com sucesso delimitado; nenhuma operação Neon.

## Diagnóstico de continuidade

Comparação de `main` ao HEAD CP163 na entrada = `identical`, 0 drift. README/pointer, CP163, política de migrações 30 e Documento 113 consultados.

## Marco concluído

**Documento 120:** `docs/governance/120-ensaio-ledger-falhas-locks-pg18-sintetico.md`.

Arquivos:
- `tests/fixtures/f4-ledger-synthetic/bootstrap.sql`: **fixture** de event ledger com trigger append-only e guarda fail-closed. Não é `ops.schema_migration` definitivo.
- `scripts/oes_pg18_ledger_synthetic_test.sh`: rollback, recibo, falha após commit, drift, retry, locks; bloqueia destino fora de PG18 local descartável.
- `.github/workflows/f4-pg18-ledger-synthetic.yml`: CI PG18 descartável, `contents: read`, push apenas nas próprias paths, sem Neon.

**Run CI verificado:** `39263916981`, job `118098438290`, `completed/success`, commit `2acabe21102774bae5ce86d15858dc434e905bf5`, PostgreSQL 18.6 / psql 16.15. **17/17** verificações de harness PASS. Artifact `12191953694`, ZIP SHA-256 `6eefdb6ed5986330b05cc03cda2e53abff8a3ca46a17fea12fbe475ddc81622f` conferido; 18 arquivos do ZIP, log e checks examinados.

## Interpretação

A prova sustenta dois caminhos de **desenho provisório**: (T) transação única com recibo atomicamente incluído quando o SQL comporta; (L) migrations com commits independentes, onde intenção prévia persistente e estado incerto exigem bloqueio de replay e reconciliação. O teste de advisory lock entre sessões prova apenas primitiva, **não lock contínuo por toda a sequência de subprocessos psql**. Não houve kill do executor nem teste de recovery de sistema operacional real. A política canônica de migrations 30 não foi alterada.

## Invariantes

> **BRG_04 = STATIC_CI_VERIFIED_PINNED_COMMIT_ONLY**  
> **BRG_05 = PG18_SEQUENTIAL_SCHEMA_INSTALL_VERIFIED_PINNED_COMMIT_ONLY**  
> **BRG_06 = SYNTHETIC_FAILURE_MODEL_PASS_LEDGER_NOT_OPERATIONAL**  
> **BRG_07 = SYNTHETIC_LOCK_PRIMITIVE_PASS_RUNNER_NOT_OPERATIONAL**  
> **BRG_03 = PRIVILEGES_TLS_NOT_VERIFIED**  
> **BRG_08 = INDEPENDENT_BACKUP_NOT_CONFIGURED**  
> **BRG_09 = BILLING_OWNER_CONSOLE_PENDING**  
> **BRANCH_AUTHORIZATION = PREPARED_NOT_APPROVED**  
> **NEON_TEST_BRANCH = NOT_CREATED**  
> **NEON_SCHEMA_MIGRATION = NOT_STARTED**  
> **B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED**  
> **PHASE_5 = NOT_STARTED**

## Ponto exato de retomada

Após novo `Prossiga`: especificar guardião de sessão/lock contínuo, riscos de concorrência/race e reconciliação por pós-condição; se possível, testar em PG18 sintético CI com *fault injection* e prova de exclusão durante subprocessos. Não confundir modelo de testes com ledger implantável. Se surgir decisão de arquitetura normativa, custos, segurança ou autorização operacional, manter modo **alto**. Nenhuma ação Neon por `Prossiga` genérico.

**STOP — pausa obrigatória após reconciliação de CP164, STATE, CHANGELOG e ponteiro.**

**Fim do CP164.**