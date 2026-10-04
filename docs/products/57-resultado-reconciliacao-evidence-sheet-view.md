# 57 — Resultado da Reconciliação e Hardening do EvidenceSheetView

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Status:** PASS  
**Data:** 4 de outubro de 2026  
**GitHub Actions run:** 37212250256  
**Commit testado:** `6340c29efb1cfedab98c360f82c2931cc8fa459f`

---

# 1. Resultado

A reconciliação da atividade paralela e o hardening do EvidenceSheetView foram validados integralmente.

> **PASS**

Sequência canônica validada:

`007 → 008 provenance-aware references → 009 study-type counts`

---

# 2. Conflito resolvido

Foram detectados:

- duas migrations numeradas 008;
- dois Documentos 55.

A reconciliação:

- preservou `008_evidence_sheet_provenance_references.sql`;
- moveu contagens por tipo para `009_evidence_sheet_view_evidence_counts.sql`;
- removeu a migration 008 duplicada;
- preservou como Documento 55 canônico a decisão de síntese adotada + atualização OES;
- removeu o Documento 55 duplicado;
- criou o Documento 56 como registro explícito da reconciliação.

---

# 3. Validações

## Provenance-aware references

F3-PROV-T01–T05:

> PASS

Confirmado:

- Report externo sustentando síntese adotada aparece nas referências;
- a Synthesis externa não vaza para `priority_results`;
- a Synthesis externa não precisa ser diretamente vinculada ao Product;
- lineage permanece visível;
- ResultSource + ProvenanceRecord coexistem.

F3-PROV-T06 no rebuild:

> PASS

---

# 4. Contagem por tipo de Study

F3-VIEW-T17:

> PASS

O EvidenceSheetView expõe:

`evidence_base.study_type_counts`

permitindo distinguir:

- systematic_review;
- primary_study;
- demais tipos.

Isso evita interpretar `study_count` como número de RCTs subjacentes a uma meta-análise externa.

---

# 5. Template

F3-TEMPLATE:

> PASS

O template passou a:

- usar “unidades de evidência no OES”;
- discriminar tipos de Study;
- mostrar “Studies diretamente modelados”;
- renderizar payload estruturado de síntese adotada;
- permitir exibir `reported_study_count`;
- distinguir estimativa externa de atualização OES.

---

# 6. Rebuild

Rebuild integral executado com:

- baseline;
- migrations 002–009;
- fixtures F2-B/S4/S5/Ficha;
- testes de view;
- testes provenance-aware.

Resultado:

> **PASS**

---

# 7. Regressões

- F2-B: PASS;
- S4: PASS;
- S5-T01–T17: PASS;
- F3-FE-T01–T17: PASS;
- F3-VIEW-T01–T17: PASS;
- F3-PROV-T01–T06: PASS;
- F3-TEMPLATE: PASS.

---

# 8. Artefatos

Artifact:

- ID: **11306779147**
- nome: `oes-s5-evidence-37212250256`
- digest: `sha256:c0347d27ab8e42ca2e4eaf79db33c1bc234e831d31f53e79cd1f5d44a3ed0aca`
- tamanho: 14134 bytes
- expiração informada: 3 de novembro de 2026.

Hashes principais:

- migration 008: `273e1b4703f2c4412aa6645bf005aee852bcad4c07c824cd81fb792e3384d732`;
- migration 009: `0b2872d1c7e67d921a6a893998bb2e9b4ea037f40a417f64e66fe0081ab8abb5`.

---

# 9. Decisão

A arquitetura está novamente em estado canônico único.

Fica autorizado prosseguir para:

> **materialização do Caso Real 01 no baseline OES como ProductVersion under_review.**

A inserção deverá preservar:

- Hwang como Study do tipo systematic_review;
- estimativa externa como Result;
- Synthesis adotada separada;
- Synthesis narrativa de atualização separada;
- RCTs novos como primary Studies;
- certainty GRADE OES vinculada à atualização;
- ausência deliberada de aprovação humana;
- publication gate bloqueado;
- preview Markdown permitido.

---

**Resultado final:** PASS.
