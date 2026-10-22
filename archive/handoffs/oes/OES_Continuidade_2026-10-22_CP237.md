# OES — Continuidade CP237

**2026-10-22 | anterior CP236 | P1 APPROVED AND COMPLETED_WITH_LIMITATIONS | P2/E/T2-A2 NOT_AUTHORIZED**

Documento 212: `docs/governance/212-d1-t2-a2-p1-decisao-e-evidencias-cp237.md`. Proprietário aprovou expressamente `APPROVED — OES / D1-T2-A2 / A2-G2-P1 / PROPORTIONAL_NEON_ADMIN_READ_ONLY_PREFLIGHT`. Freshness Gate antes de P1: `1095e2629a89c5c918025233c3492eaf3294e270`, CP236 `identical`. Plugin Neon P1 consultou administrativamente projeto, branch, banco, lista de branches e endpoints; `describe_project` e `list_postgres_endpoints` repetidos para minimização da extração sem divulgar respostas com campos sensíveis. Sem SQL, alterações, conexão PostgreSQL, CI ou custo pago.

Confirmados: projeto Free sintético `tiny-pond-20086371`, branch `synthetic-main` (`br-divine-grass-b63wlpcb`, default/primary, não protegida), banco `oes_t2a2_synthetic`, owner nominal `oes_t2a2_owner`, endpoint `ep-fragrant-violet-b6g4wnnh` read_write idle, 0,25–0,25 CU, `suspend_timeout_seconds=0`, `block_public_connections=false`, `block_vpc_connections=false`, lista permitida vazia. Uso observado compute_time_seconds=1376, branch logical_size=31735808 bytes, data_transfer_bytes=12185, written_data_bytes=0. Não confundir consumo API com billing ou dono nominal com privilégios CREATE/GRANT; plano atual e quotas completas não comprovados. P1 `COMPLETED_WITH_LIMITATIONS`, não homologação de segurança ou execução T2-A2.

A2-G1 apenas aprovado documentalmente; **P2/E/T2-A2 NOT_AUTHORIZED**, F01–F07 sem validação, L1–L4 e O-01–O-10 pendentes. TLS N1-E3 somente cliente→endpoint, backend SSL_FALSE observado; role `oes_t2a2_runtime` privilegiado NÃO USAR, `oes-sandbox` intocado. Documento 211 governa Free sem gastos/contratação/upgrade/cartão. T1 36 PASS e T2-A1 75 PASS históricos, Fase 4 NOT_READY, Fase 5 NOT_STARTED, 36 migrações UNREVIEWED.

**Próximo `Prossiga`:** documentação da proposta P2 de inspeção SQL read-only em catálogos, com identidade, SQL exata e controle de escopo; **não executar Neon ou SQL sem decisão P2 expressa**. Freshness Gate, uma atividade por Prossiga, checkpoint equilibrado. Ponteiro único README. **STOP.**
