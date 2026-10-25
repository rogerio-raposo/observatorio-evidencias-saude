# Documento 306 — PF-I02-A2: contrato mínimo de escrita preparatória e acesso

**Data:** 2026-10-25. **Natureza:** proposta técnico-funcional para deliberação; **não autoriza implementação, escrita SQL, criação de usuários ou implantação**. **Base:** CP297, Documento 300, protocolo 03, templates Question/Routing e `database/poc-s1.sql`.

## Objetivo e delimitação
Permitir futuramente que pessoa autenticada e autorizada registre Q0, prepare versões Q1 e Q2 e justifique admissibilidade e roteamento E0–E8. A preparação **não** cria Investigation nem aciona E9, busca, triagem, síntese ou produto. O requisito de identidade do autor é operacional; não se confunde com revisão científica A3.

## Matriz mínima de capacidades e autoridades propostas
| Papel lógico | Criar Q0 | Propor Q1/Q2 | Propor routing | Autorizar E9 |
|---|---|---|---|---|
| Leitor/consultante | Não | Não | Não | Não |
| Preparador autenticado | Sim | Sim | Sim | Não |
| Governança autorizada | Consultar/auditar; corrigir via nova versão e justificativa | Revisar proposta, conforme política | Revisar proposta | **Não por força deste contrato** |
| Revisor científico | Função futura, não atribuída automaticamente | Função futura | Função futura | Depende de gate próprio, ainda não definido |

Papéis acima são requisitos lógicos, **não** grants, grupos Django, contas criadas ou competências científicas presumidas. Negar acesso por padrão. A autenticação real e segregação de permissões precisam ser homologadas antes de permitir escrita HTTP.

## Identidade, campos e versionamento
- Q0: preservar bytes/texto original sem reescrever silenciosamente, ID único OES-Q-AAAA-NNNN e origem/data/autoria auditáveis.
- Q1: normalização proposta, com autor, justificativa, timestamp e referência à versão anterior.
- Q2: formulação operacional proposta, incluindo elegibilidade/desfechos/janela/metodologia quando aplicáveis; nunca caracterizar como protocolo aprovado.
- Admissibilidade E2: uma das classificações do template, razão obrigatória, decisão em versão associada.
- Routing E5–E8: classes, dimensões qualitativas, profundidade N0–N4, manutenção M0–M3, produto candidato e justificativa obrigatória; sem score automático.
- Revisões: imutabilidade lógica de versões já emitidas, nova versão em toda alteração substantiva, comparação e audit trail. Escrita transacional/concorrência e controle de unicidade devem ser comprovados antes de conexão real.

## Estados lógicos preliminares (não esquema de banco aprovado)
`DRAFT_Q0` → `PREPARED_Q1` → `PREPARED_Q2` → `ROUTING_PROPOSED` → `PENDING_REVIEW`. `HOLD` para falhas, divergências ou falta de permissão. Estados representam **somente preparação**; `APPROVED_FOR_E9` e a transição de abertura **não fazem parte de PF-I02**. Nenhuma transição automática a `investigation.investigation`.

## Mapeamento ao legado e lacunas
O modelo PoC já possui `core.entity`, `core.entity_version`, `investigation.question` e `investigation.question_version` para identidade e versão; `investigation.investigation_version` e `investigation.investigation_question` servem ao contexto de uma investigação, não devem ser usados para fingir que E9 foi aprovada. `question_version` apresenta `original_text` e `normalized_text`, mas não demonstra campo tipado e governado de Q2 nem decisão E2/routing com autorizador e trilha. **Não assumir cobertura total** do contrato nem criar tabelas antes de decisão de adaptação. O Django atual tem `DATABASES={}` por padrão, sem autenticação operacional habilitada; PG-A4 é leitor sintético opcional, impróprio para PF-I02 write path.

## Critérios candidatos de aceite
- I02-AC01: somente autor autenticado e permissão explícita podem iniciar/alterar preparação; usuários não autorizados recebem negação sanitizada.
- I02-AC02: Q0 permanece íntegra após normalizações; identificador e autoria não se perdem.
- I02-AC03: versões monotônicas/auditáveis, rejeição de conflito concorrente e rollback transacional quando aplicável.
- I02-AC04: admissão E2 e justificativa persistem vinculadas à versão certa.
- I02-AC05: roteamento proposta/documentado, sem conversão automática para abertura.
- I02-AC06: operação E9 e criação de Investigation não acessíveis pelo fluxo, inclusive chamadas diretas/negativas.
- I02-AC07: leitura após escrita apenas por autorizados, segregação de registros conforme política.
- I02-AC08: auditoria de autor/data/mudança e falhas; mensagens sem vazamento de credenciais/dados.
- I02-AC09: CI técnica com cenários positivos/negativos e regressões PF-I01 e Django.
- I02-AC10: nenhuma captura factual, alteração de produtos científicos, serviço pago ou deploy implícito.

## Gates antes de código e operações conectadas
1. Selecionar o menor caso de uso Q0→Q1 (sem exigir Q2+routing na primeira entrega), especificar papel operacional e política de privacidade dos textos submetidos.
2. Decidir autenticação, permissões e se o piloto será local ou hospedado; avaliar diferimento anterior de duas autenticações e sua pertinência antes de liberar acesso.
3. Fazer comparação específica entre contratos PoC e modelo Django; decidir persistência real e tratamento de concorrência. **Sem criar mecanismo paralelo de arquivos como produção improvisada.**
4. Autorizar expressamente incremento, arquivos afetados, testes, ambiente e qualquer ação PostgreSQL/Neon isoladamente.
5. Não ampliar E9, A3 ou readiness por aprovação dos testes de preparação.

## Recomendação
**PF-I02-A3:** inventário focado de autenticação/autorização e persistência no Django/Neon, visando propor um primeiro incremento `Q0+Q1` verificável. Priorizar integração funcional real; evitar novo demonstrador apenas em memória, novos frameworks ou extensões documentais sem uso concreto.

**Invariantes:** Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; E9 NO-GO; pesquisadores indisponíveis e A3 não executada.
