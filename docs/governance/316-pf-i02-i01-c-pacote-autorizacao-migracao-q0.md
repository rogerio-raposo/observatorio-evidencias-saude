# Documento 316 — PF-I02-I01-C: pacote de autorização delimitada da migração Q0-only

**Data:** 2026-10-26. **Situação:** `PROPOSED_FOR_APPROVAL / NO_DDL_EXECUTED`. Fundamentação: Docs. 309, 313–315, CP298. Este documento **não é autorização** para executar SQL.

## Objeto da decisão
Autorizar futuramente **uma** mudança estrutural, em transação, na branch **sintética** `br-gentle-hall-b6jaxehf`, projeto Neon `weathered-boat-65779510`, banco `oes_sandbox`, tabela `investigation.question_version`. Não alterar branch `production`, esquema de Investigation formal, usuários, grants, credentials, Django, workflows ou dados históricos. Sem custos pagos.

## Pré-condições bloqueantes imediatamente antes de DDL
1. Freshness Gate GitHub; conferir projeto/branch/banco/role efetivos e transação de preflight `READ ONLY` em chamada separada; bloquear se destino, schema ou dependências divergirem. **A transação de DDL subsequente não pode ser READ ONLY**, exigindo aprovação expressa exclusiva.
2. Conferir existência da coluna `preparation_stage` e da constraint `ck_pf_i02_question_preparation_stage` (devem estar ausentes), nulidade atual de `normalized_text` (deve ser `NO`), dependências e contagem agregada de legados nulos (zero); sem leitura de textos/payloads.
3. Conferir quem detém autoridade para ALTER no alvo, cronograma de janela sem concorrência e backups/retention pertinentes. Papel proprietário só pode ser usado na execução pontual autorizada e nunca na conexão Django.
4. Aprovar exatamente o SQL abaixo, com `lock_timeout` e `statement_timeout`, e registrar antes/depois de catálogo. Falha/timeout => rollback e HOLD, sem retry automático.

## SQL candidato fechado — NÃO EXECUTAR SEM AUTORIZAÇÃO
```sql
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '10s';
ALTER TABLE investigation.question_version
  ADD COLUMN preparation_stage text NOT NULL DEFAULT 'legacy_complete';
ALTER TABLE investigation.question_version
  ALTER COLUMN normalized_text DROP NOT NULL;
ALTER TABLE investigation.question_version
  ADD CONSTRAINT ck_pf_i02_question_preparation_stage
  CHECK (
    (preparation_stage = 'q0_draft' AND normalized_text IS NULL)
    OR (preparation_stage IN ('q1_proposed', 'legacy_complete')
        AND normalized_text IS NOT NULL)
  );
COMMIT;
```

## Pós-condições mínimas
- `preparation_stage` existe, `NOT NULL`, default `legacy_complete`;
- `normalized_text` tornou-se nullable, mas CHECK impede nulo fora de `q0_draft`;
- linhas históricas continuam `legacy_complete` com `normalized_text` preenchido (somente contagem agregada/metadata);
- nenhuma tabela da família `investigation.investigation*` alterada; nenhuma inserção ou mudança em usuários/grants;
- registrar recibo de execução e eventual erro com sanitização. **Este gate não compreende teste DML sintético de Q0**, que exige autorização separada.

## Recuperação
Se a transação falhar antes de COMMIT: rollback transacional e verificação do catálogo; não presumir estado se resultado de COMMIT for incerto. Após COMMIT, antes de qualquer Q0 novo, reversão candidata em transação autorizada: remover CHECK e coluna `preparation_stage`, restaurar `normalized_text SET NOT NULL` somente após atestar ausência de nulos. Se Q0 nulas já existirem, **não** executar reversão destrutiva nem inventar Q1: congelar escrita, preservar dados e decidir migração de recuperação.

## Autorização solicitável
`APPROVED — OES / PF-I02-I01-C / SINGLE_SYNTHETIC_Q0_SCHEMA_MIGRATION / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / exact Doc316 DDL only / preflight and postflight / no DML / no GRANT or role changes / no Django connection / no E9 / no paid services / fail closed`.

## Fronteira e continuidade
É uma decisão de **migração estrutural sintética**, não liberação de escrita funcional. I01-A continua `COMPLETED_OFFLINE_AUTH_SCAFFOLD_ONLY`, I01-B `DESIGNED_NOT_APPLIED`, I01-D não iniciado, autenticação independente operacional e autorização DB de menor privilégio pendentes. Marco B aberto, E9 NO-GO, A3 ausente, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.
