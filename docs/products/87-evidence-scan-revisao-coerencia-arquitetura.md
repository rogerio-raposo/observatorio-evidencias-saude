# 87 — Evidence Scan N0: Revisão de Coerência e Decisão Arquitetural Inicial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — decisão arquitetural inicial consolidada  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 20–21, 28–30, 38, 40, 70, 72, 86; migrations 001–012  
**Baseline:** OES-P1  
**Produto:** OES — Evidence Scan  
**Nível:** N0

---

# 1. Objetivo

Avaliar se o contrato científico/funcional definido no Documento 86 exige alteração estrutural do OES-P1.

Perguntas:

1. as entidades existentes representam adequadamente N0?
2. algum requisito central do scan exige nova tabela?
3. algum requisito exige nova coluna?
4. quais elementos podem ser derivados/projetados?
5. como representar maturidade, controvérsias, lacunas e recomendação de roteamento?
6. qual deve ser o próximo artefato técnico?

---

# 2. Decisão executiva

> **O Evidence Scan N0 não exige nova tabela nem nova coluna na versão inicial.**

OES-P1 + migrations 006–012 já fornecem:

- identidade/versionamento;
- Question;
- Investigation;
- subperguntas;
- Search;
- SearchHit;
- Report/ReportVersion;
- Product/ProductVersion;
- currency state;
- assurance;
- provenance;
- dependency graph;
- referência rastreável a Reports.

Os elementos próprios de N0 serão inicialmente representados por:

1. campos já existentes nas entidades canônicas;
2. relações existentes;
3. `provenance.record` como camada extensível de campos derivados da ProductVersion;
4. projeção derivada específica — futura **EvidenceScanView**.

A decisão preserva a regra:

> **não criar schema específico quando uma estrutura validada já representa o conceito sem perda material.**

---

# 3. Mapeamento do contrato científico para OES-P1

| Requisito N0 | Representação inicial |
|---|---|
| pergunta original | QuestionVersion.original_text |
| pergunta normalizada exploratória | QuestionVersion.normalized_text |
| estrutura/contexto | QuestionVersion.structure_type + context_payload |
| subperguntas candidatas | Question + parent relation / InvestigationQuestion exploratory |
| objetivo do scan | InvestigationVersion.objective |
| profundidade | InvestigationVersion.depth_level = N0 |
| manutenção | InvestigationVersion.maintenance_level |
| data de início | InvestigationVersion.start_date |
| data de corte | InvestigationVersion.evidence_cutoff_date + ProductVersion.evidence_cutoff_date |
| buscas | Search |
| hits | SearchHit |
| referências centrais | Report/ReportVersion + provenance |
| título/público | ProductVersion |
| conclusão exploratória | ProductVersion.conclusion_text |
| limitações | ProductVersion.limitations_summary |
| aplicabilidade exploratória | ProductVersion.applicability_summary, quando pertinente |
| estado editorial | ProductVersion.status |
| atualidade | product.currency_state |
| assurance | product.assurance_record + product.assurance_level() |
| provenance | provenance.record |
| lineage | provenance.dependency_edge |
| artifact renderizado | ProductVersion.rendered_artifact_uuid / artifact layer |

---

# 4. Elementos próprios de N0

Os seguintes elementos não possuem coluna dedicada:

- terminologia relevante;
- descrição estruturada do campo;
- sinais de volume/diversidade;
- maturidade preliminar;
- controvérsias aparentes;
- lacunas aparentes;
- recomendação de roteamento;
- justificativa do roteamento;
- subcampos/temas emergentes.

Isso não constitui, por si só, necessidade de tabela nova.

---

# 5. Uso controlado de provenance como componente extensível

A migration 012 já validou um padrão em que:

- ProductVersion é o alvo;
- `field_path` identifica componente lógico;
- `source_report_version_uuid` identifica fonte, quando houver;
- `source_value` preserva informação extraída;
- `process_type` registra natureza da transformação;
- `transformation` pode documentar julgamento/derivação;
- a view projeta o componente sem nova coluna.

N1 utiliza esse padrão para `key_results.*`.

N0 poderá reutilizá-lo.

---

# 6. Convenção preliminar de field paths N0

Vocabulário candidato:

- `scan.field_description`;
- `scan.terminology.N`;
- `scan.volume_signals.N`;
- `scan.evidence_types.N`;
- `scan.central_sources.N`;
- `scan.maturity`;
- `scan.controversies.N`;
- `scan.gaps.N`;
- `scan.subquestions.N`;
- `scan.routing.recommendation`;
- `scan.routing.rationale`.

`N` representa sequência lógica estável dentro da ProductVersion.

A convenção deverá ser formalizada no contrato de dados antes da implementação.

---

# 7. Tipos de provenance em N0

## 7.1 Extração direta

Exemplo: `scan.volume_signals.0`.

Quando houver fonte documental concreta:

- `source_report_version_uuid` preenchido;
- `process_type = direct_extraction`.

## 7.2 Descoberta terminológica

Exemplo: `scan.terminology.0`.

Quando derivada de Report, a fonte documental deverá ser identificada.

Quando derivada do conjunto da busca, a fonte documental poderá ser nula, mas o processo deverá deixar claro que se trata de julgamento da Investigation/Search.

## 7.3 Julgamento exploratório OES

Exemplos:

- maturidade;
- controvérsia aparente;
- lacuna aparente;
- rota recomendada.

Esses itens são julgamentos do OES e não devem ser apresentados como afirmações literais de uma única fonte.

`process_type` candidato: `oes_exploratory_judgement`.

A rationale deverá ser preservada em `transformation` ou payload equivalente.

---

# 8. Limite semântico do uso de provenance

`provenance.record` não deverá virar tabela genérica de qualquer conteúdo arbitrário.

Seu uso é apropriado quando o componente:

- pertence a uma ProductVersion;
- é material para a interpretação;
- precisa ser rastreável;
- resulta de fonte ou julgamento documentável;
- será projetado para apresentação.

Se futuros produtos exigirem grande conjunto de componentes arbitrários sem relação de provenance, reavaliar arquitetura genérica de componentes.

Nesta etapa:

> **não criar `product_component` genérico.**

---

# 9. Question e subperguntas

O modelo já suporta:

- QuestionVersion original/normalizada;
- hierarquia de Question;
- múltiplas InvestigationQuestion;
- role `exploratory`.

Subperguntas candidatas encontradas no scan:

- podem ser materializadas como Question quando forem relevantes para continuidade;
- não precisam gerar Question formal para todo tema descoberto.

Itens meramente narrativos podem permanecer em `scan.subquestions.N`.

---

# 10. Search e natureza iterativa

Search já suporta fonte, plataforma, estratégia, filtros, data/hora, result_count, strategy_version e status.

Isso é suficiente para documentar ciclos iterativos N0.

Não criar entidade `ExploratorySearch`.

---

# 11. SearchHit

SearchHit é suficiente para preservar capturas, resolver referências posteriormente, registrar hits relevantes e apoiar estimativas operacionais de volume.

N0 não exige captura completa de todos os hits.

A ausência de SearchHit para cada resultado recuperado deverá ser explicitada quando o scan registrar apenas referências materiais.

---

# 12. Report/ReportVersion

Fontes centrais do scan devem ser representadas como ReportVersion quando materialmente utilizadas.

Isso permite identificadores persistentes, versionamento, correções/retrações, provenance, dependency graph e futura reutilização N1/N2.

Não é necessário modelar todo Report encontrado.

---

# 13. Result/Synthesis/Certainty/RiskAssessment

N0 não exige por padrão:

- Result;
- Synthesis;
- CertaintyAssessment;
- RiskAssessment formal.

Esses objetos continuam disponíveis quando já existirem e forem reutilizados.

> **ausência desses objetos não é incompletude arquitetural de N0.**

---

# 14. ProductVersion

Campos atuais são suficientes para o núcleo:

- product_type;
- title;
- intended_audience;
- evidence_cutoff_date;
- publication_date;
- status;
- conclusion_text;
- applicability_summary;
- limitations_summary.

`conclusion_text` em N0 deverá conter **conclusão exploratória**, não conclusão clínica focal.

Elementos estruturados do scan serão projetados separadamente via provenance.

---

# 15. Assurance

A função genérica `product.assurance_level()` já suporta A0–A3.

Não criar assurance específico para N0.

Poderá haver wrapper futuro `product.evidence_scan_assurance_level()` apenas por legibilidade/contrato.

---

# 16. Dois regimes operacionais

## 16.1 Scan interno de roteamento

Pode permanecer:

- Investigation N0;
- artefato operacional;
- A1 após verificação;
- sem publicação formal.

Não precisa obrigatoriamente de Product formal persistente se sua única finalidade for E7/E8 do protocolo de roteamento.

## 16.2 Evidence Scan formal persistente

Quando publicado como produto do OES:

- Product/ProductVersion;
- primary Investigation N0;
- publication date;
- currency state;
- provenance;
- assurance mínimo A2;
- publication gate N0.

Essa distinção evita criar produtos formais desnecessários para toda exploração preliminar.

---

# 17. Publication gate N0 — decisão arquitetural

O gate formal N0 deverá ser específico do subtipo.

Não reutilizar `evidence_response_publication_issues()` nem `evidence_sheet_publication_issues()`.

Reutilizar apenas funções genéricas quando apropriado:

- `product.assurance_level()`;
- `product.product_reference_reports()`.

O gate N0 deverá verificar, no mínimo:

- product_type correto;
- primary Investigation única;
- depth = N0;
- cutoff coerente;
- QuestionVersion vinculada;
- pelo menos uma Search concluída;
- conclusão exploratória;
- limitações;
- routing recommendation ou justificativa de encerramento;
- fontes centrais rastreáveis quando afirmações materiais dependerem delas;
- assurance A2 para publicação formal persistente;
- publication_date;
- nenhum bloqueio ativo;
- disclosure de ausência de expert review.

---

# 18. Warnings N0 candidatos

Warnings não bloqueantes podem incluir:

- `NO_EXPERT_INDEPENDENT_REVIEW`;
- `SINGLE_SEARCH_SOURCE`;
- `NO_SECONDARY_EVIDENCE_SOURCE`;
- `NO_FORMAL_APPRAISAL`;
- `NO_STRUCTURED_SEARCH_HITS`;
- `FIELD_TERMINOLOGY_UNSTABLE`;
- `APPARENT_EVIDENCE_GAP`;
- `ROUTING_REQUIRES_REFORMULATION`.

Warnings científicos não devem ser misturados indiscriminadamente com erros de integridade.

A lista final pertence ao contrato de dados.

---

# 19. EvidenceScanView

N0 deverá possuir projeção própria.

Não reutilizar EvidenceResponseView ou EvidenceSheetView.

Estrutura conceitual candidata:

```text
EvidenceScanView
├── schema_version
├── identity
├── question
├── routing
├── objective
├── method
├── terminology[]
├── field_description
├── evidence_signals[]
├── central_sources[]
├── maturity
├── controversies[]
├── gaps[]
├── candidate_questions[]
├── routing_recommendation
├── limitations
├── applicability
├── references[]
└── audit
```

Essa é uma projeção, não fonte canônica independente.

---

# 20. Reuso de `product.product_reference_reports()`

A função genérica introduzida na migration 012 pode ser reutilizada.

Condição:

as fontes centrais deverão possuir provenance direta ou lineage alcançável.

Poderá existir wrapper `product.evidence_scan_reference_reports()` por clareza de API.

---

# 21. Maturidade

Maturidade é um julgamento operacional do scan.

Não criar tabela `maturity_assessment` nesta etapa.

Representação inicial:

- componente derivado da ProductVersion;
- categoria controlada;
- rationale;
- provenance/process.

Categorias:

- well_synthesized;
- partially_synthesized;
- fragmented;
- emerging;
- saturated;
- insufficient.

Rótulos de apresentação serão localizados no template/view.

---

# 22. Controvérsias

Não criar entidade `Controversy`.

Representar cada controvérsia como componente do scan contendo statement, type, sources, status e rationale.

Tipos candidatos:

- apparent_conflict;
- population_difference;
- intervention_difference;
- outcome_difference;
- temporal_difference;
- methodological_difference;
- unexplained.

Se o conflito precisar de análise científica persistente própria, poderá originar nova Question/Investigation.

---

# 23. Lacunas

Não criar entidade `EvidenceGap` nesta etapa.

Representar como componente N0 com statement, scope, confidence qualifier, supporting search/source e limitation note.

A linguagem deverá manter caráter preliminar.

Mapa de Evidências poderá exigir estrutura própria futuramente.

---

# 24. Recomendação de roteamento

Não existe RoutingRecord físico na baseline atual.

Para N0 v0.1:

- recomendação será componente estruturado da ProductVersion;
- rationale obrigatória;
- route target controlado.

Valores candidatos:

- stop_after_scan;
- repeat_n0;
- N1;
- N2;
- N3;
- N4;
- evidence_map;
- overview;
- other.

A implementação futura poderá motivar um RoutingRecord genérico se o caso real demonstrar necessidade transversal.

Não criá-lo antecipadamente apenas para N0.

---

# 25. Decisão sobre nova migration

A especificação N0 provavelmente exigirá uma migration para:

- wrapper de assurance/referências;
- publication gate N0;
- `EvidenceScanView`.

Entretanto:

> **essa migration não deverá adicionar tabela nem coluna na versão inicial.**

Número candidato:

`013_evidence_scan_contract.sql`

Somente criar após contrato de dados formal.

---

# 26. Riscos da decisão

## 26.1 Provenance usada como camada extensível

Risco: field paths podem proliferar.

Mitigação:

- convenção formal;
- validação de prefixos;
- schema version da view;
- testes de contrato.

## 26.2 Routing sem entidade própria

Risco: recomendação não ser reutilizável transversalmente.

Mitigação:

- caso real N0;
- reavaliar após Evidence Scan;
- considerar RoutingRecord genérico somente com evidência de necessidade.

## 26.3 Maturidade como julgamento derivado

Risco: categoria parecer mais objetiva do que é.

Mitigação:

- rationale obrigatória;
- linguagem operacional;
- ausência de score;
- disclosure no template.

---

# 27. Decisões consolidadas

1. N0 não requer nova tabela.
2. N0 não requer nova coluna.
3. Question/Investigation/Search/SearchHit/Report/Product são reutilizados.
4. `product.assurance_level()` é reutilizado.
5. `product.product_reference_reports()` é reutilizado.
6. componentes específicos do scan usarão provenance controlada.
7. Synthesis/Certainty/RiskAssessment não são obrigatórios.
8. EvidenceScanView será própria.
9. publication gate N0 será próprio.
10. EvidenceResponseView não será reutilizada.
11. maturity/controversy/gap não serão novas entidades na v0.1.
12. routing recommendation será componente N0 na v0.1.
13. scan interno e scan formal persistente permanecem regimes distintos.
14. eventual migration 013 será funcional/projetiva, sem DDL estrutural de tabelas/colunas.

---

# 28. Próxima etapa

Formalizar:

> **Contrato de Dados do Evidence Scan — N0**

O contrato deverá definir:

- `product_type`;
- invariantes;
- field paths;
- payloads;
- enumerações;
- publication issues;
- comportamento A1 interno versus A2 publicado;
- estrutura da EvidenceScanView;
- critérios de validação;
- compatibilidade com rebuild.

Somente depois deverá ser criada a migration 013.

---

**Decisão arquitetural inicial:** reutilizar OES-P1; especializar por contrato, provenance e projeção — não por nova estrutura persistente.