# 186 — Especificação do Template Operacional do Alerta de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **TEMPLATE_SPEC_READY**  
**Dependências:** Documentos 177–185  
**Input:** `oes.evidence_alert_view/0.1`

---

## 1. Artefatos

Implementar:

- `templates/evidence-alert.md`;
- `templates/evidence-alert-presentation-map.json`;
- `scripts/render_evidence_alert_reference.py`;
- `scripts/validate_evidence_alert_render.py`.

---

## 2. Princípio

O template é apresentação read-only.

Não executa:

- Search;
- classificação;
- cálculo de urgency;
- currentness;
- assurance;
- update;
- Alert adicional;
- notification;
- SLA.

---

## 3. Seções

1. fixture/gate;
2. identidade;
3. headline;
4. resumo;
5. classification;
6. reassessment priority;
7. avisos epistemológicos;
8. source_context;
9. target;
10. sources;
11. affected dimensions;
12. justification;
13. verification;
14. lifecycle/incorporation;
15. limitações;
16. assurance/audit;
17. publication issues;
18. hardening issues;
19. lineage;
20. IDs.

---

## 4. Presentation map

Mapear somente labels de apresentação para:

- editorial status;
- lifecycle;
- classification;
- reassessment priority;
- source role/type;
- verification status;
- actor type;
- target type;
- target currency;
- assurance;
- severity;
- booleans.

Sem lógica científica.

---

## 5. Renderer

`render_evidence_alert_reference.py` deve reutilizar o engine neutro existente.

Regras:

- JSON input;
- Markdown template;
- presentation map;
- output Markdown;
- falhar se sobrar token;
- zero DB access;
- zero mutation do payload.

---

## 6. Validator — Alert A

Exigir:

- schema correto;
- fixture banner;
- gate aprovado;
- relevant;
- priority;
- evaluation;
- human_verified;
- Alert A2;
- target A0;
- target under_evaluation;
- primary CandidateAssessment;
- supporting EvidenceEvent;
- dimensions conclusion + certainty;
- warnings de no expert review / target currentness / target assurance;
- zero hardening errors;
- nenhum token não resolvido.

---

## 7. Validator — Alert B

Exigir:

- under_review;
- ai_verified;
- A1;
- gate bloqueado;
- MISSING_HUMAN_VERIFICATION;
- ASSURANCE_BELOW_A2;
- nenhuma alegação de human review.

---

## 8. Validator — Alert C

Exigir:

- critical;
- urgent;
- target InvestigationVersion;
- target assurance/currentness/conclusion ausentes;
- direct URI source;
- ALERT_SOURCE_OUTSIDE_MONITOR;
- CRITICAL_WITHOUT_EXPERT_REVIEW;
- texto explícito de que critical/urgent não implica SLA ou auto-update.

---

## 9. Validator — invariantes

Exigir:

- source_context separado de target;
- todas as sources renderizadas;
- múltiplas dimensions preservadas;
- Alert sem currentness próprio;
- Alert sem scientific conclusion própria;
- assurance Alert × target separadas;
- lifecycle × editorial separados;
- deterministic render;
- zero inferência Fase 4.

---

## 10. Critérios de PASS

Template v0.1 = PASS quando:

1. A/B/C renderizam corretamente;
2. View é única fonte;
3. nenhum token fica pendente;
4. nenhuma informação científica é recalculada;
5. critical/urgent permanecem qualitativos;
6. S5 integra renderer/validator;
7. migration 026 permanece idempotente;
8. rebuild-through-026 permanece verde;
9. regressões globais permanecem verdes.

---

## 11. Próxima etapa

> **Implementar template, presentation map, renderer e validator; integrar ao S5.**

Após PASS:

> **formalizar o Alerta de Evidência e executar gate de encerramento da Fase 3.**

---

**Resultado:** Template Operacional do Alerta especificado.
