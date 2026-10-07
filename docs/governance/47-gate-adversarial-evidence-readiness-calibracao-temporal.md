# 47 — Gate Adversarial do Protocolo de Evidence Readiness Temporal

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — após recheck final**  
**Revisa:** Documento 46  
**Objeto:** atacar o protocolo de readiness antes de qualquer avaliação em contexto real

## 1. Resultado da primeira passagem

> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = REVISE**

> **READINESS_ASSESSMENT_ON_REAL_CONTEXT = NOT_YET_AUTHORIZED**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

Nenhum problema encontrado autoriza números ou operação real.

## 2. ERG-01 — synthetic leakage por ausência de rótulo

Problema:

O Documento 46 exige ausência de rótulo fixture/test-only/synthetic para evidência real.

Isso é necessário, mas não suficiente.

Um registro não se torna real apenas porque não contém a palavra synthetic.

Ataque:

- row copiada de fixture sem label;
- dado gerado em ambiente de teste com identificador plausível;
- ator fictício sem prefixo fixture;
- replay sintético persistido como Artifact comum.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Evidência R1 real deve possuir **prova positiva de origem**, não apenas ausência de marca sintética:

- provenance chain;
- contexto operacional real identificável;
- locator canônico;
- actor/source real;
- período real;
- declaração explícita de admissibilidade.

## 3. ERG-02 — authority path pode virar authority fictícia

Problema:

READY_FOR_CALIBRATION exige que a authority path esteja “disponível”.

Isso pode ser interpretado como mera existência de um papel abstrato.

Ataque:

- declarar “há um owner” sem owner real;
- IA concluir READY e tratar isso como decisão de governance;
- confundir readiness assessment com aprovação da futura calibração.

Resultado:

> **REVISE_REQUIRED**

Hardening:

- IA/system pode preparar assessment;
- status final READY_FOR_CALIBRATION precisa de verificação humana qualificada do readiness;
- scientific/methodological gaps devem ser verificados por human_reviewer/human_expert;
- operational/calendar gaps por owner/institutional authority;
- isso não equivale a aprovar candidate ou normative activation.

## 4. ERG-03 — READY com blockers secundários

Problema:

Documento 46 permite estado primário + blockers secundários, mas não fecha precedência.

Ataque:

- primary=READY_FOR_CALIBRATION;
- blocker secundário=NEEDS_HUMAN_AUTHORITY;
- downstream lê apenas primary e abre dossier.

Resultado:

> **REVISE_REQUIRED**

Hardening:

> **READY_FOR_CALIBRATION exige blocker set vazio.**

Se qualquer blocker material existir:

- READY é proibido;
- o estado primário deve ser não-ready;
- múltiplos blockers permanecem registrados sem score.

## 5. ERG-04 — hidden minimum-N / amostra conveniente

Problema:

Corretamente não há minimum N universal, mas isso pode virar permissividade.

Ataque:

- selecionar dois casos fáceis;
- ignorar períodos de pico;
- escolher janela retrospectiva após ver resultados;
- declarar suficiência porque “não há N mínimo”.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Antes de concluir suficiência, registrar:

- cohort definition;
- inclusion/exclusion;
- observation-window rationale;
- denominator conhecido ou limitação explícita;
- case/event count;
- missing/censored count;
- structural breaks;
- peak-load representation;
- justificativa de representatividade.

Quando a seleção é pilot/convenience:

> conclusão vale somente para o pilot context e não pode ser generalizada.

## 6. ERG-05 — fonte externa material não persistida

Problema:

Documento 46 diz preservar Artifact/record “quando possível”.

Para uma informação que muda o readiness, isso é fraco.

Ataque:

- consultar página atual de API/feed;
- não preservar locator/version/retrieval;
- depois usar afirmação não reproduzível para declarar READY.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Qualquer fato externo **material para READY** deve possuir locator persistente/auditável com:

- source;
- retrieval/observation time;
- version/effective date quando disponível;
- precision;
- interpretação.

Se isso não puder ser preservado:

> não pode ser controlling basis para READY.

## 7. ERG-06 — measurement schedule vira policy por inércia

Problema:

A distinção conceitual existe, mas falta lifecycle.

Ataque:

- rodar polling experimental por meses;
- tratá-lo depois como cadence “já praticada”;
- começar overdue/alerts contra agenda experimental.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Measurement schedule deve possuir:

- explicit non-normative status;
- start/end ou review boundary;
- observation purpose;
- no binding a UpdatePolicy/CadenceContract;
- no compliance/overdue/breach semantics;
- no notifications/auto-escalation;
- não pode virar candidate por simples persistência;
- qualquer uso posterior exige nova análise.

## 8. ERG-07 — R7 not applicable como escape

Ataque:

Marcar input difícil como not applicable sem justificar.

Resultado:

> **REVISE_REQUIRED**

Hardening:

R7 exige rationale específica e verificação compatível com o domínio.

## 9. ERG-08 — documented source schedule ≠ observed latency

Ataque:

Confundir “fonte publica semanalmente” com “OES detecta em X tempo”.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Separar:

- documented source behavior;
- observed source publication/indexation latency;
- OES detection latency;
- polling/process latency.

Uma categoria não substitui automaticamente a outra.

## 10. ERG-09 — absence-of-event + denominator desconhecido

O Documento 46 já proíbe inferência simples de zero events.

Clarificação necessária:

se o denominador/cobertura é desconhecido, “zero events” não pode apoiar adequação.

Resultado:

> **PASS_WITH_CLARIFICATION**

## 11. ERG-10 — target/source drift

O evidence_cutoff e reassessment triggers existem.

Hardening adicional:

READY deve ser invalidado antes da abertura do dossier se houver:

- target supersession;
- Monitor rebaseline;
- source/API structural change;
- material workflow change;
- calendar/authority change.

Resultado:

> **PASS_WITH_CLARIFICATION**

## 12. ERG-11 — governance judgment disfarçando missing data

Documento 46 separa evidence uncertainty, value judgment e resource decision.

Resultado:

> **PASS**

Governance pode escolher entre candidatos futuros, mas não preencher observação inexistente.

## 13. ERG-12 — capacity laundering

Documento 46 preserva conflito e proíbe relaxar need.

Resultado:

> **PASS**

Adicionar no recheck que observed low performance sob understaffing não deve ser tratado automaticamente como sustainable capacity.

## 14. ERG-13 — calendar laundering

Documento 46 possui CALENDAR_CAPACITY_LAUNDERING_RISK.

Resultado:

> **PASS**

Business calendar continua dependente de obrigação institucional, não de horário informal da equipe.

## 15. ERG-14 — fixed deadline / applicability

A arquitetura é adequada.

Hardening:

quando a obrigação for legal/regulatória ou contratual, applicability deve ser confirmada por autoridade institucional competente; não basta interpretação automática.

Resultado:

> **PASS_WITH_CLARIFICATION**

## 16. ERG-15 — replay cherry-picking

Ataque:

definir cohort depois de ver candidate performance.

Hardening:

o cohort/data window usado para readiness e futuro replay deve ser fixado antes da comparação de candidates, salvo análise exploratória explicitamente rotulada.

Resultado:

> **REVISE_REQUIRED**

## 17. ERG-16 — real-case overgeneralization

Documento 46 já afirma que produto real não implica operação real.

Hardening:

um pilot readiness vale apenas para exact context avaliado.

Generalização a outro target/source/clock exige novo assessment ou justificativa explícita de transportability.

Resultado:

> **REVISE_REQUIRED**

## 18. ERG-17 — readiness artifact vira segundo sistema normativo

Documento 46 afirma que o registro é metodológico e não nova tabela normativa.

Resultado:

> **PASS**

O readiness artifact não deve armazenar o futuro valor normativo como campo decisório.

## 19. ERG-18 — circularidade readiness ↔ Calibration Dossier

Documento 46 bloqueia dossier antes de READY e deixa claro que READY apenas autoriza abrir dossier.

Resultado:

> **PASS**

O futuro dossier deve referenciar o readiness, mas não pode retroativamente alterar a evidência disponível no readiness original.

## 20. ERG-19 — privacy/security e prospective observation

O plano prospectivo pode envolver dados operacionais sensíveis.

Hardening:

observation plan deve respeitar controles de acesso, minimização, finalidade e políticas de dados aplicáveis; readiness não autoriza coleta irrestrita.

Resultado:

> **REVISE_REQUIRED**

## 21. ERG-20 — readiness stale sem data fixa

Documento 46 possui evidence cut-off e triggers, mas não obriga review boundary explícita.

Hardening:

todo READY deve possuir:

- reassess_by ou justificativa explícita para ausência de data;
- event-based invalidation triggers.

Resultado:

> **REVISE_REQUIRED**

## 22. Hardening obrigatório

Antes do recheck, o Documento 46 deve incorporar:

1. prova positiva de realidade/admissibilidade;
2. human verification do READY;
3. blocker-set dominance;
4. cohort/window/denominator/representativeness;
5. persistence obrigatória de fonte externa material;
6. lifecycle fechado de measurement schedule;
7. rationale para R7;
8. separação de source behavior e observed latency;
9. invalidation por drift antes de dossier;
10. fixed-deadline institutional applicability;
11. pre-specification do cohort de replay;
12. pilot-only inference/transportability;
13. prospective observation data governance;
14. reassess_by ou justificativa equivalente.

## 23. Estado após primeira passagem

> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = REVISE**

> **READINESS_ASSESSMENT_ON_REAL_CONTEXT = NOT_YET_AUTHORIZED**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

## 24. Próximo passo

> **Aplicar o hardening ao Documento 46 e reexecutar este gate.**

Somente PASS/PASS_WITH_ARCHITECTURAL_DECISIONS poderá autorizar a primeira avaliação de readiness em contexto real.


---

# RECHECK FINAL APÓS HARDENING

## 25. Objeto do recheck

O recheck foi executado contra o Documento 46 após o hardening persistido no commit:

4bbcb180cecf6659934a4f1e9e1bf32c90639013

Foram reavaliados todos os achados ERG-01–ERG-20.

## 26. ERG-01 — synthetic leakage

Fechado.

O protocolo agora exige prova positiva de realidade/admissibilidade, não mera ausência de label sintético.

> **PASS**

## 27. ERG-02 — authority

Fechado.

IA/system pode preparar assessment, mas READY_FOR_CALIBRATION exige human verification compatível com os domínios científico/metodológico e operacional materialmente envolvidos.

Essa verificação não equivale a normative activation.

> **PASS_WITH_ARCHITECTURAL_DECISION**

## 28. ERG-03 — blocker dominance

Fechado.

READY exige blocker set material vazio.

Não é permitido READY com NEEDS_HUMAN_AUTHORITY, NEEDS_SOURCE_CHARACTERIZATION, capacity conflict ou outro blocker material registrado como secundário.

> **PASS**

## 29. ERG-04 e ERG-15 — amostra, cohort e replay

Fechados.

O protocolo agora exige:

- cohort definition;
- inclusion/exclusion;
- observation-window rationale;
- denominator ou limitação explícita;
- case/event count;
- missing/censored count;
- structural breaks;
- peak-load/failure representation;
- pre-specification antes de candidate comparison.

Análise exploratória permanece permitida, mas não sustenta READY sozinha.

> **PASS**

## 30. ERG-05 — external evidence persistence

Fechado.

Fato externo material para READY deve possuir locator persistente/auditável.

Sem preservação, não pode ser controlling basis.

> **PASS**

## 31. ERG-06 — measurement schedule drift

Fechado.

Measurement schedule:

- permanece explicitamente non-normative;
- possui lifecycle;
- não pode ser vinculado a policy/cadence/SLA;
- não produz compliance/overdue/breach;
- não aciona notification/auto-escalation;
- não vira candidate por persistência.

> **PASS**

## 32. ERG-07 — R7

Fechado.

Not applicable exige rationale e verification compatível quando material.

Unknown não pode ser convertido em not applicable.

> **PASS**

## 33. ERG-08 — source behavior versus latency

Fechado.

O protocolo separa documented source schedule, observed source latency, availability, OES detection latency e polling/process latency.

> **PASS**

## 34. ERG-09 — zero-event fallacy

Fechado.

Zero event sem coverage/denominator/observability adequados não sustenta adequação.

> **PASS**

## 35. ERG-10 — drift invalidation

Fechado.

Antes de abrir Calibration Dossier, READY deve ser revalidado contra target, Monitor, source/API, workflow, capacity, calendar, authority, external rule e evidence cut-off.

> **PASS**

## 36. ERG-11 — governance judgment

Permanece fechado.

Judgment não preenche dado ausente.

> **PASS**

## 37. ERG-12 — capacity laundering

Fechado com hardening adicional.

Observed constrained performance foi separado de sustainable capacity e resource deficit.

> **PASS**

## 38. ERG-13 — calendar laundering

Permanece fechado.

Institutional calendar depende de obligation/authority, não de horário informal da equipe.

> **PASS**

## 39. ERG-14 — fixed deadline applicability

Fechado.

Legal/regulatory/contractual/institutional applicability exige autoridade institucional competente.

Automação pode extrair e sinalizar; não pode decidir applicability normativa sozinha.

> **PASS**

## 40. ERG-16 — real-case overgeneralization

Fechado.

Pilot readiness vale somente para exact context.

Transportability exige nova avaliação quando diferenças materiais existirem.

> **PASS**

## 41. ERG-17 — segundo sistema normativo

Permanece fechado.

Readiness artifact continua metodológico/governamental e não armazena valor normativo decisório.

> **PASS**

## 42. ERG-18 — circularidade com Calibration Dossier

Permanece fechado.

READY apenas autoriza abertura de dossier real inicial; dossier não retroage para reescrever readiness.

> **PASS**

## 43. ERG-19 — prospective observation data governance

Fechado.

Observation Plan exige minimização, finalidade, acesso, segurança, retenção, confidentiality/privacy e provenance.

Quando governance específica for necessária, observação não começa antes dela.

> **PASS**

## 44. ERG-20 — stale readiness

Fechado.

Todo READY exige reassess_by ou rationale explícita para ausência de data fixa, além de event-based invalidation triggers.

> **PASS**

## 45. Decisões arquiteturais preservadas

O recheck consolida:

1. readiness é pré-calibração;
2. readiness não é Calibration Dossier;
3. readiness não contém valor normativo;
4. READY apenas autoriza abrir dossier real inicial;
5. human verification do READY não é normative approval;
6. measurement schedule é não normativo;
7. evidence readiness pode ser documental sem migration nova;
8. migration 032 continua suficiente para o passo seguinte;
9. qualquer novo stratifier/time basis/endpoint/authority semantics retorna à arquitetura;
10. blockers materiais dominam READY.

## 46. Autorização resultante

> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READINESS_ASSESSMENT_ON_REAL_CONTEXT = AUTHORIZED_UNDER_PROTOCOL**

Essa autorização permite:

- selecionar um exact real context;
- inventariar evidência real;
- classificar inputs R1–R7;
- emitir readiness state sob o protocolo;
- recomendar observation plan não normativo quando necessário.

Ela não permite:

- escolher cadence/SLA/grace/warning/threshold;
- abrir Calibration Dossier se o resultado não for READY_FOR_CALIBRATION;
- normative activation;
- real CadenceContract;
- real SLARule;
- real SLACalendarVersion;
- real calibrated UpdatePolicy;
- scheduler;
- notification delivery;
- auto-escalation;
- M3 unblock.

## 47. Estado final

> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **FIRST_REAL_READINESS_ASSESSMENT = AUTHORIZED_FOR_SELECTION_AND_EXECUTION**

> **REAL_CALIBRATION_DOSSIER = CONDITIONALLY_AUTHORIZED_ONLY_AFTER_CONTEXT_SPECIFIC_READY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **SCHEDULER = DEFERRED**

> **NOTIFICATIONS = DEFERRED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 48. Próximo passo exato

> **Após checkpoint, selecionar em modo alto o primeiro exact real context para Evidence Readiness e executar apenas o readiness assessment, sem iniciar calibração numérica.**

A seleção do primeiro contexto deve evitar generalização indevida e deve explicitar por que aquele contexto é adequado como primeiro piloto metodológico.
