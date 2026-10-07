# 41A — Anexo A ao Contrato Físico de Calibração Temporal

**Integra:** Documento 41  
**Data:** 7 de outubro de 2026  
**Status:** **INTEGRAL_TO_DOCUMENT_41 — READY_FOR_RECHECK**

## 1. Target e ordem temporal

Dossier target em `approved_for_normative_activation` exige, no momento da decisão:

- exact target `core.entity_version.version_status='current'`;
- ProductVersion não evidence_monitor/evidence_alert;
- InvestigationVersion não evidence_monitoring.

CadenceContract/SLARule novos não nascem para target já não corrente.

SLARule v0.1 exige `rule.effective_at >= update_policy.effective_at` e `rule.effective_at >= dossier.decided_at`.

CadenceContract exige `effective_at >= dossier.decided_at` e, quando vinculado, `policy.effective_at = contract.effective_at`.

## 2. CadenceObservation causal

Para `outcome='satisfied'`, `observed_at` é derivado do locator:

- MonitorCycle completed → `completed_at`;
- Search → `investigation.search.executed_at`;
- EvidenceEvent → `detected_at`, somente event-driven;
- UpdateSignal → `detected_at`, somente event-driven;
- Artifact → `artifact_type='cadence_attestation'`, active, `observed_at=artifact.created_at`, ator humano/owner.

UpdateSignal nunca satisfaz polling periódico.

Recurring observation também persiste `scheduled_due_at` e `due_calculation_payload`. No INSERT, scheduled due deve igual `cadence_occurrence_due_at()`. Histórico on-time/late usa esse due congelado.

## 3. Resolver sem future leakage

Policy/rule effective times podem deslocar o raw causal start. Fatos de contexto posteriores não podem deslocar start para fazer uma rule casar.

Exemplo: SLA2 sem PriorityAssessment existente até triage/start não espera prioridade futura; rule com response_class_filter não casa.

`sla_rule_effective_until(rule_uuid)` deriva a janela histórica por lineage do mesmo policy/rule_code. Row `superseded` sem successor explícito produz `SLA_RULE_LINEAGE_INCOMPLETE` e não é usada para nova instance.

## 4. Due calculation snapshot

Adicionar a `maintenance.sla_instance`:

- `due_calculation_payload` JSONB nullable.

Para v0.1, obrigatório e fechado com:

- schema_version=oes.sla_due_calculation/0.1;
- calculator_version;
- calculated_at;
- raw_causal_start_at;
- contractual_start_at;
- time_basis;
- calendar/fixed-deadline locator quando aplicável;
- nominal_due_at.

No nascimento, nominal_due_at deve coincidir com o calculator. Depois, nominal_due_at persistido é o fato histórico; atualização futura de timezone database não reclassifica a instance.

## 5. Pause auditável

Adicionar a `sla_pause`:

- `due_extension_eligible`, derivado por trigger;
- `accountable_pause_seconds`, congelado ao fechar.

Closed pause:

- elapsed → wall seconds;
- business calendar → open-calendar seconds;
- fixed deadline → zero/não elegível.

Effective due usa valor congelado em pauses fechados e cálculo corrente apenas para pause aberto elegível.

## 6. Warning e candidate precision

Criar `sla_warning_at(instance_uuid)`:

- elapsed → wall subtraction;
- same_as_sla/business-calendar → `sla_calendar_subtract_open_seconds`.

Durations em candidate JSON usam decimal seconds, não interval string livre. SLARule.target_duration serializa deterministicamente para seconds no calibration snapshot. Calendar recurrence permanece count + unit.

## 7. Incorporação

Este anexo é parte integrante do contrato físico v0.1 submetido ao Documento 42.

> **MIGRATION_032 = NOT_AUTHORIZED**

até o recheck do gate.
