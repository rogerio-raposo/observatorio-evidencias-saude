# Documento 353 — G2-P0 — Preflight conectado READ ONLY — execução factual
Data: 2026-10-26. Autorização: usuário "Autorizado" em resposta à proposta específica do G2-P0 do Doc.352. **Somente catálogo; nenhuma consulta de registros, DML, DDL, transação de teste, SET ROLE ou alteração de grants.**

## Destino e identidade verificados
- Projeto Neon `weathered-boat-65779510`; branch não-default `br-gentle-hall-b6jaxehf`, pronta, nome `oes-pg-a3-synthetic-20261024`.
- Banco `oes_sandbox`; proprietário `oes_sandbox_owner`.
- Sessão de leitura de catálogo: `session_user=current_user=oes_sandbox_owner`; **não houve conexão/SET ROLE como `oes_qprep_writer`**.
- PostgreSQL versão retornada 18.6 (fd34222).

## Catálogo e grants observados (papel alvo oes_qprep_writer)
- `rolcanlogin=false`; `rolinherit=false`.
- `USAGE` em schemas `core` e `investigation`: true.
- Cinco tabelas canônicas existentes: `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version`, `investigation.question_command_receipt`. Em todas: SELECT true, INSERT true, DELETE false, UPDATE de tabela false, RLS false.
- Únicos UPDATEs de coluna identificados: `core.entity_version.version_status` e `core.entity_version.valid_to`. Nenhuma coluna de `investigation.question` tem UPDATE.
- Defaults: `core.entity.created_at`, `core.entity_version.valid_from`, `core.entity_version.created_at`, `investigation.question_command_receipt.committed_at` = `CURRENT_TIMESTAMP`. `investigation.question_version.preparation_stage` = `'legacy_complete'`; ledger `justification` = string vazia.
- Constraints observadas: `core.entity(oes_id)` UNIQUE; `core.entity_version(entity_uuid,version_no)` UNIQUE; `core.entity_version(version_uuid,entity_uuid)` UNIQUE; índice parcial `ux_entity_version_current`; FK composta entre `investigation.question_version(version_uuid,entity_uuid)` e `core.entity_version`; ledger PK composta `(actor_id,request_id)`; FK composta receipt para `core.entity_version`; CHECK de stage Q0/Q1 e recibo.
- Atributos de privilégios são do papel-alvo consultados via catálogo, **não demonstram obtenção autorizada de sua identidade em runtime**.

## Avaliação de gate
**G2-P0 READ ONLY FACTUALLY COMPLETED**, compatível com as premissas básicas de schema e ACL. Não há autorização de G2-P1/P2, nem writer configurado. Permanecem pendentes: identidade runtime e mecanismo seguro de autorização de conexão, sem assumir SET ROLE; comportamento de triggers e grants na execução; verificação de constraints completas e compatibilidade Django; advisory locks reais, atomicidade e evidência de rollback; definição expressa de G2-P2. Não executar SELECT FOR UPDATE em `investigation.question` sem UPDATE. `managed=False` não é controle de escrita.

## Bloqueios
`G2_P0_READ_ONLY_COMPLETE / G2_P1_NOT_AUTHORIZED / G2_P2_NO_GO / E9_NO_GO`. CP311 vigente; Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED.
