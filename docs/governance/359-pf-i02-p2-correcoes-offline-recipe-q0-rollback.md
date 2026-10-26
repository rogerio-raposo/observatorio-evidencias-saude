# Documento 359 — PF-I02/P2 — Correção offline do recipe Q0 com rollback
Data: 2026-10-26. Referência: CP312, Doc358, CI anterior 40287310584 (173/173 PASS).
Escopo autorizado: correção de código offline; sem Neon, DML/DDL, SET ROLE, grants, credenciais, writer Django, HTTP write, deploy, E9 ou G2-P2B.

## Incremento
O recipe `question_orm_q0_connected_recipe_dormant.py` agora especifica guardas de PostgreSQL, autocommit habilitado e ausência de transação externa, antes de ingressar em `transaction.atomic(using=alias, savepoint=False)`. Dentro do bloco exige `in_atomic_block` e autocommit desligado, aplica locks/ORM ao mesmo alias, verifica cinco vínculos sintéticos e define rollback obrigatório. Após sair da transação, especifica cinco consultas pontuais `exists()` por UUID/PK ou `(actor_id,request_id)`, rejeitando qualquer resíduo e emitindo somente status `ROLLED_BACK_ONLY` quando todas forem negativas.

## Limites e risco residual
O ponto de entrada `execute_connected_q0` continua sempre HOLD, e o construtor `DjangoQ0Repository` continua sempre HOLD; **o recipe não é alcançável nem executado por testes**. O novo teste inspeciona estrutura de código, não uma conexão real. O pós-rollback é um desenho para execução futura com o mesmo alias, não uma verificação factual; não prova privilégios mínimos, independência de sessão, ausência de triggers/efeitos não transacionais, commit ou replay. A ativação exigirá revisão e autorização nova, nunca um bypass do construtor. A CI atualizada necessita execução e confirmação.

**Estado:** `Q0_ROLLBACK_GUARDS_CODE_PREPARED / CI_PENDING / G2_P2B_NO_GO / CP312_ACTIVE / E9_NO_GO`. Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED.
