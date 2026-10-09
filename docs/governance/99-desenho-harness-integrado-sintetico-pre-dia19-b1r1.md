# 99 — Desenho do Harness Integrado Sintético Pré-19/10 (B1R1-like)

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 9 de outubro de 2026  
**Status:** **DESIGN_DEFINED — SYNTHETIC_ONLY — NOT_IMPLEMENTED — NO_CI_PROOF**  
**Modo de decisão arquitetural:** alto  
**Modo recomendado para implementação:** médio  
**Escopo:** integração técnica sintética do caminho de activation e measurements; **não** execução factual da instância TOPI-N2-DCBTI-01.  
**Dependências:** Documentos 51–53, 61–68, 78–80, 82, 88–98; migrations 033–036; CP142.  

## 1. Decisão de escopo

Preparar um novo teste de integração, com dois EpochSources artificiais e quatro Opportunities artificiais, conectando preflight, activation, tentativas, evidências, itens, timepoints, resolutions, replay, readiness e completion sintética.

O ensaio **não cria** novo protocolo científico, semântica física, migration, policy, cadence, SLA, scheduler, notification ou autoridade operacional factual. Não modifica nenhum frozen artifact de B1R1.

O ensaio é uma **ampliação de cobertura**. A fixture existente `database/f4-temporal-observation-fixtures.sql` já materializa um fluxo sintético de uma fonte com evento, item, timepoint e resolution. Os testes `TACT`, `APF`, `FM` e `B1R1-AUTH` verificam outras partes separadamente. Não afirmar que hoje inexiste teste sintético ponta a ponta; o ganho específico está na integração **dual-source**, nas transições em ordem e no tratamento integrado de falhas.

## 2. Limites obrigatórios

1. Usar exclusivamente identidades de testes novas, com prefixo UUID reservado ao harness (por exemplo, `f74...`), nunca o prefixo `b3...` do B1/B1R1 real.
2. Plano e Epoch artificiais distintos de `b3100000-0000-0000-0000-000000000001` e `b3120000-0000-0000-0000-000000000002`. Pode-se vincular o plano ao **target sintético preexistente** das fixtures F3/F4, sujeito à checagem de identidade e currentness; jamais utilizar a versão real TOPI.
3. Criar Artifacts artificiais, rotulados `SYNTHETIC_TEST_ONLY` no conteúdo/caminho/metadata aplicáveis, sem pretender que payloads simulados foram recebidos de fontes.
4. Nenhum HTTP, PubMed ESearch, ClinicalTrials.gov /studies target-specific, rede ou segredo; resultados e erros são dados artificiais autocontidos.
5. Horários fixos de laboratório, **fora da janela real de 19/10**, como 2026-10-08 em UTC. O parâmetro `p_as_of` de preflight serve apenas para teste determinístico. Nunca registrar esses horários como instantes factuais de execução do B1R1.
6. Executar o harness SQL integralmente dentro de `BEGIN`/`ROLLBACK`. Falha com `psql -v ON_ERROR_STOP=1` deve abortar a sessão e reverter a transação; `COMMIT` é proibido.
7. Revalidar snapshots de B1/B1R1 **antes e depois**, em sessões independentes da transação sintética. Conferir status, `started_at`, `completed_at`, quantidades de eventos/resolutions e integridade de oportunidades. Nunca assumir que o estado real continuará eternamente pré-activation: comparar com o snapshot inicial.
8. Testar somente o contrato já existente. Qualquer necessidade de novo enum, guard, alteração de migration ou interpretação semântica exige STOP e decisão separada em modo alto.

## 3. Instância sintética

- `Plan`: `F4-ISE-SYNTHETIC-01`, nova identidade, `calibration_object=cadence`, `readiness_scope=policy_aggregate`.
- `Epoch`: `ISE-B1-SYNTH`, com `start_boundary_at` anterior à primeira Opportunity e `review_boundary_at` posterior à última.
- `EpochSource A`: `PUBMED_ISE_SYNTH`, duas Opportunities.
- `EpochSource B`: `CTG_ISE_SYNTH`, duas Opportunities.
- Fonte `BVS_ISE_SYNTH` facultativa como dívida deferred, se necessária para verificar `SOURCE_DEBT_VISIBILITY=INFO`; não criar Opportunity para ela.
- Autoridade sintética `operational_execution=approved`, `actor=synthetic-owner`, `actor_type=owner`, decisão posterior ao design freeze e anterior ao start sintético, associada a Artifact de decisão artificial.
- Quatro oportunidades em payload `oes.temporal_opportunity_set/0.1`, com materialização exatamente correspondente e sem numerologia normativa.
- Artefatos artificiais para specification, measurement design, sources, queries/interfaces, schedules, authority e evidências de tentativa.

Os instantes serão fechados na implementação após conferir todos os constraints de chronology, authority, materialization e review. A sequência sintética será inteiramente anterior à data presente e não utilizará `CURRENT_TIMESTAMP` como simulação de `started_at` real.

## 4. Fluxo positivo integrado

**A — Preparação e activation artificial**
1. Materializar Plan, sources, Epoch draft, EpochSources, controlling Artifacts e quatro Opportunities.
2. Inserir authority sintética depois de `temporal_observation_design_frozen_at`.
3. Passar a `authorized_non_normative`.
4. Verificar preflight `WAIT` antes de start, `PASS` dentro da janela sintética, e `FAIL/EXPIRED_NOT_EXECUTED` no instante da primeira Opportunity — sem mutação pelo preflight.
5. Executar `authorized_non_normative → active` apenas no Epoch sintético com `started_at` anterior à primeira Opportunity.
6. Comprovar 0 MeasurementEvents e 0 Resolutions imediatamente após activation.

**B — PubMed sintético**
1. Opportunity A1: resposta artificial completa com um PMID artificial; inserir query/result/identifier Artifacts artificiais, `MeasurementEvent completed`, `novelty_state=not_applicable`, `new_identifier_count=NULL`, `failure_attribution=not_applicable`.
2. Inserir `MeasurementItem new_to_epoch`, timepoint artificial `precision=day` e `observability_status=bounded`, vincular Event Artifacts e resolver `completed`.
3. Opportunity A2: resposta completa com o mesmo identificador, `item_state=reobserved`, `novelty_state=zero_new`, `new_identifier_count=0`; inserir Resolution terminal correta.

**C — ClinicalTrials.gov sintético**
1. Opportunity B1, tentativa 1: falha artificial com `execution_status=failed`, `novelty_state=unknown`, `raw_result_count_status=unknown`; vincular failure evidence artificial se usar `source_confirmed`.
2. Confirmar que a tentativa falha **não** estabelece successful baseline.
3. Opportunity B1, tentativa 2: resposta artificial completa e comprovadamente vazia, `raw_result_count=0`, `materialized_identifier_count=0`, `novelty_state=not_applicable` e `new_identifier_count=NULL`; resolver como `completed`.
4. Opportunity B2, tentativa 1: resposta artificial parcial com um NCT ID artificial, `raw_result_count_status=unknown`; não declarar completude nem closure própria de partial.
5. Opportunity B2, tentativa 2: resultado completo com o identificador já observado no partial, `item_state=reobserved`, `novelty_state=zero_new`, `new_identifier_count=0`, com Resolution `completed`.

**D — Revisão do estado sintético**
1. Comprovar replay, contagens de Opportunities, attempts/retries, terminal events, resolutions, source-specific baselines, itens, timepoints e provenance Artifacts.
2. Verificar que completion física é rejeitada enquanto houver Opportunity unresolved ou `completed_at` anterior ao review boundary.
3. Depois de resolver as quatro Opportunities e somente após o review boundary **sintético**, verificar que a transição `active → completed` é representável, sem gerar readiness, Calibration Dossier ou valores normativos.
4. A conclusão sintética não constitui review real do B1R1.

## 5. Testes negativos integrados

- Activation em `WAIT` ou após a primeira Opportunity: não executar activation. Caso a infraestrutura permita mutação física com um timestamp retrospectivo sem aferição de relógio real, não interpretar isso como autorização: o controle factual de horário permanece no runbook.
- Artefato controlador inativo/ausente, authority inválida ou opportunity-set mismatch: preflight `FAIL`; não ativar.
- Tentativa antes do Epoch active: rejeitada.
- `attempt_no` não contíguo ou retry após completed: rejeitados.
- `completed` com `novelty_state=not_applicable` depois de completed anterior da **mesma** source: rejeitado.
- Resolution `not_executed` com tentativa existente ou Resolution `completed` sem terminal completed: rejeitadas.
- Partial sem completed terminal: não criar `partial_closed` ou outro status físico inexistente.
- Item duplicado no mesmo evento, timepoint sem semântica declarada, ausência de failure Artifact obrigatório: rejeitados ou rotulados com a incerteza correta, conforme guard atual.
- Deviation material `new_epoch_required` / `invalidating` no momento aplicável: activation/completion bloqueadas conforme schema e contrato.

Casos negativos devem usar subtransações/exception blocks ou instâncias sintéticas secundárias para evitar que uma rejeição esperada invalide o fluxo positivo.

## 6. Matriz de aceitação proposta

| Grupo | Identificadores reservados | Prova |
|---|---|---|
| Integridade da fixture e chronology | ISE-T01–T04 | Design freeze, authority e finite opportunities |
| Preflight e activation sintética | ISE-T05–T08 | WAIT/PASS/FAIL, activation e zero eventos |
| PubMed e baseline independente | ISE-T09–T12 | Completed baseline, item/timepoint/artifacts e subsequent zero_new |
| ClinicalTrials.gov: falha, retry e partial | ISE-T13–T17 | Failure evidence, baseline zero, partial e retry completed |
| Resolution e replay | ISE-T18–T20 | Terminal consistency, 4 Opportunities, source separation |
| Negative gates e review sintético | ISE-T21–T23 | Fail-closed, unresolved block, completion após boundary |
| No mutation / normative isolation | ISE-T24 | ROLLBACK, unchanged real snapshots e zero normativity |

Os identificadores são **reservas de desenho**, não alegação de testes executados ou aprovados.

## 7. Implementação candidata

- Arquivo candidato: `database/f4-temporal-integrated-synthetic-harness-tests.sql`.
- Nova etapa isolada no `.github/workflows/validate-s5.yml` **depois** de migrations 033–036, fixtures F3/F4 pertinentes e authority/corrective B1R1, **antes** da etapa final de status; não substituir suites existentes.
- A execução deve capturar exit code, logs e mensagem explícita `F4-ISE-T01-T24 PASS` apenas após todas as assertivas efetivamente verificadas. Sem eco de PASS incondicional.
- Capturar fingerprint de B1/B1R1 e contagens antes/depois em sessões distintas; validar também ausência dos UUIDs sintéticos após rollback, inclusive Artifacts artificiais.
- Reutilizar as verificações atuais de `PRE_DAY19_PREPARATION_STATUS`, `ACTIVATION_WINDOW=WAIT` e rebuild; não sobrescrever nem reduzir cobertura.
- Reexecutar idempotência/regressões/rebuild; capturar o run e artifact reais de CI antes de promover o harness a `VALIDATED`.
- Se a implementação exigir alteração física de schema, voltar a modo alto antes de qualquer migration.

## 8. Critérios de promoção

`F4_ISE_DESIGN_DEFINED=YES` pode ser registrado agora.

Somente declarar `F4_ISE_IMPLEMENTED=YES` após existência do SQL e etapa CI integrados. Somente declarar `F4_ISE_TECHNICAL_VALIDATION=PASS` após execução real de GitHub Actions com resultados positivos, logs inspecionados, zero mutation comprovada e rebuild PASS. Nenhum PASS sintético autoriza activation factual, query real, calibration, M3 ou Fase 5.

## 9. Estado ao aprovar o desenho

> **F4_ISE_DESIGN = DEFINED_NON_NORMATIVE**  
> **F4_ISE_IMPLEMENTATION = NOT_STARTED**  
> **F4_ISE_CI_PROOF = NOT_AVAILABLE**  
> **B1R1 = AUTHORIZED_NON_NORMATIVE**  
> **B1R1_ACTIVATION = NOT_STARTED**  
> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**  
> **PHASE_5 = NOT_STARTED**

**Próximo bloco:** implementação sintética isolada e integração CI, preferencialmente em modo médio, após novo Freshness Gate e instrução explícita `Prossiga`.

**Fim do Documento 99**
