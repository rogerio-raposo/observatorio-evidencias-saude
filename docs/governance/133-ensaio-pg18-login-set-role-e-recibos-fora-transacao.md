# 133 — Ensaio PG18: credenciais LOGIN, membership SET/INHERIT e recibos simulados fora da transação

**OES — Fase 4 | 2026-10-20 (America/Recife) | modo alto**  
**Estado:** PG18_DISPOSABLE_LOGIN_MEMBERSHIP_41_OF_41_PASS — OUTSIDE_DB_RECEIPTS_SIMULATED_NOT_INDEPENDENT — NEON_UNTOUCHED.  
**Entrada:** CP176 / Documento 132 / HEAD `1bed3de41ebc9dd5a670e867d38bc3c2e6825669`.

## 1. Freshness Gate e autorização

O HEAD de CP176 comparado com `main` estava `identical` (0 ahead/behind). README canônico aponta CP176; checkpoint e Documento 132 consultados. O `Prossiga` autorizou apenas um ensaio **sintético, sem custo adicional e descartável**, mais documentação GitHub; não autorizou alteração Neon, criação de role/branch Neon, execução operacional de SQL, implantação de logs, uso de dados científicos, Fase 5 ou reativação B1R1.

## 2. Harness e CI

Foram criados:
- `scripts/oes_f4_pg18_login_roles_external_receipt_sim.py`: harness Python restrito a `GITHUB_ACTIONS=true`, repositório OES, endereço `127.0.0.1`, porta 5432 e DB `oes_f4_cp177_synthetic`, recusando `DATABASE_URL`/`PGSERVICE`; instala as 36 migrations **somente** no serviço `postgres:18` descartável. Usa `psql` com credenciais sintéticas distintas para três roles `LOGIN`.
- `.github/workflows/f4-pg18-login-and-audit-receipts-synthetic.yml`: workflow `contents:read`, sem credenciais persistentes do checkout e sem segredos Neon; push restrito a seus próprios arquivos e manifesto; publicação de artifact inclusive em falha.

O fixture sintético cria `oes_ci_guard_owner NOLOGIN`; `oes_ci_runtime_login`, `oes_ci_migrator_login` e `oes_ci_elevated_login` possuem `LOGIN` com senhas exclusivamente de CI. A role migrator é membro da owner com `INHERIT FALSE, SET FALSE, ADMIN FALSE`; a role elevada, membro com `INHERIT FALSE, SET TRUE, ADMIN FALSE`; runtime sem membership. A tabela `maintenance.temporal_observation_epoch`, com trigger de migration 034 já instalado, foi transferida **no banco descartável** à role `NOLOGIN`. Nenhum arquivo SQL histórico de migrations, política 30 ou catálogo de pós-condições foi alterado.

## 3. Runs e falha inicial preservada

| Run | Commit | Estado e diagnóstico |
|---|---|---|
| `39404590522` | `158459f7ce5b47c160196e4c1fa314e88a9164ae` | `completed/failure`: negativas de runtime/migrator passaram, porém role artificial proprietária não tinha `USAGE` no schema `maintenance`; bloqueio por schema tornou inconclusivo o ensaio de `SET ROLE` com owner |
| `39404695131` | `39ad812f55fd7b79c70f80766f0a85c3e9ea713c` | **`completed/success`** após conceder `USAGE` apenas à role proprietária no contêiner. Nenhuma alteração a objetos Neon |

A falha inicial foi corrigida prospectivamente e não constitui defeito da migration 034 nem falha de ACL do ambiente Neon.

**Run corrigido:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39404695131  
**Job:** `118567684999`, `completed/success`.  
**Testes:** **41/41 PASS** em `checks.tsv`, logs e marcador `PG18_LOGIN_AUDIT_RECEIPTS_SYNTHETIC_LIMITED_PASS`.  
**PostgreSQL:** servidor 18 (arquivo `server-version.txt`), cliente `psql` conforme artifact.

Artifact `f4-pg18-login-audit-receipts-cp177`, ID `12256624023`, baixado e íntegro: nove arquivos, `testzip() = None`, SHA-256 ZIP **`e40f13a2254d9e8d41e14b87b3c758f6e2f1a0200e1f35a3d96d6aee240c014f`**, idêntico ao digest GitHub. `commit.txt` coincide com o commit corrigido. `simulated-outside-db.jsonl` contém oito registros; `audit-anchor.json` contém `count=8` e hash final `55059ec277bd3bc1f88f014f27e241f85bd0bae761cb83a2261a96f595d432ae`. `result.json` explicita limites e `neon_accessed=false`.

## 4. Resultados de autenticação e propriedade

1. As três credenciais `LOGIN` efetuaram conexão autenticada ao PostgreSQL 18 local e cada sessão confirmou `session_user=current_user` esperado. Role proprietária `NOLOGIN` não conseguiu iniciar sessão diretamente.
2. Runtime não tinha membership na role proprietária, não conseguiu `SET ROLE` nem desabilitar o trigger de cronologia 034.
3. Migrator com membership e `SET FALSE`, `INHERIT FALSE` não recebeu privilégios efetivos do proprietário e não conseguiu `SET ROLE` ou desabilitar o trigger.
4. A credencial elevada, membro `SET TRUE`, `INHERIT FALSE`, não podia desabilitar o guard **sem** executar `SET ROLE`; ao assumir a role `NOLOGIN` proprietária conseguiu desabilitá-lo e reabilitá-lo.
5. Uma operação de desativação seguida por `ROLLBACK` em sessão elevada deixou o trigger habilitado. Os erros de acesso esperados das roles limitadas foram confirmados em ambiente descartável.

**Implicação:** `NOLOGIN` e `INHERIT FALSE` são controles úteis, mas **não bastam** para eliminar o risco quando `SET ROLE` é concedido a um principal autorizado. Durante a elevação, a propriedade permite DDL, logo o controle exigido é administrativo e externo à credencial SQL. O campo `ADMIN FALSE` consta das concessões sintéticas, porém **delegação ADMIN não foi submetida a teste negativo independente neste bloco**. Cadeias transitivas de membership também não foram examinadas.

## 5. Recibos fora da transação e cinco controles de integridade

O harness criou um arquivo JSONL **no filesystem efêmero do runner**, antes/depois das instruções SQL: quatro ações registraram pares `attempt/result` (oito registros) com índice, `prev_hash`, hash SHA-256 encadeado, ação, ator, operação e estado. Um arquivo `audit-anchor.json` contém contagem e hash terminal.

- Dois DDL confirmados: desabilitação e reabilitação de trigger 034 por executor elevado.
- Uma operação `BEGIN; ALTER TABLE ... DISABLE TRIGGER; ROLLBACK`: deixou trigger ativo e o JSONL conservou o par de eventos **fora da transação do PostgreSQL**.
- Uma tentativa não autorizada de `SET ROLE` pelo migrator: resultado de falha/negação registrado.
- O verificador rejeitou **alteração de payload, remoção de registro intermediário, truncamento, inversão de ordem e hash terminal adulterado**.

O arquivo JSONL e o anchor estão **ambos no mesmo runner CI**. Portanto, os resultados **não** provam imutabilidade, autenticidade externa, ausência de adulteração do par log+anchor, completude de SQL executado fora do harness, tolerância a falha do runner ou persistência fora de GitHub Actions. `attempt` é registrado pelo wrapper controlador, não por captura transparente do motor PostgreSQL. Uma queda do processo entre escrita e SQL pode gerar recibo sem execução; uma sessão direta alheia ao controlador poderia não gerar qualquer recibo. Logo isto **não** é implementação de auditoria independente e não libera BRG-03.

## 6. Gates preservados

- `BRG-03`: prova somente de PostgreSQL descartável; ACL/TLS/credentials/log externo/roles no Neon não verificados.
- `BRG-04/05`: comprovações históricas de schema e ensaios sintéticos, limitadas a commits específicos.
- `BRG-06/07`: ledger/runner/fencing operacionais não criados ou aprovados.
- `BRG-08`: backup/restore independente pendente.
- `BRG-09`: conferência owner billing e serviços gratuitos pendente.
- Catálogo principal: **36/36 `UNREVIEWED`, 0 pós-condições aprovadas e flags automáticas desabilitadas**; matriz 034–036: **36 requisitos `NOT_COLLECTED`**; modelo CP176: 12 controles mandatórios ainda não satisfeitos.
- `NEON_TEST_BRANCH=NOT_CREATED`; `NEON_SCHEMA_MIGRATION=NOT_STARTED`; `B1R1_ACTIVATION_WINDOW=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.
- Nenhum serviço pago, recurso Neon, aprovação metodológica humana ou extração de dados científicos.

## 7. Retomada proposta

Se houver novo `Prossiga`, priorizar uma revisão sintética de **`ADMIN FALSE`, cadeias transitivas `SET/INHERIT`, `SET ROLE` e concessões indiretas**, complementada com teste de **completude/independência do recibo** perante falha do próprio controlador, mudança simultânea do anchor e comandos fora do harness. Mantém-se proibida qualquer promoção automática à categoria de auditoria independente. Exigir revisão de arquitetura por especialista PostgreSQL/segurança antes de avançar com Neon, e decisão específica do titular em custos.

**Fim do Documento 133.**