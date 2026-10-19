# 111 — Plano de sequenciamento de migrations e branch sintética Neon

**Projeto:** OES — Fase 4  
**Data:** 19/10/2026  
**Modo:** médio  
**Status:** **PREPARED_ONLY — NO_NEON_BRANCH_OR_SCHEMA_WRITE — EXPLICIT_WRITE_GATE_PENDING**  
**Referências:** CP154 / Documento 110; Documento 107 / owner authorization synthetic-only; Documento Arquitetura 30 (migrações); workflow `.github/workflows/validate-s5.yml`.  
**HEAD de entrada:** `678a0d8fb007b733e7aa2be10db42d5faceafc7f`.

## 1. Freshness Gate e estado operacional

Ponteiro CP154 e README/STATE/CHANGELOG coerentes, sem alterações posteriores ao checkpoint de entrada. Neon Free `oes-sandbox`, região `aws-sa-east-1`, PostgreSQL 18.6, database `oes_sandbox`. Consulta SQL read-only `2026-10-19T12:11:00.625Z` confirmou **zero tabelas de aplicação** e cerca de 7536 kB de banco. Projeto tem apenas branch padrão `production` (nome do fornecedor, não operação factual do OES), com conteúdo de usuário ainda não implantado. Nenhuma DDL/migration/CREATE BRANCH foi executada por este checkpoint.

## 2. Sequenciamento efetivo da CI

O workflow canônico aplica exatamente **36 arquivos de entrada**, dos quais 1 baseline (`database/poc-s1.sql`) e 35 wrappers/migrations numeradas 002–036. Ordem foi extraída das linhas 284–319 de `.github/workflows/validate-s5.yml` em `main`.

**Manifesto versionado:** `database/f4-neon-sandbox-schema-migration-manifest.txt`, contendo a sequência completa em ordem determinada, com um arquivo por linha. O manifesto não é arquivo SQL nem autoriza execução.

As migrations abaixo são **wrappers compostos**, processados com `psql -f` e diretivas relativas `\ir`:
- 031 → `031a_propagation_core.sql`, `031b_propagation_signal_adapter.sql`, `031c_rebaseline_core.sql`, `031d_propagation_rebaseline_helpers.sql`, `031e_rebaseline_child_validators.sql`;
- 032 → `032a_temporal_calibration_core.sql`, `032b_temporal_cadence_contract.sql`, `032c_temporal_sla_contract.sql`, `032d_temporal_sla_runtime.sql`;
- 033 → `033a_temporal_observation_core.sql`, `033b_temporal_measurement_core.sql`, `033c_temporal_observation_guards.sql`, `033d_temporal_observation_helpers_views.sql`, `033e_temporal_observation_issue_validators.sql`.

Somam-se **14 fragmentos internos**. Eles **não são novas migrations independentes** e não devem ser executados duas vezes. O executor `mcp Neon run_sql` utiliza prepared statement de comando único e não interpreta `\ir`; portanto **não** suporta executar a sequência original por envio direto de wrappers. Um agente de execução `psql` local/seguro, com arquivos completos e hashes fixados, é necessário para fidelidade ao workflow.

## 3. Separação obrigatória entre schema e dados

A sequência 001–036 é apenas candidato de schema e funções. **Não** executar no sandbox por esta decisão:
- `database/f2b-fixtures.sql`, `database/s4-fixtures.sql`, `database/s5-fixtures.sql` e demais `*-fixtures.sql`;
- casos reais históricos `database/f3-real-case-*.sql` e `database/f4-topi-n2-dcbti-*.sql`;
- arquivos de authority, corrective materialization, activation, first-measurement, OpportunityResolution ou scripts científicos factuais;
- smoke tests que criem temporariamente dados, salvo em branch descartável **expressamente autorizado** com cleanup verificado.

**Atenção:** o baseline ou migrations podem conter `GRANT`, seeds estruturais ou `DO`; devem passar por revisão de efeitos antes da execução. Não presumir que os 36 arquivos são somente DDL sem efeitos.

## 4. Gate técnico antes de qualquer mutation

**BRG-01 — Scope**: proprietário aprova especificamente criar branch Neon para schema sintético, nome `oes-schema-test` candidato, sem dados pessoais ou faturamento; verificar quotas atuais e possível consumo extra.
**BRG-02 — Branch**: usar fork/copy-on-write separado da branch default `production`; confirmar branch ID e database; não aplicar schema no default.
**BRG-03 — Controle de privilégio**: role migrator delimitada, não armazenar senha no GitHub/chat; conexão TLS autenticada e auditada; não usar owner administrativo como executor casual.
**BRG-04 — Manifest/Hashes**: fixar HEAD GitHub, arquivos 36 + 14 fragmentos, SHA-256 de bytes reais e psql client version; validar ordem e caminhos.
**BRG-05 — Compatibilidade**: verificar PostgreSQL 18, extensões/schemas, permissões, comandos transacionais, `\ir`, segurança e possibilidade de reexecução sem drift.
**BRG-06 — Ledger**: antes de cada etapa, definir `ops.schema_migration` (migration_id, filename, sha256, applied_at/by, server_version, status), com controle de repetição e falha. **Ledger ainda não criado**.
**BRG-07 — Execução por etapas**: baseline e 002–030, depois 031–036; parar no primeiro erro com `ON_ERROR_STOP=1`, preservar stdout/stderr e timestamps; não prosseguir com estado parcial sem reconciliação.
**BRG-08 — Rebuild e restore**: validar em branch descartável com regressões mínimas adequadas; backup externo, restore independente e integridade de Artifacts continuam ausentes e bloqueiam uso factual.
**BRG-09 — Finanças**: não criar branch se não houver comprovação de que Free comporta o ensaio, sem cartão/upgrade ou custo; branch pode compartilhar storage mas consumir compute; nunca afirmar custo zero garantido sem observação de quota.
**BRG-10 — Proibição factual**: B1R1 expirou `EXPIRED_NOT_EXECUTED`; novo Epoch, cronograma e autoridade dependem de nova governança em modo alto, após ODB integral.

## 5. Protocolo futuro proposto (NÃO executar neste checkpoint)

1. Aprovar explicitamente branch `oes-schema-test` sob escopo sintético/no paid services.
2. Criar branch via Neon somente após BRG-01/09. Conferir ID e estado.
3. Executar preflight read-only da branch e verificar que não há schema OES preexistente.
4. Verificar hashes de baseline/wrappers/fragmentos num checkout imutável de `main`.
5. Revisar comandos e seeds, preparar ledger com política de falha.
6. Aplicar migrations com cliente `psql` que suporte `\ir` e logs/controle de versão, ou equivalente tecnicamente demonstrado; nenhuma reconstrução via execução ad hoc de segmentos sem hash.
7. Executar smoke tests exclusivamente sintéticos; verificar constraints, functions, triggers e reconciliar ledger.
8. Encerrar/descartar branch apenas após revisão de evidências; jamais confundir branch com backup externo.

**Alternativa para evitar branch/quota antes da aprovação:** revisar estaticamente e ensaiar em Postgres 18 temporário local ou CI, claramente sintético e sem conexão ao projeto Neon. Isso reproduz funcionalidade estrutural, não substitui prova de deployment Neon.

## 6. Estado, conclusão e próxima decisão

> **MIGRATION_SEQUENCE_DOCUMENTED = 36_ENTRY_FILES_14_SUBFRAGMENTS**  
> **NEON_PROJECT_PROVISIONED = YES_SANDBOX_ONLY**  
> **NEON_TEST_BRANCH = NOT_CREATED**  
> **NEON_SCHEMA_MIGRATION = NOT_STARTED**  
> **NEON_SCHEMA_MIGRATION_LEDGER = NOT_CREATED**  
> **NEON_SANDBOX_B1R1 = EXPIRED_NOT_EXECUTED**  
> **OPERATIONAL_DATABASE_READY = NO**  
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**  
> **PHASE_5 = NOT_STARTED**

**Próximo bloco em modo médio, após `Prossiga`:** revisar riscos de execução da sequência e preparar pacote específico de autorização BRG-01/09, sem DDL tácita. Pausa obrigatória após checkpoint.

**Fim do Documento 111**

