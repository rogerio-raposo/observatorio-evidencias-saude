# OES — Continuidade CP177

**Data:** 2026-10-20 (America/Recife)  
**Checkpoint:** CP177  
**Anterior:** CP176  
**HEAD de entrada:** `1bed3de41ebc9dd5a670e867d38bc3c2e6825669`  
**Modo:** alto  
**Estado:** PostgreSQL 18 descartável testado com credenciais LOGIN, separação SET/INHERIT e simulação de recibos fora da transação, 41/41 PASS, nenhum acesso Neon.

## 1. Freshness Gate e autorização

Ponteiro apontava CP176, handoff/Documento 132 consultados. Comparação HEAD CP176 vs main = `identical`, ahead=0 e behind=0. A autorização genérica `Prossiga` limita-se a ensaio CI sintético, documentação e pausa por checkpoint; não abrange Neon, custos, Fase 5 ou reativação B1R1.

## 2. Entregas

**Documento 133:** `docs/governance/133-ensaio-pg18-login-set-role-e-recibos-fora-transacao.md`.

Arquivos técnicos:
- `scripts/oes_f4_pg18_login_roles_external_receipt_sim.py`: harness com destino PostgreSQL 18 local estritamente allowlisted; instala 001–036 em CI, cria três identidades LOGIN artificiais e uma role proprietária NOLOGIN, prova diferenças `SET TRUE/FALSE`/`INHERIT FALSE`, reconfigura propriedade **somente em CI** da tabela real de teste `maintenance.temporal_observation_epoch` com trigger 034, testa negativas e elevação.
- `.github/workflows/f4-pg18-login-and-audit-receipts-synthetic.yml`: workflow descartável com `contents: read`, sem segredos Neon, artifact em sucesso/falha e push automático apenas em arquivos próprios.

Recibos JSONL em filesystem do **próprio runner**, independente **apenas** da transação PostgreSQL, não de administrador, máquina ou pipeline CI. Incluem quatro pares de tentativa/resultado, hash chain SHA-256 e anchor no mesmo filesystem. Cinco negativos confirmam que o verificador detecta adulteração, exclusão, truncamento, reordenação ou troca isolada do hash final.

## 3. Execuções e validação

Primeira execução `39404590522`, commit `158459f7ce5b47c160196e4c1fa314e88a9164ae`, job `118567331868` = `completed/failure`: role proprietária artificial não possuía `USAGE` no schema `maintenance`, bloqueando prova de DDL sob `SET ROLE`. Negativas de runtime/migrator já haviam passado. Problema de configuração do fixture, não falha na migration.

Execução corrigida `39404695131`, job `118567684999`, commit fixado `39ad812f55fd7b79c70f80766f0a85c3e9ea713c`, **`completed/success`**, **41/41 PASS**, marcador `PG18_LOGIN_AUDIT_RECEIPTS_SYNTHETIC_LIMITED_PASS`.

Artifact `f4-pg18-login-audit-receipts-cp177`, ID `12256624023`, ZIP recuperado, 9 arquivos, `testzip()=None`, SHA-256 **`e40f13a2254d9e8d41e14b87b3c758f6e2f1a0200e1f35a3d96d6aee240c014f`** igual ao digest GitHub. `checks.tsv` tem 41 PASS. `audit-anchor.json` count=8, hash terminal `55059ec277bd3bc1f88f014f27e241f85bd0bae761cb83a2261a96f595d432ae`. `result.json`: `external_persistent_collector_configured=false`, `audit_file_independent_of_ci_runner=false`, `audit_immutability_proven=false`, `unknown_direct_admin_sql_covered=false`, `neon_accessed=false`.

## 4. O que a prova significa

- Roles `LOGIN` distintas autenticaram; role `NOLOGIN` não autenticou. Runtime não tinha membership e foi bloqueado por `SET ROLE` e `DISABLE TRIGGER`.
- Migrator tinha membership com `INHERIT FALSE/SET FALSE`, mas não recebeu privilégios proprietários e não conseguiu assumir owner nem desabilitar guard 034.
- Executor elevado, com `INHERIT FALSE/SET TRUE`, **não** desabilitava guard antes de `SET ROLE`; após assumir owner por `SET ROLE`, pôde desabilitar e reabilitar trigger 034 no banco descartável.
- `ROLLBACK` restaurou guard, mas tentativas/resultado continuaram nos arquivos externos à **transação**.
- A integridade dos recibos é apenas local ao runner e ao anchor; não há garantia externa, captura automática de SQL direto, imutabilidade nem verificação de delegação `ADMIN FALSE`/membership transitivo. Esses itens são pendências.

## 5. Gates e invariantes

- `BRG_03 = PG18_SYNTHETIC_LOGIN_MEMBERSHIP_TESTED_NEON_AND_EXTERNAL_AUDIT_NOT_VERIFIED`
- `BRG_04 = HISTORICAL_STATIC_INVENTORY_PINNED_COMMIT_ONLY`
- `BRG_05 = HISTORICAL_PG18_SCHEMA_SYNTHETIC_PINNED_COMMITS`
- `BRG_06 = LEDGER_SYNTHETIC_ONLY_NOT_OPERATIONAL`
- `BRG_07 = SUPERVISOR_SYNTHETIC_ONLY_NOT_OPERATIONAL`
- `BRG_08 = INDEPENDENT_BACKUP_RESTORE_NOT_CONFIGURED`
- `BRG_09 = OWNER_BILLING_CONSOLE_PENDING`
- `POSTCONDITION_CATALOG = 36_UNREVIEWED_ZERO_APPROVED_AUTO_FLAGS_FALSE`
- `MATRIX_034_036 = 36_UNCOLLECTED_EVIDENCE_ITEMS`
- `ROLE_AUDIT_TARGET = 6_ROLES_12_CONTROLS_NOT_SATISFIED`
- `SIMULATED_OUTSIDE_DB_RECEIPTS = 8_EVENTS_NOT_INDEPENDENT_OR_IMMUTABLE`
- `EXTERNAL_DDL_AUDIT = NOT_CONFIGURED`
- `PAID_SERVICES = NOT_APPROVED`
- `NEON_TEST_BRANCH = NOT_CREATED`
- `NEON_SCHEMA_MIGRATION = NOT_STARTED`
- `B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED`
- `PHASE_5 = NOT_STARTED`

## 6. Ponto de retomada

Somente após novo `Prossiga`, reexecutar Freshness Gate CP177. Próximo ensaio recomendado: `ADMIN FALSE`/delegação de role e cadeias transitivas de `SET/INHERIT` em PostgreSQL 18 descartável; testar recibos com falha de controlador, comando fora do wrapper, adulteração simultânea de anchor e JSONL. **Não equiparar hash chain no runner a auditoria independente real.** Revisão humana PostgreSQL/segurança e confirmação de custo precedem qualquer operação Neon.

**STOP — pausa obrigatória após reconciliar ponteiro, STATE e CHANGELOG.**

**Fim CP177.**