# 113 — Caso Real N3-01: Segunda Verificação Metodológica Adversarial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**ProductVersion avaliada:** 2  
**Data:** 6 de outubro de 2026  
**Resultado:** **REVISE — bloqueio metodológico por cobertura de busca**  
**Independência:** não independente; execução separada da análise inicial e do primeiro passe  
**Expert independent review:** não realizada

---

# 1. Objetivo

Verificar se a correção exigida no Documento 111 solucionou a insuficiência de cobertura e se a ProductVersion 2 poderia receber `ai_methodological_verification = passed`.

# 2. Correções confirmadas

A ProductVersion 2 incorporou corretamente:

- estratégia suplementar com terminologia ampliada;
- `digital scribe` e variantes de documentação por IA;
- Kanaparthy et al. 2025 como revisão contextual de não duplicação;
- estudos prospectivos/observacionais adicionais;
- 3 Search records;
- 20 hits materializados;
- 34 decisões de screening;
- 13 referências utilizadas/contextuais;
- manutenção do conjunto causal de três RCTs;
- manutenção dos appraisals;
- manutenção das quatro SynthesisVersion;
- manutenção do GRADE experimental 3 LOW + 1 VERY LOW;
- preservação explícita da falha do Europe PMC.

Essas correções foram tecnicamente validadas em RN3-R1-T01–T10.

# 3. Regra metodológica canônica relevante

O Documento 99 estabelece que a busca N3 deverá ser:

> **sistemática, reproduzível, documentada e proporcionalmente abrangente.**

E estabelece como padrão inicial para revisões rápidas de efetividade:

> **pelo menos duas bases bibliográficas relevantes, salvo exceção metodologicamente justificada.**

A regra existe porque N3 não é uma busca seletiva N1/N2.

# 4. Problema residual — segunda base bibliográfica não executada

O protocolo pré-especificou:

- PubMed/MEDLINE;
- Europe PMC.

PubMed foi executado.

Europe PMC não pôde ser executado de forma reproduzível no runtime, nem via API nem via interface acessível.

A substituição utilizada foi:

> publisher/DOI discovery + citation chasing + busca web indexada.

Essa substituição:

- é útil como busca suplementar;
- não equivale a uma segunda base bibliográfica;
- não satisfaz por si só a regra estrutural de cobertura do Documento 99.

# 5. Teste adversarial da exceção

Uma exceção a duas bases poderia ser aceita se houvesse fundamento para considerar a cobertura restante suficientemente defensável.

O segundo passe adversarial testou essa hipótese.

Resultado:

> **a exceção não é defensável neste caso.**

Após a ProductVersion 2, nova varredura independente continuou recuperando estudos ambulatoriais elegíveis que não haviam sido materializados.

Exemplos:

## 5.1 Tan et al. 2026

**Impact of an Ambient AI Scribe Among Clinicians and Patients: Real-World Prospective Observational Time-Motion Study**

- PMID 41915701;
- DOI 10.2196/85580;
- outpatient;
- estudo prospectivo time-motion;
- 9 clínicos;
- 169 consultas;
- redução de documentation time e melhora de eye contact.

## 5.2 Reddy et al. 2026

**Rapid Evaluation of Artificial Intelligence Technology Used for Ambient Dictation in Primary Care: Comparing the Quality of Documentation of Artificial Intelligence-Generated and Human-Produced Clinical Notes**

- PMID 41996184;
- DOI 10.7326/ANNALS-25-02772;
- atenção primária;
- diretamente relevante ao outcome crítico de qualidade da documentação.

## 5.3 North et al. 2025

**Ambient listening implementation in primary care and changes in electronic health record documentation metrics**

- PMID 41323090;
- DOI 10.1177/20552076251403211;
- primary care;
- pre-post;
- documentação/EHR metrics.

## 5.4 Estudos adicionais identificados

Também foram localizados registros ambulatoriais relevantes em populações/contextos distintos, incluindo:

- pediatric outpatient implementation;
- UK general-practice survey com erros/workflow;
- repeated cross-sectional clinician workload/burnout;
- outros estudos de qualidade e experiência.

Esses registros não obrigam, por si só, mudança da estimativa causal principal, mas demonstram que a busca suplementar continuava incompleta.

# 6. Impacto sobre o conjunto causal

Importante:

> **não foi identificado novo RCT comparativo de usual care que substitua ou acrescente de forma material os três estudos randomizados já modelados.**

Portanto permanecem:

- Lukac et al.;
- Afshar et al.;
- Chowdhury et al.

A falha não é uma descoberta de novo efeito randomizado.

A falha é:

> **incapacidade de demonstrar cobertura sistemática proporcional do campo elegível.**

# 7. Appraisal

Os julgamentos centrais permanecem defensáveis:

- Lukac time-in-note: HIGH;
- Lukac workload/burnout: SOME CONCERNS;
- Afshar documentation time: LOW;
- Afshar well-being/WoW: SOME CONCERNS;
- Chowdhury: SOME CONCERNS;
- estudos observacionais não foram elevados a causalidade equivalente.

Não foi identificada correção obrigatória nesses julgamentos neste passe.

# 8. GRADE

Os níveis experimentais continuam plausíveis como exercício:

- documentation time: LOW;
- workload/work exhaustion: LOW;
- work outside work: LOW;
- note quality/safety: VERY LOW.

Entretanto:

> **eles não podem receber AI methodological verification = passed para um produto N3 enquanto a cobertura sistemática requerida não for demonstrada.**

# 9. Conclusão científica

A conclusão continua calibrada e não foi refutada:

> ambient AI scribes podem reduzir documentação/carga em alguns contextos; segurança equivalente não foi demonstrada.

Mas:

> **plausibilidade da conclusão não substitui adequação do método de busca.**

# 10. Decisão adversarial

> **REVISE**

Motivo:

> **search architecture / retrieval coverage insuficiente para N3.**

A ProductVersion 2 não é elegível para `ai_methodological_verification = passed`.

# 11. Bloqueio operacional

Não deverá ser criada ProductVersion 3 apenas por:

- adicionar artigos encontrados incrementalmente;
- aumentar contadores;
- continuar citation chasing indefinidamente.

Isso não resolveria a causa raiz.

A retomada metodologicamente válida exige:

1. acesso a uma segunda base bibliográfica relevante e reproduzível;
2. execução documentada dessa base;
3. deduplicação e triagem do conjunto recuperado;
4. atualização de contextual evidence conforme necessário;
5. nova verificação adversarial.

# 12. Opções futuras válidas

## Opção A — retomar N3

Quando houver segunda base bibliográfica acessível:

- executar a busca;
- criar nova versão apenas se houver mudança material;
- repetir verificação.

## Opção B — manter como caso experimental de validação

O caso já demonstra que:

- o publication gate não é suficiente sozinho para garantir qualidade científica;
- adversarial verification detecta uma limitação não capturada pelo gate estrutural;
- AI quality controls não substituem search coverage;
- o OES recusa elevar assurance quando requisito metodológico não foi cumprido.

## Opção C — rerroteamento

Rerrotear para N4 não resolve a limitação atual porque N4 exigiria cobertura ainda mais rigorosa e controles humanos adicionais.

# 13. Assurance/governança

O estado correto permanece:

> **A0 — experimental — não publicável.**

Continuam ausentes:

- AI methodological verification = passed;
- owner approval relevante à publicação;
- qualified human stage controls;
- expert independent review;
- A3;
- publication_date.

# 14. Próxima etapa

Materializar este segundo `REVISE` na ProductVersion 2 e validar que:

- assurance continua A0;
- histórico dos dois REVISE permanece rastreável;
- conteúdo científico não é alterado;
- publication gate continua bloqueado.

Depois criar checkpoint de encerramento do Caso Real N3 no estado experimental bloqueado.

---

**Resultado final do segundo passe: REVISE — não elegível para A1 no ambiente atual.**