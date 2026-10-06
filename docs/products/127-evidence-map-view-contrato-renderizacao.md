# 127 — EvidenceMapView: Contrato de Renderização do Mapa de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** contrato de renderização candidato  
**Dependências canônicas:** Documentos 123–126; migration 016  
**Schema de origem:** `oes.evidence_map_view/0.1`

---

# 1. Finalidade

Definir como `EvidenceMapView` deve alimentar a apresentação do Mapa de Evidências sem introduzir novos julgamentos científicos, metodológicos ou de assurance e sem transformar estrutura visual em evidência causal.

O renderer será:

> **uma camada de apresentação somente leitura sobre uma projeção derivada e versionada.**

O renderer não será:

- mecanismo de busca;
- mecanismo de screening;
- mecanismo de classificação;
- mecanismo de cálculo científico independente;
- mecanismo de criação de gaps;
- approval engine;
- motor de assurance;
- motor de priorização de pesquisa.

---

# 2. Princípio epistemológico de apresentação

O Mapa de Evidências representa:

- distribuição;
- estrutura;
- concentração;
- células vazias dentro de um framework;
- disponibilidade relativa de tipos de evidência.

Não representa automaticamente:

- magnitude de efeito;
- benefício;
- dano;
- eficácia;
- superioridade terapêutica;
- certeza global;
- recomendação clínica;
- prioridade de pesquisa.

Regra visual obrigatória:

> **densidade de evidência não pode ser apresentada como força, qualidade, certeza ou benefício.**

---

# 3. Fonte canônica do renderer

O renderer deve consumir exclusivamente:

> `EvidenceMapView`

Não poderá consultar diretamente:

- tabelas `mapping`;
- Search/Screening;
- Study/Report/Synthesis;
- ReviewerAssignment;
- QualityControlRecord;
- AssuranceRecord;
- provenance graph.

Qualquer informação necessária à apresentação deverá estar projetada pela view.

---

# 4. Regra crítica — coverage e gap são dimensões distintas da visualização

A apresentação deve sempre tornar visíveis:

- `mapping_subtype`;
- `coverage_claim`;
- `gap_claim_mode`;
- `counting_unit_policy`;
- evidence cutoff;
- FrameworkVersion.

Nunca usar o mesmo tratamento visual para:

- `apparent_only`;
- `formal_within_scope`.

## 4.1 Apparent gap

Quando `gap_claim_mode=apparent_only`, a apresentação deverá utilizar linguagem equivalente a:

> **Nenhuma unidade elegível foi localizada nas fontes consultadas para esta classificação.**

Não utilizar:

> **Não existe evidência.**

## 4.2 Formal gap

Quando `gap_claim_mode=formal_within_scope`, a apresentação poderá usar:

> **Gap formal dentro do escopo definido**

somente quando:

- `audit.formal_gap_eligible=true`;
- a célula estiver `in_scope`;
- `gap_eligible=true`;
- o flag derivado correspondente estiver verdadeiro.

Mesmo nesse estado, não inferir ausência universal de evidência.

---

# 5. Gate de publicação e assurance

Assurance e publication gate permanecem dimensões distintas.

Se:

- `audit.assurance_level=A3`;
- `audit.publishable=false`;

a apresentação deverá mostrar simultaneamente:

- assurance A3 existente;
- gate bloqueado;
- publication issues que mantêm o bloqueio.

A3 nunca autoriza o renderer a ocultar falhas de coverage, search, screening, classification ou CellScope.

---

# 6. Fixture sintética

A apresentação da fixture formal deve ser identificável automaticamente pela view.

Quando:

> `audit.synthetic_fixture=true`

o topo da apresentação deverá conter aviso equivalente a:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA MAPA DE EVIDÊNCIAS REAL**

O aviso deverá esclarecer que:

- reviewers/coders são fictícios;
- expert review é sintético;
- A3 é exclusivamente de validação de contrato;
- gaps e concentrações da fixture não representam evidência clínica real.

Não inferir fixture sintética a partir de nomes, UUIDs ou conteúdo textual no renderer.

---

# 7. Camadas de leitura

A apresentação terá quatro camadas.

## 7.1 Camada executiva

Deverá permitir leitura rápida de:

- título;
- pergunta;
- objetivo;
- subtype;
- coverage;
- gap mode;
- counting unit;
- cutoff;
- status de publicação;
- assurance;
- limitações;
- conclusão canônica do mapa;
- principais concentrações/gaps já derivados.

## 7.2 Camada cartográfica

Deverá expor:

- FrameworkVersion;
- eixos;
- categorias;
- CellScope;
- matriz/células;
- counts por tipo;
- counted unit count;
- gaps;
- concentrações;
- drill-down.

## 7.3 Camada metodológica

Deverá expor:

- protocolo;
- codebook;
- coverage policy;
- classification policy;
- searches;
- selection flow;
- reviewer assignments aplicáveis;
- search/screening/classification controls;
- assignments;
- stakeholder engagement.

## 7.4 Camada auditável

Deverá expor:

- schema version;
- IDs/versionamento;
- assurance records;
- publication issues;
- lineage;
- invalidated dependencies;
- update state;
- hashes/artefatos metodológicos.

---

# 8. identity

Exibir:

- title;
- Product ID;
- version;
- product_type;
- version status;
- editorial status;
- publication date quando presente;
- evidence cutoff;
- currency status;
- assurance.

UUID técnico poderá permanecer na camada auditável.

---

# 9. question e investigation

Exibir:

- normalized question;
- original question quando materialmente distinta;
- question type;
- structure type;
- objective;
- investigation type;
- depth level;
- maintenance level;
- investigation cutoff.

Regra:

> depth N0–N4 descreve a investigação de suporte; não deve ser apresentado como “nível do Mapa”.

---

# 10. mapping_method

Exibir explicitamente:

- mapping subtype;
- coverage claim;
- gap claim mode;
- counting unit policy;
- classification policy;
- coverage policy;
- gap rules.

Esses campos não devem ficar escondidos apenas em auditoria.

---

# 11. FrameworkVersion

Exibir:

- Framework ID;
- FrameworkVersion UUID/versão em auditoria;
- primary row dimension code;
- primary column dimension code;
- visualization policy quando existente.

Mudança de FrameworkVersion deverá ser perceptível em comparações históricas.

---

# 12. Protocol

Mapa formal deverá poder exibir:

- protocol artifact type;
- storage key/identificador;
- content hash;
- status.

O renderer não poderá reconstruir protocolo a partir de texto narrativo.

Ausência de protocolo deve permanecer vinculada ao publication issue aplicável.

---

# 13. Codebook

Exibir:

- codebook artifact identifier;
- storage key;
- content hash;
- status.

Regra:

> codebook não é detalhe opcional de UI; é parte da interpretação das categorias do mapa.

---

# 14. dimensions

Exibir, no mínimo:

- code;
- label;
- role;
- multi-valued;
- required;
- order.

Roles devem ser distinguíveis:

- row_axis;
- column_axis;
- filter;
- descriptive.

---

# 15. categories

Exibir:

- dimension;
- category code;
- label;
- parent category quando houver;
- order.

Hierarquia não deve ser achatada de forma que altere semanticamente a classificação.

---

# 16. CellScope

Cada célula apresentada deverá tornar disponível seu estado:

- `in_scope`;
- `not_applicable`;
- `excluded_by_framework`.

## 16.1 In scope

Pode receber contagens e, quando autorizado, gap.

## 16.2 Not applicable

Deve possuir tratamento visual distinto.

Nunca apresentar como gap.

## 16.3 Excluded by framework

Deve ser distinguida de célula vazia e de not_applicable.

Nunca apresentar ausência de evidência.

---

# 17. Cells

A matriz/tabela deverá derivar exclusivamente de `cells[]`.

Cada célula deverá preservar:

- row category;
- column category;
- scope status;
- gap eligibility;
- study count;
- report count;
- synthesis count;
- other count;
- total count;
- counted unit count;
- MapItem UUIDs/drill-down;
- gap flags derivados.

Não recalcular counts no renderer.

---

# 18. Unidade de contagem

`counting_unit_policy` deve aparecer próxima às contagens principais.

## 18.1 Study

O número principal da célula é `study_count`.

Reports adicionais não podem parecer estudos adicionais.

## 18.2 Report

O número principal é `report_count`.

## 18.3 Synthesis

O número principal é `synthesis_count`.

## 18.4 Mixed

Não apresentar um único total como se fosse epistemologicamente homogêneo.

Exibir counts por tipo e declarar que o total agrega unidades heterogêneas.

---

# 19. Drill-down

Toda contagem exibida deverá permitir recuperar os MapItems que a originaram.

Na saída Markdown estática, o mínimo aceitável é:

- identificador da célula;
- count;
- lista/âncoras de MapItems correspondentes.

Em futura UI interativa, click-through poderá substituir a lista expandida, mas não a rastreabilidade.

---

# 20. Gaps

A seção de gaps deverá consumir `gaps[]` e os flags da célula.

## 20.1 empty_cell_gap

Descrever como:

> gap de célula vazia dentro do escopo definido

somente quando formalmente elegível.

## 20.2 apparent_gap

Obrigatoriamente rotular:

> gap aparente

e repetir disclosure de cobertura não exaustiva.

## 20.3 primary_evidence_gap

Descrever como ausência de Study MapItems classificados naquela célula dentro do corpus mapeado.

Não converter automaticamente em necessidade de novo estudo.

## 20.4 synthesis_gap

Descrever como:

> existe evidência primária mapeada, mas nenhuma Synthesis MapItem classificada na célula segundo as regras atuais

Não declarar automaticamente:

> “é necessária uma revisão sistemática”.

---

# 21. Concentrações

`concentrations[]` representa células com contagem positiva.

A apresentação poderá ordenar ou destacar células com maior contagem.

Não poderá:

- rotular maior contagem como “melhor evidência”;
- inferir eficácia;
- inferir maior certainty;
- gerar ranking terapêutico.

Labels como low/medium/high só poderão ser usados quando thresholds estiverem explicitamente versionados em `framework.visualization`.

Quando usados, a regra de threshold deve ser apresentada ou auditável.

---

# 22. Distributions

`distributions` deverá ser apresentado como composição do corpus mapeado.

Exemplos:

- Study count;
- Report count;
- Synthesis count.

Não converter distribuição de tipos em julgamento de qualidade.

---

# 23. map_items

Cada MapItem deverá poder mostrar:

- target ID;
- target type;
- target version;
- item role;
- inclusion basis;
- status.

MapItem é a unidade auditável da cartografia, não necessariamente a unidade principal de contagem.

---

# 24. assignments

Exibir, quando necessário à auditabilidade:

- MapItem;
- dimension;
- category;
- decision state;
- actor;
- actor type;
- assignment method;
- verification status;
- verifier;
- status.

## 24.1 Candidate

Deve ser identificável como codificação candidata.

Não alimentar representação final da célula.

## 24.2 Final

É a classificação que alimenta células/contagens.

## 24.3 AI-assisted

Quando actor_type=`ai_system` ou assignment_method=`ai_assisted`:

- identificar explicitamente uso de IA;
- não usar selo visual equivalente a human verified.

## 24.4 Human consensus

Deve ser distinguível de simples human verification.

---

# 25. Reviewer assignments

Mapas formais deverão poder expor os reviewer assignments relevantes para:

- search peer review;
- screening;
- coding/classification;
- data verification;
- expert independent review.

Exibir:

- stage;
- role;
- actor;
- actor type;
- qualification;
- independence;
- scope;
- conflict status.

Não inferir qualificação a partir do nome do ator.

---

# 26. Method controls

Os controles metodológicos deverão ser distinguíveis por etapa:

- search peer review;
- screening verification;
- classification verification;
- outros controles aplicáveis.

A presença de A3 não substitui sua apresentação.

---

# 27. Searches

Exibir:

- source;
- platform;
- source class;
- execution date;
- result count;
- export artifact;
- status.

Quando coverage for `systematic_comprehensive`, a política de cobertura deve permanecer visível junto da lista de fontes.

---

# 28. Selection flow

Exibir, no mínimo:

- search hits materializados;
- screening decisions;
- full-text exclusions.

Não chamar de PRISMA automaticamente.

O renderer não recalcula o fluxo.

---

# 29. Appraisal

`appraisal[]` é condicional.

Quando vazio:

- não inferir “baixo risco de viés”;
- não criar score global;
- não declarar qualidade não avaliada sem suporte explícito na view/issues.

Quando presente futuramente:

- apresentar framework, target e judgement sem agregação arbitrária.

---

# 30. Certainty

`certainty_links[]` é condicional.

Quando vazio:

- não criar certainty global do mapa;
- não inferir baixa ou alta certeza.

Quando presente:

- manter certainty vinculada às unidades/sínteses correspondentes;
- nunca transformar em certainty do Mapa como um todo.

---

# 31. Stakeholder engagement

Exibir o conteúdo projetado de `stakeholder_engagement`.

Quando `engaged=false`:

- não criar stakeholder endorsement;
- warning correspondente deve permanecer visível quando emitido pelo gate.

---

# 32. Limitações

Exibir literalmente:

> `limitations.summary`

As limitações deverão permanecer próximas à conclusão e ao resumo de gaps/concentrações.

---

# 33. Conclusão do Mapa

A conclusão canônica deverá vir da ProductVersion e ser projetada pela view.

Pode descrever:

- distribuição;
- concentrações;
- gaps operacionais;
- disponibilidade de sínteses;
- heterogeneidade estrutural;
- limitações.

Não poderá:

- declarar que intervenção funciona;
- declarar magnitude de efeito;
- recomendar tratamento;
- criar ranking terapêutico;
- inferir ausência universal de evidência;
- converter gap em research priority.

O renderer não deverá gerar uma conclusão narrativa a partir dos counts.

---

# 34. References

A apresentação deverá exibir as referências rastreáveis do corpus.

Para Study MapItems:

> Reports canônicos ligados aos Studies devem poder ser recuperados pela view.

A lista de referências não pode depender exclusivamente da existência de Report MapItems explícitos.

Não deduplicar editorialmente fora da view quando isso puder alterar provenance.

---

# 35. Provenance e lineage

A camada auditável deve indicar:

- FrameworkVersion concreta;
- MapItem → target version;
- dependency lineage;
- disponibilidade de referência;
- invalidated dependencies.

O renderer não consulta o grafo diretamente.

---

# 36. Update state

Exibir:

- currency status;
- assessed_at;
- assessed_by;
- rationale.

A data de corte deve permanecer visível independentemente de currency status.

---

# 37. Audit

Exibir, no mínimo:

- synthetic_fixture;
- assurance_level;
- required_assurance_level;
- publishable;
- coverage_claim;
- gap_claim_mode;
- counting_unit_policy;
- FrameworkVersion;
- classification completeness;
- formal gap eligibility;
- search controls;
- classification controls;
- lineage available;
- invalidated dependencies;
- publication issues;
- assurance records.

---

# 38. Publication issues

Separar visualmente:

- errors;
- warnings.

Errors:

- blockers formais.

Warnings:

- disclosures/limitações não bloqueantes.

Nenhuma issue deve ser suprimida por:

- A3;
- aparência visual do mapa;
- alta densidade de células;
- conclusão narrativa favorável.

---

# 39. Estados de apresentação

## 39.1 Formal publicável

Quando:

- `audit.publishable=true`;
- assurance requerido satisfeito;
- coverage/gap mode consistentes;

mostrar:

> **Gate de publicação do Mapa: aprovado**

Manter warnings e disclosures.

## 39.2 Formal bloqueado

Quando `audit.publishable=false`:

mostrar:

> **GATE DE PUBLICAÇÃO DO MAPA NÃO APROVADO**

Errors devem aparecer antes de qualquer interpretação de gaps/concentrações.

## 39.3 Exploratório / não exaustivo

Quando coverage não for `systematic_comprehensive`:

mostrar disclosure explícito:

> **Cobertura não exaustiva — o mapa descreve as fontes consultadas e não sustenta alegação universal de ausência de evidência.**

Se `apparent_only`, repetir que gaps são aparentes.

---

# 40. Visualização mínima v0.1

A primeira implementação de template poderá ser estática em Markdown.

Saída mínima:

1. banner/gate/disclosures;
2. identidade;
3. pergunta e objetivo;
4. método do mapa;
5. framework/eixos;
6. resumo do corpus;
7. matriz tabular;
8. gaps;
9. concentrações;
10. MapItems/drill-down;
11. método de busca/seleção/classificação;
12. limitações;
13. conclusão;
14. referências;
15. audit.

Interatividade não é requisito de PASS da primeira versão.

---

# 41. Matriz grande

Quando o número de células exceder a legibilidade de Markdown:

- não truncar silenciosamente;
- fornecer resumo de dimensões;
- apresentar tabela particionada ou lista de células;
- preservar contagens e drill-down;
- registrar no template que a visualização integral poderá exigir UI interativa futura.

Renderer não pode selecionar apenas “células interessantes” sem regra explícita.

---

# 42. Projection Readiness Gate

A revisão do `oes.evidence_map_view/0.1` implementado na migration 016 identificou campos necessários à renderização segura que ainda não são projetados explicitamente.

Antes da criação do template operacional, a view deverá receber extensão **aditiva** para expor:

1. `audit.synthetic_fixture`;
2. `conclusion.text`;
3. metadados auditáveis do protocolo;
4. metadados auditáveis do codebook;
5. reviewer assignments aplicáveis;
6. method controls de search/screening/classification;
7. `audit.lineage_available`;
8. `audit.invalidated_dependencies`;
9. referências alcançáveis por Study MapItems via Study–Report linkage, além de Report MapItems explícitos.

Essa necessidade:

> **não invalida o PASS técnico do Documento 126.**

Ela representa uma exigência da camada de apresentação descoberta após o PASS do contrato de dados.

---

# 43. Regra de evolução

Não reabrir `database/016_evidence_map_contract.sql`.

Implementar as extensões da view em migration aditiva subsequente.

Como as mudanças são aditivas e preservam a semântica dos campos existentes:

> o schema poderá permanecer `oes.evidence_map_view/0.1` enquanto não houver alteração incompatível.

Se algum campo existente mudar de significado ou estrutura de forma incompatível:

> evoluir `schema_version`.

---

# 44. Critérios de PASS do contrato de renderização

O contrato estará apto à implementação do template quando a projeção suportar:

1. identificação inequívoca da fixture sintética;
2. gate aprovado e gate bloqueado;
3. assurance separado do publication gate;
4. subtype/coverage/gap mode/counting unit sempre visíveis;
5. formal gap separado de apparent gap;
6. not_applicable/excluded_by_framework separados de gap;
7. matriz derivada sem recálculo no renderer;
8. drill-down reconciliável;
9. concentração sem inferência de efeito/certeza;
10. protocolo e codebook auditáveis;
11. searches e selection flow;
12. reviewer assignments e stage controls;
13. candidate/final/human/AI classification distinguíveis;
14. conclusion canônica projetada;
15. references completas para Reports e Studies;
16. lineage/invalidation visíveis;
17. update state/cutoff;
18. publication issues sem supressão;
19. nenhum julgamento científico novo criado pelo renderer.

---

# 45. Decisão

> **Contrato de renderização do Mapa de Evidências definido.**

Entretanto:

> **o template operacional ainda não deve ser criado até o fechamento do Projection Readiness Gate do item 42.**

Próxima etapa:

> **implementar migration aditiva para completar a EvidenceMapView 0.1, testar a projeção ampliada e somente então especificar o Template Operacional do Mapa de Evidências.**

---

**Resultado:** contrato de renderização definido; Projection Readiness Gate = **NOT_READY para template**, por campos aditivos de apresentação ainda ausentes na view.
