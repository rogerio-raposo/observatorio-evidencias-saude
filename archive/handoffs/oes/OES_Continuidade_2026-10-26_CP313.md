# OES — CP313 | Identidade PostgreSQL mínima confirmada; Django-first preservado
**Data:** 2026-10-26. **Anterior:** CP312. **Base HEAD pré-checkpoint:** `2660f98e9444935b78450b394b458e0e9592a374`.
**Natureza:** continuidade operacional e evidência factual, sem promoção do backend de escrita.

## Resumo de decisão
**Django-first é decisão reafirmada.** O usuário descartou o uso de `oes_sandbox_owner` para escrita e determinou que os testes conectados utilizem o perfil correto. O ensaio excepcional anterior com owner **não deve ser executado**. Não retomar a proposta nem procurar atalhos SQL como substitutos da validação Django.
O obstáculo de provisionamento foi superado: `oes_qprep_login` foi **recriado manualmente no SQL Editor Neon, com senha descartável sob controle do usuário**, e auditado. Não pedir a senha ao usuário nem exibi-la em mensagens/logs/GitHub. Após os testes, o usuário rotacionará a senha manualmente no SQL Editor e confirmará o ato.

## Evidências de CI e código
- CP312, Docs 350–359 e histórico: modelos Django `managed=False` para cinco tabelas; PK composta ledger; QuerySets de consulta e inserções Q0; advisory locks; recipe Q0 rollback dormente, **sem executor operacional**.
- CI [40286940052](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40286940052): 170/170 PASS, commit `f6db52c37f05f61d08475e22597dd27dc43c2d0d`.
- CI [40287310584](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40287310584): 173/173 PASS, commit `0698a36e1141acee43bc3ffd921e33111e3645b0`.
- CI **[40287856367](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40287856367)**: **174/174 PASS**, commit `2660f98e9444935b78450b394b458e0e9592a374`, Django check sem problemas. Inspeções estáticas e testes offline não demonstram transação PostgreSQL real.
- `applications/oes_web/config/settings.py`: `DATABASES={}` por padrão, conexão `oes_synthetic_reader` opcional explicitamente READ ONLY; **não há alias writer**. `question_orm_q0_repository_dormant.py` rejeita instanciação. `question_orm_q0_connected_recipe_dormant.py` bloqueia ponto de entrada. Nenhum E9, HTTP write ou deploy.

## Neon — estado factual da identidade
Destino exclusivo: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`), database `oes_sandbox`.

1. Preflight G2-P0 e P2A READ ONLY: `oes_qprep_writer` NOLOGIN com schema USAGE e SELECT+INSERT em cinco tabelas; UPDATE somente de colunas `core.entity_version(version_status, valid_to)`; nenhuma permissão UPDATE em `investigation.question`; DELETE não concedido; RLS desabilitada.
2. A tentativa de criação pela API Neon de `oes_qprep_login` concedeu `neon_superuser` e atributos administrativos automaticamente; **foi excluída e ausência confirmada**. Nunca repetir criação pela API para este caso.
3. Segunda criação via `CREATE ROLE` SQL sem senha, vinculada por `GRANT oes_qprep_writer ... INHERIT TRUE, SET FALSE`: auditada, mas **excluída a pedido do usuário para recriar com senha na mesma instrução**.
4. Recriação manual no SQL Editor Neon pelo usuário, com senha descartável e SQL equivalente a:
   `CREATE ROLE oes_qprep_login WITH LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS PASSWORD '<senha-descartavel>';`
   `GRANT oes_qprep_writer TO oes_qprep_login WITH INHERIT TRUE, SET FALSE;`
   **Não copiar senha real para este arquivo.**
5. O usuário apresentou auditoria com `rolcanlogin=true`, `rolinherit=true`, demais flags administrativas `false`, `inherits_writer=true`, `can_set_writer=false`, `member_neon_superuser=false`. Uma verificação factual posterior de catálogo via Neon confirmou a existência do papel e SELECT+INSERT nas cinco tabelas, sem UPDATE/DELETE de tabela e sem `neon_superuser`. **A senha em si, a autenticação efetiva e o `session_user=current_user` de uma sessão Django ainda não foram testados.**

## Próxima atividade prioritária — sem retrabalho
**Teste mínimo de autenticação Django READ ONLY como `oes_qprep_login`**. Confirmar viabilidade da execução real do Django antes de acrescentar código ou novos gates. Não supor que o plugin Neon SQL execute Django nem que possua acesso à senha do usuário. Proteger credencial e decidir canal adequado sem solicitar que o usuário publique a senha no chat/GitHub. Configurar somente alias de teste efêmero, se autorizado, sem writer operacional permanente. Primeiro comando em sessão autenticada: `SELECT session_user, current_user, current_database()` e verificações de catálogo mínimas; nenhuma DML, DDL ou alteração de privilégio. O usuário autorizou anteriormente um ensaio conectado excepcional com **owner**, mas essa linha foi **revogada como orientação operacional**; para o novo perfil requer nova autorização específica de execução Q0 quando estiver tecnicamente viável.

## Disciplina de execução
- Evitar inflação de testes offline: 174/174 PASS é a evidência vigente, não readiness conectado.
- Evitar checkpoints e documentos a cada microatividade; Freshness Gate ao retomar e antes de commit; progresso periódico.
- CP313 substitui CP312 como ponteiro; não alterar gates sem autorização: G2-P2B NO-GO, Marco B OPEN, readiness NOT_READY, Fase 5 NOT_STARTED, E9 NO-GO. Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY.
- Acesso PostgreSQL administrativo apenas para preflights autorizados; nunca usar owner para write.
**Estado:** `CP313_ACTIVE / DJANGO_FIRST / RESTRICTED_LOGIN_VERIFIED_BY_CATALOG / DJANGO_AUTH_NOT_TESTED / G2_P2B_NO_GO / E9_NO_GO`.
