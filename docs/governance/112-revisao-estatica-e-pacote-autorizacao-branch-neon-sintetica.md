# 112 — Revisão estática das migrations e pacote de autorização de branch Neon sintética

**Projeto:** OES — Fase 4 — Protocolo de Atualização  
**Data:** 2026-10-19  
**Modo:** alto  
**Status:** **STATIC_REVIEW_COMPLETED_WITH_LIMITATIONS — AUTHORIZATION_PACKAGE_PREPARED_ONLY — NO_NEON_MUTATION**  
**Entrada:** Documento 111 / CP155; HEAD `097d35b7fc38f81396285798cf314def9bd81aed`.  
**Escopo:** exclusivamente preparação técnica, governança, segurança e orçamento do ensaio de *schema* sintético. Não autoriza criação de branch, roles, tables, schemas, ledger nem execução de migrations.

## 1. Freshness Gate e fontes

Ponteiro `archive/handoffs/oes/README.md` indicava CP155; comparação GitHub entre HEAD informado e `main` = `identical`, com zero commits posteriores. `README.md`, `STATE.md`, `CHANGELOG.md`, template de continuidade, CP155, Documento 111, manifesto e workflow S5 consultados.

A integração Neon, somente por API de leitura, confirmou projeto `oes-sandbox`, project ID `weathered-boat-65779510`, região `aws-sa-east-1`, PG major 18; branch **única** `production` (`br-wild-field-b6qg7k3p`), `default=true`, `protected=false`, `ready`. Nome `production` é terminologia Neon e **não** um ambiente factual OES. A API retornou limite lógico de projeto de 1 GiB e tamanho lógico da branch de 31.686.656 bytes; a métrica não equivale ao `pg_database_size` observado no Documento 110. Contadores de consumo podem ser diferidos; nenhum snapshot de painel de cobrança foi auditado.

Fonte primária pública datada de 02/10/2026: https://neon.com/blog/neon-free-plan-1-gb-per-project — apresenta Free de 1 GB por projeto, 100 CU-h/mês, 10 branches por projeto e 6 horas de janela de restauração. **Não se inferem** saldo atual de quotas, plano/billing efetivo do titular ou garantia de custo zero sem conferência no painel no instante da operação. Uma branch Neon copy-on-write não constitui backup independente.

## 2. Verificação dos arquivos no GitHub

- Foram lidos via integração GitHub os **36 arquivos de entrada** do manifesto e os **14 arquivos auxiliares** referenciados pelos wrappers 031, 032 e 033; 50 caminhos presentes na `main`.
- A ordem nominal de 36 entradas coincide com os comandos `psql -v ON_ERROR_STOP=1 -f` do workflow `.github/workflows/validate-s5.yml`, linhas 284–319.
- Os 14 fragmentos distribuem-se em 031a–e (5), 032a–d (4) e 033a–e (5); **não** devem entrar como 14 migrations independentes.
- A API fornece hashes de Git *blob* para cada arquivo, mas **não** substitui o SHA-256 dos bytes de um checkout imutável. Não há, ainda, manifesto SHA-256 fechado, tarball verificável, hash agregado de wrappers/fragmentos, versão de cliente `psql` capturada para o executor futuro ou ledger aplicado.
- Revisão foi **estática por leitura e busca de padrões**, não parser SQL formal, execução, teste de permissões ou verificação exaustiva de semântica de PL/pgSQL. Não declarar `PASS` de deploy.

## 3. Achados técnicos materiais

### F4-NBR-01 — DML estrutural embutido [confirmado]

`database/031a_propagation_core.sql` insere `maintenance.contract_epoch` para `PROPAGATION_REBASELINE_V01` com `CURRENT_TIMESTAMP` e `ON CONFLICT DO NOTHING`. `database/032a_temporal_calibration_core.sql` insere o epoch `TEMPORAL_CALIBRATION_V01` e, em primeira instalação, copia linhas preexistentes de `update_policy`, `sla_rule` e `sla_calendar_version` para `maintenance.temporal_contract_grandfathered_object` com carimbo temporal. São **dados estruturais e de controle** permitidos somente após revisão/aprovação do *schema* sintético; não são medições científicas nem fixtures. A expressão “somente DDL” seria falsa. Em branch vazia, a contagem esperada de *grandfathering* dependerá do estado realmente observado antes de migrar; não pressupor zero sem consulta.

### F4-NBR-02 — Fronteiras transacionais [confirmado]

Wrappers 031, 032 e 033 contêm `BEGIN`/`COMMIT`; 034, 035 e 036 não contêm wrapper transacional explícito. A CI executa cada arquivo com chamada separada de `psql`; não oferece atomicidade global 001–036. A migration 034 faz `DROP TRIGGER IF EXISTS` seguido de `CREATE TRIGGER`; uma interrupção sem tratamento transacional pode deixar objeto removido ou recriado parcialmente. Exige revisão e prova, antes da execução, de política de transação por unidade e *fail-closed* sem reexecução cega. `psql --single-transaction` em toda a série não deve ser presumido seguro quando os próprios scripts delimitam transações.

### F4-NBR-03 — Executor e materialidade de segurança [confirmado/pêndente]

`psql` interpreta `\\ir` relativo ao diretório do wrapper; o executor de SQL prepared-statement único do Neon não reproduz fielmente esses arquivos. Exigir executor `psql` externo auditável, `-X`, `ON_ERROR_STOP=1`, logs e conexão explicitamente direcionada à **branch de teste por ID e database**, sem enviar credenciais para chat/repo. Não foram observados comandos evidentes `GRANT`, `REVOKE` ou `CREATE ROLE` na triagem de padrões dos 50 SQL; isso **não prova** menor privilégio, especialmente para funções, schemas, triggers, ACL padrão e SQL dinâmico. Privilégios efetivos, TLS autenticado/verificado, credenciais e separação entre migrator e usuário de aplicação continuam não comprovados. Role `oes_sandbox_owner` é administrativa e não deve ser adotada automaticamente.

### F4-NBR-04 — Idempotência, ledger e recuperação [pendente]

A arquitetura exige `ops.schema_migration`, ainda inexistente. Contrato mínimo proposto: `migration_id` canônico, caminho, hash SHA-256 do entrypoint, manifesto dos hashes dos fragmentos `\\ir`, commit Git fixado, servidor/cliente, executor técnico sem segredo, início/fim, resultado, evidência pós-condição e identificação do log. O desenho deve impedir *drift* e repetição não autorizada. Registros `in_progress`, `failed` e `applied` exigem política de transação compatível; **uma falha entre COMMIT de schema e COMMIT do ledger não pode ser tratada como não aplicação**. Manter log externo durável e reconciliar objetos/versão antes de qualquer retry. Não criar o ledger por este documento.

### F4-NBR-05 — Quotas e recuperação [bloqueante]

Plano Free publicamente compatível com o conceito de uma segunda branch, porém consumo corrente, restrições específicas da conta, política de billing, compute ativo e disponibilidade regional no instante da criação devem ser verificados. Falta backup offsite independente, prova de restore, Artifacts e segregação operacional. A janela Neon de restore e uma child branch não substituem backup/restore independente para operação factual. **Sem qualquer autorização para gasto ou upgrade.**

## 4. Gates BRG — resultado desta revisão

| Gate | Resultado em 2026-10-19 | Critério para avanço |
|---|---|---|
| BRG-01 Escopo/owner | **PENDING** | aprovação textual específica para CREATE BRANCH; proibição de gasto e dados factuais |
| BRG-02 Branch | **NOT_EXECUTED** | após aprovação, confirmar ID, parentalidade e destino; nunca aplicar na default |
| BRG-03 Privilégios/TLS | **NOT_READY** | desenho migrator delimitado, TLS client `verify-full`, segurança de segredos, ACL review |
| BRG-04 Ordem/hashes | **PARTIAL_STATIC** | 36+14 conferidos; SHA-256 dos bytes e versão do runner ainda faltam |
| BRG-05 Compatibilidade | **PARTIAL_STATIC** | revisar objetos/dynamic SQL e testar PG18 sintético; deploy real não validado |
| BRG-06 Ledger | **DESIGN_PENDING** | contrato de falhas, hashes, reconciliação e transações fechado antes de criar |
| BRG-07 Execução/logs | **PLAN_ONLY** | runner, stop-on-error, logs, checkpoint por migration, política de retry |
| BRG-08 Rebuild/restore | **NOT_READY** | regressão sintética, teste de restore e backup independente antes de operação factual |
| BRG-09 Free/custos | **PENDING_OWNER_CONSOLE** | confirmar plano, quotas, consumo, zero billing e parada automática em limites |
| BRG-10 Não factual | **GUARD_ACTIVE** | B1R1 expirado; sem Epoch, medições, requisições científicas ou fixtures factuais |

**A matriz não representa PASS de criação, schema ou infraestrutura operacional.**

## 5. Sequência futura sob gates independentes

**Gate 0 — preparação somente leitura:** confirmar `main` e HEAD; auditar painel Free/limites; realizar `psql` local/CI PostgreSQL 18 com artefatos sintéticos descartáveis, hashes SHA-256, revisão de ACL, DML estrutural e semântica transacional; produzir desenho definitivo do ledger e runner. Não acessar banco Neon para escrita.

**Gate 1 — eventual criação de branch:** somente com aprovação específica do titular, BRG-01/09 comprovados e novo Freshness Gate; criar **apenas** `oes-schema-test` a partir da default, sem migração, roles ou fixtures, e verificar pela API de leitura identidade/estado/custos. Parar e documentar checkpoint.

**Gate 2 — eventual migração de schema:** nova decisão específica, independente de Gate 1; exigir BRG-03 a BRG-07 validados, checkout fixo SHA-256, `psql` compatível, ledger decidido e logs. Sem autorização automática pela aprovação da branch.

**Gate 3 — eventual uso factual:** não incluído. Depende de ODB-01–ODB-12, backup externo restaurado, governança científica, novo Epoch e novo cronograma, todos autorizados separadamente.

## 6. Modelo de autorização para decisão posterior — NÃO concedida

> **APPROVED — Neon Free synthetic test branch / Documento 112 / oes-schema-test / aws-sa-east-1 / create-branch-only / synthetic-only / no paid services / no migrations**

Este texto é **modelo não assinado**, não delegação vigente. Mesmo se usado pelo owner, somente libera o Gate 1 após verificação de quotas e segurança; não autoriza `CREATE ROLE`, schema, migrations, testes com writes, faturamento, senha no chat, ativação temporal nem Fase 5. `Prossiga` genérico não substitui esta aprovação.

## 7. Conclusão e continuidade

**STATIC_FILE_INVENTORY = VERIFIED_36_ENTRYPOINTS_14_FRAGMENTS**  
**STATIC_EXECUTION_RISK_REVIEW = COMPLETED_WITH_LIMITATIONS**  
**FUTURE_BRANCH_AUTHORIZATION_PACKAGE = PREPARED_NOT_APPROVED**  
**NEON_BRANCH_OES_SCHEMA_TEST = NOT_CREATED**  
**NEON_SCHEMA_MIGRATION = NOT_STARTED**  
**MIGRATION_LEDGER = NOT_CREATED**  
**NEON_FREE_OWNER_QUOTA_GATE = PENDING**  
**INDEPENDENT_BACKUP = NOT_CONFIGURED**  
**B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED**  
**PHASE_5 = NOT_STARTED**

Próximo passo recomendado, em modo alto ou médio conforme escopo: **pré-gate de execução local/CI inteiramente sintética, desenho definitivo do runner e ledger, e verificação read-only de quotas**, sem mutação Neon. Somente então submeter Gate 1 ao titular.

**Fim do Documento 112.**
