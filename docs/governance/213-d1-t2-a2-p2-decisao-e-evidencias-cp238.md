# Documento 213 — D1/T2-A2: decisão e evidências PostgreSQL P2 (CP238)

**OES | 2026-10-22 | A2-G2/P2_COMPLETED_WITH_SECURITY_FINDINGS | A2-G2/E NOT_AUTHORIZED | T2-A2 NOT_AUTHORIZED**

## 1. Autorização, ambiente e alcance
O proprietário aprovou expressamente: `APPROVED — OES / D1-T2-A2 / A2-G2-P2 / PG_CATALOG_READ_ONLY_PREFLIGHT`. O Freshness Gate da execução confirmou o HEAD `cf128909a65caca67b0d3cb0f9a4ce301e0b2ae5`, CP237, comparação `identical`. A execução usou exclusivamente `mcp__Neon__run_sql_transaction`, projeto `tiny-pond-20086371`, branch `br-divine-grass-b63wlpcb`, banco `oes_t2a2_synthetic`, **role_name explícito `oes_t2a2_app`**. Não houve fallback de identidade, conexão como `oes_t2a2_runtime` ou outros comandos não autorizados.

Na mesma transação: `SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY`, `SET LOCAL statement_timeout='5s'`, `SET LOCAL lock_timeout='1s'`, seguidos das sete consultas Q01–Q07 literalmente delimitadas na avaliação A2 pós-CP237: identidade, namespace, objetos de catálogo, banco/permissões, atributos de roles, memberships transitivas e ACL/default privileges. As três instruções SET retornaram zero linhas, como esperado, e as sete SELECTs retornaram resultados estruturados. **Não houve DDL, DML, GRANT, REVOKE, ALTER ROLE, acesso a registros de aplicação, CI ou mudanças administrativas.** Esta publicação não repete nem executa SQL.

## 2. Evidências minimizadas

| Verificação | Evidência obtida | Classificação |
|---|---|---|
| Q01 | Banco correto; session_user=current_user=`oes_t2a2_app`; `transaction_read_only=on`, isolamento `repeatable read`, timeouts 5s/1s | PASS |
| Q02 | 0 linhas para `oes_t2a2_proto` | PASS: namespace ausente na visão consultada |
| Q03 | 0 objetos no namespace (`pg_class`, `pg_proc`, `pg_type`) | PASS no escopo |
| Q04 | Database owner `oes_t2a2_owner`; CREATE efetivo owner=true; app=false; ambos CONNECT/TEMP=true | PASS para constatação; atenção ao poder administrativo |
| Q05 | `oes_t2a2_app`: LOGIN=true, superuser/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS/INHERIT=false. `oes_t2a2_owner` e `oes_t2a2_runtime`: LOGIN, CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS, INHERIT=true; superuser=false | SECURITY FINDING |
| Q06 | 28 caminhos de associação, incluindo `neon_superuser` nos dois papéis administrativos; `oes_t2a2_app` sem associação de saída a outros papéis no escopo observado | SECURITY FINDING / PASS de completude limitada |
| Q07 | 1 registro de banco; `PUBLIC`: CREATE=false e CONNECT=true. ACL explícita `{=Tc/oes_t2a2_owner,oes_t2a2_owner=CTc/oes_t2a2_owner,neon_superuser=CTc/oes_t2a2_owner}`; nenhuma entrada de `pg_default_acl` para papéis e namespaces selecionados | PASS delimitado, não auditoria global |

A string de ACL indica TEMP concedido a `PUBLIC`. A ausência de linhas para `pg_default_acl` não elimina privilégios padrão intrínsecos do PostgreSQL. Em Q06, consulta com profundidade limite 8 e teto 51 não atingiu o teto de linhas (28), mas isso, isoladamente, não demonstra inexistência de caminhos mais profundos: **completude transitive estrita permanece condicionada ao limite de profundidade**. Não declarar auditadas todas as permissões possíveis. Nenhum segredo ou credential foi documentado.

## 3. Achados, interpretação e limitações
**S01 — ADMINISTRATIVE_PRIVILEGE_CONCENTRATION:** `oes_t2a2_owner` possui capacidade CREATE no banco, mas também CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS e membership herdada em `neon_superuser`. O papel legado `oes_t2a2_runtime` apresenta atribuições administrativas semelhantes, deve continuar **PROIBIDO** em operações. O papel app é adequado para inspeção de catálogo no escopo, mas não para DDL. Um eventual executor da criação estrutural terá privilégios superiores ao necessário, exigindo SQL fechada, avaliação de risco e autorização autônoma — sem presumir que P2 tenha liberado DDL.

**S02 — PUBLIC CONNECT/TEMP:** a ACL do banco permite CONNECT/TEMP a `PUBLIC`, não CREATE. Isso não representa autenticação anônima, mas requer consideração de exposição de rede, papéis e política de acessos. Não alterar ACL sem aprovação independente.

**S03 — NAMESPACE ABSENT:** não foi observado schema `oes_t2a2_proto` nem objetos nele na visão Q02–Q03. Criar schema/tabelas vazias exigirá aprovação independente A2-G2/E, DDL literal com proprietário efetivo previamente identificado, e plano de interrupção/rollback. O resultado não autoriza reutilização de objetos preexistentes se estado mudar.

**S04 — TLS AND TOOL LIMIT:** a interface `run_sql_transaction` não expõe explicitamente parâmetros `sslmode`; N1-E3 demonstrou TLS do cliente Psycopg em execução anterior e observação `pg_stat_ssl.ssl=false` no backend. Não declarar TLS end-to-end nem aplicar a evidência de outra conexão sem ressalva.

**S05 — READ_ONLY_TRANSACTION:** Q01 comprovou apenas o estado transacional e identidade observados. Não se alega imutabilidade absoluta do serviço, faturamento zero em todas as situações ou integridade lógica de futuras tabelas.

Documento 211 prevalece financeiramente: Free já autorizado, sem aprovação por GET, chamada ou CU-hora dentro das quotas, mas **sem upgrade, cartão, serviço pago ou contratação sem autorização expressa**.

## 4. Matriz PF atualizada e gates

| PF | Parecer atualizado |
|---|---|
| PF-01 | PASS CP237 e autorização expressa P2 |
| PF-02 | PASS: projeto/branch/banco delimitados |
| PF-03 | PARTIAL: metadados P1 e política Free; billing completo não revalidado |
| PF-04 | OBSERVED: branch e endpoint P1; exposição administrativa registrada |
| PF-05 | PASS: namespace e objetos candidatos ausentes |
| PF-06 | PASS factual CREATE owner/app; ressalva de privilégios elevados |
| PF-07 | PASS restrito de ACL/membership; adequação completa ainda sujeita a limites |
| PF-08 | PARTIAL: TLS da ferramenta P2 não comprovado por configuração explícita |
| PF-09 | PARTIAL: sem colisão; plano de reversão para E pendente |
| PF-10 | PASS restrito: projeto/banco corretos, sem acesso a registros e sem writes observados |

A2-G1 `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED`, P1 `COMPLETED_WITH_LIMITATIONS`, P2 `COMPLETED_WITH_SECURITY_FINDINGS`, **A2-G2/E `NOT_AUTHORIZED`**, A2-G3–G5 e T2-A2 `NOT_AUTHORIZED`. F01–F07 somente endereçados documentalmente, L1–L4 ainda condicionantes, O-01–O-10 não executados. T1 36 PASS e T2-A1 75 PASS somente históricos. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`. `oes-sandbox` intocado.

**Próximo `Prossiga`:** preparação documental pontual da decisão A2-G2/E, com DDL literal mínima para namespace `oes_t2a2_proto` e tabelas vazias `scenario`, `event`, `receipt`; limitar poderes efetivos da execução e documentar rollback, sem executar Neon/DDL/SQL/CI antes de autorização expressa. **STOP.**
