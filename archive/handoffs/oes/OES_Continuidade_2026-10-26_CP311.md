# OES — CP311 | Consolidação Django-first offline
**Data:** 2026-10-26. **Anterior:** CP310. **Escopo:** continuidade e arquitetura documental, sem conexão ou execução conectada.
**Decisão:** `DJANGO_FIRST_OFFLINE_ORM_MAPPING_AND_QUERY_BLUEPRINT_VERIFIED`.

## Evidências verificadas
- GitHub Actions [40281783742](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40281783742): SUCCESS, 146/146 testes PASS, Django check sem problemas, SHA `87af14c7c24be06c560704dc85419b49cd6ef4b1`. Cinco modelos Django `managed=False`, PK composta em ledger e compilação SQL offline.
- GitHub Actions [40282204788](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40282204788): SUCCESS, 150/150 testes PASS, Django check sem problemas, SHA `d8612a6172f6f90d794c6cf141d1456b61d4f720`. Quatro testes adicionais de planos de consulta ORM para pergunta corrente, recibo e transição condicional Q1.
- Evidência anterior: CI [40278790506](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40278790506), 142/142 PASS, adaptador SQL **experimental** com serialização consultiva offline.
- Documentos 343–346: G1 catálogo READ ONLY concluído; limites de ACL, concorrência, revogação e PostgreSQL conectado preservados. Docs.347–349: preferência Django-first, mapeamento e viabilidade Django 5.2.

## Arquitetura vigente
- Reutilizar tabelas canônicas `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version`, `investigation.question_command_receipt`; sem novas tabelas ou migrações.
- `applications/oes_web/evidence/models.py` define cinco modelos `managed=False`, com `CompositePrimaryKey` no recibo; restrições compostas, triggers e índices permanecem garantidos pelo PostgreSQL, não traduzidos integralmente pelo ORM.
- `question_orm_transaction_offline.py` define apenas **QuerySets não executados** e contrato proposto; não implementa transação ORM de Q0/Q1 nem cria writer. Os testes compilam SQL sem conexão.
- Preservar `QuestionCommand`, fingerprint, regras de escopo, idempotência, versionamento e recibo como contrato funcional. `question_sql_port_offline.py` permanece **evidência de laboratório, não dependência canônica para produção**.
- Django 5.2.x e Python 3.12; conexão `oes_synthetic_reader` é READ ONLY e não pode ser convertida em writer.

## Pendências inegociáveis
1. Definir e validar implementação transacional real com `transaction.atomic(using=...)`, limites de commit/rollback e tratamento de resultado incerto; sem autorização de uso conectado.
2. Verificar compatibilidade dos SQL/ORM com grants mínimos e comportamento real de PostgreSQL. Papel `oes_qprep_writer NOLOGIN`, sem UPDATE em `investigation.question`; não modificar privilégios automaticamente.
3. Isolamento multiusuário e qualquer revogação/transferência de responsabilidade continuam bloqueados até mecanismos homologados; RLS não habilitada e nenhum pesquisador vinculado.
4. G2 é **NO-GO**, exige autorização nominal distinta de G1. Nenhuma conexão writer, SQL DDL/DML, SET ROLE, credenciais, HTTP write, deploy ou E9 autorizados.
5. Antes de operacionalização, decidir como tratar relações compostas no Django 5.2, limites da PK composta e consistência transacional no PostgreSQL.

## Próxima atividade proporcional
Auditar offline a aderência dos QuerySets Django-first às invariantes Q0/Q1; planejar uma única implementação mínima transacional aproveitando Django nativo, sem promover código experimental a produção ou iniciar G2. Persistir em checkpoint novo somente quando houver avanço material, conforme protocolo equilibrado de continuidade.

**Invariantes:** Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; E9 NO-GO; A3 ausente e sem pesquisadores associados.
