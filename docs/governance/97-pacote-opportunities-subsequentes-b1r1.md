# 97 — Pacote Operacional das Opportunities Subsequentes do Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data de preparação:** 9 de outubro de 2026  
**Status:** **READY_FOR_SUBSEQUENT_OPPORTUNITIES — NO_SOURCE_QUERY_EXECUTED**  
**Modo de preparação:** médio  
**Modo de execução inicial recomendado:** alto até estabilização do caminho real  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 88, 90, 94–96; migration 036; CP140  
**Objeto:** generalizar o caminho operacional das 12 Opportunities posteriores às primeiras Opportunities de PubMed e ClinicalTrials.gov.

## 1. Escopo

Este pacote cobre todas as Opportunities do B1R1, exceto:

- PubMed #1 — `b3140000-0000-0000-0000-000000000015`;
- ClinicalTrials.gov #1 — `b3140000-0000-0000-0000-000000000023`.

As duas primeiras permanecem cobertas pelos Documentos 94–96.

## 2. Matriz read-only

Arquivo:

`database/f4-topi-n2-dcbti-b1r1-subsequent-opportunities-readiness-readonly.sql`

A matriz reporta por Opportunity:

- source;
- Opportunity UUID;
- opportunity_no;
- planned_for;
- epoch status;
- started_at;
- target currentness;
- authority state;
- resolution state;
- prior attempt count;
- prior completed count da própria source;
- blocking deviation;
- expected_attempt_no;
- completed semantics;
- attempt readiness.

## 3. Completed semantics

A regra é source-specific.

Se:

> **prior_completed_source_count = 0**

então um eventual completed ainda é:

> **BASELINE_IF_NO_PRIOR_COMPLETED**

Logo:

- novelty_state = not_applicable;
- new_identifier_count = NULL;
- failure_attribution = not_applicable.

Isso cobre, por exemplo, o caso em que a primeira Opportunity da source falhou e a baseline real só ocorre depois.

Se:

> **prior_completed_source_count > 0**

então o completed é:

> **SUBSEQUENT_COMPLETED**

e:

- novelty_state não pode ser not_applicable;
- failure_attribution = not_applicable;
- novelty deve ser zero_new, new_items ou unknown de forma factual.

## 4. Subsequent completed — zero_new

Usar quando:

- completed;
- conjunto observado é completo;
- nenhum identifier novo no Epoch foi encontrado.

Então:

- novelty_state = zero_new;
- new_identifier_count = 0.

## 5. Subsequent completed — new_items

Usar quando:

- completed;
- existem identifiers inéditos no Epoch;
- new_identifier_count é factual.

Então:

- novelty_state = new_items;
- new_identifier_count > 0.

Isso não implica materialidade científica.

## 6. Subsequent completed — unknown

Usar quando:

- completed;
- não é possível determinar novelty de forma segura.

Não fabricar new_identifier_count.

## 7. Retry semantics

A mesma Opportunity pode receber nova tentativa somente se:

- ainda não resolvida;
- prior attempt não completed;
- expected_attempt_no é contíguo.

Depois de completed:

> **no retry**

## 8. Source-specific baseline persistence

PubMed e ClinicalTrials.gov mantêm estados independentes.

Exemplo:

- PubMed já tem completed baseline;
- ClinicalTrials.gov ainda não tem completed.

Nesse caso:

- próxima PubMed completed = subsequent semantics;
- próxima ClinicalTrials.gov completed = baseline semantics.

Não compartilhar baseline entre sources.

## 9. Delays

Se a Opportunity começar após planned_for:

- planned_for permanece intacto;
- execution_started_at é factual;
- avaliar execution_delay deviation;
- nenhuma tolerância normativa automática.

## 10. Missed Opportunity

Se nenhuma attempt ocorrer:

- não criar MeasurementEvent;
- quando factual, resolver como not_executed;
- não deslocar schedule.

## 11. Partial/failed/indeterminate

Aplicar Documento 90.

Em particular:

- partial não estabelece successful baseline;
- failed não estabelece successful baseline;
- indeterminate não estabelece successful baseline;
- partial sem completed posterior continua sem closure state próprio.

## 12. Evidence discipline

Cada tentativa subsequente deve preservar os mesmos tipos de evidence definidos nos Documentos 88, 94 e 95:

- request snapshot;
- result snapshot;
- identifier set;
- failure evidence;
- timepoints;
- effort;
- deviations;
- resolution.

## 13. Post-readout

Após persistência factual, usar as views de replay/readiness.

Para as primeiras Opportunities, usar também o post-readout específico do Documento 96.

Para Opportunities subsequentes, o mesmo modelo lógico pode ser aplicado por Opportunity/source.

## 14. Scientific boundary

Mesmo em subsequent completed com `new_items`:

> **new_to_epoch ≠ scientific materiality**

Nenhum UpdateSignal automático.

## 15. Execution mode

Enquanto o B1R1 ainda estiver no primeiro ciclo real e o caminho não tiver sido comprovado operacionalmente em produção:

> **high mode is recommended for real attempts**

Após estabilidade comprovada e sem nova decisão semântica, execuções posteriores podem ser reavaliadas quanto ao modo.

## 16. Estado

> **SUBSEQUENT_OPPORTUNITY_OPERATOR_PACKET = READY**

> **SUBSEQUENT_OPPORTUNITY_READINESS_MATRIX = READY_READ_ONLY**

> **SUBSEQUENT_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **FACTUAL_SUBSEQUENT_MEASUREMENT_SQL = NOT_CREATED**

**Fim do Documento 97**
