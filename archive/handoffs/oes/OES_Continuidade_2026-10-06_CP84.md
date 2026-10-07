# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP84  
**Checkpoint anterior:** CP83  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Contrato de Dados v0.1 do Alerta de Evidência

## 1. Marco

> **EVIDENCE_ALERT_DATA_CONTRACT = READY**

Documento:

`docs/products/179-contrato-dados-alerta-evidencia.md`

## 2. Migration autorizada

> `database/024_evidence_alert_contract.sql`

Escopo:

- `maintenance.evidence_alert`;
- `maintenance.alert_source`;
- `maintenance.alert_affected_dimension`;
- guards de integridade/versionamento;
- publication issues;
- publishability helper;
- fixture/test support.

## 3. Decisões preservadas

- Alert = Product/ProductVersion;
- nenhuma Investigation nova;
- um source_context InvestigationLink;
- target ProductVersion xor InvestigationVersion;
- source 1:N com exatamente uma primary antes de publicação;
- affected dimensions 1:N;
- classification e urgency não são calculadas;
- lifecycle material é versionado;
- Alert não possui scientific conclusion nem Product currency próprios;
- publicação formal exige human verification + A2;
- A3 não é presumido;
- critical não aciona regra automática;
- EvidenceAlertView somente após Projection Readiness explícito.

## 4. Próxima etapa

> **Implementar migration 024 + fixtures + AL-T01–T30 + regressões/rebuild.**

## 5. Limite

> **Fase 4 não iniciada. Não definir thresholds, SLA, auto-escalation ou M3 transversal.**

**Fim do CP84**
