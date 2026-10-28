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


## Política candidata de login e provisionamento — decisão pendente (2026-10-28)

**Constatação:** o projeto usa `django.contrib.auth` nativo, `PreparerIdentity.user` 1:1 com `PROTECT`, `actor_uuid` estável; o resolvedor exige registro pré-existente e falha fechado quando ausente. `require_question_preparer` exige usuário ativo, não staff/superuser e permissão explícita `evidence.prepare_question`. Nenhuma rota de provisionamento foi autorizada.

**Proposta proporcional (não executada):** preservar inicialmente o comportamento nativo do Django, inclusive atualização de `auth_user.last_login` pelo sinal padrão após autenticação. Isto implica **UPDATE delimitado** em `auth_user`; não equiparar o direito SQL por coluna ao controle de campos na aplicação: se a operação real for `UPDATE` sem colunas explícitas, a restrição via `GRANT UPDATE(last_login)` deverá ser validada em teste sintético isolado. Não desabilitar sinal de login sem decisão específica. Configuração de sessões no PostgreSQL requer SELECT/INSERT/UPDATE/DELETE sobre `django_session`, sem sequência própria.

**Provisionamento:** contas sintéticas, `auth_user_user_permissions` e `preparer_identity_prepareridentity` devem ser criadas por procedimento administrativo separado, auditável, com identidade UUID estável; runtime comum recebe somente SELECT para identidade e permissões. Evitar autocriação de identidade em login/GET e qualquer endpoint de gestão nesta etapa. A permissão `evidence.prepare_question` deve ser provisionada explicitamente, não inferida de `is_staff` nem de `is_superuser`. Criar dados sintéticos conectados exige autorização nominal distinta.

**Próxima deliberação:** escolher preservar `last_login` nativo com UPDATE mínimo ou bloquear atualização explicitamente; em seguida definir GRANTs por tabela/coluna e grantor adequado. Até deliberação, nenhuma alteração de `last_login`, sinal, role, grant, identidade ou dado em Neon. B2-M1 PASS, runtime HOLD.


## Runtime Auth — especificação de ACL para revisão (2026-10-28; nenhuma concessão)

**Preflight catalogal somente leitura:** as dez tabelas e nove sequências de `django_auth` são propriedade de `oes_auth_migrator` e possuem `relacl=NULL` (ACL não explicitada no objeto; não interpretar como inexistência de direitos do owner). `oes_runtime` continua sem USAGE no schema nem privilégios sobre os objetos. O schema é propriedade de `oes_sandbox_owner`.

**Matriz candidata exclusivamente para usuários sintéticos pré-provisionados; não é SQL aprovado:**

| Objeto | Direito proposto a `oes_runtime` | Justificativa |
|---|---|---|
| Schema `django_auth` | USAGE, nunca CREATE | Resolução de nomes |
| `auth_user` | SELECT; UPDATE **apenas** (`last_login`) sujeito a ensaio SQL/django | Login e sinal nativo `last_login` |
| `auth_group`, `auth_permission`, `django_content_type` | SELECT | Resolução de permissões |
| `auth_user_groups`, `auth_user_user_permissions`, `auth_group_permissions` | SELECT | Relações de permissões |
| `django_session` | SELECT, INSERT, UPDATE, DELETE | Ciclo de sessão, inclusive expiração e logout |
| `preparer_identity_prepareridentity` | SELECT | Resolver ator persistente |
| `django_migrations` | **nenhum** | Reservado ao migrador |
| Todas as nove sequências | **nenhum** | O fluxo de sessão usa chave textual; usuários/identidades não são criados pelo runtime |

**Cuidado importante:** `UPDATE(last_login)` é privilégio **de coluna**; validar que o Django nativo persiste exclusivamente essa coluna e não executa SQL de atualização mais ampla antes de conceder. Se o teste revelar necessidade de UPDATE irrestrito, retornar para deliberação; não ampliar silenciosamente. Além disso, a conexão do runtime não deve reutilizar `settings_auth_pg_b2_optin.py`, que emprega a identidade migradora e é específica de migrations.

**Plano de concessão (proposta, não autorizado):** um grantor com autoridade sobre o schema (atualmente `oes_sandbox_owner`) concede USAGE; o proprietário de tabelas (atualmente `oes_auth_migrator`) ou grantor de objeto devidamente autorizado concede direitos de tabela/coluna. Verificar previamente a capacidade efetiva do grantor, sem presumir que o owner do schema pode conceder sobre as tabelas. A expiração da senha em 31/10 não altera ownership nem substitui o plano de ciclo de vida do papel. **Não** executar `GRANT ALL`, `ALTER DEFAULT PRIVILEGES`, grants de sequências, SQL em schemas científicos, ou provisionamento de identidades como consequência desta proposta.

**Critério de saída para gate futuro:** política de `last_login` formalmente aprovada, SQL mínimo revisado, identidade e credencial de runtime segregadas, uma única prova sintética autorizada e plano de reversão de GRANTs conforme grantor efetivo. Até então, **runtime HOLD; nenhuma ACL alterada**.


## Evidência offline do SQL `last_login` (2026-10-28)

Teste de captura de SQL no SQLite descartável `AuthSQLiteSandboxTests.test_native_login_updates_only_last_login_column`, CI [40732121063](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40732121063) **192/192 PASS** (173 principal + 19 integração). Login sintético nativo do Django gerou **uma** instrução `UPDATE auth_user`, somente coluna `last_login`, e valor persistiu. Isso fundamenta tecnicamente o grant candidato `UPDATE(last_login)`, **mas não demonstra privilégios PostgreSQL efetivos**, que dependem de autorização e teste próprio. Nenhum GRANT, role, Neon conectado ou runtime HTTP foi alterado.


## Gate candidato AUTH-RUNTIME-G1 — SQL de concessões mínimas, NÃO EXECUTADO (2026-10-28)

**Preflight READ ONLY:** HEAD de partida `794bd38a3b5ebf1392e42dd560c4b71573693062`. Schema `django_auth` pertence a `oes_sandbox_owner`, ACL `{oes_sandbox_owner=UC/oes_sandbox_owner,oes_auth_migrator=UC/oes_sandbox_owner}`. Dez tabelas e nove sequências pertencem a `oes_auth_migrator`, sem ACL explícita; `oes_runtime` não possui USAGE no schema nem direitos sobre essas relações. Papel migrador expira em 2026-10-31 23:59:59 UTC; vencimento não transfere ownership.

**Proposta de duas autoridades distintas, sujeita a autorização própria (NÃO executar por este registro):**

```sql
-- Executar como oes_sandbox_owner (owner do schema) somente após autorização:
GRANT USAGE ON SCHEMA django_auth TO oes_runtime;

-- Executar como oes_auth_migrator (owner das relações) somente após autorização:
GRANT SELECT ON TABLE
    django_auth.auth_user,
    django_auth.auth_group,
    django_auth.auth_permission,
    django_auth.django_content_type,
    django_auth.auth_user_groups,
    django_auth.auth_user_user_permissions,
    django_auth.auth_group_permissions,
    django_auth.preparer_identity_prepareridentity
TO oes_runtime;

GRANT UPDATE (last_login) ON TABLE django_auth.auth_user TO oes_runtime;

GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE django_auth.django_session TO oes_runtime;
```

**Proibições e limites:** nenhum GRANT em `django_migrations`, sequências, schema científico, nenhuma criação de papel, `ALTER DEFAULT PRIVILEGES`, `GRANT ALL`, `CREATE ON SCHEMA`, permissões de provisionamento de conta/identidade ou endpoint HTTP. Autenticação nativa atualiza apenas `last_login` conforme ensaio SQLite [40732121063](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40732121063); compatibilidade efetiva PostgreSQL não demonstrada. O fato de `oes_runtime` já existir não prova isolamento do restante de seus direitos: qualquer reutilização exige avaliar os privilégios globais antes de decidir. Uma credencial de conexão e configuração Django de runtime distinta da credencial migradora são pré-requisitos futuros.

**Plano de verificação:** comparar ACLs/owners antes e depois; confirmar USAGE e não CREATE, SELECT apenas nas oito tabelas nomeadas, UPDATE restrito a `auth_user.last_login`, DML apenas `django_session`, nenhum direito a `django_migrations`/sequências; observar grantor real na ACL. Se qualquer desvio ocorrer, parar, não executar DML nem aplicar correções ad hoc. Reversão específica exige identificação do grantor original e aprovação; não emitir REVOKE genérico.

**Decisão:** AUTH-RUNTIME-G1 permanece proposta, sem autorização para executar SQL. B2-M1 PASS, runtime HOLD, G2-P2B NO-GO, E9 NO-GO e Fase 5 NOT_STARTED.


## AUTH-RUNTIME-G1 — decisão arquitetural preparatória sobre login (2026-10-28)

Preflight READ ONLY por `has_schema_privilege`: `oes_runtime` apresenta USAGE=true somente em `public` (CREATE=false), e USAGE/CREATE=false em `appraisal`, `artifact`, `core`, `django_auth`, `evidence`, `investigation`, `oes_app`, `oes_raw_private`, `product`, `provenance`, `synthesis`. Esta é avaliação **de privilégio efetivo de schema**, não auditoria exaustiva de papéis, atributos ou privilégios em objetos. A consulta adicional sobre memberships não pôde ser concluída por restrição da ferramenta; não inferir ausência de memberships.

**Recomendação proporcional:** reutilizar `oes_runtime` é tecnicamente possível quanto ao isolamento atual de schemas, mas não deve ser decidido só por este inventário. Preferência arquitetural por **login de autenticação exclusivo e efêmero na fase de prova**, caso testes conectados de sessão/identidade requeiram segredo e DML específicos; evita acumular no papel genérico um conjunto permanente de direitos de autenticação e reduz superfície de acesso. A escolha definitiva entre reaproveitar `oes_runtime` e papel dedicado exige revisão das dependências de aplicação e da governança de credenciais, sem criar papel enquanto não houver aprovação.

**Estado:** decisão candidata; `AUTH-RUNTIME-G1` em HOLD, nenhum papel ou GRANT alterado. B2-M1 PASS, G2-P2B NO-GO, E9 NO-GO e Fase 5 NOT_STARTED.


## AUTH-RUNTIME-G1 — contrato de login dedicado para ensaio sintético (2026-10-28; PROPOSTA)

**Identidade candidata:** `oes_auth_trial_login`, exclusiva para autenticação/sessões em `oes_sandbox.django_auth`, **não** integrante de `oes_runtime` nem do migrador. Papel `LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS`, sem memberships e com limite de conexão 1 se compatível com o ensaio. Senha descartável criada **privadamente pelo responsável no Neon SQL Editor**, nunca digitada em chat, código, log ou commit; validade UTC curta fixada no ato da autorização, sem pressupor que expiração revogue o papel ou os privilégios. O nome é candidato: confirmar ausência de colisão antes da criação.

**Permissões candidatas:** USAGE (não CREATE) no schema `django_auth`; SELECT somente nas oito relações `auth_user`, `auth_group`, `auth_permission`, `django_content_type`, `auth_user_groups`, `auth_user_user_permissions`, `auth_group_permissions`, `preparer_identity_prepareridentity`; `UPDATE(last_login)` na `auth_user`; SELECT/INSERT/UPDATE/DELETE somente na `django_session`. Nenhuma concessão sobre sequências ou `django_migrations`; nenhuma concessão nos schemas científicos. O SQL detalhado documentado anteriormente precisa substituir `oes_runtime` pelo nome do papel aprovado, **após** preflight e autorização nominal específica.

**Separação de grantors:** `oes_sandbox_owner` é proprietário do schema, apto em princípio a conceder USAGE; `oes_auth_migrator` é proprietário das dez tabelas, apto em princípio a conceder privilégios de relação/coluna. Concessões requerem autorização própria e verificação de identidade do grantor; não ampliar memberships para contornar restrições. A validade temporária do migrador termina em 2026-10-31 23:59:59 UTC, mas não afeta ownership.

**Ensaio futuro (gate distinto):** configurar conexão Django opt-in separada da configuração B2 de migrations; preflight com `current_user`, `current_schema`, `search_path`, ACLs e inventário; autenticação de **usuário sintético previamente provisionado por procedimento administrativo autorizado**; `last_login` e ciclo de sessão persistente; resolver `actor_uuid`; proibir HTTP write, criação de usuário ou identidade pelo runtime e acesso científico. Não haverá ensaio conectado automaticamente após criação do papel ou GRANT.

**Encerramento:** após único ensaio autorizado, desabilitar workflow, solicitar exclusão confirmada de segredo GitHub, inventariar ACLs/grantors e executar revogações específicas e DROP ROLE **somente após autorização separada**. Expiração da credencial não elimina grants. Falha em qualquer verificação: HOLD, sem repetição automática.

**Decisão desta atividade:** contrato documental exclusivamente; `oes_auth_trial_login` **não criado**, sem senha/segredo cadastrado, sem GRANT e sem conexões. AUTH-RUNTIME-G1 HOLD; B2-M1 PASS; G2-P2B NO-GO; E9 NO-GO; Fase 5 NOT_STARTED.


## AUTH_RUNTIME_G1_MINIMAL_GRANTS — pacote de autorização proposto (2026-10-28)

Preflight catalogal read-only após criação do papel: `oes_auth_trial_login` sem USAGE em `django_auth`, sem SELECT/INSERT/UPDATE/DELETE nas dez tabelas. `oes_sandbox_owner` é owner do schema; `oes_auth_migrator` é owner das dez tabelas. Sem alteração operacional nesta atividade.

**Escopo exato para aprovação posterior:** um GRANT USAGE ON SCHEMA django_auth TO oes_auth_trial_login, executado com autoridade do owner do schema; SELECT nas oito tabelas `auth_user`, `auth_group`, `auth_permission`, `django_content_type`, `auth_user_groups`, `auth_user_user_permissions`, `auth_group_permissions`, `preparer_identity_prepareridentity`; UPDATE(last_login) exclusivamente em `auth_user`; SELECT, INSERT, UPDATE, DELETE exclusivamente em `django_session`. Direitos de relações concedidos pelo owner `oes_auth_migrator` ou grantor que possua grant option verificável. Sem grants em sequências, `django_migrations`, outros schemas; sem memberships, mudanças de role, migrations, DML, conexões Django, teste de login ou HTTP write. Confirmar ACL e grantor por consulta read-only após execução. **HOLD em qualquer divergência.** O usuário deverá autorizar explicitamente esse pacote antes de qualquer execução.

**Dependência:** expiração da senha `oes_auth_migrator` em 2026-10-31 23:59:59 UTC. Execução e reversão posterior exigem planejar acesso autorizado aos objetos; expiração não remove grants ou ownership. Não conceder direitos como expediente para contornar falha de grantor.


## AUTH_RUNTIME_G1_MINIMAL_GRANTS — PASS catalogal (2026-10-28)

Autorização nominal `APPROVED — OES / AUTH_RUNTIME_G1_MINIMAL_GRANTS / SINGLE_CONTROLLED_MINIMAL_AUTH_ACL`. Execução restrita em `weathered-boat-65779510` / `br-gentle-hall-b6jaxehf` / `oes_sandbox`:
- `oes_sandbox_owner`: `GRANT USAGE ON SCHEMA django_auth TO oes_auth_trial_login`.
- `oes_auth_migrator`: SELECT nas oito tabelas `auth_user`, `auth_group`, `auth_permission`, `django_content_type`, `auth_user_groups`, `auth_user_user_permissions`, `auth_group_permissions`, `preparer_identity_prepareridentity`; UPDATE(`last_login`) somente em `auth_user`; SELECT/INSERT/UPDATE/DELETE em `django_session`.

Postflight READ ONLY confirmou USAGE=true e CREATE=false no schema, SELECT exatamente nas oito tabelas e sessão, DML exclusivamente em sessão, nenhuma permissão em `django_migrations`, UPDATE por coluna exclusivamente `auth_user.last_login` entre 11 colunas, zero sequências com USAGE/SELECT/UPDATE e zero memberships. Sem migrations, DML ou teste de login. Essa verificação não atesta ainda execução Django conectada, nem avalia uso de credenciais ou escrita HTTP. Preservar grantor-aware rollback para eventual encerramento; não revogar automaticamente. `AUTH_RUNTIME_G1_MINIMAL_GRANTS=PASS` no escopo catalogal; B2-M1 PASS; ensaio de login conectado não autorizado; G2-P2B NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.


## AUTH_RUNTIME_G2 — plano do ensaio conectado mínimo (2026-10-28; DESIGN ONLY)

**Estado confirmado:** AUTH_RUNTIME_G1_ROLE_CREATE PASS e AUTH_RUNTIME_G1_MINIMAL_GRANTS PASS catalogal; `oes_auth_trial_login` tem USAGE em `django_auth`, SELECT nas oito tabelas autorizadas, UPDATE apenas em `auth_user.last_login`, DML em `django_session`, sem `django_migrations`, sequências nem memberships. Nenhum ensaio Django conectado autorizado.

**Separação de subgates:**
1. **G2-P0, documental/offline:** configurar settings Django de runtime dedicados, opt-in distinto de `settings_auth_pg_b2_optin` (migrador), sem ativação de HTTP; testar fail-closed e isolamento em SQLite/mocks. Não inserir credenciais no código.
2. **G2-P1, conectado READ ONLY:** com credencial temporária em GitHub Actions secret fornecida privadamente pelo responsável, executar uma única sessão de introspecção de `current_user`, `current_schema`, `search_path`, tabelas e direitos permitidos/negados, sem ORM que execute gravação. Deve permanecer bloqueado até autorização nominal própria. Excluir segredo e desabilitar workflow após execução.
3. **G2-P2, prova de autenticação com DML:** requer usuário de teste previamente provisionado e `PreparerIdentity`/permissão explícita por gate administrativo separado. Somente após isso deliberar atualização de `last_login`, sessões e cleanup sintéticos, com inventário antes/depois, sem HTTP writes. Sem reais pesquisadores.
4. **G2-P3, encerramento:** verificar estado de sessões, revogações específicas observando grantor e remoção do papel mediante autorizações separadas. Expiração de senha não é limpeza.

**Condições de HOLD:** settings ainda apontam `oes_auth_migrator`, password/endpoint não disponível, `search_path` divergente, privileges inesperados, objeto científico acessível, tentativa de query mutante no P1, inexistência do usuário sintético no P2, ou tentativas de habilitar o web writer. Nenhuma passagem automática entre subgates. G2-P2B operacional permanece NO-GO; E9 NO-GO; Fase 5 NOT_STARTED.


## AUTH_RUNTIME_G2-P0 — implementação offline PASS (2026-10-28)

Adicionada `applications/oes_web/config/settings_auth_pg_g2_trial_optin.py`, configuração de prova exclusivamente conectável após `OES_AUTH_G2_EXPLICIT_OPT_IN=1`, host allowlisted e `OES_AUTH_G2_PASSWORD` presente. Alias `default` PostgreSQL com usuário `oes_auth_trial_login`, `search_path=django_auth`, TLS required, `CONN_MAX_AGE=0`; alias científico dummy; roteador de isolamento `AuthSandboxRouter`; não reutiliza settings B2 de migrations. Importar settings não conecta automaticamente ao Neon.

Dois testes offline adicionados em `evidence/auth_sqlite_sandbox_checks.py`: ausência de opt-in, falta de credencial e host divergente geram HOLD; configuração aprovada apenas simulada confirma usuário, banco, search_path, aliases e roteador. CI [40737324208](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40737324208) **194/194 PASS** (173 principal + 21 autenticação). Commits: settings `4c4fd50`, testes `8913678`. Nenhum segredo real, nenhuma conexão Neon, DML, role/grant, workflow conectado ou HTTP writes. **G2-P0 PASS apenas offline; G2-P1 conectado depende de autorização separada**. G2-P2B operacional NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.


## AUTH_RUNTIME_G2-P1 — artefatos preparatórios bloqueados (2026-10-28)

Foi criado o verificador conectado **somente leitura** `applications/oes_web/config/auth_pg_g2_p1_preflight.py`, restrito à configuração `oes_auth_trial_login` / `oes_sandbox` / `django_auth`, que consulta identidade, schema efetivo e USAGE/CREATE. Workflow manual `.github/workflows/oes-auth-g2-p1-readonly-manual.yml` criado com bloqueio de job `if: false`, dependente de segredo efêmero `OES_AUTH_G2_P1_PASSWORD` não cadastrado por esta atividade; sem triggers automáticos, sem DML e sem ativação HTTP. Os verificadores atuais cobrem **identidade e schema**, não a totalidade da matriz de privilégios; ampliar cobertura e testar offline antes de qualquer execução conectada. Nenhum teste conectado autorizado ou realizado. G2-P1 HOLD.


## G2-P1 — verificação de ACL ampliada e testada offline (2026-10-28)

`config/auth_pg_g2_p1_preflight.py` passou a consultar somente catálogos/identidade: banco, role, schema, search_path, USAGE/CREATE, dez tabelas com privilégios SELECT/INSERT/UPDATE/DELETE, UPDATE por coluna em `auth_user` e nove sequências sem privilégios. A comparação exige matriz exata; derivações provocam HOLD. Teste `G2CatalogueOfflineTests.test_g2_exact_acl_and_sequence_drift` adicionado, com aceite do inventário esperado e rejeição de desvio em sequência e tabela.

CI [40738061389](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40738061389) **195/195 PASS** (173 principais + 22 de autenticação/integração). Alterações: `04b4103` verificador; `b38053f` teste. **Nenhum acesso conectado ao Neon** e workflow G2-P1 permanece manual e desabilitado. Não alegar prova de conexão nem de ACL em runtime até G2-P1 ser especificamente autorizado e executado. G2-P2B operacional NO-GO; E9 NO-GO; Fase 5 NOT_STARTED.

## G2-P1 tentativa única — HOLD, credencial vazia (2026-10-28)

[GitHub Actions 40739503353](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40739503353), workflow_dispatch, tentativa 1, SHA `e66920c884aa93a2b795e8b4509cca70310ba98f`: FAILURE. `django.setup()` falhou no carregamento de settings com `RuntimeError: HOLD: dedicated G2 endpoint and ephemeral credential required`; variável `OES_AUTH_G2_PASSWORD` registrada vazia. O workflow referencia `secrets.OES_AUTH_G2_P1_PASSWORD`; conferir existência, escopo e disponibilidade do segredo na origem, sem transmitir seu conteúdo. A execução não alcançou a conexão nem a checagem ACL. Workflow novamente bloqueado por `if: false` no commit `9a884a554e9a51694d08880582d6b2dc73da29ad`. Não repetir sem novo gate/autorização. Solicitar exclusão do segredo temporário após diagnóstico; não presumir exclusão. G2-P1 HOLD; G2-P0 PASS; concessões G1 PASS; G2-P2B operacional NO-GO; E9 NO-GO; Fase 5 NOT_STARTED.


## AUTH_RUNTIME_G2-P1 — prova Django conectada READ ONLY PASS (2026-10-28)

Segunda execução especificamente autorizada [40740532848](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40740532848), `workflow_dispatch`, tentativa 1 da execução, SHA `702e592e1240804b16c3c4dd829dd280ce16f88a`: **SUCCESS**. Log: `PASS_G2_P1_CONNECTED_READ_ONLY`. Verificador Django conectado validou banco `oes_sandbox`, `session_user/current_user=oes_auth_trial_login`, schema e search_path `django_auth`, USAGE sem CREATE, matriz exata de dez tabelas e direitos, UPDATE apenas `last_login` em `auth_user`, nove sequências sem privilégios. Sem leitura de registros científicos, login de usuário, migrations, DML ou HTTP write. Workflow bloqueado novamente após PASS em commit `9b66e018465101e1322cb9d7ed65fd75200322c1`. Segredo GitHub `OES_AUTH_G2_P1_PASSWORD` **requer exclusão manual e confirmação**. G2-P1 PASS estritamente conectado/read-only; G2-P2 de autenticação sintética com DML ainda sem autorização; G2-P2B operacional NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.


## AUTH_RUNTIME_G2-P2 — desenho de ensaio sintético, SEM DML (2026-10-28)

**Pré-condições comprovadas:** G2-P0 offline PASS (194 testes naquela execução); G2-P1 conectado READ ONLY PASS, run 40740532848; `OES_AUTH_G2_P1_PASSWORD` excluído segundo confirmação do responsável. G2-P2 ainda NÃO AUTORIZADO. Nenhuma credencial deve ser reusada sem gate específico. Cautela: `oes_auth_trial_login` permite DML somente em `django_session` e UPDATE na coluna `auth_user.last_login`; não pode criar usuário, permissionamento ou identidade. O proprietário `oes_auth_migrator` é distinto do trial e deve ser tratado como autoridade de provisionamento em gate apartado, jamais por elevação do trial.

**Proposta com fronteiras sequenciais e evidência:**

1. **P2-A — pré-flight estritamente READ ONLY:** verificar, sem exposição de dados pessoais, presença/ausência de identificador sintético reservado; existência de `evidence.prepare_question` em `auth_permission` (o `post_migrate` criou permissões de modelo padrão, não comprova esta permissão customizada); relações FK entre user, permission e `PreparerIdentity`; capacidade de grantor e catalogação de sequências. Registrar baseline por inventário estrutural científico e contagem/checksums delimitados de metadados auth, preservando dados existentes. Se identificador já existir ou houver registros inesperados: HOLD.
2. **P2-B — provisionamento administrativo separado (novo gate DML):** criar **um** usuário sintético não staff, não superuser, ativo, com password hash Django (nunca credencial real ou plaintext em logs), criar ou verificar a permissão customizada `evidence.prepare_question`, associá-la nominalmente ao usuário e criar `PreparerIdentity` com UUID estável; garantir identificadores de teste inequívocos. Executar somente sob ator administrativo com autorização e privilégios adequados em `django_auth`, com sequência de criação/cleanup consistente e sem reutilizar `oes_auth_trial_login` para provisioning. Definir previamente como a senha sintética será criada e armazenada temporariamente, sem vazar. O modelo de identidade utiliza FK `on_delete=PROTECT`: remover identidade antes de excluir usuário; remover vínculos/permissão customizada apenas se criados pelo ensaio.
3. **P2-C — prova de runtime em uma execução controlada (gate DML distinto):** conectar sob `oes_auth_trial_login`, executar autenticação nativa, validar atualização exclusiva `last_login`, autorização explícita e resolução estável de `actor_uuid`; exercitar criação/leitura/atualização/exclusão **exclusivamente** de sessões sintéticas `django_session`. Sem `migrate`, criação de contas, alterações de permissões, escrita científica, HTTP write ou implantação. Antes e depois, registrar identificadores sintéticos e contagens com escopo mínimo, sem publicar hashes de senhas, tokens ou sessões.
4. **P2-D — limpeza e auditoria, gate deliberado:** invalidar/eliminar apenas sessões identificadas do teste; desfazer associações e identidade antes de apagar usuário, respeitando `PROTECT`; remover permissão customizada apenas se criada exclusivamente pelo teste. Demonstrar ausência de resíduos sintéticos, preservação de registros pré-existentes e fingerprint estrutural científico estável. Desabilitar workflow e excluir segredo temporário. Falhas após DML **não** garantem rollback automático entre transações e exigem contenção/limpeza autorizadas, sem reexecução automática.

**Riscos técnicos a resolver antes de P2-B/C:** (a) existência e ciclo da permissão customizada `evidence.prepare_question`; (b) concessão de privilégios de sequência/INSERT apenas ao agente de provisionamento, sem contaminar login runtime; (c) expiração da senha do proprietário de tabelas `oes_auth_migrator` em 2026-10-31 23:59:59 UTC, que não revoga ownership; (d) distinguir sessão criada por `django.contrib.sessions` da lógica interna de `client.login` em testes SQLite; (e) nenhuma transição automática do gate de leitura para DML.

**Decisão atual:** somente desenho. O próximo passo proporcional é P2-A READ ONLY antes de qualquer código de DML ou execução. G2-P2 HOLD, G2-P2B operacional NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.

## G2-P2-A — leitura catalogal (2026-10-28)

Preflight sem escrita em oes_sandbox: auth_user=0; auth_permission=44; auth_user_user_permissions=0; django_session=0; preparer_identity_prepareridentity=0. A permissão específica evidence.prepare_question está ausente, enquanto o ContentType evidence.oesquestion existe (1). Há nove sequências no schema django_auth. A FK da identidade para o usuário usa NO ACTION no PostgreSQL; o modelo Django especifica PROTECT. Para eventual ensaio posterior, criar registros sintéticos e limpar em ordem reversa dependerá de autorização específica. G2-P2-A concluído como leitura; G2-P2-B/C/D não autorizados. Sem DML, grants ou HTTP writes.


## G2-P2-B — contrato de provisionamento administrativo sintético (2026-10-28; NÃO EXECUTADO)

**Decisão de desenho:** uma única Unidade de Trabalho transacional, sem migração, somente no schema `django_auth`, executada por conta administrativa existente com autoridade comprovada (não por `oes_auth_trial_login`). O agente futuro deverá possuir os direitos DML e USAGE sobre as sequências necessárias; confirmar antes, sem conceder direitos adicionais automaticamente. Não reutilizar senha do migrador nem imprimir valores sensíveis.

**Preflight bloqueante:** confirmar banco, branch, `current_user`, schema, permissões; `auth_user=0`, `preparer_identity=0`, `django_session=0`, `auth_user_user_permissions=0`, `auth_permission=44`, existência única do ContentType `evidence.oesquestion`, ausência da permissão `prepare_question` e ausência do username sintético reservado. Se a situação mudou, HOLD e reavaliar, sem corrigir automaticamente. Inventariar estruturas científicas separadamente antes/depois, sem consultas a registros reais.

**Operação candidata (somente mediante aprovação nominal posterior):** em uma transação Django `atomic(using="default")` sob configuração administrativa controlada e restrita: (1) criar permissão `evidence.prepare_question` associada ao ContentType existente; (2) criar exatamente um usuário com username reservado, `is_active=True`, `is_staff=False`, `is_superuser=False`, senha exclusivamente sintética e hash gerado por `set_password`/`create_user` (nunca plaintext persistido ou exibido); (3) atribuir aquela permissão explicitamente em `auth_user_user_permissions`; (4) criar uma identidade `PreparerIdentity` para o usuário, com `actor_uuid` gerado automaticamente e imutável durante o ensaio. Não criar grupos, superuser, dados científicos, logs com credenciais, nem alterar as 44 permissões existentes.

**Recibo e verificação:** registrar identificadores técnicos do lote, existência dos quatro efeitos esperados (permission, user, vínculo, identidade), quantidade, checks de unicidade, estado de permissões e baseline científica, sem senha/hash/token/UUID sensível em logs públicos. Em caso de falha dentro da transação, ROLLBACK e HOLD; não reexecutar automaticamente. Uma falha após COMMIT não autoriza rollback fictício.

**Limpeza projetada (gate distinto):** encerrado o ensaio runtime, remover sessões sintéticas identificadas; excluir vínculo usuário-permissão; excluir `PreparerIdentity` antes do usuário para respeitar `PROTECT`; remover usuário sintético; excluir `evidence.prepare_question` apenas se comprovadamente criada pelo próprio lote e sem referências externas; preservar os 44 registros anteriores. Revisar sequências e objetos residuais sem assumir que os contadores numéricos das sequences retrocedem após rollback ou DELETE. Encerrar credenciais e workflows com autorização própria.

**Impedimentos a resolver antes de solicitar DML:** método de autenticação/segredo temporário para usuário sintético, modo autorizado de executar Django administrativo com acesso às sequências, rollback/limpeza grantor-aware e prova offline de transação e proteção de vínculos. Por proporcionalidade, não introduzir novos serviços ou roles sem necessidade comprovada.

**Estado:** contrato preparado, sem SQL executado, sem usuário criado, G2-P2-B HOLD; G2-P2B operacional NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.

## G2-P2-B — testes de provisionamento e limpeza offline PASS (2026-10-28)

Dois testes em evidence/auth_sqlite_sandbox_checks.py (commit d54f4b4289a9bcebb0eb376356c0923d79aa9164) validam, em SQLite descartável, criação transacional de permissão evidence.prepare_question, usuário sintético com password hash, vínculo explícito e PreparerIdentity, proteção PROTECT, limpeza ordenada e restauração da contagem de permissões; o segundo provoca erro entre as operações e verifica rollback integral. CI [40741871726](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40741871726) SUCCESS: 173 testes principais + 24 auth = 197 PASS. Nenhum DML Neon, role/grant, HTTP write ou usuário real. A prova offline não autoriza nem valida execução PostgreSQL; G2-P2-B conectado permanece HOLD. Próxima decisão: preflight da identidade administrativa e especificação do provisionamento conectado com controle de credencial/cleanup, sob autorização nominal.

## G2-P2-B — preflight administrativo parcial (2026-10-28; somente leitura)

O catálogo confirmou 49 objetos de django_auth pertencentes a oes_auth_migrator. Os testes pontuais de privilégios do mesmo papel deram INSERT=true em auth_user, auth_permission, auth_user_user_permissions e preparer_identity_prepareridentity, DELETE=true em preparer_identity_prepareridentity e USAGE=true nas sequências auth_user_id_seq e auth_permission_id_seq. Ambas as roles oes_auth_migrator e oes_auth_trial_login têm validade de senha 2026-10-31 23:59:59 UTC. Consultas abrangentes e a checagem das demais sequências encontraram bloqueio de segurança da ferramenta; portanto o preflight está PARCIAL e não autoriza provisionamento. Antes de qualquer DML, verificar USAGE nas sequências dos vínculos e identidade, direitos de DELETE sobre todos os registros sintéticos, compatibilidade de execução administrativa e credenciais efêmeras. Nenhuma escrita Neon, alteração de role/grant ou workflow foi realizada. G2-P2-B conectado HOLD.

## G2-P2-B — complementação do preflight de privilégios (2026-10-28)

Consultas catalogais adicionais exclusivamente de leitura confirmaram, para oes_auth_migrator: USAGE nas sequências django_auth.auth_user_user_permissions_id_seq e django_auth.preparer_identity_prepareridentity_id_seq; DELETE nas tabelas django_auth.auth_user_user_permissions, django_auth.auth_user e django_auth.auth_permission. Todas retornaram true. Com o levantamento parcial anteriormente registrado (INSERT nas quatro tabelas previstas, DELETE em identidade, USAGE em sequências de usuário e permissão), a matriz de privilégios necessária à criação e limpeza dos quatro efeitos sintéticos está confirmada. Este PASS refere-se somente a ACLs catalogais, não a execução de operações, integridade do roteiro, conexão de Django administrativo ou disponibilidade de segredo. Sem GRANT, DML, novo papel ou conexão de runtime nesta atividade. G2-P2-B execução conectada permanece HOLD, sujeita a autorização específica e controle de limpeza.


## G2-P2-B — consolidação do preflight administrativo e smoke Django READ ONLY (2026-10-28)

**Preflight Neon conectado, autorizado e exclusivamente SELECT:** na branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, conexão solicitada como `oes_auth_migrator`, consultas qualificadas no schema `django_auth` confirmaram `session_user=current_user=oes_auth_migrator`, 44 permissões, 0 usuários, 0 vínculos de permissão, 0 identidades, 0 sessões, um ContentType `evidence.oesquestion` e ausência de `evidence.prepare_question`. Os quatro pares de privilégios INSERT/DELETE em tabelas e USAGE nas respectivas quatro sequências resultaram true. Uma consulta inicialmente empregou função de privilégio de sequência em objeto do tipo tabela, retornou erro sem escrita e foi corrigida.

**Distinção de sessão:** a ferramenta Neon apresentou `current_schema()=public` e `search_path="$user", public`; esse resultado não constitui evidência sobre configuração Django. O workflow manual [40756319997](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40756319997), no SHA `3a7c86f8fa3f13e831406376b5f2ff1143cf5cb6`, executou Django sob `oes_auth_migrator` com transação explicitamente READ ONLY e concluiu SUCCESS, emitindo `PASS_G2_P2B_DJANGO_ADMIN_SESSION_READ_ONLY`. O teste validou banco, identidade, `current_schema()=django_auth`, `search_path=django_auth` e alias científico dummy.

**Segredo:** responsável confirmou exclusão de `OES_AUTH_G2_P2B_SMOKE_PASSWORD` após execução. Não se declara conferência independente no inventário de segredos.

**Suficiência delimitada:** identidade conectada, baseline e ACLs de provisionamento estão demonstradas, assim como configuração de schema em sessão Django real. Isso NÃO demonstra DML conectado, integridade pós-commit, controle de concorrência externo, recuperação de resultado indeterminado ou limpeza. A configuração `settings_auth_pg_g2_p2b_dormant.py` segue bloqueada incondicionalmente; nenhum workflow de escrita foi habilitado. Próximo passo: preparar um pacote integrado e proporcional de operação sintética com verificação antes de qualquer autorização nominal de DML; preservar Django First (Doc347), simplificação proporcional (Doc362), Marco B OPEN, G2-P2-B HOLD/NO-GO, E9 NO-GO e Fase 5 NOT_STARTED.


## G2-P2-B — pacote integrado mínimo para decisão de DML (2026-10-28; NÃO AUTORIZA EXECUÇÃO)

**Decisão de suficiência:** não criar outro backend ou serviço de provisionamento. Reutilizar Django ORM, `transaction.atomic(using="default")`, `auth.User`, `auth.Permission`, `user.user_permissions.add()` e `PreparerIdentity`. A evidência READ ONLY Neon e o smoke Django [40756319997](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40756319997) já comprovaram ACLs, baseline histórica, identidade e schema da sessão; não repetir esse levantamento sem drift. O módulo `settings_auth_pg_g2_p2b_dormant.py` continua incondicionalmente bloqueado.

**Escopo de uma futura autorização nominal de DML:** exatamente uma execução sintética sob `oes_auth_migrator`, no projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, schema `django_auth`. Efeitos permitidos: criar exclusivamente (a) `evidence.prepare_question` vinculada ao ContentType `evidence.oesquestion`, (b) um usuário sintético ativo não staff/não superuser, (c) seu único vínculo direto com essa permissão, (d) sua `PreparerIdentity` com UUID4. Nenhum usuário real, sessão ou registro científico; nenhuma migration, DDL, GRANT, role, deploy, HTTP write ou serviço pago. Credenciais efêmeras exclusivamente por segredo protegido, nunca em código ou chat.

**Sequência operacional proposta:**
1. Antes do provisionamento: confirmação nominal da autorização e do escopo, isolamento de execução única e ausência de qualquer outro writer conhecido; caso não seja possível garantir ausência de escritor externo, HOLD. Confirmar configuração Django (host allowlisted, TLS, `oes_auth_migrator`, search_path fixo; alias científico dummy) e verificar identidade real da sessão. A aprovação não será inferida de variável de ambiente ou contrato puro.
2. Iniciar transação `transaction.atomic()` no alias administrativo; validar, dentro dela, baseline **exata** de 44 permissões preexistentes, 0 usuários, 0 vínculos, 0 identidades, 0 sessões, um ContentType-alvo, ausência de `prepare_question`, e privilégios vigentes. Registrar antes de escrever uma evidência suficiente para distinguir execução nova de execução já parcialmente concluída; nunca prosseguir com drift.
3. Executar os quatro efeitos pelo ORM existente com checks de alias e constraints nativas. Confirmar antes do commit: 45 permissões (44 originais preservadas), 1 usuário não administrador com password hash Django (sem imprimir hash), 1 vínculo, 1 identidade UUID4 estável, 0 sessões. Qualquer divergência antes de commit: lançar erro, rollback, HOLD.
4. Após commit, usar **nova leitura** independente e reconfirmar os mesmos efeitos e identidade correta, sem expor credencial, hash, token ou UUID em log público. Recibo limitado a status, identificador de execução não secreto e contagens/invariantes; distinguir `PASS_POST_COMMIT`, `FAIL_ROLLED_BACK` e `INDETERMINATE_HOLD`.
5. **Nunca fazer retry automático** se houver timeout, perda de conexão ou falha após tentativa de commit. Antes de qualquer nova ação, reconciliação READ ONLY do estado; uma limpeza eventual exige autorização separada. O número de sequência pode avançar mesmo com rollback, sem que isso signifique persistência de registro.
6. Limpeza posterior, em gate distinto, somente dos objetos identificados como criados neste ensaio: sessões sintéticas (se aparecerem no teste runtime), vínculo direto, `PreparerIdentity` (antes do usuário, por `PROTECT`), usuário, permissão customizada se não houver referência externa; confirmar restauração de 44 permissões e zero usuários/vínculos/identidades/sessões, sem alterar entradas preexistentes.

**Condições ainda impeditivas (NO-GO):** não existe entrada controlada de DML conectada revisada; a função Python interna `_provision_transaction` não é fronteira de autorização. Também falta validar offline a integração específica de baseline exata na própria transação conectada, o procedimento de reconciliação pós-commit e a prevenção operacional de execução concorrente. O workflow de smoke READ ONLY não pode ser reaproveitado como writer. O próximo incremento deverá entregar esses elementos como pacote único, com testes offline proporcionais, e **só então** solicitar autorização de DML separada. Até lá: G2-P2-B HOLD / NO-GO; Marco B OPEN; E9 NO-GO; Fase 5 NOT_STARTED.


### G2-P2-B — decisão proporcional de exclusividade e reconciliação (2026-10-28)

**Fronteira de concorrência:** `concurrency.group` do GitHub Actions serializa somente execuções participantes daquele mesmo grupo. Não bloqueia aplicações, SQL Editor, outros workflows ou clientes externos. Advisory locks PostgreSQL são cooperativos e igualmente insuficientes contra writers que não aderem ao mesmo protocolo. Nenhum desses mecanismos deve ser descrito como exclusão global.

**Decisão para o ensaio único:** janela administrativa explicitamente autorizada, confirmando suspensão/ausência de outros writers do schema de autenticação durante toda a transação; workflow manual `workflow_dispatch`, um único job sem retry, `concurrency` exclusivo para esse ensaio e `cancel-in-progress: false`; checagens de identidade, baseline exata e integridade antes de escrever. Em presença de concorrência não demonstravelmente controlada, HOLD, sem usar locks ou permissões adicionais de forma implícita. Caso posteriormente seja necessária exclusão entre clientes não cooperativos, demandará desenho específico e aprovação distinta de mecanismo no banco; não introduzir agora.

**Reconciliação:** a verificação SQLite `verify_synthetic_relations_offline` e seus testes provam somente a semântica local. O futuro runner conectado deverá abrir uma **nova conexão Django READ ONLY após encerrar a transação**, obter contagens e relações exatas (usuário fixture, grupo/atributos, permissão ligada ao ContentType correto, vínculo único e `PreparerIdentity` UUID4) e comparar a `CONNECTED_POSTFLIGHT`, sem imprimir segredos nem IDs internos. A conexão de leitura deve permanecer separada da transação DML. Falha de rede após tentativa de commit ou leitura incompleta: `INDETERMINATE_HOLD` e nenhum retry nem limpeza automática, mesmo que a leitura parcial sugira sucesso. `PASS_POST_COMMIT` requer commit confirmado e leitura independente completa. Nenhuma função pura existente autoriza DML.

**Gate antes da execução:** entregar e revisar um único runner conectado com esses limites, teste offline integrado sem Neon e proteção explícita contra retry; requer autorização nominal de DML em etapa distinta. Não reutilizar o workflow de smoke de leitura como writer. G2-P2-B permanece NO-GO.


### Revisão de desbloqueio G2-P2-B — decisão de prontidão (2026-10-28)

Revisão estática do commit `9003301c52c4705f9c893e2eaf8f93bc9606687a` e CI [40761371142](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40761371142) SUCCESS, sem DML conectado.

**Resultado: NOT READY para autorização de escrita ainda.** A integração `auth_pg_g2_p2b_connected_hold.py` é candidata e está deliberadamente bloqueada nas entradas pública e interna. O código existente documenta a coleta de evidências numa nova conexão em transação READ ONLY e a reconciliação estrita, mas não é executor operacional testado. Revisão identificou três lacunas concretas, a serem resolvidas **em um único pacote**, sem novos contratos puros:

1. **Gate executável e janela exclusiva:** um workflow manual de ensaio único, separado do smoke READ ONLY, deve verificar versão/branch, segredo efêmero, ausência/suspensão de writers externos confirmada operacionalmente e concorrência de workflow. Um parâmetro booleano ou `concurrency.group` isolados não asseguram exclusividade global.
2. **Caminho de commit e erros:** separar comprovadamente erros pré-commit com rollback de perda de confirmação do commit; preservar `INDETERMINATE_HOLD` em qualquer falha ambígua e proibir retries/limpeza automáticos. Não remover os HARD HOLDs até autorização nominal de escrita.
3. **Teste da integração efetiva:** os testes atuais demonstram bloqueio e contratos puros, não que a coleta pós-commit opere numa segunda conexão READ ONLY nem que o fluxo real siga a autorização. Testar offline o fluxo usando infraestrutura descartável, sem Neon, antes da habilitação nominal.

A autorização para preparar código não permite remover bloqueios, cadastrar segredos, executar o workflow de escrita ou alterar gates. Após resolver esses três itens, uma única aprovação nominal separada poderá ser apresentada. Marco B OPEN, G2-P2-B NO-GO, E9 NO-GO, Fase 5 NOT_STARTED.
