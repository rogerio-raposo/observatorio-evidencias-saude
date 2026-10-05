# 68 — Especificação Científica e Funcional da Resposta de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — especificação inicial consolidada  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 00, 02, 03, 04, 10–15, 20–21, 28–29, 38, 40 e 67  
**Baseline arquitetural:** OES-P1  
**Produto:** OES — Resposta de Evidência  
**Nível típico:** N1

---

# 1. Finalidade

Este documento define o **contrato científico e funcional da Resposta de Evidência do OES** antes da criação de qualquer template operacional, contrato físico específico ou automação dedicada.

A Resposta de Evidência deverá funcionar como:

> **produto focal, objetivo e proporcional para responder uma pergunta delimitada quando existirem sínteses recentes e suficientemente adequadas, sem pretensão de busca exaustiva nem de reconstrução completa do corpo de evidências.**

Seu objetivo é produzir uma resposta tecnicamente verificável com menor profundidade operacional que uma Ficha de Evidência N2, preservando transparência sobre:

- pergunta respondida;
- escopo efetivamente investigado;
- método de busca utilizado;
- fontes decisivas;
- principais resultados;
- certeza/confiança disponível;
- limitações;
- aplicabilidade quando pertinente;
- data de corte;
- nível de garantia metodológica.

A Resposta de Evidência não deverá ser usada para simular investigação mais profunda do que a realmente executada.

---

# 2. Papel na arquitetura de produtos

A Resposta de Evidência é o produto típico de **N1**.

Regra estrutural:

`Question → Investigation(N1) → Evidence sources → Product(Resposta de Evidência)`

Quando existirem objetos científicos estruturados já disponíveis no OES, a Resposta poderá reutilizá-los.

Exemplos:

- síntese previamente estruturada;
- RiskAssessment existente;
- CertaintyAssessment existente;
- Ficha de Evidência vigente;
- investigação N2–N4 previamente concluída.

A Resposta não deverá duplicar como nova fonte canônica aquilo que já estiver estruturado no OES-P1.

---

# 3. Fronteiras com produtos adjacentes

## 3.1 Resposta de Evidência versus Evidence Scan — N0

O **Evidence Scan** responde principalmente:

> **como é o campo e que evidência parece existir?**

A **Resposta de Evidência** responde:

> **o que a melhor evidência disponível permite dizer sobre esta pergunta focal?**

Portanto, N1 exige mais que exploração.

A Resposta deverá possuir:

- pergunta focal explícita;
- critérios de relevância;
- fontes decisivas identificadas;
- verificação das afirmações materiais;
- conclusão coerente com as fontes;
- incerteza explicitada.

Se a pergunta ainda estiver ampla, mal definida ou depender principalmente de mapeamento do campo, deverá permanecer N0 ou ser rerroteada.

## 3.2 Resposta de Evidência versus Ficha de Evidência — N2

A **Ficha de Evidência** é a unidade persistente central de conhecimento para perguntas focais reutilizáveis.

A Resposta de Evidência não exige, por padrão:

- reconstrução formal do corpo completo de evidências;
- estruturação de todas as entidades científicas relevantes;
- nova avaliação formal de certainty;
- appraisal formal de todas as fontes;
- atualização persistente;
- monitoramento longitudinal.

A Resposta N1 deverá ser rerroteada para N2 quando:

- a pergunta deva permanecer como unidade reutilizável do acervo;
- rastreabilidade científica mais granular seja necessária;
- certainty formal nova seja material;
- múltiplas fontes conflitantes exijam avaliação mais estruturada;
- a resposta dependa de atualização sistemática de síntese;
- manutenção M2/M3 seja pretendida;
- o nível de criticidade torne a profundidade N1 insuficiente.

## 3.3 Resposta de Evidência versus N3/N4

N1 não deverá ser usado para:

- sustentar alegação de busca completa;
- executar revisão sistemática abreviada sem declará-la;
- substituir Síntese Rápida N3 quando houver decisão relevante exigindo método sistemático;
- substituir Revisão de Evidências N4 em alta criticidade, conflito importante, finalidade normativa ou necessidade de completude.

---

# 4. Critérios de elegibilidade para N1

Uma investigação poderá ser roteada para Resposta de Evidência quando, em conjunto:

1. a pergunta for focal;
2. existirem sínteses recentes e suficientemente aderentes;
3. a necessidade de completude for limitada;
4. a criticidade for compatível com abordagem proporcional;
5. não houver necessidade de produzir nova revisão sistemática;
6. eventual atualização por estudos posteriores puder ser tratada de forma seletiva e transparente;
7. uma investigação N2–N4 for desproporcional à necessidade informacional.

O Routing Record deverá registrar a justificativa.

---

# 5. Critérios de rerroteamento

A investigação deverá ser reconsiderada antes da publicação quando forem identificados:

- ausência de síntese adequada;
- sínteses decisivas muito desatualizadas;
- conflito material entre sínteses robustas;
- corpo de estudos primários posterior capaz de alterar substancialmente a conclusão;
- necessidade de nova meta-análise;
- necessidade de nova certainty formal;
- heterogeneidade ou complexidade que impeça resposta proporcional;
- alta criticidade;
- finalidade de diretriz, política, incorporação tecnológica, regulação ou decisão individual de alto risco;
- necessidade de manutenção persistente.

Nesses casos, considerar N2, N3, N4 ou rota transversal apropriada.

---

# 6. Unidade científica da resposta

A unidade primária será:

> **uma pergunta focal vinculada a uma Investigation N1 e delimitada por uma data de corte.**

A pergunta poderá ser estruturada conforme o tipo científico pertinente:

- intervenção;
- diagnóstico;
- prognóstico;
- etiologia/exposição;
- prevalência/incidência;
- experiência/fenômeno;
- sistema/serviço;
- política/implementação;
- segurança;
- outra classe prevista na taxonomia OES.

A estruturação deverá ser suficiente para avaliar correspondência entre a pergunta e as fontes utilizadas.

---

# 7. Método mínimo

A Resposta de Evidência exige, no mínimo:

1. pergunta focal explícita;
2. busca estruturada, ainda que seletiva;
3. critérios de relevância explícitos;
4. prioridade a sínteses recentes e adequadas;
5. registro das fontes decisivas selecionadas;
6. verificação de estudos primários decisivos ou posteriores quando pertinente;
7. avaliação crítica proporcional das fontes decisivas;
8. conferência dos dados e afirmações materiais que sustentam a conclusão;
9. declaração de que a busca/seleção não pretende exaustividade quando aplicável;
10. síntese proporcional ao nível N1;
11. incerteza e limitações explicitadas;
12. data de corte.

---

# 8. Busca e recuperação

## 8.1 Princípio

A busca N1 deverá ser:

> **estruturada, documentada e suficiente para localizar as melhores fontes decisivas, sem alegação de completude.**

## 8.2 Prioridade de fontes

Ordem preferencial:

1. revisões sistemáticas recentes e aderentes;
2. meta-análises ou outras sínteses robustas;
3. diretrizes pertinentes;
4. HTAs;
5. estudos primários decisivos;
6. estudos posteriores capazes de modificar a interpretação;
7. fontes institucionais/regulatórias quando materialmente relevantes.

A hierarquia não substitui avaliação de pertinência e qualidade.

## 8.3 Fontes de busca

Conforme a pergunta, poderão ser utilizadas:

- PubMed/MEDLINE;
- bases de sínteses;
- segunda base bibliográfica, opcional;
- CENTRAL para intervenções quando pertinente;
- BVS/LILACS quando o contexto justificar;
- registros de ensaios quando materialmente relevantes;
- citation chasing seletivo;
- fontes institucionais ou regulatórias.

Literatura cinzenta não é requisito rotineiro em N1, mas poderá ser buscada seletivamente.

## 8.4 Documentação mínima da busca

Registrar:

- fontes consultadas;
- data da busca;
- termos/estratégia em nível suficiente para auditoria proporcional;
- filtros relevantes;
- limites aplicados;
- critério utilizado para priorizar as fontes decisivas;
- declaração de não exaustividade quando pertinente.

---

# 9. Seleção das fontes

A seleção N1 é orientada para as **melhores fontes disponíveis**, não para identificação completa de todos os registros elegíveis.

Deverá haver:

- critérios de relevância explícitos;
- correspondência com a pergunta;
- avaliação da atualidade;
- registro das fontes-chave incluídas;
- justificativa para a escolha das fontes decisivas quando houver alternativas relevantes.

Motivos formais de exclusão de todos os textos completos não são requisito padrão N1.

Entretanto, exclusões materialmente capazes de alterar a interpretação deverão ser registradas.

IA poderá organizar e priorizar resultados, mas fontes decisivas deverão ser verificadas contra o documento original.

---

# 10. Avaliação crítica

## 10.1 Regra

A avaliação crítica será proporcional e focada nas **fontes decisivas**.

No mínimo, deverão ser considerados:

- correspondência com a pergunta;
- data e atualidade;
- abrangência;
- critérios de elegibilidade;
- métodos de seleção;
- qualidade/risco de viés;
- métodos de síntese;
- limitações capazes de alterar a conclusão.

## 10.2 Instrumentos formais

Instrumento completo não é obrigatório para todas as fontes.

Quando a resposta depender fortemente de:

- uma única revisão sistemática;
- uma única diretriz;
- um único estudo decisivo;

deverá ser considerada avaliação formal apropriada.

Para revisão sistemática decisiva, ROBIS permanece o instrumento padrão OES para risco de viés quando avaliação formal for necessária.

## 10.3 Proibição

O rótulo “systematic review”, “meta-analysis” ou “guideline” não deverá ser tratado como garantia de confiabilidade.

---

# 11. Extração

A extração N1 será **focal**.

Deverá incluir somente dados necessários para sustentar a resposta.

Valores numéricos e afirmações que sustentem diretamente a conclusão deverão ser conferidos contra a fonte antes da publicação.

Não é requisito padrão:

- extração independente em duplicata;
- formulário extensivo para todas as características dos estudos.

Quando houver transformação de dado ou cálculo derivado, a origem e a transformação deverão ser identificáveis.

---

# 12. Síntese

## 12.1 Abordagem padrão

N1 poderá:

- adotar criticamente uma síntese existente;
- comparar sínteses existentes;
- realizar síntese descritiva estruturada;
- integrar seletivamente estudos primários posteriores quando pertinente.

## 12.2 Meta-análise

Nova meta-análise **não é rotina em N1**.

Se uma nova síntese quantitativa for necessária para responder adequadamente à pergunta, a investigação deverá ser rerroteada.

## 12.3 Conflito entre fontes

Quando fontes robustas discordarem materialmente, a Resposta deverá:

1. tornar a discordância explícita;
2. identificar possíveis causas;
3. evitar escolher silenciosamente a fonte mais conveniente;
4. avaliar se N1 ainda é adequado.

Se o conflito não puder ser resolvido proporcionalmente, rerrotear.

---

# 13. Certeza/confiança

## 13.1 Reuso de avaliação existente

N1 poderá utilizar avaliação de certeza/confiança já existente quando:

- o framework for identificável;
- população, comparação e desfecho forem compatíveis;
- a avaliação corresponder materialmente ao resultado comunicado;
- não houver mudança relevante do corpo de evidências;
- limitações forem declaradas.

## 13.2 Ausência de certainty formal adequada

Quando não houver avaliação formal compatível:

- não inventar GRADE/CERQual;
- não converter qualidade da revisão em nível de certeza;
- não inferir certainty apenas por significância estatística;
- não usar linguagem que simule avaliação formal inexistente.

A Resposta deverá comunicar a incerteza em linguagem descritiva calibrada.

## 13.3 Mudança material após a síntese-base

Se estudos posteriores alterarem materialmente o corpo de evidências, a certainty antiga não deverá ser apresentada como se permanecesse automaticamente válida.

Nessa situação, considerar rerroteamento para N2 ou nível superior.

---

# 14. Aplicabilidade

Aplicabilidade deverá ser tratada quando material para a pergunta.

Poderão ser considerados:

- população-alvo;
- contexto assistencial;
- diferenças de sistema de saúde;
- disponibilidade da intervenção/teste;
- epidemiologia;
- regulamentação;
- recursos;
- contexto brasileiro/SUS quando explicitamente relevante.

Aplicabilidade não deverá ser confundida com certeza.

Uma fonte metodologicamente robusta pode ter aplicabilidade limitada ao contexto-alvo.

---

# 15. Construção da conclusão

A conclusão deverá:

- responder diretamente à pergunta;
- distinguir evidência de interpretação;
- refletir a força real das fontes;
- explicitar incerteza;
- evitar causalidade quando não sustentada;
- evitar generalização além da população/condição avaliadas;
- evitar recomendação não autorizada.

Quando certeza formal compatível existir, a linguagem poderá ser calibrada a ela.

Quando não existir, utilizar linguagem descritiva sem rotulagem GRADE/CERQual artificial.

---

# 16. Estrutura científica mínima do produto

Toda Resposta de Evidência publicada deverá conter, no mínimo:

## Bloco A — Identificação

- Product ID;
- versão;
- título;
- Question ID;
- Investigation ID;
- nível N;
- nível M;
- público-alvo quando relevante;
- estado editorial;
- data de publicação;
- data de corte.

## Bloco B — Pergunta

- pergunta focal;
- estrutura científica aplicável;
- finalidade;
- contexto relevante.

## Bloco C — Resposta sintética

- conclusão principal;
- grau de incerteza em linguagem calibrada;
- ausência de recomendação automática quando aplicável.

## Bloco D — Método

- fontes pesquisadas;
- data da busca;
- abordagem de seleção;
- declaração de não exaustividade;
- appraisal aplicado às fontes decisivas.

## Bloco E — Fontes-chave

Para cada fonte decisiva:

- identificação;
- tipo de fonte;
- correspondência com a pergunta;
- data/atualidade;
- papel na resposta;
- limitação material.

## Bloco F — Principais resultados

- resultados necessários à resposta;
- medidas numéricas quando apropriadas;
- contexto suficiente para interpretação;
- fonte/proveniência.

## Bloco G — Certeza/confiança

- framework existente quando reutilizado;
- nível/julgamento somente quando compatível;
- origem da avaliação;
- limitações;
- ou declaração explícita de ausência de avaliação formal compatível.

## Bloco H — Limitações

- limitações da evidência;
- limitações das fontes;
- limitações da busca seletiva;
- lacunas relevantes;
- conflitos entre fontes, se existentes.

## Bloco I — Aplicabilidade

Condicional à pergunta.

## Bloco J — Transparência e garantia

- nível de assurance;
- verificação metodológica;
- aprovação de governança;
- situação de expert review;
- principais avisos de uso.

## Bloco K — Referências

- referências decisivas;
- identificadores persistentes quando disponíveis.

---

# 17. Proveniência e auditabilidade

Afirmações materiais deverão ser rastreáveis até a fonte que as sustenta.

No mínimo:

- números decisivos;
- níveis de certainty reutilizados;
- datas de busca;
- appraisal formal quando realizado;
- conclusão principal;

deverão possuir provenance suficiente para auditoria.

Quando a Resposta reutilizar objetos já existentes no OES, deverá apontar para suas versões concretas em vez de duplicá-los silenciosamente.

---

# 18. Data de corte e atualidade

Toda Resposta de Evidência formal deverá possuir **data de corte**.

A data de corte significa:

> **até quando o OES considerou evidência potencialmente relevante para aquela resposta.**

Não significa que a literatura esteja completa até essa data.

O produto deverá distinguir:

- data da busca;
- data de corte;
- data de publicação.

Quando a resposta depender de revisão com cutoff antigo, a diferença deverá ser explicitada e, quando pertinente, deverá ser executada busca seletiva posterior.

---

# 19. Manutenção

Compatibilidade preferencial:

- **M0 — estático**;
- **M1 — elegível para atualização**.

M2 poderá ser utilizado quando houver justificativa.

M3 é excepcional para Resposta de Evidência.

Se houver necessidade de monitoramento persistente, o conhecimento deverá preferencialmente:

- migrar para uma Ficha de Evidência N2; ou
- vincular-se a uma Ficha existente.

---

# 20. Garantia metodológica e publicação

## 20.1 Regra padrão

Conforme Documento 04:

> **Resposta de Evidência N1 persistente/formal requer A2 para publicação padrão OES.**

Portanto, uma versão formal publicada deverá ter:

1. verificação metodológica ativa em `passed`;
2. owner governance approval ativa em `approved`;
3. ausência de bloqueios ativos de assurance;
4. demais invariantes científicos satisfeitos;
5. `publication_date` somente após fechamento do conteúdo.

Expert review é opcional no N1 padrão.

## 20.2 A2 sem A3

Quando não houver revisão especializada independente, a saída deverá declarar explicitamente:

> **Verificação metodológica:** processo OES assistido por IA.  
> **Aprovação de governança:** realizada pelo proprietário do projeto.  
> **Revisão especializada independente:** não realizada.

## 20.3 Alta criticidade

Mesmo em uma pergunta inicialmente candidata a N1, A2 poderá ser insuficiente se a finalidade envolver:

- decisão clínica individual de alto risco;
- diretriz;
- política pública;
- incorporação tecnológica;
- regulação;
- decisão institucional com potencial importante de dano.

Nesses casos, rerrotear a profundidade e/ou exigir A3 conforme Documento 04.

---

# 21. Uso de IA

IA poderá auxiliar em:

- estruturação da pergunta;
- construção e refinamento da busca;
- deduplicação e organização;
- priorização de fontes;
- extração preliminar;
- comparação entre sínteses;
- detecção de inconsistências;
- elaboração de narrativa;
- checagem adversarial.

IA não poderá:

- inventar fontes;
- declarar busca completa quando seletiva;
- tratar resumo secundário como substituto da fonte decisiva;
- criar GRADE/CERQual inexistente;
- resolver silenciosamente conflito entre fontes;
- atribuir owner approval;
- atribuir expert review;
- transformar evidência em recomendação clínica individual sem metodologia autorizadora.

Fontes decisivas e afirmações materiais deverão ser verificadas.

---

# 22. Estados editoriais

A Resposta poderá utilizar os estados editoriais comuns do OES, incluindo:

- draft;
- under_review;
- published;
- superseded/retired quando previsto pela arquitetura vigente.

A publicação somente ocorrerá após o gate correspondente.

Uma versão anterior publicada não deverá ser sobrescrita silenciosamente por nova conclusão.

---

# 23. Versionamento

Nova ProductVersion deverá ser criada quando ocorrer mudança material, incluindo:

- nova evidência capaz de alterar a resposta;
- mudança da conclusão;
- mudança relevante da certeza;
- correção científica;
- alteração material de escopo;
- atualização substantiva de aplicabilidade.

Correções editoriais sem mudança científica deverão ser distinguíveis de revisões materiais.

Quando a pergunta mudar substancialmente, considerar nova Investigation e/ou novo Product.

---

# 24. Não duplicação

Antes de abrir uma nova Resposta, verificar:

- existe Ficha de Evidência vigente sobre a mesma pergunta?
- existe investigação N2–N4 recente que possa ser reutilizada?
- existe outra Resposta atual que apenas precise de atualização?
- existe síntese externa robusta suficientemente correspondente?

Preferir reutilização e derivação rastreável a repetição desnecessária.

---

# 25. Critérios mínimos de publicação

Uma Resposta de Evidência N1 não deverá ser publicada se faltar qualquer elemento material abaixo:

- pergunta focal definida;
- Routing Record compatível com N1;
- busca estruturada e documentada;
- fontes decisivas verificadas;
- coerência entre fontes e conclusão;
- limitações relevantes explícitas;
- incerteza explicitada;
- data de corte;
- referências;
- provenance das afirmações materiais;
- assurance compatível com a finalidade;
- publication gate sem erros bloqueantes.

---

# 26. Critérios de qualidade do produto final

Uma Resposta N1 adequada deverá permitir que um leitor responda:

1. qual pergunta foi feita?
2. por que N1 foi escolhido?
3. onde o OES procurou evidência?
4. a busca foi completa ou seletiva?
5. quais fontes realmente sustentam a resposta?
6. essas fontes são suficientemente atuais e confiáveis?
7. quais resultados importam para a pergunta?
8. existe certeza formal reutilizável?
9. quais limitações podem mudar a interpretação?
10. até quando a evidência foi considerada?
11. a conclusão vai além do que as fontes permitem?
12. qual foi o nível de garantia antes da publicação?

Se essas perguntas não puderem ser respondidas, o produto não atende ao contrato N1.

---

# 27. Decisões consolidadas

1. Resposta de Evidência corresponde tipicamente a N1.
2. É produto focal de resposta, não produto exploratório.
3. Busca N1 é estruturada, mas não pretende exaustividade.
4. Fontes decisivas devem ser verificadas.
5. Appraisal é proporcional e focado nas fontes decisivas.
6. Extração é focal; dados materiais devem ser conferidos.
7. Nova meta-análise não é rotina N1.
8. Certainty existente pode ser reutilizada somente quando metodologicamente compatível.
9. Não será criada certainty formal fictícia.
10. Conflito material não resolvível proporcionalmente exige rerroteamento.
11. M0/M1 são os estados de manutenção preferenciais.
12. Monitoramento persistente deve preferencialmente migrar para ou vincular-se à Ficha N2.
13. Publicação formal/persistente N1 exige A2 como padrão.
14. Expert review é opcional no N1 padrão e deve ser declarado quando ausente.
15. Alta criticidade pode exigir elevação de nível e/ou A3.
16. Resposta de Evidência não deverá duplicar objetos científicos já estruturados no OES.
17. Template, contrato de dados e implementação somente deverão ser definidos após esta especificação.

---

# 28. Próxima etapa

Realizar uma **revisão de coerência do Documento 68** contra:

- Documento 40;
- protocolos 10–15;
- Documento 04;
- baseline OES-P1;
- experiência arquitetural obtida com a Ficha de Evidência.

Somente após essa revisão decidir:

1. quais estruturas da Ficha podem ser reutilizadas;
2. se a Resposta necessita contrato de dados próprio;
3. se necessita uma view própria;
4. quais campos podem ser projeções comuns;
5. quais diferenças são exclusivamente de produto/apresentação.

Não criar template operacional antes dessa decisão.

---

**Documento vivo. Alterações materiais deverão ser justificadas e registradas no CHANGELOG.md.**
