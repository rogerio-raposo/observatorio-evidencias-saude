# 63 — Caso Real 01: Primeira Verificação Metodológica Adversarial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Tipo de garantia:** `ai_methodological_verification`  
**Passagem:** primeira verificação adversarial após o redesenho A0–A3  
**Data:** 4 de outubro de 2026  
**Decisão:** **REVISE**  
**Assurance após esta decisão:** permanece **A0**

---

# 1. Finalidade

Executar uma segunda passagem metodológica deliberadamente adversarial sobre:

- pergunta/PICO;
- busca e elegibilidade;
- ROBIS;
- RoB 2;
- síntese;
- GRADE;
- conclusão;
- limitações;
- rastreabilidade.

Esta verificação:

> **não é independente e não constitui expert review.**

---

# 2. Achado material

Foi identificada uma premissa incorreta no appraisal ROBIS anterior de Hwang et al. 2025.

O Documento 50 interpretava a presença da referência:

> Shin et al. 2024 — Somzz

como evidência de que um estudo publicado após o cutoff declarado de 31/03/2024 havia sido incluído na revisão/meta-análise.

A rechecagem do artigo completo mostrou:

1. Hwang declara busca até **31 de março de 2024**;
2. a Tabela 1 lista os **29 estudos/artigos incluídos**;
3. Shin/Somzz **não aparece** nessa tabela;
4. Shin aparece na **lista geral de referências** do artigo;
5. portanto, a simples presença da citação não demonstra inclusão na meta-análise.

Conclusão:

> **a alegação de “estudo pós-cutoff incluído” não é sustentada pela evidência verificada e deve ser retirada.**

---

# 3. Impacto no ROBIS

O julgamento anterior do Domínio 2:

> **HIGH CONCERN por inconsistência temporal**

não é defensável com a documentação atualmente verificada.

O Domínio 2 deverá ser reavaliado com base nos fatores realmente observáveis:

- PubMed;
- CENTRAL;
- Embase;
- PsycINFO;
- estratégia completa indicada em suplemento;
- screening em duplicata;
- ausência de evidência clara, no texto principal, de busca em trial registries/literatura cinzenta/citation chasing;
- restrição linguística não suficientemente clara no texto recuperado.

Julgamento revisado candidato:

> **UNCLEAR CONCERN**, não HIGH CONCERN.

O julgamento global ROBIS poderá permanecer:

> **UNCLEAR RISK OF BIAS**

mas por razões diferentes e mais defensáveis.

---

# 4. Impacto sobre Somzz

Somzz 2024 passa a ser tratado como:

> **RCT elegível identificado após o cutoff da busca Hwang e não demonstrado como integrante dos 29 estudos incluídos.**

Consequências:

- retirar `possible_overlap_with_hwang_pooling=true`;
- retirar o bloqueio narrativo que impedia tratá-lo como atualização;
- manter o estudo na atualização OES;
- continuar sem repooling estatístico, pois o OES não reconstruiu integralmente o subgrupo Hwang.

---

# 5. Impacto sobre a síntese

A estimativa-base permanece inalterada:

- SMD=-0,93;
- IC95% -1,07 a -0,79;
- I²=68%;
- k=10.

A decisão de não realizar nova meta-análise OES também permanece defensável porque:

- a estimativa publicada é comparador-específica;
- os estudos novos usam formatos/estimandos heterogêneos;
- N2 não exige reconstrução integral do pooling;
- o objetivo é atualização rastreável, não produção de uma nova revisão N3/N4.

A justificativa “risco de dupla contagem de Somzz” deve, entretanto, ser removida.

---

# 6. Impacto sobre GRADE

O erro encontrado:

- afeta a justificativa do ROBIS;
- não altera diretamente os RoB 2 dos RCTs;
- não elimina as preocupações de risk of bias do corpo de evidências.

O downgrade provisório de 1 nível por risk of bias **pode permanecer**, pois ainda existem:

- poucos estudos inequivocamente low risk na revisão-base;
- RCTs recentes classificados com algumas preocupações;
- outcome predominantemente autorreferido;
- missing data/concealment em estudos específicos.

Entretanto, qualquer justificativa que cite a falsa inconsistência de cutoff deverá ser removida.

Certainty provisória candidata após correção:

> **MODERADA**

---

# 7. Impacto sobre a conclusão

Não foi identificado motivo para inverter a conclusão.

A direção continua sustentada por:

- meta-análise comparador-específica;
- meta-análise corroborativa;
- RCTs recentes diretamente aderentes.

A conclusão permanece candidata a:

> benefício provável, com magnitude variável.

---

# 8. Melhor contra-argumento

O melhor argumento contra a conclusão atual é:

> a estimativa quantitativa-base apresenta heterogeneidade relevante, o subgrupo focal não possui RoB reconstruído estudo a estudo no OES e os RCTs recentes mostram amplitudes de efeito bastante diferentes.

Esse argumento:

- não demonstra ausência de benefício;
- reduz a confiança na magnitude exata;
- sustenta comunicação cautelosa;
- não exige, neste N2, inverter a direção da conclusão.

---

# 9. Decisão da verificação

> **REVISE**

Motivo:

foi identificado erro material na justificativa metodológica do ROBIS e no tratamento de Somzz como potencialmente sobreposto ao pooling Hwang.

Não classificar como `failed`, porque:

- a pergunta permanece válida;
- os dados principais continuam rastreáveis;
- a estimativa publicada está correta;
- a direção da síntese permanece sustentada;
- o problema é corrigível sem reconstruir a investigação.

---

# 10. Correções obrigatórias antes de nova verificação

1. corrigir Documento 49;
2. corrigir Documento 50;
3. corrigir Documento 51;
4. corrigir Documento 52;
5. corrigir Documentos 53 e 54 onde dependentes;
6. corrigir dataset SQL do Caso Real 01;
7. remover flags de possible overlap de Somzz;
8. atualizar ROBIS Domain 2;
9. rerodar toda a regressão;
10. repetir a verificação metodológica adversarial.

---

# 11. Assurance

Como a decisão é `REVISE`:

> **não criar assurance_record `passed`.**

O Caso Real 01 permanece:

- assurance **A0**;
- `under_review`;
- `publishable=false`.

---

**Resultado:** REVISE — correção metodológica necessária antes de A1.
