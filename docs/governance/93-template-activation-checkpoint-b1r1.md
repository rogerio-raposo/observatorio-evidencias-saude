# 93 — Template Operacional de Activation Artifact e Checkpoint Pós-Activation do B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data de preparação:** 8 de outubro de 2026  
**Status:** **TEMPLATE_ONLY — NO_FACTUAL_ACTIVATION_DATA**  
**Modo de preparação:** médio  
**Modo de uso factual:** alto  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 91–92; CP136  
**Objeto:** fornecer estrutura pronta para registrar a activation factual e o checkpoint pós-activation sem antecipar qualquer timestamp ou resultado.

## 1. Regra de uso

Este documento é apenas template.

Não contém:

- activation timestamp factual;
- preflight factual;
- activation Artifact UUID factual;
- activation SQL commit factual;
- post-activation PASS factual.

Somente pode ser instanciado após:

> **LIVE PREFLIGHT = PASS**

## 2. Campos do Activation Artifact factual

Preencher somente no dia:

- document_id;
- created_at factual;
- actor;
- mode;
- repository HEAD;
- checkpoint vigente;
- Plan UUID;
- Epoch UUID;
- authority UUID;
- design_frozen_at;
- start boundary;
- first PubMed Opportunity;
- observed activation timestamp;
- aggregate preflight state;
- checks individuais;
- MeasurementEvent count antes da activation;
- OpportunityResolution count antes da activation;
- material deviation count;
- source debt visibility;
- live preflight evidence locator;
- decisão operacional final;
- activation SQL path/commit após materialização.

## 3. Valores estáticos permitidos no template

Plan UUID:

`b3100000-0000-0000-0000-000000000001`

Epoch UUID:

`b3120000-0000-0000-0000-000000000002`

Authority UUID:

`b3150000-0000-0000-0000-000000000002`

Design frozen at:

`2026-10-08T19:48:20-03:00`

Start boundary:

`2026-10-19T08:00:00-03:00`

First PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

## 4. Campos proibidos antes do ato

Não preencher antecipadamente:

- observed activation timestamp;
- aggregate preflight state;
- individual check outcomes;
- activation Artifact UUID;
- activation SQL commit;
- post-activation status;
- started_at.

## 5. Estrutura recomendada do Activation Artifact

### Identity

- project;
- phase;
- TOPI code;
- Plan UUID;
- Epoch UUID;
- authority UUID.

### Freshness Gate

- HEAD;
- README pointer;
- STATE checkpoint;
- commits posteriores;
- workflow status.

### Factual clock

- current America/Recife time;
- activation interval check.

### Live preflight

- aggregate state;
- check table completa;
- zero-event proof;
- zero-resolution proof.

### Activation decision

- PASS → proceed;
- WAIT → do not activate;
- FAIL → do not activate.

### Materialization

Somente se PASS:

- exact factual started_at;
- activation Artifact UUID;
- SQL commit;
- database transition result.

### Post-validation

- B1R1 active;
- started_at within interval;
- authority approved at started_at;
- target current;
- opportunity sets intact;
- zero MeasurementEvent;
- zero OpportunityResolution;
- zero blocking deviation.

## 6. Template de checkpoint pós-activation

O checkpoint factual pós-activation deve conter:

- checkpoint number;
- prior checkpoint;
- exact HEAD;
- exact started_at;
- activation Artifact;
- activation SQL;
- preflight evidence;
- post-activation validation evidence;
- first PubMed Opportunity timestamp;
- zero-event state;
- mandatory pause before first measurement when operationally possible.

## 7. Read-only post-activation validation

Arquivo:

`database/f4-topi-n2-dcbti-b1r1-post-activation-readonly.sql`

Esse script:

- usa transaction READ ONLY;
- pode ser executado antes da activation sem mutação;
- após activation, deve permitir comprovar:
  - epoch active;
  - started_at in range;
  - target current;
  - authority approved;
  - opportunity sets intactos;
  - zero MeasurementEvent;
  - zero OpportunityResolution;
  - zero material deviation blocker.

## 8. Activation SQL

Este template não contém SQL executável de activation.

Razão:

> **ACTIVATION SQL MUST REMAIN FACTUAL AND DAY-OF**

A estrutura executável só pode ser criada após live preflight PASS, com o timestamp observado no ato.

## 9. Estado

> **ACTIVATION_ARTIFACT_TEMPLATE = READY**

> **POST_ACTIVATION_CHECKPOINT_TEMPLATE = READY**

> **POST_ACTIVATION_READONLY_CAPTURE = READY**

> **FACTUAL_ACTIVATION_DATA = NONE**

> **ACTIVATION_SQL_FACTUAL = NOT_CREATED**

**Fim do Documento 93**
