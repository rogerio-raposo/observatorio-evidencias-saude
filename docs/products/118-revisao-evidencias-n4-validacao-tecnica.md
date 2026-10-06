# 118 — Revisão de Evidências N4: Resultado da Validação Técnica do Contrato

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status:** validação técnica do contrato = **PASS**  
**Escopo:** migration 015, fixture formal sintética, gate, EvidenceReviewView, testes adversariais, idempotência e rebuild

---

# 1. Objetivo

Registrar o fechamento técnico do contrato N4 antes da criação de template/renderização e antes de qualquer Caso Real N4.

# 2. Componentes validados

- Documento 115 — especificação científica e funcional;
- Documento 116 — revisão de coerência e decisão arquitetural;
- Documento 117 — contrato de dados;
- `database/015_evidence_review_contract.sql`;
- `investigation.reviewer_assignment` append-preserving;
- extensão do guard de RiskAssessment para alvo `Synthesis`, necessária ao ROB-ME;
- fixture formal sintética N4;
- `EvidenceReviewView`;
- publication gate N4;
- testes ER4-T01–T25;
- rebuild ER4-T26;
- duplicate-migration detection ER4-T27;
- regressões N0–N3/F2-B/S4/S5.

# 3. Decisão arquitetural confirmada

O N4 não exigiu novo modelo científico paralelo.

OES-P1 reutiliza:

- Search/Screening;
- Study/Report/Result;
- RiskAssessment;
- Synthesis;
- Certainty;
- Artifact;
- Provenance;
- Assurance.

Nova estrutura DDL:

> **`investigation.reviewer_assignment`**

Finalidade:

> declarar papéis humanos qualificados, independência, escopo e conflitos de forma verificável pelo gate.

# 4. ROB-ME

Durante a validação, o guard herdado de F2 permitia RiskAssessment apenas para `Study`, `Result` e `Report`.

O N4 exige appraisal de missing evidence em nível de síntese.

Correção:

> `appraisal.assert_risk_target_type()` foi estendida na migration 015 para aceitar também `Synthesis`.

Os tipos anteriores foram preservados.

Essa correção foi refletida nos Documentos 116 e 117.

# 5. Fixture formal sintética

A fixture representa deliberadamente um cenário ideal e **não corresponde a revisores reais do projeto**.

Ela contém:

- subtype `systematic_review_intervention`;
- readiness = ready;
- protocolo prospectivo;
- três bases bibliográficas sintéticas;
- exports rastreáveis;
- peer review de busca sintético;
- dois screeners independentes;
- dupla extração crítica;
- dupla avaliação de risco de viés;
- meta-analysis pairwise sintética;
- code + dataset artifacts;
- statistical review;
- ROB-ME;
- dupla avaliação GRADE;
- Summary of Findings;
- AI methodological verification;
- owner approval;
- expert independent review;
- assurance derivada A3;
- publication gate aberto.

Todos os atores humanos da fixture são fictícios e existem apenas para validação do contrato.

# 6. Testes positivos e adversariais

ER4-T01–T25 demonstraram:

- A3 + controles de etapa completos → publishable;
- `EvidenceReviewView` completo;
- warnings não bloqueiam;
- readiness `not_ready` bloqueia mesmo com A3;
- uma única base bibliográfica bloqueia;
- fonte declarada obrigatória precisa ser executada;
- A3 não bypassa search peer review;
- dupla triagem title/abstract é exigida;
- dupla triagem full-text é exigida;
- discordância de screening exige adjudicação;
- dupla extração crítica é exigida;
- divergência de extração exige consenso;
- dupla appraisal é exigida;
- divergência de appraisal exige consenso;
- meta-analysis exige code/dataset;
- statistical review qualificada é exigida;
- ROB-ME é exigido no contrato sintético de meta-analysis;
- dupla certainty é exigida;
- divergência de certainty exige consenso;
- SoF é exigido;
- expert independent review + A3 são exigidos;
- dependency invalidada bloqueia;
- ReviewerAssignment é imutável/append-preserving;
- IA não pode receber assignment humano;
- search export é exigido;
- protocolo deve preceder a busca definitiva.

# 7. Rebuild e idempotência

Confirmados:

- **ER4-T26 PASS** — rebuild preserva o estado formal sintético A3 N4;
- **ER4-T27 PASS** — reaplicação duplicada da migration 015 é detectada;
- **Rebuild through migration 015 PASS**.

# 8. Evidência de execução

GitHub Actions:

- run **37417796591**;
- attempt 1;
- conclusion **success**;
- commit validado `a255bf2a33b1cfba1214c7d9daaca234a7f6987e`.

Artifact:

- ID **11391167525**;
- nome `oes-s5-evidence-37417796591`;
- digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

Commits posteriores `feff8e2f...` e `94346cf7...` alteraram apenas os Documentos 116/117 para alinhar a documentação do ROB-ME; não modificaram SQL.

# 9. Regressões

O mesmo run confirmou:

- F2-B PASS;
- S4 PASS;
- S5-T01–T17 PASS;
- N0 contract/view PASS;
- N1 contract/view PASS;
- N2 contract/view PASS;
- N3 contract/view PASS;
- Caso Real N3 e histórico REVISE preservados;
- assurance A0–A3 governance PASS;
- rebuild global PASS.

# 10. Limite da validação

Este PASS demonstra:

> **o contrato técnico N4 consegue representar e bloquear corretamente os requisitos de uma revisão formal quando todos os controles existem.**

Não demonstra:

- disponibilidade real da equipe humana;
- disponibilidade real de duas ou mais bases adequadas;
- search peer review real;
- dupla seleção/extraction/appraisal/certainty real;
- expert independent review real;
- Caso Real N4 publicável.

Na configuração humana atual do OES, um Caso Real N4 formal deverá falhar o readiness gate.

# 11. Decisão

> **Contrato N4 v0.1 tecnicamente validado — PASS.**

Migration 015 e `EvidenceReviewView` estão aptos a servir de base para a camada de apresentação.

# 12. Próxima etapa

> **Criar o contrato de apresentação/template da Revisão de Evidências N4 e validar renderização sintética.**

Somente depois:

> **avaliar um Caso Real N4 experimental, iniciando obrigatoriamente pelo Infrastructure Readiness Gate.**

---

**Resultado:** PASS técnico N4; pronto para template/renderização, não para publicação real.