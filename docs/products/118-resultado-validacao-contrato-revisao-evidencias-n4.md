# 118 — Resultado da Validação Técnica do Contrato da Revisão de Evidências — N4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status:** **PASS técnico**

---

# 1. Escopo

Registrar o resultado da validação técnica da arquitetura e do contrato de dados N4 definidos nos Documentos 115–117.

# 2. Implementação validada

Artefatos principais:

- `database/015_evidence_review_contract.sql`;
- `database/f3-evidence-review-fixtures.sql`;
- `database/f3-evidence-review-tests-a.sql`;
- `database/f3-evidence-review-tests-b.sql`;
- `database/f3-evidence-review-rebuild-check.sql`.

Nova estrutura persistente:

- `investigation.reviewer_assignment`.

Extensão semântica:

- `appraisal.assert_risk_target_type()` passa a aceitar `Synthesis`, além de Study/Result/Report, para permitir ROB-ME em nível de síntese.

# 3. EvidenceReviewView

Schema:

`oes.evidence_review_view/0.1`

A view projeta:

- identidade;
- pergunta;
- investigation/subtype;
- infrastructure readiness;
- protocolo/registro;
- emendas/desvios;
- reviewer assignments;
- quality controls;
- searches;
- search peer review;
- selection flow;
- full-text exclusions;
- extraction controls;
- study characteristics;
- risk of bias;
- results;
- syntheses;
- heterogeneity;
- sensitivity analyses;
- missing evidence;
- certainty;
- Summary of Findings;
- applicability;
- limitations;
- reproducibility;
- references;
- audit.

# 4. Fixture formal sintética

A fixture N4 representa uma revisão sistemática de intervenção **inteiramente sintética**, contendo:

- readiness = ready;
- protocolo prospectivo;
- três bases bibliográficas;
- exports rastreáveis;
- search peer review sintético;
- dois screeners independentes;
- dupla extração crítica;
- dupla appraisal;
- meta-analysis reprodutível;
- statistical review;
- ROB-ME;
- dupla GRADE;
- Summary of Findings;
- AI verification;
- owner approval;
- expert independent review sintético;
- assurance A3;
- publicação sintética para teste do gate.

Nenhum ator sintético deve ser interpretado como revisão humana real.

# 5. Testes

Foram validados os testes ER4-T01–T25, incluindo:

- A3 + publishable no caminho formal sintético;
- projection da EvidenceReviewView;
- readiness obrigatório;
- pelo menos duas bases bibliográficas;
- required sources;
- search peer review;
- dupla seleção;
- adjudicação;
- dupla extração;
- consenso em discordâncias;
- dupla appraisal;
- análise reprodutível;
- statistical review;
- ROB-ME;
- dupla certainty;
- Summary of Findings;
- expert review;
- A3;
- invalidated dependency;
- append-preserving reviewer assignments;
- proibição de IA como reviewer humano;
- search exports;
- protocolo prospectivo.

# 6. Rebuild e regressões

O pipeline também validou:

- migration 015;
- rebuild from zero;
- regressões F2-B;
- S4;
- S5;
- N0;
- N1;
- N2;
- N3.

# 7. GitHub Actions

Run final mais recente da implementação:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37417796591**;
- conclusion **success**;
- commit validado `a255bf2a33b1cfba1214c7d9daaca234a7f6987e`.

Artifact:

- ID **11391167525**;
- nome `oes-s5-evidence-37417796591`;
- digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

# 8. Interpretação

O PASS demonstra que:

> **OES-P1 consegue representar uma Revisão de Evidências N4 formal sem duplicar o núcleo científico existente.**

A única nova tabela requerida nesta versão foi ReviewerAssignment.

Também foi demonstrado que:

> **A3 não contorna controles metodológicos de etapa.**

Se search peer review, dupla seleção, dupla extração, appraisal, certainty ou qualquer outro requisito material faltar, publication gate fecha mesmo que assurance permaneça A3.

# 9. Limite operacional real

O PASS é de **arquitetura/contrato sintético**.

Na configuração humana atual do OES:

- não existem dois revisores humanos qualificados;
- não existe search peer reviewer qualificado configurado;
- não existe expert independent reviewer configurado;
- acesso bibliográfico completo não é garantido.

Portanto:

> **não está autorizado iniciar Caso Real N4 formal.**

# 10. Decisão

> **Contrato técnico N4 = PASS.**

Próxima etapa:

> **contrato de renderização e template operacional da Revisão de Evidências N4.**

---

**Resultado final:** PASS técnico, com publicação real N4 ainda bloqueada pela configuração operacional humana/infrastrutural atual.
