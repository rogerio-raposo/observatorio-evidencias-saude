# OES — CP318 | Continuidade PF-I04/P4-A3–A6
Data: 2026-10-27. Anterior: CP317. Base main: 8528163066d5201614d91a75b8cddc88adba4da6.
Natureza: consolidação documental; nenhuma autorização operacional.

## A3 — Suficiência
Stack Django Auth, sessões, permissões, serviço QuestionCommand e cinco modelos ORM Q0 são reaproveitáveis. Runtime não configurado, escrita HTTP e commit Q0 bloqueados. Matriz local de privilégios é experimental; não usar credenciais owner/migrador/reader.

## A4 — Preflight autorizado READ ONLY
No Neon, projeto visível oes-sandbox (weathered-boat-65779510), branch sintética oes-pg-a3-synthetic-20261024 (br-gentle-hall-b6jaxehf), banco oes_sandbox, PostgreSQL 18.6. Branch production não acessada. Inspeção exclusivamente por SELECT catalogal, sem dados de usuários ou científicos.
Schema oes_app pertence a oes_sandbox_owner; 9 tabelas e 8 sequências administrativas Django pertencem a oes_django_migrator, NOLOGIN, sem CREATE no schema.
oes_qprep_login (LOGIN) e oes_qprep_writer (NOLOGIN) possuem SELECT e INSERT, mas não UPDATE/DELETE, em core.entity, core.entity_version, investigation.question, investigation.question_version e investigation.question_command_receipt. Nenhum tem direitos nas tabelas ou sequências oes_app. oes_pg_a4_reader não possui acesso oes_app; oes_runtime não foi encontrado entre os papéis candidatos examinados. Executor do SELECT: oes_sandbox_owner, search_path observado "$user", public; não inferir configuração futura de runtime.

## A5 — Candidato de identidade
Recomendado papel técnico dedicado oes_runtime, ainda inexistente/não aprovado, com CONNECT no banco, USAGE em schemas estritamente necessários, SELECT na autenticação Django, operações de sessão indispensáveis, Q0 SELECT/INSERT pontuais e nenhuma DDL/propriedade/superuser/admin. Administração de usuários e concessão de permissão funcional devem ser separadas do runtime. UPDATE limitado a auth_user.last_login e eventual atualização de hash de senha dependem de ensaio e contrato; não presumir grants finais. O papel homônimo no script local não foi criado no Neon.

## A6 — Permissão funcional
O serviço exige evidence.prepare_question, porém não foi localizada definição Meta.permissions ou migration da aplicação evidence no repositório. Testes atuais usam mocks. A existência dessa permissão entre as linhas de auth_permission em oes_app NÃO foi comprovada; tampouco sua ausência foi comprovada por SELECT. Não criar tabela artificial ou atribuir permissões sem gate. Confirmar exclusivamente o registro e contenttype por inspeção autorizada e, se ausente, especificar provisionamento idempotente separado.

## Gates e limites
P4 NOT_AUTHORIZED, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, Marco B OPEN, Fase 5 NOT_STARTED; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY. P3a/P3b preservados; migração e migrador não devem ser repetidos/reativados. Sem pesquisadores ligados ao piloto.
Nenhuma alteração de Neon, roles, grants, contas, segredos, código ou workflows; SQL executado em A4 foi apenas SELECT catalogal autorizado.

## Ponto exato de retomada
PF-I04/P4-A7 — delimitar novo gate restrito para verificar por SELECT o código evidence.prepare_question e seu contenttype em oes_app.auth_permission e oes_app.django_content_type, SEM acessar auth_user, sessões, credenciais ou dados científicos. Após aprovação específica, executar leitura mínima e decidir proposta administrativa idempotente; não efetuar DML. Cada Prossiga autoriza só uma atividade, seguida de STOP; Freshness Gate antes de commit.
