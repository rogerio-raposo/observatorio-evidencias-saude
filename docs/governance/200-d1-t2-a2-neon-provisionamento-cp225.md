# Documento 200 — D1-T2-A2: provisionamento Neon Free sintético e preflight de segurança (CP225)

**2026-10-21 | NEON_SYNTHETIC_PROJECT_PROVISIONED_ONLY | T2-A2 NOT_AUTHORIZED**

## 1. Marco e origem da decisão
Após CP224 foram realizadas atividades de comparação documental PostgreSQL local versus Neon Free, inspeção B01–B10 (evidências relatadas em conversa, sem logs brutos canônicos), preflight de metadados Neon, comparação de isolamento entre projeto e branch, e **aprovação explícita do proprietário para criar um novo projeto Neon**. Esta aprovação autoriza somente o provisionamento de um projeto independente, não DDL/SQL, adaptador, dados, migrations canônicas, CI, deployment ou alterações de gates.

## 2. Evidência factual da API Neon (consulta somente leitura posterior à criação)
- Organização associada ao sandbox OES existente; novo projeto Neon **`oes-d1-t2-a2-synthetic`**, ID **`tiny-pond-20086371`**.
- Plano **`free_v3`**, região **`aws-sa-east-1`**, PostgreSQL **18**.
- Branch inicial independente **`synthetic-main`**, ID **`br-divine-grass-b63wlpcb`**, primária, não protegida.
- Banco criado automaticamente no provisionamento: **`oes_t2a2_synthetic`**.
- Endpoint inicial **read_write**, status **active** na consulta; metadados do projeto: mínimo/máximo **0,25 CU** e `suspend_timeout_seconds=0` (valor retornado pelo Neon, sem afirmar escala a zero ou ausência de consumo).
- Configurações observadas: `block_public_connections=false`; lista de IPs permitidos vazia, **não deve ser interpretada como bloqueio de acesso**; `enable_logical_replication=false`. Proteção da branch: `false`.
- Consumo reportado para o projeto recém-criado durante consulta: compute_time_seconds=0, data_transfer_bytes=0 e synthetic_storage_size=0 (valores momentâneos e não garantia de consumo futuro).
- O sandbox anterior **`oes-sandbox`** permaneceu separado; nenhuma ação de escrita foi solicitada nesse projeto.
- A primeira tentativa de criação, que explicitava intervalo de suspensão de 300 s, foi recusada com **HTTP 412** (`modifying the suspend interval is not permitted on this account`); a lista confirmou ausência do novo projeto após o erro. A criação seguinte omitiu esse parâmetro e foi concluída com sucesso. **Não modificar suspensão por suposição.**

## 3. Limites e riscos de segurança
1. **Isolamento por projeto confirmado**, não por ausência de riscos de acesso: endpoint read_write e conexões públicas não bloqueadas exigem decisão sobre controles de rede, privilégios e credenciais antes de qualquer SQL.
2. O provisionamento cria branch e banco inicial, mas **nenhum SQL, tabela T2-A2, dado sintético ou conexão ao banco** foi executado por este processo.
3. Não foram lidos registros, tabelas, schemas, roles sensíveis nem connection strings; portanto ausência de dados factuais em todas as superfícies internas **não está comprovada por inspeção**. O projeto foi criado do zero com configuração nomeada e sem clonagem/importação voluntária.
4. Plano Free verificado no registro, porém **custo incremental zero futuro e limites de consumo devem ser monitorados e reconfirmados** antes de ativar operações. Sem cartão, upgrade, cobrança ou recursos pagos.
5. A ausência de proteção da branch primária é risco para mutações involuntárias; qualquer mudança de política exige autorização específica. Segredos e URLs de conexão nunca devem ser publicados.
6. Compatibilidade PostgreSQL 18 com código Python e semânticas T2-A1 ainda não testada; nenhuma alegação de equivalência à View SQL ou prontidão operacional.

## 4. Próxima decisão separada
Propor **um preflight específico de segurança e custos, preferencialmente apenas por metadados**: avaliar capacidades reais de restrição de acesso, estado/contabilização de compute, quotas Free, controles de credenciais e plano de descarte, sem SQL. Se alguma verificação exigir conexão, acesso a registros, alteração de configuração ou criação de role, interromper e solicitar autorização separada.

Somente depois submeter escopo concreto de desenvolvimento do adaptador e comandos sintéticos, esquema mínimo (Scenario/Event/Receipt), transações, rollback, idempotência, concorrência e replay para aprovação **T2-A2**. Nenhum uso de migrations canônicas.

## 5. Estado canônico
- T1 `CLOSED_SYNTHETIC_LOCAL_ONLY`, 36 PASS históricos.
- T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY`, 75 PASS históricos (39+36).
- **T2-A2 `NOT_AUTHORIZED`**; Neon aprovado **somente para a criação do projeto isolado já concluída**.
- D0 editorial encerrado → D1 prioritário → D2 factual condicionado → governança operacional completa posterior.
- Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrations `UNREVIEWED`; gates, controles de papéis e BRGs preservados.

**STOP.** Próxima atividade sob `Prossiga`: somente parecer de segurança/custos e proposta de autorização de uso experimental do projeto Neon novo, sem SQL nem mudanças de configuração.
