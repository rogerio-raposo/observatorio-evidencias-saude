# 91 — Especificação do Template Operacional do Evidence Scan — N0

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — especificação inicial do template  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 86–90  
**Entrada canônica de renderização:** `EvidenceScanView` — `oes.evidence_scan_view/0.1`

---

# 1. Finalidade

Definir como o conteúdo estruturado no EvidenceScanView deverá ser apresentado na primeira versão operacional do **Evidence Scan — N0**.

Regra:

> **o template apresenta o campo explorado; não decide ciência, maturidade ou roteamento.**

O template não poderá:

- criar maturity;
- inventar lacunas;
- resolver controvérsias;
- inferir ausência de evidência;
- decidir routing;
- criar certainty;
- elevar o produto para N1+;
- aprovar publicação.

# 2. Formato inicial

A primeira implementação será **Markdown canônico**.

Motivos:

- legibilidade;
- versionamento Git;
- diff;
- baixo acoplamento;
- transformação futura para HTML/PDF/DOCX;
- compatibilidade com Ficha N2 e Resposta N1.

# 3. Arquitetura de leitura

O Evidence Scan terá duas camadas.

## 3.1 Camada 1 — orientação rápida

Deve permitir compreender imediatamente:

1. pergunta original;
2. objetivo exploratório;
3. descrição do campo;
4. maturidade preliminar;
5. principais sinais encontrados;
6. próxima rota metodológica sugerida;
7. limitações essenciais;
8. data de corte.

## 3.2 Camada 2 — transparência

Deve permitir verificar:

- buscas;
- natureza não exaustiva;
- terminologia;
- tipos de evidência;
- fontes centrais;
- controvérsias;
- lacunas aparentes;
- perguntas candidatas;
- referências;
- assurance;
- publication issues;
- lineage/provenance.

# 4. Ordem canônica das seções

1. Cabeçalho;
2. Pergunta original;
3. Pergunta exploratória/normalizada, quando diferente;
4. Objetivo do scan;
5. Visão geral do campo;
6. Maturidade preliminar;
7. Sinais de evidência;
8. Terminologia relevante, quando presente;
9. Controvérsias aparentes, quando presentes;
10. Lacunas aparentes, quando presentes;
11. Perguntas candidatas, quando presentes;
12. Próxima rota metodológica sugerida;
13. Conclusão exploratória;
14. Limitações;
15. Método exploratório;
16. Fontes centrais;
17. Referências;
18. Garantia metodológica e auditoria.

# 5. Cabeçalho

Exibir:

- título;
- Product ID;
- versão;
- profundidade N0;
- manutenção;
- estado editorial;
- atualidade;
- data de corte;
- assurance;
- publication date quando existir.

UUIDs técnicos ficam para a auditoria final.

# 6. Estado interno versus publicado

## 6.1 A1 interno

Quando assurance=A1 e o artefato não for publicável:

> **ARTEFATO INTERNO — NÃO PUBLICADO**

e, quando o gate também tiver erros:

> **PREVIEW — NÃO PUBLICÁVEL**

Owner governance approval ausente deve permanecer visível.

## 6.2 A2 formal

Quando audit.publishable=true:

- não mostrar preview;
- mostrar gate aprovado;
- exibir publication date;
- manter warnings;
- divulgar ausência de expert review.

# 7. Pergunta

Apresentar primeiro:

`question.original_text`

Se `question.normalized_text` diferir materialmente, apresentar:

> **Formulação exploratória usada no scan:** ...

Isso preserva a distinção Q0/Q1.

# 8. Objetivo

Fonte:

`objective`

Deve aparecer antes dos resultados do scan para impedir interpretação como resposta focal.

# 9. Visão geral do campo

Fonte:

`field_description.text`

Rotular como:

> **Visão geral exploratória do campo**

Se ausente, produto formal não deve ser considerado válido pelo gate.

# 10. Maturidade preliminar

Fonte:

`maturity`

Mostrar:

- categoria localizada;
- rationale;
- qualifier.

Mensagem obrigatória:

> **A maturidade é um julgamento operacional para roteamento e não representa certeza/confiança da evidência.**

# 11. Sinais de evidência

Combinar, sem fundir semanticamente:

- `volume_signals[]`;
- `evidence_types[]`.

Contagens deverão manter qualifiers.

Nunca apresentar somatório de Search counts como total do campo.

# 12. Terminologia

Fonte:

`terminology[]`

Apresentar apenas quando houver conteúdo.

Termos `ambiguous` devem ser marcados como ambíguos.

# 13. Controvérsias aparentes

Fonte:

`controversies[]`

Mostrar:

- statement;
- type;
- status;
- rationale quando disponível.

Título obrigatório:

> **Controvérsias aparentes**

Não usar linguagem de resolução definitiva.

# 14. Lacunas aparentes

Fonte:

`gaps[]`

Título obrigatório:

> **Lacunas aparentes na busca exploratória**

Cada item deverá mostrar qualifier/limitation quando disponíveis.

Mensagem padrão:

> **Uma lacuna registrada em N0 não demonstra ausência definitiva de evidência.**

# 15. Perguntas candidatas

Fonte:

`candidate_questions[]`

Rotular como:

> **Perguntas candidatas para investigação posterior**

Não apresentar como perguntas formalmente adotadas pelo OES, salvo se já materializadas em Question.

# 16. Roteamento

Fonte:

`routing_recommendation`

Apresentar:

- target;
- rationale;
- necessidade de reformulação;
- status.

Título:

> **Próxima rota metodológica sugerida**

Não usar termos como recomendação clínica.

# 17. Conclusão exploratória

Fonte:

`conclusion.text`

Título:

> **Conclusão exploratória**

Deve permanecer após maturidade/routing, não no topo, para reduzir risco de leitura como resposta focal.

# 18. Limitações

Fonte:

`limitations.summary`

Se produto formal publicado e limitações ausentes, a situação é incompatível com o gate.

# 19. Método exploratório

Texto mínimo obrigatório:

> **Busca exploratória e não exaustiva. Este Evidence Scan não pretende demonstrar identificação completa de toda a literatura.**

Exibir Search records em tabela:

- fonte;
- plataforma;
- execução;
- registros;
- hits materializados;
- status.

Apresentar `count_disclaimer` quando qualquer result_count existir.

# 20. Fontes centrais

Fonte:

`central_sources[]`

Apresentar:

- Report ID;
- título;
- publicação;
- estado;
- papel;
- razão;
- localização utilizada.

Se a lista estiver vazia e `traceable_basis_type=search_only_insufficient`, usar o comportamento especial da seção 21.

# 21. Estado insufficient sem Report central

Quando:

- maturity.category=insufficient;
- references=[];
- audit.traceable_basis_type=search_only_insufficient;

não mostrar erro visual de seção vazia.

Exibir:

> **Nenhuma fonte central foi localizada nas buscas exploratórias registradas. Isso não demonstra ausência definitiva de evidência.**

Em seguida:

- mostrar Search records;
- mostrar warning `NO_TRACEABLE_CENTRAL_REPORTS`;
- preservar limitações;
- preservar routing.

# 22. Referências

Fonte:

`references[]`

Quando presentes, apresentar lista deduplicada.

Quando ausentes em estado insufficient válido, usar texto da seção 21.

# 23. Garantia metodológica

Exibir sempre em produto formal:

- assurance level;
- AI methodological verification;
- owner governance approval;
- expert independent review.

Para A2 sem A3:

> **Verificação metodológica:** processo OES assistido por IA.  
> **Aprovação de governança:** realizada pelo proprietário do projeto.  
> **Revisão especializada independente:** não realizada.

# 24. Publication gate

## 24.1 publishable=true

Exibir:

> **Gate de publicação:** aprovado.

Warnings continuam visíveis.

## 24.2 publishable=false

O documento deverá iniciar com:

> **PREVIEW — NÃO PUBLICÁVEL**

e listar errors bloqueantes na auditoria.

# 25. Warnings

Warnings candidatos:

- NO_EXPERT_INDEPENDENT_REVIEW;
- SINGLE_SEARCH_SOURCE;
- NO_TRACEABLE_CENTRAL_REPORTS;
- NO_FORMAL_APPRAISAL;
- NO_STRUCTURED_SEARCH_HITS;
- FIELD_TERMINOLOGY_UNSTABLE;
- APPARENT_EVIDENCE_GAP;
- ROUTING_REQUIRES_REFORMULATION.

Warnings não devem ser confundidos com falha do produto quando o gate estiver aprovado.

# 26. Auditoria técnica

Seção final poderá exibir:

- schema version;
- ProductVersion UUID;
- InvestigationVersion UUID;
- QuestionVersion UUID;
- traceable_basis_type;
- lineage_available;
- assurance records;
- publication issues.

# 27. Transformação de apresentação

O renderer poderá:

- formatar datas;
- ordenar arrays;
- traduzir enums em rótulos;
- omitir seções condicionais vazias;
- apresentar payloads em listas/tabelas.

Não poderá:

- decidir maturity;
- alterar routing;
- criar gap;
- combinar contagens;
- inferir consensus;
- suprimir warning ativo;
- converter ausência de Report em ausência de evidência.

# 28. Critérios de validação do template

O template v0.1 será PASS quando:

1. renderizar `oes.evidence_scan_view/0.1`;
2. mostrar pergunta original;
3. mostrar objetivo;
4. mostrar field description;
5. mostrar não exaustividade;
6. mostrar maturity como julgamento operacional;
7. mostrar routing;
8. mostrar limitações;
9. mostrar central sources quando existentes;
10. mostrar references;
11. suportar controversies/gaps/candidate questions vazios;
12. suportar `search_only_insufficient`;
13. mostrar A1 interno como não publicado;
14. mostrar A2 formal como publicável;
15. mostrar ausência de expert review;
16. preservar publication issues;
17. não deixar tokens não resolvidos;
18. não consultar tabelas científicas;
19. regressões N1/N2 permanecerem verdes.

# 29. Arquivos previstos

- `templates/evidence-scan.md`;
- `templates/evidence-scan-presentation-map.json`;
- `scripts/render_evidence_scan_reference.py`;
- `scripts/validate_evidence_scan_render.py`.

# 30. Próxima etapa

Implementar template Markdown, presentation map, renderer e validator usando a fixture sintética N0 validada.

A implementação deverá consumir exclusivamente:

`EvidenceScanView — oes.evidence_scan_view/0.1`

e não consultar tabelas científicas diretamente.

---

**Documento vivo. Alterações materiais deverão ser registradas no CHANGELOG.md.**