# OES — PF-I04/P4-A24 | Revisão estática independente e gate READ ONLY candidato

**Data:** 2026-10-27. **Estado:** `STATIC_REVIEW_PASS_WITH_RESERVATIONS / FINAL_ACCEPTANCE_BLOCKED / NO_NEON_EXECUTION`. **Checkpoint:** CP322. **Freshness Gate:** GitHub `main` idêntico a `3186476599a750d5e9eaeb184b6b59f3c8af50a8` no início desta atividade.

## 1. Arquivos efetivamente inspecionados

- `/mnt/data/oes_p4_a23/OES_PF-I04_P4-A23_VERIFICADOR_PASS_HOLD_CANDIDATO.sql`, SHA-256 **`567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7`**.
- `/mnt/data/oes_p4_a23/OES_PF-I04_P4-A23_CONTRATO_VERIFICACAO.md`, SHA-256 **`735c8dc9d2211032074f147ecb3fcc54dd334ca9bee2ab177c40c36575bf5bf7`**.
- `/mnt/data/OES_PF-I04_P4-A23_VERIFICADOR_HOLD.zip`, integridade ZIP PASS, dois componentes idênticos aos arquivos avulsos.
- Contexto: CP322/STATE GitHub, parecer P4-A22 e transação P4-A21-HOLD para verificação de fronteiras.

## 2. Resultado técnico

1. Inspeção léxica/estrutural: a consulta SQL contém um único terminador de comando `;`, parênteses equilibrados, não contém operações mutantes executáveis após filtragem de comentários e literais; formato `WITH ... SELECT` de leitura catalogal. **Não equivale a parsing PostgreSQL 18**.
2. O contrato compara direitos efetivos individuais de tabelas (oito operações), colunas (quatro), sequências (três), e concedentes de ACLs diretas para runtime em tabelas, colunas, sequências e schemas. Também verifica inventários, papéis, associação original e resumo `PASS/HOLD`.
3. `has_column_privilege` considera privilégios da tabela e privilégios da coluna: ambas as camadas são inspecionadas. Chamadas por privilégio individual evitam o erro `any-of` identificado em P4-A20.
4. O resultado de referência **antes** do Bloco A é `HOLD`, porque faltam as concessões Django pretendidas. Uma execução que produza `HOLD` por ausências esperadas confirma apenas a avaliação parcial do checker; não demonstra completude, atomicidade, segurança do futuro script mutante ou capacidade de login.

## 3. Apontamentos

### A24-R01 — bloqueante para aceitação FINAL: ACLs de PUBLIC e terceiros não são integralmente comparadas
As CTEs `actual_table_acl`, `actual_column_acl`, `actual_schema_acl` e `actual_sequence_acl` filtram `acl.grantee=ids.runtime_oid`. Não auditam diretamente as concessões para `PUBLIC` (`grantee=0`) ou a outros beneficiários. Se a tabela `oes_app.auth_user` tiver SELECT direto esperado para runtime e alguém também conceder SELECT a PUBLIC, `has_table_privilege(runtime, auth_user, SELECT)` permanece true e os ACLs diretos do runtime permanecem idênticos ao esperado; o status pode ser PASS, apesar da exposição adicional a PUBLIC. O mesmo vale para USAGE de `oes_app` e outros privilégios positivos esperados. O texto A23 de que diferenças de PUBLIC sempre provocam HOLD deve ser restringido. Uma extensão de escopo deverá adotar baseline explícita para concessões a PUBLIC (e, se requerido, para outros beneficiários) sem revogações genéricas.

### A24-R02 — importante: amplitude/fidelidade do catálogo de colunas
O verificador percorre todas as colunas existentes para direitos, mas só exige a existência nominal de `auth_user.last_login` e `auth_user.password`. Se uma coluna nova surgir em tabela com SELECT integral esperado, a permissão de leitura implícita será aceita sem comparação contra um inventário fechado de colunas. Definir se o contrato exige congelamento de DDL/colunas ou verificação de hash do schema; manter critério proporcional.

### A24-R03 — importante: cobertura do universo declarado
Há inspeção nominal de nove tabelas e oito sequências Django no schema `oes_app`, e cinco tabelas Q0; objetos fora do universo não são inventariados de forma geral. O contrato não avalia DEFAULT PRIVILEGES, funções, RLS, triggers, TEMPORARY nem outros schemas, e NÃO pode declarar ausência de qualquer outro acesso no banco. Registrar essas exclusões na eventual decisão.

### A24-R04 — operacional: saída potencialmente grande
O SELECT retorna `SUMMARY` e uma linha por verificação de coluna/tabela/ACL. O canal conectado deve preservar e conferir a primeira linha SUMMARY, a contagem total e linhas de divergência; saída truncada/incompleta é `HOLD`. Em eventual revisão, pode-se produzir consulta compacta (`SUMMARY + mismatches`) sem remover a auditoria interna integral, mas isso exige um novo SHA e novo gate.

### A24-R05 — bloqueante até validação de parser/conexão
Nenhum servidor/cliente/parser PostgreSQL 18 foi utilizado para executar a consulta. Uma futura consulta READ ONLY, se aprovada, pode demonstrar aceitabilidade sintática e retornar baseline esperada `HOLD`, mas não pode demonstrar o `PASS` após Bloco A até que este seja separadamente autorizado e efetivado.

### A24-R06 — limite da estratégia administrativa
O checker pós-Bloco A não constitui prova da transação, do comportamento de `SET LOCAL ROLE`, revogação grantor-aware, indivisibilidade do canal, rollback ou integridade dos privilégios de terceiros. Essas provas demandam gates separados, após correção de A24-R01.

## 4. Gate READ ONLY candidato (não autorizado neste documento)

**Propósito estrito:** validar o parsing e a execução catalogal da versão A23 **exatamente identificada pelo SHA** no ambiente PostgreSQL 18 do Neon e conferir o comportamento atual `HOLD` **pré-Bloco A**, sem tratar esse resultado como aprovação operacional.

**Alvo:** projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, executor `oes_sandbox_owner`.

**Escopo:** uma execução de um único SELECT `WITH ... SELECT` do arquivo `OES_PF-I04_P4-A23_VERIFICADOR_PASS_HOLD_CANDIDATO.sql`, SHA-256 `567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7`, apenas pg_catalog/funções de privilégio; sem leitura de dados de usuários/sessões/Q0; sem papéis/grants/SET ROLE/DML/DDL; sem credenciais, Django, HTTP, deploy, serviços pagos. Interrupção/erro/resultado incompleto => HOLD. Executar somente após autorização nominal.

**Esperado:** consulta sintaticamente aceita; `SUMMARY/HOLD` por privilégios Django não concedidos, mais divergências identificadas. Um inesperado PASS em baseline atual é HOLD para investigação. Nenhum resultado autoriza mutação.

**Texto exato de autorização candidata:**

`APPROVED — OES / PF-I04/P4-A25 / SINGLE_A23_VERIFIER_BASELINE_CATALOG_READ_ONLY / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / executor oes_sandbox_owner / exactly one reviewed WITH SELECT from A23 SHA256 567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7 / pg_catalog and privilege functions only / expected pre-grant HOLD / no Django or Q0 data reads / no SET ROLE / no GRANT or REVOKE / no DDL or DML / no role or membership changes / no credentials / no Django connection / no HTTP or deploy / no paid services / fail closed`

## 5. Encaminhamento

- **P4-A24 concluída documentalmente.** SQL A23 **pode ser objeto de teste READ ONLY** com autorização, mas **não** pode ser o verificador único de aceitação final até tratamento de A24-R01.
- Priorizar próximo checkpoint CP323, incluindo P4-A21 a P4-A24, o pacote A23 e este parecer, antes de executar teste conectado.
- O script de concessão de P4-A21 permanece `HOLD`. Gates globais permanecem: Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY, Fase 5 NOT_STARTED, Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED, nenhum pesquisador vinculado.

## 6. Referências

- https://www.postgresql.org/docs/18/functions-info.html
- https://www.postgresql.org/docs/18/ddl-priv.html

**Sem alterações no GitHub ou no Neon nesta atividade.**
