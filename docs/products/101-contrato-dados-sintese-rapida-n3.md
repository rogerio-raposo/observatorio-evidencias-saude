# 101 — Contrato de Dados da Síntese Rápida de Evidências — N3

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato inicial consolidado  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 20–21, 28–30, 38, 40, 99–100  
**Baseline:** OES-P1 + migrations 002–013  
**Produto:** OES — Síntese Rápida de Evidências  
**Nível:** N3

---

# 1. Finalidade

Definir a representação persistente e derivada necessária para implementar N3 sem duplicar o núcleo científico do OES.

O contrato introduz apenas duas estruturas transversais:

- `investigation.method_decision`;
- `investigation.quality_control_record`.

E especializa o produto por:

- `product_type = rapid_evidence_synthesis`;
- primary Investigation N3;
- publication gate N3;
- futura `RapidEvidenceSynthesisView`.

---

# 2. Princípio

> **N3 reutiliza entidades científicas existentes e adiciona apenas governança estruturada do método rápido e dos controles de qualidade.**

Não criar:

- RapidSearch;
- RapidScreening;
- RapidRiskAssessment;
- RapidResult;
- RapidSynthesis;
- RapidCertainty.

---

# 3. Product e Investigation

Product type:

`rapid_evidence_synthesis`

Invariantes:

- exatamente uma primary Investigation;
- `depth_level = N3`;
- QuestionVersion primária;
- protocolo obrigatório;
- cutoff Product = cutoff Investigation;
- ProductVersion current para publicação;
- `limitations_summary` obrigatório;
- `conclusion_text` obrigatório para produto final;
- maintenance M0–M3 permitido.

---

# 4. Protocolo

Fonte canônica:

`investigation.investigation_version.protocol_artifact_uuid`

Para N3 formal:

- não nulo;
- artifact ativo;
- ligado à versão da Investigation diretamente ou por metadata/role coerente;
- protocolo criado antes da busca definitiva, salvo justificativa histórica explícita em caso de atualização importada.

O contrato inicial validará presença e rastreabilidade; a precedência temporal detalhada poderá ser endurecida quando o lifecycle de artifacts for formalizado.

---

# 5. `investigation.method_decision`

## 5.1 Finalidade

Registrar decisão metodológica material da Investigation.

DDL conceitual:

```text
method_decision_uuid UUID PK
investigation_version_uuid UUID FK
decision_type TEXT
stage TEXT
decision_code TEXT
planned_flag BOOLEAN
rationale TEXT
risk_payload JSONB
mitigation_payload JSONB
impact_payload JSONB
resolution_status TEXT
decided_by TEXT
decided_at TIMESTAMPTZ
linked_artifact_uuid UUID FK nullable
record_status TEXT
supersedes_method_decision_uuid UUID FK nullable
```

---

# 6. Vocabulário de `decision_type`

Valores iniciais:

- `rapid_restriction`;
- `protocol_deviation`;
- `method_change`;
- `rerouting_trigger`;
- `other`.

---

# 7. Vocabulário de `stage`

Valores iniciais:

- `question`;
- `search`;
- `screening`;
- `extraction`;
- `appraisal`;
- `synthesis`;
- `certainty`;
- `reporting`;
- `cross_cutting`.

---

# 8. `resolution_status`

Valores:

- `open`;
- `accepted`;
- `mitigated`;
- `resolved`;
- `rerouted`;
- `rejected`.

Regra:

> protocol deviation ativo com `open` bloqueia publicação formal.

Rapid restriction preplanned deverá normalmente estar `accepted` ou `mitigated`.

---

# 9. Conteúdo obrigatório por rapid restriction

Para `decision_type=rapid_restriction`:

- decision_code;
- stage;
- planned_flag;
- rationale;
- risk_payload;
- mitigation_payload;
- resolution_status;
- decided_by;
- decided_at.

Exemplos de decision_code:

- `limited_databases`;
- `date_restriction`;
- `language_restriction`;
- `limited_grey_literature`;
- `single_screen_after_calibration`;
- `focused_data_extraction`;
- `focused_risk_of_bias`;
- `focused_certainty`;
- `omitted_secondary_analyses`;
- `other`.

---

# 10. Conteúdo obrigatório por protocol deviation

Para `decision_type=protocol_deviation`:

- stage;
- decision_code;
- `planned_flag=false`;
- rationale;
- impact_payload;
- mitigation_payload quando aplicável;
- resolution_status.

Desvio não poderá ser convertido retroativamente em restrição planejada.

---

# 11. Append-preserving

`method_decision` seguirá política de histórico:

- `record_status = active|superseded`;
- uma decisão material não é reescrita;
- correção cria novo registro;
- `supersedes_method_decision_uuid` preserva cadeia.

Índice único parcial poderá impedir duas versões ativas da mesma decisão lógica quando aplicável.

---

# 12. `investigation.quality_control_record`

## 12.1 Finalidade

Registrar verificações metodológicas por etapa, distintas do assurance final do produto.

DDL conceitual:

```text
quality_control_uuid UUID PK
investigation_version_uuid UUID FK
stage TEXT
control_type TEXT
actor TEXT
actor_type TEXT
qualification_payload JSONB nullable
independent_flag BOOLEAN
decision TEXT
scope_payload JSONB
agreement_payload JSONB nullable
discrepancy_payload JSONB nullable
resolution_payload JSONB nullable
performed_at TIMESTAMPTZ
evidence_artifact_uuid UUID FK nullable
notes TEXT nullable
record_status TEXT
supersedes_quality_control_uuid UUID FK nullable
```

---

# 13. `control_type`

Valores iniciais:

- `search_strategy_verification`;
- `search_strategy_peer_review`;
- `screening_pilot`;
- `screening_secondary_verification`;
- `critical_data_verification`;
- `risk_of_bias_verification`;
- `synthesis_statistical_review`;
- `certainty_verification`;
- `reporting_verification`;
- `other`.

---

# 14. `actor_type`

Valores:

- `ai_system`;
- `human_reviewer`;
- `human_expert`.

Constraints:

- AI → `independent_flag=false` para fins de human independence;
- human_reviewer/human_expert → qualification_payload obrigatório;
- nenhuma linha de IA satisfaz qualified human control.

---

# 15. `decision` do quality control

Valores:

- `passed`;
- `revise`;
- `failed`;
- `not_applicable`.

Para publication gate:

- `passed` satisfaz controle;
- `revise|failed` bloqueiam enquanto ativos;
- `not_applicable` só satisfaz quando o próprio gate considerar o controle condicional e houver rationale adequada.

---

# 16. Scope payload

`scope_payload` é obrigatório.

Deverá identificar o que foi verificado.

Exemplos:

Screening:

```json
{
  "records_sampled": 120,
  "records_total": 600,
  "sample_fraction": 0.20,
  "stages": ["title_abstract"],
  "screening_decision_ids": ["..."]
}
```

Extração:

```json
{
  "result_version_uuids": ["..."],
  "critical_fields": ["effect","variance","n","events"]
}
```

Risk of bias:

```json
{
  "risk_assessment_version_uuids": ["..."],
  "framework": "RoB 2"
}
```

---

# 17. Agreement payload

Para controles em que concordância é relevante:

`agreement_payload` poderá conter:

- metric;
- value;
- numerator/denominator;
- threshold;
- interpretation.

OES não fixa universalmente κ≥0.8 como regra.

Quando protocolo adotar limiar, ele deverá ser explícito.

---

# 18. Qualification payload

Para humano qualificado, registrar de forma proporcional:

- role;
- methodological_training;
- domain_expertise quando necessária;
- relevant_experience;
- credential_or_basis;
- conflict_of_interest;
- verification_scope.

Regra:

> preenchimento nominal não transforma o proprietário não especialista em revisor qualificado.

---

# 19. Helper conceitual — qualified control

Função candidata:

`investigation.has_qualified_control(investigation_version_uuid, control_type)`

Retorna true somente quando existir registro ativo com:

- actor_type humano;
- qualification_payload não nulo;
- independent_flag=true;
- decision=`passed`.

Para controles que não exigem independência estrita, função especializada poderá ajustar a regra; publication gate N3 utilizará versão estrita nos controles materiais.

---

# 20. Search

Para N3 formal, exigir:

- pelo menos uma Search concluída;
- cobertura de fontes coerente com protocolo;
- regra padrão de pelo menos duas fontes bibliográficas para efetividade.

Gate inicial:

> exigir pelo menos duas `source_name` distintas **ou** decisão metodológica ativa `search_source_exception`/equivalente que justifique a exceção.

Para perguntas de outra classe, a exceção documentada poderá ser legítima.

---

# 21. Search strategy verification

Produto formal deverá ter quality control humano qualificado:

- `search_strategy_peer_review`; ou
- `search_strategy_verification`.

PRESS poderá ser registrado em evidence_artifact/qualification payload quando utilizado.

AI search check não satisfaz este requisito formal.

---

# 22. Screening

ScreeningDecision permanece a unidade de decisão.

Para N3 formal com registros elegíveis/triados, exigir:

- screening decisions rastreáveis;
- `screening_pilot`;
- `screening_secondary_verification` humano qualificado passed;
- full-text exclusions com motivo, quando houver full-text stage.

Se Search não recuperar nenhum registro, o gate deverá aceitar estado no-evidence sem fabricar screening decisions, desde que Search e fluxo zero sejam rastreáveis.

---

# 23. Selection flow

RapidEvidenceSynthesisView deverá derivar, quando possível:

- search_hits_captured;
- deduplicated_records;
- title_abstract_decisions;
- full_text_decisions;
- full_text_exclusions;
- included_reports;
- included_studies.

Quando result_count externo não corresponder a SearchHits materializados:

- manter os dois valores distintos;
- não inferir PRISMA total a partir de dados incompletos.

---

# 24. Result e extração

Result/ResultSource permanecem canônicos.

Para evidence_available:

- Results críticos devem ter provenance;
- extractor deve ser registrado;
- `critical_data_verification` humano qualificado = passed.

Para síntese que apenas adota dados de review existente:

- provenance deve apontar para ReportVersion da revisão;
- appraisal da revisão é obrigatório;
- critical-data verification continua necessária.

---

# 25. RiskAssessment

Para evidence_available, exigir RiskAssessment materialmente adequado.

Publication gate deverá exigir:

- pelo menos um RiskAssessment para cada unidade crítica conforme protocolo;
- verification_status coerente;
- `risk_of_bias_verification` humano qualificado = passed.

Não tentar validar universalmente cobertura de cada Study em SQL v0.1; fixture e contrato deverão testar casos representativos.

---

# 26. Synthesis

Para `evidence_state=evidence_available`:

- pelo menos uma SynthesisVersion ligada ao Product;
- Synthesis deve pertencer à primary Investigation;
- contribuições/rastreabilidade coerentes.

Exceções:

- `no_evidence`;
- `non_estimable`, quando protocolo permitir saída sem Synthesis quantitativa, mas ainda houver síntese narrativa estruturada.

Para v0.1, o estado `no_evidence` poderá dispensar Synthesis desde que CertaintyAssessment/evidence state e conclusão reflitam corretamente ausência de evidência.

---

# 27. Meta-analysis / statistical review

Se Synthesis indicar:

- meta-analysis;
- network meta-analysis;
- complex quantitative synthesis;

o gate poderá exigir:

`synthesis_statistical_review` humano qualificado = passed.

Para síntese narrativa/SWiM simples, esse control_type não é universalmente obrigatório.

A lista de synthesis_type que dispara o requisito deverá ser controlada no contrato SQL.

---

# 28. CertaintyAssessment

Para unidades decisórias críticas com framework aplicável:

- CertaintyAssessment ligada ao Product;
- evidence state coerente;
- `certainty_verification` humano qualificado = passed.

Se framework formal for inaplicável:

- deverá existir method_decision justificando a exceção;
- produto deverá usar linguagem de confidence apropriada;
- não preencher final_level artificialmente.

---

# 29. Evidence states

Estados relevantes:

- `evidence_available`;
- `no_evidence`;
- `non_estimable` quando operacionalizado.

Regras:

- `no_evidence` não recebe certainty level artificial;
- absence de Result não é erro quando Search/selection demonstram no-evidence;
- conclusion deverá distinguir ausência de evidência de evidência de ausência.

---

# 30. Summary of Findings

Quando aplicável, SoF será artifact ligado à Investigation/Product.

Gate v0.1 poderá exigir:

- SoF artifact; ou
- method_decision `summary_of_findings_not_applicable`/equivalente.

Isso evita tornar SoF universal para classes onde não é apropriado.

---

# 31. Rapid-method limitations

Fonte principal:

- ProductVersion.limitations_summary;
- rapid restrictions ativas;
- protocol deviations.

View deverá projetar separadamente:

- limitações científicas da evidência;
- limitações decorrentes do método rápido.

Template não poderá fundi-las silenciosamente.

---

# 32. Assurance

Reutilizar:

`product.assurance_level()`

Wrapper candidato:

`product.rapid_evidence_synthesis_assurance_level()`.

Para publicação formal:

> **A3 obrigatório.**

A0/A1/A2 podem existir em desenvolvimento, mas não tornam N3 formal publicável.

---

# 33. Publication gate — erros científicos/estruturais

Códigos candidatos:

- `MISSING_PRODUCT_VERSION`;
- `WRONG_PRODUCT_TYPE`;
- `MISSING_PRIMARY_INVESTIGATION`;
- `MULTIPLE_PRIMARY_INVESTIGATIONS`;
- `PRIMARY_INVESTIGATION_NOT_N3`;
- `PRIMARY_INVESTIGATION_NOT_CURRENT`;
- `CUTOFF_DATE_MISMATCH`;
- `MISSING_QUESTION`;
- `MISSING_PROTOCOL`;
- `MISSING_SEARCH_RECORD`;
- `INSUFFICIENT_SEARCH_SOURCE_COVERAGE`;
- `MISSING_SELECTION_FLOW`;
- `MISSING_RISK_ASSESSMENT`;
- `MISSING_SYNTHESIS`;
- `MISSING_CERTAINTY_ASSESSMENT`;
- `MISSING_LIMITATIONS`;
- `MISSING_CURRENCY_STATE`;
- `INVALIDATED_DEPENDENCY`;
- `INVALIDATED_UPSTREAM_DEPENDENCY`.

---

# 34. Publication gate — erros de controle metodológico

- `OPEN_PROTOCOL_DEVIATION`;
- `MISSING_SEARCH_STRATEGY_VERIFICATION`;
- `MISSING_SCREENING_PILOT`;
- `MISSING_QUALIFIED_SCREENING_VERIFICATION`;
- `MISSING_QUALIFIED_DATA_VERIFICATION`;
- `MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION`;
- `MISSING_QUALIFIED_CERTAINTY_VERIFICATION`;
- `MISSING_REQUIRED_STATISTICAL_REVIEW`;
- `ACTIVE_QUALITY_CONTROL_REVISE`;
- `ACTIVE_QUALITY_CONTROL_FAILED`.

---

# 35. Publication gate — assurance

- `MISSING_AI_METHODOLOGICAL_VERIFICATION`;
- `ACTIVE_AI_METHOD_BLOCK`;
- `MISSING_OWNER_APPROVAL`;
- `ACTIVE_OWNER_BLOCK`;
- `MISSING_EXPERT_INDEPENDENT_REVIEW`;
- `ACTIVE_EXPERT_BLOCK`;
- `ASSURANCE_BELOW_A3`;
- `MISSING_PUBLICATION_DATE`.

Para N3, ausência de expert review é **error**, não warning.

---

# 36. Warnings candidatos

Warnings não bloqueantes poderão incluir:

- `RAPID_METHOD_RESTRICTIONS_PRESENT`;
- `DATE_RESTRICTION`;
- `LANGUAGE_RESTRICTION`;
- `LIMITED_GREY_LITERATURE`;
- `SINGLE_SCREENING_AFTER_CALIBRATION`;
- `FOCUSED_RISK_OF_BIAS`;
- `FOCUSED_CERTAINTY`;
- `REUSED_SYSTEMATIC_REVIEW_DATA`;
- `NO_FORMAL_META_ANALYSIS` quando não necessária;
- `APPLICABILITY_NOT_FORMALLY_ASSESSED`.

Warnings deverão refletir limitações reais, não funcionar como checklist ornamental.

---

# 37. Experimental mode

Uma fixture/caso experimental N3 poderá conter:

- protocolo;
- searches;
- screening;
- Results;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- method_decisions;
- AI quality controls;
- A1/A2.

Esperado:

> `publishable=false` enquanto controles humanos qualificados/A3 estiverem ausentes.

O gate deverá demonstrar explicitamente os blockers.

---

# 38. `RapidEvidenceSynthesisView` — schema inicial

Schema candidato:

`oes.rapid_evidence_synthesis_view/0.1`

Estrutura:

```text
RapidEvidenceSynthesisView
├── schema_version
├── identity
├── question
├── investigation
├── decision_context
├── protocol
├── rapid_method
│   ├── restrictions[]
│   ├── deviations[]
│   └── timebox
├── searches[]
├── selection_flow
├── included_evidence
├── risk_of_bias
├── results
├── syntheses[]
├── certainty[]
├── summary_of_findings
├── rapid_method_limitations
├── applicability
├── conclusion
├── references[]
├── quality_controls[]
└── audit
```

---

# 39. `audit`

Campos mínimos:

- publishable;
- assurance_level;
- expert_independent_reviewed;
- qualified_controls_satisfied;
- required_controls[];
- missing_controls[];
- assurance_records[];
- publication_issues[];
- protocol_deviations_open;
- lineage_available.

---

# 40. Decision context

Derivar inicialmente de:

- Investigation objective;
- Question context_payload;
- Product intended_audience;
- method_decisions relevantes.

Não criar tabela específica de DecisionContext na v0.1.

---

# 41. Referências

References deverão derivar de lineage/provenance:

- Results → Reports;
- RiskAssessment targets;
- Synthesis contributions;
- Certainty → Synthesis;
- fontes adotadas de revisões existentes.

Não criar bibliografia paralela manual.

---

# 42. Reprodutibilidade histórica

View deverá usar versões concretas:

- QuestionVersion;
- InvestigationVersion;
- StudyVersion;
- ReportVersion;
- ResultVersion;
- RiskAssessmentVersion;
- SynthesisVersion;
- CertaintyAssessmentVersion;
- ProductVersion;
- method_decision/QC records ativos naquele estado.

Não substituir automaticamente por versões mais novas.

---

# 43. Critérios de PASS do contrato

A implementação N3 v0.1 deverá demonstrar:

1. estruturas transversais criadas com constraints;
2. histórico append-preserving;
3. Product type N3;
4. protocolo obrigatório;
5. Search reproduzível;
6. rapid restrictions estruturadas;
7. protocol deviations estruturados;
8. quality controls por etapa;
9. AI controls não satisfazem human-qualified controls;
10. screening decisions continuam canônicos;
11. Result/ResultSource continuam canônicos;
12. RiskAssessment reutilizado;
13. Synthesis reutilizada;
14. CertaintyAssessment reutilizada;
15. publication gate exige A3 + controls;
16. A2 permanece não publicável em N3;
17. no-evidence representável;
18. meta-analysis dispara statistical review quando configurada;
19. view determinística;
20. rebuild reproduz estado;
21. regressões N0/N1/N2 permanecem verdes.

---

# 44. Migration candidata

Após este contrato fica autorizada a criação de:

`database/014_rapid_evidence_synthesis_contract.sql`

Escopo:

- `investigation.method_decision`;
- `investigation.quality_control_record`;
- constraints/indexes/helpers;
- publication gate N3;
- RapidEvidenceSynthesisView.

A migration não deverá alterar significado das entidades científicas existentes.

---

# 45. Próxima etapa

Implementar migration 014, fixture experimental N3 e testes de contrato.

O primeiro fixture deverá demonstrar propositalmente:

- conteúdo científico estruturalmente completo;
- AI quality checks presentes;
- owner approval opcional para testar A2;
- ausência de qualified human controls;
- ausência de A3;
- `publishable=false` por design.

Somente depois deverá ser discutido template ou caso real N3.

---

**Decisão do contrato:** N3 reutiliza o núcleo científico OES-P1 e adiciona governança metodológica transversal que impede publicação formal sem controles humanos qualificados.