# Documento 327 — PF-I02-W1B: Unit of Work e recibos offline

**Data:** 2026-10-26. **Autorização expressa:** `APPROVED — OES / PF-I02-W1B / OFFLINE_TRANSACTIONAL_UOW_AND_LEDGER_TESTS_ONLY / no Neon / no SQL execution / no roles or grants / no real users / no HTTP write enablement / no deploy / E9 blocked / fail closed`.

## Entrega e evidência
`applications/oes_web/evidence/question_uow_offline.py`: `OfflineQuestionUnitOfWork` recebe uma porta transacional injetada; contrato de recibo com actor/request/fingerprint/question/version. Valida transição Q0-only em expected=0 e Q1 em expected>0, serialização da chave via método abstrato `lock_request`, replay por fingerprint, conflito, checagem de versão corrente e escopo, preservação Q0, e recibo no mesmo contexto transacional. **A atomicidade só é garantida pela futura implementação da porta; o módulo não abre conexão nem executa SQL.**

`applications/oes_web/evidence/tests/test_pf_i02_w1b_uow.py`: fake transacional com cópia de estado e publish no commit; testes de Q0/Q1, replay, fingerprint divergente, revisão obsoleta, ator distinto, rollback na simulação de falha, transição inválida e anônimo negado.

CI `40266279555` em commit `0c050d9529418cb66c383bb13d2f7fbb745ef6d8`: `completed/success` (Django check e `evidence.tests`). Nenhum Neon/SQL conectado, DDL, grants, identidade real ou HTTP write.

## Limites e questão relevante
**`W1B_OFFLINE_TRANSACTIONAL_PROTOCOL_TESTED`** apenas. O método `lock_request` da fake é no-op e, portanto, o ensaio não comprova concorrência simultânea, serialização cross-process ou idempotência efetivamente durável. Na implementação PostgreSQL, lock do request, conflito único, reconciliação pós-commit, ACL/RLS e ledger de recibos do Doc.326 são gates bloqueantes. O recibo devolvido no mock não demonstra recuperação após reinício. Não declarar W2/W3 pronto nem E9 ou marco B encerrado.

## Continuidade
Próxima prioridade: revisão única da porta SQL concreta, ledger e políticas mínimas antes de autorização de DDL/roles W2. Evitar novos protótipos paralelos; conservar estrutura Django atual e desligamento do write HTTP. CP300 permanece vigente até novo checkpoint. Marco B aberto, E9 NO-GO, A3 ausente, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.
