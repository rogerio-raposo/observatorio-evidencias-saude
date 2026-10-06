# 120 — Especificação do Template Operacional da Revisão de Evidências — N4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status:** especificação operacional candidata

---

# 1. Finalidade

Definir a estrutura canônica do template Markdown da Revisão de Evidências N4, consumindo exclusivamente `oes.evidence_review_view/0.1`.

# 2. Arquivos previstos

- `templates/evidence-review.md`;
- `templates/evidence-review-presentation-map.json`;
- `scripts/render_evidence_review_reference.py`;
- `scripts/validate_evidence_review_render.py`.

# 3. Ordem canônica

1. banner de estado;
2. cabeçalho;
3. pergunta;
4. conclusão;
5. certainty;
6. Summary of Findings;
7. aplicabilidade;
8. limitações;
9. readiness;
10. protocolo/registro;
11. emendas/desvios;
12. buscas;
13. search peer review;
14. fluxo de seleção;
15. full-text exclusions;
16. estudos incluídos;
17. extração;
18. risk of bias;
19. missing evidence/ROB-ME;
20. resultados;
21. sínteses;
22. heterogeneidade;
23. sensitivity;
24. reviewer assignments;
25. quality controls;
26. reprodutibilidade;
27. referências;
28. assurance/audit;
29. issues do gate;
30. IDs técnicos.

# 4. Banner de fixture sintética

Quando `audit.synthetic_fixture=true`:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA REVISÃO HUMANA REAL**

Texto obrigatório adicional:

> Revisores, expert review e A3 deste artefato são sintéticos e existem somente para validação do contrato técnico N4.

# 5. Banner de publication gate

Se `audit.publishable=true`:

> **Gate de publicação N4: aprovado.**

Se `audit.publishable=false`:

> **GATE DE PUBLICAÇÃO N4 NÃO APROVADO**

e:

> Assurance, inclusive A3, não substitui requisitos de etapa.

# 6. Cabeçalho

Exibir:

- Product ID;
- versão;
- subtype;
- profundidade;
- manutenção;
- estado editorial;
- currency;
- cutoff;
- publication date;
- assurance;
- readiness.

# 7. Pergunta

Exibir normalized question e original question quando houver.

# 8. Conclusão

Exibir `conclusion.text` sem reescrita.

Se não publicável, rotular como conclusão de versão não publicável.

# 9. Certainty

Tabela com:

- framework;
- initial level;
- final level;
- evidence state;
- date;
- role.

# 10. Summary of Findings

Exibir artifact UUID, storage key, hash e mime type.

# 11. Aplicabilidade e limitações

Exibir os resumos canônicos da ProductVersion.

# 12. Readiness

Exibir state, domains, required sources, rationale e resolution.

# 13. Protocolo

Exibir artifact/hash/data/status.

# 14. Registro

Exibir artifacts de registro quando existirem.

# 15. Emendas/desvios

Exibir cada MethodDecision aplicável.

# 16. Buscas

Tabela com source, platform, source class, execution, result count, materialized hits, export artifact e status.

# 17. Search peer review

Tabela separada.

# 18. Fluxo de seleção

Exibir todas as contagens da view.

# 19. Exclusões full text

Tabela com target, reviewer, reason, date e adjudication.

# 20. Estudos

Tabela com Study ID, design, type, sample size e status.

# 21. Extração

Exibir independent extraction records e verification controls.

# 22. Risk of bias

Tabela com framework, target, outcome, judgement, assessor, verification e date.

# 23. Missing evidence

Seção separada para ROB-ME/equivalente.

# 24. Resultados

Tabela de valores estruturados.

# 25. Sínteses

Exibir method/model/software/result summary e artifacts de análise.

# 26. Heterogeneidade

Exibir I², tau² e prediction interval apenas quando presentes.

# 27. Sensitivity analyses

Exibir itens projetados; não inventar análises adicionais.

# 28. Reviewer assignments

Tabela com stage, role, actor, type, qualification, independence e conflicts.

# 29. Quality controls

Tabela com stage, control, actor, type, independence, decision, scope e date.

# 30. Reprodutibilidade

Exibir analysis artifacts e product artifacts.

# 31. Referências

Lista completa da view.

# 32. Assurance e auditoria

Exibir:

- assurance level;
- publishable;
- synthetic fixture;
- readiness;
- reviewer count;
- qualified stage controls satisfied;
- protocol deviations open;
- expert reviewed;
- lineage;
- invalidated dependencies.

# 33. Issues

Exibir todas as publication issues.

# 34. Assurance records

Tabela com assurance type, actor, actor type, independent, decision e performed_at.

# 35. IDs técnicos

Exibir schema e UUIDs centrais.

# 36. Presentation map

Deverá traduzir:

- editorial status;
- currency;
- assurance;
- readiness;
- actor type;
- roles;
- stages;
- control types;
- decisions;
- certainty levels;
- RoB judgements;
- booleans relevantes.

# 37. Renderer

Reutilizar o engine neutro validado em `render_evidence_sheet_reference.py`.

O wrapper N4 não realizará lógica científica.

# 38. Validator

Deverá validar:

- schema version;
- synthetic banner;
- gate approved no fixture formal;
- readiness ready;
- 12 reviewer assignments;
- 3 searches;
- search peer review;
- 2 studies;
- 2 study-level risk assessments;
- 1 ROB-ME;
- 2 Results;
- 1 synthesis;
- heterogeneity;
- sensitivity;
- 1 certainty;
- 1 SoF;
- A3;
- qualified stage controls;
- no unresolved tokens.

# 39. Cenário adversarial de apresentação

O validator deverá criar cópia em memória com:

- `audit.publishable=false`;
- `audit.assurance_level=A3` mantido;
- publication issue sintética.

E exigir:

- gate visual bloqueado;
- A3 ainda visível;
- mensagem de que A3 não substitui stage controls;
- nenhum texto de gate aprovado.

# 40. Critérios de PASS

PASS exige:

- render real da fixture sintética;
- validator positivo;
- validator adversarial;
- integração S5;
- regressões;
- rebuild;
- nenhum token não resolvido.

# 41. Próxima etapa

> Implementar template/presentation map/renderer/validator e integrar ao CI.

---

**Resultado:** template operacional N4 especificado.