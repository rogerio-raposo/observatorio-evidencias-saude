# OES — Continuidade CP241

**2026-10-22 | anterior CP240 | A2-G4 DOCUMENTARY_CONTRACT_CONSOLIDATED_ONLY | A2-G4/G5 E IMPLEMENTAÇÃO T2-A2 NOT_AUTHORIZED**

## Identidade e escopo do checkpoint
CP241 registra a consolidação **exclusivamente documental** de quatro atividades internas A1–A4 pós-CP240: proposta do contrato experimental PostgreSQL, revisão adversarial RA-01–RA-10, redação revisada e avaliação final de suficiência RF-01–RF-05. Documento 216: `docs/governance/216-d1-t2-a2-g4-contrato-implementacao-documental-cp241.md`. Base GitHub anterior CP240 HEAD `42f052d8b07991dec22d93042efc4f1b96220178`, branch `main`, Freshness Gate inicial `identical`. Novo HEAD deve ser verificado contra o commit de publicação e ponteiro único.

## Estado e decisões
O contrato candidato define fronteira T1 Python / ponte T2-A1 / repositório PostgreSQL A2-G4, UoW com leitura sob mesma transação, `READ COMMITTED`/lock por cenário como hipótese condicionada, criação por unicidade/colisão/rollback+nova transação, revisão/evento/recibo atômicos, fingerprint Python histórico, criação repetida com snapshot **corrente**, demais recibos com resposta original, divergência e replay, resultado incerto em COMMIT, erros SQLSTATE contextuais, restrição de `Any` frente a JSONB, uso exclusivo da app de menor privilégio, rollback/descarte por autorização separada.

**Parecer:** `SUFFICIENT_WITH_FINAL_REFINEMENTS_FOR_DOCUMENTARY_PERSISTENCE`; não é prontidão para implementação. RA-01–RA-10 endereçados em especificação, sem prova operacional; RF-03 representação Python da confirmação incerta e parâmetros de conexão/retry ainda requerem decisão. F01–F07 seguem apenas documentais, L1–L4 condicionantes, O-01–O-10 não executados.

## Limites e proibições
A2-G1 permanece `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED`; P1 `COMPLETED_WITH_LIMITATIONS`, P2 `COMPLETED_WITH_SECURITY_FINDINGS`, E `COMPLETED_STRUCTURAL_ONLY`, A2-G3 `COMPLETED_MINIMAL_GRANTS_VERIFIED`. **A2-G4/G5 e implementação T2-A2 NÃO AUTORIZADOS.** Não houve código, SQL, CI, fixtures, nova conexão Neon, ALTER ROLE/GRANT, objetos, segredos ou alteração de `oes-sandbox` neste bloco. `oes_t2a2_runtime` proibido; owner elevado; TLS apenas cliente–endpoint demonstrado anteriormente. Neon Free não autoriza despesas. T1 36 e T2-A1 75 PASS **históricos**, não reexecutados. Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`; nenhuma promoção científica/operacional.

## Ponto exato de retomada
**A1 pós-CP241 — preparação documental de uma minuta de autorização estritamente delimitada para A2-G4**, incorporando contratos, RF-03, dependências concretas e segregação A2-G4/A2-G5; somente após `Prossiga`. A minuta não pode autorizar por si só implementação, SQL, Neon, driver, CI, fixtures ou mudanças de gates. Exigir aprovação expressa separada para executar. Protocolo CP194: um `Prossiga` = uma atividade interna; checkpoint a cada 3–5 atividades ou risco; Freshness Gate na abertura e antes do commit; relatório e STOP após checkpoint. Ponteiro único: `archive/handoffs/oes/README.md`.

**STOP — aguardando novo `Prossiga`.**
