# 158 — ROBIS Preparatório C10 — OVR-01 dCBT-I

**Data:** 6 de outubro de 2026  
**Status:** fechamento preparatório C10; AI-only; não persistido no banco  
**Dependências:** Documentos 149–157; CP67

## 1. Finalidade

Fechar C10 por avaliação ROBIS preparatória das Reviews analíticas do OVR-01, sem criar:

- human verification;
- reviewer humano fictício;
- RiskAssessmentVersion nova;
- assurance adicional;
- alteração no Caso Real N2.

## 2. Regras

- usar ROBIS em nível da Review;
- distinguir ROBIS de RoB 2 dos primary studies;
- usar apenas evidência metodológica verificável;
- quando método não estiver acessível, classificar como unclear em vez de inferir qualidade;
- nenhum julgamento recebe human_verified/human_consensus.

## 3. Hwang 2025

Já existe no N2:

- RiskAssessmentVersion `81000000-0000-0000-0000-000000000401`;
- framework ROBIS 2016;
- assessor `OES AI-assisted draft`;
- overall judgement `unclear`;
- status draft.

O OVR-01 deverá reutilizar esse appraisal como draft, sem modificar o N2.

Fonte externa confirma:

- RoB 2 dos RCTs;
- 3 estudos low risk, 19 some concerns, 7 high risk;
- avaliação independente por dois autores com terceiro revisor para discordâncias.

Esses dados descrevem appraisal dos RCTs e não substituem ROBIS da Review.

Decisão OVR-01:

> **Hwang ROBIS = unclear — reuse existing AI-assisted draft.**

## 4. Gao 2026 — evidência metodológica verificável

Fontes acessíveis confirmam:

- systematic review + random-effects meta-analysis;
- 15 RCTs / N=3507;
- REML;
- truncated Knapp-Hartung;
- subgroup analyses;
- exploratory meta-regression;
- cautela explícita dos autores quanto ao pequeno número de app-based studies;
- existe figura de risk-of-bias assessment no material do publisher.

Não foi possível verificar adequadamente nas fontes acessíveis:

- data exata da última busca;
- estratégia de busca completa;
- bases/coverage de forma suficientemente auditável;
- protocolo/registration verificável;
- duplicate screening procedures;
- duplicate data extraction procedures;
- duplicate appraisal procedures.

## 5. Gao — ROBIS domains

### Domain 1 — Study eligibility criteria

Judgement:

> **low**

Rationale:

- população adulta geral;
- fully automated dCBT-I;
- randomized controlled trials;
- outcome de insomnia severity claramente alinhado.

### Domain 2 — Identification and selection of studies

Judgement:

> **unclear**

Rationale:

- C2 last-search date permanece não verificável;
- search strategy/databases não estão suficientemente expostas nas fontes públicas acessíveis;
- não assumir ausência nem adequação.

### Domain 3 — Data collection and study appraisal

Judgement:

> **unclear**

Rationale:

- risk-of-bias assessment existe;
- porém os procedimentos de extração/appraisal independente não são suficientemente verificáveis no material acessível.

### Domain 4 — Synthesis and findings

Judgement:

> **low**

Rationale:

- random-effects;
- REML;
- truncated Knapp-Hartung;
- subgroup/meta-regression;
- interpretação cautelosa;
- nenhuma falha material de síntese foi demonstrada nas fontes acessíveis.

### Overall Gao

> **unclear**

Rationale principal:

> a limitação de acesso ao método e o C2 não resolvido impedem ROBIS overall low; não há base suficiente para overall high.

Verification:

> **AI-only / unverified for OVR-01 persistence purposes.**

## 6. Nazari 2025 — evidência metodológica verificável

Full text confirma:

- PRISMA;
- PROSPERO CRD42023455678;
- PubMed, PsycINFO, Web of Science e Scopus;
- Google Scholar/reference screening suplementar;
- inception a janeiro de 2025;
- English-only;
- três autores no screening;
- extração estruturada;
- RoB 2;
- appraisal independente por dois autores com resolução por consenso;
- random-effects;
- Q/I²;
- subgroup/sensitivity analyses;
- funnel plot/Egger;
- REML + Knapp-Hartung em meta-regression.

Também confirma:

- I²=98.1% no estimate global;
- 49 RCTs declarados;
- subgroup tables com contagens que não reconciliam trivialmente com 49;
- grande heterogeneidade residual.

## 7. Nazari — achado de identidade Study/Report do OES

A reconciliação dos Documentos 151–155 identificou ao menos cinco clusters de múltiplos Reports tratados como linhas separadas na Review:

1. GoodNight;
2. REST;
3. DIALS;
4. SPREAD;
5. Ritterband 2017 / Shaffer 2020.

Assim:

- 49 linhas/artigos da Review;
- 44 Study candidates após os clusters confirmados.

Isso cria risco material de unidade de análise.

Não se afirma neste momento que:

> cada Report duplicado tenha contribuído independentemente para todo pooled estimate.

Mas a Review descreve 49 RCTs e usa as linhas como unidade nas tabelas/subgrupos, o que exige concern elevado até auditoria detalhada do modelo de cada estimate.

## 8. Nazari — ROBIS domains

### Domain 1 — Study eligibility criteria

Judgement:

> **low**

Rationale:

- critérios claros para adultos;
- fully automated dCBT-I;
- RCTs;
- insomnia severity;
- PROSPERO.

### Domain 2 — Identification and selection of studies

Judgement:

> **low**

Rationale:

- múltiplas bases;
- período explícito;
- independent screening;
- full-text review;
- adjudicação;
- citation/reference supplementation.

Limitação:

- English-only.

### Domain 3 — Data collection and study appraisal

Judgement:

> **low**

Rationale:

- data extraction estruturada;
- RoB 2;
- appraisal independente por dois autores;
- discrepancies por consenso.

### Domain 4 — Synthesis and findings

Judgement:

> **high**

Rationale:

- pelo menos cinco clusters de multiple Reports não são tratados como uma Study na lista declarada de 49 RCTs;
- risco material de unit-of-analysis/double counting;
- subgroups reportam contagens que podem exceder/reconciliar mal com o total nominal;
- heterogeneidade extrema (I²=98.1%);
- mixed-control global pooling;
- SD de mudança pode ser derivado com correlação assumida R=0.8;
- extração de gráficos é usada para alguns dados.

Os últimos três pontos não seriam isoladamente suficientes para high, mas aumentam a preocupação no contexto do problema de identidade Study/Report.

### Overall Nazari

> **high**

Rationale principal:

> a ameaça de unidade de análise na síntese é material para a independência das observações e para o peso dos studies no pooled estimate.

Qualificador:

> overall high é um draft AI-only do OES e deve permanecer sujeito a revisão metodológica futura; não representa ROBIS human-verified.

## 9. C10 — resultado

| Review | Overall ROBIS preparatório | Estado |
|---|---|---|
| Hwang 2025 | unclear | existing AI-assisted draft |
| Gao 2026 | unclear | new preparatory AI-only assessment |
| Nazari 2025 | high | new preparatory AI-only assessment |

Resultado:

> **C10 = PASS_WITH_DOCUMENTED_LIMITATIONS**

## 10. Persistência futura

Se OVR-01 for autorizado depois do gate:

- Hwang poderá referenciar/reutilizar o RiskAssessmentVersion existente;
- Gao deverá receber RiskAssessmentVersion própria somente no momento autorizado;
- Nazari deverá receber RiskAssessmentVersion própria somente no momento autorizado;
- assessor deverá permanecer AI-system/OES AI-assisted;
- não usar human_verified/human_consensus.

## 11. Relação com publication gate

Mesmo com ROBIS drafts completos:

> o Overview formal permanecerá bloqueado por ausência de appraisal control humano qualificado e verificação humana independente.

## 12. Estado C1–C12

- C1 PASS;
- C2 BLOCKED / NOT_VERIFIED;
- C3 PASS;
- C4 PASS;
- C5 PASS_WITH_DOCUMENTED_UNCERTAINTY;
- C6 PASS;
- C7 PASS;
- C8 READY_WITH_DOCUMENTED_CONDITIONS;
- C9 PASS;
- C10 PASS_WITH_DOCUMENTED_LIMITATIONS;
- C11 PASS_WITH_PREPARED_NAZARI_MATERIALIZATION;
- C12 PASS_WITH_DOCUMENTED_LIMITATION.

## 13. Próxima etapa

> **Executar o gate pré-persistência consolidado do OVR-01.**

C2 deve ser tratado explicitamente no gate; não pode ser silenciosamente ignorado.

**Resultado:** C10 fechado com ROBIS preparatório AI-only; nenhuma entidade/appraisal real OVR-01 foi persistida.
