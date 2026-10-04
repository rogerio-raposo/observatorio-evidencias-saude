# 40 — Taxonomia e Arquitetura dos Produtos do OES

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — arquitetura inicial consolidada  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 00, 02, 03, 10–15 e 38  
**Baseline arquitetural:** OES-P1

---

# 1. Finalidade

Este documento define a **taxonomia oficial inicial dos produtos do Observatório de Evidências em Saúde — OES** e estabelece as regras arquiteturais comuns que deverão orientar suas futuras especificações e templates.

O documento responde a quatro perguntas:

1. quais produtos o OES produz;
2. para que serve cada produto;
3. qual profundidade e manutenção são compatíveis com cada produto;
4. quais requisitos mínimos devem permanecer comuns entre produtos.

Este documento **não cria ainda templates individuais**.

---

# 2. Princípio central

Um produto OES é uma camada de conhecimento e comunicação construída sobre uma investigação rastreável.

Regra estrutural:

> **Question → Investigation → Evidence objects → Synthesis/Certainty → Product**

Produto não substitui:

- Question;
- Investigation;
- Study;
- Report;
- Result;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- Provenance.

O produto apresenta e comunica o estado relevante da evidência; as entidades científicas subjacentes permanecem a fonte auditável.

---

# 3. Três famílias de produtos

A taxonomia inicial será organizada em três famílias.

## 3.1 Produtos de investigação

São diretamente determinados pela profundidade N0–N4.

1. OES — Evidence Scan;
2. OES — Resposta de Evidência;
3. OES — Ficha de Evidência;
4. OES — Síntese Rápida de Evidências;
5. OES — Revisão de Evidências.

## 3.2 Produtos analíticos transversais

Não correspondem necessariamente a um único nível linear N0–N4.

6. OES — Mapa de Evidências;
7. OES — Overview de Revisões.

## 3.3 Produtos de manutenção

Pertencem à dimensão M0–M3 e não criam um novo nível de profundidade.

8. OES — Monitor de Evidências;
9. OES — Alerta de Evidência.

---

# 4. Regra de independência entre profundidade e manutenção

A arquitetura N0–N4 responde:

> **quão profundamente a pergunta foi investigada?**

A arquitetura M0–M3 responde:

> **como o conhecimento será mantido ao longo do tempo?**

Portanto:

- Monitor de Evidências não é N5;
- Alerta de Evidência não é uma nova revisão;
- M3 não implica automaticamente N4;
- um produto N2 pode ser M3;
- um produto N4 pode ser M0.

A combinação deverá ser explicitamente registrada.

---

# PARTE I — PRODUTOS DE INVESTIGAÇÃO

# 5. OES — Evidence Scan

## 5.1 Nível

**N0**

## 5.2 Finalidade

Explorar rapidamente um campo para:

- reconhecer sua estrutura;
- localizar sínteses relevantes;
- estimar volume e diversidade da literatura;
- identificar terminologia;
- detectar controvérsias;
- orientar reformulação da pergunta;
- decidir necessidade e profundidade de investigação posterior.

## 5.3 O que não pretende fazer

Evidence Scan:

- não pretende exaustividade;
- não deve alegar identificação completa da literatura;
- não produz nova avaliação formal de certeza;
- não deve sustentar recomendação.

## 5.4 Saída mínima

- pergunta original;
- pergunta exploratória/normalizada;
- objetivo do scan;
- fontes consultadas;
- período da busca;
- sínteses e referências centrais encontradas;
- descrição do campo;
- principais lacunas/controvérsias;
- limitações da busca;
- conclusão exploratória;
- data de corte;
- recomendação de roteamento posterior, quando aplicável.

## 5.5 Manutenção

Compatibilidade preferencial:

- M0;
- M1.

M2/M3 somente se o objeto deixar de ser mero scan e for formalmente rerroteado.

---

# 6. OES — Resposta de Evidência

## 6.1 Nível

**N1**

## 6.2 Finalidade

Responder de forma objetiva a uma pergunta focal quando:

- já existem sínteses recentes e adequadas;
- a necessidade de completude é limitada;
- uma investigação mais profunda seria desproporcional.

## 6.3 Método mínimo

- pergunta focal explícita;
- busca estruturada, ainda que seletiva;
- prioridade a revisões sistemáticas, meta-análises, diretrizes e HTAs adequados;
- verificação de estudos primários decisivos ou posteriores quando pertinente;
- avaliação crítica proporcional das fontes utilizadas;
- declaração de que a busca não pretende completude, quando esse for o caso.

## 6.4 Certeza

Pode utilizar avaliação de certeza existente quando:

- framework é identificável;
- questão/desfecho é compatível;
- não houve alteração material do corpo de evidências;
- limitações são declaradas.

Não simular GRADE/CERQual novo quando não realizado.

## 6.5 Saída mínima

- pergunta;
- resposta sintética;
- método de busca;
- fontes-chave;
- principais resultados;
- certeza/confiança disponível;
- limitações;
- aplicabilidade, quando relevante;
- data de corte;
- referências.

## 6.6 Manutenção

Compatibilidade preferencial:

- M0;
- M1.

M2 pode ser usado em casos justificados, mas monitoramento persistente deverá preferencialmente migrar para ou vincular-se a uma Ficha de Evidência.

---

# 7. OES — Ficha de Evidência

## 7.1 Nível

**N2**

## 7.2 Papel arquitetural

A Ficha de Evidência é definida como:

> **unidade persistente central de conhecimento do OES para perguntas focais reutilizáveis.**

Ela não substitui Study, Result, Synthesis ou CertaintyAssessment.

A Ficha organiza e comunica, de forma versionada, uma visão auditável do estado da evidência para uma pergunta definida.

## 7.3 Finalidade

- manter conhecimento reutilizável;
- permitir atualização sem reconstrução integral;
- servir de base para monitoramento;
- permitir comparação entre versões;
- fornecer síntese estruturada com rastreabilidade.

## 7.4 Conteúdo mínimo

- Product ID e versão;
- Question ID;
- Investigation ID;
- pergunta estruturada;
- finalidade;
- população/contexto;
- intervenção/exposição/teste/fator, quando aplicável;
- comparador, quando aplicável;
- desfechos/achados prioritários;
- método;
- fontes e data de busca;
- critérios de elegibilidade;
- evidência incluída;
- principais Results;
- Synthesis associada;
- magnitude/direção;
- incerteza;
- RiskAssessment relevante;
- CertaintyAssessment por unidade apropriada;
- limitações;
- aplicabilidade;
- conclusão;
- data de corte;
- estado de atualidade;
- histórico/versionamento.

## 7.5 Certeza e garantia

Quando houver nova avaliação formal:

- utilizar registro estruturado;
- preservar unidade de avaliação;
- aplicar o nível de garantia definido no Documento 04;
- para N2 padrão, exigir ao menos A2 antes de publicação;
- declarar explicitamente a ausência de revisão especializada independente quando A3 não estiver presente.

A aprovação do proprietário não deverá ser tratada como validação técnica de GRADE/CERQual.

## 7.6 Manutenção

Compatível com:

- M0;
- M1;
- M2;
- M3.

A Ficha é o produto preferencial para conhecimento que deverá permanecer vivo.

---

# 8. OES — Síntese Rápida de Evidências

## 8.1 Nível

**N3**

## 8.2 Finalidade

Produzir síntese formal e auditável quando há necessidade decisória relevante, mas prazo ou proporcionalidade inviabilizam uma revisão sistemática completa.

## 8.3 Regra metodológica

Toda abreviação deverá ser:

- pré-especificada;
- justificada;
- documentada;
- comunicada no produto.

A Síntese Rápida nunca será apresentada como equivalente metodológico automático a uma revisão sistemática completa.

## 8.4 Saída mínima

Além dos elementos comuns:

- protocolo ou plano metodológico;
- simplificações adotadas;
- fluxo de seleção;
- características dos estudos;
- avaliação crítica;
- resultados por desfecho/achado;
- síntese quantitativa ou narrativa, quando cabível;
- certeza/confiança;
- Summary of Findings quando apropriado;
- limitações decorrentes do método rápido;
- data de corte.

## 8.5 Revisão humana

Exige:

- avaliação estruturada;
- verificação independente das decisões materiais;
- resolução documentada de discordâncias relevantes.

## 8.6 Manutenção

Pode ser:

- M0;
- M1;
- M2;
- M3.

M3 exige protocolo de atualização compatível com living evidence.

---

# 9. OES — Revisão de Evidências

## 9.1 Nível

**N4**

## 9.2 Finalidade

Produto de maior profundidade para situações com:

- alta criticidade;
- necessidade de completude;
- literatura extensa ou conflitante;
- ausência de síntese adequada;
- necessidade de síntese quantitativa complexa;
- finalidade científica, institucional, regulatória, diretriz ou política.

## 9.3 Nomenclatura

“Revisão de Evidências” será o nome de família OES.

O subtipo **Revisão Sistemática** somente poderá ser utilizado quando os requisitos metodológicos correspondentes forem efetivamente cumpridos.

Outros subtipos poderão ser definidos posteriormente quando metodologicamente justificados.

## 9.4 Saída mínima

- protocolo;
- estratégia completa e reproduzível;
- bases e fontes;
- elegibilidade;
- processo de seleção;
- fluxo;
- características dos estudos;
- RiskAssessment;
- Results;
- Synthesis;
- análises de heterogeneidade/sensibilidade quando cabíveis;
- avaliação de missing evidence/publication bias quando cabível;
- CertaintyAssessment;
- Summary of Findings/Evidence Profile quando apropriado;
- limitações;
- aplicabilidade;
- conclusão;
- data de corte;
- materiais reprodutíveis.

## 9.5 Revisão humana

Exige pelo menos:

- dois avaliadores independentes nas etapas críticas definidas pelos protocolos;
- adjudicação ou consenso documentado;
- justificativas completas dos julgamentos materiais.

## 9.6 Manutenção

Compatível com M0–M3.

N4 + M3 poderá constituir revisão sistemática viva quando todos os requisitos específicos forem satisfeitos.

---

# PARTE II — PRODUTOS ANALÍTICOS TRANSVERSAIS

# 10. OES — Mapa de Evidências

## 10.1 Pergunta central

> **Que evidência existe, como ela se distribui e onde estão as lacunas?**

## 10.2 Finalidade

Representar a distribuição da evidência por dimensões relevantes, como:

- população;
- intervenção/exposição;
- comparador;
- desfecho;
- desenho;
- contexto;
- período;
- geografia;
- quantidade de estudos;
- disponibilidade de sínteses.

## 10.3 Rota metodológica

Pode derivar de:

- scoping review;
- evidence map;
- evidence and gap map;
- outro método de mapeamento explicitamente definido.

Não deve ser forçado artificialmente a N2 ou N4.

O nível de rigor, busca e seleção deverá ser declarado no protocolo específico.

## 10.4 Certeza

Mapa de Evidências não implica, por si só, avaliação formal de certeza.

Quando certainty existir para subconjuntos, deverá ser vinculada às unidades científicas correspondentes, sem criar um “score global do mapa”.

## 10.5 Manutenção

M0–M3, conforme finalidade e volatilidade do campo.

---

# 11. OES — Overview de Revisões

## 11.1 Unidade principal

Revisões sistemáticas existentes.

## 11.2 Finalidade

Sintetizar evidência quando:

- múltiplas revisões respondem a perguntas relacionadas;
- há sobreposição entre revisões;
- interessa comparar sínteses existentes;
- uma nova revisão de estudos primários seria desnecessária ou desproporcional.

## 11.3 Requisitos

Deverá explicitar:

- pergunta;
- critérios para revisões;
- estratégia de busca;
- avaliação da qualidade/risco de viés das revisões;
- sobreposição dos estudos;
- atualidade;
- coerência/divergência entre revisões;
- tratamento de revisões conflitantes;
- certeza/confiança quando cabível;
- limitações.

## 11.4 Nível

Não recebe automaticamente um único N pela natureza “overview”.

A profundidade deverá ser registrada conforme método aplicado.

## 11.5 Manutenção

M0–M3.

---

# PARTE III — PRODUTOS DE MANUTENÇÃO

# 12. OES — Monitor de Evidências

## 12.1 Natureza

O Monitor é um **produto/processo de manutenção**, não uma nova síntese independente.

Deverá estar vinculado a:

- Investigation; e/ou
- produto científico persistente, preferencialmente Ficha, Síntese Rápida, Revisão, Mapa ou Overview.

## 12.2 Finalidade

Executar vigilância de novas evidências capazes de modificar:

- Results;
- Synthesis;
- Certainty;
- aplicabilidade;
- conclusão;
- estado de atualidade.

## 12.3 Manutenção

Por definição:

- M2 — monitoramento ativo; ou
- M3 — evidência viva.

## 12.4 Saída operacional mínima

- objeto monitorado;
- pergunta;
- escopo da vigilância;
- fontes;
- estratégia;
- periodicidade;
- última execução;
- data de corte anterior;
- novas referências encontradas;
- triagem;
- avaliação de potencial impacto;
- decisão: sem atualização / avaliar / atualizar;
- próximo estado.

## 12.5 Regra

Ausência de novidade não gera nova versão científica do produto subjacente, salvo necessidade de registrar verificação periódica por política futura.

---

# 13. OES — Alerta de Evidência

## 13.1 Natureza

O Alerta é um **evento comunicacional de manutenção**.

Não é uma nova investigação e não substitui atualização formal do produto.

## 13.2 Gatilho

Pode ser emitido quando nova informação tiver potencial de modificar materialmente:

- benefício;
- dano;
- magnitude;
- precisão;
- certeza;
- aplicabilidade;
- conclusão;
- status regulatório cientificamente relevante;
- validade de uma fonte, como correção ou retração.

## 13.3 Categorias preliminares

Mantêm-se:

- Informativo;
- Relevante;
- Crítico.

A operacionalização quantitativa/temporal pertence à Fase 4.

## 13.4 Saída mínima

- alvo do alerta;
- evento detectado;
- fonte;
- data;
- classificação preliminar;
- possível dimensão afetada;
- justificativa;
- urgência de reavaliação;
- vínculo ao produto/investigação;
- estado: triagem / avaliação / incorporado / descartado.

## 13.5 Regra

> **Alerta não altera a conclusão científica por si só.**

Mudança de conclusão exige processo de atualização rastreável do produto correspondente.

---

# PARTE IV — MATRIZ DE COMPATIBILIDADE

# 14. Profundidade e produto

| Produto | Profundidade típica |
|---|---|
| Evidence Scan | N0 |
| Resposta de Evidência | N1 |
| Ficha de Evidência | N2 |
| Síntese Rápida | N3 |
| Revisão de Evidências | N4 |
| Mapa de Evidências | rota própria / profundidade declarada |
| Overview de Revisões | rota própria / profundidade declarada |
| Monitor de Evidências | herda produto/investigação monitorada |
| Alerta de Evidência | herda produto/investigação afetada |

A relação é orientadora e controlada pelo Routing Record.

## 14.1 Manutenção

| Produto | M0 | M1 | M2 | M3 |
|---|---:|---:|---:|---:|
| Evidence Scan | preferencial | possível | excepcional | excepcional |
| Resposta de Evidência | preferencial | preferencial | possível | excepcional |
| Ficha de Evidência | sim | sim | sim | sim |
| Síntese Rápida | sim | sim | sim | possível |
| Revisão de Evidências | sim | sim | sim | sim |
| Mapa de Evidências | sim | sim | sim | sim |
| Overview de Revisões | sim | sim | sim | sim |
| Monitor de Evidências | não | não | sim | sim |
| Alerta de Evidência | evento | evento | associado | associado |

“Possível” ou “excepcional” exige justificativa de roteamento.

---

# PARTE V — ARQUITETURA COMUM DOS PRODUTOS

# 15. Identidade e persistência

Todo produto formal persistente deverá possuir:

- Product ID;
- ProductVersion;
- Product type;
- Investigation link;
- versão concreta das Syntheses/Certainty Assessments utilizadas, quando aplicável;
- data de corte da evidência;
- estado editorial;
- estado de atualidade;
- provenance suficiente para reconstrução.

OES-P1 permanece o baseline físico.

Nenhuma conclusão deverá depender apenas de texto sem vínculo com a evidência estruturada quando essa estrutura estiver disponível.

---

# 16. Camadas de estado

Para evitar ambiguidade, três dimensões deverão permanecer separadas.

## 16.1 Estado editorial do produto

Categorias iniciais:

- draft;
- under_review;
- published;
- superseded;
- archived.

## 16.2 Estado de atualidade da evidência

Categorias iniciais:

- atual;
- em_avaliacao;
- atualizacao_recomendada;
- desatualizada;
- arquivada.

## 16.3 Estado da evidência científica

É registrado nas entidades metodológicas correspondentes, por exemplo:

- evidence_available;
- no_evidence;
- insuficiente/não estimável, quando definido pelo protocolo.

Essas três dimensões não deverão ser fundidas.

---

# 17. Metadados obrigatórios comuns

Produtos científicos formais deverão registrar, conforme aplicabilidade:

- Product ID;
- version number;
- product type;
- title;
- Question ID;
- Investigation ID;
- finalidade;
- público-alvo;
- profundidade N;
- manutenção M;
- data de início;
- data de corte da evidência;
- data da publicação/versão;
- método;
- fontes;
- responsáveis/revisores;
- status editorial;
- estado de atualidade;
- conclusão;
- limitações;
- referências;
- provenance/version lineage.

Campos não aplicáveis deverão ser explicitamente ausentes, e não preenchidos artificialmente.

---

# 18. Estrutura narrativa comum

Sempre que metodologicamente aplicável, produtos deverão apresentar em ordem reconhecível:

1. pergunta/objetivo;
2. resposta ou conclusão principal;
3. como a evidência foi localizada;
4. que evidência foi encontrada;
5. principais resultados/achados;
6. certeza/confiança;
7. limitações;
8. aplicabilidade;
9. data de corte;
10. referências e rastreabilidade.

A extensão varia por produto; a estrutura epistemológica permanece.

---

# 19. Data de corte

Todo produto que contenha conclusão científica deverá declarar:

> **evidência considerada até [data].**

A data de publicação do produto não substitui a data de corte da evidência.

Quando diferentes componentes possuírem datas distintas, isso deverá ser explicitado.

---

# 20. Certeza/confiança

## 20.1 Regra

O produto comunica a certeza existente; não a inventa.

Deverá manter a unidade apropriada:

- quantitativo: comparação/desfecho/timepoint/estimando;
- qualitativo: ReviewFinding.

## 20.2 Ausência de avaliação formal

Quando certainty não for avaliada:

> **não avaliada formalmente**

e nunca “muito baixa” por conveniência.

## 20.3 Ausência de evidência

Ausência de evidência permanece estado próprio e não categoria de certeza.

---

# 21. Aplicabilidade

Produtos poderão conter uma seção de aplicabilidade quando pertinente.

Até que o método específico de ApplicabilityAssessment seja consolidado:

- a análise poderá ser descritiva;
- o contexto-alvo deverá ser explicitado;
- não haverá score universal;
- ausência de evidência brasileira não implicará automaticamente baixa certeza;
- aplicabilidade permanecerá separada de indirectness quando a pergunta científica não for especificamente brasileira.

A futura operacionalização metodológica poderá ampliar esta seção sem alterar a taxonomia de produtos.

---

# 22. Evidência, interpretação e recomendação

Regra obrigatória em todos os produtos:

> **evidência → certeza → interpretação → aplicabilidade → eventual recomendação**

A Fase 3 não cria um framework de recomendação.

Portanto:

- produtos OES podem apresentar conclusão da evidência;
- podem discutir implicações;
- podem declarar incertezas e aplicabilidade;
- não devem transformar automaticamente certeza em recomendação;
- “recomendamos” somente poderá existir em produto/função futura autorizada por metodologia específica.

---

# PARTE VI — VERSIONAMENTO

# 23. Unidade de versão

Toda alteração material publicada gera nova ProductVersion.

A identidade Product permanece estável.

---

# 24. Classes de mudança

Registrar pelo menos uma classe de mudança:

## 24.1 Editorial

Correção de:

- ortografia;
- formatação;
- referência;
- metadado sem impacto científico.

## 24.2 Evidência nova

Inclusão ou remoção de Study/Report/Result relevante.

## 24.3 Correção científica

Correção/retração/reanálise de evidência já utilizada.

## 24.4 Mudança quantitativa

Alteração relevante de estimativa, intervalo ou resultado sintetizado.

## 24.5 Mudança de certeza

Alteração do CertaintyAssessment/Confidence.

## 24.6 Mudança de aplicabilidade

Nova informação contextual material.

## 24.7 Mudança de conclusão

A interpretação principal mudou materialmente.

Uma versão pode receber múltiplas classes.

---

# 25. Regra de conclusão estável

Nova evidência não implica automaticamente nova conclusão.

O versionamento deverá permitir distinguir:

- atualização sem mudança da conclusão;
- atualização que modifica magnitude;
- atualização que modifica certeza;
- atualização que modifica conclusão.

---

# 26. Correções editoriais

Correções puramente editoriais deverão preservar histórico.

A política operacional futura poderá diferenciar:

- revisão editorial interna sem nova publicação;
- errata publicada;
- nova versão pública.

Nenhuma correção poderá alterar silenciosamente significado científico.

---

# PARTE VII — CRITÉRIOS DE ESCOLHA

# 27. Roteamento produto–necessidade

Regra geral:

| Necessidade | Produto preferencial |
|---|---|
| conhecer rapidamente o campo | Evidence Scan |
| responder pergunta focal com sínteses adequadas | Resposta de Evidência |
| manter pergunta focal reutilizável no acervo | Ficha de Evidência |
| apoiar decisão com método formal abreviado | Síntese Rápida |
| obter síntese aprofundada/completa | Revisão de Evidências |
| mapear distribuição e lacunas | Mapa de Evidências |
| sintetizar revisões existentes | Overview de Revisões |
| acompanhar novas evidências | Monitor de Evidências |
| comunicar evento potencialmente modificador | Alerta de Evidência |

A decisão final pertence ao Routing Record e deve conter justificativa.

---

# 28. Não duplicação

Antes de criar produto mais profundo, perguntar:

> **já existe um produto OES atual ou uma síntese externa robusta que pode ser reutilizada ou atualizada?**

Preferir:

- atualização;
- derivação;
- reutilização estruturada;

em vez de duplicação de investigação.

---

# 29. Produtos derivados

Um mesmo Investigation pode sustentar mais de um Product quando finalidades comunicacionais diferirem.

Exemplo:

- Revisão de Evidências N4;
- uma ou mais Fichas de Evidência derivadas;
- Monitor de Evidências;
- Alertas posteriores.

A derivação deverá apontar para as versões científicas utilizadas.

---

# PARTE VIII — REVISÃO E PUBLICAÇÃO

# 30. Critério mínimo por profundidade

## N0

- transparência do escopo;
- verificação das fontes principais;
- limitações explícitas.

## N1

- verificação das afirmações materiais;
- coerência entre fontes e conclusão;
- incerteza explicitada.

## N2

- entidades científicas estruturadas;
- revisão dos julgamentos materiais antes da publicação;
- certainty formal quando aplicável.

## N3

- verificações independentes conforme protocolos;
- método abreviado declarado;
- decisões materiais auditáveis.

## N4

- controles de revisão exigidos pelos protocolos N4;
- materiais reproduzíveis;
- reporting adequado ao método.

O status `published` somente deverá ser atribuído após os requisitos do nível correspondente.

---

# 31. Uso de IA na produção

IA poderá auxiliar:

- estruturação;
- geração de tabelas;
- transformação de dados estruturados em narrativa;
- detecção de inconsistências;
- comparação entre versões;
- preparação de linguagem calibrada.

IA não poderá:

- criar evidência inexistente;
- alterar certainty sem processo metodológico;
- omitir limitações relevantes;
- atribuir recomendação automaticamente;
- esconder o nível de garantia metodológica;
- apresentar A2 como se fosse revisão especializada independente;
- omitir a ausência de A3 quando ela for material para a interpretação do produto;
- omitir a ausência de revisão especializada independente quando ela não tiver ocorrido;
- apresentar owner approval como validação metodológica especializada.

---

# PARTE IX — DECISÕES CONSOLIDADAS

# 32. Decisões

1. A taxonomia inicial possui nove produtos.
2. Cinco produtos correspondem diretamente a N0–N4.
3. Mapa e Overview são produtos analíticos transversais.
4. Monitor e Alerta pertencem à manutenção e não criam novo nível N.
5. Ficha de Evidência é a unidade persistente central preferencial para perguntas focais reutilizáveis.
6. Todo produto científico formal possui data de corte.
7. Estado editorial, atualidade da evidência e estado científico são dimensões diferentes.
8. Certainty é comunicada na unidade metodológica correta e não inferida quando ausente.
9. Ausência de evidência não equivale a certeza muito baixa.
10. Aplicabilidade permanece separada de certainty quando conceitualmente apropriado.
11. Evidência e recomendação permanecem separadas.
12. ProductVersion registra alterações materiais sem sobrescrever histórico.
13. Monitoramento não altera conclusões silenciosamente.
14. Alertas são eventos; atualização científica exige nova versão do produto.
15. Produtos derivados devem manter vínculo com Investigation/Synthesis/Certainty utilizados.
16. OES-P1 é o baseline arquitetural para persistência dos produtos.
17. Templates serão criados somente depois desta arquitetura comum.

---

# 33. Próxima etapa

Formalizar individualmente os produtos da Fase 3.

Ordem recomendada:

1. **Ficha de Evidência** — por ser a unidade persistente central;
2. Resposta de Evidência;
3. Evidence Scan;
4. Síntese Rápida;
5. Revisão de Evidências;
6. Mapa de Evidências;
7. Overview de Revisões;
8. Monitor de Evidências;
9. Alerta de Evidência.

A especificação da Ficha deverá definir:

- contrato científico;
- seções obrigatórias;
- campos;
- regras de preenchimento;
- relação com Product/Synthesis/Certainty;
- estados;
- versionamento;
- critérios mínimos de publicação;
- exemplo estrutural;
- posteriormente, template.

---

**Documento vivo. Alterações na taxonomia de produtos deverão ser justificadas e registradas no CHANGELOG.md.**
