# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Metodológica

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP05  
**Checkpoint anterior:** CP04  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — síntese de evidências  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP05

Estado formal:

> **Fase 0 — Concepção e fundamentos: EM DESENVOLVIMENTO**  
> **Documentos 00–03: CONSOLIDADOS COMO DOCUMENTOS VIVOS**  
> **Documento 10 — Busca e Recuperação: CONSOLIDADO**  
> **Documento 11 — Elegibilidade, Triagem e Seleção: CONSOLIDADO**  
> **Documento 12 — Risco de Viés e Qualidade Metodológica: CONSOLIDADO**  
> **Documento 13 — Extração e Estruturação de Dados: CONSOLIDADO**  
> **Documento 14 — Síntese de Evidências: CONSOLIDADO**  
> **Documento 15 — Certeza/Confiança no Corpo de Evidências: NÃO INICIADO**

Base documental do checkpoint:

`main @ e68a40a63343be71ef5e98f5847392aa5bbd660f`

---

# 2. Novos artefatos desde CP04

- `docs/methodology/14-sintese-evidencias.md`
- `templates/synthesis-record.md`

Também foram atualizados:

- `README.md`
- `STATE.md`
- `CHANGELOG.md`
- `docs/README.md`
- `templates/README.md`
- `references/fontes-metodologicas.md`

---

# 3. Decisões consolidadas no Documento 14

1. síntese não é sinônimo de meta-análise;
2. combinabilidade será julgada clínica, metodológica e estatisticamente;
3. não haverá score universal de combinabilidade;
4. cada síntese terá unidade analítica explícita;
5. common/fixed-effect versus random-effects não será escolhido por teste de heterogeneidade ou corte de I²;
6. random-effects deverá ser interpretado conjuntamente com heterogeneidade e, quando apropriado, intervalo de predição;
7. I² não será regra automática de decisão;
8. subgrupos serão preferencialmente pré-especificados e avaliados por interação;
9. meta-regressão será usada com parcimônia;
10. análises de sensibilidade testarão robustez, não escolherão retrospectivamente a conclusão;
11. risco de viés deverá influenciar interpretação e análises;
12. missing evidence será separado do risco de viés interno;
13. funnel plot não será tratado como diagnóstico automático de publication bias;
14. eventos raros exigem métodos específicos;
15. múltiplos braços e estimativas correlacionadas deverão ser tratados sem dupla contagem;
16. network meta-analysis exigirá avaliação de transitivity e coherence;
17. SWiM será referência para relato de síntese quantitativa sem meta-análise;
18. vote counting por significância estatística será evitado;
19. DTA, prognóstico, predição, prevalência/incidência e qualitativos seguirão métodos especializados;
20. JBI meta-aggregation será abordagem candidata para síntese qualitativa compatível;
21. efeitos absolutos serão apresentados quando úteis;
22. significância estatística não será confundida com importância clínica, causalidade ou certeza;
23. N3–N4 exigirão análise reproduzível e versionada;
24. IA poderá auxiliar, mas não decidirá silenciosamente combinabilidade, modelo ou conclusão.

---

# 4. Arquitetura de síntese ativa

Estrutura conceitual:

`Study/Result → Synthesis ID → efeito/síntese → Risk of Bias profile → Certainty assessment`

Identificador provisório:

`OES-SY-AAAA-NNNNNN`

Cada síntese deverá manter:

- Result IDs;
- Study IDs;
- pergunta;
- desfecho;
- timepoint;
- métrica;
- modelo;
- software/versão;
- parâmetros/código;
- Risk of Bias Records;
- análises de sensibilidade;
- versionamento.

---

# 5. Regras estatísticas de alto nível

- modelo não será escolhido pelo p-valor de heterogeneidade;
- I² será descritivo e contextual, não gate automático;
- tau/tau² serão considerados em random-effects;
- prediction intervals serão considerados quando apropriados;
- subgrupos deverão ser avaliados por interação;
- meta-regressão exige número suficiente de estudos;
- funnel plot asymmetry possui múltiplas explicações;
- eventos raros não possuem método universal;
- multi-arm exige correção de dependência;
- análises avançadas exigirão capacidade estatística adequada.

---

# 6. Síntese sem meta-análise

Quando meta-análise não for apropriada:

- método deverá ser explicitado;
- agrupamentos deverão ser justificados;
- direção e magnitude deverão ser preservadas;
- SWiM será referência de transparência para intervenções quantitativas;
- “narrative synthesis” sem método será insuficiente;
- vote counting por significância será evitado.

---

# 7. Métodos especializados

O Documento 14 estabeleceu que não haverá um único método de síntese para todas as classes.

Referências específicas:

- intervenções: Cochrane Handbook;
- DTA: Cochrane DTA Handbook v2.0.1;
- prognóstico/predição: Cochrane Prognosis Handbook;
- prevalência/incidência: JBI/PERSyst conforme aplicabilidade;
- qualitativa: JBI meta-aggregation quando alinhada à pergunta;
- mixed methods: abordagem explícita, incluindo JBI convergent segregated quando apropriada.

---

# 8. Política de IA

IA pode auxiliar em:

- agrupamento preliminar;
- detecção de incompatibilidades;
- código;
- conferência de fórmulas;
- tabelas/gráficos;
- documentação.

IA não pode:

- decidir silenciosamente combinabilidade;
- escolher modelo pelo resultado;
- alterar dados;
- ocultar heterogeneidade;
- inventar parâmetros;
- produzir estimativa final sem execução reproduzível.

Código gerado por IA deverá ser revisado, executado, versionado e testado.

---

# 9. Questões ainda abertas

Permanecem para etapas seguintes:

- regras detalhadas de GRADE por classe de pergunta;
- certainty em NMA;
- CERQual;
- ROB-ME/missing evidence na certeza;
- thresholds clínicos de imprecisão;
- integração entre certeza e Ficha de Evidência;
- Summary of Findings;
- modelo de dados definitivo;
- implementação estatística padrão;
- seleção de software/pacotes oficiais do OES;
- política de revisão estatística externa em análises complexas.

Não tratar esses itens como resolvidos.

---

# 10. Ponto exato de retomada

## Documento 15 — Protocolo de Avaliação da Certeza/Confiança no Corpo de Evidências

Próximos elementos:

- certeza por desfecho;
- GRADE;
- risco de viés;
- inconsistência;
- indirectness;
- imprecisão;
- missing evidence/publication bias;
- fatores de aumento;
- diagnóstico;
- prognóstico;
- predição;
- prevalência;
- CERQual;
- NMA;
- Summary of Findings;
- linguagem de certeza;
- separação entre certeza e recomendação;
- Camada Brasil/aplicabilidade.

---

# 11. Regra de retomada

Antes de continuar:

1. consultar o ponteiro operacional;
2. ler este CP05;
3. aplicar o Template Canônico em Modo Continuidade;
4. executar Freshness Gate contra `main`;
5. consultar `STATE.md` e os Documentos 13 e 14;
6. apresentar Diagnóstico de Continuidade;
7. retomar no Documento 15 após confirmação da base.

---

**Fim do CP05**
