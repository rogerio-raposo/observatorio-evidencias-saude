# 107 — Caso Real N3-01: Busca Definitiva Rápida, Desvio de Protocolo e Seleção

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**Data:** 5 de outubro de 2026  
**Data de corte:** 2026-10-05  
**Status:** busca/seleção experimental concluída; appraisal pendente

---

# 1. Regra de interpretação

Este registro documenta a busca executável no ambiente disponível e **não declara completude equivalente a uma N4**.

Não foram inventados:

- hit counts;
- registros não observados;
- cobertura de Europe PMC;
- dupla triagem humana;
- peer review humano da estratégia.

# 2. Busca 1 — PubMed/MEDLINE

Fonte:

> **PubMed/MEDLINE**

Período alvo:

> **2025-01-01 a 2026-10-05**

Estratégia conceitual:

`("ambient AI" OR "ambient artificial intelligence" OR "ambient scribe" OR "AI scribe" OR "ambient listening") AND (documentation OR note OR "clinical note" OR EHR OR "electronic health record") AND (physician OR clinician OR provider OR practitioner) AND (time OR workload OR burnout OR quality OR accuracy)`

Execução:

- pesquisa bibliográfica orientada por termos;
- recuperação e verificação de registros PubMed individualizados;
- citation chasing seletivo de estudos e revisão-base.

`result_count`:

> **não disponível de forma reproduzível no runtime; manter NULL.**

# 3. Busca 2 prevista — Europe PMC

O protocolo previa Europe PMC como segunda fonte bibliográfica.

Durante a execução, a interface disponível não permitiu executar/recuperar de modo reproduzível a busca parametrizada no Europe PMC.

Esse fato constitui:

> **desvio de protocolo — source_access_failure**

e não deve ser ocultado.

# 4. Desvio de protocolo

## Código

`EUROPE_PMC_RUNTIME_ACCESS_FAILURE`

## Estágio

`search`

## Estado

> **resolved_with_mitigation para fins experimentais; permanece limitação material.**

## Impacto potencial

- perda de registros não recuperados pelo PubMed;
- cobertura menor que a prevista;
- redução da reprodutibilidade externa da segunda fonte;
- risco de selection/retrieval bias.

## Mitigação

Substituição operacional por:

> **busca suplementar em páginas editoriais/índices de DOI + citation chasing da revisão-base e dos estudos principais.**

A substituição:

- não é chamada de Europe PMC;
- não é tratada como equivalente a Embase/Scopus;
- não satisfaz peer review qualificado de busca;
- permanece explicitamente registrada como rapid-method limitation.

# 5. Revisão-base para não duplicação

**Bracken A et al. 2025 — Artificial Intelligence (AI) – Powered Documentation Systems in Healthcare: A Systematic Review**

- J Med Syst. 2025;49:28;
- DOI 10.1007/s10916-025-02157-4;
- 11 estudos incluídos;
- busca em PubMed, Embase e Cochrane;
- literatura predominantemente anterior aos RCTs peer-reviewed mais recentes;
- escopo inclui ChatGPT e ambient AI, sendo mais amplo que a pergunta focal.

Decisão:

> **usar como fonte contextual, checagem de não duplicação e citation chasing; não usar como unidade de efeito independente.**

# 6. Registros materiais capturados

Dez registros materiais foram capturados para triagem dirigida.

Esse número representa:

> **conjunto materializado no OES, não número total de resultados recuperados pelas fontes.**

# 7. Incluídos — síntese comparativa principal

## 7.1 Lukac et al. 2025

**Ambient AI Scribes in Clinical Practice: A Randomized Trial**

- NEJM AI;
- PMID 41497288;
- DOI 10.1056/aioa2501000;
- 238 médicos ambulatoriais;
- três braços: DAX, Nabla, usual care;
- outcome primário: change in log time-in-note;
- elegível para comparação ambient scribe versus usual care.

Status:

> **INCLUDE — primary comparative RCT**

## 7.2 Afshar et al. 2025

**A Pragmatic Randomized Controlled Trial of Ambient Artificial Intelligence to Improve Health Practitioner Well-Being**

- NEJM AI;
- PMID 41625485;
- DOI 10.1056/aioa2500945;
- 66 profissionais;
- stepped-wedge, individually randomized pragmatic trial;
- clínicas ambulatoriais em dois estados;
- outcomes: professional fulfillment, work exhaustion/interpersonal disengagement, note time, work outside work e PDSQI-9.

Status:

> **INCLUDE — primary comparative randomized evidence**

## 7.3 Chowdhury et al. 2026

**Comparing ambient scribes: a randomized crossover clinical trial addressing ambient scribe technologies' impact on physician burnout**

- JAMIA. 2026;33(5):990–999;
- PMID 41729180;
- DOI 10.1093/jamia/ocag018;
- 160 clínicos ambulatoriais randomizados em crossover;
- comparação entre duas tecnologias ambient scribe;
- não possui usual-care contemporâneo como comparação principal.

Status:

> **INCLUDE — secondary head-to-head randomized stratum**

Regra:

> não combinar automaticamente esse estudo com os RCTs ambient-versus-usual-care.

# 8. Incluídos — evidência contextual

## 8.1 Stults et al. 2025

**Evaluation of an Ambient Artificial Intelligence Documentation Platform for Clinicians**

- JAMA Netw Open. 2025;8:e258614;
- PMID 40314951;
- DOI 10.1001/jamanetworkopen.2025.8614;
- estudo de melhoria da qualidade, pré/pós;
- 100 clínicos; 57 com surveys pareados;
- dados EHR pré e pós-implementação.

Status:

> **INCLUDE — contextual implementation evidence only**

Não será usado como equivalente a RCT para certeza causal.

## 8.2 Taylor et al. 2026

**Quality of Clinical Notes Created by Ambient Listening Generative AI: Pragmatic Prospective Pilot Study**

- JMIR Med Inform. 2026;14:e86474;
- PMID 41996389;
- DOI 10.2196/86474;
- 31 médicos;
- 7545 notas geradas; 356 avaliadas formalmente;
- foco em omissões, hallucinations, inclusões acidentais, bias e gravidade potencial.

Status:

> **INCLUDE — contextual note-quality/safety evidence only**

Não será combinado com estimativas randomizadas de workload/documentation time.

# 9. Incluído apenas como revisão contextual

Bracken et al. 2025:

> **INCLUDE — contextual systematic review / citation source**

Não entra como estudo independente na síntese de efeito.

# 10. Exclusões materiais

## 10.1 Lukac et al. medRxiv 2025

**A Randomized-Clinical Trial of Two Ambient Artificial Intelligence Scribes...**

- PMID 40672471;
- DOI 10.1101/2025.07.10.25331333.

Motivo:

> **duplicate_report — preprint do estudo posteriormente publicado em NEJM AI.**

## 10.2 Preiksaitis et al. 2026

**Ambient Artificial Intelligence Scribe Adoption and Documentation Time in the Emergency Department**

- PMID 41665590;
- DOI 10.1016/j.annemergmed.2025.12.017.

Motivo:

> **wrong_setting — emergency department; setting principal pré-especificado é ambulatorial.**

## 10.3 Morey et al. 2026

**Ambient Artificial Intelligence Versus Human Scribes in the Emergency Department**

- PMID 41251650;
- DOI 10.1016/j.annemergmed.2025.10.006.

Motivo:

> **wrong_setting — emergency department.**

## 10.4 Ambient AI Scribes in the Emergency Department: A Scoping Review of Current Evidence

- PMID 42585863;
- revisão de contexto ED.

Motivo:

> **wrong_setting + secondary_review_not_update_unit.**

# 11. Fluxo de seleção materializado

Registros materiais capturados:

> **10**

Classificação:

- 3 RCTs/comparative randomized studies → síntese principal/secondary comparator stratum;
- 2 estudos prospectivos/QI → contexto de implementação/qualidade;
- 1 revisão sistemática → contexto/não duplicação/citation chasing;
- 4 registros excluídos com motivo explícito.

Importante:

> **este fluxo não é apresentado como PRISMA completo nem como total de hits da busca.**

# 12. Cobertura dos outcomes

## Documentation time / time-in-note

Cobertura direta:

- Lukac;
- Afshar;
- Chowdhury head-to-head;
- Stults contextual.

## Work outside work / after-hours

Cobertura direta:

- Afshar;
- Chowdhury head-to-head.

## Workload/burnout

Cobertura direta:

- Lukac;
- Afshar;
- Chowdhury;
- Stults contextual.

## Note quality / safety

Cobertura:

- Lukac — clinician-reported inaccuracies/safety;
- Afshar — PDSQI-9/billing quality;
- Taylor — dedicated prospective safety/quality assessment;
- Chowdhury não é fonte principal de segurança.

# 13. Decisão sobre meta-análise

Após seleção, permanece a decisão pré-especificada:

> **não realizar nova meta-análise na etapa inicial.**

Razões:

- diferentes desenhos randomizados;
- diferentes produtos;
- outcomes e escalas diferentes;
- medidas de tempo em unidades/transformações diferentes;
- Chowdhury é head-to-head, não usual-care;
- heterogeneidade clínica e operacional relevante.

Será usada síntese narrativa estruturada/SWiM.

# 14. Limitações da busca/seleção

- Europe PMC não executado conforme protocolo;
- segundo canal substituto menos padronizado;
- result_count das buscas indisponível;
- conjunto materializado não equivale ao universo total recuperado;
- triagem e verificação executadas por IA;
- ausência de segundo revisor humano qualificado;
- ausência de search-strategy peer review humano qualificado;
- inglês predominante.

# 15. Status do quality control

Até esta etapa:

- busca executada por IA;
- seleção executada por IA;
- segunda passagem de IA será registrada na materialização;
- **qualified human search verification: ausente**;
- **qualified human screening pilot: ausente**;
- **qualified human secondary screening: ausente**.

# 16. Próxima etapa

> **Appraisal dos três estudos randomizados + avaliação crítica proporcional das evidências contextuais.**

Somente depois serão produzidas síntese e certainty experimentais.

---

**Decisão:** seleção suficientemente estruturada para prosseguir no modo N3 experimental, mas incompatível com publicação formal.