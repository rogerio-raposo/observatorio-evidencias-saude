# OES — Continuidade CP238

**2026-10-22 | anterior CP237 | P2 APPROVED AND COMPLETED_WITH_SECURITY_FINDINGS | E/T2-A2 NOT_AUTHORIZED**

**Documento 213:** `docs/governance/213-d1-t2-a2-p2-decisao-e-evidencias-cp238.md`. Proprietário autorizou expressamente `APPROVED — OES / D1-T2-A2 / A2-G2-P2 / PG_CATALOG_READ_ONLY_PREFLIGHT`. Neon `run_sql_transaction` sob `oes_t2a2_app` em `oes_t2a2_synthetic`, branch `br-divine-grass-b63wlpcb`, projeto `tiny-pond-20086371`, REPEATABLE READ READ ONLY, statement_timeout=5s, lock_timeout=1s. Q01–Q07 apenas catálogos, sem DDL/DML/GRANT, CI, segredos ou conteúdo científico. HEAD CP237 confirmado antes e depois.

Q01 identidade e read-only PASS. Q02–Q03 namespace `oes_t2a2_proto` e objetos ausentes. Q04 owner nominal e CREATE efetivo em `oes_t2a2_owner` true, app false. Q05 privilégios administrativos elevados em owner/runtime (CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS, memberships `neon_superuser`), app restrito. Q06 28 caminhos de memberships até profundidade 8; não inferir cobertura além do limite. Q07 ACL database PUBLIC CONNECT/TEMP true, CREATE false; sem default ACL personalizada para escopo. TLS P2 via plugin sem `sslmode` explícito; evidência N1-E3 limitada cliente externo Psycopg. Plano financeiro Doc 211 aplica-se, não exigir autorizações individuais para Free, sem pagamento/cartão/upgrade.

**Estado:** A2-G1 aprovado apenas documentalmente; P1 `COMPLETED_WITH_LIMITATIONS`; P2 `COMPLETED_WITH_SECURITY_FINDINGS`; **A2-G2/E, A2-G3/G4/G5 e T2-A2 NOT_AUTHORIZED**. Runtime privilegiado NÃO USAR; `oes-sandbox` fora do escopo. F01–F07 não testados, L1–L4 e O-01–O-10 pendentes; T1 36 PASS/T2-A1 75 PASS históricos; Fase4 NOT_READY, Fase5 NOT_STARTED, migrations 36 UNREVIEWED.

**Próximo `Prossiga`:** preparar documentalmente proposta A2-G2/E DDL mínima de três tabelas vazias e esquema isolado, com avaliação de identidade/admin, rollback, condições STOP; nenhuma execução sem aprovação expressa independente. Freshness Gate por atividade e pré-commit; checkpoint a cada 3–5 atividades salvo risco. Ponteiro único README. STOP.
