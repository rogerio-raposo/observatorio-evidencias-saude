# OES — PF-I04/P4-A41 | PostgreSQL 18 v3 em contêiner descartável — PASS restrito

**Data:** 2026-10-28 (America/Recife). **Checkpoint de origem:** CP327. **Status:** `PG18_V3_ISOLATED_FULL_CIRCUIT_PASS / NEON_NOT_TOUCHED / CONNECTED_SETUP_NOT_AUTHORIZED`.

## 1. Causa e correção de A40
O ensaio anterior A40 em PostgreSQL 18.6 comprovou `HOLD A39 setup: target not pristine` após CREATE ROLE por não-superusuário com CREATEROLE. De acordo com PostgreSQL 18, o criador recebe automaticamente ADMIN TRUE, INHERIT FALSE, SET FALSE sobre o papel criado, com concessão de bootstrap superuser; esse autogrant não é revogável pelo criador. A41 v3 inventaria autogrant do target e tolera autogrant do criador do `oes_p4_trial_login` (se existir), mas rejeita terceiros e flags anômalos.

**Fonte:** https://www.postgresql.org/docs/18/role-attributes.html . Nunca confiar só no banco: roles/memberships são cluster-wide NA BRANCH Neon, e o endpoint real precisa conferência de metadados.

## 2. Arquivos canônicos v3 (todos NÃO AUTORIZADOS para Neon)
Diretório `archive/handoffs/oes/artifacts/P4-A41/`:
1. `OES_P4_A41_SETUP_V3_SYNTHETIC_TARGET_HOLD.sql` SHA-256 `68e364af8927a67bf0f9f743084ed79cbc0d4114f7af9aa98c6d3e2c8f84fa62`, Git blob `ccaa828062080655d7be209a4813042910d93ef6`, **BEGIN→COMMIT/CREATE ROLE/GRANT**, cria alvo NOLOGIN e concede apenas role sintética ao login trial, com autogrant creator esperado.
2. `OES_P4_A41_POSTFLIGHT_V3_CATALOG_READ_ONLY_HOLD.sql` SHA-256 `3dacfa56e85d8acbdde2f235d981e57e82d5da946c2392e19cde3433c286c8dd`, Git blob `c96006b31520ee33d7281816735bcdda80de99d7`, **uma consulta READ ONLY**, 28 verificações + SUMMARY de contagem total/0 failures, incluindo ambas direções de memberships, creator autogrants, dependências/ownership explícitos e 0 sessões trial.
3. `OES_P4_A41_CLEANUP_V3_SYNTHETIC_TARGET_HOLD.sql` SHA-256 `3bb320045e431d77b9596da2312fcce3bd13458def316042d7546eb5b8e04454`, Git blob `a1b634d48525f78cde61e70697bf93fa48dfb400`, **BEGIN→COMMIT**, requer login NOLOGIN e inventário de duas associações do target; REVOKE apenas concessão explícita owner→trial, DROP exclusivamente target, autogrant creator removido pelo DROP. Nunca CASCADE.
4. Reutilizados sem alterações: `OES_P4_A37_TRIAL_SYNTHETIC_ROLLBACK_ONLY_CANDIDATO_HOLD.sql` SHA-256 `0ade6935a8d4a368c660f2c94de6a34b4a7d27f768aa87b8d5c8edf964c71b35`, original em P4-A38; `OES_P4_A39_CREDENTIAL_LOCKDOWN_HOLD.sql` SHA-256 `ff9782bfbc2bdec1503187d69f0b12b1c10a53d7cc08176a79ab15ef7a11baa7`, original em P4-A39.

**NÃO modificar originais A37/A39 ou A32/A35.** O teste gera apenas cópias de fixture e substitui o OID literal histórico 155649 pelo OID dinâmico sintético, com contagens fixas 1/1/1/0/2; fonte byte a byte revisada por SHA.

## 3. Runs reais de GitHub Actions (somente PG18 sintético)
- **A41 primeiro run** [40631051160](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40631051160), commit `0859c370ae1717e3efd4c589c56a8d5e896440c5`, `completed/failure`. Todas as fases DB passaram, inclusive trial/rollback/postflight/negativos/lockdown/cleanup, mas asserção final da fixture exigia roleid=trial sem memberships e falhou por autogrant legítimo do criador do login. **Falha no verificador**, não no SQL cleanup.
- **A41 segundo run** [40631160589](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40631160589), commit `3a51f0964c0a158b136adab117c55ba85c464927`, evento `push`, 1ª tentativa. `completed/success`, job sintético SUCCESS. Consultados logs: `postgresql_18 PASS`, `local_only_endpoint PASS`, `fixture_trial_creator_autogrant PASS`, `fixture_unique_original_grant PASS`, cinco `sha_* PASS`, `setup_pg18_exec PASS`, `trial_grant_set_revoke_rollback PASS`, `postflight_28_check_pass PASS`, `postflight_detects_third_party PASS`, `postflight_restored PASS`, `independent_credential_lockdown_commit PASS`, `cleanup_rejects_third_party PASS`, `cleanup_after_lockdown_commit PASS`, `final_cleanup_catalog_state PASS`, `no_neon_connection PASS`, relatório JSON `status=PASS`.
- Negativo de terceiro no cleanup produz uma mensagem SQL ERROR deliberada na sessão descartável; isso é comportamento PASS porque foi interceptado e exigiu rejeição. Não confundir com falha de run. Depois da remoção controlada da associação sintética inesperada, cleanup e postcleanup PASS.
- Artefato executor `scripts/oes_p4_a41_pg18_disposable.py` e workflow `.github/workflows/oes-pf-i04-p4-a41-pg18-disposable.yml`. A41 workflow foi alterado **depois do PASS** para `workflow_dispatch` apenas, SEM `push`, no commit `cf655e8851ab4e254164e0b8cbe8fd5d60c7d58f`. Não disparar novamente automaticamente.
- **Toda fixture é descartável:** `postgres:18` GitHub Actions, senha sintética `a41_disposable_ci_only_not_neon`, host cliente `127.0.0.1`, roles temporárias, sem Neon endpoint, sem segredos, sem dados Django/Q0 ou produção. P4-A41 não acessou nem modificou Neon.

## 4. O que o PASS prova / não prova
**Prova em PG18 descartável:** sintaxe e semântica das variantes v3 e dos originais trial A37 e lockdown A39 sob fixture com criador não-superusuário, autogrant do criador, autogrant do trial, GRANT own-grantor/SET LOCAL ROLE/REVOKE/ROLLBACK, postflight de 28 checks, rejeição de terceiro no postflight e cleanup, lockdown por COMMIT independente e postcleanup íntegro.

**NÃO prova:** privilégios/role attributes de `oes_sandbox_owner` reais na branch Neon; OID real, grantor real do autogrant, inexistência de associações em ambos sentidos do login trial na branch, ausência de outros objetos do papel, conectividade/segredos GitHub, custo da execução, equivalência científica ou operacional com a associação histórica OID 155649, autorização de A29/A21/Django/E9.

## 5. Próximos gates, todos independentes
1. **P4-A42 PROPOSTA READ ONLY**: antes de setup Neon, consulta catalogal em `oes_sandbox` e branch `br-gentle-hall-b6jaxehf` aprovada nominalmente; inventariar `rolname/rolcreaterole/rolsuper` do owner, `pg_auth_members` para trial tanto como member quanto roleid, preservar exatamente OID 155649 e identificar flags, checar target ainda inexistente. Nenhuma senha, `pg_authid` ou tabela de dados.
2. Se baseline não corresponder às alternativas permitidas em A41, **HOLD e nova variante**, não forçar setup.
3. **P4-A43**: preparar workflow NOVO específico para login trial (A35 permanece para owner/A29 com HARD HOLD), endpoint DIRECT/branch confirmado, segredo descartável sob autorização nominal, retry/dispatch defense, evidência de execução única e reversão. **Não criar segredo ainda.**
4. Após decisão explícita de custos e operacional, autorizações nominais separadas SETUP v3 (commit persistente), TRIAL A37 (uma sessão/rollback), POSTFLIGHT v3 em nova sessão, LOCKDOWN A39 (NOLOGIN PASSWORD NULL), CLEANUP v3 (REVOKE/DROP) e pós-check. Não reutilizar `Prossiga` como autorização mutante.
5. Login real `oes_p4_trial_login`: anteriormente criado pelo responsável, sem memberships como *member*, senha válida até `2026-10-31 03:30:53 UTC`; `rolcanlogin` agora não revalidado. A criação de papel-alvo no Neon NÃO ocorreu. Não inserir credencial em chat.

**Conclusão:** `PF-I04/P4-A41 = DISPOSABLE_PG18_FULL_CIRCUIT_PASS`; **Neon P4 ainda NO-GO**, CP327 até novo checkpoint. Gates Marco B OPEN; G2-P2B NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 5 NOT_STARTED.
