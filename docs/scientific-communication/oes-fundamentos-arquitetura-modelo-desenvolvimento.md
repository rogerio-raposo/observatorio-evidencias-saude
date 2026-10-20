# Observatório de Evidências em Saúde (OES)
## Fundamentos científicos, arquitetura metodológica e modelo de desenvolvimento de um sistema de produção, síntese e atualização de evidências

**Versão editorial:** 0.1 (manuscrito em elaboração)  
**Data de referência:** 20 de outubro de 2026  
**Público-alvo:** pesquisadores e grupos da área da saúde interessados em compreender e desenvolver observatórios de evidências  
**Estado editorial:** apresentação e Capítulo 1 redigidos; Capítulos 2–16 estruturados e pendentes de redação  
**Validação científica independente do manuscrito:** não realizada  
**Natureza:** documento descritivo e metodológico; não é convite de recrutamento, parecer científico ou declaração de prontidão operacional

> **Nota de escopo:** este manuscrito descreve uma iniciativa em desenvolvimento. Não substitui os protocolos canônicos, não concede aprovação metodológica nem modifica fases, *gates* ou autorizações do projeto. Qualquer afirmação sobre maturidade deve ser interpretada na data de referência e conferida em [STATE.md](../../STATE.md). A redação será atualizada conforme novas decisões forem formalizadas.

## Organização do documento

- **Parte I — Concepção e fundamentos:** 1. Introdução; 2. Fundamentos conceituais e princípios do OES; 3. Escopo científico e definição das perguntas.
- **Parte II — Arquitetura científica e metodológica:** 4. Arquitetura de investigação do OES; 5. Processo metodológico de produção de evidências; 6. Arquitetura dos produtos do observatório; 7. Governança científica e garantia metodológica.
- **Parte III — Arquitetura da informação e operação:** 8. Modelo de conhecimento e arquitetura de dados; 9. Fluxo operacional do observatório; 10. Protocolo de atualização das evidências; 11. Infraestrutura tecnológica e automação.
- **Parte IV — Desenvolvimento, validação e replicação:** 12. Estratégia de desenvolvimento do OES; 13. Validação científica, metodológica e tecnológica; 14. Experiência do OES: avanços, limitações e aprendizados; 15. Guia para criação de observatórios de evidências em saúde; 16. Discussão e perspectivas.

Além dos 16 capítulos, estão previstos referências bibliográficas e apêndices: glossário completo; diagramas de arquitetura; matriz de níveis e produtos; fluxograma metodológico; governança e garantia; roteiro de implantação; instrumentos/templates; e mapa da documentação do projeto.

## Apresentação

A produção científica em saúde oferece oportunidades crescentes de aprimoramento das decisões, mas a disponibilidade de publicações não assegura que suas informações sejam identificadas, avaliadas e interpretadas de modo consistente. Estudos sobre uma mesma questão podem apresentar populações, métodos, estimativas e resultados diferentes; revisões podem sobrepor evidências; e novos achados podem tornar necessária a reavaliação de sínteses já existentes. O trabalho necessário para transformar essa literatura em conhecimento utilizável é metodologicamente exigente e precisa ser documentado.

O **Observatório de Evidências em Saúde (OES)** é uma iniciativa que busca estruturar esse trabalho por meio de um processo explícito de formulação de perguntas, investigação, avaliação crítica, síntese, comunicação e atualização de evidências. Seu princípio orientador é **metodologia antes da automação**: os processos computacionais devem servir a decisões científicas fundamentadas, não substituí-las por conveniência tecnológica. [Fonte: Documento 00](../governance/00-documento-de-concepcao.md).

Este texto apresenta o modelo concebido e desenvolvido até o momento, suas escolhas científicas e arquiteturais, seus resultados documentados e suas limitações. Seu propósito é oferecer aos pesquisadores elementos suficientes para analisar criticamente a proposta e avaliar o que poderia ser adaptado a contextos institucionais diferentes. Não pressupõe que a arquitetura do OES seja o único modelo possível nem que seus componentes já tenham recebido validação científica independente.

A exposição distingue cinco situações: **(i)** definição conceitual ou metodológica documentada; **(ii)** implementação técnica; **(iii)** validação técnica ou demonstração experimental; **(iv)** revisão científica humana especializada; e **(v)** operação efetiva e sustentada. Uma situação não implica automaticamente a seguinte.

## PARTE I — CONCEPÇÃO E FUNDAMENTOS

# 1. Introdução

### 1.1. O crescimento da produção científica em saúde

A expansão e a diversificação da literatura científica em saúde ampliam as possibilidades de pesquisa e de fundamentação de decisões, mas também tornam mais complexa a identificação do conjunto de evidências relevante para uma pergunta definida. A informação está distribuída entre periódicos, bases bibliográficas, registros de estudos, relatórios técnicos, revisões, diretrizes e outras fontes. Essas fontes não são intercambiáveis: variam em finalidade, cobertura, atualização e grau de avaliação metodológica.

O desafio não se reduz à quantidade de documentos. Estudos que parecem abordar uma mesma questão podem diferir na população investigada, na intervenção ou exposição considerada, nos comparadores, nos desfechos, no tempo de acompanhamento e no risco de viés. Resultados divergentes podem refletir diferenças reais entre contextos, imprecisão estatística, limitações metodológicas ou variação aleatória. Além disso, diferentes publicações podem descrever um mesmo estudo; tratá-las como investigações independentes distorceria a representação do corpo de evidências.

Em paralelo, a dimensão temporal é incontornável. Uma síntese pode ser adequada na data em que foi produzida e necessitar de reavaliação quando novos resultados, correções, retratações ou informações de segurança se tornam disponíveis. Portanto, recuperar documentos constitui apenas uma parte do trabalho necessário para manter conhecimento científico utilizável.

### 1.2. Da informação científica ao conhecimento utilizável

Transformar publicações em conhecimento utilizável exige formular uma pergunta suficientemente precisa, escolher métodos compatíveis com sua natureza, identificar estudos pertinentes, avaliar sua confiabilidade e interpretar os resultados em conjunto. Também exige distinguir o risco de viés dos estudos individuais da certeza do corpo de evidências e separar o significado científico de um achado de sua aplicabilidade em determinado contexto.

Nesse percurso, a organização da informação precisa preservar o caminho percorrido entre a fonte e a conclusão. Uma afirmação sintética será mais verificável se o leitor puder reconhecer quais estudos a sustentam, como foram selecionados, quais resultados contribuíram, que julgamentos metodológicos foram feitos e até que data a literatura foi considerada. A documentação desses vínculos é central para detectar erros, revisar conclusões e reutilizar avaliações já realizadas.

É igualmente importante comunicar incerteza sem convertê-la em respostas artificiosamente definitivas. A inexistência de estudos elegíveis não demonstra ausência de efeito; uma estimativa estatisticamente precisa não garante aplicabilidade universal; e uma revisão metodologicamente estruturada não produz automaticamente uma recomendação clínica. Recomendações requerem julgamentos adicionais sobre benefícios, danos, valores, recursos, equidade e contexto.

### 1.3. O conceito de observatório de evidências científicas

Neste documento, **observatório de evidências** designa uma estrutura organizada para identificar, avaliar criticamente, sintetizar, comunicar e acompanhar a evolução do conhecimento científico em torno de perguntas ou domínios de interesse. Trata-se de uma **definição operacional adotada pelo OES**, e não da alegação de que exista um único conceito universalmente aceito para iniciativas dessa natureza.

Um observatório não se confunde com uma biblioteca de artigos, um buscador bibliográfico ou um painel de indicadores. Esses recursos podem integrar sua infraestrutura, mas a função distintiva proposta é manter relações explícitas entre perguntas, investigações, fontes, julgamentos de qualidade, sínteses, conclusões, datas e revisões subsequentes. Tampouco todos os produtos precisam seguir o mesmo grau de aprofundamento: uma exploração inicial do campo tem finalidade e requisitos distintos de uma revisão sistemática.

O acompanhamento temporal acrescenta outra dimensão. Identificar uma nova publicação é um sinal potencialmente relevante, mas não altera, por si só, a conclusão anterior. É necessário decidir se a informação merece avaliação, se muda a atualidade atribuída ao produto e se exige uma atualização científica formal. Assim, vigilância, interpretação e atualização são atividades relacionadas, porém distintas.

### 1.4. Apresentação do OES

O OES foi concebido para converter literatura científica dispersa em conhecimento estruturado, rastreável e comunicável, preservando a transparência das limitações e da incerteza. Seu desenho organiza os problemas em perguntas científicas, investigações metodológicas e produtos de evidência, sustentados por registros de fontes, avaliações e decisões. A natureza da pergunta orienta a escolha dos métodos; a criticidade e a finalidade orientam a profundidade da investigação. [Fontes: Documentos 00, 01 e 02](../governance/00-documento-de-concepcao.md).

A arquitetura estabelece cinco níveis de profundidade (N0–N4), que vão da exploração de um campo até investigações aprofundadas. Distingue, ainda, a profundidade da investigação dos regimes de manutenção do conhecimento (M0–M3). A taxonomia inicial compreende nove produtos: Evidence Scan, Resposta de Evidência, Ficha de Evidência, Síntese Rápida, Revisão de Evidências, Mapa de Evidências, Overview de Revisões, Monitor de Evidências e Alerta de Evidência. [Fonte: Documento 40](../products/40-taxonomia-arquitetura-produtos.md).

Até a data de referência, o projeto consolidou a base inicial de concepção e dos protocolos metodológicos, concluiu uma *baseline* arquitetural de dados e formalizou a taxonomia e os componentes dos nove produtos na Fase 3. Há implementações e provas técnicas documentadas, incluindo cenários sintéticos e alguns casos de uso com dados científicos reais. Esses resultados não equivalem a afirmar que todos os produtos estão disponíveis em operação pública ou que a metodologia foi validada externamente.

A Fase 4, relativa ao protocolo de atualização, permanece em desenvolvimento. As Fases 5 (Automação e IA), 6 (Validação) e 7 (Operação contínua) não foram iniciadas formalmente. A experiência do OES também registra uma limitação decisiva: seu desenvolvimento até este marco não contou com revisão científica independente por equipe humana especializada. Verificações assistidas por IA e aprovação de governança não devem ser apresentadas como substitutas dessa revisão. [Fontes: STATE e Documento 04](../../STATE.md).

Portanto, o estágio atual permite examinar uma proposta metodológica e uma arquitetura documentada, além de artefatos técnicos e casos que podem subsidiar avaliação crítica. **Não permite concluir que o observatório esteja cientificamente validado para uso amplo nem operacionalizado como serviço contínuo de vigilância de evidências.**

### 1.5. Objetivos e organização do documento

O objetivo geral deste documento é **descrever o OES e tornar suas escolhas conceituais, metodológicas, organizacionais e tecnológicas inteligíveis a pesquisadores interessados na criação de observatórios de evidências em saúde**. Mais especificamente, pretende: (a) explicitar o problema e os princípios que motivam a proposta; (b) apresentar como perguntas e evidências são processadas; (c) caracterizar os produtos e os mecanismos de atualização; (d) distinguir capacidades implementadas, testadas e ainda previstas; e (e) identificar decisões e aprendizados potencialmente transferíveis a outras iniciativas.

A Parte I trata da concepção, dos princípios e do escopo das perguntas. A Parte II apresenta a arquitetura científica, os métodos de produção de evidências, os produtos e a governança. A Parte III descreve os objetos de informação, o ciclo operacional, a atualização e a infraestrutura tecnológica. A Parte IV documenta a trajetória de desenvolvimento, a validação, os limites e as possibilidades de adaptação a outros contextos.

A apresentação procura evitar dois extremos: uma narrativa promocional que confunda desenvolvimento com validação científica e um inventário excessivamente técnico que obscureça as questões metodológicas relevantes para pesquisadores. A documentação primária do repositório permanece disponível para aprofundamento e verificação.

# 2. Fundamentos conceituais e princípios do OES

*Redação pendente — estrutura de tópicos aprovada.*

- **2.1. Missão, visão e objetivos:** texto a desenvolver a partir da documentação canônica pertinente.
- **2.2. O corpo de evidências como unidade fundamental de análise:** texto a desenvolver a partir da documentação canônica pertinente.
- **2.3. Princípios científicos e metodológicos:** texto a desenvolver a partir da documentação canônica pertinente.
- **2.4. Proporcionalidade metodológica:** texto a desenvolver a partir da documentação canônica pertinente.
- **2.5. Evidência, interpretação e recomendação:** texto a desenvolver a partir da documentação canônica pertinente.
- **2.6. Atualidade do conhecimento científico:** texto a desenvolver a partir da documentação canônica pertinente.

# 3. Escopo científico e definição das perguntas

*Redação pendente — estrutura de tópicos aprovada.*

- **3.1. Domínios temáticos do observatório:** texto a desenvolver a partir da documentação canônica pertinente.
- **3.2. Tipologia das perguntas científicas:** texto a desenvolver a partir da documentação canônica pertinente.
- **3.3. Formulação e estruturação das perguntas:** texto a desenvolver a partir da documentação canônica pertinente.
- **3.4. Admissibilidade e priorização das demandas:** texto a desenvolver a partir da documentação canônica pertinente.
- **3.5. Roteamento metodológico:** texto a desenvolver a partir da documentação canônica pertinente.

## PARTE II — ARQUITETURA CIENTÍFICA E METODOLÓGICA

# 4. Arquitetura de investigação do OES

*Redação pendente — estrutura de tópicos aprovada.*

- **4.1. Organização geral da investigação:** texto a desenvolver a partir da documentação canônica pertinente.
- **4.2. Níveis de profundidade metodológica (N0–N4):** texto a desenvolver a partir da documentação canônica pertinente.
- **4.3. Critérios de escolha da profundidade:** texto a desenvolver a partir da documentação canônica pertinente.
- **4.4. Regimes de manutenção (M0–M3):** texto a desenvolver a partir da documentação canônica pertinente.
- **4.5. Independência entre profundidade e manutenção:** texto a desenvolver a partir da documentação canônica pertinente.
- **4.6. Escalonamento e reclassificação das investigações:** texto a desenvolver a partir da documentação canônica pertinente.

# 5. Processo metodológico de produção de evidências

*Redação pendente — estrutura de tópicos aprovada.*

- **5.1. Planejamento e protocolo de investigação:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.2. Busca e recuperação da literatura:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.3. Triagem e seleção dos estudos:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.4. Avaliação crítica e risco de viés:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.5. Extração e estruturação dos dados:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.6. Síntese das evidências:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.7. Avaliação da certeza ou confiança nas evidências:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.8. Avaliação da aplicabilidade:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.9. Formulação das conclusões científicas:** texto a desenvolver a partir da documentação canônica pertinente.
- **5.10. Transparência e reprodutibilidade:** texto a desenvolver a partir da documentação canônica pertinente.

# 6. Arquitetura dos produtos do observatório

*Redação pendente — estrutura de tópicos aprovada.*

- **6.1. Conceito e função dos produtos científicos:** texto a desenvolver a partir da documentação canônica pertinente.
- **6.2. Produtos de investigação: Evidence Scan, Resposta de Evidência, Ficha de Evidência, Síntese Rápida e Revisão de Evidências:** texto a desenvolver a partir da documentação canônica pertinente.
- **6.3. Produtos analíticos transversais: Mapa de Evidências e Overview de Revisões:** texto a desenvolver a partir da documentação canônica pertinente.
- **6.4. Produtos de manutenção: Monitor e Alerta de Evidência:** texto a desenvolver a partir da documentação canônica pertinente.
- **6.5. Padronização dos produtos:** texto a desenvolver a partir da documentação canônica pertinente.
- **6.6. Relações e reutilização entre produtos:** texto a desenvolver a partir da documentação canônica pertinente.

# 7. Governança científica e garantia metodológica

*Redação pendente — estrutura de tópicos aprovada.*

- **7.1. Estrutura de governança do OES:** texto a desenvolver a partir da documentação canônica pertinente.
- **7.2. Papéis e responsabilidades:** texto a desenvolver a partir da documentação canônica pertinente.
- **7.3. Níveis de garantia (A0–A3):** texto a desenvolver a partir da documentação canônica pertinente.
- **7.4. Requisitos de revisão humana:** texto a desenvolver a partir da documentação canônica pertinente.
- **7.5. Controle de qualidade e validação metodológica:** texto a desenvolver a partir da documentação canônica pertinente.
- **7.6. Critérios de publicação:** texto a desenvolver a partir da documentação canônica pertinente.
- **7.7. Independência científica e conflitos de interesse:** texto a desenvolver a partir da documentação canônica pertinente.

## PARTE III — ARQUITETURA DA INFORMAÇÃO E OPERAÇÃO

# 8. Modelo de conhecimento e arquitetura de dados

*Redação pendente — estrutura de tópicos aprovada.*

- **8.1. Requisitos de informação do observatório:** texto a desenvolver a partir da documentação canônica pertinente.
- **8.2. Modelo conceitual de dados:** texto a desenvolver a partir da documentação canônica pertinente.
- **8.3. Distinção entre estudo, publicação e resultado:** texto a desenvolver a partir da documentação canônica pertinente.
- **8.4. Registros metodológicos e operacionais:** texto a desenvolver a partir da documentação canônica pertinente.
- **8.5. Proveniência e linhagem dos dados:** texto a desenvolver a partir da documentação canônica pertinente.
- **8.6. Identificação, versionamento e histórico:** texto a desenvolver a partir da documentação canônica pertinente.
- **8.7. Arquitetura de persistência:** texto a desenvolver a partir da documentação canônica pertinente.
- **8.8. Integridade, interoperabilidade e evolução do modelo:** texto a desenvolver a partir da documentação canônica pertinente.

# 9. Fluxo operacional do observatório

*Redação pendente — estrutura de tópicos aprovada.*

- **9.1. Visão geral do ciclo de trabalho:** texto a desenvolver a partir da documentação canônica pertinente.
- **9.2. Recebimento e normalização da demanda:** texto a desenvolver a partir da documentação canônica pertinente.
- **9.3. Planejamento e abertura da investigação:** texto a desenvolver a partir da documentação canônica pertinente.
- **9.4. Execução da investigação:** texto a desenvolver a partir da documentação canônica pertinente.
- **9.5. Revisão, aprovação e publicação:** texto a desenvolver a partir da documentação canônica pertinente.
- **9.6. Comunicação e disponibilização:** texto a desenvolver a partir da documentação canônica pertinente.
- **9.7. Monitoramento e retroalimentação:** texto a desenvolver a partir da documentação canônica pertinente.

# 10. Protocolo de atualização das evidências

*Redação pendente — estrutura de tópicos aprovada.*

- **10.1. Fundamentação da atualização contínua:** texto a desenvolver a partir da documentação canônica pertinente.
- **10.2. Estados de atualidade das evidências:** texto a desenvolver a partir da documentação canônica pertinente.
- **10.3. Fontes e sinais de atualização:** texto a desenvolver a partir da documentação canônica pertinente.
- **10.4. Avaliação da relevância das novas informações:** texto a desenvolver a partir da documentação canônica pertinente.
- **10.5. Periodicidade, prioridades e escalonamento:** texto a desenvolver a partir da documentação canônica pertinente.
- **10.6. Atualização científica e versionamento:** texto a desenvolver a partir da documentação canônica pertinente.
- **10.7. Evidências vivas (Living Evidence):** texto a desenvolver a partir da documentação canônica pertinente.
- **10.8. Registro e auditoria das atualizações:** texto a desenvolver a partir da documentação canônica pertinente.

# 11. Infraestrutura tecnológica e automação

*Redação pendente — estrutura de tópicos aprovada.*

- **11.1. Princípio de desenvolvimento orientado pela metodologia:** texto a desenvolver a partir da documentação canônica pertinente.
- **11.2. Componentes da arquitetura tecnológica:** texto a desenvolver a partir da documentação canônica pertinente.
- **11.3. Banco de dados e estruturas de persistência:** texto a desenvolver a partir da documentação canônica pertinente.
- **11.4. Fluxos automatizados de processamento:** texto a desenvolver a partir da documentação canônica pertinente.
- **11.5. Inteligência artificial no ciclo das evidências:** texto a desenvolver a partir da documentação canônica pertinente.
- **11.6. Limites e salvaguardas da inteligência artificial:** texto a desenvolver a partir da documentação canônica pertinente.
- **11.7. Segurança e continuidade operacional:** texto a desenvolver a partir da documentação canônica pertinente.
- **11.8. Escalabilidade e sustentabilidade tecnológica:** texto a desenvolver a partir da documentação canônica pertinente.

## PARTE IV — DESENVOLVIMENTO, VALIDAÇÃO E REPLICAÇÃO

# 12. Estratégia de desenvolvimento do OES

*Redação pendente — estrutura de tópicos aprovada.*

- **12.1. Abordagem incremental:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.2. Fase 0 — Concepção e fundamentos:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.3. Fase 1 — Manual Metodológico:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.4. Fase 2 — Modelo de Dados da Evidência:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.5. Fase 3 — Produtos do Observatório:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.6. Fase 4 — Protocolo de Atualização:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.7. Fase 5 — Automação e IA:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.8. Fase 6 — Validação:** texto a desenvolver a partir da documentação canônica pertinente.
- **12.9. Fase 7 — Operação contínua:** texto a desenvolver a partir da documentação canônica pertinente.

# 13. Validação científica, metodológica e tecnológica

*Redação pendente — estrutura de tópicos aprovada.*

- **13.1. Dimensões de validação:** texto a desenvolver a partir da documentação canônica pertinente.
- **13.2. Provas de conceito e testes automatizados:** texto a desenvolver a partir da documentação canônica pertinente.
- **13.3. Estudos de caso e aplicações experimentais:** texto a desenvolver a partir da documentação canônica pertinente.
- **13.4. Revisões adversariais:** texto a desenvolver a partir da documentação canônica pertinente.
- **13.5. Critérios de aceitação e liberação:** texto a desenvolver a partir da documentação canônica pertinente.
- **13.6. Indicadores de desempenho e qualidade:** texto a desenvolver a partir da documentação canônica pertinente.

# 14. Experiência do OES: avanços, limitações e aprendizados

*Redação pendente — estrutura de tópicos aprovada.*

- **14.1. Resultados alcançados:** texto a desenvolver a partir da documentação canônica pertinente.
- **14.2. Exemplos de aplicação:** texto a desenvolver a partir da documentação canônica pertinente.
- **14.3. Dificuldades científicas e metodológicas:** texto a desenvolver a partir da documentação canônica pertinente.
- **14.4. Desafios tecnológicos e operacionais:** texto a desenvolver a partir da documentação canônica pertinente.
- **14.5. Limitações do estágio atual de desenvolvimento:** texto a desenvolver a partir da documentação canônica pertinente.
- **14.6. Lições para outras iniciativas:** texto a desenvolver a partir da documentação canônica pertinente.

# 15. Guia para criação de observatórios de evidências em saúde

*Redação pendente — estrutura de tópicos aprovada.*

- **15.1. Avaliação preliminar de viabilidade:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.2. Delimitação do escopo e do público-alvo:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.3. Constituição da equipe e da governança:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.4. Seleção e adaptação dos referenciais metodológicos:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.5. Definição do conjunto inicial de produtos:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.6. Construção de um observatório mínimo viável:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.7. Estratégia de validação inicial:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.8. Planejamento da expansão e sustentabilidade:** texto a desenvolver a partir da documentação canônica pertinente.
- **15.9. Riscos e fatores críticos de sucesso:** texto a desenvolver a partir da documentação canônica pertinente.

# 16. Discussão e perspectivas

*Redação pendente — estrutura de tópicos aprovada.*

- **16.1. Contribuições do modelo OES:** texto a desenvolver a partir da documentação canônica pertinente.
- **16.2. Replicabilidade e adaptação institucional:** texto a desenvolver a partir da documentação canônica pertinente.
- **16.3. Integração com ecossistemas existentes:** texto a desenvolver a partir da documentação canônica pertinente.
- **16.4. Perspectivas para automação e evidência viva:** texto a desenvolver a partir da documentação canônica pertinente.
- **16.5. Considerações finais:** texto a desenvolver a partir da documentação canônica pertinente.
## Referências e documentação de base (seleção inicial)

As referências científicas externas serão verificadas e normalizadas na fase de redação dos respectivos capítulos. A lista abaixo identifica **fontes internas do projeto**, não substituindo bibliografia científica externa.

- [Documento 00 — Concepção](../governance/00-documento-de-concepcao.md)
- [Documento 01 — Escopo e taxonomia das perguntas](../governance/01-taxonomia-perguntas.md)
- [Documento 02 — Níveis de investigação e produtos](../governance/02-niveis-investigacao-produtos.md)
- [Documento 04 — Governança e garantia metodológica](../governance/04-governanca-garantia-revisao.md)
- [Documento 40 — Taxonomia dos produtos](../products/40-taxonomia-arquitetura-produtos.md)
- [STATE — Estado corrente e histórico documentado](../../STATE.md)
- [Continuidade operacional](../../archive/handoffs/oes/README.md)

**Nota editorial:** a apresentação executiva D0 (Documento 168) é um artefato separado, com finalidade distinta, e não substitui esta descrição de 16 capítulos.

## Apêndices previstos

A. Glossário técnico completo; B. Visão geral da arquitetura do OES; C. Matriz de níveis de investigação e produtos; D. Fluxo metodológico de processamento; E. Modelo de governança e garantia; F. Roteiro de implantação; G. Instrumentos e templates; H. Documentação e repositório do projeto.

---

*Fim da versão 0.1 — apenas a apresentação e o Capítulo 1 constituem texto corrido desenvolvido nesta versão. Os demais capítulos são um plano estrutural de redação, não conteúdo científico já concluído.*
