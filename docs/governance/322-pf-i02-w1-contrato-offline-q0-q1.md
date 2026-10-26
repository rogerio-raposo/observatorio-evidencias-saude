# Documento 322 — PF-I02-W1: contrato de comandos Q0→Q1 offline

**Data:** 2026-10-26. **Autorização expressa:** `APPROVED — OES / PF-I02-W1 / OFFLINE_DJANGO_Q0_Q1_CODE_AND_TESTS_ONLY / no Neon / no SQL writes / no real users / no grants or credentials / no deploy / E9 blocked / fail closed`.

## Entrega efetiva
`applications/oes_web/evidence/question_preparation.py` introduz `QuestionCommand` tipado (request_id, question_id, expected_version, Q0, Q1 opcional e justificativa), fingerprint SHA-256 determinístico, checagem de permissão `evidence.prepare_question` já presente no projeto, validação de entradas, backend transacional **somente injetado** e validação de recibo `PREPARATORY_ONLY`. Sem backend, retorna HOLD; exceção desconhecida retorna estado incerto e proíbe retry implícito. Respostas que indiquem E9 não são aceitas.

`tests/test_pf_i02_w1_contract.py` testa anônimo e autenticado sem permissão, persistência ausente, recibo positivo sob mock, fingerprint, entrada inválida, falha indeterminada, recibo inválido e ausência de rotas POST Q0/Q1. Workflow `.github/workflows/oes-pf-i02-w1-offline.yml` executa check e suíte Django.

## CI
Run **40265423907**, commit `b7ba8b1951ba1254b24fd6fc8ffef297fa16973f`: `completed/success`. Não houve SQL/Neon, criação de usuários, grants ou credenciais.

## Limitações materiais
**W1 parcial quanto ao contrato HTTP integral.** Nenhuma rota GET/POST de perguntas foi exposta — escolha fail-closed deliberada enquanto `DEBUG=True`, secret de desenvolvimento e banco `dummy` persistem. CSRF e sessões estão apenas no scaffold; nenhum formulário, autenticação real ou teste HTTP com sessão de usuário foi demonstrado. O serviço não implementa concorrência, idempotência durável, vínculo efetivo de versões, preservação no banco ou auditoria: esses requisitos pertencem ao unit-of-work ainda inexistente e precisarão de novos testes/integridade antes da W3. O teste de mock não demonstra uma transação real. Não declarar W1 integralmente concluído apenas por CI verde.

## Parecer
`W1_OFFLINE_COMMAND_BOUNDARY_TESTED / HTTP_AND_DURABLE_UOW_PENDING`. Próximo: consolidar o desenho preciso de backend transacional, identidade Django persistente e papéis do PostgreSQL e autorizar W2 separadamente, sem liberar HTTP ou E9. CP300 vigente; Marco B aberto, E9 NO-GO, readiness `NOT_READY`, A3 não realizada.
