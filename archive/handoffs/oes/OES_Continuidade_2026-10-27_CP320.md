# OES — CP320 | PF-I04/P4-A10–A11 — autorização offline reforçada
Data: 2026-10-27. Anterior: CP319. HEAD-base: 0bfda5a5bbe751b67b335fed44e2dabe84e45cde.

## P4-A10 — Desenho de identidade e gestão
- Recomendação documental de papel técnico dedicado `oes_runtime` no PostgreSQL sintético, **não provisionado**. Uma identidade Django individual do preparador, autoria `actor_id=str(user.pk)`, e administração segregada de contas. Não reutilizar owner/migrador/leitor/identidades experimentais como runtime.
- Matriz candidata: CONNECT ao banco; USAGE nos schemas indispensáveis; SELECT em tabelas auth relevantes; DML mínimo em django_session; SELECT/INSERT nas cinco tabelas Q0; nenhum DDL, propriedade, acesso django_migrations ou grants genéricos. UPDATE restrito em `auth_user.last_login` pode ser necessário, e atualização de hash em `auth_user.password` exige decisão/ensaio próprios. Não converter a matriz em GRANT automaticamente.
- Permissão `evidence.prepare_question` já existe no catálogo sob contenttype evidence.oesquestion, ID 41, conforme CP319, mas não atribuída a usuários. Contas sintéticas devem ser is_active=true, is_staff=false, is_superuser=false. Configuração runtime, segredo protegido, conexão e HTTP permanecem indisponíveis.

## P4-A11 — Correção e regressão offline
- Arquivo `applications/oes_web/evidence/preparation_auth.py` reforçado: exige booleanos estritos is_authenticated=True, is_active=True, is_staff=False, is_superuser=False e método has_perm callable retornando True para `evidence.prepare_question`; nega atributos ausentes/inconsistentes e superusuário/staff, mesmo quando has_perm sinaliza autorização.
- Corrigidos os fixtures offline de seis módulos legados para refletir identidade não administrativa ativa; acrescentados testes negativos em `test_pf_i02_auth_scaffold.py` (inativo, staff, superusuário, atributos inválidos, permissão ausente/método não invocável).
- GitHub Actions final `40572406644`, commit `0bfda5a5bbe751b67b335fed44e2dabe84e45cde`: **130/130 testes offline PASS**. Execuções intermediárias FAIL durante adequação dos fixtures, posteriormente resolvidas; não representar PASS como integração real.
- Mudanças em oito arquivos de código/teste, nenhum modelo/rota HTTP/configuração de conexão ativada, nenhum Neon/SQL/segredo, papel/grant, conta Django, deploy ou dado real. O repositório Q0 permanece dormente.

## Gates e próximos passos
- CP319/P4-A9 permanece factual: permissão cadastrada, sem atribuição a usuário. P3a/P3b migrados tecnicamente, migrador NOLOGIN e sem CREATE, não repetir migrations.
- Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED. Pesquisadores não vinculados; nenhuma promoção científica.
- Ponto exato de retomada: **PF-I04/P4-A12 — preparar pacote delimitado para identidade técnica runtime (role, canal de credencial descartável, privilégios mínimos e testes negativos), sem execução de SQL ou provisionamento antes de autorização nominal específica**. Verificar se a escolha de criar login dedicado ou usar solução administrativa mais restrita precisa de novo gate. Cada Prossiga autoriza uma atividade e STOP. Freshness Gate antes de novos commits, checkpoint proporcional.
