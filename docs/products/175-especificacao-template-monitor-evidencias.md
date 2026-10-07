# 175 — Especificação do Template Operacional do Monitor de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **TEMPLATE_SPEC_READY**  
**Dependências:** Documentos 165–174; migrations 021–023  
**Input contract:** `oes.evidence_monitor_view/0.1`

---

## 1. Finalidade

Definir a primeira renderização Markdown do Monitor de Evidências consumindo exclusivamente:

> `product.evidence_monitor_view(product_version_uuid)`

O template comunica o estado do monitoramento sem criar nova investigação, nova síntese, novo currentness, nova decisão de update ou Alert.

---

## 2. Arquivos

Implementar:

- `templates/evidence-monitor.md`;
- `templates/evidence-monitor-presentation-map.json`;
- `scripts/render_evidence_monitor_reference.py`;
- `scripts/validate_evidence_monitor_render.py`.

---

## 3. Princípios

O template:

- apresenta dados já projetados;
- não consulta banco;
- não recalcula coverage;
- não recalcula currentness;
- não decide update;
- não cria CandidateAssessment;
- não cria CandidateImpact;
- não cria Alert;
- não altera assurance;
- não altera publication gate;
- não antecipa política da Fase 4.

---

## 4. Ordem canônica

1. banner de fixture sintética;
2. gate formal;
3. cabeçalho;
4. pergunta;
5. alvo monitorado;
6. estado do Monitor e do target;
7. resumo operacional;
8. plano de monitoramento;
9. latest cycle;
10. latest completed cycle;
11. histórico de cycles;
12. Searches/SearchHits;
13. source requirements/status;
14. temporal issues;
15. EvidenceEvents;
16. CandidateAssessments/Impacts;
17. maintenance decision;
18. resulting target currentness;
19. method decisions;
20. quality controls;
21. lineage;
22. limitações;
23. assurance/audit;
24. publication issues;
25. projection hardening issues;
26. assurance records;
27. IDs técnicos.

---

## 5. Banner de fixture

Quando:

`audit.synthetic_fixture=true`

exibir:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA MONITOR REAL**

e:

> Searches, events, candidates, impacts, reviewers, assurance, currentness e decisões desta fixture existem exclusivamente para validação técnica.

---

## 6. Gate formal

Quando:

`audit.publishable=true`

exibir:

> **Gate formal do Monitor: aprovado.**

Quando false:

> **GATE FORMAL DO MONITOR NÃO APROVADO**

Nenhum nível de assurance poderá ocultar blocker.

---

## 7. Cabeçalho

Exibir:

- Product ID;
- versão;
- product type;
- Investigation ID;
- depth herdado;
- maintenance level;
- editorial status;
- operational status;
- Monitor currency;
- target currency;
- baseline evidence cutoff;
- latest completed cycle cutoff;
- assurance;
- target assurance;
- assurance requerida;
- publishable.

---

## 8. Pergunta

Exibir:

- normalized question;
- original question quando materialmente distinta;
- structure type;
- context.

---

## 9. Target

### ProductVersion target

Exibir:

- target Product ID;
- type;
- title;
- version;
- editorial status;
- cutoff;
- depth;
- assurance;
- currency;
- scientific conclusion;
- applicability;
- limitations.

### InvestigationVersion target

Exibir:

- Investigation ID;
- type;
- version;
- status;
- depth;
- maintenance;
- objective;
- cutoff.

Não mostrar assurance/currentness/conclusion de Product quando não houver Product target.

---

## 10. Aviso epistemológico permanente

Exibir:

> **O Monitor detecta e avalia sinais de nova evidência; não altera automaticamente a conclusão científica do produto monitorado.**

Exibir também:

> **Monitor currentness e target scientific currentness são estados distintos.**

E:

> **Uma exceção metodológica não equivale à execução da fonte dispensada.**

---

## 11. Monitor plan

Apresentar:

- surveillance scope;
- source policy;
- normalized requirements;
- strategy policy;
- cadence policy;
- impact policy;
- escalation policy.

Source requirements em tabela:

- code;
- kind;
- required value;
- minimum count;
- allow exception;
- rationale.

---

## 12. Latest cycle

Exibir:

- cycle no;
- execution status;
- completeness;
- window;
- start/completion;
- decision;
- verification;
- escalation.

Quando latest cycle não for completed:

> rotular explicitamente como não conclusivo.

---

## 13. Latest completed cycle

Exibir separadamente:

- cycle;
- cutoff;
- maintenance decision;
- rationale;
- verification;
- resulting target currentness.

---

## 14. Histórico de cycles

Tabela-resumo:

- cycle no;
- window;
- status;
- completeness;
- decision;
- verification;
- resulting currency;
- issue count.

Nunca apagar cycles antigos.

---

## 15. Searches

Por cycle:

- Search ID;
- source;
- platform;
- source class;
- executed_at;
- result count;
- strategy version;
- status;
- temporal acceptability.

Exact strategy/filters podem ficar em camada metodológica detalhada.

---

## 16. SearchHits

Exibir:

- SearchHit ID;
- Report ID quando resolvido;
- source record;
- title;
- authors/year;
- identifier;
- rank;
- resolution status.

---

## 17. Source requirement status

Tabela:

- requirement;
- kind;
- fulfilled;
- exception applied;
- satisfied;
- exception MethodDecision.

Quando exception=true:

> **Cumprido por exceção metodológica documentada; a fonte não deve ser apresentada como executada por causa disso.**

---

## 18. Temporal issues

Exibir todos os issues.

Errors antes de warnings.

---

## 19. EvidenceEvents

Tabela:

- event;
- type;
- date;
- source;
- affected version;
- description;
- verification;
- status.

Não rotular automaticamente como Alert.

---

## 20. Candidates

Tabela:

- assessment;
- origin;
- candidate kind;
- decision;
- resolved target;
- primary impact;
- verification;
- actor;
- date.

---

## 21. Impacts

Por candidate retained:

- impact class;
- primary?;
- rationale;
- payload.

Não produzir severity/ranking próprio.

---

## 22. Maintenance decision

Exibir literal:

- decision;
- rationale;
- actor;
- actor type.

Não converter `evaluate_update` em “atualizar” automaticamente.

---

## 23. Verification

Rótulos distintos:

- unverified;
- ai_verified;
- human_verified;
- human_consensus.

AI nunca recebe ícone/texto equivalente a human.

---

## 24. Target currentness history

Quando houver `resulting_target_currency`:

- status;
- assessed_at;
- rationale;
- record status.

Se superseded:

> manter a indicação histórica.

---

## 25. Method decisions

Tabela:

- type;
- stage;
- code;
- rationale;
- resolution;
- decided_by;
- decided_at.

Exceções não devem ser ocultadas.

---

## 26. Quality controls

Tabela:

- stage;
- control type;
- code;
- actor;
- actor type;
- qualification;
- independent;
- decision;
- performed_at.

---

## 27. Lineage

Exibir:

- target dependency;
- derived updates/provenance quando houver.

O renderer não consulta grafo.

---

## 28. Limitações

Exibir literalmente:

- Product limitations;
- target limitations, quando target Product.

Não resumir ou suavizar automaticamente.

---

## 29. Audit

Exibir:

- synthetic fixture;
- Monitor assurance;
- target assurance;
- required assurance;
- publishable;
- operational status;
- Monitor currency;
- target currency;
- maintenance level;
- baseline cutoff;
- latest completed cycle/cutoff;
- latest cycle verification;
- pending candidates;
- active events;
- source coverage;
- invalidated dependencies;
- M3 transversal policy operational state.

---

## 30. Publication issues

Todas as issues da View devem ser renderizadas.

Separar:

- errors;
- warnings.

---

## 31. Projection hardening issues

Renderizar em seção própria.

Quando vazia:

> **Nenhum issue de projection hardening ativo.**

---

## 32. M3

Se publication issue contiver:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

exibir:

> **M3 formal permanece bloqueado até a operacionalização transversal prevista para a Fase 4.**

Não sugerir thresholds/cadência.

---

## 33. Assurance records

Tabela:

- assurance type;
- actor;
- actor type;
- independent;
- decision;
- date.

---

## 34. Presentation map

O arquivo JSON traduzirá, no mínimo:

- editorial status;
- operational status;
- currency status;
- target type;
- maintenance level;
- execution status;
- completeness;
- maintenance decision;
- verification status;
- actor type;
- impact class;
- event type;
- candidate kind;
- requirement kind;
- resolution status;
- severity;
- assurance level;
- booleans.

Sem lógica científica.

---

## 35. Renderer

`scripts/render_evidence_monitor_reference.py`

Reutilizará o engine neutro existente.

Deverá:

- ler template;
- ler JSON da View;
- ler presentation map;
- renderizar;
- falhar com token não resolvido;
- não mutar payload;
- não consultar DB.

---

## 36. Validator — fixture M2 formal

Validar:

- schema `oes.evidence_monitor_view/0.1`;
- fixture sintética;
- gate aprovado;
- Monitor A2;
- target A0;
- editorial published;
- operational active;
- Monitor currency current;
- target currency under_evaluation;
- maintenance M2;
- baseline 2026-10-01;
- 2 cycles;
- latest completed cycle 2;
- cutoff 2026-10-06;
- 3 source requirements;
- 1 Search no cycle 2;
- 1 SearchHit;
- 1 regulatory event;
- candidate com impacts quantitative + certainty;
- candidate de evento com applicability;
- AI verification explícita;
- warnings renderizados;
- zero hardening errors;
- nenhum token não resolvido.

---

## 37. Validator — blocked M3

Renderizar a fixture M3.

Exigir:

- gate bloqueado;
- target InvestigationVersion;
- M3;
- blocker `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`;
- ausência de target assurance/currentness científicos inventados;
- mensagem explícita de dependência da Fase 4.

---

## 38. Validator — exception scenario

Criar cópia em memória do payload M2 com requirement:

- `fulfilled=false`;
- `exception_applied=true`;
- `satisfied=true`;
- MethodDecision sintética.

Exigir:

- texto de exception;
- não mostrar a requirement como source efetivamente executada.

---

## 39. Validator — running latest cycle

Criar cópia em memória com latest cycle:

- status `running`;
- sem maintenance decision final.

Exigir:

- rótulo de cycle em andamento;
- latest completed cycle preservado separadamente;
- nenhuma decisão final inferida.

---

## 40. Validator — AI verification

Exigir:

- `ai_verified` renderizado como IA;
- ausência das expressões que impliquem human review/expert review quando não houver registro.

---

## 41. Validator — multiple impacts

Exigir:

- quantitative como primary;
- certainty como secondary;
- nenhuma perda de dimensão.

---

## 42. Critérios de PASS

Template v0.1 = PASS quando:

1. fixture M2 renderiza;
2. blocked M3 renderiza corretamente;
3. exception scenario preserva semântica;
4. running-cycle scenario não cria decisão final;
5. AI/human verification permanece distinto;
6. multiple impacts permanecem múltiplos;
7. issues são renderizados;
8. nenhum token não resolvido;
9. nenhum cálculo científico novo;
10. integração S5;
11. idempotência das migrations permanece verde;
12. rebuild-through-023 permanece verde;
13. regressões globais permanecem verdes.

---

## 43. Próxima etapa

> **Implementar os quatro artefatos da camada de apresentação e integrar ao S5.**

Após PASS:

> **executar readiness gate pré-Caso Real do Monitor ou, se a Fase 3 não exigir Caso Real, registrar a conclusão técnica do produto antes de avançar ao Alerta de Evidência.**

---

**Resultado:** especificação do Template Operacional do Monitor pronta para implementação.
