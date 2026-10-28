# OES — PF-I04/P4-A38 | Persistência byte a byte e revisão independente dos SQLs A37

**Data:** 2026-10-28. **Base canônica antes da atividade:** CP326, GitHub HEAD `97c4a1ebd65650dca712077c2a806c68efe58b30` (`identical`). **Estado final da auditoria:** `SOURCE_INTEGRITY_PASS / OFFLINE_STATIC_REVIEW_WITH_BLOCKERS / EXECUTION_HOLD`. Nenhuma consulta SQL Neon, nenhuma mutação, nenhum segredo ou workflow disparado.

## 1. Quatro fontes preservadas integralmente

Diretório `archive/handoffs/oes/artifacts/P4-A38/`. Os hashes de blob Git calculados por `git hash-object` dos arquivos locais foram comparados aos retornados após `fetch_file` do GitHub. Todos os quatro **iguais**; as fontes integrais não foram editadas e o histórico de commits preserva a rastreabilidade de reenvios para restaurar identidades byte a byte.

| Fonte (nome original A37) | SHA-256 (conteúdo canônico) | Git blob SHA-1 comprovado | Bytes | Linhas |
| --- | --- | --- | ---: | ---: |
| `OES_P4_A37_SETUP_SYNTHETIC_TARGET_CANDIDATO_HOLD.sql` | `b2b2063eff27d6a0d5996aa2befcfc1922bae68fff249422cc25e1ab99dbb09b` | `fdf1b92880adb83c2343f31840b50a93b9385e83` | 2781 | 57 |
| `OES_P4_A37_TRIAL_SYNTHETIC_ROLLBACK_ONLY_CANDIDATO_HOLD.sql` | `0ade6935a8d4a368c660f2c94de6a34b4a7d27f768aa87b8d5c8edf964c71b35` | `782ba277613bc31deffcea844168ee38bc0f84ef` | 5754 | 115 |
| `OES_P4_A37_POSTFLIGHT_CATALOG_READ_ONLY_HOLD.sql` | `7648e3e320ba3fcdfbb535b47bfa1687c85ca969f301b9ab0b3ddfcb310d6c87` | `20d1618492a53d094b3120a60305720a0eac9c1d` | 2745 | 54 |
| `OES_P4_A37_CLEANUP_SYNTHETIC_HOLD.sql` | `4cf8ff2bc8ac7ca520e6f90815da5b8d5ba7e016c4c43276f4c9f910157dc1df` | `c17c7b1368f1897c308866656e9a65e573ee6674` | 2288 | 48 |

ZIP A37 local SHA-256 `bd9f71a95d504c4ec7217410a752369d4d8e04909bca63054889a807eea3dde8`, entradas byte-idênticas aos arquivos locais; não é o artefato GitHub de autoridade, que são os quatro SQLs acima. Parecer A37 original já persistido em `archive/handoffs/oes/artifacts/P4-A37/OES_PF-I04_P4-A37_DECISAO_SINTETICA_E_HASHES_HOLD.md`.

## 2. Revisão estrutural realizada SEM PostgreSQL

Foi aplicado scanner lexical local de instruções de nível superior, respeitando aspas simples, comentários e blocos `DO $tag$ ... $tag$` (não um parser PG18). Conferidos byte count, linha, SHA-256, marcadores, boundaries e presença/ausência de comandos por script:

- SETUP: **9** comandos superiores; começa `BEGIN`, termina `COMMIT` e contém exatamente uma criação de `oes_p4_trial_target` e GRANT persistente de `ADMIN TRUE, INHERIT FALSE, SET FALSE` para `oes_p4_trial_login`. Não executado.
- TRIAL: **19** comandos superiores; `BEGIN` → `ROLLBACK` único, sem `COMMIT`, `CREATE ROLE`, `ALTER ROLE` ou `DROP ROLE`; um `GRANT` grantor `trial_login`, um `REVOKE ... GRANTED BY trial_login RESTRICT`, `SET LOCAL ROLE target` e `NONE`, quatro marcadores A37; nenhuma instrução de GRANT em objetos Django/Q0. Não executado.
- POSTFLIGHT: **um** comando superior `WITH ... SELECT`; 12 checks + 1 summary projetados; não comprova que o ensaio ocorreu. Não executado.
- CLEANUP: **8** comandos superiores; `BEGIN`→`COMMIT`, `ALTER ROLE trial NOLOGIN PASSWORD NULL`, REVOKE da associação sintética pelo owner e `DROP ROLE target`. Não executado.

**A semântica de GRANT por concedentes distintos e das opções SET/INHERIT/ADMIN permanece hipótese operacional até teste PG18 autorizado**. As associações são objetos globais de *cluster* PostgreSQL, não isoladas pela seleção de `current_database()`; a branch Neon sintética é a fronteira de isolamento e deve ser certificada pelo endpoint/metadados, nunca somente pelo SQL.

## 3. Achados e limites antes de qualquer autorização operacional

### A38-R01 — postflight incompleto quanto a terceiros [BLOQUEANTE]
O SELECT de 12 checks verifica (a) `roleid=target, member=trial` e o grantor esperado, (b) ausência de self-grant, (c) proteção da membership Django original. **Não inventaria todas as linhas `pg_auth_members` cujo `roleid=target` ou `member=target`** nem todas as dependências/ownership do target. Uma associação inesperada do target para outro membro, ou do target como membro de uma role privilegiada, pode passar despercebida. O cleanup pode remover o alvo e suas associações sem documentar terceiros. Preparar v2, nova identidade SHA-256 e nova revisão para qualquer gate de postflight/cleanup.

### A38-R02 — âncora de identidade insuficiente no postflight [CONDIÇÃO]
O postflight confere `current_database()='oes_sandbox'`, mas **não confere `session_user`, `current_user`, versão PostgreSQL, nem host/branch**. O host e branch Neon precisam ser verificados fora da consulta; a identidade deve ser auditada no SQL v2 antes de uso, sem presumir que resultado PASS identifica branch.

### A38-R03 — cleanup desabilita login mas não certifica senha nula [CONDIÇÃO]
O cleanup usa `ALTER ROLE ... NOLOGIN PASSWORD NULL`, mas o pós-check só confirma `rolcanlogin=false`; `pg_roles` deliberadamente não revela o hash de senha. Não afirmar prova de `PASSWORD NULL` somente por essa consulta. Uma auditoria autorizada de atributo sensível em `pg_authid` exigiria gate próprio e seria desnecessária se o comando ALTER foi confirmado e `NOLOGIN` foi validado. Prever revisão independente pós-cleanup.

### A38-R04 — privilégio ADMIN mesmo sobre alvo sintético requer janela limitada [CONDIÇÃO]
A membership ADMIN TRUE no `oes_p4_trial_target` autoriza retransmissão de membership do target enquanto a credencial válida estiver acessível; o alvo deve permanecer **NOLOGIN, sem ownership e sem poderes**. `rolcanlogin=false` não comprova ausência de objetos, grants recebidos ou membership herdada. Verificar todas essas condições na futura baseline e no pós-ensaio; nenhuma transferência a terceiros permitida. `connection limit=1` também não é garantia de exactly-once.

### A38-R05 — SQL conectado e workflow distintos [BLOQUEANTE]
O A35 existente está fixado em `PGUSER=oes_sandbox_owner`, nos SQLs A29 e em `if: false`, portanto **não corresponde** ao novo login/target A37. O workflow A32 é testemunho offline imutável. Qualquer ensaio A37 exige novo artefato/workflow explicitamente revisado, aprovação do setup **persistente** separada da autorização de trial `ROLLBACK`, do postflight em sessão independente e do cleanup, com política de senha/segredo descartáveis.

## 4. Decisão

**`P4-A38 = DOCUMENTARY_PERSISTENCE_PASS / OPERATIONAL_HOLD`.** Não executar os candidatos A37 nesta forma: preservar originais como fontes históricas; criar v2 do postflight (e fortalecer o cleanup/setup conforme achados) antes de solicitar qualquer autorização de execução. Não preencher GitHub Secret, não conceder `ADMIN` em migrador/owner, não criar `oes_p4_trial_target` até novo gate. O login existente `oes_p4_trial_login` permanece sem membership. Fase 5 NOT_STARTED; Marco B OPEN; G2-P2B NO-GO; E9 NO-GO; readiness NOT_READY; P4 NOT_AUTHORIZED.

**Próximo P4-A39 sugerido:** corrigir documentalmente as lacunas R01/R02 e formalizar estratégia de inspeção pós-cleanup, com nova identidade SQL e revisão; se não for possível provar baixo risco, manter HOLD. Checkpoint CP326 vigente até consolidação proporcional.
