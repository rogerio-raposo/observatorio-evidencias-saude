# 14 — Protocolo de Síntese de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — em desenvolvimento  
**Data de consolidação inicial:** 3 de outubro de 2026

## 1. Finalidade

Este protocolo define como o OES transformará resultados extraídos em sínteses quantitativas, qualitativas ou estruturadas, preservando coerência clínica, validade metodológica, transparência e rastreabilidade.

A síntese não terá como objetivo produzir obrigatoriamente uma estimativa combinada.

> **A forma de síntese deverá representar adequadamente o corpo de evidências sem criar comparabilidade, precisão ou consenso artificiais.**

O OES poderá utilizar, conforme a pergunta:

- meta-análise;
- síntese sem meta-análise;
- síntese de acurácia diagnóstica;
- síntese prognóstica;
- síntese de modelos de predição;
- network meta-analysis;
- síntese qualitativa;
- integração de métodos mistos;
- apresentação estruturada sem síntese combinada.

---

# PARTE I — PRINCÍPIOS

## 2. Síntese não é sinônimo de meta-análise

Meta-análise somente será utilizada quando:

- os estudos responderem a uma questão suficientemente semelhante;
- as estimativas forem conceitualmente comparáveis;
- diferenças de população, intervenção/exposição, comparador, desfecho, tempo e desenho não tornarem o efeito combinado enganoso;
- houver método estatístico apropriado;
- a interpretação da estimativa combinada for cientificamente defensável.

A existência de números matematicamente combináveis não obriga sua combinação.

## 3. Unidade da síntese

Toda síntese deverá definir explicitamente sua unidade analítica.

Estrutura conceitual preferencial:

**Population + Intervention/Exposure + Comparator + Outcome + Timepoint + Analysis/Estimand**

Quando a combinação mudar de forma relevante, uma nova síntese deverá ser criada.

## 4. Synthesis ID

Identificador provisório:

**OES-SY-AAAA-NNNNNN**

Cada síntese deverá registrar:

- Investigation ID;
- Result IDs;
- Study IDs;
- pergunta/subpergunta;
- desfecho;
- timepoint;
- métrica;
- método;
- modelo estatístico, se aplicável;
- software/versão;
- parâmetros/código;
- Risk of Bias Records relacionados;
- análises de sensibilidade;
- data e versão.

## 5. Pré-especificação

N3 e N4 deverão possuir plano de síntese pré-especificado, incluindo, quando pertinente:

- agrupamentos;
- comparações;
- desfechos;
- timepoints;
- medidas de efeito;
- modelo;
- tratamento de múltiplos braços;
- dados correlacionados;
- eventos raros;
- subgrupos;
- meta-regressão;
- análises de sensibilidade;
- critérios de não combinação;
- síntese sem meta-análise;
- integração de risco de viés;
- missing evidence/small-study effects.

Mudanças pós-hoc deverão ser declaradas.

---

# PARTE II — COMBINABILIDADE

## 6. Avaliação prévia

Antes de qualquer combinação, avaliar:

### Similaridade clínica

- população;
- condição e gravidade;
- intervenção/exposição;
- dose/intensidade;
- comparador;
- contexto;
- seguimento.

### Similaridade de desfecho

- constructo;
- definição;
- instrumento;
- escala;
- limiar;
- direção;
- tempo.

### Similaridade metodológica

- desenho;
- estimando;
- análise ajustada/não ajustada;
- unidade de análise;
- risco de viés.

### Compatibilidade estatística

- medida de efeito;
- variância;
- independência;
- distribuição;
- correlação.

## 7. Decisão de combinabilidade

Não haverá score universal.

Possíveis decisões:

- combinar diretamente;
- transformar/harmonizar e combinar;
- combinar em subgrupos;
- apresentar separadamente;
- sintetizar sem meta-análise;
- não sintetizar.

Toda decisão material deverá ser justificada.

## 8. Agrupamentos pós-hoc

Agrupamentos criados após inspeção dos resultados deverão ser identificados como pós-hoc.

Não se reorganizarão estudos silenciosamente para reduzir heterogeneidade ou produzir significância.

---

# PARTE III — MEDIDAS DE EFEITO

## 9. Regra geral

A medida deverá refletir o tipo de dado e a pergunta clínica.

Sempre que útil, efeitos relativos e absolutos deverão ser apresentados de forma complementar.

## 10. Dicotômicos

Medidas candidatas:

- Risk Ratio;
- Odds Ratio;
- Risk Difference;
- Hazard Ratio, quando apropriado.

A escolha dependerá de incidência, desenho, estabilidade e interpretabilidade.

## 11. Contínuos

### Mean Difference

Preferida quando a mesma escala/unidade é utilizada.

### Standardized Mean Difference

Pode ser usada quando estudos medem o mesmo constructo com escalas diferentes.

SMD não será utilizada para mascarar diferenças conceituais entre instrumentos.

## 12. Tempo até evento

Hazard ratios poderão ser combinados quando representarem estimandos suficientemente comparáveis.

Estimativas derivadas de curvas permanecerão identificadas como derivadas.

## 13. Taxas e person-time

Quando apropriado, poderão ser utilizadas medidas como rate ratio ou incidence rate.

Unidade temporal e denominador serão explicitados.

## 14. Conversões

Conversões só serão realizadas quando justificadas e reproduzíveis.

O OES preservará:

- valor original;
- fórmula/método;
- pressupostos;
- valor derivado.

---

# PARTE IV — MODELOS DE META-ANÁLISE

## 15. Common/fixed-effect

Será utilizado quando o alvo inferencial for compatível com um efeito comum segundo o modelo adotado.

O uso do modelo não elimina a obrigação de investigar heterogeneidade.

## 16. Random-effects

Será utilizado quando for plausível que os efeitos verdadeiros variem entre estudos.

A interpretação deverá considerar:

- efeito médio;
- intervalo de confiança;
- tau/tau²;
- heterogeneidade;
- intervalo de predição, quando apropriado.

## 17. Escolha do modelo

A escolha entre common/fixed-effect e random-effects:

- **não será baseada apenas em teste Q**;
- **não será baseada em corte de I²**;
- deverá refletir o alvo inferencial e o modelo plausível de variação entre estudos.

O protocolo poderá prever modelos alternativos em análise de sensibilidade.

## 18. Estimador de heterogeneidade

O estimador de tau² deverá ser registrado.

Métodos contemporâneos, como REML, poderão ser considerados quando apropriados.

Não haverá escolha automática apenas porque determinado estimador é default do software.

## 19. Intervalo de predição

Em random-effects, o OES considerará intervalos de predição quando o número de estudos e os pressupostos permitirem.

Cautelas:

- poucos estudos;
- assimetria;
- distribuição inadequada;
- interpretação contextual.

---

# PARTE V — HETEROGENEIDADE

## 20. Tipos

Distinguir:

- heterogeneidade clínica;
- heterogeneidade metodológica;
- heterogeneidade estatística.

A última deverá ser interpretada à luz das duas primeiras.

## 21. I²

I² poderá ser reportado, mas não será:

- teste de existência de heterogeneidade;
- medida direta de importância clínica;
- regra para escolher modelo;
- regra automática para interromper meta-análise.

## 22. Tau² e tau

Serão considerados particularmente em random-effects por expressarem variabilidade entre efeitos na escala da análise.

## 23. Teste Q

Poderá ser reportado, reconhecendo sua limitada utilidade isolada.

Não será critério único de decisão.

---

# PARTE VI — EXPLORAÇÃO DE HETEROGENEIDADE

## 24. Subgrupos

Subgrupos deverão ser:

- clinicamente plausíveis;
- preferencialmente pré-especificados;
- limitados em número;
- comparados por teste de interação quando possível.

> **Diferença de significância entre subgrupos não demonstra diferença entre subgrupos.**

## 25. Subgrupos pós-hoc

Serão interpretados como exploratórios e geradores de hipótese.

## 26. Meta-regressão

Poderá ser usada para investigar relação entre características de estudos e efeitos.

Como regra de prudência, não será rotina quando houver menos de aproximadamente 10 estudos por covariável, salvo justificativa especializada.

Esse valor não é um limiar absoluto.

---

# PARTE VII — ANÁLISES DE SENSIBILIDADE

## 27. Finalidade

Testar robustez diante de decisões plausíveis.

Exemplos:

- exclusão de alto risco de viés;
- modelo alternativo;
- estimador alternativo de tau²;
- imputações;
- resultados derivados;
- eventos raros;
- timepoints alternativos;
- estudos influentes.

## 28. Regra

Sensibilidade não será utilizada para escolher retrospectivamente a análise que produza a conclusão desejada.

A análise principal deverá permanecer identificada.

---

# PARTE VIII — RISCO DE VIÉS NA SÍNTESE

## 29. Integração

Cada síntese deverá identificar o perfil de risco de viés dos estudos contribuintes.

Possibilidades:

- todos os estudos;
- análise restrita pré-especificada;
- estratificação;
- sensibilidade;
- interpretação diferenciada.

## 30. Peso estatístico não é credibilidade

Um estudo pode ter grande peso estatístico e alto risco de viés.

A interpretação deverá considerar ambos separadamente.

## 31. Exclusão

Alto risco de viés não implicará exclusão automática.

Qualquer exclusão metodológica deverá ser pré-especificada e justificada.

---

# PARTE IX — MISSING EVIDENCE E SMALL-STUDY EFFECTS

## 32. Separação conceitual

Distinguir:

- risco de viés interno;
- missing evidence;
- small-study effects.

## 33. Funnel plots

Funnel plot será ferramenta exploratória.

Assimetria não será interpretada automaticamente como publication bias.

Possíveis causas incluem:

- missing evidence;
- heterogeneidade verdadeira;
- diferenças metodológicas;
- artefatos matemáticos.

## 34. Testes de assimetria

Como regra, testes não serão utilizados com menos de aproximadamente 10 estudos.

O teste deverá ser apropriado à medida de efeito.

Não se aplicará Egger automaticamente a qualquer análise.

## 35. ROB-ME

Quando apropriado, ROB-ME ou método específico de missing evidence poderá ser utilizado.

A integração com certeza será formalizada no Documento 15.

---

# PARTE X — EVENTOS RAROS

## 36. Regra geral

Não haverá método universal para eventos raros.

Considerar:

- frequência;
- balanceamento;
- zero events em um ou ambos os braços;
- medida de efeito;
- número de estudos;
- pressupostos.

## 37. Correções de continuidade

Não serão aplicadas mecanicamente.

Método e impacto deverão ser documentados.

## 38. Peto

Pode ser considerado em situações específicas, mas não será padrão universal.

---

# PARTE XI — MÚLTIPLOS BRAÇOS E DEPENDÊNCIA

## 39. Multi-arm

Evitar dupla contagem.

Possíveis abordagens:

- combinar braços;
- selecionar comparação segundo protocolo;
- dividir grupo compartilhado quando apropriado;
- modelar correlação;
- usar NMA.

## 40. Resultados correlacionados

Não tratar como independentes múltiplas estimativas provenientes dos mesmos participantes.

Métodos possíveis:

- regra de seleção;
- combinação;
- modelos multivariados;
- robust variance estimation;
- métodos hierárquicos.

## 41. Cluster, crossover e medidas repetidas

Estruturas de correlação específicas deverão ser respeitadas.

Quando necessário, corrigir:

- clustering;
- pareamento;
- medidas repetidas;
- efeitos de período/carry-over.

---

# PARTE XII — NETWORK META-ANALYSIS

## 42. Indicação

NMA poderá ser considerada quando:

- existirem três ou mais intervenções;
- a rede for conectada;
- transitivity for plausível;
- houver capacidade estatística adequada.

## 43. Assumptions

Avaliar:

- transitivity;
- coherence/inconsistency;
- modificadores de efeito;
- geometria da rede;
- risco de viés;
- sparsity.

## 44. Rankings

Rankings não serão interpretados isoladamente.

Sua leitura deverá considerar:

- magnitude;
- incerteza;
- risco de viés;
- coerência;
- certeza da evidência.

---

# PARTE XIII — SÍNTESE SEM META-ANÁLISE

## 45. Indicações

Quando:

- medidas não forem harmonizáveis;
- dados forem incompletos;
- heterogeneidade tornar média enganosa;
- desenhos forem incompatíveis;
- síntese quantitativa apropriada não for possível.

## 46. “Narrative synthesis” não basta

O OES deverá especificar:

- agrupamento;
- métrica;
- método;
- direção e magnitude;
- risco de viés;
- apresentação.

## 47. SWiM

SWiM será referência de transparência para síntese quantitativa sem meta-análise.

É guideline de relato e não substitui método de condução.

## 48. Vote counting

Vote counting baseado apenas em significância estatística será evitado.

Quando direção de efeito for utilizada, suas limitações deverão ser explícitas.

---

# PARTE XIV — SÍNTESE POR TIPO DE PERGUNTA

## 49. Intervenção

Referências principais:

- Cochrane Handbook Chapters 10–13.

Métodos possíveis:

- pairwise meta-analysis;
- common/random-effects;
- NMA;
- SWiM;
- subgrupos/sensibilidade.

## 50. Diagnóstico

Síntese de acurácia deverá utilizar métodos hierárquicos específicos quando apropriado, preservando a relação entre sensibilidade, especificidade e threshold.

Referência:

**Cochrane Handbook for Systematic Reviews of Diagnostic Test Accuracy, versão 2.0.1 (2026).**

Não se utilizará meta-análise genérica de proporções como substituto automático.

## 51. Prognóstico global

Síntese poderá envolver:

- risco em horizonte temporal;
- incidência cumulativa;
- sobrevida;
- outras medidas prognósticas.

Métodos especializados deverão seguir o Cochrane Prognosis Handbook.

## 52. Fatores prognósticos

Estimativas ajustadas e não ajustadas serão separadas quando representarem estimandos diferentes.

Não se combinarão coeficientes incompatíveis apenas por terem o mesmo nome de fator.

## 53. Modelos de predição

Sínteses poderão abordar separadamente:

- discriminação;
- calibração;
- O:E;
- calibration slope;
- c-statistic/AUC.

Desenvolvimento e validação externa não serão misturados indiscriminadamente.

## 54. Prevalência e incidência

A síntese deverá considerar:

- definição do caso;
- amostragem;
- denominador;
- contexto;
- período;
- distribuição.

Não será fixada, nesta fase, uma transformação universal para proporções.

Métodos especializados JBI/PERSyst serão considerados conforme aplicabilidade.

## 55. Qualitativa

JBI meta-aggregation será abordagem preferencial candidata quando alinhada à pergunta.

Estrutura:

**findings → categories → synthesised findings**

Síntese qualitativa não será reduzida a frequência de temas.

## 56. Mixed methods

Integração deverá ser pré-especificada.

Abordagens como convergent segregated poderão ser utilizadas quando apropriadas.

---

# PARTE XV — APRESENTAÇÃO E INTERPRETAÇÃO

## 57. Forest plots

Quando usados, deverão apresentar:

- estimativas;
- intervalos;
- modelo;
- peso, se aplicável;
- efeito combinado;
- heterogeneidade;
- escala clara.

## 58. Efeitos absolutos

Quando úteis, efeitos absolutos deverão acompanhar efeitos relativos.

O risco basal utilizado deverá ser registrado.

## 59. Linguagem

Evitar concluir “não houve efeito” apenas porque p > 0,05.

Interpretar:

- estimativa;
- intervalo;
- magnitude;
- benefício/dano compatível;
- heterogeneidade;
- risco de viés.

## 60. Significância estatística

Não será confundida com:

- importância clínica;
- causalidade;
- relevância decisória;
- certeza da evidência.

---

# PARTE XVI — SOFTWARE E REPRODUTIBILIDADE

## 61. Registro

N3–N4 deverão registrar:

- software;
- versão;
- pacote;
- função;
- parâmetros;
- estimador;
- seed, quando relevante;
- script/código;
- data de execução.

## 62. Reprodutibilidade

A síntese deverá ser reconstruível a partir de:

**Data Extraction Records + plano de síntese + código/parâmetros + software/versionamento.**

## 63. Congelamento analítico

N3–N4 deverão possuir dataset logicamente congelado antes da análise principal.

Mudanças posteriores gerarão:

- nova versão;
- nova execução;
- justificativa;
- avaliação de impacto.

---

# PARTE XVII — IA NA SÍNTESE

## 64. Usos permitidos

IA poderá auxiliar em:

- agrupamento preliminar;
- detecção de incompatibilidades;
- geração de código;
- conferência de fórmulas;
- interpretação inicial de outputs;
- tabelas/gráficos;
- documentação.

## 65. Restrições

IA não poderá:

- decidir silenciosamente combinabilidade;
- escolher modelo pelo resultado mais favorável;
- alterar dados;
- omitir heterogeneidade;
- inventar parâmetros;
- produzir estimativa final sem execução reproduzível.

## 66. Código gerado por IA

Deverá ser:

- revisado;
- executado;
- versionado;
- testado;
- mantido junto aos dados e parâmetros.

---

# PARTE XVIII — PROPORCIONALIDADE N0–N4

## 67. N0

Síntese exploratória, sem meta-análise formal.

## 68. N1

Pode adotar criticamente síntese existente ou fazer síntese descritiva estruturada.

Meta-análise nova não é rotina.

## 69. N2

Pode realizar síntese quantitativa simples quando extração, risco de viés e protocolo forem adequados.

Caso contrário, usar síntese existente ou método sem meta-análise.

## 70. N3

Exige:

- plano explícito;
- análise reproduzível;
- simplificações declaradas;
- heterogeneidade proporcional;
- sensibilidade para decisões críticas;
- verificação independente dos resultados materiais.

## 71. N4

Exige:

- plano pré-especificado;
- código reproduzível;
- análise completa de combinabilidade;
- heterogeneidade;
- sensibilidade;
- efeito modificador quando justificado;
- missing evidence;
- métodos especializados;
- revisão estatística quando necessária.

---

# PARTE XIX — CONTROLE DE QUALIDADE

## 72. Auditoria mínima

Antes de concluir uma síntese, verificar:

- pergunta definida;
- estudos corretos;
- ausência de dupla contagem;
- medida apropriada;
- direção harmonizada;
- timepoints coerentes;
- modelo justificado;
- heterogeneidade avaliada;
- risco de viés integrado;
- missing evidence considerado;
- análises pós-hoc identificadas;
- sensibilidade quando necessária;
- software/código documentados;
- resultado reproduzível;
- interpretação não baseada apenas em p-valor.

## 73. Alertas metodológicos futuros

O sistema deverá detectar situações como:

- random-effects escolhido por I²;
- common/fixed-effect escolhido por I²;
- dupla contagem de grupo controle;
- subgrupo interpretado sem interação;
- meta-regressão subdimensionada;
- funnel plot tratado como diagnóstico de publication bias;
- transformação sem proveniência;
- NMA com ranking sem incerteza;
- DTA sintetizada por método inadequado;
- “narrative synthesis” sem método explícito.

---

# PARTE XX — DECISÕES CONSOLIDADAS

## 74. Regras adotadas

1. Síntese não é sinônimo de meta-análise.
2. Combinabilidade será julgada clínica, metodológica e estatisticamente.
3. Não haverá score universal de combinabilidade.
4. Cada síntese terá unidade analítica explícita.
5. A escolha common/fixed-effect versus random-effects não será feita por teste de heterogeneidade ou corte de I².
6. Random-effects será interpretado com heterogeneidade e, quando apropriado, intervalo de predição.
7. I² não será regra automática de decisão.
8. Subgrupos serão preferencialmente pré-especificados e avaliados por interação.
9. Meta-regressão será usada com parcimônia.
10. Sensibilidade testará robustez, não selecionará resultado conveniente.
11. Risco de viés influenciará interpretação e análises.
12. Missing evidence será separado de risco de viés interno.
13. Funnel plot não diagnostica publication bias.
14. Eventos raros exigem método específico.
15. Multi-arm e dependência serão tratados sem dupla contagem.
16. NMA exigirá transitivity e coherence.
17. SWiM será referência para relato de síntese quantitativa sem meta-análise.
18. Vote counting por significância será evitado.
19. Sínteses diagnósticas, prognósticas, de predição, prevalência e qualitativas usarão métodos especializados.
20. JBI meta-aggregation será abordagem preferencial candidata para síntese qualitativa compatível.
21. Efeitos absolutos serão apresentados quando úteis.
22. Significância estatística não será confundida com importância clínica ou certeza.
23. N3–N4 exigirão análise reproduzível e versionada.
24. IA poderá auxiliar, mas não decidirá silenciosamente combinabilidade, modelo ou conclusão.

---

# 75. Próxima etapa

**15 — Protocolo de Avaliação da Certeza/Confiança no Corpo de Evidências**

Deverá definir:

- GRADE para intervenções;
- certeza por desfecho;
- risco de viés;
- inconsistência;
- indirectness;
- imprecisão;
- missing evidence/publication bias;
- fatores de aumento quando aplicáveis;
- diagnóstico;
- prognóstico;
- predição;
- prevalência;
- evidência qualitativa/CERQual;
- network meta-analysis;
- Summary of Findings;
- comunicação da certeza;
- separação entre certeza e recomendação;
- aplicabilidade e Camada Brasil.

## Referenciais principais

- Cochrane Handbook — Chapter 10: https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-10
- Cochrane Handbook — Chapter 11: https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-11
- Cochrane Handbook — Chapter 12: https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-12
- Cochrane Handbook — Chapter 13: https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-13
- SWiM: https://www.bmj.com/content/368/bmj.l6890
- Cochrane DTA Handbook: https://www.cochrane.org/authors/handbooks-and-manuals/handbook-systematic-reviews-diagnostic-test-accuracy
- Cochrane Prognosis Handbook: https://www.cochrane.org/authors/handbooks-and-manuals/cochrane-handbook-systematic-reviews-prognosis-research-and-prediction-models
- JBI Manual: https://synthesismanual.jbi.global/

---

**Fim do Documento 14**
