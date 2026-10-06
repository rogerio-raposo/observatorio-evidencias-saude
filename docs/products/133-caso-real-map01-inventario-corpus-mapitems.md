# 133 — Caso Real MAP-01: Inventário Formal do Corpus e MapItems Elegíveis

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Mapa de Evidências  
**Caso:** MAP-01 — ambient AI scribes: mapa exploratório do corpus N3-01  
**Data:** 6 de outubro de 2026  
**Status:** inventário pré-persistência  
**Dependência:** Documento 132

---

# 1. Finalidade

Fechar a lista de versões de entidades que poderão constituir MapItems do MAP-01 antes da criação de FrameworkVersion, assignments e Product.

Princípios:

- reutilizar versões concretas já persistidas;
- não duplicar Report como Study;
- não incluir registros excluídos pelo screening;
- não transformar literatura contextual em evidência causal;
- preservar a distinção entre Study, Report e Synthesis.

---

# 2. Resultado do inventário

MapItems elegíveis:

- **5 StudyVersions**;
- **8 ReportVersions contextuais/secundárias**;
- **4 SynthesisVersions**.

Total:

> **17 MapItems**

Counting unit principal:

> **Study**

Portanto:

> Reports e Syntheses permanecem visíveis no mapa, mas não aumentam `study_count`.

---

# 3. Study MapItems

| TargetVersion | OES ID | Estudo | evidence_role | outcome_domain candidato |
|---|---|---|---|---|
| `e1000000-0000-0000-0000-000000000101` | OES-ST-2026-000701 | Lukac et al. randomized trial | comparative_randomized_study | documentation_time; workload_work_exhaustion; note_quality_safety |
| `e1000000-0000-0000-0000-000000000102` | OES-ST-2026-000702 | Afshar et al. stepped-wedge randomized trial | comparative_randomized_study | documentation_time; workload_work_exhaustion; work_outside_work; note_quality_safety |
| `e1000000-0000-0000-0000-000000000103` | OES-ST-2026-000703 | Chowdhury et al. randomized crossover trial | comparative_randomized_study | documentation_time; workload_work_exhaustion; work_outside_work |
| `e1000000-0000-0000-0000-000000000104` | OES-ST-2026-000704 | Stults et al. pre-post QI study | contextual_primary_study | documentation_time; broader_implementation_context |
| `e1000000-0000-0000-0000-000000000105` | OES-ST-2026-000705 | Taylor et al. prospective note-quality pilot | contextual_primary_study | note_quality_safety; broader_implementation_context |

## 3.1 Justificativa

As classificações dos três estudos randomizados seguem a cobertura de outcomes explicitamente registrada no Documento 107 e nas SynthesisVersions do N3.

Stults permanece contextual e não é promovido a unidade causal equivalente aos RCTs.

Taylor permanece contextual para qualidade/segurança e implementação.

---

# 4. Synthesis MapItems

| TargetVersion | OES ID | Synthesis | evidence_role | outcome_domain |
|---|---|---|---|---|
| `e1000000-0000-0000-0000-000000000501` | OES-SY-2026-000701 | Narrative synthesis — documentation time | synthesis | documentation_time |
| `e1000000-0000-0000-0000-000000000502` | OES-SY-2026-000702 | Narrative synthesis — workload/work exhaustion | synthesis | workload_work_exhaustion |
| `e1000000-0000-0000-0000-000000000503` | OES-SY-2026-000703 | Narrative synthesis — work outside work | synthesis | work_outside_work |
| `e1000000-0000-0000-0000-000000000504` | OES-SY-2026-000704 | Narrative synthesis — note quality/safety | synthesis | note_quality_safety |

Estas classificações são diretamente deriváveis do `outcome_entity_uuid` e da identidade persistida da SynthesisVersion.

---

# 5. Contextual Report MapItems

Reports que permanecem elegíveis como MapItems contextuais porque foram incluídos no corpus, mas não devem duplicar os cinco Study MapItems existentes.

| TargetVersion | OES ID | Report | evidence_role | outcome_domain candidato |
|---|---|---|---|---|
| `e1000000-0000-0000-0000-000000000206` | OES-RP-2026-000706 | Bracken et al. systematic review | contextual_secondary_report | broader_implementation_context |
| `e1000000-0000-0000-0000-000000000211` | OES-RP-2026-000711 | Kanaparthy et al. rapid review | contextual_secondary_report | broader_implementation_context |
| `e1000000-0000-0000-0000-000000000212` | OES-RP-2026-000712 | van Linschoten et al. before-after mixed-methods | contextual_secondary_report | broader_implementation_context |
| `e1000000-0000-0000-0000-000000000213` | OES-RP-2026-000713 | Harvey et al. prospective implementation study report | contextual_secondary_report | broader_implementation_context |
| `e1000000-0000-0000-0000-000000000214` | OES-RP-2026-000714 | mixed-methods outpatient trial evaluation report | contextual_secondary_report | broader_implementation_context |
| `e1000000-0000-0000-0000-000000000215` | OES-RP-2026-000715 | documentation burden and burnout report | contextual_secondary_report | workload_work_exhaustion; broader_implementation_context |
| `e1000000-0000-0000-0000-000000000216` | OES-RP-2026-000716 | trainee documentation burden report | contextual_secondary_report | workload_work_exhaustion; broader_implementation_context |
| `e1000000-0000-0000-0000-000000000217` | OES-RP-2026-000717 | EPIC Signal / physician workload report | contextual_secondary_report | workload_work_exhaustion; broader_implementation_context |

## 5.1 Regra conservadora

Quando o título/metadata persistida não sustenta classificação explícita em um outcome crítico específico:

> classificar somente em `broader_implementation_context`.

Não inferir outcomes adicionais a partir de expectativas sobre o desenho.

---

# 6. Reports explicitamente não elegíveis

## 6.1 Reports 201–205

Não serão MapItems separados porque já possuem StudyVersion canônica no MAP-01:

- 201 → Study 101;
- 202 → Study 102;
- 203 → Study 103;
- 204 → Study 104;
- 205 → Study 105.

Eles continuarão recuperáveis como referências via Study–Report linkage.

## 6.2 Report 207

- preprint de Lukac;
- screening full text = `exclude`;
- reason = `duplicate_report`.

> **Não elegível como MapItem.**

## 6.3 Reports 208–210

Excluídos por setting/secondary-review rule.

> **Não elegíveis como MapItems.**

## 6.4 Reports 218–220

Screening corretivo:

- 218 = simulated encounters;
- 219 = simulated encounters;
- 220 = narrative secondary review not update unit.

> **Não elegíveis como MapItems.**

---

# 7. Reconciliação com screening

Corpus contextual original incluído:

- Reports 201–206.

Destes:

- 201–205 são representados pelos respectivos Study MapItems;
- 206 permanece Report MapItem contextual.

Busca corretiva:

- Reports 211–217 = full-text include;
- Reports 218–220 = exclude.

Assim:

> **nenhum Report excluído entra no inventário.**

---

# 8. evidence_context candidato

Classificações candidatas:

## 8.1 ambient_vs_usual_care

- Study 101;
- Study 102;
- Syntheses 501–503 quando aplicável.

## 8.2 head_to_head_vendor

- Study 103;
- Syntheses 501–503 quando o contexto head-to-head estiver incorporado.

## 8.3 implementation_context

- Study 104;
- Reports 212–217;
- eventualmente Study 105 como contexto complementar.

## 8.4 secondary_review_context

- Report 206;
- Report 211.

## 8.5 quality_safety_context

- Study 105;
- Synthesis 504.

Essa dimensão será filtro e não altera as células principais.

---

# 9. CellScope candidato

Matriz:

> `evidence_role × outcome_domain`

## 9.1 Comparative randomized study

Em escopo para:

- documentation_time;
- workload_work_exhaustion;
- work_outside_work;
- note_quality_safety.

`broader_implementation_context`:

> `excluded_by_framework`

Motivo:

> essa célula não representa o papel principal atribuído aos RCTs no framework MAP-01.

## 9.2 Contextual primary study

Todas as cinco categorias permanecem:

> `in_scope`

## 9.3 Contextual secondary report

Todas as cinco categorias permanecem:

> `in_scope`

## 9.4 Synthesis

Em escopo para os quatro outcomes críticos.

`broader_implementation_context`:

> `not_applicable`

Motivo:

> o N3-01 produziu quatro syntheses outcome-específicas e não uma synthesis de implementação ampla.

---

# 10. Apparent gap eligibility

Para células `in_scope`:

> `gap_eligible=true`

Como o Framework usa:

> `gap_claim_mode=apparent_only`

uma célula vazia poderá produzir apenas:

> **apparent gap**

Nunca formal gap.

Células `excluded_by_framework` ou `not_applicable`:

> `gap_eligible=false`

---

# 11. Inventário quantitativo esperado

Antes das assignments:

- Study MapItems = 5;
- Report MapItems = 8;
- Synthesis MapItems = 4;
- total MapItems = 17.

CellScope:

- 4 evidence-role categories × 5 outcome categories = 20 células;
- 18 células `in_scope`;
- 1 `excluded_by_framework`;
- 1 `not_applicable`.

---

# 12. Critérios de persistência

A implementação deverá falhar se:

- número de MapItems != 17;
- qualquer Report excluído entrar como MapItem;
- qualquer Report 201–205 for contado como MapItem adicional;
- Study 101–105 estiver ausente;
- Synthesis 501–504 estiver ausente;
- CellScope tiver quantidade/status diferentes sem decisão documental anterior;
- gap mode não for `apparent_only`;
- coverage não for `structured_non_exhaustive`.

---

# 13. Decisão

> **Inventário formal MAP-01 fechado em 17 MapItems.**

Próxima etapa:

> **produzir o codebook v0.1 do Framework MAP-01, com regras de classificação reproduzíveis para evidence_role, outcome_domain e evidence_context.**

---

**Resultado:** corpus elegível delimitado antes da persistência do Mapa.
