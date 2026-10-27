# Documento 319 — PF-I04-A2/P1: contrato de migrations e isolamento Django

**Data:** 2026-10-27. **Natureza:** P1 documental, sem operação conectada mutante e sem aceite de P3/P4.

## 1. Inventário verificável
- `applications/oes_web/requirements.txt`: `Django>=5.2,<5.3` e `psycopg[binary]>=3.2,<4`; não há versão patch imutável. Para SQL reprodutível, fixar versões instaladas e hashes de dependências antes de gerar `sqlmigrate`.
- `INSTALLED_APPS`: `django.contrib.auth`, `django.contrib.contenttypes`, `django.contrib.sessions`, `django.contrib.staticfiles`, `evidence`.
- `DATABASES={}` por padrão; opção PG-A4 somente leitura. Sem `default` operacional, não executar `migrate`.
- `OesEntity`, `OesQuestion`, versões e recibos possuem `managed=False` e não devem produzir DDL de domínio.
- Inventário Neon sintético não encontrou schema `oes_app` ou tabelas de autenticação Django; `core`, `investigation` e `public` existem. Q0 e recibos permanecem no domínio OES.

## 2. Conjunto candidato de migrations
- Para autenticação Django padrão, planejar `contenttypes`, `auth` e `sessions` e a tabela `django_migrations`. O estado de migrações poderá exigir dependências/transições da release Django efetivamente instalada.
- `staticfiles` não exige tabela própria para este objetivo; `evidence` não deve ser migrado como schema científico.
- A lista exata de arquivos, operações SQL, índices, constraints, sequences e permissões **não foi gerada neste P1**. Depende de fixação do ambiente Django, `showmigrations --plan` e `sqlmigrate` em ambiente isolado, com revisão específica para PostgreSQL. Não inventar SQL exato ou afirmar compatibilidade antes da verificação.

## 3. Contrato de namespace e conexão
- Nome aprovado arquiteturalmente: schema `oes_app`, banco `oes_sandbox`, branch sintética `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`.
- Nomes não qualificados das tabelas Django deverão resolver apenas ao schema de aplicação, por `search_path` seguro e testado. Evitar criar objetos Django em `public` ou `investigation`; validar resolução de nomes, extensões e migrations sob role controlada.
- Considerar o comportamento de `django_migrations` e das permissões automáticas `auth_permission`/`django_content_type`; escolher política de migrations administrativas distinta da conexão runtime.
- Django Auth `user.pk` é identificador de conta; `responsible_actor_id` do OES exige convenção estável, restrição de escopo e política de desativação/revogação antes do primeiro Q0.
- Não usar `oes_sandbox_owner` como login runtime, nem `oes_qprep_login` como role de migration. Diferimento das duas identidades independentes do piloto (Doc. 287) não implica privilégios de DDL para a aplicação.

## 4. Evidência exigida antes de P3
1. Versões exatas do runtime Python/Django/psycopg, hash de dependências, `showmigrations --plan` e SQL integral produzido pela versão escolhida, arquivados sem credenciais.
2. Revisão de pré-requisitos, localização de cada tabela e `django_migrations`, incluindo teste de `search_path` e ausência de conflitos em `public`.
3. Matriz nominativa de roles e GRANTs mínimos por schema/tabela/sequence; owner/migrator separado de runtime.
4. Testes negativos de permissão, sessões e revogação; procedimento de migração e recuperação com timeout e estado pós-commit verificável.
5. Autorização específica para DDL/migrations P3; depois autorização distinta para conexão privada Django e Q0 durável P4.

## 5. Estado e próximo passo
**P1 preparado documentalmente, não fechado como SQL reproduzível.** Próxima atividade proporcional: selecionar versão patch Django e produzir inventário local imutável `showmigrations --plan`/`sqlmigrate`, sem Neon; então consolidar SQL e grants candidatos para revisão. Nenhuma criação de schema, migração, role, login, segredo, sessão ou HTTP write foi autorizada ou executada.

CP314 canônico; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.
