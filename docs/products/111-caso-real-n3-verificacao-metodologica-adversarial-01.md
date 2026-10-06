# 111 — Caso Real N3-01: Primeira Verificação Metodológica Adversarial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**ProductVersion avaliada:** 1  
**Data:** 6 de outubro de 2026  
**Resultado:** **REVISE**  
**Independência:** não independente; execução separada da análise inicial  
**Expert independent review:** não realizada

---

# 1. Objetivo

Executar segunda passagem metodológica adversarial sobre:

- adequação do roteamento N3;
- aderência ao protocolo;
- suficiência da mitigação após falha do Europe PMC;
- risco de missing studies;
- seleção;
- appraisal;
- resultados extraídos;
- síntese narrativa;
- GRADE experimental;
- conclusão;
- governança e assurance.

Esta etapa não é expert independent review.

# 2. Elementos confirmados

Foram confirmados como adequados:

1. escolha de N3 para uma atualização rápida orientada à decisão;
2. protocolo pré-especificado antes da busca definitiva;
3. rapid restrictions explícitas;
4. ausência de meta-análise artificial;
5. separação entre ambient-versus-usual-care e head-to-head;
6. uso contextual — e não causal equivalente — de estudos não randomizados;
7. appraisal diferenciado por desenho/outcome;
8. RoB alto para `time-in-note` de Lukac devido à mensuração incompleta do tempo na plataforma;
9. preocupação moderada em outcomes autorreferidos/open-label;
10. GRADE experimental conservador;
11. conclusão calibrada sobre eficiência e segurança;
12. seis quality controls por IA corretamente marcados como não qualificados;
13. A0/non-publishable preservado.

# 3. Confirmação do appraisal de Lukac

O artigo final informa que:

- o ensaio ocorreu de novembro de 2024 a janeiro de 2025;
- o registro NCT06792890 foi submetido após o início e publicado apenas em janeiro de 2025;
- o Epic Signal não contabilizava tempo de edição dentro da plataforma dos scribes;
- os autores reconhecem que o `time-in-note` pode superestimar economia de tempo;
- o poststudy survey pode sofrer nonresponse bias.

Resultado adversarial:

> **appraisal OES permanece defensável.**

# 4. Confirmação do appraisal de Afshar

O ensaio:

- foi registrado no ClinicalTrials.gov em 9 de agosto de 2024;
- iniciou posteriormente em agosto de 2024;
- utilizou randomização estratificada;
- pré-especificou endpoints;
- realizou ITT;
- publicou SAP e código;
- reconhece que o efeito de work outside work é sensível à remoção das observações extremas.

Resultado adversarial:

> **appraisal OES permanece defensável.**

# 5. Issue material 1 — checagem de não duplicação incompleta

A primeira execução usou Bracken et al. 2025 como revisão-base.

A busca adversarial identificou também:

**Kanaparthy et al. 2025 — Real-World Evidence Synthesis of Digital Scribes Using Ambient Listening and Generative Artificial Intelligence for Clinician Documentation Workflows: Rapid Review**

- PMID 41071988;
- DOI 10.2196/76743;
- busca em Ovid MEDLINE, Embase, Web of Science, Cochrane CENTRAL/Reviews e PubMed Central;
- período 2014–2024;
- 1450 registros;
- 6 estudos incluídos;
- foco específico em digital/ambient scribes no mundo real.

Problema:

> a revisão é diretamente relevante para checagem de não duplicação e contexto histórico do N3, mas não foi incluída na primeira execução.

Importante:

> ela não invalida a escolha N3, porque sua cobertura termina em 2024 e não inclui os RCTs peer-reviewed decisivos publicados depois.

Correção necessária:

> incluir Kanaparthy 2025 como fonte contextual de não duplicação/citation chasing.

# 6. Issue material 2 — mitigação após falha do Europe PMC foi insuficientemente sensível

O protocolo previa PubMed + Europe PMC.

Europe PMC falhou no runtime e foi substituído por:

> busca direcionada em publisher/DOI + citation chasing.

A busca adversarial localizou pelo menos dois estudos prospectivos ambulatoriais elegíveis ao estrato contextual que não foram capturados:

## 6.1 van Linschoten et al. 2026

**Ambient scribe in general practice: a multi-perspective before-after longitudinal mixed-methods study**

- PMID 41772212;
- DOI 10.1038/s41746-026-02454-3;
- estudo prospectivo multicêntrico before-after;
- 12 GPs/GPs in training;
- 535 consultas;
- redução de tempo de documentação;
- relato de summaries inexatos e necessidade de revisão.

## 6.2 Harvey et al. 2026

**Ambient AI Scribe Implementation in an Ambulatory Setting in a Single Medical Group: Prospective Study**

- PMID 42337645;
- DOI 10.2196/84104;
- 80 providers;
- >25.000 notas;
- cenário ambulatorial;
- tempo de notas e pajama time reduzidos entre usuários frequentes;
- sem diferença clara em sintomas de burnout;
- contexto de qualidade e patient experience.

Problema:

> ambos são compatíveis com o protocolo como evidência contextual de implementação/qualidade e deveriam ter sido triados.

Conclusão adversarial:

> **a mitigação não demonstrou sensibilidade suficiente para sustentar A1 neste estado.**

# 7. Causa provável da perda

A estratégia conceitual original enfatizou:

- `ambient AI`;
- `ambient artificial intelligence`;
- `ambient scribe`;
- `AI scribe`;
- `ambient listening`.

Ela não enfatizou adequadamente termos como:

- `digital scribe`;
- `AI-powered documentation`;
- `AI documentation system`;
- `generative AI documentation`;
- `ambient documentation`.

Correção necessária:

> ampliar o bloco de intervenção/documentação e executar busca suplementar documentada.

# 8. Impacto sobre síntese e GRADE

Até este passe:

> **não foi identificado novo RCT comparativo que obrigue alteração imediata do conjunto de efeito principal.**

Os estudos adicionais identificados são contextuais/prospectivos.

Portanto:

- não há motivo atual para alterar os três RCTs principais;
- não há motivo atual para criar pooling;
- o GRADE LOW/LOW/LOW/VERY LOW permanece provisoriamente defensável;
- esses julgamentos deverão ser rechecados após a busca suplementar completa.

# 9. Conclusão científica

A redação:

> ambient AI scribes podem reduzir tempo de documentação e alguns componentes de carga/exaustão, enquanto segurança permanece muito incerta

continua compatível com as fontes verificadas.

Não foi identificada necessidade de tornar a conclusão mais favorável.

Também não foi identificada evidência que permita afirmar segurança equivalente.

# 10. Governança

Resultado:

> **PASS quanto à transparência de governança.**

- nenhum controle humano qualificado foi fabricado;
- expert review ausente;
- A3 ausente;
- publication_date ausente;
- produto corretamente em A0;
- renderização real exibe blockers.

# 11. Decisão

> **REVISE**

A ProductVersion 1 não deverá receber `ai_methodological_verification = passed`.

# 12. Correções obrigatórias

1. registrar este primeiro passe adversarial como `revise` na ProductVersion 1;
2. ampliar termos da busca suplementar para incluir `digital scribe` e variantes de AI documentation;
3. executar nova busca suplementar documentada;
4. incluir Kanaparthy et al. 2025 como contexto/não duplicação;
5. triar van Linschoten et al. 2026 e Harvey et al. 2026;
6. incorporar os elegíveis como contexto, sem tratá-los como RCTs;
7. atualizar contadores de seleção e referências;
8. preservar estudos excluídos com motivos;
9. reavaliar se novos estudos alteram appraisal/síntese/GRADE;
10. criar ProductVersion 2 corrigida;
11. repetir a verificação metodológica adversarial.

# 13. O que não deve ser alterado automaticamente

- pergunta;
- routing N3/M1;
- três RCTs principais;
- decisão de não meta-analisar;
- RoB de Lukac/Afshar/Chowdhury;
- GRADE, salvo se a nova busca trouxer evidência materialmente nova;
- blockers humanos/A3.

---

**Resultado do primeiro passe:** REVISE.