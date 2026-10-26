# Documento 332 — PF-I02: auditoria complementar somente leitura

Data: 2026-10-26. Checkpoint de partida: CP302. Freshness Gate: main idêntico a d1f95c737c701c803e5ea6bd227f04c2df14bbf9.

Ambiente sintético: projeto weathered-boat-65779510; branch br-gentle-hall-b6jaxehf; banco oes_sandbox. Transação READ ONLY confirmada.

A função core.assert_entity_type, utilizada por tr_question_entity_type, tem SECURITY DEFINER desabilitado e EXECUTE efetivo por PUBLIC habilitado. Contagem de políticas pg_policy nas tabelas core.entity, core.entity_version, investigation.question, investigation.question_version e investigation.question_command_receipt: zero. A auditoria anterior confirmou oes_qprep_writer inexistente e ausência de DML PUBLIC nas tabelas consultadas.

Interpretação delimitada: EXECUTE por PUBLIC, por si, não prova acesso ou exploração indevida, mas exige revisão de necessidade e do caminho de execução do trigger. RLS ausente não estabelece isolamento por preparador. Não foram criados papéis, GRANTs, DML, DDL, usuários ou rotas HTTP.

Estado: READ_ONLY_FUNCTION_AUDIT_COMPLETE / W2A_HOLD. Antes de provisionar writer, revisar fonte da função, search_path, permissões indiretas e política de isolamento; autorizações conectadas continuam separadas. Marco B aberto; E9 NO-GO; readiness NOT_READY.
