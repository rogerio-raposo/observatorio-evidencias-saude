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

**Explicitamente fora do escopo:** criação de database/schema, SQL DDL/DML, grants, secrets, migrations Neon, workflow conectado, deploy, custos pagos, Q1, E9.

**Estado de governança:** Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.
