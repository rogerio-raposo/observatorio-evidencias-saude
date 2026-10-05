# 80 — Caso Real N1: Primeira Verificação Metodológica Adversarial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Produto:** Resposta de Evidência — N1  
**Caso:** Caso Real N1-01 — música gravada e ansiedade perioperatória  
**Etapa:** verificação metodológica adversarial assistida por IA  
**Data:** 5 de outubro de 2026  
**Resultado:** **REVISE**  
**Independência:** não independente; execução separada da análise inicial  
**Dependências:** Documentos 75–79 e materialização inicial do caso

---

# 1. Objetivo

Reexaminar criticamente, em etapa separada:

- adequação do roteamento N1;
- correspondência pergunta–fontes;
- appraisal ROBIS;
- extração dos resultados;
- redação da conclusão;
- comunicação de incerteza;
- provenance;
- risco de extrapolação.

Esta verificação não é expert independent review.

---

# 2. Elementos confirmados

Foram confirmados como adequados:

1. pergunta focal e compatível com N1;
2. finalidade informacional, não normativa;
3. fonte decisiva com alta correspondência à pergunta;
4. busca OES explicitamente seletiva e não exaustiva;
5. ausência de nova meta-análise;
6. ausência de GRADE/CERQual artificial;
7. NNT reportado tratado como estimativa transformada, não como evento binário diretamente observado;
8. comparação com benzodiazepínicos excluída da conclusão OES;
9. ROBIS e limitações metodológicas expostos;
10. estudos posteriores usados como atualização seletiva, sem pooling silencioso;
11. owner approval e expert review não inferidos;
12. produto corretamente mantido em A0/under_review.

---

# 3. Issue material 1 — falsa aparência de intervalo entre meta-análises

## Texto problemático

A formulação:

> “Meta-análises de 2026 estimaram efeitos favoráveis de aproximadamente SMD -0,50 a -0,73.”

é concisa, mas pode ser interpretada como se os dois valores formassem um intervalo diretamente comparável de uma mesma estimativa.

## Problema

Stoop et al. e Yu et al.:

- utilizam conjuntos de estudos e decisões analíticas diferentes;
- não representam necessariamente o mesmo estimando;
- Yu et al. remove oito outliers da análise principal;
- Stoop et al. utiliza mudança de ansiedade e possui estrutura analítica própria.

Logo:

> transformar os dois pontos em uma única “faixa” cria uma síntese quantitativa informal que o OES não calculou.

## Correção necessária

Apresentar separadamente:

- Stoop et al.: SMD aproximadamente -0,73;
- Yu et al.: SMD -0,50 em sua análise principal.

E concluir apenas que:

> as duas meta-análises apontam direção favorável, mas a magnitude varia conforme composição e método.

---

# 4. Issue material 2 — força excessiva da atualização pós-cutoff

## Texto problemático

> “Estudos publicados após o cutoff da síntese decisiva mantêm direção geral favorável e não sugerem reversão da conclusão.”

## Problema

A busca pós-cutoff do OES é deliberadamente N1:

- seletiva;
- não exaustiva;
- sem triagem completa de todas as bases;
- sem nova síntese quantitativa.

A frase, sem qualificador explícito, pode ser lida como afirmação sobre todo o corpo posterior.

## Correção necessária

Substituir por formulação do tipo:

> “Na checagem seletiva OES de estudos posteriores ao cutoff, os estudos localizados mantiveram direção geral favorável; não foi identificado sinal que exigisse rerroteamento, sem pretensão de completude.”

---

# 5. ROBIS — revisão adversarial

O julgamento OES de alto risco global permanece defensável para uso operacional N1, desde que entendido como julgamento do OES e não como classificação publicada pelos autores.

Pontos favoráveis do processo da revisão:

- protocolo prospectivo;
- busca ampla;
- seleção duplicada;
- extração duplicada;
- RoB 2;
- random-effects;
- investigação de publication bias.

Pontos que sustentam cautela:

- desfecho autorreferido sem cegamento prático;
- provável alto risco no domínio de mensuração em muitos ensaios;
- funnel plot assimétrico e Egger significativo;
- NNT dependente de transformação do SMD e de CER estimada;
- conclusão publicada sobre similaridade com benzodiazepínicos ultrapassa comparação direta.

Nenhuma mudança no ROBIS é exigida neste passe.

---

# 6. Certainty

A decisão de não criar CertaintyAssessment OES permanece correta.

Não há fundamento para traduzir:

- ROBIS high risk;
- significância estatística;
- consistência direcional;

em nível GRADE inventado.

---

# 7. Provenance

A arquitetura de provenance é adequada:

- key result de Stoop;
- key result de Yu;
- NNT transformado;
- umbrella review;
- revisão metodológica;
- estudos pós-cutoff.

Entretanto, após a correção da conclusão, os valores de Stoop e Yu deverão permanecer apresentados como resultados distintos, não como uma faixa derivada pelo OES.

---

# 8. Roteamento

**N1 permanece adequado.**

As issues encontradas são corrigíveis sem:

- nova meta-análise;
- certainty formal nova;
- busca exaustiva;
- escalonamento para N2/N3.

---

# 9. Decisão

> **REVISE**

O produto não deverá receber AI methodological verification = passed neste estado.

---

# 10. Correções obrigatórias

1. remover a apresentação de SMD -0,50 a -0,73 como faixa única;
2. apresentar as estimativas de Stoop e Yu separadamente;
3. qualificar explicitamente a evidência pós-cutoff como checagem seletiva OES;
4. atualizar ProductVersion.conclusion_text;
5. preservar key results e provenance individualizados;
6. repetir a verificação metodológica em nova execução.

---

# 11. Próxima etapa

Aplicar as correções sem alterar:

- pergunta;
- routing N1/M1;
- ROBIS;
- ausência de certainty formal;
- ausência de owner approval;
- ausência de expert review.

Depois executar segunda verificação metodológica adversarial.

---

**Resultado do primeiro passe: REVISE.**
