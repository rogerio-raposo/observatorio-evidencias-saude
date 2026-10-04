# 41 — Especificação Científica e Funcional da Ficha de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — especificação inicial consolidada  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 00, 02, 03, 10–15, 21, 28, 29, 38 e 40  
**Baseline arquitetural:** OES-P1  
**Produto:** OES — Ficha de Evidência  
**Nível típico:** N2

---

# 1. Finalidade

Este documento define o **contrato científico e funcional da Ficha de Evidência do OES** antes da criação de seu template operacional.

A Ficha de Evidência deverá funcionar como:

> **unidade persistente, versionada e reutilizável de conhecimento do OES para uma pergunta focal, construída sobre evidência estruturada e rastreável.**

A Ficha deve permitir responder, de forma concisa e auditável:

- qual pergunta está sendo respondida;
- qual evidência foi considerada;
- qual síntese foi utilizada;
- quais são os principais resultados;
- qual é a certeza/confiança;
- quais limitações permanecem;
- quão aplicável é a evidência ao contexto-alvo;
- qual conclusão é sustentada;
- até quando a evidência foi considerada;
- o que mudou entre versões.

Este documento **não define ainda o layout visual final** da Ficha.

---

# 2. Papel arquitetural

A Ficha é um **Product subtype** dentro do baseline OES-P1.

Regra estrutural:

`Question → Investigation → Evidence objects → Synthesis/Certainty → Product(Ficha)`

A Ficha não substitui:

- Question;
- Investigation;
- Search;
- Screening;
- Study;
- Report;
- Result;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- Provenance.

Ela é uma **projeção de conhecimento** construída sobre versões concretas dessas entidades.

## 2.1 Princípio de não duplicação

A Ficha não deverá armazenar, como nova fonte canônica, dados que já existam de forma estruturada em entidades do OES-P1.

Exemplos:

- efeito quantitativo permanece em Result/Synthesis;
- certeza permanece em CertaintyAssessment;
- risco de viés permanece em RiskAssessment;
- estratégia de busca permanece em Search;
- identificação do estudo permanece em Study/Report.

A Ficha poderá apresentar esses elementos, mas a origem auditável continuará sendo a entidade científica correspondente.

---

# 3. Unidade de conhecimento

## 3.1 Unidade primária

A unidade primária da Ficha será:

> **uma pergunta focal cientificamente estruturada, vinculada a uma Investigation e a um corpo de evidências delimitado por data de corte.**

## 3.2 Identidade persistente

A mesma Ficha deverá manter o mesmo `Product ID` enquanto permanecer a mesma unidade de conhecimento.

Uma atualização de evidência não cria necessariamente nova Ficha.

Cria:

> **nova ProductVersion da mesma Ficha.**

## 3.3 Quando criar nova Ficha

Nova identidade de Product será preferida quando houver mudança material da pergunta que altere substancialmente:

- população;
- intervenção/exposição/teste/fator;
- comparador;
- condição-alvo;
- fenômeno;
- contexto central;
- objetivo decisório;
- unidade principal de análise.

Mudanças menores, novas evidências ou refinamentos que preservem a pergunta central deverão gerar nova versão, não novo Product.

---

# 4. Relação com N2

A Ficha é o produto típico de **N2**.

N2 significa que a investigação:

- é suficientemente estruturada para ser reutilizável;
- possui rastreabilidade formal;
- possui evidência organizada;
- possui avaliação crítica proporcional;
- registra resultados e sínteses;
- pode incluir certainty formal quando metodologicamente apropriado.

A Ficha não deverá ser usada para disfarçar:

- N0 como síntese estruturada;
- N1 como investigação completa;
- N3 como revisão sistemática completa;
- N4 como simples resumo informal.

## 4.1 Reuso de investigação mais profunda

Uma Ficha poderá reutilizar evidência ou Syntheses originadas de investigações N3/N4.

Nesse caso:

- a profundidade original deverá permanecer identificável;
- a Ficha não deverá renomear retrospectivamente a investigação N3/N4 como N2;
- a Investigation primária da Ficha poderá ser N2;
- investigações-fonte adicionais poderão ser vinculadas como suporte;
- ProductSynthesis deverá apontar para versões concretas das Syntheses reutilizadas.

---

# 5. Público e finalidade

A Ficha poderá atender:

- consulta técnica;
- consulta educacional;
- apoio à decisão clínica não individual;
- apoio à decisão institucional;
- planejamento de pesquisa;
- vigilância de evidências;
- uso como componente de produtos mais amplos.

O público-alvo deverá ser explicitado em `intended_audience`.

A finalidade não autoriza simplificação silenciosa do método.

---

# 6. Tipos de conteúdo da Ficha

Cada campo/seção deverá receber uma das seguintes classificações:

### O — Obrigatório

Deve estar presente para publicação.

### C — Condicional

Obrigatório quando a natureza da pergunta ou da evidência o tornar aplicável.

### D — Derivado

É apresentado na Ficha, mas obtido de entidade canônica subjacente.

### NA — Não aplicável

Pode estar explicitamente ausente quando não fizer sentido metodológico.

Campos não aplicáveis não deverão ser preenchidos artificialmente.

---

# 7. Estrutura científica da Ficha

A estrutura mínima será organizada em doze blocos.

---

## 7.1 Bloco A — Identificação e estado

### Campos

| Campo | Classe | Fonte |
|---|---|---|
| Product ID | O | Product |
| Product version | O | EntityVersion / ProductVersion |
| Product type | O | ProductVersion |
| Título | O | ProductVersion |
| Público-alvo | C | ProductVersion |
| Estado editorial | O | ProductVersion.status |
| Estado de atualidade | O | camada de produto conforme Documento 40 |
| Data de publicação | C | ProductVersion.publication_date |
| Data de corte da evidência | O | ProductVersion.evidence_cutoff_date |
| Investigation ID | O | ProductInvestigation |
| Question ID | O/D | Investigation.primary_question_entity_uuid |
| Nível N | D | InvestigationVersion.depth_level |
| Nível M | D | InvestigationVersion.maintenance_level |

## Regra

A data de corte da Ficha deverá ser coerente com a Investigation e com as Syntheses utilizadas.

Quando houver datas de corte distintas em componentes reutilizados, a Ficha deverá explicitá-las.

---

## 7.2 Bloco B — Pergunta e escopo científico

### Conteúdo

- pergunta original;
- pergunta normalizada;
- pergunta operacional, quando formalizada;
- classe metodológica;
- população;
- intervenção/exposição/teste/fator;
- comparador;
- desfecho/achado;
- contexto;
- horizonte temporal;
- finalidade.

### Classe

- pergunta normalizada: **O/D**;
- elementos estruturais: **C/D**;
- contexto: **C/D**.

### Fonte

- QuestionVersion;
- InvestigationQuestion;
- InvestigationVersion.

## Regra

A Ficha deverá apresentar a pergunta em linguagem compreensível sem apagar a estrutura científica subjacente.

---

## 7.3 Bloco C — Método resumido

### Conteúdo mínimo

- tipo de investigação;
- nível N;
- bases/fontes pesquisadas;
- data da última busca;
- período coberto;
- critérios de elegibilidade resumidos;
- abordagem de triagem;
- instrumentos de avaliação crítica;
- método de síntese;
- framework de certainty, quando usado;
- principais simplificações metodológicas.

### Classe

**O**, com elementos **C** conforme desenho.

### Fontes

- InvestigationVersion;
- Search;
- ScreeningDecision;
- RiskAssessment;
- SynthesisVersion;
- CertaintyAssessmentVersion.

## Regra

A seção deve permitir compreender o método sem reproduzir integralmente o protocolo.

O protocolo completo, quando existir, deverá permanecer como artefato vinculado.

---

## 7.4 Bloco D — Corpo de evidências

### Conteúdo

- número de Studies incluídos;
- número de Reports relevantes;
- desenhos dos estudos;
- populações estudadas;
- contextos;
- tamanho total ou aproximado da amostra, quando meaningful;
- principais fontes de evidência;
- atualização temporal da base.

### Classe

**O/D**.

### Fontes

- Study;
- StudyVersion;
- Report;
- StudyReportLink;
- ScreeningDecision;
- SynthesisContribution.

## Regra

A Ficha deve contar **Studies**, e não apenas Reports, para evitar dupla contagem de múltiplas publicações do mesmo estudo.

---

## 7.5 Bloco E — Resultados/achados prioritários

Este é o núcleo analítico da Ficha.

Cada unidade prioritária deverá conter, conforme o tipo de pergunta:

### Quantitativo

- outcome;
- comparação;
- população;
- timepoint;
- estimand;
- medida;
- efeito;
- intervalo de incerteza;
- efeito absoluto quando aplicável;
- efeito relativo quando aplicável;
- número de Studies;
- número de participantes, quando disponível;
- direção do efeito;
- certainty.

### Qualitativo

- ReviewFinding;
- estudos contribuintes;
- contexto;
- interpretação do achado;
- confidence/CERQual.

### Diagnóstico

- teste índice;
- condição-alvo;
- threshold, quando aplicável;
- sensibilidade/especificidade ou outra métrica;
- incerteza;
- certainty.

### Prognóstico/predição

- horizonte;
- desempenho;
- discriminação/calibração quando apropriado;
- contexto;
- certainty/confidence conforme framework adotado.

### Classe

**O/D**, conforme a pergunta.

### Fontes

- Outcome;
- ResultVersion;
- SynthesisVersion;
- ReviewFindingVersion;
- PredictionModel;
- CertaintyAssessmentVersion.

## Regra de priorização

A Ficha deverá privilegiar unidades previamente definidas como críticas ou importantes.

Para perguntas de intervenção, uma apresentação inspirada em Summary of Findings deverá ser preferida quando apropriada.

Como regra de comunicação, a Ficha deverá ser concisa; em contextos de intervenção, **até aproximadamente sete desfechos prioritários** deverá ser a referência inicial, sem converter esse número em limite universal para todos os tipos de pergunta.

---

## 7.6 Bloco F — Risco de viés / qualidade metodológica

### Conteúdo

- frameworks utilizados;
- padrão dominante de risco de viés;
- limitações críticas relevantes;
- relação das limitações com a interpretação.

### Classe

**C/D**.

### Fonte

- RiskAssessment;
- RiskAssessmentVersion;
- RiskAssessmentDomain.

## Regra

A Ficha não deverá produzir um “score de qualidade” universal.

Risco de viés de estudo individual não será apresentado como sinônimo de certainty do corpo de evidências.

---

## 7.7 Bloco G — Certeza/confiança

### Conteúdo

Para cada unidade científica relevante:

- framework;
- versão/fonte do framework;
- nível final;
- principais razões para downgrade/upgrade ou redução de confiança;
- estado de evidência;
- data da avaliação.

### Classe

**C/D**.

### Fonte

- CertaintyAssessmentVersion;
- CertaintyDomain;
- CertaintyReview, quando implementado.

## Regras

1. certainty será apresentada por unidade adequada;
2. não haverá certainty global artificial da Ficha;
3. ausência de avaliação formal será declarada como:
   > **não avaliada formalmente**;
4. ausência de evidência não será convertida em “muito baixa”;
5. a Ficha poderá herdar certainty de síntese externa apenas quando a compatibilidade metodológica for explicitamente verificada.

---

## 7.8 Bloco H — Segurança e danos

Quando a pergunta envolver intervenção, exposição ou tecnologia com potencial de dano, a Ficha deverá apresentar resultados de segurança separadamente.

### Classe

**C**.

### Regra

Benefício e dano não deverão ser fundidos em conclusão única sem explicitar o trade-off.

Eventos adversos graves ou sinais de segurança relevantes deverão receber destaque proporcional à criticidade.

---

## 7.9 Bloco I — Limitações

### Conteúdo

Distinguir:

1. limitações da evidência;
2. limitações da busca;
3. limitações da síntese;
4. limitações do nível N2;
5. limitações de aplicabilidade;
6. lacunas de pesquisa.

### Classe

**O**.

## Regra

A seção de limitações deverá informar como as limitações afetam a interpretação, e não apenas enumerá-las.

---

## 7.10 Bloco J — Aplicabilidade

### Conteúdo

- contexto-alvo;
- compatibilidade entre população estudada e população-alvo;
- contexto assistencial;
- disponibilidade de tecnologia;
- prevalência basal, quando relevante;
- recursos;
- regulamentação;
- especificidades do SUS/Brasil quando a pergunta-alvo for brasileira;
- principais fatores que podem limitar transferência.

### Classe

**C**.

### Fonte

- ProductVersion.applicability_summary;
- InvestigationVersion;
- futura ApplicabilityAssessment, quando operacionalizada.

## Regra

Até a formalização do ApplicabilityAssessment:

- análise será descritiva;
- não haverá score universal;
- aplicabilidade não será convertida automaticamente em certainty;
- ausência de estudo brasileiro não implicará automaticamente baixa aplicabilidade.

---

## 7.11 Bloco K — Conclusão da evidência

### Conteúdo

Uma conclusão principal, curta e calibrada.

### Classe

**O**.

### Fonte

- ProductVersion.conclusion_text, sustentada por Synthesis/Certainty vinculadas.

## Regras obrigatórias

A conclusão deverá:

- responder diretamente à pergunta;
- refletir direção e magnitude quando disponíveis;
- incorporar incerteza;
- ser compatível com certainty;
- mencionar evidência insuficiente quando for o caso;
- distinguir benefício e dano quando necessário;
- não extrapolar população, comparação ou contexto;
- não se transformar automaticamente em recomendação.

### Formulações aceitáveis

- “A evidência sugere que...”
- “A evidência indica provavelmente...”
- “Há evidência de alta certeza de que...”
- “A evidência disponível é insuficiente para determinar...”
- “Os estudos apresentam resultados inconsistentes...”
- “Não foram identificadas evidências elegíveis para...”

### Formulações a evitar

- “Está cientificamente comprovado...”
- “Funciona.”
- “Não funciona.”, quando a evidência for apenas inconclusiva;
- “Recomenda-se...”, sem framework de recomendação autorizado.

---

## 7.12 Bloco L — Atualização, versionamento e rastreabilidade

### Conteúdo

- versão atual;
- versão anterior;
- classe(s) de mudança;
- data de corte;
- data da última busca;
- estado de atualidade;
- nível M;
- resumo da mudança;
- fontes adicionadas/removidas;
- impacto em Synthesis;
- impacto em Certainty;
- impacto em aplicabilidade;
- impacto em conclusão;
- links de provenance/version lineage.

### Classe

**O** para produtos versionados após a primeira publicação; **C** na versão inicial.

---

# 8. Matriz de obrigatoriedade

| Seção | Obrigatória | Condicional | Pode ser NA |
|---|---:|---:|---:|
| Identificação e estado | sim | — | não |
| Pergunta e escopo | sim | — | não |
| Método resumido | sim | — | não |
| Corpo de evidências | sim | — | não |
| Resultados/achados prioritários | sim | — | não |
| Risk of Bias | — | sim | sim |
| Certainty/confiança | — | sim | sim |
| Segurança/danos | — | sim | sim |
| Limitações | sim | — | não |
| Aplicabilidade | — | sim | sim |
| Conclusão | sim | — | não |
| Atualização/versionamento | sim | — | não |

“NA” deverá significar **não aplicável**, e não “não preenchido”.

---

# 9. Mapeamento para OES-P1

## 9.1 Identidade

- Product → identidade persistente;
- EntityVersion → versionamento técnico;
- ProductVersion → estado publicável da Ficha.

## 9.2 Investigação

- ProductInvestigation → vínculo a InvestigationVersion;
- InvestigationVersion → N, M, objetivo, data de corte;
- InvestigationQuestion → pergunta operacional vinculada.

## 9.3 Evidência

- Study / StudyVersion;
- Report / ReportVersion;
- StudyReportLink;
- Result / ResultVersion;
- ResultSource.

## 9.4 Avaliação crítica

- RiskAssessment;
- RiskAssessmentVersion;
- domínios correspondentes.

## 9.5 Síntese

- Synthesis;
- SynthesisVersion;
- SynthesisContribution;
- ReviewFinding, quando qualitativo;
- PredictionModel, quando aplicável.

## 9.6 Certeza

- CertaintyAssessment;
- CertaintyAssessmentVersion;
- CertaintyDomain;
- CERQual via ReviewFinding, quando aplicável.

## 9.7 Produto

- ProductVersion;
- ProductSynthesis;
- ProductCertainty;
- rendered artifact, quando criado.

## 9.8 Provenance

- ProvenanceRecord;
- DependencyEdge;
- version lineage.

---

# 10. Regras de vínculo da Ficha

## 10.1 Investigation primária

A Ficha deverá possuir **uma Investigation principal**.

Investigações adicionais poderão ser vinculadas como:

- source;
- supporting;
- update_source;
- predecessor;
- related.

## 10.2 Syntheses

Toda Synthesis utilizada na conclusão deverá estar vinculada ao ProductVersion.

Não é permitido citar uma Synthesis na narrativa principal sem vínculo estruturado quando essa Synthesis existir no OES-P1.

## 10.3 Certainty

Toda certainty formal comunicada deverá apontar para CertaintyAssessmentVersion concreta.

## 10.4 Consistência temporal

ProductVersion não deverá utilizar silenciosamente:

- Synthesis obsoleta;
- Certainty superseded;
- Investigation não compatível com a pergunta;
- Result invalidado sem justificativa explícita.

---

# 11. Contrato da tabela de resultados/achados

A Ficha deverá possuir uma representação compacta dos principais resultados.

Campos conceituais mínimos:

| Campo | Quantitativo | Qualitativo |
|---|---:|---:|
| unidade | Outcome | ReviewFinding |
| população/contexto | sim | sim |
| comparação | quando aplicável | geralmente NA |
| timepoint | quando aplicável | quando aplicável |
| estimand/métrica | sim | NA |
| magnitude | sim | narrativa |
| incerteza | sim | narrativa |
| Studies contribuintes | sim | sim |
| participantes | quando disponível | quando útil |
| certainty/confidence | quando avaliada | quando avaliada |
| justificativa breve | sim | sim |

A apresentação final poderá ser tabela, cards ou outro formato, mas o contrato científico deverá permanecer equivalente.

---

# 12. Summary of Findings e Evidence Profile

Para intervenções e outras questões compatíveis:

- a Ficha poderá incorporar uma representação Summary of Findings;
- deverá priorizar desfechos críticos/importantes;
- quando houver efeitos dicotômicos e dados adequados, efeitos absolutos e relativos deverão ser apresentados;
- número de Studies/participantes e certainty deverão acompanhar a unidade;
- justificativas relevantes de certainty deverão ser acessíveis.

A Ficha não será obrigada a reproduzir integralmente um Evidence Profile quando isso reduzir clareza, mas deverá permitir chegar ao registro estruturado subjacente.

---

# 13. Aplicabilidade ao Brasil

Quando o contexto-alvo for brasileiro, a Ficha deverá explicitar a **Camada Brasil**.

Elementos candidatos:

- epidemiologia brasileira;
- SUS;
- disponibilidade da intervenção/teste;
- regulação sanitária;
- diferenças de baseline risk;
- acesso;
- organização assistencial;
- recursos/custos, quando relevantes;
- evidência brasileira.

Essa camada:

- não altera automaticamente o efeito científico;
- não substitui certainty;
- poderá modificar a interpretação contextual.

---

# 14. Fronteira entre evidência e recomendação

A Ficha é um produto de evidência.

Estrutura:

> **evidência → certeza → interpretação → aplicabilidade**

A Ficha poderá apresentar:

- implicações;
- pontos de atenção;
- incertezas;
- condições de aplicabilidade.

A Ficha **não deverá produzir recomendação normativa** enquanto o OES não possuir framework específico autorizado.

Não usar como conclusão automática:

- “deve usar”;
- “não deve usar”;
- “é indicado”;
- “é contraindicado”,

salvo quando a frase for claramente atribuída a fonte externa e apresentada como posição dessa fonte, não como recomendação própria do OES.

---

# 15. Critérios mínimos para publicação

Uma Ficha somente poderá atingir estado `published` quando:

1. Product e ProductVersion válidos existirem;
2. houver Investigation principal explicitamente vinculada;
3. a pergunta estiver estruturada;
4. o nível metodológico estiver definido;
5. a data de corte estiver registrada;
6. buscas/fontes utilizadas estiverem identificáveis;
7. critérios de elegibilidade estiverem registrados;
8. corpo de evidências estiver reconstruível;
9. resultados/achados prioritários estiverem vinculados às entidades correspondentes;
10. Syntheses relevantes estiverem vinculadas;
11. RiskAssessment estiver disponível quando metodologicamente exigido;
12. certainty estiver vinculada quando formalmente avaliada;
13. ausência de certainty estiver explicitamente declarada quando não avaliada;
14. limitações estiverem registradas;
15. aplicabilidade estiver avaliada ou marcada como não aplicável/não formalizada;
16. conclusão estiver sustentada pelas evidências vinculadas;
17. revisão humana dos julgamentos materiais estiver concluída;
18. nenhuma fonte essencial estiver invalidada/retratada sem reavaliação documentada;
19. provenance e lineage permitirem reconstrução;
20. não houver conflito não resolvido entre conclusão e certainty.

---

# 16. Gate de publicação

Antes de publicação, executar checklist:

### Integridade científica

- pergunta ↔ Investigation coerentes;
- Study/Report sem dupla contagem indevida;
- Results corretos;
- Syntheses atuais;
- RiskAssessment correto;
- certainty coerente.

### Integridade temporal

- última busca identificada;
- data de corte coerente;
- fontes retratadas/corrigidas tratadas.

### Integridade narrativa

- conclusão responde à pergunta;
- linguagem calibrada;
- limitações explícitas;
- ausência de recomendação indevida.

### Integridade de versionamento

- ProductVersion current;
- predecessor preservado;
- classe de mudança registrada, quando atualização.

Falha em item material impede `published`.

---

# 17. Estados editoriais

Adotar inicialmente os estados do Documento 40:

- `draft`;
- `under_review`;
- `published`;
- `superseded`;
- `archived`.

Fluxo típico:

`draft → under_review → published → superseded/archived`

Uma nova ProductVersion poderá estar em `draft` enquanto a versão publicada anterior continua válida.

---

# 18. Estado de atualidade

Manter separado do estado editorial:

- atual;
- em_avaliacao;
- atualizacao_recomendada;
- desatualizada;
- arquivada.

Exemplo válido:

- editorial: `published`;
- atualidade: `atualizacao_recomendada`.

Isso significa:

> a versão continua sendo a publicação vigente, mas há sinal suficiente para recomendar reavaliação.

---

# 19. Versionamento científico da Ficha

Classes iniciais:

- editorial;
- evidência nova;
- correção científica;
- mudança quantitativa;
- mudança de certeza;
- mudança de aplicabilidade;
- mudança de conclusão.

Uma atualização poderá ter múltiplas classes.

## 19.1 Nova ProductVersion obrigatória

Gerar nova versão quando houver mudança material em:

- evidência incluída;
- Result relevante;
- Synthesis;
- certainty;
- aplicabilidade;
- conclusão;
- data de corte com reavaliação científica;
- correção científica.

## 19.2 Alteração editorial

Correções puramente editoriais poderão gerar nova ProductVersion classificada como `editorial` quando afetarem artefato publicado.

A política futura poderá adotar convenção major/minor/patch, mas não é necessária nesta fase.

---

# 20. Regras de comparação entre versões

O OES deverá conseguir responder:

- qual evidência entrou;
- qual saiu;
- qual foi invalidada;
- quais Results mudaram;
- quais Syntheses mudaram;
- se certainty mudou;
- se aplicabilidade mudou;
- se a conclusão mudou;
- por quê.

Uma atualização nunca deverá sobrescrever silenciosamente a versão anterior.

---

# 21. Relação com M0–M3

## M0 — Estático

- sem monitoramento ativo;
- atualização apenas por nova demanda.

## M1 — Elegível para atualização

- Ficha permanece no acervo;
- revisão periódica poderá ser iniciada;
- periodicidade formal será definida na Fase 4.

## M2 — Monitoramento ativo

- Ficha vinculada a Monitor de Evidências;
- novas evidências são pesquisadas em intervalos definidos;
- nova referência não altera automaticamente a Ficha.

## M3 — Evidência viva

- vigilância frequente;
- triagem contínua/recorrente;
- atualização acelerada quando gatilho material ocorre.

## Regra

Nível M deverá vir da Investigation/monitoramento e não ser inferido pelo número de atualizações já ocorridas.

---

# 22. Relação com Monitor e Alerta

A Ficha é o produto preferencial para:

> **Investigation → Ficha → Monitor → Alerta → reavaliação → nova ProductVersion**

O Alerta:

- sinaliza evento;
- não altera a conclusão.

O Monitor:

- identifica e classifica novidade;
- não substitui reavaliação.

Somente o processo formal de atualização pode gerar nova conclusão científica.

---

# 23. Relação com outros produtos

## 23.1 Evidence Scan → Ficha

Pode ocorrer quando um scan demonstra que:

- a pergunta é focal;
- existe evidência suficiente;
- há valor em manter conhecimento persistente.

Exige abertura formal de Investigation N2.

## 23.2 Resposta de Evidência → Ficha

Pode ocorrer quando:

- a questão se torna recorrente;
- há necessidade de monitoramento;
- é necessário maior grau de estruturação.

## 23.3 Síntese Rápida / Revisão → Ficha

A Ficha pode servir como camada persistente resumida de uma investigação N3/N4.

Deverá preservar links para as Syntheses e Investigations-fonte.

## 23.4 Ficha → Síntese Rápida / Revisão

Quando:

- incerteza relevante emerge;
- evidência entra em conflito;
- maior completude se torna necessária;
- decisão ganha criticidade.

A Ficha poderá ser rerroteada para N3/N4 sem perda de histórico.

---

# 24. Exemplo estrutural abstrato

## Identificação

- Product: OES-P-2026-000123
- versão: 3
- tipo: Ficha de Evidência
- estado editorial: published
- atualidade: atual
- N: N2
- M: M2
- evidência considerada até: 30/09/2026

## Pergunta

Em adultos com condição X, a intervenção A, comparada à intervenção B, reduz o desfecho Y?

## Evidência

- 5 Studies;
- 7 Reports;
- 3 ensaios randomizados;
- 2 coortes;
- última busca: 30/09/2026.

## Resultado prioritário

Desfecho Y em 12 meses:

- RR 0,82;
- IC 95% 0,70–0,96;
- efeito absoluto: apresentado quando calculável;
- 4 Studies;
- certainty: moderada.

## Limitação principal

Imprecisão residual e heterogeneidade clínica moderada.

## Aplicabilidade

Populações estudadas parcialmente compatíveis com o contexto-alvo; diferenças relevantes de baseline risk exigem cautela na extrapolação absoluta.

## Conclusão

A evidência indica provavelmente redução do desfecho Y com A em comparação a B, embora permaneça incerteza sobre a magnitude exata do benefício.

## Histórico

v2 → v3:

- 1 novo Study;
- Synthesis atualizada;
- certeza permaneceu moderada;
- efeito mudou de RR 0,86 para RR 0,82;
- conclusão qualitativa permaneceu estável.

---

# 25. Requisitos de apresentação futura

O template deverá permitir dois níveis de leitura:

## Camada 1 — leitura rápida

- pergunta;
- conclusão;
- resultados prioritários;
- certainty;
- principais limitações;
- data de corte;
- atualidade.

## Camada 2 — auditabilidade

- método;
- estudos;
- Results;
- RiskAssessment;
- Synthesis;
- certainty detalhada;
- aplicabilidade;
- referências;
- provenance;
- histórico.

O leitor não deverá precisar percorrer todo o registro técnico para compreender a conclusão principal.

---

# 26. Campos que não devem ser copiados desnecessariamente

Evitar replicar no ProductVersion:

- todos os Studies;
- todos os Reports;
- todos os Results;
- todos os domínios GRADE;
- estratégia de busca completa;
- dados estatísticos intermediários.

Esses elementos devem permanecer em entidades/artefatos próprios e ser referenciados.

---

# 27. Lacunas de implementação identificadas

O contrato científico da Ficha revela requisitos de produto ainda não plenamente materializados no baseline físico.

## 27.1 Estado de atualidade

Documento 40 exige estado de atualidade separado do estado editorial.

OES-P1 atual possui `ProductVersion.status`, mas não campo canônico específico de atualidade.

## 27.2 Classes de mudança

Documento 40 permite múltiplas classes de mudança por ProductVersion.

OES-P1 ainda não possui estrutura explícita para isso.

## 27.3 Relação Product → Product

Derivação entre produtos, como:

- Revisão → Ficha;
- Ficha → atualização;
- Ficha → Monitor,

poderá exigir relação explícita futura.

## 27.4 ApplicabilityAssessment

A interface lógica foi reservada, mas ainda não operacionalizada metodologicamente/fisicamente.

## 27.5 Registro de revisão editorial/científica

A Ficha requer evidência de revisão humana dos julgamentos materiais antes de `published`.

A estrutura física específica desse gate ainda poderá exigir extensão.

## Regra

Essas lacunas deverão ser avaliadas **após o fechamento desta especificação**.

Não serão implementadas silenciosamente no template.

---

# 28. Relação com referenciais externos

A Ficha não pretende substituir Summary of Findings ou Evidence Profile.

Ela deverá aproveitar princípios compatíveis, especialmente:

- foco em outcomes críticos/importantes;
- apresentação de magnitude absoluta e relativa quando adequada;
- número de Studies/participantes;
- certainty por outcome;
- explicações transparentes dos julgamentos.

Para decisões informadas, a Ficha deverá manter separadas a síntese da evidência e a decisão/recomendação, coerentemente com princípios de evidence-informed decision-making.

Referências principais:

- Cochrane Handbook, Chapter 14 — Summary of Findings e certainty;
- GRADE Working Group;
- WHO — Evidence, policy, impact: guide for evidence-informed decision-making.

---

# 29. Decisões consolidadas

1. A Ficha de Evidência é a unidade persistente central preferencial para perguntas focais reutilizáveis.
2. A Ficha é Product subtype e não nova entidade científica primária.
3. Product ID permanece estável entre atualizações da mesma unidade de conhecimento.
4. Mudança material gera nova ProductVersion.
5. Mudança material da pergunta pode gerar nova Ficha.
6. A Ficha não duplica dados científicos já estruturados.
7. Uma Investigation principal é obrigatória.
8. Syntheses utilizadas na conclusão devem estar explicitamente vinculadas.
9. Certainty formal comunicada exige CertaintyAssessmentVersion concreta.
10. Não existe certainty global artificial da Ficha.
11. Ausência de evidência não equivale a very low certainty.
12. Results prioritários devem ser apresentados por unidade científica apropriada.
13. Study e Report permanecem distintos; contagens devem evitar dupla contagem de publicações.
14. Segurança/danos serão tratados separadamente quando aplicável.
15. Limitações são obrigatórias.
16. Aplicabilidade permanece descritiva até formalização específica.
17. Camada Brasil será aplicada quando o contexto-alvo for brasileiro.
18. Conclusão deverá ser calibrada à evidência e certainty.
19. A Ficha não produz recomendação normativa por si só.
20. Estado editorial e atualidade permanecem separados.
21. Ficha é compatível com M0–M3.
22. Monitor/Alerta não alteram a Ficha automaticamente.
23. Publicação exige gate científico mínimo.
24. O template operacional somente deverá ser criado após esta especificação ser aceita como base.
25. Lacunas físicas identificadas deverão ser tratadas por evolução controlada do baseline, não por campos improvisados no artefato.

---

# 30. Próxima etapa

Após consolidação deste Documento 41:

1. avaliar as lacunas físicas identificadas;
2. decidir se alguma exige migration antes do template;
3. definir o **Contrato de Dados de Produto da Ficha**;
4. somente então criar o template operacional;
5. validar o template com pelo menos um caso real.

---

**Documento vivo. Alterações materiais deverão ser registradas no CHANGELOG.md.**
