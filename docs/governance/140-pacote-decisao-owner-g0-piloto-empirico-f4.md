# 140 — Pacote G0 de decisão do proprietário para futuro piloto empírico P-B

**OES | Fase 4 | 2026-10-20 (America/Recife) | CP184 | modo médio**  
**Natureza:** proposta documental para futura deliberação, sem decisão substantiva presumida.  
**Status:** `G0_OWNER_DECISION_PACKAGE_PREPARED — OWNER_DECISION_PENDING — NO_FACTUAL_AUTHORIZATION`.

## 1. Continuidade e finalidade

Freshness Gate CP183/main: `dba90c228bc2920f35ef687af368e0bd9a43beda`, identical, ahead/behind 0. Template, ponteiro e handoff CP183, Docs 107/110/139, STATE e CHANGELOG consultados. O usuário autorizou apenas `Prossiga` para preparar G0, mantendo modo médio até uma decisão efetiva sobre custo, risco, novos recursos ou autoridade temporal.

Objetivo do G0: apresentar ao proprietário uma **decisão compacta e verificável** sobre a finalidade, limites e governança do futuro piloto de primeiras medições reais PubMed/ClinicalTrials.gov — **P-B**, distinto de **P-A**, eventual ensaio de interfaces públicas sem persistência factual. A decisão G0 não é aprovação de execução: G1–G5 e gates ODB/BRG continuam independentes.

## 2. Elementos que podem ser recomendados sem presumir consentimento

| Dimensão G0 | Proposta para deliberação | Limite / condição |
|---|---|---|
| Objetivo | Priorizar P-B: duas primeiras observações prospectivas factuais, uma por fonte, em experimento não normativo finito | Não transformar automaticamente em vigilância contínua, living/M3 ou cadence normativa |
| Alvo | Preservar TOPI-N2-DCBTI-01 como contexto candidato, pendente confirmação da relevância e da versão científica atual | Não reutilizar UUIDs de epoch/Opportunity B1R1, nem sua authority caducada |
| Conjunto de dados | Metadados públicos mínimos: identificador PMID/NCT, fonte/endpoint, query/interface congeladas, instante, status e contagens, page/token metadata quando pertinente, referência a response/artifact e hashes | Excluir dados pessoais de pacientes, PHI, credenciais, tokens de autenticação e conteúdo sensível; avaliar termos e retenção |
| Modalidade | Preparação de pequeno piloto persistente P-B em Neon Free **somente como candidato** | Aprovação histórica foi para sandbox synthetic-only, não autorização factual |
| Operador | Definir pessoa responsável pelo ato operacional e por incidentes; executor com role restrita distinta do owner administrativo | Nenhuma delegação, role ou credencial está aprovada neste pacote |
| Evidência | Registro íntegro de tentativa, resposta, status completed/partial/failed/indeterminate e provenance externa ao executor | MeasurementEvent só após request factual autorizada; primeiro `new_to_epoch` não indica materialidade científica |
| Recuperação | Definir operador, retenção, backup independente e restore verificável antes de persistência factual | Histórico de snapshots do Neon não substitui backup externo independente |
| Custo | Preferência por plano Free e zero serviços pagos; conferir cotas, billing, alertas e eventuais limites no painel pessoal | Não inferir garantia de US$ 0, não cadastrar cartão nem autorizar upgrade |
| Ciência e revisão | Após coleta, separar observação/novidade de appraisal e decisão de atualização; revisão humana qualificada quando exigida | IA ou proprietário não podem ser contabilizados como expert reviewer por ficção |
| Tempo | Selecionar nova janela futura **somente após** readiness e aprovação específica de desenho/activation | B1R1 expirado em 2026-10-19; sem backdate ou alteração de 14 Opportunities antigas |

As opções acima são **candidatas**: não foram aprovadas pelo usuário, e não criam obrigação financeira ou alteração de permissões.

## 3. Decisões que precisam de manifestação expressa do proprietário

| Código | Questão decisória | Sugestão de preparação | Estado |
|---|---|---|---|
| G0-D1 | Confirmar se o objetivo imediato é P-B com armazenamento factual de duas fontes | Propor P-B pequeno, não normativo, sujeito a gates | PENDING_OWNER |
| G0-D2 | Confirmar metadados permitidos, ausência de PHI e política de retenção | Minimização estrita, sem dado identificável de pacientes | PENDING_OWNER |
| G0-D3 | Confirmar custódia/capacidade de operar backups e arquivos fora do Neon | Exigir destino independente e restore; não escolher serviço externo sem consentimento | PENDING_OWNER |
| G0-D4 | Confirmar responsabilidade por execução, segurança e incidentes | Nomear funções/competências; nenhum especialista presumido | PENDING_OWNER |
| G0-D5 | Confirmar política de custo e consumo Neon Free | Limite de custo zero como preferência; verificar cobrança/cotas em painel | PENDING_OWNER |
| G0-D6 | Autorizar ou não **somente** abertura futura do gate G1 técnico, sem executar SQL | Decisão específica posterior após escopo/custo; nenhuma mutação agora | PENDING_OWNER |

**Regra:** nenhuma célula PENDING_OWNER pode ser substituída por `Prossiga` genérico. Para aprovação de finalidade factual, custo/quotas, responsabilidades por dados e eventual passagem a G1 com operações persistentes, recomendar **modo alto** e uma decisão identificada por código, escopo e negativas explícitas. A mera publicação do pacote não autoriza G0 nem G1.

## 4. Critérios de saída do G0 — proposta, não gate executado

- **G0-01:** finalidade P-B e exclusões P-A/B1R1 expressamente compreendidas, com confirmação do titular;
- **G0-02:** tipos de dados, fonte e retenção delimitados, sem PHI;
- **G0-03:** papel do operador e responsável pelo incidente/backup definido, sem identidade artificial;
- **G0-04:** custo/teto, cotas, cobrança e eventual diferença de serviços explicitados pelo titular;
- **G0-05:** recuperação fora do Neon planejada, evidência futura de restore exigida e sem destino externo inventado;
- **G0-06:** minuta de autorização, se houver, distingue `PREPARE_G1`, `NEON_MUTATION`, `NEW_EPOCH`, `SOURCE_QUERY` e `FACTUAL_PERSISTENCE`, todas separadas;
- **G0-07:** calendário **não definido** até validação da infraestrutura e risco de expiração reduzido.

**Resultado deste CP:** `G0_PACKET_COMPLETE_DOCUMENTARY_ONLY`, **G0_OWNER_APPROVAL=NOT_GRANTED**, P-B `NOT_OPERATIONAL_READY`. Nenhuma das decisões D1–D6 foi tomada nesta conversa.

## 5. O que um futuro ato aprovado não poderia dispensar

| Gate | Bloqueio preservado |
|---|---|
| ODB-01–12 | Só passar quando os controles aplicáveis forem observados e auditados no ambiente real |
| BRG-03 | Isolamento de roles, TLS, segredos, auditoria externa e DDL privilegiado |
| BRG-04/05 | Provas antigas sintéticas não são prova do Neon atual |
| BRG-06/07 | Ledger de migrações e supervisor/fencing/runner ainda não operacionais |
| BRG-08 | Backup e restore independente não configurados |
| BRG-09 | Titular ainda deve conferir plano/custo |
| Migrações | 36 UNREVIEWED, zero pós-condições aprovadas; 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos |
| Temporal | B1R1 EXPIRED_NOT_EXECUTED; sem novo epoch/Opportunity aprovado |
| Ciência | AT-01–AT-12 definidos no Documento 137 e runbook Documento 138, mas zero execuções integradas/parecer independente; nenhuma cadence normativa; M3 bloqueado |

## 6. Modelo compacto de decisão futura — não assinado

```text
OES / G0 / owner — FUTURE DECISION DRAFT, NOT APPROVED
reference: Documento 140 / CP184
objective: P-B first prospective PubMed + ClinicalTrials.gov measurements
target: TOPI-N2-DCBTI-01 — confirm version and scope
allowed_data: minimal public metadata only, no PHI
hosting: existing Neon Free as conditional candidate; factual use not yet authorized
budget: no paid services; verify live limits/billing in owner console
retention/backup: independent storage and restore, responsible human to be identified
operators: to be named; privileged roles separated from runtime
authorization_request_scope: choose separately PREPARE_G1 or other limited act
explicit_non_authorizations: Neon SQL/branch/migrations/roles, new epoch,
  B1R1 backdating, source query, MeasurementEvent, billing upgrade,
  scientific publication, M3, Phase 5
owner_decision_and_date: PENDING
```

A aprovação de um **G0 preparado** não deverá ser interpretada como autorização para criar conta, alterar Neon, provisionar serviços, rodar buscas específicas ou iniciar epoch. Cada autorização depende de manifestação factual do titular.

## 7. Fechamento do CP184 e próximo ponto

**CP184:** pacote de decisão G0 documentado e pronto para futura deliberação, sem resolver os bloqueios. Candidato CP185 (não iniciado): revisão de viabilidade/priorização dos bloqueios restantes e proposição de **um único próximo ato de baixo risco** compatível com orçamento zero; **antes de solicitar aprovação real do owner sobre G0, sinalizar mudança para modo alto se o conteúdo envolver risco, custódia, infraestrutura ou custos**.

Não presumir que nova rodada extensa de testes PG18 seja necessária: Documento 135 exige utilidade decisória concreta.

**STOP após commit, reconciliação e novo `Prossiga`.**
