# Documento 360 — PF-I04-A2/P3: pacote técnico candidato de migração Django (NÃO EXECUTAR)

**Data:** 2026-10-27. **Status:** PREPARED_FOR_REVIEW / P3_NOT_AUTHORIZED. **Base:** CP315, Docs. 317–319 e 330 (PF-I04), CI 40541606299.

## 1. Destino e escopo fechado
Projeto Neon `weathered-boat-65779510`; branch **sintética** `br-gentle-hall-b6jaxehf`; database `oes_sandbox`. A alternativa B foi aprovada **arquiteturalmente**: schema `oes_app` apenas para Django `auth`, `contenttypes`, `sessions` e registro `django_migrations`. Não alterar `production`, schemas `core`/`investigation`, dados científicos, roles preexistentes nem acesso público.

## 2. Evidência reproduzível e limite
Django 5.2.18, Python 3.12, psycopg 3.3.6; CI 40541606299 PASS com 15 migrations, 9 tabelas, 8 sequências e 40 linhas `auth_permission` em PostgreSQL 16 descartável, sem objetos Django em `public`. A CI **não testou** privilégios separados do migrador/runtime, ambiente Neon, recuperação nem execução do schema com ownership diferente.

## 3. SQL preparatório candidato — NÃO AUTORIZADO
A única operação estrutural preliminar candidata é criar um namespace isolado. O SQL abaixo é **ilustrativo**, não um pacote fechado executável, pois o proprietário e o papel migrador ainda precisam ser definidos e aprovados. Não usar com role runtime.

```sql
-- CANDIDATO DOCUMENTAL. NÃO EXECUTAR.
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '10s';
-- Pré-condição externa: destino, current_user, ausência de oes_app e autorização conferidos.
CREATE SCHEMA oes_app;
-- Ownership e ACL devem ser explicitamente definidos antes de aprovar este SQL.
COMMIT;
```

Este bloco **não constitui todo o P3**: as 15 migrations precisam ser executadas pelo executor Django (não concatenar `sqlmigrate`), sob conexão localmente testada com `search_path` controlado. RunPython, `django_migrations`, permissões de post_migrate e dependências devem ser incluídos na verificação.

## 4. Matriz candidata de capacidades
| Ator | Privilégios positivos propostos | Negativos obrigatórios |
|---|---|---|
| Migrador transitório (a designar) | CREATE no namespace administrativo sob controle e propriedade dos objetos Django; operar `migrate` somente na janela | Não reutilizar como runtime; nenhum acesso a raw privado ou alteração científica |
| Runtime Django (a designar) | CONNECT, USAGE em `oes_app`, DML estritamente necessário para `auth_user`, `auth_group`, `auth_permission`, contenttypes e sessions e USAGE de sequências usadas; direitos de Q0 só com aprovação separada | Sem CREATE/ALTER/DROP, sem owner, sem CREATE em public, sem leitura indiscriminada de schemas científicos |
| `oes_qprep_login` | Nenhuma ampliação automática | Não migrador; não assumir que representa usuário Django |
| `oes_pg_a4_reader` | Permanecer leitor experimental | Não writer |

**Não gerar GRANTs finais antes de confirmar ownership, role destinatária, acesso efetivo já herdado, sequência de post_migrate e mínimos demonstrados.** Um login de aplicação do piloto pode ser único para runtime (Doc. 287); autoridade administrativa de migração permanece distinta.

## 5. Preflight nominal necessário
Executar **somente após autorização específica de consulta**:
- confirmar `current_database()`, `current_user`, branch e endpoint por canal administrativo;
- listar `pg_namespace` (ausência `oes_app`), owners e privilégios relevantes; inspecionar conflitos `auth_*`, `django_*` em schemas existentes;
- conferir `search_path` e resolução de objetos, `CREATE` em database/public, schemas e extensões; verificar transações, lock_timeout/statement_timeout, backups e janela de execução;
- sem leitura de `auth_user`, de senhas, payloads privados, dados de pesquisadores ou textos científicos.

## 6. Execução futura em etapas independentes
**P3a** (aprovação nominal): schema, ownership e ACL exatos; preflight/postflight. **P3b** (outra aprovação): migrations Django 5.2.18 com ambiente imutável, `search_path` revisado e inspeção de todos os objetos e 15 registros do histórico. Separar atos facilita HOLD e auditoria; não presumir rollback automático após commits anteriores. **P4** requer aprovação adicional para conexão Django runtime, gestão de contas/sessões e primeiro Q0 persistente.

## 7. Verificações pós-execução e recuperação
Confirmar 15 migrations, 9 tabelas, 8 sequências, permissões geradas e **nenhum objeto Django no schema public**; inspecionar metadata de ownership e grants e fazer testes negativos com papel runtime, sem ler dados sensíveis. Em falha de execução ou resultado de COMMIT incerto: HOLD, inspeção somente leitura, sem retry automático. Remover schema apenas com autorização posterior e comprovação de ausência de dados úteis/contas; não prescrever `DROP SCHEMA ... CASCADE` como rollback automático.

## 8. Situação decisória
**P3 NÃO AUTORIZADO.** Este documento não altera gate G2-P2B, E9 ou readiness. Próxima ação: resolver nomes/ownership e privilégios concretos, reproduzir migração sob papéis separados em ambiente descartável e então submeter SQL e autorização P3a nominal. CP315 vigente; Marco B OPEN; Fase 5 NOT_STARTED.

## 9. Evidência posterior de privilégios por tabela (2026-10-27)
- [GitHub Actions 40547999201](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40547999201), commit `f08f1527446cf48817a05e3329fd965e72837564`: 15/15 migrations e separação de papéis PASS, mas grants ainda amplos sobre todas as tabelas no teste inicial.
- [GitHub Actions 40548763947](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40548763947), commit `4b7e60ed7e0c6822911bd29c006fb2ede3f6b65d`: `ROLE AUDIT PASS: per-table grants; runtime DDL and privileged writes denied`. Verificadas recusas efetivas de CREATE em `oes_app`, INSERT/SELECT em `django_migrations` e UPDATE em `auth_permission`; sequências verificadas. Banco descartável, **nenhum acesso Neon**.
- Esta matriz é **experimental**, não prova autenticação Django e sessões ponta a ponta com usuário runtime. Em particular, o controle de `django_migrations` só cabe ao migrador; concessões runtime dependem de requisitos funcionais explícitos. Evitar novos testes isolados sem cenário funcional novo.

## 10. Minuta de autorização P3a — NÃO APROVADA
**Objeto estrito proposto:** exclusivamente criar namespace `oes_app` no projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, com dono/migrador e ACL definidos em SQL integral previamente revisado. Proibidos migrations, criação de tabelas Django, DML, HTTP, contas Django, alteração de papéis legados, senha/segredo, produção, custo pago, E9 e P4.

**Condições ainda pendentes, antes de solicitar aprovação:** (i) seleção formal do dono existente e identificação do executor, evitando criar role desnecessária; (ii) SQL exato, sem placeholder, incluindo owner e ACL, com rollback/recuperação pós-COMMIT; (iii) preflight read-only atual e confronto de HEAD/destino/ausência do schema; (iv) prova de que a ferramenta de execução não alterará branch de produção; (v) postflight específico e STOP para resultados inconclusivos. **Não presumir que a presente minuta é autorização.**

**Modelo de pedido futuro (não acionável neste estado):** `APPROVED — OES / PF-I04-A2 / P3a_SCHEMA_ONLY / [target e SQL exatos auditados] / PRE_POST_READ_ONLY / no migrations / no DML / no application login / no roles or grants outside approved SQL / no HTTP / no paid services / fail closed`.

**Decisão atual:** P3a `HOLD_PENDING_EXACT_SQL_AND_OWNER`; P3b e P4 permanecem não autorizados; CP315 vigente.
