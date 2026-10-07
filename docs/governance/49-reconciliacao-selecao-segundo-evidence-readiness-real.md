# 49 — Reconciliação do Primeiro Readiness Assessment e Seleção do Segundo Contexto Real

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **RECONCILED — SECOND_REAL_READINESS_ASSESSMENT_SELECTED_NOT_EXECUTED**  
**Modo:** alto  
**Dependências:** Documentos 46–48; CP28; Documentos 66–67; CP109

## 1. Finalidade

Este documento reconcilia uma divergência factual identificada após o CP109 e decide, com base no estado canônico, o próximo passo entre as duas alternativas deixadas pelo primeiro Evidence Readiness Assessment:

- **Opção A:** especificar um Temporal Observation Plan não normativo para N1-01;
- **Opção B:** executar um segundo Evidence Readiness Assessment real antes de iniciar observação prospectiva.

A decisão resultante é:

> **OPTION_B = SELECTED**

> **SECOND_REAL_READINESS_CONTEXT = N2_RC01_PRODUCTVERSION_1_CADENCE_POLICY_AGGREGATE**

> **SECOND_REAL_READINESS_ASSESSMENT = AUTHORIZED_FOR_EXECUTION_UNDER_DOCUMENT_46**

O assessment ainda não é executado neste documento.

## 2. Freshness Gate e evidência reconciliada

Na abertura deste bloco foi confirmado:

- branch canônica: `main`;
- HEAD de entrada: `c2d4e799d113d468c803843891b4fe77daacaf20`;
- checkpoint vigente: CP109;
- nenhum commit posterior inesperado;
- Documento 48 preservado no estado histórico em que foi produzido;
- CP28, Documento 66, Documento 67 e a materialização SQL do Caso Real 01 N2 confirmam estado A2/publicado.

## 3. Divergência identificada

O Documento 48, seção 3, caracterizou o N2/dCBT-I como permanecendo em:

> pré-publicação / `under_review`

com revisão humana material pendente.

Essa caracterização está incorreta em relação ao estado canônico já consolidado antes do Documento 48.

O estado correto é:

- Product: `OES-P-2026-000401`;
- ProductVersion UUID: `81000000-0000-0000-0000-000000000701`;
- product_type: `evidence_sheet`;
- ProductVersion: 1;
- status: `published`;
- publication_date: `2026-10-04`;
- assurance: **A2**;
- owner governance approval: **approved**;
- expert independent review: **não realizada**, com disclosure preservado;
- publication gate: **PASS / publishable=true**.

Esse estado está explicitamente consolidado no CP28 e nos Documentos 66–67.

## 4. Tratamento da divergência

O Documento 48 não é reescrito retroativamente.

Razões:

1. ele registra um assessment com evidence cut-off explícito;
2. a divergência faz parte da trilha auditável do processo;
3. a conclusão do assessment do N1-01 pode ser avaliada separadamente da justificativa comparativa usada para seleção do piloto;
4. corrigir o registro histórico silenciosamente reduziria auditabilidade.

A correção passa a ser feita por este documento e pelos estados/checkpoints posteriores.

## 5. Impacto sobre o primeiro assessment

A divergência afeta materialmente:

- a comparação entre candidatos ao primeiro piloto;
- a justificativa de por que N1-01 era o único caso publicado/A2 suficientemente maduro;
- a avaliação do valor informacional da Opção B após CP109.

Ela **não invalida**, por si só, o resultado do primeiro assessment do N1-01.

O estado:

> **PRIMARY_READINESS_STATE = INSUFFICIENT_EVIDENCE**

continua sustentado por evidência específica do N1-01:

- ausência de UpdateRiskProfile real;
- source characterization insuficiente;
- ausência de série longitudinal de surveillance/cadence;
- absence de human authority específica para readiness/maintenance;
- feasibility/capacity não estabelecida;
- replay longitudinal não viável.

Nenhum desses blockers depende da caracterização incorreta do N2.

Portanto:

> **FIRST_REAL_READINESS_ASSESSMENT_RESULT = PRESERVED**

> **DOCUMENT_48_SELECTION_RATIONALE = PARTIALLY_CORRECTED_BY_DOCUMENT_49**

## 6. Estado real do N2 candidato

### Target

- Product: `OES-P-2026-000401`;
- ProductVersion UUID: `81000000-0000-0000-0000-000000000701`;
- product_type: `evidence_sheet`;
- title: dCBT-I totalmente automatizada versus educação digital sobre sono;
- status: `published`;
- publication_date: `2026-10-04`;
- evidence_cutoff_date: `2026-10-04`;
- assurance: A2.

### Investigation

- Investigation: `OES-I-2026-000401`;
- InvestigationVersion UUID: `81000000-0000-0000-0000-000000000002`;
- investigation_type: `evidence_sheet`;
- depth: N2;
- maintenance_level registrado: M1;
- status: active.

O `maintenance_level=M1` é um dado histórico real, mas:

> **não constitui cadence interval nem calibration basis.**

### Searches reais

Há quatro Search rows reais no mesmo timestamp operacional de produção do caso:

1. PubMed/MEDLINE — revisões sistemáticas/meta-análises;
2. PubMed/MEDLINE — atualização por RCTs;
3. BVS/LILACS — evidência regional/brasileira;
4. ClinicalTrials.gov — identidade de ensaios e estudos não publicados/em andamento.

Os `result_count` permanecem NULL quando o ambiente não forneceu contagem bruta confiável, conforme explicitamente documentado.

Essas searches demonstram execução real multi-source.

Elas não constituem, por si só:

- surveillance longitudinal;
- source latency measurement;
- cadence history;
- repeated monitoring cycles;
- operational capacity evidence.

## 7. Comparação A versus B após reconciliação

### Opção A — Observation Plan imediato no N1-01

Vantagens:

- começa a adquirir dados longitudinais que o primeiro assessment demonstrou faltar;
- permite source characterization e observation prospectiva no target já avaliado.

Riscos neste momento:

- compromete a primeira operação prospectiva a um único piloto;
- pode cristalizar escolhas de measurement plan antes de testar transportabilidade do protocolo;
- N1-01 possui busca seletiva e um único ecossistema bibliográfico principal, limitando o teste de source-scope behavior.

### Opção B — segundo readiness assessment no N2

Vantagens:

- usa um segundo produto real, A2 e publicado;
- muda simultaneamente depth/product_type de N1/evidence_response para N2/evidence_sheet;
- testa um caso com search scope real mais diversificado;
- permite verificar se blockers do N1 são contextuais ou recorrentes;
- testa transportabilidade do Protocolo 46 antes de iniciar observação prospectiva;
- exige principalmente análise de evidência já persistida, sem criar uma operação longitudinal prematura.

Risco:

- o N2 pode igualmente concluir NOT READY, especialmente por ausência de história temporal, UpdateRiskProfile e authority específica.

Esse risco não reduz o valor do segundo assessment: confirmar quais blockers são recorrentes e quais variam por contexto é precisamente informação metodológica relevante.

## 8. Decisão

À luz da correção factual e da relação custo/valor informacional:

> **a Opção B domina a Opção A como próximo passo imediato.**

Isso não significa que o Observation Plan do N1-01 foi rejeitado.

Significa apenas:

> **TEMPORAL_OBSERVATION_PLAN_N1_01 = DEFERRED_UNTIL_AFTER_SECOND_REAL_READINESS_ASSESSMENT**

A razão é reduzir o risco de desenhar a primeira observação prospectiva a partir de um único contexto e obter uma segunda leitura empírica do protocolo antes de operacionalizar coleta longitudinal.

## 9. Exact context selecionado

O segundo assessment deverá usar:

> **Calibration object: cadence readiness**

> **Target: ProductVersion `81000000-0000-0000-0000-000000000701`**

> **Product: `OES-P-2026-000401`**

> **Investigation: `OES-I-2026-000401`**

> **Depth/product: N2 / evidence_sheet**

> **Readiness scope: policy_aggregate**

A seleção de `policy_aggregate` é analítica e não cria CadenceObligation.

## 10. Regras para o segundo assessment

O segundo assessment deve obedecer integralmente ao Documento 46 e ao hardening do Documento 47.

Deve, no mínimo:

1. fixar evidence cut-off próprio;
2. provar realidade/admissibilidade dos dados;
3. excluir fixtures F3/F4 como evidência normativa;
4. avaliar ER-A a ER-J;
5. separar publication authority de maintenance/readiness authority;
6. não tratar M1 como interval/cadence;
7. caracterizar cohort/window/denominator/representatividade;
8. distinguir source behavior, indexing/publication latency e OES detection latency;
9. aplicar blocker-set dominance;
10. registrar transportabilidade sem generalização automática.

## 11. O que permanece proibido

Esta decisão não autoriza:

- Calibration Dossier real;
- cadence interval;
- grace;
- warning threshold;
- SLA duration;
- calendário normativo;
- CadenceContract real;
- UpdatePolicy calibrada;
- scheduler;
- notifications;
- auto-escalation;
- mudança automática de currentness;
- M3 formal;
- nova migration.

## 12. Estado após reconciliação

> **FIRST_REAL_READINESS_ASSESSMENT_RESULT = PRESERVED**

> **DOCUMENT_48_SELECTION_RATIONALE = PARTIALLY_CORRECTED**

> **OPTION_B = SELECTED**

> **SECOND_REAL_READINESS_CONTEXT = N2_RC01_PRODUCTVERSION_1_CADENCE_POLICY_AGGREGATE**

> **SECOND_REAL_READINESS_ASSESSMENT = SELECTED_NOT_EXECUTED**

> **TEMPORAL_OBSERVATION_PLAN_N1_01 = DEFERRED_PENDING_SECOND_ASSESSMENT**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **SCHEDULER = DEFERRED**

> **NOTIFICATIONS = DEFERRED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 13. Próximo passo exato

> **Após checkpoint, em modo alto, executar o segundo Evidence Readiness Assessment real no N2/dCBT-I ProductVersion `81000000-0000-0000-0000-000000000701`, cadence / policy_aggregate, sem iniciar calibração numérica nem observação prospectiva.**

**Fim do Documento 49**
