# 52 — Gate Adversarial da Arquitetura de Aquisição de Evidência Temporal Não Normativa

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **FIRST_PASS = REVISE**  
**Modo:** alto  
**Objeto:** revisão adversarial do Documento 51

## 1. Resultado da primeira passagem

> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = REVISE**

> **FIRST_OBSERVATION_INSTANCE = NOT_AUTHORIZED**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

A escolha arquitetural “protocolo transversal reutilizável + instância por target” é mantida como direção preferida, mas o Documento 51 precisa de hardening antes de autorizar qualquer instância.

## 2. TEA-G01 — shadow M2 por repetição operacional

Ataque:

Um target M1 recebe checks repetidos, agenda, missingness log e source coverage. Depois de algumas semanas, a operação passa a ser descrita como “monitoramento”, embora nenhum M1→M2 tenha ocorrido.

Risco:

- Monitor informal;
- currentness implícita;
- promessa de cobertura;
- bypass do contrato 027 e da governança M2.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

- usar identidade explícita de `measurement_event`;
- proibir rótulos Monitor/MonitoringCycle;
- declarar que frequência/repetição não muda maintenance level;
- estabelecer trigger de parada se o objetivo operacional passar a ser vigilância persistente;
- proibir claim de coverage/currentness sustentado apenas pelo piloto.

## 3. TEA-G02 — Search semantic laundering

Ataque:

Qualquer probe de fonte, ping de API, consulta para latência ou check vazio é persistido como `investigation.search` porque a tabela já existe.

Risco:

- misturar experimento operacional com busca científica;
- contaminar histórico da Investigation;
- transformar probe em corpus científico;
- criar SearchHit/ScreeningDecision sem intenção científica real.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Antes de persistir cada classe de evento, exigir **semantic storage mapping**.

`investigation.search` só pode ser usado se o evento for de fato uma Search científica vinculável à Investigation segundo o significado canônico do objeto.

Probe de disponibilidade, liveness, latency ou capacity não pode ser armazenado como Search apenas por conveniência.

Quando não houver objeto físico semanticamente compatível:

> usar Artifact/documentação auditável até decisão física posterior.

## 4. TEA-G03 — source latency confundida com detection latency

Ataque:

OES encontra um registro às 10h e conclui que a fonte demorou X horas para indexá-lo sem timestamp causal confiável.

Risco:

- invented source latency;
- precisão falsa;
- cadence calibrada contra endpoint incorreto.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Toda latency observation deve declarar:

- start endpoint;
- end endpoint;
- timezone;
- timestamp precision;
- source of each timestamp;
- observed versus inferred;
- censoring/interval bounds quando timestamp exato não existir.

Sem endpoints adequados:

> registrar `latency_not_observable`, não estimar.

## 5. TEA-G04 — schedule experimental vira candidate privilegiado

Ataque:

A agenda usada para medir passa a ser o primeiro candidate de cadence porque “já funcionou”.

Risco:

- anchoring;
- circular calibration;
- policy by inertia.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

- measurement schedule nunca recebe status de candidate;
- Calibration Dossier futuro deve gerar/avaliar candidates independentemente;
- eventual candidate numericamente igual à agenda experimental precisa de justificativa independente;
- histórico do piloto não constitui approval.

## 6. TEA-G05 — desenho adaptativo oportunista

Ataque:

Durante o piloto, frequência, fontes, query ou janela são alteradas após observar resultados favoráveis/desfavoráveis, e todos os dados são agregados como uma única série.

Risco:

- selection bias;
- denominator mutável;
- stopping rule oportunista;
- impossibilidade de replay.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

- plan version imutável durante cada observation epoch;
- mudança material cria nova versão/epoch;
- deviations são append-only;
- dados pré/pós mudança permanecem estratificados;
- stop/review boundary deve ser pré-especificado ou alteração justificada antes de interpretar suficiência.

## 7. TEA-G06 — source scope laundering

Ataque:

As fontes usadas na produção original são declaradas automaticamente como universo de surveillance.

Risco:

- coverage falsa;
- omission bias;
- transportar decisão histórica de busca para manutenção temporal.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Toda instância deve possuir:

- candidate source universe;
- included sources;
- excluded sources;
- rationale;
- known unknowns;
- claim explicitamente limitado ao measurement scope.

Production-search source != surveillance source by default.

## 8. TEA-G07 — authority laundering

Ataque:

“Prossiga”, plan preparation, owner publication approval ou AI methodological pass são tratados como autorização operacional/humana do piloto.

Risco:

- fabricated authority;
- confusão entre governança editorial e execution authority.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Antes de `active_observation`, a instância deve registrar authority evidence estruturada/documental com:

- authority type;
- actor/role;
- scope;
- decision;
- timestamp;
- artifact/locator;
- limitations.

Ausência:

> **EXECUTION_NOT_AUTHORIZED**

Não inferir authority a partir de instrução genérica ou aprovação anterior de publicação.

## 9. TEA-G08 — capacity laundering pelo piloto

Ataque:

Tempo observado durante um piloto controlado é tratado como sustainable capacity institucional.

Risco:

- extrapolação de workload;
- SLA/cadence relaxada por performance experimental.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Separar:

- observed pilot effort;
- observed throughput;
- constrained performance;
- sustainable capacity assessment.

Pilot effort pode informar, mas não prova B5 suficiente.

## 10. TEA-G09 — incidental finding causa atualização silenciosa

Ataque:

Uma nova evidência importante encontrada durante measurement é automaticamente incorporada, muda currentness ou altera conclusão.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Finding incidental deve entrar em trilha separada:

`observed finding → provenance → candidate triage → canonical update workflow`

Sem alteração automática de:

- conclusion;
- assurance;
- currentness;
- product version.

## 11. TEA-G10 — negative check falso

Ataque:

Consulta falha ou result_count desconhecido e é registrada como “zero novas evidências”.

Risco:

- false negative;
- falsa cobertura.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Distinguir obrigatoriamente:

- successful_zero_result;
- successful_nonzero_result;
- denominator_unknown;
- partial_retrieval;
- source_failure;
- OES_failure;
- not_executed;
- indeterminate.

Só `successful_zero_result` pode ser interpretado como check negativo, dentro do scope realmente executado.

## 12. TEA-G11 — target/source drift sem partitioning

Ataque:

API, interface, query ou target muda no meio do piloto e a série continua agregada.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

- drift trigger cria novo epoch ou invalidação;
- source-level fatos podem permanecer históricos;
- transportability para target novo exige decisão explícita;
- não apagar dados antigos;
- não agregar pré/pós mudança sem justificativa.

## 13. TEA-G12 — data-governance incompleto

Ataque:

Pilot coleta payloads completos, credenciais, identificadores pessoais ou material licenciado sem necessidade.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

- data minimization por event class;
- secrets nunca em artifact;
- registrar termos/licença/acesso quando material;
- payload sensível apenas se necessário e autorizado;
- retention/disposal;
- incident path;
- provenance sem copiar conteúdo protegido além do necessário.

## 14. TEA-G13 — pacote final vira Calibration Dossier por atalho

Ataque:

Temporal Evidence Acquisition Result Package é renomeado ou tratado como Calibration Dossier e valores são escolhidos diretamente.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Fluxo obrigatório:

`Observation Result Package → novo Evidence Readiness Assessment → se READY → Calibration Dossier`

Não existe atalho.

## 15. TEA-G14 — readiness por stopping rule favorável

Ataque:

O piloto termina quando os dados “parecem suficientes”, sem boundary prévio, selecionando uma janela conveniente.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

- review boundary pré-especificado;
- termination reasons enumerados;
- extensão/encurtamento versionado antes da decisão de readiness;
- janela final e desvios registrados;
- nenhum minimum-N implícito;
- representatividade reavaliada no readiness.

## 16. TEA-G15 — query/source changes escondem heterogeneidade

Ataque:

Mudanças de estratégia são tratadas como simples manutenção e todos os resultados são combinados.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Cada mudança material de:

- query;
- filters;
- platform/interface;
- source;
- coverage rule;

cria estrato/epoch próprio ou nova versão do plano.

## 17. TEA-G16 — external source facts sem locator

Ataque:

Documentação atual de API/feed é lida, influencia desenho e depois não é reproduzível.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

Fato externo material deve preservar:

- source;
- locator;
- retrieval time;
- version/effective date quando disponível;
- precision;
- interpretação.

Sem isso, não pode ser controlling basis.

## 18. TEA-G17 — physical gap prematuramente resolvido por migration

Ataque:

A ausência de tabela perfeita para measurement events leva diretamente a migration nova antes de validar o piloto documental.

Resultado:

> **REVISE_REQUIRED**

Hardening requerido:

- primeiro fechar semantic event model;
- mapear objetos existentes;
- usar Artifact/documentação onde suficiente;
- somente abrir physical-contract block se houver lacuna material comprovada;
- migration exige gate próprio.

## 19. TEA-G18 — pilot target escolhido antes do gate

Ataque:

N1 ou N2 é escolhido agora e o desenho transversal passa a ser otimizado para ele durante o hardening.

Resultado:

> **PASS_GUARD_PRESERVED**

O Documento 51 corretamente não selecionou a primeira instância.

Manter essa separação até o recheck final.

## 20. Síntese da primeira passagem

A escolha de arquitetura é defensável:

> **REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

mas o contrato metodológico ainda está incompleto.

Revisões obrigatórias antes do PASS:

1. semantic storage mapping;
2. latency endpoint semantics;
3. immutable/versioned observation epochs;
4. source-universe discipline;
5. explicit execution authority evidence;
6. negative-check taxonomy;
7. pilot-effort vs sustainable-capacity separation;
8. drift partitioning;
9. result-package → readiness → dossier mandatory chain;
10. stopping-rule guard;
11. external fact locator;
12. explicit no-shadow-M2 invariants.

## 21. Estado

> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = REVISE**

> **ARCHITECTURE_CHOICE = RETAINED_PENDING_HARDENING**

> **FIRST_OBSERVATION_INSTANCE = NOT_SELECTED**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 22. Próximo passo

> **Hardenizar o Documento 51 incorporando TEA-G01–G17 e executar recheck adversarial antes de selecionar a primeira instância.**

**Fim do Documento 52**
