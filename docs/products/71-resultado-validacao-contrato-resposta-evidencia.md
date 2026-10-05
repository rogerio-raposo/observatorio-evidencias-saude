# 71 — Resultado da Validação do Contrato da Resposta de Evidência — N1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Validação técnica concluída — PASS  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 68–70; migrations 002–012  
**Produto:** OES — Resposta de Evidência  
**Nível:** N1

---

# 1. Objetivo

Registrar o resultado da validação técnica do contrato de dados, publication gate e projeção inicial da **Resposta de Evidência — N1**.

A validação procurou demonstrar que o OES consegue representar uma resposta N1:

- focal;
- baseada em busca estruturada e seletiva;
- sustentada por fonte decisiva rastreável;
- sem obrigatoriedade artificial de Synthesis;
- sem obrigatoriedade artificial de nova CertaintyAssessment;
- com assurance A0–A3;
- com publication gate próprio;
- sem regressão da Ficha de Evidência N2.

---

# 2. Implementação validada

## Migration 012

Arquivo:

`database/012_evidence_response_contract.sql`

A migration implementa, por composição sobre o baseline existente:

- `product.assurance_level()`;
- wrapper compatível `product.evidence_sheet_assurance_level()`;
- `product.evidence_response_assurance_level()`;
- `product.product_reference_reports()`;
- `product.evidence_response_reference_reports()`;
- `product.evidence_response_publication_issues()`;
- `product.evidence_response_is_publishable()`;
- `product.evidence_response_view()`.

Nenhuma nova tabela ou coluna foi criada.

---

# 3. Fixture de validação

Arquivo:

`database/f3-evidence-response-fixtures.sql`

A fixture foi deliberadamente construída com:

- Investigation primary N1;
- uma busca estruturada;
- uma revisão sistemática sintética como fonte decisiva;
- provenance direta ProductVersion → ReportVersion;
- um resultado-chave representado em provenance;
- assurance A2;
- ausência de expert review;
- **nenhum Synthesis link**;
- **nenhum Certainty link**.

Objetivo:

> provar que N1 pode permanecer N1 sem ser artificialmente convertido em uma Ficha N2 reduzida.

---

# 4. Testes funcionais

Arquivo:

`database/f3-evidence-response-tests.sql`

Foram validados:

- **ER-T01** — fixture N1 = A2 e publishable;
- **ER-T02** — Synthesis/Certainty não são obrigatórios; warnings permanecem explícitos;
- **ER-T03** — provenance direta produz referência rastreável;
- **ER-T04** — EvidenceResponseView projeta fonte decisiva e resultado-chave;
- **ER-T05** — natureza seletiva/não exaustiva da busca permanece explícita;
- **ER-T06** — função genérica de assurance preserva compatibilidade com Evidence Sheet;
- **ER-T07** — ausência de owner approval reduz assurance e bloqueia publicação;
- **ER-T08** — roteamento diferente de N1 bloqueia publicação;
- **ER-T09** — expert rejection ativa bloqueia publicação;
- **ER-T10** — fonte upstream invalidada bloqueia publicação;
- **ER-T11** — ausência de busca estruturada concluída bloqueia publicação;
- **ER-T12** — ausência de fonte rastreável bloqueia publicação;
- **ER-T13** — audit expõe A2, publishable e warning de ausência de expert review.

Resultado:

> **ER-T01–T13 PASS**

---

# 5. Rebuild

Arquivo:

`database/f3-evidence-response-rebuild-check.sql`

O rebuild-from-zero validou:

- product type = `evidence_response`;
- depth = N1;
- assurance = A2;
- expert independent review = false;
- uma fonte-chave;
- um resultado-chave;
- publication gate = PASS.

Resultado:

> **ER-T14 PASS**

---

# 6. Regressões

O mesmo run confirmou PASS para:

- F2-B;
- S4;
- S5;
- Evidence Sheet contract;
- EvidenceSheetView;
- provenance-aware references;
- assurance gate;
- assurance view;
- template da Ficha;
- Caso Real 01;
- rebuild existente.

Conclusão:

> a introdução do contrato N1 não produziu regressão material detectável na trilha N2 já validada.

---

# 7. Evidência GitHub Actions

**Run:** 37356428107  
**Status:** completed  
**Conclusion:** success  
**Commit validado:** `a8f9042e41177b670c15c7f0782465e2b6c73bb4`

**Artifact:** 11364184531  
**Nome:** `oes-s5-evidence-37356428107`

---

# 8. Decisões confirmadas pela validação

1. N1 pode ser implementado sem nova tabela científica.
2. Synthesis não é requisito universal de Resposta de Evidência.
3. CertaintyAssessment não é requisito universal de Resposta de Evidência.
4. Provenance direta ProductVersion → ReportVersion é suficiente para o caso mínimo validado.
5. Resultados-chave podem ser projetados a partir de provenance direta quando não houver Result/Synthesis OES.
6. Assurance A0–A3 pode ser derivado por função genérica transversal.
7. Publication gate precisa permanecer específico por subtipo.
8. EvidenceResponseView deve ser uma projeção própria, não reutilização de EvidenceSheetView.
9. Ausência de expert review é compatível com A2 padrão N1, desde que explicitamente declarada.
10. A arquitetura OES-P1 continua suficiente para o produto N1 nesta etapa.

---

# 9. Limitações da validação

Esta validação utilizou fixture sintética e comprova coerência arquitetural/funcional.

Ainda não comprova, por si só:

- adequação do template final;
- qualidade comunicacional;
- comportamento com múltiplas fontes conflitantes;
- reuso de certainty externa real;
- integração com um caso real N1;
- adequação para uso clínico ou decisório específico.

Esses pontos deverão ser testados nas próximas etapas.

---

# 10. Próxima etapa

Formalizar o contrato de renderização:

> **EvidenceResponseView**

Somente depois:

1. criar template operacional N1;
2. criar apresentação/regras de renderização;
3. validar com caso real;
4. executar assurance e publication gate reais.

---

**Resultado final:** PASS.
