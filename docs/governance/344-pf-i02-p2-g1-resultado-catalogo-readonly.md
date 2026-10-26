# Documento 344 — PF-I02 / P2 / G1 — Resultado do preflight conectado de catálogo READ ONLY
**Data:** 2026-10-26. **Autorização:** usuário: “Autorizado G1”. **Base:** Doc.343, CP310. **Escopo:** somente catálogo/ACL, nenhum dado de usuário/Question/recibo consultado.

## Identidade e isolamento da execução
Neon project `weathered-boat-65779510`; branch `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`), confirmada como não default, `primary=false`; database `oes_sandbox`. Consultas executadas via `run_sql_transaction`, cada uma iniciando `SET TRANSACTION READ ONLY`; preflight retornou `current_database=oes_sandbox`, `current_user=oes_sandbox_owner`, `transaction_read_only=on`. Somente metadados de catálogo e privilégios; sem SET ROLE, DML, DDL, rows de Question, segredos ou mudança de grants.

## Achados objetivos
- Cinco tabelas alvo presentes: `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version`, `investigation.question_command_receipt`.
- `oes_qprep_writer`: SELECT e INSERT em todas as cinco; UPDATE **geral negado** nas cinco; UPDATE por coluna **somente** `core.entity_version.version_status` e `core.entity_version.valid_to` confirmados. Em particular, não tem UPDATE em `investigation.question`.
- O SQL offline Q1 emprega `FOR UPDATE OF q, ev`, ao passo que o papel não possui UPDATE de `q`: incompatibilidade **potencial relevante**, exigindo avaliação de privilégios e semântica de bloqueios; G1 não executou SELECT FOR UPDATE nem qualquer ensaio de permissão conectada. Não conceder UPDATE amplo automaticamente.
- `core.entity.oes_id`: unique `entity_oes_id_key`. `core.entity_version`: unique `(entity_uuid,version_no)` e índice parcial `ux_entity_version_current` sobre `entity_uuid` onde `version_status='current'`.
- `investigation.question.responsible_actor_id` é `text NULL`, constraint `ck_pf_i02_question_responsible_actor` comprimento btrim 1–128 quando não NULL.
- `investigation.question_version`: `preparation_stage` NOT NULL e CHECK q0_draft+normalized_text NULL versus q1_proposed/legacy_complete+normalized_text NOT NULL.
- Ledger: checks de actor/request não vazios e até 128, fingerprint hexadecimal minúsculo sha256, command_kind Q0/Q1 e coerência de versão/justificativa.
- `core.entity_version.change_type` é TEXT NOT NULL; isso **não** homologa a nomenclatura `normalization_proposed`.
- RLS `relrowsecurity=false` e `relforcerowsecurity=false` nas quatro tabelas verificadas em consulta de constraints (entity_version, question, question_version, ledger). Sem isolamento por linha demonstrado.

## Decisão e limites
**`G1_CATALOG_READ_ONLY_VERIFIED / G2_NO_GO_PENDING_SEPARATE_AUTHORIZATION`.** O G1 comprova apenas metadados, não o sucesso/falha efetiva de bloqueios PostgreSQL, transações, concorrência, policy de usuários ou dados reais. Recomenda-se antes de G2 revisar offline a estratégia de locks de `investigation.question` para não exigir UPDATE amplo e especificar a forma segura de transação/identidade; qualquer ensaio conectado sintético mínimo exige aprovação nominal adicional. Sem alterar gates atuais. Marco B aberto, Fase 5 NOT_STARTED, readiness NOT_READY, E9 NO-GO.
