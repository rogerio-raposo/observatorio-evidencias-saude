# Documento 358 — PF-I02/P2 — Auditoria crítica do harness Q0 antes de G2-P2B
Data: 2026-10-26. Base CP312, docs 355–357, CI 40287310584 (173/173 PASS), SHA `0698a36e1141acee43bc3ffd921e33111e3645b0`.
**Escopo: revisão estática/offline. Nenhuma conexão Neon, DML, DDL, role/grant, credencial ou deploy.**

## Diagnóstico e decisão
**O harness ainda não está apto à execução conectada.** A CI verifica o bloqueio, não a semântica conectada. Em `question_orm_q0_connected_recipe_dormant.py`, `execute_connected_q0` sempre lança HOLD; `_rollback_recipe` chama `DjangoQ0Repository(alias=alias)`, cujo construtor sempre lança HOLD, de modo que nenhuma linha do bloco `transaction.atomic` é exercitada. Isto é bloqueio deliberado, não defeito a ser contornado por `object.__new__` ou monkey patch.

### Lacunas materiais encontradas
1. **Isolamento transacional:** `transaction.atomic(using=alias, savepoint=False)` pode executar dentro de uma transação externa; `transaction.set_rollback(True)` não prova que todos os efeitos estão limitados ao ensaio. Uma futura execução deverá verificar a ausência de atomic externo **antes** de abrir o bloco, com conexão/alias aprovados, autocommit e transação exclusivamente controlada; fail-closed se houver ambiguidade.
2. **Conexão e identidade:** chamadas `.using(alias)` e `connections[alias].cursor()` são coerentes apenas se alias, backend e identidade PostgreSQL forem aferidos na **mesma sessão de execução**. Com owner excepcional, registrar o limite: não prova least privilege.
3. **Rollback residual:** o código marca rollback e depois sempre lança HOLD por falta de verificação independente. Necessário mecanismo posterior que consulte **somente os identificadores sintéticos previamente gerados** e comprove zero linhas nas cinco tabelas; leitura deve ser explícita e delimitada, nunca varredura ou suposição.
4. **Contagem de efeitos:** cinco chamadas `create` e cinco verificações `exists` não demonstram, por si sós, ausência de triggers/efeitos não transacionais, contagem de linhas afetadas ou isolamento de concorrência. Reconhecer limites de evidência.
5. **Segurança semântica:** `_rollback_recipe` não passa pelo serviço completo `OfflineQuestionUnitOfWork.execute`; por isso não prova fingerprint calculado pelo serviço, autorização/replay de ponta a ponta ou Q1. A futura prova deve ser explicitamente limitada à transação Q0 mínima.
6. **Papel administrativo:** `oes_sandbox_owner` possui poderes superiores aos de `oes_qprep_writer`; aceitar excepcionalmente só no piloto, com consentimento explícito, sem reusar em aplicação ou habilitar HTTP write.

## Encaminhamento eficiente
Não elevar cobertura por testes sintéticos de simples presença de código. Em nova atividade **aprovada**, realizar uma única implementação coesa do harness isolado, com ativação explícita e não operacional apenas em ambiente controlado, verificação pré-transação, pós-rollback pontual e testes offline de falha; submeter então novo gate formal para execução conectada. Sem autorização nominal G2-P2B, **nenhuma escrita Neon**.

**Gate atual:** `STATIC_REVIEW_COMPLETE / CONNECTED_HARNESS_NOT_READY / G2_P2B_NO_GO / CP312_ACTIVE / E9_NO_GO`. Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED.
