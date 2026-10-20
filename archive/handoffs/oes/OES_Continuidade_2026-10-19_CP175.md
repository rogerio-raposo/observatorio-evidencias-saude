# OES — Continuidade CP175

**Data:** 2026-10-19 (America/Recife)  
**Checkpoint vigente:** CP175  
**Anterior:** CP174  
**Freshness HEAD de entrada:** `8c8a54937f9ef1a697c309d4e7876dd473ff8a8c`  
**Modo:** alto  
**Estado:** prova PG18 sintética de segregação de roles e DDL event trigger concluída, 38/38 PASS, com riscos de auditoria internos explicitados; Neon intocado.

## 1. Diagnóstico de continuidade

Freshness Gate CP174/`main` = `identical`, 0 ahead/behind. README/ponteiro, CP174, política canônica 30, Documento 130 e catálogo principal das 36 migrations lidos. Catálogo 36/36 `UNREVIEWED`, zero pós-condições e zero habilitações de replay, reconciliação ou migrations. Autorização limitada a ensaios sintéticos PG18 na CI e gravação de documentação GitHub, **não** operações Neon.

## 2. Artefatos

**Documento 131:** `docs/governance/131-ensaio-pg18-segregacao-roles-e-auditoria-ddl-transacional.md`.

- `scripts/oes_f4_pg18_acl_ddl_audit_synthetic.py`: instala 001–036 **somente** em DB PG18 descartável, cria roles artificiais `oes_ci_schema_owner`, `oes_ci_runtime`, `oes_ci_migrator`; permite leitura/gravação limitada, bloqueia criação/alteração/desabilitação de guards para roles restritos, testa administrador e auditoria DDL transacional com event trigger sintético. Não é migrator de produção ou plataforma de observabilidade.
- `.github/workflows/f4-pg18-acl-ddl-audit-synthetic.yml`: GitHub Actions `postgres:18`, `contents: read`, push limitado aos arquivos do ensaio e `workflow_dispatch`, sem segredos/host Neon, artifact em caso de falha.

## 3. Evidências verificadas

- Run inicial **`39358068414`**, SHA `895a8be2945982f6dfd98bf97823f6d0faca908d`, `completed/failure`: teste esperava `f` em conversão de booleano PostgreSQL para texto, que produziu `false`.
- Segundo run **`39358143142`**, SHA `be6b37c960450926e61c19522d019536dbfe58b2`, `completed/failure`: negativas de privilégios passaram; comparação de ausência de tabela usou saída booleana inconsistente. Ambas falhas atribuídas a asserções do harness e corrigidas prospectivamente.
- Run aprovado **`39358223730`**, job `118417944949`, SHA testado `b53897af4e12052c122f5ab1d1c879f1a32c52d1`, `completed/success`, servidor PostgreSQL **18.6**. Logs e `checks.tsv`: **38/38 PASS**.
- Artifact `12236325916`, ZIP baixado/testado, dez arquivos, SHA-256 **`44107e32b45fcf7b4698572d736e38005370348d6465d3bd320c2544ec23a408`** conferido contra digest GitHub. `audit-events.json` contém duas alterações `ALTER TABLE` confirmadas de `maintenance.temporal_observation_epoch` por `session_actor=postgres`. `result.json`: `external_immutable_ddl_audit_configured=false`, `least_privilege_neon_verified=false`, `neon_accessed=false`.

## 4. Resultados e limites

- Roles de teste `NOLOGIN NOSUPERUSER` separadas sem participação na role owner; somente permissões concedidas permitem leitura/inserção no fixture. Runtime/migrator não conseguiram desabilitar triggers 034/036, alterar função 034/035 ou criar tabela proibida no schema maintenance; funções e triggers permaneceram íntegros após tentativas.
- Proprietário da tabela artificial conseguiu DDL em seu objeto; superusuário CI conseguiu desabilitar/reabilitar trigger 034 real no schema **do contêiner descartável**.
- Event trigger interno registrou **dois** DDL confirmados, mas evento de DDL revertido e a respectiva linha de audit foram desfeitos conjuntamente. **Auditoria interna é transacional e não substitui log externo e segregado**, especialmente diante de administradores capazes de alterá-la.
- Esta prova **não** valida privilégio mínimo Neon, configuração TLS, segredo, pgAudit/log externo independente, migrator operacional seguro, backup, custo ou proteção contra qualquer abuso superuser. Nenhum registro científico ou clínico.

## 5. Gates em vigor

- `BRG_04 = HISTORICAL_STATIC_INVENTORY_VERIFIED_PINNED_COMMIT_ONLY`
- `BRG_05 = HISTORICAL_SYNTHETIC_PG18_SCHEMA_BEHAVIOR_PINNED_COMMITS`
- `BRG_06 = SYNTHETIC_LEDGER_ONLY_OPERATIONAL_NOT_IMPLEMENTED`
- `BRG_07 = SYNTHETIC_SUPERVISOR_ONLY_OPERATIONAL_NOT_APPROVED`
- `BRG_03 = PG18_SYNTHETIC_ACL_AND_TRANSACT_DDL_AUDIT_PASS_NEON_UNVERIFIED`
- `BRG_08 = INDEPENDENT_BACKUP_RESTORE_NOT_CONFIGURED`
- `BRG_09 = OWNER_BILLING_CONSOLE_PENDING`
- `POSTCONDITION_CATALOG = 36_UNREVIEWED_0_APPROVED_AUTO_FLAGS_FALSE`
- `MATRIX_034_036 = 36_NOT_COLLECTED_0_APPROVED`
- `BRANCH_AUTHORIZATION = PREPARED_NOT_APPROVED`
- `NEON_TEST_BRANCH = NOT_CREATED`
- `NEON_SCHEMA_MIGRATION = NOT_STARTED`
- `B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED`
- `PHASE_5 = NOT_STARTED`

## 6. Próxima retomada

Após `Prossiga`, confirmar HEAD CP175; elaborar **modelo-alvo offline de roles e auditoria DDL externa** (responsabilidades, concessões mínimas, transições entre owner/migrator/runtime, separação de credenciais e mecanismos de log fora do banco). Priorizar revisão de desenho para incompatibilidades entre propriedade de objetos e capacidade de migrar sem desabilitar guards; se testar, somente PG18 descartável. Nenhuma alteração Neon por `Prossiga` genérico. Em modo alto até validação especializada.

**STOP — pausa obrigatória após reconciliar README, STATE e CHANGELOG.**

**Fim CP175.**