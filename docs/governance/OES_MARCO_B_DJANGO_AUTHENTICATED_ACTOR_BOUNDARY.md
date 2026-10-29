# OES — Marco B — Fronteira de ator autenticado Django (decisão preparatória)

**Estado:** orientação arquitetural, sem autorização operacional. **Base:** CP342; [ensaio 40903228787](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40903228787) e [verificação READ ONLY 40905200153](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40905200153).

## Distinções obrigatórias

1. **Cadastro:** existe um usuário sintético em `django_auth.auth_user`, com senha inutilizável, `PreparerIdentity` vinculada e permissão direta `evidence.prepare_question`.
2. **Autenticação:** nenhum login humano ou de serviço foi demonstrado. A senha inutilizável impede login normal por senha; o simples cadastro não fornece sessão autenticada.
3. **Autorização:** `require_question_preparer(user)` exige `is_authenticated=True`, ativo, não staff, não superuser e permissão exata. A validação anterior exercitou o contrato com objeto em memória, não uma sessão Django real.
4. **Autoria científica:** `actor_uuid` identifica um ator sintético experimental; não representa pesquisador real, sua aprovação, consentimento ou atribuição científica.

## Alternativas e decisão proporcional

- **A — Teste de integração offline com Django test client e `force_login` em banco de teste isolado:** recomendado como próxima prova **exclusivamente sintética**, se precisar provar middleware, resolução de permissões e sessão. `force_login` é facilitador de testes, não mecanismo de autenticação operacional. Não consultar nem alterar o Neon.
- **B — Credencial de login operacional para o preparador sintético:** não recomendada agora; adiciona superfície de ataque e contraria o objetivo de senha inutilizável.
- **C — Ator autenticado por federação/SSO de pesquisadores reais:** decisão futura de identidade institucional e governança, condicionada à participação científica. Não criar usuário real prematuramente.
- **D — Injeção de identidade confiável por backend interno:** exigir validação de origem, atestação, trilha de auditoria, prevenção de impersonação e novo gate; não permitir seleção livre de username ou UUID por requisição.

## Próxima atividade proposta

Criar, em teste offline isolado, matriz negativa/positiva de autenticação versus autorização Django (usuário ativo com permissão, anônimo, sem permissão, staff, superuser, inativo), exercitando sessão simulada pelo test client com banco exclusivamente de teste. Antes de executar qualquer teste com gravação no Neon, integração HTTP externa, habilitação da escrita Q0 ou mudança de autenticação, exigir gate nominal distinto.

**Gates invariantes:** Marco B OPEN; Django Q0 HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED. Nenhum deploy, DDL/GRANT ou credencial novo autorizado.
