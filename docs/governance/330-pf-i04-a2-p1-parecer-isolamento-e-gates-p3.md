# OES — PF-I04-A2/P1 | Parecer de isolamento e pacote P3 candidato
**Data:** 2026-10-27. **Status:** PREPARED_NOT_AUTHORIZED. **Natureza:** apenas governança e desenho, sem DDL no Neon.

## Evidência nova
- [GitHub Actions 40541606299](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40541606299), commit `a5cf31ab4652c5c6a93d09338732517d6b62caec`, `completed/success`; PostgreSQL 16 **descartável**, Django 5.2.18, 15/15 migrations `contenttypes`, `auth`, `sessions` aplicadas, 40 permissões criadas, `ISOLATION PASS`.
- Inventário do teste: 9 tabelas e 8 sequências no schema local `oes_app`, incluindo `django_migrations`, `auth_user`, associações, `django_content_type` e `django_session`; **zero objetos Django em public** segundo a consulta automatizada. O teste não avaliou grants mínimos, propriedade, restore ou deploy.
- CI 40540685917 criou 15 prévias `sqlmigrate` no PostgreSQL local, artefato 12750596954; nomes de tabela não qualificados exigem `search_path` controlado. `RunPython` e `post_migrate` não se reproduzem integralmente por arquivos individuais.

## Arquitetura já aprovada pelo responsável
Alternativa B: manter autenticação, permissões e sessões Django em schema `oes_app` de `oes_sandbox` na branch sintética `br-gentle-hall-b6jaxehf` do projeto `weathered-boat-65779510`; entidades OES continuam em `core` e `investigation`. Esta é **decisão arquitetural**, não autorização para mutação do Neon.

## Matriz de privilégios para revisão
| Função | Necessidade candidata | Vedação |
|---|---|---|
| Administrador de schema/migrador transitório | Autoridade delimitada para criar `oes_app`, objetos Django e registrar migrations, em janela autorizada | Não é identidade runtime; não atribuir CREATE geral perpetuamente |
| Django runtime | CONNECT no banco, USAGE no `oes_app`, operações indispensáveis sobre tabelas e sequências administrativas; somente direitos Q0 necessários em `core`/`investigation`, a definir por tabela | Sem DDL, superuser, owner, CREATE em public ou acesso a raw privado |
| Leitor experimental PG-A4 | Manter read-only e isolado | Não converter em writer |
| `oes_qprep_login` experimental | Não ampliar automaticamente | Não usar como migrador |

**Atenção:** permissões exatas dependem de comandos Django efetivos, ownership, sequences, gatilhos, default privileges e testes negativos de REVOKE. Nenhuma instrução GRANT/REVOKE foi aprovada ou executada. Evitar suposições sobre o papel `public` ou sobre `search_path` em sessões reais.

## Pré-requisitos bloqueantes de P3
1. Inspeção catalogal read-only atualizada de schema `oes_app`, owners, permissões efetivas, `search_path`, extensions, `django_migrations` e conflitos; confirmar projeto, branch, banco, role e janela.
2. SQL exato versionado e revisado para criação do schema, definição de owner e privilégios; migrations sob Django 5.2.18 e Python 3.12 com dependências fixadas. Garantir que `evidence` unmanaged não gere DDL científico.
3. Estratégia de separação migrador/runtime, gestão e revogação de credenciais, TLS, logs sem payloads e recuperação após commit. Backups e custo confirmados.
4. Comportamento fail-closed, preflight/postflight independentes, plano de recuperação, critérios de STOP e teste de ausência de objetos Django em `public`.
5. Aprovação explícita e específica do proprietário para P3 DDL/migrations e quaisquer privilégios; autorização distinta para conectar runtime, criar contas e persistir Q0 (P4).

**Conclusão:** P1 prova viabilidade de isolamento em PostgreSQL local. **P3 NÃO AUTORIZADO.** Nenhum SQL/DDL/DML, grants, secrets, criação de usuário ou HTTP write no Neon nesta atividade. CP315 vigora após publicação; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; Fase 5 NOT_STARTED.
