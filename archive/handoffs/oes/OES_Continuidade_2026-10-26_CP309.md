# OES — CP309 | Encerramento técnico restrito de Q0 offline
**Data:** 2026-10-26. **Anterior:** CP308. **Documento decisivo:** 341.

## Marco novo
CI https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40275424108, commit `d2a531b1cf480920f17c2b7123a385b78b93e6ec`: workflow e job SUCCESS, 126/126 testes PASS, Django check sem problemas. O erro anterior da CI 40275241461 foi resolvido por ajuste de expectativa do teste de Q0 sem recibo. Q0 offline tem quatro INSERTs de entidade/pergunta/versões e recibo na mesma transaction factory injetada, com simulações de commit e rollback, colisões de identidade e bloqueio de recibo ausente. Encerramento `Q0_OFFLINE_TECHNICAL_CLOSURE_ONLY`.

## Estado herdado
Doc.336 aprova responsável único sintético; Docs.337–338 comprovam migração apenas estrutural de `investigation.question.responsible_actor_id text NULL` com CHECK no Neon sandbox `weathered-boat-65779510` branch `br-gentle-hall-b6jaxehf` DB `oes_sandbox`. Doc.339 mapeia Q0, Doc.340 confirma constantes canônicas, Doc.341 registra evidência CI. Writer `oes_qprep_writer NOLOGIN` com ACL W2a restrita; SQL conectado, grants, credenciais e Django runtime sem autorização. `can_access_question` e `current_question` cobertos offline; `register_q0` e `save_receipt` somente Q0 offline; `propose_q1` HOLD.

## Retomada prioritária
Executar Freshness Gate de GitHub. Próxima atividade delimitada: desenhar/implementar em passos proporcionais o Q1 **offline com cursor injetado**, nova versão e recibo Q1, preservando Q0 original e imutabilidade do ledger; não acionar Neon nem habilitar HTTP. Avaliar lock atual, possíveis restrições SQL, replay integrado e simulação de falhas. A CI 126 PASS não demonstra execução SQL real, concorrência adversarial ou isolamento multiusuário; RLS ausente. Não inventar prontidão operacional.

## Invariantes
Marco B aberto; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; readiness NOT_READY; Fase 5 NOT_STARTED; A3 ausente e pesquisadores não vinculados; E9 NO-GO; sem serviços pagos.
