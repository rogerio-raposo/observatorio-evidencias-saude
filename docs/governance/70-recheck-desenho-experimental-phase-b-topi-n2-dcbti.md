# 70 — Recheck Adversarial do Desenho Experimental da Phase B da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — PREPARATION_AUTHORITY_ONLY**  
**Modo:** alto  
**Documento avaliado:** Documento 69  
**Objeto:** testar o finite opportunity set candidato antes de qualquer real materialization

## 1. Resultado

> **TOPI_N2_DCBTI_PHASE_B_DESIGN_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **FINITE_OPPORTUNITY_SET = PASS**

> **ANTI_ANCHORING = PASS**

> **SOURCE_SPECIFIC_DESIGN = PASS**

> **BASELINE_SEMANTICS = PASS_WITH_EXPLICIT_LIMITATION**

> **RUNTIME_CONNECTIVITY_ORDERING = PASS_WITH_REQUIRED_PREPARATION_GATE**

> **AUTHORITY_ORDERING = PASS_WITH_REQUIRED_TWO_STAGE_AUTHORITY**

> **DRAFT_MATERIALIZATION = NOT_YET_AUTHORIZED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

O desenho pode avançar apenas para um pacote de authority de preparação limitada.

## 2. Regularity / policy-laundering attack

Ataque:

Um conjunto de repeated checks pode virar cadence de fato.

Recheck:

- PubMed não usa intervalo constante;
- ClinicalTrials.gov não usa intervalo constante;
- schedules são finite;
- nenhum RRULE/interval generator existe;
- nenhuma Opportunity é CadenceObligation;
- nenhum field de overdue/breach/compliance existe;
- future calibration deve justificar qualquer valor de forma independente.

Resultado:

> **PASS**

## 3. Source-update anchoring attack

Ataque:

PubMed possui daily corpus behavior documentado; isso poderia induzir daily OES checking.

Recheck:

O desenho não copia daily source behavior.

PubMed opportunities variam em gaps de 1–5 dias.

ClinicalTrials.gov é mais esparso.

A source update resolution informa observability, não policy.

Resultado:

> **PASS**

## 4. Under-observation attack

Ataque:

8 PubMed + 6 ClinicalTrials opportunities podem ser poucos para estimar comportamento temporal.

Recheck:

Correto.

O desenho explicitamente não pretende estimar:

- stable event rate;
- source failure probability;
- sustainable capacity;
- normative interval.

Pretende testar:

- repeatability;
- replay;
- novelty comparison;
- endpoint observability;
- pilot burden;
- missingness/failure behavior.

Não há minimum-N oculto.

Resultado:

> **PASS_WITH_SCOPE_LIMITATION**

Um resultado com baixa informação temporal continua válido como evidência de insufficiency.

## 5. Over-observation / burden attack

Ataque:

14 source-specific opportunities em cerca de três semanas podem ser excesso operacional.

Recheck:

- não há polling intraday repetido;
- PubMed é mais frequente somente na fase inicial;
- ClinicalTrials.gov possui 6 opportunities;
- queries devem ser pequenas;
- effort é medido explicitamente;
- burden observado não prova sustainable capacity.

Resultado:

> **PASS**

Se o burden real impedir execução, isso deve aparecer como missingness/deviation, não ser escondido.

## 6. First-event baseline attack

Ataque:

Sem baseline completo pré-B1, todos os records da primeira execução seriam structurally new_to_epoch e poderiam ser confundidos com nova evidência.

Controle obrigatório:

Primeira successful observation de cada source:

> **OBSERVED_EPOCH_BASELINE_ACQUISITION**

Event aggregate:

- `novelty_state = not_applicable`;
- `new_identifier_count = NULL`;
- result set preservado por identifier artifact/rows;
- item_state `new_to_epoch` permanece apenas semântica estrutural.

Proibição:

> first-event items não podem ser tratados como “new since evidence cutoff” somente pelo item_state.

Resultado:

> **PASS_WITH_EXPLICIT_LIMITATION**

## 7. Historical-miss attack

Ataque:

A primeira baseline pode revelar record antigo ausente do corpus histórico.

Isso não é prospective novelty.

Controle:

- preservar identifier/source dates;
- classificar como candidate historical finding quando apropriado;
- enviar ao workflow científico canônico separado;
- não alterar product/currentness automaticamente;
- não usar como prova de source publication latency.

Resultado:

> **PASS**

## 8. Query drift attack — PubMed

Ataque:

Usar relative date filters mudaria a query semanticamente a cada execução.

Controle:

- strategy congelada;
- sem `last X days`;
- mesma query em todas as opportunities;
- material query change exige novo epoch.

Resultado:

> **PASS**

A união review/RCT é aceitável porque preserva as duas classes históricas do caso.

## 9. Query drift attack — ClinicalTrials.gov

Ataque:

A API parameterization final ainda não foi congelada.

Recheck:

O Documento 69 não finge que ela já está pronta.

A API request real somente poderá ser congelada depois de runtime connectivity probe.

Se a parameterization final alterar materialmente o semantic scope:

> voltar ao recheck antes de materializar EpochSource.

Resultado:

> **PASS_WITH_PRECONDITION**

## 10. Runtime connectivity immutability attack

Ataque:

`temporal_observation_epoch_source.runtime_connectivity_status` é imutável.

Se materializado como `unverified`, activation futura pode ficar permanentemente bloqueada.

Controle:

> **verificar runtime connectivity antes de criar o real EpochSource.**

Sources:

- PubMed E-utilities;
- ClinicalTrials.gov API v2.

Se `verified` não puder ser honestamente estabelecido:

- não criar EpochSource com falso status;
- não reduzir source scope silenciosamente;
- registrar blocker;
- revisar design.

Resultado:

> **PASS_WITH_REQUIRED_PREPARATION_GATE**

## 11. Connectivity-failure attribution attack

Ataque:

Falha do client OES pode ser atribuída incorretamente à source.

Controle:

Connectivity probe deve registrar:

- runtime/client;
- locator/endpoint;
- attempt time;
- observed response;
- HTTP/transport metadata quando disponível;
- causal attribution.

Sem prova:

> **failure_attribution = unknown**

Resultado:

> **PASS**

## 12. Authority-before-freeze attack

Ataque:

Solicitar agora approval de Phase B execution produziria decision timestamp anterior ao futuro `design_frozen_at`.

Migration 033 bloquearia a authorization transition.

Controle:

> não solicitar Phase B execution authority neste checkpoint.

Fluxo obrigatório:

1. preparation authority;
2. connectivity probes;
3. draft materialization;
4. design freeze;
5. exact execution authority package;
6. owner decision após freeze;
7. authority row;
8. authorized_non_normative;
9. active.

Resultado:

> **PASS_WITH_REQUIRED_TWO_STAGE_AUTHORITY**

## 13. Generic “Prossiga” attack

Ataque:

A mensagem de continuidade poderia ser interpretada como authority.

Controle:

Não.

O próximo owner decision deve ser explicitamente vinculado ao pacote de preparação.

Mensagem genérica:

> **não autoriza source probe nem draft materialization.**

Resultado:

> **PASS**

## 14. Draft materialization attack

Ataque:

Materializar target real sem owner awareness pode ultrapassar o boundary do CP120.

Controle:

Criar pacote explícito separado para:

- connectivity probes limitados;
- artifact/config preparation;
- real Plan/Source/Epoch/EpochSource/Opportunity draft materialization;
- zero prospective measurement.

Resultado:

> **PASS**

Materialização continua bloqueada enquanto esse pacote não for explicitamente aprovado.

## 15. Schedule-expiry attack

Ataque:

Se approvals atrasarem, poderia haver tentação de deslocar automaticamente os timestamps.

Controle:

Se o epoch não estiver pronto antes da primeira opportunity:

> **não alterar timestamps.**

O candidate B1 expira sem execução.

Novo desenho:

- nova plan version ou epoch;
- novo payload;
- novo recheck;
- nova authority.

Resultado:

> **PASS**

## 16. Execution-delay attack

Ataque:

`planned_for` poderia virar hidden deadline.

Controle:

- actual execution time é fato;
- diferença é operational deviation;
- nenhuma breach/compliance;
- nenhuma tolerance/grace automática;
- materialidade depende do impacto metodológico.

Resultado:

> **PASS**

## 17. DST / timezone attack

O desenho usa:

> **America/Recife / -03:00**

Recife não depende de mudança sazonal no período do B1.

Source dates podem estar em outros calendários/timezones ou ser date-only.

Controle:

- preservar raw source value;
- registrar precision;
- não inferir hora inexistente;
- latency derivada usa bounds.

Resultado:

> **PASS**

## 18. Favorable-stopping attack

Ataque:

Encerrar quando houver “evidência suficiente” ou “nenhuma novidade”.

Controle:

- review boundary fixo;
- migration 033 impede completion precoce;
- todas opportunities exigem resolution;
- não há early stop por scientific outcome.

Resultado:

> **PASS**

## 19. Automatic-extension attack

Ataque:

No-information result poderia gerar extensão automática.

Controle:

Não existe extension rule automática.

Novo período exige:

- novo epoch/plan;
- novo opportunity set;
- novo gate;
- authority.

Resultado:

> **PASS**

## 20. BVS debt laundering attack

Ataque:

B1 com PubMed + ClinicalTrials.gov poderia ser interpretado como source completeness.

Controle:

BVS/LILACS permanece:

- candidate source;
- `deferred`;
- reason_code explícito;
- reassessment trigger;
- visível no readiness layer.

Resultado:

> **PASS**

B1 completion não é source completeness.

## 21. Cross-source aggregation attack

Ataque:

Aggregate policy-level status poderia esconder source failure.

Controle:

- measurement remains source-specific;
- opportunities e events são source-specific;
- aggregate posterior é derivado;
- source debt preservado.

Resultado:

> **PASS**

## 22. Latency overclaim attack

Ataque:

Date-only source fields poderiam virar latency exata.

Controle:

- PubMed CRDT/EDAT = day precision quando aplicável;
- ClinicalTrials posted fields = date precision quando aplicável;
- timepoint bounds preservam intervalo;
- OES detection timestamp é separado;
- helper deriva latency interval;
- nenhum exact source hour é fabricado.

Resultado:

> **PASS**

## 23. Novelty laundering attack

Ataque:

`new_to_epoch` poderia ser tratado como material scientific change.

Controle:

- source novelty != scientific materiality;
- incidental findings entram em candidate triage;
- nenhuma conclusion/currentness/assurance muda automaticamente;
- UpdateSignal não é criado pela observation layer.

Resultado:

> **PASS**

## 24. Human scientific-authority attack

Ataque:

O owner poderia aprovar execution e isso ser tratado como scientific-methodological validation do UpdateRiskProfile.

Controle:

- owner preparation/execution authority é operacional;
- A1/A3/A4 e ratings authoritative continuam exigindo qualified human scientific/methodological judgment;
- Phase B data apenas prepara evidence inputs.

Resultado:

> **PASS**

## 25. Target drift attack

Antes de:

- connectivity probe material;
- draft materialization;
- execution authority;
- activation;

deve ocorrer target-current recheck.

Se target deixar de current:

> B1 não inicia.

Resultado:

> **PASS**

## 26. Physical-version attack

Ataque:

Conceptual v0.1 nunca foi materializada, mas physical Plan candidate é version 2.

Recheck:

Aceitável se o Artifact de specification registrar explicitamente:

- v0.1 = documentary predecessor only;
- v0.2-final = first physical materialization;
- no supersedes UUID because no v0.1 physical row exists.

Resultado:

> **PASS_WITH_DOCUMENTATION_REQUIREMENT**

## 27. External-fact freshness

Os controlling source facts foram rechecados em 2026-10-08 em official NLM/ClinicalTrials.gov documentation.

Nenhum runtime probe foi executado neste recheck.

Resultado:

> **DOCUMENTARY_FRESHNESS = ADEQUATE_FOR_DESIGN**

> **RUNTIME_FRESHNESS = PENDING**

## 28. Final state

> **TOPI_N2_DCBTI_PHASE_B_DESIGN_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **TOPI_N2_DCBTI_V02_FINAL_DESIGN = READY_FOR_PREPARATION_AUTHORITY_REQUEST**

> **PUBMED_OPPORTUNITIES = 8**

> **CLINICALTRIALS_GOV_OPPORTUNITIES = 6**

> **BVS_LILACS = DEFERRED_SOURCE_DEBT**

> **PREPARATION_AUTHORITY = NOT_YET_REQUESTED**

> **DRAFT_MATERIALIZATION = NOT_AUTHORIZED**

> **PHASE_B_EXECUTION_AUTHORITY = NOT_YET_REQUESTABLE_BECAUSE_DESIGN_NOT_PHYSICALLY_FROZEN**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 29. Próximo passo

> **Criar pacote explícito de decisão de authority para Phase B preparation.**

O pacote deve autorizar somente:

1. target-current recheck;
2. minimal runtime connectivity probes de PubMed e ClinicalTrials.gov;
3. congelamento de query/interface Artifacts;
4. real draft materialization da TOPI v0.2-final e Epoch B1;
5. payload↔Opportunity equality validation;
6. preservação de design_frozen_at.

Não autoriza measurement execution.

**Fim do Documento 70**
