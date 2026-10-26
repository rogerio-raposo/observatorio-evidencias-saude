# Documento 337 — PF-I02-P2-A7: proposta de persistência do responsável sintético (NÃO EXECUTAR)
**Data:** 2026-10-26. **Estado:** DESIGN_ONLY / NO_DDL_APPROVED. Base: CP307, Doc.336 e preflight Neon A6 de catálogo READ ONLY.

## Evidência A6
Projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`; transação `READ ONLY=on`. `investigation.question` possui apenas `entity_uuid uuid NOT NULL` (PK e FK para `core.entity`). `core.entity.created_by text NULL` é autoria histórica, não responsabilidade atual. `investigation.question_command_receipt.actor_id` é executor histórico, não titular vigente. Nenhuma coluna/resolução de responsável atual foi verificada. Não se consultaram linhas de usuários/perguntas nem se alterou o banco.

## Modelo mínimo candidato
Uma coluna **anulável** `investigation.question.responsible_actor_id text`, onde NULL significa **sem responsável / acesso negado**, jamais acesso público. O responsável inicial de Q0 (apenas experimental) será `str(user.pk)` obtido após gate `evidence.prepare_question`, e sua escrita precisa ocorrer atomicamente com a criação de Question. Na leitura de Q1 e replay, somente correspondência estrita do valor **não nulo** com ator autorizado permite acesso. A coluna não representa autenticação independente nem titularidade institucional. Histórico de autoria continua em `core.entity.created_by`; recibos do ledger permanecem imutáveis. Transferências, delegação e restauração de titularidade estão fora de escopo.

A nulidade admite revogação sem exclusão do registro ou perda de recibos, e evita atribuir responsabilidade fictícia a dados legados. Para qualquer Question sem responsável, Q1/replay => HOLD. O banco não consegue garantir só com CHECK que toda criação Q0 recebe o criador vigente; essa invariância exige transação e teste, ou novo mecanismo em gate futuro.

## DDL candidato mínimo — SOMENTE REVISÃO
```sql
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '10s';
ALTER TABLE investigation.question
  ADD COLUMN responsible_actor_id text NULL,
  ADD CONSTRAINT ck_pf_i02_question_responsible_actor
    CHECK (responsible_actor_id IS NULL
           OR length(btrim(responsible_actor_id)) BETWEEN 1 AND 128);
COMMIT;
```
Condição de aplicação: branch/banco/owner/objeto/coluna/constraint checados em preflight READ ONLY imediatamente anterior; nenhum DML ou backfill. Não incorporar esse DDL a migrações até aprovação nominal separada. Não alterar `core.entity`, `question_version` ou ledger.

## ACL e atualização — GATE INDEPENDENTE
W2a permite SELECT/INSERT em `investigation.question`, **não UPDATE**. A inserção Q0 poderia fornecer `responsible_actor_id` no próprio INSERT com o writer, mas revogação efetiva (atribuição NULL) exige fluxo administrativo separado, com autorização institucional e privilégio mínimo próprio a definir — **não conceder UPDATE geral ao writer**. Mesmo com comparação em SQL, RLS ausente e SELECT ampla do writer impedem alegação de isolamento no nível do banco: a aplicação precisa de política validada e prova de não vazamento antes de qualquer runtime.

## Recovery candidata — NÃO EXECUTAR
Antes de COMMIT, erro implica ROLLBACK e pós-verificação. Após COMMIT, não aplicar DROP automático. A eventual reversão exige demonstrar ausência de dependências e de atribuições existentes, aprovação específica e plano de retenção; `DROP COLUMN ... CASCADE` proibido. Evitar perda de autorizações e trilhas.

## Aceite em gates separados
1. Aprovar projeto de DDL e executar futuramente apenas coluna+CHECK em transação única sintética, com pre/post metadata READ ONLY.
2. Validar offline fail-closed: Q0 com responsável inicial; Q1/replay com responsabilidade atual; revogação NULL; outro ator bloqueado; exceções/rollback; nenhuma consulta por recibo como autoridade.
3. Revisar em separado ACL, autenticação técnica e fluxo de revogação; ensaios conectados sintéticos só com autorização específica.
4. Reavaliar RLS/segregação antes de participantes reais.

**Fronteiras:** nenhuma operação Neon nesta atividade; W2b/W3, DML, SET ROLE, LOGIN, credenciais, HTTP write, E9, produção ou serviços pagos não autorizados. Marco B aberto; readiness NOT_READY; Fase 5 NOT_STARTED.
