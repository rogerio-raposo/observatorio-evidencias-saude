# 72 — EvidenceResponseView: Contrato de Renderização da Resposta de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato de renderização inicial  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 68–71  
**Baseline:** OES-P1 + migration 012  
**Produto:** OES — Resposta de Evidência  
**Nível:** N1  
**Schema version:** `oes.evidence_response_view/0.1`

---

# 1. Finalidade

Definir formalmente a projeção estruturada que alimentará a apresentação da **Resposta de Evidência — N1**.

O objeto é denominado:

> **EvidenceResponseView**

Ele é uma representação derivada e somente de leitura.

Não é:

- entidade científica;
- fonte canônica independente;
- substituto de ProductVersion;
- substituto de Investigation/Search;
- substituto de Report/Result/Synthesis/Certainty;
- template final;
- mecanismo de decisão metodológica.

Sua função é reunir, de forma reproduzível, os dados necessários à apresentação N1 sem duplicar o modelo científico.

---

# 2. Princípios

EvidenceResponseView deverá ser:

- derivada de entidades canônicas;
- determinística para o mesmo estado do banco;
- somente leitura;
- específica do subtipo `evidence_response`;
- compatível com ausência de Synthesis;
- compatível com ausência de CertaintyAssessment;
- provenance-aware;
- assurance-aware;
- explicitamente não exaustiva em sua descrição metodológica N1.

A view não deverá transformar simplificação operacional em alegação de completude.

---

# 3. Separação entre camadas

A arquitetura seguirá:

`Entidades canônicas → EvidenceResponseView → Template/Renderização`

A EvidenceResponseView poderá:

- agregar;
- ordenar;
- projetar;
- derivar rótulos de apresentação;
- expor audit state.

Ela não poderá:

- criar novo julgamento científico;
- escolher fonte decisiva sem base rastreável;
- recalcular certainty;
- criar meta-análise;
- inferir recomendação;
- alterar estado editorial;
- aprovar publicação.

---

# 4. Estrutura de topo

```text
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
```

---

# 5. Versionamento do contrato

A versão inicial será:

`oes.evidence_response_view/0.1`

Esse versionamento é independente de:

- ProductVersion;
- versão da Investigation;
- versão metodológica;
- versão do template;
- versão do artefato renderizado.

Mudança incompatível na estrutura JSON deverá alterar `schema_version`.

Mudança apenas de template não altera necessariamente a versão da view.

---

# 6. identity

Campos:

- `product_id`;
- `product_entity_uuid`;
- `product_version_uuid`;
- `version_no`;
- `product_type`;
- `title`;
- `intended_audience`;
- `editorial_status`;
- `entity_version_status`;
- `publication_date`;
- `evidence_cutoff_date`;
- `currency_status`.

Fontes:

- Product;
- ProductVersion;
- EntityVersion;
- current currency state.

Invariante:

> `product_type = evidence_response` para uso normal da projeção N1.

---

# 7. question

Campos:

- `question_id`;
- `question_entity_uuid`;
- `question_version_uuid`;
- `original_text`;
- `normalized_text`;
- `question_type`;
- `structure_type`;
- `context`;
- `time_horizon`.

Fonte:

QuestionVersion vinculada como pergunta primária da Investigation primary.

Regra:

> a pergunta exibida deve ser a versão concreta associada à Investigation usada por aquela ProductVersion.

Não substituir automaticamente pela “última pergunta” se a ProductVersion foi construída sobre versão histórica específica.

---

# 8. routing

Campos:

- `investigation_id`;
- `investigation_entity_uuid`;
- `investigation_version_uuid`;
- `investigation_type`;
- `depth_level`;
- `maintenance_level`;
- `objective`;
- `start_date`;
- `evidence_cutoff_date`.

Invariante N1:

`depth_level = N1`

A view apenas expõe o roteamento; não o decide.

---

# 9. answer

Objeto:

- `text`;
- `recommendation_present`.

Na versão 0.1:

- `text` deriva de `ProductVersion.conclusion_text`;
- `recommendation_present = false` por padrão do produto N1.

Regra:

> EvidenceResponseView comunica resposta/conclusão de evidência, não recomendação clínica ou normativa automática.

---

# 10. method

Campos iniciais:

- `non_exhaustive`;
- `searches[]`.

## 10.1 non_exhaustive

Para N1 padrão:

`true`

Significa:

> a busca é estruturada e seletiva e não pretende demonstrar identificação exaustiva de toda a literatura.

Não significa busca arbitrária ou não documentada.

## 10.2 searches[]

Para cada Search:

- `search_id`;
- `source_name`;
- `platform`;
- `exact_strategy`;
- `filters`;
- `executed_at`;
- `result_count`;
- `status`.

Fonte:

`investigation.search`

Regra:

a view não altera nem resume silenciosamente a estratégia original.

---

# 11. key_sources[]

Representa as fontes que sustentam materialmente a resposta.

Campos:

- `report_id`;
- `report_entity_uuid`;
- `report_version_uuid`;
- `title`;
- `publication_date`;
- `publication_status`;
- `source_locations`;
- `roles[]`;
- `formal_appraisal_count`.

## 11.1 Identidade

A identidade vem de Report/ReportVersion.

## 11.2 Origem da vinculação

As fontes podem ser alcançadas por:

- provenance direta ProductVersion → ReportVersion;
- lineage por Synthesis;
- lineage por CertaintyAssessment;
- dependency graph.

## 11.3 roles[]

Os papéis são inicialmente derivados para apresentação.

Vocabulário inicial:

- `decisive`;
- `supporting`;
- `contextual`;
- `linked_evidence`.

Na implementação v0.1:

- provenance para `conclusion_text` ou `key_results.*` → `decisive`;
- provenance para `applicability*` → `contextual`;
- demais provenance direta → `supporting`;
- fonte alcançada apenas por lineage sem classificação direta → `linked_evidence`.

Esses rótulos não substituem provenance.

## 11.4 Limite semântico

Se caso real demonstrar que múltiplos papéis não podem ser derivados de forma estável, o contrato poderá evoluir.

Não criar nova estrutura persistente apenas por conveniência visual.

---

# 12. key_results[]

Representa resultados materiais usados na resposta quando eles não estiverem necessariamente modelados como Synthesis/Result OES.

Na versão 0.1, provenance direta com:

`field_path LIKE 'key_results.%'`

poderá gerar item contendo:

- `field_path`;
- `source_report_id`;
- `source_report_version_uuid`;
- `source_location`;
- `source_value`;
- `process_type`;
- `transformation`.

## 12.1 Regra de precedência

Quando um resultado já estiver estruturado como Result/Synthesis OES:

> preferir projeção da entidade estruturada, evitando duplicação.

A provenance direta é válida para o caso N1 mínimo em que a resposta adota criticamente informação externa sem reconstruir uma Synthesis OES.

## 12.2 Não promoção automática

A presença de `source_value` em key_results não transforma esse valor em Result ou Synthesis canônica.

---

# 13. certainty

Objeto:

- `formal_assessment`;
- `assessments[]`.

## 13.1 Certainty estruturada

Quando houver `product.certainty_link`:

`formal_assessment = true`

e cada assessment poderá expor:

- `certainty_id`;
- `version_uuid`;
- `framework`;
- `framework_version`;
- `final_level`;
- `evidence_state`;
- `assessment_date`;
- `role`.

## 13.2 Sem certainty formal

Na ausência de CertaintyAssessment vinculada:

`formal_assessment = false`

Isso é válido em N1.

O template deverá comunicar incerteza sem simular GRADE/CERQual.

---

# 14. limitations

Objeto:

- `summary`;
- `present`.

Fonte:

`ProductVersion.limitations_summary`

Regra:

limitations é conteúdo interpretativo persistido do produto.

A view não deverá fabricar automaticamente uma lista de limitações a partir de todos os objetos upstream.

---

# 15. applicability

Objeto:

- `summary`;
- `formal_assessment`.

Na versão 0.1:

- `summary` deriva de `ProductVersion.applicability_summary`;
- `formal_assessment = false`.

Essa regra permanece até ApplicabilityAssessment operacional ser formalizado.

---

# 16. references[]

Lista deduplicada de ReportVersions rastreáveis.

Cada referência poderá conter:

- `report_id`;
- `report_entity_uuid`;
- `report_version_uuid`;
- `title`;
- `publication_date`;
- `publication_status`;
- `source_locations`.

A lista pode incluir fontes alcançadas por lineage além das fontes classificadas diretamente como decisivas.

Regra:

> references é projeção de rastreabilidade, não bibliografia manual paralela.

---

# 17. audit

Campos:

- `publishable`;
- `assurance_level`;
- `expert_independent_reviewed`;
- `assurance_records[]`;
- `assurance_disclosure`;
- `publication_issues[]`;
- `lineage_available`.

## 17.1 publishable

Derivado de:

`product.evidence_response_is_publishable()`

## 17.2 assurance_level

Derivado de:

`product.evidence_response_assurance_level()`

com regra A0–A3 comum.

## 17.3 assurance disclosure

A2 sem A3 deverá comunicar explicitamente:

> verificação metodológica assistida por IA e aprovação de governança registradas; revisão especializada independente não realizada.

## 17.4 publication_issues[]

Derivada de:

`product.evidence_response_publication_issues()`

Warnings permanecem visíveis e não são apagados porque o produto seja publishable.

---

# 18. Publication gate versus view

A view não decide publicação.

Fluxo:

`dados canônicos → publication issues → publishable → EvidenceResponseView.audit`

A projeção deve expor o resultado do gate sem duplicar sua lógica.

---

# 19. Comportamento com Synthesis opcional

EvidenceResponseView deve funcionar em três configurações:

### A — sem Synthesis

Resposta sustentada diretamente por ReportVersion via provenance.

### B — com Synthesis

Resposta reutiliza SynthesisVersion estruturada.

### C — híbrida

Synthesis-base + Reports adicionais.

A ausência de Synthesis não pode, isoladamente, tornar a view inválida em N1.

---

# 20. Comportamento com Certainty opcional

A view deve funcionar:

- com CertaintyAssessment estruturada;
- sem CertaintyAssessment;
- futuramente com certainty reportada por fonte externa, desde que claramente distinguida de avaliação OES.

A ausência de certainty formal deve permanecer explícita.

---

# 21. Reprodutibilidade histórica

ProductVersion deve apontar para versões concretas.

A view não deverá substituir automaticamente:

- ReportVersion;
- SynthesisVersion;
- CertaintyAssessmentVersion;
- QuestionVersion;
- InvestigationVersion;

por versões mais recentes.

Regra:

> **a projeção de uma ProductVersion histórica deve continuar reproduzível.**

---

# 22. Critérios de PASS do contrato

EvidenceResponseView = PASS quando:

1. schema version é explícita;
2. ProductVersion correta é projetada;
3. pergunta histórica correta é preservada;
4. Investigation primary N1 é preservada;
5. buscas são expostas sem alegação de exaustividade;
6. fontes decisivas são rastreáveis;
7. key_results possuem origem;
8. ausência de Synthesis é suportada;
9. ausência de CertaintyAssessment é suportada;
10. assurance é derivado corretamente;
11. publication issues permanecem visíveis;
12. referências são provenance-aware;
13. não há nova fonte canônica;
14. regressões N2 permanecem verdes;
15. rebuild reproduz a mesma estrutura funcional.

A migration 012 e o Documento 71 já demonstraram PASS técnico inicial para esses requisitos no fixture N1 mínimo.

---

# 23. Relação com template

Somente após este contrato:

> **EvidenceResponseView → Template da Resposta de Evidência**

O template será transformação de apresentação.

Ele não decidirá:

- quais fontes são válidas;
- qual certainty deve ser usada;
- se a busca é suficiente;
- se N1 é o nível correto;
- se o produto pode ser publicado.

---

# 24. Decisões consolidadas

1. EvidenceResponseView é projeção derivada, não entidade.
2. Schema inicial = `oes.evidence_response_view/0.1`.
3. A view é específica de N1.
4. Busca seletiva/non-exhaustive deve ser explícita.
5. Synthesis é opcional.
6. CertaintyAssessment é opcional.
7. key_sources são provenance-aware.
8. roles são inicialmente derivados.
9. key_results podem vir de provenance direta.
10. EvidenceResponseView não duplica EvidenceSheetView.
11. Assurance é transversal; publication gate é específico.
12. O template não poderá conter lógica científica escondida.

---

# 25. Próxima etapa

Especificar o:

> **Template Operacional da Resposta de Evidência — N1**

A especificação deverá definir:

- ordem de leitura;
- campos obrigatórios e condicionais;
- apresentação de busca seletiva;
- apresentação de fontes-chave;
- apresentação de resultados;
- comunicação de certainty ausente ou herdada;
- limitações;
- aplicabilidade;
- assurance/disclosures;
- comportamento quando `publishable=false`.

Somente após a especificação deverá ser criado o template executável.

---

**Documento vivo. Alterações incompatíveis no contrato deverão considerar evolução de `schema_version`.**
