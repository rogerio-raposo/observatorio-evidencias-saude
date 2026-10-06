# 147 — Qualificação de Corpus Candidato OVR-01: Subconjunto Secundário do N3-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto futuro avaliado:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status da qualificação:** **UNSUITABLE**  
**Escopo:** avaliação pré-Investigation; nenhum OVR-01 foi criado  
**Dependências:** Documento 146; Caso Real N3-01

---

# 1. Finalidade

Avaliar se o subconjunto de evidência secundária já recuperado no Caso Real N3-01 pode servir como corpus inicial de um Overview developmental interno sem executar nova busca e sem criar ainda:

- Question;
- Investigation;
- Product;
- ReviewItem;
- membership;
- ROBIS;
- assurance.

A decisão permitida é:

- suitable;
- suitable_with_conditions;
- unsuitable.

---

# 2. Regra de qualificação

O Documento 146 exige, antes da criação de OVR-01, que o corpus candidato demonstre minimamente:

1. pelo menos 2 systematic reviews elegíveis;
2. Reports integrais ou dados suficientes para identificação;
3. escopo suficientemente relacionado para cluster defensável;
4. last search date extraível;
5. lista de primary Studies recuperável ao menos parcialmente;
6. review-level Result/Synthesis relevante;
7. source location rastreável;
8. distinção entre Reviews independentes e updates;
9. ausência de necessidade imediata de supplemental primary-study synthesis;
10. limitações documentáveis.

Falha no requisito 1 impede autorização do corpus.

---

# 3. Inventário secundário relevante do N3-01

## 3.1 Report 206 — Bracken et al.

OES:

- Report: `OES-RP-2026-000706`;
- ReportVersion: `e1000000-0000-0000-0000-000000000206`;
- tipo persistido: `systematic_review`;
- PMID: 39966286;
- PMCID: PMC11835907;
- DOI: 10.1007/s10916-025-02157-4.

Título:

> *Artificial Intelligence (AI) - Powered Documentation Systems in Healthcare: A Systematic Review*

Características metodológicas verificadas:

- systematic review explícita;
- PRISMA;
- PubMed, Embase e Cochrane Library;
- busca registrada em 08/08/2024 para PubMed/Embase;
- dois revisores independentes para elegibilidade;
- 11 estudos incluídos;
- escopo inclui sistemas de documentação por IA, tanto ChatGPT quanto ambient AI.

Decisão de tipo para Overview:

> **elegível como systematic review em princípio.**

Limitação:

> no OES ela existe somente como Report, não como Review Study/StudyVersion.

---

## 3.2 Report 211 — Kanaparthy et al.

OES:

- Report: `OES-RP-2026-000711`;
- ReportVersion: `e1000000-0000-0000-0000-000000000211`;
- tipo persistido: `rapid_review`;
- PMID: 41071988;
- PMCID: PMC12513689;
- DOI: 10.2196/76743.

Título:

> *Real-World Evidence Synthesis of Digital Scribes Using Ambient Listening and Generative Artificial Intelligence for Clinician Documentation Workflows: Rapid Review*

Características metodológicas verificadas:

- rapid review explícita;
- Ovid MEDLINE;
- Embase;
- Web of Science Core Collection;
- Cochrane CENTRAL & Reviews;
- PubMed Central;
- período de cobertura 2014–2024;
- 1450 registros identificados;
- 6 estudos incluídos;
- busca desenvolvida com profissional de biblioteca;
- extração estruturada;
- cada artigo avaliado por pelo menos dois revisores, com terceiro disponível para adjudicação.

Entretanto, os próprios autores distinguem o método de uma systematic review abrangente.

Decisão de tipo para Overview v0.1:

> **não qualificar automaticamente como systematic review.**

O contrato físico atual de ReviewItem exige:

> `StudyVersion.study_type='systematic_review'`.

Reclassificar esta rapid review como systematic review apenas para fazê-la caber no contrato seria metodologicamente inadequado.

---

## 3.3 Report 210

Tipo:

> `scoping_review`

Título:

> *Ambient AI Scribes in the Emergency Department: A Scoping Review of Current Evidence*

Estado N3:

- setting inadequado ao núcleo ambulatorial;
- secondary review não usada como update unit.

Decisão:

> **não elegível para o corpus candidato atual.**

---

## 3.4 Report 220

Tipo:

> `narrative_review`

Título:

> *Transforming clinical documentation with ambient artificial intelligence (AI) scribes: a narrative review of technology, impact, and implementation*

Estado N3:

- narrative secondary review;
- excluída como update unit.

Decisão:

> **não elegível como systematic review.**

---

# 4. Requisito 1 — pelo menos duas systematic reviews

Resultado:

> **FAIL**

Existe somente uma review inequivocamente compatível com o tipo exigido:

- Report 206.

Report 211:

- é metodologicamente estruturado;
- é útil como evidência secundária;
- mas é declarado e persistido como rapid review;
- não deve ser convertido artificialmente em systematic review.

Reports 210/220:

- scoping/narrative;
- não suprem o requisito.

Consequência:

> o corpus não atinge o mínimo necessário para abrir um Overview de Revisões.

---

# 5. Materialização OES

No N3-01 estão materializados como Study/StudyVersion apenas os cinco estudos primários 101–105.

Os Reports 206 e 211:

- não possuem Review Study entity própria;
- não possuem StudyVersion de systematic review;
- não possuem `study_report_link` como Review Study;
- não possuem ReviewItem;
- não possuem primary-study membership;
- não possuem ResultVersion em nível da Review;
- não possuem SynthesisVersion em nível da Review;
- não possuem ROBIS da Review;
- não possuem CertaintyAssessment da Review;
- não possuem currentness persistida para Overview.

Portanto:

> usar 206/211 demandaria construção de novo estado científico, não mero reaproveitamento de entidades prontas.

---

# 6. Comparabilidade

## Report 206

Escopo:

- sistemas de documentação por IA em saúde;
- inclui ChatGPT e ambient AI;
- múltiplos tipos de documento e contextos.

## Report 211

Escopo:

- digital scribes com ambient listening/generative AI;
- real-world clinical implementation;
- workflow, eficiência, satisfação, qualidade e barreiras.

Interseção:

> existe sobreposição temática.

Equivalência:

> não demonstrada.

Estado:

> **PARTIAL / insuficiente para cluster analítico pré-autorizado.**

A diferença de escopo não é necessariamente impeditiva em um futuro Overview, mas precisaria de protocolo próprio e análise explícita da população/intervenção/outcomes.

---

# 7. Last search date/currentness

## Report 206

Data de busca documentada:

> 08/08/2024.

Isso é utilizável para currentness.

## Report 211

O corpus está descrito como:

> 2014–2024.

Na materialização N3 atual não existe:

- `last_search_date`;
- currentness status;
- currentness rationale.

Estado:

> **PARTIAL.**

---

# 8. Primary-study membership

Ambas as reviews informam quantidade de estudos incluídos:

- Report 206: 11;
- Report 211: 6.

Entretanto, no OES:

- as listas não estão reconciliadas como Study identities;
- não existe membership Review × primary Study;
- não foi determinada a interseção entre os 11 e os 6 estudos;
- não foi demonstrada correspondência completa com Studies 101–105.

Estado:

> **RECUPERÁVEL EM PRINCÍPIO, MAS NÃO MATERIALIZADO.**

Para um futuro corpus válido, essa reconstrução seria necessária.

---

# 9. Review-level Results/Syntheses

O N3-01 possui Syntheses 501–504.

Essas Syntheses:

> são sínteses OES do corpus primário N3.

Elas não representam:

- o Result de Bracken;
- o Result de Kanaparthy;
- uma Synthesis adotada de qualquer uma dessas Reviews.

Logo:

> **não reutilizar 501–504 como OutcomeEvidence das Reviews 206/211.**

Review-level Result/Synthesis de 206/211 precisaria ser extraído/materializado separadamente.

Estado:

> **FAIL no corpus atualmente persistido.**

---

# 10. ROBIS e certainty

Não existem para 206/211, no estado atual do OES:

- ROBIS;
- review-level certainty;
- verified currentness;
- human appraisal controls.

Para rota developmental interna isso não seria blocker absoluto depois de um corpus válido, mas permaneceria como limitação/publication blocker.

Estado:

> **AUSENTE.**

---

# 11. Update identity

Não há evidência de que 211 seja update de 206.

Os dois têm:

- autores distintos;
- escopos distintos;
- métodos distintos;
- bases distintas;
- datas distintas.

Portanto:

> tratá-los como duas Reviews independentes seria mais plausível que relação de update.

Entretanto, isso não resolve o problema de tipo metodológico do Report 211.

---

# 12. Quadro de qualificação

| Critério | Estado |
|---|---|
| ≥2 systematic reviews elegíveis | **FAIL** |
| Reports completos/identificáveis | PASS |
| Escopo relacionado/comparável | PARTIAL |
| Last search date | PARTIAL |
| Primary-study membership recuperável | PARTIAL |
| Review-level Result/Synthesis persistido | **FAIL** |
| Source location rastreável | PARTIAL |
| Update identity distinguível | PASS/sem update identificado |
| Sem supplemental primary synthesis imediata | provavelmente PASS, não demonstrado |
| Limitações documentáveis | PASS |

Resultado determinante:

> **UNSUITABLE**

---

# 13. Por que não usar “suitable_with_conditions”

O estado não é apenas um corpus adequado com lacunas operacionais.

Falta o requisito constitutivo:

> **duas systematic reviews elegíveis sob o contrato atual.**

Corrigir essa falha exigiria uma das seguintes ações:

1. localizar outra systematic review real;
2. alterar o escopo/tema;
3. alterar o contrato para admitir rapid reviews como ReviewItem.

A opção 3:

> **não deve ser feita apenas para acomodar este candidato.**

Portanto, a decisão correta é:

> **UNSUITABLE para OVR-01.**

---

# 14. Consequências

Não:

- criar Question OVR-01;
- criar Investigation OVR-01;
- criar Product OVR-01;
- materializar 211 como systematic review por conveniência;
- modificar N3-01;
- reabrir N3 ProductVersion;
- misturar Syntheses 501–504 com Review-level OutcomeEvidence.

O N3-01 permanece inalterado.

---

# 15. Valor do candidato apesar da rejeição

A avaliação foi útil porque demonstrou que:

- reutilização de corpus é possível somente quando a unidade científica requerida já existe ou pode ser legitimamente materializada;
- Report type não deve ser promovido artificialmente a Study type;
- evidência secundária contextual não equivale automaticamente a corpus de Overview;
- o OES bloqueia avanço quando a ontologia científica não fecha.

---

# 16. Próxima etapa

> **Selecionar um novo corpus candidato especificamente adequado a Overview de Revisões.**

Critério inicial de busca:

- tema suficientemente estreito;
- pelo menos duas systematic reviews claramente identificáveis;
- full text acessível;
- listas de estudos incluídos recuperáveis;
- outcomes comparáveis;
- last search dates disponíveis;
- preferencialmente reviews com ROBIS/GRADE ou dados suficientes para materialização.

A seleção do próximo candidato deverá ocorrer:

> **antes de criar OVR-01.**

---

**Resultado final:** subconjunto secundário do N3-01 = **UNSUITABLE para OVR-01**; nenhum Caso Real criado.
