# 123 — Prova sintética do supervisor PG18, competição por claim e reconciliação conservadora

**OES — Fase 4 | 2026-10-19 | modo alto**  
**Estado:** SYNTHETIC_SUPERVISOR_25_OF_25_CONTROLS_VERIFIED_FROM_LOGS_AND_ARTIFACT — GITHUB_RUN_METADATA_INCONSISTENT — NOT_OPERATIONAL.  
**Base:** CP166 / Documento 122 / HEAD de entrada `ab9e7ff7ab64ab8125e073f3f5764ab5257526d6`.

## 1. Freshness Gate

Comparação `main` ao HEAD CP166 = `identical`, total 0 commits de drift. Ponteiro vigente indicava CP166. CP166 integral lido, sem abrir gates Neon.

## 2. Execução encontrada

- Run: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39278420804
- Commit do run `7bba5cbd3a5c1cf9d628049b2b00643f8d21b226`.
- Job `supervisor-rehearsal` ID `118148257964`.
- Ambiente capturado em artifact: PostgreSQL servidor `18.6`, cliente `psql 16.15`.
- Artifact `f4-pg18-supervisor-synthetic`, ID `12199766445`.
- SHA-256 do ZIP recuperado e calculado independentemente: `57dc8e2ba0af83bbfb352735989e48e965cdeafc7111e0725c5a795abadfea9e`, igual ao digest informado pela API GitHub.
- ZIP contém dez arquivos, incluindo `checks.tsv`, `harness.log`, `postconditions.json`, `claim-results.json`, `result.txt` e `commit.txt`.
- `checks.tsv`: **25/25** controles `PASS`. `result.txt`: `SYNTHETIC_SUPERVISOR_PASS_WITH_LIMITATIONS`. O log do job replica os 25 resultados e confirma upload do artifact. Erros de SQL no log são negativos esperados: `RETRY_BLOCKED` e `canceling statement due to user request`.

**Anomalia relevante:** as consultas disponíveis aos metadados REST da execução e do job continuam apresentando `status=queued`, `conclusion=null`, embora logs detalhados e artifact contenham evidência de execução e finalização das etapas. A conclusão administrativa `completed/success` **não foi confirmada** de maneira independente. Preservar ambos os fatos sem promover a inconsistência a PASS global do workflow.

## 3. Controles executados e resultados

Os 25 registros PASS do harness cobrem:

1. Conferência PG18 e bootstrap sintético.
2. Duas tentativas concorrentes de reivindicar o mesmo migration ID com índice parcial único: exatamente uma inserção de intenção durável, perdedor impedido de repetir.
3. Aquisição e permanência de advisory lock com guardião em conexão ociosa.
4. SQL legado confirmado sem recibo `applied`, com reexecução bloqueada.
5. Processo filho ativo antes da perda forçada do guardião, DDL ainda invisível antes do COMMIT.
6. Detecção da perda do guardião e liberação do lock, solicitação de `pg_cancel_backend` ao backend em transação.
7. Saída não nula do cliente; DDL em transação cancelada não persistiu; tentativa permaneceu protegida contra replay.
8. Nenhum recibo `applied` artificial; supervisor recusou novo subprocesso após perda e não executou SQL proibido.
9. Catálogo fixo confirmou duas pós-condições: `oes_ci.commit_without_receipt` **existe**; `oes_ci.uncommitted_cancel` **não existe**. Ambos os casos mantiveram `uncertain_requires_reconciliation`, sem `automatic_replay` e sem `automatic_applied_receipt`.

O `claim-results.json` contém `[true, false]`, sustentando um único vencedor na tentativa simultânea artificial. `postconditions.json` registra os dois outcomes separadamente. **Não concluir que todo cancelamento garante rollback:** este caso confirmou rollback porque a transação sintética ainda estava aberta e a consulta foi cancelada antes de `COMMIT`. O CP165 já demonstrara o cenário oposto de commit de SQL em voo após perda do guardião.

## 4. Interpretação de risco e gates

- **BRG-06:** concorrência por registro `prepared` e estados conservadores testados **em fixture sintética**; ledger canônico OES/Neon NÃO implantado e política definitiva de claim/reconciliation não aprovada.
- **BRG-07:** monitoramento local da conexão, recusa de novas tarefas e cancelamento pontual de backend em voo testados **sinteticamente**; não existe supervisor/runner integrado e seguro para 36 migrations.
- **BRG-05:** prova anterior de 36/36 migrations no PG18 permanece vinculada somente ao commit do Documento 119; este ensaio foi separado, **não testou migrations reais sob supervisor**.
- **BRG-03/08/09:** menor privilégio, segredos/TLS, backup independente e billing no console titular pendentes.
- `assert_can_start` continua sujeito a TOCTOU se não integrado ao mecanismo atômico de claim. O índice único no teste não é aprovação de schema real. Separar escopo por projeto/branch/database é exigência futura.
- Bloqueio automático não equivale a reconciliação automática segura. Pós-condições de produção devem ser definidas por migration (incluindo 031–036 com fronteiras transacionais particulares), auditadas e avaliadas diante de dados reais apenas após autorização.
- Não foram testados `SIGKILL` do processo supervisor principal, separação de roles e privilégios, restarts de serviço, perda de rede, guarda durante 36 subprocessos, cancelamento pós-commit, backup/restore ou compatibilidade com Neon.

**Nenhuma operação Neon, nenhuma branch, nenhum ledger real, nenhuma migration real neste bloco.** `B1R1_ACTIVATION_WINDOW=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.

## 5. Continuidade

Em novo checkpoint, priorizar: (a) reconciliar inconsistência de metadados GitHub run/job, se observável; (b) especificar de modo fail-closed supervisão e fencing sem janela de disparo concorrente; (c) projetar catálogo por migration e validação independente de pós-condições em PostgreSQL descartável; (d) fazer análise de segurança de roles e backup antes de qualquer proposta de operação Neon. Recomenda-se modo **alto** para política normativa.

**Fim do Documento 123.**