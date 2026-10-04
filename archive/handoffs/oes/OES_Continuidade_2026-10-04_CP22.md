# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP22  
**Checkpoint anterior:** CP21  
**Status:** artefato de continuidade; não normativo  
**Escopo:** reconciliação de continuidade, provenance-aware references e EvidenceSheetView hardening  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP22

> **Fase 3 — EM DESENVOLVIMENTO**  
> **Caso Real 01 — protocolo, busca, appraisal, síntese, GRADE e draft científico concluídos**  
> **Conflito de continuidade 008/55 — RESOLVIDO**  
> **Migration 008 canônica — provenance-aware references**  
> **Migration 009 — study-type counts**  
> **Workflow reconciliado — PASS**  
> **Próxima etapa: materializar o Caso Real 01 como ProductVersion under_review**

---

# 2. Evidência técnica

GitHub Actions run:

- **37212250256**
- commit: `6340c29efb1cfedab98c360f82c2931cc8fa459f`
- resultado: **success**

Validações:

- F2-B: PASS;
- S4: PASS;
- S5-T01–T17: PASS;
- F3-FE-T01–T17: PASS;
- F3-VIEW-T01–T17: PASS;
- F3-PROV-T01–T06: PASS;
- F3-TEMPLATE: PASS;
- rebuild through migration 009: PASS.

Artifact:

- ID: **11306779147**
- digest: `sha256:c0347d27ab8e42ca2e4eaf79db33c1bc234e831d31f53e79cd1f5d44a3ed0aca`

---

# 3. Sequência canônica de migrations

- 006 — Evidence Sheet contract;
- 007 — EvidenceSheetView;
- 008 — provenance-aware references;
- 009 — Study type counts.

Não existem mais duas migrations 008 canônicas.

---

# 4. Documentos do Caso Real 01 já consolidados

- 48 — protocolo N2;
- 49 — busca e triagem inicial;
- 50 — ROBIS da síntese-base;
- 51 — RoB 2 dos RCTs de atualização;
- 52 — síntese atualizada;
- 53 — GRADE provisório;
- 54 — draft científico da Ficha;
- 55 — decisão arquitetural para síntese adotada + atualização OES;
- 56 — reconciliação de continuidade/hardening;
- 57 — resultado da validação da reconciliação.

---

# 5. Decisão arquitetural vigente

Para o Caso Real 01:

1. Hwang 2025 será Study do tipo `systematic_review`;
2. sua estimativa publicada será Result externo;
3. haverá Synthesis `adopted_external`;
4. haverá Synthesis `oes_update` separada;
5. não haverá novo pooling OES;
6. RCTs novos serão Studies primários;
7. GRADE OES será ligado à Synthesis de atualização;
8. referências externas serão recuperadas por provenance/dependency graph;
9. EvidenceSheetView expõe `study_type_counts`;
10. template diferencia unidades diretamente modeladas de k reportado pela meta-análise.

---

# 6. Estado científico do Caso Real 01

Conclusão draft:

> dCBT-I totalmente automatizada provavelmente reduz a gravidade da insônia versus educação digital sobre sono/higiene do sono; direção consistente, magnitude variável.

GRADE provisório:

> **moderada**

Bloqueante:

> revisão humana dos julgamentos materiais antes de publicação.

---

# 7. Ponto exato de retomada

## Materialização do Caso Real 01 no OES-P1

Próximos passos:

1. criar Question/Investigation real N2;
2. registrar Search;
3. materializar Hwang como systematic_review Study + Report + Result;
4. materializar RCTs decisivos como primary Studies + Reports + Results;
5. registrar ROBIS/RoB 2;
6. criar Synthesis `adopted_external`;
7. criar Synthesis `oes_update`;
8. criar GRADE provisório;
9. criar ProductVersion `under_review`;
10. não inserir review_record approved;
11. executar publication gate;
12. esperar `publishable=false`;
13. gerar EvidenceSheetView;
14. renderizar preview Markdown;
15. registrar defeitos remanescentes.

---

**Fim do CP22**
