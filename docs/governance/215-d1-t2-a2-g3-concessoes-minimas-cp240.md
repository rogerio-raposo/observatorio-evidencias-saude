# Documento 215 — D1/T2-A2: autorização e evidências de concessões mínimas A2-G3 (CP240)

**OES | 2026-10-22 | A2-G3_COMPLETED_MINIMAL_GRANTS_VERIFIED | A2-G4/G5 E T2-A2 NOT_AUTHORIZED**

## 1. Decisão expressa, continuidade e limites
O proprietário autorizou explicitamente: `APPROVED — OES / D1-T2-A2 / A2-G3 / MINIMAL_APPLICATION_GRANTS_ONLY`, e depois emitiu `Prossiga` para a execução exclusiva de preflight, cinco GRANTs mínimos e pós-verificação. O Freshness Gate confirmou no início o GitHub `main` HEAD `22401531744d95f71fb25aab5bc71f3f85b08180` e CP239, comparação `identical`. Projeto Neon `tiny-pond-20086371`, branch `br-divine-grass-b63wlpcb`, banco `oes_t2a2_synthetic`, papel executor explicitamente `oes_t2a2_owner`; papel beneficiário `oes_t2a2_app`. Nenhum segredo ou connection string foi divulgado.

## 2. Preflight observado
`run_sql_transaction` somente leitura com `REPEATABLE READ` e timeouts locais 5s/1s comprovou banco e papel esperados; owner do schema e das três tabelas `oes_t2a2_owner`; schema `oes_t2a2_proto` existente; tabelas `scenario`, `event`, `receipt` existentes e vazias (`COUNT(*)=0` em todas). Antes dos GRANTs, `oes_t2a2_app` tinha USAGE=false e CREATE=false no schema, SELECT/INSERT/UPDATE/DELETE/TRUNCATE=false nas três tabelas; `PUBLIC` sem USAGE/CREATE no schema. ACLs explícitas das três tabelas eram `NULL`.

## 3. Execução transacional — lista fechada
`run_sql_transaction`, sob `oes_t2a2_owner`, executou `SET LOCAL statement_timeout='5s'`, `SET LOCAL lock_timeout='1s'`, `SET LOCAL search_path=pg_catalog` e exatamente cinco GRANTs:

```sql
GRANT USAGE ON SCHEMA oes_t2a2_proto TO oes_t2a2_app;
GRANT SELECT, INSERT ON TABLE oes_t2a2_proto.scenario TO oes_t2a2_app;
GRANT UPDATE (revision, state) ON TABLE oes_t2a2_proto.scenario TO oes_t2a2_app;
GRANT SELECT, INSERT ON TABLE oes_t2a2_proto.event TO oes_t2a2_app;
GRANT SELECT, INSERT ON TABLE oes_t2a2_proto.receipt TO oes_t2a2_app;
```

O retorno apresentou 8 resultados de 0 linhas, sem erro. Sem `WITH GRANT OPTION`, REVOKE, ALTER ROLE, DDL estrutural, inserts, CI, alteração de infra, acesso a dados reais ou operação em `oes-sandbox`.

## 4. Pós-verificação independente
Nova transação somente leitura sob owner, `REPEATABLE READ`, com timeouts locais, confirmou banco, role e `transaction_read_only=on`.

| Verificação | Resultado observado |
|---|---|
| Schema USAGE de app | true |
| Schema CREATE de app | false |
| Schema PUBLIC USAGE/CREATE | false/false |
| `scenario`, `event`, `receipt`: SELECT e INSERT app | true/true nas três |
| UPDATE irrestrito na tabela, para app | false nas três |
| UPDATE por coluna `scenario.revision` e `scenario.state` | true/true |
| UPDATE `scenario.scenario_id` e `scenario.synthetic` | false/false |
| DELETE, TRUNCATE, REFERENCES, TRIGGER e MAINTAIN app | false nas três |
| PUBLIC SELECT/INSERT/UPDATE/DELETE | false nas três |
| Registros | `scenario=0`, `event=0`, `receipt=0` |

ACL schema retornou `{oes_t2a2_owner=UC/oes_t2a2_owner,oes_t2a2_app=U/oes_t2a2_owner}`. ACL de tabela `{oes_t2a2_owner=arwdDxtm/oes_t2a2_owner,oes_t2a2_app=ar/oes_t2a2_owner}` em cada uma, e UPDATE por coluna `scenario` demonstrado separadamente via `has_column_privilege`; a ACL de tabela sozinha não mostra os GRANTs por coluna. O resultado não constitui auditoria de todas as possíveis vias de privilégio futuro; não realizar alegação de resistência a SQL arbitrária.

## 5. Avaliação de segurança e continuidade
**`A2-G3_COMPLETED_MINIMAL_GRANTS_VERIFIED`** comprova concessões mínimas e negativas expressamente inspecionadas. Não comprova domínio transacional, replay, concorrência, idempotência persistente ou segurança de produção. `oes_t2a2_owner` conserva capacidades administrativas elevadas conhecidas em P2; `oes_t2a2_runtime` **NÃO UTILIZAR**. TLS N1-E3 verificado no trecho cliente Psycopg→endpoint, sem prova de TLS até o backend nem de configuração TLS da sessão do plugin. Política Free do Documento 211 permanece sem autorização de pagamento ou upgrade.

A2-G2/E `COMPLETED_STRUCTURAL_ONLY`; A2-G3 `COMPLETED_MINIMAL_GRANTS_VERIFIED`; **A2-G4/G5 e T2-A2 `NOT_AUTHORIZED`**. F01–F07 endereçados apenas documentalmente; L1–L4 pendentes; O-01–O-10 não executados. T1 36 PASS e T2-A1 75 PASS somente históricos; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`.

**Próximo `Prossiga`:** preparar documentalmente a proposta delimitada A2-G4 do adaptador PostgreSQL experimental, mantendo Python legado, sem implementar ou testar adaptador, executar SQL/CI, criar dados ou ampliar grants antes de autorização independente. **STOP.**
