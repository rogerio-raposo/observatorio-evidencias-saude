# Database PoC

Este diretório contém artefatos experimentais do modelo físico do OES.

## Escopo atual

O candidato físico **OES-P1** foi implementado incrementalmente para prova arquitetural por meio de:

- `poc-s1.sql` — baseline experimental;
- `002_poc_s2_search_screening_risk.sql` — Search, SearchHit, DedupCluster, ScreeningDecision e RiskAssessment;
- `003_poc_s3_provenance_guard.sql` — proteção history-preserving de provenance;
- `004_poc_s4_report_relation_impact.sql` — ReportRelation e traversal derivado de impacto;
- `005_poc_s5_specialized_methods.sql` — StudyGroup/NMA, PredictionModel e ReviewFinding/CERQual;
- `006_product_evidence_sheet_contract.sql` — contrato físico da Ficha de Evidência, atualidade, classes de mudança, revisão humana e publication gate;
- `007_evidence_sheet_view.sql` — projeção JSONB determinística para renderização da Ficha;
- `008_evidence_sheet_provenance_references.sql` — referências da Ficha conscientes de provenance/lineage;
- `009_evidence_sheet_view_evidence_counts.sql` — contagens de unidades de evidência por `study_type`;
- `010_product_assurance_governance.sql` — registros de assurance A0–A3 e publication gate baseado em AI verification, owner approval e expert review;
- `011_evidence_sheet_assurance_view.sql` — projeção de assurance no EvidenceSheetView.
- `008_evidence_sheet_provenance_references.sql` — referências da Ficha derivadas também de provenance/dependency graph;
- `009_evidence_sheet_view_evidence_counts.sql` — discriminação das unidades de evidência por `study_type`;
- `poc-s1-smoke.sql` — smoke inicial;
- `f2b-fixtures.sql` — fixtures determinísticas do gate;
- `f2b-tests.sql` — bateria runtime T03–T13 e T16–T19;
- `f2b-rebuild-check.sql` — verificação do rebuild do zero;
- `f3-human-review-gate-tests.sql` — testes transacionais da semântica `approved` / `revise` / `rejected` do Gate de Revisão Humana, sempre com `ROLLBACK`.

A cadeia mínima validada inclui:

`Search → Screening → Study/Report → Result → Synthesis → Certainty → Product`

com suporte a:

- identidade estável;
- versionamento;
- provenance;
- deduplicação;
- RiskAssessment;
- artifact metadata;
- dependency lineage.

## Status

**Experimental — candidato validado em PoC; não produção.**

A execução bem-sucedida não representa escolha definitiva de PostgreSQL, schema final ou autorização para automação ampla.

## GATE F2-B

**PASS — 4 de outubro de 2026.**

Execução:

- GitHub Actions run: **37187885839**
- commit: `de168908d8fe311e64c07937dc70df36af39d910`
- PostgreSQL server: **18.6**
- T01–T19: **PASS**
- rebuild do zero: **PASS**
- artifact: **11297272424**
- artifact digest: `sha256:5381605d34064f95a2d4444e34d275b8c89ceb28a19cc915db104da9362c1d7c`

Registros:

- `docs/architecture/27-plano-testes-gate-f2b.md`
- `docs/architecture/F2B_Test_Run_2026-10-04_37187885839.md`
- `docs/architecture/32-resultado-gate-f2b.md`

## Invariantes validadas

A bateria demonstrou, no escopo da PoC:

1. instalação limpa do baseline e migrations;
2. smoke end-to-end;
3. unicidade da versão corrente;
4. supersessão restrita à mesma entidade;
5. integridade de subtipos;
6. integridade de FKs;
7. invariantes de Result;
8. intervalos coerentes;
9. estado `no_evidence` incompatível com certainty final;
10. cadeia de versionamento v1→v2 preservando histórico;
11. provenance material imutável e correção por supersessão;
12. lineage canônico + dependency projection;
13. rollback de operação multi-step;
14. rebuild do zero;
15. reaplicação acidental de migration detectável;
16. regras de ScreeningDecision;
17. integridade de RiskAssessment;
18. preservação de SearchHits após deduplicação;
19. cadeia Search-to-Product reconstruível.

## Limitações atuais

Ainda não constituem validação completa do candidato para promoção definitiva:

- NMA completa;
- diagnóstico especializado;
- PredictionModel;
- síntese qualitativa/CERQual;
- ApplicabilityAssessment;
- cenários ampliados de ReportRelation/retração/impact analysis;
- monitoramento;
- IA operacional;
- autenticação/autorização;
- backup/HA;
- migration ledger para ambiente persistente;
- migrações de produção.

Esses itens deverão ser avaliados conforme sua relevância para os critérios de promoção do Documento 25.

## Política de migração

O baseline não deve ser reescrito silenciosamente para acomodar novas funcionalidades.

Extensões deverão preferir migrations incrementais versionadas conforme:

`docs/architecture/30-politica-migracoes.md`

## PoC-S4

**PASS — 4 de outubro de 2026.**

- GitHub Actions run: **37188934837**
- PostgreSQL server: **18.6**
- S4-T01–T15: **PASS**
- artifact: **11298153474**
- digest: `sha256:c37a2a57bc6b039461324576b06aa4c88f401773ca83dddfa5f9d3cae583cab5`

A PoC-S4 validou:

- Study com múltiplos Reports;
- Report com múltiplos Studies;
- síntese multiestudo;
- ReportRelation;
- correção/retração;
- impact traversal;
- coexistência de lineage histórico e pós-retração.

## PoC-S5

**PASS — 4 de outubro de 2026.**

- GitHub Actions run: **37189646452**
- PostgreSQL server: **18.6**
- regressão F2-B: PASS
- regressão S4: PASS
- S5-T01–T17: **PASS**
- artifact: **11297653844**
- digest: `sha256:ba8aed9373dfde8c5ee14c67f91084b2158c3b76bc98560fbc5a22555b133719`

A PoC-S5 validou NMA, PredictionModel, Qualitativa/CERQual e lineage especializado.

## Estado arquitetural

**OES-P1 foi promovido a baseline arquitetural da Fase 2.**

Os SQLs permanecem experimentais e não constituem schema de produção congelado. Mudanças futuras deverão ocorrer por migrations controladas.

## Próxima etapa

A arquitetura de dados deixa de ser o foco principal. O projeto transita para **Fase 3 — Produtos do Observatório**.



## Fase 3 — Contrato físico da Ficha de Evidência

**PASS — 4 de outubro de 2026.**

- GitHub Actions run: **37191456703**
- PostgreSQL server: **18.6**
- F3-FE-T01–T17: **PASS**
- regressão F2-B: PASS
- regressão S4: PASS
- regressão S5: PASS
- rebuild: PASS
- artifact: **11299032774**
- digest: `sha256:2e3508b0d876e13e2f6efb367da8e8b308c943560e3d5e978fa293a8a4f851c1`

O baseline passa a incluir, para a camada de produtos:

- `limitations_summary`;
- `product.currency_state`;
- `product.version_change_class`;
- `product.review_record`;
- uma Investigation primary por ProductVersion;
- funções de publication issues/publishability da Ficha.

Próximo passo: EvidenceSheetView e template operacional.


## Fase 3 — EvidenceSheetView

**PASS — 4 de outubro de 2026.**

- GitHub Actions run: **37191973078**
- PostgreSQL server: **18.6**
- F3-VIEW-T01–T16: **PASS**
- regressões F2-B/S4/S5/Ficha: PASS
- rebuild até migration 007: PASS
- artifact: **11298729618**
- digest: `sha256:d3e53b35bccf3a89e5ee8621ff2d3fc5501d56b56e4a22b5aa8993e9897cbef9`

A função de referência é:

`product.evidence_sheet_view(uuid) RETURNS jsonb`

A migration 007 é idempotente por desenho, pois utiliza `CREATE OR REPLACE FUNCTION`.

Próxima etapa: especificação e construção do template operacional da Ficha.


## Fase 3 — Reconciliação real-case / EvidenceSheetView hardening

**PASS — 4 de outubro de 2026.**

- GitHub Actions run: **37212250256**
- F3-PROV-T01–T06: PASS
- F3-VIEW-T17: PASS
- F3-TEMPLATE: PASS
- regressões F2-B/S4/S5/Ficha/View: PASS
- rebuild até migration 009: PASS
- artifact: **11306779147**
- digest: `sha256:c0347d27ab8e42ca2e4eaf79db33c1bc234e831d31f53e79cd1f5d44a3ed0aca`

Sequência canônica:

`007 → 008 provenance-aware references → 009 study-type counts`.

Próximo passo: materializar o Caso Real 01 como Ficha `under_review`.


## Caso Real 01 — dCBT-I

**PASS de pré-publicação — 4 de outubro de 2026.**

Arquivos canônicos:

- `f3-real-case-01-dcbti.sql`;
- `f3-real-case-01-tests.sql`;
- `f3-real-case-01-rebuild-check.sql`.

GitHub Actions:

- run: **37213165321**
- RC01-T01–T10: PASS
- preview Markdown: PASS
- publication gate: bloqueado como esperado
- rebuild: PASS
- artifact: **11307386757**
- digest: `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`

O produto permanece `under_review`; nenhum `review_record approved` foi criado.


## Caso Real 01 — Gate de Revisão Humana

**PASS técnico — 4 de outubro de 2026.**

- GitHub Actions run: **37213717492**
- HRG-T01–T06: **PASS**
- RC01-T01–T10: PASS
- rebuild: PASS
- artifact: **11306934256**
- digest: `sha256:81578896ae97f582bd3029c4f276303e0208067b0cdcf053b0bb46f764b3a51f`

Semântica validada:

- `revise` mantém publicação bloqueada;
- `rejected` adiciona bloqueio explícito;
- `approved` não sobrepõe rejeição ativa;
- `approved` sem `publication_date` não libera publicação;
- somente o conjunto completo de requisitos pode tornar a Ficha elegível;
- todos os review records dos testes são sintéticos e revertidos por `ROLLBACK`.

O Caso Real 01 permanece sem revisão humana real e continua `under_review`.


## Caso Real 01 — assurance A1

**PASS — 4 de outubro de 2026.**

- run: **37226199396**
- RC01-T01–T10: PASS
- AG-T01–T07: PASS
- AV-T01–T02: PASS
- F3-TEMPLATE: PASS
- rebuild through migration 011: PASS
- artifact: **11311923205**
- digest: `sha256:4450a1eb9cd4e46012b8fecf55fa132a7b13e80af0472a10eaf8d859d12aeeb6`

Estado do Caso Real 01:

- assurance: **A1**;
- AI methodological verification ativa: `passed`;
- owner governance approval: ausente;
- expert independent review: ausente;
- `publishable=false`.

## Fase 4 — Protocolo Transversal de Atualização v0.1

**PASS técnico — 7 de outubro de 2026.**

Migration:

- `027_transversal_update_protocol_contract.sql`

Fixtures/testes:

- `f4-update-protocol-fixtures.sql`;
- `f4-update-protocol-tests.sql`;
- F4-UP-T01–T63: **PASS**;
- F4-UP-IDEM: **PASS**;
- rebuild through migration 027: **PASS**.

Estruturas aditivas:

- `maintenance.update_policy`;
- `maintenance.update_signal`;
- `maintenance.update_signal_source`;
- `maintenance.materiality_assessment`;
- `maintenance.materiality_dimension`;
- `maintenance.update_decision`;
- `maintenance.update_decision_currency_state`.

GitHub Actions:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37570978847**;
- HEAD: `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- conclusion: **success**;
- artifact: **11460960487**;
- digest: `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`.

Limite preservado:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL` permanece ativo.

A migration 027 não define thresholds, SLA numérico, scheduler, notifications, auto-classification, auto-escalation, propagation automática nem M3 readiness.

Após a auditoria retrospectiva da Fase 4, a migration 028 foi autorizada **somente** como hardening corretivo da 027. Ela reforça lifecycle/issue helpers e não implementa prioridade, SLA físico, notificações, propagation ou M3 readiness.

Estado metodológico após Documentos 16–23:

- perfis de risco = PASS_WITH_ARCHITECTURAL_DECISIONS;
- cadence/thresholds temporais = PASS_WITH_ARCHITECTURAL_DECISIONS;
- SLA semântico = PASS_WITH_ARCHITECTURAL_DECISIONS;
- auditoria retrospectiva = REVISE até nova validação canônica da migration 028;
- prioridade/escalation = aguardando fechamento do bloco corretivo.

Próxima etapa metodológica, **após PASS corretivo**:

> arquitetura transversal de prioridade e escalation.

