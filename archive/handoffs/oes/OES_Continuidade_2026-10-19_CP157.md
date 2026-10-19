# OES — Continuidade CP157

**Data:** 2026-10-19  
**Checkpoint:** CP157  
**Anterior:** CP156  
**HEAD de entrada (Freshness Gate):** `cd7855c1fa366716569e35acbd5f81337b866caa`  
**HEAD técnico após Documento 113:** `b0dda1efe6fbe98496dbde0beed382ced7aa568c`  
**Status:** Pré-gate offline preparado e testado unitariamente com dados sintéticos; contrato lógico de ledger proposto; nenhum write Neon.

## Base confirmada

O template de continuidade e o ponteiro indicaram CP156. Freshness Gate GitHub `cd7855c1fa366716569e35acbd5f81337b866caa...main` = identical, ahead/behind = 0. CP156 e Documento 112 consultados. Nenhuma decisão anterior foi substituída.

## Novo marco

**Documento 113:** `docs/governance/113-pre-gate-psql-ledger-e-cotas-neon-sintetico.md`.

Arquivos versionados:
- `scripts/oes_neon_migration_preflight.py` — preflight offline, sem conexão/SQL, exigência de HEAD, inventário S5/manifest 36 e 14 includes, SHA-256 de bytes e saída JSON, fail-closed.
- `tests/test_oes_neon_migration_preflight.py` — 7 testes unitários exclusivamente sintéticos.

Evidência local: Python 3.13.5; `unittest` = **7/7 OK**; execução de CLI sem HEAD = BLOCKED, exit 2, sem acesso Neon. Git blob SHA verificado do código publicado contra os bytes testados localmente. Não existe execução em checkout completo do repositório, nem hash SHA-256 dos 50 SQL reais gerado, nem ensaio com `psql`/PostgreSQL 18, nem execução GitHub Actions para estes testes. O ambiente local não disponibilizou executável `psql`.

**Ledger técnico:** desenho lógico proposto, não aprovado/implantado; inclui identidades, SHA-256 entrypoint + fragmentos, tentativas append-only, controles de transação, evidência e estado `uncertain_requires_reconciliation`. Runner SQL/migration não implementado. Sem alegar atomicidade entre SQL e recibo do ledger nem admitir reexecução automática após falha incerta.

**Neon read-only:** `oes-sandbox`, `aws-sa-east-1`, subscription `free_v3`, limite de 10 branches e uma branch default `production`; projeto logical quota 1 GiB, compute consultado `idle`. Fonte oficial Neon de 2026-10-02 confirma Free publicado, 100 CU-h por projeto/mês e 10 branches. Consumo/billing específico e disponibilidade no instante de futura criação ainda não conferidos no console do owner. **Nenhuma branch criada.**

Correção de notação textual `\\ir` versus diretiva efetiva `\ir` registrada prospectivamente no Documento 113, sem alterar snapshots antigos.

## Gates e limites

> **F4_NEON_STATIC_PREFLIGHT_CODE = COMMITTED**  
> **F4_NEON_STATIC_UNIT_TESTS = 7_OF_7_OK_LOCAL_SYNTHETIC_ONLY**  
> **F4_NEON_STATIC_ACTUAL_REPO_HASHES = NOT_GENERATED**  
> **F4_NEON_PSQL_RUNNER = NOT_IMPLEMENTED**  
> **F4_NEON_LEDGER = PROPOSED_NOT_CREATED**  
> **NEON_FREE_PLAN = FREE_V3_API_OBSERVED**  
> **BRG_09 = PARTIAL_READONLY_OWNER_CONSOLE_PENDING**  
> **BRANCH_AUTHORIZATION = PREPARED_NOT_APPROVED**  
> **NEON_TEST_BRANCH = NOT_CREATED**  
> **NEON_SCHEMA_MIGRATION = NOT_STARTED**  
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**  
> **OPERATIONAL_DATABASE_READY = NO**  
> **B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED**  
> **PHASE_5 = NOT_STARTED**

NÃO autorizar por mera continuidade: branch, role, DDL/DML Neon, ledger, migration, cobrança, consultas científicas factuais, retificação B1R1, novo Epoch ou Fase 5.

## Ponto exato de retomada

Após novo `Prossiga`, preparar a execução **apenas offline/local/CI** do inventário contra checkout GitHub integral imutável e do harness de ledger/runner sintético PostgreSQL 18, com prova de versão do psql, hashes de todos os 50 SQL e avaliação das falhas/locks. Se isso não estiver tecnicamente disponível, registrar bloqueio sem declarar PASS. Verificação de billing/consumo no painel titular continua necessária antes de qualquer proposta efetiva de branch; aprovação específica deve ser separada da autorização de migrations.

**Modo:** médio para desenvolvimento de teste sintético e alto para fechar política de ledger/privilégios/custos/decisão operacional.

**Ponteiro:** `archive/handoffs/oes/README.md`.

**STOP — aguardar explicitamente `Prossiga`.**

**Fim do CP157.**
