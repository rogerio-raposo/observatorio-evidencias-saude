# 172 — Monitor de Evidências: Projection Readiness Gate 02 pós-hardening

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **Projection Readiness = READY**  
**Dependências:** Documentos 165–171; migrations 021–022; MON-T01–T33; MONH-T01–T24

---

## 1. Finalidade

Reexecutar adversarialmente o Projection Readiness Gate da futura:

> `oes.evidence_monitor_view/0.1`

após o hardening da migration 022.

O gate revisita explicitamente:

- PR-MON-01;
- PR-MON-02;
- PR-MON-03;
- PR-MON-04;
- PR-MON-05.

READY neste documento significa:

> **o estado persistido possui semântica suficiente para implementar uma View determinística e auditável.**

Não significa:

- template ready;
- Caso Real ready;
- M3 formal ready;
- Fase 4 iniciada.

---

## 2. Resultado

> **READY**

Todos os cinco blockers do Documento 169 foram materialmente resolvidos.

A migration candidata:

> `database/023_evidence_monitor_view_rendering_readiness.sql`

fica autorizada para implementar a EvidenceMonitorView 0.1 e seus helpers de projeção.

---

# 3. PR-MON-01 — múltiplas categorias de impacto

Estado anterior:

> NOT_READY

Problema:

- `candidate_assessment.impact_class` singular;
- Documento 165 permite múltiplas categorias por evidência.

Hardening:

> `maintenance.candidate_impact`

Agora:

- relação 1:N;
- classes normalizadas;
- classe duplicada rejeitada;
- no máximo um primary;
- cycle completion exige exatamente um primary para candidate retido;
- primary child deve corresponder ao resumo legado;
- impact rows tornam-se imutáveis com o julgamento.

Fixture:

- candidate científico possui:
  - quantitative = primary;
  - certainty = secondary.

Testes:

- MONH-T01–T05 = PASS.

Decisão:

> **PR-MON-01 = PASS / RESOLVED**

A futura View poderá projetar:

- `primary_impact_class`;
- `impacts[]`;

sem interpretar JSON livre.

---

# 4. PR-MON-02 — source policy parcialmente interpretada

Estado anterior:

> NOT_READY

Hardening:

> `maintenance.monitor_source_requirement`

A obrigação operacional machine-readable deixa de depender de interpretação aberta do JSON.

Kinds v0.1:

- `source_name`;
- `source_class`;
- `minimum_distinct_bibliographic_sources`.

`source_policy_payload` permanece:

> descrição rica do plano.

Semântica operacional:

> **somente SourceRequirement normalizado constitui requisito machine-enforced novo.**

Compatibilidade:

- `required_source_names` declarado no JSON deve possuir requirement normalizado;
- `required_source_classes` idem;
- `minimum_bibliographic_sources` idem.

Um novo tipo de requisito não reconhecido:

> é rejeitado pela constraint; não é silenciosamente tratado como cumprido.

Teste:

- MONH-T06–T08 = PASS.

Decisão:

> **PR-MON-02 = PASS / RESOLVED**

A futura View poderá projetar separadamente:

- policy descritiva;
- requirements normalizados;
- status de cada requirement.

---

# 5. PR-MON-03 — exceções de cobertura

Estado anterior:

> NOT_READY

Hardening reutiliza:

> `investigation.method_decision`

Source exception válida exige:

- Monitor Investigation correta;
- `stage='search'`;
- `decision_code='monitor_source_requirement_exception'`;
- cycle UUID;
- requirement code;
- record active;
- resolution accepted/mitigated;
- `allow_exception=true`.

O helper de status distingue:

- `fulfilled`;
- `exception_applied`;
- `satisfied`;
- MethodDecision concreta.

Logo:

> **exception não é projetada como source executada.**

Testes:

- MONH-T09 = accepted exception;
- MONH-T10 = open exception não satisfaz.

Resultado:

> PASS

Decisão:

> **PR-MON-03 = PASS / RESOLVED**

---

# 6. PR-MON-04 — temporal consistency e Search drift

Estado anterior:

> NOT_READY

Hardening agora avalia:

- window anterior ao baseline;
- window posterior à completion date;
- previous cycle ausente quando exigido;
- gap temporal não explicado;
- Search Investigation drift;
- Search status diferente de completed;
- Search fora da cycle window.

Exceções temporais:

- `monitor_search_temporal_exception`;
- `monitor_cycle_window_gap_exception`.

Após revisão adversarial pós-CP79 foi identificado um resíduo:

> o helper genérico de exceções não exigia inicialmente `stage='search'`.

Correção:

- commit `04fa93df0eff601cc76df1274fcbfb4d403a516c`;
- o helper passou a exigir `stage='search'`.

Teste reforçado:

- commit `06ea4b203b3d2d3a1425f7f4c7fe3c4a1d764aed`;
- decisão accepted no estágio errado não satisfaz;
- decisão accepted em `search` satisfaz.

Search drift é reavaliado dinamicamente para os campos que determinam validade operacional v0.1:

- InvestigationVersion;
- status;
- executed_at;
- source_name;
- source_class.

Source-name/source-class drift repercute no status dos SourceRequirements.

Todos os completed cycles entram no hardening gate do produto.

Testes:

- MONH-T11–T17;
- MONH-T20;
- revalidação adicional do MONH-T12 pós-CP79.

Resultado:

> PASS

Decisão:

> **PR-MON-04 = PASS / RESOLVED**

Observação de escopo:

A migration 022 não torna globalmente `investigation.search` append-only.

Isso é coerente com o Documento 170:

> não alterar o contrato global de Search nesta migration.

A futura View deve tratar Search como registro canônico atual e projetar os issues dinâmicos do Monitor.

---

# 7. PR-MON-05 — Cycle → CurrencyState

Estado anterior:

> NOT_READY

Hardening:

> `maintenance.guard_cycle_currency_state_mutation()`

Agora:

- UPDATE proibido;
- DELETE proibido;
- o vínculo histórico é imutável.

Correção científica:

> novo cycle + nova CurrencyState.

Testes:

- MONH-T18;
- MONH-T19.

Resultado:

> PASS

Decisão:

> **PR-MON-05 = PASS / RESOLVED**

---

# 8. Regressões

Contrato 021:

- MON-T01–T32 = PASS.

Idempotência da cadeia:

- MON-T33 = PASS para `021 → 022`.

Hardening:

- MONH-T01–T22 = PASS;
- MONH-T23 = migration 022 re-apply PASS;
- MONH-T24 = rebuild-through-022 PASS.

M2:

> formal A2 permanece publishable.

M3:

> blocker `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL` permanece.

Nenhuma regra da Fase 4 foi antecipada.

---

# 9. Evidência final pós-correção adversarial

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37555981343**

Run number:

> **127**

HEAD:

`06ea4b203b3d2d3a1425f7f4c7fe3c4a1d764aed`

Conclusão:

> **success**

Incluindo:

- install through migration 022;
- Monitor contract/hardening step;
- chain re-apply;
- 022 re-apply;
- regressões globais;
- rebuild-from-zero.

Artifact:

- id **11454409428**;
- name `oes-s5-evidence-37555981343`;
- size **196573 bytes**;
- digest `sha256:c2cc76b684d1e89f5a4ae4aadf8067d6c1a659b62384242f7ebc9a48cb69e4ad`.

---

# 10. O que a View já pode projetar sem inferência metodológica externa

## Identity

- Monitor Product;
- Monitor ProductVersion;
- editorial status;
- baseline cutoff;
- publication date.

## Question/Investigation

- primary Question;
- inherited depth;
- maintenance level;
- protocol artifact;
- Monitor Investigation status.

## Monitor plan

- scope;
- source policy;
- normalized source requirements;
- strategy;
- cadence;
- impact policy;
- escalation policy.

## Operational state

- current MonitorState;
- history quando desejado.

## Monitor currentness

- `product.currency_state` da própria Monitor ProductVersion.

## Target

- ProductVersion ou InvestigationVersion;
- identity;
- inherited depth;
- baseline cutoff;
- target editorial status quando aplicável;
- target assurance quando aplicável;
- target currentness quando aplicável;
- target scientific conclusion quando aplicável.

## Cycles

- lifecycle;
- windows;
- previous cycle;
- Searches;
- requirement status;
- exceptions;
- temporal issues;
- EvidenceEvents;
- CandidateAssessments;
- CandidateImpacts;
- maintenance decision;
- verification;
- escalation recommendation;
- resulting target CurrencyState.

## Audit

- Monitor assurance;
- target assurance;
- publication issues 021;
- projection-hardening issues 022;
- publishable;
- M3 blocker;
- dependency lineage.

Nada acima exige:

> cálculo científico novo dentro da View.

---

# 11. Regras obrigatórias para migration 023

EvidenceMonitorView deverá:

1. ser read-only;
2. não executar Search;
3. não criar CandidateAssessment;
4. não criar CurrencyState;
5. não alterar target conclusion;
6. não criar Alert;
7. não inferir human verification;
8. projetar Monitor currency e target currency separadamente;
9. projetar `fulfilled` e `exception_applied` separadamente;
10. projetar múltiplos CandidateImpacts;
11. projetar temporal/hardening issues;
12. projetar blockers M3;
13. manter baseline cutoff separado do latest cycle cutoff;
14. distinguir target ProductVersion de target InvestigationVersion;
15. não transformar warning em error nem error em warning;
16. ordenar arrays deterministicamente.

---

# 12. Projection schema candidato confirmado

Schema:

> `oes.evidence_monitor_view/0.1`

Estrutura:

```text
EvidenceMonitorView
├── schema_version
├── identity
├── question
├── monitor_investigation
├── monitor_plan
│   ├── surveillance_scope
│   ├── source_policy
│   ├── source_requirements[]
│   ├── strategy_policy
│   ├── cadence_policy
│   ├── impact_policy
│   └── escalation_policy
├── operational_state
├── monitor_currency
├── target
├── latest_cycle
├── cycles[]
│   ├── window
│   ├── execution
│   ├── searches[]
│   ├── source_requirement_status[]
│   ├── temporal_issues[]
│   ├── events[]
│   ├── candidates[]
│   │   └── impacts[]
│   ├── maintenance_decision
│   ├── verification
│   ├── escalation_recommendation
│   └── resulting_target_currency
├── update_lineage
├── limitations
├── quality_controls[]
└── audit
    ├── assurance_level
    ├── target_assurance_level
    ├── publication_issues[]
    ├── projection_hardening_issues[]
    └── publishable
```

---

# 13. Template readiness

Permanece:

> **NOT_EVALUATED**

Projection Readiness = READY autoriza:

> implementação da View

mas não autoriza:

> template.

Após migration 023 + testes de View:

> executar Rendering Readiness / contrato de apresentação.

---

# 14. Caso Real

Permanece:

> **NOT_AUTHORIZED nesta etapa.**

Não abrir Monitor real apenas porque a View ficou tecnicamente implementável.

---

# 15. Fase 4

Permanece:

> **NÃO INICIADA**

O gate READY não define:

- cadence transversal;
- living thresholds;
- SLAs;
- alert severity;
- políticas globais de atualização.

---

# 16. Decisão final

> **EVIDENCE_MONITOR_PROJECTION_READINESS = READY.**

Autorizado:

> `database/023_evidence_monitor_view_rendering_readiness.sql`

Próxima etapa:

> **implementar EvidenceMonitorView 0.1 + testes de projeção + idempotência + rebuild.**

---

**Resultado:** PR-MON-01–05 resolvidos; a camada persistida está pronta para uma View determinística e auditável, sem iniciar template, Caso Real, Alert ou Fase 4.
