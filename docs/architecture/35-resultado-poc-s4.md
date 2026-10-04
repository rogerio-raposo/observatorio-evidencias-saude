# 35 — Resultado da PoC-S4: Multiplicidade, Síntese Multiestudo e Retração

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** PASS  
**Data:** 4 de outubro de 2026  
**Plano:** Documento 34  
**GitHub Actions run:** 37188934837  
**Run number:** 1  
**Commit testado:** `c86a037526fa162ccb3d5773e9a1d1ad2efe1572`

## 1. Resultado

A PoC-S4 foi executada integralmente em PostgreSQL 18.6.

> **PoC-S4 = PASS**

Todos os testes S4-T01–T15 foram aprovados.

## 2. Ambiente

- GitHub-hosted Ubuntu 24.04;
- PostgreSQL server: **18.6**;
- container: `postgres:18`;
- image digest observado: `sha256:5a5a84b19854a9ffaa54082c166ff4ec27473a361e496e5ea167f298f2da9722`.

## 3. Hashes dos artefatos SQL

| Arquivo | SHA-256 |
|---|---|
| `database/poc-s1.sql` | `2d856f3fe29c4b600086a8996b14b74524b974471111f44c3244061b901e36e5` |
| `database/002_poc_s2_search_screening_risk.sql` | `7f8109711aa6fd8bada3932edb4d4c3d57bc49afdc45d9c2b265d0f8c21c9740` |
| `database/003_poc_s3_provenance_guard.sql` | `98723e581b9c329cf8534ffe7501bcdc522fd73aa1f381656571feae4d344e3b` |
| `database/004_poc_s4_report_relation_impact.sql` | `1d46f50e410860f0d48aba3d3da152cdf03aaa028b07174155cb10de157b79ae` |
| `database/f2b-fixtures.sql` | `f6f4b61367528aec2f9b250205a3387f0cfb0203cc0958a7fa97d97e7244bd18` |
| `database/s4-fixtures.sql` | `12471085b72873ddb00e2d02a7295d61d70f2a9e8c85c83963144a4c34917e74` |
| `database/s4-tests.sql` | `61779fdf717fbe522d4d4345363cefb33b249f18b78373677ec771cbcc19d6c2` |
| `database/s4-rebuild-check.sql` | `ca55aa5d85186e168a0e50cb471760980acdc4f47d26c81239c82c2454655f6f` |

## 4. Testes

| Teste | Resultado |
|---|---|
| S4-T01 — instalação limpa até migration 004 | PASS |
| S4-T02 — Study com múltiplos Reports | PASS |
| S4-T03 — Report com múltiplos Studies | PASS |
| S4-T04 — síntese com dois Studies distintos | PASS |
| S4-T05 — vocabulário de ReportRelation | PASS |
| S4-T06 — bloqueio de auto-relação | PASS |
| S4-T07 — cadeia Report X v1→v2→v3 | PASS |
| S4-T08 — estado current/retracted | PASS |
| S4-T09 — correction_of + retraction_of | PASS |
| S4-T10 — impact traversal até Products | PASS |
| S4-T11 — histórico v1/v2 dos derivados | PASS |
| S4-T12 — no_evidence + Product v2 | PASS |
| S4-T13 — lineage histórico e pós-retração | PASS |
| S4-T14 — rebuild do zero | PASS |
| S4-T15 — reaplicação de migration detectável | PASS |

Detalhes observados:

- Study A vinculado a **2 Reports**;
- Report X vinculado a **2 Studies**;
- Synthesis v1 combinou **2 Studies distintos**;
- impact traversal atingiu Product histórico e atual com profundidade 4;
- rebuild encontrou **2 relações documentais**, **2 Studies na síntese**, **16 versões impactadas** e **2 versões de Product**.

## 5. Artifact

- Artifact ID: **11298153474**
- Nome: `oes-s4-evidence-37188934837`
- Digest: `sha256:c37a2a57bc6b039461324576b06aa4c88f401773ca83dddfa5f9d3cae583cab5`
- Tamanho: 3704 bytes
- Expiração informada: 3 de novembro de 2026

## 6. Decisão sobre os critérios de promoção

Após S4:

- critério 4 — Study com múltiplos Reports: **VALIDADO**;
- critério 5 — Report com múltiplos Studies: **VALIDADO**;
- critério 7 — síntese quantitativa: **VALIDADO**;
- critério 14 — retração e impact analysis: **VALIDADO**;
- critério 15 — lineage completo: **PARCIALMENTE VALIDADO**, aguardando métodos especializados da S5.

Matriz resultante:

- **11 VALIDADO**;
- **1 PARCIALMENTE VALIDADO**;
- **3 NÃO VALIDADO**.

## 7. Decisão arquitetural

OES-P1 continua:

> **CANDIDATO FÍSICO VALIDADO, NÃO PROMOVIDO.**

A PoC-S4 removeu as lacunas relacionais e de retração do Grupo A.

Restam exclusivamente os critérios especializados:

- 8 — NMA;
- 9 — predição;
- 10 — qualitativa/CERQual;
- remanescente especializado do 15 — lineage.

## 8. Próxima etapa

> **PoC-S5 — Métodos Especializados Mínimos**

Trilhas:

- S5-A — NMA;
- S5-B — PredictionModel;
- S5-C — Qualitativa/CERQual.

A PoC-S5 deverá validar representação, identidade, versionamento, provenance e lineage; não exige implementação de motores estatísticos completos.

---

**Resultado:** PASS.
