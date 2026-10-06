# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP40  
**Checkpoint anterior:** CP39  
**Status:** artefato de continuidade; não normativo  
**Escopo:** consolidação metodológica e arquitetural inicial do Mapa de Evidências após os Documentos 123–125  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP39 criado no commit `2ea0b53455bfc7bd10ce78a223436e19b04b4437`.

Estado da branch `main` antes da criação deste checkpoint:

- HEAD: `284f08c710847891785e740b9a1edb2fa6cc1143`;
- status relativo ao commit do CP39: `ahead`;
- commits à frente: **7**;
- commits atrás: **0**.

Arquivos materialmente alterados após CP39:

- `docs/products/123-especificacao-mapa-evidencias.md`;
- `docs/products/124-mapa-evidencias-revisao-coerencia-arquitetura.md`;
- `docs/products/125-contrato-dados-mapa-evidencias.md`;
- `STATE.md`;
- `CHANGELOG.md`;
- `docs/products/README.md`;
- `archive/handoffs/oes/README.md`.

Diagnóstico:

> **Existe avanço material pós-CP39, coerente e persistido. Não houve deriva de branch nem perda do trabalho. O ponto de retomada do CP39 foi superado pelos Documentos 123–125.**

## 2. Marco do CP40

> **A especificação científica, a decisão arquitetural inicial e o contrato de dados v0.1 do Mapa de Evidências estão consolidados.**

> **A implementação técnica do contrato ainda não foi iniciada.**

> **Nenhum template do Mapa de Evidências deve ser criado antes do PASS técnico do contrato.**

## 3. Base documental consolidada

- Documento 123 — Especificação Científica e Funcional do Mapa de Evidências;
- Documento 124 — Mapa de Evidências: Revisão de Coerência e Decisão Arquitetural Inicial;
- Documento 125 — Contrato de Dados do Mapa de Evidências.

## 4. Decisões metodológicas consolidadas

O Mapa de Evidências:

- é produto analítico transversal e não recebe automaticamente um nível N0–N4;
- deve declarar explicitamente subtipo, força da alegação de cobertura e modo de alegação de gap;
- não converte densidade de estudos em magnitude de efeito, certeza ou recomendação;
- trata gaps como afirmações operacionais dependentes de escopo, fontes e data de corte;
- distingue mapas exploratórios/structured non-exhaustive de systematic maps/EGMs formais;
- exige framework/codebook versionado;
- preserva drill-down e provenance até as unidades que originam contagens;
- não trata interatividade ou visualização como substitutos de método.

## 5. Decisão arquitetural consolidada

OES-P1 permanece como núcleo científico.

Adicionar camada especializada e versionada no schema lógico `mapping`, com sete estruturas:

1. `mapping.framework`;
2. `mapping.framework_version`;
3. `mapping.dimension`;
4. `mapping.category`;
5. `mapping.map_item`;
6. `mapping.assignment`;
7. `mapping.cell_scope`.

Princípios:

- `MapItem` referencia versões de entidades científicas já existentes;
- Search, Screening, Study, Report, Result, Synthesis, RiskAssessment, CertaintyAssessment, Artifact, ReviewerAssignment e QualityControlRecord são reutilizados;
- dimensões/categorias são imutáveis dentro de uma FrameworkVersion;
- mudança material do framework exige nova FrameworkVersion;
- células, contagens, concentrações e gaps são **derivados**, não novas fontes primárias;
- não criar tabela `Gap`, `Concentration`, `CellCount` ou duplicações de entidades científicas.

## 6. Contrato de dados v0.1

O Documento 125 autoriza a implementação de:

> `database/016_evidence_map_contract.sql`

Escopo técnico previsto:

- schema `mapping`;
- sete tabelas especializadas;
- guards/triggers/indexes;
- validação de tipos de MapItem;
- regras de classificação e verificação;
- helpers para células/contagens/gaps;
- publication gate;
- `EvidenceMapView` no schema `oes.evidence_map_view/0.1`.

## 7. Semântica crítica do contrato

### 7.1 Coverage e gaps

- `coverage_claim`: `exploratory`, `structured_non_exhaustive`, `systematic_comprehensive`;
- `gap_claim_mode`: `none`, `apparent_only`, `formal_within_scope`;
- formal gap só é admissível dentro de célula explicitamente `in_scope` e `gap_eligible`;
- célula vazia fora de escopo ou `not_applicable` não gera gap;
- mapas não sistemáticos não podem publicar formal gap claims.

### 7.2 Contagem

- a unidade de contagem é explicitamente definida pelo framework;
- Reports múltiplos do mesmo Study não podem inflar `study_count`;
- cada contagem deve reconciliar com seus MapItems de origem.

### 7.3 Classificação

- assignments preservam método e estado de verificação;
- classificação assistida por IA é permitida quando declarada;
- IA não pode converter classificação em `human_verified`;
- controles independentes/consenso devem ser exigidos quando configurados pelo protocolo.

### 7.4 Assurance

- mapa exploratório/structured non-exhaustive pode operar em A1/A2 conforme finalidade;
- `systematic_comprehensive + formal_within_scope` tem A3 como requisito candidato formalizado no contrato, além dos controles humanos qualificados;
- Assurance não substitui search, screening, coding ou revisão especializada.

## 8. Fixture formal e testes previstos

A primeira implementação deverá incluir fixture sintética formal demonstrando, no mínimo:

- `evidence_gap_map`;
- `systematic_comprehensive`;
- `formal_within_scope`;
- duas dimensões primárias;
- um filtro adicional;
- hierarquia simples;
- dois Studies;
- uma Synthesis;
- uma célula populada;
- uma célula vazia `in_scope` que gera gap formal;
- uma célula `not_applicable` vazia que não gera gap;
- codebook;
- search/screening;
- controles de classificação;
- consenso de classificações humanas sintéticas;
- A3 sintético;
- drill-down reconciliável.

Os testes mínimos devem cobrir os 22 comportamentos definidos no Documento 125, incluindo regressões N0–N4 e rebuild.

## 9. Estado técnico no CP40

Ainda **não existem**, no estado consolidado por este checkpoint:

- `database/016_evidence_map_contract.sql`;
- fixture formal sintética do Mapa;
- suíte de testes do contrato do Mapa;
- rebuild atualizado através da migration 016;
- integração S5 específica do Mapa;
- PASS técnico do contrato;
- contrato de renderização/template do Mapa.

Portanto:

> **não iniciar template, presentation map ou renderer antes do PASS técnico da implementação do contrato.**

## 10. Estado da Fase 3

Trilhas já exercitadas:

1. N0 — Evidence Scan: concluído inicialmente, caso real A1 interno;
2. N1 — Resposta de Evidência: concluída inicialmente, caso real A2/published;
3. N2 — Ficha de Evidência: concluída inicialmente, caso real A2/published;
4. N3 — contrato/template validados; caso real experimental bloqueado em A0;
5. N4 — contrato/template validados; Caso Real formal deferido por Infrastructure Readiness Gate = NOT_READY;
6. Mapa de Evidências — especificação, decisão arquitetural e contrato de dados v0.1 concluídos; implementação técnica pendente.

Produtos seguintes após o Mapa:

- Overview de Revisões;
- Monitor de Evidências;
- Alerta de Evidência.

## 11. Ponto exato de retomada

> **Implementar `database/016_evidence_map_contract.sql`, fixture formal sintética, testes adversariais e rebuild; integrar ao S5.**

Sequência obrigatória:

1. migration 016;
2. fixture formal sintética;
3. testes do contrato, incluindo cenários adversariais;
4. rebuild completo e regressões N0–N4;
5. integração/validação S5;
6. obter **PASS técnico**;
7. somente após o PASS, criar contrato de renderização/template do Mapa de Evidências.

## 12. Restrições de continuidade

Não:

- reabrir ou refazer os Documentos 123–125 sem evidência de erro material;
- criar template antes do PASS técnico;
- persistir gap/concentration/cell count como nova verdade primária;
- reduzir requisitos de coverage/classification para obter artificialmente um mapa formal;
- tratar fixture sintética como evidência real;
- abrir Caso Real do Mapa antes da conclusão e validação do contrato técnico.

**Fim do CP40**
