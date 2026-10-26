# Documento 324 — PF-I02-W2a: pacote SQL candidato de papel mínimo e verificação negativa

**Data:** 2026-10-26. **Estado:** `DESIGN_ONLY_NOT_AUTHORIZED`. Base: Docs. 285, 319–323; CP300. **Todo SQL neste documento é para revisão: não executar, não criar papel ou credencial, não conceder privilégios.**

## Decisão técnica para reduzir risco
O primeiro W2a deve tratar **somente da fronteira de privilégios**, não de login e nem de processamento HTTP. Papel candidato `oes_qprep_writer`, inicialmente **NOLOGIN / NOINHERIT / NOBYPASSRLS / NOCREATEDB / NOCREATEROLE / NOSUPERUSER**, sem vínculo com owner, PG-A4 ou E6. O nome, não a existência, está reservado. Habilitar LOGIN e distribuir segredo exige autorização W2b distinta; NÃO executar `SET ROLE` como prova de autenticação independente.

Alvo exclusivo: projeto `weathered-boat-65779510`, branch sintética `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`. Branch `production` e outros projetos excluídos.

## Pré-condições obrigatórias (metadados sob READ ONLY)
- Confirmar `current_database()`, `current_user`, `transaction_read_only=on` e IDs exatos da branch/projeto fornecidos à conexão.
- Confirmar ausência de `oes_qprep_writer` e de memberships inesperados, ACLs herdadas via `PUBLIC`, schema USAGE/CREATE, owner de cada objeto, políticas RLS, triggers e funções chamadas por INSERT.
- Confirmar coluna `preparation_stage` e CHECK Q0/Q1 após Documento 317, sem interpretar `poc-s1.sql` como schema final.
- Resolver idempotência/audit trail e segregação de leitura **antes de homologar grants de runtime**; privilégios diretos por tabela não garantem isolamento por entidade. Caso não exista política adequada, manter HOLD.

## SQL candidato W2a — somente após aprovação separada
```sql
-- REVIEW ONLY, NEVER execute under a generic Prossiga
-- Preflight MUST establish role absence, grantor, target, PUBLIC and membership state.
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '10s';
CREATE ROLE oes_qprep_writer
  NOLOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;
GRANT CONNECT ON DATABASE oes_sandbox TO oes_qprep_writer;
GRANT USAGE ON SCHEMA core, investigation TO oes_qprep_writer;
GRANT SELECT, INSERT ON TABLE
  core.entity,
  core.entity_version,
  investigation.question,
  investigation.question_version
  TO oes_qprep_writer;
GRANT UPDATE (version_status, valid_to)
  ON TABLE core.entity_version TO oes_qprep_writer;
COMMIT;
```

**Ressalva de desenho:** os `SELECT` de tabela são **mais abrangentes que o isolamento por preparador requerido pelo PF-I02**. O bloco é candidato para verificação de privilégio em ambiente sintético, não para uso direto pelo Django. Deve ser revisto em conjunto com RLS/política de acesso ou API SQL controlada e a trilha persistente. O `GRANT CONNECT` pode coexistir com privilégios `PUBLIC`; verificar efetividade de negativas em vez de inferi-las.

## Pós-verificações exigidas
- Papel sem LOGIN, BYPASSRLS, CREATEDB, CREATEROLE, SUPERUSER, sem associação inadvertida com owner.
- Positivas de `CONNECT`, USAGE e DML exatamente previstos nas quatro tabelas; UPDATE só `core.entity_version.version_status` e `valid_to`.
- Negativas efetivas: `CREATE` schemas, DELETE, TRUNCATE, UPDATE de ID/autor/textos, e quaisquer operações em `investigation.investigation`, `investigation.investigation_version`, `investigation.investigation_question`, produtos/captura/E6. Inspecionar memberships, privilégios de `PUBLIC`, função EXECUTE e RLS.
- Banco de origem e contagens de registros sintéticos não devem mudar, e nenhum dado científico deve ser lido.

## Recuperação proposta — autorização específica necessária
Somente se os grants foram comprovadamente originados por essa operação, e após identificar grantor/memberships: revogar permissões concedidas e eliminar o papel **NOLOGIN** recém-criado se não usado; `DROP ROLE` somente após verificação de ausência de dependências, nunca `CASCADE`. Se estado ficar incerto, HOLD, sem operação automática. Nenhuma senha ou role LOGIN a limpar no W2a.

## Gate de autorização
O presente documento **não constitui pacote final executável** enquanto faltarem (a) revisão de ACL efetiva e triggers, (b) política de leitura por preparador e (c) idempotência/auditoria durável. Próxima atividade preferencial: completar essas três decisões em **um único ajuste de desenho**, sem novo protótipo. Só então solicitar autorização W2a para criar o papel e grants exatos; W2b para autenticação independente; W3 para integração. Nenhum comando do bloco foi executado.

Marco B aberto; E9 NO-GO; A3 não realizada; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
