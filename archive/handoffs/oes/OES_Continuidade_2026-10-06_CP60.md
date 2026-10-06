# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP60  
**Checkpoint anterior:** CP59  
**Status:** artefato de continuidade; não normativo  
**Escopo:** qualificação positiva condicionada do corpus dCBT-I para OVR-01  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP60

> **Corpus dCBT-I = SUITABLE_WITH_CONDITIONS para OVR-01 developmental.**

Documento canônico:

`docs/products/148-qualificacao-corpus-candidato-ovr01-dcbti.md`

## 2. Reviews qualificadas

### Hwang et al. 2025

- StudyVersion `81000000-0000-0000-0000-000000000101`;
- systematic_review;
- ReportVersion `81000000-0000-0000-0000-000000000201`;
- ResultVersion `81000000-0000-0000-0000-000000000301`;
- SynthesisVersion `81000000-0000-0000-0000-000000000501`;
- ROBIS draft existente;
- search cutoff 31/03/2024.

### Gao et al. 2026

- StudyVersion `81000000-0000-0000-0000-000000000102`;
- systematic_review;
- ReportVersion `81000000-0000-0000-0000-000000000202`;
- ResultVersion `81000000-0000-0000-0000-000000000302`;
- SynthesisVersion `81000000-0000-0000-0000-000000000502`;
- ROBIS ainda ausente;
- last-search date ainda não persistida.

## 3. Condições obrigatórias

Antes de persistir ReviewItems/membership:

1. recuperar/confirmar study list de Gao;
2. extrair last-search date de Gao;
3. reconciliar Study identities Hwang × Gao;
4. construir inventário de membership;
5. definir escopo de cluster/comparador;
6. decidir prospectivamente sobre eventual terceira Review;
7. produzir ROBIS de Gao em estado não humano;
8. não reutilizar certainty da Evidence Sheet como certainty reportada pelas Reviews;
9. não criar nova meta-analysis.

## 4. Regra de reutilização

OVR-01 poderá referenciar:

- Review StudyVersions;
- Reports;
- ResultVersions;
- Syntheses externas existentes.

Não deverá alterar:

- Evidence Sheet N2 publicada;
- Investigation N2;
- Synthesis 503;
- certainty da Evidence Sheet;
- assurance da Evidence Sheet.

OVR-01 terá:

- Question própria;
- Investigation própria;
- Product próprio.

## 5. Estado de autorização

Autorizado agora:

> **preparar protocolo developmental OVR-01.**

Ainda não autorizado:

- persistir ReviewItems;
- persistir membership;
- calcular overlap;
- criar ProductVersion real;
- elevar assurance.

## 6. Ponto exato de retomada

> **Preparar protocolo developmental do OVR-01 dCBT-I, definindo pergunta review-level, eligibility, comparadores, overlap, currentness, ROBIS, OutcomeEvidence, certainty e plano de fechamento das condições pré-persistência.**

**Fim do CP60**
