# 176 — Monitor de Evidências: Resultado da Validação do Template Operacional

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS DA CAMADA DE APRESENTAÇÃO**  
**Dependências:** Documentos 165–175; migrations 021–023

---

## 1. Decisão

> **EVIDENCE_MONITOR_PRESENTATION_V0_1 = PASS.**

A camada de apresentação do Monitor foi implementada e validada contra as fixtures M2 e M3 reais do contrato.

Arquivos:

- `templates/evidence-monitor.md`;
- `templates/evidence-monitor-presentation-map.json`;
- `scripts/render_evidence_monitor_reference.py`;
- `scripts/validate_evidence_monitor_render.py`.

---

## 2. Semântica validada

A apresentação preserva:

- estado editorial do Monitor;
- estado operacional;
- currentness do Monitor Product;
- currentness científico do target;
- baseline cutoff separado do cutoff dos cycles;
- target ProductVersion separado de InvestigationVersion;
- assurance do Monitor separado da assurance do target;
- source requirement fulfilled separado de exception;
- múltiplos CandidateImpacts;
- EvidenceEvent separado de CandidateAssessment;
- cycle atual separado do latest completed cycle;
- AI verification separada de human verification;
- blocker M3/Fase 4 visível.

O renderer não:

- executa Search;
- recalcula coverage;
- recalcula currentness;
- cria CandidateAssessment;
- decide update;
- cria Alert;
- altera assurance;
- inicia Fase 4.

---

## 3. Run intermediário #129

Run:

> `37557966183`

Resultado:

> **failure**

Causa:

- a fixture M3 possui target do tipo InvestigationVersion;
- portanto `latest_completed_cycle.resulting_target_currency` é corretamente `null`;
- o template inicial tentou acessar subcampos desse objeto inexistente.

Correção:

- campos de resulting target currentness passaram a ser condicionais;
- quando o target não possui ProductVersion, a apresentação mostra explicitamente:
  **não aplicável para target sem ProductVersion**.

Não houve mudança no contrato científico, na View ou na migration 023.

---

## 4. Run final #130

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37558043092**

Run number:

> **130**

HEAD validado:

`40762d00f874599716fcbb86271bea4084ca19ef`

Conclusão:

> **success**

Confirmado:

- Monitor contract = PASS;
- projection hardening = PASS;
- EvidenceMonitorView = PASS;
- template/render M2 = PASS;
- validator M2/M3 = PASS;
- migration 021→022 chain re-apply = PASS;
- migration 022 re-apply = PASS;
- migration 023 re-apply = PASS;
- rebuild-from-zero through 023 = PASS;
- regressões globais = PASS.

Artifact:

- id **11455658237**;
- name `oes-s5-evidence-37558043092`;
- size **208203 bytes**;
- digest `sha256:6d80f9f80622713717d373d99ea200481f8926c295587e223a15a2f179bde0e3`.

---

## 5. Estado do Monitor na Fase 3

O Monitor possui agora:

- especificação científica/funcional;
- revisão arquitetural;
- contrato de dados;
- migrations;
- fixtures M2/M3;
- guards adversariais;
- projection hardening;
- EvidenceMonitorView;
- contrato de renderização;
- template operacional;
- renderer;
- validator;
- integração S5;
- rebuild/regressões.

Portanto:

> **MONITOR_DE_EVIDENCIAS = FORMALIZED_IN_PHASE_3.**

---

## 6. Caso Real

A taxonomia da Fase 3 exige a formalização individual dos produtos, não a obrigatoriedade de um Caso Real para cada família.

Assim:

> **um Caso Real do Monitor não é requisito para considerar a formalização do Monitor concluída na Fase 3.**

Isso não significa que o Monitor esteja validado em produção real.

Caso Real futuro poderá ser aberto quando houver finalidade concreta e corpus adequado, sem bloquear a sequência taxonômica atual.

---

## 7. Limites preservados

Ainda não:

- criar Alert automaticamente;
- tornar M3 formalmente operacional;
- definir cadence/thresholds transversais;
- iniciar Fase 4.

O blocker:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

permanece intencionalmente ativo.

---

## 8. Próxima etapa da Fase 3

A taxonomia canônica lista como último produto:

> **OES — Alerta de Evidência**

Próxima etapa:

> **Especificação Científica e Funcional do Alerta de Evidência.**

---

**Resultado final:** Monitor de Evidências formalizado na Fase 3; próximo produto = Alerta de Evidência.
