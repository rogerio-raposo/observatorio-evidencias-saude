# 89 — Protocolo Operacional de Review e Encerramento do Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **PRE-SPECIFIED — REVIEW_NOT_STARTED**  
**Modo:** médio  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 39, 46, 78, 82, 84–88; migrations 033–036; CP132  
**Objeto:** pré-especificar, antes de qualquer dado real do B1R1, como o Epoch será revisado e encerrado após o review boundary, sem criar thresholds normativos, calibration candidate ou conclusão científica automática.

## 1. Finalidade

Este protocolo existe para evitar análise retrospectiva oportunista após observar os resultados do B1R1.

Ele define antecipadamente:

- quais fatos operacionais serão sumarizados;
- como missingness/failures serão expostos;
- quais condições físicas permitem encerrar o Epoch;
- quais inferências são proibidas;
- quais saídas podem alimentar futura evidence-readiness;
- quais decisões continuam exigindo novo gate.

Este documento não inicia o review.

## 2. Review boundary

B1R1 review boundary:

> **2026-11-10T18:00:00-03:00**

Nenhum encerramento físico como `completed` é válido antes desse instante.

## 3. Condições físicas de completion

O guard de lifecycle já exige, para:

> **active → completed**

simultaneamente:

1. `completed_at` não-NULL;
2. `completed_at >= review_boundary_at`;
3. target ainda current;
4. zero Opportunities sem Resolution;
5. zero deviations com materiality `new_epoch_required` ou `invalidating`.

Logo:

> **EPOCH_COMPLETION_IS_A_PHYSICAL_STATE_TRANSITION, NOT_AN_ANALYTIC_JUDGMENT**

## 4. Review não é calibration

O review do B1R1 pode descrever evidência operacional.

Ele não pode, por si só:

- selecionar cadence normativa;
- selecionar grace;
- selecionar warning lead;
- selecionar SLA;
- abrir Calibration Dossier automaticamente;
- declarar READY_FOR_CALIBRATION automaticamente;
- desbloquear M3;
- promover measurement schedule a policy.

## 5. Unidade de análise

A unidade primária é:

> **Opportunity**

com agregação posterior por:

- EpochSource;
- source;
- Epoch B1R1.

Não usar somente totais agregados se eles esconderem source-specific debt.

## 6. Dataset controlador

A revisão deve usar, no mínimo:

- `maintenance.temporal_measurement_replay_v`;
- `maintenance.temporal_measurement_readiness_evidence_v`;
- MeasurementEvent rows;
- MeasurementItem rows;
- item timepoints;
- Event Artifacts;
- Observation Deviations;
- OpportunityResolution rows;
- frozen source/query/interface artifacts;
- authority/design/activation records.

Views são conveniência analítica; rows e artifacts permanecem evidence source of truth.

## 7. Opportunity accounting

Para cada uma das 14 Opportunities, registrar:

- source;
- opportunity_no;
- planned_for;
- final opportunity status;
- attempt_count;
- first_started_at;
- last_completed_at;
- last_execution_status;
- resolution_status;
- resolved_at;
- deviation_count.

A soma das categorias finais deve reconciliar com o total planejado por source.

## 8. Categorias finais de Opportunity

Somente categorias físicas existentes:

- completed;
- failed_closed;
- not_executed;
- indeterminate_closed;
- invalidated, quando aplicável.

Não criar categorias analíticas novas que pareçam status operacionais.

## 9. Missingness

Para cada source, reportar:

- planned_opportunities;
- completed_opportunities;
- failed_closed_opportunities;
- not_executed_opportunities;
- indeterminate_closed_opportunities;
- unresolved_opportunities;
- descriptive_missingness_proportion.

A proporção é descritiva.

Não existe threshold pré-fixado que transforme automaticamente missingness em:

- acceptable;
- unacceptable;
- ready;
- insufficient.

## 10. Attempts e retries

Reportar por source:

- total attempt_count;
- Opportunities com >1 attempt;
- distribuição descritiva de attempts por Opportunity;
- retry_count acumulado quando disponível no effort payload.

Não interpretar mais retries automaticamente como source unreliability sem examinar evidence attribution.

## 11. Failure attribution

Separar, no mínimo:

- source_confirmed;
- oes_confirmed;
- mixed;
- unknown.

Também reportar:

- quantos failures possuem evidence Artifact;
- quantos failures não permitem atribuição segura;
- quais failures coincidem com source_access/interface/runtime deviations.

Não converter `unknown` em source failure.

## 12. Source-specific completeness

### PubMed

Avaliar:

- completed retrievals;
- known raw counts;
- PMID set completeness;
- qualquer `count > 10000`;
- qualquer fail-closed event;
- qualquer query/interface deviation.

### ClinicalTrials.gov

Avaliar:

- completed paginated retrievals;
- number of pages quando observável;
- NCT ID set completeness;
- pagination interruptions;
- API/runtime deviations;
- record extraction completeness para minimal record contract.

## 13. Identifier history

Por source, reportar:

- unique identifiers observed in Epoch;
- new_to_epoch items;
- reobserved items;
- updated_record items;
- indeterminate items.

Não somar `new_to_epoch` e chamar isso de "scientific novelty".

## 14. Aggregate novelty history

Para cada completed event:

- first completed per source deverá aparecer como baseline:
  - novelty_state=not_applicable;
  - new_identifier_count=NULL;
- completed posteriores:
  - zero_new;
  - new_items;
  - unknown.

Reportar a sequência temporal.

Não inferir materialidade científica a partir dela.

## 15. Source timepoints

Por source, reportar:

- item count;
- items_with_observable_timepoint;
- semantic codes observados;
- observability_status distribution;
- precision distribution;
- bounded/not_observable cases.

Não transformar date-only em timestamp exato na análise.

## 16. Detection/latency evidence

Quando semanticamente computável, latency deve preservar:

- source timepoint semantic code;
- source precision;
- OES `oes_detected_at`;
- censoring/observability limitations.

Qualquer métrica de latency é:

> **DESCRIPTIVE PILOT EVIDENCE**

Não é ainda SLA/cadence basis suficiente por si só.

## 17. Effort

Por source e no Epoch total, reportar quando disponível:

- operator_minutes_observed;
- machine_elapsed_seconds;
- retry_count;
- handoff_count.

Separar:

- observed effort;
- missing effort;
- incident/outage constrained effort.

Não chamar esforço observado de sustainable capacity automaticamente.

## 18. Deviations

Inventariar todas as deviations por:

- deviation_type;
- materiality;
- Opportunity;
- MeasurementEvent, quando aplicável;
- evidence Artifact.

Dar destaque especial a:

- runtime_change;
- query_change;
- interface_change;
- source_scope_change;
- authority_change;
- data_governance.

Se existir `new_epoch_required` ou `invalidating`:

> **PHYSICAL COMPLETION IS BLOCKED**

## 19. Deferred source debt

BVS/LILACS continua explicitamente:

> **deferred_source_debt**

O review deve reportar essa dívida.

É proibido descrever o B1R1 como cobertura integral do universo de fontes candidatas.

## 20. Zero-event interpretation

Zero:

- new items;
- failures;
- updates;
- observed timepoints;

nunca deve ser interpretado isoladamente.

Sempre contextualizar com:

- planned coverage;
- completed coverage;
- missingness;
- source liveness;
- observability;
- denominator conhecido/desconhecido;
- observation window.

## 21. Cohort/window

Para qualquer uso posterior do B1R1 como readiness evidence, registrar:

- cohort = exact B1R1;
- source scope = PubMed + ClinicalTrials.gov, BVS/LILACS deferred;
- start boundary;
- review boundary;
- planned Opportunity denominator = 14;
- actual resolved denominator;
- completed denominator;
- failures;
- missing/not_executed;
- censored/indeterminate cases;
- structural deviations.

Não ampliar transportability para outro target/source/period sem novo assessment.

## 22. Evidence cut-off

O review deverá registrar um:

> **evidence_cutoff_at**

igual ou posterior ao review boundary e coerente com a última evidência operacional incluída.

Evidência posterior não pode ser retroativamente atribuída ao review original.

## 23. Reassessment triggers

Mesmo após review, considerar triggers como:

- target supersession;
- source/API material change;
- workflow material change;
- capacity material change;
- source debt resolution;
- major missingness discovery;
- provenance defect;
- authority change;
- structural break.

O review não permanece automaticamente aplicável após drift material.

## 24. Physical closure preparation

Antes de tentar `active → completed`, confirmar:

- current time >= review boundary;
- target current;
- todas as 14 Opportunities possuem Resolution;
- nenhum material deviation bloqueante;
- source debt registrado;
- review artifact preparado;
- evidence cutoff definido;
- nenhuma row inconsistente.

## 25. Unresolved Opportunity handling

Se qualquer Opportunity ainda estiver unresolved no review boundary:

> **DO NOT COMPLETE EPOCH**

Primeiro deve haver resolução factual apropriada.

Não usar completion para esconder backlog.

## 26. Missed Opportunity at review

Se uma Opportunity não teve nenhuma attempt:

- não criar MeasurementEvent retroativo;
- resolver como `not_executed` quando factual;
- preservar razão/evidence quando disponível.

Não preencher dado ausente.

## 27. Failed/indeterminate Opportunity at review

Se já existe terminal failed/indeterminate attempt e a operação decidiu encerrar:

- usar Resolution física compatível;
- não converter em completed;
- não executar retry artificial apenas para "fechar" a série.

## 28. Review artifact

O review final deverá registrar, no mínimo:

- exact Plan/Epoch UUID;
- design_frozen_at;
- activation started_at;
- observation window;
- review boundary;
- evidence_cutoff_at;
- source-by-source Opportunity accounting;
- missingness;
- attempts/retries;
- failure attribution;
- identifier history;
- source timepoint coverage;
- descriptive latency;
- effort;
- deviations;
- deferred source debt;
- data limitations;
- structural breaks;
- unresolved evidence limitations;
- no-calibration disclaimer;
- assessor;
- verification status.

## 29. Verification

O review operacional pode ser preparado por AI/system.

Qualquer posterior conclusão:

> **READY_FOR_CALIBRATION**

continua exigindo o protocolo de Evidence Readiness e human verification correspondente.

Este Documento 89 não concede essa verification.

## 30. Relação com Evidence Readiness

O B1R1 review poderá ser uma basis real candidata, especialmente para:

- source behavior;
- operational feasibility;
- missingness;
- effort;
- temporal observability;
- API/source failures.

Mas:

> **B1R1_REVIEW ≠ READY_FOR_CALIBRATION**

Uma future context-specific readiness assessment deve ser separado, com seus próprios:

- evidence reality proof;
- cohort/window;
- denominator;
- blockers;
- human verification;
- evidence cutoff;
- reassess boundary.

## 31. Proibição de hidden minimum-N

Não existe regra:

- "14 Opportunities são suficientes";
- "8 PubMed checks são suficientes";
- "6 ClinicalTrials checks são suficientes";
- "X completed checks desbloqueiam calibration".

A suficiência futura depende do contexto e do protocolo de readiness.

## 32. Proibição de favorable stopping

O review boundary já está congelado.

Não encerrar antecipadamente porque:

- apareceram new items;
- não apareceram new items;
- resultados parecem estáveis;
- effort parece baixo;
- source parece confiável.

## 33. Proibição de automatic extension

Não estender o B1R1 automaticamente porque:

- houve missingness;
- houve source outage;
- N parece baixo;
- houve poucas novidades.

Qualquer novo período requer nova decisão/estrutura adequada.

## 34. Scientific interpretation boundary

O review operacional pode apontar:

- identifiers observados;
- records updated;
- source timepoints;
- possible incidental scientific findings already routed.

Ele não pode sozinho concluir:

- evidence changed;
- recommendation changed;
- currentness mudou;
- assurance mudou;
- update required.

Essas conclusões pertencem ao workflow científico canônico.

## 35. Completion timestamp

Se completion física for autorizada e válida:

- `completed_at` deve ser factual;
- >= review boundary;
- nunca pré-escrito;
- nunca retroativo por conveniência.

## 36. Post-completion invariants

Após completion:

- Epoch design permanece imutável;
- measurement history permanece append-only/immutable;
- review evidence permanece provenance-bound;
- nenhuma normative cadence nasce automaticamente;
- nenhum SLA nasce automaticamente;
- M3 continua bloqueado até decisão própria.

## 37. Expected review outputs

A saída esperada é um pacote com:

1. **B1R1 execution accounting**;
2. **source-specific descriptive evidence**;
3. **data-quality/missingness assessment**;
4. **effort/feasibility observations**;
5. **deviation register**;
6. **source debt statement**;
7. **review limitations**;
8. **candidate evidence inventory for future readiness**.

Não inclui normative candidate values.

## 38. Estado pré-review

Neste momento:

> **B1R1_REVIEW_PROTOCOL = PRE_SPECIFIED**

> **B1R1_REVIEW = NOT_STARTED**

> **B1R1_EPOCH_COMPLETION = NOT_ALLOWED_BEFORE_REVIEW_BOUNDARY**

> **READINESS_ASSESSMENT = NOT_STARTED**

> **CALIBRATION_DOSSIER = NOT_OPEN**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

## 39. Próximo ato

Antes de 19/10:

- nenhum review real pode começar;
- nenhuma evidence result do B1R1 existe.

O próximo ato irreversível continua:

> **live activation preflight em 19/10/2026, 08:00–09:00 -03, modo alto.**

**Fim do Documento 89**
