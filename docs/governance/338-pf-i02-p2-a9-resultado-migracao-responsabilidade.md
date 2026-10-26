# Documento 338 — PF-I02-P2-A9: resultado da migração sintética de responsabilidade

**Data:** 2026-10-26. **Estado:** `SYNTHETIC_SCHEMA_MIGRATION_APPLIED_VERIFIED`. Base: Documento 337; CP307.

## Autorização nominal
`APPROVED — OES / PF-I02-P2-A9 / SINGLE_SYNTHETIC_QUESTION_RESPONSIBILITY_SCHEMA_MIGRATION / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / exact Doc337 DDL only / READ ONLY preflight and postflight / one atomic transaction / no DML or backfill / no roles or grants / no SET ROLE / no credentials / no Django connection / no HTTP write / no E9 / no paid services / fail closed / post-commit reversal requires separate approval`.

## Evidência da execução conectada autorizada
- Freshness Gate: `main` idêntica ao HEAD `27706729783196a7cbd25b6bccf4962f831eaf39`; branch Neon `br-gentle-hall-b6jaxehf`, nome `oes-pg-a3-synthetic-20261024`, `default=false`.
- Preflight em transação com `SET TRANSACTION READ ONLY`: `db=oes_sandbox`, `current_user=oes_sandbox_owner`, `transaction_read_only=on`, tabela `investigation.question` existente e pertencente ao owner, coluna `responsible_actor_id` ausente e constraint `ck_pf_i02_question_responsible_actor` ausente.
- Única transação DDL via `run_sql_transaction`, encapsulamento transacional fornecido pelo conector: `SET LOCAL lock_timeout='2s'`; `SET LOCAL statement_timeout='10s'`; `ALTER TABLE investigation.question ADD COLUMN responsible_actor_id text NULL, ADD CONSTRAINT ck_pf_i02_question_responsible_actor CHECK (responsible_actor_id IS NULL OR length(btrim(responsible_actor_id)) BETWEEN 1 AND 128)`. Retorno sem erro.
- Postflight em **nova transação READ ONLY**: `responsible_actor_id` tipo `text`, `is_nullable=YES`, `column_default=NULL`; constraint presente, `pg_get_constraintdef` confirma condição `IS NULL OR length(btrim(...)) BETWEEN 1 AND 128`.
- Nenhuma leitura de registros de usuários ou perguntas; nenhum DML, backfill, papel, GRANT, REVOKE, SET ROLE, credencial, conexão Django, HTTP ou E9. Sem rollback ou cleanup pós-commit.

## Limites e próximos gates
`created_by` é autoria histórica; `responsible_actor_id` representa responsável atual somente no contrato sintético aprovado em Doc.336. NULL é ausência de autorização, não permissividade. A coluna não implementa por si só a autorização; a porta P2 segue incompleta. W2a writer NOLOGIN/ACL permanece sem UPDATE em `investigation.question`. Revogação administrativa e controle de concorrência necessitam desenho e aprovação independentes; RLS ausente, sem prova de segregação multiusuário. CI anterior 40271463247: 109/109 PASS offline, anterior à migração e sem testes PostgreSQL conectados.

Eventual reversão da coluna pós-commit **não autorizada**, sem DROP automático. Próxima atividade: avançar em testes/implementação offline, condicionada a contrato de autorização e sem antecipar escrita conectada; não repetir DDL.

Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; A3 ausente; E9 NO-GO.
