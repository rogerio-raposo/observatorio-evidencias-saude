# Database PoC

Este diretório contém artefatos experimentais do modelo físico do OES.

## PoC-S1

Arquivo:

- `poc-s1.sql`

Objetivo:

validar o candidato **OES-P1** no menor conjunto de tabelas capaz de reconstruir a cadeia:

`Question → Investigation → Study/Report → Result → Synthesis → Certainty → Product`

com:

- identidade estável;
- versões;
- provenance;
- artifact metadata;
- dependency lineage.

## Status

**Experimental — não produção.**

A existência deste DDL não representa escolha definitiva de PostgreSQL nem autorização para iniciar automação ampla.

## Limitações desta primeira PoC

Ainda não implementa:

- Search/SearchHit;
- triagem;
- deduplicação;
- RiskAssessment;
- NMA completa;
- diagnóstico especializado;
- PredictionModel;
- CERQual/ReviewFinding;
- ApplicabilityAssessment;
- monitoramento;
- IA;
- autenticação/autorização;
- políticas de backup/HA;
- migrações de produção.

## Gate

O schema deverá ser executado contra uma instância PostgreSQL compatível antes de qualquer promoção.

Além da execução do DDL, a validação deverá incluir smoke tests de:

1. criação de uma cadeia completa;
2. bloqueio de segunda versão `current`;
3. reconstrução de lineage;
4. nova versão de Result/Synthesis/Certainty/Product;
5. impacto de Report corrigido/retratado;
6. integridade das FKs;
7. rollback transacional.
