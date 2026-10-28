# OES — PF-I04/P4-A42 — revisão estática e gate nominal candidato (HOLD)

**Data:** 2026-10-28 (America/Recife).  
**Escopo:** atividade interna 4 após CP328.  
**Autoridade documental:** `archive/handoffs/oes/README.md` -> CP328, `STATE.md`, `CHANGELOG.md` e fontes P4-A41.  
**GitHub HEAD verificado:** `25c7c907eabdf83ee0ae23254ddaede0ceaccbd3` (main).  
**Status:** `OFFLINE_STATIC_REVIEW_COMPLETE / NEON_SQL_NOT_EXECUTED / NOMINAL_EXECUTION_GATE_NOT_APPROVED / NOT_PERSISTED_IN_GITHUB`.

## 1. Artefatos e identidades

- Original A42 v1: `OES_PF-I04_P4-A42_BASELINE_NEON_CATALOG_READ_ONLY_CANDIDATE_HOLD.sql`, SHA-256 `2d3b98299db7ecf36026ff444e58f5672ef0a23ab8de6ee5c8298eb790ce753b` (histórico imutável).
- A42 v2: `OES_PF-I04_P4-A42_BASELINE_NEON_CATALOG_READ_ONLY_V2_REVIEW_HOLD.sql`, SHA-256 `360bb3f00e60c8ac2b4d20ff9b2c8b29dd557768d8a759db53824d1742ea6fd7` (histórico imutável).
- **Candidato preferencial A42 v3:** `OES_PF-I04_P4-A42_BASELINE_NEON_CATALOG_READ_ONLY_V3_STRICT_EXPIRY_HOLD.sql`, SHA-256 **`158ee2171543770f58cad66d5320a71e1383fc59546d65e3d9a9bd1c02e686d4`**, 11.413 bytes / 193 linhas.

A v3 preserva integralmente a semântica da v2, acrescentando (i) verificação do prazo de validade do login contra a data histórica exata `2026-10-31 03:30:53 UTC`, e (ii) condicionante `count(*) = 20` para o resumo de checagens. V2 apenas verificava prazo futuro: um prolongamento inesperado da credencial poderia passar despercebido. Não se alteraram as versões anteriores nem as fontes A37/A39/A41.

## 2. Confrontação com PF-I04/P4-A41

O candidato v3 contém uma única instrução `WITH ... SELECT`, 20 checagens com nomes distintos, resumo `CHECKS_PASS_REVIEW_REQUIRED` condicionado a todas as checagens, linhas INFO para roles, memberships, dependências e configuração. Sem comando de DDL/DML/GRANT/REVOKE/SET/BEGIN/COMMIT/ROLLBACK; sem tabelas Django/Q0; sem SELECT a `pg_authid` ou leitura de segredos. A referência ao catálogo `pg_authid` aparece apenas como `regclass` para qualificar dependências em `pg_shdepend`.

Checklist de controles:

1. Identidade de banco, `current_user` e `session_user` (3).
2. Versão PostgreSQL 18 (1).
3. Administrador não-superusuário com `CREATEROLE` (1).
4. Login trial existente, atributos mínimos e prazo válido *e idêntico ao histórico* (4).
5. Alvo sintético inexistente (1).
6. `pg_auth_members` para trial como membro e como papel concedido; no máximo um autogrant ao owner, ADMIN TRUE/INHERIT FALSE/SET FALSE (2).
7. Associação original única e OID 155649/grantor `cloud_admin`/flags preservados (2).
8. Ausência de membership de `oes_runtime` e de capacidades SET/USAGE do trial em migrator/owner (3).
9. Nenhuma sessão trial no momento da consulta, nenhuma configuração por papel e nenhuma dependência não-membership de trial (3).

**Total: 20**. A matriz above é exclusivamente uma revisão humana e lexical local; não se executou parser nem motor PostgreSQL 18 para A42.

### Limites do parecer

- O resultado `CHECKS_PASS_REVIEW_REQUIRED` não constitui autorização, nem prova a existência/usabilidade da senha; `rolvaliduntil` revela apenas o prazo de validade armazenado.
- O inventário INFO (roles, memberships, `pg_shdepend`, `pg_db_role_setting`) exige leitura humana; divergências resultam em `HOLD` e redesenho do candidato antes de qualquer setup.
- `pg_stat_activity` é uma observação pontual, não uma garantia de inexistência futura de conexões.
- O inventário de roles/memberships é global **à branch PostgreSQL**, não exclusivamente ao banco. A identidade da branch não pode ser inferida de `current_database()`.
- A41 foi validada em PostgreSQL 18 descartável; o SQL A42 v3 foi somente revisado estaticamente, não possui PASS PostgreSQL próprio.
- Nenhuma evidência catalogal atual de `oes_p4_trial_login`, autogrants ou OID 155649 foi coletada nesta atividade.
- Nenhum SQL Neon, alteração de role/credencial, GitHub secret, CI, workflow conectado, custo ou implantação foi iniciado.

## 3. Revalidação por metadados — sem execução SQL

Em atividade anterior, a integração Neon confirmou `weathered-boat-65779510` / `br-gentle-hall-b6jaxehf` / `oes_sandbox`, owner `oes_sandbox_owner`, PostgreSQL 18. Consulta específica `get_postgres_endpoint` confirmou ID `ep-wispy-dream-b6021bw0`, branch correta, host DIRECT `ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech`, tipo `read_write`, `pooler_enabled=false`, compute `idle`, `disabled=false`. O HTTP 401 de uma listagem distinta não demonstrou mudança de endpoint. Antes do gate de execução reconfirmar endpoint por metadados e SHA/HEAD, sem reutilizar automaticamente uma aprovação vencida.

## 4. Texto candidato de autorização nominal — NÃO APROVADO

> **APPROVED — OES / PF-I04/P4-A42 / ONE_NEON_READ_ONLY_CATALOG_BASELINE_V3 / project `weathered-boat-65779510` / branch `br-gentle-hall-b6jaxehf` / database `oes_sandbox` / compute `ep-wispy-dream-b6021bw0` DIRECT / role `oes_sandbox_owner` / exact SQL SHA-256 `158ee2171543770f58cad66d5320a71e1383fc59546d65e3d9a9bd1c02e686d4` / Neon integration `run_sql` one statement, one attempt, explicit project+branch+database+role+compute / catalog-only SELECT / no pg_authid reads, Django/Q0, data writes, roles or grants, secrets, workflows, re-runs or paid services / on error, unexpected identity, missing evidence or any HOLD: STOP, no retry / result for human review, no subsequent setup or postflight authorization.**

O texto acima é **proposta**, não autorização efetiva. O usuário deverá fornecer sua própria aprovação específica depois de avaliar o arquivo final persistido, a viabilidade do canal e a ausência de custos adicionais.

## 5. Persistência e passagem de bastão

Atividade 4: `REVIEW_COMPLETE_OFFLINE / NOT_PERSISTED`. Recomenda-se publicar **v1, v2, v3 e este parecer** em pasta nova `archive/handoffs/oes/artifacts/P4-A42/` e, no mesmo checkpoint proporcional, registrar CP329, atualizar o ponteiro, STATE e CHANGELOG apenas conforme mudança de estado. O Freshness Gate deve ser repetido imediatamente antes de qualquer commit. Após publicação de checkpoint, STOP obrigatório até instrução explícita. Nenhum gate conectado é concedido por essa publicação.

Gates inalterados: F4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; F5 `NOT_STARTED`; Marco B `OPEN`; G2-P2B `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; PF-I04/P4 `NOT_AUTHORIZED`. A32/A35 `HARD HOLD`.
