# OES — PF-I04/P4-A37 | Baseline do login temporário e candidato sintético HOLD

**Data:** 2026-10-28. **Checkpoint vigente:** CP326. **Resultado:** `BASELINE_CONFIRMED / SYNTHETIC_VARIANT_DESIGNED / OPERATIONAL_HOLD`. **GitHub HEAD verificado:** `2dbb5b6f92be8bac0d74fb05fed4c7686ba36965`. **Nenhum acesso conectado PostgreSQL/Neon pelo assistente nesta atividade.**

## Evidência da consulta realizada pelo responsável
Foi informado resultado de SQL Editor Neon: banco `oes_sandbox`, executor `oes_sandbox_owner`, associações de `oes_p4_trial_login` = **0**, associação original migrator→owner = **1**, OID **155649** intacto, direitos SET do trial para migrator e owner ambos `false`. Login criado anteriormente como LOGIN/NOINHERIT, sem flags administrativas, conexão máxima 1, senha válida até 2026-10-31 03:30:53 UTC. Não copiar senha nem segredo.

## Decisão técnica
**Não conceder membership de `oes_django_migrator` ou `oes_sandbox_owner` ao login temporário.** ADMIN OPTION numa role poderosa possibilita delegação/reconcessão do papel e eventual obtenção de SET TRUE, apesar do atributo NOINHERIT. SET TRUE sozinho permitiria assumir privilégios efetivos de migração. Ambos excessivos para verificar semântica PostgreSQL.

Preparou-se localmente variante limitada a um **novo alvo sintético** `oes_p4_trial_target`, NOLOGIN, sem objetos e sem privilégios específicos. O setup (ainda bloqueado) prevê GRANT target→`oes_p4_trial_login` por `oes_sandbox_owner`, **ADMIN TRUE, INHERIT FALSE, SET FALSE**, exclusivamente sobre o target sintético. Um script separado autenticado como trial testará self-GRANT target→trial, `SET LOCAL ROLE target`, restauração, revogação apenas do próprio grant e **ROLLBACK**. O teste não modifica migrator/owner nem tabelas Django/Q0; um terceiro script executa postflight catalogal em sessão independente, e um quarto faz cleanup após gate separado.

**Limite científico:** prova possível de mecânica de grantors no papel sintético **não prova** o caso histórico OID 155649, nem autoriza o SQL A29 original, os GRANTs Django A21 ou operações E9.

## Artefatos SQL locais e identidades SHA-256
1. `OES_P4_A37_SETUP_SYNTHETIC_TARGET_CANDIDATO_HOLD.sql` — **`b2b2063eff27d6a0d5996aa2befcfc1922bae68fff249422cc25e1ab99dbb09b`**, setup com CREATE ROLE e GRANT persistentes (COMMIT), **não executar sem gate nominal**.
2. `OES_P4_A37_TRIAL_SYNTHETIC_ROLLBACK_ONLY_CANDIDATO_HOLD.sql` — **`0ade6935a8d4a368c660f2c94de6a34b4a7d27f768aa87b8d5c8edf964c71b35`**, 4 marcadores A37_PRE/TEMP_GRANT/TARGET/CLEAN, contagens 1→2→2→1, mesmo PID, rollback obrigatório.
3. `OES_P4_A37_POSTFLIGHT_CATALOG_READ_ONLY_HOLD.sql` — **`7648e3e320ba3fcdfbb535b47bfa1687c85ca969f301b9ab0b3ddfcb310d6c87`**, consulta única `WITH ... SELECT` (12 checks), nova sessão, autorização independente.
4. `OES_P4_A37_CLEANUP_SYNTHETIC_HOLD.sql` — **`4cf8ff2bc8ac7ca520e6f90815da5b8d5ba7e016c4c43276f4c9f910157dc1df`**, revoga login/senha e associação, remove target sintético, somente após postflight e gate independente.

As fontes integrais estão no ZIP local de conveniência `OES_PF-I04_P4-A37_SINTETICO_CANDIDATOS_HOLD.zip`, SHA-256 `bd9f71a95d504c4ec7217410a752369d4d8e04909bca63054889a807eea3dde8`. ZIP NÃO foi persistido no GitHub e deverá ser materializado/verificado antes de qualquer execução. Contrato de fonte local: `OES_P4_A37_CONTRATO_DECISAO_E_GATES.md` SHA-256 `23515df3f2c9cd593817b7b0f5767534b50c2200d4362436ef3380caa07d7bbb`. **NÃO afirmar que os SQLs foram publicados em GitHub.** Scripts passaram somente validação estática, não validação contra parser/engine PostgreSQL.

## Gates separados e fronteira
- Setup: precisa aprovação nominal para **CREATE ROLE** e **GRANT ADMIN apenas sobre novo alvo**, com escopo/branch/db e hash exato.
- Trial: nova revisão do workflow, mudança de `PGUSER` para `oes_p4_trial_login`, segredo específico temporário (AINDA NÃO CADASTRAR), SHA e gate próprio, `psql` sessão única e ROLLBACK obrigatório.
- Postflight: SELECT catalogal em nova sessão, gate separado inclusive em falha; nenhum dado de tabelas reais.
- Cleanup: revogação de login, PASSWORD NULL, REVOKE e DROP somente do alvo, autorização separada; exclusão do Secret GitHub não substitui revogação no banco.

O workflow A32 permanece imutável e A35 permanece `if: false` / `NOT_AUTHORIZED` / `NOT_APPROVED`. Marco B OPEN; G2-P2B NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 5 NOT_STARTED.

**Próxima atividade P4-A38 recomendada:** persistir as quatro fontes integrais SQL sob versionamento GitHub e realizar uma revisão estática independente de permissões/semântica, mantendo todos os gates em HOLD. Evitar ensaio conectado ou criação do alvo apenas por `Prossiga`.
