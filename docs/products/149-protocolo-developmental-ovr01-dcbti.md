# 149 — Protocolo Developmental OVR-01: dCBT-I Totalmente Automatizada

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto futuro:** OES — Overview de Revisões  
**Caso candidato:** OVR-01 — dCBT-I totalmente automatizada  
**Data:** 6 de outubro de 2026  
**Status:** protocolo developmental pré-persistência  
**Maturidade autorizada:** A0 inicial; eventual A1 somente após verificação metodológica por IA  
**Publicação:** proibida nesta rota  
**Dependências:** Documentos 138–148; CP60

---

# 1. Finalidade

Definir prospectivamente o primeiro Overview developmental interno do OES usando o corpus dCBT-I qualificado no Documento 148.

Este protocolo:

- autoriza a preparação metodológica do OVR-01;
- não autoriza ainda a persistência de ReviewItems/membership;
- não altera a Evidence Sheet N2 existente;
- não converte o trabalho em Overview formal/publicável;
- não substitui as condições pré-persistência do Documento 148.

---

# 2. Estado epistemológico do produto

OVR-01 será inicialmente:

- `product_type=overview_of_reviews`;
- interno;
- `under_review`;
- `publication_date=NULL`;
- assurance **A0**;
- `publishable=false`;
- sem alegação de completude sistemática;
- sem controles humanos fictícios;
- sem A3;
- sem nova meta-analysis.

A rota é:

> **developmental interna, não formal.**

A infraestrutura formal do produto existe, mas os requisitos humanos e de cobertura para publicação não estão satisfeitos.

---

# 3. Pergunta review-level

Pergunta proposta:

> **Como systematic reviews recentes caracterizam o efeito da dCBT-I totalmente automatizada sobre a gravidade da insônia em adultos no pós-tratamento, considerando diferenças de comparador, overlap de estudos primários, currentness, ROBIS e certainty reportada?**

Essa pergunta é própria do Overview.

Ela não é idêntica à pergunta da Evidence Sheet N2.

---

# 4. Estrutura da pergunta

Estrutura:

> **PICO em nível de Review, com atributos metodológicos adicionais.**

## Population

- adultos com insônia ou sintomas clinicamente relevantes de insônia;
- populações gerais adultas;
- estudos exclusivamente pediátricos excluídos;
- populações altamente específicas poderão ser incluídas apenas se a review fornecer estrato compatível com a pergunta central.

## Intervention

- dCBT-I multicomponente;
- totalmente automatizada;
- unguided/sem suporte terapêutico humano ativo como componente necessário;
- web, aplicativo ou plataforma digital.

## Comparator

Comparadores elegíveis:

- digital sleep education;
- sleep hygiene education;
- waitlist;
- treatment as usual;
- attention/control digital;
- outros controles passivos/educacionais claramente identificados.

Comparadores serão:

> **preservados como dimensão analítica, não colapsados automaticamente.**

## Outcome principal

- gravidade da insônia;
- ISI ou outro instrumento validado de insomnia severity;
- primeiro pós-tratamento completo ou timepoint comparável declarado pela Review.

## Unidade científica

- systematic review/meta-analysis elegível;
- representada no OES como Study/StudyVersion.

---

# 5. Critérios de elegibilidade de Review

Incluir Review quando todos os requisitos abaixo forem satisfeitos:

1. `study_type=systematic_review` ou método inequivocamente compatível antes da materialização;
2. síntese quantitativa ou revisão sistemática com dados review-level relevantes;
3. população adulta;
4. fully automated/unguided dCBT-I identificável;
5. insomnia severity disponível;
6. RCTs como base principal da evidência de eficácia;
7. post-treatment estimate ou informação suficiente para OutcomeEvidence;
8. Study list recuperável ao menos para membership preliminar;
9. Report integral ou informação metodológica suficiente para rastreabilidade;
10. identidade independente da Review verificável.

---

# 6. Exclusões de Review

Excluir do corpus analítico principal:

- narrative review;
- scoping review;
- rapid review que não satisfaça a definição prospectiva de systematic review;
- umbrella/overview anterior que use Reviews como unidade, para evitar recursividade;
- review exclusivamente pediátrica;
- review de CBT-I guiada sem estrato plenamente automatizado;
- review apenas de prevenção/educação sem CBT-I multicomponente;
- review sem insomnia severity;
- review sem possibilidade de reconstruir a lista de estudos;
- network meta-analysis excessivamente ampla quando o estrato fully automated não puder ser isolado;
- review de intervenção digital ampla que não permita separar dCBT-I.

Reviews metodologicamente relevantes, mas fora do corpus analítico, poderão ser:

> `contextual`

somente se houver motivo explícito.

---

# 7. Corpus conhecido no início do protocolo

## Review A — Hwang et al. 2025

OES StudyVersion:

`81000000-0000-0000-0000-000000000101`

Estado preliminar:

> **elegível.**

## Review B — Gao et al. 2026

OES StudyVersion:

`81000000-0000-0000-0000-000000000102`

Estado preliminar:

> **elegível com condições de extração pendentes.**

## Review C candidata — Nazari et al. 2025

Identificada durante a qualificação do corpus:

> *Effectiveness of Digital Cognitive Behavioral Therapy for Insomnia: A Meta-Analysis of Randomized Controlled Trials.*

Estado:

> **candidata; ainda não incluída.**

Ela deverá passar pelos mesmos critérios de elegibilidade antes de qualquer persistência do OVR-01.

---

# 8. Regra anti-cherry-picking

A existência prévia de Hwang e Gao no N2:

> **não autoriza limitar o Overview a essas duas Reviews por conveniência.**

Antes da persistência do OVR-01 deverá ocorrer uma etapa de discovery/qualificação direcionada de Reviews secundárias.

Objetivo:

- identificar Reviews claramente elegíveis já conhecidas ou facilmente recuperáveis;
- evitar exclusão consciente de Review elegível recente;
- sem reivindicar busca sistemática formal/exaustiva.

---

# 9. Política de discovery pré-persistência

A etapa pré-persistência deverá usar:

1. PubMed/MEDLINE;
2. referências/citation chaining das Reviews centrais;
3. verificação de identificadores já conhecidos no OES;
4. full text/supplementary quando necessário à membership.

Consulta temática mínima:

- insomnia;
- fully automated digital CBT-I / internet CBT-I / digital CBT for insomnia;
- systematic review / meta-analysis.

O objetivo não é cumprir N4.

Coverage claim:

> **structured_non_exhaustive candidate-review discovery.**

Não será declarado:

- systematic completeness;
- exhaustive review search;
- formal PRIOR-compliant Overview.

---

# 10. Data de corte

Data de corte inicial proposta:

> **2026-10-06**

Ela se aplica à preparação do corpus developmental.

Qualquer Review publicada depois do cutoff:

> não entra silenciosamente no OVR-01 v1.

---

# 11. Currentness policy

A currentness da Review será determinada pela **data da última busca**, não pela data de publicação.

Classificação operacional developmental:

- `current` — última busca até 24 meses antes do cutoff;
- `possibly_outdated` — >24 até 36 meses;
- `outdated` — >36 meses;
- `unclear` — data de busca não recuperada.

Aplicação preliminar:

## Hwang

Última busca:

> 31/03/2024.

Em 06/10/2026:

> **possibly_outdated**.

## Gao

Última busca:

> ainda não extraída.

Estado inicial permitido somente durante preparação:

> **unclear**.

Antes da persistência de ReviewItem:

> a data de busca de Gao deverá ser recuperada.

---

# 12. Review identity / update policy

Uma Review será uma unidade científica independente quando:

- autores/método/protocolo/corpus indicarem revisão distinta;
- não houver relação de update formal da mesma revisão.

Multiple Reports:

> não criam múltiplas Reviews.

Update/correction/retraction:

- usar ReportRelation quando identificável;
- selecionar StudyVersion concreta;
- nunca inferir update apenas por ano/título.

Hwang e Gao são tratadas preliminarmente como:

> **Reviews independentes.**

---

# 13. Primary-study membership policy

Membership é central ao Overview.

Para cada Review:

- recuperar lista completa dos primary Studies;
- reconciliar cada Study por DOI/PMID/registro/autores/ano/título;
- reaproveitar Study entities OES existentes quando a identidade for confirmada;
- criar novas Study entities somente quando necessário e posteriormente autorizado;
- registrar source Report e source location;
- registrar identity confidence.

Durante preparação:

- AI-assisted identity matching é permitido;
- nenhuma linha será marcada human_verified;
- ambiguidades permanecem medium/low ou unresolved.

---

# 14. Regra para CCA/pairwise

Não calcular CCA antes de:

- Study lists de todas as Reviews analíticas estarem reconstruídas;
- aliases resolvidos;
- memberships suficientemente completas.

Se qualquer Review analítica tiver membership:

- partial;
- unknown;

então:

> **CCA deverá permanecer NULL / não calculável.**

Nenhum valor aproximado será produzido.

---

# 15. Cluster policy

Cluster principal proposto:

> `fully_automated_dcbti_insomnia_severity_adults`

Escopo:

- população adulta;
- fully automated dCBT-I;
- insomnia severity;
- post-treatment.

Reviews poderão pertencer ao mesmo cluster por tema/evidência compartilhada.

Entretanto:

> **cluster comum não torna estimates automaticamente comparáveis.**

---

# 16. Comparator policy

OutcomeEvidence deverá preservar o comparador exato de cada estimate.

Famílias preliminares:

1. `digital_sleep_education_or_hygiene`;
2. `waitlist_or_no_treatment`;
3. `treatment_as_usual`;
4. `attention_or_active_control`;
5. `mixed_multiple_controls`;
6. `other_explicit_control`.

Não colapsar diferentes comparadores em uma única interpretação causal sem justificativa.

---

# 17. Overlap strategy

Estratégia inicial developmental:

> **include_all_separate_estimates**

Razões:

- evita dupla contagem quantitativa porque não haverá novo pooling;
- mantém Hwang/Gao/Nazari visíveis separadamente;
- permite descrever overlap estrutural;
- não força priorização antes de membership/currentness/ROBIS estarem completos.

Não usar:

> `include_all_deduplicate_outcomes`

porque permanece não suportado formalmente no v0.1.

`prioritize_review` poderá ser adotado futuramente somente se houver critério prospectivo claro e necessidade de estimate principal.

---

# 18. Regra de double counting

O OVR-01:

- não somará participantes entre Reviews;
- não somará números de RCTs como se independentes;
- não fará nova meta-analysis;
- não combinará Hwang + Gao + Nazari estatisticamente.

Contagens apresentadas serão:

- por Review;
- unique primary Studies;
- membership occurrences;
- overlap metrics derivadas.

---

# 19. OutcomeEvidence policy

Hwang:

- reutilizar ResultVersion `81000000-0000-0000-0000-000000000301`;
- reutilizar SynthesisVersion `81000000-0000-0000-0000-000000000501`;
- comparison = online education about sleep;
- source = Figure 4/subgroup;
- analysis role inicialmente `supporting_estimate` ou `primary_estimate` somente conforme decisão final do protocolo de apresentação.

Gao:

- reutilizar ResultVersion `81000000-0000-0000-0000-000000000302`;
- reutilizar SynthesisVersion `81000000-0000-0000-0000-000000000502`;
- comparison = multiple control types;
- fonte atual = abstract;
- não transformar em estimate comparator-specific.

Nazari:

- somente após elegibilidade e extração;
- não criar estimate sem source location rastreável.

---

# 20. Regra sobre Synthesis 503

SynthesisVersion:

`81000000-0000-0000-0000-000000000503`

é:

> **narrative update OES da Evidence Sheet N2.**

Ela não representa uma Review.

Portanto:

> **não será usada como Review-level OutcomeEvidence do OVR-01.**

Os RCTs do update também não serão introduzidos como supplemental primary-study synthesis no Overview v0.1.

---

# 21. ROBIS policy

Cada Review analítica deverá ter ROBIS próprio.

## Hwang

Existe RiskAssessmentVersion:

`81000000-0000-0000-0000-000000000401`

Permitido:

- reutilizar como draft AI-assisted;
- preservar `unverified/AI-only` semanticamente.

Não permitido:

- transformar em human_verified;
- tratá-lo como avaliação formal independente.

## Gao

Deverá ser produzido ROBIS draft antes da persistência final do corpus do Overview.

## Nazari

Se incluída:

> ROBIS draft também será necessário.

---

# 22. Certainty policy

O Overview não terá certainty global.

Para cada OutcomeEvidence:

- usar certainty somente quando reportada ou materializada legitimamente para aquela Review;
- manter ausência como ausência;
- não inferir certainty a partir de ROBIS;
- não copiar certainty da Evidence Sheet N2.

CertaintyAssessment N2 existente:

`81000000-0000-0000-0000-000000000601`

não será reutilizada como certainty de Hwang/Gao/Nazari.

---

# 23. Concordance policy

Concordância será avaliada somente quando:

- outcome;
- população;
- timepoint;
- comparator/estimand

forem suficientemente comparáveis.

Estados permitidos:

- concordant;
- directionally_discordant;
- magnitude_discordant;
- certainty_discordant;
- not_comparable.

Para Hwang × Gao:

> a direção pode ser comparável em nível amplo, mas magnitude não será comparada como mesmo estimando enquanto os comparadores diferirem.

Se essa condição não fechar:

> usar `not_comparable` ou avaliação limitada explicitamente.

---

# 24. Reanalysis policy

OVR-01 v1:

> **não executará nova reanálise quantitativa.**

Proibido:

- novo pooled SMD;
- meta-meta-analysis;
- weighted average de Reviews;
- de-duplicação outcome-level calculada ad hoc.

Somente estimates publicados/adotados serão apresentados separadamente.

---

# 25. Assurance

Estado inicial:

> **A0.**

Depois da persistência e testes, poderá existir:

> **A1**

somente após verificação metodológica real por IA.

Não criar automaticamente:

- owner approval;
- human expert review;
- A2;
- A3.

---

# 26. Publication state

OVR-01 v1:

- `status=under_review`;
- `publication_date=NULL`;
- interno;
- não publicável.

Publication issues esperadas são parte do produto developmental e não falha do desenho.

---

# 27. Relação com a Evidence Sheet N2

Reutilização permitida:

- Hwang StudyVersion/Report;
- Gao StudyVersion/Report;
- Hwang Result/Synthesis;
- Gao Result/Synthesis;
- Hwang draft ROBIS.

Não modificar:

- Product N2;
- Investigation N2;
- current ProductVersion N2;
- Synthesis 503;
- CertaintyAssessment N2;
- assurance/currency do produto N2.

OVR-01 deverá ter:

- Question própria;
- Investigation própria;
- Product próprio.

---

# 28. Terceira Review — política prospectiva

Nazari et al. 2025 deverá ser:

> **screened antes da persistência do OVR-01.**

Se cumprir integralmente os critérios:

> incluir como Review analítica, salvo razão metodológica pré-especificada de exclusão.

Não excluir somente porque:

- aumenta trabalho de membership;
- altera CCA;
- não estava na Evidence Sheet original.

Se não cumprir:

> registrar motivo explícito.

---

# 29. Condições pré-persistência obrigatórias

Antes de criar ReviewItems/membership reais:

## C1 — Gao study list

Recuperar a lista completa de RCTs incluídos por Gao.

## C2 — Gao last-search date

Extrair a última data de busca.

## C3 — Nazari screening

Aplicar os critérios deste protocolo.

## C4 — Review inventory

Fechar inventário das Reviews analíticas/contextuais.

## C5 — Study identity reconciliation

Reconciliar aliases entre as study lists.

## C6 — Membership matrix

Construir matriz Review × primary Study.

## C7 — Membership completeness

Classificar cada Review como complete/partial/unknown.

## C8 — Overlap readiness

Somente calcular CCA se C7 permitir.

## C9 — Comparator stratification

Mapear cada OutcomeEvidence à família de comparador correta.

## C10 — Gao ROBIS

Produzir draft AI-only.

## C11 — Source provenance

Confirmar ResultSource/provenance para cada OutcomeEvidence usado.

## C12 — Certainty provenance

Registrar apenas certainty realmente review-reported/materializada.

---

# 30. Gate pré-persistência

ReviewItems/membership poderão ser persistidos apenas se:

- C1–C6 = concluídas;
- C7 = explicitamente classificada;
- C9 = concluída;
- C10 = concluída ou documentadamente bloqueada com rationale;
- C11 = concluída;
- Nazari = incluída/excluída com decisão rastreável.

CCA não precisa estar calculável para o developmental OVR-01.

Se membership permanecer parcial:

> OVR-01 poderá prosseguir apenas A0/A1 interno com CCA null e disclosure explícito.

---

# 31. Saídas da próxima etapa

Antes do SQL real, produzir:

1. Documento 150 — inventário de Reviews e screening do corpus;
2. Documento 151 — codebook/membership identity rules;
3. Documento 152 — matriz preliminar Review × primary Study / overlap readiness;
4. Documento 153 — appraisal/currentness/OutcomeEvidence readiness.

A numeração poderá ser ajustada se outra necessidade metodológica surgir.

---

# 32. Critério de autorização do Caso Real

Somente após o gate do item 30:

> **persistir Question/Investigation/Product e estruturas `overview` do OVR-01.**

Até lá:

> **nenhuma entidade OVR-01 real deve ser criada.**

---

# 33. Próxima etapa

> **Fechar C1–C4: recuperar study list e last-search date de Gao, aplicar eligibility à Review Nazari e produzir o inventário definitivo de Reviews do corpus OVR-01.**

---

**Resultado:** protocolo developmental OVR-01 dCBT-I definido; persistência real permanece bloqueada pelas condições pré-persistência.
