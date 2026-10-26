# OES — CP302 | Ledger sintético e revisão da fronteira writer

**Data:** 2026-10-26. **Anterior:** CP301. **Fonte material:** Documento 331.

## Estado comprovado
Migração do ledger `investigation.question_command_receipt` executada uma vez, exclusivamente em `weathered-boat-65779510` / `br-gentle-hall-b6jaxehf` / `oes_sandbox`, segundo DDL do Documento 330. Preflight e pós-verificação READ ONLY confirmaram esquema, PK e FKs; zero DML, grants, roles ou Django. Estado `SYNTHETIC_LEDGER_SCHEMA_APPLIED_VERIFIED`.

Inspeção adicional somente leitura confirmou `oes_qprep_writer` inexistente, ausência de RLS nas tabelas `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version` e no ledger. ACLs das tabelas Question/ledger não exibem grants específicos; `oes_pg_a4_reader` mantém SELECT explícito em `core.entity` e `core.entity_version`. Isso não constitui prova de negativas efetivas para identidades ainda não provisionadas.

## Prioridade e restrições
Próximo gate: revisar política de leitura e permissões do writer, incluindo PUBLIC, memberships, triggers, funções e segregação de atores, antes de qualquer SQL de CREATE ROLE/GRANT. W1/W1B offline testados, sem driver PostgreSQL de escrita, sem login persistente, sem endpoint HTTP de escrita e sem uso operacional do ledger. Não repetir migrações ou ensaios já concluídos.

Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; A3 ausente; E9 NO-GO; readiness `NOT_READY`; Fase 5 `NOT_STARTED`. `Prossiga` delimita uma atividade; alterações conectadas exigem autorização nominal e Freshness Gate.
