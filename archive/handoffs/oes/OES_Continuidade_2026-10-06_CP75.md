# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP75  
**Checkpoint anterior:** CP74  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Contrato de Dados v0.1 do Monitor de Evidências

## 1. Marco

> **MONITOR DE EVIDÊNCIAS — DATA_CONTRACT_V0_1_READY_FOR_IMPLEMENTATION.**

Documento:

`docs/products/167-contrato-dados-monitor-evidencias.md`

## 2. Contrato consolidado

Product:

- `product_type='evidence_monitor'`.

Investigation:

- `investigation_type='evidence_monitoring'`;
- depth N herdada do alvo;
- maintenance M2/M3;
- Search própria da Investigation do Monitor.

Schema especializado:

> `maintenance`

Estruturas:

1. `monitor_definition`;
2. `monitor_target`;
3. `monitor_state`;
4. `monitor_cycle`;
5. `cycle_search`;
6. `evidence_event`;
7. `candidate_assessment`;
8. `cycle_currency_state`.

## 3. Reutilização obrigatória

Continuam canônicos:

- `investigation.search`;
- `investigation.search_hit`;
- deduplicação;
- ScreeningDecision quando aplicável;
- MethodDecision/QualityControlRecord;
- `product.currency_state`;
- `product.version_change_class`;
- `product.assurance_record`;
- ReportRelation;
- provenance/dependency.

## 4. Decisões críticas

- Monitor cutoff = cutoff basal do alvo naquela Monitor ProductVersion;
- cycles armazenam janelas/cutoffs posteriores;
- ciclo rotineiro não cria nova ProductVersion;
- target update exige nova Monitor ProductVersion para seguir nova versão;
- Monitor Product currency e target currency permanecem distintos;
- Monitor M2 formal v0.1 exige mínimo A2;
- M3 é representável, porém formalmente bloqueado até a Fase 4;
- Monitor não sobrescreve conclusão científica do target;
- Alert ainda não é implementado.

## 5. Migration autorizada

> `database/021_evidence_monitor_contract.sql`

Escopo:

- schema maintenance;
- oito estruturas;
- constraints/indexes/guards;
- helpers de cycle/source/currentness;
- publication issues/gate do Monitor;
- sem implementação completa do EvidenceMonitorView nesta etapa.

## 6. Próxima etapa

> **Implementar migration 021 + fixture sintética M2/M3 + testes de contrato + regressões/rebuild.**

Após PASS técnico:

> **avaliar Projection Readiness da EvidenceMonitorView.**

**Fim do CP75**
