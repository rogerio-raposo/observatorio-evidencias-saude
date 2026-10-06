# 150 — Inventário de Reviews e Fechamento C1–C4 do OVR-01 dCBT-I

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto futuro:** OES — Overview de Revisões  
**Caso candidato:** OVR-01 — dCBT-I totalmente automatizada  
**Data:** 6 de outubro de 2026  
**Status:** C1 PASS / C2 BLOCKED-NOT_VERIFIED / C3 PASS / C4 PASS  
**Dependências:** Documento 149; CP61  
**Regra:** nenhuma entidade real OVR-01 é criada neste documento.

---

# 1. Finalidade

Fechar as condições C1–C4 do protocolo developmental OVR-01:

- C1 — recuperar study list de Gao;
- C2 — extrair last-search date de Gao;
- C3 — aplicar eligibility prospectiva a Nazari;
- C4 — fechar inventário de Reviews do corpus.

Resultado agregado:

> **C1 = PASS**  
> **C2 = BLOCKED / NOT_VERIFIED**  
> **C3 = PASS**  
> **C4 = PASS**

Consequência:

> **persistência real do OVR-01 continua bloqueada enquanto C2 permanecer sem data de busca verificável.**

---

# 2. C1 — Study list de Gao

Review:

> Gao K, Zhao Y, Zhang X, Su K, Jia J, Xu Y. *Efficacy of fully automated digital cognitive behavioral therapy for insomnia in adults: a systematic review and meta-analysis*. Sleep and Breathing. 2026;30:177. DOI 10.1007/s11325-026-03723-x. PMID 42240717.

A publicação reporta:

- 15 trials;
- N = 3507;
- fully automated dCBT-I;
- general adult populations;
- insomnia severity como outcome principal relevante.

O forest plot oficial de insomnia severity apresenta 15 linhas de trial, permitindo reconstruir a lista nominal:

1. Ritterband et al. 2009;
2. Pillai et al. 2015;
3. Bernstein et al. 2017;
4. Horsch et al. 2017;
5. Ritterband et al. 2017;
6. Lopez et al. 2019;
7. Lorenz et al. 2019;
8. Behrendt et al. 2020;
9. Vedaa et al. 2020;
10. Eigl et al. 2023;
11. Zhang et al. 2023;
12. Hinterberger et al. 2024;
13. Chan et al. 2025;
14. Maurer et al. 2025;
15. Specht et al. 2025.

A lista é coerente com as referências bibliográficas da própria Review.

Estado:

> **C1 = PASS para inventário nominal.**

Limite:

- identificação bibliográfica nominal não equivale ainda a Study identity OES reconciliada;
- DOI/PMID/aliases serão tratados em C5;
- nenhuma `primary_study_membership` é persistida nesta etapa.

---

# 3. C2 — Last-search date de Gao

Fontes públicas verificadas:

- PubMed;
- Springer Nature article page;
- publisher preview;
- ResearchGate publisher preview.

As fontes públicas confirmam:

- systematic review/meta-analysis;
- 15 trials;
- data de recebimento do manuscrito em 19/03/2026;
- publicação em 04/06/2026;
- dados incluídos no artigo/supplementary information.

Entretanto:

> **a data exata da última busca bibliográfica não está projetada nas fontes públicas acessíveis consultadas.**

Não é metodologicamente aceitável inferir last-search date a partir de:

- data do trial mais recente;
- data de recebimento;
- data de publicação;
- ano das referências.

Portanto:

> **C2 = BLOCKED / NOT_VERIFIED.**

Currentness provisório de Gao:

> `unclear`

até recuperação da data real.

Caminhos válidos para fechamento:

1. acesso ao texto integral/supplementary method do publisher;
2. cópia legitimamente obtida pelos autores/instituição;
3. fonte bibliográfica secundária confiável que transcreva explicitamente a data da busca.

Não preencher data por estimativa.

---

# 4. C3 — Screening prospectivo de Nazari 2025

Review:

> Nazari A, Mirzakhani A, Garmaroudi G, Amani M. *Effectiveness of Digital Cognitive Behavioral Therapy for Insomnia: A Meta-Analysis of Randomized Controlled Trials*. Iran J Psychiatry. 2025;20(4):523–544. DOI 10.18502/ijps.v20i4.19689. PMID 41798736. PMCID PMC12965280.

## 4.1 Study type

- systematic review;
- meta-analysis;
- PRISMA;
- PROSPERO CRD42023455678.

Resultado:

> PASS.

## 4.2 Population

- adultos;
- insomnia diagnosticada por critérios/escalas validadas.

Resultado:

> PASS.

## 4.3 Intervention

- fully automated dCBT-I;
- plataformas digitais;
- sem necessidade de terapeuta como componente da intervenção-alvo.

Resultado:

> PASS.

## 4.4 Comparator

- waitlist;
- treatment as usual;
- placebo/outros controles elegíveis.

Resultado:

> PASS.

## 4.5 Outcome

- insomnia severity;
- instrumentos validados, incluindo ISI;
- estimate quantitativo review-level.

Resultado:

> PASS.

## 4.6 Design primário

- RCTs.

Resultado:

> PASS.

## 4.7 Search/currentness

Busca:

- PubMed;
- PsycINFO;
- Web of Science;
- Scopus;
- Google Scholar e reference screening suplementar.

Cobertura temporal:

> inception até janeiro de 2025.

Resultado:

> PASS.

## 4.8 Study list

- 49 RCTs;
- Table 1 publicada em full text PMC;
- membership potencialmente reconstruível.

Resultado:

> PASS.

## 4.9 Decisão

> **Nazari 2025 = ELIGIBLE ANALYTIC REVIEW para o corpus developmental OVR-01.**

Não é incluída apenas por aumentar densidade do corpus; ela satisfaz critérios prospectivos definidos antes do screening.

C3:

> **PASS.**

---

# 5. Discovery anti-cherry-picking

A etapa structured_non_exhaustive também identificou Reviews recentes que não entram no núcleo analítico principal.

## 5.1 Zhong et al. 2026

Título:

> *Effectiveness of unguided digital cognitive behavioral therapy for insomnia on depressive symptoms: a systematic review and meta-analysis of randomized controlled trials.*

Características:

- systematic review/meta-analysis;
- unguided dCBT-I;
- 16 RCTs;
- insomnia outcome disponível;
- população especificamente com comorbid insomnia + depressive symptoms.

Decisão:

> **EXCLUDED_SCOPE para o corpus analítico principal.**

Rationale:

- população altamente específica;
- pergunta primária centrada em comorbidade depressiva;
- não representa a população geral-alvo do cluster principal.

Pode ser mantida:

> como contexto metodológico/secondary contextual review, sem ReviewItem analítico no OVR-01 v1.

## 5.2 Digital CBT-I in older adults — 2026

Review específica para:

- adultos ≥60 anos;
- dCBT-I;
- mix de guided/unguided com subgroup por guidance.

Decisão:

> **EXCLUDED_SCOPE do núcleo analítico v1.**

Rationale:

- população etária específica;
- corpus da Review não é exclusivamente fully automated;
- o OVR-01 v1 prioriza Reviews cuja unidade científica inteira se alinha ao fully automated dCBT-I em adultos.

## 5.3 Leite et al. 2025

Título:

> *Effects of Digital Cognitive Behavioral Therapy for Insomnia on Self-Reported Sleep Parameters: Systematic Review and Meta-Analysis.*

Características:

- 14 RCTs;
- outcomes = TST, SOL, SE, WASO, number of awakenings;
- não centra insomnia severity/ISI como outcome review-level do protocolo OVR-01.

Decisão:

> **EXCLUDED_OUTCOME.**

## 5.4 Zettor et al. 2025

Foco:

> atividade profissional/work outcomes.

Decisão:

> **EXCLUDED_OUTCOME/SCOPE.**

---

# 6. C4 — Inventário definitivo de Reviews do corpus v1

## 6.1 Reviews analíticas

### Review A — Hwang et al. 2025

Estado:

> INCLUDE — analytic

OES:

- StudyVersion `81000000-0000-0000-0000-000000000101`;
- ReportVersion `81000000-0000-0000-0000-000000000201`;
- ResultVersion `81000000-0000-0000-0000-000000000301`;
- SynthesisVersion `81000000-0000-0000-0000-000000000501`.

Last search:

> 31/03/2024.

## 6.2 Review B — Gao et al. 2026

Estado:

> INCLUDE — analytic, currentness unresolved

OES:

- StudyVersion `81000000-0000-0000-0000-000000000102`;
- ReportVersion `81000000-0000-0000-0000-000000000202`;
- ResultVersion `81000000-0000-0000-0000-000000000302`;
- SynthesisVersion `81000000-0000-0000-0000-000000000502`.

Last search:

> **unknown / C2 blocked.**

## 6.3 Review C — Nazari et al. 2025

Estado:

> INCLUDE — analytic; ainda não materializada no OES.

Identificadores:

- PMID 41798736;
- PMCID PMC12965280;
- DOI 10.18502/ijps.v20i4.19689;
- PROSPERO CRD42023455678.

Last search:

> janeiro de 2025.

Antes da persistência real do Overview, Nazari precisará de:

- Study/StudyVersion;
- Report/ReportVersion;
- StudyReportLink;
- Result/ResultVersion ou Synthesis adotada rastreável;
- ResultSource/provenance;
- ROBIS draft;
- study membership.

---

# 7. Reviews fora do núcleo analítico

| Review | Decisão | Motivo |
|---|---|---|
| Zhong 2026 | EXCLUDED_SCOPE / contextual | população comórbida insomnia + depressive symptoms |
| Older-adult dCBT-I 2026 | EXCLUDED_SCOPE | ≥60 anos; mix guided/unguided |
| Leite 2025 | EXCLUDED_OUTCOME | sleep diary parameters, não insomnia severity central |
| Zettor 2025 | EXCLUDED_OUTCOME/SCOPE | professional activity |

Essas exclusões:

> não implicam baixa qualidade metodológica.

Representam apenas desalinhamento com a pergunta review-level prospectiva do OVR-01 v1.

---

# 8. Estado C1–C4

| Condição | Resultado |
|---|---|
| C1 — Gao study list | **PASS** |
| C2 — Gao last-search date | **BLOCKED / NOT_VERIFIED** |
| C3 — Nazari screening | **PASS — ELIGIBLE** |
| C4 — inventário definitivo | **PASS** |

---

# 9. Consequência operacional

O inventário analítico v1 fica definido prospectivamente como:

1. Hwang 2025;
2. Gao 2026;
3. Nazari 2025.

Porém:

> **não está autorizado persistir OVR-01 enquanto C2 não for fechado.**

Também permanecem pendentes:

- C5–C12.

Não criar ainda:

- Question OVR-01;
- Investigation OVR-01;
- Product OVR-01;
- ReviewItems;
- membership;
- CCA.

---

# 10. Próxima etapa

Prosseguir em paralelo por duas frentes:

## Frente A — resolver C2

> obter last-search date verificável de Gao sem inferência.

## Frente B — C5–C6 preparatórios

> iniciar reconciliação de Study identities e matriz Review × primary Study para Hwang/Gao/Nazari, sem persistir membership.

Se C2 continuar indisponível:

> manter Gao currentness=`unclear` e o gate pré-persistência bloqueado, sem degradar a regra metodológica.

---

**Resultado final:** C1, C3 e C4 fechados; C2 permanece bloqueado por ausência de last-search date verificável; nenhum OVR-01 real criado.
