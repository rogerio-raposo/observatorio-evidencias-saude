# 103 — RapidEvidenceSynthesisView: Contrato de Renderização da Síntese Rápida — N3

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato de renderização inicial  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 99–102; migration 014  
**Baseline:** OES-P1 + migration 014  
**Produto:** OES — Síntese Rápida de Evidências  
**Nível:** N3  
**Schema version:** `oes.rapid_evidence_synthesis_view/0.1`

---

# 1. Finalidade

Definir como o objeto `RapidEvidenceSynthesisView` deverá alimentar a apresentação N3 sem esconder restrições do método rápido nem sugerir garantia formal inexistente.

O objeto é:

> **projeção derivada, somente leitura e específica de N3.**

Não é:

- entidade científica;
- template;
- approval engine;
- substituto do protocol;
- substituto de RiskAssessment/Synthesis/Certainty;
- mecanismo que decide se um revisor é qualificado.

# 2. Princípio de apresentação

A renderização N3 terá três objetivos simultâneos:

1. comunicar a síntese científica;
2. comunicar como a rapidez alterou o método;
3. comunicar se os controles formais necessários realmente existem.

Regra:

> **completude científica não poderá mascarar incompletude de governança metodológica.**

# 3. Estrutura de topo

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
│   └── deviations[]
├── searches[]
├── selection_flow
├── included_evidence[]
├── risk_of_bias[]
├── results[]
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

# 4. Camadas de leitura

## 4.1 Camada decisória

Deverá permitir leitura rápida de:

- pergunta;
- conclusão da evidência;
- síntese principal;
- certainty/confidence;
- limitações críticas;
- cutoff;
- assurance;
- gate status.

## 4.2 Camada metodológica

Deverá tornar visíveis:

- protocolo;
- buscas;
- fluxo de seleção;
- rapid restrictions;
- deviations;
- appraisal;
- quality controls;
- missing controls;
- rationale de bloqueio.

## 4.3 Camada auditável

Deverá expor:

- IDs/versionamento;
- references;
- lineage;
- assurance records;
- publication issues.

# 5. Estado experimental

Quando:

- `publishable=false`; e
- `assurance_level<A3` ou `qualified_controls_satisfied=false`;

a apresentação deverá iniciar com aviso explícito:

> **EXPERIMENTAL — NÃO PUBLICÁVEL COMO N3 FORMAL**

Se existirem erros adicionais:

> **PREVIEW — GATE DE PUBLICAÇÃO NÃO APROVADO**

Esses avisos não podem ficar apenas na auditoria final.

# 6. Estado formal

Quando:

- publishable=true;
- assurance=A3;
- qualified_controls_satisfied=true;

a apresentação poderá indicar:

> **Gate de publicação N3: aprovado**

Warnings permanecem visíveis.

# 7. identity

Exibir:

- title;
- Product ID;
- version;
- product_type;
- editorial status;
- publication date quando presente;
- evidence cutoff;
- currency status.

UUIDs técnicos ficam na auditoria.

# 8. question e decision_context

Pergunta principal:

`question.normalized_text`

Pergunta original poderá aparecer quando diferir materialmente.

`decision_context` deverá exibir:

- objective;
- intended audience;
- contexto decisório quando disponível.

N3 não poderá ser apresentado sem deixar clara a finalidade da síntese.

# 9. protocol

Se presente, exibir:

- artifact type;
- storage key ou identificador amigável;
- content hash para auditoria;
- status.

Se ausente:

- publication issue correspondente deverá permanecer visível;
- template não cria substituto narrativo.

# 10. rapid_method.restrictions[]

Seção obrigatória quando houver qualquer restriction.

Título:

> **Restrições planejadas do método rápido**

Cada item deverá exibir:

- stage;
- code;
- rationale;
- risk;
- mitigation;
- resolution status.

Não omitir o risco adicional gerado pela simplificação.

# 11. rapid_method.deviations[]

Título:

> **Desvios do protocolo**

Cada item deverá mostrar:

- stage;
- code;
- rationale;
- impact;
- mitigation;
- resolution status.

Se houver deviation `open`, um aviso bloqueante deverá permanecer visível.

# 12. Searches

Exibir tabela com:

- source;
- platform;
- execution date;
- result_count;
- materialized hits;
- status.

Quando contagens externas e hits materializados diferirem:

> mostrar ambos sem reconciliar artificialmente.

# 13. selection_flow

Exibir:

- search hits materializados;
- screening decisions;
- title/abstract decisions;
- full-text decisions;
- full-text exclusions.

Não chamar automaticamente de PRISMA se o fluxo não estiver completo.

# 14. included_evidence[]

Apresentar:

- Report ID;
- title;
- publication date;
- publication status;
- source locations quando relevantes.

Essa seção representa evidência incluída/rastreável, não avaliação de qualidade.

# 15. risk_of_bias[]

Apresentar:

- framework;
- target;
- outcome;
- overall judgement;
- assessment date;
- verification status.

Regra:

> `verification_status` não poderá ser interpretado como verificação humana qualificada sem quality_control_record correspondente.

# 16. results[]

Exibir apenas campos disponíveis:

- outcome;
- measure;
- reported/derived value;
- CI;
- unit.

O template não recalcula Results.

# 17. syntheses[]

Cada síntese deverá mostrar:

- synthesis type;
- origin;
- method;
- model;
- software quando aplicável;
- result summary;
- role.

Se synthesis_type for quantitativo/meta-analítico:

- quality control estatístico requerido deverá aparecer no audit/missing controls quando ausente.

# 18. certainty[]

Apresentar:

- framework;
- initial level;
- final level;
- evidence state;
- assessment date;
- role.

Para `no_evidence`:

- não apresentar certainty level artificial;
- linguagem deverá distinguir ausência de evidência de evidência de ausência.

# 19. Summary of Findings

Quando artifact existir:

- indicar presença e identificador;
- futura renderização poderá incorporá-lo ou vinculá-lo.

Quando não aplicável por method_decision:

- apresentar justificativa em seção metodológica;
- não criar tabela SoF vazia.

# 20. Limitações — duas classes

Separar obrigatoriamente:

## 20.1 Limitações da evidência

Exemplos:

- risco de viés;
- imprecisão;
- inconsistência;
- indirectness;
- baixa representatividade.

## 20.2 Limitações do método rápido

Fonte:

- `rapid_method_limitations.summary`;
- `rapid_method.restrictions[]`;
- deviations.

Exemplos:

- bases limitadas;
- literatura cinzenta reduzida;
- triagem simples após calibração;
- certainty focada.

Regra:

> **não misturar as duas classes em um único texto sem rótulo.**

# 21. applicability

Apresentação descritiva enquanto `formal_assessment=false`.

Não inferir transferibilidade.

# 22. conclusion

Fonte:

`conclusion.text`

Pode expressar conclusão científica N3.

Não poderá:

- converter automaticamente em recomendação;
- omitir impacto das rapid restrictions quando material;
- ocultar certainty.

# 23. quality_controls[]

Cada controle deverá mostrar:

- stage;
- control_type;
- actor;
- actor_type;
- qualified;
- independent;
- decision;
- scope;
- agreement quando aplicável;
- discrepancies/resolution quando presentes;
- performed_at.

Regra visual:

> **IA verificada/AI passed não deve aparecer com o mesmo rótulo visual de human-qualified passed.**

# 24. missing_controls[]

Quando não vazio:

seção obrigatória e destacada:

> **Controles qualificados ainda ausentes**

Cada item deverá mostrar:

- control_code;
- message.

Não usar linguagem como “recomendado”; esses itens são blockers formais de N3.

# 25. audit

Campos essenciais:

- publishable;
- assurance_level;
- expert_independent_reviewed;
- qualified_controls_satisfied;
- missing_controls[];
- assurance_records[];
- publication_issues[];
- protocol_deviations_open;
- lineage_available.

# 26. A2 experimental

Para fixture/caso experimental A2:

a renderização deverá deixar explícito:

- owner approval pode existir;
- AI verification pode existir;
- A3 ausente;
- expert independent review ausente;
- qualified controls ausentes;
- publicação formal bloqueada.

Não usar:

> “quase aprovado”

ou linguagem equivalente.

# 27. A3 formal

Somente quando view indicar simultaneamente:

- assurance_level=A3;
- expert_independent_reviewed=true;
- qualified_controls_satisfied=true;
- publishable=true;

o template poderá remover o aviso experimental.

# 28. Publication issues

Errors e warnings devem ser separados visualmente.

Errors:

- blockers formais.

Warnings:

- limitações/transparência não bloqueantes.

Template não converte warning em error nem error em warning.

# 29. Reprodutibilidade histórica

Renderização deve preservar versões concretas.

Não substituir silenciosamente:

- Reports;
- Results;
- Synthesis;
- Certainty;
- method decisions;
- quality controls;
- ProductVersion.

# 30. Critérios de PASS

O contrato de renderização será considerado apto ao template quando suportar:

1. N3 experimental bloqueado;
2. N3 formal A3;
3. protocolo;
4. rapid restrictions;
5. protocol deviations;
6. Search/selection flow;
7. included evidence;
8. risk of bias;
9. Results;
10. Synthesis;
11. Certainty;
12. SoF presente ou não aplicável;
13. limitações científicas e rápidas separadas;
14. quality controls;
15. missing controls;
16. assurance A0–A3;
17. publication issues;
18. nenhum julgamento científico criado no renderer.

# 31. Próxima etapa

Especificar:

> **Template Operacional da Síntese Rápida — N3**

O template deverá priorizar a leitura decisória sem reduzir transparência metodológica.

Somente depois deverão ser criados Markdown, presentation map, renderer e validator.

---

**Documento vivo. Alterações incompatíveis deverão considerar evolução de `schema_version`.**