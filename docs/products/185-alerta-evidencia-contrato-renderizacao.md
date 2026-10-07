# 185 — EvidenceAlertView: Contrato de Renderização do Alerta de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **RENDERING_CONTRACT_READY**  
**Dependências:** Documentos 177–184; migrations 024–026  
**Input:** `oes.evidence_alert_view/0.1`

---

## 1. Regra central

O renderer consome exclusivamente:

> `product.evidence_alert_view(product_version_uuid)`

Não consulta tabelas diretamente e não reconstrói estado ausente.

---

## 2. O renderer não faz

- não cria Alert;
- não classifica automaticamente;
- não deriva reassessment priority;
- não cria SLA;
- não altera target currentness;
- não cria scientific conclusion;
- não altera assurance;
- não cria expert review;
- não emite recomendação clínica;
- não inicia Fase 4.

---

## 3. Ordem mínima

1. banner de fixture;
2. gate formal;
3. cabeçalho/identidade;
4. headline e summary;
5. classification e reassessment priority;
6. aviso de classificação preliminar;
7. source_context;
8. target;
9. sources;
10. affected dimensions;
11. justification;
12. verification;
13. lifecycle/incorporation;
14. target scientific context;
15. limitations;
16. assurance/audit;
17. publication issues;
18. projection hardening issues;
19. lineage;
20. IDs técnicos.

---

## 4. Estados separados

A apresentação deve distinguir:

- Alert editorial status;
- Alert lifecycle status;
- target currentness, quando target ProductVersion;
- Alert assurance;
- target assurance.

Nunca condensar tudo em “status”.

---

## 5. Classification

Exibir literalmente:

- informational;
- relevant;
- critical.

Sempre acompanhar a regra:

> **Classificação preliminar de comunicação; não constitui atualização automática da conclusão científica.**

Para `critical`:

> **Crítico não implica SLA, auto-update, auto-publicação ou expert review na Fase 3.**

---

## 6. Reassessment priority

Exibir:

- routine;
- priority;
- urgent.

Sempre comunicar:

> **Prioridade qualitativa; nenhum prazo temporal está embutido nesta categoria na Fase 3.**

---

## 7. Source context × target

Exibir em seções separadas.

`source_context` responde:

> em qual Investigation o signal foi detectado/avaliado?

`target` responde:

> qual versão científica pode ser afetada?

Não tratar source_context como target automaticamente.

---

## 8. Target ProductVersion

Exibir:

- Product ID;
- tipo;
- título;
- versão;
- editorial status;
- cutoff;
- assurance;
- currentness;
- scientific conclusion;
- applicability;
- limitations.

Aviso:

> **A conclusão exibida pertence ao target; o Alert não cria nova conclusão científica.**

---

## 9. Target InvestigationVersion

Exibir:

- Investigation ID;
- tipo;
- versão;
- depth;
- maintenance;
- objective;
- cutoff;
- status.

Não inventar:

- Product assurance;
- Product currentness;
- Product conclusion.

---

## 10. Sources

Exibir todas:

- primary;
- supporting.

Por source:

- role;
- type;
- date;
- description;
- locator/identity;
- Monitor/cycle origin quando aplicável;
- source issues.

Não ocultar supporting sources.

---

## 11. Direct source

Quando não houver Monitor origin:

> **Fonte direta: o Alert não deriva de CandidateAssessment/EvidenceEvent persistido em Monitor.**

Preservar warning:

> `ALERT_SOURCE_OUTSIDE_MONITOR`

quando presente.

---

## 12. Affected dimensions

Exibir todas as dimensões, sem score agregado.

Não escolher uma “principal” se o contrato não registrar isso.

---

## 13. Verification

Exibir literalmente:

- unverified;
- ai_verified;
- human_verified;
- human_consensus;
- verifier;
- verifier actor type;
- verification date.

Nunca apresentar AI verification como human verification.

---

## 14. Assurance

Exibir separadamente:

- Alert assurance;
- target assurance.

A2 do Alert:

> não significa A2 do target.

A2:

> não significa expert review.

A3 somente quando houver registro explícito.

---

## 15. Gate

Quando `audit.publishable=true`:

> **Gate formal do Alerta: aprovado.**

Quando false:

> **GATE FORMAL DO ALERTA NÃO APROVADO**

Issues permanecem visíveis em ambos os casos.

---

## 16. Lifecycle

Exibir:

- triage;
- evaluation;
- incorporated;
- discarded.

Para `incorporated`:

> mostrar linkage projetado, sem afirmar mudança de conclusão além do que a View registra.

Para `discarded`:

> mostrar rationale.

---

## 17. Alert sem currentness próprio

Não criar seção “currentness do Alert”.

Quando útil, declarar:

> **O estado de atualidade científico exibido é o do target, não do Alert.**

---

## 18. Alert sem scientific conclusion própria

Não usar `summary` ou `justification` como se fossem conclusion científica.

---

## 19. Publication issues

Renderizar todos:

- errors;
- warnings.

Warnings não devem ser visualmente convertidos em blockers.

---

## 20. Projection hardening issues

Renderizar em seção distinta.

Quando vazia:

> **Nenhum issue de projection hardening ativo.**

---

## 21. Lineage

Exibir dependencies projetadas, incluindo:

- maintenance_alert_target;
- maintenance_alert_source quando aplicável;
- maintenance_alert_incorporation quando aplicável.

---

## 22. Fixture

Quando `audit.synthetic_fixture=true`:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA ALERTA REAL**

---

## 23. Critérios de PASS

O contrato está pronto se o template consegue, usando somente a View:

1. renderizar Alert A formal;
2. mostrar Alert B bloqueado AI-only;
3. mostrar Alert C critical/direct source;
4. separar context e target;
5. separar Alert assurance e target assurance;
6. separar lifecycle e editorial status;
7. preservar todas as sources;
8. preservar múltiplas dimensions;
9. preservar human/AI verification;
10. mostrar warnings/errors;
11. não criar currentness/conclusion do Alert;
12. não inferir Fase 4.

Todos estão satisfeitos pela `EvidenceAlertView 0.1`.

---

## 24. Próxima etapa

> **Especificar e implementar o Template Operacional do Alerta de Evidência.**

---

**Resultado:** contrato de renderização do Alerta pronto.
