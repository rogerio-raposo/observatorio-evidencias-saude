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



## Gate B — escolha recomendada para identidade migradora (2026-10-28)

**Status: proposta somente; SEM AUTORIZAÇÃO para ALTER ROLE, GRANT, CREATE ROLE ou migrations.**

Novo preflight READ ONLY confirmou: `oes_django_migrator` = NOLOGIN/NOINHERIT, sem validade definida, sem SET ROLE para `oes_sandbox_owner`, com USAGE em `oes_app` e sem CREATE em `django_auth`; `oes_runtime` = LOGIN/NOINHERIT, sem USAGE em `oes_app` e sem CREATE em `django_auth`.

**Recomendação de menor mudança:** manter `oes_django_migrator` como papel técnico NOLOGIN histórico, sem habilitar LOGIN globalmente. Se a reutilização for aprovada, utilizar **login temporário dedicado**, com `NOINHERIT` e permissão `SET ROLE oes_django_migrator` estritamente controlada; porém, como `oes_django_migrator` já tem USAGE em `oes_app`, isso NÃO oferece isolamento perfeito de domínios. Para isolamento mais estrito, preferir criar um papel **exclusivo de migração da autenticação**, `oes_auth_migrator`, com LOGIN temporário e USAGE/CREATE apenas em `django_auth`. Nesta etapa, esta última é a opção preferencial para posterior autorização, mas não exige um segundo database nem um owner adicional.

A atribuição de CREATE sobre `django_auth` e os ownerships de tabelas a `oes_auth_migrator` exigem aprovação separada. O schema permanece com owner `oes_sandbox_owner`; tabelas criadas pelo migrador pertencerão ao executor efetivo. O runtime poderá receber grants explícitos sobre tabelas e sequências depois do Gate de migration, sob a identidade proprietária dos objetos.

**Alternativa rejeitada por ora:** habilitar LOGIN em `oes_django_migrator` ou executar migrations diretamente com `oes_sandbox_owner` (superfície ampliada ou privilégios administrativos excessivos).

**Atenção:** `oes_auth_migrator` é proposta de nome, não role criada; `oes_runtime` ainda pode ser candidato a runtime Django após inspeção de permissões acumuladas. Nenhuma dessas escolhas implica ativação de autenticação real ou HTTP Q0.



## Gate B — proposta delimitada de provisionamento do migrador (2026-10-28)

**Preflight READ ONLY:** `oes_auth_migrator` inexistente; `django_auth` existente, owner `oes_sandbox_owner`, 0 objetos; executor `oes_sandbox_owner` com CREATEROLE. **Nenhuma alteração SQL autorizada nesta atividade.**

**Operação futura sujeita a aprovação separada:** criar exclusivamente `oes_auth_migrator` como LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS, com senha descartável definida privadamente pelo responsável no editor SQL do Neon e validade curta explicitamente aprovada; conceder somente USAGE, CREATE no schema `django_auth` do database `oes_sandbox`. Não reutilizar senha histórica; nunca registrá-la em GitHub, chat ou logs. Executar por sessão administrativa aprovada, com preflight e postflight catalogais, verificando memberships, ACL, ownership e inexistência de privilégios sobre schemas científicos. Não incluir migrations neste gate.

**Sequência sugerida em autorização futura:** (1) preflight de invariantes; (2) criação do login com senha descartável pelo responsável; (3) GRANT USAGE, CREATE ON SCHEMA django_auth TO oes_auth_migrator; (4) postflight; (5) revogação/expiração da credencial após utilização aprovada. Uma ação SQL de CREATE ROLE é global ao cluster PostgreSQL, portanto nomes e privilégios devem ser cuidadosamente delimitados. Não incluir grants em `public`, `oes_app`, `core`, `investigation` etc. Não habilitar HTTP nem Q0.

**Pendências:** especificar prazo real de validade da senha no instante da execução, verificar eventuais privilégios padrão de PUBLIC e planejar posterior ownership/grants de tabelas e sequências criadas pelas migrations. O papel não precisa de CREATEDB nem CREATE no database para criar objetos em um schema existente.


## Gate B1 — provisionamento autorizado e verificado (2026-10-28)

Autorização específica: `APPROVED — OES / DJANGO_AUTH_GATE_B1 / SINGLE_EPHEMERAL_MIGRATOR_ROLE_AND_SCHEMA_GRANT`, com escopo restrito a `oes_sandbox`, schema `django_auth`, sem migrations, DML, HTTP ou privilégios científicos.

O responsável criou `oes_auth_migrator` no SQL Editor do Neon com senha privada descartável. Preflight READ ONLY confirmou: LOGIN=true, INHERIT=false, SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS=false, validade `2026-10-31 23:59:59+00`, zero associações, USAGE/CREATE no schema inicialmente false.

Única mutação executada pelo assistente: `GRANT USAGE, CREATE ON SCHEMA django_auth TO oes_auth_migrator;`.

Postflight READ ONLY: USAGE=true, CREATE=true em `django_auth`; zero associações; atributos e validade preservados; CREATE=false nos schemas científicos `core`, `investigation` e `oes_app`; schema `django_auth` permanece com **0 objetos**. Nenhuma migration ou dado novo. **Gate B1 PASS.** Credencial deverá ser eliminada/expirada conforme política; não registrada em repositório ou conversa. **Gate B de migrations ainda NÃO AUTORIZADO** e demais gates NO-GO preservados.


## Gate B2 — revisão de prontidão pré-migration (2026-10-28)

**Estado: HOLD — autorização NÃO solicitada, nenhuma migration autorizada.**

Preflight conectado READ ONLY: schema `django_auth` permanece vazio (0 objetos); `oes_auth_migrator` LOGIN=true, CREATE em `django_auth`=true. A configuração `settings_auth_pg_design.py` é deliberadamente **dummy**, não pode ser usada para executar migrations. A DDL offline testada abrange `CREATE TABLE` dos modelos principais, **não** prova todas as operações do grafo de migrations nativas, tabelas M2M, `post_migrate`, ordenação de dependências e permissões.

### Condições mínimas de liberação de B2

1. Implementar configuração **separada e opt-in**, desabilitada por padrão, para migration Django no PostgreSQL `oes_sandbox`, usando unicamente `oes_auth_migrator` e senha efêmera em segredo de execução aprovado; nunca `oes_sandbox_owner` ou `oes_runtime`.
2. Travar conexão ao endpoint e branch autorizados, SSL obrigatório, `search_path=django_auth` **sem `public`**, e confirmar por SQL READ ONLY `current_database()`, `current_user`, `current_schema()`, `current_schemas(false)`, `SHOW search_path` antes do DDL. Uma configuração de design com `dummy` não substitui essa validação.
3. Conferir offline o plano **completo** de migrations em Django 5.2 para `auth`, `contenttypes`, `sessions`, `preparer_identity`, incluindo `django_migrations`, M2M, sequências, índices, `post_migrate` e `django_content_type`; não inferir cobertura completa de compilação `create_model`.
4. Verificar que `evidence` é somente modelo científico não gerenciado e que nenhuma migration dele nem tabela científica será criada/modificada; confirmar os efeitos de `post_migrate` sobre ContentTypes de modelos não gerenciados.
5. Revisar `DATABASE_ROUTERS` e privilégios efetivos; `oes_auth_migrator` deve dispor apenas de USAGE/CREATE em `django_auth`; definir grants posteriores ao runtime **em gate independente**, incluindo sequências e DEFAULT PRIVILEGES do criador real.
6. Preflight de inventário e ACL com critério de interrupção caso haja objetos inesperados; preparar postflight com lista de objetos criados, owner/ACL, `django_migrations`, e contagem/integridade de objetos científicos antes/depois.
7. Restringir execução futura a uma única operação de migration sintética aprovada, sem usuários reais, sem POST Q0, sem deploy, sem serviços pagos. Após uso, desativar credencial efêmera conforme controle aprovado, sem sua divulgação.

**Decisão nesta atividade:** manter Gate B2 em HOLD até cobertura offline suficiente e configuração de execução segura. Não efetuar DDL/GRANT/migration como consequência deste documento.


## B2-P0 — preflight conectado sob migrador, READ ONLY (2026-10-28)

**Autorização:** `APPROVED — OES / DJANGO_AUTH_GATE_B2_P0 / SINGLE_CONNECTED_READ_ONLY_MIGRATOR_PREFLIGHT`, estritamente leitura, sem migrations ou mutações.

Consulta realizada uma vez via Neon, selecionando `role_name=oes_auth_migrator`, database `oes_sandbox`, branch `br-gentle-hall-b6jaxehf`. Resultado: `session_user=current_user=oes_auth_migrator`, `current_database()=oes_sandbox`, USAGE/CREATE em `django_auth`=true, CREATE em `public`=false, objetos em `django_auth`=0. **search_path da sessão conectada = `"$user", public`; current_schema() = `public`; current_schemas(false) = {public}.**

**Conclusão restrita:** identidade e ACL adequadas ao acesso ao schema, mas o `search_path` dessa sessão Neon não seleciona `django_auth`. **B2 permanece HOLD**; não houve DDL, DML, migration, ALTER ROLE ou GRANT. A consulta não testou a conexão Django opt-in, cujo `OPTIONS.options=-c search_path=django_auth` precisa ser demonstrado separadamente em teste expressamente autorizado; não confundir configuração de sessão da API com a configuração futura do Django.

**Próxima ação:** elaborar prova de conexão Django de leitura exclusivamente com `search_path` explícito, conferindo `current_schema()`, `current_schemas(false)` e `SHOW search_path` antes de qualquer migration. Falha implica NO-GO.


## Gate B2-P1 — preflight Django conectado PASS (2026-10-28)

Aprovação explícita: `APPROVED — OES / DJANGO_AUTH_GATE_B2_P1 / SINGLE_DJANGO_CONNECTED_READ_ONLY_PREFLIGHT`. Workflow manual `oes-auth-b2-p1-readonly-manual.yml`, [run 40727429944](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40727429944), tentativa 1, SHA `5d21be77b6047dec87a64ad3014fc138378a129c`, conclusão **SUCCESS**. Log: `PASS_READ_ONLY_DJANGO_AUTH_SCHEMA`.

O script Django verificou em uma única consulta SELECT que `current_database=oes_sandbox`, `session_user=current_user=oes_auth_migrator`, `search_path=current_schema=django_auth`, `current_schemas(false)={django_auth}`, USAGE/CREATE=true e objetos no schema=0. Nenhum DDL/DML/migration, grant ou alteração de papel.

Workflow desabilitado novamente após consumo autorizado (commit `e44c54e9c7bde5d61589e19860da1498fed4fd3e`). **B2-P1 PASS; Gate B2 de migrations permanece HOLD e não autorizado.** A existência do segredo temporário no GitHub não implica sua remoção; requer confirmação/limpeza explícita pelo responsável.


## Gate B2-M1 — plano de execução das migrations (proposta, NÃO autorizado)

**Situação da credencial:** usuário confirmou exclusão do segredo GitHub `OES_AUTH_B2_PASSWORD` após o B2-P1 PASS. A role temporária `oes_auth_migrator` continua sujeita à validade definida no PostgreSQL e requer novo segredo descartável protegido para qualquer execução futura. Não pressupor que a exclusão do segredo revogue privilégios da role.

**Escopo pretendido:** uma única execução controlada de `python manage.py migrate --noinput --database default --settings=config.settings_auth_pg_b2_optin` no projeto, branch e database já aprovados, apenas sob autorização específica B2-M1 ainda não concedida. Não usar `migrate --run-syncdb`; não executar `makemigrations`; não executar `flush`, `createsuperuser`, `collectstatic`, servidores ou endpoints HTTP.

**Checks obrigatórios imediatamente antes da migration:** preflight `read_only_preflight()` via a própria conexão Django; confirmar identidade, schema, ACL e 0 objetos, inclusive tabela `django_migrations`; inspecionar o plano com `showmigrations --plan` somente após credencial aprovada. O `search_path` é **exclusivamente** `django_auth` e o alias científico permanece `dummy`. Capturar inventário READ ONLY dos schemas científicos antes/depois, preferencialmente com hashes de nomes/tipos/owners, sem ler dados científicos.

**Efeitos esperados e ressalvas:** a migração cria `django_migrations`, tabelas nativas `auth`, `contenttypes`, `sessions`, a tabela `preparer_identity_prepareridentity`, tabelas M2M, índices e sequências em `django_auth`; o comando Django também pode escrever metadados de `ContentType` e `Permission` (incluindo modelos `evidence` não gerenciados) **dentro de `django_auth`**, por sinais `post_migrate`. Não devem ser criadas ou alteradas tabelas científicas. Proibição de usuários reais e de dados científicos reais permanece.

**Contenção:** a execução de migrations nativas pode abranger diversas transações; **não prometer rollback atômico de todo o comando**. Se erro, interromper novas tentativas e emitir inventário/postflight de leitura, com estado de `django_migrations`; não apagar manualmente tabelas ou refazer comando até plano de recuperação expressamente aprovado. O PASS exige conclusão de migrate, schema ownership e ACL coerentes, integridade `django_migrations` e inventário científico estável. O workflow de preflight B2-P1 permanece desabilitado.

**Decisão nesta atividade:** somente plano documental, sem recriar segredo, sem conexão ou migration PostgreSQL. Gate B2 continua HOLD até aprovação individual B2-M1.


## B2-M1 — migrations Django conectadas PASS (2026-10-28)

Autorização expressa de execução única B2-M1; workflow manual [run 40730386136](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40730386136), `workflow_dispatch`, tentativa 1, SHA `5bd718263d4462a3b2fe4bef6b9cb8e91d869f22`, conclusão **SUCCESS**. Preflight `PASS_READ_ONLY_DJANGO_AUTH_SCHEMA`, escopo `B2_M1_APPROVED_MIGRATION_GRAPH`, `MIGRATE_COMMAND_COMPLETED`, postflight `B2_M1_POSTFLIGHT_PASS`.

**16/16 migrations aplicadas** (`contenttypes`, `auth`, `preparer_identity`, `sessions`), confirmadas por comparação de registro e arquivos locais. `django_auth` contém **49 objetos pg_class** após migração; role/sessão `oes_auth_migrator` no schema `django_auth`. `post_migrate` produziu metadados ContentType e Permission, inclusive para cinco modelos científicos `evidence` não gerenciados; metadados residem em `django_auth`. Fingerprint do inventário estrutural científico: 315 registros e SHA-256 `2e75e4c018b62f8b288b5f84e9a70fe0ebf9eea64e928468130e4950d38f6b81` tanto antes quanto depois. Isso é verificação estrutural delimitada, não prova de ausência de toda alteração de dados ou ACL.

Workflow B2-M1 **desabilitado após execução** em commit `31fd4dbb910bde68a84a1951005c2f4ef72779b5`. **Segredo `OES_AUTH_B2_M1_PASSWORD` exige exclusão manual confirmada pelo responsável**; não presumir removido. Não reexecutar. B2-M1 PASS exclusivamente no escopo de migrations de autenticação sintética, sem usuário real, runtime grants, HTTP writes, deploy ou promoção operacional. G2-P2B NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.


## Pós-B2-M1 — levantamento de ACL do runtime (READ ONLY, 2026-10-28)

Responsável confirmou exclusão de `OES_AUTH_B2_M1_PASSWORD` (não verificada no inventário GitHub). Consultas somente leitura ao Neon constataram 10 tabelas, 30 índices e 9 sequências no `django_auth`, todas propriedade de `oes_auth_migrator`. `oes_runtime` LOGIN=true, NOINHERIT e sem USAGE/CREATE no schema; sem SELECT/INSERT/UPDATE/DELETE nas dez tabelas. `oes_django_migrator` NOLOGIN e sem USAGE/CREATE no schema. Nenhuma concessão foi executada.

**Recomendação para gate futuro separado, ainda não autorizado:** mapear ações e acessos efetivamente exigidos pelas rotas Django de sessão, login, autorização e identidade persistente antes de qualquer GRANT. O runtime necessitará em geral USAGE no schema, acesso de leitura aos catálogos de usuários, grupos, permissões e content types; a persistência de sessões e identidades poderá exigir INSERT/UPDATE/DELETE estritos em tabelas determinadas, e USAGE nas sequências vinculadas a INSERT. Evitar `ALL PRIVILEGES ON ALL TABLES`, CREATE no schema, acesso a `django_migrations`, privilégios administrativos e grants em schemas científicos. As ACLs sobre objetos devem ser emitidas pelo proprietário de objetos `oes_auth_migrator` ou por grantor autorizado, **não presumir capacidade do owner do schema sobre tabelas de outro papel**. O modelo de provisionamento de contas reais permanece pendente; não habilitar runtime HTTP.

**Estado:** B2-M1 PASS; runtime ACL não autorizada, nenhuma mudança de role/grant, G2-P2B NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.


## Matriz candidata de privilégios do runtime Django (2026-10-28; SEM GRANT)

**Princípio:** `oes_runtime` não deve ser equiparado a migrador. Esta é uma matriz de desenho, não uma concessão autorizada. Cabe ao gate operacional futuro decidir se `oes_runtime` será reutilizado ou se será adotado login exclusivamente de autenticação; não alterar papel existente por inferência.

| Objeto django_auth | Leitura autenticada e autorização | Sessão/login sintético persistente | Provisionamento administrativo separado |
|---|---|---|---|
| `auth_user` | SELECT (identificação, hash, flags, grupos e permissões) | UPDATE **somente se** política de login exigir `last_login` | INSERT/UPDATE/DELETE, caso aprovado, fora do runtime comum |
| `auth_group`, `auth_permission`, `django_content_type` | SELECT | SELECT | Alterações somente sob gestão administrativa |
| `auth_user_groups`, `auth_user_user_permissions`, `auth_group_permissions` | SELECT para checar autorização | SELECT | INSERT/DELETE só no fluxo de administração de papéis/permissões |
| `django_session` | SELECT | INSERT, UPDATE, DELETE para gravar, renovar e encerrar sessão | não aplicável |
| `preparer_identity_prepareridentity` | SELECT para resolver `actor_uuid` | **sem INSERT padrão**: identidade deve ser provisionada por fluxo autorizado | INSERT/UPDATE, se e quando definido; DELETE não recomendado por padrão |
| `django_migrations` | nenhum | nenhum | migrador exclusivamente |
| Sequências `django_session` | não há (PK de sessão não sequencial) | nenhuma | — |
| Sequências relacionadas a `auth_user`, grupos, M2M, permissões e content types | nenhuma | nenhuma no fluxo de login comum | USAGE somente às sequências correspondentes às operações INSERT aprovadas |
| `preparer_identity_prepareridentity_id_seq` | nenhuma | nenhuma quando identidade já provisionada | USAGE para provisionamento autorizado |

**Alternativa preferencial para fase experimental controlada:** autenticação funcional de usuários sintéticos **previamente provisionados**, com SELECT estrito nas tabelas de autenticação, INSERT/UPDATE/DELETE apenas na `django_session` e UPDATE em `auth_user` condicionada ao uso do sinal padrão `last_login` (alternativamente desligar esse comportamento mediante decisão técnica documentada). Sem criação de usuários por HTTP, sem auto-provisionamento de `PreparerIdentity`, sem edição de grupos ou permissões por runtime, sem CREATE no schema, sem privileges `ALL`, sem grants em scientific schemas.

**Impedimento operacional:** `oes_runtime` não possui sequer USAGE em `django_auth` e não tem privilégios nas dez tabelas nem nas nove sequências; todos esses objetos foram criados e pertencem a `oes_auth_migrator`. O schema pertence a `oes_sandbox_owner`. Planejar `GRANT USAGE ON SCHEMA` via owner do schema e `GRANT` de tabelas por owner dos objetos ou grantor autorizado; são aprovações distintas. A role do migrador tem validade de senha até 2026-10-31 23:59:59 UTC; **vencimento não transfere propriedade nem remove role**.

**Gates seguintes:** (1) decisão de política do mecanismo de login (atualização `last_login` e gestão de identidades), (2) aprovação nominal da matriz de tabelas e grants de schema, (3) ensaio sintético sob login runtime explicitamente autorizado, (4) limpeza de credenciais e rechecagem de ACL. Não conceder direitos ou ativar HTTP nesta etapa. B2-M1 PASS; runtime ainda HOLD; G2-P2B NO-GO; E9 NO-GO; Fase 5 NOT_STARTED.
