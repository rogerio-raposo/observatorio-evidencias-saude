# Observatório de Evidências em Saúde (OES)
## Fundamentos científicos, arquitetura metodológica e modelo de desenvolvimento de um sistema de produção, síntese e atualização de evidências

**Versão editorial:** 0.3 (manuscrito em elaboração)  
**Data de referência:** 20 de outubro de 2026  
**Público-alvo:** pesquisadores e grupos da área da saúde interessados em compreender e desenvolver observatórios de evidências  
**Estado editorial:** apresentação e Capítulos 1–3 redigidos; Capítulos 4–16 estruturados e pendentes de redação  
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

### 2.1. Missão, visão e objetivos

O Observatório de Evidências em Saúde (OES) foi concebido para transformar informação científica dispersa em conhecimento estruturado, criticamente avaliado, rastreável e compreensível. Sua **missão** consiste em apoiar a elaboração e a manutenção de sínteses de evidências que possam informar a pesquisa e a tomada de decisões em saúde, reconhecendo que identificar publicações não equivale a determinar o que um conjunto de estudos permite concluir. Essa formulação corresponde à concepção documentada no início do projeto, não à afirmação de que já exista um serviço científico plenamente operacional. [Fonte: Documento 00](../governance/00-documento-de-concepcao.md).

A **visão** é constituir uma estrutura de consulta e acompanhamento da evidência que integre métodos científicos explícitos, organização persistente do conhecimento, atualização temporal, comunicação acessível e recursos computacionais de apoio. No modelo proposto, a continuidade do conhecimento não depende apenas da produção de novos relatórios: depende também da capacidade de relacionar perguntas, estudos, resultados e produtos sucessivos, preservando o que foi analisado anteriormente e por qual método.

O projeto combina três objetivos complementares. O primeiro é **científico**: favorecer avaliações que considerem o corpo de evidências relevante, seus limites e a confiança justificável em suas conclusões. O segundo é **informacional**: registrar os objetos científicos, as fontes e as decisões de maneira que possam ser auditados, recuperados e reutilizados. O terceiro é **operacional**: estabelecer condições para detectar quando surgem informações capazes de justificar reavaliação, sem transformar a chegada de uma nova publicação em alteração automática de uma conclusão.

O OES não pretende substituir a produção de estudos primários, a avaliação clínica individual, os processos de recomendação profissional ou a competência metodológica de pesquisadores. Seu papel é organizar um percurso entre a pergunta e a síntese, preservando a distinção entre o trabalho científico executado, o nível de garantia recebido e a finalidade de uso de cada produto. Em particular, o desenvolvimento de procedimentos assistidos por inteligência artificial não deve ser apresentado como validação científica independente.

A realização desses objetivos dependerá, em graus diferentes, de métodos, pessoas, infraestrutura e validação. Por isso, este documento trata missão e visão como **direções de desenvolvimento** e identifica separadamente os resultados efetivamente demonstrados em cada fase. A utilidade potencial do modelo é uma hipótese a ser examinada por pesquisadores, não um desempenho científico já comprovado.

### 2.2. O corpo de evidências como unidade fundamental de análise

A unidade de referência do OES é o **corpo de evidências pertinente a uma pergunta científica definida**. Essa escolha altera o modo de interpretar a literatura: uma publicação pode conter resultados úteis, mas raramente é suficiente para representar, isoladamente, o conhecimento disponível sobre uma intervenção, condição, exposição ou fenômeno. O conjunto relevante pode abranger estudos com desenhos diferentes, populações não equivalentes, múltiplos desfechos, estimativas divergentes e limitações metodológicas de natureza distinta.

No plano conceitual, é necessário separar três objetos que frequentemente aparecem misturados em apresentações informais: **estudo**, **documento que relata o estudo** e **resultado científico**. Um ensaio clínico, por exemplo, pode ser descrito em um protocolo, um registro de ensaio e mais de um artigo; esses documentos não representam necessariamente ensaios independentes. O mesmo estudo também pode produzir resultados distintos para vários desfechos e tempos de seguimento. Preservar essas identidades permite reduzir a dupla contagem e localizar a origem das informações empregadas nas sínteses. Essa distinção está formalizada no [modelo conceitual de dados do OES (Documento 20)](../architecture/20-modelo-conceitual-dados.md).

A avaliação do corpo de evidências também exige reconhecer que **risco de viés de um estudo não é sinônimo de certeza da conclusão global**. Julgamentos sobre certeza ou confiança dependem da unidade de análise, da pergunta, do desfecho ou achado e do conjunto dos fatores relevantes, incluindo limitações dos estudos, consistência, precisão, evidência indireta e possível ausência seletiva de resultados. Uma síntese quantitativa não se torna confiável apenas porque reúne muitos participantes; inversamente, a existência de alguma limitação nos estudos incluídos não determina mecanicamente o julgamento final. [Fonte: Documento 15 — Certeza da evidência](../methodology/15-certeza-evidencia.md).

A pergunta científica estabelece, portanto, os limites da interpretação: quais populações e contextos interessam, quais intervenções ou exposições estão em exame, quais comparadores são pertinentes e quais desfechos têm importância para a análise. Quando uma pergunta contém objetos metodologicamente heterogêneos, pode ser necessário dividi-la em subperguntas antes de integrar as conclusões. O OES não pressupõe uma hierarquia universal de desenhos de estudo válida para qualquer pergunta; o desenho apropriado varia entre, por exemplo, efetividade terapêutica, prevalência, acurácia diagnóstica e pesquisa qualitativa. [Fonte: Documento 01 — Escopo e taxonomia das perguntas](../governance/01-taxonomia-perguntas.md).

Dessa perspectiva, o produto final — ficha, resposta, mapa ou revisão — é uma **representação comunicável de um processo científico documentado**, não a própria evidência primária. Essa distinção é condição importante para que novos produtos possam reutilizar estudos e sínteses existentes sem apagar a origem dos dados ou confundir uma apresentação editorial com uma avaliação metodológica original.

### 2.3. Princípios científicos e metodológicos

A arquitetura do OES adota a diretriz **metodologia antes da automação**. Isso significa que a escolha dos procedimentos de busca, seleção, avaliação, síntese e atualização deve ser fundamentada na natureza da pergunta científica e nos requisitos da investigação. As ferramentas digitais são meios para apoiar esse percurso, não critérios suficientes para determinar sua validade. Os princípios a seguir sintetizam compromissos presentes na concepção e nos protocolos do projeto. [Fonte: Documento 00](../governance/00-documento-de-concepcao.md).

**Adequação à pergunta.** Métodos e fontes devem corresponder ao fenômeno investigado. Uma estratégia adequada para avaliar ensaios de intervenção não pode ser transferida mecanicamente para estudos qualitativos, de prognóstico ou de diagnóstico. O método escolhido precisa ser justificável antes da seleção dos estudos que eventualmente sustentem uma conclusão.

**Avaliação crítica sem deferência automática à autoridade.** A importância de um periódico, a reputação de uma instituição, a existência de consenso ou a confiança expressa por um sistema de IA não eliminam a necessidade de examinar dados e métodos. Evidências e julgamentos devem ser sustentados por justificativas verificáveis, e não apenas pela posição de quem os apresenta.

**Transparência e rastreabilidade.** A conclusão deve conservar vínculos identificáveis com a pergunta, as fontes consultadas, os critérios de elegibilidade, as decisões de inclusão e exclusão, as avaliações críticas e os resultados empregados. A rastreabilidade não se limita a uma lista de referências: envolve a preservação do encadeamento de decisões que levou ao resultado comunicado.

**Reprodutibilidade proporcional ao produto.** Sempre que o método permitir, outra equipe deve conseguir compreender e reproduzir as etapas relevantes da investigação a partir dos registros disponíveis. Uma exploração inicial de campo não deve alegar exaustividade; já um produto que se identifica como revisão sistemática deve satisfazer exigências mais amplas de protocolo, busca, seleção e relato. A transparência sobre simplificações é obrigatória mesmo quando a profundidade é menor.

**Comunicação explícita da incerteza.** Resultados conflitantes, intervalos amplos, evidência indireta, lacunas de conhecimento e restrições de cobertura devem aparecer nas conclusões com linguagem proporcional à sua importância. A ausência de evidências utilizáveis deve ser distinguida de evidência capaz de sustentar a ausência de determinado efeito. Níveis de certeza, quando formalmente avaliados, não devem ser reduzidos a rótulos intuitivos sem critérios documentados.

**Independência e responsabilidade científica.** Interesses comerciais, institucionais ou pessoais não devem definir previamente os resultados. É necessário distinguir responsabilidades de elaboração, verificação metodológica, aprovação de governança e revisão especializada independente. No OES, a verificação assistida por IA não representa revisão humana ou avaliação por pares; a aprovação de governança também não substitui competência metodológica especializada. [Fonte: Documento 04 — Governança e garantia](../governance/04-governanca-garantia-revisao.md).

**Preservação do histórico.** Informações corrigidas, julgamentos modificados e produtos atualizados devem manter registro das versões anteriores e das razões para a mudança. O compromisso não é declarar uma conclusão imutável, mas tornar verificável o que se sabia, como se avaliou e por que o entendimento mudou.

Esses princípios são requisitos do modelo concebido e critérios pelos quais sua implementação deverá ser examinada. Sua formulação documental não demonstra, isoladamente, cumprimento consistente em todas as aplicações: esse cumprimento precisa ser evidenciado por revisão metodológica, testes apropriados e avaliações científicas externas.

### 2.4. Proporcionalidade metodológica

O OES parte do reconhecimento de que **rigor metodológico e profundidade de investigação não são equivalentes**. Rigor significa executar de maneira consistente e transparente os procedimentos pertinentes à finalidade declarada; profundidade diz respeito à extensão da busca, da avaliação e da síntese necessárias para responder à pergunta. Uma resposta focal pode ser rigorosa sem reproduzir todos os procedimentos de uma revisão sistemática completa, desde que não reivindique completude ou certeza que seu método não pode sustentar.

A arquitetura foi organizada em cinco níveis de investigação, de **N0 a N4**. N0 corresponde à exploração de um campo e ao reconhecimento preliminar da literatura. N1 busca responder objetivamente a uma pergunta focal quando sínteses adequadas estão disponíveis e a completude não é o objetivo. N2 estrutura uma Ficha de Evidência reutilizável e versionada. N3 compreende uma síntese rápida formal, com abreviações metodológicas previamente definidas e declaradas. N4 comporta investigações aprofundadas, incluindo revisões sistemáticas quando todos os seus requisitos forem cumpridos. Os níveis representam diferentes compromissos de método e finalidade; não constituem etapas pelas quais toda pergunta precise passar. [Fonte: Documento 02 — Arquitetura de níveis e produtos](../governance/02-niveis-investigacao-produtos.md).

A escolha deve considerar a consequência de uma conclusão incorreta, a complexidade da pergunta, a maturidade e a heterogeneidade da literatura, a incerteza existente, a necessidade de completude, a finalidade do produto e os recursos metodológicos disponíveis. A urgência de uma demanda pode justificar um método rápido, mas não a omissão silenciosa de suas restrições. Se a pergunta exige métodos ou competências que não estão disponíveis, a limitação precisa ser explicitada e pode impedir a apresentação de um produto como avaliação científica final.

Por exemplo, uma pergunta delimitada, amparada por revisão sistemática recente e metodologicamente apropriada, pode ser respondida com uma síntese focal que cite os limites de sua busca complementar. Já uma questão de segurança com consequências importantes, resultados conflitantes e fontes insuficientemente examinadas pode exigir investigação mais abrangente. Esses exemplos ilustram decisões condicionais, e não regras que substituam o julgamento científico.

A profundidade deve ser decidida mediante **roteamento metodológico documentado**, e não por uma pontuação universal que converta características heterogêneas em um nível automático. O percurso pode ser escalonado ou reduzido quando informações subsequentes demonstrarem que o método inicial era insuficiente ou excessivo, desde que a mudança seja justificada e registrada. [Fonte: Documento 03 — Triagem e roteamento metodológico](../governance/03-roteamento-metodologico.md).

A proporcionalidade também envolve **garantia científica**. Investigações mais profundas ou de maior criticidade podem demandar revisão humana especializada, independentemente de suas possibilidades tecnológicas de automação. A governança do OES já distingue níveis de garantia de A0 a A3 e estabelece requisitos diferenciados para produtos N2, N3 e N4. Assim, capacidade de gerar um produto e autorização para considerá-lo cientificamente validado são questões distintas.

### 2.5. Evidência, interpretação e recomendação

Uma distinção central do OES separa **o que foi observado e relatado**, **o que uma avaliação crítica permite inferir** e **o que alguém deve decidir fazer**. Essas três dimensões estão relacionadas, mas nenhuma decorre automaticamente da anterior.

A **evidência** inclui os dados, estimativas, resultados e achados apresentados por estudos e sínteses, acompanhados de suas condições de produção. Uma diferença entre grupos, uma associação, um achado qualitativo ou uma estimativa de prevalência precisa ser interpretado à luz da população, do desenho, das medidas e das limitações correspondentes. Preservar o resultado original e distingui-lo de transformações posteriores ajuda a evitar que a apresentação esconda escolhas analíticas relevantes.

A **interpretação científica** examina a consistência dos achados, a magnitude e a precisão das estimativas, os riscos de viés, a possibilidade de explicações alternativas e a certeza ou confiança no corpo de evidências. Também considera a distância entre as condições dos estudos e a pergunta de interesse. Essa interpretação pode sustentar conclusões graduadas, como indicação provável de benefício, resultados inconsistentes ou evidência insuficiente; não precisa produzir uma afirmação categórica quando as informações disponíveis não a justificam.

A **recomendação**, por sua vez, exige julgamentos adicionais que podem ultrapassar o escopo de um produto de síntese. Uma conclusão favorável sobre determinado desfecho não resolve, por si só, a ponderação de benefícios e danos, custos, valores e preferências, equidade, aceitabilidade, viabilidade ou prioridades do sistema de saúde. Referenciais de *Evidence to Decision* podem apoiar esse processo quando aplicáveis, mas sua utilização deve ser explícita e não presumida. [Fonte: Documento 00 — Separação entre evidência e recomendação](../governance/00-documento-de-concepcao.md).

Considere uma intervenção associada à melhora de um desfecho clínico em determinado conjunto de estudos. É possível sintetizar o tamanho do efeito e sua incerteza sem concluir que a intervenção deva ser oferecida a todas as pessoas. A decisão de uso pode depender de eventos adversos, alternativas disponíveis, características da população e recursos locais. Essa separação é particularmente importante quando os produtos do observatório serão consultados fora do contexto em que a investigação foi realizada.

Consequentemente, o OES não se apresenta como serviço de diagnóstico individual ou prescrição. Seus produtos devem comunicar **conclusões sobre evidências**, indicando claramente quando critérios de decisão ou recomendações formais não foram avaliados. O desenho das saídas procura reduzir o risco de que uma descrição científica seja interpretada como orientação clínica normativa.

### 2.6. Atualidade do conhecimento científico

Toda conclusão científica é situada no tempo. A busca bibliográfica possui uma data, uma estratégia e um escopo; o conjunto de estudos identificado corresponde a essas condições. A comunicação de resultados sem referência temporal pode levar o leitor a atribuir atualidade indevida a conclusões que talvez tenham sido produzidas antes de mudanças importantes na literatura.

Por isso, o OES prevê o registro da **data de busca**, da **data de corte da evidência** e do **histórico de versões** dos produtos. Essas informações permitem distinguir a produção de uma síntese da avaliação posterior sobre sua atualidade. Uma versão pode ter sido elaborada de maneira adequada e, ainda assim, merecer reavaliação após a publicação de estudos relevantes ou a identificação de problemas em fontes anteriormente incorporadas.

A arquitetura de atualização da Fase 4 distingue quatro dimensões: **versão científica** do conteúdo, **avaliação de atualidade** de uma versão específica, **regime de manutenção** adotado e **estado operacional/comunicacional** dos ciclos de monitoramento e dos alertas. Essa separação evita inferências indevidas. Detectar um novo artigo não significa que a conclusão mudou; emitir um alerta não equivale a executar nova síntese; e o vencimento de um ciclo programado não torna, automaticamente, cientificamente desatualizado o produto observado. [Fonte: Documento 05 — Protocolo transversal de atualização](../governance/05-protocolo-transversal-atualizacao.md).

O OES prevê quatro regimes de manutenção, de **M0 a M3**: ausência de vigilância ativa, elegibilidade para reavaliação, monitoramento ativo e evidência viva. Esses regimes são independentes da profundidade N0–N4. Uma Ficha de Evidência pode, em princípio, ser acompanhada por um Monitor; uma revisão aprofundada pode permanecer sem monitoramento ativo quando isso for justificável. A escolha depende da importância da pergunta, da probabilidade de novas informações relevantes, do potencial de mudança e da capacidade sustentável de acompanhar e avaliar a literatura.

Uma avaliação de atualização deve determinar se um sinal identificado modifica aspectos como resultados, certeza, aplicabilidade, validade da evidência ou conclusão. Quando a mudança científica é material, a arquitetura exige processo explícito de reavaliação e versionamento, preservando a versão anterior e suas condições de garantia. Quando não existe impacto material demonstrado, o evento pode ser documentado sem criar uma nova conclusão.

A formalização desses conceitos **não prova a existência de um serviço de monitoramento contínuo**. Na data de referência deste manuscrito, a Fase 4 ainda está em desenvolvimento e a operacionalização formal de evidência viva (M3) permanece bloqueada. Há componentes técnicos e testes relacionados ao monitoramento, mas eles não devem ser confundidos com vigilância factual sustentada e cientificamente validada. O compromisso com atualização é, portanto, simultaneamente um princípio metodológico, uma arquitetura em evolução e um requisito a demonstrar nas fases seguintes.


# 3. Escopo científico e definição das perguntas

### 3.1. Domínios temáticos do observatório

O escopo científico de um observatório de evidências pode ser delimitado por área clínica, problema de saúde pública, população, tecnologia ou finalidade institucional. No OES, a concepção inicial adota uma perspectiva **metodologicamente transversal**: em vez de restringir antecipadamente todas as investigações a determinada especialidade, estabelece uma estrutura capaz de tratar classes diferentes de questões de saúde, com métodos adequados a cada uma. Essa abrangência é uma **possibilidade arquitetural proposta**, não a demonstração de capacidade operacional ou cobertura efetiva de todos os temas. [Fonte: Documento 00 — Concepção](../governance/00-documento-de-concepcao.md).

Os domínios previstos incluem investigação de intervenções preventivas ou terapêuticas, segurança e eventos adversos, testes diagnósticos e rastreamento, prognóstico e predição, exposições e fatores de risco, frequência de condições, experiências de pacientes e profissionais, organização de serviços e políticas de saúde. O OES também contempla perguntas destinadas a caracterizar a distribuição da literatura e suas lacunas, sem necessariamente estimar efeitos clínicos. Esses domínios formam um repertório de problemas científicos, e não uma lista de linhas de pesquisa já implantadas. [Fonte: Documento 01 — Escopo científico e taxonomia](../governance/01-taxonomia-perguntas.md).

A delimitação temática e a delimitação metodológica não são equivalentes. Um observatório dedicado, por exemplo, à saúde mental pode receber perguntas de efetividade terapêutica, segurança, experiência do usuário, prevalência ou implementação de políticas. Embora relacionadas pelo tema, essas perguntas demandam critérios de elegibilidade, desenhos de estudo e instrumentos de avaliação diferentes. Em sentido inverso, uma arquitetura metodológica para síntese de intervenções pode ser adaptada a especialidades distintas, desde que suas premissas sejam reexaminadas no novo contexto.

Para iniciativas que desejem adaptar o modelo, a escolha do escopo deve considerar necessidades dos usuários, disponibilidade de especialistas, fontes bibliográficas relevantes, demanda previsível, recursos e consequências de conclusões incorretas. A amplitude desejada não dispensa decisões realistas de implantação: um observatório com competências restritas pode delimitar um conjunto inicial de perguntas e expandi-lo após demonstrações metodológicas específicas. Essa é uma orientação de planejamento derivada do princípio de proporcionalidade, não uma condição já cumprida pelo OES.

O contexto brasileiro poderá acrescentar uma camada de análise de aplicabilidade relacionada à epidemiologia, à organização do Sistema Único de Saúde, à disponibilidade de intervenções, à regulação e aos recursos existentes. Essa contextualização não transforma resultados internacionais em dados nacionais nem substitui estudos locais; ela ajuda a explicitar em que medida a evidência disponível responde à realidade em que poderá ser utilizada. [Fonte: Documento 01 — Camada Brasil](../governance/01-taxonomia-perguntas.md).

### 3.2. Tipologia das perguntas científicas

O OES organiza as demandas segundo **dez classes metodológicas iniciais**. A classificação precede a escolha de instrumentos e procedimentos, porque não existe uma hierarquia de estudos que seja igualmente apropriada para investigar todos os fenômenos. Um ensaio randomizado pode sustentar inferências sobre efeitos de intervenções; já uma pergunta sobre prevalência requer atenção especial à amostragem e à representatividade, enquanto uma investigação qualitativa examina experiências e significados. [Fonte: Documento 01 — Taxonomia consolidada](../governance/01-taxonomia-perguntas.md).

| Classe | Questão típica | Aspecto metodológico central |
|---|---|---|
| **Intervenção e efetividade (INT)** | Uma intervenção produz benefício em relação a determinada alternativa? | Comparadores, desfechos, estimativas de efeito e risco de viés dos estudos |
| **Segurança e eventos adversos (SAF)** | Quais danos podem ocorrer e com que frequência? | Detecção de eventos raros ou tardios e fontes complementares de segurança |
| **Diagnóstico e rastreamento (DIA)** | Com que acurácia um teste identifica uma condição? | Teste índice, padrão de referência, população e medidas de acurácia |
| **Prognóstico (PRO)** | Qual é a evolução esperada de uma condição ao longo do tempo? | População, horizonte temporal e fatores relacionados ao curso clínico |
| **Predição clínica (PRE)** | Um modelo estima adequadamente a probabilidade de um desfecho? | Validação, discriminação, calibração e utilidade do modelo |
| **Etiologia e exposição (ETI)** | Uma exposição está causalmente relacionada a determinado resultado? | Confundimento, temporalidade, seleção e interpretações causais |
| **Frequência (FREQ)** | Qual é a prevalência ou incidência de uma condição? | Definição de caso, população de referência e representatividade |
| **Experiências e fenômenos qualitativos (QUAL)** | Como um fenômeno é vivido, percebido ou interpretado? | Contexto, adequação da abordagem qualitativa e interpretação dos achados |
| **Sistemas, políticas e saúde pública (SYS)** | Qual é o efeito ou a implementação de determinada política ou serviço? | Contexto, desenhos de avaliação, implementação e efeitos populacionais |
| **Mapeamento da evidência (MAP)** | Quais estudos existem e onde estão as lacunas? | Delimitação do campo, caracterização da literatura e cobertura das fontes |

Essa taxonomia não significa que uma demanda real pertença sempre a uma única categoria. Uma investigação sobre uma tecnologia em saúde pode abranger eficácia, segurança, aceitabilidade e implementação. O protocolo do OES prevê a identificação das diferentes classes envolvidas e, quando necessário, sua **decomposição em subperguntas metodologicamente homogêneas**. As análises específicas podem ser posteriormente reunidas em uma apresentação integrada, sem que as exigências próprias de cada classe sejam apagadas.

Cada classe também admite objetivos analíticos distintos, como explorar, descrever, estimar, comparar, explicar, predizer ou investigar relações causais. A expressão vaga “o que se sabe sobre determinada doença?” pode, por exemplo, solicitar um panorama da literatura, uma estimativa epidemiológica ou uma avaliação de tratamentos. A intenção precisa ser identificada para evitar que o sistema apresente uma resposta cientificamente elaborada para uma pergunta diferente daquela que motivou a demanda.

As ferramentas de avaliação crítica são selecionadas conforme os desenhos e as finalidades, não pela adoção de um índice universal de qualidade. Entre os referenciais candidatos documentados no OES estão instrumentos apropriados para ensaios randomizados, intervenções não randomizadas, estudos de exposição, diagnóstico, prognóstico e modelos preditivos. A escolha e o uso corretos dessas ferramentas continuam sujeitos à competência metodológica e à revisão científica pertinente; a presença de seus nomes no protocolo não demonstra aplicação validada para todas as classes.

### 3.3. Formulação e estruturação das perguntas

O processamento científico começa frequentemente com uma **pergunta expressa em linguagem natural**. Essa forma deve ser preservada, inclusive quando contém ambiguidades ou pressupostos não explicitados. A estruturação subsequente não é um simples exercício de reformulação textual: ela define a unidade de análise, orienta a busca bibliográfica, estabelece a elegibilidade dos estudos e delimita o significado das conclusões que poderão ser produzidas.

A arquitetura distingue três representações sucessivas. **Q0** é a pergunta original, armazenada sem reescrita. **Q1** é sua versão normalizada, na qual se tornam explícitos os principais componentes científicos. **Q2** é a pergunta operacional, acompanhada de critérios verificáveis para executar a investigação, como população elegível, fontes, desfechos, recortes temporais, desenhos de estudo e métodos previstos. Manter a relação entre essas representações permite avaliar se o trabalho respondeu à intenção inicial e identificar alterações de escopo. [Fonte: Documento 03 — Entrada, triagem e roteamento](../governance/03-roteamento-metodologico.md).

Para perguntas de intervenção, estruturas como **PICO** ajudam a explicitar população, intervenção, comparador e desfechos, com extensões possíveis para tempo e contexto (*setting*). Nas perguntas diagnósticas, é essencial definir população, teste índice, condição-alvo e padrão de referência. Em estudos de prognóstico ou predição, o horizonte temporal e a população de aplicação precisam estar claros. Para prevalência, importam a condição, a população, o território e o período; para questões qualitativas, a formulação pode ser orientada pelo fenômeno de interesse e por seu contexto. Nenhum desses esquemas deve ser aplicado mecanicamente a todas as classes.

Considere uma demanda hipotética: “A terapia digital melhora a insônia?”. A pergunta original não informa a que população se refere, qual intervenção digital está sendo examinada, com o que será comparada ou quais resultados são relevantes. Uma formulação científica poderia restringir a população a adultos com insônia, definir um tipo específico de terapia digital, explicitar o comparador e distinguir gravidade da insônia, qualidade do sono, adesão e eventos adversos. A versão operacional acrescentaria critérios de elegibilidade, desfechos prioritários, período de busca e desenhos de estudo apropriados. O exemplo ilustra a estruturação; não representa nova investigação ou resultado científico deste manuscrito.

A definição de **desfechos críticos, importantes e exploratórios** é particularmente relevante em perguntas de intervenção. Mudanças em medidas substitutas ou biomarcadores não devem ser interpretadas automaticamente como benefícios clínicos diretamente percebidos pelos pacientes. Também é necessário registrar subgrupos e tempos de seguimento relevantes, diferenciando análises planejadas de explorações posteriores. Esses cuidados reduzem o risco de que a síntese seja conduzida apenas pelos resultados mais favoráveis encontrados na literatura.

A normalização deve preservar incertezas legítimas. Se faltam informações indispensáveis à decisão metodológica, a questão pode precisar de esclarecimento ou de um levantamento exploratório antes da busca definitiva. A concepção do OES estabelece que uma busca aprofundada deverá ocorrer **após** a definição operacional, ressalvadas buscas exploratórias destinadas justamente a compreender o campo e refinar a pergunta. [Fontes: Documentos 01 e 03](../governance/01-taxonomia-perguntas.md).

### 3.4. Admissibilidade e priorização das demandas

Nem toda solicitação dirigida a um observatório deve transformar-se imediatamente em investigação formal. A **admissibilidade** busca determinar se existe uma pergunta científica tratável dentro do escopo e das competências disponíveis. O protocolo do OES distingue demandas admissíveis, admissíveis após reformulação, fora de seu escopo científico e inadequadas como investigação formal. Esse procedimento evita prometer respostas que extrapolem a finalidade do observatório. [Fonte: Documento 03 — Admissibilidade](../governance/03-roteamento-metodologico.md).

Uma demanda referente ao diagnóstico ou à prescrição individual, por exemplo, não deve ser tratada como consulta clínica personalizada. Quando pertinente, pode ser reformulada como pergunta científica geral sobre intervenções, testes ou resultados em uma população definida. Também podem exigir reformulação perguntas excessivamente amplas, formuladas como alegações retóricas ou que misturem fenômenos sem um recorte analítico viável.

A **priorização** responde a problema diferente: entre demandas potencialmente admissíveis, quais devem receber atenção primeiro e com que investimento metodológico? O OES documenta dimensões relevantes para essa decisão, incluindo criticidade, complexidade, maturidade da literatura, incerteza, necessidade de completude, síntese quantitativa, aplicabilidade, volatilidade da evidência e urgência. A consequência de uma conclusão incorreta é um elemento importante: produtos destinados a apoiar decisões com potencial significativo de dano exigem cuidado metodológico e garantia compatíveis.

Urgência e criticidade não são sinônimos. Uma pergunta pode ser urgente e relativamente simples; outra pode ser altamente crítica sem prazo imediato. A urgência poderá justificar métodos rápidos com limitações declaradas, mas não elimina requisitos de qualidade nem autoriza apresentar uma busca seletiva como revisão exaustiva. Além disso, a relevância de uma demanda para pesquisadores ou gestores não demonstra, por si só, que exista capacidade instalada para respondê-la no nível desejado.

O protocolo inicial **não adota pesos numéricos universais nem uma pontuação automática** para ordenar as dimensões ou converter o perfil da pergunta em nível N0–N4. As escolhas dependem de justificativa metodológica registrada. A seleção efetiva de uma carteira de temas, com critérios institucionais de alocação de recursos ou impacto social, precisará ser contextualizada e validada na governança de cada observatório que vier a utilizar o modelo.

A ausência de evidências adequadas também constitui um resultado possível. Uma investigação não deve ser artificialmente aprofundada apenas para produzir uma conclusão positiva. Quando a literatura é incipiente ou fragmentada, identificar limites do conhecimento e formular perguntas de pesquisa adicionais pode ser a resposta científica mais apropriada.

### 3.5. Roteamento metodológico

Após a admissibilidade e a estruturação da demanda, o **roteamento metodológico** define a modalidade de investigação mais adequada à pergunta e à finalidade declarada. No OES, esse fluxo está descrito em etapas sucessivas, da entrada à abertura formal: **E0 — entrada; E1 — registro; E2 — admissibilidade; E3 — clarificação da intenção; E4 — normalização científica; E5 — classificação metodológica; E6 — avaliação de roteamento; E7 — escaneamento preliminar, quando necessário; E8 — definição da rota; e E9 — abertura formal da investigação**. Essa sequência é uma especificação de processo e não deve ser confundida com garantia de sua execução automatizada em produção. [Fonte: Documento 03 — Protocolo de roteamento](../governance/03-roteamento-metodologico.md).

A primeira decisão é identificar o tipo de pergunta e seu objetivo analítico. A segunda consiste em avaliar a profundidade apropriada. Uma investigação exploratória poderá adotar **N0**; uma resposta focal baseada em sínteses existentes, **N1**; uma avaliação estruturada persistente, **N2**; uma síntese rápida formal, **N3**; e uma investigação aprofundada ou revisão sistemática, quando seus requisitos estiverem presentes, **N4**. Mapas de evidências e *overviews* de revisões seguem rotas próprias, compatíveis com a natureza de seus objetos de análise. A progressão N0–N4 não é obrigatória ou automática.

A escolha do nível considera se existem revisões suficientemente recentes e adequadas à pergunta. Antes de iniciar uma investigação extensa, é metodologicamente pertinente verificar a possibilidade de **adotar criticamente uma síntese existente**, complementá-la com estudos posteriores ou desenvolver uma Ficha de Evidência que reúna resultados e julgamentos relevantes. Essa avaliação requer examinar a correspondência da revisão à pergunta operacional, suas buscas, elegibilidade, cobertura, métodos, atualidade e aplicabilidade. O simples título “revisão sistemática” não dispensa avaliação crítica.

O roteamento abrange ainda uma dimensão independente da profundidade: o **regime de manutenção M0–M3**. Ele descreve como determinada investigação ou produto poderá ser acompanhado ao longo do tempo, desde a ausência de vigilância ativa até um regime de evidência viva. A escolha do regime não aumenta automaticamente a profundidade da investigação nem autoriza revisão científica sem os controles correspondentes. Na data de referência, a Fase 4 permanece em desenvolvimento e o regime M3 não deve ser descrito como operacionalizado.

O processo deve gerar um **registro de roteamento** que preserve a identidade da pergunta, sua classe, finalidade, dimensões de avaliação, contexto, nível de profundidade, regime de manutenção, produto e justificativa. O esquema conceitual prevê identificadores relacionados para perguntas e investigações e documentação das decisões relevantes. Esse registro permite auditar por que determinado método foi escolhido e fundamentar uma eventual mudança de rota. [Fonte: Documento 03 — *Routing Record*](../governance/03-roteamento-metodologico.md).

O **reroteamento** pode ser necessário após um escaneamento ou durante a investigação. A descoberta de revisões robustas pode reduzir a necessidade de uma nova síntese aprofundada; a identificação de resultados contraditórios, riscos importantes ou lacunas inesperadas pode justificar aprofundamento. A decisão precisa ser documentada, preservando as versões anteriores e evitando uma alteração retrospectiva invisível do método.

Por fim, o roteamento não equivale a um *gate* de validade científica. Uma ferramenta de IA pode auxiliar na leitura da demanda, sugerir a classe ou identificar ambiguidades, mas essas sugestões não substituem competência especializada quando ela é exigida. Em particular, os produtos formais N3 e N4 mantêm requisitos de revisão humana qualificada; a ausência desses requisitos impede que a simples geração técnica seja apresentada como produto final cientificamente assegurado. [Fonte: Documento 04 — Governança de garantia](../governance/04-governanca-garantia-revisao.md).

Dessa forma, a definição da pergunta não constitui apenas a etapa inicial do OES. Ela funciona como **mecanismo de controle de coerência** ao longo de todo o percurso: orienta a elegibilidade, limita as inferências justificáveis, determina a forma de comunicar resultados e estabelece o objeto que poderá ser monitorado e atualizado.


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

*Fim da versão 0.3 — a apresentação e os Capítulos 1–3 constituem texto corrido desenvolvido nesta versão. Os Capítulos 4–16 são um plano estrutural de redação, não conteúdo científico já concluído.*
