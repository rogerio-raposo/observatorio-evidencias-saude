# 42 — Contrato de Dados da Ficha de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato de dados inicial  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 21, 28, 29, 38, 40 e 41  
**Baseline:** OES-P1

---

# 1. Finalidade

Traduzir a especificação científica da Ficha de Evidência em um contrato de dados implementável, preservando:

- fonte canônica;
- não duplicação;
- versionamento;
- provenance;
- lineage;
- estados separados;
- auditabilidade.

O contrato distingue quatro categorias:

- **S — armazenado:** dado canônico persistido;
- **D — derivado:** obtido de entidades canônicas;
- **R — renderizado:** produzido para apresentação a partir de S/D;
- **F — futuro:** requisito reconhecido, mas deliberadamente não implementado agora.

---

# 2. Princípio de minimização

Regra:

> **não criar campo no Product apenas porque o template precisa exibi-lo.**

Novo armazenamento somente será criado quando o conteúdo:

1. não puder ser derivado com segurança;
2. possuir significado próprio no nível do produto;
3. precisar de histórico/auditoria;
4. for necessário para o gate de publicação.

---

# 3. Matriz principal do contrato

| Elemento da Ficha | Classe | Fonte/estrutura |
|---|---|---|
| Product ID | S | core.entity + product.product |
| Product version | S | core.entity_version |
| tipo | S | product.product_version.product_type |
| título | S | product.product_version.title |
| público | S | product.product_version.intended_audience |
| estado editorial | S | product.product_version.status |
| estado de atualidade | S | nova product.currency_state |
| data de publicação | S | product.product_version.publication_date |
| data de corte | S | product.product_version.evidence_cutoff_date |
| conclusão | S | product.product_version.conclusion_text |
| limitações narrativas | S | novo limitations_summary |
| aplicabilidade narrativa | S | product.product_version.applicability_summary |
| Question ID | D | Investigation.primary_question |
| pergunta normalizada | D/R | investigation.question_version |
| N | D | investigation.investigation_version.depth_level |
| M | D | investigation.investigation_version.maintenance_level |
| objetivo | D/R | investigation.investigation_version.objective |
| método resumido | D/R | Investigation/Search/Screening/Risk/Synthesis |
| fontes/bases | D/R | investigation.search |
| última busca | D | investigation.search.executed_at |
| estudos incluídos | D | evidence.study + links/contributions |
| reports | D | evidence.report |
| Results prioritários | D/R | evidence.result_version |
| sínteses | D/R | synthesis.synthesis_version |
| risco de viés | D/R | appraisal.risk_assessment_version |
| certainty | D/R | appraisal.certainty_assessment_version |
| CERQual | D/R | ReviewFinding + Certainty |
| histórico científico | D/R | core.entity_version + dependency/provenance |
| classes da mudança | S | nova product.version_change_class |
| revisão humana | S | nova product.review_record |
| artefato final | S/R | artifact + rendered_artifact_uuid |
| Product→Product | F | reservado |
| ApplicabilityAssessment formal | F | reservado |

---

# 4. ProductVersion

O baseline existente permanece válido.

Campos existentes:

- version_uuid;
- entity_uuid;
- product_type;
- title;
- intended_audience;
- evidence_cutoff_date;
- publication_date;
- status;
- conclusion_text;
- applicability_summary;
- rendered_artifact_uuid.

## 4.1 Extensão mínima

Adicionar:

`limitations_summary text`

Justificativa:

- limitações são obrigatórias no contrato científico;
- possuem interpretação de nível de produto;
- não são plenamente deriváveis;
- precisam permanecer auditáveis entre versões.

## 4.2 Estado editorial

`ProductVersion.status` será formalizado como estado editorial.

Vocabulário:

- draft;
- under_review;
- published;
- superseded;
- archived.

Não armazenar estado de atualidade nesse campo.

---

# 5. Estado de atualidade como histórico

## 5.1 Decisão

Não adicionar simples coluna mutável `currency_status` a ProductVersion.

Motivo:

um produto publicado pode passar de:

`atual → em avaliação → atualização recomendada`

sem mudança imediata da conclusão científica.

Sobrescrever uma coluna destruiria o histórico operacional.

## 5.2 Nova estrutura

Criar:

`product.currency_state`

Campos:

- currency_state_uuid;
- product_version_uuid;
- currency_status;
- assessed_at;
- assessed_by;
- rationale;
- supersedes_currency_state_uuid;
- record_status.

Vocabulário físico:

- current;
- under_evaluation;
- update_recommended;
- outdated;
- archived.

`record_status`:

- active;
- superseded.

## 5.3 Invariantes

- no máximo um CurrencyState ativo por ProductVersion;
- supersessão somente dentro da mesma ProductVersion;
- estado anterior preservado;
- mudança de atualidade não cria automaticamente nova ProductVersion.

---

# 6. Classes de mudança

## 6.1 Nova estrutura

Criar:

`product.version_change_class`

Campos:

- product_version_uuid;
- change_class;
- rationale;
- sequence_no.

Chave:

`(product_version_uuid, change_class)`

## 6.2 Vocabulário

- editorial;
- new_evidence;
- scientific_correction;
- quantitative_change;
- certainty_change;
- applicability_change;
- conclusion_change.

Uma ProductVersion pode possuir múltiplas classes.

## 6.3 Relação com core.entity_version.change_type

`core.entity_version.change_type` continuará registrando a classe técnica principal da versão.

`product.version_change_class` registra a semântica científica/funcional específica do produto.

Não sobrecarregar `change_type` com lista múltipla.

---

# 7. Registro de revisão humana

## 7.1 Nova estrutura

Criar:

`product.review_record`

Campos:

- review_uuid;
- product_version_uuid;
- reviewer;
- role;
- independent_flag;
- decision;
- reviewed_at;
- notes;
- status.

Vocabulário mínimo de `decision`:

- approved;
- revise;
- rejected.

`status`:

- active;
- superseded.

## 7.2 Finalidade

Registrar evidência auditável de que:

- julgamento material foi revisado;
- certainty foi revisada quando aplicável;
- conclusão foi conferida;
- gate de publicação foi satisfeito.

## 7.3 Papel

`role` permanece inicialmente textual controlado por aplicação.

Papéis candidatos:

- scientific_reviewer;
- methodological_reviewer;
- certainty_reviewer;
- editor.

A taxonomia final de papéis poderá ser expandida posteriormente.

---

# 8. Investigation primária

## 8.1 Regra

Cada Ficha publicada deverá possuir exatamente um vínculo:

`product.investigation_link.role = 'primary'`

## 8.2 Investigações adicionais

Papéis permitidos inicialmente:

- source;
- supporting;
- update_source;
- predecessor;
- related.

## 8.3 Nível

Para uma Ficha canônica criada como N2:

- Investigation primária deve ser N2.

Quando a Ficha resumir investigação N3/N4 existente:

- uma Investigation N2 de manutenção pode ser primária;
- a N3/N4 será vinculada como `source`;
- Syntheses de origem permanecem vinculadas por versão.

Esta regra evita falsificar a profundidade metodológica da fonte.

---

# 9. Question

Question não será duplicada no Product.

Derivar da Investigation primária:

- primary_question_entity_uuid;
- QuestionVersion pertinente;
- normalized_text;
- question_type;
- structure_type;
- context_payload;
- time_horizon_payload.

O template poderá renderizar versões amigáveis sem criar nova fonte canônica.

---

# 10. N e M

Não criar colunas `depth_level` ou `maintenance_level` em ProductVersion.

Derivar da Investigation primária.

Motivo:

- evita divergência;
- N/M são propriedades do roteamento/investigação;
- Product apenas comunica essas propriedades.

---

# 11. Método resumido

Não armazenar `method_summary` canônico no ProductVersion nesta fase.

Renderizar a partir de:

- InvestigationVersion;
- Search;
- ScreeningDecision;
- RiskAssessment;
- SynthesisVersion;
- CertaintyAssessment.

Quando houver necessidade editorial de texto resumido, ele poderá existir no artefato renderizado.

O protocolo permanece artefato metodológico separado.

---

# 12. Corpo de evidências

Contagens serão derivadas.

## 12.1 Studies

Contar Study identities, não Reports.

## 12.2 Reports

Contagem separada.

## 12.3 Participantes

Derivar quando metodologicamente possível, evitando soma indevida em:

- estudos sobrepostos;
- múltiplos braços;
- múltiplos Reports do mesmo Study;
- dados reutilizados.

Quando uma contagem total não for válida, comunicar “não agregável” em vez de somar mecanicamente.

---

# 13. Resultados prioritários

Não criar tabela de resultados própria da Ficha.

A tabela/card de resultados é uma projeção de:

- ProductSynthesis;
- SynthesisVersion;
- SynthesisContribution;
- ResultVersion;
- Outcome;
- CertaintyAssessment.

A ordem de apresentação usa:

- ProductSynthesis.sequence_no;
- ProductCertainty.sequence_no;
- prioridade definida na Investigation/protocolo quando disponível.

---

# 14. Certeza/confiança

Não armazenar nível de certainty no ProductVersion.

Regra:

> **Product → CertaintyAssessmentVersion**

A ausência de ProductCertainty correspondente será renderizada como:

> não avaliada formalmente

quando isso for metodologicamente válido.

Se `evidence_state='no_evidence'`, a apresentação deverá usar estado próprio.

---

# 15. Risco de viés

Não duplicar no produto.

Derivar dos RiskAssessment vinculados à Investigation e às entidades que sustentam as Syntheses exibidas.

A apresentação resumida deverá distinguir:

- risco de viés dos Studies/Results;
- certainty do corpo.

---

# 16. Aplicabilidade

## 16.1 Estado atual

Usar:

`ProductVersion.applicability_summary`

para síntese descritiva.

## 16.2 Decisão

**Não implementar ApplicabilityAssessment nesta etapa.**

Motivo:

- metodologia ainda não consolidada;
- uma estrutura prematura cristalizaria categorias/thresholds não aprovados;
- applicability_summary atende o contrato inicial.

Quando o método for formalizado, a Ficha deverá vincular versão concreta de ApplicabilityAssessment.

---

# 17. ProductRelation

## 17.1 Decisão

**Não implementar ProductRelation ainda.**

A Ficha inicial consegue preservar lineage suficiente por:

- ProductInvestigation;
- ProductSynthesis;
- ProductCertainty;
- provenance/dependency;
- EntityVersion.

ProductRelation será reconsiderada quando a especificação de pelo menos um segundo produto demonstrar necessidade concreta, especialmente:

- Revisão → Ficha;
- Monitor → Ficha;
- Alerta → Ficha;
- derivação entre produtos.

Princípio:

> não antecipar cardinalidade e vocabulário sem casos de uso reais.

---

# 18. Referências

Não criar lista duplicada de referências no Product.

Derivar de:

- ResultSource;
- Reports que sustentam Syntheses;
- provenance;
- referências metodológicas do protocolo.

O template poderá selecionar “referências principais”, mas deverá preservar acesso à lista auditável completa.

---

# 19. Estado publicado e versão técnica

Não confundir:

- `core.entity_version.version_status`;
- `product.product_version.status`.

## 19.1 EntityVersion

Controla o estado técnico da versão:

- draft;
- current;
- superseded;
- archived;
- invalidated.

## 19.2 ProductVersion.status

Controla o estado editorial:

- draft;
- under_review;
- published;
- superseded;
- archived.

Uma ProductVersion publicada normalmente deverá estar associada à EntityVersion `current`.

Ao publicar sucessora:

- versão anterior de EntityVersion → superseded;
- ProductVersion anterior → superseded;
- nova versão → current/published.

---

# 20. Invariantes da Ficha publicada

Uma Ficha em `published` deverá satisfazer:

1. `product_type='evidence_sheet'`;
2. exatamente uma Investigation `primary`;
3. Investigation primária N2;
4. Question primária válida;
5. evidence_cutoff_date não nula;
6. evidence_cutoff_date coerente com Investigation;
7. publication_date não nula;
8. conclusion_text não vazio;
9. limitations_summary não vazio;
10. CurrencyState ativo existente;
11. ao menos um review_record ativo com `decision='approved'`;
12. nenhuma revisão ativa com `decision='rejected'`;
13. Syntheses citadas vinculadas;
14. Certainty formal citada vinculada;
15. nenhuma dependência crítica invalidada sem reavaliação;
16. ProductVersion associada à EntityVersion current;
17. provenance/lineage reconstruível.

Algumas verificações exigirão função de gate, não apenas constraints locais.

---

# 21. Gate físico proposto

Criar função:

`product.evidence_sheet_publication_issues(product_version_uuid)`

Retorno:

- issue_code;
- severity;
- message.

Criar função auxiliar:

`product.evidence_sheet_is_publishable(product_version_uuid)`

Retorna boolean.

## 21.1 Princípio

O gate deverá:

- avaliar;
- relatar problemas;
- não publicar automaticamente;
- não alterar estado silenciosamente.

A transição para `published` continuará sendo ação explícita.

---

# 22. Códigos iniciais de issue

- WRONG_PRODUCT_TYPE
- MISSING_PRIMARY_INVESTIGATION
- MULTIPLE_PRIMARY_INVESTIGATIONS
- PRIMARY_INVESTIGATION_NOT_N2
- MISSING_QUESTION
- CUTOFF_DATE_MISMATCH
- MISSING_PUBLICATION_DATE
- MISSING_CONCLUSION
- MISSING_LIMITATIONS
- MISSING_CURRENCY_STATE
- MISSING_APPROVED_REVIEW
- ACTIVE_REJECTION
- INVALIDATED_DEPENDENCY
- NOT_CURRENT_ENTITY_VERSION
- UNLINKED_SYNTHESIS
- UNLINKED_CERTAINTY

A lista poderá evoluir.

---

# 23. Migration mínima requerida

A especificação conclui que **uma migration é necessária antes do template**.

Migration candidata:

`006_product_evidence_sheet_contract.sql`

Deverá:

1. adicionar `limitations_summary`;
2. restringir ProductVersion.status ao vocabulário editorial aprovado;
3. criar `product.currency_state`;
4. criar índice de um CurrencyState ativo por ProductVersion;
5. criar `product.version_change_class`;
6. criar `product.review_record`;
7. criar índice/constraint para no máximo uma Investigation primary por ProductVersion;
8. criar função de publication issues;
9. criar função de publishability;
10. preservar todas as regressões F2-B/S4/S5.

---

# 24. Testes mínimos da migration

## F3-FE-T01

Migration aplica após 005.

## F3-FE-T02

ProductVersion aceita `limitations_summary`.

## F3-FE-T03

Status editorial inválido é rejeitado.

## F3-FE-T04

Dois CurrencyStates ativos para a mesma ProductVersion são rejeitados.

## F3-FE-T05

Histórico de CurrencyState por supersessão é preservado.

## F3-FE-T06

Múltiplas classes de mudança coexistem.

## F3-FE-T07

ReviewRecord aprovado é persistido.

## F3-FE-T08

Duas Investigations primary para a mesma ProductVersion são rejeitadas.

## F3-FE-T09

Ficha incompleta retorna issues.

## F3-FE-T10

Ficha completa retorna publishable=true.

## F3-FE-T11

Rejeição ativa bloqueia publicação.

## F3-FE-T12

Cutoff inconsistente é detectado.

## F3-FE-T13

Regressões F2-B passam.

## F3-FE-T14

Regressões S4 passam.

## F3-FE-T15

Regressões S5 passam.

## F3-FE-T16

Rebuild do zero passa com migration 006.

---

# 25. Campos deliberadamente não adicionados

Não adicionar agora:

- depth_level em Product;
- maintenance_level em Product;
- certainty_level em Product;
- risk_of_bias_summary estruturado duplicado;
- study_count persistido;
- participant_count persistido;
- method_summary canônico;
- ProductRelation;
- ApplicabilityAssessment;
- Recommendation;
- recommendation_strength.

Esses dados são derivados, prematuros ou pertencem a outras entidades.

---

# 26. Contrato de renderização

O template futuro receberá como entrada um objeto derivado contendo, no mínimo:

`EvidenceSheetView`

com:

- identity;
- version;
- editorial_state;
- currency_state;
- question;
- routing;
- method;
- evidence_base;
- priority_results;
- certainty;
- risk_of_bias_summary;
- safety;
- limitations;
- applicability;
- conclusion;
- update_history;
- references;
- audit_links.

Esse objeto é uma **view de aplicação/renderização**, não nova fonte canônica.

---

# 27. Decisões consolidadas

1. ProductVersion continua enxuto.
2. Limitations summary será armazenado.
3. Atualidade terá histórico próprio.
4. Classes de mudança terão relação N:M com ProductVersion.
5. Revisão humana terá registro próprio.
6. N/M serão derivados da Investigation.
7. Question será derivada da Investigation.
8. Results/Synthesis/Certainty não serão duplicados.
9. ApplicabilityAssessment formal será adiado.
10. ProductRelation será adiada até caso de uso concreto.
11. Uma Investigation primary por ProductVersion será invariant.
12. Publicação será validada por função de gate.
13. Migration 006 é necessária antes do template.
14. Nenhum novo campo científico será criado apenas por conveniência visual.

---

# 28. Próxima etapa

Implementar e testar:

> `database/006_product_evidence_sheet_contract.sql`

Somente após PASS da migration e do gate físico:

1. criar o contrato `EvidenceSheetView`;
2. criar template operacional;
3. validar com caso real.

---

**Documento vivo. Alterações materiais deverão ser registradas no CHANGELOG.md.**
