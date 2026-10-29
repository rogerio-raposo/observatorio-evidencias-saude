# OES — Decisão de integração: identidade sintética e tentativa única Q0

Data: 2026-10-29. Base: CP343; 287/287 testes offline PASS (Actions 40952187463). Autorização do responsável para **um único ensaio** de cinco INSERTs ORM sintéticos na transação Django com rollback obrigatório e reconciliação independente; ainda não consumida.

## D1 — Proveniência do ator

Para este ensaio CI (não sessão de login), empregar uma **identidade sintética de serviço vinculada por leitura**, não um usuário Django falsamente autenticado.

1. Sob alias Django `default`, confirmar servidor: role `oes_auth_trial_login`, database `oes_sandbox`, schema `django_auth`, conexão de leitura. Fixar username reservado `oes_synth_preparer_marco_b_trial_20261029` no **código revisado**, sem input de ator, username, SQL ou question_id no workflow.
2. Ler exatamente uma linha `auth_user` desse username e seu `preparer_identity_prepareridentity` por chave de usuário. Exigir usuário ativo, não staff, não superuser e senha inutilizável (sem simular login).
3. Ler permissões **diretas** `auth_user_user_permissions` + `auth_permission` + `django_content_type` e associações `auth_user_groups`; exigir exatamente `evidence.prepare_question`, nenhuma associação a grupo ou permissão extra.
4. Exigir um UUID4 canônico em `PreparerIdentity.actor_uuid` e construir `oes:actor:<uuid>` exclusivamente da linha validada. Comparar com `trial.actor_id` gerado internamente; não aceitar ator externo.
5. Usar essa evidência só como identidade sintética técnica em teste de infraestrutura. **Não** chamar essa consulta de login/autenticação real ou utilizá-la em endpoint HTTP.

A revisão `review_persisted_actor_binding(user,...)` existente cobre usuários já autenticados, não resolve este caso de CI. Mantê-la sem bypass ou `is_authenticated=True` artificial.

## D2 — Tentativa única sem escrita científica adicional

`concurrency` serializa jobs, mas não consome a autorização; `workflow_dispatch` pode ser repetido. Um UUID novo por execução também não evita um segundo ensaio. **Não declarar exatamente-once baseado nesses mecanismos.**

Opções avaliadas:
- GitHub environment com aprovação manual: controla início, mas aprovações futuras podem ocorrer. Necessita uma fonte externa de estado consumido.
- Artefato Actions e busca histórica: úteis para auditoria, não garantem exclusão mútua/consumo atômico sob corrida.
- Entrada append-only em sistema de controle de autorização com operação condicional de consumo (compare-and-set) **antes de credenciais e DML**, imutabilidade/auditoria e leitura de estado em todo dispatch: oferece a propriedade pretendida, mas exige capacidade e permissões externas específicas ainda não aprovadas.

**Decisão:** não introduzir uma nova base, tabelas, papel de banco, serviço pago ou workflow escritor para simular exclusividade. O gate de tentativa única permanece **NO-GO** até definição e validação de uma fonte de consumo atômico, verificável antes de qualquer conexão escritora. A autorização do responsável continua válida, mas não equivale a prova de consumo único. Qualquer mecanismo escolhido deverá distinguir `NOT_USED`, `CONSUMED` e `UNCERTAIN` (os dois últimos bloqueiam), ser idempotente sob repetição de evento e falhar fechado em indisponibilidade.

## D3 — Próximo incremento mínimo

1. Implementar e testar **somente leitura** uma função de verificação do vínculo sintético com contrato explícito, isolada do Django `require_question_preparer`; nenhum resultado pode habilitar o runner.
2. Selecionar mecanismo externo concreto de consumo atômico com o menor privilégio possível e documentar seu contrato. Não usar GitHub Actions concurrency como substituto.
3. Somente depois congelar SHA, testar workflow manual e executar o ensaio já autorizado sem retry.

### Fronteiras inalteradas

Workflow `.github/workflows/oes-django-q0-single-rollback-hold.yml` mantém job conectado `if: false`, sem secrets, nenhuma escrita Neon. `run_connected` continua HOLD, Q0 geral HARD HOLD, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED. CP343 é o checkpoint vigente.
