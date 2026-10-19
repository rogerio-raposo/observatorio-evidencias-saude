# 122 — Supervisor sintético PostgreSQL 18: reivindicação concorrente, cancelamento e reconciliação

**OES / Fase 4 / 2026-10-19 / modo alto**  
**Status inicial:** SYNTHETIC_SUPERVISOR_CI_QUEUED_NOT_VERIFIED — NO_NEON_WRITE.  
**Base:** CP165 / Documento 121, HEAD de entrada `2ebd3a56da271a4d98859d6b0e5c9db5c40a8ea3`.

## 1. Freshness Gate e autorização
GitHub `main` comparado ao HEAD CP165: `identical`, ahead=0, behind=0. Ponteiro, CP165, fixture de ledger e Documento 121 consultados. Owner somente autorizou preparação e execução da **CI sintética**, não qualquer operação no Neon.

## 2. Artefatos

- `tests/fixtures/f4-supervisor-synthetic/postconditions.json`: catálogo fixo de dois resultados esperados, um para SQL confirmado sem recibo e outro para transação sintética cancelada antes do COMMIT. Não contém dados reais.
- `scripts/oes_pg18_supervisor_synthetic_test.py`: teste Python sem bibliotecas externas, guardado por `GITHUB_ACTIONS=true`, repositório conhecido, `PGHOST=127.0.0.1`, `PGPORT=5432`, `PGDATABASE=oes_f4_supervisor_synthetic`, `PGUSER=postgres` e ausência de `DATABASE_URL` ou `PGSERVICE`.
- `.github/workflows/f4-pg18-supervisor-synthetic.yml`: execução `workflow_dispatch` e push apenas para os paths desse teste/fixture; `postgres:18` descartável; checkout fixado, `contents:read`, sem credenciais Git persistentes, sem secrets/hosts Neon, upload de logs em falhas e sucesso.

## 3. Cenários pretendidos — NÃO confundir planejamento com prova

1. Criar fixture `ops.schema_migration_event` **sintética**, acrescida no teste de índice parcial `UNIQUE (migration_id) WHERE event_type='prepared'`. Disparar dois `psql` concorrentes; exigir exatamente um retorno `RETURNING event_id` e uma única intenção persistida. **Não** considerar `assert_can_start` sozinho mecanismo anti-race.
2. Manter advisory lock por sessão ociosa em processo guardião separado dos subprocessos.
3. Confirmar SQL legado `CREATE TABLE` e perder seu recibo; guardar `uncertain`, proibir replay.
4. Iniciar transação SQL ainda aberta com `pg_sleep`, causar perda do guardião e solicitar `pg_cancel_backend` antes do COMMIT. Confirmar saída não nula de `psql`, DDL revertido no cenário e intenção persistida. Isso NÃO prova cancelamento universal de SQL já confirmado.
5. Demonstrar que a barreira local do supervisor recusa iniciar novo processo após perda do guardião.
6. Verificar duas pós-condições do catálogo e emitir relatório de reconciliação; **nenhuma promoção automática para `applied` nem replay automático**.

A classificação `uncertain_requires_reconciliation` é deliberadamente conservadora, inclusive quando o ensaio de cancelamento indica rollback, até prova mais abrangente. A regra de exclusividade testada dependerá do índice parcial de intenção no protótipo; **a estrutura de ledger operacional segue não aprovada**.

## 4. Execução automática e estado inicialmente verificável

Run iniciado por push: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39278420804  
Commit submetido: `7bba5cbd3a5c1cf9d628049b2b00643f8d21b226`.  
Consultas iniciais GitHub indicaram `queued`, `conclusion=null`, job `supervisor-rehearsal` ID `118148257964` também na fila. **Nenhum PASS, falha técnica, versão de servidor executada, log ou artifact foi comprovado no momento da preparação deste documento.**

## 5. Limites, riscos residuais e próximo gate

O script é **harness de verificação**, não executor persistente de migrations. A guarda `guardian.poll()` prévia a criar subprocesso possui janela TOCTOU; após uma falha em execução, um backend já iniciado pode commitar antes do cancelamento. O índice de intent do teste não assegura escopo correto entre branches/roles ou integração com locks, e o log de CI não constitui trilha externa append-only operacional.

Permanecem não testados: 36 migrations sob supervisor, cancelamento pós-COMMIT, concorrência entre runners reais, `SIGKILL` do supervisor principal, reaquisição de lock sob partições de rede, permissões mínimas, TLS autenticado, segredos, backup/restore e custo Neon.

**BRG-06/07 não liberados operacionalmente.** BRG-03, BRG-08 e BRG-09 pendentes. Nenhuma branch `oes-schema-test` criada, nenhuma operação no Neon, B1R1 `EXPIRED_NOT_EXECUTED`, Fase 5 não iniciada.

**Próximo passo:** verificar run `39278420804`, obter logs/artifacts e registrar resultado de cada cenário. Não declarar êxito enquanto não houver job `completed/success` e controles comprovados.

**Fim do Documento 122 — estado de preparação.**