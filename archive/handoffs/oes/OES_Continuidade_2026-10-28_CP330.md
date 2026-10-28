# OES — CP330 | Django Auth PostgreSQL B2-M1 HOLD — preparação concluída

**Data:** 2026-10-28 (America/Recife)
**Checkpoint anterior:** CP329, `archive/handoffs/oes/OES_Continuidade_2026-10-28_CP329.md`.
**Base Freshness Gate:** `main` SHA `58f8a3d3ced55c99bd6c9556909204708d94e081`.
**Status:** snapshot operacional; nenhuma autorização de migrations PostgreSQL. Documento 362 e CP329 preservados.

## Marco técnico desde CP329

- Integração Django sessão/permissão sintética SQLite + Neon científico READ ONLY: GitHub [40701127859](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40701127859) PASS. Q0 sintético com commit/replay: [40695250735](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40695250735) PASS, não autoriza escrita operacional.
- Identidade persistente `PreparerIdentity.actor_uuid` separada da chave do usuário; serviço estrito autenticado sem habilitar HTTP POST; migração própria testada exclusivamente no SQLite descartável.
- Decisão arquitetural: **um PostgreSQL por ambiente; schemas segregados**, incluindo `django_auth`. Referência canônica `docs/governance/oes-auth-single-database-architecture-2026-10-28.md`; proposta antiga de banco `oes_auth` superada.
- Neon `weathered-boat-65779510` / branch `br-gentle-hall-b6jaxehf` / database `oes_sandbox`: Gate A PASS (schema `django_auth` criado e vazio, owner `oes_sandbox_owner`); Gate B1 PASS (`oes_auth_migrator` LOGIN NOINHERIT e USAGE/CREATE exclusivamente `django_auth` entre schemas relevantes); validade do papel até **2026-10-31 23:59:59 UTC**. Expiração de senha não elimina o papel nem revoga grants.
- B2-P0 leitura sob `oes_auth_migrator`: `search_path="$user", public`, schema `public`; ressalva pertinente à sessão da integração Neon, não à conexão Django. B2-P1 Django efetivamente conectado com `search_path=django_auth`: [40727429944](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40727429944) SUCCESS, log `PASS_READ_ONLY_DJANGO_AUTH_SCHEMA`, sem migrations; workflow manual desabilitado novamente. Responsável declarou exclusão do segredo `OES_AUTH_B2_PASSWORD`; não confirmada por inventário administrativo.
- B2-M1 **apenas preparado**: workflow `.github/workflows/oes-auth-b2-m1-migrations-manual.yml`, `if: ${{ false }}`, segredo distinto `OES_AUTH_B2_M1_PASSWORD` **não criado**; preflight, allowlist de migrations, plano, `migrate`, fingerprint estrutural científico, postflight de migrations, ContentTypes e Permissions. CI offline [40729253488](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40729253488): **191/191 PASS**. Nenhum `migrate` PostgreSQL executado. Não confundir teste offline com prontidão operacional.
- Referências de código: `applications/oes_web/config/settings_auth_pg_b2_optin.py`, `auth_pg_b2_preflight.py`, `auth_pg_b2_inventory.py`, `auth_pg_b2_postflight.py`, `auth_pg_b2_scope.py`, `config/auth_sandbox_router.py`, `preparer_identity/`.

## Gates e fronteiras

Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Marco B `OPEN`; G2-P2B operacional `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`. A32/A35 desabilitados; PF-I04/P4 autônomo deferido; nenhum pesquisador real integrado. Não há autorização para B2-M1, DDL/DML conectado, alterações adicionais de papéis/grants, HTTP write, deploy, dados factuais ou serviços pagos.

## Ponto exato de retomada

**Aguardar deliberação específica do responsável sobre Gate B2-M1**, após revisar os riscos do workflow, inclusive seus efeitos de `post_migrate`, rollback parcial e necessidade de segredo efêmero. Sem aprovação, não habilitar o job, criar credencial, conectar ou executar migrations. Após eventual aprovação, liberar somente o escopo nominal e uma execução, aferir logs/postflight, desabilitar novamente e solicitar exclusão do segredo. O primeiro passo de retomada é diagnóstico/freshness, **não disparo automático**.

**Ponteiro único:** `archive/handoffs/oes/README.md`. Snapshot imutável; documentos canônicos e `STATE.md` prevalecem em caso de alteração posterior. Aplicar Template de Continuidade e Documento 362; parar após publicação deste checkpoint até nova instrução.
