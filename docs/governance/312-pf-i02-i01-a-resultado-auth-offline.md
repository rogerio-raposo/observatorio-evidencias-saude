# Documento 312 — PF-I02-I01-A: autenticação Django offline, resultado restrito

**Data:** 2026-10-25. **Autorização expressa:** `APPROVED — OES / PF-I02-I01-A / OFFLINE_DJANGO_AUTH_CODE_ONLY / no Neon or SQL writes / no real users / no deploy / E9 blocked`. Base: Doc. 311/CP298.

## Implementação
- `applications/oes_web/config/settings.py`: apps `django.contrib.auth`, `contenttypes`, `sessions`; SessionMiddleware, CsrfViewMiddleware, AuthenticationMiddleware e SecurityMiddleware; cookies básicos de sessão/CSRF; nenhum banco operacional adicionado, `DEBUG=True` e secret de desenvolvimento ainda presentes.
- `applications/oes_web/evidence/preparation_auth.py`: função de guarda `require_question_preparer` que exige `is_authenticated` e `has_perm('evidence.prepare_question')`. **Nenhuma permissão customizada persistente foi registrada, nenhum usuário/grupo criado e nenhuma rota Q0/Q1 adicionada.** Usuário Django com superuser e permissões implícitas exige política posterior específica; o helper isolado não comprova segregação de papéis em produção.
- `applications/oes_web/evidence/tests/test_pf_i02_auth_scaffold.py`: cenários offline de anônimo, autenticado sem permissão, simulação de usuário autorizado, ausência de rotas preparatórias/E9 e regressões.
- `.github/workflows/oes-pf-i02-auth-offline.yml`: checagem Django e suíte offline existente, sem uso de banco operacional.

## Evidência e correção de CI
Execução **40257199570**: completed/**failure**, uma falha em 80 testes por asserção equivocada `settings.DATABASES == {}` — Django normaliza para `default` dummy em tempo de execução. Código de aplicação permaneceu inalterado; o teste foi corrigido para exigir `django.db.backends.dummy`.
Execução **40257279644** no commit `f29ac1bd66d85203033f7d09767dc570c73b3e1c`: completed/**success**. A aprovação é estritamente de CI offline, não prova login real, sessão persistida, CSRF por navegação, permissões cadastradas ou segurança de implantação.

## Encerramento de fronteira
**I01-A `COMPLETED_OFFLINE_AUTH_SCAFFOLD_ONLY`**: estrutura de autenticação e negação de autorização demonstrada em testes sem banco. Não declarar `AUTH_READY`, `LOGIN_ENABLED` ou escrita Q0/Q1 disponível. Configuração DEBUG e secret de desenvolvimento permanecem, portanto nenhuma exposição pública.

## Continuidade
Próximo gate I01-B: revisão de migração mínima Q0-only e modelo de auditoria/versão; nenhuma DDL executada. I01-C exige autorização de papéis e credenciais separada; I01-D exige integração conectada. E9 NO-GO; Marco B aberto; A3 não realizada; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`, Fase 5 `NOT_STARTED`.
