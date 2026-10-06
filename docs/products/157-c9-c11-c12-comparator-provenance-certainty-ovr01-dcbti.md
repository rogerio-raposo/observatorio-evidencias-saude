# 157 — Comparator Stratification, OutcomeEvidence Provenance e Certainty — OVR-01 dCBT-I

**Data:** 6 de outubro de 2026  
**Status:** fechamento preparatório C9, C11 e C12  
**Dependências:** Documentos 149–156; Caso Real N2; CP67

## 1. Finalidade

Fechar prospectivamente:

- C9 — comparator stratification;
- C11 — source provenance de OutcomeEvidence;
- C12 — certainty provenance.

Nenhum Result, Synthesis, CertaintyAssessment ou OutcomeEvidence novo é persistido neste documento.

## 2. Regra geral de comparadores

Estimates de Reviews diferentes não serão tratados como intercambiáveis quando os comparadores diferirem.

Famílias operacionais do protocolo:

1. digital_sleep_education_or_hygiene;
2. waitlist_or_no_treatment;
3. treatment_as_usual;
4. attention_or_active_control;
5. mixed_multiple_controls;
6. other_explicit_control.

## 3. Hwang 2025

### Estimate existente

- ResultVersion: `81000000-0000-0000-0000-000000000301`;
- outcome: insomnia severity;
- timepoint: post-treatment;
- measure: SMD;
- estimate: -0.93;
- IC95%: -1.07 a -0.79;
- k=10;
- I²=68%.

### Comparator

Fonte OES:

> online education about sleep

Família:

> **digital_sleep_education_or_hygiene**

### Source provenance

ResultSource já persistido:

- ReportVersion `81000000-0000-0000-0000-000000000201`;
- source location: Figure 4 / subgroup online education about sleep;
- source type: figure;
- original payload: SMD -0.93; IC95% -1.07 a -0.79; I² 68; k=10;
- primary source = true.

C11 Hwang:

> **PASS**

## 4. Gao 2026

### Estimate existente

- ResultVersion: `81000000-0000-0000-0000-000000000302`;
- outcome: insomnia severity;
- timepoint: post-treatment;
- measure: SMD;
- estimate: -0.82;
- trials=15;
- N=3507.

### Comparator

O estimate materializado no N2 é global/corroborativo e agrega múltiplos controles.

Família:

> **mixed_multiple_controls**

Não converter esse estimate em:

- sleep-education-specific;
- waitlist-specific;
- TAU-specific.

### Source provenance

ResultSource já persistido:

- ReportVersion `81000000-0000-0000-0000-000000000202`;
- source location: Abstract results;
- source type: abstract;
- original payload: SMD -0.82; trials=15; N=3507;
- primary source = true.

O publisher preview também identifica Figure 3 como forest plot de insomnia severity, mas o OES não deverá alterar silenciosamente a fonte já persistida sem nova extração controlada.

C11 Gao:

> **PASS**

## 5. Nazari 2025

### Estimate candidato

A Review reporta para insomnia severity:

- WMD = -3.42;
- IC95% = -4.35 a -2.48;
- P < 0.001;
- I² = 98.1%;
- 49 linhas/trials reportados;
- N=20.118.

### Comparator

Os controles incluem:

- waitlist;
- treatment as usual;
- placebo;
- outros controles.

Família do estimate global:

> **mixed_multiple_controls**

A Review também apresenta subgroup por control intervention (waitlist versus other), mas o OVR-01 v1 não deve criar automaticamente novo estimate comparator-specific sem extração explícita.

### Source provenance preparado

Report futuro:

- Nazari et al. 2025;
- PMID 41798736;
- PMCID PMC12965280;
- DOI 10.18502/ijps.v20i4.19689.

Source location proposta para o estimate global:

> Abstract results + Overall Meta-Analysis Findings / Figure 2.

Source type:

> figure/text.

C11 Nazari:

> **PASS_PREPARATORY**

Condição:

> materializar Report/Result/ResultSource antes de qualquer OutcomeEvidence real.

## 6. C9 — resultado

| Review | Estimate | Família de comparador | Regra |
|---|---|---|---|
| Hwang | SMD -0.93 | digital_sleep_education_or_hygiene | comparator-specific |
| Gao | SMD -0.82 | mixed_multiple_controls | global/corroborativo |
| Nazari | WMD -3.42 | mixed_multiple_controls | global |

Resultado:

> **C9 = PASS**

Consequência:

> Hwang, Gao e Nazari podem coexistir no mesmo cluster temático, mas suas magnitudes não constituem automaticamente o mesmo estimando.

## 7. Concordance decorrente de C9

A direção do efeito pode ser discutida qualitativamente quando compatível.

Magnitude:

> não deve ser comparada diretamente entre Hwang e os estimates globais de Gao/Nazari sem harmonização de comparator/measure/estimand.

Quando necessário:

> usar `not_comparable` ou concordance limitada por dimensão.

## 8. Certainty da Evidence Sheet N2

Existe no N2:

- CertaintyAssessmentVersion `81000000-0000-0000-0000-000000000601`;
- GRADE OES;
- final level moderate;
- ligada à SynthesisVersion 503.

Essa certainty:

> **NÃO é certainty reportada por Hwang, Gao ou Nazari.**

Portanto:

> **não reutilizar no OVR-01 como review-level certainty.**

## 9. Hwang — certainty provenance

Nas fontes integrais/acessíveis verificadas para Hwang:

- não foi identificada avaliação GRADE/certainty-of-evidence review-level;
- há RoB 2 dos primary studies;
- ausência de GRADE não deve ser convertida em low certainty.

Preparação:

> `certainty_assessment_version_uuid = NULL` para OutcomeEvidence de Hwang, salvo descoberta posterior de assessment explícita.

## 10. Gao — certainty provenance

No abstract/publisher preview e nas fontes indexadas acessíveis:

- não foi identificada avaliação GRADE/certainty-of-evidence review-level;
- full method permanece parcialmente inacessível;
- nenhuma certainty deve ser inventada.

Preparação:

> `certainty_assessment_version_uuid = NULL`.

Qualificador:

> ausência confirmada nas fontes acessíveis, não alegação de prova negativa sobre material não acessível.

## 11. Nazari — certainty provenance

O full text acessível:

- usa RoB 2 para risco de viés dos RCTs;
- não contém GRADE;
- não apresenta framework explícito de certainty-of-evidence.

Preparação:

> `certainty_assessment_version_uuid = NULL`.

## 12. C12 — resultado

> **C12 = PASS_WITH_DOCUMENTED_LIMITATION**

Política fechada:

- Hwang certainty = não reportada/não materializada;
- Gao certainty = não identificada nas fontes acessíveis;
- Nazari certainty = não reportada;
- Evidence Sheet N2 GRADE = proibido reutilizar como review-level certainty.

Isso satisfaz o contrato porque ausência de certainty é um estado válido e deve permanecer ausente.

## 13. C11 — resultado agregado

> **C11 = PASS_WITH_PREPARED_NAZARI_MATERIALIZATION**

- Hwang provenance = já persistida;
- Gao provenance = já persistida;
- Nazari provenance = fonte/localização definida para futura materialização.

## 14. Estado

- C9 = PASS;
- C11 = PASS_WITH_PREPARED_NAZARI_MATERIALIZATION;
- C12 = PASS_WITH_DOCUMENTED_LIMITATION;
- C10 ainda pendente;
- C2 continua BLOCKED / NOT_VERIFIED.

## 15. Próxima etapa

> **Produzir ROBIS draft AI-only de Gao e Nazari, preservando Hwang ROBIS existente e sem criar human verification.**

Depois, executar gate pré-persistência consolidado incluindo C2.

**Resultado:** comparator/provenance/certainty policies fechadas sem nova inferência quantitativa.
