# 115 — Especificação Científica e Funcional da Revisão de Evidências — N4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências  
**Nível:** N4  
**Data:** 6 de outubro de 2026  
**Status:** Documento vivo — especificação científica e funcional inicial  
**Dependências canônicas:** Documentos 02–04, 10–15, 20–21, 38, 40, 99–114 e CP36

---

# 1. Finalidade

A **Revisão de Evidências — N4** é o produto de maior profundidade metodológica do OES para perguntas em que a finalidade exige:

- elevada completude;
- busca sistemática abrangente;
- seleção independente;
- appraisal completo;
- síntese aprofundada;
- avaliação formal de certeza/confiança;
- rastreabilidade suficiente para reprodução;
- controles humanos qualificados;
- revisão especializada independente antes de publicação formal.

N4 é indicado especialmente quando houver, em grau material:

- alta criticidade;
- literatura extensa ou conflitante;
- ausência de síntese adequada;
- necessidade de síntese quantitativa complexa;
- necessidade de avaliar missing evidence/publication bias;
- finalidade científica, institucional, regulatória, diretriz ou política.

Regra central:

> **N4 não é “N3 com mais estudos”. É uma classe de investigação em que completude, independência de etapas críticas e reprodutibilidade são requisitos constitutivos.**

---

# 2. Nome de família e subtipos

O nome de família será:

> **OES — Revisão de Evidências**

O termo:

> **Revisão Sistemática**

somente poderá ser utilizado como subtipo quando os requisitos metodológicos correspondentes forem efetivamente satisfeitos.

Não será permitido:

- rotular produto como systematic review apenas por usar busca bibliográfica;
- inferir revisão sistemática a partir de depth=N4;
- usar nomenclatura de revisão sistemática quando etapas críticas forem abreviadas de forma incompatível;
- ocultar ausência de revisores independentes;
- ocultar insuficiência de fontes ou bases.

Subtipos futuros poderão incluir, quando metodologicamente definidos:

- systematic review of interventions;
- systematic review of diagnostic test accuracy;
- systematic review of prognosis;
- systematic review of prediction models;
- systematic review of prevalence/incidence;
- qualitative evidence synthesis;
- mixed-methods review;
- network meta-analysis review;
- individual participant data review;
- living systematic review;
- outros subtipos formalmente especificados.

A existência de subtipo não cria automaticamente novo nível além de N4.

---

# 3. Pergunta central

N4 responde a uma pergunta formalmente operacionalizada, em geral Q2, cuja resposta requer investigação aprofundada.

O framework deverá ser adequado à classe de pergunta, por exemplo:

- PICO/PICOTS — intervenção;
- PECO — exposição;
- framework diagnóstico;
- prognóstico;
- predição;
- prevalência/incidência;
- qualitativo;
- mixed methods;
- sistemas/políticas.

A pergunta deverá determinar elegibilidade, busca, unidades de extração, RiskAssessment, agrupamentos de síntese, certainty/confidence e aplicabilidade.

---

# 4. Quando N4 é apropriado

N4 é apropriado quando uma ou mais das seguintes condições forem materiais:

1. finalidade exige alta completude;
2. decisão é de elevada consequência;
3. literatura é extensa ou conflitante;
4. sínteses existentes estão desatualizadas, inadequadas ou metodologicamente frágeis;
5. é necessária síntese quantitativa complexa;
6. é necessário explorar heterogeneidade de forma aprofundada;
7. missing evidence/publication bias pode alterar a conclusão;
8. são necessárias análises de sensibilidade robustas;
9. há múltiplos desenhos ou estimandos que exigem integração metodológica cuidadosa;
10. finalidade externa exige padrão de revisão sistemática;
11. produto será usado em diretriz, regulação, HTA ou política de alta consequência;
12. N3 seria insuficiente porque suas abreviações poderiam alterar materialmente a validade.

---

# 5. Quando N4 é inadequado ou prematuro

N4 não deverá ser iniciado quando:

- a pergunta ainda estiver ampla ou instável;
- um N0 for necessário para delimitação;
- uma síntese recente e robusta responder adequadamente à pergunta;
- uma N1/N2 for proporcional;
- uma N3 satisfizer a necessidade sem perda material de validade;
- Overview for epistemologicamente mais apropriado;
- Evidence Map for mais apropriado;
- não houver infraestrutura mínima para executar o método N4;
- não houver equipe qualificada suficiente para etapas humanas obrigatórias;
- bases críticas estiverem inacessíveis e a cobertura não puder ser defendida;
- expertise estatística/metodológica requerida não estiver disponível.

Regra:

> **a profundidade desejada não autoriza iniciar N4 quando a infraestrutura necessária é inexistente.**

---

# 6. Infrastructure Readiness Gate — requisito prévio

Antes de abrir formalmente qualquer Caso Real N4 deverá ser executado um:

> **N4 Infrastructure Readiness Gate**

O gate deverá ser concluído antes da busca definitiva.

## 6.1 Objetivo

Confirmar que o OES dispõe dos recursos mínimos para cumprir o protocolo proposto.

## 6.2 Domínios

### A. Cobertura bibliográfica

Confirmar:

- acesso às bases necessárias à classe de pergunta;
- possibilidade de executar estratégias reproduzíveis;
- capacidade de exportar e registrar resultados;
- fontes suplementares necessárias;
- registros de ensaios quando aplicáveis;
- fontes regionais, institucionais ou regulatórias pertinentes.

### B. Equipe metodológica

Confirmar disponibilidade real de:

- pelo menos dois avaliadores qualificados e independentes nas etapas críticas;
- adjudicação/terceiro avaliador quando necessária;
- especialista em informação ou equivalente quando a busca exigir;
- expertise de appraisal apropriada;
- expertise GRADE/CERQual/CINeMA quando aplicável.

### C. Estatística

Quando necessário, confirmar:

- expertise bioestatística;
- software adequado;
- capacidade de reproduzir análises;
- suporte a modelos complexos;
- meta-regressão/NMA/IPD quando pertinente.

### D. Ferramentas e artefatos

Confirmar:

- deduplicação;
- armazenamento de estratégias e exports;
- ambiente analítico;
- controle de versão;
- preservação de código;
- artefatos de SoF/Evidence Profile;
- mecanismos de auditoria.

### E. Governança

Confirmar:

- caminho A3;
- expert independent review disponível;
- conflitos de interesse registráveis;
- papéis distintos entre revisores;
- capacidade de preservar decisões independentes antes de consenso.

## 6.3 Resultado

Estados:

- ready;
- ready_with_documented_conditions;
- not_ready.

Se not_ready:

> **não iniciar Caso Real N4 formal.**

É permitido continuar especificação, arquitetura, fixtures sintéticas, testes técnicos e simulação controlada.

---

# 7. Lição incorporada do Caso Real N3-01

O Caso Real N3 demonstrou que:

- technical PASS não equivale a methodological PASS;
- busca suplementar não substitui automaticamente uma base bibliográfica;
- adicionar artigos incrementalmente não corrige arquitetura de busca inadequada;
- conclusão plausível não compensa coverage insuficiente;
- adversarial verification deve poder bloquear assurance.

Para N4:

> **a suficiência de infraestrutura deve ser verificada antes de investir na execução científica.**

---

# 8. Protocolo obrigatório

Toda investigação N4 deverá possuir protocolo formal antes da busca definitiva e seleção.

O protocolo deverá registrar, conforme aplicável:

- pergunta e rationale;
- subtipo N4;
- objetivos;
- framework;
- critérios de elegibilidade;
- outcomes/achados;
- fontes de informação;
- estratégias de busca;
- literatura cinzenta;
- registros;
- seleção;
- extração;
- risk of bias/appraisal;
- unidade de síntese;
- medidas de efeito;
- método/modelo;
- heterogeneidade;
- subgrupos;
- meta-regressão;
- sensibilidade;
- missing evidence/publication bias;
- certainty/confidence;
- SoF/Evidence Profile;
- aplicabilidade;
- papéis/revisores;
- adjudicação;
- software;
- reprodutibilidade;
- data de corte;
- updating plan para M1–M3;
- conflitos de interesse;
- financiamento;
- condições de desvio/emenda.

Registro público externo deverá ser definido quando metodologicamente indicado.

---

# 9. Emendas e desvios

Após o protocolo:

## Emenda

Mudança planejada e justificada antes de observar o resultado relevante.

## Desvio

Diferença entre método planejado e executado.

Ambos deverão registrar:

- identificador;
- data;
- motivo;
- impacto potencial;
- responsável;
- estado/resolução.

Proibido:

> reescrever silenciosamente o protocolo para fazê-lo parecer compatível com a execução.

---

# 10. Busca — regra geral

A busca N4 deverá:

> **maximizar sensibilidade e reduzir risco de perda sistemática de evidência relevante.**

Deverá ser:

- sistemática;
- reproduzível;
- documentada;
- suficientemente abrangente para a classe de pergunta;
- atualizada próximo ao fechamento quando necessário.

Não haverá número universal fixo de bases.

A cobertura será orientada pelo domínio, mas a revisão deverá justificar fontes incluídas e fontes relevantes omitidas.

---

# 11. Fontes de informação N4

Conforme a pergunta, considerar:

- MEDLINE/PubMed;
- CENTRAL;
- Embase;
- bases especializadas;
- CINAHL;
- PsycINFO;
- LILACS/BVS;
- bases regionais;
- registros de ensaios;
- WHO ICTRP;
- ClinicalTrials.gov;
- ReBEC;
- literatura cinzenta;
- teses/dissertações;
- relatórios;
- regulatory/HTA sources;
- fontes institucionais;
- citation chasing retrospectivo e prospectivo;
- protocolos;
- preprints quando pertinentes;
- contato com autores quando justificado.

Literatura cinzenta em N4 deverá ser:

> **sistematicamente considerada**, ainda que a decisão final seja não incluí-la.

---

# 12. Estratégia de busca

A estratégia deverá:

- derivar da pergunta/elegibilidade;
- combinar vocabulário controlado e texto livre;
- incluir variantes, sinônimos e termos históricos quando necessários;
- evitar restrição excessiva por outcome sem justificativa;
- usar filtros metodológicos somente quando apropriados/validados;
- ser traduzida adequadamente entre plataformas;
- preservar cada estratégia exata.

Cada Search deverá registrar:

- Search ID;
- base;
- plataforma;
- data;
- estratégia integral;
- campos;
- filtros;
- período;
- idioma;
- result_count;
- responsável;
- versão;
- observações.

---

# 13. Peer review da busca

Para N4:

> **PRESS ou verificação equivalente por especialista qualificado é recomendada como padrão.**

Se PRESS não for aplicável:

- justificar;
- definir controle equivalente;
- registrar qualificação do verificador.

IA poderá auxiliar na detecção de erros sintáticos, termos ausentes e problemas de tradução entre bases.

IA não será registrada como PRESS reviewer humano.

---

# 14. PRISMA-S

Para Revisão Sistemática N4:

> **PRISMA-S deverá orientar o relato da busca**, salvo incompatibilidade documentada com subtipo específico.

PRISMA-S é extensão de relato.

Não deverá ser usada como substituto do método de busca.

---

# 15. Estudos sentinela e sensibilidade da busca

Estudos conhecidos elegíveis poderão testar a estratégia.

Se estudo sentinela não for recuperado:

- investigar termos;
- indexação;
- filtros;
- campos;
- cobertura;
- erros de tradução entre bases.

A correção deverá ser registrada.

---

# 16. Deduplicação e unidade Study/Report

N4 deverá distinguir:

- registro recuperado;
- Report;
- Study;
- múltiplos Reports do mesmo Study.

Deduplicação poderá usar DOI, PMID, trial ID, título, autores, periódico, ano e métodos probabilísticos.

Não descartar relatório secundário apenas por existir publicação principal.

---

# 17. Elegibilidade

Critérios deverão ser:

- pré-especificados;
- operacionais;
- reproduzíveis;
- compatíveis com a pergunta.

Deverão definir tratamento de populações mistas, intervenções/exposições mistas, comparadores, outcomes, desenhos, timepoints, subgrupos, idiomas, status de publicação, múltiplos relatórios, dados não separáveis, estudos em andamento e awaiting classification.

---

# 18. Seleção N4

## 18.1 Pilotagem

Obrigatória antes da seleção integral.

## 18.2 Título/resumo

Padrão preferencial:

> **dois revisores independentes em todos os registros.**

Exceções deverão ser protocoladas e justificadas.

## 18.3 Texto completo

Obrigatório:

> **pelo menos dois revisores independentes.**

## 18.4 Discordâncias

Decisões iniciais deverão ser registradas antes do consenso.

Fluxo:

Reviewer A + Reviewer B → discordância → discussão → consenso ou adjudicação.

Quando necessário:

> terceiro avaliador/adjudicador.

## 18.5 Exclusões

Toda exclusão em full text deverá possuir motivo e ser rastreável.

---

# 19. IA na seleção

IA poderá:

- deduplicar;
- priorizar;
- identificar duplicatas prováveis;
- sugerir elegibilidade;
- organizar conflitos;
- localizar informação.

IA não poderá:

- ocupar vaga de segundo revisor humano independente;
- apagar discordância;
- fabricar concordância;
- realizar adjudicação humana fictícia.

---

# 20. Extração de dados

N4 deverá utilizar formulário estruturado e versionado.

Extrair, conforme aplicável:

- Study/Report IDs;
- população;
- intervenção/exposição;
- comparador;
- contexto;
- follow-up;
- outcome;
- timepoint;
- estimand;
- effect measure;
- numerador/denominador;
- variância/SE/CI;
- missing data;
- ajustes;
- multiplicidade;
- financiamento;
- conflitos;
- informações de risk of bias.

Dados críticos deverão receber:

> **extração independente ou verificação humana qualificada segundo o protocolo.**

O padrão formal N4 não poderá depender exclusivamente de extração por IA.

---

# 21. Appraisal / Risk of Bias

Obrigatório para evidência que sustenta materialmente a conclusão.

Ferramenta deverá ser orientada por desenho/pergunta.

Exemplos:

- RoB 2 — RCTs;
- ROBINS-I — intervenções não randomizadas;
- ROBINS-E — exposições;
- QUADAS-3 — acurácia diagnóstica;
- QUIPS — prognóstico;
- PROBAST+AI — modelos de predição;
- ROBIS — revisões;
- JBI tools quando apropriado.

Versão da ferramenta deverá ser registrada.

---

# 22. Appraisal N4 — independência

Padrão:

- pelo menos dois avaliadores;
- avaliação inicial independente;
- instrumento completo;
- justificativas por domínio;
- resolução de discordâncias;
- adjudicação quando necessário.

IA poderá apoiar, mas:

> **não poderá produzir o julgamento final N4 sem revisão humana qualificada.**

---

# 23. Results

Cada Result deverá identificar:

- Study;
- Report source;
- Outcome;
- timepoint;
- população;
- comparador;
- estimand;
- measure;
- value;
- uncertainty;
- analysis population;
- adjusted/unadjusted;
- provenance;
- extraction/verification.

Dados transformados deverão preservar valor original, transformação, fórmula e código/artefato quando aplicável.

---

# 24. Plano de síntese

Deverá ser pré-especificado.

Conforme aplicável:

- agrupamentos;
- comparisons;
- outcomes;
- timepoints;
- estimands;
- effect measures;
- model;
- múltiplos braços;
- dados correlacionados;
- cluster/crossover;
- eventos raros;
- zero events;
- subgroups;
- meta-regression;
- sensitivity analyses;
- criteria for pooling;
- no-pooling rules;
- SWiM;
- integração de risk of bias;
- missing evidence/small-study effects.

Mudanças pós-hoc deverão ser declaradas.

---

# 25. Combinabilidade

Antes de pooling, avaliar similaridade:

- clínica;
- de outcome;
- metodológica;
- estatística.

Não existe score universal de combinabilidade.

Decisões possíveis:

- combinar;
- harmonizar e combinar;
- subgrupos;
- separar;
- SWiM;
- não sintetizar.

---

# 26. Meta-análise

Meta-análise não é obrigatória em todo N4.

Quando realizada:

- modelo deverá ser justificado;
- escolha não será determinada pelo resultado observado;
- heterogeneidade será investigada;
- inferência considerará número de estudos e incerteza;
- código, parâmetros e software serão registrados.

Não usar:

> “N4 = meta-análise obrigatória”.

---

# 27. Heterogeneidade

Avaliar:

- clínica;
- metodológica;
- estatística.

Quando quantitativa, considerar τ², I², prediction intervals e análises de influência quando apropriado.

Não reduzir interpretação a limiar automático de I².

---

# 28. Subgrupos e meta-regressão

Deverão ser pré-especificados quando confirmatórios, plausíveis e limitados em número.

Análises pós-hoc serão identificadas.

Meta-regressão exige suporte estatístico e informação suficiente.

---

# 29. Análises de sensibilidade

Planejar para decisões capazes de alterar a conclusão, por exemplo:

- high risk of bias;
- imputações;
- modelo;
- correlação assumida;
- definição de outcome;
- estudos não publicados;
- influência;
- transformações.

---

# 30. Missing evidence / publication bias

N4 deverá avaliar missing evidence quando aplicável.

Podem ser considerados:

- registros;
- protocolos;
- discrepâncias outcome-reporting;
- estudos não publicados;
- funnel plots quando apropriados;
- small-study effects;
- métodos estatísticos compatíveis;
- ROB-ME ou ferramenta vigente;
- contato com autores.

Ausência de assimetria não prova ausência de publication bias.

---

# 31. Network meta-analysis

Quando aplicável:

- protocolo específico;
- rede clinicamente coerente;
- transitivity;
- consistency/incoherence;
- ranking somente quando interpretável;
- CINeMA ou framework vigente;
- expertise estatística obrigatória;
- código reprodutível.

NMA não será executada apenas porque uma rede pode ser construída.

---

# 32. Síntese sem meta-análise

Quando pooling for inadequado:

- usar narrativa estruturada;
- preservar direção/magnitude;
- evitar vote counting por significância;
- considerar SWiM;
- explicar por que não houve meta-análise.

---

# 33. Certainty / confidence

Framework deverá ser apropriado à classe de evidência.

Exemplos:

- GRADE;
- GRADE-CERQual;
- CINeMA;
- frameworks específicos quando pertinentes.

Para N4:

> **pelo menos dois avaliadores independentes deverão participar da avaliação final de certeza/confiança.**

Preservar framework/versão, domínio, julgamento, downgrade/upgrade, rationale, reviewer e consenso/adjudicação.

IA não poderá atribuir certeza final N4 sem revisão humana qualificada.

---

# 34. Summary of Findings / Evidence Profile

Quando aplicável, N4 deverá produzir:

- Summary of Findings;
- Evidence Profile;
- Summary of Qualitative Findings;
- ou equivalente metodologicamente apropriado.

Outcomes deverão ser pré-especificados e orientados à decisão.

Efeitos absolutos deverão registrar baseline risk, fonte, contexto e transformação.

---

# 35. Aplicabilidade

N4 deverá distinguir:

- validade interna;
- certeza/confiança;
- aplicabilidade;
- transferibilidade;
- contexto local;
- recomendação.

Aplicabilidade não será automaticamente incorporada ao GRADE como downgrade sem regra do framework.

---

# 36. Reprodutibilidade analítica

Preservar, conforme aplicável:

- protocolo;
- search strategies;
- exports;
- dedup log;
- screening decisions;
- exclusion reasons;
- extraction forms;
- risk-of-bias records;
- datasets;
- analysis code;
- software/version;
- model parameters;
- figures;
- SoF/Evidence Profile;
- audit/assurance records.

Quando dados não puderem ser redistribuídos, registrar a restrição e preservar código/metadados permitidos.

---

# 37. Relato

Para Revisão Sistemática N4 de intervenções:

> **PRISMA 2020 será referência de relato.**

Para busca:

> **PRISMA-S será referência de relato da estratégia e recuperação.**

Extensões PRISMA específicas deverão ser consideradas conforme o subtipo.

Relato não substitui método.

---

# 38. Atualização da busca antes do fechamento

Quando houver intervalo material entre busca e conclusão:

- avaliar rerun;
- registrar data final;
- incorporar estudos novos conforme protocolo;
- preservar histórico.

Uma revisão não deverá ser apresentada como current sem avaliação de currency.

---

# 39. Living review — N4 + M3

N4 + M3 poderá ser designada living systematic review somente quando existir:

- protocolo de vigilância;
- frequência;
- gatilhos de incorporação;
- reexecução de busca;
- seleção/appraisal/extração atualizáveis;
- regras de atualização de synthesis/certainty;
- versionamento;
- comunicação do estado de atualização.

M3 isoladamente não cria living systematic review.

---

# 40. Assurance N4

Publicação formal N4 exige:

> **A3 + requisitos humanos específicos do protocolo.**

A3 sozinho não basta se etapas críticas não tiverem os avaliadores exigidos.

O owner:

> **não pode ocupar vaga de revisor metodológico qualificado apenas por ser humano ou proprietário.**

---

# 41. IA em N4

IA poderá auxiliar em busca, deduplicação, priorização, localização de trechos, extração preliminar, appraisal preliminar, cálculo, geração de código, detecção de inconsistências e organização de certainty.

IA não poderá ser registrada como:

- segundo avaliador humano;
- adjudicador humano;
- PRESS reviewer humano;
- expert independent reviewer;
- avaliador final de certainty sem revisão humana;
- substituto de expertise estatística exigida.

---

# 42. Controles humanos críticos

A especificação operacional deverá definir controles tipados, pelo menos para:

- search strategy peer review;
- title/abstract screening;
- full-text screening;
- critical-data extraction/verification;
- risk-of-bias/appraisal;
- certainty/confidence;
- statistical review quando análise complexa exigir;
- expert independent review final.

Cada controle deverá registrar actor, qualification, role, independence, decision, scope, date, conflict e resolution.

---

# 43. Gate de publicação

Um N4 formal deverá ser bloqueado se houver, entre outros:

- protocolo ausente;
- Infrastructure Readiness Gate não aprovado;
- fonte/base crítica ausente sem justificativa aceitável;
- busca não reproduzível;
- search peer review requerido e ausente;
- seleção independente incompleta;
- full-text decisions sem dupla avaliação;
- dados críticos sem verificação;
- appraisal incompleto;
- synthesis ausente quando necessária;
- certainty ausente/incompleta;
- SoF/Evidence Profile requerido e ausente;
- open deviation material não resolvido;
- missing evidence não avaliado quando aplicável;
- artefato reprodutível requerido e ausente;
- qualified human controls incompletos;
- expert independent review ausente;
- assurance abaixo de A3;
- publication_date ausente;
- dependência científica invalidada.

---

# 44. Estado experimental

O OES poderá desenvolver N4 em estado experimental para:

- arquitetura;
- fixtures;
- migrations;
- views;
- templates;
- gates;
- testes;
- casos simulados.

Se Infrastructure Readiness Gate=not_ready:

> **qualquer caso real deverá permanecer explicitamente experimental e não poderá receber rótulo formal de Revisão Sistemática.**

---

# 45. Relação N4 versus N3

N3:

- admite abreviações pré-especificadas;
- pode reduzir cobertura com risco comunicado;
- é orientado a rapidez/proporcionalidade.

N4:

- não parte de abreviação como mecanismo central;
- busca maximizar sensibilidade/completude;
- exige maior independência e reprodutibilidade;
- suporta análises mais complexas.

Se uma abreviação material for necessária para tornar N4 executável:

> **avaliar rerroteamento para N3 em vez de chamar o produto de N4.**

---

# 46. Relação N4 versus N2

N2:

- unidade persistente focal;
- pode adotar/atualizar evidência;
- publicação padrão pode ocorrer em A2.

N4:

- investigação primária de síntese aprofundada;
- exige A3 e controles humanos;
- busca/seleção são centrais ao método;
- pode alimentar uma Ficha N2 persistente posteriormente.

---

# 47. Relação N4 versus Overview e Evidence Map

Quando a unidade principal forem revisões sistemáticas existentes, considerar Overview.

Quando a pergunta for “que evidência existe e como ela se distribui?”, considerar Evidence Map.

N4 deve ser escolhido pela arquitetura epistemológica da pergunta, não por ser “mais profundo”.

---

# 48. Manutenção M0–M3

N4 é compatível com M0, M1, M2 e M3.

A escolha deve refletir:

- velocidade do campo;
- consequência de desatualização;
- capacidade de manter busca;
- disponibilidade de equipe;
- custo/complexidade.

---

# 49. Critérios de conclusão científica

A conclusão N4 deverá:

- responder à pergunta;
- refletir magnitude;
- refletir incerteza;
- refletir certainty/confidence;
- preservar heterogeneidade relevante;
- evitar extrapolação;
- separar evidência de recomendação;
- explicitar missing evidence;
- explicitar aplicabilidade.

Não deverá converter ausência de evidência em ausência de efeito ou p-value em certeza.

---

# 50. Padrões externos confirmados nesta data

Na data desta especificação:

- o Cochrane Handbook online permanece fonte metodológica viva e recebe atualizações versionadas;
- PRISMA 2020 permanece a referência principal de relato de systematic reviews;
- PRISMA-S permanece extensão específica para relato de buscas;
- RoB 2 permanece ferramenta corrente para randomized trials;
- QUADAS-3 é a versão corrente recomendada para diagnostic test accuracy;
- PROBAST+AI é referência atualizada para prediction models com regressão/IA;
- o GRADE Book está em transição para substituir integralmente o GRADE Handbook.

Regra:

> **o protocolo específico deverá confirmar novamente a versão vigente de cada framework/ferramenta no momento da execução.**

---

# 51. Requisitos mínimos de saída N4

Uma Revisão de Evidências N4 deverá poder apresentar:

1. identidade/versionamento;
2. pergunta;
3. protocolo;
4. Infrastructure Readiness Gate;
5. emendas/desvios;
6. bases/fontes;
7. estratégias completas;
8. search peer review;
9. deduplicação;
10. fluxo de seleção;
11. exclusões full text;
12. estudos incluídos;
13. Study/Report linkage;
14. características;
15. Results;
16. RiskAssessment;
17. Synthesis;
18. heterogeneidade;
19. sensibilidade;
20. missing evidence/publication bias;
21. certainty/confidence;
22. SoF/Evidence Profile;
23. aplicabilidade;
24. limitações;
25. conclusão;
26. data de corte;
27. materiais reprodutíveis;
28. assurance;
29. reviewers/adjudication;
30. audit/provenance.

---

# 52. Condições para usar o subtipo “Revisão Sistemática”

O rótulo deverá exigir, no mínimo:

- pergunta estruturada;
- protocolo prévio;
- Infrastructure Readiness Gate adequado;
- busca sistemática/reproduzível/abrangente;
- fontes suficientes;
- seleção formal;
- avaliação independente nas etapas críticas;
- appraisal;
- synthesis;
- certainty/confidence quando aplicável;
- relato compatível com guideline pertinente;
- reprodutibilidade;
- A3;
- human-qualified controls completos.

Se requisito estrutural material estiver ausente:

> **usar “Revisão de Evidências — N4 experimental” ou rerrotear; não usar “Revisão Sistemática” como rótulo formal.**

---

# 53. Situação operacional atual do OES

Na configuração atual:

- arquitetura e metodologia N4 podem ser desenvolvidas;
- fixtures e testes podem ser executados;
- views/templates/gates podem ser construídos;
- um Caso Real N4 formal **não deverá ser iniciado ainda**.

Razões:

- não há dois revisores humanos qualificados disponíveis;
- não há expert independent reviewer configurado;
- a experiência N3 mostrou limitações de acesso a bases bibliográficas;
- não há garantia de expertise estatística para todas as análises complexas possíveis.

Portanto:

> **o próximo passo é arquitetura/contrato N4, não Caso Real N4.**

---

# 54. Próxima etapa

Executar:

> **Revisão de Coerência e Decisão Arquitetural da Revisão de Evidências — N4**

Objetivos:

1. mapear requisitos deste Documento 115 ao OES-P1;
2. decidir quais estruturas N3 podem ser reutilizadas;
3. identificar lacunas específicas de N4;
4. definir se novos tipos/tabelas são necessários;
5. modelar Infrastructure Readiness Gate;
6. modelar reviewers/independence/adjudication;
7. modelar search peer review;
8. modelar missing-evidence assessment;
9. modelar reprodutibilidade analítica;
10. não criar migration antes dessa revisão.

---

**Decisão:** a especificação científica e funcional inicial do N4 fica consolidada neste Documento 115.