# 11 — Protocolo de Elegibilidade, Triagem e Seleção de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — em desenvolvimento  
**Data de consolidação inicial:** 3 de outubro de 2026

## 1. Finalidade

Este protocolo define como registros recuperados pelas buscas do OES serão avaliados até que se determine quais estudos, revisões, documentos ou outras fontes integrarão uma investigação.

O objetivo é garantir que a passagem entre:

**resultado de busca → registro triado → relatório recuperado → estudo elegível → corpo de evidências**

ocorra por critérios explícitos, proporcionais ao nível de investigação e auditáveis.

A seleção não deverá ser guiada pelos resultados encontrados, pela direção do efeito ou pela conveniência de uma conclusão.

---

## 2. Princípio fundamental

> **Elegibilidade deve ser definida antes da seleção definitiva.**

Critérios de inclusão e exclusão devem derivar da pergunta operacional Q2, da classe metodológica, do objetivo analítico e do protocolo da investigação.

Alterações posteriores podem ocorrer quando surgirem situações imprevistas, mas devem:

- manter fidelidade ao objetivo da investigação;
- ser justificadas;
- ser datadas;
- ser versionadas;
- não ser motivadas pelos resultados dos estudos.

---

## 3. Unidade de seleção

O OES distinguirá três entidades:

### Registro

Entrada bibliográfica ou documental recuperada por uma fonte.

Exemplos:

- referência PubMed;
- registro ClinicalTrials.gov;
- resultado LILACS;
- página institucional.

### Relatório / publicação

Documento concreto contendo informações sobre uma investigação.

Exemplos:

- artigo;
- protocolo;
- resumo de congresso;
- relatório técnico;
- preprint;
- publicação de follow-up.

### Estudo

Unidade científica subjacente.

Um estudo pode possuir múltiplos relatórios.

Consequentemente:

> **incluir cinco relatórios de um mesmo ensaio não significa incluir cinco estudos.**

A estrutura de seleção deverá preservar contagens separadas de registros, relatórios e estudos.

---

## 4. Relação com o Protocolo de Busca

O Documento 10 termina com um conjunto de registros recuperados, preferencialmente deduplicados.

O Documento 11 inicia a partir desse conjunto.

Fluxo:

**Busca**

↓

**Registros recuperados**

↓

**Deduplicação bibliográfica**

↓

**Triagem título/resumo**

↓

**Recuperação de texto completo**

↓

**Avaliação de elegibilidade**

↓

**Vinculação de múltiplos relatórios**

↓

**Decisão no nível do estudo**

↓

**Corpo de evidências**

---

## 5. Tipos de decisão

Uma seleção poderá produzir os seguintes estados.

### RECORD-PENDING

Registro ainda não avaliado.

### RECORD-EXCLUDE

Registro excluído na triagem inicial.

### RECORD-POTENTIAL

Registro potencialmente elegível e encaminhado para recuperação.

### REPORT-NOT-RETRIEVED

Relatório potencialmente relevante que não pôde ser recuperado.

### REPORT-FULLTEXT

Relatório recuperado e em avaliação de texto completo.

### STUDY-INCLUDED

Estudo elegível.

### STUDY-EXCLUDED

Estudo avaliado por texto completo e considerado inelegível.

### STUDY-AWAITING-CLASSIFICATION

Informação insuficiente para decisão final.

### STUDY-ONGOING

Estudo ainda em andamento ou sem resultados suficientemente disponíveis.

### STUDY-LINKED

Relatório vinculado a Study ID já existente.

Esses estados poderão ser refinados posteriormente no modelo de dados.

---

# PARTE I — CRITÉRIOS DE ELEGIBILIDADE

## 6. Critérios pré-especificados

Para N2, N3 e N4, os critérios deverão ser formalizados antes da seleção definitiva.

Conforme a pergunta, poderão incluir:

- população;
- condição;
- intervenção;
- exposição;
- comparador;
- teste índice;
- referência diagnóstica;
- fator prognóstico;
- preditores;
- desfecho, somente quando metodologicamente justificado;
- desenho do estudo;
- contexto;
- período;
- duração mínima de acompanhamento;
- tipo de publicação;
- idioma;
- região;
- características adicionais necessárias.

---

## 7. Critérios positivos e negativos

Sempre que possível, os critérios deverão ser formulados de forma operacional.

Exemplo inadequado:

> “Estudos relevantes sobre idosos.”

Exemplo preferível:

> “Estudos em adultos com idade média ≥65 anos ou que apresentem resultados separadamente para participantes ≥65 anos.”

Quando uma regra quantitativa não for cientificamente justificável, poderá ser usada definição qualitativa explícita.

---

## 8. Populações parcialmente elegíveis

Estudos frequentemente contêm mistura de participantes elegíveis e não elegíveis.

O protocolo deverá definir como lidar com:

- população mista;
- faixa etária parcialmente sobreposta;
- múltiplas doenças;
- subgrupos;
- dados agregados impossíveis de separar.

Possibilidades incluem:

1. incluir apenas dados do subgrupo elegível quando disponíveis;
2. incluir o estudo integralmente se regra previamente definida permitir;
3. solicitar informação adicional;
4. classificar como indeterminado;
5. excluir quando a população relevante não puder ser isolada e a mistura comprometer a pergunta.

Regras arbitrárias pós-hoc deverão ser evitadas.

---

## 9. Intervenções e exposições parcialmente elegíveis

Quando um estudo combina múltiplas intervenções ou exposições:

- verificar se o componente de interesse pode ser isolado;
- verificar se os grupos são comparáveis;
- registrar cointervenções;
- evitar atribuir ao componente de interesse efeito que não possa ser separado do restante da intervenção.

---

## 10. Comparadores

A elegibilidade do comparador deverá ser explicitada quando necessária.

Exemplos:

- placebo;
- nenhuma intervenção;
- cuidado usual;
- comparador ativo;
- exposição menor;
- população de referência.

“Cuidado usual” deverá ser interpretado considerando contexto e período do estudo.

---

## 11. Desfechos como critério de elegibilidade

Como regra geral para perguntas de intervenção:

> **a ausência de relato de um desfecho de interesse não deverá, isoladamente, tornar um estudo inelegível.**

Isso reduz risco de seleção condicionada ao relato dos resultados.

Um desfecho poderá constituir critério de elegibilidade apenas quando:

- a própria pergunta depende da ocorrência ou mensuração daquele desfecho;
- a finalidade específica da intervenção está definida pelo desfecho;
- houver justificativa metodológica explícita.

Se um estudo elegível não apresenta dados utilizáveis para um desfecho crítico, ele poderá permanecer incluído no corpo de estudos, com registro de ausência de dados.

---

## 12. Desenho do estudo

Critérios de desenho deverão preferencialmente descrever **características metodológicas**, e não depender apenas do rótulo usado pelos autores.

Exemplo:

em vez de aceitar automaticamente qualquer publicação intitulada “cohort study”, o OES deverá verificar características relevantes do desenho.

Quando múltiplos desenhos forem elegíveis, o protocolo deverá definir:

- quais serão aceitos;
- se serão analisados separadamente;
- se existe ordem de preferência;
- como serão integrados.

---

## 13. Tipos de publicação

O OES deverá distinguir elegibilidade científica de formato de publicação.

Por padrão, não se presumirá que apenas artigo completo revisado por pares pode informar uma investigação.

Podem ser relevantes:

- artigos completos;
- preprints;
- resumos de congresso;
- protocolos;
- registros de ensaios;
- relatórios regulatórios;
- teses;
- documentos governamentais.

Entretanto, cada tipo deverá permanecer identificado e seu papel metodológico será avaliado posteriormente.

---

## 14. Idioma

Idioma só deverá ser usado como critério de exclusão quando houver justificativa operacional e metodológica explícita.

A existência de capacidade de tradução assistida reduz a necessidade de exclusão automática por idioma.

Restrições linguísticas deverão ser registradas como limitação quando puderem afetar a cobertura.

---

## 15. Período

Limites temporais deverão derivar de justificativa científica, histórica ou de atualização.

Exemplos:

- tecnologia inexistente antes de determinada data;
- continuação de revisão anterior;
- mudança regulatória que torna estudos mais antigos não comparáveis.

Não usar corte temporal apenas para reduzir carga de triagem sem reconhecer a limitação.

---

# PARTE II — PILOTAGEM E CALIBRAÇÃO

## 16. Pilotagem

Antes de seleção em escala, critérios deverão ser testados em amostra deliberadamente heterogênea de registros.

A amostra deverá, quando possível, conter:

- casos claramente elegíveis;
- casos claramente inelegíveis;
- casos limítrofes;
- múltiplos desenhos;
- exemplos com informação incompleta.

Objetivos:

- detectar ambiguidade;
- treinar revisores;
- padronizar interpretação;
- aperfeiçoar formulários;
- reduzir divergências posteriores.

---

## 17. Alterações durante a pilotagem

Critérios podem ser clarificados antes da triagem definitiva.

Toda alteração substantiva deverá ser registrada no protocolo ou log de desvios.

Depois que os revisores tiverem conhecimento amplo dos resultados dos estudos, mudanças de elegibilidade exigirão escrutínio adicional para evitar decisão orientada pelo efeito observado.

---

# PARTE III — TRIAGEM DE TÍTULO E RESUMO

## 18. Objetivo

A primeira triagem não existe para provar inelegibilidade com máxima certeza.

Seu objetivo é remover registros claramente irrelevantes e preservar sensibilidade.

Regra operacional:

> **na dúvida, avançar para texto completo.**

---

## 19. Decisões permitidas

Na triagem inicial:

- POTENTIAL / avançar;
- EXCLUDE / claramente inelegível;
- UNCERTAIN / avançar.

UNCERTAIN será operacionalmente tratado como potencialmente elegível.

---

## 20. Informação insuficiente

Ausência de resumo, resumo incompleto ou terminologia ambígua não deverão gerar exclusão automática quando título e metadados indicarem possível elegibilidade.

---

# PARTE IV — RECUPERAÇÃO DE TEXTO COMPLETO

## 21. Recuperação

Todo registro potencialmente elegível deverá, quando o nível exigir avaliação formal, ter seu relatório completo recuperado.

Fontes de recuperação podem incluir:

- periódico;
- repositório institucional;
- PubMed Central;
- preprint;
- registro do estudo;
- página do patrocinador;
- contato com autores;
- outras fontes legítimas.

---

## 22. Relatórios não recuperados

Se um relatório potencialmente elegível não puder ser obtido:

- não será classificado automaticamente como excluído;
- será registrado como **REPORT-NOT-RETRIEVED**;
- tentativas de obtenção relevantes serão documentadas;
- o possível impacto será considerado como limitação.

PRISMA distingue relatórios não recuperados de relatórios avaliados e excluídos.

---

# PARTE V — TRIAGEM DE TEXTO COMPLETO

## 23. Decisão final

A avaliação de texto completo deverá aplicar os critérios pré-especificados.

Estados possíveis:

- Include;
- Exclude;
- Awaiting classification;
- Ongoing;
- Linked report.

---

## 24. Hierarquia de motivos de exclusão

Cada exclusão após texto completo deverá receber **um motivo primário**.

Uma hierarquia deverá ser definida antes ou durante a pilotagem.

Exemplo preliminar:

1. população inelegível;
2. condição/fenômeno inelegível;
3. intervenção/exposição/teste inelegível;
4. comparador inelegível;
5. desenho inelegível;
6. contexto inelegível;
7. período/follow-up inelegível;
8. tipo de documento inelegível;
9. desfecho inelegível — somente quando desfecho for legitimamente critério;
10. outra razão protocolar específica.

A ordem poderá variar conforme a investigação.

O primeiro critério inelegível, segundo a hierarquia estabelecida, poderá ser registrado como motivo primário.

---

## 25. Motivos que não devem ser usados indevidamente

Evitar como justificativas genéricas:

- “não relevante”;
- “qualidade ruim”, antes da etapa formal de risco de viés, salvo se o protocolo explicitamente usar qualidade como critério;
- “resultado não significativo”;
- “efeito pequeno”;
- “não confirma hipótese”;
- “dados não utilizáveis”, quando o estudo permanece cientificamente elegível;
- “sem acesso”, que deverá ser classificado como não recuperado.

---

## 26. Estudos sem dados utilizáveis

Um estudo pode satisfazer critérios de elegibilidade e ainda:

- não reportar o desfecho crítico;
- reportar dados insuficientes;
- apresentar resultado em formato não combinável;
- exigir esclarecimento do autor.

Nesses casos, elegibilidade e utilizabilidade dos dados deverão permanecer separadas.

> **Elegível sem dado utilizável não é sinônimo de excluído.**

---

# PARTE VI — MÚLTIPLOS RELATÓRIOS E STUDY ID

## 27. Vinculação de relatórios

Antes da contagem final de estudos, relatórios deverão ser avaliados quanto à possibilidade de pertencerem à mesma investigação.

Sinais de vinculação:

- mesmo identificador de registro;
- autores;
- centros;
- período de recrutamento;
- tamanho amostral;
- intervenção;
- características basais;
- patrocinador;
- acrônimo do estudo.

---

## 28. Study ID

Quando houver correspondência suficiente:

**OES-ST-AAAA-NNNN**

será atribuído ao estudo.

Todos os relatórios relacionados serão vinculados ao mesmo Study ID.

Nenhum relatório secundário será descartado simplesmente por não ser a publicação principal; ele pode conter informação necessária sobre métodos, segurança, follow-up ou subgrupos.

---

## 29. Relatório principal

O OES poderá identificar um relatório como principal para determinados dados, mas isso não tornará os demais relatórios “estudos duplicados”.

A escolha da fonte para cada variável ou resultado deverá ser justificável.

---

# PARTE VII — DISCORDÂNCIAS E ADJUDICAÇÃO

## 30. Independência

Quando dois revisores forem exigidos, suas decisões iniciais deverão ser registradas antes de consenso.

A segunda avaliação não deverá ser simplesmente uma confirmação visível da decisão do primeiro quando o protocolo exigir independência.

---

## 31. Resolução

Fluxo preferencial:

**Revisor A + Revisor B**

↓

discordância

↓

discussão baseada no protocolo

↓

consenso

ou, se persistir:

↓

**Revisor C / adjudicador**

A decisão final e, quando relevante, o motivo da divergência deverão permanecer rastreáveis.

---

## 32. Alteração silenciosa proibida

Sistemas de software ou IA não deverão substituir automaticamente uma decisão divergente sem registro.

A decisão adjudicada não apagará o histórico das avaliações anteriores.

---

# PARTE VIII — REGRAS PROPORCIONAIS N0–N4

## 33. N0 — Evidence Scan

Objetivo:

- exploração;
- reconhecimento de campo;
- descoberta de sínteses e estudos-chave.

Não exige processo formal completo de elegibilidade.

Requisitos mínimos:

- critérios exploratórios registrados;
- evitar apresentar seleção como exaustiva;
- identificar natureza não sistemática da triagem.

IA poderá exercer papel amplo de priorização e descoberta.

---

## 34. N1 — Resposta de Evidência

Seleção orientada para as melhores fontes disponíveis.

Requisitos:

- pergunta focal;
- critérios de relevância explícitos;
- registro das principais fontes selecionadas;
- explicitação de que a busca/seleção não pretende exaustividade.

Não exige diagrama PRISMA completo.

Quando uma fonte for decisiva para a conclusão, sua elegibilidade e aplicabilidade deverão ser verificadas.

---

## 35. N2 — Ficha de Evidência

Processo formal e reproduzível.

### Título/resumo

Padrão inicial:

- um revisor realiza triagem completa;
- todos os casos incertos avançam;
- exclusões devem receber verificação adicional proporcional à criticidade e ao volume;
- em temas de maior criticidade, preferir verificação de todas as exclusões ou dupla triagem.

### Texto completo

Padrão inicial:

- decisão primária por um revisor;
- verificação por segundo revisor de todos os estudos incluídos e de todas as exclusões materialmente relevantes;
- divergências resolvidas por consenso ou adjudicação.

### Registro

- critérios;
- fluxo;
- números;
- motivos de exclusão em texto completo;
- lista de estudos incluídos;
- relatórios vinculados.

---

## 36. N3 — Síntese Rápida

A seleção deverá utilizar abordagem abreviada explicitamente definida.

Padrão operacional candidato:

### Pilotagem

- todos os revisores avaliam amostra comum.

### Título/resumo

- pelo menos uma proporção inicial é triada por dois revisores independentemente;
- acordo é avaliado;
- se o acordo for alto e o tema permitir, o restante poderá ser triado por um revisor;
- se o acordo for inadequado, a dupla triagem deverá ser ampliada.

Como referência inicial, a orientação Cochrane para revisões rápidas sugere cerca de 20% dos registros para dupla triagem e admite progressão para triagem simples quando o acordo é bom, usando κ ≥0,8 como exemplo. Esse valor é operacional e não deve ser tratado como limiar cientificamente universal.

### Texto completo

Aplicar lógica semelhante.

Quando recursos permitirem:

- segundo revisor deverá verificar todas as exclusões de texto completo.

### Regras

Toda simplificação deverá ser:

- pré-especificada;
- relatada;
- considerada na interpretação das limitações.

---

## 37. N4 — Revisão Sistemática / Síntese Aprofundada

Padrão de seleção de maior rigor do OES.

### Título/resumo

Preferência por:

- dois revisores independentes em todos os registros.

Exceções deverão ser justificadas no protocolo.

### Texto completo

Obrigatório:

- pelo menos dois revisores;
- avaliação independente;
- processo pré-definido de resolução de discordâncias.

### Adicionalmente

- pilotagem formal;
- motivos de exclusão;
- contagem PRISMA;
- vinculação de múltiplos relatórios;
- identificação de estudos em andamento;
- estudos aguardando classificação;
- relatórios não recuperados;
- trilha de adjudicação.

---

## 38. Matriz de seleção por nível

| Elemento | N0 | N1 | N2 | N3 | N4 |
|---|---|---|---|---|---|
| Critérios explícitos | exploratórios | sim | sim | sim | sim |
| Protocolo prévio | não obrigatório | simplificado | esperado | obrigatório | obrigatório |
| Pilotagem | opcional | opcional | recomendada | obrigatória | obrigatória |
| Título/resumo duplo | não | não | conforme criticidade | parcial/calibrado | preferencialmente integral |
| Full text com segundo revisor | não | seletivo | verificação estruturada | parcial/calibrado + verificação | independente obrigatório |
| Motivo de exclusão full text | não | seletivo | sim | sim | sim |
| PRISMA | não | não | adaptado quando útil | recomendado | obrigatório quando aplicável |
| Study ID / linkage | seletivo | quando necessário | sim | sim | sim |
| Registro de adjudicação | não | seletivo | sim | sim | sim |

---

# PARTE IX — IA E AUTOMAÇÃO NA TRIAGEM

## 39. Funções permitidas

IA e algoritmos poderão auxiliar em:

- priorização de registros;
- classificação preliminar;
- identificação de duplicatas;
- extração de PICO;
- identificação de provável desenho;
- sugestão de motivo de exclusão;
- agrupamento semântico;
- vinculação de relatórios;
- detecção de possíveis estudos relacionados.

---

## 40. Priorização não é exclusão

O sistema poderá reordenar registros para que os mais prováveis de serem relevantes apareçam primeiro.

Entretanto:

> **classificar um registro como baixa probabilidade não equivale a autorização automática para excluí-lo.**

---

## 41. Exclusão automatizada

Na fase inicial do OES:

### N0

Permitida como auxílio exploratório quando não houver alegação de completude.

### N1

Pode ser utilizada para organização e priorização, mas fontes decisivas deverão ser verificadas.

### N2

Não haverá exclusão silenciosa puramente automatizada de registros potencialmente elegíveis.

### N3

Automação poderá reduzir carga de trabalho apenas dentro de abordagem previamente definida, validada e com controle humano compatível.

### N4

Automação poderá priorizar e assistir, mas exclusão automática sem processo de validação especificamente aprovado não será padrão do OES.

Essa política é deliberadamente conservadora enquanto o próprio OES não validar seu pipeline automatizado.

---

## 42. Transparência da automação

Sempre que automação afetar seleção formal, registrar:

- ferramenta/modelo;
- versão, quando disponível;
- função desempenhada;
- etapa;
- número de registros afetados;
- intervenção humana;
- regra de parada, quando houver;
- método de validação.

PRISMA 2020 recomenda que ferramentas automatizadas usadas na seleção sejam explicitamente descritas e que, quando aplicável, se reporte quantos registros foram excluídos por humanos e quantos por automação.

---

## 43. Regra de parada em active learning

O OES não adotará inicialmente uma regra universal segundo a qual o sistema possa encerrar a triagem porque “provavelmente não restam estudos relevantes”.

Qualquer stopping rule automática em N2–N4 exigirá:

- validação prévia;
- desempenho documentado;
- tolerância de erro definida;
- adequação ao tipo de pergunta;
- aprovação metodológica específica.

---

# PARTE X — FLUXO PRISMA E RASTREABILIDADE

## 44. Contagens essenciais

Quando aplicável, o OES deverá registrar separadamente:

- registros identificados;
- duplicatas/removidos antes da triagem;
- registros triados;
- registros excluídos na triagem;
- relatórios buscados para recuperação;
- relatórios não recuperados;
- relatórios avaliados em texto completo;
- relatórios excluídos e motivos;
- estudos incluídos;
- relatórios correspondentes aos estudos incluídos;
- estudos em andamento;
- estudos aguardando classificação.

---

## 45. PRISMA

N3 e N4 deverão utilizar fluxo PRISMA ou adaptação apropriada ao tipo de revisão.

N2 poderá utilizar fluxo simplificado ou completo quando a complexidade justificar.

O diagrama é um instrumento de transparência, não um substituto para o registro de decisão no nível de cada relatório/estudo.

---

# PARTE XI — REGISTRO OPERACIONAL

## 46. Screening Record

Cada avaliação formal deverá poder registrar:

- Record ID;
- Report ID, quando disponível;
- Study ID, quando conhecido;
- Investigation ID;
- etapa;
- revisor;
- decisão;
- motivo;
- data;
- observações;
- confiança/flag de incerteza, quando usado operacionalmente;
- decisão final;
- adjudicador, quando aplicável.

---

## 47. Identificadores candidatos

### Record ID

**OES-RC-AAAA-NNNNNN**

Identifica um registro recuperado.

### Report ID

**OES-RP-AAAA-NNNNNN**

Identifica um documento/relatório específico.

### Study ID

**OES-ST-AAAA-NNNN**

Identifica a unidade científica.

Esses identificadores são provisórios até o fechamento do modelo de dados.

---

## 48. Histórico de decisão

Quando uma decisão mudar:

- manter avaliação anterior;
- registrar nova avaliação;
- registrar motivo;
- registrar responsável;
- preservar a decisão final separadamente.

A rastreabilidade não deverá depender apenas do estado final.

---

# PARTE XII — SITUAÇÕES ESPECIAIS

## 49. Estudos aguardando classificação

Usar quando:

- informação metodológica é insuficiente;
- população não pode ser confirmada;
- desenho é incerto;
- estudo possui registro mas resultado/publicação ainda não permite decisão;
- contato com autores está pendente.

Esses estudos não serão tratados como excluídos.

---

## 50. Estudos em andamento

Ensaios ou estudos identificados como em andamento deverão permanecer vinculados à investigação para facilitar atualização.

Em M2/M3, poderão alimentar monitoramento futuro.

---

## 51. Retratações e correções

Quando um relatório tiver:

- retratação;
- expressão de preocupação;
- correção material;
- versão substitutiva;

o status deverá ser identificado antes da síntese.

Retratação não será tratada apenas como “exclusão por irrelevância”; o vínculo histórico deve ser preservado para auditoria.

---

## 52. Publicações secundárias

Análises secundárias, follow-ups e estudos de subgrupos poderão:

- fornecer dados adicionais;
- contribuir para risco de viés;
- esclarecer métodos;
- informar segurança.

Deverão ser vinculados ao estudo original sempre que apropriado.

---

## 53. Revisões sistemáticas como unidade de evidência

Quando o produto for overview/umbrella review, a unidade elegível poderá ser a própria revisão sistemática.

Nesse caso, a seleção seguirá critérios específicos de:

- correspondência com a pergunta;
- tipo de revisão;
- atualidade;
- escopo;
- métodos;
- população/intervenção/desfechos.

O risco de sobreposição entre revisões deverá ser tratado separadamente.

---

# PARTE XIII — CONTROLE DE QUALIDADE

## 54. Auditoria mínima

Antes de encerrar a seleção N2–N4, verificar:

- critérios aplicados conforme protocolo;
- registros duplicados não contados como estudos;
- textos completos recuperados quando possível;
- motivos de exclusão consistentes;
- casos incertos resolvidos ou classificados;
- múltiplos relatórios vinculados;
- estudos em andamento identificados;
- contagens coerentes;
- decisões da IA identificadas;
- discordâncias resolvidas;
- desvios de protocolo documentados.

---

## 55. Consistência das contagens

As seguintes contagens deverão ser conciliáveis:

**registros**

≠

**relatórios**

≠

**estudos.**

O sistema deverá detectar inconsistências como:

- mais estudos incluídos do que relatórios;
- registro duplicado contado duas vezes;
- relatório excluído e simultaneamente vinculado a estudo incluído sem justificativa;
- estudo incluído sem nenhum relatório ou fonte identificável.

---

# PARTE XIV — DESVIOS DO PROTOCOLO

## 56. Mudança de elegibilidade

Quando houver necessidade de alterar critérios durante uma investigação:

registrar:

- critério original;
- novo critério;
- data;
- motivo;
- fase em que ocorreu;
- impacto sobre registros já avaliados;
- necessidade de retriagem.

Se a alteração for motivada pelo conhecimento dos resultados, deverá ser tratada como risco metodológico grave e explicitamente declarada.

---

## 57. Retriagem

Alterações de critério poderão exigir:

- retriagem integral;
- retriagem de subconjunto afetado;
- nenhuma retriagem, quando a mudança for apenas clarificação sem efeito prático.

A decisão deverá ser justificada.

---

# PARTE XV — RELAÇÃO COM AS ETAPAS POSTERIORES

## 58. Elegibilidade não é qualidade

Um estudo elegível pode apresentar alto risco de viés.

Portanto:

> **estudo elegível não significa estudo confiável.**

A avaliação de risco de viés ocorrerá no Documento 12.

---

## 59. Elegibilidade não é contribuição à síntese

Um estudo pode ser elegível para a revisão, mas não contribuir para determinada meta-análise ou síntese específica.

A decisão de quais estudos contribuem para cada síntese dependerá da compatibilidade entre:

- população;
- intervenção/exposição;
- comparador;
- desfecho;
- tempo;
- medida;
- desenho.

Essa etapa será formalizada no protocolo de síntese.

---

## 60. Elegibilidade não é certeza

A certeza/confiança na conclusão será avaliada no nível do corpo de evidências, em etapa posterior.

---

# PARTE XVI — DECISÕES CONSOLIDADAS

## 61. Regras adotadas

Ficam estabelecidas, provisoriamente, as seguintes regras:

1. elegibilidade será pré-especificada para investigações formais;
2. mudanças de critérios exigem justificativa e versionamento;
3. registros, relatórios e estudos são entidades distintas;
4. múltiplos relatórios do mesmo estudo serão vinculados;
5. triagem inicial deverá privilegiar sensibilidade;
6. dúvida em título/resumo favorece avanço;
7. relatório não recuperado não equivale a estudo excluído;
8. motivos de exclusão em texto completo serão explícitos;
9. ausência de dados utilizáveis não implica inelegibilidade;
10. outcomes raramente serão critério de elegibilidade em revisões de intervenção;
11. discordâncias serão preservadas e adjudicadas;
12. N0–N4 terão controles proporcionais;
13. N4 exigirá dois revisores independentes para decisão final de texto completo;
14. N3 poderá utilizar triagem abreviada calibrada e explicitamente documentada;
15. automação poderá priorizar, mas não terá autorização geral para exclusão silenciosa em N2–N4;
16. qualquer automação material deverá ser documentada;
17. PRISMA será usado quando apropriado para representar o fluxo;
18. a unidade final da seleção será, sempre que aplicável, o estudo e não a publicação.

---

## 62. Arquitetura após esta etapa

O pipeline metodológico do OES passa a ter:

**00–03 — Concepção, taxonomia, níveis e roteamento**

↓

**10 — Busca e Recuperação**

↓

**11 — Elegibilidade, Triagem e Seleção**

↓

**12 — Avaliação de Risco de Viés**

↓

**13 — Extração de Dados**

↓

**14 — Síntese de Evidências**

↓

**15 — Certeza/Confiança**

---

## 63. Próxima etapa

**12 — Protocolo de Avaliação de Risco de Viés e Qualidade Metodológica**

Deverá definir:

- distinção entre risco de viés, qualidade de relato e certeza da evidência;
- seleção de instrumentos por desenho;
- RoB 2;
- ROBINS-I;
- ROBINS-E;
- QUADAS-3;
- QUIPS;
- PROBAST+AI;
- instrumentos para prevalência e qualitativos;
- avaliação de revisões sistemáticas;
- regras de dupla avaliação;
- discordâncias;
- automação/IA;
- uso ou não de scores agregados;
- impacto do risco de viés sobre síntese e certeza.

## Referenciais principais

- Cochrane Handbook — Chapter 3: https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-03
- Cochrane Handbook — Chapter 4: https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-04
- Cochrane MECIR — Selecting studies: https://www.cochrane.org/authors/handbooks-and-manuals/mecir-manual
- Cochrane Rapid Reviews Methods: https://methods.cochrane.org/rapidreviews/
- Garritty et al. Updated recommendations for Cochrane rapid review methods guidance. BMJ 2024;384:e076335.
- PRISMA 2020: https://www.prisma-statement.org/prisma-2020
- JBI Manual for Evidence Synthesis: https://synthesismanual.jbi.global/
