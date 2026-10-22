# Documento 208 — D1/T2-A2: protocolo A2-G2/P e revisão adversarial (CP233)

**OES | 2026-10-22 | A2-G2/P_REVISE_BEFORE_OPERATIONAL_AUTHORIZATION | A2-G1 CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED | T2-A2 NOT_AUTHORIZED**

## 1. Autoridade, proveniência e resultado

Consolidação exclusivamente documental de três atividades pós-CP232: A1 delimitou o escopo estrutural/preflight; A2 definiu níveis de verificação, matriz PF-01–PF-10 e autorizações independentes; A3 realizou revisão adversarial com PA-01–PA-08 e critérios AC-01–AC-10. Evidência canônica: Documento 200 (Neon Free, segurança e custo), Documento 202 (ACL e papel excessivamente privilegiado), Documento 203 (papel app restrito e N1-D2 não concluído), Documento 204 (N1-E3), Documentos 205–206 (arquitetura e oráculos) e **Documento 207 (decisão expressa A2-G1)**; handoff CP232. Os debates A1–A3 foram anteriormente `NÃO PERSISTIDOS` e são incorporados agora **apenas como protocolo documental**.

**Parecer:** `A2-G2/P_REVISE_BEFORE_OPERATIONAL_AUTHORIZATION`. P1 e P2 não estão aprovados, e nenhum acesso ou teste atual atesta a eficácia destes controles. Nada neste documento é comando de execução, autorização geral de conexão, criação ou eliminação de recursos, modificação de infraestrutura, nem promoção de T2-A2.

## 2. Fronteira e ambiente histórico

Projeto **`oes-d1-t2-a2-synthetic`**, ID `tiny-pond-20086371`, região `aws-sa-east-1`, branch `synthetic-main` (`br-divine-grass-b63wlpcb`), banco `oes_t2a2_synthetic`, PostgreSQL 18. Plano `free_v3` foi verificado historicamente, **sem garantia atual** de saldo, custo zero ou imutabilidade de quotas. Provisionamento informou endpoint `read_write`, `block_public_connections=false`, branch primária não protegida, lista de IPs permitidos vazia que **não prova** bloqueio da rede, 0,25 CU em metadados e `suspend_timeout_seconds=0` — não interpretar como suspensão/ativação gratuita. `oes-sandbox` é um projeto independente fora do escopo; quotas organizacionais possivelmente compartilhadas exigem avaliação.

`oes_t2a2_app`: papel LOGIN restrito historicamente verificado após N1-D3, sem CREATE efetivo no banco/public e sem membership conhecida naquela inspeção; não declarar ACL futura satisfatória. `oes_t2a2_runtime`: `CREATEDB`, `CREATEROLE` e associação `neon_superuser` históricas, **NÃO UTILIZAR**. `oes_t2a2_owner` foi identificado como identidade existente, mas suas capacidades atuais/ownership apropriado não foram comprovados para este escopo; N1-D2 não concluído. Papéis `authenticator`, `anonymous`, `authenticated` e Data API não devem ser alterados.

N1-E3: run 39737616716 demonstrou cliente Psycopg 3 com `sslmode=verify-full` e CA confiável ao endpoint e autenticação do papel app; `pg_stat_ssl.ssl=false` observado no backend, **sem prova** de TLS ponta a ponta até o processo PostgreSQL ou da proteção dos segmentos internos. Não reutilizar indiscriminadamente aquela autorização para novas sessões.

## 3. Estrutura futura candidata — ainda não autorizada

A2-G1 aprovou **somente como referência documental condicionada** um namespace isolado `oes_t2a2_proto` contendo `scenario`, `event` e `receipt`, com PK/FK/CHECK/NOT NULL pertinentes ao contrato T1/T2-A1. Eventuais tabelas deverão começar **vazias**. A2-G2/E, se no futuro aprovado expressamente, trataria apenas da criação desses objetos com DDL exata revisada, sem inserir fixtures, conceder GRANTs de aplicação, implementar adaptador, executar CI ou tocar em 36 migrações históricas. PKs implicam índices próprios; índices extras exigem justificativa. A2-G3 para GRANTs, A2-G4 para adaptador e A2-G5 para testes permanecem **não autorizados**, assim como A2-G2/P1/P2. Não pressupor autorização de DROP no escopo de criação.

## 4. Níveis de verificação com aprovações independentes

| Nível | Objetivo e fonte | Autorização atual |
|---|---|---|
| D0 — histórico documental | GitHub, documentos e artefatos existentes; identificar evidências históricas, limites e inconsistências | Apenas análise documental concluída |
| P1 — metadados administrativos | Neon API, **GET/leitura explicitamente delimitados**: projeto, branch, banco, plano/quotas/consumo, endpoint, acesso público/proteção; não coletar connection strings ou segredos | `NOT_AUTHORIZED` |
| P2 — catálogos PostgreSQL | Conexão autenticada e consultas SQL de leitura sob identidade selecionada: `pg_namespace`, `pg_class`, `pg_database`, `pg_roles`, `pg_auth_members`, `pg_default_acl` e funções de privilégio previamente revisadas | `NOT_AUTHORIZED` |
| E — criação estrutural | Criar somente namespace e três tabelas vazias mediante DDL aprovada e preflight conclusivo/revalidado | `NOT_AUTHORIZED` |

P1 e P2 são subetapas **auxiliares** de planejamento de A2-G2/P, e E corresponde ao candidato A2-G2/E. Não são novos gates institucionais; uma aprovação não inclui a seguinte. `SELECT` não torna uma operação automaticamente isenta de custo, efeito lateral, vazamento ou risco. P2 deverá ter identidade e conexão determinadas, transação somente leitura, allowlist de comandos/funções, limites de sessão e saída de evidências minimizada. Não executar consultas arbitrárias ou sobre tabelas de conteúdo.

## 5. Matriz PF-01–PF-10: evidência necessária e fonte

| ID | Conteúdo | Fonte futura | Estado neste CP |
|---|---|---|---|
| PF-01 | HEAD, ponteiro e autorizações | GitHub | PASS somente para atividade documental CP233 |
| PF-02 | Projeto/branch/banco/região exatos | P1 Neon | `UNVERIFIED` no estado operacional atual |
| PF-03 | Plano vigente, saldo, quotas e cobrança | P1 Neon e termos financeiros aplicáveis | `UNVERIFIED` |
| PF-04 | Endpoint, conexão pública, proteção de branch | P1 Neon | `UNVERIFIED` |
| PF-05 | Schema e objetos existentes/colisões | P2 PostgreSQL | `UNVERIFIED` |
| PF-06 | Owner e CREATE efetivo necessário | P2 PostgreSQL | `UNVERIFIED` |
| PF-07 | ACL, memberships, PUBLIC, default privileges | P2 PostgreSQL | `UNVERIFIED` |
| PF-08 | Credenciais e TLS, limites de observação | Projeto de conexão separado; evidência N1-E3 histórica | `PARTIALLY_DOCUMENTED` |
| PF-09 | Dependências e reversão do namespace futuro | Inventário P2 + plano de remoção específico | `UNVERIFIED` |
| PF-10 | Isolamento e ausência de impacto externo | P1/P2 e registro de escopo | `UNVERIFIED` |

Nenhuma verificação P1/P2 foi feita após CP232. Evidência pretérita não deve ser classificada como confirmação contemporânea. `UNVERIFIED` em condição bloqueante não se transforma em `PASS`.

## 6. Revisão adversarial A3: PA-01–PA-08

| ID | Gravidade | Falha/risco | Tratamento documental proposto |
|---|---|---|---|
| PA-01 | CRITICAL | Plano Free não garante custo zero; sessão pode ativar compute e consumir quotas compartilhadas | Comprovar saldo/termos/limites antes de P2; STOP em risco de cobrança ou consumo não autorizado |
| PA-02 | CRITICAL | Identidade owner e seus direitos efetivos não estão demonstrados | Papel por consulta definido antecipadamente; sem utilizar `oes_t2a2_runtime` ou escalar privilégios |
| PA-03 | HIGH | SQL nominalmente read-only pode acionar funções com efeitos laterais | Allowlist de comandos e funções, transação read-only, timeout e proibição de leituras de dados |
| PA-04 | HIGH | Rede pública e segmentos TLS não totalmente caracterizados | Explicitar exposição, autenticação, TLS externo comprovado e incerteza interna; STOP se risco não aceitável |
| PA-05 | HIGH | Metadados, ACL e quotas podem mudar entre preflight e execução | Estabelecer validade e revalidação autorizada imediatamente antes de E; drift bloqueia |
| PA-06 | HIGH | ACL aparentemente mínima pode omitir privilégios efetivos ou caminhos indiretos | Examinar owner, `PUBLIC`, memberships transitivas, heranças, defaults e limites de visibilidade |
| PA-07 | MODERATE | Reversão de DDL e descarte posterior não são equivalentes | Separar rollback transacional aplicável, compensação e DROP futuro autorizado de modo independente |
| PA-08 | MODERATE | Evidência incompleta/sem proveniência pode ser interpretada como aprovação | Registro padronizado com hora, escopo, fonte, identidade, resultado PASS/FAIL/UNVERIFIED e limites |

**Resultado:** 2 críticos, 4 altos e 2 moderados; `REVISE_BEFORE_OPERATIONAL_AUTHORIZATION`. Tratamentos acima são propostas, não eficácia observada.

## 7. Critérios AC-01–AC-10

| ID | Pós-condição exigida se P1/P2 vierem a ser autorizados |
|---|---|
| AC-01 | Projeto/branch/banco/região confirmados sem ambiguidades |
| AC-02 | Custos e quotas demonstrados compatíveis com autorização financeira de custo não pago |
| AC-03 | Identidade, owner e privilégios efetivos suficientemente comprovados |
| AC-04 | Inventário capaz de detectar colisões prévias de schema/objetos |
| AC-05 | ACL, `PUBLIC`, grants indiretos, ownership e defaults avaliados |
| AC-06 | Nenhum segredo ou conteúdo de aplicação recuperado indevidamente |
| AC-07 | Exposição de rede, autenticação e fronteira TLS explicitamente documentadas |
| AC-08 | Reversão e recursos afetáveis identificados sem autorização implícita para apagar |
| AC-09 | Evidências atribuíveis a data/hora, fonte, identidade, escopo e limites |
| AC-10 | Ausência de operações fora de autorização demonstrada nos limites observáveis |

Cada critério recebe `PASS` (evidência suficiente no escopo), `FAIL` (requisito comprovadamente não atendido) ou `UNVERIFIED` (ausência/ambiguidade). Distinguir falha de teste e resultado não observado. PASS de P1 não equivale a PASS de P2, e ambos não liberam automaticamente E.

## 8. Segurança das consultas, custos e condições de parada

A eventual proposta P1 deve conter lista fechada de endpoints/ações de leitura, ID do projeto, limites de dados e obrigação de não alterar configuração, rede, role, endpoint, branch, banco, senha, plano ou quota. A eventual P2 precisa de aprovação **separada**, identidade exata, canal TLS, SQL literal permitida e revisada, transação somente leitura, limites de tempo/linhas, proibição de funções não auditadas, alterações de `search_path` persistentes e leituras de registros científicos. Distinguir permissão do plugin de permissão do PostgreSQL; resultados vazios de catálogos com visibilidade insuficiente não provam ausência de privilégios. Não executar workflows anteriores sem autorização.

STOP ante: HEAD divergente; projeto, branch, banco, identidade ou papel inesperado; possibilidade de cobrança ou gasto fora da autorização; credencial exposta; consultas além da allowlist; privilégios elevados não justificados; schema ou dependência preexistente; risco TLS/rede não aceito; dados reais/factuais; efeito em `oes-sandbox`; ou `UNVERIFIED` bloqueante. Reversão de transação deve ser distinguida de limpeza posterior; a criação não autoriza `DROP`. Mudanças relevantes invalidam evidência histórica até revalidação autorizada.

## 9. Fronteiras de autorização e continuidade

**Situação no CP233:** A2-G1 `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED`; A2-G2/P1 `NOT_AUTHORIZED`; A2-G2/P2 `NOT_AUTHORIZED`; A2-G2/E `NOT_AUTHORIZED`; T2-A2 `NOT_AUTHORIZED`. F01–F07 apenas `DOCUMENTARILY_ADDRESSED_NOT_OPERATIONALLY_VALIDATED`; L1–L4 permanecem; O-01–O-10 nunca executados. T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` com 36 PASS históricos; T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` com 75 PASS históricos; Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrações `UNREVIEWED`. D0 editorial encerrado → D1 sintético prioritário → D2 factual posterior → governança operacional completa posterior.

**Próxima atividade sob novo `Prossiga`:** avaliação **exclusivamente documental** da suficiência e da minuta de autorização P1 para metadados administrativos somente leitura, sem solicitar/aprovar acesso automaticamente e sem executar Neon, SQL ou CI. A2-G2/P2 e E exigem decisões futuras independentes. Preservar custo zero autorizado, nenhuma contratação, nenhum dado real, nenhum novo gate científico/operacional. **STOP.**
