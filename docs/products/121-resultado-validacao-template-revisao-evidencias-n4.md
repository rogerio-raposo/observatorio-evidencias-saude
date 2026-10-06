# 121 — Revisão de Evidências N4: Resultado da Validação do Template e Renderização

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Revisão de Evidências — N4  
**Data:** 6 de outubro de 2026  
**Status:** validação de apresentação = **PASS**  
**Escopo:** EvidenceReviewView, template Markdown, presentation map, renderer, validator e cenário adversarial de gate

---

# 1. Objetivo

Registrar a validação da camada de apresentação da Revisão de Evidências N4 após o PASS técnico do contrato de dados.

# 2. Artefatos validados

- Documento 119 — contrato de renderização da EvidenceReviewView;
- Documento 120 — especificação do template operacional;
- `templates/evidence-review.md`;
- `templates/evidence-review-presentation-map.json`;
- `scripts/render_evidence_review_reference.py`;
- `scripts/validate_evidence_review_render.py`;
- `oes.evidence_review_view/0.1`.

# 3. Regras de apresentação confirmadas

O renderer:

- reutiliza o engine neutro OES;
- não consulta o banco;
- não altera o payload;
- não cria julgamento científico;
- não cria qualification;
- não cria assurance;
- não transforma A3 em autorização automática de publicação.

# 4. Disclosure da fixture sintética

A EvidenceReviewView passou a expor:

> `audit.synthetic_fixture=true`

para a fixture formal de arquitetura.

O template exige o banner:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA REVISÃO HUMANA REAL**

e declara que reviewers, expert review e A3 são sintéticos e servem apenas à validação do contrato N4.

# 5. Conteúdo projetado pelo template

A renderização validada inclui:

- identidade e versionamento;
- pergunta e objetivo;
- conclusão;
- certainty;
- Summary of Findings;
- aplicabilidade;
- limitações;
- Infrastructure Readiness Gate;
- protocolo e registro;
- emendas/desvios;
- buscas;
- peer review da estratégia;
- fluxo de seleção;
- exclusões full text;
- estudos contribuidores;
- extração independente e controles;
- risk of bias;
- missing evidence/ROB-ME;
- Results;
- Synthesis;
- heterogeneidade;
- sensitivity analyses;
- ReviewerAssignments;
- QualityControlRecords;
- reprodutibilidade;
- referências;
- assurance;
- publication issues;
- identificadores técnicos.

# 6. Correção detectada durante a validação

A primeira execução do template falhou porque `missing_evidence` não projetava `outcome_entity_uuid`, embora o contrato de apresentação o utilizasse.

Correção:

> `EvidenceReviewView` passou a projetar `outcome_entity_uuid` no bloco de ROB-ME/missing evidence.

Commit SQL validado:

`4bd35271e94dfb05bf572fe76b49fa5c5af47bac`.

# 7. Cenário formal sintético

O validator confirmou simultaneamente:

- depth N4;
- subtype `systematic_review_intervention`;
- readiness `ready`;
- assurance A3;
- `publishable=true`;
- qualified stage controls satisfeitos;
- expert independent review sintético presente;
- três buscas;
- search peer review;
- 12 ReviewerAssignments;
- dois Studies;
- dois RiskAssessments de estudo;
- um ROB-ME;
- dois Results;
- uma meta-analysis;
- heterogeneidade;
- sensitivity analyses;
- uma CertaintyAssessment;
- um SoF;
- referências rastreáveis;
- disclosure sintético visível.

# 8. Cenário adversarial de apresentação

O validator cria uma cópia apenas em memória com:

- assurance mantida em A3;
- `publishable=false`;
- stage controls marcados como não satisfeitos;
- publication issue sintética `MISSING_SEARCH_PEER_REVIEW`.

O render deve então mostrar:

> **GATE DE PUBLICAÇÃO N4 NÃO APROVADO**

mantendo A3 visível e exibindo:

> **A3, quando presente, não substitui stage controls nem abre o gate N4 automaticamente.**

Também deve remover qualquer mensagem de gate aprovado.

Resultado:

> **PASS**

# 9. Evidência de execução

GitHub Actions:

- run **37418624629**;
- attempt 1;
- conclusion **success**;
- commit validado `4bd35271e94dfb05bf572fe76b49fa5c5af47bac`.

Artifact:

- ID **11391724857**;
- nome `oes-s5-evidence-37418624629`;
- digest `sha256:a2d0c3dc12758a14fc13a2ac4ca50a3868ac9ceeac615ec34c6b417ee37b44ba`.

# 10. Logs confirmados

- `ER4-T01–T25 PASS`;
- `F3-ER4-TEMPLATE validation PASS`;
- `F3-ER4-TEMPLATE PASS`;
- `ER4-T26 PASS`;
- `ER4-T27 PASS`;
- `Rebuild through migration 015 PASS`;
- regressões N0–N3/F2-B/S4/S5 PASS.

# 11. Limite do PASS

Este resultado valida:

> **a camada técnica de apresentação N4 com fixture sintética.**

Não valida:

- reviewer humano real;
- search peer review real;
- expert independent review real;
- A3 real;
- Caso Real N4 publicável.

# 12. Decisão

> **Template/renderização N4 v0.1 = PASS.**

A trilha técnica inicial N4 — especificação, arquitetura, contrato, gate, view e apresentação — está fechada.

# 13. Próxima etapa

> **Antes de qualquer Caso Real N4, executar obrigatoriamente o Infrastructure Readiness Gate.**

Na configuração atual do OES, o resultado esperado é `not_ready` enquanto não existirem equipe humana qualificada e infraestrutura bibliográfica suficientes.

Esse resultado negativo deve ser tratado como comportamento metodologicamente correto, e não contornado por redução silenciosa do método.

---

**Resultado final:** PASS de template/renderização N4; nenhum Caso Real N4 formal autorizado.