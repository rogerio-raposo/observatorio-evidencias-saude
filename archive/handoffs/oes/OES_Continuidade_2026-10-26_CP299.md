# OES — CP299 | PF-I02-I01-C migração Q0-only sintética

**Data:** 2026-10-26. **Anterior:** CP298. **Documento principal:** `docs/governance/317-pf-i02-i01-c-resultado-migracao-q0-sintetica.md`.

## Estado
Com autorização expressa do responsável, DDL exato do Documento 316 aplicado **uma única vez** no Neon `weathered-boat-65779510`, branch sintética `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`; `production` não acessada. Preflight/postflight em transações `READ ONLY`: `preparation_stage NOT NULL DEFAULT legacy_complete`, `normalized_text` nullable sob CHECK Q0/Q1, `original_text` NOT NULL. Tabela Question Version tinha zero linhas antes/depois. `SYNTHETIC_Q0_SCHEMA_MIGRATION_APPLIED_VERIFIED`. Sem DML de perguntas, grants, roles, credenciais, Django ou deploy.

PF-I02-I01-A apenas scaffold de auth offline com CI success; B desenho de esquema incorporado sinteticamente em C, não em produção; D não iniciado. Próximo: decidir validação restrita de transação sintética e modelo de identidade técnica, mediante autorização específica; não repetir migração.

## Invariantes
Marco B aberto; E9 NO-GO; A3 não realizada, pesquisadores indisponíveis; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`. `Prossiga` habilita uma atividade; Freshness Gate obrigatório antes de mutações.
