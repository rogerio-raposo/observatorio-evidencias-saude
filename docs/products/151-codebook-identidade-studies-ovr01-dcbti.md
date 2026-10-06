# 151 — Codebook de Identidade de Studies e Reports para OVR-01 dCBT-I

**Data:** 6 de outubro de 2026  
**Status:** preparatório de C5; não canônico  
**Dependências:** Documentos 149–150; CP62

## 1. Unidade de identidade

Para overlap, a unidade é o **primary Study/trial subjacente**, não o artigo, autor/ano, DOI isolado ou Report.

Uma Study pode possuir múltiplos Reports.

## 2. Evidência de identidade

Ordem preferencial:

1. trial registry ID;
2. DOI/PMID + mesma amostra/intervenção/comparador;
3. autores + N + recrutamento + intervenção + comparator + período;
4. título/ano somente como sinal inicial.

Autor/ano sozinho nunca basta para identidade final.

## 3. Confidence

- **high** — mesmo registry ou declaração explícita de secondary/follow-up analysis do mesmo trial;
- **medium** — amostra/setting/intervenção compatíveis, mas falta identificador decisivo;
- **low** — match depende principalmente de autor/ano/título aproximado.

## 4. Ano bibliográfico

Online-first e issue-year podem divergir.

Ano discordante não implica Study diferente. Registrar canonical year, alternate year label e rationale.

## 5. Clusters já identificados

### GoodNight Study

Registry: **ACTRN12611000121965**

Reports do mesmo trial:

- Christensen et al. 2016;
- Batterham et al. 2017;
- Batterham et al. 2024.

Regra: SAME_TRIAL_REGISTRY.

Confidence: **high**.

Os três Reports contam como **uma Study** para membership/overlap.

### Eigl 2023 versus Hinterberger 2024 — CORRIGIDO

A verificação em fonte primária demonstrou que são Studies distintos.

**Eigl 2023:** DOI 10.3390/clockssleep5040039; n=53; online CBT-I program; active psychoeducation/sleep-hygiene control.

**Hinterberger 2024:** DOI 10.1111/jsr.14136; n=57; smartphone app + heart-rate monitoring; randomização própria.

Regra: SPLIT_DISTINCT_RANDOMIZATIONS.

Confidence: **high**.

A hipótese preliminar de same Study fica **SUPERSEDED pelo Documento 153**.

## 6. Alias Lorenz

Labels observados:

- Lorenz 2018;
- Lorenz 2019.

Título associado ao mesmo candidato:

*Randomized controlled trial to test the efficacy of an unguided online intervention with automated feedback for the treatment of insomnia.*

Regra: candidate same Study até confirmação bibliográfica.

Confidence provisória: **medium**.

## 7. Mesmo autor não implica mesma Study

Ritterband 2009, Ritterband 2011 e Ritterband 2017 permanecem candidatos distintos até prova de identidade.

## 8. Secondary analyses

Quando um Report declara secondary analysis, follow-up, mediation ou outcome adicional de um trial identificado, ele deve apontar para a Study existente.

Não criar nova Study apenas porque o outcome, follow-up ou first author mudou.

## 9. Regras de merge/split

**Merge** quando registry/randomização/coorte forem comuns.

**Split** quando houver registries, randomizações, cohorts ou intervenções incompatíveis.

## 10. Source hierarchy

1. Report primário;
2. trial registry;
3. full text da Review;
4. supplementary;
5. PubMed/Crossref;
6. tabela/forest plot secundário.

Forest-plot label é discovery evidence, não identidade final.

## 11. Candidate key documental

Até existir OES Study entity, usar chave documental no formato **OVR01-PS-<slug>**.

Essas chaves não são OES IDs.

## 12. Regra de membership

Um Study conta no máximo uma vez por Review.

Dois Reports do mesmo Study dentro da mesma Review equivalem a uma única membership occurrence.

## 13. Regra para CCA

Não calcular CCA enquanto:

- identities não estiverem reconciliadas;
- multiple Reports não estiverem colapsados;
- completeness não estiver classificada.

## 14. Estado de C5

> **C5 = IN_PROGRESS**

Regras de identidade fechadas; reconciliação completa ainda não.

## 15. Próxima etapa

Aplicar o codebook às Reviews Hwang, Gao e Nazari e produzir matriz preliminar Review × canonical Study candidate.

A matriz deverá distinguir:

- confirmed same Study;
- probable same Study;
- unresolved;
- Review-only Study.

**Resultado:** codebook C5 definido; nenhuma membership persistida.
