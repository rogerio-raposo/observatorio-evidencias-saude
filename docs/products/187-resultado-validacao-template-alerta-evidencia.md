# 187 — Alerta de Evidência: Resultado da Validação do Template Operacional

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **PASS DA CAMADA DE APRESENTAÇÃO**  
**Dependências:** Documentos 177–186; migrations 024–026

---

## 1. Decisão

> **EVIDENCE_ALERT_PRESENTATION_V0_1 = PASS.**

A camada de apresentação do Alerta de Evidência foi implementada e validada contra as três fixtures canônicas:

- Alert A — formal, derivado do Monitor;
- Alert B — AI-only bloqueado;
- Alert C — critical/direct source com target InvestigationVersion.

Artefatos:

- `templates/evidence-alert.md`;
- `templates/evidence-alert-presentation-map.json`;
- `scripts/render_evidence_alert_reference.py`;
- `scripts/validate_evidence_alert_render.py`.

---

## 2. Semântica preservada

A apresentação mantém separados:

- Alert editorial status;
- Alert lifecycle;
- classification;
- reassessment priority;
- source_context;
- target;
- target currentness;
- Alert assurance;
- target assurance;
- verification;
- publication gate;
- publication issues;
- projection hardening issues.

Também preserva:

- source primary e supporting;
- CandidateAssessment e EvidenceEvent como origens distintas;
- direct source sem origem fictícia em Monitor;
- múltiplas affected dimensions;
- target ProductVersion e InvestigationVersion;
- ausência de Product assurance/currentness/conclusion para target InvestigationVersion;
- ausência de currentness científico próprio do Alert;
- ausência de scientific conclusion própria do Alert.

---

## 3. Limites epistemológicos

O template explicita que:

- classification é preliminar;
- priority é qualitativa;
- `critical`/`urgent` não criam SLA;
- não há auto-update;
- não há auto-publicação;
- não há expert review presumida;
- o Alert não altera a conclusão científica do target.

Assim:

> **nenhuma regra operacional da Fase 4 foi antecipada pela camada de apresentação.**

---

## 4. Runs intermediários

### Run #139

Run:

> `37561330178`

Resultado:

> **failure**

Causa:

- o template renderizava campos de EvidenceEvent dentro de `monitor_origin` também para source CandidateAssessment;
- `monitor_origin.event_type` não existe nesse subtipo.

Correção:

- campos CandidateAssessment passaram a ser condicionados por `candidate_assessment_uuid`;
- campos EvidenceEvent passaram a ser condicionados por `evidence_event_uuid`.

Não houve mudança na View ou no contrato científico.

### Run #140

Run:

> `37561433730`

Resultado:

> **failure**

Causa:

- o validator procurava a substring sem marcação Markdown
  `Assurance de Product: não aplicável`;
- o template correto contém `**Assurance de Product:** não aplicável`.

Correção:

- validator passou a testar os rótulos e a expressão `não aplicável` separadamente;
- nenhuma semântica foi relaxada.

---

## 5. Run final

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37561515491**

Run number:

> **141**

HEAD validado:

`7d525fc978ee623f17a981b9bf42cdf18686c51e`

Conclusão:

> **success**

Confirmado:

- Evidence Alert contract = PASS;
- projection hardening = PASS;
- EvidenceAlertView = PASS;
- template/render/validator = PASS;
- Alert A formal = PASS;
- Alert B AI-only permanece bloqueado;
- Alert C critical/direct source preserva semântica;
- migration 024 re-apply = PASS;
- migration 025 re-apply = PASS;
- migration 026 re-apply = PASS;
- rebuild-from-zero through 026 = PASS;
- regressões globais = PASS.

Artifact:

- id **11456897850**;
- name `oes-s5-evidence-37561515491`;
- size **221190 bytes**;
- digest `sha256:257b26162a577f24cede0c21befd437b1cad4dc6c5847d39ef29e2755d85e099`.

---

## 6. Estado do Alerta na Fase 3

O Alerta possui agora:

- especificação científica/funcional;
- revisão arquitetural;
- contrato de dados;
- migration 024;
- hardening 025;
- Projection Readiness = READY;
- EvidenceAlertView 0.1 / migration 026;
- fixtures A/B/C;
- guards adversariais;
- contrato de renderização;
- template operacional;
- presentation map;
- renderer;
- validator;
- integração S5;
- idempotência;
- rebuild/regressões.

Portanto:

> **ALERTA_DE_EVIDENCIA = FORMALIZED_IN_PHASE_3.**

---

## 7. Caso Real

Caso Real do Alerta não é requisito para o fechamento taxonômico da Fase 3.

Isso não equivale a:

- validação em produção;
- autorização de canais de notificação;
- definição de SLA;
- definição de thresholds;
- política de auto-escalation.

---

## 8. Próxima etapa

> **Executar Gate de Encerramento da Fase 3 contra os nove produtos da taxonomia.**

---

**Resultado final:** Alerta de Evidência formalizado na Fase 3; Fase 4 permanece não iniciada.
