# 106 — Caso Real N3-01: Protocolo da Síntese Rápida sobre Ambient AI Scribes

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**Data:** 5 de outubro de 2026  
**Status:** protocolo pré-especificado — produto experimental/não publicável

---

# 1. Pergunta

> **Em clínicos que atuam em atendimento ambulatorial, o uso de ambient AI scribes, comparado à documentação usual sem ambient scribe, reduz o tempo de documentação e a carga/burnout do clínico sem degradar materialmente a qualidade ou segurança das notas?**

# 2. Finalidade decisória

Informar, em caráter metodológico experimental, uma decisão de adoção de tecnologia de documentação assistida por IA em sistema de saúde.

A saída não constitui recomendação de compra, implantação ou política institucional.

# 3. Justificativa para N3

N3 é apropriado porque:

- a pergunta é focal e decisória;
- existe revisão sistemática recente, mas ampla e predominantemente anterior aos ensaios randomizados peer-reviewed mais novos;
- surgiram RCTs e estudos prospectivos em 2025–2026;
- é necessário appraisal explícito;
- é necessária síntese estruturada por outcome;
- certainty/confidence é relevante para decisão;
- uma atualização rápida sistemática é proporcional;
- uma N4 completa não é necessária para o objetivo de validação metodológica.

Não usar N1/N2 isoladamente porque a atualização exige processo de busca/seleção/appraisal sistemático novo.

# 4. Framework PICO

## População

Clínicos/physicians/advanced practice providers que realizam atendimento ambulatorial e documentação clínica em EHR.

## Intervenção

Ambient AI scribe/ambient listening system que captura a conversa clínica e gera draft de nota clínica para revisão do profissional.

## Comparador principal

Documentação usual sem ambient AI scribe.

## Comparadores secundários

- outro ambient AI scribe;
- human scribe;
- baseline individual quando desenho comparativo adequado.

Comparadores secundários não serão combinados automaticamente com usual care.

# 5. Outcomes

## Críticos

1. tempo de documentação/time-in-note;
2. trabalho fora do horário/EHR after-hours ou work-outside-work;
3. carga cognitiva/workload;
4. burnout/work exhaustion;
5. qualidade/segurança da nota quando medida por instrumento ou revisão explícita.

## Importantes

- satisfação do clínico;
- produtividade;
- necessidade de edição;
- adoção/utilização;
- eventos adversos/inaccuracies materialmente relevantes.

# 6. Desenhos elegíveis

Para efeito comparativo principal:

- randomized controlled trials;
- randomized crossover trials;
- stepped-wedge randomized trials;
- controlled prospective comparative studies.

Para qualidade/segurança contextual:

- prospective validation studies poderão ser incluídos como evidência contextual, sem serem combinados com estimativas de efeito randomizadas.

Revisões sistemáticas/scoping reviews serão usadas para:

- checar não duplicação;
- citation chasing;
- contextualizar cobertura;
- identificar estudos potencialmente elegíveis.

Não serão tratadas como unidades independentes em pooling com estudos primários.

# 7. Exclusões

- estudos exclusivamente inpatient quando resultados ambulatoriais não forem separáveis;
- estudos exclusivamente emergency department para a síntese principal;
- simulações sem prática clínica real para efeito principal;
- ChatGPT/manual prompt sem captura ambiente de consulta;
- sistemas de transcrição sem geração de draft clínico;
- estudos sem outcome de eficiência, workload/burnout ou qualidade/segurança.

# 8. Fontes de informação

Busca definitiva rápida em:

1. **PubMed/MEDLINE**;
2. **Europe PMC**.

Buscas suplementares:

- backward citation checking da revisão sistemática de Bracken et al. 2025;
- forward/backward checking dos RCTs principais;
- verificação de trial registration quando explicitamente identificada.

# 9. Estratégia conceitual

Bloco intervenção:

`("ambient AI" OR "ambient artificial intelligence" OR "ambient scribe" OR "AI scribe" OR "ambient listening")`

Bloco documentação:

`(documentation OR note OR "clinical note" OR EHR OR "electronic health record")`

Bloco população/efeito:

`(physician OR clinician OR provider OR practitioner) AND (time OR workload OR burnout OR quality OR accuracy)`

Período principal:

> **1 janeiro 2025 a 5 outubro 2026**

Rationale: a revisão sistemática-base foi recebida em novembro de 2024 e aceita em janeiro de 2025; o objetivo é atualização rápida da evidência posterior.

# 10. Rapid restrictions pré-especificadas

## R1 — duas fontes bibliográficas

**Abreviação:** PubMed + Europe PMC, sem Embase/Scopus/CINAHL.

**Risco:** perda de estudos indexados apenas em outras bases.

**Mitigação:** citation chasing da revisão-base e dos estudos principais; disclosure explícito.

## R2 — idioma

**Abreviação:** inglês; português se localizado.

**Risco:** language bias.

**Mitigação:** registrar a restrição; não inferir ausência global de evidência.

## R3 — desenhos para eficácia

**Abreviação:** priorizar desenhos comparativos, especialmente randomizados.

**Risco:** perda de implementação real-world não comparativa.

**Mitigação:** estudos prospectivos não comparativos podem ser usados como contexto de qualidade/segurança, claramente separados.

## R4 — outcomes críticos

**Abreviação:** foco em documentação, workload/burnout e qualidade/segurança.

**Risco:** omissão de efeitos organizacionais secundários.

**Mitigação:** produtividade/satisfação/adoption preservadas como outcomes importantes quando reportados.

## R5 — sem meta-análise nova por padrão

**Abreviação:** síntese narrativa estruturada/SWiM, salvo homogeneidade suficiente.

**Risco:** menor precisão quantitativa combinada.

**Mitigação:** apresentar estimativas por estudo e direção/consistência; não fazer vote counting por significância.

# 11. Seleção

Processo experimental:

- deduplicação assistida por IA;
- triagem title/abstract por IA;
- verificação secundária por IA registrada separadamente;
- full-text/abstract eligibility documentada;
- motivos de exclusão registrados para candidatos centrais.

Controles humanos qualificados exigidos pelo N3 formal permanecerão **ausentes**.

# 12. Extração

Campos críticos:

- população/setting;
- tecnologia/vendor;
- comparador;
- duração;
- utilization/adherence;
- time-in-note/documentation time;
- after-hours/WoW;
- burnout/workload scales;
- note-quality/safety metrics;
- estimativas e IC;
- perdas/attrition;
- conflitos/financiamento quando reportados.

Extração será executada por IA e verificada por segunda passagem de IA.

Isso **não satisfaz** critical-data verification humana qualificada.

# 13. Appraisal

## RCTs

> **RoB 2** — avaliação preliminar OES assistida por IA.

## Estudos não randomizados comparativos

> **ROBINS-I ou instrumento proporcional ao desenho**, se usados materialmente.

## Revisão sistemática-base

> avaliação crítica proporcional/ROBIS como contexto de atualização, sem adotá-la automaticamente como verdade canônica.

Todos os julgamentos materiais permanecerão sem verificação humana qualificada.

# 14. Síntese

Plano primário:

- agrupar por outcome;
- separar usual-care comparisons de head-to-head vendor comparisons;
- separar RCTs de observacionais;
- não combinar escalas incompatíveis;
- não converter diferenças relativas de tempo em minutos sem base adequada;
- síntese narrativa estruturada.

# 15. Certainty

Aplicar GRADE experimentalmente aos outcomes críticos sustentados por RCTs:

- documentação/time-in-note;
- workload/burnout.

Qualidade/segurança poderá receber avaliação separada se houver base comparativa suficiente.

Os julgamentos GRADE serão OES/IA e permanecerão sem verificação humana qualificada.

# 16. Summary of Findings

Previsto para os outcomes críticos quando a síntese estiver suficientemente estruturada.

Se determinado não aplicável, a decisão será registrada formalmente.

# 17. Timebox

Este caso é um **exercício de validação do produto N3**, executado em ciclo único de desenvolvimento do OES.

Não será usada linguagem de turnaround clínico real.

# 18. Gatilhos de rerroteamento para N4

Rerrotear se:

- >10 estudos comparativos materialmente heterogêneos exigirem síntese extensiva;
- conflitos de qualidade/segurança exigirem busca mais abrangente;
- meta-análise complexa se tornar necessária;
- resultados críticos dependerem de fontes não recuperáveis/verificáveis;
- abreviações rápidas puderem alterar materialmente a conclusão.

# 19. Assurance/governança

Estado inicial:

> **A0 — experimental**

Mesmo após AI methodological verification e eventual owner approval:

- publication gate N3 continuará bloqueado;
- qualified human controls reais permanecerão ausentes;
- expert independent review permanecerá ausente;
- A3 não será fabricado.

# 20. Próxima etapa

Executar e registrar:

> **busca definitiva rápida + seleção dos estudos elegíveis**

antes de appraisal, síntese ou certainty.

---

**Nota:** este protocolo foi definido antes da busca definitiva do Caso Real N3-01.