# Documento 329 — PF-I02: correções offline de replay e justificativa

**Data:** 2026-10-26. **Escopo:** apenas código Django offline e testes de W1B, sem Neon, SQL, role/grant, usuário real ou endpoint de escrita.

## Evidência
Ajustado `question_uow_offline.py` para exigir `can_access_question` antes de devolver recibo previamente salvo; receipt offline passou a incluir `command_kind` e `justification` para Q1. `question_preparation.py` limita request_id a 1–128 caracteres e exige justificativa não vazia para Q1. Os testes incluem replay após revogação lógica de acesso, replay histórico após Q1, justificativa no recibo e limite do request_id.

Primeira execução `40266665065` falhou por `IndentationError` introduzido na edição; problema corrigido no commit `4d92a1cd42b89f8948623248860c62b32ea13b7f`. CI final `40266729081`: `completed/success`.

## Limites
A porta transacional continua simulada e usa lock no-op; não há serialização real, identidade Django persistente, ledger físico, RLS, driver PostgreSQL, verificação de concessões ou autorização HTTP. A justificativa de Q1 consta no recibo offline mas ainda não no banco. Esse resultado não prova segurança multiusuário ou tolerância a commit incerto. Nenhum E9. Marco B aberto e readiness `NOT_READY`.
