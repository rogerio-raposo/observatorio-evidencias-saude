# 114 — Preparação de prova CI do inventário e bloqueio do ensaio PostgreSQL 18

**OES / Fase 4 / Modo médio / 2026-10-19**  
**Status:** CI_WORKFLOW_COMMITTED — CI_PROOF_NOT_CONFIRMED — PG18_RUNNER_BLOCKED_LOCAL — NO_NEON_WRITE.  
**Entrada:** CP157, Documento 113, HEAD `3ecb187d04edc75a9b957bef5c252d746607d76e`.

## 1. Freshness Gate
Comparação do HEAD CP157 com `main` no início do bloco: `identical`, zero commits posteriores; ponteiro CP157 e checkpoint integral conferidos.

## 2. Evidências locais
O comando `python -m unittest discover -s tests -v` no diretório local `/mnt/data/oes_preflight` executou 7 testes sintéticos do pré-gate, todos `OK`. A execução somente cobriu fixtures artificiais; não prova os hashes dos 50 SQL nem PostgreSQL 18. A tentativa de acessar o remoto GitHub diretamente do container via `git ls-remote` falhou por falta de resolução DNS; portanto **nenhum checkout integral foi obtido localmente**. `pg_config --version` retornou PostgreSQL 17.11 e `psql` não estava instalado ou acessível; **nenhum ensaio PostgreSQL 18 ou ledger persistente foi executado**.

## 3. Preparação da prova de inventário na CI
Adicionado workflow `.github/workflows/f4-neon-offline-preflight.yml` com:
- `actions/checkout@v4`, `persist-credentials: false`, `fetch-depth: 1`;
- `actions/setup-python@v5`, Python 3.13;
- sete testes locais sintéticos (a executar na CI);
- chamada read-only `python scripts/oes_neon_migration_preflight.py --expected-head "$GITHUB_SHA"` no checkout integral;
- inventário JSON dos 36 entrypoints e 14 fragmentos e SHA-256, com `sql_executed=false` e `neon_accessed=false`;
- captura de SHA do commit, versão do Python e arquivo de checksum como artifact;
- permissões `contents: read`, sem segredo Neon, sem `DATABASE_URL`, sem SQL ou comandos de deploy.

Workflow é acionável por `workflow_dispatch` e por alteração dos caminhos listados no próprio workflow. **Não foi obtido identificador verificável de run/log/artifact nesta etapa**. Não classificar a prova CI como `PASS` até existir run `success`, verificação de steps e checksums. A validação do YAML perante a plataforma é também pendente até o run.

## 4. Runner/ledger e bloqueios
O desenho lógico de ledger do Documento 113 permanece **DESIGN_ONLY**. Nenhum script de execução de migration, ledger SQL, teste efetivo PG18 de locks, interleaving COMMIT/ledger, reversão, restauração ou migração real foi implementado/realizado. Não prometer atomicidade entre processos. Deve-se validar idempotência e estado incerto em ambiente descartável antes de qualquer proposta de deploy.

## 5. Estados BRG
- BRG-04: verificador e workflow disponíveis, mas **PROOF_PENDING** — SHA-256 factual do checkout completo não observado.
- BRG-05: **BLOCKED_NO_PG18_LOCAL_PSQL**, validação PG18 pendente.
- BRG-06: **LEDGER_DESIGN_ONLY**, testes de lock/falha pendentes.
- BRG-07: **RUNNER_NOT_IMPLEMENTED**, nenhum SQL executado.
- BRG-09: leitura anterior Free v3/10 branches preservada, billing console pendente.
- BRG-01: aprovação `create-branch-only` pendente; BRG-02: branch inexistente; BRG-03/08: não prontos; BRG-10: restrição synthetic-only preservada.

## 6. Continuidade
Próxima atividade: localizar um run verificável do novo workflow, conferir artifacts e produzir manifesto SHA-256 real; caso não se possa executar/acessar CI, registrar bloqueio e considerar outro método verificável. Preparar teste PG18 exclusivamente local/CI sem Neon após garantir executor e isolamento. Retornar a modo alto para decisões de arquitetura de ledger, segurança e custos.

**Nenhum CREATE BRANCH, CREATE ROLE, DDL/DML, migration, ledger ou consulta científica factual no Neon.** B1R1 `EXPIRED_NOT_EXECUTED`; backup independente não configurado; Fase 5 não iniciada.

**Fim do Documento 114.**
