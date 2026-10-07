# 174 — EvidenceMonitorView: Contrato de Renderização do Monitor de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **RENDERING_CONTRACT_READY**  
**Dependências:** Documentos 165–173; migrations 021–023  
**Schema de origem:** `oes.evidence_monitor_view/0.1`

---

## 1. Finalidade

Definir como a `EvidenceMonitorView` alimentará a apresentação do Monitor sem introduzir nova inferência científica, metodológica, editorial ou de assurance.

O renderer será:

> **camada read-only de apresentação da View.**

Não será:

- motor de Search;
- mecanismo de triagem;
- motor de impacto;
- mecanismo de currentness;
- motor de atualização científica;
- mecanismo de Alert;
- motor de assurance;
- approval engine.

---

## 2. Regra central

O renderer consome exclusivamente:

> `product.evidence_monitor_view(product_version_uuid)`

Não poderá consultar diretamente tabelas `maintenance`, `investigation`, `product`, `provenance` ou outras estruturas.

Se um dado necessário à apresentação não estiver na View:

> ele não poderá ser reconstruído pelo renderer.

---

## 3. Quatro dimensões obrigatoriamente separadas

A apresentação deve distinguir visual e semanticamente:

1. **estado editorial do Monitor**;
2. **estado operacional do Monitor**;
3. **currentness da Monitor ProductVersion**;
4. **currentness científico do target**, quando o target for ProductVersion.

Nunca fundir esses estados em um único rótulo “status”.

---

## 4. Baseline × cycles

Exibir separadamente:

- baseline evidence cutoff do Monitor;
- window/cutoff de cada cycle;
- latest completed cycle cutoff.

O renderer não atualizará silenciosamente o baseline do Monitor com o cutoff do cycle mais recente.

---

## 5. Target polimórfico

Quando `target.target_type=product_version`, apresentar:

- Product identity/version;
- product type;
- editorial status;
- cutoff;
- depth herdado;
- assurance;
- target currency;
- scientific conclusion;
- applicability;
- limitations.

Quando `target.target_type=investigation_version`, apresentar:

- Investigation identity/version;
- type;
- depth;
- maintenance;
- objective;
- cutoff;
- status.

Nesse segundo caso, não inventar:

- Product assurance;
- Product currency;
- Product conclusion.

---

## 6. Monitor plan

A camada executiva/metodológica deve expor:

- surveillance scope;
- source policy;
- normalized source requirements;
- strategy policy;
- cadence policy;
- impact policy;
- escalation policy.

`source_policy` é descritiva.

`source_requirements[]` é a fonte machine-readable das obrigações operacionais.

---

## 7. Source requirement status

Por cycle, apresentar separadamente:

- requirement;
- `fulfilled`;
- `exception_applied`;
- `satisfied`;
- MethodDecision de exceção, quando houver;
- evidence payload.

Regra:

> **exception_applied nunca pode ser apresentado como source executada.**

---

## 8. Searches

Exibir somente Searches já projetadas:

- Search ID/UUID;
- source;
- platform;
- source class;
- exact strategy;
- filters;
- execution date;
- result count;
- strategy version;
- operator;
- status;
- temporal acceptability;
- export artifact;
- SearchHits.

O renderer não executa Search, não reconta SearchHits e não corrige drift.

---

## 9. SearchHits

Exibir:

- SearchHit ID;
- report identity quando resolvida;
- source record ID;
- raw title/authors/year/identifier;
- source rank;
- resolution status;
- imported_at.

Ausência de Report resolvido não será ocultada.

---

## 10. Temporal issues

Exibir integralmente:

- code;
- severity;
- message.

Nunca suprimir issue por:

- cycle completed;
- Monitor A2;
- target A2/A3;
- status published.

---

## 11. EvidenceEvents

Exibir:

- event type;
- event date/detected_at;
- affected version;
- source artifact/URI;
- description;
- payload;
- actor;
- verification;
- status.

EvidenceEvent não é automaticamente evidence update nem Alert.

---

## 12. CandidateAssessments

Exibir:

- origin;
- resolved target;
- candidate kind;
- decision;
- exclusion reason;
- primary impact;
- impacts normalizados;
- actor;
- verification;
- assessed_at;
- record status.

Não transformar `pending` em retained/excluded.

---

## 13. CandidateImpacts

Para cada candidate:

- impact class;
- primary/secondary;
- payload;
- rationale;
- sequence.

Regra:

> múltiplas dimensões de impacto permanecem múltiplas.

Não agregar em score único.

---

## 14. Maintenance decision

Exibir literalmente:

- decision;
- rationale;
- decided_by;
- actor_type.

Estados operacionais possíveis devem permanecer os canônicos do payload.

O renderer não decidirá atualização.

---

## 15. Verification

Exibir:

- status;
- verified_by;
- verifier actor type;
- verified_at.

AI verification não pode receber rótulo de human verification.

Ausência de human reviewer/expert não pode ser preenchida artificialmente.

---

## 16. Resulting target CurrencyState

Por cycle, exibir:

- currency state UUID;
- target ProductVersion UUID;
- currency status;
- assessed_at;
- assessed_by;
- rationale;
- record status.

Estados históricos `superseded` continuam visíveis.

---

## 17. Current cycle × latest completed cycle

A View projeta ambos.

A apresentação deve distinguir:

- `latest_cycle`;
- `latest_completed_cycle`.

Um cycle em execução não poderá ser tratado como decisão final apenas por ser numericamente o mais recente.

---

## 18. Method decisions

Exibir `method_decisions[]` com:

- type;
- stage;
- code;
- planned;
- rationale;
- risk;
- mitigation;
- impact;
- resolution;
- actor;
- date;
- artifact.

Exceções permanecem auditáveis mesmo quando accepted/mitigated.

---

## 19. Quality controls

Exibir:

- stage;
- control type/code;
- actor/type;
- qualification;
- independence;
- decision;
- scope;
- agreement;
- discrepancy;
- resolution;
- evidence artifact;
- notes;
- performed_at.

Não inferir qualificação humana pelo nome.

---

## 20. Assurance

Monitor assurance e target assurance permanecem distintas.

Exibir:

- `audit.assurance_level`;
- `audit.target_assurance_level`;
- `audit.required_assurance_level`.

Não apresentar assurance do target como assurance do Monitor.

---

## 21. Publication gate

Se `audit.publishable=true`:

> **Gate formal do Monitor: aprovado.**

Se false:

> **GATE FORMAL DO MONITOR NÃO APROVADO**

Errors e warnings continuam visíveis em ambos os casos.

---

## 22. Publication issues × hardening issues

Separar:

- `audit.publication_issues[]`;
- `audit.projection_hardening_issues[]`.

A camada de apresentação não deve deduplicar ou reinterpretar códigos.

---

## 23. M3

Quando houver:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

exibir explicitamente que:

> **M3 formal permanece bloqueado até política transversal da Fase 4.**

Não ocultar esse blocker e não antecipar thresholds/cadências da Fase 4.

---

## 24. Alert

O Monitor pode projetar eventos/candidatos que futuramente motivem Alert.

A apresentação não poderá:

- criar Alert;
- classificar severity de Alert;
- emitir comunicação de Alert;
- inferir urgency além do que estiver persistido.

Alert é produto/evento separado da taxonomia.

---

## 25. Audit mínimo

Exibir:

- schema version;
- synthetic fixture;
- assurance;
- target assurance;
- required assurance;
- publishable;
- operational status;
- Monitor currency;
- target currency;
- maintenance level;
- baseline cutoff;
- latest completed cycle;
- latest completed cycle cutoff;
- latest cycle verification;
- pending candidates;
- active events;
- source coverage;
- invalidated dependencies;
- M3 policy operational state;
- publication issues;
- hardening issues;
- assurance records.

---

## 26. Camadas de leitura

### Executiva

- título;
- alvo monitorado;
- pergunta;
- editorial/operational/currentness;
- latest completed cycle;
- maintenance decision;
- escalation recommendation;
- gate/assurance;
- limitations.

### Operacional

- plan;
- cycles;
- Searches/SearchHits;
- requirements;
- events;
- candidates/impacts;
- decisions;
- currentness result.

### Metodológica

- protocol;
- method decisions;
- quality controls;
- verification;
- source/temporal exceptions.

### Auditável

- UUIDs;
- lineage;
- issues;
- assurance records;
- provenance derivada;
- schema version.

---

## 27. Ordem mínima da saída v0.1

1. banner de fixture;
2. gate formal;
3. cabeçalho;
4. pergunta;
5. target;
6. quatro dimensões de estado;
7. baseline/current cycle summary;
8. monitor plan;
9. latest completed cycle;
10. cycles históricos;
11. Searches/SearchHits;
12. source requirement status;
13. temporal issues;
14. EvidenceEvents;
15. CandidateAssessments/Impacts;
16. maintenance decisions;
17. target currentness history;
18. method decisions;
19. quality controls;
20. limitations;
21. audit;
22. publication/hardening issues;
23. assurance records;
24. IDs técnicos.

---

## 28. Critérios de PASS do contrato

O contrato está apto ao template se a View permite:

1. target ProductVersion e InvestigationVersion;
2. separação das quatro dimensões de estado;
3. baseline distinto de cycle cutoff;
4. current/latest-completed cycle distinto;
5. Searches e SearchHits;
6. normalized source requirements;
7. fulfilled × exception;
8. temporal issues;
9. events;
10. candidate decisions;
11. múltiplos impacts;
12. verification actor type;
13. resulting target CurrencyState histórico;
14. Monitor assurance × target assurance;
15. publication × hardening issues;
16. M3 blocker;
17. lineage;
18. saída totalmente read-only.

Todos estão satisfeitos pela `EvidenceMonitorView 0.1`.

---

## 29. Projection readiness para template

> **READY**

Não é necessária migration adicional antes do template.

---

## 30. Próxima etapa

> **Especificar e implementar o Template Operacional do Monitor de Evidências.**

---

**Resultado:** contrato de renderização pronto; a View 0.1 suporta apresentação segura sem inferência adicional.
