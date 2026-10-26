# Documento 315 — PF-I02-I01-C: preflight de constraints e índices em transação READ ONLY

**Data:** 2026-10-26. **Base:** Documento 314; CP298. **Escopo:** catálogo PostgreSQL da branch sintética `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`, banco `oes_sandbox`. Não foi inspecionada a branch `production`.

## Execução e limite de autoridade
Uma chamada `run_sql_transaction` realizou `SET TRANSACTION READ ONLY` e três SELECTs: confirmação de contexto, `pg_constraint` e `pg_indexes` para `core.entity`, `core.entity_version`, `investigation.question` e `investigation.question_version`. A consulta de contexto retornou `transaction_read_only=on`, banco `oes_sandbox`, papel `oes_sandbox_owner`. O papel conectado continua proprietário; **proteção transacional read-only confirmada nesta chamada não equivale a isolamento por privilégio mínimo**. Nenhum DDL, DML, GRANT, role ou segredo foi alterado.

## Restrições verificadas
- `investigation.question_version.normalized_text`: restrição NOT NULL, incompatível com Q0 isolada; `original_text`: NOT NULL.
- `investigation.question_version` possui PK `version_uuid`, FK de entidade `question` e FK composta para `core.entity_version`; não apareceu coluna/constraint de estágio preparatório.
- `core.entity`: PK entidade e unicidade de `oes_id`.
- `core.entity_version`: PK `version_uuid`, unicidade `(entity_uuid, version_no)`, FK de `supersedes_version_uuid` na mesma entidade, check `version_no>0`, check de status `draft/current/superseded/archived/invalidated`.
- Índice parcial único `ux_entity_version_current` em `entity_uuid` quando status `current`; impacto sobre ordem de mudanças de status e concorrência precisa ser testado no gate de transação.
- Não houve leitura de linhas de Question, detalhes de usuários, credenciais ou material científico.

## Parecer
**CATALOG_CONSTRAINT_INDEX_READ_ONLY_CONFIRMED** somente nesta branch sintética: estrutura existente corresponde aos pressupostos de migração do Documento 313. Não se confirmou compatibilidade de todos os triggers/dependências, histórico de migrations aplicado, ACLs de escritor futuro ou viabilidade em `production`. Não autoriza aplicar o SQL do Documento 313.

## Próxima decisão
Passar do diagnóstico repetitivo para uma decisão objetiva sobre **ambiente e autorização de migração**: preferir branch sintética isolada já conhecida para validação inicial, mas requerer aprovação expressa do alvo, DDL exato e rollback, e credenciais/roles próprias antes de conexão de escrita. Evitar novas leituras apenas para reconfirmar NOT NULL. Manter implantação externa e E9 bloqueadas.

Marco B aberto, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`, A3 não realizada.
