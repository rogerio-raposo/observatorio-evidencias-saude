# 113 — Pré-gate offline do executor psql, contrato de ledger e diligência Free Neon

**OES | Fase 4 — Protocolo de Atualização**  
**Data:** 2026-10-19  
**Modo:** alto  
**Status:** **OFFLINE_STATIC_TOOLING_PREPARED_AND_SYNTHETIC_UNIT_TESTED — LEDGER_DESIGN_PROPOSED — NO_NEON_WRITES**  
**Base documental:** CP156 / Documento 112; HEAD de entrada `cd7855c1fa366716569e35acbd5f81337b866caa`.  
**Escopo:** pré-gate estático/local com especificação não executável de ledger/runner. Proibidos CREATE BRANCH, CREATE ROLE, migrations, DDL, DML e qualquer operação científica factual no Neon.

## 1. Freshness Gate

A comparação do HEAD CP156 com a branch GitHub `main` retornou `identical`, 0 commits posteriores no início do bloco. O ponteiro indicava CP156; seu documento integral e Documento 112 foram relidos. Nada modifica decisões congeladas.

## 2. Artefatos novos

- `scripts/oes_neon_migration_preflight.py`: verificador **somente leitura**, biblioteca padrão Python, sem dependência Neon ou execução SQL. Exige `--expected-head` de 40 hexadecimais e checkout Git limpo para a interface de linha de comando. Confronta exatamente 36 caminhos do manifesto com 36 comandos `psql -f` do workflow S5; valida inclusão dos 14 fragmentos de 031–033 na ordem prevista; bloqueia fragmentos ausentes, caminhos inseguros, `\i` não previsto e inclusão aninhada; computa SHA-256 dos bytes de cada arquivo e digest do inventário. Produz JSON com `status=STATIC_INVENTORY_VALIDATED_ONLY` e `sql_executed=false`.
- `tests/test_oes_neon_migration_preflight.py`: **7 testes unitários com árvores inteiramente artificiais**; nenhum arquivo SQL factual, nenhuma conexão, nenhuma CI GitHub ou migration.
- SHA Git blob dos arquivos publicados foi confrontado com `git hash-object` dos respectivos arquivos locais: identidade verificada, separadamente do teste unitário.
- Testes locais: `python -m unittest discover -s /mnt/data/oes_preflight/tests -v` = **7/7 OK** em Python 3.13.5, no ambiente temporário do assistente (caminho local não é localização canônica OES).
- CLI sem `--expected-head`: **BLOCKED**, exit code 2, sem conectar ao Neon.

**Limites de prova:** o teste não rodou em checkout integral do repositório nem em GitHub Actions; portanto ainda não computou o inventário SHA-256 factual dos 50 arquivos canônicos em um HEAD de checkout imutável. A ausência do cliente `psql` no ambiente local impede certificar o cliente ou um ensaio PostgreSQL 18. O verificador não executa SQL e não constitui runner de migrations. `PASS` de schema/deploy/rollback/restore não foi reivindicado. O script não foi integrado a workflow automatizado, deliberadamente.

## 3. Ledger proposto — contrato lógico, NÃO implantado

São conceitos distintos: (a) `maintenance.contract_epoch`, dados estruturais versionados pelas migrations 031/032; (b) o **futuro** ledger técnico `ops.schema_migration`. Não confundir epochs científicos/temporais com recibos de migração.

Proposta de esquema de ledger:
- **Identidade:** `migration_id` canônico, número sequencial 001–036, caminho de entrypoint, identificador do pacote; cada migration executada exatamente uma vez por branch.
- **Integridade:** `source_commit` de 40 hexadecimais, SHA-256 dos bytes do entrypoint, lista ordenada de {path, sha256} para cada `\ir`, SHA-256 agregado do inventário completo.
- **Ambiente:** Neon project ID, branch ID *não default*, database, server version, `psql --version`, role técnica sem segredo e instante UTC.
- **Evidências:** identificador de tentativa, estado e timestamps, exit code, hash/localizador de stdout/stderr com sanitização de segredos, fingerprint pós-condição de objetos, identidade técnica do agente e verificador.
- **Política:** tentativas append-only; `applied` imutável; caminhos/hashes alterados para mesmo migration_id significam DRIFT e exigem STOP. Não armazenar password, connection string, token nem payload clínico em logs/ledger.

Estados candidatos de tentativa: `prepared`, `in_progress`, `applied`, `failed_verified_rollback`, `uncertain_requires_reconciliation`. Esses nomes ainda são **proposta**, sem DDL aprovado.

### Falhas, atomicidade e concorrência

As migrations são arquivos `psql -f` separados no S5. Wrappers 031–033 incluem `BEGIN/COMMIT` e fragmentos `\ir`; 034 recria trigger sem transação explícita no arquivo. **Não assumir atomicidade da sequência 001–036** e não impor `psql --single-transaction` à série sem prova técnica.

O futuro runner deverá:
1. verificar branch ID, database, HEAD, SHA-256, ACL, TLS autenticado e ausência de migrations previas antes de cada execução;
2. adquirir controle efetivo de exclusividade (executor único e mecanismo de lock demonstrado, inclusive diante de subprocessos `psql`);
3. registrar intento durável em log externo antes do arquivo; iniciar `psql -X -v ON_ERROR_STOP=1 -f ...` com autenticação não impressa;
4. capturar exit code, timestamps, output completo com tratamento de segredos, verificar objetos/constraints/seed estrutural e somente então registrar `applied`;
5. se houver timeout, desconexão ou falha entre commit SQL e commit de ledger, classificar como `uncertain_requires_reconciliation` e **nunca reexecutar automaticamente**;
6. bloquear execução do próximo arquivo até reconciliação manual/automática **especificamente validada**; reconstruir branch descartável se necessário, sem tratar snapshots do provedor como backup independente.

Ainda não foi demonstrado mecanismo atômico de ledger e migration através de processos independentes, nem política final de lock; são **gates impeditivos**, não detalhes de implementação presumidamente resolvidos.

## 4. Neon Free: diligência read-only

Consulta direta à API Neon identificou projeto `oes-sandbox` (`weathered-boat-65779510`), `aws-sa-east-1`, PostgreSQL major 18, owner subscription `free_v3`, limite account-level de **10 branches**, única branch `production` (`br-wild-field-b6qg7k3p`), default e não protegida. Limite lógico do projeto: 1 GiB; compute da default consultado em estado `idle`, perfil de autoscaling 0,25–2 CU. Nenhum CREATE BRANCH, SQL, deploy ou alteração de recurso executado.

Fonte primária Neon de **02/10/2026**: https://neon.com/blog/neon-free-plan-1-gb-per-project informa 100 CU-h/mês/projeto, 10 branches/projeto e 1 GB/projeto. Os contadores fornecidos pela API não constituem um extrato de billing nem garantia do consumo disponível em tempo real; o owner ainda deve inspecionar no painel, antes de qualquer criação, plano efetivo, consumo/quota, risco de suspensão, exigência de cartão/upgrade e limites de projeto. **Não conectar cartão nem aceitar custo.**

**BRG-09 = PARTIALLY_VERIFIED_ACCOUNT_FREE_AND_BRANCH_LIMIT; BILLING_CONSOLE_CHECK_PENDING**. Uma segunda branch parece compatível nominalmente com o plano observado, mas a autorização permanece pendente.

## 5. Matriz de gates após o pré-gate

| Gate | Estado verificado | Bloqueador remanescente |
|---|---|---|
| BRG-01 | PENDING_OWNER | Aprovação específica *create-branch-only* ainda não obtida |
| BRG-02 | NOT_EXECUTED | Branch `oes-schema-test` ainda inexistente |
| BRG-03 | NOT_READY | Role migrator, TLS externo, ACL e segredos |
| BRG-04 | TOOLING_PREPARED / UNPROVEN_ON_REPO | SHA-256 reais em checkout fixado e execução integrada |
| BRG-05 | NOT_READY | Cliente psql disponível, testes PostgreSQL 18 e análise comportamental |
| BRG-06 | LOGICAL_CONTRACT_PROPOSED | Ledger, lock e reconciliação sem lacunas transacionais |
| BRG-07 | RUNNER_NOT_IMPLEMENTED | Log externo, stop-on-error, evidências e fail-closed |
| BRG-08 | NOT_READY | Backup independente e restauração não comprovados |
| BRG-09 | PARTIAL_READONLY | Plano free_v3 e limite 10 observados; saldo/billing no console pendentes |
| BRG-10 | GUARD_ACTIVE | Synthetic-only, B1R1 expirado, nenhuma operação científica factual |

## 6. Correção prospectiva de notação

O CP156 e o Documento 112 contêm a representação editorial `\ir` em alguns trechos onde o comando real psql é **uma barra invertida** seguida de `ir`, escrito literalmente `\ir`. Os SQL wrappers observados no repositório contêm o comando real correto. Não reescrever checkpoints imutáveis; esta nota esclarece a notação para qualquer executor futuro e não altera a semântica histórica.

## 7. Decisão e continuidade

O presente bloco foi estritamente preparatório. O modelo de autorização do Documento 112 permanece **PREPARED_NOT_APPROVED**; um `Prossiga` não equivale à aprovação de criação de branch, roles, schema ou migrations.

**Próximo bloco recomendado:** ensaio do verificador em checkout integral imutável do GitHub e, caso disponível, validação sintética de runner/ledger em PostgreSQL 18 local/CI; revisão final de credenciais, lock e billing; só depois oferecer decisão de owner sobre criar `oes-schema-test`. Se o checkout/cliente/infraestrutura não estiverem acessíveis, registrar impedimento sem inventar PASS.

> **OFFLINE_PREFLIGHT_CODE = COMMITTED**  
> **SYNTHETIC_UNIT_TESTS = 7_OF_7_OK_LOCAL_ONLY**  
> **REAL_50_FILE_SHA256_RECEIPT = NOT_GENERATED**  
> **PSQL_RUNNER = NOT_IMPLEMENTED**  
> **LEDGER = DESIGN_ONLY_NOT_CREATED**  
> **NEON_BRANCH_OES_SCHEMA_TEST = NOT_CREATED**  
> **NEON_SCHEMA_MIGRATION = NOT_STARTED**  
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**  
> **B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED**  
> **PHASE_5 = NOT_STARTED**

**Fim do Documento 113.**
