# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP81  
**Checkpoint anterior:** CP80  
**Status:** artefato de continuidade; não normativo  
**Escopo:** validação da EvidenceMonitorView 0.1

## 1. Marco

> **EVIDENCE_MONITOR_VIEW_0_1 = PASS.**

Documento:

`docs/products/173-monitor-resultado-evidencemonitorview.md`

## 2. Implementação

Migration:

`database/023_evidence_monitor_view_rendering_readiness.sql`

Funções:

- `product.evidence_monitor_target_projection(...)`;
- `maintenance.monitor_cycle_projection(...)`;
- `product.evidence_monitor_view(...)`.

Schema de projeção:

> `oes.evidence_monitor_view/0.1`

As funções são read-only/STABLE e não alteram estado persistido.

## 3. Semântica preservada

A View mantém explicitamente separados:

1. editorial status do Monitor;
2. operational status do Monitor;
3. currentness do Monitor Product;
4. currentness científico do target.

Também preserva:

- baseline cutoff × latest completed cycle cutoff;
- target ProductVersion × InvestigationVersion;
- Monitor assurance × target assurance;
- Search/SearchHit canônicos;
- source requirement `fulfilled` × `exception_applied`;
- múltiplos CandidateImpacts;
- EvidenceEvent × CandidateAssessment;
- histórico Cycle→CurrencyState;
- AI verification sem fabricação de human verification;
- blockers formais M3/Fase 4.

## 4. Testes

Arquivo:

`database/f3-evidence-monitor-view-tests.sql`

Resultados:

- MONV-T01–T17 = PASS;
- MONV-T18 migration 023 idempotent re-apply = PASS;
- MONV-T19 rebuild-through-023 = PASS.

As suítes anteriores permanecem verdes:

- MON-T01–T32;
- MONH-T01–T22;
- MON-T33;
- MONH-T23.

## 5. Evidência CI

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

- **37556593132**;
- run number **128**;
- HEAD validado `613a9ced4ad43a3eb890a2b5db35acf51a08127e`;
- conclusão **success**.

Artifact:

- id **11454488440**;
- name `oes-s5-evidence-37556593132`;
- digest `sha256:6043e52ac33800ec5d944b1a4633bfe5049a9c8ecff2613eb577aadea2916630`.

Após o run foram persistidos somente:

- Documento 173;
- atualização de `STATE.md`;
- atualização de `CHANGELOG.md`.

Nenhum desses commits altera a implementação validada.

## 6. Readiness atual

- scientific/functional = PASS;
- architecture = PASS;
- data contract = PASS;
- migration 021 = PASS;
- projection hardening 022 = PASS;
- Projection Readiness = READY;
- migration/View 023 = PASS;
- template/presentation = **NOT_YET_SPECIFIED**;
- Caso Real do Monitor = NOT_AUTHORIZED;
- Alert = NOT_IMPLEMENTED;
- Fase 4 = NOT_STARTED.

## 7. Próxima etapa

> **Definir o contrato de renderização e a Especificação do Template Operacional do Monitor de Evidências.**

A camada de apresentação deverá:

- consumir somente `EvidenceMonitorView`;
- não consultar tabelas diretamente;
- preservar Monitor × target × currentness × cycles × assurance;
- distinguir source fulfillment de exception;
- mostrar blockers/warnings sem reinterpretá-los;
- não criar Alert;
- não iniciar Fase 4.

Somente após a especificação:

> implementar template + presentation map + renderer + validator e integrar ao S5.

## 8. Limites

Ainda não:

- abrir Caso Real do Monitor;
- criar Alert de Evidência;
- definir cadências/thresholds transversais;
- tornar M3 formalmente publicável;
- iniciar Fase 4.

## 9. Protocolo anti-interrupção

Na retomada:

1. executar Freshness Gate;
2. ler Documentos 165–173 conforme necessário;
3. conferir migration 023 e run 37556593132;
4. especificar primeiro o contrato de renderização/template;
5. não implementar apresentação antes da especificação;
6. manter template totalmente derivado da View.

**Fim do CP81**
