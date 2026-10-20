# 142 — Evidência Neon read-only de plano e quotas; pendência de cobrança pelo titular

**OES | Fase 4 | 2026-10-20 (America/Recife) | CP186 | modo médio**  
**Estado:** `FREE_PLAN_API_VERIFIED_PARTIAL_BILLING_UNVERIFIED`. Escopo exclusivamente read-only/API de metadados e documentação; nenhum SQL, alteração, contrato, método de pagamento, coleta de fontes ou permissão operacional.

## 1. Freshness Gate e método

HEAD de entrada CP185 `8c8eae2f554a1a050bea5d511c89d49dc47d8c6e`, ponteiro CP185; GitHub compare `identical`, ahead/behind 0. Template, handoff CP185, Documento 141, STATE e CHANGELOG consultados. O usuário autorizou um `Prossiga` em modo médio para verificar o dado possível e apontar a lacuna dependente do proprietário. `Prossiga` não aprova G0-D1–D6, billing, novo epoch, SQL ou fonte factual.

**Fonte primária factual limitada:** integração Neon `describe_project` sobre o projeto OES sandbox existente; resposta observada em 20/10/2026. Foram recuperados metadados de projeto/assinatura e contadores publicados pela API, sem banco SQL. O retorno contém metadados de identidade do titular, que são **deliberadamente omitidos** deste documento e do registro público; nenhum segredo foi salvo.

## 2. O que foi observado diretamente

| Dimensão | Observação da integração | Inferência admissível |
|---|---|---|
| Projeto | `oes-sandbox` | Projeto existente reconhecido, não autorização de uso factual |
| Região | `aws-sa-east-1` | Residência de dados de projeto em São Paulo |
| Versão | PostgreSQL major 18 | Identidade da engine informada na API, não schema OES validado |
| Assinatura do owner do projeto | `subscription_type=free_v3` | Plano Free identificado **na resposta desta data**, sem demonstrar fatura zerada |
| Limite lógico por branch | `branch_logical_size_limit_bytes=1073741824` | 1 GiB de limite lógico reportado, não medição de espaço já utilizado |
| Limite de branches | `branches_limit=10` | Limite declarado, não branches efetivamente criadas |
| Período de consumo | início `2026-10-19T11:41:30Z`, fim `2026-11-01T00:00:00Z` | Janela informada pela API, sem extrapolar projeção financeira |
| Tempo de compute | `compute_time_seconds=353` | Contador retornado pela API, sem inferir tarifa |
| Tempo ativo | `active_time_seconds=1388` | Contador retornado pela API, sem inferir SLA |
| Transferência | `data_transfer_bytes=5027` | Medidor reportado, sem atestar custo |
| Dados escritos | `written_data_bytes=0` | Contador de consumo no período, **não** prova absoluta de ausência de writes em todos os recursos |
| Armazenamento sintético | `synthetic_storage_size=0` | Contador específico, não prova de volume real global ou backup |
| Retenção de histórico | `history_retention_seconds=21600` | 6 horas declaradas, não satisfaz backup independente |
| Conectividade | `block_public_connections=false` | Exige avaliação de segurança; não há hardening comprovado |
| Permissão efetiva da conexão | `ADMIN` | Escopo de privilégio amplo; não habilitar executor factual |

A API **não apresentou neste ato**: cobrança vigente e futura, método de pagamento, extrato financeiro, eventual opção paga, consumo financeiro ou alerta de excedente. As cotas e os contadores são informação parcial, sujeitos à semântica e à atualização do fornecedor. Não afirmar valor de fatura, número de compute-hours gratuitos ou garantia de `US$0` sem evidência documental aplicável.

## 3. Avaliação restrita do BRG-09 e G0-D5

**Fatos agora demonstrados:**
- `NEON_PLAN_IDENTIFIED=FREE_V3`;
- `PROJECT_REGION_IDENTIFIED=AWS_SA_EAST_1`;
- `API_USAGE_COUNTERS_CAPTURED=PARTIAL`;
- `NEON_API_READ_ONLY_INSPECTION=COMPLETED`.

**Informações não observadas e dependentes da console do titular:**
1. existência de método de pagamento, sem compartilhar seus dados;
2. ocorrência de qualquer serviço, recurso ou upgrade pago no projeto/organização;
3. fatura/saldo vigente e exposição a cobrança por excedente, sem publicar dados pessoais;
4. percentuais de quota e avisos de limite segundo o painel, inclusive limites não cobertos pelos medidores recebidos;
5. confirmação da intenção de permanecer no Free e não autorizar cobrança/upgrade.

**Estado:** `BRG-09=PENDING_OWNER_FINANCIAL_CONFIRMATION`; **não PASS**. `G0-D5=PENDING_OWNER`; a informação da API não é manifestação de vontade do titular nem autorização de custo.

## 4. Próximo ato necessário do titular — escopo mínimo

O titular poderá consultar `https://console.neon.tech/` e fornecer **apenas** estas informações, sem capturas de dados financeiros pessoais:

- **Plano exibido:** Free, outro ou não verificado;
- **Serviços pagos ou upgrades ativos:** sim/não/não verificado;
- **Cartão/método de pagamento cadastrado:** sim/não/não verificado, sem número ou detalhes;
- **Exposição a cobrança e limites:** resumo do painel, em linguagem não sensível;
- **Data/hora da conferência:** horário local.

Nenhuma dessas respostas deve ser presumida. Caso painel e API sejam discordantes, manter `BLOCKED` e avaliar antes de qualquer etapa operacional. Se o painel exigir cadastro de cartão, upgrade ou pagamento para obter dados, **STOP**, sem executá-los.

## 5. Fronteira factual e do programa

- Nenhum acesso a SQL, branch, role, migration, artifact, Postgres executor ou aplicação; apenas chamada API de leitura de metadados Neon e GitHub.
- B1R1 `EXPIRED_NOT_EXECUTED`; preflight e primeiras PubMed/ClinicalTrials.gov historicamente não executados; `NEW_EPOCH=NOT_AUTHORIZED`, P-B `NOT_OPERATIONALLY_READY`.
- `BRG-03/06/07/08` permanecem bloqueados; `BRG-04/05` provas históricas/sintéticas. 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles roles insatisfeitos.
- Documentos 137–140 científicos/empíricos permanecem em escopo documental; zero cenários AT de aceitação end-to-end e nenhuma avaliação científica independente. `PHASE_4_DOCUMENTAL_CLOSURE=NOT_READY`; M3 blocked; Fase 5 NOT_STARTED.

## 6. Retomada

**Próximo CP187 candidato, somente após `Prossiga` e Freshness Gate:** confrontar o resumo **não sensível fornecido pelo titular** com os fatos da API e registrar a disposição parcial/final de BRG-09; se não houver dados, documentar `INFORMATION_NOT_AVAILABLE` e não repetir auditorias sem benefício. Qualquer deliberação real de custo, permissão, G0 ou operação exige aviso prévio de **modo alto**, sem início automático.

**STOP após publicação/reconciliação.**
