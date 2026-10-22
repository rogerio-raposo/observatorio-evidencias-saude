# Documento 212 — D1/T2-A2: decisão e evidências do preflight administrativo P1 (CP237)

**OES | 2026-10-22 | A2-G2/P1_COMPLETED_WITH_LIMITATIONS | P2/E/T2-A2 NOT_AUTHORIZED**

## 1. Autoridade e execução delimitada
Após CP236 e avaliação documental A1 pós-CP236, o proprietário aprovou expressamente: **`APPROVED — OES / D1-T2-A2 / A2-G2-P1 / PROPORTIONAL_NEON_ADMIN_READ_ONLY_PREFLIGHT`**. A autorização contempla consultas administrativas Neon somente de leitura no projeto `tiny-pond-20086371`, sem limite arbitrário de uma chamada por operação e com controle proporcional de escopo. Ela **não** abrange SQL, conexão PostgreSQL, DDL/DML/GRANT, papéis, alterações de rede, criação/remoção de recursos, CI, testes, adaptador, dados reais, serviços pagos ou `oes-sandbox`.

Freshness Gate imediatamente anterior à execução: `main` HEAD `1095e2629a89c5c918025233c3492eaf3294e270`, CP236, comparação `identical`. Foram invocadas via plugin Neon apenas `describe_project`, `get_branch`, `get_postgres_database`, `list_branches`, `list_postgres_endpoints`, e repetidas consultas de `describe_project` e `list_postgres_endpoints` para **extrair somente campos pertinentes** após supressão das respostas originais potencialmente sensíveis. `get_postgres_endpoint` estava permitido, mas não foi necessário. Nenhuma ferramenta modificadora ou `run_sql` foi utilizada. Os dados abaixo são resumo minimizado da observação na conversa, **não logs brutos ou auditoria de plano/billing**.

## 2. Identidades confirmadas

| Item | Observado |
|---|---|
| Projeto | `oes-d1-t2-a2-synthetic` |
| ID | `tiny-pond-20086371` |
| Região | `aws-sa-east-1` |
| PostgreSQL | 18 |
| Branch | `synthetic-main`, `br-divine-grass-b63wlpcb` |
| Branch | principal e default, `protected=false`, estado `ready` |
| Banco | `oes_t2a2_synthetic` |
| Proprietário administrativo retornado pela API | `oes_t2a2_owner` |
| Endpoints listados no projeto | 1 |
| Endpoint (identificador) | `ep-fragrant-violet-b6g4wnnh` |
| Endpoint tipo/estado | `read_write` / `idle` |
| Endpoint | `disabled=false`, região `aws-sa-east-1` |
| Configuração de compute | mínimo 0,25 CU, máximo 0,25 CU, `suspend_timeout_seconds=0` |

O fato de o banco informar o owner `oes_t2a2_owner` **não comprova** privilégios efetivos para CREATE, ownership de objetos futuros ou possibilidade de GRANT; essa verificação pertence a P2 autorizado separadamente.

## 3. Segurança e utilização observadas

`block_public_connections=false`; `block_vpc_connections=false`; lista de IPs permitidos com 0 entradas; branch `protected=false`. Nenhuma dessas observações constitui por si só certificação de segurança. O acesso público não bloqueado não equivale a acesso anônimo; controle de autenticação e risco de exposição permanecem relevantes. Configurações não foram modificadas.

Compute acumulado retornado: **1.376 segundos**. Branch: `logical_size=31735808` bytes, `data_transfer_bytes=12185` bytes, `written_data_bytes=0` no registro consultado. Números de uso são observações administrativas de momento, **não prova de faturamento/quotas disponíveis, nem de ausência histórica de escrita ou custo futuro**. O máximo de compute configurado (0,25 CU) não equivale ao teto potencial informado pelo proprietário para Free (2 CU). O plano atual da conta e saldos completos de quotas ficaram `UNVERIFIED`.

N1-E3 permanece `CLOSED_CLIENT_TLS_ONLY_WITH_BACKEND_OBSERVABILITY_LIMIT`: TLS no trecho cliente→endpoint Psycopg verify-full comprovado anteriormente, `pg_stat_ssl.ssl=false` no backend não demonstra proteção dos segmentos internos. P1 não realizou nova conexão ao banco.

## 4. Avaliação criterial e limites

| Critério | Parecer |
|---|---|
| PF-01 — continuidade/autorização | PASS (HEAD e decisão expressa) |
| PF-02 — identidades de projeto/branch/banco | PASS administrativo |
| PF-03 — configuração/uso disponíveis | PARTIAL; condições financeiras e quotas `UNVERIFIED` |
| PF-04 — segurança administrativa de branch/endpoints | OBSERVED, não homologada |
| PF-05 a PF-07 — objetos, owner efetivo, ACL SQL | `UNVERIFIED`: exigem P2 |
| PF-08 — TLS/segredos | Evidência histórica N1-E3; respostas sensíveis não publicadas |
| PF-09 — reversão/dependências | `UNVERIFIED`: não aferido |
| PF-10 — segregação | Alvo observado foi somente o projeto sintético; não houve modificação do `oes-sandbox` |

Status técnico de P1: **`A2-G2/P1_COMPLETED_WITH_LIMITATIONS`**, e não `SQL_SECURITY_PASS`, `P2_PASS` ou `IMPLEMENTATION_READY`. Houve consultas somente de leitura, sem SQL, alteração de infraestrutura, CI, DDL/DML/GRANT, mudança de banco ou testes.

## 5. Governança prospectiva e próximo passo

A política transversal do Documento 211 permite uso proporcional de serviços Free já autorizados, sem aprovação financeira por GET; cartão, upgrade, contratação e despesa exigem decisão expressa. A execução pontual P1 está encerrada; não autoriza novo escopo permanente sem finalidade técnica vigente.

A2-G1 `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED`; A2-G2/P1 `COMPLETED_WITH_LIMITATIONS`; A2-G2/P2 `NOT_AUTHORIZED`; A2-G2/E `NOT_AUTHORIZED`; T2-A2 `NOT_AUTHORIZED`. F01–F07 somente endereçados documentalmente, L1–L4 pendentes, oráculos O-01–O-10 não executados. T1 `CLOSED_SYNTHETIC_LOCAL_ONLY`, 36 PASS históricos; T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`, 75 PASS históricos. Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrações `UNREVIEWED`.

**Próxima atividade sob `Prossiga`:** preparar documentalmente a proposta proporcional de **P2 somente leitura** de catálogos PostgreSQL, com allowlist SQL literal, identidade apropriada, conexão e limites TLS, avaliação de owner/ACL/objetos, e condições de STOP. Não executar P2 até autorização expressa e independente. **STOP.**
