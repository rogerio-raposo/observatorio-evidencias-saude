# OES — PF-I04/P4-A26 | Correção documental do verificador v3

**Data:** 2026-10-27. **Estado:** `A25_EXECUTION_FAILED / A26_STATIC_PATCH_PREPARED / NO_NEON_EXECUTION / OPERATIONAL_HOLD`.
**Checkpoint de referência:** CP323. **Conexão Neon:** não realizada em P4-A26.

## 1. Origem e integridade
- Arquivo preservado A23: `archive/handoffs/oes/artifacts/CP323/OES_PF-I04_P4-A23_VERIFICADOR_PASS_HOLD_CANDIDATO.sql`.
- SHA-256 A23: `567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7`.
- Novo arquivo A26: `OES_PF-I04_P4-A26_VERIFICADOR_V3_PUBLIC_ACL_HOLD.sql`.
- SHA-256 A26: `136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a`. **Nova versão distinta: a aprovação P4-A25 não se aplica a este arquivo.**
- GitHub main CP323 verificado antes da elaboração, sem alterações.

## 2. Falha de P4-A25
Uma e somente uma consulta A23 foi submetida no Neon sintético, mas falhou com `ACL arrays must be one-dimensional`, sem produzir SUMMARY/PASS/HOLD. Nenhum segundo ensaio autorizado. Diagnóstico provável: `aclexplode(coalesce(a.attacl,'{}'::aclitem[]))` em `attacl` nulo, produzindo array vazio sem dimensão válida. Em PostgreSQL, arrays ACL devem ser unidimensionais; `aclexplode` recebe NULL em vez de `{}` quando a ACL está ausente ou vazia. **Causa específica ainda não comprovada por execução isolada**.

## 3. Alterações v3
1. Substituídos os quatro pontos de `aclexplode(...)` da versão A23 por `CASE WHEN cardinality(ACL) > 0 THEN ACL ELSE NULL::aclitem[] END`. Isso evita a passagem de arrays explicitamente vazios (zero dimensões) em tabelas, colunas, schemas ou sequências. ACLs válidos não vazios continuam sendo examinados; estruturas inválidas não passam silenciosamente. Nenhuma leitura de registros de aplicação.
2. Adicionada CTE `actual_public_acl` auditando explicitamente `grantee=0` (= PUBLIC), sobre os schemas `oes_app`, `core` e `investigation`, as 14 tabelas escopadas e suas colunas, e as oito sequências Django. O schema `public` **não** entram na regra negativa por causa do USAGE preexistente; isso não implica concessão nova.
3. Adicionados `public_acl_count` e linhas individuais `public_acl`; qualquer concessão explícita a PUBLIC no universo restringido retorna `HOLD`, mesmo quando o privilégio direto esperado de `oes_runtime` também existe.
4. Mantidos testes positivos/negativos de runtime, associação original `155649`, ACLs diretas, propriedade e resumo. Antes do Bloco A, espera-se HOLD por ausências de GRANTs Django; esse resultado ainda não foi obtido no PostgreSQL.

## 4. Limites e riscos
- **Verificação apenas estática:** nenhum parser/servidor PostgreSQL 18 foi usado; sintaxe, semântica e completude carecem de validação conectada separada. Qualquer erro SQL ou saída truncada = HOLD.
- Expectativa "zero ACL para PUBLIC" é uma **nova política candidata fail-closed para objetos explicitamente inspecionados**. Se a baseline catalogal tiver concessões históricas a PUBLIC, o resultado correto será HOLD para revisão, **nunca REVOKE automático**.
- A regra não audita integralmente grants de terceiros (diferentes de PUBLIC e runtime), DEFAULT PRIVILEGES, DATABASE/TEMPORARY, funções, RLS, triggers, esquemas não nomeados nem inventário fechado de colunas; mantém apontamentos A24-R02–R06.
- A matriz final não poderá ser declarada PASS operacional apenas com essa consulta. Evidência de transação, atomicidade, rollback, grantor-aware cleanup e ensaio Django segue bloqueada.
- O script transacional de P4-A21 contém HOLD incondicional e **não é autorizado para execução**; a v3 é **somente verificador SELECT**.

## 5. Próximo gate candidato
PF-I04/P4-A27, exclusivamente se houver aprovação nominal específica, poderá testar **uma** execução READ ONLY da v3 com SHA acima, projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, executor `oes_sandbox_owner`, sem dados Django/Q0, sem GRANT/REVOKE/SET ROLE/DDL/DML, sem credenciais/HTTP/deploy, fail closed. Isso verificaria parsing e erro A25, mas não autoriza escrita.

**STOP.** P4-A26 apenas documental; registrar nos próximos checkpoints, sem substituir o CP323 até publicação proporcional.
