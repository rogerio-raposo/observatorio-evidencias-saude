# 120 — Ensaio sintético de ledger, falhas de commit e locks no PostgreSQL 18

**OES — Fase 4 | 2026-10-19 | modo alto**  
**Status:** **PG18_LEDGER_FAILURE_MODEL_TESTED_WITH_LIMITATIONS — DESIGN_PROVISIONAL — NO_NEON_WRITE**  
**Entrada:** CP163 / Documento 119, HEAD `4a2d9d2e60c2b86ca789944dd69a343c8fb4ee01`.

## 1. Diagnóstico de continuidade e fronteira de autorização

O Freshness Gate de entrada CP163 → `main` retornou `identical` e zero commits de drift; ponteiro/CP163, Documento 113 e política canônica `docs/architecture/30-politica-migracoes.md` foram consultados. Autorização de continuidade permite **somente ensaio sintético em GitHub Actions**, não mudanças Neon, cobrança ou ativação de dados científicos.

Criados os artefatos versionados:
- `tests/fixtures/f4-ledger-synthetic/bootstrap.sql`: *schema* fictício `ops.schema_migration_event` exclusivamente no PG18 descartável, com eventos append-only e guarda contra drift/replay.
- `scripts/oes_pg18_ledger_synthetic_test.sh`: harness com bloqueio explícito se o destino não for host local `127.0.0.1`, porta `5432`, database `oes_f4_ledger_synthetic`, usuário `postgres`; fixtures, falhas esperadas e verificação de locks.
- `.github/workflows/f4-pg18-ledger-synthetic.yml`: CI isolada, somente `contents: read`, PostgreSQL 18 em contêiner efêmero, senha artificial restrita à job, gatilho `push` em `main` apenas para seus próprios artefatos e `workflow_dispatch`. Nenhum destino, segredo ou SQL Neon.

## 2. Prova GitHub Actions

Execução **39263916981**: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39263916981  
Job **118098438290**, `ledger-failure-model`: `completed/success`.  
Commit testado: `2acabe21102774bae5ce86d15858dc434e905bf5`.  
Servidor: PostgreSQL **18.6**; cliente: `psql` **16.15**.

Artifact `f4-pg18-ledger-synthetic-proof`, ID **12191953694**: ZIP obtido, 18 arquivos examináveis; checksum SHA-256 dos bytes do ZIP **`6eefdb6ed5986330b05cc03cda2e53abff8a3ca46a17fea12fbe475ddc81622f`**, igual ao digest informado na API GitHub. `checks.tsv` lista **17 controles PASS**, `result.txt` contém `SYNTHETIC_LEDGER_HARNESS_PASS`; `commit.txt` e versões concordam com o run. Logs registram erros **intencionalmente induzidos e validados como bloqueios esperados**, sem confundi-los com falha do job.

| Grupo | Controles observados | Resultado |
|---|---|---|
| Bootstrap | Estrutura fictícia e guarda PG18 instalados | PASS |
| Rollback | DDL e recibo inserido juntos são desfeitos ao injetar erro; intenção prévia persiste; retry recusado | PASS |
| Transação única | DDL + recibo confirmados na mesma transação; aplicação dupla recusada | PASS |
| Integridade de eventos | UPDATE e DELETE negados pelo trigger append-only | PASS |
| Commit sem recibo | DDL já persistido, recibo ausente, tentativa anterior bloqueia retry | PASS |
| Drift e incerteza | SHA divergente recusado; estado `uncertain_requires_reconciliation` persiste | PASS |
| Exclusão em sessão | `pg_advisory_lock` impede aquisição simultânea por outra sessão e libera ao encerrar | PASS |

## 3. Decisão arquitetural de trabalho — somente protótipo

**Separar dois caminhos de execução** até que um runner operacional os implemente com provas:

**Caminho T — operação transacional compatível:** quando o arquivo não contém `COMMIT` interno e todas as operações aceitam transação, a aplicação SQL e o recibo `applied` podem ocorrer em **uma única transação no mesmo processo/conexão**. A prova sintética demonstra atomicidade nesse cenário **artificial**, não assegura que as 36 migrations atuais sigam esse padrão.

**Caminho L — commit legado separado:** wrappers 031–033 delimitam `BEGIN/COMMIT` e as migrations 034–036 não têm fronteira explícita; nenhum runner novo pode presumir atomicidade global. Requer **intenção durável anterior ao arquivo**, registro externo imutável e check de pós-condições. Se o processo ou o recibo falha após commit de schema, estado passa a `uncertain_requires_reconciliation` (ou permanece `prepared` caso a classificação não tenha sido gravada); em ambos, **bloqueio obrigatório de replay** até reconciliação deliberada. O teste reproduziu essa separação com objetos artificiais.

**Controle concorrente:** um *session-level advisory lock* somente protege enquanto a sessão que o detém permanece ativa; a CI **não** implementou ou testou um guardião que conserve esse lock por toda a sequência de subprocessos `psql`. Após crash e liberação automática, é a intenção persistente que impede repetir. Para ambientes futuros exigem-se lock abrangente, conexão mantida, monitoramento do guardião, log externo append-only, separação de privilégios e tratamento de alterações manuais não autorizadas.

O `ops.schema_migration_event` fictício **não** constitui definição aprovada do ledger `ops.schema_migration` previsto na política 30. Triggers append-only podem ser modificados por administradores; não substituem segregação de roles, logs externos e backups. Não há garantia formal de ausência de *race conditions* entre `assert_can_start` e o ato de gravar `prepared` no protótipo. Os estados de reconciliação e materialização de recibo final ainda exigem especificação normativa e novas provas.

## 4. Gates atualizados e o que NÃO foi demonstrado

- **BRG-04:** prova estática anterior mantida com escopo de commit específico.
- **BRG-05:** instalação sequencial real de 36 migrations no PG18 demonstrada no Documento 119, commit específico; o ensaio do ledger usou **apenas SQL sintético**, não 36 migrations.
- **BRG-06:** **FAILURE_MODEL_SYNTHETIC_TEST_PASS / OPERATIONAL_LEDGER_NOT_IMPLEMENTED**.
- **BRG-07:** **LOCK_PRIMITIVE_SYNTHETIC_PASS / DURABLE_RUNNER_NOT_IMPLEMENTED**.
- **BRG-03:** sem role migrator de menor privilégio, ACL e TLS efetivo comprovados.
- **BRG-08:** sem backup independente e restore testado.
- **BRG-09:** consumo/billing no console do owner pendente.
- **BRG-01/02:** criação de branch de teste não aprovada/não executada.

Não foram testados: concorrência **ao longo de 36 subprocessos**, teste sob kill real do executor, consistência de logs externos duráveis, processo de reconciliação com pós-condições das migrations 001–036, recuperação pós-crash e restauração. **Nenhum SQL nem outra alteração foi realizado no Neon**.

## 5. Continuidade e recomendação

Próximo gate sintético, preferencialmente em **modo alto**, deve projetar um guardião de conexão/lock persistente por toda a sequência, além de um catálogo de pós-condições e mecanismo explícito de decisão `applied / uncertain / failed_verified_rollback`; testar falhas induzidas antes/depois de commits usando unicamente PostgreSQL 18 descartável. Não adotar o protótipo como runner de aplicação sem revisão de segurança, custo e segregação de responsabilidades. Cada futura migração no Neon requer autorização própria.

`B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED`; `PHASE_5 = NOT_STARTED`; `NEON_TEST_BRANCH = NOT_CREATED`; `INDEPENDENT_BACKUP = NOT_CONFIGURED`.

**Fim do Documento 120.**
