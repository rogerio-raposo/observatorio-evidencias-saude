# 13 — Protocolo de Extração e Estruturação de Dados

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — em desenvolvimento  
**Data de consolidação inicial:** 3 de outubro de 2026

## 1. Finalidade

Este protocolo define como o Observatório de Evidências em Saúde — OES transformará informações contidas em estudos, relatórios, registros e outras fontes elegíveis em dados estruturados, auditáveis e utilizáveis para síntese.

A extração deverá preservar simultaneamente:

- fidelidade à fonte;
- distinção entre estudo, relatório e resultado;
- proveniência;
- reprodutibilidade;
- controle de erro;
- possibilidade de atualização;
- compatibilidade com síntese quantitativa ou qualitativa;
- proporcionalidade ao nível N0–N4.

O objetivo não é coletar todo dado disponível. O OES deverá extrair o conjunto de dados necessário para responder à pergunta, avaliar a credibilidade da evidência, sustentar a síntese e permitir atualização futura.

---

# PARTE I — PRINCÍPIOS FUNDAMENTAIS

## 2. Extração não é transcrição indiscriminada

A extração é uma etapa analítica controlada.

Ela deve converter informação dispersa em estrutura explícita sem apagar a distinção entre:

1. o que foi diretamente relatado;
2. o que foi calculado pelo OES;
3. o que foi inferido;
4. o que foi obtido por contato externo;
5. o que foi transformado ou normalizado.

Consequentemente:

> **todo dado que sustente resultado, síntese ou conclusão deve ser rastreável até sua origem e até eventuais transformações aplicadas.**

---

## 3. Unidade científica e unidade documental

O OES manterá a distinção já definida no Documento 11.

### Study

Investigação científica subjacente.

### Report

Documento, publicação, registro ou outra fonte que contenha informação sobre o Study.

### Result

Resultado específico associado a uma combinação de elementos como:

- desfecho;
- grupo;
- comparação;
- tempo;
- população analítica;
- medida;
- análise.

Um Study pode possuir múltiplos Reports e múltiplos Results.

Um Report pode conter vários Results e, excepcionalmente, informação sobre mais de um Study.

A extração não deverá duplicar um estudo apenas porque existem várias publicações.

---

## 4. Modelo conceitual mínimo

Antes do modelo de dados definitivo, o OES adotará a seguinte estrutura conceitual:

**Study → Report → Result**

com vínculos adicionais para:

- Population;
- Intervention/Exposure;
- Comparator;
- Outcome;
- Timepoint;
- Analysis;
- Risk of Bias Assessment;
- Source/Provenance.

Essa estrutura é conceitual e não congela ainda a implementação computacional.

---

## 5. Dado original e dado derivado

O OES distinguirá obrigatoriamente:

### Raw / Source value

Valor conforme relatado na fonte.

### Derived value

Valor calculado, convertido, reconstruído ou normalizado pelo OES.

Exemplos:

- conversão de erro-padrão em desvio-padrão;
- cálculo de risco relativo a partir de contagens;
- conversão de unidade;
- reconstrução de hazard ratio;
- cálculo de intervalo de confiança;
- combinação de grupos;
- digitalização de gráfico.

Regra:

> **o valor original nunca deverá ser silenciosamente substituído pelo valor derivado.**

Quando houver transformação, deverão ser preservados:

- valor de origem;
- transformação;
- fórmula ou método;
- parâmetros utilizados;
- responsável;
- data;
- resultado derivado.

---

## 6. Proveniência por campo

A proveniência deverá ser registrada no menor nível operacional razoável.

Para campos críticos, o OES deverá conseguir responder:

- de qual Report veio o dado;
- em que página, tabela, figura, suplemento, registro ou seção estava;
- se o valor foi diretamente extraído ou derivado;
- quem realizou a extração;
- quem verificou;
- quando ocorreu;
- se houve correção posterior.

Campos que alimentam diretamente sínteses quantitativas deverão ter proveniência granular obrigatória.

---

# PARTE II — PLANEJAMENTO DA EXTRAÇÃO

## 7. Pré-especificação

Antes da extração definitiva, a investigação deverá definir, de forma proporcional ao nível:

- quais categorias de dados serão extraídas;
- quais desfechos são de interesse;
- quais tempos de seguimento são relevantes;
- quais grupos/comparações serão utilizados;
- quais medidas de efeito são preferidas;
- quais análises terão prioridade quando várias forem relatadas;
- como múltiplos Reports serão conciliados;
- quais campos exigem verificação;
- como discordâncias serão resolvidas.

A seleção de dados não deverá ser guiada retrospectivamente pela direção ou significância dos resultados.

---

## 8. Formulário de extração

Investigações N2–N4 deverão utilizar formulário estruturado.

N3 e N4 deverão, como padrão, realizar piloto do formulário antes da extração em escala.

O piloto deverá verificar:

- clareza dos campos;
- opções de resposta;
- ambiguidade;
- carga operacional;
- cobertura dos desfechos;
- capacidade de representar múltiplos Reports;
- compatibilidade com a síntese prevista.

Para N3, o piloto deverá preferencialmente envolver pelo menos dois estudos quando disponíveis.

Para N4, o formulário deverá ser testado por mais de um extrator antes de ser considerado estável.

---

## 9. Codebook

Quando houver campos codificados, categorias não triviais ou múltiplos extratores, deverá existir orientação de preenchimento.

O codebook poderá estar incorporado ao formulário, ao protocolo ou a documento complementar.

Deverá definir, quando pertinente:

- conceito do campo;
- formato;
- valores permitidos;
- regra para “não relatado”;
- regra para “não aplicável”;
- regra para “incerto”;
- prioridade entre fontes conflitantes;
- transformações autorizadas.

Campos vazios não deverão ser usados quando a ausência puder ter significados diferentes.

---

# PARTE III — CATEGORIAS DE DADOS

## 10. Identificação e vínculo documental

Extrair quando aplicável:

- Study ID;
- Report ID;
- citação;
- DOI;
- PMID;
- identificador de registro;
- identificador do patrocinador;
- versão/preprint/publicação final;
- relação entre Reports;
- fonte primária para cada conjunto de resultados.

Identificadores operacionais poderão ser provisórios até o fechamento do modelo de dados.

---

## 11. Características do estudo

Conforme desenho e pergunta:

- desenho;
- centros;
- país/região;
- cenário assistencial;
- período de recrutamento;
- duração;
- prospectivo/retrospectivo;
- método de alocação quando pertinente;
- tamanho amostral;
- critérios de elegibilidade;
- financiamento;
- conflitos de interesse;
- registro e protocolo.

Não será obrigatório extrair todo item em todos os níveis.

---

## 12. Participantes

Conforme a pergunta:

- população-alvo;
- número incluído;
- número analisado;
- idade;
- sexo/gênero quando relevante;
- condição clínica;
- gravidade;
- comorbidades;
- critérios diagnósticos;
- características prognósticas;
- características socioeconômicas ou demográficas relevantes;
- perdas e exclusões após inclusão.

Variáveis sensíveis só deverão ser extraídas quando metodologicamente pertinentes.

---

## 13. Intervenção, exposição e comparador

A estrutura deverá permitir descrição suficiente para interpretação e replicabilidade.

Podem ser extraídos:

- nome;
- definição;
- dose/intensidade;
- frequência;
- duração;
- via;
- cointervenções;
- aderência;
- exposição e método de mensuração;
- definição operacional do comparador;
- contaminação/crossover quando pertinente.

---

## 14. Desfecho

Um desfecho não deverá ser representado apenas por seu nome.

Quando possível, registrar separadamente:

1. domínio;
2. medida/instrumento;
3. métrica;
4. método de agregação;
5. tempo de avaliação.

Exemplo conceitual:

**dor → escala 0–10 → mudança desde baseline → média → 12 semanas**

Essa decomposição reduz falsas equivalências entre resultados aparentemente semelhantes.

---

## 15. Eventos adversos e danos

Dados de dano exigem atenção à forma de coleta.

Registrar, quando pertinente:

- definição do evento;
- gravidade;
- sistemático versus espontâneo;
- denominador;
- janela de observação;
- número de participantes com evento;
- número de eventos;
- descontinuação;
- evento grave;
- causalidade atribuída pelos autores.

Não combinar silenciosamente “número de eventos” com “número de participantes com pelo menos um evento”.

---

## 16. Resultados quantitativos

A extração deverá preservar os elementos necessários para reconstruir ou utilizar a estimativa.

### Desfechos dicotômicos

Quando disponíveis:

- eventos;
- total por grupo;
- medida de efeito relatada;
- intervalo de confiança;
- valor de p, quando relevante.

### Desfechos contínuos

Quando disponíveis:

- n;
- média;
- desvio-padrão;
- mudança ou valor final;
- escala;
- unidade;
- mediana e dispersão, se essa for a forma relatada.

### Tempo até evento

Quando disponíveis:

- hazard ratio;
- intervalo de confiança;
- eventos;
- tempo de seguimento;
- método de estimação.

### Medidas diagnósticas

Quando aplicável:

- verdadeiro positivo;
- falso positivo;
- verdadeiro negativo;
- falso negativo;
- sensibilidade;
- especificidade;
- limiar;
- população analisada.

### Prognóstico, prevalência e associação

Extrair os componentes pertinentes ao desenho, preservando:

- estimativa;
- incerteza;
- modelo;
- conjunto de ajustes;
- tempo;
- definição da população.

---

## 17. Estimativas ajustadas e não ajustadas

Quando ambas forem relatadas, não deverão ser misturadas sem regra prévia.

Para estudos observacionais, registrar:

- estimativa bruta;
- estimativa ajustada selecionada;
- covariáveis do modelo;
- justificativa da escolha;
- modelo estatístico.

A estimativa preferencial deverá ser definida de acordo com a pergunta causal ou prognóstica e com o plano de síntese.

---

## 18. Múltiplas análises e multiplicidade

Um mesmo desfecho pode produzir várias estimativas por:

- população ITT/per-protocol;
- modelo ajustado/não ajustado;
- diferentes imputações;
- múltiplos tempos;
- diferentes escalas;
- subgrupos;
- análises primárias e secundárias.

A regra de escolha deverá ser pré-especificada quando possível.

Quando a escolha não puder ser pré-especificada, a decisão deverá ser documentada e não poderá depender da significância estatística favorável.

---

# PARTE IV — MÚLTIPLOS RELATÓRIOS E CONFLITOS

## 19. Reconciliação de múltiplos Reports

Reports secundários não serão descartados apenas porque existe uma publicação principal.

Podem fornecer:

- métodos adicionais;
- follow-up;
- desfechos não apresentados no artigo principal;
- correções;
- dados de subgrupos;
- informações para risco de viés.

O OES deverá manter o vínculo de proveniência de cada campo ao Report correspondente.

---

## 20. Dados discrepantes entre fontes

Quando duas fontes do mesmo Study divergirem, o OES deverá:

1. confirmar que se referem à mesma população, tempo e análise;
2. verificar erratas, suplementos e registros;
3. identificar se há atualização legítima da análise;
4. registrar a discrepância;
5. aplicar regra de prioridade previamente definida quando possível;
6. contatar autores quando a discrepância for crítica e houver viabilidade.

Não se deverá selecionar silenciosamente o valor “mais plausível” ou o que favoreça determinada conclusão.

---

## 21. Hierarquia de fonte

Não haverá hierarquia universal rígida.

A prioridade dependerá do dado.

Exemplos:

- protocolo/registro pode ser superior para verificar pré-especificação;
- artigo final pode ser superior para resultado principal analisado;
- clinical study report pode conter detalhe ausente na publicação;
- errata posterior pode substituir valor anterior.

Toda regra de prioridade deverá considerar o propósito do campo.

---

# PARTE V — DADOS AUSENTES E CONTATO COM AUTORES

## 22. Estados de ausência

Distinguir:

- não relatado;
- não aplicável;
- não medido;
- medido, mas resultado não disponível;
- ilegível/não recuperável;
- incerto;
- solicitado ao autor;
- obtido por contato.

Essas categorias não são equivalentes.

---

## 23. Contato com autores

Contato poderá ser realizado quando informação ausente ou conflitante for material para:

- elegibilidade;
- risco de viés;
- cálculo de efeito;
- síntese;
- interpretação.

Registrar:

- data;
- destinatário;
- pergunta;
- resposta;
- dado recebido;
- documentação associada.

Informação obtida por correspondência deverá manter proveniência própria.

---

## 24. Imputação

Imputações realizadas pelo OES deverão ser:

- justificadas;
- reproduzíveis;
- claramente identificadas como derivadas;
- separadas de valores observados;
- consideradas em análise de sensibilidade quando material.

O Documento 14 definirá como imputações afetam a síntese.

---

# PARTE VI — TRANSFORMAÇÃO E NORMALIZAÇÃO

## 25. Regra de preservação

Preferir extrair inicialmente os dados na forma em que foram relatados.

Normalização deverá ocorrer em camada posterior.

Exemplos:

- unidade original → unidade comum;
- SE → SD;
- escala original → direção harmonizada;
- contagem → risco;
- estimativa publicada → log-estimativa para meta-análise.

---

## 26. Registro de transformação

Toda transformação material deverá registrar:

- entrada;
- método/fórmula;
- parâmetros;
- saída;
- software ou script, quando usado;
- responsável;
- data;
- verificação.

Transformações repetitivas deverão preferencialmente ser executadas por código reproduzível, não por cálculo manual isolado.

---

## 27. Extração de gráficos

Quando dados necessários existirem apenas em figuras:

1. verificar se há tabela, suplemento, registro ou outra fonte numérica;
2. considerar contato com autores quando relevante;
3. se necessário, utilizar ferramenta de digitalização apropriada;
4. preservar a imagem/fonte e a configuração de eixos;
5. registrar software e procedimento;
6. verificar o valor extraído por segundo processo ou segundo revisor quando alimentar síntese quantitativa N3–N4.

Valores digitalizados deverão ser marcados como **derivados de figura**, não como diretamente reportados.

---

# PARTE VII — CONTROLE DE QUALIDADE POR NÍVEL

## 28. N0 — Evidence Scan

Extração mínima, exploratória e não exaustiva.

Pode registrar:

- referência;
- desenho;
- população;
- pergunta;
- direção geral do achado;
- principais limitações.

Não exige dupla extração.

Não deverá alimentar meta-análise formal sem escalonamento metodológico.

---

## 29. N1 — Resposta de Evidência

Extração focal.

Deverá priorizar os dados necessários à resposta.

Valores numéricos ou afirmações que sustentem diretamente a conclusão deverão ser conferidos contra a fonte antes da publicação do produto.

Dupla extração integral não é requisito padrão.

---

## 30. N2 — Ficha de Evidência Estruturada

Deverá utilizar formulário estruturado e registrar proveniência dos campos críticos.

Padrão:

- um extrator;
- verificação independente dos resultados e campos que sustentem conclusões por segundo revisor quando o produto incluir estimativas quantitativas ou decisões de maior consequência.

Quando houver apenas um operador humano disponível, a limitação deverá ser explicitada e verificações adicionais documentadas.

---

## 31. N3 — Síntese Rápida

Padrão:

- um revisor realiza a extração;
- segundo revisor verifica todos os dados críticos capazes de alterar resultados ou conclusões;
- formulário pilotado;
- conjunto de campos limitado ao necessário;
- discordâncias resolvidas por consenso e, quando necessário, adjudicação.

Dados críticos incluem, como mínimo quando pertinentes:

- definição de desfecho;
- n analisado;
- eventos/estatísticas de desfecho;
- estimativa de efeito;
- medida de incerteza;
- tempo;
- grupo/comparação;
- direção do efeito;
- dados usados na síntese.

A abreviação deverá ser declarada no método.

---

## 32. N4 — Revisão Sistemática / Síntese Aprofundada

Para resultados que alimentam diretamente a síntese:

> **extração independente por pelo menos duas pessoas é o padrão preferencial.**

No mínimo, dados de desfecho deverão ser extraídos independentemente em duplicata, com processo explícito de resolução de discordâncias.

Características do estudo também deverão preferencialmente ser extraídas em duplicata ou verificadas por segundo revisor.

O protocolo da investigação deverá definir:

- quem extrai;
- quem verifica;
- quais campos;
- mecanismo de consenso;
- adjudicação.

---

# PARTE VIII — DISCORDÂNCIA, CORREÇÃO E VERSIONAMENTO

## 33. Resolução de discordâncias

Quando houver dois extratores:

1. comparar os registros sem sobrescrever silenciosamente as versões originais;
2. identificar a causa;
3. retornar à fonte;
4. resolver por consenso;
5. usar terceiro avaliador quando necessário;
6. registrar decisão final em campos críticos.

A taxa de discordância poderá ser usada como sinal de necessidade de recalibração, mas não será convertida automaticamente em métrica de qualidade do estudo.

---

## 34. Correções

Correções posteriores deverão preservar histórico.

Quando um valor usado em síntese for corrigido, registrar:

- valor anterior;
- valor corrigido;
- motivo;
- data;
- responsável;
- impacto sobre análises derivadas.

A arquitetura tecnológica futura deverá evitar sobrescrita sem trilha de auditoria.

---

## 35. Congelamento analítico

Antes de síntese quantitativa formal N3–N4, deverá existir um ponto de congelamento lógico do conjunto de dados.

Após o congelamento, mudanças materiais deverão ser registradas e, se afetarem análise, gerar nova execução identificável.

---

# PARTE IX — IA E AUTOMAÇÃO

## 36. Usos permitidos

IA e automação poderão auxiliar em:

- localização de trechos;
- pré-preenchimento de campos;
- identificação de tabelas;
- vinculação Study–Report;
- detecção de inconsistências;
- conversões repetitivas;
- checagem de completude;
- comparação entre extrações;
- geração de alertas de possível erro.

---

## 37. Restrições

IA não deverá:

- inventar valores ausentes;
- preencher inferências como se fossem fatos relatados;
- escolher silenciosamente entre resultados conflitantes;
- transformar dados sem registrar o método;
- substituir a verificação humana de dados críticos em N3–N4;
- ocultar a proveniência da informação.

Todo campo extraído automaticamente deverá poder ser rastreado até a fonte.

---

## 38. Validação de automação

Antes de incorporar automação em etapa crítica, o OES deverá avaliar sua performance no contexto de uso.

A validação deverá considerar, conforme aplicável:

- erro de extração;
- omissões;
- alucinações;
- capacidade de citar a fonte correta;
- estabilidade;
- desempenho por formato documental.

Automação não será promovida a padrão apenas por conveniência operacional.

---

# PARTE X — EXTRACTION RECORD

## 39. Registro estruturado

O template inicial será:

**templates/data-extraction-record.md**

Identificador provisório:

**OES-DE-AAAA-NNNNNN**

Esse identificador é operacional e poderá ser substituído quando o modelo de dados definitivo for consolidado.

O registro deverá incluir:

- investigação;
- Study/Report;
- extrator;
- verificador;
- data;
- características;
- população;
- intervenção/exposição/comparador;
- desfechos;
- resultados;
- proveniência;
- dados derivados;
- discrepâncias;
- contato com autores;
- status de verificação.

---

# PARTE XI — INTERFACE COM AS ETAPAS ADJACENTES

## 40. Relação com risco de viés

O Extraction Record não substitui o Risk of Bias Record.

Entretanto, deverá fornecer dados e proveniência que sustentem a avaliação de risco de viés.

Quando a ferramenta de risco de viés operar no nível do resultado, deverá existir vínculo entre:

**Result ↔ Risk of Bias Assessment**

---

## 41. Relação com síntese

O Documento 14 consumirá os dados estruturados produzidos aqui.

Somente resultados compatíveis com o plano de síntese deverão ser combinados.

A existência de dados numericamente combináveis não implica que a combinação seja metodologicamente apropriada.

---

## 42. Relação com certeza/confiança

O Documento 15 avaliará o corpo de evidências.

A extração deverá preservar informações necessárias para essa avaliação, especialmente:

- estimativas;
- incerteza;
- risco de viés;
- consistência de definições;
- aplicabilidade;
- tamanho e estrutura do corpo de evidências.

---

# PARTE XII — REGRAS DE DADOS

## 43. Princípios para o futuro modelo de dados

O modelo tecnológico deverá suportar:

1. múltiplos Reports por Study;
2. múltiplos Results por Study;
3. múltiplos tempos por Outcome;
4. múltiplas análises do mesmo Result;
5. proveniência por campo crítico;
6. valor original e valor derivado;
7. histórico de correção;
8. vínculos com risco de viés;
9. versionamento;
10. reutilização em atualizações e produtos diferentes.

---

## 44. Reutilização

Um dos objetivos do OES é reduzir retrabalho.

Dados extraídos poderão ser reutilizados em investigações futuras desde que:

- a identidade do Study seja confiável;
- a proveniência esteja preservada;
- o campo corresponda ao mesmo constructo;
- a fonte continue válida;
- eventuais correções posteriores sejam incorporadas;
- a nova pergunta não exija interpretação diferente.

Reutilização não elimina verificação de adequação ao novo contexto.

---

## 45. Segurança, licenciamento e dados individuais

O OES deverá respeitar:

- direitos autorais;
- licenças de bases e documentos;
- termos de uso;
- proteção de dados pessoais;
- requisitos éticos aplicáveis.

Dados individuais de participantes não serão armazenados como rotina sem fundamento metodológico, jurídico e de governança específico.

---

# PARTE XIII — REFERENCIAIS METODOLÓGICOS

## 46. Referências principais

### Cochrane Handbook — Chapter 5: Collecting data

Referência central para:

- estudo como unidade de interesse;
- múltiplos relatórios;
- desenho e piloto de formulários;
- extração em duplicata;
- dados de desfecho;
- gráficos;
- automação;
- arquivamento e reutilização.

https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-05

### Cochrane Rapid Reviews Methods Guidance / Garritty et al. 2024

Referência para proporcionalidade em sínteses rápidas:

- limitar campos ao necessário;
- pilotar formulário;
- um extrator + verificação por segundo revisor dos dados críticos.

https://www.bmj.com/content/384/bmj-2023-076335

### JBI Manual for Evidence Synthesis

Referência complementar para extração orientada ao tipo de síntese e aos desenhos incluídos.

https://synthesismanual.jbi.global/

---

# PARTE XIV — DECISÕES CONSOLIDADAS

## 47. Regras do OES

Ficam consolidadas para esta fase:

1. Study, Report e Result são entidades distintas.
2. O valor relatado e o valor derivado serão preservados separadamente.
3. Proveniência será obrigatória para dados críticos.
4. Formulário estruturado será padrão em N2–N4.
5. N3 usará, como padrão, um extrator com verificação dos dados críticos por segundo revisor.
6. N4 adotará extração independente em duplicata para dados de desfecho que alimentem sínteses.
7. Múltiplos Reports serão vinculados e reconciliados, não tratados como estudos independentes.
8. Discrepâncias entre fontes serão registradas e resolvidas por regra explícita.
9. Dados ausentes terão estados diferenciados.
10. Transformações serão registradas e reproduzíveis.
11. Extração de gráficos será marcada como dado derivado.
12. IA poderá auxiliar, mas não substituir silenciosamente controle humano de dados críticos.
13. Correções deverão preservar histórico.
14. O futuro modelo de dados deverá suportar proveniência e versionamento.
15. O Extraction Record será separado do Risk of Bias Record, porém vinculável ao mesmo Result.

---

## 48. Ponto de saída do Documento 13

O resultado desta etapa é um conjunto estruturado de dados apto a alimentar o próximo protocolo:

> **14 — Protocolo de Síntese de Evidências**

O Documento 14 definirá:

- critérios para síntese narrativa;
- critérios para meta-análise;
- escolha de medidas de efeito;
- heterogeneidade;
- modelos estatísticos;
- subgrupos;
- sensibilidade;
- multiplicidade;
- síntese sem meta-análise;
- integração de risco de viés;
- regras por tipo de pergunta.

---

**Fim do Documento 13**
