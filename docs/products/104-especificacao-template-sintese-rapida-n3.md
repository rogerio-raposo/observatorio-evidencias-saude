# 104 — Especificação do Template Operacional da Síntese Rápida — N3

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — especificação inicial do template  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 99–103  
**Entrada canônica:** `RapidEvidenceSynthesisView` — `oes.rapid_evidence_synthesis_view/0.1`

---

# 1. Finalidade

Definir a apresentação operacional da **Síntese Rápida de Evidências — N3**.

Regra:

> **o template apresenta uma síntese formal rápida e seus controles; não completa método ausente nem cria garantia.**

# 2. Formato inicial

Markdown canônico.

Motivos:

- versionamento;
- diff;
- auditabilidade;
- transformação futura para HTML/PDF/DOCX;
- reuso do motor neutro já validado nos produtos N0–N2.

# 3. Ordem canônica

1. aviso de status/gate;
2. cabeçalho;
3. pergunta e contexto decisório;
4. conclusão da evidência;
5. certeza/confiança;
6. síntese principal;
7. principais resultados;
8. limitações da evidência;
9. limitações do método rápido;
10. protocolo;
11. restrições planejadas;
12. desvios do protocolo;
13. método de busca;
14. fluxo de seleção;
15. evidência incluída;
16. risco de viés;
17. quality controls;
18. controles qualificados ausentes;
19. aplicabilidade;
20. referências;
21. assurance e auditoria.

# 4. Aviso de estado

Quando `audit.publishable=false`, o documento deverá começar com:

> **EXPERIMENTAL — NÃO PUBLICÁVEL COMO N3 FORMAL**

seguido de:

> **PREVIEW — GATE DE PUBLICAÇÃO NÃO APROVADO**

quando houver blockers.

Quando `audit.publishable=true`:

> **Gate de publicação N3: aprovado**

sem aviso experimental.

# 5. Cabeçalho

Exibir:

- title;
- Product ID;
- version;
- depth N3;
- maintenance;
- editorial status;
- evidence cutoff;
- currency;
- assurance;
- publication date quando houver.

# 6. Pergunta

Forma principal:

`question.normalized_text`

Pergunta original poderá aparecer quando diferente.

# 7. Contexto decisório

Fonte:

`decision_context`

Exibir:

- objective;
- intended audience;
- question context quando útil.

# 8. Conclusão da evidência

Fonte:

`conclusion.text`

Deverá aparecer cedo na leitura, mas acompanhada da certainty e do estado do gate.

Não converter em recomendação.

# 9. Certeza/confiança

Fonte:

`certainty[]`

Exibir para cada unidade:

- framework;
- final level;
- evidence state;
- assessment date;
- role.

Se `no_evidence`:

- apresentar estado;
- não exibir nível artificial.

# 10. Sínteses

Fonte:

`syntheses[]`

Apresentar:

- synthesis type;
- origin;
- method;
- model;
- result summary;
- role.

Não recalcular resultados.

# 11. Resultados

Fonte:

`results[]`

Tabela flexível:

- measure;
- reported/derived value;
- CI;
- unit;
- outcome/Result ID quando disponível.

Dados ausentes permanecem vazios; não inferir.

# 12. Limitações da evidência

A primeira versão não possui campo separado estruturado além de appraisal/certainty.

Portanto, apresentar:

- RiskAssessment;
- CertaintyAssessment;
- applicability;
- conclusão/limitations persistidas quando relevantes.

Não inventar lista derivada de todos os domínios.

# 13. Limitações do método rápido

Fonte:

`rapid_method_limitations.summary` + restrictions/deviations.

Título obrigatório:

> **Limitações decorrentes do método rápido**

Não fundir com risco de viés dos estudos.

# 14. Protocolo

Fonte:

`protocol`

Exibir artifact identifier/status/hash de forma compacta.

# 15. Restrições planejadas

Para cada restriction:

- stage;
- code;
- rationale;
- risk;
- mitigation;
- resolution status.

Se não houver restrictions, o template deverá indicar que isso é incompatível com caracterização N3 do contrato v0.1.

# 16. Desvios do protocolo

Se houver:

- stage;
- code;
- rationale;
- impact;
- mitigation;
- resolution.

Se nenhum:

> Nenhum desvio ativo/projetado.

# 17. Busca

Tabela:

- source;
- platform;
- execution;
- result_count;
- hits materializados;
- status.

Não reconciliar contagens externas e capturadas.

# 18. Fluxo de seleção

Exibir os contadores disponíveis em `selection_flow`.

Não chamar de PRISMA automaticamente.

# 19. Evidência incluída

Fonte:

`included_evidence[]`

Apresentar:

- Report ID;
- title;
- publication date/status.

# 20. Risco de viés

Fonte:

`risk_of_bias[]`

Apresentar:

- framework;
- target;
- overall judgement;
- verification status.

Adicionar nota fixa:

> **o verification status do appraisal não substitui registro de quality control humano qualificado.**

# 21. Quality controls

Fonte:

`quality_controls[]`

Tabela:

- stage;
- control type;
- actor;
- actor type;
- qualified;
- independent;
- decision;
- performed at.

IA deve ser visualmente distinguida de human-qualified control por rótulo textual.

# 22. Missing controls

Se `audit.missing_controls` não estiver vazio:

Título obrigatório:

> **Controles qualificados ainda ausentes — blockers formais**

Listar código + mensagem.

Não reduzir para nota de rodapé.

# 23. Assurance

Mostrar:

- assurance level;
- expert independent reviewed;
- qualified controls satisfied;
- protocol deviations open;
- lineage available.

Para A2 experimental:

> **A2 não autoriza publicação N3 formal.**

Para A3 formal com controls satisfied:

> **A3 + controles qualificados satisfeitos.**

# 24. Publication issues

Listar todos.

Separar visualmente errors e warnings quando o renderer evoluir; na v0.1, preservar severity em cada item.

# 25. Applicability

Mostrar summary quando presente.

Enquanto formal_assessment=false:

> análise descritiva; não é avaliação formal de transferibilidade.

# 26. Referências

Fonte:

`references[]`

Lista deduplicada e rastreável.

# 27. Summary of Findings

Quando artifact presente:

- exibir identificação.

Quando ausente mas método registrou não aplicabilidade:

- não criar tabela vazia;
- a justificativa permanece auditável via method decision/publication gate.

# 28. Comportamento experimental A2

Fixture atual deve renderizar:

- experimental;
- não publicável;
- A2;
- scientific core completo;
- quality controls por IA visíveis;
- `qualified_controls_satisfied=false`;
- seis missing controls;
- missing expert review/A3 como errors.

# 29. Comportamento formal A3

Validator de apresentação poderá simular, em memória:

- assurance=A3;
- publishable=true;
- expert=true;
- qualified_controls_satisfied=true;
- missing_controls=[];
- publication issues sem errors.

Objetivo:

> validar comportamento visual do template, sem materializar falso A3 persistente.

A prova canônica de que o gate formal abre já pertence ao RS-T11 SQL transacional.

# 30. Renderer

Reutilizar o motor neutro de templates já validado.

Novo wrapper:

`scripts/render_rapid_evidence_synthesis_reference.py`

Ele não poderá consultar banco ou modificar payload.

# 31. Validator

Arquivo previsto:

`scripts/validate_rapid_evidence_synthesis_render.py`

Deverá testar:

- fixture experimental A2;
- missing controls visíveis;
- rapid restrictions;
- protocolo;
- Synthesis/Certainty;
- comportamento formal A3 simulado;
- ausência de tokens não resolvidos;
- nenhuma informação criada fora da view.

# 32. Critérios de PASS

Template v0.1 = PASS quando:

1. renderizar schema v0.1;
2. mostrar pergunta/contexto;
3. mostrar conclusão;
4. mostrar certainty;
5. mostrar Synthesis;
6. mostrar restrictions;
7. mostrar deviations;
8. mostrar searches/selection;
9. mostrar evidence/RoB;
10. mostrar quality controls;
11. mostrar missing controls;
12. mostrar experimental warning no A2;
13. não mostrar experimental warning no A3 formal simulado;
14. preservar publication issues;
15. mostrar limitações do método rápido;
16. mostrar assurance;
17. não deixar tokens;
18. regressões N0–N2 permanecerem verdes.

# 33. Arquivos previstos

- `templates/rapid-evidence-synthesis.md`;
- `templates/rapid-evidence-synthesis-presentation-map.json`;
- `scripts/render_rapid_evidence_synthesis_reference.py`;
- `scripts/validate_rapid_evidence_synthesis_render.py`.

# 34. Próxima etapa

Implementar template, mapa, renderer e validator com base na fixture experimental N3 validada.

---

**Documento vivo. Alterações materiais deverão ser registradas no CHANGELOG.md.**