# OES — CP304 | W2a preparação de autorização e recuperação controlada

**Data:** 2026-10-26. **Anterior:** CP303. **Base GitHub verificada antes da publicação:** `e6bb4125793759e8427e49bef28445675fb58805` (main idêntica). **Escopo:** PF-I02-W2a A1–A3 e preflight conectado A2, sem provisionamento. **Status:** `W2A_PREFLIGHT_COMPLETE / ROLE_PROVISIONING_NOT_AUTHORIZED`.

## Evidência retomada e execução autorizada
- CP303 e Docs. 330–334 continuam válidos; ledger `investigation.question_command_receipt` foi criado anteriormente, não recriar.
- Autorização nominal: `APPROVED — OES / PF-I02-W2a-A2 / NEON_CATALOG_ACL_READ_ONLY_PREFLIGHT / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / metadata only / no CREATE ROLE / no GRANT or REVOKE / no SET ROLE / no DDL or DML / no credentials / no Django / no HTTP / no E9 / no paid services / fail closed`.
- Neon get_branch confirmou `br-gentle-hall-b6jaxehf`, branch sintética não default, projeto correto. SQL transacional iniciou com `SET TRANSACTION READ ONLY`; primeira chamada multicomando foi rejeitada antes de executar; uma tentativa com `has_schema_privilege('PUBLIC',...)` falhou porque PUBLIC não é um papel nominável nessa função; refeito por inspeção ACL, sem mutações.
- Banco `oes_sandbox`; `current_user=session_user=oes_sandbox_owner`; `transaction_read_only=on`; `oes_qprep_writer` ausente; cinco tabelas presentes.
- `core.entity` e `core.entity_version`: owner `oes_sandbox_owner`, SELECT previamente concedido a `oes_pg_a4_reader`; as três tabelas `investigation.question`, `question_version`, `question_command_receipt` têm relacl NULL (privilégios padrão de owner). Nenhum grant direto a PUBLIC detectado nas cinco ACLs (aclexplode de ACLs/defaults).
- Schemas: `core` ACL owner UC e `oes_pg_a4_reader` U; `investigation` nspacl NULL; `public` USAGE para PUBLIC, sem CREATE público. Database `oes_sandbox` possui CONNECT público (`=Tc`), o que NÃO implica acesso às tabelas. Não revogar ACL preexistente.
- Cinco tabelas sem RLS e sem políticas; nenhum `attacl` individual presente no preflight. `tr_question_entity_type` em `investigation.question` usa `core.assert_entity_type()`, SECURITY INVOKER; registro documental anterior: EXECUTE por PUBLIC, referência qualificada a `core.entity`.
- `oes_sandbox_owner` é LOGIN, CREATEROLE, BYPASSRLS, membro de `neon_superuser` e mantém memberships administrativas preexistentes E6/PG-A4. Nunca usar owner como identidade Django/runtime. Papel de writer ainda não existe, logo seus privilégios efetivos não foram testados.

## Pacote candidato W2a — somente design; NÃO EXECUTAR
Pré-condições em novo gate, imediatamente antes da execução: confirmar projeto/branch via API Neon, DB/session/current_user e transação; ausência de writer e de grants/memberships inesperados; colunas `core.entity_version(version_status, valid_to)`; nomes/owners das cinco tabelas; relações e triggers; concedente apto. A inspeção não valida plenamente sequências, funções indiretas ou estrutura integral, que devem ser consideradas antes de qualquer teste de INSERT. Divergência => HOLD.

SQL de provisionamento candidato, exclusivamente após autorização nominal adicional (um único transaction boundary do executor):
```sql
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '10s';
DO $$
BEGIN
 IF current_database() <> 'oes_sandbox' OR current_user <> 'oes_sandbox_owner'
    OR EXISTS (SELECT 1 FROM pg_roles WHERE rolname='oes_qprep_writer')
 THEN RAISE EXCEPTION 'W2a HOLD: environment, grantor or role mismatch'; END IF;
END $$;
CREATE ROLE oes_qprep_writer NOLOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT CONNECT ON DATABASE oes_sandbox TO oes_qprep_writer;
GRANT USAGE ON SCHEMA core, investigation TO oes_qprep_writer;
GRANT SELECT, INSERT ON TABLE core.entity, core.entity_version,
 investigation.question, investigation.question_version,
 investigation.question_command_receipt TO oes_qprep_writer;
GRANT UPDATE (version_status, valid_to) ON core.entity_version TO oes_qprep_writer;
COMMIT;
```
A existência de COMMIT no texto **não é autorização para executá-lo**. Somente o conector apontado à branch autorizada e sob novo approval poderá executar. Inexistência de LOGIN/credenciais/membership; sem Django, DML, HTTP ou E9.

## Recuperação limitada — candidato, NÃO EXECUTAR
Em caso de falha antes do COMMIT: ROLLBACK transacional. Em caso de commit confirmado, operar somente sob autorização explícita de cleanup, após comparar ACLs e concedentes com o snapshot imediatamente anterior. O revogador deve ser o mesmo concedente e grants adicionais/divergências resultam em HOLD, sem CASCADE.

```sql
-- EXECUÇÃO CONDICIONAL, PROIBIDA SEM APPROVAL SEPARADO.
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '10s';
DO $$
BEGIN
 IF current_database() <> 'oes_sandbox' OR current_user <> 'oes_sandbox_owner'
    OR NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='oes_qprep_writer')
 THEN RAISE EXCEPTION 'W2a cleanup HOLD: database, grantor or missing role'; END IF;
END $$;
REVOKE UPDATE (version_status, valid_to) ON core.entity_version FROM oes_qprep_writer;
REVOKE SELECT, INSERT ON TABLE core.entity, core.entity_version,
 investigation.question, investigation.question_version,
 investigation.question_command_receipt FROM oes_qprep_writer;
REVOKE USAGE ON SCHEMA core, investigation FROM oes_qprep_writer;
REVOKE CONNECT ON DATABASE oes_sandbox FROM oes_qprep_writer;
-- NÃO DROP ROLE neste bloco. COMMIT somente após conferir efeito e contexto.
COMMIT;
```
Depois de REVOKE, verificar novamente `pg_auth_members`, `pg_shdepend`, `pg_default_acl` e todas as concessões relevantes ao papel; para `DROP ROLE oes_qprep_writer`, exigir autorização específica e ausência de dependências/atribuições e uso inesperado. `DROP ROLE` normal falhará se persistirem dependências: tratar como HOLD, não usar `CASCADE`, `DROP OWNED` ou `REASSIGN OWNED`. Revogação não remove `CONNECT` efetivo via PUBLIC; teste negativo deverá distinguir grants diretos e direitos herdados de PUBLIC.

## Próximo gate e fronteiras
1. Revisar pacote para aprovação nominal de **W2a ROLE_AND_GRANTS_ONLY**: role NOLOGIN + grants candidatos, transação única, catálogo pre/post de ACL, verificações negativas, reversão grantor-aware; nenhuma operação de leitura de dados ou DML. Teste de `SET ROLE` exige autorização específica, independente de papel/grants.
2. A prova de permissões efetivas do writer somente após criação autorizada; `SET ROLE` não prova autenticação LOGIN. Escrita real, integração PostgreSQL/Django, usuários humanos, concorrência/idempotência e segregação multiusuário seguem gates futuros.
3. Imutáveis: Marco B aberto, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`, E9 NO-GO, A3 não realizada, nenhum pesquisador vinculado, sem novos dados factuais ou serviços pagos.

**Ponto exato de retomada:** após ativar CP304, parar obrigatoriamente e aguardar `Prossiga`. Em novo passo, revisar criticamente suficiência de W2a com autorização nominal específica, sem inferir aprovação a partir de CP304. Ponteiro canônico: `archive/handoffs/oes/README.md`.
