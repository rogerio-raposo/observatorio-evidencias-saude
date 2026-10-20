# 131 — Ensaio sintético PG18: segregação de privilégios e limites da auditoria DDL transacional

**OES — Fase 4 | 2026-10-19 (America/Recife) | modo alto**  
**Status:** PG18_SYNTHETIC_ROLE_DENIAL_AND_INDB_DDL_AUDIT_38_PASS_PINNED_COMMIT — BRG03_NEON_NOT_VERIFIED — NO_NEON_WRITE.  
**Entrada:** CP174 / Documento 130 / HEAD `8c8a54937f9ef1a697c309d4e7876dd473ff8a8c`.

## 1. Continuidade, fronteira e autorização

Freshness Gate CP174/`main` retornou `identical`, 0 ahead/behind. README/ponteiro e CP174 foram lidos. Catálogo canônico `database/f4-reconciliation-postconditions-draft.json` conferido com 36/36 migrations `UNREVIEWED`, zero condições e nenhuma flag de replay, reconciliação ou execução habilitada. Política 30 e Documento 130 consultados.

Somente PostgreSQL 18 descartável no GitHub Actions foi usado. Nenhuma conexão/branch/schema/role/credential/ledger/migration foi criada ou alterada no Neon. **Não houve autorização de operação Neon, contratação ou consumo de serviço pago.**

## 2. Arquivos do ensaio

- `scripts/oes_f4_pg18_acl_ddl_audit_synthetic.py`: harness CI-only, exigindo `GITHUB_ACTIONS=true`, repositório exato OES, host `127.0.0.1`, porta 5432, DB `oes_f4_acl_ddl_synthetic` e usuário `postgres`, bloqueando `DATABASE_URL`/`PGSERVICE`/`PGSERVICEFILE`. Instala migrations 001–036 exclusivamente no banco local sintético. Cria três roles `NOLOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB`: `oes_ci_schema_owner`, `oes_ci_runtime` e `oes_ci_migrator`.
- `.github/workflows/f4-pg18-acl-ddl-audit-synthetic.yml`: job `postgres:18` com `contents:read`, checkout sem credenciais GitHub persistentes e artifact mesmo sob falha. Gatilho `push` limitado a arquivos do próprio ensaio e manifesto; `workflow_dispatch` manual. Sem secrets/host Neon.

Roles de teste são artificiais e recebem permissões explícitas de leitura nas duas tabelas reais de guards `maintenance.temporal_observation_epoch` e `maintenance.temporal_measurement_event`, **instaladas apenas no PG18 descartável**. O runtime também recebe `INSERT` em tabela artificial `oes_ci_role_test.probe`, sem propriedade do objeto. O papel migrator é deliberadamente restrito no teste, não se afirma que tenha privilégio suficiente para migrar um schema real.

## 3. Três execuções e rastreabilidade de falhas

| Run | Commit | Resultado | Diagnóstico |
|---|---|---|---|
| `39358068414` | `895a8be2945982f6dfd98bf97823f6d0faca908d` | **failure** | Comparação incorreta do texto de expressão booleana PostgreSQL: `false` vs `f`; falha do harness, não da segregação de roles |
| `39358143142` | `be6b37c960450926e61c19522d019536dbfe58b2` | **failure** | Roles e sete tentativas de alteração não autorizadas passaram. A asserção posterior de ausência de tabela usava conversão booleana inconsistente; falha do harness |
| `39358223730` | `b53897af4e12052c122f5ab1d1c879f1a32c52d1` | **completed/success** | Comparações corrigidas prospectivamente; prova de roles, DDL negado e evento DDL transacional concluída |

**Run aprovado:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39358223730  
**Job:** `118417944949`, `completed/success`.  
**Servidor:** PostgreSQL **18.6**, cliente `psql` conforme artifact.  
**Comprovação:** `checks.tsv` contém **38/38 PASS** e `result.txt` contém `PG18_ACL_DDL_AUDIT_SYNTHETIC_PASS_LIMITED`.

Artifact `f4-pg18-acl-ddl-audit-synthetic`, ID **12236325916**, 10 entradas ZIP, testzip íntegro; SHA-256 dos bytes **`44107e32b45fcf7b4698572d736e38005370348d6465d3bd320c2544ec23a408`** calculado independentemente e igual ao digest informado pela API GitHub. `commit.txt` coincide com o SHA executado. `result.json`, `audit-events.json`, `function-fingerprints.json`, `expected-denials.log` e `harness.log` inspecionados.

## 4. Resultados e interpretação

**Privilégios mínimos sintéticos:**

1. Três roles de CI foram criadas com `NOLOGIN`, sem `SUPERUSER`, `CREATEROLE` ou `CREATEDB`, sem participação no papel proprietário e sem `CREATE` no schema `maintenance`.
2. Runtime e migrator conseguiram executar somente as operações explicitamente concedidas no fixture de teste. Um runtime com `INSERT` na tabela artificial não pôde alterá-la; o proprietário artificial pôde alterar a própria tabela.
3. Com `SET ROLE`, runtime e migrator foram **impedidos** de `DISABLE TRIGGER` nos guards reais 034/036 instalados localmente, assim como de substituir a função 034, transferir a propriedade da função 035 e criar tabela indevida em `maintenance`.
4. Os triggers 034 e 036 permaneceram habilitados após as tentativas negadas; fingerprints das funções 034, 035 e 036 permaneceram idênticos.
5. Roles restritas não conseguiram desabilitar ou remover o event trigger artificial de auditoria.

**Observação administrativa DDL:**

6. Em CI, superusuário `postgres` desabilitou e reabilitou o trigger 034. Um event trigger artificial `ddl_command_end` gravou **duas** linhas de `ALTER TABLE` confirmadas, com objeto `maintenance.temporal_observation_epoch`, `session_actor=postgres`, `role_setting=none`.
7. `BEGIN; ALTER TABLE ... DISABLE TRIGGER; ROLLBACK;` restaurou o trigger mas não deixou registro adicional na tabela interna de auditoria: a própria inserção do evento foi desfeita na transação. Portanto, uma trilha **dentro do mesmo banco e transação NÃO é auditoria independente e durável**.
8. O superusuário que tem controle sobre o banco e event triggers também pode modificar o mecanismo de auditoria. Este teste **não** estabeleceu trilha externa append-only, inviolabilidade, logs de operações não confirmadas ou proteção contra administrador privilegiado.

## 5. Riscos que continuam abertos

- **BRG-03 não aprovado:** nenhuma role, TLS, política de segredos, ACL, console, DDL audit ou endpoint do **Neon** foi testado. A prova mostra somente o comportamento PostgreSQL sob roles artificiais em ambiente descartável.
- Roles designadas `migrator` e `runtime` são exemplos de segregação, não arquitetura final. Um migrator operacional precisará de privilégio suficiente para migrations aprovadas, **sem adquirir capacidade irrestrita de desabilitar guards**; podem existir conflitos reais de ownership que exigem desenho próprio.
- O caso de superusuário demonstra o limite do modelo: DDL administrativo capaz de desabilitar trigger persiste se confirmado, e auditoria interna pode ser insuficiente, mesmo com `event trigger` presente. Exigir logging independente, gestão de retenção, testes de recuperação e revisão de permissões.
- Não foram testados conexão TLS, `pgAudit` externo, `log_statement`, replicação de logs, temporizações de failover, múltiplos administradores, `SECURITY DEFINER` mal configurado, alterações de `search_path`, `SET ROLE` por usuários de produção, backup/restauração ou ACL com dados científicos.
- O catálogo principal permanece **36/36 `UNREVIEWED`, 0 pós-condições aprovadas**, e a matriz 034–036 tem **36 exigências `NOT_COLLECTED`**. Os resultados sintéticos do presente run não serão convertidos automaticamente em evidência operacional da matriz.
- **BRG-06/07** ainda sem ledger/runner operacionais; **BRG-08** backup e restore independentes não configurados; **BRG-09** billing no console do titular pendente. `NEON_TEST_BRANCH=NOT_CREATED`, `B1R1=EXPIRED_NOT_EXECUTED`, `PHASE_5=NOT_STARTED`.

## 6. Continuidade

Recomenda-se, em modo alto e ainda sem Neon, preparar um **modelo de privilégio-alvo e de logging externo verificável**, distinguindo proprietário de schema, runtime, executor de migrations, operador de backup e auditor; documentar operações permitidas/proibidas e pontos de auditoria fora da transação. Em eventual CI futura, testar acesso por conexão real de usuários `LOGIN` artificiais, `SET ROLE`, ownership e limitações do event trigger, sempre em serviço PG18 descartável. Antes de qualquer operacionalização: revisão humana independente de PostgreSQL/segurança, custos, backup e autorização específica do owner.

**Fim do Documento 131.**
