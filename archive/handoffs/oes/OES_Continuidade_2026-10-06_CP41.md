# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP41  
**Checkpoint anterior:** CP40  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento técnico do contrato v0.1 do Mapa de Evidências  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP40 criado no commit `1050ca8032b878a661441ac2e59df60c54d97d3e`.

Estado da branch `main` imediatamente antes da criação deste checkpoint:

- status relativo ao commit do CP40: `ahead`;
- commits à frente: **13**;
- commits atrás: **0**.

Avanço material pós-CP40:

- migration 016 do Mapa de Evidências;
- fixture formal sintética;
- testes positivos/adversariais;
- rebuild check;
- integração ao workflow S5;
- execução de CI com PASS;
- Documento 126;
- atualização de STATE, CHANGELOG e índice de produtos.

Diagnóstico:

> **o ponto de retomada do CP40 foi integralmente executado e validado. Não há divergência de branch nem trabalho técnico do contrato pendente.**

## 2. Marco do CP41

> **Contrato técnico do Mapa de Evidências v0.1 = PASS.**

Validação canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37464023391**;
- conclusion **success**;
- commit validado `9403f1a36bbcc2c486afa393146b528f72b7a08f`;
- artifact **11413512318**;
- digest `sha256:a531328905b4dba42fc249c92eaa8f2331e975ed9dfa418779e7523ae45f8d3a`.

## 3. Documento de fechamento técnico

Criado:

- Documento 126 — Resultado da Validação Técnica do Contrato do Mapa de Evidências.

Documentos vigentes da trilha:

- 123 — Especificação Científica e Funcional;
- 124 — Revisão de Coerência e Decisão Arquitetural Inicial;
- 125 — Contrato de Dados v0.1;
- 126 — Resultado da Validação Técnica: PASS.

## 4. Implementação validada

Arquivos:

- `database/016_evidence_map_contract.sql`;
- `database/f3-evidence-map-fixtures.sql`;
- `database/f3-evidence-map-tests-a.sql`;
- `database/f3-evidence-map-tests-b.sql`;
- `database/f3-evidence-map-rebuild-check.sql`.

Integração:

- `.github/workflows/validate-s5.yml`.

Schema especializado:

- `mapping`.

Estruturas:

1. `mapping.framework`;
2. `mapping.framework_version`;
3. `mapping.dimension`;
4. `mapping.category`;
5. `mapping.map_item`;
6. `mapping.assignment`;
7. `mapping.cell_scope`.

Funções principais:

- `mapping.evidence_map_cells()`;
- `product.evidence_map_publication_issues()`;
- `product.evidence_map_is_publishable()`;
- `product.evidence_map_view()`.

Schema da projeção:

- `oes.evidence_map_view/0.1`.

## 5. Resultados técnicos

Foram validados:

- EM-T01–T21 no contrato específico;
- EM-T22 por regressão integrada N0–N4;
- duplicate detection da migration 016;
- rebuild completo através da migration 016;
- ausência de regressões F2-B/S4/S5/N0/N1/N2/N3/N4.

Semânticas críticas demonstradas:

- células e gaps são derivados;
- Report não infla contagem por Study;
- formal gap depende de coverage sistemático + CellScope;
- not_applicable não gera gap;
- cross-framework classification é rejeitada;
- IA não pode produzir `human_verified`;
- dupla codificação e consenso são exigíveis;
- A3 não contorna search/screening/classification controls;
- Framework children são imutáveis dentro da mesma FrameworkVersion.

## 6. Fixture formal sintética

A fixture demonstra um:

- `evidence_gap_map`;
- `systematic_comprehensive`;
- `formal_within_scope`;
- counting unit = `study`;
- 2 Studies;
- 1 Report;
- 1 Synthesis;
- 2 células populadas;
- 1 célula vazia in-scope com gap formal;
- 1 célula not_applicable sem gap;
- dupla codificação humana sintética;
- consenso sintético;
- search peer review sintético;
- secondary screening sintético;
- classification QC sintético;
- A3 sintético.

Todos os atores humanos são fictícios e servem exclusivamente à validação do contrato.

## 7. Limites do PASS

O PASS não demonstra:

- adequação de corpus real;
- search coverage real `systematic_comprehensive`;
- classificação humana real;
- formal gap claim real;
- Caso Real do Mapa;
- template/renderização final.

Portanto:

> **nenhuma alegação real de gap está autorizada pelo CP41.**

## 8. Regra de apresentação

A restrição do CP40 foi cumprida:

> **nenhum template do Mapa foi criado antes do PASS técnico.**

Com o PASS técnico obtido, fica autorizada a próxima etapa:

> **contrato de renderização do EvidenceMapView.**

A autorização não significa criar imediatamente um template sem antes definir esse contrato.

## 9. Próxima sequência

1. Documento 127 — contrato de renderização do EvidenceMapView;
2. especificação do template operacional;
3. template Markdown/presentation map/renderer/validator;
4. testes adversariais de apresentação;
5. validação final da camada de apresentação;
6. readiness para eventual Caso Real do Mapa.

## 10. Ponto exato de retomada

> **Criar o Documento 127 — Contrato de Renderização do EvidenceMapView, usando `oes.evidence_map_view/0.1` como fonte canônica e preservando coverage, counting unit, CellScope, gaps, concentrações, assurance e provenance.**

## 11. Restrições de continuidade

Não:

- reabrir migration 016 ou Documentos 123–126 sem evidência de erro material;
- persistir contagens/gaps derivados como nova verdade primária;
- transformar empty cell em formal gap sem CellScope e coverage compatíveis;
- ocultar no template a natureza exploratória/aparente quando aplicável;
- apresentar fixture sintética como evidência real;
- iniciar Caso Real do Mapa apenas porque o contrato técnico passou.

**Fim do CP41**
