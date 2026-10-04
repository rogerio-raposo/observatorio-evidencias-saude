# 55 — Caso Real 01: Decisão Arquitetural para Síntese Adotada + Atualização OES

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Data:** 4 de outubro de 2026  
**Status:** decisão arquitetural consolidada para o caso real

---

# 1. Problema revelado pelo caso real

A Ficha Real 01 não usa uma meta-análise recalculada pelo OES.

O fluxo científico é:

1. uma meta-análise publicada fornece a estimativa quantitativa-base;
2. o OES avalia criticamente essa síntese;
3. o OES identifica RCTs novos;
4. os RCTs são usados para atualizar/triangular a conclusão;
5. o OES não recalcula o pooling.

A arquitetura deve representar isso sem sugerir falsamente que:

- o OES refez a meta-análise;
- os RCTs novos foram incorporados ao peso estatístico da estimativa publicada;
- o número de Studies diretamente modelados no OES equivale ao número de estudos subjacentes à meta-análise externa.

---

# 2. Decisão

> **Nenhuma alteração do schema científico canônico é necessária para o Caso Real 01.**

O baseline atual possui entidades e relações científicas suficientes.

Durante a validação do caso real, contudo, foram necessárias duas **migrations compatíveis da camada de projeção**, sem criação de nova entidade canônica:

- migration 008 — referências do EvidenceSheetView conscientes de provenance/lineage;
- migration 009 — contagens de unidades de evidência por `study_type`.

Essas migrations corrigem rastreabilidade e apresentação do EvidenceSheetView; não alteram a decisão de que a meta-análise externa e a atualização OES podem ser representadas pelo modelo canônico existente.

---

# 3. Representação da revisão Hwang

Hwang et al. 2025 será modelada como:

- `Study`;
- `study_type = systematic_review`;
- `design = systematic_review_meta_analysis`;
- Report científico próprio;
- Result contendo a estimativa publicada do subgrupo focal.

O Result manterá:

- outcome;
- estimand;
- measure = SMD;
- reported value;
- IC95%;
- method payload;
- ResultSource apontando ao Report Hwang.

Assim:

> a estimativa meta-analítica externa é tratada como resultado publicado de uma fonte secundária, não como cálculo novo do OES.

---

# 4. Synthesis quantitativa adotada

Criar Synthesis com:

- `synthesis_type = meta_analysis`;
- `synthesis_origin = adopted_external`;
- método descrevendo explicitamente a origem;
- `result_summary` contendo:
  - efeito publicado;
  - intervalo;
  - k reportado;
  - I²;
  - identificador da fonte;
  - `recalculated_by_oes = false`.

Contribution:

- Result Hwang;
- `contribution_role = adopted_external_estimate`;
- `included_main_analysis = true`.

---

# 5. Synthesis de atualização OES

Criar segunda Synthesis:

- `synthesis_type = narrative_update`;
- `synthesis_origin = oes_update`;
- sem modelo de pooling;
- `result_summary` contendo:
  - direção;
  - magnitude variável;
  - número de estudos novos diretamente modelados;
  - indicação de que não houve pooling novo;
  - resumo da triangulação.

Contributions:

- Results dos RCTs novos;
- `contribution_role = update_evidence`;
- `included_main_analysis = false`.

Motivo:

> os Results contribuem para atualização da interpretação, mas não para a estimativa numérica publicada de Hwang.

---

# 6. Somzz e possível dupla contagem

Somzz 2024:

- será modelado como Study elegível;
- seu Result poderá contribuir para a Synthesis de atualização;
- `included_main_analysis = false`;
- notes indicarão que sua inclusão efetiva no pooling Hwang não está esclarecida.

Não será usado para:

- recalcular a estimativa-base;
- aumentar artificialmente a contagem de estudos independentes da meta-análise.

---

# 7. Certainty

A avaliação GRADE OES será vinculada à:

> **Synthesis de atualização OES**

e não diretamente à Synthesis externa isolada.

Motivo:

a certainty OES considera:

- a estimativa-base;
- ROBIS;
- RoB 2;
- RCTs novos;
- heterogeneidade;
- atualização até o cutoff.

Framework:

- GRADE;
- final level provisório: moderate;
- status: under review/draft;
- revisão humana obrigatória antes de publicação.

---

# 8. Provenance

## Estimativa externa

Cadeia:

`Hwang Report → Hwang Result → adopted Synthesis`

## Atualização

Cadeias:

`RCT Report → RCT Result → OES narrative-update Synthesis`

## Certainty

`adopted Synthesis + update Synthesis + appraisals → CertaintyAssessment`

## Product

`Synthesis/Certainty → ProductVersion`

A dependency graph deverá preservar essas relações.

---

# 9. Contagem de Studies

O `EvidenceSheetView 0.1` calcula `evidence_base.study_count` a partir dos Studies diretamente conectados por `SynthesisContribution`.

Em uma síntese adotada:

> esse valor **não corresponde necessariamente ao total de estudos subjacentes à meta-análise publicada**.

Exemplo do Caso Real 01:

- Hwang = 1 Study diretamente modelado;
- Hwang reporta k=10 no subgrupo focal;
- RCTs novos são Studies adicionais diretamente modelados.

Portanto:

> o template não deverá rotular `study_count` como “total de estudos do corpo de evidências”.

Rótulo correto nesta versão:

> **Studies diretamente modelados no OES**

O número reportado pela síntese externa deve ser exibido no resultado prioritário como:

> **k reportado pela síntese-base: 10**

---

# 10. Ajuste de apresentação necessário

O template deverá:

1. trocar “Studies” por “Studies diretamente modelados no OES” na seção de base;
2. permitir renderizar campos estruturados de `result_summary`, quando presentes;
3. diferenciar:
   - estimativa externa adotada;
   - atualização narrativa OES;
4. exibir `recalculated_by_oes=false` de forma legível:
   > “Meta-análise não recalculada pelo OES.”

Esses ajustes são de projeção/apresentação.

Não exigem nova entidade científica nem mudança do schema canônico. As migrations 008/009 formalizam apenas a projeção necessária para representar corretamente referências por provenance e tipos de unidades de evidência.

---

# 11. Regra para `result_summary`

Para síntese quantitativa adotada, usar payload estruturado:

```json
{
  "summary_type": "adopted_quantitative_estimate",
  "effect_measure": "SMD",
  "effect_value": -0.93,
  "ci_lower": -1.07,
  "ci_upper": -0.79,
  "reported_study_count": 10,
  "heterogeneity_i2": 68,
  "effect_display": "SMD -0,93 (IC95% -1,07 a -0,79)",
  "interpretation": "Efeito favorável à dCBT-I; magnitude grande na síntese publicada.",
  "recalculated_by_oes": false
}
```

Para atualização narrativa:

```json
{
  "summary_type": "narrative_update",
  "direction": "favors_intervention",
  "newly_modelled_studies": 3,
  "pooled_by_oes": false,
  "summary_text": "Os RCTs recentes mantêm direção favorável, com magnitude variável."
}
```

---

# 12. Conclusão arquitetural

O Caso Real 01 pode ser representado no OES-P1 atual sem distorcer a natureza da evidência.

A regra crítica é:

> **adotar uma meta-análise não significa transformá-la em cálculo OES.**

A arquitetura preservará:

- origem externa;
- atualização separada;
- ausência de pooling novo;
- lineage;
- certainty OES própria;
- estado under_review.

---

# 13. Próxima etapa

1. ajustar template para semântica de estudos diretamente modelados;
2. criar dataset SQL do Caso Real 01;
3. executar publication gate;
4. gerar EvidenceSheetView real;
5. renderizar preview;
6. registrar qualquer defeito remanescente.

---

**Decisão consolidada:** nenhuma migration do schema científico canônico foi necessária. As migrations 008/009 são hardening compatível da projeção EvidenceSheetView e foram validadas por regressão e rebuild.
