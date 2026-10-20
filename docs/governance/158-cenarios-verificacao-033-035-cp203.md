# 158 — Cenários e oráculos de verificação para migrations 033–035

**OES | CP203 | 2026-10-20 | Fase 4 | modo médio**
**Status:** DRAFT_ONLY, preparação documental sob `PREPARE_G1_DOCUMENTARY_ONLY`.

## 1. Escopo e método
Consolida atividades A1 (critérios), A2 (12 cenários candidatos e evidências), A3 (fixtures, oráculos, concorrência e cobertura) posteriores ao Documento 157/CP202. Fontes SQL examinadas: `database/033b_temporal_measurement_core.sql`, `033c_temporal_observation_guards.sql`, `034_temporal_observation_activation_chronology.sql`, `035_temporal_observation_activation_preflight.sql`. Sem SQL executado, consulta Neon, CI, PubMed/ClinicalTrials, novo epoch, alteração do catálogo ou gasto.

## 2. Doze cenários candidatos
| ID | Objetivo | Oráculo esperado | Categoria principal |
|---|---|---|---|
| V033-01 | Inserção draft com desenho ativo | Aceita somente com pré-condições válidas | comportamental |
| V033-02 | Inserção/transição de epoch inválida | Rejeição e estado anterior íntegro | comportamental |
| V033-03 | Tentativa com `attempt_no` não consecutivo | Rejeição | comportamental |
| V033-04 | Tentativa após resolução/conclusão prévia | Rejeição e ausência de evento persistido | comportamental |
| V033-05 | UPDATE/DELETE de linha histórica imutável | Rejeição e dados inalterados | comportamental |
| V033-06 | Duas inserções concorrentes na mesma oportunidade | Unicidade, sequência e integridade final | transacional/concorrente |
| V034-01 | Ativação antes da primeira oportunidade com autoridade válida e sem desvio | Aceitação condicionada a todas as guardas | comportamental |
| V034-02 | `started_at` igual ou posterior à primeira oportunidade | Rejeição | comportamental |
| V034-03 | Autoridade inválida ou desvio impeditivo em `started_at` | Rejeição | comportamental |
| V035-01 | Funções, assinaturas, atributos, códigos e agregação | Identidade estática conforme fonte | estática |
| V035-02 | Preflight com verificação impeditiva | FAIL, e precedência FAIL > WAIT > PASS | comportamental |
| V035-03 | Mudança material entre preflight e ativação | Nenhuma ativação indevida persistida | transacional/concorrente |

Todos são **propostos**, não resultados executados. As categorias indicam método dominante, podendo exigir inspeção auxiliar.

## 3. Fixtures e oráculos aprofundados
### V033-06
Pré-condições: epoch `active`, target atual, oportunidade não resolvida, `effort_payload` válido, tentativas prévias consistentes. Duas sessões concorrentes propõem o mesmo próximo `attempt_no`. O código 033c usa `max(attempt_no)` e a tabela 033b declara `UNIQUE(measurement_opportunity_uuid,attempt_no)`. Oráculos: (i) nunca duas tentativas confirmadas com a mesma chave; (ii) após término, nenhuma lacuna ou tentativa após conclusão/resolução indevida; (iii) resultados, erros e estado final de ambas as transações registrados. Incluir uma variante de disputa append × resolução. Unicidade isolada não prova serialização completa do lifecycle. Definir nível de isolamento, interleaving, rollback e descarte do ambiente antes de autorização.

### V035-03
Pré-condições: epoch `authorized_non_normative`, materialização válida, sem eventos pré-ativação, janela ainda aberta, preflight inicialmente favorável. Uma segunda sessão altera autoridade, desvio ou outra condição material entre consulta e tentativa de ativação. Registrar `p_as_of`, `started_at`, momento de decisão e instante de confirmação. A migração 034 exige autoridade `approved` em `started_at` e nenhuma alteração impeditiva registrada até esse instante; a 035 consulta em `p_as_of` e é **consultiva**, sem gatilho obrigatório. Oráculos: nunca persistir ativação que viole as condições exigidas pelo contrato temporal ou demais guardas; resultado PASS do preflight por si só não satisfaz o critério de integração. Testar mudanças antes/depois de `started_at`, sem presumir equivalência de relógios ou mecanismo de travamento existente. A obrigatoriedade operacional de preflight é lacuna ainda aberta.

## 4. Cobertura
| ID | Estática auxiliar | Comportamental principal | Transacional/concorrente principal |
|---|---|---|---|
| V033-01 a V033-05 | sim | sim | não, ressalvada extensão V033-04 |
| V033-06 | sim | necessário | sim |
| V034-01 a V034-03 | sim | sim | não, ressalvada extensão V034-03 |
| V035-01 | sim (principal) | não | não |
| V035-02 | sim | sim | não |
| V035-03 | sim | necessário | sim |

Propor registro por cenário: `scenario_id`, `requirement_id`, commit e SHA-256, fixtures, isolamento, ação, expectativa, observação, estado final, limpeza, autorização, executor, instante e revisão independente. `observed_result` permanece NOT_COLLECTED. Os ensaios requerem ambiente descartável e autorização operacional explícita, inclusive para SQL somente leitura.

## 5. Riscos e limites
Permanecem abertos: níveis de isolamento adequados, disputa append × resolução, correlação entre `p_as_of` e `started_at`, e mecanismo operacional que torne o preflight obrigatório; nenhum mecanismo corretivo foi escolhido. Diferenciar corretude isolada de trigger, preservação de invariantes sob concorrência e imposição do fluxo operacional. Não promover DRAFT para REVIEWED com base nestas tabelas.

## 6. Bloqueios e retomada
36 migrations UNREVIEWED; zero pós-condições aprovadas; 36 requisitos 034–036 NOT_COLLECTED; 12 roles pendentes. BRG-03/06/07/08 BLOCKED; BRG-04/05 históricos; BRG-09 parcial; B1R1 EXPIRED_NOT_EXECUTED, M3 bloqueado; Fase 4 NOT_READY; Fase 5 NOT_STARTED.

Próximo bloco A1 sob novo `Prossiga`: analisar criticamente, somente em documentos, os limites de cobertura e as pré-condições de autorização para os cenários V033-06 e V035-03, sem implementar ou executar testes.

**STOP.**
