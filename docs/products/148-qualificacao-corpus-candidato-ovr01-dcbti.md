# 148 — Qualificação de Corpus Candidato OVR-01: dCBT-I Totalmente Automatizada

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto futuro avaliado:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status da qualificação:** **SUITABLE_WITH_CONDITIONS**  
**Escopo:** avaliação pré-Investigation; nenhum OVR-01 foi criado  
**Dependências:** Documento 146; Caso Real N2 / Evidence Sheet dCBT-I

---

# 1. Finalidade

Avaliar se o corpus já materializado no Caso Real N2 sobre dCBT-I totalmente automatizada pode servir como base de um primeiro Overview developmental interno.

A avaliação é feita antes da criação de:

- Question OVR-01;
- Investigation OVR-01;
- Product OVR-01;
- ReviewItems do Overview;
- primary-study membership;
- overlap resolution.

---

# 2. Escopo candidato

Tema candidato:

> **eficácia da dCBT-I totalmente automatizada em adultos com insônia, com foco em gravidade da insônia no pós-tratamento.**

A formulação do futuro Overview não deve herdar automaticamente o PICO estreito da Evidence Sheet N2.

O corpus suporta melhor uma pergunta review-level mais ampla:

> **Como as systematic reviews recentes caracterizam o efeito da dCBT-I totalmente automatizada sobre a gravidade da insônia em adultos, considerando diferenças de comparador, overlap, currentness e risco de viés da Review?**

---

# 3. Review candidata 1 — Hwang et al. 2025

OES:

- Study: `OES-ST-2026-000411`;
- StudyVersion: `81000000-0000-0000-0000-000000000101`;
- study_type: `systematic_review`;
- design: `systematic_review_meta_analysis`;
- Report: `OES-RP-2026-000411`;
- ReportVersion: `81000000-0000-0000-0000-000000000201`.

Publicação:

> Hwang JW, Lee GE, Woo JH, Kim SM, Kwon JY. *Systematic review and meta-analysis on fully automated digital cognitive behavioral therapy for insomnia*. npj Digital Medicine. 2025;8:157.

Identificadores:

- PMID 40075149;
- PMCID PMC11903857;
- DOI 10.1038/s41746-025-01514-4;
- PROSPERO CRD42024526617.

Método verificado:

- systematic review + meta-analysis;
- Cochrane Handbook;
- PRISMA;
- PubMed;
- CENTRAL;
- Embase;
- PsycINFO;
- busca até 31/03/2024;
- RCTs;
- 29 estudos;
- 9475 participantes;
- estudo-selection e extraction em duplicata;
- RoB 2.

Resultado relevante já materializado no OES:

- ResultVersion `81000000-0000-0000-0000-000000000301`;
- outcome = insomnia severity;
- post-treatment;
- subgroup comparador = online education about sleep;
- SMD = -0.93;
- IC95% -1.07 a -0.79;
- I² = 68%;
- k = 10.

Synthesis OES:

- `81000000-0000-0000-0000-000000000501`;
- `synthesis_origin=adopted_external`;
- não recalculada pelo OES.

ROBIS OES:

- existe;
- draft AI-assisted;
- overall judgement = unclear;
- não human verified.

---

# 4. Review candidata 2 — Gao et al. 2026

OES:

- Study: `OES-ST-2026-000412`;
- StudyVersion: `81000000-0000-0000-0000-000000000102`;
- study_type: `systematic_review`;
- design: `systematic_review_meta_analysis`;
- Report: `OES-RP-2026-000412`;
- ReportVersion: `81000000-0000-0000-0000-000000000202`.

Publicação:

> Gao K, Zhao Y, Zhang X, Su K, Jia J, Xu Y. *Efficacy of fully automated digital cognitive behavioral therapy for insomnia in adults: a systematic review and meta-analysis*. Sleep and Breathing. 2026;30:177.

Identificadores:

- PMID 42240717;
- DOI 10.1007/s11325-026-03723-x.

Método verificável:

- systematic review;
- random-effects meta-analysis;
- RCTs;
- general adult populations;
- 15 trials;
- N = 3507;
- subgroup analyses;
- meta-regression por plataforma e ano de publicação.

Resultado relevante já materializado no OES:

- ResultVersion `81000000-0000-0000-0000-000000000302`;
- outcome = insomnia severity;
- post-treatment;
- SMD = -0.82;
- 15 trials;
- comparadores agrupados/múltiplos.

Synthesis OES:

- `81000000-0000-0000-0000-000000000502`;
- `synthesis_origin=corroborative_external`;
- não recalculada pelo OES.

Source location atual:

> abstract results.

ROBIS específico da Review Gao:

> **ainda não materializado.**

Last search date:

> **ainda não extraído/persistido no OES.**

---

# 5. Requisito 1 — pelo menos duas systematic reviews

Resultado:

> **PASS**

Diferentemente do candidato N3-01, ambas as unidades:

- são systematic reviews;
- estão materializadas como Study/StudyVersion;
- possuem Reports vinculados.

Nenhuma reclassificação ontológica é necessária.

---

# 6. Reports/full text

## Hwang

- full text open access;
- PMCID disponível;
- tabela de 29 estudos disponível;
- supplementary information disponível.

Estado:

> **PASS**

## Gao

No OES:

- Report está marcado `full_text_status=available`;
- publisher declara que os dados analisados estão no artigo/supplementary information.

Entretanto:

- a página pública disponível no momento é preview de conteúdo sob assinatura;
- study list completa ainda não foi reconciliada no OES.

Estado:

> **PASS WITH CONDITION**

Condição:

> garantir acesso ao conteúdo necessário para reconstrução de membership antes de persistir o Overview.

---

# 7. Comparabilidade

Intervenção:

> fully automated dCBT-I

População:

> adultos com insônia / general adult populations

Outcome compartilhado:

> insomnia severity

Timepoint:

> post-treatment

Portanto existe um núcleo comparável.

Diferença relevante:

## Hwang

A estimativa materializada no OES é comparator-specific:

> online education about sleep.

## Gao

A estimativa materializada é global:

> multiple control types.

Consequência:

> **as duas magnitudes não devem ser tratadas como estimativas intercambiáveis do mesmo estimando.**

Para um Overview developmental:

- Hwang pode permanecer como estimate comparator-specific;
- Gao pode permanecer como estimate global/corroborativo;
- ambos podem ser apresentados separadamente;
- nenhuma re-meta-analysis deve ser criada;
- concordance pode ser avaliada apenas quanto ao que for verdadeiramente comparável.

Estado:

> **PASS WITH CONDITION**

---

# 8. Primary-study membership

Hwang:

- lista de 29 estudos publicada;
- membership recuperável.

Gao:

- 15 trials;
- membership não materializada;
- article/supplementary devem ser reconciliados.

No OES atual:

> não existe ainda `overview.primary_study_membership` para nenhuma das duas Reviews.

Portanto:

> overlap e CCA não podem ser calculados antes dessa reconstrução.

Estado:

> **PASS WITH MANDATORY PRE-PERSISTENCE CONDITION**

Condição:

1. reconstruir study list de Hwang;
2. reconstruir study list de Gao;
3. reconciliar aliases/Study identities;
4. identificar interseção;
5. documentar confiança de identidade;
6. só então calcular CCA/pairwise pela função canônica.

---

# 9. Last search date/currentness

Hwang:

> 31/03/2024.

Gao:

> ainda não extraído no corpus OES atual.

A data de publicação de Gao:

> não substitui last search date.

Estado:

> **PARTIAL**

Condição:

> extrair last-search date de Gao antes de persistir `overview.review_item`.

---

# 10. Review-level Result/Synthesis

Hwang:

- ResultVersion 301 = presente;
- SynthesisVersion 501 = presente;
- ResultSource = Figure 4 / subgroup online education about sleep.

Gao:

- ResultVersion 302 = presente;
- SynthesisVersion 502 = presente;
- ResultSource = Abstract results.

Estado:

> **PASS**

Regra:

> Syntheses 501/502 podem ser referenciadas como evidência review-level já existente, preservando sua origem externa e sem recalculá-las.

---

# 11. Source provenance

ResultSource já existe para ambas:

## Hwang

- source ReportVersion 201;
- Figure 4 / subgroup online education about sleep;
- SMD, CI, I², k registrados.

## Gao

- source ReportVersion 202;
- abstract results;
- SMD e trial count registrados.

Estado:

> **PASS**, com necessidade de ampliar source location de Gao se o full text for utilizado na preparação do Overview.

---

# 12. ROBIS

Hwang:

- ROBIS AI-assisted draft existente;
- overall = unclear;
- não human verified.

Gao:

- nenhum ROBIS persistido.

Developmental A0/A1:

> isso é admissível como limitação/blocker.

Formal A3:

> não seria admissível.

Estado:

> **PARTIAL**

Condição:

> produzir ROBIS de Gao antes de qualquer tentativa de maturidade superior; não fabricar human verification.

---

# 13. Certainty

A Evidence Sheet N2 possui CertaintyAssessment OES moderada.

Essa certainty:

- está ligada à síntese OES atualizada 503;
- não é certainty reportada por Hwang ou Gao;
- não deve ser reutilizada automaticamente como certainty review-level no Overview.

Para OVR-01:

> certainty de cada Review deve ser extraída somente se a própria Review a reportar de forma rastreável.

Se ausente:

> permanecer ausente.

Estado:

> **CONDITION / não blocker da rota developmental.**

---

# 14. Update identity

Hwang e Gao:

- autores distintos;
- publicações distintas;
- métodos distintos;
- amostras de trials distintas;
- Gao cita literatura anterior, incluindo Hwang;
- não há evidência de que Gao seja uma atualização formal da mesma Review entity.

Decisão inicial:

> **Reviews independentes, não versions/update Reports da mesma Review.**

Estado:

> **PASS**, sujeito à confirmação na preparação do protocolo.

---

# 15. Necessidade de supplemental primary-study synthesis

Para o primeiro Overview developmental:

> **não é necessária.**

A proposta é usar:

- estimates de Hwang;
- estimate de Gao;
- overlap/membership;
- currentness;
- ROBIS;
- concordance.

Não criar:

- novo pooling;
- synthesis com primary-study Results fora das Reviews;
- update meta-analysis OES.

Estado:

> **PASS**

---

# 16. Densidade secundária adicional

A busca de qualificação identificou pelo menos outra systematic review/meta-analysis recente de fully automated dCBT-I:

> Nazari A, Mirzakhani A, Garmaroudi G. *Effectiveness of Digital Cognitive Behavioral Therapy for Insomnia: A Meta-Analysis of Randomized Controlled Trials*. Iran J Psychiatry. 2025;20(4):523–544.

Características:

- systematic review/meta-analysis;
- PubMed, PsycINFO, Web of Science e Scopus;
- literatura até janeiro de 2025;
- 49 RCTs;
- 20.118 participantes;
- full text em PMC.

Essa terceira review:

> **não integra automaticamente o corpus qualificado neste documento.**

Ela demonstra, porém:

> **densidade secundária suficiente para o tema e potencial de expansão controlada do corpus.**

Sua inclusão deverá ser decidida no protocolo, não de forma oportunista.

---

# 17. Quadro de qualificação

| Critério | Estado |
|---|---|
| ≥2 systematic reviews elegíveis | **PASS** |
| Reports/full text identificáveis | PASS WITH CONDITION |
| Escopo relacionado/comparável | PASS WITH CONDITION |
| Last search dates | PARTIAL |
| Primary-study membership recuperável | PASS WITH MANDATORY CONDITION |
| Review-level Result/Synthesis | **PASS** |
| Source location/provenance | **PASS** |
| Review vs update distinguível | PASS |
| Sem supplemental primary synthesis imediata | **PASS** |
| Limitações documentáveis | **PASS** |

Resultado:

> **SUITABLE_WITH_CONDITIONS**

---

# 18. Condições obrigatórias antes de persistir OVR-01

Antes de criar ReviewItems/membership do Caso Real:

1. recuperar/confirmar full study list de Gao;
2. extrair last search date de Gao;
3. reconciliar Study identities entre Hwang e Gao;
4. construir inventário preliminar de membership;
5. calcular overlap apenas depois da identidade reconciliada;
6. definir explicitamente o cluster/comparison scope;
7. decidir se a terceira review Nazari entra ou fica fora, com rationale prospectivo;
8. produzir ROBIS de Gao em estado AI-only/unverified ou equivalente;
9. não reutilizar a certainty N2 como review-reported certainty;
10. não executar nova meta-analysis.

---

# 19. Autorização resultante

Conforme Documento 146, um candidato:

> suitable_with_conditions

pode seguir para preparação de protocolo developmental.

Portanto fica autorizado:

> **preparar o protocolo de OVR-01, sem ainda persistir ReviewItems/membership até o fechamento das condições 1–8.**

OVR-01 deverá iniciar:

- internal;
- under_review;
- publication_date=NULL;
- A0;
- publishable=false;
- sem controles humanos fictícios.

---

# 20. Relação com o Caso Real N2

A reutilização é autorizada apenas como reutilização de entidades científicas já existentes.

Não alterar:

- Evidence Sheet N2 publicada;
- Investigation original N2;
- Synthesis 503;
- CertaintyAssessment da Evidence Sheet;
- assurance da Evidence Sheet.

OVR-01 deverá ter:

- Question própria;
- Investigation própria;
- Product próprio.

As Review StudyVersions e Reports podem ser referenciados como corpus reutilizado.

---

# 21. Próxima etapa

> **Preparar o protocolo developmental de OVR-01 para dCBT-I, incluindo questão review-level, critérios de Review eligibility, política de overlap, currentness, ROBIS, OutcomeEvidence e plano de fechamento das condições pré-persistência.**

Ainda não:

> persistir ReviewItems/membership.

---

**Resultado final:** corpus dCBT-I = **SUITABLE_WITH_CONDITIONS para OVR-01 developmental**.
