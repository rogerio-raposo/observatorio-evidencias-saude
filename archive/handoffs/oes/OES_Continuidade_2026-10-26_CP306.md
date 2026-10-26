# OES — CP306 | P2 offline CI e gate de autorização por ator
**Data:** 2026-10-26. **Anterior:** CP305. **Estado:** `P2_OFFLINE_CI_109_PASS / SQL_PORT_PARTIAL / CONNECTED_HOLD`.

## Evidência conectada à CI, sem SQL conectado
- Workflow manual Django [run 40271314159](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40271314159) falhou em import por SyntaxError no adaptador P2 (sequências literais `\\n`); Django check PASS antes da falha. Correção sintática publicada no commit `d99cf7b33f74262c908055b60c8ed8c26ae566a2`.
- [run 40271463247](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40271463247): job `django-read-only-tests` completed/success, Python 3.12, `python manage.py check` PASS, comando `python manage.py test evidence.tests evidence.test_question_sql_port_offline --verbosity 2`: **109 testes PASS**, incluindo **9 P2**. Logs de job foram inspecionados. CI offline não comprova SQL PostgreSQL executado.
- GitHub HEAD validado contra `d99cf7b33f74262c908055b60c8ed8c26ae566a2` antes deste checkpoint. Implementação P2 publicada em `applications/oes_web/evidence/question_sql_port_offline.py` e testes adjacentes; workflow existente atualizado, sem novo pipeline.

## Contrato mínimo de autorização para P2, ainda NÃO implementado
- A autorização de função já existe em `preparation_auth.py`: `require_question_preparer(user)` exige `is_authenticated` e `evidence.prepare_question`; status staff/superuser não libera por si. `QuestionCommand` e `OfflineQuestionUnitOfWork` devem permanecer únicos.
- Esta permissão **não** comprova direito de ler/alterar *uma pergunta específica*. `actor_id = str(user.pk)` é uma identidade de chamada, não prova de vinculação da pergunta a um preparador no PostgreSQL. Esquema sintético sem RLS; não presumir isolamento por registro.
- O método `can_access_question(question_id,actor_id)` precisa de predicado fundamentado em vínculo autorizativo persistente, revogável e verificado a cada replay. Não criar tabela de ACL, atribuição automática ao primeiro autor, default allow ou confiar em `actor_id` isoladamente. Se não houver vínculo confiável, manter `PreparationHold` fail closed. `current_question` deve aplicar o mesmo escopo e não vazar existência/texto de perguntas alheias.
- `lock_request` e `find_receipt` implementados em SQL parametrizado com cursor/factory injetados; `current_question`, `can_access_question`, `register_q0`, `propose_q1`, `save_receipt` permanecem HOLD por design. Testes por doubles não certificam locks PG, ACL, DML, RLS ou semântica pós-commit.
- Próxima atividade: identificar, somente por inspeção documental/código e, se necessário, catálogo READ ONLY **sujeito a aprovação específica para Neon**, a fonte canônica de vínculo preparador↔pergunta. Produzir proposta mínima sem código novo ou novos grants até gate. Não duplicar abstrações.

## Invariantes
W2a fechado tecnicamente só para role/ACL, role NOLOGIN e grants preservados no sandbox. W2b/W3 não autorizados; nenhuma credencial, LOGIN, SET ROLE, DML, HTTP write, E9, deploy ou serviço pago. Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; sem pesquisadores vinculados.

## Ponto exato de retomada
Aplicar Freshness Gate e partir de CP306. Analisar se há vínculo autoritativo já existente no domínio/autorização para implementação segura de `can_access_question` e `current_question` sem inventar uma política. Qualquer alteração de SQL conectado ou privileges depende de aprovação nominal. Não avançar automaticamente W2b/W3.
