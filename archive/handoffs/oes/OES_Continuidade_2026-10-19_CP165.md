# OES — Continuidade CP165

**Data:** 2026-10-19  
**Checkpoint:** CP165  
**Anterior:** CP164  
**HEAD de entrada (Freshness Gate):** `2ad4da0fbd725273ed253d88fd3ccc29ed2a2ff8`  
**Status:** guardião de lock sintético testado com falhas documentadas, correção validada e contraprova de SQL em voo; nenhuma mutação Neon.

## Diagnóstico de continuidade
Ponteiro/CP164 conferidos; HEAD CP164/main = `identical`, zero drift na entrada. Documento 120 e arquivo fixture sintético consultados. Modo alto.

## Artefatos e provas
**Documento 121:** `docs/governance/121-guardiao-lock-persistente-pg18-e-contraprova-crash.md`.

- `scripts/oes_pg18_guardian_synthetic_test.py`: harness sintético de guardião psql com sessão ociosa, subprocessos independentes, concorrente, kill do guardião, intenção durável, bloqueio de replay e verificação da SQL em voo; restrito ao PostgreSQL 18 descartável da CI.
- `.github/workflows/f4-pg18-guardian-synthetic.yml`: execução automática apenas para paths do ensaio, PG18 descartável, sem Neon.
- Run **39266423818** `failure`: lock não liberado imediatamente após matar cliente com query ativa `pg_sleep(60)`; achado de segurança preservado.
- Run **39266711331** `failure`: enquadramento de newline do comando de stdin incorreto, lock não adquirido; corrigido prospectivamente.
- Run **39266780706** `success`, commit `064d970ddbc1e4a4830a44472074eaec5734698b`, job `118108308578`, PG18.6/psql16.15; **15/15 checks PASS**.
- Artifact `12193207877` baixado, SHA256 do ZIP `867f2189872cbdd3accf12851f6d4d1843a63bbea7b1a5bf4e7f7c62a39f6175` comprovado; `checks.tsv`, `result.txt`, `commit.txt` e versão verificados.

## Interpretação
Lock de conexão **ociosa** permanece durante dois subprocessos em sequência, e é liberado após morte da conexão. Contraprova: subprocesso SQL já iniciado **pode continuar e commitar após a perda do guardião**. Intenção `prepared` deve persistir e bloquear replay; nova sessão que adquira lock continua impedida pelo ledger de teste. Essa combinação NÃO representa um runner operacional seguro ou garantia de atomicidade das migrations legadas, apenas evidência do modelo de falhas.

## Estados
- `BRG_04 = STATIC_CI_VERIFIED_PINNED_COMMIT_ONLY`
- `BRG_05 = PG18_SEQUENTIAL_SCHEMA_INSTALL_VERIFIED_PINNED_COMMIT_ONLY`
- `BRG_06 = LEDGER_SYNTHETIC_MODEL_TESTED_OPERATIONAL_LEDGER_NOT_CREATED`
- `BRG_07 = GUARDIAN_SYNTHETIC_PASS_WITH_CRITICAL_NEGATIVE_CONTROL_RUNNER_NOT_OPERATIONAL`
- `BRG_03 = ACL_TLS_SECRETS_NOT_VERIFIED`
- `BRG_08 = INDEPENDENT_BACKUP_NOT_CONFIGURED`
- `BRG_09 = OWNER_BILLING_CONSOLE_PENDING`
- `BRANCH_AUTHORIZATION = PREPARED_NOT_APPROVED`
- `NEON_TEST_BRANCH = NOT_CREATED`
- `NEON_SCHEMA_MIGRATION = NOT_STARTED`
- `B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED`
- `PHASE_5 = NOT_STARTED`

## Ponto exato de retomada
Após novo `Prossiga`, propor e testar em PG18 **somente sintético** um supervisor que monitore a vida do guardião, impeça novos processos após perda e trate subprocessos em voo; introduzir catálogo de pós-condições e reconciliação segura de receipts, além de concorrência real entre controladores. Em modo **alto** por envolver atomicidade e risco de execução parcial. Regras de governança exigem autorização separada antes de qualquer write Neon. Não considerar `prepared` como prova de não aplicação, nem o lock sozinho como garantia de integridade.

**STOP — pausa obrigatória após publicação do CP165 e reconciliação canônica.**

**Fim do CP165.**