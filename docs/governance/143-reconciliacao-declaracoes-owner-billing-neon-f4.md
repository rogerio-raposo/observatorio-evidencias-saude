# 143 — Reconciliação das declarações do titular com metadados Neon Free

**OES | 2026-10-20 (America/Recife) | CP187 | modo médio**  
**Estado:** `OWNER_FINANCIAL_DECLARATION_RECEIVED_AND_RECONCILED — BRG09_PARTIAL_EVIDENCE — NOT_OPERATIONALLY_APPROVED`.

## 1. Freshness Gate e método

Ponteiro CP186, handoff CP186, Documento 142, STATE e CHANGELOG revisados; HEAD CP186/main `3c236159ab6ceb0c7c02f48542688b70f39f8be7` = identical, ahead/behind 0. A presente avaliação registra somente respostas textuais do proprietário prestadas nesta conversa e as compara com a leitura histórica Neon `describe_project` de CP186. **Não** acessa o painel privado de faturamento e **não** executa SQL.

## 2. Declaração do proprietário e sua origem

O proprietário respondeu, na ordem das quatro perguntas formuladas no fim do CP186: **"sim, não, não, não"**. Interpretação ordinal inequívoca:

| Pergunta | Resposta textual | Grau de evidência |
|---|---|---|
| O painel identifica o plano como Free? | Sim | Declaração direta do titular, sem captura do painel |
| Existem serviços pagos ou upgrades ativos? | Não | Declaração direta do titular, não auditoria de cobrança |
| Existe método de pagamento cadastrado? | Não | Declaração direta do titular, sem dados bancários |
| Há avisos de cobrança ou ultrapassagem de cotas? | Não | Declaração direta do titular; ausência de avisos no momento da verificação relatada |

**Temporalidade:** mensagens prestadas em 20/10/2026, mas sem horário factual individual certificado da inspeção do painel. Não atribuir horário inventado à declaração ou afirmar acesso independente à interface de faturamento.

**Privacidade:** não registrar e-mail, identificador de organização, cartão, CPF, token, credenciais, conexão ou dados pessoais. Este documento registra apenas as quatro observações não sensíveis voluntárias.

## 3. Confrontação com API e conclusão estritamente admissível

O Documento 142 demonstrou via integração Neon `subscription_type=free_v3`, região `aws-sa-east-1`, limite lógico de 1 GiB/branch, limite de 10 branches e contadores de uso parciais. A afirmação **Free** é corroborada por duas naturezas de evidência: resposta da API e informação do titular. As três respostas negativas sobre pagamento, método cadastrado e alertas **não são corroboradas pela API** porque os respectivos campos de billing não estavam disponíveis naquela consulta.

| Dimensão | API (CP186) | Proprietário (CP187) | Resultado |
|---|---|---|---|
| Plano Free | free_v3 | Sim | CORROBORATED_FREE_PLAN |
| Serviços pagos/upgrades | Não observável | Não | OWNER_DECLARED_NO_PAID_SERVICES |
| Método de pagamento | Não observável | Não | OWNER_DECLARED_NO_PAYMENT_METHOD |
| Avisos/ultrapassagem | Não observável | Não | OWNER_DECLARED_NO_WARNINGS |
| Limites e risco de cobrança futura | Limites técnicos parciais | Não especificou termos | NOT_FULLY_VERIFIED |

A declaração atende a **dependência informacional específica** do CP186: obter os quatro esclarecimentos do proprietário. **Não** comprova que o serviço será gratuito indefinidamente, que todos os termos comerciais foram inspecionados, nem que nenhuma fatura pode ser gerada. O risco deve ser reavaliado antes de operações que possam consumir recursos ou exigir cobrança.

## 4. Estado dos controles

- `BRG-09_OWNER_FINANCIAL_DECLARATION=RECEIVED`.
- `BRG-09_EVIDENCE=PARTIALLY_SATISFIED_WITH_OWNER_ATTESTATION`.
- `BRG-09_OPERATIONAL_GATE=NOT_APPROVED` até revisão de limites/termos aplicáveis e decisão explícita do proprietário sobre qualquer operação relevante.
- `G0-D5_INFORMATION_AVAILABLE=YES`; `G0-D5_OWNER_APPROVAL=PENDING`. Responder perguntas factuais **não** equivale a aprovar política de orçamento, delegações ou uso factual.
- `P_B_FACTUAL_PILOT=NOT_AUTHORIZED`; `NEON_FACTUAL_WRITES=NOT_AUTHORIZED`; `NEW_EPOCH=NOT_AUTHORIZED`.

Os demais G0-D1–D4 e D6 permanecem PENDING_OWNER. OBRIGAÇÕES: BRG-03/06/07/08 bloqueados, BRG-04/05 históricos/sintéticos; 36 migrations UNREVIEWED; zero pós-condições aprovadas; 36 evidências 034–036 NOT_COLLECTED; 12 controles de roles não satisfeitos. Sem backup/restore independente, roles minimamente privilegiadas ou executor autorizado.

B1R1 = `EXPIRED_NOT_EXECUTED`; nenhum preflight B1R1, primeira PubMed ou primeira ClinicalTrials.gov realizado. M3 BLOCKED; Fase 4 documental NOT_READY; Fase 5 NOT_STARTED.

## 5. Proporcionalidade e próximo ato candidato

**Ponto solucionado neste CP:** a falta das quatro declarações simples do titular foi resolvida. Não solicitar novamente as mesmas respostas sem razão factual de mudança.

**Candidato CP188, somente após novo `Prossiga` e Freshness Gate:** avaliar de forma consolidada e documental a **decisão G0 mínima** para o piloto P-B a partir das evidências já obtidas, sem prolongar sucessivamente a coleta de comprovantes financeiros nem executar Neon. Se for necessário pedir aprovação efetiva de orçamento/risco, responsabilidades e operação, avisar **antes** que modo alto é apropriado e apresentar um escopo decisório delimitado.

Nenhum recurso foi modificado em CP187, nenhuma consulta PubMed/ClinicalTrials.gov, nenhum SQL, CI, pagamento, migração ou novo epoch.

**STOP após reconciliação do commit.**
