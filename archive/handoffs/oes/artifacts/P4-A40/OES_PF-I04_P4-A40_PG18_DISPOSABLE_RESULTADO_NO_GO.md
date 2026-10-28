# OES — PF-I04/P4-A40 | PostgreSQL 18 descartável — falha real de setup / NO-GO

**Data de execução:** 2026-10-28 UTC. **Checkpoint vigente:** CP327. **Classificação:** `DISPOSABLE_PG18_EXECUTED / SETUP_NO_GO / NEON_UNTOUCHED`. Esta é evidência de incompatibilidade no candidato A39; não se deve anunciar PASS end-to-end.

## 1. Evidência remota e isolamento
Workflow independente de CI: `.github/workflows/oes-pf-i04-p4-a40-pg18-disposable.yml`, `runs-on: ubuntu-latest`, serviço `postgres:18`, host cliente `127.0.0.1`, banco criado no runner `oes_sandbox`, usuários fixture novos, senha **puramente sintética do runner**; nenhuma variável de conexão Neon/secret/GitHub Secret usada. Harness: `scripts/oes_p4_a40_pg18_disposable.py`. As ações foram publicadas no GitHub; não houve SQL ou role change no projeto Neon `weathered-boat-65779510`.

Três execuções observadas, todas `completed/failure` (HOLD):
1. [40630179968](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40630179968), SHA `759ad75c72f40cd62bca57958f13de56f19fb599`: servidor PostgreSQL **18.6**, abortou em `local_only_endpoint`; a asserção exigia indevidamente `inet_server_addr() = 127.0.0.1`, embora contêiner Docker reporte seu IP de bridge. Nenhum SQL do ensaio.
2. [40630287399](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40630287399), SHA `dd4a6eb25c332ade7c0cfa84461fc3d7d2b6a3d7`: versão/endpoint/fixture e **todos os cinco SHA-256 canônicos PASS**; interrompeu preparação de cópias em contagem de OID do cleanup (2 referências ao histórico, antes/depois). Nenhum SQL A39 ainda.
3. [40630416910](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40630416910), SHA `5a6959ac1908dd1f5bd282fc664751ac33feb019`: PostgreSQL 18.6, serviço local, fixture e SHA canônicos PASS; A39 SETUP v2 foi efetivamente enviado ao mecanismo. `BEGIN`, três SET LOCAL, DO de preflight e `CREATE ROLE oes_p4_trial_target` executaram na transação; DO seguinte lançou **`ERROR: HOLD A39 setup: target not pristine`**. `psql ON_ERROR_STOP` saiu, sessão fechou e a transação não teve COMMIT; o contêiner foi destruído. Não foram executados GRANT do setup, trial A37, postflight, lockdown ou cleanup.

## 2. Causa técnica e demonstração
O PG18 concede AUTOMATICAMENTE ao não-superusuário com `CREATEROLE` uma membership na role que ele cria: `GRANT created_role TO creator WITH ADMIN TRUE, SET FALSE, INHERIT FALSE`, concedida pelo bootstrap superuser. A associação automática não pode ser revogada pelo próprio criador sem poderes adicionais. Essa regra é explícita na documentação PostgreSQL 18: https://www.postgresql.org/docs/18/role-attributes.html .

O A39 setup v2 inclui logo após `CREATE ROLE` uma asserção de **zero** linhas `pg_auth_members` para `roleid=target OR member=target`, além de filtros de `pg_shdepend`. Se `oes_sandbox_owner` atua como CREATEROLE não-superusuário (como na fixture), a associação administrativa automática faz essa asserção falhar, exatamente o observado. O teste não coletou inventário interno adicional antes do erro; a explicação é suportada pela semântica documentada e pela localização/forma da falha. NÃO afirmar que a topologia real de Neon foi validada; nela a role criadora e a grantor podem diferir.

**Achado adicional a verificar em nova baseline:** o responsável relatou `associacoes_trial=0` usando somente `WHERE member='oes_p4_trial_login'`. Isso não exclui associação automática no outro sentido, `WHERE roleid='oes_p4_trial_login'` com o criador como membro. A39 setup também exige zero em ambos os sentidos para o trial login; esta condição pode ser excessivamente rígida. Não presumir que a role criada no Neon tem ou não esse autogrant sem catálogo conectado aprovado.

## 3. Governança do teste e invariantes
- **Nenhuma fonte A37/A39 canônica foi editada**; cinco SHA-256 originais preservados. Apenas cópias de fixtures substituem `oid=155649` pelo OID atribuído ao grant original no contêiner descartável; o manifesto de substituições registra contagem 1/1/1/0/2. Esta transformação não autoriza edição/executar o SQL original no Neon.
- O workflow CI foi alterado após o resultado para ficar **`workflow_dispatch` somente**, sem `push`: commit `c909430fce2c73bb28a42534f6b543951291fb97`. Não disparar novas execuções até novo diff/revisão.
- Workflows A32/A35 continuam bloqueados com `if:false` e os gates `NOT_AUTHORIZED`/`NOT_APPROVED`. Nenhum segredo GitHub criado e nenhuma credencial PostgreSQL real alterada pelo assistente.
- O A39 SETUP V2 em sua forma atual é **`NO-GO`**; como a etapa inicial abortou, **não há nenhuma prova empírica de sucesso** do trial A37, postflight v2, lockdown ou cleanup v2. É indevido classificar P4-A40 como PASS global. Resultado é **detecção bem-sucedida de incompatibilidade em teste descartável**.

## 4. Decisão proporcional e próxima atividade
1. Manter A37/A39 imutáveis como candidatos HISTÓRICOS sob HOLD.
2. **P4-A41 offline:** criar v3 corrigida para `oes_sandbox_owner` criador não-superusuário: permitir exatamente o autogrant do criador de `oes_p4_trial_target`, com `admin=true, inherit=false, set=false`; inventariar grantor/OID conforme docs e runtime, **sem presumir nome fixo do bootstrap**. Exigir exatamente a associação original automática + a associação explícita trial, sem terceiros; não tentar revogar autogrant; `DROP ROLE target` deve removê-la naturalmente.
3. Refazer o teste PG18 completo descartável com negativos de terceiros e rollback, depois abordar eventuais novos HOLDs sem mascará-los. É necessário também revisar se `oes_p4_trial_login` possui associação como `roleid` para o owner, não detectada pela consulta anterior; apenas mediante novo gate nominal READ ONLY conectado ao Neon se requerido.
4. Só cogitar gate de SETUP real no Neon após **PG18 PASS de v3**, verificação de branch/endpoint, programação de lockdown e autorização nominal por SHA. Nenhum GRANT migrator/owner ou SQL Django/Q0 por atalho.

**Estados globais preservados:** Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.
