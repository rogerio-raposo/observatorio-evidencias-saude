# 108 — Caso Real N3-01: Appraisal Experimental dos Estudos Incluídos

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**Data:** 5 de outubro de 2026  
**Status:** appraisal experimental concluído; sem verificação humana qualificada

---

# 1. Regra de garantia

Todos os julgamentos abaixo foram executados pelo OES assistido por IA.

> **Nenhum appraisal deste caso foi verificado por segundo avaliador humano qualificado.**

Consequência:

- os julgamentos podem sustentar desenvolvimento experimental;
- não satisfazem o quality control formal de N3;
- não autorizam publicação;
- deverão permanecer identificados como `ai_verified`/experimental na materialização.

# 2. Frameworks

## RCTs

> **RoB 2 — avaliação por outcome.**

Domínios:

- D1 — processo de randomização;
- D2 — desvios das intervenções pretendidas;
- D3 — dados de outcome ausentes;
- D4 — mensuração do outcome;
- D5 — seleção do resultado reportado.

## Estudos contextuais

Não serão artificialmente enquadrados como RCT.

Será usada avaliação proporcional ao desenho, com foco no risco de usar o estudo para inferência causal ou frequência de dano.

# 3. Lukac et al. 2025 — time-in-note

Identificador:

- PMID 41497288;
- DOI 10.1056/aioa2501000.

## D1 — randomização

> **SOME CONCERNS**

Razões:

- covariate-constrained randomization descrita;
- grupos contemporâneos;
- porém o registro do ensaio foi submetido após o início do estudo;
- protocolo final existe, mas a ausência de preregistration tempestiva aumenta preocupação de seleção de análise/outcome.

## D2 — desvios da intervenção

> **LOW RISK** para efeito de assignment

- análise ITT;
- baixa utilização real do scribe faz parte do efeito pragmático de assignment;
- não foi identificada exclusão pós-randomização capaz de explicar o efeito primário.

## D3 — dados ausentes

> **LOW RISK** para o outcome objetivo de EHR

O outcome primário deriva de métricas de EHR e a análise principal incorpora os participantes randomizados conforme assignment.

## D4 — mensuração

> **HIGH RISK**

O artigo informa que a métrica Epic Signal de `time-in-note` não capturava tempo de edição realizado dentro das plataformas dos scribes.

Isso é material porque:

- a omissão ocorre somente nos braços de intervenção;
- o tempo real de documentação pode ser subestimado nos grupos ambient AI;
- o viés potencial favorece a intervenção.

## D5 — seleção do resultado

> **SOME CONCERNS**

Principal motivo:

- registro pós-início do ensaio.

## Julgamento global — time-in-note

> **HIGH RISK OF BIAS**

O high risk é determinado principalmente por D4.

# 4. Lukac et al. 2025 — workload/burnout

## D1

> SOME CONCERNS — registro pós-início.

## D2

> LOW RISK — ITT pragmático.

## D3

> SOME CONCERNS

Poststudy surveys foram respondidos por proporções inferiores a 100%; não há evidência suficiente para assumir ausência completa de viés de nonresponse.

## D4

> SOME CONCERNS

- estudo open-label;
- outcomes autorreferidos;
- conhecimento da intervenção pode influenciar Mini-Z, PTL e PFI-WE.

## D5

> SOME CONCERNS — preregistration tardia.

## Julgamento global — workload/burnout

> **SOME CONCERNS**

# 5. Afshar et al. 2025 — documentação objetiva

Identificador:

- PMID 41625485;
- DOI 10.1056/aioa2500945;
- NCT06517082.

## D1

> **LOW RISK**

- registro ClinicalTrials.gov em 9 de agosto de 2024;
- início do trial em agosto de 2024;
- stratified permuted-block randomization;
- três sequências stepped-wedge;
- endpoints pré-especificados.

## D2

> **LOW RISK**

- análise ITT;
- transições de acesso definidas pela randomização;
- não foram reportados desvios de endpoints pré-especificados.

## D3

> **LOW RISK** para métricas de EHR

Grande volume de notas e métricas operacionais derivadas do EHR.

## D4

> **LOW RISK** para tempo em notas

Outcome objetivo registrado por EHR; não depende de autorrelato.

## D5

> **LOW RISK**

- endpoints pré-especificados;
- statistical analysis plan publicamente disponibilizado;
- autores afirmam ausência de desvio dos endpoints planejados.

## Julgamento global — documentation time

> **LOW RISK OF BIAS**

# 6. Afshar et al. 2025 — work exhaustion / professional fulfillment

## D1

> LOW RISK.

## D2

> LOW RISK para efeito de assignment.

## D3

> LOW RISK / SOME CONCERNS limítrofe

Não foi identificado sinal material de missing outcome capaz de explicar o resultado, mas o tamanho da amostra é pequeno.

## D4

> **SOME CONCERNS**

- desenho open-label;
- PFI é validado, mas autorreferido;
- expectancy/Hawthorne effects são explicitamente reconhecidos pelos autores.

## D5

> LOW RISK.

## Julgamento global — well-being outcomes

> **SOME CONCERNS**

# 7. Afshar et al. 2025 — work outside work

Julgamento adicional:

> **SOME CONCERNS**

Motivo:

- a estimativa favoreceu ambient AI;
- o resultado foi sensível à remoção dos 3% de observações diárias mais extremas;
- portanto a robustez quantitativa desse outcome específico é limitada.

Isso não invalida os demais outcomes.

# 8. Chowdhury et al. 2026 — documentation time head-to-head

Identificador:

- PMID 41729180;
- DOI 10.1093/jamia/ocag018.

## D1

> **LOW RISK**

- 2×2 crossover;
- randomização estratificada;
- block size 4;
- allocation via REDCap;
- baseline groups equilibrados nos fatores medidos.

## D2

> **SOME CONCERNS**

- não houve período scribe-free de washout;
- autores reconhecem potencial carryover;
- feature upgrades durante o trial também podem introduzir variação temporal.

## D3

> **LOW RISK** para métricas objetivas de EHR

Missingness foi pequena para minutes-in-notes e outras signal metrics.

## D4

> **LOW RISK** para métricas objetivas de EHR

As medidas derivam de Epic Signal.

## D5

> **SOME CONCERNS**

- protocolo institucional é citado;
- não foi localizada preregistration pública equivalente aos RCTs NEJM AI;
- houve interim analysis para planejamento orçamentário, declaradamente sem alterar allocation/sample size/analysis plan.

## Julgamento global — documentação head-to-head

> **SOME CONCERNS**

# 9. Chowdhury et al. 2026 — burnout/satisfaction

## D3

> **SOME CONCERNS**

- 24/160 participantes não forneceram nenhuma das duas surveys pós-produto e foram excluídos das análises de survey.

## D4

> **SOME CONCERNS**

- open-label;
- participantes e assessores conheciam a intervenção;
- outcomes de satisfação/burnout são autorreferidos.

## Carryover

> **SOME CONCERNS**

Ausência de washout scribe-free pode influenciar especialmente outcomes subjetivos e burnout, como reconhecido pelos autores.

## Julgamento global — burnout/satisfaction

> **SOME CONCERNS**

# 10. Stults et al. 2025 — contextual implementation evidence

Identificador:

- PMID 40314951;
- DOI 10.1001/jamanetworkopen.2025.8614.

Desenho:

- qualidade/melhoria;
- pré/pós;
- sem randomização contemporânea.

Julgamento:

> **HIGH RISK para inferência causal de eficácia.**

Principais razões:

- confounding secular;
- self-selection/early adopter effects;
- survey pareada disponível em subconjunto;
- ausência de comparador randomizado.

Uso autorizado no N3:

> contexto de implementação e coerência externa; não elevar certainty dos RCTs.

# 11. Taylor et al. 2026 — contextual safety/note quality

Identificador:

- PMID 41996389;
- DOI 10.2196/86474.

Desenho:

- prospective pilot/QI;
- 7545 notas geradas;
- 356 notas avaliadas formalmente por médicos.

Julgamento:

> **HIGH RISK para estimar frequência populacional precisa de erros.**

Razões:

- amostra avaliada corresponde a 4,7% das notas;
- processo de seleção das notas avaliadas pode gerar selection bias;
- instrumento foi desenvolvido para o projeto;
- médicos usuários avaliaram as notas;
- ausência de comparador independente para todas as notas.

Uso autorizado:

> evidência contextual de que omissões/hallucinations/erros potencialmente graves podem ocorrer e exigem revisão clínica.

Não usar:

> como estimativa definitiva da taxa de dano de ambient AI scribes.

# 12. Bracken et al. 2025 — revisão sistemática-base

Uso:

- não duplicação;
- contexto histórico;
- citation chasing.

Appraisal proporcional:

- três bases pesquisadas;
- dois revisores independentes na seleção;
- extração/appraisal por dois autores;
- MMAT aplicado aos estudos;
- heterogeneidade grande entre ChatGPT e ambient AI;
- quality/efficiency outcomes medidos de formas muito diferentes.

Julgamento OES contextual:

> **ROBIS preliminar: SOME CONCERNS**, principalmente na interpretação/síntese ampla de um conjunto altamente heterogêneo.

Importante:

> essa revisão não é fonte decisiva para os efeitos atualizados do Caso Real N3.

# 13. Síntese dos julgamentos

| Estudo/outcome | Julgamento OES | Uso |
|---|---|---|
| Lukac — time-in-note | HIGH | efeito comparativo; downgrade material |
| Lukac — burnout/workload | SOME CONCERNS | efeito comparativo |
| Afshar — documentation time | LOW | efeito comparativo principal |
| Afshar — well-being | SOME CONCERNS | efeito comparativo principal |
| Afshar — WoW | SOME CONCERNS | efeito comparativo secundário/sensível |
| Chowdhury — documentation head-to-head | SOME CONCERNS | comparação de fornecedores |
| Chowdhury — burnout/satisfaction | SOME CONCERNS | comparação de fornecedores |
| Stults — pre/post | HIGH para causalidade | contexto |
| Taylor — safety frequency | HIGH para frequência exata | contexto de segurança |
| Bracken — systematic review | SOME CONCERNS preliminar | contexto/não duplicação |

# 14. Quality control

Estado:

- appraisal executor: OES/IA;
- segunda passagem: OES/IA;
- qualified human RoB verification: **ausente**;
- expert independent review: **ausente**.

Portanto:

> **o gate N3 formal deve permanecer bloqueado.**

# 15. Próxima etapa

> **Síntese narrativa estruturada/SWiM + GRADE experimental dos outcomes críticos.**

Meta-análise nova permanece não indicada.

---

**Status:** appraisal suficiente para prosseguir no modo experimental; não apto a publicação formal.