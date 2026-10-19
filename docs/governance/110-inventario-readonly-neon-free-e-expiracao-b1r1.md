# 110 — Inventário read-only do Neon Free e expiração da janela B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 2026-10-19  
**Modo:** médio  
**Status:** **NEON_SANDBOX_READONLY_INVENTORY_COMPLETE — B1R1_EXPIRED_NOT_EXECUTED — OPERATIONAL_DB_NOT_READY**  
**Fontes:** consulta direta à integração Neon, CP153/Documento 109, CP148/Documento 104 e Documento 91.

## 1. Freshness Gate

O ponteiro indicava CP153; HEAD `d264143fd4f6a2ce2e98662ff0dcb645e865c46a`; README, STATE e CHANGELOG consistentes, sem commit posterior ao checkpoint de entrada. Aprovação Neon Free synthetic-only / `aws-sa-east-1` / no paid services permanece válida.

## 2. Inventário factual — apenas SELECT/API read-only

Projeto Neon:
- nome `oes-sandbox`, project ID `weathered-boat-65779510`;
- `region_id=aws-sa-east-1`, PostgreSQL major 18;
- branch única padrão `production`, ID `br-wild-field-b6qg7k3p`, `ready`, não protegida, criada pelo console; nome `production` é metadado do fornecedor, não status científico OES;
- database `oes_sandbox`;
- consulta temporal SQL: `2026-10-19T12:05:22.721Z` = `2026-10-19T09:05:22.721-03:00`;
- servidor `18.6 (653b019)`, `UTF8`, TimeZone = `GMT`;
- tamanho `pg_database_size` ~= `7536 kB`;
- único schema visível não sistêmico: `public`;
- **0 tabelas de aplicação** e **0 funções não sistêmicas**, sem migrations OES;
- `plpgsql` 1.0, única extensão observada;
- roles visíveis: `cloud_admin`, `neon_service`, `neon_superuser`, `oes_sandbox_owner`;
- role conectada `oes_sandbox_owner`, com `rolcreatedb=true`, `rolcreaterole=true`, `rolreplication=true`, `rolbypassrls=true`, `rolsuper=false`; tratar como acesso administrativo, não least-privilege;
- `current_setting('transaction_read_only')=off`; consultas SELECT foram somente de leitura, mas a sessão NÃO estava em transação read-only;
- `current_setting('ssl')=off` no servidor; isso **não é evidência conclusiva de transporte não criptografado** através do proxy gerenciado Neon. Validar o TLS com ferramentas e política da conexão externa antes do gate ODB-03;
- configurações API expõem `block_public_connections=false` e allowlist vazia; não assumir acesso privado;
- contadores da API de projeto/branch podem refletir atualização diferida; não usá-los como prova de não mutação externa.

Todas as instruções SQL emitidas foram **SELECT**; não houve DDL, grants, CREATE ROLE, CREATE BRANCH, INSERT/UPDATE/DELETE, migrations, fixtures, request científico, registro de medição ou qualquer alteração operacional realizada pelo assistente nesta etapa.

## 3. Encerramento temporal de B1R1

**Regra normativa operacional — Documento 91:** interval de ativação B1R1 `[2026-10-19T08:00:00-03:00, 2026-10-19T09:00:00-03:00)`; a partir de 09h00 sem ativação válida, `EXPIRED_NOT_EXECUTED`, vedados backdating e alteração silenciosa de schedule.

**Base factual disponível:**
1. CP148/Documento 104 documentou que não existia PostgreSQL operacional persistente para o preflight no início da janela, segundo declaração do owner; preflight e activation não foram executados.
2. Neon criou `oes-sandbox` às `2026-10-19T11:45:22Z` (= 08:45:22-03), mas CP153 documentou somente consulta SELECT às `2026-10-19T08:59:14.637-03:00`, sem schema OES ou activation.
3. Em `2026-10-19T09:05:22.721-03:00`, inventário do banco no próprio PostgreSQL confirmou zero tabelas e funções OES, portanto não existia nesse ambiente uma transição persistida `B1R1→active`.
4. Consulta de horário factual America/Recife às `2026-10-19T09:05:48-03:00` confirmou o limite encerrado.

**Decisão operacional:** `B1R1_ACTIVATION_WINDOW=EXPIRED_NOT_EXECUTED`, baseada na ausência de ativação efetiva conduzida neste processo e na infraestrutura observada; **não** se trata de consulta a uma suposta instância factual anterior. Evitar afirmar conhecimento universal sobre bancos não conectados; a conclusão é suficiente para o processo OES auditado. Não há execução válida B1R1 demonstrada, nem timestamp `started_at` factual no banco operacional.

Em consequência: NÃO executar PubMed/ClinicalTrials.gov nas Opportunities originalmente agendadas; não reativar B1/B1R1; não alterar os 14 horários; não fabricar MeasurementEvents/Resolutions/Artifacts factuais. Novo experimento/epoch e congelamento temporal exigirão aprovação de governança distinta depois dos gates ODB.

## 4. Interpretação dos controles ODB

| Controle | Estado após inventário |
|---|---|
| ODB-01 — owner, plano, região | owner aprovou sandbox Free/sa-east-1; projeto/região observados; cobrança e quotas precisam revisão em painel |
| ODB-02 — PostgreSQL persistente | instância acessível observada; persistência inter-suspensão e capacidade de restore ainda não comprovadas |
| ODB-03 — acesso seguro e privilégios mínimos | **NOT_READY**; role owner conectada, acesso público, TLS cliente não auditado |
| ODB-04 — dados e minimização | restrição synthetic-only vigente, sem PHI; governança factual pendente |
| ODB-05 — schema e migrations | **NOT_STARTED**; banco vazio, ledger inexistente |
| ODB-06 — bootstrap histórico | **NOT_STARTED**; nenhuma reprodução factual retroativa permitida |
| ODB-07 — Artifacts e hashes | **NOT_CONFIGURED** |
| ODB-08 — backup externo/restore | **BLOCKED** |
| ODB-09 — observabilidade | hora PostgreSQL observada, resto pendente |
| ODB-10 — executor factual | **NOT_AUTHORIZED** |
| ODB-11 — segregação da CI | nenhum vínculo operacional com CI observado; hardening/inspeção de configuração pendentes |
| ODB-12 — testes | inventário SELECT PASS; smoke tests sintéticos persistentes e recuperação pendentes |

**OPERATIONAL_DATABASE_READY = NO.** A branch do provedor com nome `production` não recebe dados factuais científicos nesta fase.

## 5. Plano de migrações sintéticas — somente preparação

1. Inventariar a ordem de aplicação canônica `database/poc-s1.sql` e migrations 002–036, incluindo arquivos 031a–e, 032a–d, 033a–e. Comparar sequência executada na CI; não concluir que ordenação lexicográfica simples é suficiente.
2. Propor **branch Neon segregada `oes-schema-test`** (nome candidato) para ensaios sintéticos descartáveis. Criar branch apenas após gate de custo/cotas e aprovação do ato de mutação de infraestrutura; branch não é cópia independente de backup.
3. Definir ledger de migration `ops.schema_migration` conforme Documento Arquitetura 30 (ID, path, hash, applied_at/by, estado, PostgreSQL version), com aplicação exatamente uma vez, detecção de drift e política de rollback/forward-fix. Ainda não implementar schema.
4. Delimitar scripts estritamente de schema versus fixtures: **proibir** execução indiscriminada de `s5-fixtures.sql`, scripts `f4-topi-n2-dcbti-...`, authority/activation e dados de casos reais no banco operacional. Testes em branch descartável só com escopo sintético, hashes e logs.
5. Hardening: antes de acessar com papéis funcionais, definir `oes_readonly` e `oes_migrator` como candidatos de least-privilege, revisar `BYPASSRLS`, TLS, conexão pública e auditoria. Não criar roles ainda.
6. Plano de backup independente, retenção e teste de restauração precisa preceder qualquer conteúdo factual; definir destino fora do Neon e operador.
7. Capturar logs de execução e evidência reproduzível para cada futura fase. Se branch/provisionamento exigir serviço pago, STOP e decisão do proprietário.

## 6. Próximo passo e pausa obrigatória

Prosseguir somente após `Prossiga` com um checkpoint de **desenho e prova de sequência de migrations em ambiente descartável**, priorizando um plano que não consuma quota inesperada do Neon Free. Continuar modo médio em preparação; voltar ao modo alto para decisão de permissão, backup e novo Epoch.

> **NEON_SANDBOX_INVENTORY = PASS_READ_ONLY**  
> **NEON_SANDBOX_SCHEMA = EMPTY_PUBLIC_ONLY**  
> **NEON_SANDBOX_CONNECTED_ROLE = ADMIN_CAPABLE**  
> **B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **OPERATIONAL_DATABASE_READY = NO**  
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**  
> **PHASE_5 = NOT_STARTED**

**Fim do Documento 110**

