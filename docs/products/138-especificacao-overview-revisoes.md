# 138 — Especificação Científica e Funcional do Overview de Revisões

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** especificação científica e funcional inicial  
**Dependências OES:** Documentos 02, 22, 40 e arquitetura OES-P1  
**Base metodológica externa consultada:** Cochrane Handbook — Chapter V: Overviews of Reviews; JBI Manual for Evidence Synthesis — Umbrella Reviews; PRIOR Statement; literatura metodológica sobre primary-study overlap/CCA

---

# 1. Finalidade

Definir o contrato científico inicial do produto:

> **OES — Overview de Revisões**

O produto é destinado a situações em que múltiplas revisões sistemáticas respondem a perguntas relacionadas e o problema decisório exige:

- organizar essas revisões;
- avaliar sua confiabilidade;
- identificar sua atualidade;
- mapear a sobreposição de estudos primários;
- comparar seus resultados;
- compreender concordâncias e divergências;
- evitar dupla contagem;
- comunicar a evidência em nível de revisão sem reconstruir desnecessariamente uma nova revisão de estudos primários.

---

# 2. Definição operacional

Um Overview de Revisões OES usa métodos explícitos para:

1. localizar revisões sistemáticas elegíveis;
2. selecionar versões concretas dessas revisões;
3. avaliar risco de viés/qualidade metodológica;
4. extrair características e resultados relevantes;
5. mapear estudos primários compartilhados;
6. tratar sobreposição;
7. comparar/sintetizar resultados de revisões;
8. avaliar atualidade e confiança;
9. produzir conclusão própria do Overview.

A unidade principal de:

- busca;
- elegibilidade;
- inclusão;
- análise;

é:

> **a revisão sistemática.**

---

# 3. Relação com OES-P1

No OES-P1, uma revisão sistemática pode ser representada como:

> `Study(study_type=systematic_review)`

com:

- um ou mais Reports;
- Results;
- RiskAssessment;
- Synthesis quando aplicável;
- CertaintyAssessment quando aplicável;
- provenance.

Assim:

> **Overview não exige redefinir revisão sistemática como nova entidade científica.**

Entretanto, a arquitetura base não representa integralmente:

- membership review ↔ primary Study;
- overlap entre reviews;
- clusters de reviews sobrepostas;
- decisão de retenção/priorização;
- reconciliação de resultados conflitantes;
- prevenção explícita de double counting em nível do Overview.

Esses requisitos deverão ser resolvidos por camada especializada, se confirmados na revisão arquitetural seguinte.

---

# 4. Escopo metodológico v0.1

A primeira versão formal do produto será limitada a:

> **overviews de revisões sistemáticas quantitativas de intervenções em saúde.**

Motivo:

- é o domínio com guidance metodológico mais consolidado;
- Cochrane Chapter V fornece orientação específica;
- PRIOR foi desenvolvido para overviews de intervenções;
- OES já possui estruturas para Results quantitativos, ROBIS, Synthesis e GRADE.

Ficam fora do escopo formal v0.1:

- overviews diagnósticos;
- prognósticos;
- etiológicos;
- qualitativos;
- mixed-methods;
- scoping reviews de reviews;
- evidence maps de reviews.

Esses usos poderão ser adicionados após metodologia específica.

---

# 5. Nomenclatura

Nome oficial do produto:

> **OES — Overview de Revisões**

Termos como:

- umbrella review;
- review of reviews;
- overview of systematic reviews;
- meta-review;

podem aparecer como sinônimos metodológicos.

Entretanto:

> **o rótulo “umbrella review” não será usado como selo de qualidade.**

A validade dependerá do método efetivamente executado.

---

# 6. Product type

Identificador lógico candidato:

> `overview_of_reviews`

A decisão física final será confirmada no contrato de dados.

---

# 7. Pergunta central

Forma geral:

> **O que mostram as revisões sistemáticas existentes sobre [intervenções/comparações] para [população/condição] nos desfechos relevantes, e quão confiáveis, atuais, consistentes e independentes são essas sínteses?**

---

# 8. Estrutura da pergunta

Para v0.1:

> **PICO ampliado para review-level evidence**

Registrar:

- população;
- intervenção;
- comparador;
- outcomes críticos/importantes;
- setting;
- período;
- tipo de revisão elegível;
- critérios mínimos de systematicity;
- escopo das revisões.

A elegibilidade poderá exigir avaliação dos estudos primários contidos nas reviews quando a review tiver escopo mais amplo que o Overview.

---

# 9. Quando utilizar

Overview é apropriado quando:

- existem múltiplas revisões sistemáticas relevantes;
- as revisões cobrem intervenções, comparações ou outcomes relacionados;
- interessa uma visão decisória ampla;
- uma nova revisão completa de estudos primários seria redundante/desproporcional;
- é possível compreender e controlar overlap.

---

# 10. Quando não utilizar

Não utilizar Overview quando:

- existe apenas uma revisão sistemática relevante;
- as revisões disponíveis são tão inadequadas que não sustentam síntese confiável;
- a pergunta exige busca extensiva de estudos primários não cobertos pelas reviews;
- a maior parte dos dados precisará ser reextraída dos estudos primários;
- o objetivo real é atualizar uma revisão sistemática;
- o objetivo exige meta-análise nova de estudos primários;
- heterogeneidade entre review questions impede comparabilidade útil.

Nesses casos:

> rotear para N2, N3, N4 ou outro produto apropriado.

---

# 11. Protocolo

Overview formal exige protocolo prospectivo.

O protocolo deverá definir antes da execução:

- pergunta;
- eligibility;
- definição operacional de systematic review;
- bases/repositórios;
- estratégia de busca;
- processo de seleção;
- risk-of-bias tool;
- extração;
- overlap policy;
- review prioritization policy;
- conflict/concordance policy;
- synthesis strategy;
- certainty policy;
- atualização;
- handling de missing information;
- critérios de publication/assurance.

---

# 12. Definição de systematic review

A inclusão não poderá depender somente do rótulo usado pelos autores.

Cada candidato deverá satisfazer definição pré-especificada contendo, no mínimo, elementos suficientes para demonstrar método sistemático, como:

- pergunta/objetivo explícito;
- fontes pesquisadas;
- estratégia suficientemente reproduzível;
- critérios de inclusão/exclusão;
- processo de seleção;
- método de síntese;
- identificação dos estudos incluídos.

Risk-of-bias assessment da review poderá ser avaliado separadamente; sua ausência não transforma automaticamente o artigo em não-review, mas poderá afetar inclusão ou interpretação conforme protocolo.

---

# 13. Review identity

A unidade científica deve ser a review, não cada publicação.

Uma mesma systematic review poderá possuir:

- protocolo;
- publicação principal;
- atualização;
- correção;
- suplemento;
- companion report.

Esses Reports não deverão ser contados como reviews independentes.

O Overview deverá selecionar:

> **uma Review/StudyVersion concreta como unidade de análise.**

---

# 14. Atualizações de reviews

Quando uma review atualiza outra:

- preservar lineage;
- identificar search date de cada versão;
- evitar contar review original + atualização como evidência independente;
- utilizar política pré-especificada para escolher versão vigente.

A review mais recente não será automaticamente preferida se:

- escopo mudou;
- elegibilidade mudou;
- qualidade metodológica piorou;
- outcomes relevantes foram omitidos.

---

# 15. Supplemental primary studies

PRIOR reconhece que alguns overviews incluem estudos primários suplementares quando reviews estão desatualizadas ou incompletas.

Entretanto, para OES v0.1:

> **supplemental primary studies não farão parte do corpus analítico formal do Overview.**

Se a pergunta exigir busca sistemática complementar de estudos primários:

> **reavaliar o roteamento para N3/N4 ou futura metodologia híbrida.**

Estudos primários poderão ser consultados para:

- resolver identidade;
- mapear overlap;
- verificar dado específico;
- provenance;

sem se tornarem unidades independentes da síntese do Overview.

---

# 16. Busca

Overview formal exige:

> **busca abrangente, reproduzível e orientada à identificação de systematic reviews.**

Fontes podem incluir:

- MEDLINE/PubMed;
- Embase;
- Cochrane Database of Systematic Reviews;
- Epistemonikos;
- bases específicas do domínio;
- literatura cinzenta/repositórios, quando protocolarmente justificável.

O protocolo deverá definir:

- required source names/classes;
- filtros de systematic review;
- restrições;
- cutoff;
- search exports.

---

# 17. Regra de cobertura

Não será adotado um número universal rígido de bases para todos os temas.

O publication gate formal deverá validar:

- cobertura declarada no protocolo;
- execução de todas as fontes obrigatórias;
- justificativa de exceções;
- reprodutibilidade;
- search peer review quando exigida;
- ausência de substituição silenciosa por buscas oportunísticas.

---

# 18. Seleção

Etapas:

1. deduplicação;
2. title/abstract;
3. full text;
4. confirmação da definição de systematic review;
5. decisão de inclusão;
6. resolução de multiple reports/updates;
7. clusterização por overlap/escopo.

Overview formal deverá utilizar:

- revisores humanos independentes nas etapas críticas;
- consenso/adjudicação documentados.

IA pode apoiar, mas não substituir controles humanos obrigatórios.

---

# 19. Fluxo de seleção

O fluxo deverá distinguir:

- records;
- reports;
- candidate reviews;
- review units;
- multiple reports da mesma review;
- reviews excluídas;
- reviews incluídas;
- reviews priorizadas/excluídas devido a overlap policy.

Não chamar automaticamente de PRISMA/PRIOR flow sem satisfazer os requisitos correspondentes.

---

# 20. Avaliação da review

O Overview deverá avaliar cada review incluída.

## 20.1 Risk of bias

Padrão OES v0.1:

> **ROBIS**

Motivos:

- avalia diretamente risco de viés em systematic reviews;
- já possui representação no OES;
- é aplicável a reviews de intervenções e outros tipos de pergunta.

## 20.2 Methodological quality

AMSTAR 2 ou instrumento JBI poderá ser registrado como avaliação adicional quando protocolarmente necessário.

Regra:

> **methodological quality e risk of bias não serão fundidos num único score.**

Não converter AMSTAR 2 ou ROBIS em pontuação contínua universal do Overview.

---

# 21. Exclusão por qualidade

Default OES:

> **não excluir review apenas após observar um julgamento ROBIS desfavorável.**

Se o protocolo quiser usar quality threshold para inclusão:

- critério deve ser prospectivo;
- instrumento deve ser definido;
- threshold deve ser justificado;
- impacto da exclusão deverá ser discutido.

---

# 22. Risk of bias dos estudos primários

O Overview deverá, quando disponível:

- coletar os risk-of-bias judgments dos estudos primários tal como reportados nas reviews;
- registrar tool/framework;
- preservar discrepâncias entre reviews.

Não harmonizar automaticamente:

- RoB 1;
- RoB 2;
- ROBINS-I;
- ferramentas ad hoc;

num único score.

Reassessment de primary-study RoB não será rotina v0.1.

Se for necessário reassessment extenso:

> reavaliar roteamento/metodologia.

---

# 23. Review characteristics

Para cada review, extrair:

- Review ID;
- Reports;
- autores/ano;
- review question;
- populations;
- interventions;
- comparators;
- outcomes;
- search databases;
- search date;
- eligibility;
- study designs;
- number of primary studies;
- number of participants;
- synthesis methods;
- effect measures;
- heterogeneity;
- RoB tool/results;
- certainty method/results;
- protocol/registration;
- limitations;
- funding/conflicts quando relevantes.

---

# 24. Primary-study membership

Para analisar overlap:

> cada review deverá, quando possível, ser ligada aos primary Studies que contém.

A matriz Review × PrimaryStudy constitui:

> **verdade auditável de membership.**

Medidas de overlap serão derivadas dessa matriz.

---

# 25. Identidade dos estudos primários

O mesmo Study pode aparecer em reviews através de Reports diferentes.

Logo:

> overlap deve ser calculado em nível de Study, não de citation/report.

Quando Study identity for incerta:

- registrar resolução parcial/ambígua;
- não tratar Reports diferentes automaticamente como Studies diferentes.

---

# 26. Estado de completude do overlap

Cada review deverá possuir um estado:

- `complete`;
- `partial`;
- `unknown`.

CCA ou outras métricas agregadas só serão apresentadas como completas quando a matriz de membership tiver base suficiente.

---

# 27. Corrected Covered Area — CCA

CCA poderá ser calculada como métrica derivada de overlap.

Uso:

- descrever extensão da redundância;
- contextualizar independência do corpo de reviews;
- apoiar interpretação.

Não usar CCA como:

- risk-of-bias score;
- certainty score;
- critério automático de exclusão;
- peso estatístico.

---

# 28. Overlap pairwise

Além do CCA global, poderão ser derivados:

- número de Studies compartilhados por par de reviews;
- proporção de membership compartilhada;
- matriz/heatmap de overlap;
- overlap por comparação/outcome, quando necessário.

---

# 29. Política de double counting

O Overview deverá escolher prospectivamente uma estratégia.

## 29.1 Estratégia A — include all + de-duplicate outcome data

Pode incluir todas as reviews relevantes, mas:

- outcome data de um mesmo Study não pode ser contado múltiplas vezes como independente;
- requer rastreabilidade Study-level.

É a estratégia mais completa, porém mais complexa.

## 29.2 Estratégia B — prioritize review within overlap cluster

Selecionar uma review por cluster sobreposto usando critérios pré-especificados.

Possíveis critérios:

- melhor aderência à pergunta;
- menor risk of bias;
- maior atualidade;
- maior abrangência;
- melhor disponibilidade de dados.

Critérios deverão ser operacionalizados no protocolo.

## 29.3 Estratégia C — include all, present review-level estimates separately

Permitida quando:

- objetivo é descritivo/comparativo;
- nenhuma combinação quantitativa assume independência;
- overlap é explicitamente mostrado;
- limitações são declaradas.

---

# 30. Estratégia proibida

> **Nunca tratar estimativas de reviews altamente sobrepostas como observações independentes e simplesmente meta-analisá-las.**

Isso produz pseudo-replicação e dupla contagem.

---

# 31. Clusters de reviews

Reviews poderão ser agrupadas por:

- população;
- intervenção/comparação;
- outcome;
- período;
- escopo;
- primary-study membership.

Um overlap cluster deverá permitir registrar:

- reviews membros;
- grau de overlap;
- decisão de retenção;
- racional.

---

# 32. Priorização de review

Quando o protocolo optar por selecionar uma review entre várias sobrepostas, a decisão deverá ser auditável.

Não utilizar regra implícita:

> “usar a mais recente”.

O decision record deverá registrar critérios aplicados e resultado.

---

# 33. Results no Overview

O Overview deve extrair e apresentar:

- estimativas;
- intervalos;
- direction;
- heterogeneity;
- número de Studies/participants;
- outcome/timepoint;
- model/measure;
- certainty reportada.

Não utilizar apenas:

> conclusão textual dos autores da review.

---

# 34. Reanálise

Cochrane admite reanálise de outcome data em determinadas situações.

Para OES v0.1:

> **não haverá meta-análise de segunda ordem como comportamento padrão.**

O Overview poderá:

- padronizar apresentação;
- converter medidas quando metodologicamente seguro;
- juxtapose estimates;
- adotar criticamente uma síntese externa.

Nova reanálise quantitativa deverá exigir:

- método especializado explícito;
- dataset/code;
- controle estatístico;
- decisão arquitetural específica.

---

# 35. Informal indirect comparisons

O Overview não poderá inferir que:

> intervenção A é superior a B

apenas porque:

- Review A mostra efeito maior que Review B;
- as reviews estudaram populações/comparadores diferentes.

Tabelas comparativas deverão conter disclosure quando comparação indireta informal puder ser sugerida.

---

# 36. Concordância e divergência

Para review pairs/clusters relevantes, poderá ser classificada:

- `concordant`;
- `directionally_discordant`;
- `magnitude_discordant`;
- `certainty_discordant`;
- `not_comparable`.

A classificação deverá considerar:

- pergunta;
- included Studies;
- search date;
- RoB;
- synthesis method;
- effect measure;
- heterogeneity;
- certainty.

---

# 37. Conflitos entre reviews

Reviews conflitantes não serão resolvidas por simples votação.

O Overview deverá explicar possíveis fontes de divergência:

- eligibility;
- data de busca;
- inclusão de novos Studies;
- analysis model;
- outcome definition;
- population;
- intervention definition;
- handling de missing data;
- risk of bias;
- publication bias;
- overlap.

---

# 38. Certainty

O Overview poderá:

> **coletar GRADE existente nas reviews.**

Para cada julgamento coletado registrar:

- review source;
- outcome/comparison;
- framework;
- rating;
- rationale disponível;
- date/version.

Não criar:

> **certeza global do Overview.**

---

# 39. GRADE novo

Novo GRADE pelo OES somente quando:

- o corpus subjacente estiver de-duplicado;
- evidence base estiver suficientemente identificada;
- resultado analisado pelo Overview corresponder ao estimando;
- informação necessária estiver disponível;
- protocolo autorizar;
- controle humano/assurance exigido estiver presente.

Não inferir GRADE pela média dos julgamentos das reviews.

---

# 40. Missing results / publication bias

Quando as reviews avaliarem reporting/publication bias:

- coletar método e julgamento;
- apresentar por review/outcome.

Quando o Overview fizer avaliação própria de missing results:

- método deve ser pré-especificado;
- nível de inferência deve ser explícito.

Ausência de avaliação:

> **não avaliado**, nunca “baixo risco” por default.

---

# 41. Atualidade

Cada review deverá registrar:

- publication date;
- last search date;
- update status;
- relation com review anterior/atualização.

A atualidade científica é mais dependente de:

> **last search date**

do que da data de publicação isolada.

---

# 42. Estado de currency da review

Estado candidato:

- `current`;
- `possibly_outdated`;
- `outdated`;
- `unclear`.

A regra temporal específica deverá ser definida pelo protocolo/tema.

Não adotar threshold universal sem justificativa.

---

# 43. Coverage gaps

O Overview pode identificar:

- intervenções sem review;
- outcomes não cobertos;
- reviews desatualizadas;
- reviews de alto risco de viés;
- regiões/populações pouco representadas.

Esses gaps não são automaticamente:

- ausência de primary evidence;
- prioridade de pesquisa;
- recomendação de nova review.

---

# 44. Stakeholder engagement

Pode ser registrado quando pertinente.

Stakeholder input não substitui:

- busca;
- appraisal;
- overlap control;
- certainty;
- reviewer controls.

---

# 45. Applicability

A aplicabilidade poderá ser avaliada descritivamente.

Separar:

- applicability;
- certainty;
- review relevance;
- indirectness.

Não penalizar certeza automaticamente por ausência de estudos brasileiros.

---

# 46. Produto e nível de profundidade

Overview não recebe automaticamente N4.

Entretanto, um **Overview formal sistemático v0.1** exigirá rigor operacional próximo ao N4 em:

- busca;
- seleção;
- appraisal;
- extração;
- overlap;
- synthesis governance.

O `depth_level` deverá descrever a Investigation de suporte.

---

# 47. Assurance

## 47.1 Formal systematic Overview

Requer:

> **A3**

e controles humanos qualificados.

## 47.2 Internal developmental Overview

Pode existir em A0/A1 para:

- arquitetura;
- método;
- validação interna.

Não poderá ser apresentado como Overview formal concluído.

## 47.3 A2

A2 não será suficiente para publicação formal do Overview v0.1.

Motivo:

- dupla camada de evidência;
- risco de overlap/double counting;
- dependência de appraisal de reviews;
- potencial de comparações inválidas;
- necessidade de decisão metodológica especializada.

---

# 48. Controles humanos formais

Overview formal deverá exigir, conforme protocolo:

- search peer review qualificado;
- seleção independente;
- appraisal independente;
- data extraction independente;
- overlap/membership verification;
- resolution/adjudication;
- expert independent review;
- statistical review quando houver reanálise quantitativa.

IA não satisfaz esses papéis humanos.

---

# 49. Reporting

Template formal deverá alinhar-se ao PRIOR quando aplicável.

Não declarar:

> **PRIOR compliant**

sem validação item a item.

O produto deverá comunicar:

- protocolo;
- flow;
- reviews incluídas;
- appraisal;
- overlap;
- results;
- certainty;
- conflicts;
- limitations;
- funding/conflicts;
- update/cutoff;
- provenance.

---

# 50. Saída mínima

1. identidade;
2. pergunta;
3. objetivo;
4. método;
5. protocolo;
6. busca;
7. flow;
8. characteristics of included reviews;
9. risk of bias / methodological quality;
10. primary-study membership;
11. overlap;
12. review clusters;
13. outcome results;
14. concordância/divergência;
15. certainty;
16. currentness;
17. applicability;
18. limitations;
19. conclusão;
20. references;
21. audit/assurance.

---

# 51. Conclusão do Overview

A conclusão deverá ser construída pelo OES a partir de:

- estimates;
- review RoB;
- primary-study RoB reportado;
- overlap;
- certainty;
- currentness;
- consistency;
- relevance.

Não copiar simplesmente a conclusão de uma review escolhida.

---

# 52. Candidate architecture — reuse

Reutilizar:

- Question;
- Investigation;
- Search;
- SearchHit;
- ScreeningDecision;
- Study;
- StudyVersion;
- Report;
- StudyReportLink;
- Result;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- Product;
- Assurance;
- Artifact;
- Provenance.

---

# 53. Candidate architecture — specialized Overview layer

A revisão arquitetural deverá avaliar estruturas especializadas para:

1. `overview.review_item`;
2. `overview.primary_study_membership`;
3. `overview.review_cluster`;
4. `overview.cluster_membership`;
5. `overview.overlap_resolution`;
6. `overview.outcome_evidence`;
7. `overview.concordance_assessment`.

Nomes ainda não são contrato físico.

---

# 54. ReviewItem

Função candidata:

- vincular Review/StudyVersion ao Overview;
- registrar role;
- eligibility basis;
- inclusion status;
- currentness;
- review-level metadata.

Não duplicar Study/Report.

---

# 55. PrimaryStudyMembership

Função candidata:

> ReviewVersion ↔ primary Study

Campos candidatos:

- review item;
- Study/identifier;
- membership status;
- source location;
- identity confidence;
- outcome/comparison context;
- verification status.

Essa estrutura deverá ser a base de overlap.

---

# 56. ReviewCluster

Função candidata:

- agrupar reviews suficientemente relacionadas/sobrepostas;
- registrar escopo do cluster;
- facilitar política de priorização/deduplicação.

---

# 57. OverlapResolution

Função candidata:

Registrar prospectivamente e auditavelmente:

- estratégia A/B/C;
- review selecionada;
- reviews retidas/excluídas;
- criteria;
- rationale;
- actor/verification.

---

# 58. OutcomeEvidence

Função candidata:

Representar resultado de review no contexto do Overview sem copiar indevidamente estruturas primárias.

Deverá vincular:

- ReviewItem;
- outcome;
- comparison;
- timepoint;
- review Result/Synthesis;
- effect estimate;
- certainty source;
- primary-study set quando disponível.

---

# 59. ConcordanceAssessment

Função candidata:

Comparar ReviewItems/OutcomeEvidence sem produzir score de qualidade.

Poderá registrar:

- concordance state;
- dimensions of disagreement;
- rationale;
- provenance.

---

# 60. Dados derivados — não persistir como verdade primária

Derivar, quando possível:

- pairwise overlap;
- CCA;
- overlap heatmap;
- review coverage counts;
- age/currentness indicators;
- concordance summaries.

Não persistir esses cálculos como substitutos da membership/inputs auditáveis.

---

# 61. View futura

Nome candidato:

> `OverviewOfReviewsView`

Schema candidato:

> `oes.overview_of_reviews_view/0.1`

Deverá ser suficiente para renderer sem consultas diretas às tabelas científicas.

---

# 62. Publication gate futuro

Deverá verificar, no mínimo:

- Product type;
- primary Investigation;
- protocol;
- comprehensive/reproducible review search;
- systematic-review eligibility;
- complete review identity resolution;
- appraisal;
- primary-study overlap assessment;
- overlap resolution policy;
- extraction completeness;
- conflict handling;
- certainty disclosure;
- currentness;
- invalidated dependencies;
- publication status;
- currency;
- A3;
- qualified stage controls.

---

# 63. Fixture formal

Antes de Caso Real:

> criar fixture sintética com reviews parcialmente sobrepostas.

Fixture deverá conter pelo menos:

- 3 systematic reviews;
- 5 primary Studies;
- overlap parcial;
- uma review de alto risk of bias;
- duas reviews atualizadas em datas diferentes;
- estimates concordantes e discordantes;
- GRADE disponível em parte do corpus;
- cluster com decisão de overlap;
- A3 sintético;
- qualified human controls sintéticos.

---

# 64. Testes adversariais mínimos

1. review duplicada por múltiplos Reports;
2. updated review contada duas vezes;
3. overlapping primary Study double-counted;
4. CCA calculado sobre membership incompleta;
5. review de alto RoB tratada como equivalente sem disclosure;
6. certainty global inventada;
7. author conclusion usada no lugar de outcome data;
8. informal indirect comparison;
9. systematic review definition não satisfeita;
10. search incompleta;
11. overlap não avaliado;
12. A3 sem stage controls;
13. IA simulando reviewer humano;
14. review desatualizada tratada como current;
15. systematic Overview com supplemental primary studies não autorizados;
16. re-meta-analysis sem statistical governance.

---

# 65. Readiness para Caso Real

Caso Real formal somente após:

- contrato de dados PASS;
- fixture PASS;
- view PASS;
- template PASS;
- Infrastructure Readiness Gate.

Dada a exigência de controles humanos qualificados:

> **não assumir antecipadamente que a infraestrutura atual do OES está READY.**

Readiness deverá ser avaliado após o contrato técnico.

---

# 66. Relação com Mapa de Evidências

Mapa:

> distribui evidência por dimensões.

Overview:

> sintetiza e compara systematic reviews.

Um Overview poderá alimentar um Mapa.

Um Mapa de reviews não substitui Overview porque não resolve necessariamente:

- overlap;
- conflicts;
- review risk of bias;
- effect synthesis;
- certainty.

---

# 67. Relação com N4

N4:

> investiga e sintetiza primary evidence diretamente.

Overview:

> investiga systematic-review evidence.

Se o Overview precisar retornar extensivamente aos primary studies para produzir a resposta:

> considerar N4.

---

# 68. Relação com Ficha/Resposta

Uma revisão sistemática ou Overview robusto poderá alimentar:

- N1;
- N2;
- monitoramento.

Mas:

> review-level synthesis não elimina a necessidade de verificar aderência da pergunta e atualidade.

---

# 69. Manutenção

Compatível com:

- M0;
- M1;
- M2;
- M3.

M2/M3 devem monitorar:

- novas reviews;
- updates de reviews incluídas;
- correções/retrações;
- mudanças relevantes de primary-study corpus;
- atualização de GRADE;
- novas comparisons/outcomes.

---

# 70. Fontes metodológicas de referência

1. Pollock M, Fernandes RM, Becker LA, Pieper D, Hartling L. **Chapter V: Overviews of Reviews.** Cochrane Handbook for Systematic Reviews of Interventions, version 6.5, 2024; chapter last updated August 2023.
2. Gates M, Gates A, Pieper D, et al. **Reporting guideline for overviews of reviews of healthcare interventions: development of the PRIOR statement.** BMJ. 2022;378:e070849.
3. JBI Manual for Evidence Synthesis. **Umbrella Reviews**, 2024 edition.
4. Pieper D, Antoine SL, Mathes T, Neugebauer EAM, Eikermann M. **Systematic review finds overlapping reviews were not mentioned in every other overview.** Journal of Clinical Epidemiology. 2014.
5. Hennessy EA, Johnson BT. **Examining overlap of included studies in meta-reviews: guidance for using the corrected covered area index.** Research Synthesis Methods. 2020.

---

# 71. Decisão

> **Especificação científica e funcional inicial do Overview de Revisões definida.**

Decisões centrais:

- systematic review é a unidade principal;
- OES-P1 representa review como Study + Report;
- supplemental primary studies ficam fora do corpus analítico formal v0.1;
- ROBIS é o default de risk of bias da review;
- overlap exige membership Study-level;
- CCA é derivado, não score;
- double counting é proibido;
- meta-análise de meta-análises não é default;
- certainty existente é coletada, não agregada artificialmente;
- formal Overview exige A3 + qualified human controls;
- arquitetura especializada deverá ser revisada antes do contrato de dados.

---

# 72. Próxima etapa

> **Executar a Revisão de Coerência e Decisão Arquitetural do Overview de Revisões.**

Objetivos:

1. testar aderência ao OES-P1;
2. decidir estruturas especializadas mínimas;
3. verificar reuse de Study/Report/Synthesis/ROBIS;
4. definir identity/version semantics de reviews;
5. fechar overlap representation;
6. fechar relação Product ↔ Overview layer;
7. somente depois criar contrato de dados.

---

**Resultado:** Overview de Revisões metodologicamente especificado; nenhuma implementação física iniciada.
