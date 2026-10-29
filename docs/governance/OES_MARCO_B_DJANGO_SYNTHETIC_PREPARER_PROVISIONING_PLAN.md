# OES — Marco B — Plano controlado de provisionamento sintético Django

**Estado:** desenho preparatório, NÃO EXECUTÁVEL; executor Q0 em HARD HOLD; E9 NO-GO.
**Destino único:** Neon project `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, schema `django_auth`.
**Identidade administrativa candidata:** `oes_auth_migrator` (dona das tabelas e sequências verificadas). Não usar `oes_auth_trial_login` para escritas; não usar `oes_sandbox_owner`.

## Condições prévias de autorização

Nenhuma execução deste plano está autorizada por sua existência. Exigir gate nominal separado para DML, transação, credencial administrativa temporária e execução única. Não criar workflow de escrita, não cadastrar secrets, não modificar roles ou GRANT sem gate correspondente.

1. Confirmar por sessão nova a conexão autenticada como `oes_auth_migrator`, `current_database() = oes_sandbox`, endpoint direto da branch e `current_schema() = django_auth`; impor `search_path=django_auth,public`.
2. Confirmar propriedades e privilégios de tabelas **e sequências**, existência das FK/UNIQUE e a semântica dos identificadores automáticos; não inferir INSERT operacional de propriedade isoladamente.
3. Confirmar `django_auth.auth_user` vazio e ausência do identificador sintético reservado, das associações correspondentes e do codename `prepare_question` para o content type escolhido. Qualquer divergência implica HOLD; nunca reaproveitar registro preexistente automaticamente.
4. Verificar `evidence.OesQuestion` como metadado de permissão, com content type `(app_label='evidence', model='oesquestion')`; usar `evidence.prepare_question` somente depois de verificar sua resolução Django.
5. Confirmar parâmetros operacionais sintéticos imutáveis, gerados antes da execução, registrados fora dos logs sensíveis: username técnico reservado, actor_uuid e chave de reconciliação. Não utilizar usuários reais, dados pessoais nem senha funcional.

## Desenho da unidade transacional única

No momento de gate futuro, executar exatamente uma unidade atômica administrativa, com identidade e `search_path` previamente verificados:

- Sob transação explícita, adquirir lock transacional dedicado e executar novamente as pré-condições, impedindo corrida ou repetição.
- Se ausente e permitido pelo gate, criar somente o content type `evidence/oesquestion` e a permissão `prepare_question` de nome descritivo; nenhum outro conteúdo/migração automática.
- Criar exatamente um usuário sintético `is_active=true`, `is_staff=false`, `is_superuser=false`, senha inutilizável pelo mecanismo oficial Django; sem grupos ou permissões extras.
- Criar exatamente um `PreparerIdentity` vinculado ao usuário e um único vínculo `auth_user_user_permissions` à permissão aprovada.
- Conferir invariantes, unicidade, FKs e ausência de privilégios adicionais na mesma transação. Commit apenas se todas as verificações forem positivas; qualquer falha antes do commit exige rollback integral.

## Resultado indeterminado e reconciliação

Não repetir INSERT automaticamente diante de timeout ou perda de conexão durante o commit. Consultar, com papel somente leitura `oes_auth_trial_login`, o estado final usando identificador reservado, actor_uuid e associação exata de permissão. Classificar exclusivamente como:

- **COMMITTED_VERIFIED:** todos os registros e vínculos esperados estão presentes e consistentes.
- **NOT_COMMITTED_VERIFIED:** ausência confirmada mediante evidência suficiente e revisão humana antes de eventual nova tentativa.
- **UNCERTAIN_OR_DIVERGENT:** qualquer estado parcial, duplicidade, erro ou insuficiência de evidência; HOLD, sem nova tentativa.

Evitar imprimir nomes de usuários, e-mails, tokens, senhas, hashes ou UUIDs em logs públicos. Reportar apenas PASS/HOLD e categorias de reconciliação.

## Encerramento e segurança

Após validação independente, remover a credencial administrativa temporária do GitHub Secrets quando utilizada; preservar somente os secrets limitados de leitura conforme política previamente aprovada. Não alterar o conjunto de permissões do papel `oes_auth_trial_login`, não habilitar executor Q0, HTTP write, E9, deploy ou serviços pagos.

**Pendente antes da autorização operacional:** plano técnico executável, teste offline das operações, confirmação de formato/geração de IDs, demonstração de conexão administrativa e gate nominal de DML.
