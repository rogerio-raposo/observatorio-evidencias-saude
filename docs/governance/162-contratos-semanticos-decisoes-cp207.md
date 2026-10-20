# 162 — Contratos semânticos de ativação SEM-01–SEM-06: alternativas e deliberação futura

**OES | CP207 | 2026-10-20 | Fase 4 | modo médio**
**Status:** DRAFT_ONLY / PREPARE_G1_DOCUMENTARY_ONLY. Nenhuma opção selecionada, revisão especializada realizada ou autorização adicional.

## 1. Proveniência
Consolidação A1–A3 pós-CP206: seis questões semânticas; opções e consequências; perguntas decisórias, critérios e responsabilidades de avaliação. Fontes Documentos 159–161, `STATE.md`, migrations 033c/034/035. Freshness Gate de entrada CP206: `3d92b2396825f6cf3e36cdd235684f24e08cf7a0`, identical a main. A3 avaliada em modo alto; consolidação em médio.

## 2. Distinções indispensáveis
**Implementado**: verificações demonstráveis no texto SQL; não implica teste. **Não demonstrado**: efeitos transacionais, concorrência e caminhos operacionais. **Não decidido**: exigências temporais, autoridade e procedimentos. Contrato semântico precede solução técnica; autorização e revisão independentes são etapas separadas.

## 3. Matriz decisória dos seis contratos
| ID | Pergunta | Opções analíticas, não selecionadas | Critério documental de suficiência | Evidência necessária |
|---|---|---|---|---|
| SEM-01 | O que `started_at` representa e quem o define? | instante declarado; capturado pela aplicação; gerado no banco | evento inequívoco, fonte e integridade | proveniência, regras de registro, limites e casos de fronteira |
| SEM-02 | Relação exigida de `p_as_of` com `started_at`? | independentes; tolerância máxima; vinculação à ativação | obsolescência e precedência explicitadas | cronologia, validade diagnóstica e rejeições |
| SEM-03 | Até quando vale a autoridade? | histórica; histórica+corrente; combinada por condição | distinguir requisitos em `started_at` dos correntes | histórico, decisões, alterações e transações |
| SEM-04 | Qual marco encerra a janela? | `started_at`; tempo operacional; múltiplos marcos | desigualdades, igualdade e confirmação definidos | oráculos de fronteira e interleavings |
| SEM-05 | Preflight é obrigatório, e quando expira? | consultivo; obrigatório; obrigatório com revalidação | todos os resultados e caminhos cobertos | fluxo, `PASS/WAIT/FAIL`, obsolescência e auditoria |
| SEM-06 | Quem pode solicitar/efetivar ativação? | updates autorizados; procedimento central; múltiplos caminhos invariantes | atores, interfaces, privilégios e bloqueios verificáveis | inventário de papéis, permissões e audit trail |

As opções que criam obrigatoriedade, restrições correntes adicionais ou significados temporais novos podem **alterar** o contrato vigente, exigindo aprovação apropriada. O estado atual das migrations não demonstra que `p_as_of` e `started_at` sejam vinculados, nem torna o preflight obrigatório; 034 compara autoridade e desvios com `started_at`, 035 avalia janela em `p_as_of`. `CURRENT_TIMESTAMP` é referenciado ao início da transação PostgreSQL e não prova validade até COMMIT.

## 4. Competências e revisão — propostas, não novos poderes
- Responsável pelo projeto: delimitar prioridades, escopo e tramitação perante instância canônica, sem substituir pareceres especializados.
- Revisão científico-metodológica independente: SEM-01–SEM-04, especialmente semântica histórica, consequências científicas e ausência de introdução tácita de SLA/cadência normativa; SEM-05/06 quando houver impacto metodológico.
- Revisão técnica independente: SEM-01–SEM-06 quanto a temporalidade, concorrência, segurança, caminhos de escrita, permissões, prova e rollback.
- Governança/autoridade competente: confirmar atribuições formais antes da deliberação; 12 controles de papéis continuam pendentes. Preparar formulário não constitui voto, parecer ou autorização.

## 5. Critérios transversais de deliberação
Clareza, rastreabilidade ao contrato, testabilidade, compatibilidade com fontes SQL, segurança temporal, reconstrução auditável, preservação da não normatividade e autoridade competente verificada. Decisão futura deve registrar `semantic_contract_id`, `decision_question`, `considered_options`, `existing_contract`, `proposed_change`, `methodological_review`, `technical_review`, `governance_authority`, `decision_record`, `supporting_evidence` e `implementation_authorization`. Pareceres, registros decisórios e autorizações atualmente NOT_COLLECTED/NOT_GRANTED; não inferir aprovações.

## 6. Dependências e prioridade de preparação
Primeiro SEM-01 (instante), depois SEM-02/04 (diagnóstico e janela) e SEM-03 (autoridade), então SEM-05/06 (obrigatoriedade e caminhos). Pode haver análise paralela, sem decisões implícitas. Ensaios V033-06/V035-03 e variantes C04/T03/T04 seguem propostos, sem evidência coletada.

## 7. Controles e continuidade
36 migrations UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de papéis pendentes. BRG-03/06/07/08 BLOCKED, BRG-04/05 históricos, BRG-09 parcial, B1R1 EXPIRED_NOT_EXECUTED, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED. Sem SQL, Neon, CI, consultas factuais, novos epochs ou serviços pagos.

**Próximo Prossiga, A1:** delimitar pacote de encaminhamento documental e pré-requisitos de parecer independente para SEM-01–SEM-06, sem produzir pareceres fictícios nem solicitar decisão operacional implícita. STOP.
