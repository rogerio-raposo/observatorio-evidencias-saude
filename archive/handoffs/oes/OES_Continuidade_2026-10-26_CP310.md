# OES — CP310 | Encerramento técnico restrito Q0→Q1 offline
**Data:** 2026-10-26. **Anterior:** CP309. **Decisão:** `Q0_Q1_OFFLINE_TECHNICAL_CLOSURE_ONLY`.

## Evidências
GitHub Actions https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40277043796: SUCCESS, `140/140` testes PASS, Django check sem problemas, commit `a18f90575ae8ede0ac7bce779623e980c86c5ede`. Corrigida a consulta `current_question` para exigir `version_status='current'` e `valid_to IS NULL`. Documentos 341–342 e componentes `question_sql_port_offline.py`, `question_uow_offline.py`, suites de Q0/Q1 e replay.

## Encerramento e limites
Q0 e Q1 com cursor injetado; versionamento, preservação Q0 literal, recibos, verificação de responsabilidade, idempotência/replay e rollback **simulados**. Isso encerra o incremento **offline e sintético**, não constitui validação SQL PostgreSQL conectada ou aplicação operacional. Não ampliar a leitura de resultados para segurança multiusuário. A3 ausente, sem pesquisadores associados.

## Bloqueios explicitamente diferidos ao futuro gate conectado
1. Provar semântica SQL PostgreSQL de `SELECT ... FOR UPDATE OF q, ev`, `FOR SHARE OF q`, grants por tabela/coluna e eventual exigência de privilégios adicionais; `oes_qprep_writer NOLOGIN` não tem UPDATE em `investigation.question`. **Não modificar ACL automaticamente**.
2. Estabelecer factory conectada com transação atômica, rollback/commit, timeout e tratamento de resultado de commit incerto; verificar isolamento e interleavings de Q1 e revogação.
3. Decidir segregação de acesso por registro; RLS ausente, `created_by` não equivale a autorização. Modelo de responsável único sintético não equivale a acesso de pesquisadores reais.
4. Reconciliar `change_type='normalization_proposed'` e verificar compatibilidade com schema, índices/constraints e migrações da base efetiva.
5. Tratar colisão global de `oes_id` via UNIQUE, em falha transacional sem divulgação de entidade de outro ator; avaliar vínculo UUID de recibo no replay.
6. Rever a leitura dupla de versão Q1 e corrida TOCTOU sob conexão autorizada; testes offline não simulam locks reais.

## Continuidade
Próxima atividade proporcional: avaliar desenho do gate conectado, apenas documental e read-only no **repositório** até autorização nominal. Não criar credenciais, não SQL conectado, não Neon, não DDL/DML, não SET ROLE, não grants, não HTTP write, não deploy, não E9, sem serviços pagos. Não solicitar repetição de casos já cobertos por 140 testes offline.

**Invariantes:** Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; E9 NO-GO; CP310 vigente após atualização do ponteiro.
