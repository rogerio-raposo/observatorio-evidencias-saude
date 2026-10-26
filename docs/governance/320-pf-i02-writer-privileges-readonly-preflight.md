# Documento 320 — PF-I02-I01: preflight de papéis e fronteira de writer Q0→Q1

**Data:** 2026-10-26. **Natureza:** inspeção conectada somente leitura; nenhuma mudança de role, grant, credencial, schema ou dado. **Base:** Doc. 319/CP300.

## Ambiente e evidência
Neon projeto `weathered-boat-65779510`, branch sintética `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`. Uma transação `SET TRANSACTION READ ONLY` retornou `transaction_read_only=on` sob `oes_sandbox_owner`. Consultas apenas a `pg_roles`, `pg_class` e `pg_namespace` (metadados). Freshness Gate anterior: main idêntico a `14691180e25131c8f3e0df5a4bc7330c59caa553`.

## Inventário observado
- `oes_sandbox_owner`: LOGIN, CREATEDB, CREATEROLE, INHERIT e BYPASSRLS; proprietário de `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version` e `investigation.investigation`. **Proibido utilizá-lo em Django.**
- `oes_pg_a4_reader`: LOGIN, sem CREATEDB/CREATEROLE/BYPASSRLS; `SELECT` explícito em `core.entity` e `core.entity_version`. Não demonstra permissão de escrita nem de leitura de Question completa.
- `oes_e6_capture_login`: NOLOGIN, sem privilégios administrativos exibidos; controle experimental E6, não escritor Q0/Q1.
- `oes_t2a2_app`: não apareceu entre os papéis consultados nesta base; concessões D1/T2-A2 pertencem a outro projeto.
- `investigation.question`, `investigation.question_version` e `investigation.investigation` exibiram ACL de tabela nula, propriedade do owner. ACL nula não substitui auditoria de privilégios efetivos por papel, grupos, PUBLIC, schemas, funções e políticas RLS.

## Direção mínima
O fluxo Django Q0→Q1 requer nova identidade técnica **exclusiva de preparação**, distinta do proprietário, PG-A4 e E6, com privilégios estritamente necessários às transações T1/T2. A matriz final deverá considerar `USAGE` nos schemas, `SELECT` de linhas permitidas, `INSERT` nas quatro tabelas Question/Entity, UPDATE somente do status/validade de versões antigas, e `SELECT`/operações de auditoria e idempotência somente após seu desenho aprovado; vedar DDL, `DELETE/TRUNCATE`, administração, tabelas Investigation, produtos e captura E6. Testar negativas efetivas antes de usar em runtime.

A autenticação humana Django ainda é apenas scaffold offline; deve ser efetivada com banco/sessões, grupo e permissão explicitamente registrados e política de acesso. Idempotência, concorrência e auditoria confiáveis precisam ser implementadas e verificadas no fluxo integrado. Nada disso foi autorizado nem executado nesta atividade.

## Parecer e próximo gate
**`Q0_Q1_WRITER_PRIVILEGE_PREFLIGHT_READ_ONLY_COMPLETE`**. Não repetir T1/T2 sob owner. Próxima decisão: pacote único de implementação para writer mínimo e autenticação integrada com pré-verificações e autorização separada de criar role/grants/credenciais e código Django. Marco B aberto; E9 NO-GO; readiness `NOT_READY`; A3 não realizada.
