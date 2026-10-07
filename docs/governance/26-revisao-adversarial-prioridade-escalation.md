# 26 — Revisão Adversarial da Arquitetura Transversal de Prioridade e Escalation

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — correções arquiteturais requeridas antes de aprovação**  
**Dependência:** Documento 25  
**Objeto:** testar coerência, não compensação, autoridade, anti-circularidade e separação entre prioridade e escalation

---

## 1. Finalidade

Submeter o Documento 25 a revisão adversarial antes de qualquer contrato físico.

A revisão tenta quebrar o desenho nos pontos em que prioridade costuma se confundir com:

- urgência comunicacional do Alert;
- materialidade;
- currentness;
- SLA;
- capacidade;
- severidade;
- escalation;
- autoridade.

---

## 2. Resultado inicial

> **REVISE**

O modelo base é adequado, mas quatro correções são obrigatórias antes de PASS:

1. separar completamente a classe máxima de prioridade da rota de governança;
2. remover floors baseados em fatores isolados que não são dominantes;
3. explicitar autoridade de PriorityAssessment;
4. exigir qualificação apropriada para usar MaterialityAssessment como base autoritativa.

Há também dois ajustes de lifecycle:

5. retirar target supersession/invalidation de dominance gate;
6. impedir que agregação de fila apague causalidade por signal.

---

## 3. AR-F4-P01 — priority × escalation

### Ataque

Documento 25 define a classe:

> `immediate_governance`

mas também afirma:

> priority class e escalation são eixos distintos.

Isso mistura:

- intensidade/precedência de resposta;
- rota de autoridade.

### Decisão

A classe máxima deve ser:

> `immediate`

Governança será representada separadamente por:

- escalation reason;
- escalation route;
- authority/lifecycle.

### Resultado

> **REVISE_REQUIRED**

---

## 4. AR-F4-P02 — floors isolados não dominantes

### Ataque

O Documento 05 estabelece:

> nenhum fator isolado determina prioridade global.

O Documento 25 propõe:

- `material_change_confirmed` isolado → pelo menos expedited;
- `update_recommended` isolado → pelo menos expedited.

Esses floors transformam estados científicos/currentness em prioridade global automática.

### Decisão

Manter floors somente quando houver:

- dominance condition; ou
- combinação explicitamente definida.

Exemplos aceitáveis:

- validity_or_use_threat → urgent;
- suspend_current_use → immediate;
- material_change_confirmed + A1 high → urgent;
- potentially_material + A1 high/A3 high → expedited;
- outdated + A1 high → urgent.

`material_change_confirmed` isolado e `update_recommended` isolado:

> são strong modifiers, não floors universais.

### Resultado

> **REVISE_REQUIRED**

---

## 5. AR-F4-P03 — authority_status ausente

### Ataque

O desenho permite PriorityAssessment conceitual, mas não distingue formalmente:

- proposal;
- authoritative.

Sem isso, uma prioridade produzida por AI/system poderia parecer decisão operacional final.

### Decisão

PriorityAssessment futuro deverá declarar:

- `authority_status = proposal | authoritative`.

Baseline:

- AI/system → proposal;
- human reviewer/expert → authoritative quando a base for científica e dentro de competência;
- owner/governance → authoritative para fila/recurso/governança, sem substituir scientific qualification;
- authoritative downgrade de urgent/immediate exige autoridade compatível com o fundamento dominante.

### Resultado

> **REVISE_REQUIRED**

---

## 6. AR-F4-P04 — materiality AI-only como floor autoritativo

### Ataque

Se PriorityAssessment usar MaterialityAssessment AI-only como base para floor autoritativo, a fronteira já consolidada da migration 027 é enfraquecida.

### Decisão

Para PriorityAssessment **authoritative**:

- outcome científico usado como floor/strong modifier deve ser `human_verified` ou `human_consensus`, quando a regra exigir qualificação científica;
- assessment AI-only pode sustentar proposal;
- dominance mecânica de fonte não deve ser confundida com conclusão científica.

### Resultado

> **REVISE_REQUIRED**

---

## 7. AR-F4-P05 — Alert local × prioridade transversal

### Ataque

Alert possui:

- classification;
- reassessment_priority.

Se houver mapping implícito:

> critical/urgent → transversal urgent

a arquitetura duplica o Alert.

### Estado do Documento 25

O documento rejeita equivalência automática e exige reassessment.

Isso é correto.

A regra anti-silent-downgrade deve especificar que o Alert usado como input precisa ser:

- concreto/versionado;
- verificável;
- não invalidado;
- com status de verificação conhecido.

Não é necessário exigir publicação formal como condição universal de uso interno.

### Resultado

> **PASS_WITH_CLARIFICATION**

---

## 8. AR-F4-P06 — target superseded/invalidated como dominance gate

### Ataque

Supersession/invalidation do target não significa urgência maior por si só.

Pode significar:

- caso encerrado;
- caso redirecionado;
- carry-forward;
- inconsistência de linkage.

### Decisão

Retirar target supersession/invalidation de `dominance gates`.

Tratar em lifecycle:

- issue;
- reassessment;
- closure/retarget explícito.

### Resultado

> **REVISE_REQUIRED**

---

## 9. AR-F4-P07 — breach circularity

### Ataque

Priority seleciona SLA Rule; breach do SLA aumenta priority; priority poderia recalcular o próprio SLA e apagar o breach.

### Estado do Documento 25

O desenho proíbe recalcular silenciosamente a SLA Instance existente.

Breach:

- modifica pressão operacional;
- pode abrir escalation;
- não retroage rule selection.

### Resultado

> **PASS**

---

## 10. AR-F4-P08 — capacidade como compensador

### Ataque

Fila sobrecarregada poderia induzir downgrade de prioridade para “caber” na capacidade.

### Estado

O Documento 25 proíbe essa compensação.

Resultado correto:

> high priority / insufficient capacity

com resource escalation.

### Resultado

> **PASS**

---

## 11. AR-F4-P09 — update cost

### Ataque

Custo alto poderia reduzir prioridade.

### Estado

B4 afeta feasibility/estratégia de execução, não importância.

### Resultado

> **PASS**

---

## 12. AR-F4-P10 — dependency reach

### Ataque

Systemic reach poderia ser confundido com materialidade científica alta.

### Estado

A5 aumenta:

- coordenação;
- propagation assessment priority.

Não aumenta sozinho:

- materiality;
- currentness.

### Resultado

> **PASS**

---

## 13. AR-F4-P11 — queue aggregation

### Ataque

Se vários signals do mesmo target forem reduzidos a uma única prioridade agregada persistida, perde-se causalidade.

### Decisão

Permitir:

- derived queue ordering;
- display da maior response class vigente.

Não permitir, por default:

- substituir PriorityAssessments por signal por um único registro agregado;
- deduplicar causalidade apenas por target.

Qualquer caso agregado futuro exige link explícito para todos os casos componentes.

### Resultado

> **REVISE_WITH_CLARIFICATION**

---

## 14. AR-F4-P12 — safety/integrity dominance

### Ataque

A4 high é exposição estrutural, não signal ativo.

### Estado

Documento 25 não transforma A4 high sozinha em urgent.

Exige:

- signal/fonte;
- qualificação;
- ameaça de uso/validade quando aplicável.

### Resultado

> **PASS**

---

## 15. AR-F4-P13 — validity_or_use_threat

### Ataque

Pode-se alegar que um único MaterialityAssessment estaria determinando prioridade.

### Análise

`validity_or_use_threat` já é uma conclusão qualificada sobre ameaça de validade/uso, não um indicador bruto.

Como dominance rule, pode sustentar:

- floor urgent;
- mandatory escalation assessment.

Desde que authoritative use respeite human qualification.

### Resultado

> **PASS_WITH_AUTHORITY_CONDITION**

---

## 16. AR-F4-P14 — suspend_current_use

### Ataque

Priority `immediate` poderia suspender uso automaticamente.

### Decisão

Não.

A causalidade é:

> UpdateDecision `suspend_current_use` → priority floor immediate + current-use escalation route.

A PriorityAssessment:

- não cria o UpdateDecision;
- não executa publicação/retirada;
- não muda CurrencyState.

### Resultado

> **PASS_AFTER_RENAME**

---

## 17. AR-F4-P15 — no_material_change após Alert critical

### Ataque

Um Alert histórico critical/urgent poderia impedir redução de prioridade mesmo após avaliação humana de no_material_change.

### Estado

Documento 25 permite redução com rationale explícita e preserva o Alert histórico.

### Resultado

> **PASS**

---

## 18. AR-F4-P16 — insufficient_to_decide

### Ataque

Incerteza poderia ser usada para deixar caso crítico em standard indefinidamente.

### Estado

Documento 25 permite expedited/urgent conforme criticidade/safety/deadline/currentness e proíbe downgrade silencioso.

### Resultado

> **PASS**

---

## 19. AR-F4-P17 — escalation candidate × activation

### Ataque

System poderia detectar breach e transformar automaticamente isso em escalation autoritativa.

### Estado

Auto-escalation permanece NOT_AUTHORIZED.

A arquitetura deve reforçar:

- candidate pode ser automático;
- `active` exige authority compatível na baseline;
- issue mecânico pode existir sem equivaler a escalation ativa.

### Resultado

> **PASS_WITH_CLARIFICATION**

---

## 20. AR-F4-P18 — rota não é severidade

### Ataque

Rotas poderiam virar uma hierarquia implícita.

### Estado

Documento 25 define rotas não numéricas e múltiplas.

### Resultado

> **PASS**

---

## 21. AR-F4-P19 — M0–M3

### Ataque

Caso urgent poderia promover automaticamente M1→M2/M3.

### Estado

Independência explícita.

### Resultado

> **PASS**

---

## 22. AR-F4-P20 — N0–N4

### Ataque

Urgência poderia justificar reduzir controles metodológicos.

### Estado

Documento 25 proíbe.

### Resultado

> **PASS**

---

## 23. AR-F4-P21 — prioridade e prazo

### Ataque

Nomes `urgent`/`immediate` poderiam embutir prazo numérico.

### Estado

Documento 25 declara que as classes são ordinais e não contêm duração.

### Resultado

> **PASS**

---

## 24. AR-F4-P22 — fixed deadline

### Ataque

Deadline externo poderia ser reinterpretado como evidência científica.

### Estado

É operational pressure/modifier.

### Resultado

> **PASS**

---

## 25. AR-F4-P23 — currentness

### Ataque

Priority alta poderia escrever CurrencyState.

### Estado

Currentness é read-only para prioridade.

### Resultado

> **PASS**

---

## 26. AR-F4-P24 — triage gap

### Ataque

Persistir PriorityAssessment sem milestone transversal de triage pode criar estado ambíguo.

### Análise

O Documento 25 reconhece que contrato físico não deve ser isolado de:

- triage;
- SLA;
- workflow.

### Resultado

> **PASS_WITH_ARCHITECTURAL_DECISION**

---

## 27. AR-F4-P25 — referências externas

Cochrane, NICE e WHO sustentam:

- atualização orientada a importância/impacto;
- proportional/targeted surveillance;
- atenção diferenciada a safety;
- uso criterioso de recursos;
- revisão dinâmica de prioridade.

Nenhuma fonte sustenta um score universal OES.

### Resultado

> **PASS**

---

## 28. Correções obrigatórias no Documento 25

Antes de PASS:

1. renomear `immediate_governance` → `immediate`;
2. mover governança exclusivamente para escalation route;
3. remover floor universal de `material_change_confirmed` isolado;
4. remover floor universal de `update_recommended` isolado;
5. preservar composite floors:
   - confirmed + high criticality;
   - potentially material + high criticality/sensitivity;
   - outdated + high criticality;
6. adicionar `authority_status`;
7. limitar materiality authoritative input a human-qualified outcome quando aplicável;
8. retirar target supersession/invalidation dos dominance gates;
9. explicitar agregação de fila como derivada;
10. reforçar candidate automático ≠ active escalation.

---

## 29. Estado

Até essas correções:

> **PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = REVISE**

> **MIGRATION_029 = NOT_AUTHORIZED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

---

## 30. Próximo passo

> **Aplicar as correções ao Documento 25 e reexecutar este gate adversarial.**
