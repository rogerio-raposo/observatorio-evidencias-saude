# 90 — Decision Tables de Contingência Operacional do Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **PRE-SPECIFIED — CONTINGENCY_READY**  
**Modo:** médio  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 77, 78, 82, 87–89; migrations 033–036; CP133  
**Objeto:** pré-especificar respostas operacionais a contingências plausíveis de activation, source execution, retry, deviation e Opportunity closure sem criar nova semântica física.

## 1. Princípio

Quando ocorrer uma contingência:

> **preservar fatos, não improvisar semântica.**

A resposta operacional deve usar apenas:

- activation preflight `PASS|WAIT|FAIL`;
- `execution_status` existente;
- `failure_attribution` existente;
- `deviation_type` existente;
- `materiality` existente;
- `resolution_status` existente.

Se o caso exigir algo fora desse vocabulário:

> **STOP → RETURN TO HIGH MODE**

## 2. Activation — relógio antes da janela

Condição:

`CURRENT_TIMESTAMP < 2026-10-19T08:00:00-03:00`

Preflight esperado:

> **WAIT**

Ação:

- não criar activation artifact factual;
- não criar SQL de activation;
- não preencher `started_at`;
- não executar source query;
- aguardar nova avaliação factual.

Proibido:

- usar horário futuro preparado;
- “pré-ativar” por conveniência;
- usar start boundary como se fosse fato observado.

## 3. Activation — dentro da janela e preflight PASS

Condição:

`08:00 <= now < 09:00 -03`

e:

> **live preflight = PASS**

Ação:

- registrar hora factual;
- criar activation artifact;
- persistir `active` + factual `started_at`;
- validar zero MeasurementEvent/Resolution;
- checkpoint pós-activation.

Não executar primeira PubMed query antes de 09:00.

## 4. Activation — dentro da janela e preflight WAIT

Se qualquer check retornar WAIT:

> **DO NOT ACTIVATE**

Repetir preflight somente após a causa factual deixar de existir.

Não converter WAIT em PASS manualmente.

## 5. Activation — dentro da janela e preflight FAIL

Ação:

> **DO NOT ACTIVATE**

Preservar:

- check_code;
- detail;
- timestamp;
- HEAD;
- evidence relevante.

Se a causa for uma mudança material:

- registrar deviation quando aplicável;
- avaliar `new_epoch_required` ou `invalidating`.

Nenhum bypass manual.

## 6. Activation — 09:00 ou depois sem activation válida

Condição:

`now >= 2026-10-19T09:00:00-03:00`

e B1R1 não active.

Preflight:

> **FAIL / EXPIRED_NOT_EXECUTED**

Ação:

- não ativar;
- não deslocar schedule;
- não criar `started_at`;
- não fabricar Opportunity execution;
- retornar à governança para próximo desenho/replacement, se houver.

## 7. Target deixa de ser current antes da activation

Preflight:

> **FAIL**

Ação:

- não ativar;
- preservar evidence;
- classificar como blocker de target drift;
- retornar à governança.

Não rebaselinear silenciosamente.

## 8. Authority deixa de estar approved

Preflight:

> **FAIL**

Ação:

- não ativar;
- registrar `authority_change` deviation se aplicável;
- não reutilizar authority histórica.

## 9. Controlling Artifact inativo/missing

Preflight:

> **FAIL**

Ação:

- não ativar;
- preservar qual artifact falhou;
- não substituir artifact por caminho equivalente não congelado.

## 10. Runtime connectivity frozen status deixa de ser confiável antes da activation

Se houver fato novo material indicando interface inválida ou source não acessível:

- não confiar cegamente no status histórico;
- registrar evidence;
- se material, deviation `runtime_change` ou `source_access`;
- materiality conforme impacto factual.

Se `new_epoch_required` ou `invalidating`:

> **activation blocked**

## 11. Opportunity set mismatch

Preflight:

> **FAIL**

Ação:

- não editar Opportunities;
- não ajustar payload;
- preservar mismatch;
- retornar à governança.

## 12. PubMed — HTTP/network failure antes de payload utilizável

Ação:

- criar tentativa factual somente se request realmente iniciou;
- `execution_status=failed` ou `indeterminate` conforme evidência;
- `novelty_state=unknown`;
- `raw_result_count_status=unknown`;
- `raw_result_count=NULL`;
- failure attribution conforme evidência;
- preservar failure Artifact;
- deviation `source_access` quando aplicável.

Retry somente se factual e operacionalmente decidido.

## 13. PubMed — resposta 200, JSON inválido/inparseável

Ação:

- não marcar completed;
- status `failed` ou `indeterminate` conforme prova;
- raw count = unknown;
- preservar response snapshot;
- failure attribution = `source_confirmed`, `oes_confirmed`, `mixed` ou `unknown` conforme causa demonstrável.

## 14. PubMed — count > 10000

Contrato:

> **FAIL CLOSED**

Ação:

- não alterar query;
- não adicionar datas;
- não segmentar silenciosamente;
- não declarar completed;
- registrar evidence;
- deviation `source_scope_change` ou `query_change` somente se houver proposta real de alteração; caso contrário registrar `other` ou `source_access/runtime_change` conforme o fato.

Se execução não puder cumprir o frozen completeness contract:

> **current attempt not completed**

## 15. PubMed — count <= 10000, idlist incompleta

Ação:

- não marcar completed;
- `raw_result_count_status=known` somente se count fonte é confiável;
- `materialized_identifier_count` = quantidade realmente materializada;
- status `partial` se identifiers factuais foram obtidos;
- status `failed`/ `indeterminate` se não houver base segura para partial.

## 16. PubMed — zero results completos

Se resposta completa comprovar count = 0:

- `raw_result_count_status=known`;
- `raw_result_count=0`;
- `materialized_identifier_count=0`.

Se for primeira completed observation PubMed:

- `novelty_state=not_applicable`;
- `new_identifier_count=NULL`.

Zero results não é falha.

## 17. ClinicalTrials.gov — primeira página falha

Mesma disciplina de failure:

- request iniciou → tentativa factual;
- não completed;
- raw count unknown salvo prova confiável;
- preservar error/status;
- deviation `source_access` quando aplicável.

## 18. ClinicalTrials.gov — página intermediária falha

Se páginas anteriores geraram NCT IDs factuais:

> **execution_status=partial**

quando o conjunto parcial estiver materializado de forma auditável.

Regras:

- `raw_result_count_status=unknown`;
- `raw_result_count=NULL` salvo cardinalidade completa comprovada independentemente;
- `materialized_identifier_count` factual;
- items podem ser persistidos;
- não estabelecer successful baseline porque não completed.

## 19. ClinicalTrials.gov — nextPageToken ausente após resposta válida

Se ausência de token significa término normal da paginação:

- completude pode ser confirmada;
- completed permitido se parsing e materialização terminarem corretamente.

Não exigir página adicional fictícia.

## 20. ClinicalTrials.gov — token repetido/ciclo

Ação:

- interromper para evitar loop;
- não marcar completed;
- preservar sequence/page evidence;
- `execution_status=partial` se records factuais foram obtidos, senão failed/indeterminate;
- deviation `runtime_change` ou `interface_change` se comportamento divergir materialmente do contrato.

## 21. ClinicalTrials.gov — schema da resposta mudou

Se campos/estrutura impedirem parser ou minimal record contract:

- não adaptar parser silenciosamente no meio da Opportunity;
- preservar payload;
- deviation `interface_change`;
- avaliar materiality.

Se puder alterar significado/completude:

> **STOP CURRENT EXECUTION PATH**

## 22. Source retorna identifiers duplicados

Antes de persistir:

- deduplicar somente quando identidade fonte é inequivocamente a mesma;
- preservar raw snapshot;
- materialized set deve conter identifiers únicos por evento.

Não contar duplicatas como novos items.

## 23. Identifier previamente observado reaparece

Use:

> **reobserved**

salvo evidência factual de record update.

Não usar `new_to_epoch`.

## 24. Identifier reaparece com record alterado

Use:

> **updated_record**

somente com comparação factual auditável.

Não inferir atualização apenas por mudança de ordem ou ausência de campo não garantido.

## 25. Source timestamp ausente

Ação:

- não inventar timestamp;
- registrar `not_observable` quando aplicável;
- bounds NULL;
- preservar `oes_detected_at` separadamente.

## 26. Source fornece date-only

Ação:

- precision = day;
- raw value preservado;
- bounds do dia somente quando semanticamente justificáveis;
- não converter em horário exato.

## 27. Retry após failed/partial/indeterminate

Pré-condições:

- Opportunity não resolvida;
- nenhum prior completed;
- attempt_no contíguo.

Ação:

- nova row append-only;
- preservar tentativa anterior;
- incrementar retry_count factual.

Não editar evento anterior.

## 28. Retry após completed

Proibido fisicamente.

Ação:

> **DO NOT RETRY SAME OPPORTUNITY**

## 29. Opportunity chegou ao fim sem tentativa

Ação quando factual:

- zero MeasurementEvent;
- `resolution_status=not_executed`;
- reason_code factual;
- evidence Artifact quando material.

Não criar failed event fictício.

## 30. Failed attempt sem novo retry planejado

Se a decisão operacional factual é fechar:

- `resolution_status=failed_closed`;
- terminal event precisa ser `failed`.

Não fechar como completed.

## 31. Indeterminate attempt sem novo retry planejado

Fechar como:

> **indeterminate_closed**

com terminal event indeterminate.

## 32. Partial attempt sem completed posterior

Schema de Resolution não possui `partial_closed`.

Portanto:

> **não inventar closure code.**

Se a situação exigir encerramento definitivo sem status físico representável:

> **STOP → RETURN TO HIGH MODE**

Até decisão, Opportunity permanece unresolved.

## 33. Execution delay

Se request inicia após `planned_for`:

- manter planned_for intacto;
- registrar execution_started_at factual;
- deviation `execution_delay` quando relevante.

Não existe tolerance automática.

A materiality não pode ser inferida apenas pela duração do atraso.

## 34. Query drift necessário para recuperar resultado

Se operação sugerir mudar query:

> **DO NOT APPLY UNDER B1R1**

Registrar:

- deviation `query_change` somente se mudança foi realmente proposta/necessária;
- materiality apropriada;
- retornar à governança se necessária para continuar.

## 35. Interface drift

Exemplos:

- endpoint muda;
- parameter semantics mudam;
- pagination contract muda;
- API version quebra parser.

Ação:

- preservar evidence;
- deviation `interface_change` ou `runtime_change`;
- não alterar frozen interface artifact in place.

## 36. Source scope drift

Se surgir necessidade de adicionar/remover source ou ampliar escopo:

- deviation `source_scope_change`;
- não absorver silenciosamente;
- retornar à governança.

## 37. Credential/secrets incident

Se acesso exigir segredo novo ou ocorrer exposição:

- não persistir segredo em Artifact/log;
- deviation `data_governance` quando aplicável;
- interromper execução se segurança/provenance estiver comprometida.

## 38. Evidence Artifact falha ao persistir

Se failure evidence é obrigatória para a attribution desejada:

- não usar `source_confirmed` ou `mixed` sem Artifact;
- usar attribution compatível com evidence efetivamente preservada;
- se isso impedir representação honesta, STOP.

## 39. UpdateSignal incidentalmente parecer necessário

A observação não cria UpdateSignal automaticamente.

Ação:

- preservar provenance;
- encaminhar finding pelo workflow canônico de triage/update;
- measurement permanece measurement.

## 40. Activation executada, mas primeira PubMed Opportunity perdida

Não reverter `started_at`.

Ação:

- Opportunity PubMed #1 pode futuramente resolver `not_executed` se nenhuma attempt ocorreu;
- próxima Opportunity continua no timestamp congelado;
- first successful PubMed baseline será o primeiro completed futuro da source.

Não deslocar schedule.

## 41. Primeira PubMed attempt falha

A baseline PubMed ainda não existe.

Se houver retry factual da mesma Opportunity e ele completed:

- esse completed é a first successful baseline.

Se Opportunity fechar failed:

- próxima future completed PubMed Opportunity será baseline.

## 42. Primeira ClinicalTrials attempt partial

Não estabelece baseline.

Primeiro completed futuro ClinicalTrials.gov continua sendo baseline.

## 43. Uma source funciona e outra falha

Não colapsar estado em “Epoch success/failure”.

Manter:

- source-specific evidence;
- Opportunity-specific resolutions;
- failure attribution;
- source debt/limitations.

## 44. Material deviation antes do review boundary

Se `new_epoch_required` ou `invalidating`:

- physical completion fica bloqueada;
- não continuar como se não existisse;
- retornar à governança.

## 45. Review boundary com Opportunities irresolvidas

Ação:

> **DO NOT COMPLETE EPOCH**

Resolver factualmente primeiro.

Não criar resolutions em massa sem evidence.

## 46. Review boundary com source debt BVS/LILACS ainda aberto

Source debt, por si só, é informativo e já congelado.

Ação:

- manter visível no review;
- não dizer “full source coverage”.

Não resolver automaticamente.

## 47. Target deixa de ser current antes de completion

Physical guard bloqueia completion.

Ação:

- não completar;
- retornar à governança para rebaseline/reassessment.

## 48. Zero new identifiers em todas as observações

Não concluir:

- cadence adequada;
- source estável;
- nenhuma atualização científica;
- readiness para calibration.

Reportar apenas como fato descritivo contextualizado.

## 49. Muitas falhas operacionais

Não converter automaticamente em SLA/cadence mais lenta.

Reportar:

- source failures;
- OES failures;
- missingness;
- effort;
- constrained performance.

Qualquer calibration futura segue Documento 39/46.

## 50. Evidence inconsistente entre view e rows

Rows/artifacts são controlling evidence.

Ação:

- investigar;
- não fechar review baseado apenas em view;
- se bug de schema/view material for identificado, STOP e retornar à arquitetura.

## 51. Regra consolidada de escalation de modo

Continuar em modo operacional corrente somente quando a resposta já estiver determinada por schema/contrato.

Exigir retorno a **modo alto** se houver necessidade de decidir:

- novo status;
- nova migration;
- nova source semantics;
- nova query/interface semantics;
- novo completeness rule;
- novo materiality rule;
- nova authority class;
- novo closure state;
- novo normative interpretation.

## 52. Estado

> **B1R1_CONTINGENCY_TABLES = PRE_SPECIFIED**

> **NEW_SCHEMA = NO**

> **NEW_MIGRATION = NO**

> **NEW_AUTHORITY = NO**

> **B1R1_STATE_MUTATION = NO**

> **REAL_SOURCE_EXECUTION = NO**

**Fim do Documento 90**
