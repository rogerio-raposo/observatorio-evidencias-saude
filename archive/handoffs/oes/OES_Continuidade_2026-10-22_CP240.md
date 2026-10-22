# OES — Continuidade CP240

**2026-10-22 | anterior CP239 | A2-G3 APPROVED AND COMPLETED_MINIMAL_GRANTS_VERIFIED | A2-G4/G5 E T2-A2 NOT_AUTHORIZED**

Documento 215: `docs/governance/215-d1-t2-a2-g3-concessoes-minimas-cp240.md`. Proprietário aprovou expressamente `APPROVED — OES / D1-T2-A2 / A2-G3 / MINIMAL_APPLICATION_GRANTS_ONLY`; após `Prossiga`, Freshness Gate HEAD `22401531744d95f71fb25aab5bc71f3f85b08180` CP239 `identical`. Plugin Neon sob `oes_t2a2_owner`, banco `oes_t2a2_synthetic`, branch `br-divine-grass-b63wlpcb`, projeto `tiny-pond-20086371`.

Preflight READ ONLY confirmou schema/tabelas owner esperado, nenhum privilégio app preexistente, zero dados. Um `run_sql_transaction` executou apenas cinco GRANTs: USAGE schema; SELECT/INSERT em scenario/event/receipt; UPDATE(revision,state) somente em scenario, sem grant option. Pós-verificação READ ONLY PASS: app USAGE=true CREATE=false; SELECT/INSERT=true três tabelas; UPDATE por tabela=false e UPDATE por coluna true só revision/state, false para scenario_id/synthetic; DELETE/TRUNCATE/REFERENCES/TRIGGER/MAINTAIN false; PUBLIC sem USAGE/CREATE no schema e sem SELECT/INSERT/UPDATE/DELETE nas três tabelas; zero linhas nas três. Sem ALTER ROLE, REVOKE, DDL adicional, dados, CI, implantação ou outro projeto.

**Estado:** A2-G1 condicional documental, A2-G2/P1 completed_with_limitations, P2 completed_with_security_findings, E completed_structural_only, A2-G3 completed_minimal_grants_verified. **A2-G4/G5 e implementação T2-A2 NOT_AUTHORIZED.** Owner elevado; runtime `oes_t2a2_runtime` proibido. N1-E3 TLS externo apenas; plugin sem TLS explícito. Política financeira transversal Doc 211. F01–F07 apenas documental, L1–L4/O-01–O-10 pendentes, T1 36/T2-A1 75 PASS históricos, Fase4 NOT_READY, Fase5 NOT_STARTED, 36 migrations UNREVIEWED.

**Próximo `Prossiga`:** proposta estritamente documental de A2-G4 para adaptador PostgreSQL Python isolado, sem SQL, CI, escrita de código, inserção de fixtures, novas permissões, implementação ou promoção de gates. Freshness Gate por atividade; checkpoint normalmente 3–5 atividades, antecipável por risco. Ponteiro único README. STOP.
