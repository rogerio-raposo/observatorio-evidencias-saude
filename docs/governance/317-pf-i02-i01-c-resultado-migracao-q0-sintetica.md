# Documento 317 — PF-I02-I01-C: resultado da migração sintética Q0-only

**Data:** 2026-10-26. **Autorização expressa:** `APPROVED — OES / PF-I02-I01-C / SINGLE_SYNTHETIC_Q0_SCHEMA_MIGRATION / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / exact Doc316 DDL only / preflight and postflight / no DML / no GRANT or role changes / no Django connection / no E9 / no paid services / fail closed`. **Documento de referência:** 316.

## Contexto exato
Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`. Papel efetivo `oes_sandbox_owner`. Branch `production` não acessada.

## Preflight (transação READ ONLY)
`transaction_read_only=on`; `preparation_stage` ausente, constraint `ck_pf_i02_question_preparation_stage` ausente, `normalized_text.is_nullable=NO`; total de versões Question **0**, nulos legados **0**; proprietário igual ao papel conectado; uma FK dependente da tabela detectada. Nenhuma linha de conteúdo científico lida.

## Execução aprovada
Uma única chamada Neon `run_sql_transaction` realizou as instruções DDL equivalentes ao corpo transacional do Documento 316: `SET LOCAL lock_timeout='2s'`, `SET LOCAL statement_timeout='10s'`, `ALTER TABLE ... ADD COLUMN preparation_stage text NOT NULL DEFAULT 'legacy_complete'`, `ALTER COLUMN normalized_text DROP NOT NULL`, `ADD CONSTRAINT ck_pf_i02_question_preparation_stage CHECK ((preparation_stage='q0_draft' AND normalized_text IS NULL) OR (preparation_stage IN ('q1_proposed','legacy_complete') AND normalized_text IS NOT NULL))`. O conector encapsula as instruções em uma transação; nenhuma repetição automática. Retorno sem erro.

## Postflight (nova transação READ ONLY)
`transaction_read_only=on`, no banco autorizado. Colunas:
- `normalized_text`: `is_nullable=YES`;
- `original_text`: `is_nullable=NO`;
- `preparation_stage`: `is_nullable=NO`, default `'legacy_complete'::text`.
A constraint foi confirmada por `pg_get_constraintdef` com as duas condições esperadas. `investigation.question_version` tinha **0** linhas, 0 inconsistências e 0 linhas legadas a migrar; portanto a preservação de histórico é vacuamente satisfeita, **não testada sobre registros legados presentes**.

## Limites e aceite
**`SYNTHETIC_Q0_SCHEMA_MIGRATION_APPLIED_VERIFIED`**, estritamente na branch indicada. Não houve DML de perguntas, teste de insert Q0, conexão Django, role/grant, credencial, publicação científica, abertura E9, serviço pago ou deploy. O uso de papel owner foi limitado à mudança explicitamente autorizada; não é identidade da aplicação. Não foi demonstrada proteção por papel least-privilege nem autenticação independente. Não inferir homologação de produção ou de fluxo persistente.

## Seguimento
Antes de Q0→Q1 integrado: consolidar checkpoint, decidir papel técnico writer/credenciais e validação sintética de transação/idempotência mediante autorização separada; manter controle de rollback não destrutivo. O SQL reverso não foi executado. PF-I02-I01-D não iniciado. Marco B aberto; readiness `NOT_READY`; E9 NO-GO; A3 ausente.
