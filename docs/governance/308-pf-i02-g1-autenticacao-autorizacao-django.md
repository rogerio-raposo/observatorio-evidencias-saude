# Documento 308 — PF-I02-G1: desenho mínimo de autenticação e autorização Django

**Data:** 2026-10-25. **Classificação:** contrato técnico preparatório / decisão proposta. **Sem execução operacional, sem código, contas, segredos, SQL, grants, deploy ou habilitação de workflows.** Bases: Docs. 306–307, CP297.

## Constatação
Django hoje contém apenas `django.contrib.staticfiles` e `evidence`; `CommonMiddleware` somente, `DATABASES={}`, secret estático de desenvolvimento e `DEBUG=True`. Portanto **não há autenticação Django, sessão autenticada, grupos, permissões ou proteção CSRF para formulários**; adicionar `@login_required` isoladamente não seria suficiente. PG-A4 é leitor sintético opcional; não é banco de identidade nem caminho de escrita.

## Desenho recomendado (sem habilitação)
1. **Identidade humana:** usar `django.contrib.auth` e `django.contrib.sessions`, middleware Authentication/Session, `django.contrib.contenttypes`, migrações sob banco operacional definido; não inventar autenticação baseada em cabeçalhos ou senha fixa. Login de pessoa (preparador) não é papel SQL técnico.
2. **Papéis mínimos:** `oes_question_preparer` com capacidade explícita `prepare_question`; `oes_document_reader` apenas consulta autorizada. `is_staff`, `is_superuser` ou mera autenticação não equivalem a permissão para escrever Q0/Q1. Governança de quem concede e revoga deve ser formalizada; não criar usuários ou grupos reais agora.
3. **Negação por padrão:** rota Q0/Q1 inexistente até implementação aprovada; quando implementada, sessão autenticada + permissão + política de acesso a registros; negação sanitizada 403/404; nenhuma operação E9 ou de criação Investigation.
4. **Formulários e sessão:** HTTPS quando houver implantação, cookies Secure/HttpOnly/SameSite, CSRF middleware e token, timeout/expiração, logout efetivo, proteção contra força bruta e logs de eventos sem dados sensíveis. Configuração local de desenvolvimento ≠ operacional.
5. **Separação de bancos:** banco de identidade/sessões Django e esquema OES Question devem ter ownership/credenciais explícitos e privilégios mínimos. Preferir uma arquitetura PostgreSQL coerente **após** G2/G3; não criar banco separado nem duas autenticações sem justificativa concreta. Não usar credenciais Neon E6, PG-A4 ou proprietário de schema para HTTP.
6. **Auditoria confiável:** gravar identificador estável do ator autenticado, tipo de ação, versão anterior/nova, horário, justificativa e resultado em transação; validar acesso no serviço e na fronteira DB, nunca confiar em `created_by` recebido pelo navegador.

## Sequenciamento mínimo e testes requeridos
- G1a (documental): aprovar identidade, papéis, política de sessão, ambiente inicial e regras de concessão/revogação.
- G2: avaliar correspondência entre question/version legado e ciclo Q0→Q1; definir migrações e atomicidade sem executar.
- G3: definir usuário de escrita e infraestrutura de segredos, modelo de host, backup e recuperação; checar se auth e Question coexistem no banco autorizado sem duplicar stack.
- G4: só com autorização explícita, configurar autenticação real, rotas protegidas e persistência Q0→Q1, com cenários de usuário anônimo, usuário sem permissão, preparador, CSRF ausente/inválido, versão concorrente, rollback, leitura sem permissão e tentativa direta de E9. Regressões PF-I01.

## Fronteira
Este desenho **não torna seguro** o Django atual para acesso público e não prova funcionamento de login, isolamento de dados ou persistência. Sem pesquisadores vinculados; autenticador humano não é revisor A3. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Marco B aberto; E9 NO-GO; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.

## Próxima decisão proporcional
Validar desenho G1 como direção e avançar **G2: análise de adaptação mínima do schema Q0→Q1**, sem alterações em tabelas. Somente então elaborar autorização delimitada para implantação do primeiro fluxo persistente. Não gerar novo protótipo redundante.
