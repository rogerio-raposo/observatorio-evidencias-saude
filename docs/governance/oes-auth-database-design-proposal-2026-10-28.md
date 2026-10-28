# OES — proposta histórica de database de autenticação Django (substituída)

> **Decisão posterior (2026-10-28):** o responsável aprovou arquitetura de referência de **um database PostgreSQL por ambiente, com schemas separados e privilégios mínimos**. O segundo database `oes_auth` deixa de ser a recomendação e NÃO deve ser criado com base neste documento. Este texto é preservado somente como histórico da alternativa avaliada. Ver `docs/governance/oes-auth-single-database-architecture-2026-10-28.md`.

**Data:** 2026-10-28  
**Estado:** SUPERADA COMO RECOMENDAÇÃO ARQUITETURAL / NÃO APROVADA PARA EXECUÇÃO  
**Fundamento:** CP329, Documento 362, princípio de menor privilégio.  
**Alvo proposto:** projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, novo database `oes_auth`. O database científico `oes_sandbox` não será modificado.

## 1. Constatações verificadas

- Inventário Neon: somente `oes_sandbox` existe na branch.
- Catálogo PostgreSQL em `oes_sandbox`: `oes_django_migrator` está **NOLOGIN**, `oes_runtime` possui LOGIN; ambos sem CREATEDB, CREATEROLE, BYPASSRLS, CREATE no database ou no schema public e sem capacidade de assumir `oes_sandbox_owner`.
- A API de inventário não comprova concessões em um database que ainda não existe. Não se presume que privilégios no `oes_sandbox` se apliquem a `oes_auth`.
- Os modelos `auth`, `contenttypes`, `sessions` e `preparer_identity` foram exercitados em SQLite descartável. As migrations do Neon ainda não foram executadas.

## 2. Fronteiras de acesso propostas

| Função | Proposta | Permissões somente em oes_auth | Exclusões |
| --- | --- | --- | --- |
| Proprietário estrutural | Novo `oes_auth_owner`, NOLOGIN | Owner do database e schema de autenticação | Não membro de `oes_sandbox_owner`; sem LOGIN |
| Migrador | Novo `oes_auth_migrator`, LOGIN temporário/administrado | CONNECT, USAGE, CREATE e ownership de objetos que migrar no schema `django_auth` | Sem CREATEDB, CREATEROLE, superuser, BYPASSRLS, sem privilégios científicos |
| Runtime | Novo `oes_auth_runtime`, LOGIN | CONNECT e USAGE no schema; SELECT/INSERT/UPDATE/DELETE apenas nas tabelas Django estritamente requeridas | Sem CREATE em database/schema, DDL, ownership, acesso científico |
| Leitor científico | `oes_pg_a4_reader` existente | Somente `oes_sandbox`, sem mudança | Sem autenticação em `oes_auth` |

**Por que não reutilizar automaticamente?** `oes_django_migrator` está NOLOGIN e `oes_runtime` já existe com finalidade histórica; alterar os dois amplia sua superfície de acesso. Papéis dedicados isolam os domínios, embora acrescentem administração. Alternativa de reutilização deve ser analisada antes da aprovação; esta matriz não é decisão irrevogável.

## 2A. Revisão crítica de reutilização versus isolamento (2026-10-28)

**Recomendação técnica, ainda não autorização:** preferir papéis dedicados de autenticação por domínio. Reutilizar `oes_django_migrator` exigiria alterar sua condição atual NOLOGIN ou desenhar membership/SET ROLE; reutilizar `oes_runtime` ampliaria a superfície de acesso e complicaria revogações futuras no domínio científico. Não foi verificada nenhuma concessão ao futuro `oes_auth`, que ainda não existe.

| Critério | Reutilizar papéis existentes | Papéis dedicados de autenticação |
| --- | --- | --- |
| Mudanças nos papéis científicos | Podem ser necessárias | Não necessárias |
| Independência de revogação e rotação | Menor | Maior |
| Segregação entre migração e runtime | Exige reavaliação das identidades atuais | Definida por função |
| Custo de operação | Menos identidades | Duas credenciais LOGIN, uma função owner NOLOGIN |
| Acesso SQL a dados científicos | Exige conferir ACLs acumuladas | Excluir por padrão; auditar `PUBLIC` e heranças |

**Desenho mínimo recomendado:** `oes_auth_owner` NOLOGIN (titular de database/schema), `oes_auth_migrator` LOGIN sob habilitação controlada para migrations, e `oes_auth_runtime` LOGIN sem DDL; ambos sem CREATEDB/CREATEROLE/BYPASSRLS e sem memberships dos papéis científicos. O titular NOLOGIN deve ter ownership e um caminho de administração explicitamente aprovado; não presumir que o migrador possa assumir o owner. Tabelas/índices/sequências criados por migration devem ter ownership e privilégios pós-migração conferidos, inclusive `ALTER DEFAULT PRIVILEGES` sob o papel criador real quando necessário.

**Pontos de atenção:** papéis PostgreSQL são compartilhados na instância/branch; separar databases não elimina privilégios implícitos de `PUBLIC`, propriedade de objetos ou acesso por funções administrativas. A matriz só estará comprovada após preflight e postflight catalogais. O custo de um database adicional no mesmo projeto e os limites aplicáveis devem ser conferidos antes da criação. Nenhuma mudança operacional decorre desta revisão.

## 3. Sequência condicionada a autorizações específicas

1. Preflight READ ONLY: disponibilidade de criação de segundo database na branch/plano, roles, memberships, parâmetros de templates, `pg_database`, ACLs e situação de custo. Não se conclui disponibilidade com base apenas no inventário.
2. Aprovar nominalmente database, schema e papéis, incluindo tratamento de credenciais, ownership e possibilidade de restauração.
3. Criar somente `oes_auth`, com proprietário dedicado e sem alterações aos objetos/ACLs do `oes_sandbox`; verificar catálogo e ausência de efeitos colaterais.
4. Criar ou ajustar somente papéis de `oes_auth`, privilégios mínimos por função, revogação de privilégios PUBLIC desnecessários e política de `search_path`; conferir memberships e defaults.
5. Aplicar migrations nativas do Django e `preparer_identity` **somente** em `oes_auth`, com `django_migrations` e tabelas restritas ao schema acordado. Confirmar comportamento real de CREATE/ownership/default privileges, tabelas, sequências, índices, sessões, `django_content_type` e permissões antes do teste.
6. Validar autenticação sintética e identidade estável; mantendo a conexão científica separada, sem escrita HTTP e sem dados reais. Não executar ensaio conectado de escrita Q0 sem nova autorização.

## 4. Atenções de implementação

- Django usa nomes de tabela não qualificados nas migrations nativas: definir e verificar explicitamente o `search_path` do migrador e runtime para o schema `django_auth`. O simples uso de `DATABASE_ROUTERS` não substitui grants PostgreSQL.
- O runtime pode precisar de privilégios de sequências e tabelas nativas para criar sessões e gerenciar usuários; não conceder CREATE ou direitos de migração.
- Distinguir `oes_auth` de `oes_sandbox` em `DATABASES`; `default` reservado a autenticação. Rotas de dados científicos devem exigir alias/credencial próprios. Não confundir PostgreSQL role com identidade de ator `oes:actor:<uuid>`.
- A migration `preparer_identity` existente só foi validada em SQLite; validar sua DDL PostgreSQL antes da execução. Não transportar identidades efêmeras do SQLite.
- Proteções Django (`DEBUG`, `SECRET_KEY`, cookie seguro/HTTPS, CSRF, sessões, gestão de usuários) exigem configuração própria de implantação; não derivar prontidão de ambiente de teste.
- Escopo excluído: DDL/DML agora, migrations agora, secrets agora, ativação de workflows conectados, alterações de `oes_sandbox`, Q1, E9, serviços pagos, pesquisadores e dados reais.

## 5. Critério de GO para execução futura

Somente após aprovação expressa do proprietário para uma operação delimitada, com preflight e postflight READ ONLY, confirmação de isolamento `oes_auth`/`oes_sandbox`, papéis/ACL mínimos, rollback apropriado e custos cobertos pelo plano vigente. Caso contrário: **NO-GO / fail closed**.

**Estado geral inalterado:** Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.
