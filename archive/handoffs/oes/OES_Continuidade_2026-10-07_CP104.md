# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Metodologia de Calibração Temporal

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP104  
**Checkpoint anterior:** CP103  
**Status:** artefato de continuidade; não normativo  
**Escopo:** metodologia de calibração temporal e gate adversarial, sem valores normativos

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **TEMPORAL_CALIBRATION_METHODOLOGY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate da retomada

A retomada partiu do CP103.

Confirmado:

- HEAD inicial: `c7d5c0d66f7affb40d770c8f291bbca3abea9957`;
- Documento 40 havia sido persistido apesar do ReadTimeout anterior;
- README/STATE/CHANGELOG/CP103 coerentes;
- nenhum commit concorrente posterior;
- timeout anterior classificado como ambiguous completion de comunicação, não falha do repositório.

## 3. Documento 39

Arquivo:

`docs/governance/39-metodologia-calibracao-temporal.md`

Resultado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Metodologia:

- quatro relógios separados;
- calibration context por target/policy/profile/source/clock/context;
- need envelope;
- source-reality envelope;
- feasibility envelope;
- external-constraint envelope;
- nenhuma função de score universal;
- nenhum mapping A1–A5 → dias;
- nenhum default universal por M0–M3.

## 4. Documento 40

Arquivo:

`docs/governance/40-gate-adversarial-metodologia-calibracao-temporal.md`

Primeira passagem:

> **REVISE**

Recheck final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 5. Hardening metodológico consolidado

Foram fechados:

1. A1–A5 não determinam números automaticamente;
2. seleção por constraints + dominância/Pareto;
3. source latency não define cadence sozinha;
4. suficiência exige caracterização de volume/missingness/censura;
5. replay inclui casos censurados/falhas/outliers;
6. PriorityAssessment usado na seleção SLA é snapshot pré-instance;
7. calibração provisional não vira rule normativa ativa;
8. repeated breach não alonga SLA automaticamente;
9. external deadline exige compatibilidade semântica;
10. capacity/calendar laundering proibidos;
11. currentness/assurance permanecem ortogonais;
12. M3 continua bloqueado.

## 6. Pré-requisitos físicos identificados

Antes de qualquer valor temporal normativo deverá existir contrato físico para:

1. Calibration Dossier;
2. structured calibration basis;
3. cadence payload/schema fechado;
4. source-scoped cadence obligation quando necessária;
5. canonical SLA rule resolver;
6. filter-domain validation;
7. canonical rule snapshot;
8. nominal due calculator;
9. business-calendar arithmetic;
10. fixed-deadline source lineage;
11. calendar effective-window guard;
12. warning/breach/escalation payload schemas;
13. issue/readiness helpers;
14. test plan;
15. M3 blocker preservation.

## 7. O que continua não autorizado

Não foram autorizados:

- numeric cadence;
- numeric grace;
- stale thresholds numéricos;
- numeric SLA durations;
- real SLA calendars;
- normative SLARules;
- migration 032;
- scheduler;
- notifications;
- auto-escalation;
- M3;
- Fase 5.

## 8. Estado técnico herdado

Último PASS técnico canônico permanece:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run ID: **37644296649** (#167);
- technical HEAD: `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- conclusion: **success**;
- artifact: **11494595216**;
- digest: `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`.

Este bloco foi documental/metodológico; nenhuma nova migration ou workflow técnico foi alterado.

## 9. Commits principais do bloco

- `bf5379429e8549425f2e051e8fd0e295c2e45e90` — Define temporal calibration methodology;
- `c7d5c0d66f7affb40d770c8f291bbca3abea9957` — Adversarial gate temporal calibration methodology;
- `3c52f3e3153850482acd8fab21cce4eed1debb43` — Harden temporal calibration methodology after adversarial gate;
- `0a39e3b7dc9ef5512780a5bced7be1cae83202ae` — Pass temporal calibration methodology gate;
- `b7a3a1af410e6f27db1fd90e1248be7f4ada76aa` — Finalize temporal calibration methodology after gate;
- `60ae6cd1825dc508d6f6e0a521361a0859c13811` — STATE;
- `3f942420a3bac1694d703d4fab59af3e4fd03aae` — CHANGELOG.

## 10. Estado antes do CP104

HEAD imediatamente antes da criação deste checkpoint:

`3f942420a3bac1694d703d4fab59af3e4fd03aae`

## 11. Próximo passo exato

> **Especificar o contrato físico v0.1 dos pré-requisitos de calibração temporal e submetê-lo a novo gate adversarial/físico antes de qualquer migration ou valor normativo.**

## 12. Disciplina de modo

O próximo passo volta a envolver decisões físicas/arquiteturais relevantes.

> **Modo alto continua recomendado para a especificação do contrato físico e seu gate.**

Após o fechamento desse contrato, eventual implementação mecânica poderá voltar a modo médio.

## 13. Regra de parada

Após ativação do CP104:

> **parar e aguardar instrução explícita do usuário antes de iniciar a especificação física.**

**Fim do CP104**
