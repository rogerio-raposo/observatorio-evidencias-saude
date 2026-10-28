# OES — arquitetura de referência: um database por ambiente, schemas segregados

**Data:** 2026-10-28  
**Decisão:** APROVADA quanto à direção arquitetural; **NÃO autoriza implementação SQL**.  
**Fundamento:** simplificação proporcional (CP329 / Doc362), preservação dos gates.

## Decisão

Adotar como referência um único database PostgreSQL por ambiente, com segregação lógica de autenticação Django e domínios científicos por schemas, roles e privilégios mínimos. O database experimental existente é `oes_sandbox`; produção futura requer ambiente e decisão próprios. A proposta anterior de novo database `oes_auth` está **SUPERADA**, preservada somente como histórico. Não criar `oes_auth` por interpretação da autorização arquitetural.

## Inventário READ ONLY confirmado em 2026-10-28

Em `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`:
- Schemas: `appraisal`, `artifact`, `core`, `evidence`, `investigation`, `oes_app`, `oes_raw_private`, `product`, `provenance`, `public`, `synthesis`. **`django_auth` não existe**.
- `oes_runtime`: USAGE em `public`, sem CREATE; sem USAGE/CREATE nos schemas científicos enumerados.
- `oes_django_migrator`: NOLOGIN; USAGE em `public` e `oes_app`, sem CREATE nos schemas enumerados.
- Esses fatos não autorizam concessões nem garantem adequação operacional de papéis.

## Desenho preferencial

- `django_auth` (nome proposto, não criado): `django_migrations`, `auth_*`, `django_content_type`, `django_session`, `preparer_identity_*` e sequências/índices associados.
- Domínios científicos: schemas atuais preservados, sem migração/reorganização motivada pela decisão de autenticação.
- Django ORM: `default` para autenticação quando autorizado; conexões científicas estritamente controladas, especialmente as de leitura; **sem habilitação de POST/write**.
- PostgreSQL: isolar ownership, USAGE, CREATE, DML e sequências por papel/schema; inspecionar privilégios PUBLIC, `search_path`, `ALTER DEFAULT PRIVILEGES` e role que efetivamente cria objetos nas migrations.
- Django: validar que `DATABASE_ROUTERS` e `search_path` não direcionam tabelas científicas/gerenciadas ao schema errado; garantir aplicação de migrations autorizadas exclusivamente no schema de autenticação. Não criar ForeignKey ORM entre databases distintos.
- Identidade do preparador: UUID persistente vinculado ao usuário Django; ponto de entrada autenticado estrito, serviço legado exclusivamente offline.
- Persistência da autenticação e sessões não está operacional: a validação atual usa SQLite descartável.

## Próximo preflight e autorização

1. Verificar READ ONLY `pg_database`, `pg_namespace`, ACLs, papéis/memberships e atuais objetos no schema proposto.
2. Especificar ownership mínimo e credenciais descartáveis de migração, avaliando papéis exclusivos versus reutilização sem ampliação de acesso científico.
3. Validar offline as migrations e configuração Django para o schema proposto.
4. **Só então**, solicitar autorização específica e limitada para criação de schema e permissões; migration PostgreSQL será um gate separado, sem dados reais, sem rotas de escrita HTTP.


## Plano operacional mínimo — pré-execução, sem autorização DDL

**Evidência offline disponível:** CI 40720648452, 180/180 testes PASS, compilação de DDL nativa Django para autenticação/sessões e identidade separadamente; não é ensaio de migrations PostgreSQL completas.

### Fronteira de objetos
- Database permanece `oes_sandbox`; somente schema novo `django_auth` é candidato a futura criação.
- Schema deve conter todas as tabelas Django gerenciadas de auth/contenttypes/sessions/preparer_identity, incluindo `django_migrations` e tabelas M2M de auth, índices, constraints e sequências.
- Nenhuma alteração aos schemas científicos atuais. Não criar objetos no `public`.
- SQL nativo do Django usa nomes não qualificados: `search_path=django_auth` deve ser fixado na conexão de migração e runtime. Confirmar que `current_schema()` e `current_schemas(false)` são os esperados antes da primeira migration. Migrations não criam schema automaticamente.

### Ownership e privilégios — desenho, não concessão
1. Selecionar um proprietário do schema e um executor de migrations com capacidade de criar e alterar seus próprios objetos. Se o migrador criar tabelas sob seu próprio papel, ownership dessas tabelas não é automaticamente o do proprietário do schema.
2. Runtime: CONNECT no database e USAGE em `django_auth`, DML mínimo nas tabelas e USAGE/SELECT nas sequências que exigirem; sem CREATE, ownership ou DDL.
3. Para grants em objetos futuros, vincular `ALTER DEFAULT PRIVILEGES FOR ROLE <criador_efetivo>` ao papel que executa DDL; grants de schema não equivalem a grants de tabela/sequência.
4. Verificar ACLs herdadas de `PUBLIC` e quaisquer memberships/SET ROLE antes de declarar isolamento. Proibir reutilização inadvertida de credenciais científicas.
5. Política de segredos: valores temporários em mecanismo aprovado; nunca em commit, logs ou prompts. Revogar/remover após ensaio autorizado.

### Preflight verificável e somente leitura
- `pg_namespace`: inexistência de `django_auth`; schema owners e ACLs existentes.
- `pg_roles`, `pg_auth_members`, `pg_database`: LOGIN/NOLOGIN, memberships, CONNECT/CREATE, privilégios e ownership.
- `pg_class`/ `pg_tables`: ausência de colisões de objetos Django e inventário atual.
- Configuração Django: apps habilitadas, roteamento estrito, alias de conexão e `search_path`; confirmar `DEBUG`/SECRET_KEY e contexto de teste.
- Critério de bloqueio: nome já ocupado, privilégios inesperados, role indeterminada, `search_path` ambíguo, alterações a objetos científicos, custos ou credenciais não aprovados.

### Sequência de gates separáveis
**Gate A (proposto, não aprovado):** criação isolada de schema, ownership e ACLs; preflight/postflight read only; nenhuma migration.  
**Gate B (posterior):** migrações Django exclusivamente no schema, mediante autorização independente e verificação de DDL, sequências, migrations, tabela de permissões e integridade.  
**Gate C (posterior):** teste de autenticação sintética; jamais habilitar automaticamente escrita Q0/HTTP.

**Rollback:** antes das migrations, reversão administrativa somente com inventário exato dos objetos criados e autorização. Após migrations, não presumir que DROP SCHEMA CASCADE seja rollback aceitável; exigir plano específico.

**Decisão arquitetural continua aprovada, mas nenhuma etapa de execução está autorizada.**

**Explicitamente fora do escopo:** criação de database/schema, SQL DDL/DML, grants, secrets, migrations Neon, workflow conectado, deploy, custos pagos, Q1, E9.

**Estado de governança:** Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.


## Execução autorizada do Gate A — 2026-10-28

**Aprovação específica recebida:** `APPROVED — OES / DJANGO_AUTH_SCHEMA_GATE_A / SINGLE_EMPTY_SCHEMA_CREATE / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / schema django_auth / owner oes_sandbox_owner / READ ONLY preflight and postflight / no migrations / no roles or grants / no DML / no HTTP writes / no paid services / fail closed`.

- Preflight SQL READ ONLY: `current_database()=oes_sandbox`, executor `oes_sandbox_owner`, `django_auth` inexistente, role proprietária presente, executor com CREATE no database, contagem de objetos nos schemas científicos selecionados = **99**.
- **Única mutação autorizada e realizada:** `CREATE SCHEMA django_auth AUTHORIZATION oes_sandbox_owner;`.
- Postflight SQL READ ONLY: schema `django_auth` existente, owner `oes_sandbox_owner`, ACL explícita `NULL` (privilégios padrão aplicáveis), **zero objetos**, `oes_runtime` e `oes_django_migrator` sem CREATE no novo schema, contagem dos mesmos objetos científicos = **99**.
- Não ocorreu migration, DML, concessão/revogação de privilégios, alteração de papel, segredo, deploy ou habilitação HTTP.
- **Gate A encerrado como PASS limitado à criação do schema vazio.** Gate B (migrations e privilégios) **NÃO AUTORIZADO**; demais gates inalterados.
- Nota: a contagem científica é uma verificação delimitada dos schemas `core`, `investigation`, `evidence`, `provenance` e `oes_app`, não um hash de todo o estado do banco.



## Gate B — matriz mínima de privilégios, preflight READ ONLY (2026-10-28)

**Situação:** desenho documental, sem autorização de grants, alterações de roles ou migrations.

Consulta do catálogo em `oes_sandbox` / `django_auth` após Gate A: schema pertence a `oes_sandbox_owner`, ACL explícita NULL, objetos 0. `oes_django_migrator` permanece NOLOGIN, sem USAGE/CREATE em `django_auth` e sem SET ROLE para `oes_sandbox_owner`; `oes_runtime` LOGIN, igualmente sem USAGE/CREATE em `django_auth`. Ambos dispõem de CONNECT no database. O owner possui USAGE/CREATE.

| Papel operacional | Direitos mínimos necessários | Direitos excluídos |
| --- | --- | --- |
| Executor de migration (identidade ainda a definir) | CONNECT em `oes_sandbox`; USAGE+CREATE em `django_auth`; ownership dos objetos que criar; conexão com `search_path=django_auth` | Sem CREATE no database, CREATEDB, CREATEROLE, superuser, BYPASSRLS, acesso ampliado aos schemas científicos |
| Runtime autenticador (identidade ainda a definir) | CONNECT; USAGE no schema; SELECT/INSERT/UPDATE/DELETE nas tabelas Django requeridas; USAGE de sequências para INSERT; eventual SELECT de sequências se justificado pelo SQL real | Sem CREATE em schema/database, ownership, TRUNCATE, REFERENCES genérico, DDL |
| Owner administrativo | Mantém ownership do schema e capacidade delimitada de administração | Não utilizar credencial owner no runtime |

**Ponto bloqueante:** `oes_django_migrator` é NOLOGIN e não dispõe de CREATE no schema; `oes_runtime` não possui sequer USAGE. O estado atual não sustenta migrations nem login persistente. Não utilizar automaticamente `oes_sandbox_owner` como credencial de migration Django, pois esse papel tem privilégios amplos. Definir expressamente mecanismo de conexão do migrador (role LOGIN dedicada ou login controlado com SET ROLE) e ownership das tabelas antes de qualquer GRANT.

**Detalhamento necessário antes de Gate B:** testar plano completo de migrations (incluindo tabelas M2M, `django_migrations`, índices, sequências, constraints e `post_migrate` de permissões), conferir roles/ACLs, determinar criador efetivo para `ALTER DEFAULT PRIVILEGES`, fixar `search_path=django_auth` para migrador e runtime e comprovar que objetos não são criados em `public`. Separar autorização de criação/alteração de privilégios da autorização de executar migrations.

**Proibido nesta etapa:** conceder privilégios, alterar LOGIN, criar novas roles, executar migrations ou conectar escrita HTTP/Q0. G2-P2B operacional NO-GO, E9 NO-GO e Fase 5 NOT_STARTED.

