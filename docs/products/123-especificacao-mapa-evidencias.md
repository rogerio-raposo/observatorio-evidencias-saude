# 123 — Especificação Científica e Funcional do Mapa de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Família:** Produto analítico transversal  
**Data:** 6 de outubro de 2026  
**Status:** especificação inicial consolidada

---

# 1. Finalidade

O Mapa de Evidências do OES é um produto analítico transversal destinado a responder:

> **Que evidência existe, como ela se distribui e onde estão as lacunas dentro de um escopo explicitamente definido?**

Seu objetivo central é representar estrutura e distribuição do corpo de evidências, e não estimar automaticamente efeitos, estabelecer eficácia ou produzir recomendação.

---

# 2. Natureza transversal

O Mapa de Evidências:

- não recebe automaticamente um nível N0–N4;
- deverá declarar a profundidade/rigor da investigação que o sustenta;
- poderá utilizar metodologia de scoping review, mapping review, systematic map, evidence map ou evidence and gap map;
- poderá ser M0–M3;
- poderá reutilizar Studies, Reports, Results, Syntheses e CertaintyAssessments já existentes no OES;
- não cria uma nova classe epistemológica de evidência.

---

# 3. Fronteira com outros produtos

## 3.1 Mapa versus Evidence Scan N0

N0:

- explora rapidamente um campo;
- não pretende completude;
- identifica terminologia, sínteses centrais e aparentes gaps;
- orienta roteamento.

Mapa formal:

- possui framework classificatório explícito;
- busca e seleção compatíveis com a força das alegações de cobertura;
- classifica sistematicamente as unidades incluídas;
- representa distribuição por dimensões pré-definidas;
- pode identificar gaps apenas dentro do escopo metodologicamente sustentado.

## 3.2 Mapa versus N3/N4

N3/N4 respondem perguntas de síntese focal e podem estimar efeitos/certainty.

Mapa:

- prioriza estrutura/distribuição;
- normalmente não combina efeitos;
- não transforma quantidade de estudos em magnitude de benefício;
- não substitui revisão de efetividade.

## 3.3 Mapa versus Overview

Overview tem revisões sistemáticas como unidade principal de síntese.

Mapa pode incluir:

- estudos primários;
- revisões;
- ambos;
- outros tipos de evidência, conforme protocolo.

## 3.4 Mapa versus scoping review

Scoping review é um método de síntese com finalidades próprias.

O Mapa de Evidências é uma família de produto que poderá ser derivada de uma scoping review quando o objetivo e a apresentação forem compatíveis.

Não tratar os termos como sinônimos automáticos.

---

# 4. Subtipos metodológicos iniciais

Vocabulário candidato:

1. `scoping_evidence_map`;
2. `systematic_evidence_map`;
3. `evidence_gap_map`;
4. `descriptive_mapping_review`;
5. `other_evidence_map`.

O subtipo deverá ser declarado no protocolo.

---

# 5. Rota metodológica

A escolha do subtipo deverá considerar:

- pergunta;
- finalidade;
- amplitude do campo;
- unidade de evidência;
- necessidade de completude;
- pretensão de identificar gaps;
- finalidade decisória;
- necessidade de stakeholder engagement;
- recursos disponíveis.

Quanto mais forte a alegação de cobertura/gap, maior a exigência metodológica.

---

# 6. Pergunta e framework

Perguntas típicas:

- que intervenções foram estudadas para quais outcomes?
- quais populações/contextos/geografias estão representados?
- quais desenhos de estudo existem?
- onde há concentração de estudos?
- onde não foram localizados estudos elegíveis dentro do escopo?
- onde existem estudos primários, mas faltam sínteses?
- onde existem revisões, mas estão desatualizadas?

O framework poderá utilizar:

- PICO/PICOS/PICOTS;
- PCC;
- PECO;
- intervention × outcome matrix;
- population × topic;
- exposure × outcome;
- geography × topic;
- design × outcome;
- framework específico do domínio.

---

# 7. Framework do mapa

Todo mapa formal deverá possuir um `Map Framework` pré-especificado ou versionado antes da classificação final.

Deverá definir:

- dimensões;
- categorias;
- hierarquia;
- regras de codificação;
- tratamento de múltipla classificação;
- categorias residuais;
- unidade contada;
- filtros;
- regras para gaps/concentrações.

Alterações relevantes do framework deverão ser registradas.

---

# 8. Stakeholder engagement

Stakeholder engagement não é requisito universal para todo mapa.

É fortemente recomendado quando:

- categorias do mapa refletem necessidades decisórias;
- o mapa orientará prioridades de pesquisa;
- financiamento/agenda de pesquisa poderá ser influenciado;
- outcomes/intervenções relevantes dependem de perspectiva de usuários.

Quando utilizado, registrar:

- quem participou;
- papel;
- etapa;
- influência sobre scope/framework;
- conflitos/interesses;
- mudanças resultantes.

Stakeholders não substituem controles metodológicos.

---

# 9. Protocolo

Mapa formal exige protocolo prospectivo proporcional ao subtipo.

Deverá registrar:

- rationale;
- pergunta/objetivo;
- subtype;
- framework;
- unidade de inclusão;
- elegibilidade;
- fontes;
- busca;
- seleção;
- data charting/coding;
- treinamento/calibração;
- critical appraisal, se aplicável;
- regras de classificação;
- visualização;
- definição de gap/concentração;
- stakeholder engagement, se houver;
- assurance/revisão;
- data de corte;
- plano de atualização.

---

# 10. Busca — princípio

A busca deve ser proporcional à alegação do produto.

## 10.1 Mapa exploratório interno

Pode usar cobertura limitada, desde que:

- não reivindique completude;
- gaps sejam descritos como aparentes;
- limitações sejam explícitas;
- não utilize rótulo de systematic map/EGM formal.

## 10.2 Systematic map/EGM formal

Exige busca:

- sistemática;
- reprodutível;
- abrangente para o escopo;
- documentada por fonte;
- suficientemente sensível para sustentar alegações de distribuição/gap.

Uma busca abreviada não pode ser compensada apenas por linguagem visual sofisticada.

---

# 11. Fontes

As fontes dependem do domínio.

Podem incluir:

- bases bibliográficas;
- bases regionais;
- registros;
- repositórios;
- literatura cinzenta;
- websites institucionais;
- bases especializadas;
- citation chasing;
- fontes regulatórias.

Cada omissão relevante deverá ser justificada.

---

# 12. Seleção

Para mapas formais sistemáticos:

- critérios explícitos;
- screening rastreável;
- razões de exclusão em texto completo;
- controle humano compatível com a alegação de completude;
- discordâncias resolvidas e preservadas.

O protocolo deverá definir se título/resumo e full text serão duplicados ou verificados.

Para rótulo `systematic_evidence_map` ou `evidence_gap_map` formal, o padrão OES deverá tender a avaliação independente em etapas críticas.

---

# 13. Unidade de evidência e contagem

O mapa deverá declarar explicitamente o que cada contagem representa.

Possíveis unidades:

- Study;
- Report;
- Synthesis/review;
- trial registration;
- guideline/HTA;
- outra unidade especificada.

Regra:

> **não contar Reports como se fossem Studies quando múltiplos Reports pertencem ao mesmo Study.**

---

# 14. Data charting / coding

O mapa prioriza dados de classificação de alto nível.

Campos possíveis:

- população;
- idade;
- intervenção/exposição;
- comparador;
- outcome medido;
- desenho;
- contexto;
- país/região;
- setting;
- período;
- tamanho amostral;
- status de publicação;
- existência de síntese;
- framework de appraisal;
- certainty existente;
- equity dimensions;
- implementação.

Não extrair detalhes complexos sem necessidade do framework.

---

# 15. Piloto e confiabilidade de codificação

Antes da classificação em escala:

- pilotar formulário/codebook;
- verificar interpretação das categorias;
- registrar ambiguidades;
- ajustar regras;
- preservar versão do codebook.

Quando categorias exigirem julgamento substantivo, utilizar verificação independente proporcional ao risco.

---

# 16. Critical appraisal

Critical appraisal não é obrigatório em todo Mapa de Evidências.

Deverá ser definido por subtype/finalidade.

## 16.1 Sem appraisal

Permitido quando o objetivo é mapear apenas existência/distribuição.

Deverá declarar:

> **densidade de evidência não equivale a qualidade da evidência.**

## 16.2 Com appraisal

Quando qualidade metodológica fizer parte do mapa:

- utilizar instrumentos adequados;
- ligar appraisal às unidades correspondentes;
- nunca converter appraisal heterogêneo em score global arbitrário do mapa.

---

# 17. Certainty/confidence

Mapa não exige CertaintyAssessment global.

Quando certainty existir:

- vincular à síntese/outcome correspondente;
- representar como atributo/filtro;
- não calcular certainty do mapa pela quantidade de estudos.

---

# 18. Definição de gap

Gap deve ser uma afirmação operacional delimitada.

Forma preferencial:

> **Nenhuma unidade elegível foi localizada para a célula X dentro do escopo, fontes e data de corte definidos.**

Evitar:

> “não existe evidência”.

---

# 19. Tipos candidatos de gap

OES poderá distinguir:

- `empty_cell_gap` — nenhuma unidade elegível localizada na célula;
- `primary_evidence_gap` — ausência de estudo primário elegível;
- `synthesis_gap` — estudos existem, síntese adequada não;
- `population_gap`;
- `outcome_gap`;
- `geographic_gap`;
- `design_gap`;
- `temporal_gap`;
- `quality_gap` — somente quando appraisal foi realizado;
- `certainty_gap` — somente quando certainty relevante foi avaliada/disponível.

Gap é atributo do framework/célula, não entidade causal.

---

# 20. Concentração de evidência

Evidence concentration poderá ser descrita por:

- número de Studies;
- número de Syntheses;
- distribuição temporal;
- distribuição geográfica;
- desenho;
- outras dimensões.

Regra:

> **mais estudos não significa maior efeito, maior certeza ou melhor evidência.**

---

# 21. Células do mapa

A visualização poderá utilizar células definidas pelo cruzamento de dimensões.

Exemplo:

> intervenção × outcome

Cada célula deverá poder recuperar as unidades que originam a contagem.

Não permitir célula sem drill-down/rastreabilidade quando a fonte estiver estruturada no OES.

---

# 22. Visualizações

Possíveis saídas:

- matriz;
- heatmap;
- bubble map;
- tabela dinâmica;
- gráfico temporal;
- mapa geográfico;
- filtros interativos;
- dashboard.

Visualização é camada de apresentação.

A evidência canônica permanece nas entidades estruturadas.

---

# 23. Interatividade

Interatividade é desejável, mas não requisito epistemológico.

Um mapa estático pode ser metodologicamente válido.

Um dashboard interativo não é metodologicamente válido se a recuperação/classificação da evidência for inadequada.

---

# 24. Conclusão do mapa

A conclusão deverá descrever:

- distribuição;
- concentrações;
- gaps operacionais;
- heterogeneidade estrutural;
- disponibilidade de sínteses;
- limitações.

Não deverá, por padrão:

- declarar que intervenção funciona;
- declarar magnitude de efeito;
- produzir ranking terapêutico;
- recomendar conduta;
- inferir ausência universal de evidência.

---

# 25. Evidence gap versus research priority

Gap não é automaticamente prioridade de pesquisa.

Para transformar gap em prioridade, considerar processo adicional com:

- importância do problema;
- valor potencial da informação;
- factibilidade;
- equidade;
- custo;
- stakeholders;
- pesquisa em andamento;
- relevância decisória.

Mapa poderá informar priorização, mas não substituí-la.

---

# 26. Reporting

O guideline de relato deverá seguir o subtype.

Rotas candidatas:

- JBI/PRISMA-ScR quando scoping review sustentar o produto;
- ROSES para systematic maps quando aplicável;
- Campbell EGM templates/standards quando evidence and gap map for a rota;
- guideline específico do domínio quando pertinente.

Conduta e reporting permanecem dimensões distintas.

---

# 27. Assurance

O nível de assurance depende do método e da força das alegações.

## 27.1 Mapa exploratório interno

Pode permanecer A1 ou A2 quando:

- não reivindica completude;
- gaps são explicitamente aparentes;
- não usa rótulo systematic map/EGM formal;
- finalidade é roteamento/planejamento interno.

## 27.2 Systematic map / EGM formal

Deverá exigir:

- verificação metodológica;
- governança;
- controles humanos qualificados compatíveis com busca/seleção/coding;
- revisão especializada independente proporcional;
- assurance formal definido no contrato.

Regra inicial candidata:

> **A3 para systematic_evidence_map/evidence_gap_map formal com alegações de completude/gaps.**

Essa regra deverá ser confirmada no contrato arquitetural.

---

# 28. Uso de IA

IA poderá apoiar:

- descoberta de terminologia;
- deduplicação;
- priorização de screening;
- classificação candidata;
- tagging;
- normalização geográfica;
- extração de metadados;
- detecção de inconsistências;
- geração de visualização.

IA não poderá:

- fabricar cobertura;
- classificar exclusões irreversivelmente sem regra validada;
- transformar zero recuperado em ausência universal;
- criar gaps não sustentados;
- contar Reports como Studies;
- atribuir qualidade/certainty sem método;
- substituir controles humanos quando exigidos pelo subtype formal.

---

# 29. Atualização e manutenção

Mapa é compatível com M0–M3.

Para M1–M3, definir:

- trigger/cadência;
- fontes;
- estratégia atualizável;
- tratamento de novos registros;
- versionamento do framework;
- atualização das células;
- changelog de gaps/concentrações.

Uma célula pode deixar de ser gap em nova versão.

---

# 30. Framework versioning

Alterações em categorias podem mudar contagens sem mudança da literatura.

Portanto registrar separadamente:

- nova evidência;
- recodificação;
- alteração do framework;
- correção;
- mudança de escopo.

Comparações históricas devem indicar versão do framework.

---

# 31. Saída mínima

Mapa formal deverá apresentar:

- Product ID/version;
- pergunta/objetivo;
- subtype;
- framework/version;
- protocolo;
- escopo;
- critérios de elegibilidade;
- fontes/estratégias;
- período/data de corte;
- fluxo de seleção;
- unidade de contagem;
- codebook;
- dimensões/categorias;
- distribuição da evidência;
- gaps operacionais;
- concentrações;
- appraisal/certainty quando aplicável;
- limitações;
- assurance;
- referências;
- provenance;
- visualização ou tabela equivalente;
- update plan.

---

# 32. Casos em que o Mapa é inadequado

Rerrotear quando a necessidade real for:

- descoberta rápida/terminologia → N0;
- resposta focal → N1/N2;
- síntese de decisão abreviada → N3;
- estimativa aprofundada/completa → N4;
- síntese de revisões → Overview;
- monitoramento → Monitor.

---

# 33. Relação com Brasil/SUS

Quando o mapa tiver finalidade brasileira:

- considerar LILACS/BVS e fontes nacionais pertinentes;
- representar geografia;
- permitir filtros Brasil/região;
- distinguir ausência de estudo brasileiro de ausência global;
- registrar contexto SUS quando codificado.

---

# 34. Referenciais metodológicos externos iniciais

Considerar, conforme subtype e finalidade:

- Campbell Collaboration — Evidence and Gap Map protocol/review templates e EGM conduct/reporting standards;
- JBI Manual for Evidence Synthesis — scoping review methodology vigente, incluindo distinção entre scoping, mapping review e EGM;
- Campbell et al./Khalil et al. — literatura metodológica recente sobre Big Picture Reviews e mapping reviews;
- ROSES — reporting standards para systematic map protocols/reports;
- Collaboration for Environmental Evidence — Guidelines and Standards quando systematic map for a rota apropriada;
- PRISMA-ScR quando scoping review for o método subjacente.

---

# 35. Decisões consolidadas

1. Mapa é produto transversal, não N fixo.
2. O subtype/metodologia deve ser explícito.
3. Mapa formal não é N0.
4. Mapa não implica effectiveness synthesis.
5. Gap é escopo-dependente.
6. Empty cell não prova ausência universal.
7. Study e Report não podem ser confundidos na contagem.
8. Appraisal é condicional.
9. Certainty global do mapa não será criada.
10. Evidence concentration não implica evidência forte.
11. Framework/codebook é componente metodológico central.
12. Visualização não substitui método.
13. Interatividade é opcional.
14. Stakeholder engagement é finalidade-dependente.
15. Systematic map/EGM formal deverá ter assurance mais alto que mapa exploratório.
16. IA auxilia classificação, não fabrica coverage/gaps.
17. Mapa pode ser M0–M3.
18. Mudanças do framework devem ser versionadas separadamente de nova evidência.

---

# 36. Próxima etapa

> **Executar revisão de coerência e decisão arquitetural inicial do Mapa de Evidências.**

Perguntas arquiteturais:

- OES-P1 já representa as unidades necessárias?
- é necessária entidade `MapFramework`?
- categorias/dimensões devem ser tabelas ou JSONB controlado?
- como representar Cell sem duplicar evidence units?
- gap deve ser derivado ou persistido?
- como representar codebook/versioning?
- como tratar Study/Report/Synthesis como unidades do mesmo mapa?
- como projetar visualização e filtros?
- como separar systematic map formal de exploratory map?
- como modelar assurance por subtype?

Não criar migration antes dessa decisão.

---

**Resultado:** especificação científica e funcional inicial do Mapa de Evidências consolidada.