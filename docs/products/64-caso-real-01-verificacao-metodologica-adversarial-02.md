# 64 — Caso Real 01: Segunda Verificação Metodológica Adversarial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Tipo de garantia:** `ai_methodological_verification`  
**Passagem:** segunda verificação adversarial, após correções do Documento 63  
**Data:** 4 de outubro de 2026  
**Decisão:** **PASSED**  
**Assurance resultante:** **A1**

---

# 1. Natureza da verificação

Esta é uma segunda passagem metodológica assistida por IA, executada após uma primeira passagem que resultou em `REVISE`.

Ela:

- é separada da análise inicial;
- procura ativamente erros e contraexemplos;
- não é independente no sentido de peer review;
- não constitui expert review;
- não substitui revisão qualificada quando A3 for exigido.

---

# 2. Correção verificada

O erro material encontrado na primeira passagem foi corrigido.

## Hwang / Somzz

Verificação direta do artigo Hwang confirmou:

- busca declarada até 31/03/2024;
- 29 estudos/artigos incluídos apresentados na Tabela 1;
- Shin/Somzz não aparece nessa tabela;
- Shin/Somzz aparece apenas como referência bibliográfica no artigo.

Correções aplicadas:

- retirada a alegação de inclusão pós-cutoff;
- ROBIS Domínio 2 rebaixado de `high_concern` para `unclear_concern`;
- Somzz classificado como RCT de atualização pós-cutoff;
- removidas flags de possible overlap;
- removida a dupla contagem como justificativa para não realizar pooling.

---

# 3. Pergunta e PICO

A pergunta continua focal e coerente:

- adultos com insônia;
- dCBT-I totalmente automatizada;
- educação digital sobre sono/higiene do sono;
- gravidade da insônia;
- pós-tratamento.

Não foi identificada mudança indevida de escopo.

> **PASS**

---

# 4. Busca e seleção

Para N2:

- síntese-base recente identificada;
- busca de atualização executada;
- PubMed/MEDLINE, fonte regional e trial registry consultados;
- estudos-semente recuperados;
- limitações da busca documentadas;
- ausência de hit count bruto não foi convertida em número inventado.

A busca não reivindica exaustividade N4.

> **PASS com limitação explicitada**

---

# 5. ROBIS — Hwang 2025

Julgamento revisado:

- elegibilidade: low concern;
- identificação/seleção: unclear concern;
- coleta/appraisal: unclear concern;
- síntese/achados: unclear concern;
- global: **unclear risk of bias**.

Razões remanescentes:

- fontes adicionais para missing evidence não estão plenamente documentadas no texto principal;
- impacto de exclusões por dados não obtidos permanece incerto;
- subgrupo focal possui I²=68%;
- contribuição do RoB dos estudos do subgrupo não foi reconstruída individualmente pelo OES;
- a revisão não apresenta certainty GRADE formal.

A falsa justificativa temporal foi retirada.

> **PASS**

---

# 6. RoB 2 dos RCTs de atualização

Julgamentos mantidos:

- Sweetman 2024 — algumas preocupações;
- SleepioRx 2025 — algumas preocupações;
- SHUTi OASIS 2025 — algumas preocupações;
- Somzz 2024 — algumas preocupações.

As razões são específicas:

- concealment;
- missing data;
- outcome autorreferido em contexto open-label;
- LOCF.

Conflitos de interesse permanecem separados de RoB 2.

> **PASS**

---

# 7. Síntese

A arquitetura científica permanece defensável:

## Estimativa adotada

Hwang 2025:

- SMD=-0,93;
- IC95% -1,07 a -0,79;
- I²=68%;
- k=10;
- não recalculada pelo OES.

## Corroboração

Gao 2026:

- 15 trials;
- N=3.507;
- SMD global=-0,82;
- trials mais recentes com tendência a efeitos menores;
- heterogeneidade residual baixa.

## Atualização

Quatro RCTs pós-corte/materialmente novos são usados narrativamente.

Não foi realizado pooling parcial.

A decisão de não recalcular meta-análise é proporcional ao N2 porque reconstrução completa do subgrupo exigiria trabalho próximo a N3/N4.

> **PASS**

---

# 8. GRADE

## Risk of bias

Downgrade -1 permanece defensável.

A justificativa não depende mais do erro de cutoff.

Base:

- revisão total com poucos estudos low risk;
- quatro RCTs recentes com algumas preocupações;
- outcome predominantemente autorreferido;
- missing data/concealment em estudos específicos.

## Inconsistency

I²=68% é material.

Entretanto, a certainty é vinculada à afirmação:

> **dCBT-I provavelmente reduz a gravidade da insônia**

e não à afirmação:

> **o efeito verdadeiro é exatamente SMD=-0,93.**

A síntese e a conclusão declaram explicitamente magnitude variável.

Gao 2026 também sustenta direção favorável, com SMD global menor e tendência a efeitos menores em estudos recentes.

Decisão:

> não aplicar segundo downgrade por inconsistency para a afirmação direcional.

Essa decisão deverá ser reavaliada se o OES passar a reivindicar uma magnitude clínica específica.

## Indirectness

Sem preocupação séria para a pergunta global.

## Imprecision

Sem preocupação séria para a direção do efeito; o IC da síntese-base não cruza o nulo.

## Publication bias

Não demonstrado; incerteza residual permanece.

### Certainty

> **MODERADA**

> **PASS**

---

# 9. Conclusão

Redação candidata:

> **A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente nas fontes decisivas, mas a magnitude varia entre estudos.**

Essa redação:

- não transforma SMD=-0,93 em efeito universal;
- não produz recomendação clínica;
- explicita incerteza de magnitude;
- é compatível com certainty moderada.

> **PASS**

---

# 10. Segurança

A Ficha não atribui a certainty do outcome de eficácia à segurança.

Mantém:

> nenhum sinal consistente grave identificado nos estudos recuperados, mas evidência insuficiente para concluir ausência de danos.

> **PASS**

---

# 11. Aplicabilidade

A aplicabilidade ao Brasil permanece separada da validade interna/certainty.

A ausência de RCT brasileiro diretamente aderente é declarada.

Não é usado downgrade automático apenas por ausência de estudo nacional.

> **PASS**

---

# 12. Rastreabilidade

A cadeia permanece reconstruível:

`Question → Investigation → Search → Study/Report → Result → RiskAssessment → Synthesis → Certainty → Product → EvidenceSheetView`

A meta-análise externa permanece explicitamente:

`adopted_external`

e a atualização:

`oes_update`

sem simular repooling.

> **PASS**

---

# 13. Melhor contra-argumento

O melhor argumento contra a certeza moderada é:

> I²=68% no subgrupo comparador-específico, combinado com limitações de RoB e variação considerável dos efeitos novos, poderia justificar um segundo downgrade se o alvo fosse uma magnitude clínica específica ou se a heterogeneidade implicasse conclusões qualitativamente diferentes.

Resposta OES:

- a afirmação foi delimitada à direção do efeito;
- a magnitude é explicitamente descrita como variável;
- nenhuma fonte decisiva identificada inverte a direção;
- uma meta-análise de 2026 corrobora benefício, embora com magnitude menor.

Esse contra-argumento:

> **não exige revisão adicional para a formulação atual, mas deve permanecer registrado.**

---

# 14. Decisão

> **PASSED**

Não foi identificado, após as correções do Documento 63, erro metodológico material não resolvido incompatível com avanço para A1.

---

# 15. Assurance

Registrar:

- assurance_type = `ai_methodological_verification`;
- actor_type = `ai_system`;
- independent_flag = `false`;
- decision = `passed`.

Manter a primeira decisão `revise` como registro superseded para preservar histórico.

Nível resultante:

> **A1 — ai_methodological_reviewed**

Ainda faltam:

- owner governance approval;
- publication_date final.

Expert review:

> **não realizado.**

---

# 16. Próxima etapa

Apresentar ao proprietário:

`templates/owner-governance-approval.md`

O proprietário deverá avaliar apenas:

- aderência da pergunta ao objetivo;
- clareza da conclusão;
- visibilidade da incerteza/limitações;
- transparência sobre IA e ausência de expert review;
- ausência de recomendação não autorizada;
- autorização de publicação interna no OES sob A2.

Ele **não deverá validar tecnicamente ROBIS, RoB 2 ou GRADE**.

---

**Resultado final:** PASSED — Caso Real 01 elegível para A1.
