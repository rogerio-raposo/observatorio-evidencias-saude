# 144 — Consolidação da proposta G0 do piloto factual PubMed/ClinicalTrials.gov

**OES | Fase 4 | 2026-10-20 (America/Recife) | CP188 | modo médio**  
**Estado:** `G0_DECISION_PROPOSAL_CONSOLIDATED_NOT_APPROVED`. Avaliação documental, **sem consentimento presumido, mutação Neon, autorização de custos, source query ou epoch**.

## 1. Continuidade e fundamento

Freshness Gate CP187/main no SHA `cea01ebe0aa3fb3721369e1aa80d233d01046e03`, identical, 0 ahead/behind. Template, ponteiro e handoff CP187, Documento 140 (G0 inicial), Documento 143 (evidência financeira parcial), STATE e CHANGELOG verificados. Um único `Prossiga` autoriza apenas este checkpoint documental. O modo médio é suficiente para elaborar proposta; a aprovação efetiva de riscos, permissões, recursos e custos exigirá comunicação prévia de que modo alto é apropriado.

## 2. Problema decisório

A finalidade estratégica P-B continua ser realizar **primeiras medições factuais prospectivas de PubMed e ClinicalTrials.gov**, preservadas nos pacotes históricos Docs 94–95, em novo epoch e com um banco persistente adequadamente habilitado. O sandbox Neon Free existente não está operacionalmente pronto. O antigo B1R1 expirou, sem preflight, activation ou primeira medição; não recuperar as 14 oportunidades por backdating.

Este documento consolida **as decisões necessárias**, não as toma. Evita solicitar novamente informação já fornecida sobre pagamento.

## 3. Quadro G0-D1–D6 com evidência e lacuna final

| Código | Proposta para decisão | Evidência já reunida | Pendência de aprovação |
|---|---|---|---|
| G0-D1 | P-B pequeno, finito, uma primeira medição por fonte, sem M3 e sem calibre normativo temporal | Docs 94/95/138–140; prioridade estratégica declarada | Owner confirma o **escopo** e diferencia P-A não persistente |
| G0-D2 | Somente metadados públicos mínimos de PMID/NCT, request/status/timestamps, hash e provenance; excluir PHI | Modelo de minimização Doc 140, sem dados factuais processados | Owner aprova classe de dados e retenção, sem alegar parecer jurídico/científico |
| G0-D3 | Armazenamento de artifacts e backup **independente** com restauração demonstrada antes da persistência factual | BRG-08 pendente; nenhuma configuração ou restore real | Definir custódia, destino tecnicamente permitido, responsabilidades e prova de restore; serviço externo não escolhido |
| G0-D4 | Owner responde por decisões de governança; operador técnico identificado executa somente atos autorizados; reviewer humano qualificado avalia ciência onde exigido | Doc 04, runbook 138, modelos de roles e auditoria | Papéis humanos reais e competência/segregação ainda não designados |
| G0-D5 | Preferência por Neon Free, orçamento sem serviços pagos e interrupção antes de qualquer upgrade/cobrança | API `free_v3` em CP186; titular declarou Free, nenhum pago, nenhum cartão, nenhum aviso em CP187 | Definir **política de orçamento** e verificação de limites atualizados antes de operação; `BRG-09` não aprovado e não há garantia contratual de custo zero |
| G0-D6 | Permitir eventualmente **somente** preparar G1 técnico sob escopo escrito separado, sem automaticamente autorizar Neon SQL, migração ou novo epoch | Matriz ODB-01–12 Doc 139 e histórico BRG | Manifestação expressa do owner para `PREPARE_G1`, com limites e exclusões |

**Situação de todas as células:** `PENDING_OWNER_DECISION`. A evidência de D5 está disponível para deliberação, mas a decisão sobre orçamento **ainda não** foi tomada.

## 4. Menor decisão futura potencialmente suficiente

**Proposta, não aprovação:** caso o proprietário concorde com o objetivo, permitir apenas `PREPARE_G1_DOCUMENTARY_ONLY` para mapear a cadeia mínima de migrations e os controles de backup/roles, sem custo e sem ações Neon. Essa preparação pode ser executada em modo médio, após autorização específica, mas **qualquer execução persistente, desenho de autoridade de uso factual, decisão financeira ou permissão real exige discussão/decisão em modo alto**.

**Alternativa admissível:** o proprietário pode recusar ou adiar P-B, mantendo a frente como `STRATEGIC_PENDING` e priorizando G1–G6 científico-funcionais. **Não** tratar proposta como compromisso do proprietário.

**Condição contra burocracia:** não repetir evidência CP186/CP187 e não produzir mais pacotes G0 semelhantes sem demanda decisória nova; o próximo checkpoint deverá resolver dependência concreta ou oferecer a deliberação expressa ao titular, não converter ausência de autorização em novo ciclo circular de documentos.

## 5. Gate de entrada futuro antes de qualquer D1 real

- `BRG-03` TLS/segurança/roles/auditoria: BLOCKED.
- `BRG-04/05` históricos/sintéticos: NOT_OPERATIONAL_PROOF.
- `BRG-06` migration ledger: BLOCKED; `BRG-07` supervisor/fencing/runner: BLOCKED.
- `BRG-08` backup independente/restore: BLOCKED; `BRG-09` evidência owner partial, OPERATIONAL_GATE_NOT_APPROVED.
- 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos.
- `OPERATIONAL_DATABASE_READY=NO`; `NEON_FACTUAL_WRITES=NOT_AUTHORIZED`; `NEW_EPOCH=NOT_AUTHORIZED`; `SOURCE_QUERY=NOT_AUTHORIZED`.
- AT-01–AT-12 do Documento 137 não executados end-to-end; nenhum parecer científico independente. M3 BLOCKED, `PHASE_4_DOCUMENTAL_CLOSURE=NOT_READY`, Fase 5 NOT_STARTED.

## 6. Decisão do CP e próxima retomada

**CP188:** `G0_PROPOSAL_CONSOLIDATED_DOCUMENTARY_ONLY`; owner approval `NOT_GRANTED`. Nenhuma consulta a Neon, SQL, CI/PG18, PubMed ou ClinicalTrials.gov, nenhum gasto e nenhuma configuração operacional.

**CP189 candidato, apenas após novo `Prossiga` e Freshness Gate:** apresentar a **deliberação objetiva ao proprietário** entre (a) autorizar exclusivamente `PREPARE_G1_DOCUMENTARY_ONLY` sob custo zero, (b) adiar P-B e avançar lacunas científico-funcionais, ou (c) propor escopo ajustado. Antes de uma aprovação substantiva que abranja orçamento, custódia ou operação, recomendar modo alto. **Não executar G1 operacional por inferência.**

**STOP.**
