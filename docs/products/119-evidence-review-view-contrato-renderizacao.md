# 119 — EvidenceReviewView: Contrato de Renderização da Revisão de Evidências — N4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status:** contrato de renderização candidato

---

# 1. Finalidade

Definir como `oes.evidence_review_view/0.1` deve ser apresentada sem introduzir novos julgamentos científicos, metodológicos ou de assurance.

# 2. Princípio de apresentação

O renderer:

- consome somente EvidenceReviewView;
- não consulta banco;
- não recalcula síntese;
- não cria certainty;
- não cria assurance;
- não infere qualificação humana;
- não transforma warning em error;
- não transforma A3 em publication approval se `publishable=false`.

# 3. Regra crítica de segurança

> **A3 e publication gate são dimensões distintas.**

Se `audit.assurance_level=A3` mas `audit.publishable=false`, a apresentação deve mostrar claramente:

- A3 existe;
- publicação permanece bloqueada;
- issue(s) do gate permanecem visíveis.

# 4. Fixture sintética

Se `audit.synthetic_fixture=true`, a apresentação deve exibir no topo:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA REVISÃO HUMANA REAL**

e esclarecer que:

- reviewers são fictícios;
- expert review é sintético;
- A3 é exclusivamente de validação de contrato;
- nenhum resultado deve ser usado como evidência clínica real.

# 5. Camadas de leitura

## 5.1 Camada decisória

- pergunta;
- conclusão;
- certainty;
- Summary of Findings;
- aplicabilidade;
- limitações.

## 5.2 Camada metodológica

- subtype;
- readiness;
- protocolo/registro;
- buscas;
- search peer review;
- seleção;
- extração;
- RoB/ROB-ME;
- síntese;
- heterogeneidade/sensibilidade;
- certainty;
- reviewer assignments;
- quality controls.

## 5.3 Camada auditável

- assurance;
- publication issues;
- assignments;
- artifacts;
- provenance/reproducibility;
- IDs/versioning.

# 6. Estado formal publicável

Quando `audit.publishable=true`:

- exibir `Gate de publicação N4: aprovado`;
- exibir assurance;
- exibir readiness;
- manter warnings;
- manter synthetic disclosure quando aplicável.

# 7. Estado bloqueado

Quando `audit.publishable=false`:

- exibir `GATE DE PUBLICAÇÃO N4 NÃO APROVADO`;
- manter conclusion rotulada como não publicável;
- exibir errors antes dos warnings;
- nunca omitir missing stage controls.

# 8. identity

Exibir:

- título;
- Product ID;
- versão;
- editorial status;
- currency;
- cutoff;
- publication date quando houver;
- assurance.

# 9. question/investigation/subtype

Exibir:

- normalized question;
- original question quando presente;
- depth;
- maintenance;
- objective;
- subtype.

# 10. infrastructure_readiness

Exibir:

- state;
- domains;
- required sources;
- rationale;
- resolution status.

`not_ready` ou `ready_with_documented_conditions` não pode parecer equivalente a `ready`.

# 11. protocol/registration

Exibir:

- protocol artifact/hash;
- registration artifacts quando existentes;
- ausência de registro externo como warning, não como protocolo ausente.

# 12. amendments_and_deviations

Exibir todos os registros ativos relevantes com:

- type/stage/code;
- planned;
- rationale;
- risk;
- mitigation;
- impact;
- resolution.

# 13. reviewer_assignments

Exibir:

- stage;
- role;
- actor;
- actor_type;
- qualification;
- independent;
- scope;
- conflict.

Não converter `qualification_payload` em simples selo visual sem manter o conteúdo auditável.

# 14. method.quality_controls

Exibir cada controle com:

- stage;
- control type;
- actor;
- actor type;
- independence;
- decision;
- scope;
- performed_at;
- evidence artifact.

# 15. searches

Exibir:

- source;
- platform;
- source_class;
- strategy version;
- executed_at;
- result_count;
- materialized hits;
- export artifact;
- status.

# 16. search_peer_review

Exibir separadamente para que a presença de searches não seja confundida com peer review da estratégia.

# 17. selection_flow

Exibir contagens derivadas:

- search hits;
- unique report targets;
- screening decisions;
- title/abstract;
- full text;
- exclusions;
- adjudications.

# 18. excluded_full_text

Exibir target/reason/reviewer/data.

# 19. extraction_controls

Exibir:

- independent extraction records;
- verification controls;
- source location;
- actor;
- target ResultVersion.

# 20. study_characteristics

Exibir os estudos efetivamente contribuidores à síntese.

# 21. risk_of_bias

Exibir:

- framework;
- target;
- outcome;
- judgement;
- assessor;
- verification status;
- date.

# 22. missing_evidence

Exibir ROB-ME ou equivalente separadamente do study-level RoB.

# 23. results

Exibir valores estruturados sem recalcular.

# 24. syntheses

Exibir:

- synthesis type/origin;
- method/model;
- software/version;
- result summary;
- code artifact;
- dataset artifact;
- role.

# 25. heterogeneity

Exibir métricas projetadas; não reinterpretar thresholds automaticamente.

# 26. sensitivity_analyses

Exibir contribuições/flags projetados; não inventar análises ausentes.

# 27. certainty

Exibir:

- framework/version;
- initial/final level;
- evidence state;
- date;
- role.

# 28. summary_of_findings

Exibir artifact/hash e não reconstruir conteúdo fora da view.

# 29. applicability/limitations/conclusion

Exibir literalmente as sínteses textuais canônicas da ProductVersion.

# 30. reproducibility

Exibir:

- analysis artifacts;
- product artifacts;
- software/version;
- hashes/storage keys.

# 31. references

Exibir todas as references da view sem deduplicação editorial adicional.

# 32. audit

Exibir:

- synthetic_fixture;
- assurance level;
- publishable;
- readiness;
- reviewer assignment count;
- qualified stage controls satisfied;
- protocol deviations open;
- expert independent reviewed;
- lineage;
- invalidated dependencies;
- publication issues;
- assurance records.

# 33. Publication issues

Errors devem ser mostrados antes de warnings.

Nenhuma issue deve ser suprimida por existir A3.

# 34. Identificadores técnicos

Exibir:

- schema version;
- Product entity/version UUID;
- InvestigationVersion;
- QuestionVersion.

# 35. Critérios de PASS

PASS de renderização exige:

1. zero tokens não resolvidos;
2. todos os campos críticos projetados;
3. banner sintético quando `synthetic_fixture=true`;
4. formal fixture A3 mostra gate aprovado;
5. estado adversarial A3 + publishable=false mostra gate bloqueado;
6. readiness visível;
7. reviewer assignments visíveis;
8. stage controls visíveis;
9. ROB-ME visível;
10. code/dataset/reproducibility visíveis;
11. assurance records visíveis;
12. nenhum julgamento científico criado no renderer.

# 36. Próxima etapa

> Criar o template operacional, presentation map, renderer e validator N4.

---

**Resultado:** contrato de renderização N4 definido.