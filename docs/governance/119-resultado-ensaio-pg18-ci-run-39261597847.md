# 119 — Evidência de ensaio PostgreSQL 18 sintético — GitHub Actions 39261597847

**OES | Fase 4 | 2026-10-19 | modo médio**  
**Estado:** PG18_SYNTHETIC_SEQUENTIAL_SCHEMA_INSTALL_PASS_PINNED_COMMIT_ONLY — NO_NEON_MUTATION.  
**Entrada:** CP162 / Documento 118 / HEAD `55b8e07558b4c7fabf0d556309177575cd48020f`. Freshness Gate na entrada = identical.

## Execução

GitHub Actions https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39261597847, criado em 2026-10-19 13:36:26Z por push da mudança no próprio workflow. HEAD efetivamente ensaiado: `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`.

Job `pg18-schema-rehearsal` ID `118090362879`: completed/success. Etapas de checkout, ambiente, preflight, aplicação de migrations, inspeção e artifact foram success. Log de sequência evidencia `PASS` para as 36 entradas `database/poc-s1.sql` a `database/036_temporal_first_measurement_semantics.sql`. 14 fragments foram conferidos e incluídos por wrappers; não são 14 migrations independentes.

Artifact `f4-pg18-schema-rehearsal` ID `12190502582`; GitHub reportou ZIP SHA-256 `a27d4f5652fb676069a5290187ac0d8bf3596dc7c83fc21d20f3691ab6505bfc`. Download e inspeção de ZIP confirmaram 46 entradas e `sequence.log` com 36 PASS.

## Versões, hashes e objetos

- Servidor: PostgreSQL **18.6**, `server_version_num=180006`.
- Cliente: `psql` **16.15**. Compatibilidade demonstrada no cenário; não se afirma uso do cliente 18.
- Commit CI: `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`.
- Verificação estática: 36 entrypoints e 14 fragments, digest `228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6`, mesmo hash obtido no run offline do Documento 116.
- `maintenance.contract_epoch`: **2** registros estruturais (não científicos).
- Funções nos schemas selecionados pela consulta CI: **275**.
- Tabelas contadas por schema: `appraisal=6; artifact=2; core=2; evidence=18; investigation=12; maintenance=74; mapping=7; overview=7; product=9; provenance=2; synthesis=10`.
- Sem fixtures nem dados científicos; `inventory.json.sql_executed=false` descreve só preflight estático, e não a aplicação SQL comprovada em logs separados.

## Interpretação dos gates

**BRG-05 = PG18_SCHEMA_SEQUENTIAL_INSTALL_VERIFIED_PINNED_COMMIT_ONLY**. **BRG-07 = CI_RUNNER_BASIC_EXECUTION_VERIFIED_ONLY** (sequência, logs, fail-stop contratual), **NÃO** prova de runner operacional com transações/ledger. BRG-06 ledger, proteção contra repetição, atomicidade e recuperação permanecem PENDING. BRG-03 ACL/segredos/TLS no Neon e BRG-08 backup/restore NÃO comprovados. BRG-09 billing de owner pendente.

A senha definida na job é artificial; o contêiner PG18 descarta dados ao finalizar. A prova não contempla banco Neon, role de privilégio mínimo, migração de dados reais, falha intermediária, reparo do trigger 034, lock concorrente ou reexecução.

Nenhum CREATE BRANCH, SQL, migration, role ou ledger Neon. `B1R1 = EXPIRED_NOT_EXECUTED`, `PHASE_5 = NOT_STARTED`.

## Continuidade

Projetar e testar mecanismo de ledger transacional, registro externo de tentativas, lock de execução e falhas controladas **somente em PostgreSQL descartável**. Recomenda-se modo alto para fechar decisões de atomicidade e recovery. Não elevar o ambiente OES a operacional.

**Fim do Documento 119.**