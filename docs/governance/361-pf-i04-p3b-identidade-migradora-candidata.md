# Documento 361 — PF-I04-A2/P3b | Papel migrador e ciclo de vida propostos
**Data:** 2026-10-27. **Status:** CANDIDATO DOCUMENTAL; ROLE/GRANT NÃO AUTORIZADOS. **Checkpoint:** CP315.

## Contexto
P3a concluiu criação de schema vazio `oes_app` no Neon sintético `weathered-boat-65779510` / `br-gentle-hall-b6jaxehf` / `oes_sandbox`. O usuário autorizou P3b (migrations administrativas Django), mas NÃO a criação de papéis/grants ou mudança de credenciais. Workflow do owner foi suspenso no commit `e5de1732b9afe5fb9a25e217043d21d196a6e795`; não reativar antes de novo desenho aprovado.
Preflight somente SELECT nesta atividade: current_user `oes_sandbox_owner`; `oes_app` owner `oes_sandbox_owner`, objetos=0; candidato `oes_django_migrator` ausente; owner tem CREATE.

## Proposta A — papel de migração isolado
Criar `oes_django_migrator` com LOGIN temporário, sem SUPERUSER, CREATEDB, CREATEROLE, REPLICATION ou BYPASSRLS, concedendo apenas USAGE e CREATE no schema `oes_app` e CONNECT no banco (caso necessário). Não conceder USAGE/CREATE em `core` ou `investigation`, nem DDL em `public`; não conceder membership ao owner; não modificar `oes_qprep_login`.

**ATENÇÃO À PROPRIEDADE:** o papel criará tabelas, índices e sequências Django como owner. REVOKE CREATE após migrations não elimina poderes de owner sobre esses objetos. `ALTER ROLE ... NOLOGIN` é o caminho inicial de desativação; exclusão de papel exigiria reassignment explícito, inventário e autorização posterior.

## SQL candidato, NÃO EXECUTAR
```sql
-- Apenas após autorização separada de ROLE/GRANT, alvo e preflight.
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '10s';
CREATE ROLE oes_django_migrator LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT CONNECT ON DATABASE oes_sandbox TO oes_django_migrator;
GRANT USAGE, CREATE ON SCHEMA oes_app TO oes_django_migrator;
COMMIT;
```
Sem senha na instrução: o provisionamento de credencial deve ocorrer por procedimento seguro de Neon, sem exposição em SQL versionado, logs, resposta ou chat. O SQL somente configura capacidade de login; não estabelece um segredo. A viabilidade de criar `LOGIN` sem senha e definir uma credencial com procedimento separado deve ser confirmada antes de aprovar.

## Validações necessárias antes de qualquer execução
1. Confirmar novamente o branch explícito não primário, banco, executor, schema vazio e ausência do nome do papel.
2. Consultar privilégios efetivos do novo papel, inclusive herdados e `public` (após autorização de criação), e demonstrar conexão com `search_path=oes_app` sem fallback em `public`.
3. Fixar PostgreSQL 18 do Neon como alvo; evidência CI anterior é PostgreSQL 16. Não considerar equivalência demonstrada.
4. Corrigir runner: não utilizar `oes_sandbox_owner`; endpoint sintético revisado, segredo temporário do **migrador** e gate desabilitado até autorização de role/credential.
5. Execução Django migrations apenas após comprovar 15 migrations pendentes e schema vazio, sem `migrate evidence` mutante. Após P3b: inventário completo de objetos, `django_migrations`, `auth_permission`, ownership e ausência em `public`.
6. Desabilitar LOGIN e revogar CREATE/USAGE do schema do migrador apenas mediante autorização explícita de desativação, idealmente após postflight. Auditar residual de ownership. Sem DROP automático.

## Alternativa de governança
Para evitar credencial permanente, manter `oes_django_migrator` como owner sem LOGIN após operação; futuras migrations demandarão nova janela de ativação e credencial descartável, com aprovação delimitada. Possível desenho mais complexo com owner NOLOGIN + migrador temporário separado foi diferido por proporcionalidade.

## Decisão solicitável futuramente (não aprovada)
`APPROVED — OES / PF-I04-A2 / P3b_MIGRATOR_ROLE_GRANTS_ONLY / synthetic branch br-gentle-hall-b6jaxehf / oes_sandbox / create oes_django_migrator / CONNECT database + USAGE,CREATE oes_app only / no password mutation / no migrations in this substep / no production / fail closed`.

**Estado:** P3b migrações autorizadas em princípio mas execução **HOLD** até provisão segura do migrador; nenhuma role, grant, credential ou migration executada nesta atividade; P4 não autorizado. Gates Marco B OPEN; G2-P2B NO-GO; E9 NO-GO; readiness NOT_READY.
