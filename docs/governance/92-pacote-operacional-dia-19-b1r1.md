# 92 — Pacote Operacional do Dia 19/10 para Activation e Primeira Opportunity do B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data de preparação:** 8 de outubro de 2026  
**Status:** **READY_FOR_DAY_OF_EXECUTION — NO_FACTUAL_ACTIVATION_PRECREATED**  
**Modo de preparação:** médio  
**Modo exigido no dia:** alto  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 87–91; migration 035; CP135  
**Objeto:** reunir em um único pacote a sequência operacional, evidência mínima e comandos read-only necessários em 19/10, sem criar activation fact antecipado.

## 1. Estado esperado ao iniciar

Antes de 08:00 -03:

- B1 = invalidated;
- B1R1 = authorized_non_normative;
- started_at = NULL;
- authority approved;
- zero MeasurementEvent;
- zero OpportunityResolution;
- nenhuma material deviation bloqueante conhecida.

## 2. Janela

Activation interval:

`2026-10-19T08:00:00-03:00 <= now < 2026-10-19T09:00:00-03:00`

Primeira PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Primeira ClinicalTrials.gov Opportunity:

`2026-10-19T10:30:00-03:00`

## 3. Antes de 08:00

Executar apenas:

- Freshness Gate;
- inspeção de repositório;
- leitura dos runbooks;
- confirmação de integridade de artifacts;
- preparação da sessão.

Não executar live activation.

## 4. Arquivos que devem estar disponíveis

- `docs/governance/91-runbook-live-activation-b1r1.md`;
- `docs/governance/88-runbook-operacional-medicoes-reais-b1r1.md`;
- `docs/governance/90-decision-tables-contingencias-b1r1.md`;
- `database/035_temporal_observation_activation_preflight.sql`;
- `database/f4-topi-n2-dcbti-b1r1-live-preflight-readonly.sql`;
- frozen PubMed/ClinicalTrials artifacts v2.

## 5. Captura read-only de preflight

Arquivo:

`database/f4-topi-n2-dcbti-b1r1-live-preflight-readonly.sql`

Propriedade:

> **BEGIN TRANSACTION READ ONLY**

Ele captura:

- CURRENT_TIMESTAMP;
- aggregate preflight state;
- checks individuais;
- epoch status/boundaries/design freeze/authority;
- source/connectivity/opportunity-set state;
- MeasurementEvent count;
- OpportunityResolution count;
- material deviation count;
- first PubMed Opportunity.

Ele termina com:

> **ROLLBACK**

Logo:

> **LIVE_PREFLIGHT_CAPTURE_MUTATION = ZERO_BY_CONSTRUCTION**

## 6. Saída mínima do live preflight

Salvar integralmente a saída em evidence Artifact/log.

Conferir:

- aggregate_state = PASS;
- EPOCH_EXISTS = PASS;
- EPOCH_STATUS = PASS;
- TARGET_CURRENT = PASS;
- AUTHORITY_STATE = PASS;
- CONTROLLING_ARTIFACTS = PASS;
- RUNTIME_CONNECTIVITY = PASS;
- OPPORTUNITY_SET = PASS;
- MATERIAL_DEVIATIONS = PASS;
- PRESTART_EVENT_STATE = PASS;
- ACTIVATION_WINDOW = PASS;
- SOURCE_DEBT_VISIBILITY = INFO;
- measurement_event_count = 0;
- opportunity_resolution_count = 0;
- material_deviation_count = 0.

## 7. Se aggregate_state = WAIT

Ação:

> **DO NOT ACTIVATE**

Se ainda antes de 08:00:

- aguardar;
- repetir somente quando factual.

Se dentro da janela e WAIT por outro motivo:

- investigar check individual;
- não forçar PASS.

## 8. Se aggregate_state = FAIL

Ação:

> **DO NOT ACTIVATE**

Preservar:

- timestamp;
- HEAD;
- checkpoint;
- checks;
- reason/detail.

Aplicar Documento 90.

## 9. Se aggregate_state = PASS

Somente então:

1. registrar factual observed activation time;
2. criar Documento/Artifact factual de activation;
3. registrar HEAD/checkpoint;
4. incluir preflight output;
5. incluir zero-event proof;
6. gerar SQL factual de activation;
7. executar SQL;
8. validar estado pós-activation.

## 10. O que não deve existir antes do PASS

Não deve existir:

- activation Artifact factual;
- SQL com started_at futuro;
- pre-filled activation timestamp;
- MeasurementEvent;
- OpportunityResolution;
- source result snapshot.

## 11. Post-activation proof

Após activation válida, comprovar:

- B1R1 = active;
- started_at >= 08:00 -03;
- started_at < 09:00 -03;
- authority approved at started_at;
- target current;
- opportunity sets intactos;
- zero MeasurementEvent;
- zero OpportunityResolution.

## 12. Checkpoint entre activation e 09:00

Se operacionalmente possível, criar checkpoint imediatamente.

Conteúdo mínimo:

- exact started_at;
- activation Artifact UUID;
- activation SQL commit;
- HEAD;
- preflight evidence;
- post-activation validation;
- zero-event proof.

## 13. Preparação da primeira PubMed Opportunity

Somente após activation validada.

Opportunity:

`b3140000-0000-0000-0000-000000000015`

Timestamp:

`2026-10-19T09:00:00-03:00`

Usar Documento 88.

## 14. PubMed first-measurement evidence

Preservar, conforme factual:

- request parameters;
- start/end timestamps;
- raw response/result snapshot;
- count;
- PMID identifier set;
- parse/completeness evidence;
- runtime/failure evidence;
- effort payload.

## 15. First PubMed completed semantics

Se completed:

- novelty_state = not_applicable;
- new_identifier_count = NULL;
- failure_attribution = not_applicable.

Se não completed:

- não estabelece PubMed successful baseline.

## 16. Preparação ClinicalTrials.gov 10:30

Opportunity:

`b3140000-0000-0000-0000-000000000023`

Timestamp:

`2026-10-19T10:30:00-03:00`

Frozen request:

- query.cond=insomnia;
- query.term=(digital CBT OR digital CBT-I OR internet CBT-I);
- format=json;
- pageSize=10;
- paginação completa.

## 17. Escalation points em 19/10

Permanecer em modo alto se ocorrer:

- preflight não PASS;
- source/API drift;
- count > 10000 PubMed;
- ambiguous completeness;
- first failure attribution;
- first source timepoint interpretation;
- partial sem closure representável;
- qualquer necessidade de nova semântica.

## 18. Evidence naming recommendation

Usar nomes explícitos contendo:

- TOPI-N2-DCBTI-01;
- B1R1;
- source;
- opportunity_no;
- observed timestamp;
- artifact role.

Não depender apenas de nomes genéricos como `response.json`.

## 19. Segurança operacional

Não registrar:

- API tokens;
- secrets;
- auth headers;
- cookies sensíveis;
- credenciais locais.

Preservar apenas metadata necessária à provenance.

## 20. Clock sources

Para fatos OES, usar relógio factual no ato.

Distinguir:

- current time;
- planned_for;
- started_at;
- execution_started_at;
- execution_completed_at;
- oes_detected_at;
- source temporal fields;
- resolved_at.

## 21. Fail-safe temporal

Se estiver muito próximo de 09:00 e activation ainda não tiver sido concluída e validada:

> **DO NOT RUSH**

> **DO NOT BACKDATE**

> **ALLOW EXPIRY**

## 22. Estado deste pacote

> **DAY_19_OPERATOR_PACKET = READY**

> **LIVE_PREFLIGHT_CAPTURE_SQL = READY_READ_ONLY**

> **ACTIVATION_FACT = NOT_CREATED**

> **ACTIVATION_SQL_FACTUAL = NOT_CREATED**

> **REAL_SOURCE_EXECUTION = NO**

**Fim do Documento 92**
