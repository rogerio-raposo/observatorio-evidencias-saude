# Documento 328 — PF-I02: revisão da porta PostgreSQL transacional Q0→Q1

**Data:** 2026-10-26. **Estado:** `SQL_ADAPTER_REVIEW_ONLY / NOT_AUTHORIZED_TO_EXECUTE`. Base CP300, Docs. 319, 323–327. Não contém autorização para execução de SQL, conexão de aplicação, role/grant, credenciais ou ativação HTTP.

## Verificação de continuidade
Freshness Gate `main` idêntico a `85b21c9924dbf035a229ef639b648de077bcb912` no início. W1B em `applications/oes_web/evidence/question_uow_offline.py`: métodos de porta `begin/lock_request/find_receipt/current_question/register_q0/propose_q1/save_receipt`. CI 40266279555 validou uma porta fake, **não** comportamento PostgreSQL.

## Contrato concreto a implementar — uma única transação
1. `begin()`: conexão somente com futuro writer não-owner, `transaction.atomic(using=...)` ou psycopg transacional; aplicar `SET LOCAL lock_timeout` e `statement_timeout`, sem fallback de credencial. O registro do ledger e da pergunta deve usar **a mesma conexão e transação**. Não misturar Django default dummy e alias de leitor PG-A4.
2. `lock_request(actor,request)`: serializar a chave de idempotência. Para evitar corrida em INSERT quando ainda não existe recibo, mecanismo candidato: `pg_advisory_xact_lock` com chave derivada de identificador canônico; colisões de hash só provocam serialização excessiva, nunca autorização ou identidade. **A segurança final reside na constraint UNIQUE/PK `(actor_id,request_id)`** e na releitura sob lock; não presumir unicidade da chave de hash.
3. `find_receipt`: SELECT de recibo por ator e request_id; igualdade *exata* de fingerprint e question_id; replay retorna versão original sem DML, mesmo após avanço de versões posteriores. Rejeitar request_id reutilizado com payload diferente. Na reconciliação de timeout/commit incerto, consulta independente restrita, não replay automático.
4. `current_question(question_id,actor,lock)`: localizar identidade por `core.entity.oes_id`, exigir tipo `Question` e escopo autorizado; `SELECT ... FOR UPDATE` em `core.entity` antes de verificar versão corrente de Q1; retornar versão e Q0 da última versão. **A mesma autorização deve preceder replays**, não apenas novos writes. Uma política de acesso ao nível de registro ainda precisa ser aprovada.
5. `register_q0`: permitir apenas expected_version=0, Q1 ausente e pergunta inexistente; UUIDs gerados no servidor, quatro INSERTs na ordem `core.entity → investigation.question → core.entity_version → investigation.question_version`, com `q0_draft`, `original_text` literal e `normalized_text=NULL`. Colisões de OES ID/UUID: conflito sem reparo automático.
6. `propose_q1`: exigir versão esperada igual à corrente e `original_text` idêntico; alterar apenas `core.entity_version.version_status/valid_to` da versão anterior, inserir nova `core.entity_version` e `investigation.question_version` com `q1_proposed`, vínculo de supersessão e justificativa de normalização retida em metadado auditável. A ordem update-antes-insert respeita índice parcial de uma versão `current`; se INSERT falhar, rollback deve reverter UPDATE.
7. `save_receipt`: INSERT no único `investigation.question_command_receipt` do Doc.326, com ator, request_id, fingerprint, entidade, versão e tipo; só na mesma transação de sucesso. Chave `(actor_id,request_id)` imutável. **Receipt.version_uuid deve corresponder à versão criada** e a FK composta/validação de identidade deve impedir associação a outra pergunta, não apenas FK isolada.
8. `commit`: retornar `PREPARATORY_ONLY` após confirmação; falha antes do commit = rollback; confirmação indeterminada = HOLD e reconciliação, sem reexecução implícita.

## Revisões bloqueantes detectadas
- **Escopo humano**: ausência de RLS nas quatro tabelas e SELECT amplo do Doc.324. Acesso Django de um único preparador sintético é hipótese restrita, não prova de isolamento DB. Separar políticas runtime de ensaio de ACL; sem multiusuário antes de prova de leitura cruzada.
- **Justificativa**: W1 inclui `justification`, mas a porta W1B não define persistência; exigir campo auditável em ledger/metadado apropriado antes da implementação SQL.
- **Vínculos**: ledger do Doc.326 usa FK `resulting_version_uuid` isolada; acrescentar integridade referencial entre recibo, entidade e versão, aproveitando `UNIQUE(version_uuid,entity_uuid)` existente, sem duplicar perguntas.
- **Atomicidade/concorrência**: fake usa `lock_request` no-op. Exigir prova conectada posterior de mesma chave simultânea, duas propostas concorrentes, falha no INSERT do ledger e commit incerto.
- **Autorização de replay**: em W1B `find_receipt` é consultado antes de `current_question`; o adaptador deve verificar escopo do ator **antes de retornar recibo**. Não permitir vazamento por request_id/actor_id induzido.
- **Identidade e logs**: `created_by` texto não autentica o ator; obter user id de sessão Django real, auditar desabilitação/rotação e não registrar Q0/Q1 em logs.
- **Compatibilidade**: Django `DATABASES` é dummy salvo leitor experimental; nenhum writer alias deve ser habilitado enquanto role/credencial não aprovados.

## Testes de aceite futuro
Repetição idêntica devolve mesmo recibo; reuso divergente rejeitado; Q1 preserva Q0 e apenas uma current; conflito de versão e acesso cruzado bloqueados; falhas de FK/ledger causam rollback íntegro; duas sessões concorrentes não duplicam versões; commit incerto reconciliado sem replay; consultas de E9 e outras famílias negativas; cleanup sintético exclusivamente autorizado.

## Recomendação
Próximo gate proporcional: **corrigir offline a especificação de recibo, justificativa e autorização de replay, mais contrato da porta SQL sem executá-lo**, seguido de revisão de grant preciso e autorização independente para DDL/role. Não repetir T1/T2 administrativos. Nenhum DDL, DML, role ou operação Neon nesta atividade.

**Invariantes:** Marco B aberto; E9 NO-GO; A3 ausente; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
