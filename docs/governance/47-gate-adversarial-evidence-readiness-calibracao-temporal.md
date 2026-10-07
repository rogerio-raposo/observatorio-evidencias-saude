# 47 — Gate Adversarial do Protocolo de Evidence Readiness Temporal

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — primeira passagem**  
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
