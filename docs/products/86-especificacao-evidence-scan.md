# 86 — Especificação Científica e Funcional do Evidence Scan — N0

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — especificação inicial consolidada  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 00, 02, 03, 04, 10–15, 20–21, 28–29, 38, 40 e 85  
**Baseline arquitetural:** OES-P1  
**Produto:** OES — Evidence Scan  
**Nível típico:** N0

---

# 1. Finalidade

Este documento define o **contrato científico e funcional do Evidence Scan do OES** antes da criação de qualquer contrato de dados específico, view, template ou automação dedicada.

O Evidence Scan deverá funcionar como:

> **produto exploratório, rápido e rastreável destinado a reconhecer a estrutura de um campo de evidências, reduzir incerteza sobre a própria pergunta e orientar o roteamento metodológico subsequente.**

Seu objetivo principal não é responder de forma conclusiva uma pergunta clínica focal.

O Evidence Scan deverá ajudar a determinar:

- como o campo está organizado;
- que terminologia é utilizada;
- que tipos de estudo predominam;
- se existem revisões sistemáticas, meta-análises, diretrizes ou HTAs relevantes;
- quão recente parece ser a evidência;
- se a literatura parece ampla, escassa, fragmentada ou conflitante;
- quais subperguntas relevantes emergem;
- quais lacunas ou controvérsias aparentes existem;
- se a pergunta original precisa ser reformulada;
- qual profundidade N0–N4 parece proporcional para a etapa seguinte.

---

# 2. Papel na arquitetura de produtos

O Evidence Scan é o produto típico de **N0**.

Regra estrutural mínima:

`Question(Q0/Q1) → Investigation(N0) → exploratory searches → selected evidence signals → Product(Evidence Scan)`

Diferentemente de N1/N2, N0 pode ser executado quando a pergunta ainda não possui uma Q2 operacional totalmente estabilizada.

O scan poderá:

- preservar a pergunta original;
- produzir uma pergunta exploratória normalizada;
- identificar candidatos a subperguntas;
- recomendar uma Q1/Q2 posterior;
- recomendar encerramento sem investigação adicional quando a finalidade já tiver sido satisfeita.

O Evidence Scan não deverá duplicar entidades científicas já existentes no OES-P1 quando puder reutilizá-las.

---

# 3. Pergunta central do Evidence Scan

O Evidence Scan responde prioritariamente:

> **Que tipo de campo de evidências existe em torno desta questão, como ele parece se organizar e qual investigação deveria ocorrer a seguir?**

Ele não responde prioritariamente:

> **Qual é o efeito, associação, acurácia, prevalência ou certeza final para uma pergunta focal?**

Essa distinção é obrigatória.

---

# 4. Fronteiras com produtos adjacentes

## 4.1 Evidence Scan versus Resposta de Evidência — N1

Evidence Scan:

- pode começar com pergunta ampla ou ainda instável;
- busca reconhecer o campo;
- prioriza descoberta de fontes e estrutura;
- pode trabalhar com terminologia ainda em refinamento;
- não precisa identificar uma única fonte decisiva;
- não exige conclusão focal de efeito/associação;
- não exige appraisal formal das fontes por padrão.

Resposta de Evidência N1:

- exige pergunta focal;
- exige fontes decisivas identificadas;
- exige verificação das afirmações materiais;
- exige avaliação crítica proporcional;
- produz resposta sintética à pergunta.

Regra de transição:

> se o scan já permitir formular pergunta focal e localizar sínteses recentes adequadas, o próximo produto preferencial será N1, salvo motivo para N2–N4.

## 4.2 Evidence Scan versus Ficha de Evidência — N2

Evidence Scan não é unidade persistente central de conhecimento focal.

Não exige por padrão:

- reconstrução formal de Results;
- Synthesis;
- CertaintyAssessment;
- RiskAssessment estruturado;
- monitoramento persistente;
- versionamento científico longitudinal detalhado.

Quando o conhecimento precisar permanecer reutilizável e atualizado como unidade focal do acervo, considerar N2.

## 4.3 Evidence Scan versus Mapa de Evidências

Evidence Scan é uma **exploração proporcional**.

Mapa de Evidências é produto analítico próprio destinado a representar sistematicamente distribuição e lacunas da evidência.

Evidence Scan:

- pode estimar volume;
- pode descrever distribuição aparente;
- pode identificar lacunas preliminares.

Não poderá apresentar:

- contagem como exaustiva;
- cobertura como sistemática;
- matriz de evidência como completa;
- “evidence gap map” formal;

sem método correspondente.

Se a pergunta central passar a ser “que evidência existe e onde estão as lacunas?” com necessidade de cobertura sistemática, rerrotear para Mapa de Evidências.

## 4.4 Evidence Scan versus scoping review

Evidence Scan não deverá ser chamado de scoping review.

Uma scoping review exige método próprio, maior completude e documentação compatível.

O scan poderá indicar que uma scoping review seria a rota apropriada.

---

# 5. Critérios de elegibilidade para N0

N0 é apropriado quando uma ou mais condições materiais estiverem presentes:

1. pergunta ampla;
2. campo ainda desconhecido;
3. terminologia incerta;
4. existência de sínteses desconhecida;
5. volume e diversidade da literatura desconhecidos;
6. necessidade de definir subperguntas;
7. dúvida sobre melhor enquadramento científico;
8. necessidade de decidir entre N1–N4;
9. necessidade de reconhecer rapidamente controvérsias aparentes;
10. necessidade de avaliar maturidade inicial antes de investimento metodológico maior.

O Routing Record deverá justificar o uso de N0.

---

# 6. Situações em que N0 é inadequado

N0 não deverá ser utilizado como produto final quando:

- a finalidade real for responder pergunta clínica focal;
- houver decisão relevante que dependa de conclusão científica;
- a pergunta exigir magnitude de efeito confiável;
- for necessária certainty formal;
- houver finalidade normativa/regulatória;
- houver necessidade de completude;
- houver necessidade de síntese quantitativa;
- o usuário solicitar revisão sistemática, síntese rápida formal ou avaliação de certeza;
- o campo já estiver suficientemente conhecido e a pergunta focal já puder ser roteada diretamente.

N0 não deverá ser usado para economizar método quando um nível superior é necessário.

---

# 7. Unidade científica do scan

A unidade primária será:

> **uma pergunta original ou exploratória vinculada a uma Investigation N0 e delimitada por uma data de corte.**

A pergunta poderá estar em três estados:

### Q0 — original

Preservada exatamente como submetida.

### Q1 — normalizada exploratória

Organiza população, conceito, contexto, intervenção/exposição ou outros elementos disponíveis sem forçar precisão inexistente.

### Q2 — candidata

Quando o scan produzir base suficiente para recomendar uma pergunta operacional futura.

O Evidence Scan pode encerrar sem Q2 final.

---

# 8. Método mínimo

O Evidence Scan deverá registrar no mínimo:

1. pergunta original;
2. objetivo exploratório;
3. pergunta normalizada exploratória quando possível;
4. fontes consultadas;
5. data(s) da busca;
6. estratégias ou conceitos de busca suficientes para rastreabilidade proporcional;
7. principais sínteses/referências identificadas;
8. sinais sobre volume/diversidade;
9. terminologia relevante;
10. controvérsias ou divergências aparentes;
11. lacunas preliminares;
12. limitações da busca;
13. conclusão exploratória;
14. classificação preliminar da maturidade do campo;
15. recomendação de roteamento;
16. data de corte.

---

# 9. Busca e recuperação

## 9.1 Princípio

A busca N0 deverá ser:

> **exploratória, estruturada o suficiente para ser auditável, iterativa e explicitamente não exaustiva.**

O scan pode ajustar termos conforme aprende sobre o campo.

Essa iteração deverá ser registrada quando material.

## 9.2 Fontes

Conforme a pergunta, o scan poderá utilizar:

- PubMed/MEDLINE;
- bases de revisões/sínteses;
- BVS/LILACS;
- CENTRAL;
- bases especializadas;
- registros de estudos;
- diretrizes;
- HTAs;
- fontes institucionais;
- citation chasing seletivo;
- mecanismos de descoberta bibliográfica.

Não existe número universal obrigatório de bases em N0.

## 9.3 Cobertura mínima proporcional

Como padrão inicial, o scan deverá consultar:

- pelo menos uma fonte bibliográfica principal; e
- quando materialmente aplicável, uma fonte orientada a sínteses, diretrizes ou evidência secundária.

Exceções deverão ser justificadas.

## 9.4 Estratégia iterativa

A busca poderá ocorrer em ciclos:

1. termos iniciais;
2. descoberta de vocabulário;
3. refinamento;
4. busca por sínteses;
5. busca por subtemas ou controvérsias aparentes.

A sequência não precisa simular estratégia definitiva de revisão.

## 9.5 Contagem de resultados

Hit counts poderão ser registrados como:

> **estimativas operacionais da busca executada**

e não como medida estável do tamanho total do campo.

Não usar contagens de mecanismos diferentes como se fossem comparáveis sem qualificação.

---

# 10. Seleção das fontes

A seleção no Evidence Scan é orientada por **informatividade exploratória**.

Priorizar fontes capazes de revelar:

- terminologia;
- estrutura do campo;
- revisões existentes;
- principais tipos de estudos;
- controvérsias;
- atualidade;
- lacunas aparentes.

Não é necessário:

- documentar exclusão de cada registro;
- executar triagem duplicada;
- construir fluxo PRISMA;
- capturar todos os estudos elegíveis.

Entretanto:

> toda fonte usada para sustentar uma afirmação material do scan deverá ser identificável.

---

# 11. Tipos de evidência preferenciais

A ordem de descoberta poderá favorecer:

1. revisões sistemáticas e meta-análises;
2. scoping reviews/evidence maps quando disponíveis;
3. diretrizes e HTAs;
4. revisões narrativas de alta utilidade contextual;
5. estudos primários recentes ou seminais;
6. registros de estudos;
7. fontes institucionais relevantes.

Essa ordem serve à exploração e não constitui hierarquia automática de validade.

---

# 12. Appraisal

## 12.1 Regra

Evidence Scan não exige appraisal formal completo por padrão.

Entretanto, deverá evitar tratar:

- revisão sistemática;
- meta-análise;
- diretriz;
- guideline;
- consensus statement;

como sinônimo de fonte confiável apenas pelo rótulo.

## 12.2 Checagem mínima

Para fontes centrais usadas na descrição do campo, avaliar de forma proporcional:

- correspondência com o tema;
- atualidade;
- desenho;
- escopo;
- origem;
- limitações aparentes;
- existência de sinais evidentes de baixa confiabilidade.

## 12.3 Quando escalar appraisal

Se o scan começar a depender de uma fonte para produzir afirmação científica focal sobre efeito, magnitude ou certeza:

> o produto está deixando de ser N0.

Rerrotear para N1+ ou executar investigação adicional apropriada.

---

# 13. Extração

A extração será exploratória e mínima.

Campos possíveis:

- título;
- tipo de publicação;
- ano;
- população/tema;
- intervenção/exposição;
- principais desfechos;
- número aproximado de estudos;
- período coberto;
- conclusão da fonte;
- limitações reportadas;
- identificadores persistentes.

Não é requisito:

- formulário de extração completo;
- dupla extração;
- captura de todas as características;
- normalização quantitativa de resultados.

Valores numéricos poderão ser extraídos quando ajudarem a caracterizar o campo, mas não deverão ser reinterpretados como síntese OES N0.

---

# 14. Síntese permitida

O Evidence Scan poderá produzir:

- síntese descritiva do campo;
- agrupamento por temas;
- classificação de maturidade;
- identificação de subcampos;
- lista de sínteses relevantes;
- descrição de controvérsias;
- descrição preliminar de lacunas;
- recomendação de roteamento.

Não deverá produzir:

- nova meta-análise;
- pooled estimate;
- Summary of Findings;
- Evidence Profile;
- certeza formal;
- recomendação clínica;
- conclusão causal focal não sustentada por nível adequado.

---

# 15. Classificação de maturidade do campo

O scan poderá utilizar as categorias descritivas já previstas no Documento 03:

- **bem sintetizado**;
- **parcialmente sintetizado**;
- **fragmentado**;
- **emergente**;
- **saturado**;
- **insuficiente**.

Essas categorias são:

> **julgamentos operacionais de roteamento**, não scores científicos.

## 15.1 Bem sintetizado

Há sínteses recentes e suficientemente aderentes capazes de sustentar investigação focal mais eficiente.

Rota provável:

- N1 ou N2.

## 15.2 Parcialmente sintetizado

Existem sínteses, mas deixam subquestões, desfechos, populações ou atualizações relevantes sem cobertura adequada.

Rota provável:

- N1/N2 com atualização;
- N3 conforme criticidade.

## 15.3 Fragmentado

A evidência existe, mas está dispersa entre desenhos, populações, intervenções ou conceitos, sem síntese adequada.

Rota provável:

- Mapa/Overview;
- N3/N4;
- reformulação da pergunta.

## 15.4 Emergente

Poucos estudos, terminologia ainda instável ou campo em rápida formação.

Rota provável:

- N1 seletivo;
- N2/M2;
- monitoramento futuro.

## 15.5 Saturado

Grande volume e múltiplas sínteses, potencialmente redundantes.

Rota provável:

- Overview;
- seleção crítica da melhor síntese;
- evitar nova revisão primária desnecessária.

## 15.6 Insuficiente

Não foi localizada evidência suficiente para definir investigação produtiva ou responder à pergunta.

Isso não significa prova de ausência de efeito.

---

# 16. Controvérsias e conflitos

O scan poderá registrar:

> **sinal de controvérsia**

quando localizar fontes relevantes com conclusões aparentemente divergentes.

Não deverá tentar resolver definitivamente o conflito sem método adequado.

A saída deverá diferenciar:

- controvérsia aparente;
- conflito metodológico conhecido;
- diferença de população/intervenção/desfecho;
- diferença temporal;
- diferença ainda não explicada.

Conflito material é um gatilho de rerroteamento.

---

# 17. Lacunas

Lacunas no Evidence Scan são:

> **lacunas preliminares aparentes dentro da cobertura exploratória executada.**

Não declarar:

- “não existe evidência”;
- “nenhum estudo foi publicado”;
- “esta é uma lacuna definitiva”;

salvo quando uma busca adequada ao nível dessa afirmação tiver sido realizada.

Preferir:

- “não localizado nesta busca exploratória”;
- “evidência não identificada nas fontes consultadas”;
- “aparente escassez de sínteses”.

---

# 18. Certeza/confiança

Evidence Scan:

> **não produz nova avaliação formal de certeza/confiança.**

Quando uma fonte central reportar GRADE/CERQual ou outro framework:

- o scan poderá registrar que a avaliação existe;
- deverá identificar a fonte/framework;
- não deverá incorporar automaticamente o nível como julgamento OES;
- não deverá usar certainty externa para transformar o scan em resposta focal.

Saída padrão:

> **Certeza/confiança formal: não avaliada pelo OES neste Evidence Scan.**

---

# 19. Aplicabilidade

A análise de aplicabilidade em N0 é apenas exploratória.

Pode identificar:

- países/contextos predominantes;
- presença ou ausência aparente de estudos brasileiros;
- tipos de sistema de saúde;
- populações pouco representadas.

Não deverá produzir score ou julgamento formal de transferibilidade.

---

# 20. Conclusão exploratória

A conclusão do Evidence Scan deverá responder:

1. como o campo parece estar estruturado;
2. que tipo de evidência foi localizada;
3. qual a maturidade preliminar;
4. quais controvérsias/lacunas são aparentes;
5. se a pergunta deve ser reformulada;
6. qual rota metodológica é recomendada.

Exemplo conceitual:

> **O campo parece bem sintetizado, com revisões sistemáticas recentes e múltiplos RCTs. A pergunta original é ampla e deve ser dividida por população e desfecho. Para a pergunta focal principal, uma Resposta de Evidência N1 parece proporcional.**

Essa formulação é adequada a N0.

Uma formulação como:

> “A intervenção reduz mortalidade”

não é conclusão adequada de N0 sem investigação focal correspondente.

---

# 21. Roteamento posterior

Toda saída N0 deverá registrar uma das decisões:

- encerrar após scan;
- reformular pergunta e repetir N0;
- N1 — Resposta de Evidência;
- N2 — Ficha de Evidência;
- N3 — Síntese Rápida;
- N4 — Revisão de Evidências;
- Mapa de Evidências;
- Overview de Revisões;
- outra rota justificada.

A recomendação deverá incluir justificativa.

---

# 22. Rerroteamento durante o próprio scan

O scan poderá ser interrompido e rerroteado quando ficar claro que:

- a pergunta já é focal e facilmente respondível por síntese adequada;
- a criticidade exige investigação superior;
- há conflito material;
- é necessária busca sistemática;
- uma avaliação quantitativa é necessária;
- o campo é tão fragmentado que um mapa/scoping review é mais apropriado.

O rerroteamento deverá ser registrado, não escondido.

---

# 23. Manutenção

Compatibilidade preferencial:

- **M0 — estático**;
- **M1 — elegível para atualização**.

M2/M3 não são apropriados para manter um mero scan de forma permanente.

Se monitoramento contínuo for necessário:

> criar ou vincular produto/investigação mais apropriado.

---

# 24. Persistência

Evidence Scan pode existir em dois regimes.

## 24.1 Scan operacional interno

Finalidade:

- apoiar roteamento;
- orientar reformulação;
- servir como etapa de descoberta.

Pode ser preservado como artefato operacional sem necessariamente se tornar produto publicado do catálogo.

## 24.2 Evidence Scan formal persistente

Quando o scan possuir:

- Product ID;
- ProductVersion;
- data de corte;
- estado editorial;
- conclusão exploratória;
- referências;
- provenance;
- publicação no acervo OES;

ele passa a ser produto formal persistente e deverá cumprir o publication gate N0.

---

# 25. Assurance e publication gate

## 25.1 Regra geral

Conforme Documento 04:

> **N0 pode exigir A1 ou A2 conforme persistência/uso.**

## 25.2 Scan operacional interno

Um scan interno que serve apenas ao roteamento pode concluir a etapa em:

> **A1 — verificação metodológica assistida por IA concluída**

sem owner approval obrigatória.

Ele não deverá ser apresentado como produto formal publicado do acervo.

## 25.3 Evidence Scan formal persistente

Para publicação formal no acervo OES, exigir:

> **A2**

com:

- AI methodological verification = `passed`;
- owner governance approval = `approved`;
- ausência de decisões ativas `revise`/`failed`/`rejected`;
- disclosure de ausência de expert independent review quando aplicável;
- publication_date somente após fechamento do conteúdo.

## 25.4 Expert review

Não é requisito padrão de N0.

A3 poderá existir quando houver motivo específico.

---

# 26. Verificação metodológica por IA em N0

A segunda passagem deverá verificar principalmente:

- se o scan está sendo apresentado como exploratório;
- se não existe alegação indevida de exaustividade;
- se as principais fontes realmente existem e correspondem ao campo;
- se afirmações sobre volume são qualificadas;
- se lacunas são descritas como aparentes;
- se controvérsias não são “resolvidas” sem método;
- se não foi produzida conclusão clínica focal indevida;
- se a recomendação de roteamento é coerente;
- se limitações são visíveis.

Não é necessário simular appraisal N1/N2 quando o produto não faz afirmações que o exijam.

---

# 27. Provenance

Toda afirmação material deverá ser rastreável em nível proporcional.

Especialmente:

- existência de síntese relevante;
- número de estudos reportado por uma revisão;
- classificação de desenho;
- ano/data;
- afirmação de controvérsia;
- existência de diretriz/HTA;
- informação de atualização.

Entretanto, a provenance N0 não precisa reconstruir todo o corpo de estudos primários.

---

# 28. Elementos mínimos do produto

Todo Evidence Scan formal deverá conter:

1. Product ID e versão;
2. pergunta original;
3. pergunta exploratória/normalizada;
4. objetivo do scan;
5. profundidade N0;
6. manutenção M;
7. data de início;
8. data de corte;
9. fontes consultadas;
10. estratégia/conceitos de busca;
11. terminologia relevante;
12. sínteses e referências centrais;
13. descrição do campo;
14. volume/diversidade em linguagem proporcional;
15. maturidade preliminar;
16. controvérsias aparentes;
17. lacunas aparentes;
18. limitações;
19. conclusão exploratória;
20. recomendação de roteamento;
21. assurance/disclosure quando formal;
22. referências/provenance.

---

# 29. Elementos condicionais

Conforme o caso:

- subperguntas candidatas;
- classificação temática;
- cronologia preliminar;
- geografia;
- desenhos predominantes;
- evidence map/scoping review já existente;
- diretrizes/HTAs;
- registros de estudos;
- contexto brasileiro;
- sinais de atualização rápida;
- candidatos a fontes decisivas para N1.

---

# 30. Elementos que não devem ser obrigatórios

Não tornar obrigatórios em N0:

- Synthesis;
- CertaintyAssessment;
- RiskAssessment formal;
- Outcome estruturado;
- Result estruturado;
- screening completo;
- PRISMA;
- meta-análise;
- dupla triagem;
- dupla extração;
- Summary of Findings;
- protocolo de revisão sistemática.

Criar essas estruturas artificialmente transformaria N0 em produto mais profundo sem necessidade.

---

# 31. Critérios de publicação de um Evidence Scan formal

Antes de publicação formal, verificar:

1. ProductVersion válida;
2. Investigation N0 primária;
3. pergunta original preservada;
4. objetivo exploratório explícito;
5. pelo menos uma busca/fonte de descoberta registrada;
6. fontes centrais rastreáveis;
7. data de corte;
8. limitação de não exaustividade explícita;
9. conclusão estritamente exploratória;
10. maturidade/roteamento justificados;
11. ausência de recomendação clínica automática;
12. AI methodological verification = passed;
13. owner approval = approved;
14. nenhuma assurance ativa bloqueante;
15. publication_date;
16. ausência de expert review divulgada quando A3 não existir.

---

# 32. Critérios de inadequação antes da publicação

Bloquear publicação formal se houver:

- alegação de exaustividade incompatível com N0;
- conclusão focal de efeito apresentada como se fosse N1+;
- recomendação normativa;
- fonte central sem rastreabilidade;
- ausência de limitações;
- ausência de data de corte;
- ausência de roteamento ou justificativa para encerramento;
- assurance insuficiente;
- conflito aparente ocultado;
- afirmação de “nenhuma evidência” baseada apenas em busca exploratória limitada.

---

# 33. IA permitida

IA poderá apoiar:

- expansão de terminologia;
- tradução de conceitos em estratégias iniciais;
- deduplicação exploratória;
- agrupamento temático;
- classificação de desenhos;
- identificação de sínteses;
- extração de metadados;
- comparação entre escopos de revisões;
- detecção de aparentes controvérsias;
- proposta de reformulação da pergunta;
- proposta de roteamento.

Tudo permanece sujeito a verificação das fontes materiais.

---

# 34. IA não autorizada

IA não poderá:

- inventar referências;
- afirmar completude;
- transformar busca limitada em ausência de evidência;
- criar certeza formal;
- inferir causalidade não estabelecida;
- converter scan em recomendação;
- ocultar conflito;
- tratar contagens instáveis como tamanho real do universo científico;
- promover ou rebaixar produto sem justificativa documentada.

---

# 35. Relação com OES-P1

Hipótese arquitetural inicial:

> **OES-P1 provavelmente é suficiente para representar um Evidence Scan sem nova entidade científica central.**

Elementos potencialmente reutilizáveis:

- Question/QuestionVersion;
- Investigation/InvestigationVersion;
- Search;
- SearchHit;
- ScreeningDecision quando usado;
- Report/ReportVersion;
- provenance;
- dependency graph;
- Product/ProductVersion;
- currency state;
- assurance records.

A eventual necessidade de campos específicos do scan deverá ser avaliada no próximo documento.

Nenhuma migration deverá ser criada antes dessa revisão.

---

# 36. Próxima etapa

Realizar:

> **revisão de coerência e decisão arquitetural inicial do Evidence Scan — N0**

Objetivos:

1. verificar se OES-P1 + migration 012 já suportam N0;
2. mapear cada elemento do contrato científico para estruturas existentes;
3. identificar lacunas reais versus conveniências de apresentação;
4. evitar criar tabelas específicas sem necessidade;
5. definir se o próximo artefato deverá ser contrato de dados ou apenas projeção derivada.

Somente após essa revisão deverá ser criado qualquer schema, migration, view ou template N0.

---

**Documento vivo. Alterações materiais deverão ser registradas no CHANGELOG.md.**
