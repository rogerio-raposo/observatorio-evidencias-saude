# Documento 209 — D1/T2-A2: proposta restrita P1 e revisão final de segurança (CP234)

**OES | 2026-10-22 | P1_RESTRICTED_SCOPE_DEFINED — APPROVAL_PENDING | T2-A2 NOT_AUTHORIZED**

## 1. Origem e alcance

Consolida as atividades A1–A3 posteriores ao CP233: avaliação documental de suficiência P1; inspeção **somente dos contratos das ferramentas**, sem invocação Neon; revisão final adversarial de minimização, custos e autorização. Fontes canônicas: Documentos 200, 202–208 e handoff CP233. A aprovação A2-G1 do Documento 207 permanece estritamente arquitetural/documental condicionada. Este documento não autoriza acesso ao Neon nem substitui decisão do proprietário.

## 2. Escopo administrativo permitido na proposta — allowlist mínima

Projeto único: `oes-d1-t2-a2-synthetic`, ID `tiny-pond-20086371`; branch histórica `synthetic-main`, ID `br-divine-grass-b63wlpcb`; banco esperado `oes_t2a2_synthetic`, região histórica `aws-sa-east-1`. Identidades deverão ser confirmadas mediante eventual autorização de consulta; dados históricos não comprovam o estado atual.

| Ferramenta Neon | Parâmetros que deverão ser explícitos | Finalidade |
|---|---|---|
| `describe_project` | `project_id=tiny-pond-20086371` | Identidade, configuração, plano e uso que os metadados disponibilizarem |
| `get_branch` | `project_id=tiny-pond-20086371`, `branch_id=br-divine-grass-b63wlpcb` | Identidade, estado administrativo e proteção da branch, quando disponíveis |
| `get_postgres_database` | `project_id=tiny-pond-20086371`, `branch_id=br-divine-grass-b63wlpcb`, `database_name=oes_t2a2_synthetic` | Confirmar identidade administrativa do banco |

No máximo uma invocação de cada ferramenta, sem repetição ou expansão automática. Embora seus contratos descrevam leitura, a ferramenta pode devolver registros completos sem seleção de campos; filtrar **o relatório e qualquer saída de evidências**, nunca alegar minimização na origem. A ausência de campos relevantes permanece `UNVERIFIED`.

## 3. Ferramentas excluídas e fronteira de operações

`list_postgres_endpoints` fica excluída do escopo inicial por retornar endpoints do projeto inteiro sem filtro por branch; `get_postgres_endpoint` também, pois exige endpoint identificado e pode ampliar a coleta. Excluem-se: `list_projects` e inventários de outros projetos; `list_project_permissions` e `list_project_members` (dados pessoais e alcance desnecessário); `get_connection_string` (segredos); `run_sql`, `describe_branch`, `get_database_tables`, `inspect_database` e demais ferramentas que acessam PostgreSQL; criação, alteração, restauração, exclusão, início, suspensão ou reinício de recursos; SQL/DDL/DML/GRANT, roles, infraestrutura, autenticação, CI, adaptador e testes. Nenhuma inferência de que P1 detecta objetos, ACL ou integridade PostgreSQL é válida.

## 4. Revisão adversarial final R1–R4

| ID | Achado e tratamento |
|---|---|
| R1 | As ferramentas retornam registros potencialmente amplos: restringir valores registrados, não reivindicar filtragem no servidor |
| R2 | Listagem de endpoints pode incluir outras branches: excluir os dois métodos de endpoints da autorização inicial |
| R3 | Projeto Free e uso reportado não bastam para comprovar quotas organizacionais, ausência de cobrança e ativação gratuita: condição financeira prévia, sem inferir custo zero |
| R4 | Campos ausentes, extras ou sensíveis não justificam novas consultas: STOP, classificação `UNVERIFIED`, nenhuma reprodução de segredos |

Nenhuma ferramenta Neon foi executada durante a inspeção. O exame do contrato não verifica o efeito real, as quotas nem a segurança econômica da chamada.

## 5. Condições anteriores à deliberação e execução eventual

O protocolo deve exigir: Freshness Gate; aprovação explícita do proprietário apenas para P1; confirmação documental suficiente sobre inexistência de contratação/consumo pago ou de risco financeiro não autorizado; identidade exata do projeto; restrição a três consultas sem SQL ou compute iniciado deliberadamente; nenhum acesso a outro projeto; nenhum segredo, senha, token, connection string ou registro de aplicação publicado; resultados mínimos com fonte, data/hora, parâmetros autorizados e status `PASS`, `FAIL` ou `UNVERIFIED`. Se a condição financeira não puder ser demonstrada com suficiência, **não executar P1**; não usar o próprio P1 para contornar uma exigência financeira prévia sem deliberação própria.

STOP diante de HEAD divergente, projeto/branch/banco inesperado, operação fora da allowlist, indicação de cobrança ou upgrade, recurso inesperado, informação sensível, resposta incompleta para controle bloqueante ou acesso que ultrapasse o escopo. Não disparar repetição automática após erro. Operações apenas de leitura não provam custo ou efeito indireto nulos.

P1 não autoriza P2 (catálogos PostgreSQL por sessão SQL), E (DDL estrutural), A2-G3 (GRANTs), A2-G4 (adaptador), A2-G5 (testes), novas CI, novos papéis, consumo pago, dados reais, acesso a `oes-sandbox` ou mudança de qualquer gate. F01–F07 continuam somente endereçados documentalmente; L1–L4 e PA-01–PA-08 mantêm suas exigências pertinentes. N1-E3 confirmou TLS no trecho do cliente ao endpoint; `pg_stat_ssl.ssl=false` no backend não confirma segurança de segmentos internos; não utilizar `oes_t2a2_runtime`.

## 6. Minuta restrita — NÃO APROVADA

> **PROPOSED — OES / D1-T2-A2 / A2-G2-P1 / RESTRICTED_NEON_ADMIN_METADATA_PREFLIGHT** — Autorizar exclusivamente uma verificação administrativa pontual de metadados do projeto `tiny-pond-20086371`, mediante no máximo uma chamada a cada uma das ferramentas `describe_project`, `get_branch` e `get_postgres_database`, com os identificadores fixos acima, **somente após demonstradas as condições financeiras e de segurança prévias**. Registrar saída filtrada e rastreável, sem segredos; classificar resultados `PASS/FAIL/UNVERIFIED`. Proibir listas amplas, endpoints extras, conexão PostgreSQL, SQL, alterações, CI, dados reais e custos pagos. Nenhuma repetição, ampliação ou autorização de P2/E está implícita. STOP ante divergência ou risco. **PROPOSTA NÃO APROVADA, NÃO EXECUTÁVEL POR PUBLICAÇÃO.**

## 7. Situação e continuidade

A2-G1 `CONDITIONAL_DOCUMENTARY_DESIGN_APPROVED`; P1 `NOT_AUTHORIZED`; P2 `NOT_AUTHORIZED`; E `NOT_AUTHORIZED`; T2-A2 `NOT_AUTHORIZED`. T1 `CLOSED_SYNTHETIC_LOCAL_ONLY` (36 PASS históricos), T2-A1 `CLOSED_SYNTHETIC_IN_MEMORY_ONLY` (75 PASS históricos). Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`; 36 migrações `UNREVIEWED`. Prioridade D0 editorial/documental encerrado → D1 protótipo sintético → D2 factual futuro → governança posterior.

**Próximo Prossiga:** avaliação delimitada das condições prévias e da minuta P1, para eventual decisão expressa do proprietário **sem presumir aprovação** e sem acessar Neon. Documento e checkpoint não autorizam nenhum novo recurso/serviço, SQL, CI ou gasto. **STOP.**
