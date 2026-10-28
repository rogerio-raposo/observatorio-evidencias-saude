# OES — PF-I04/P4-A27 | Revisão independente do verificador v3 e gate READ ONLY

**Data:** 2026-10-27. **Estado:** `STATIC_REVIEW_PASS_WITH_RESERVATIONS / CONNECTED_VALIDATION_NOT_AUTHORIZED / OPERATIONAL_HOLD`. **Checkpoint:** CP323. GitHub main no HEAD `14bec7c4534dac21448eeab25b53476ed854b319` — Freshness Gate `identical`.

## Artefatos e integridade
- Original: `OES_PF-I04_P4-A26_VERIFICADOR_V3_PUBLIC_ACL_HOLD.sql` (429 linhas).
- SHA-256: `136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a`.
- ZIP `OES_PF-I04_P4-A26_VERIFICADOR_V3_HOLD.zip`: `testzip()` sem erro; membro SQL byte a byte idêntico ao original.
- Nota: `OES_PF-I04_P4-A26_NOTA_DE_CORRECAO_E_LIMITES.md`.
- Source não persistido no GitHub nesta atividade; somente material de revisão local. Não executar diretamente arquivo não autorizado.

## Revisão estática
1. Exatamente um comando catalogal `WITH ... SELECT` com término `ORDER BY sort_order,check_group,subject;`; nenhum GRANT, REVOKE, SET ROLE, DDL ou DML executável identificado. Essa é verificação estrutural, não parsing PostgreSQL 18.
2. Os pontos de `aclexplode` nos catálogos de tabelas, sequências, schemas e colunas usam `CASE WHEN cardinality(...) > 0 THEN ... ELSE NULL::aclitem[] END`, evitando passar arrays ACL vazios com zero dimensões à função. Isso trata a causa provável de `ACL arrays must be one-dimensional` de P4-A25. **A eliminação efetiva do erro ainda não foi testada**.
3. Adicionada CTE `actual_public_acl` para grantee 0 (`PUBLIC`) nos schemas `oes_app`, `core`, `investigation`, 14 tabelas escopadas e suas colunas, 8 sequências Django; schema `public` excluído intencionalmente. Resumo inclui `public_acl_count` e linhas de discrepância.
4. Mantidas verificações de privilégios individuais por tabela/coluna, inventário nominal, relação OID `155649` `cloud_admin`, owner/migrador/runtime, grantor e grant options diretas ao runtime. Resumo `SUMMARY/PASS-HOLD` e divergências.
5. A regra **zero ACL PUBLIC** nos objetos escopados é proposta conservadora *nova*, não um baseline historicamente comprovado. Concessões históricas a PUBLIC devem levar a HOLD e investigação, jamais revogação automática. O verificador não audita todos os terceiros, default privileges, funções, triggers, RLS ou todos os schemas/colunas possíveis: não constitui prova geral de isolamento.
6. Uma consulta de 429 linhas pode produzir muitas linhas de resposta. Exigir resumo, contagem e cobertura das divergências; erro, resposta truncada/incompleta ou unexpected PASS pré-GRANT = HOLD. Não alterar/compactar o SQL sob o mesmo SHA.
7. Não houve parse de SQL nem consulta no PostgreSQL 18 ou Neon; não houve autorização ou execução de GRANT/REVOKE/SET ROLE. Transação administrativa P4-A21 continua sob trava HOLD e não foi ensaiada.

## Decisão
`P4-A27 STATIC REVIEW PASS WITH RESERVATIONS`: liberar apenas a **solicitação de autorização nominal** para executar **uma única vez** o SELECT v3 exato em conexão catalogal do owner e avaliar erro de P4-A25 e baseline pré-GRANT. Não é aceite funcional, científico ou de segurança da aplicação.

## Texto exato de autorização candidata — não concedida

APPROVED — OES / PF-I04/P4-A27 / SINGLE_V3_VERIFIER_BASELINE_CATALOG_READ_ONLY / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / executor oes_sandbox_owner / exactly one reviewed WITH SELECT from A26 SHA256 136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a / pg_catalog and privilege functions only / expected pre-grant HOLD / verify summary and output completeness / no Django or Q0 data reads / no SET ROLE / no GRANT or REVOKE / no DDL or DML / no role or membership changes / no credentials / no Django connection / no HTTP or deploy / no paid services / fail closed

## Próximos passos
Após autorização nominal, exatamente um SELECT no destino e com a identidade especificados; se houver qualquer erro ou saída incompleta, interromper e não repetir. Registrar resultado, status das políticas `PUBLIC` (ainda candidatas), e preparar checkpoint proporcional. Gates atuais: Marco B OPEN, G2-P2B operacional NO-GO, E9 NO-GO, readiness NOT_READY, PF-I04/P4 NOT_AUTHORIZED, fase 5 NOT_STARTED.
