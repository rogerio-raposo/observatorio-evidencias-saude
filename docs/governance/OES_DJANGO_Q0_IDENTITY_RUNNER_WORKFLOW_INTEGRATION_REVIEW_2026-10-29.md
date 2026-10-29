# OES — Revisão de integração: identidade persistida, runner e workflow Q0

Data: 2026-10-29. Referência: CI offline [40952187463](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40952187463), 287/287 PASS no commit fde341f67ac65f8b1cf99d0cf2d229e7ba17eba4.

## Resultado

**INTEGRAÇÃO CONECTADA: HOLD.** Esta revisão não consumiu autorização para o ensaio único. O workflow `.github/workflows/oes-django-q0-single-rollback-hold.yml` não recebe secrets e o job conectado é `if: false`; sua etapa de revisão passa a verificar, pelo AST da revisão despachada, que ambos os `run_connected` permanecem com um único `raise`. Não prova segurança do executor privado; é controle de não ativação.

## Lacuna de proveniência

O serviço `preparer_identity.resolver.persisted_preparer_actor_id(user)` associa o `user.pk` a `PreparerIdentity` no alias `default`. A revisão `review_persisted_actor_binding` exige `require_question_preparer(user)` e deriva o ator dessa associação; porém `_perform_rollback_only(trial, verified_actor)` ainda aceita strings de seu chamador interno. O usuário sintético provisionado tem **senha inutilizável**. Portanto, um futuro runner CI não pode alegar login real ou derivar um `user` autenticado de uma mera SELECT. É preciso uma fronteira nominal de **identidade sintética de serviço para teste**, com consulta READ ONLY da única associação e da permissão direta, que NÃO substitua autenticação Django e não seja usada por runtime HTTP. Confirmar papel de banco no servidor e vínculo 1:1. Nenhum actor ID de input do workflow.

## Controles remanescentes antes de executar

1. Fixar SHA da implementação conectada e exigir correspondência explícita da revisão; não derivar autorização apenas de `github.sha` móvel ou de `Prossiga`.
2. Distinguir a identidade de serviço sintética do fluxo `require_question_preparer(user)` voltado a usuários autenticados; revisar um caminho operacional isolado sem simular `is_authenticated`.
3. Executar preflight READ ONLY da única identidade e vínculo no alias auth, sem reexecutar provisionamento.
4. Reavaliar `writer.in_atomic_block` e `reader.in_atomic_block` antes de fechar conexões, recusar transações preexistentes. Confirmar `get_autocommit()` e identidade/DB/read-only no servidor.
5. Garantir execução única também entre diferentes runs: `concurrency` apenas serializa, não impede novo dispatch posterior; exigir token de tentativa único consumido em ledger imutável ou outra prova externa equivalente **sem adicionar DML fora das cinco tabelas**. Sem esse mecanismo, NO-GO.
6. Reconciliar cinco tabelas e oes_id por leitor fresco, com resultado HOLD em qualquer incerteza. Nenhum commit, retry, DELETE, GRANT, migration, HTTP write ou deploy.
7. Confirmar CI do workflow de revisão e de qualquer mudança de código antes de habilitar a tentativa.

## Decisão

Manter `connected-trial` desabilitado. Próxima atividade proporcional: especificar a derivação READ ONLY do ator do usuário sintético (sem falsificar autenticação) e uma garantia externa de execução única, depois uma revisão final do runner. Sem novos preflights redundantes ou provisão de usuários.

Gates: Marco B OPEN, Q0 geral HARD HOLD, E9 NO-GO, Fase 5 NOT_STARTED. CP343 vigente.
