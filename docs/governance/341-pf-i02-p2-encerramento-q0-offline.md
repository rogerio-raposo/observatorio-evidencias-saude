# Documento 341 — PF-I02-P2: encerramento técnico restrito de Q0 offline
**Data:** 2026-10-26. **Estado:** Q0_OFFLINE_TECHNICAL_CLOSURE_ONLY. **Base:** CP308, Docs. 336–340.

## Evidência CI
Execução GitHub Actions https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40275424108: `completed/success`, job `django-read-only-tests` PASS, SHA `d2a531b1cf480920f17c2b7123a385b78b93e6ec`, 126 testes executados, 126 PASS; `python manage.py check` sem problemas. Testes simulados confirmaram commit de cinco inserts, rollback em falha por tabela, falha de ledger, identidade duplicada entre atores, Q0 repetida e aborto quando recibo ausente. Teste de regressão de recibo com ator divergente corrigido e PASS.
A execução anterior 40275241461 falhou 125/126 devido a expectativa obsoleta de teste para proteção Q0 sem recibo; correção exclusivamente de teste, sem afrouxar o fail-closed.

## Escopo alcançado
`InjectedQuestionSQLPort` com factory de transação/cursor injetada, `can_access_question`, `current_question`, `register_q0` e `save_receipt` para Q0, sem conexão, credencial ou HTTP. Q0 prepara quatro INSERTs e ledger parametrizados, responsabilidade inicial do ator autenticado sob contrato W1, UUIDs gerados em Python. Simulador em memória exercita atomicidade; `propose_q1` permanece HOLD.

## Limites obrigatórios
CI offline **não** prova transação real PostgreSQL, isolamento RLS, concorrência adversarial, idempotência de replay integrada à porta SQL, nem autenticação humana operacional. Factory conectada não aprovada; papel writer NOLOGIN, sem UPDATE geral. A migração `responsible_actor_id` da branch Neon sintética já foi verificada em Doc.338, mas nenhuma DML conectada de Q0 por essa porta foi autorizada ou executada. Não repetir ensaio administrativo anterior como substituto de integração. E9 NO-GO.

## Seguimento
Após CP309: implementar `propose_q1` offline e suporte de recibo Q1, validar transição e concorrência apenas simulada; revisão específica de replay, colisões e locks antes de qualquer gate conectado. Autorização separada para SQL conectado, roles/grants, Django runtime, HTTP ou deploy.
Marco B aberto; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; readiness NOT_READY; Fase 5 NOT_STARTED; A3 ausente, sem pesquisadores vinculados.
