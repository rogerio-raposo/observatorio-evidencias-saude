# 116 — Revisão de Evidências N4: Revisão de Coerência e Decisão Arquitetural Inicial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status:** decisão arquitetural inicial  
**Dependências canônicas:** Documentos 20–21, 38, 40, 99, 114–115; migrations 001–014

---

# 1. Objetivo

Determinar se a arquitetura OES-P1 vigente consegue representar os requisitos científicos e de governança do N4 e identificar, antes de qualquer migration, quais extensões estruturais são realmente necessárias.

Pergunta arquitetural:

> **N4 exige um novo modelo científico ou apenas controles humanos adicionais sobre o modelo já existente?**

Resposta:

> **OES-P1 já cobre o núcleo científico. N4 exige principalmente uma extensão genérica para designação/qualificação de revisores e novas regras de contrato/gate/view.**

---

# 2. Decisão principal

> **Não criar novas tabelas para Study, Report, Result, Search, Screening, RiskAssessment, Synthesis, Certainty, Artifact, Provenance ou Assurance.**

> **Criar, como candidata única de DDL N4 v0.1, a estrutura genérica `investigation.reviewer_assignment`.**

As demais necessidades N4 deverão reutilizar estruturas existentes com vocabulários controlados, provenance e projections.

---

# 3. Reutilização do núcleo OES-P1

N4 reutiliza integralmente:

- `core.entity` / `core.entity_version`;
- `investigation.question` / `question_version`;
- `investigation.investigation` / `investigation_version`;
- `investigation.search`;
- `investigation.search_hit`;
- `investigation.screening_decision`;
- `investigation.method_decision`;
- `investigation.quality_control_record`;
- `evidence.study` / `study_version`;
- `evidence.report` / `report_version`;
- `evidence.study_report_link`;
- `evidence.outcome` / `outcome_version`;
- `evidence.result` / `result_version`;
- `evidence.result_source`;
- `appraisal.risk_assessment` / `risk_assessment_version` / domains;
- `synthesis.synthesis` / `synthesis_version` / contribution;
- `appraisal.certainty_assessment` / version / domains;
- `artifact.artifact` / `artifact.entity_link`;
- `product.product` / `product_version`;
- `product.assurance_record`;
- `provenance.record` / dependency graph.

---

# 4. Por que o núcleo científico é suficiente

O N4 não introduz uma nova unidade científica fundamental.

Ele aprofunda:

- cobertura de busca;
- duplicação/independência de decisões;
- reprodutibilidade;
- controles de qualidade;
- assurance.

Study, Report, Result, RiskAssessment, Synthesis e Certainty permanecem as mesmas unidades epistemológicas já utilizadas por N2/N3.

Portanto:

> **não duplicar entidades científicas apenas porque o nível metodológico mudou.**

---

# 5. Lacuna estrutural real

Hoje o OES consegue registrar:

- `reviewer` em ScreeningDecision;
- `extractor` em ResultSource;
- `assessor` em RiskAssessment;
- `reviewer` em CertaintyDomain;
- `actor`, `qualification_payload` e `independent_flag` em QualityControlRecord.

Mas não existe uma entidade canônica que declare previamente:

- quem está designado para qual etapa;
- papel formal;
- qualificação;
- independência requerida;
- escopo;
- conflitos de interesse;
- período de validade da designação.

Isso impede um gate N4 de provar, de forma limpa, que os atores registrados nas decisões eram revisores qualificados legitimamente designados.

---

# 6. Nova estrutura proposta — `investigation.reviewer_assignment`

Finalidade:

> **representar designação formal de atores humanos qualificados para etapas metodológicas da Investigation.**

Campos candidatos:

- `reviewer_assignment_uuid`;
- `investigation_version_uuid`;
- `stage`;
- `actor`;
- `actor_type`;
- `role`;
- `qualification_payload`;
- `independent_flag`;
- `scope_payload`;
- `conflict_payload`;
- `assigned_at`;
- `ended_at`;
- `record_status`;
- `supersedes_reviewer_assignment_uuid`.

---

# 7. Stages candidatos

Reutilizar o vocabulário operacional já consolidado:

- search;
- screening;
- extraction;
- appraisal;
- synthesis;
- certainty;
- reporting;
- cross_cutting.

---

# 8. Roles candidatos

Vocabulário inicial:

- `review_lead`;
- `search_peer_reviewer`;
- `primary_reviewer`;
- `secondary_reviewer`;
- `data_extractor`;
- `data_verifier`;
- `appraisal_reviewer`;
- `certainty_reviewer`;
- `statistical_reviewer`;
- `adjudicator`;
- `reporting_reviewer`;
- `expert_independent_reviewer`;
- `other`.

O papel não implica qualificação por si só; `qualification_payload` é obrigatório para atores humanos.

---

# 9. Qualificação

`qualification_payload` deverá permitir registrar, conforme a função:

- área de formação/competência;
- experiência metodológica;
- instrumento/framework dominado;
- experiência em busca;
- expertise estatística;
- treinamento/calibração;
- evidência documental ou referência interna;
- validade temporal quando pertinente.

O gate não deverá inferir qualificação a partir do nome ou cargo.

---

# 10. Independência

`independent_flag=true` significa que o papel exige execução/julgamento independente conforme protocolo.

Não significa independência absoluta entre pessoas ou instituições.

Quando necessário, `scope_payload`/`conflict_payload` deverá esclarecer:

- independent initial judgement;
- blinded-to-peer-decision;
- adjudication after disagreement;
- organizational conflict;
- financial/intellectual conflict.

---

# 11. Relação com QualityControlRecord

`reviewer_assignment` registra:

> **quem estava autorizado/designado.**

`quality_control_record` registra:

> **qual controle foi efetivamente executado.**

Essas funções não devem ser fundidas.

Exemplo:

- Reviewer B possui assignment `secondary_reviewer`, screening;
- QCR registra `screening_secondary_verification`, passed;
- ScreeningDecision demonstra decisões específicas;
- gate cruza os três elementos.

---

# 12. Search peer review

Nenhuma nova tabela é necessária.

Representação:

- assignment: `stage=search`, `role=search_peer_reviewer`;
- QCR: `control_type=search_strategy_peer_review`;
- `evidence_artifact_uuid`: PRESS checklist ou artefato equivalente;
- `scope_payload`: Search IDs/strategy versions revisadas;
- `decision`: passed/revise/failed.

---

# 13. Screening duplicado

Nenhuma nova tabela é necessária.

`investigation.screening_decision` já suporta múltiplas decisões para o mesmo target/stage.

N4 deverá exigir, conforme protocolo:

- dois reviewers distintos;
- assignments válidos;
- decisões temporalmente independentes;
- consenso/adjudicação quando houver discordância.

`adjudication_flag` e QCR/discrepancy payload serão utilizados para resolução.

---

# 14. Discordância e adjudicação

Não criar `disagreement` table em v0.1.

Usar:

- ScreeningDecision para decisões individuais/finais;
- QCR `agreement_payload`;
- QCR `discrepancy_payload`;
- QCR `resolution_payload`;
- reviewer assignment do adjudicator quando necessário.

Reavaliar tabela genérica de disagreement somente se casos reais demonstrarem perda de rastreabilidade.

---

# 15. Extração independente/duplicada

`evidence.result_source` preserva a fonte final e o extractor, mas sua chave não comporta duas extrações independentes idênticas da mesma localização.

Decisão N4 v0.1:

> **preservar extrações independentes como `provenance.record` antes da reconciliação final.**

Process types candidatos:

- `n4_independent_extraction`;
- `n4_extraction_verification`;
- `n4_extraction_consensus`.

O ResultVersion permanece o valor reconciliado/canônico.

---

# 16. Gate de extração

Para campos/outcomes críticos, o gate deverá ser capaz de confirmar:

- pelo menos duas extrações independentes ou modo permitido pelo protocolo;
- atores distintos e qualificados;
- provenance de source location;
- discrepância/resolução quando valores divergem;
- valor final rastreável.

---

# 17. Risk of Bias duplicado

Não criar nova tabela.

Utilizar RiskAssessment como julgamento canônico final.

Julgamentos independentes preliminares poderão ser preservados por:

- provenance records por domain;
- artifacts de instrumento preenchido;
- QCR `risk_of_bias_verification`;
- assignments de dois appraisal reviewers;
- discrepancy/resolution payload.

Somente se essa representação se mostrar insuficiente em caso real deverá ser considerada entidade específica de candidate assessment.

---

# 18. Certainty duplicada

Mesma decisão do appraisal.

CertaintyAssessment permanece julgamento final.

Preservar julgamentos independentes e reconciliação via:

- provenance por domain;
- artifacts;
- QCR `certainty_verification`;
- reviewer assignments;
- discrepancy/resolution payload.

---

# 19. Missing evidence / ROB-ME

Nenhuma nova entidade é necessária.

`appraisal.risk_assessment` já possui `target_entity_uuid` genérico.

Portanto, ROB-ME poderá ser representado como:

- framework = ROB-ME;
- target = Synthesis entity/version correspondente;
- outcome quando aplicável;
- instrument payload/domains;
- dois reviewer assignments + controle de verificação.

Esta reutilização deve ser formalizada no contrato de dados.

---

# 20. Protocolo

Nenhuma nova tabela.

O protocolo continua em:

`investigation.investigation_version.protocol_artifact_uuid`.

Artefatos complementares podem ser vinculados por `artifact.entity_link`.

---

# 21. Registro público do protocolo

Nenhuma nova tabela em v0.1.

Representar por artifact/provenance:

- role `protocol_registration`;
- source URI;
- registry;
- identifier;
- registration date;
- status;
- reason when not applicable/unavailable.

Se consultas futuras exigirem registro estruturado em grande escala, reavaliar tabela dedicada.

---

# 22. Emendas/desvios

`investigation.method_decision` é suficiente.

Usar:

- `decision_type=method_change` para emendas;
- `decision_type=protocol_deviation` para desvios;
- linked artifact quando houver documento de emenda;
- impact/risk/mitigation payloads;
- append-preserving supersession.

Nenhuma migration estrutural adicional necessária.

---

# 23. Infrastructure Readiness Gate

Não criar tabela dedicada.

Representar a decisão no `method_decision`:

- `decision_type=other`;
- `stage=cross_cutting`;
- `decision_code=N4_INFRASTRUCTURE_READINESS`;
- `impact_payload.state = ready | ready_with_documented_conditions | not_ready`;
- `risk_payload` por domínio;
- `mitigation_payload` para condições;
- artifact opcional com checklist.

O publication gate exigirá state compatível com execução formal.

---

# 24. Domínios do Readiness Gate

Payload deverá cobrir:

- bibliographic coverage;
- reviewer availability;
- search expertise;
- appraisal expertise;
- certainty expertise;
- statistical expertise;
- software/compute;
- artifact/versioning capacity;
- A3 pathway;
- conflicts/governance.

---

# 25. PRISMA flow

Nenhuma tabela persistida específica.

O flow deverá ser derivado de:

- Searches;
- SearchHits;
- dedup clusters;
- ScreeningDecisions;
- Study/Report linkage;
- status ongoing/awaiting/not retrieved;
- update searches.

Um snapshot renderizado poderá ser persistido como artifact.

Regra:

> **contagens PRISMA derivam do banco; não são fonte primária do banco.**

---

# 26. Reprodutibilidade

`artifact.artifact` + `artifact.entity_link` são suficientes.

Roles candidatos:

- protocol;
- protocol_registration;
- protocol_amendment;
- search_export;
- search_peer_review;
- screening_export;
- extraction_form;
- extraction_codebook;
- risk_of_bias_form;
- analysis_dataset;
- analysis_code;
- statistical_output;
- prisma_flow;
- prisma_checklist;
- sof;
- evidence_profile;
- reproducibility_bundle.

---

# 27. Product type e subtype

Não criar coluna nova.

Proposta:

- `product_type = evidence_review`;
- `depth_level = N4`;
- subtype principal em `investigation_type` e/ou provenance controlada.

Subtypes candidatos:

- `systematic_review_intervention`;
- `systematic_review_diagnostic`;
- `systematic_review_prognosis`;
- `systematic_review_prediction`;
- `systematic_review_prevalence`;
- `qualitative_evidence_synthesis`;
- `mixed_methods_review`;
- `network_meta_analysis_review`;
- `living_systematic_review`;
- `other_n4`.

Não criar tabela subtype na primeira versão.

---

# 28. EvidenceReviewView

Nome proposto:

> **EvidenceReviewView**

Schema version candidata:

> `oes.evidence_review_view/0.1`

Seções propostas:

- identity;
- question;
- investigation;
- subtype;
- infrastructure_readiness;
- protocol;
- registration;
- amendments_and_deviations;
- reviewer_assignments;
- methods;
- searches;
- search_peer_review;
- selection_flow;
- included_studies;
- excluded_full_text;
- extraction_controls;
- study_characteristics;
- risk_of_bias;
- results;
- syntheses;
- heterogeneity;
- sensitivity_analyses;
- missing_evidence;
- certainty;
- summary_of_findings;
- applicability;
- limitations;
- reproducibility;
- references;
- audit.

---

# 29. Publication gate N4

O gate deverá reutilizar `product.assurance_level()` e acrescentar controles N4.

Classes de erro candidatas:

- MISSING_PROTOCOL;
- INFRASTRUCTURE_NOT_READY;
- INSUFFICIENT_BIBLIOGRAPHIC_COVERAGE;
- MISSING_SEARCH_PEER_REVIEW;
- MISSING_DUPLICATE_TITLE_ABSTRACT_SCREENING;
- MISSING_DUPLICATE_FULL_TEXT_SCREENING;
- UNRESOLVED_SCREENING_DISAGREEMENT;
- MISSING_CRITICAL_DATA_DUPLICATE_EXTRACTION;
- MISSING_DUPLICATE_RISK_OF_BIAS_ASSESSMENT;
- MISSING_SYNTHESIS;
- MISSING_STATISTICAL_REVIEW quando aplicável;
- MISSING_MISSING_EVIDENCE_ASSESSMENT quando aplicável;
- MISSING_DUPLICATE_CERTAINTY_ASSESSMENT;
- MISSING_SUMMARY_OF_FINDINGS quando aplicável;
- OPEN_PROTOCOL_DEVIATION;
- MISSING_REPRODUCIBILITY_ARTIFACT;
- MISSING_AI_METHODOLOGICAL_VERIFICATION;
- MISSING_OWNER_APPROVAL;
- MISSING_EXPERT_INDEPENDENT_REVIEW;
- ASSURANCE_BELOW_A3;
- MISSING_PUBLICATION_DATE;
- INVALIDATED_DEPENDENCY.

---

# 30. Warnings candidatos

- protocol registration not public;
- grey literature limited with justification;
- no meta-analysis performed;
- search update may be due;
- no local/Brazil evidence;
- high risk of bias predominates;
- high heterogeneity;
- small-study effects uncertain;
- conflicts of interest reported;
- subtype-specific reporting extension unavailable.

Warnings nunca deverão substituir errors materiais.

---

# 31. Regras especiais por subtipo

O gate geral N4 não deve impor métodos indevidos a todos os subtipos.

Exemplos:

- meta-analysis não obrigatória;
- ROB-ME somente quando aplicável;
- statistical reviewer apenas quando análise complexa;
- SoF/Evidence Profile conforme framework;
- trial registries especialmente relevantes a intervenção;
- CINeMA somente em NMA;
- CERQual em qualitative evidence synthesis.

Essas regras serão parametrizadas pelo contrato/subtype, não por exceções ad hoc.

---

# 32. IA e reviewer assignment

ReviewerAssignment formal será restrito a atores humanos para papéis de controle N4.

IA continuará registrada em QCR/provenance como `ai_system`.

Regra:

> **IA não recebe reviewer assignment destinado a satisfazer requisito humano qualificado.**

---

# 33. Owner

Owner approval continua em AssuranceRecord.

Não criar reviewer assignment automaticamente para o proprietário.

Se, no futuro, o owner também possuir qualificação formal para uma etapa:

- deverá receber assignment explícito;
- qualificação deverá ser registrada;
- independência deverá ser avaliada;
- owner approval continuará sendo função distinta.

---

# 34. Expert independent review

A3 continuará derivada de `product.assurance_record`.

ReviewerAssignment poderá registrar o papel metodológico planejado/real do expert, mas:

> **o registro que eleva assurance permanece AssuranceRecord.**

Não duplicar lógica A3 em nova tabela.

---

# 35. Living N4

N4 + M3 não exige nova tabela de produto.

Reutilizar:

- Search versioning;
- ProductVersion;
- CurrencyState;
- MethodDecision;
- dependency graph;
- artifacts;
- maintenance metadata existentes/futuros.

Requisitos específicos de living review serão tratados no contrato N4 ou módulo de manutenção, sem criar nível de profundidade novo.

---

# 36. Impacto da configuração humana atual

A nova tabela ReviewerAssignment permitirá representar corretamente a ausência de equipe.

No estado atual, um Caso Real N4 formal deverá falhar readiness por:

- ausência de dois revisores humanos qualificados;
- ausência de search peer reviewer qualificado;
- ausência de expert independent reviewer configurado;
- infraestrutura bibliográfica ainda não garantida.

Esse FAIL é comportamento esperado e desejável.

---

# 37. O que não deve ser implementado

Não criar agora:

- nova Study table N4;
- nova Report table N4;
- nova Result table N4;
- nova Screening table N4;
- nova Extraction table N4;
- nova RoB table N4;
- nova Certainty table N4;
- PRISMA flow table;
- ProtocolRegistration table;
- InfrastructureReadiness table;
- Disagreement table;
- StatisticalReview table;
- ROB-ME table.

Essas necessidades já possuem representação suficiente ou poderão ser testadas primeiro via contrato/provenance.

---

# 38. Migration candidata

Próxima migration candidata:

> **015 — Evidence Review N4 contract**

DDL previsto:

> **uma nova tabela `investigation.reviewer_assignment`**

Mais:

- functions;
- gate;
- EvidenceReviewView;
- constraints/indexes;
- possivelmente CHECKs/vocabulários do novo objeto.

Não alterar tabelas científicas existentes sem evidência concreta de necessidade.

---

# 39. Critérios de aceitação arquitetural

A arquitetura N4 será considerada coerente se conseguir demonstrar:

1. review subtype sem nova entidade redundante;
2. readiness persistível/auditável;
3. reviewer roles qualificados;
4. independência verificável;
5. dois screeners distinguíveis;
6. duplicate extraction rastreável;
7. duplicate appraisal rastreável;
8. duplicate certainty rastreável;
9. adjudication preservável;
10. search peer review rastreável;
11. ROB-ME representável;
12. PRISMA flow derivável;
13. artifacts reprodutíveis vinculáveis;
14. A3 reutilizada sem duplicação;
15. gate capaz de bloquear ausência de qualquer requisito material.

---

# 40. Decisão

> **OES-P1 é arquiteturalmente adequado ao N4 com uma única extensão estrutural candidata: `investigation.reviewer_assignment`.**

> **Todo o restante deverá ser implementado primeiro por contratos, vocabulários controlados, provenance, QualityControlRecord, MethodDecision, artifacts e projections.**

Esta é uma decisão inicial e deverá ser testada contra fixture N4 antes de promover qualquer estrutura adicional.

---

# 41. Próxima etapa

> **Criar o Documento 117 — Contrato de Dados da Revisão de Evidências N4.**

O contrato deverá formalizar:

- `product_type=evidence_review`;
- subtype;
- ReviewerAssignment;
- process types de duplicate extraction/appraisal/certainty;
- readiness payload;
- search source classes;
- controls obrigatórios;
- EvidenceReviewView;
- publication issues/errors/warnings;
- fixture sintética;
- critérios de PASS;
- limites do modo experimental atual.

Somente após o Documento 117 deverá ser criada a migration 015.

---

**Resultado:** decisão arquitetural inicial N4 consolidada; uma única nova tabela candidata; nenhuma migration criada nesta etapa.