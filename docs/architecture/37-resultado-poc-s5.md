# 37 — Resultado da PoC-S5: Métodos Especializados Mínimos

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** PASS  
**Data:** 4 de outubro de 2026  
**Plano:** Documento 36  
**GitHub Actions run:** 37189646452  
**Run number:** 1  
**Commit testado:** `0de9ac8ac3893e305615f242aae85aa7e0323805`

## 1. Resultado

A PoC-S5 foi executada integralmente em PostgreSQL 18.6.

> **PoC-S5 = PASS**

A execução incluiu:

- regressão F2-B: PASS;
- regressão S4: PASS;
- S5-T01–T17: PASS;
- rebuild do zero: PASS.

## 2. Ambiente

- GitHub-hosted Ubuntu 24.04;
- PostgreSQL server: **18.6**;
- container: `postgres:18`.

## 3. Hashes principais

| Arquivo | SHA-256 |
|---|---|
| `database/poc-s1.sql` | `2d856f3fe29c4b600086a8996b14b74524b974471111f44c3244061b901e36e5` |
| `database/002_poc_s2_search_screening_risk.sql` | `7f8109711aa6fd8bada3932edb4d4c3d57bc49afdc45d9c2b265d0f8c21c9740` |
| `database/003_poc_s3_provenance_guard.sql` | `98723e581b9c329cf8534ffe7501bcdc522fd73aa1f381656571feae4d344e3b` |
| `database/004_poc_s4_report_relation_impact.sql` | `1d46f50e410860f0d48aba3d3da152cdf03aaa028b07174155cb10de157b79ae` |
| `database/005_poc_s5_specialized_methods.sql` | `1b7e2ecbb623e6105c022c4ab6991a3ea3c2e5f1aede8980371e4b77e4af16d8` |
| `database/f2b-fixtures.sql` | `f6f4b61367528aec2f9b250205a3387f0cfb0203cc0958a7fa97d97e7244bd18` |
| `database/s4-fixtures.sql` | `12471085b72873ddb00e2d02a7295d61d70f2a9e8c85c83963144a4c34917e74` |
| `database/s5-fixtures.sql` | `1be31864c4b1bd6c564e161cf0c2737d46be4dd35b3b1a7680ba92c15f556f78` |
| `database/f2b-tests.sql` | `c9946ffdd9263f76c8db928673fe368baf9583be91bd046f8ed2494a1fdfafd8` |
| `database/s4-tests.sql` | `61779fdf717fbe522d4d4345363cefb33b249f18b78373677ec771cbcc19d6c2` |
| `database/s5-tests.sql` | `d0cccf1acf3d55b974fe63df9075bc5bd7edb89e61f134dbebe75a0d6dc01182` |
| `database/s5-rebuild-check.sql` | `cc4704eaf3405254f8421fb0c9a4e72d298a08d5ce9a413dcc770aaea47a7abe` |

## 4. S5-A — NMA

Resultados:

- grupos do Result pertencem ao Study correto: PASS;
- referência cruzada para grupo de outro Study: rejeitada;
- 3 SynthesisNodes: PASS;
- 4 NodeMappings: PASS;
- 3 Contrasts: PASS;
- 2 Studies contribuintes: PASS;
- Contrast entre nós de Syntheses diferentes: rejeitado;
- lineage Report → Result → NMA Synthesis → Certainty → Product: PASS.

Consequência:

> critério 8 — NMA: **VALIDADO**.

## 5. S5-B — PredictionModel

Resultados:

- PredictionModel v1 superseded + v2 current: PASS;
- roles development + external_validation: PASS;
- Results de performance em 2 Studies: PASS;
- vínculo explícito Result → PredictionModel: PASS;
- lineage Report → Result → Synthesis → Certainty → Product: PASS.

Consequência:

> critério 9 — predição: **VALIDADO**.

## 6. S5-C — Qualitativa/CERQual

Resultados:

- CERQual sem ReviewFinding: rejeitado;
- ReviewFinding com 2 Studies contribuintes: PASS;
- methodological limitations: representado;
- coherence: representado;
- adequacy: representado;
- relevance: representado;
- confiança final CERQual: representada;
- lineage Report → ReviewFinding → CERQual → Product: PASS.

Consequência:

> critério 10 — qualitativa/CERQual: **VALIDADO**.

## 7. Lineage especializado

As três trilhas demonstraram reconstrução até Product.

Consequência:

> critério 15 — reconstrução completa de lineage: **VALIDADO**.

## 8. Rebuild

S5-T16 reproduziu em banco limpo:

- 3 NMA Nodes;
- 2 versões de PredictionModel;
- 2 FindingContributions;
- 4 domínios CERQual;
- 3 Products especializados.

## 9. Artifact

- ID: **11297653844**
- nome: `oes-s5-evidence-37189646452`
- digest: `sha256:ba8aed9373dfde8c5ee14c67f91084b2158c3b76bc98560fbc5a22555b133719`
- tamanho: 5646 bytes
- expiração informada: 3 de novembro de 2026

## 10. Matriz de promoção

Após S5:

- **15 VALIDADO**;
- **0 PARCIALMENTE VALIDADO**;
- **0 NÃO VALIDADO**.

## 11. Decisão recomendada

A evidência de PoC permite promover OES-P1 de “candidato físico validado” para:

> **BASELINE ARQUITETURAL DA FASE 2**

Essa promoção significa que OES-P1 passa a ser a referência arquitetural canônica para evolução do modelo de dados.

Não significa:

- PostgreSQL como stack definitiva;
- schema de produção congelado;
- prontidão operacional;
- encerramento de evolução futura por migrations.

---

**Resultado:** PASS.
