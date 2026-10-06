# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP37  
**Checkpoint anterior:** CP36  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação, arquitetura, contrato de dados e validação técnica da Revisão de Evidências — N4  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP37

> **Revisão de Evidências N4 — especificação científica e funcional consolidada**

> **Arquitetura inicial N4 — consolidada**

> **Contrato de dados N4 — implementado**

> **Migration 015 — PASS**

> **EvidenceReviewView `oes.evidence_review_view/0.1` — PASS**

> **Fixture formal sintética A3 + ER4-T01–T25 + rebuild — PASS**

> **Próximo estágio: contrato de renderização e template operacional N4**

## 2. Documentos consolidados

- 115 — Especificação Científica e Funcional da Revisão de Evidências — N4;
- 116 — Revisão de Coerência e Decisão Arquitetural Inicial;
- 117 — Contrato de Dados da Revisão de Evidências — N4;
- 118 — Resultado da Validação Técnica do Contrato — PASS.

## 3. Decisões científicas centrais

N4:

- é o nível de maior profundidade do OES;
- prioriza completude, independência e reprodutibilidade;
- não equivale obrigatoriamente a meta-análise;
- somente pode usar o subtipo `Revisão Sistemática` quando os requisitos correspondentes forem realmente cumpridos;
- exige protocolo prospectivo;
- exige Infrastructure Readiness Gate;
- exige cobertura bibliográfica defensável;
- exige controles humanos qualificados nas etapas críticas;
- exige A3 para publicação formal;
- não permite que A3 substitua stage controls;
- não permite que IA seja contada como segundo revisor humano.

## 4. Arquitetura

OES-P1 foi considerado adequado ao N4 sem duplicação do núcleo científico.

Nova tabela:

> `investigation.reviewer_assignment`

Função:

- designar ator humano;
- stage;
- role;
- qualificação;
- independência;
- escopo;
- conflitos;
- validade temporal.

Estruturas reutilizadas:

- Search/SearchHit;
- ScreeningDecision;
- MethodDecision;
- QualityControlRecord;
- Study/Report/Result;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- Artifact;
- Provenance;
- Assurance.

## 5. Extensão ROB-ME

A baseline 002 permitia RiskAssessment apenas sobre:

- Study;
- Result;
- Report.

N4 exige ROB-ME em nível de síntese.

Migration 015 estende:

`appraisal.assert_risk_target_type()`

para aceitar também:

> `Synthesis`

A extensão preserva todos os alvos anteriormente válidos.

## 6. EvidenceReviewView

Schema:

`oes.evidence_review_view/0.1`

Projeta:

- identity;
- question;
- investigation/subtype;
- infrastructure readiness;
- protocol/registration;
- amendments/deviations;
- reviewer assignments;
- method/quality controls;
- searches;
- search peer review;
- selection flow;
- excluded full text;
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

## 7. Fixture sintética N4

A fixture representa, exclusivamente para validação arquitetural:

- systematic_review_intervention;
- readiness=ready;
- protocolo prospectivo;
- três bases bibliográficas;
- search exports;
- search peer review sintético;
- dois screeners independentes;
- dupla extração;
- dupla appraisal;
- pairwise meta-analysis;
- code + dataset;
- statistical review;
- ROB-ME;
- dupla GRADE;
- SoF;
- AI methodological verification;
- owner approval;
- expert independent review sintético;
- assurance A3;
- publication gate aberto.

Todos os atores são fictícios/sintéticos.

## 8. Testes

ER4-T01–T25 validam, entre outros:

- caminho formal sintético A3;
- EvidenceReviewView;
- readiness obrigatório;
- pelo menos duas bases bibliográficas;
- required sources;
- search exports;
- search peer review;
- dupla seleção;
- adjudicação;
- dupla extração;
- consenso em divergência;
- dupla appraisal;
- reprodutibilidade da meta-analysis;
- statistical review;
- ROB-ME;
- dupla certainty;
- SoF;
- expert review/A3;
- invalidated dependency;
- append-preserving ReviewerAssignment;
- IA impedida de impersonar reviewer humano;
- protocolo prospectivo.

## 9. Validação CI

GitHub Actions final:

- run **37417796591**;
- workflow **OES PoC-S5 PostgreSQL Validation**;
- conclusion **success**;
- commit validado `a255bf2a33b1cfba1214c7d9daaca234a7f6987e`.

Artifact:

- ID **11391167525**;
- nome `oes-s5-evidence-37417796591`;
- digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

Regressões:

- F2-B PASS;
- S4 PASS;
- S5 PASS;
- N0 PASS;
- N1 PASS;
- N2 PASS;
- N3 PASS;
- rebuild through migration 015 PASS.

## 10. Limite operacional real

O PASS N4 é:

> **técnico/arquitetural/sintético**

Não existe autorização para Caso Real N4 formal porque a configuração atual não dispõe de:

- dois revisores humanos qualificados;
- search peer reviewer qualificado real;
- expert independent reviewer real;
- garantia de acesso completo às bases necessárias.

Consequência:

> **não iniciar Caso Real N4 formal.**

É permitido continuar:

- renderização;
- template;
- gate visual;
- validação sintética;
- documentação;
- arquitetura de manutenção.

## 11. Estado da Fase 3

Produtos exercitados:

1. N0 — Evidence Scan: caso real A1 interno;
2. N1 — Resposta de Evidência: caso real A2 published;
3. N2 — Ficha de Evidência: caso real A2 published;
4. N3 — Síntese Rápida: contrato/template validados; caso real experimental corretamente bloqueado em A0;
5. N4 — Revisão de Evidências: especificação/contrato técnico validados com fixture formal sintética A3; nenhum caso real formal autorizado.

Taxonomia restante:

- Mapa de Evidências;
- Overview de Revisões;
- Monitor de Evidências;
- Alerta de Evidência.

## 12. Ponto exato de retomada

> **Fase 3 — criar o contrato de renderização da EvidenceReviewView e o template operacional da Revisão de Evidências N4.**

Sequência recomendada:

1. contrato de renderização;
2. presentation map;
3. template Markdown;
4. renderer;
5. validator;
6. fixture rendering A3 sintética;
7. estados bloqueados/experimentais;
8. resultado da validação do template;
9. checkpoint antes de avançar para o próximo produto.

**Fim do CP37**
