# 110 — Caso Real N3-01: Resultado da Validação Técnica A0

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**Data:** 6 de outubro de 2026  
**Status:** validação técnica A0 concluída — **PASS**  
**Publicação formal:** bloqueada por desenho de governança

---

# 1. Objetivo

Registrar a validação técnica ponta a ponta do Caso Real N3-01 antes da verificação metodológica adversarial por IA.

# 2. Artefatos científicos do caso

- Documento 106 — protocolo pré-especificado;
- Documento 107 — busca rápida, desvio de protocolo e seleção;
- Documento 108 — appraisal experimental;
- Documento 109 — síntese narrativa, GRADE experimental e SoF;
- materialização OES-P1 em `database/f3-real-case-n3-ambient-ai-scribes.sql`;
- testes RN3-T01–T15;
- rebuild RN3-T16;
- renderização real A0 com validator dedicado.

# 3. Estado científico/técnico validado

O caso preserva:

- depth N3;
- maintenance M1;
- Product `OES-P-2026-000701`;
- estado `under_review`;
- assurance A0;
- `publishable=false`;
- protocolo rastreável;
- cinco rapid restrictions planejadas;
- um desvio de protocolo mitigado e explicitamente visível;
- duas Search records;
- 10 hits materializados;
- 17 decisões de screening;
- seis Reports utilizados/contextuais;
- 11 Results estruturados;
- 10 appraisals;
- quatro SynthesisVersion narrativas;
- quatro CertaintyAssessment experimentais;
- SoF rastreável;
- seis quality controls executados por IA;
- seis controles humanos qualificados ausentes.

# 4. GRADE experimental validado

- documentation time: LOW;
- workload/work exhaustion: LOW;
- work outside work: LOW;
- note quality/safety: VERY LOW.

Esses níveis são experimentais e não equivalem a GRADE verificado por avaliadores humanos qualificados.

# 5. Governança preservada

O gate mantém como erros:

- `MISSING_AI_METHODOLOGICAL_VERIFICATION`;
- `MISSING_OWNER_APPROVAL`;
- `MISSING_EXPERT_INDEPENDENT_REVIEW`;
- `ASSURANCE_BELOW_A3`;
- `MISSING_PUBLICATION_DATE`;
- `MISSING_SEARCH_STRATEGY_VERIFICATION`;
- `MISSING_SCREENING_PILOT`;
- `MISSING_QUALIFIED_SCREENING_VERIFICATION`;
- `MISSING_QUALIFIED_DATA_VERIFICATION`;
- `MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION`;
- `MISSING_QUALIFIED_CERTAINTY_VERIFICATION`.

Nenhum controle por IA foi convertido em controle humano qualificado.

# 6. Renderização real A0

Foi criado validator dedicado para o payload real:

`scripts/validate_real_n3_render.py`

O Markdown real deve mostrar obrigatoriamente:

- `EXPERIMENTAL — NÃO PUBLICÁVEL COMO N3 FORMAL`;
- `PREVIEW — GATE DE PUBLICAÇÃO NÃO APROVADO`;
- assurance A0;
- controles qualificados ausentes;
- ausência de expert review;
- desvio `EUROPE_PMC_RUNTIME_ACCESS_FAILURE`;
- blockers formais do gate;
- conclusão calibrada;
- nenhuma alegação de A3.

# 7. Evidência de execução

GitHub Actions:

- run **37412408640**;
- attempt 1;
- conclusion **success**;
- commit validado `d837048cd73b6186d86dfde886230dfd9c52cffc`.

Artifact:

- ID **11389418733**;
- nome `oes-s5-evidence-37412408640`;
- digest `sha256:563f47eafcf276d872ab0e8d15ca548454bdb85cec0aaabf26d2dff4fd9fa408`.

# 8. Logs confirmados

- `RN3-T01–T15 PASS`;
- `RN3-T16 PASS`;
- `RN3-TEMPLATE-A0 validation PASS`;
- `F3-RS-TEMPLATE validation PASS`;
- `Rebuild through migration 014 PASS`;
- regressões N0–N2/F2-B/S4/S5 PASS.

# 9. Decisão

> **Caso Real N3-01: PASS técnico em A0 experimental.**

Esse PASS não é verificação metodológica A1 e não altera os blockers de publicação.

# 10. Próxima etapa

> **Verificação metodológica adversarial por IA.**

A verificação deverá testar explicitamente:

- adequação da escolha N3;
- aderência ao protocolo;
- impacto do desvio Europe PMC;
- risco de missing studies;
- coerência da seleção;
- validade dos appraisals;
- fidelidade dos resultados extraídos;
- coerência da síntese narrativa;
- proporcionalidade dos downgrades GRADE;
- calibragem da conclusão;
- transparência de limitações;
- preservação dos blockers humanos/A3.

Resultados possíveis:

- `PASSED` → materializar A1 experimental;
- `REVISE` → corrigir antes de A1;
- `FAILED` → encerrar ou rerrotear.

---

**Resultado:** PASS técnico A0; verificação metodológica ainda pendente.