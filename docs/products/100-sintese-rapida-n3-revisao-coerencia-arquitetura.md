# 100 — Síntese Rápida N3: Revisão de Coerência e Decisão Arquitetural Inicial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — decisão arquitetural inicial consolidada  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 20–21, 28–30, 38, 40, 99; migrations 001–013  
**Baseline:** OES-P1  
**Produto:** OES — Síntese Rápida de Evidências  
**Nível:** N3

---

# 1. Objetivo

Avaliar se a especificação científica/funcional do Documento 99 exige novas estruturas no OES-P1 e distinguir:

- estruturas científicas já disponíveis;
- lacunas de controle metodológico;
- dados específicos de apresentação;
- requisitos de gate.

---

# 2. Decisão executiva

> **O núcleo científico de N3 já é representável no OES-P1.**

N3 não exige novas entidades científicas para:

- Question;
- Investigation;
- Search/SearchHit;
- ScreeningDecision;
- Study/Report;
- Result/ResultSource;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- Product/ProductVersion;
- assurance;
- provenance;
- artifacts.

Entretanto:

> **OES-P1 não representa de forma suficientemente estruturada duas classes transversais de controle exigidas por N3/N4: decisões de abreviação/desvio metodológico e verificações qualificadas por etapa.**

Portanto, a evolução recomendada é pequena e transversal, não uma arquitetura N3 paralela.

---

# 3. Mapeamento do contrato N3 para OES-P1

| Requisito N3 | Estrutura existente | Estado |
|---|---|---|
| pergunta Q2 | QuestionVersion | suficiente |
| Investigation N3 | InvestigationVersion | suficiente |
| protocolo | InvestigationVersion.protocol_artifact_uuid | suficiente |
| busca | Search/SearchHit | suficiente |
| seleção | ScreeningDecision | suficiente para decisões |
| estudos/reports | Study/Report | suficiente |
| extração | Result/ResultSource | suficiente para conteúdo |
| risk of bias | RiskAssessment/Domain | suficiente para appraisal |
| síntese | Synthesis/Contribution | suficiente |
| certainty | CertaintyAssessment/Domain | suficiente |
| código/dataset | Artifact + SynthesisVersion links | suficiente |
| produto | Product/ProductVersion | suficiente |
| assurance A0–A3 | product.assurance_record | suficiente |
| lineage | provenance/dependency_edge | suficiente |
| abreviações planejadas | sem estrutura controlada própria | **lacuna** |
| desvios do protocolo | sem estrutura controlada própria | **lacuna** |
| verificação qualificada por etapa | representação parcial/inconsistente | **lacuna** |

---

# 4. Protocolo

`InvestigationVersion.protocol_artifact_uuid` já oferece vínculo canônico para protocolo.

Decisão:

> **não criar entidade Protocol nesta etapa.**

O artifact deverá conter o protocolo completo e poderá ser versionado por novo artifact + nova InvestigationVersion ou política operacional futura.

O gate N3 deverá exigir `protocol_artifact_uuid`.

---

# 5. Search

Search já registra:

- source_name;
- platform;
- exact_strategy;
- filters;
- executed_at;
- result_count;
- strategy_version;
- operator;
- status.

Isso é suficiente para N3.

Não criar `RapidSearch`.

A eventual peer review da estratégia de busca pertence ao controle metodológico e não à entidade Search em si.

---

# 6. ScreeningDecision

A estrutura atual contém:

- investigation_version_uuid;
- target_entity_uuid;
- stage;
- reviewer;
- decision;
- exclusion_reason;
- parent_decision_uuid;
- adjudication_flag.

Ela permite registrar decisões individuais e adjudicação.

Entretanto, não representa sozinha de forma robusta:

- qualificação do verificador;
- escopo da amostra calibrada;
- métrica/conclusão da calibração;
- autorização documentada para seguir com single screening.

Decisão:

> manter ScreeningDecision para decisões registro-a-registro e adicionar controle transversal por etapa.

---

# 7. Extração

`evidence.result_source` registra:

- fonte;
- localização;
- valor original;
- extraction_method;
- extractor;
- extracted_at.

É suficiente para provenance do dado extraído.

Não contém verificador qualificado do dado crítico.

Decisão:

> não duplicar ResultSource; registrar a verificação crítica em controle metodológico transversal associado à Investigation e ao escopo verificado.

---

# 8. RiskAssessment

`appraisal.risk_assessment_version` já registra:

- framework;
- target;
- outcome;
- overall_judgement;
- assessor;
- verification_status;
- instrument_payload.

A presença de `verification_status` é útil, mas insuficiente para N3 formal porque não identifica de modo estruturado:

- quem verificou;
- sua qualificação;
- independência;
- data;
- escopo;
- decisão;
- evidência documental da verificação.

Decisão:

> preservar `verification_status` como resumo operacional e usar registro transversal de controle como fonte auditável da verificação qualificada.

---

# 9. Synthesis

SynthesisVersion + Contribution já representam:

- unidade analítica;
- synthesis_type;
- origin;
- method/model;
- software;
- code artifact;
- analysis dataset;
- result summary;
- Results contribuintes.

Isso é suficiente para síntese narrativa estruturada e meta-análise.

Não criar `RapidSynthesis` como entidade científica separada.

A natureza rápida pertence à Investigation/Product/método, não à entidade Synthesis.

---

# 10. CertaintyAssessment

CertaintyAssessment/Domain já representam:

- framework;
- unidade ligada a Synthesis/Outcome;
- níveis;
- evidence state;
- domínios;
- rationale;
- reviewer.

A lacuna é semelhante ao appraisal:

> falta registro estruturado da verificação qualificada independente dos julgamentos materiais.

Não criar `RapidCertainty`.

---

# 11. Assurance

`product.assurance_record` já deriva A0–A3.

Isso continua válido para N3.

Entretanto:

> **A3 não prova, por si só, que os controles de etapa N3 foram cumpridos.**

O publication gate deverá verificar simultaneamente:

- assurance A3;
- registros de controle metodológico exigidos.

---

# 12. Lacuna 1 — decisões metodológicas rápidas

N3 precisa registrar de forma estruturada:

- abreviação planejada;
- etapa afetada;
- justificativa;
- risco metodológico adicional;
- mitigação;
- se prevista no protocolo;
- impacto esperado;
- eventual desvio posterior;
- impacto do desvio;
- decisão de aceitar/corrigir/rerrotear.

Provenance não é a estrutura ideal porque isso é **governança de processo**, não proveniência científica de um campo do produto.

Artifact sozinho também é insuficiente para gate estruturado.

---

# 13. Estrutura candidata A — `investigation.method_decision`

Tabela transversal candidata:

`investigation.method_decision`

Finalidade:

> registrar decisões metodológicas materiais associadas a uma Investigation sem criar uma entidade científica nova.

Campos conceituais:

- method_decision_uuid;
- investigation_version_uuid;
- decision_type;
- stage;
- decision_code;
- planned_flag;
- rationale;
- risk_payload;
- mitigation_payload;
- impact_payload;
- decided_by;
- decided_at;
- linked_artifact_uuid;
- status;
- supersedes_method_decision_uuid.

`decision_type` candidato:

- `rapid_restriction`;
- `protocol_deviation`;
- `method_change`;
- `rerouting_trigger`;
- `other`.

Etapas candidatas:

- question;
- search;
- screening;
- extraction;
- appraisal;
- synthesis;
- certainty;
- reporting.

---

# 14. Regra de versionamento de method_decision

Decisões metodológicas materiais deverão ser append-preserving.

Regra:

> correção não sobrescreve decisão histórica; registro anterior é superseded e novo registro é criado.

Isso mantém coerência com a política de provenance/versionamento do OES.

---

# 15. Lacuna 2 — verificação qualificada por etapa

N3/N4 precisam distinguir:

- quem executou a análise inicial;
- quem verificou;
- qualificação do verificador;
- independência;
- escopo;
- método de verificação;
- resultado;
- discordâncias;
- resolução.

Essa função não é equivalente a:

- AI methodological verification de produto;
- owner approval;
- expert final review.

É controle de qualidade durante a Investigation.

---

# 16. Estrutura candidata B — `investigation.quality_control_record`

Tabela transversal candidata:

`investigation.quality_control_record`

Finalidade:

> registrar controles de qualidade/verificações de etapas metodológicas dentro da Investigation.

Campos conceituais:

- quality_control_uuid;
- investigation_version_uuid;
- stage;
- control_type;
- actor;
- actor_type;
- qualification_payload;
- independent_flag;
- decision;
- scope_payload;
- agreement_payload;
- discrepancy_payload;
- resolution_payload;
- performed_at;
- evidence_artifact_uuid;
- notes;
- status;
- supersedes_quality_control_uuid.

`control_type` candidato:

- `search_strategy_peer_review`;
- `screening_pilot`;
- `screening_secondary_verification`;
- `critical_data_verification`;
- `risk_of_bias_verification`;
- `synthesis_statistical_review`;
- `certainty_verification`;
- `other`.

---

# 17. Actor e qualificação

Para permitir desenvolvimento e produção sem confundir papéis:

`actor_type` poderá distinguir:

- `ai_system`;
- `human_reviewer`;
- `human_expert`.

Para satisfazer requisito formal de N3:

- actor deve ser humano;
- qualification_payload deve estar preenchido;
- competência deve ser compatível com a etapa;
- independent_flag deve refletir independência real do julgamento inicial.

Registros de IA poderão existir para transparência, mas:

> **não satisfazem o requirement de qualified secondary verification.**

---

# 18. Screening detalhado versus quality control

ScreeningDecision continua sendo a fonte de decisão registro-a-registro.

`quality_control_record` registra o controle do processo:

- amostra dupla;
- concordância;
- discrepâncias;
- resultado da calibração;
- autorização para single screening restante.

Não duplicar todos os screening decisions dentro do quality control.

---

# 19. Critical-data verification

Result/ResultSource permanecem a fonte dos dados.

`quality_control_record` de tipo `critical_data_verification` deverá registrar:

- Results/Reports ou escopo verificado;
- campos críticos;
- tamanho da amostra ou total verificado;
- divergências;
- resolução;
- verificador.

Quando necessário, evidence_artifact poderá conter checklist detalhado.

---

# 20. Risk-of-bias verification

RiskAssessmentVersion permanece o julgamento científico.

Quality control deverá registrar:

- RiskAssessments cobertos;
- verificador;
- framework;
- discordâncias;
- resolução;
- decisão final sobre completude da verificação.

`verification_status` da RiskAssessment poderá ser derivado/atualizado coerentemente, mas não substituir o registro auditável.

---

# 21. Certainty verification

CertaintyAssessment permanece a fonte dos julgamentos de certeza.

Quality control deverá registrar verificação de:

- domínios materiais;
- rationale;
- final_level;
- unidade científica correta;
- discordâncias/resolução.

---

# 22. Statistical review

Meta-análises complexas ou decisões estatísticas materiais poderão exigir:

`control_type = synthesis_statistical_review`

Esse controle será obrigatório quando o protocolo/gate assim classificar a síntese.

Não é requisito universal para toda síntese narrativa N3.

---

# 23. Product type

Product type candidato:

`rapid_evidence_synthesis`

Não criar tabela `rapid_evidence_synthesis`.

A especialização ocorrerá por:

- ProductVersion.product_type;
- Investigation N3;
- links a Synthesis/Certainty;
- method_decision;
- quality_control_record;
- publication gate;
- futura RapidEvidenceSynthesisView.

---

# 24. Protocol deviations

`method_decision` com `decision_type=protocol_deviation` deverá distinguir:

- desvio inevitável;
- correção de erro;
- mudança motivada por evidência emergente;
- limitação de recurso;
- decisão de rerroteamento.

Todo desvio material deverá conter impacto e mitigação.

Gate deverá bloquear desvio material ativo sem avaliação/justificativa adequada.

---

# 25. Rapid restrictions

`method_decision` com `decision_type=rapid_restriction` deverá registrar cada simplificação material.

Exemplos:

- limitar bases;
- limitar data;
- limitar idioma;
- limitar grey literature;
- triagem simples após calibração;
- extração limitada;
- RoB focado em outcomes críticos;
- GRADE limitado a outcomes críticos;
- omissão justificada de análises secundárias.

Esses registros alimentam diretamente a seção de limitações do método rápido.

---

# 26. Publication gate N3 — implicação arquitetural

O gate N3 deverá verificar duas camadas.

## 26.1 Ciência/produto

- ProductVersion válida;
- primary Investigation N3;
- protocolo;
- Search;
- seleção;
- Reports/Studies;
- appraisal;
- Synthesis;
- Certainty quando aplicável;
- limitações;
- cutoff;
- currency;
- lineage.

## 26.2 Governança/controle

- rapid restrictions registradas;
- protocol deviations resolvidos/documentados;
- screening qualified verification;
- critical-data qualified verification;
- RoB qualified verification;
- certainty qualified verification quando aplicável;
- statistical review quando requerido;
- assurance A3;
- publication_date.

---

# 27. Gate em modo experimental atual

Na configuração atual do OES, uma fixture/caso experimental N3 deverá conseguir:

- materializar todos os componentes científicos;
- registrar controles executados por IA como transparência;
- derivar no máximo A0/A1/A2 conforme assurance existente;
- demonstrar blockers de qualified human controls;
- demonstrar blocker de A3;
- permanecer `draft` ou `under_review`;
- permanecer `publishable=false`.

Isso será considerado:

> **PASS da arquitetura experimental.**

---

# 28. A3 e quality control

Expert independent review (`assurance_record`) e quality controls possuem escopos distintos.

A mesma pessoa qualificada poderá, em princípio, atuar como:

- segundo verificador metodológico em etapas; e
- expert independent reviewer final;

somente quando:

- não for autora dos julgamentos iniciais;
- independência for real;
- qualificação for adequada;
- papéis estiverem documentados;
- não houver conflito incompatível.

O gate não deverá inferir automaticamente que um A3 final cobre controles ausentes.

---

# 29. Artifact layer

Artifacts existentes são suficientes para:

- protocolo;
- estratégia peer-reviewed;
- formulário/checklist de verificação;
- dataset de análise;
- código;
- PRISMA/flow diagram;
- Summary of Findings;
- relatório de desvios.

`artifact.entity_link` poderá vincular artifacts à InvestigationVersion.

Não criar armazenamento binário em tabelas N3.

---

# 30. View futura

N3 deverá possuir projeção própria:

> **RapidEvidenceSynthesisView**

Ela deverá projetar, no mínimo:

- identity;
- question;
- decision_context;
- protocol;
- rapid_method_restrictions[];
- searches[];
- selection_flow;
- included_evidence;
- risk_of_bias;
- results;
- syntheses[];
- certainty[];
- summary_of_findings;
- protocol_deviations[];
- rapid_method_limitations;
- applicability;
- conclusion;
- references;
- quality_controls[];
- audit.

Não reutilizar EvidenceSheetView/EvidenceResponseView/EvidenceScanView.

---

# 31. Relação com N4

`method_decision` e `quality_control_record` são transversais e deverão poder ser reutilizados em N4.

Isso evita:

- criar tabelas específicas `rapid_*` para cada etapa;
- duplicar controles humanos;
- cristalizar shortcuts dentro de entidades científicas.

N4 poderá exigir conjuntos mais estritos de quality controls e menos/nenhuma rapid restriction.

---

# 32. Riscos da decisão

## 32.1 Estruturas genéricas demais

Risco:

`method_decision` ou `quality_control_record` virarem payload arbitrário.

Mitigação:

- enums controlados;
- campos obrigatórios por tipo;
- constraints;
- schemas de payload documentados;
- testes de contrato.

## 32.2 Qualificação apenas textual

Risco:

qualification_payload ser preenchido nominalmente sem competência real.

Mitigação:

- política explícita de qualificação;
- owner não pode satisfazer por default;
- audit disclosure;
- futuramente registro de reviewer identity/credential mais robusto.

## 32.3 A3 usado como atalho

Risco:

expert approval final mascarar etapas sem verificação.

Mitigação:

- gate verifica quality controls independentemente do assurance level.

---

# 33. Decisões consolidadas

1. OES-P1 já cobre o núcleo científico N3.
2. Protocol continua como artifact ligado à InvestigationVersion.
3. Search/SearchHit são reutilizados.
4. ScreeningDecision continua sendo decisão registro-a-registro.
5. Result/ResultSource continuam sendo fonte de extração/provenance.
6. RiskAssessment é reutilizado.
7. Synthesis é reutilizada; não existe RapidSynthesis científica separada.
8. CertaintyAssessment é reutilizada.
9. Product type candidato = `rapid_evidence_synthesis`.
10. criar estrutura transversal para decisões metodológicas materiais.
11. criar estrutura transversal para quality controls/verificações por etapa.
12. quality control é distinto de product assurance.
13. A3 é necessário para publicação N3 formal, mas não cobre automaticamente controles ausentes.
14. modo experimental deve permanecer não publicável sem qualified human controls.
15. futuras estruturas devem ser reutilizáveis por N4.

---

# 34. Próxima etapa

Formalizar:

> **Contrato de Dados da Síntese Rápida — N3**

O contrato deverá definir:

- schema de `investigation.method_decision`;
- schema de `investigation.quality_control_record`;
- enums/payloads;
- invariantes N3;
- product_type;
- publication issues;
- regra de A3;
- controles obrigatórios por etapa;
- comportamento experimental;
- estrutura da RapidEvidenceSynthesisView;
- testes mínimos;
- compatibilidade com rebuild e regressões N0–N2.

Somente depois deverá ser criada migration candidata.

---

**Decisão arquitetural inicial:** expandir OES-P1 apenas com controles metodológicos transversais; reutilizar integralmente o núcleo científico existente.