# Database PoC

Este diretório contém artefatos experimentais do modelo físico do OES.

## Escopo atual

O candidato físico **OES-P1** foi implementado incrementalmente para prova arquitetural por meio de:

- `poc-s1.sql` — baseline experimental;
- `002_poc_s2_search_screening_risk.sql` — Search, SearchHit, DedupCluster, ScreeningDecision e RiskAssessment;
- `003_poc_s3_provenance_guard.sql` — proteção history-preserving de provenance;
- `004_poc_s4_report_relation_impact.sql` — ReportRelation e traversal derivado de impacto;
- `005_poc_s5_specialized_methods.sql` — StudyGroup/NMA, PredictionModel e ReviewFinding/CERQual;
- `poc-s1-smoke.sql` — smoke inicial;
- `f2b-fixtures.sql` — fixtures determinísticas do gate;
- `f2b-tests.sql` — bateria runtime T03–T13 e T16–T19;
- `f2b-rebuild-check.sql` — verificação do rebuild do zero.

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

