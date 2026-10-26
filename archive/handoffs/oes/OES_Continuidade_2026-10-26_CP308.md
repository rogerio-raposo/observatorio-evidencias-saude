# OES — CP308 | P2-A9 migração sintética confirmada
**Data:** 2026-10-26. **Anterior:** CP307. **Documento de evidência:** 338.

## Estado comprovado
Autorização nominal `PF-I02-P2-A9 / SINGLE_SYNTHETIC_QUESTION_RESPONSIBILITY_SCHEMA_MIGRATION`. Na branch Neon `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, preflight READ ONLY atestou tabela `investigation.question`, owner e ausência de coluna/constraint. Transação única alterou somente esta tabela com `responsible_actor_id text NULL` e CHECK `ck_pf_i02_question_responsible_actor` para NULL ou texto aparado entre 1 e 128 caracteres. Postflight READ ONLY confirmou coluna e constraint exatas. Nenhum DML, backfill, GRANT, papel, SET ROLE, credencial, Django, HTTP, E9 ou cleanup. Não repetir migração; não reverter sem aprovação específica.
Política sintética experimental de responsável único aprovada em Doc.336; Doc.337 projeto DDL; Doc.338 execução. A coluna não garante escopo de acesso, revogação concorrente, nem segregação no banco; RLS ausente. Papel writer `oes_qprep_writer NOLOGIN` preservado, sem UPDATE em `investigation.question`. Adaptador P2 SQL offline parcial; CI 40271463247 anterior 109/109 PASS, sem validação conectada.

## Próxima atividade
Freshness Gate; retomar implementação **offline** da porta P2, primeiro com avaliação do predicado de autorização para `can_access_question` e `current_question`, e testes com cursor injetado, sem rede, SQL conectado, alterações de grants ou HTTP. Delimitar locks necessários para evitar revogação concorrente, sem prometer isolamento multiusuário. Persistência de futuras alterações e gates conforme protocolo de aprovação.

## Invariantes
Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; A3 ausente e sem pesquisadores vinculados; E9 NO-GO, sem serviços pagos.
