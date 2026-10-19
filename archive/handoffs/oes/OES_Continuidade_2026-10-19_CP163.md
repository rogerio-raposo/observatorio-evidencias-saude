# OES — Continuidade CP163

**Data:** 2026-10-19  
**Anterior:** CP162  
**HEAD entrada:** `55b8e07558b4c7fabf0d556309177575cd48020f`  
**Status:** primeira prova PostgreSQL 18 sintética de instalação completa 36/36, no commit do run; nenhuma mutação Neon.

## Diagnóstico e evidência

Freshness Gate CP162/main = identical, ahead=0, no início. Pela integração GitHub `fetch` na coleção REST `/repos/rogerio-raposo/observatorio-evidencias-saude/actions/runs` (URL sem query), o run automático **39261597847** foi localizado; esta rota de leitura resolve a dificuldade de descoberta presente nos CP159/162. Job `118090362879`: `completed/success`.

**Documento 119:** `docs/governance/119-resultado-ensaio-pg18-ci-run-39261597847.md`.

Run em `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`; contêiner PostgreSQL 18.6; cliente psql 16.15. O log e artifact ID `12190502582` exibem 36/36 migrations PASS, pré-gate 36+14, digest de inventário `228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6`; 275 funções nos schemas selecionados, 2 epochs estruturais. Sem fixture científica. Notar que `sql_executed=false` no JSON pertence apenas ao verificador estático; 36 arquivos SQL foram efetivamente executados no banco descartável da CI.

## Gates

- `BRG_04 = STATIC_VERIFIED_PINNED_COMMIT`
- `BRG_05 = PG18_SCHEMA_SEQUENTIAL_INSTALL_VERIFIED_PINNED_COMMIT_ONLY`
- `BRG_06 = LEDGER_NOT_IMPLEMENTED`
- `BRG_07 = CI_RUNNER_BASIC_SEQUENCE_VERIFIED_NOT_OPERATIONAL`
- `BRG_03 = NEON_ACL_TLS_NOT_VERIFIED`
- `BRG_08 = INDEPENDENT_BACKUP_NOT_CONFIGURED`
- `BRG_09 = OWNER_BILLING_CONSOLE_PENDING`
- `NEON_TEST_BRANCH = NOT_CREATED`
- `NEON_SCHEMA_MIGRATION = NOT_STARTED`
- `B1R1 = EXPIRED_NOT_EXECUTED`
- `PHASE_5 = NOT_STARTED`

## Próxima atividade e pausa

Após `Prossiga`, elaborar ensaio sintético de ledger, exclusividade/locks, estados de commit incerto e recuperação em PostgreSQL 18 descartável; em **modo alto** para aprovação da política de atomicidade/segurança. Não criar branch nem executar migrations Neon sem autorização separada.

**STOP — pausa obrigatória após reconciliar ponteiro, STATE e CHANGELOG.**

**Fim do CP163.**