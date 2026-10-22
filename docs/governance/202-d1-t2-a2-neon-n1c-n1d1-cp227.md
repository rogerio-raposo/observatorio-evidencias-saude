# Documento 202 — CP227: achados de segurança N1-C/N1-D1 no Neon sintético

**2026-10-21 | DOCUMENTARY_SECURITY_FINDINGS | N1-D2 NOT_APPROVED | T2-A2 NOT_AUTHORIZED**

## 1. Evidências e fronteira
Após CP226 houve cinco atividades delimitadas: matriz de permissões e proposta N1-C; execução autorizada de N1-C; interpretação documental do TLS; proposta N1-D1; execução expressamente autorizada N1-D1. As consultas ocorreram exclusivamente no projeto Neon Free `oes-d1-t2-a2-synthetic` (ID `tiny-pond-20086371`), branch `synthetic-main` (ID `br-divine-grass-b63wlpcb`), banco `oes_t2a2_synthetic`, papel `oes_t2a2_runtime`. Sem DDL, DML, GRANT, REVOKE, instalação, obtenção de segredo ou alteração de rede.

## 2. N1-C: leitura da sessão
Uma consulta de metadados retornou banco e papel corretos; versão PostgreSQL 18.6; `pg_stat_ssl.ssl=false` na sessão observada; `has_database_privilege(...,'CREATE')=true`, TEMP=true, CREATE no schema `public`=false, USAGE=true. O valor de `pg_stat_ssl` **não prova ausência de TLS no trajeto externo do plugin**: eventual terminação intermediária permanece hipótese não verificada. Não declarar conexão TLS do adaptador comprovada. A interface `run_sql` do plugin não expõe parâmetro `sslmode`.

## 3. N1-D1: privilégios do runtime
Uma consulta somente de leitura a catálogos PostgreSQL retornou para `oes_t2a2_runtime`: `rolsuper=false`, **`rolcreatedb=true`**, **`rolcreaterole=true`**, `rolinherit=true`. Associação direta a **`neon_superuser`**, com `inherit_option=true`, `set_option=true` e `admin_option=false`. CREATE efetivo no banco=true; no schema `public`=false. No banco, ACL listada concede CONNECT/TEMP a PUBLIC, e CREATE ao owner e a neon_superuser; não há CREATE explícito direto ao runtime na lista consultada. **A atribuição do CREATE efetivo à associação com neon_superuser é uma explicação consistente, não uma análise exaustiva de todos os caminhos.** A identidade runtime **não atende ao menor privilégio**.

## 4. Restrição imediata
Não utilizar `oes_t2a2_runtime` para o adaptador ou testes de escrita antes de corrigir e verificar privilégios. Não executar SQL de alteração de roles, grants ou mudanças de rede sem nova autorização concreta. N1-D2 **não aprovado** e N1-E de conexão TLS direta **não aprovado**. O projeto original `oes-sandbox` não foi modificado.

## 5. Deliberação futura
Preparar proposta N1-D2 com operações PostgreSQL precisas e pós-condições verificáveis: revisar alteração de atributos administrativos `CREATEDB`/`CREATEROLE`, remoção de membership `neon_superuser`, avaliar concessões por PUBLIC e heranças restantes, validar que o papel não consegue criar banco, papel ou schema nem assumir papéis elevados; documentar rollback restrito e avaliar suporte pelo Neon antes da execução. Evitar afetar `oes_t2a2_owner` e outros projetos. Separadamente autorizar N1-E (conexão direta Psycopg com `sslmode=verify-full`), sem expor segredo.

## 6. Preservação
T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 testes históricos); T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (75 históricos); T2-A2 `NOT_AUTHORIZED`. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrations `UNREVIEWED`; requisitos/roles/BRGs e gates inalterados. Nenhuma promoção científica ou operacional.

**STOP.**
