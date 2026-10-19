# 121 — Guardião de lock persistente e contraprova de crash em PostgreSQL 18 sintético

**OES — Fase 4 | 2026-10-19 | modo alto**  
**Status:** SYNTHETIC_GUARDIAN_TEST_PASS_WITH_NEGATIVE_CONTROL — NOT_OPERATIONAL — NO_NEON_MUTATION.  
**Entrada:** Documento 120 / CP164 / HEAD `2ad4da0fbd725273ed253d88fd3ccc29ed2a2ff8`.

## 1. Freshness Gate e escopo

HEAD CP164 comparado a `main`: `identical`, zero drift na entrada. Ponteiro, CP164 e fixture de ledger sintético consultados. Execução limitada a PostgreSQL 18 efêmero na CI, sem conexão, role, branch, schema, tabela ou migration Neon.

Foi adicionado `scripts/oes_pg18_guardian_synthetic_test.py`, que exige `GITHUB_ACTIONS=true`, repositório OES, host `127.0.0.1`, porta 5432, usuário `postgres`, database `oes_f4_guardian_synthetic` e ausência de `DATABASE_URL`. Esse guard serve como cerca de segurança para **teste**, não como credencialização de produção.

Foi adicionado `.github/workflows/f4-pg18-guardian-synthetic.yml` com PostgreSQL 18 descartável, permissões GitHub `contents: read`, credenciais artificiais e gatilho `push` estritamente limitado aos próprios arquivos de ensaio.

## 2. Evolução do protótipo e falhas preservadas

- **Run 39266423818**, commit `4bdc9d57b391b58645702e1d53aace23889e63f9`: **FAILED**. O guardião usava uma conexão em query ativa `pg_sleep(60)`; após `SIGKILL` ao cliente, a sessão servidor podia manter o advisory lock enquanto a query permanecia ativa. A verificação de liberação rápida do lock falhou. *Não foi um PASS e não deve ser apagado do histórico.*
- **Run 39266711331**, commit `cd329ef26c7d183a816a9bb5dcfc4e15f9fe4abe`: **FAILED**. Na primeira revisão para sessão ociosa, o comando enviado ao stdin do `psql` não continha a quebra de linha efetiva esperada; o lock não foi adquirido.
- **Run 39266780706**, commit `064d970ddbc1e4a4830a44472074eaec5734698b`: **SUCCESS**. A versão corrigida preserva o processo `psql` interativo com stdin aberto, enviando `SELECT pg_advisory_lock(...);` e deixando a conexão ociosa durante os subprocessos.

Os resultados anteriores demonstram que **liberação rápida do lock após interrupção do cliente não é uma propriedade incondicional de toda implementação**.

## 3. Prova final verificada

Run: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39266780706  
Job `guardian-crash-model` ID `118108308578`: `completed/success`.  
Servidor `PostgreSQL 18.6`; cliente `psql 16.15`.  
Artifact `f4-pg18-guardian-synthetic-evidence`, ID **12193207877**, ZIP SHA-256 **`867f2189872cbdd3accf12851f6d4d1843a63bbea7b1a5bf4e7f7c62a39f6175`**, conferido independentemente com os bytes recuperados. `commit.txt` coincide com o commit do run. `checks.tsv` confirma **15/15 PASS**.

Cenários observados: PostgreSQL 18; fixture; aquisição do lock do guardião; intenção durável antes dos comandos; lock durante dois subprocessos `psql` separados; exclusão de um contender entre subprocessos; subprocesso confirmado ativo; `SIGKILL` do guardião e liberação do lock; subprocesso iniciado **concluiu e confirmou DDL após o crash do guardião** (*negative control*); ausência de recibo falso; bloqueio de replay pelo `prepared` durável; evento `uncertain_requires_reconciliation`; nova sessão consegue obter lock mas **não** repetir migration.

## 4. Interpretação de segurança

**Prova positiva limitada:** com conexão dedicada **ociosa** a sessão consegue reter advisory lock durante múltiplas conexões `psql` independentes; na falha artificial da sessão, o lock foi liberado; a intenção durável bloqueou a repetição.

**Contraprova crítica:** perda do guardião **não cancela necessariamente um subprocesso SQL já em execução**. No cenário testado, esse subprocesso concluiu DDL depois do crash. Portanto:
1. o lock **não é recibo de commit** nem meio suficiente de recuperação;
2. o estado `prepared` deve sobreviver, impedindo *retry* automático;
3. uma solução futura precisa vigiar a conexão guardiã continuamente e impedir **novos** subprocessos após falha;
4. é necessário tratar cancelamento e eventual terminação de SQL em voo, além de consulta pós-condição, porque cancelar não garante rollback caso a transação já tenha cometido;
5. nenhuma decisão automática de `applied` é segura após perda de confirmação; registrar `uncertain` e reconciliar o estado observável;
6. não foi provada proteção contra *race conditions* entre múltiplos controladores nem separação de privilégios. Roles administrativas podem alterar triggers append-only.

**O ensaio não implementa um runner real nem comprova execução de 36 migrations sob o guardião.** Também não comprova restart após morte do processo controlador, recovery de processo/zona, garantia de lock sob rede Neon, preservação de logs externos, ACL, TLS, backup independente, nem caminhos de resolução de todos os SQL legados.

## 5. Gates e decisão de continuidade

| Gate | Estado após este ensaio |
|---|---|
| BRG-04 | Prova estática em commit anterior, não substituída |
| BRG-05 | Prova de instalação sequencial PG18 em commit anterior, não substituída |
| BRG-06 | Intenção durável e bloqueio de replay em fixture: **synthetic PASS; ledger operational NO** |
| BRG-07 | Lock durante dois subprocessos, liberação após kill e contraprova de SQL em voo: **synthetic PASS with limitation; runner operational NO** |
| BRG-03 | Segregação de privilégio, TLS, segredo: não comprovados |
| BRG-08 | Backup/restauração independentes: pendentes |
| BRG-09 | Billing/consumo no console do titular: pendentes |

**Decisão:** manter arquitetura de ensaio como **protótipo de pesquisa técnica**. Não usar o script para aplicar migrations reais no Neon e não criar branch por aprovação implícita.

**Próximo checkpoint técnico:** desenhar um supervisor de conexão e subprocessos com encerramento coordenado, registro externo de intenção e pós-condições por migration; testar também contendedores simultâneos e falha em pontos de commit, exclusivamente em PG18 descartável.

`NEON_TEST_BRANCH=NOT_CREATED`; `NEON_SCHEMA_MIGRATION=NOT_STARTED`; `B1R1_ACTIVATION_WINDOW=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.

**Fim do Documento 121.**