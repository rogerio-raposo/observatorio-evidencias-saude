# 70 — Contrato de Dados da Resposta de Evidência — N1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato inicial consolidado  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 20–21, 28–30, 38, 40, 68–69  
**Baseline:** OES-P1 + migrations 002–011  
**Produto:** OES — Resposta de Evidência  
**Nível:** N1

---

# 1. Finalidade

Definir como o contrato científico do Documento 68 será representado no baseline OES-P1, distinguindo:

- campos persistidos;
- campos derivados;
- estruturas reutilizadas;
- campos condicionais;
- informações de apresentação;
- invariantes do publication gate.

Este documento não define ainda o layout final nem implementa migration.

---

# 2. Princípio do contrato

A Resposta de Evidência deverá usar a menor quantidade possível de estado próprio.

Regra:

> **persistir identidade, decisão científica e rastreabilidade; derivar apresentação e agregações sempre que possível.**

Não criar:

- tabela paralela de estudos;
- tabela paralela de revisões;
- certainty duplicada;
- fonte bibliográfica duplicada;
- Synthesis artificial apenas para satisfazer o produto.

---

# 3. Classes de campo

| Classe | Significado |
|---|---|
| O | obrigatório para publicação |
| C | condicional |
| D | derivado de estrutura canônica |
| P | persistido diretamente em estrutura existente |
| PR | derivado de provenance/lineage |
| A | apresentação; não cria nova verdade canônica |

---

# 4. Identidade do produto

| Campo lógico | Classe | Fonte canônica | Regra |
|---|---|---|---|
| product_id | O/D | `core.entity.oes_id` | entidade Product |
| product_version_uuid | O/D | `product.product_version.version_uuid` | versão concreta |
| version_no | O/D | `core.entity_version.version_no` | imutável por versão |
| product_type | O/P | `product.product_version.product_type` | candidato físico `evidence_response` |
| title | O/P | `product.product_version.title` | obrigatório |
| intended_audience | C/P | `product.product_version.intended_audience` | quando material |
| editorial_status | O/P | `product.product_version.status` | vocabulário comum |
| publication_date | C/P | `product.product_version.publication_date` | exigida em published |
| evidence_cutoff_date | O/P | `product.product_version.evidence_cutoff_date` | obrigatório |

Nenhuma coluna nova é necessária.

---

# 5. Pergunta e roteamento

| Campo lógico | Classe | Fonte |
|---|---|---|
| investigation_id | O/D | primary `product.investigation_link` |
| investigation_version | O/D | `investigation.investigation_version` |
| depth_level | O/D | InvestigationVersion; deve ser N1 |
| maintenance_level | O/D | InvestigationVersion |
| objective | O/D | InvestigationVersion.objective |
| question_id | O/D | InvestigationVersion.primary_question_entity_uuid |
| question_text/estrutura | O/D | QuestionVersion correspondente |
| routing justification | C/D | Routing Record / protocol artifact quando materializado |

Invariante:

> exatamente uma Investigation primary por ProductVersion.

Para Resposta de Evidência, a primary Investigation deve ser N1.

---

# 6. Resposta sintética

| Campo | Classe | Fonte |
|---|---|---|
| answer/conclusion | O/P | `product.product_version.conclusion_text` |
| applicability summary | C/P | `product.product_version.applicability_summary` |
| limitations summary | O/P | `product.product_version.limitations_summary` |

`conclusion_text` é a resposta sintética principal N1.

Não será criada coluna separada `answer_text`.

---

# 7. Método de busca

A busca N1 será derivada da Investigation.

| Campo | Classe | Fonte |
|---|---|---|
| databases/sources searched | O/D | `investigation.search.source_name` |
| platform | C/D | `investigation.search.platform` |
| exact strategy | O/D | `investigation.search.exact_strategy` |
| filters | C/D | `investigation.search.filters_payload` |
| executed_at | O/D | `investigation.search.executed_at` |
| result_count | C/D | `investigation.search.result_count` |
| operator | C/D | `investigation.search.operator` |

Declaração metodológica padrão N1:

> **a busca é estruturada e seletiva; não pretende demonstrar identificação exaustiva de toda a literatura.**

Essa frase é regra do produto e pode ser gerada pela projeção/template; não requer coluna própria.

Publication gate deve exigir ao menos um registro de busca compatível com a Investigation primary, salvo exceção formalmente justificada em futura regra específica.

---

# 8. Seleção

Quando houver SearchHit/ScreeningDecision, reutilizar:

- `investigation.search_hit`;
- `investigation.screening_decision`;
- deduplicação existente quando utilizada.

N1 não exige que todos os registros recuperados passem por fluxo completo de screening formal.

Entretanto fontes decisivas selecionadas devem ser identificáveis como Reports e rastreáveis à Investigation ou ao Product.

---

# 9. Fontes-chave

## 9.1 Identidade canônica

A identidade bibliográfica permanece em:

- `evidence.report`;
- `evidence.report_version`.

## 9.2 Vínculo com a Resposta

O vínculo de suporte a afirmações será representado por:

`provenance.record.target_version_uuid = ProductVersion`

com:

- `field_path` = campo/projeção N1 sustentada;
- `source_report_version_uuid` = ReportVersion fonte;
- `source_location` = página/tabela/seção;
- `source_value` = valor ou conteúdo extraído quando aplicável;
- `process_type` = processo de uso/extração;
- `transformation` = transformação, se houver.

## 9.3 Papéis de apresentação

`key_sources[].role` será inicialmente **derivado**, não persistido como nova verdade canônica.

Regra candidata:

- decisive: fonte com provenance ativa para `conclusion_text` ou `key_results.*`;
- supporting: fonte que sustenta interpretação material adicional;
- contextual: fonte usada apenas para contexto/aplicabilidade;
- update: fonte usada em atualização posterior à síntese-base;
- regulatory/institutional: fonte cujo tipo/origem justifique essa identificação.

Se um caso real demonstrar que a derivação é ambígua ou insuficiente, uma estrutura explícita de source link poderá ser reavaliada.

## 9.4 Decisão

> **v0.1 não cria `product.source_link`.**

---

# 10. Resultados-chave sem Synthesis formal

N1 pode precisar comunicar resultados de revisão, diretriz ou estudo sem materializar Synthesis OES.

Nesse cenário, os resultados-chave serão representados por provenance no ProductVersion.

Exemplo lógico:

`field_path = key_results.0.effect_estimate`

`source_value = {measure, estimate, lower, upper, unit, context}`

A representação deve:

- preservar o valor original;
- registrar localização;
- indicar transformação quando houver;
- não transformar automaticamente o dado em Result/Synthesis OES.

`key_results[]` será uma projeção derivada desses registros.

Se o resultado já existir como Result/Synthesis OES, a projeção deverá preferir a entidade estruturada em vez de duplicar o valor no produto.

---

# 11. Synthesis

`product.synthesis_link` é condicional.

Usar quando:

- uma SynthesisVersion OES existente for reutilizada;
- síntese externa tiver sido formalmente representada como Synthesis;
- composição N1 depender de uma síntese estruturada.

Não usar apenas para preencher requisito visual.

Publication gate N1 não exigirá Synthesis universalmente.

---

# 12. Certeza/confiança

`product.certainty_link` é condicional.

Quando certainty formal compatível estiver estruturada no OES:

- vincular CertaintyAssessmentVersion concreta;
- projetar framework, nível e justificativas relevantes;
- preservar provenance.

Quando a fonte externa apenas relatar certainty e ela não for estruturada no OES:

- registrar a afirmação via provenance;
- comunicar como certainty relatada pela fonte;
- não apresentá-la como nova avaliação OES.

Quando não existir certainty formal compatível:

- campo formal permanece ausente/NA;
- incerteza é descrita narrativamente.

---

# 13. Avaliação crítica

RiskAssessment é condicional.

Quando realizado appraisal formal:

- reutilizar `appraisal.risk_assessment_version`;
- manter framework e alvo originais;
- não copiar julgamento para texto como nova fonte canônica.

Quando avaliação crítica for proporcional e narrativa, limitações materiais podem ser registradas em `limitations_summary` e sustentadas por provenance.

---

# 14. Aplicabilidade

Enquanto ApplicabilityAssessment formal permanecer não operacional:

- utilizar `product.product_version.applicability_summary`;
- provenance deve sustentar afirmações factuais relevantes;
- a projeção deve indicar que não se trata de avaliação formal estruturada.

---

# 15. Atualidade e versionamento

Reutilizar:

- `product.currency_state`;
- `product.version_change_class`;
- core versioning.

Uma Resposta publicada deverá possuir estado de atualidade ativo.

M0/M1 são os estados preferenciais de manutenção.

---

# 16. Assurance

Reutilizar `product.assurance_record`.

Assurance derivado:

- A0: requisitos de A1 ausentes;
- A1: AI methodological verification passed;
- A2: A1 + owner approved;
- A3: A2 + expert approved.

Para publicação formal N1 padrão:

> **mínimo A2.**

A ausência de A3 deve permanecer explícita.

---

# 17. Invariantes do publication gate N1

O gate deverá gerar erro quando ocorrer qualquer condição abaixo:

1. ProductVersion inexistente;
2. `product_type` diferente do tipo N1 definido;
3. ausência ou multiplicidade de Investigation primary;
4. primary Investigation diferente de N1;
5. ProductVersion não corrente;
6. título ausente;
7. `conclusion_text` ausente;
8. `limitations_summary` ausente;
9. `evidence_cutoff_date` ausente;
10. ausência de busca registrada para a Investigation sem exceção formal;
11. ausência de qualquer ReportVersion rastreável que sustente a resposta;
12. assurance abaixo de A2 para status published;
13. AI verification ativa em revise/failed;
14. owner approval ativa em revise/rejected;
15. expert review ativa em revise/rejected;
16. status published sem publication_date;
17. certainty formal comunicada sem vínculo/provenance compatível.

O gate poderá emitir warnings para:

- ausência de expert review;
- apenas uma fonte decisiva;
- busca em uma única fonte bibliográfica;
- fonte-base com cutoff significativamente anterior ao cutoff do produto;
- ausência de appraisal formal quando uma única fonte sustenta quase toda a conclusão.

Warnings não substituem rerroteamento quando a criticidade tornar N1 inadequado.

---

# 18. Contrato lógico de projeção

Projeção candidata:

`oes.evidence_response_view/0.1`

Estrutura:

~~~text
EvidenceResponseView
├── schema_version
├── identity
├── question
├── routing
├── answer
├── method
├── key_sources[]
├── key_results[]
├── certainty
├── limitations
├── applicability
├── references[]
└── audit
~~~

## 18.1 identity

- product_id;
- product/version UUID;
- version_no;
- product_type;
- title;
- intended_audience;
- status;
- publication_date;
- evidence_cutoff_date;
- currency status.

## 18.2 question

- Question ID/version;
- question type;
- structured question payload quando existente;
- question text/label.

## 18.3 routing

- Investigation ID/version;
- depth_level=N1;
- maintenance_level;
- objective.

## 18.4 answer

- conclusion_text.

## 18.5 method

- searches[];
- non_exhaustive=true;
- selection summary derivável;
- appraisal summary quando existente.

## 18.6 key_sources[]

- report ID/version;
- report type;
- title;
- publication date;
- journal/source;
- derived role(s);
- source locations;
- appraisal reference quando existente.

## 18.7 key_results[]

Pode ser composto por:

- dados estruturados de Result/Synthesis existentes; ou
- provenance direta no ProductVersion.

Cada item deve expor origem.

## 18.8 certainty

- structured assessment quando vinculada;
- reported certainty quando apenas provenanciada;
- ou `formal_assessment=false`.

## 18.9 limitations

- `limitations_summary`;
- provenance material.

## 18.10 applicability

- summary;
- `formal_assessment=false` enquanto camada formal não existir.

## 18.11 references[]

União deduplicada de ReportVersions alcançadas por provenance direta ou por Synthesis/Certainty vinculadas.

## 18.12 audit

- publishable;
- assurance level;
- assurance records;
- expert independent review flag;
- publication issues;
- lineage availability.

---

# 19. Necessidade de nova migration

Conclusão do contrato:

> **não é necessária nova tabela para representar a Resposta de Evidência v0.1.**

Uma migration técnica poderá, entretanto, ser necessária para adicionar:

1. função genérica de assurance derivado, se aprovada;
2. `evidence_response_publication_issues()`;
3. `evidence_response_is_publishable()`;
4. `evidence_response_reference_reports()` ou helper genérico equivalente;
5. `evidence_response_view()`.

Essas funções/projeções não alteram o modelo científico central.

---

# 20. Critério para reabrir o modelo

Nova estrutura persistente somente será considerada se um caso de validação demonstrar que o baseline atual não consegue representar sem perda semântica:

- papel de fontes decisivas;
- resultados-chave;
- relação entre síntese-base e atualização;
- certainty reportada versus certainty OES;
- provenance da conclusão.

Até lá:

> **preferir composição sobre extensão do schema.**

---

# 21. Decisões consolidadas

1. `product_type` N1 terá valor físico específico a validar na implementação.
2. ProductVersion existente cobre identidade, resposta, datas, estado, limitações e aplicabilidade.
3. Investigation/Search existentes cobrem roteamento e método.
4. provenance cobre suporte direto de Reports a afirmações do produto.
5. `key_results[]` pode ser derivado de provenance quando não houver Synthesis.
6. Synthesis e Certainty são condicionais.
7. RiskAssessment formal é condicional.
8. source role será inicialmente derivado.
9. não será criada `product.source_link` na v0.1.
10. não será criada tabela de key results.
11. publication gate N1 será específico.
12. EvidenceResponseView será específica, mas somente leitura e derivada.
13. não há necessidade atual de nova tabela ou coluna.

---

# 22. Próxima etapa

Implementar e testar o contrato N1 em uma migration controlada contendo somente funções/projeções necessárias, acompanhada de fixtures e testes específicos.

A implementação deverá preservar regressões da Ficha de Evidência e do baseline F2-B/S4/S5.

Depois do PASS técnico:

1. formalizar o contrato `EvidenceResponseView`;
2. criar template operacional N1;
3. validar ponta a ponta com caso real.

---

**Documento vivo. Alterações materiais deverão ser registradas no CHANGELOG.md.**