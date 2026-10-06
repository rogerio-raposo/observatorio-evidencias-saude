# 109 — Caso Real N3-01: Síntese Narrativa Estruturada, GRADE Experimental e SoF

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Síntese Rápida de Evidências — N3  
**Caso:** N3-01 — ambient AI scribes e carga de documentação clínica  
**Data de corte:** 2026-10-05  
**Status:** síntese/certainty experimental concluída; não publicável como N3 formal

---

# 1. Regra de síntese

Foi executada:

> **síntese narrativa estruturada/SWiM, sem nova meta-análise.**

Razões:

- diferentes produtos;
- diferentes desenhos randomizados;
- outcomes e escalas diferentes;
- métricas de tempo não diretamente intercambiáveis;
- um RCT é head-to-head entre fornecedores;
- heterogeneidade operacional relevante.

Não foi realizado vote counting por significância estatística.

# 2. Corpo de evidência usado para efeito

## Ambient AI versus usual care

### Lukac et al. 2025

- 238 médicos ambulatoriais;
- DAX, Nabla, usual-care control;
- Nabla: redução relativa de `time-in-note` de **9,5%** versus controle (IC95% -17,2% a -1,8%);
- DAX: **-1,7%** versus controle (IC95% -9,4% a +5,9%);
- outcomes psicométricos sugeriram direção favorável para workload/work exhaustion;
- baixa utilização real dos scribes;
- métrica time-in-note não capturou edição dentro da plataforma dos scribes.

### Afshar et al. 2025

- 66 profissionais;
- stepped-wedge randomized pragmatic trial;
- ambient AI versus practice-as-usual conforme wave;
- work exhaustion/interpersonal disengagement: **-0,44** ponto (IC95% -0,62 a -0,25);
- professional fulfillment: +0,14 (IC95% 0,004 a 0,28), não significativo no esquema inferencial dos coprimary outcomes;
- time spent on notes: **-0,36 hora/dia** (IC95% -0,55 a -0,17);
- work outside work: -0,50 hora/dia (IC95% -0,90 a -0,09), mas sensível à exclusão de observações extremas;
- PDSQI-9 permaneceu alto nos domínios medidos.

## Head-to-head de produtos

### Chowdhury et al. 2026

- 160 clínicos ambulatoriais;
- randomized crossover entre dois ambient scribes;
- produto B versus produto A:
  - satisfação: diferença +0,60 (IC95% 0,32 a 0,90);
  - time-in-notes/day: -3,19 minutos (IC95% -4,87 a -1,50);
- diferenças de burnout entre produtos não foram materialmente demonstradas;
- ausência de período scribe-free de washout cria preocupação de carryover.

Esse estudo informa:

> **comparação entre produtos, não efeito de ambient AI versus usual care.**

# 3. Evidência contextual

## Stults et al. 2025

Pré/pós/QI:

- time-in-note por consulta caiu aproximadamente 0,9 minuto após implementação;
- NASA-TLX melhorou;
- burnout não apresentou redução estatisticamente clara.

Uso:

> coerência externa/implementação; não causalidade robusta.

## Taylor et al. 2026

Prospective quality/safety pilot:

- 7545 notas geradas;
- 356 avaliadas formalmente;
- omissões: 18%;
- hallucinations: 11,5%;
- inclusões acidentais: 9,3%;
- 5,3% das notas avaliadas continham erros classificados como risco sério ou iminente.

Interpretação OES:

> esses percentuais não devem ser tratados como taxa populacional definitiva de dano, mas demonstram que erros clinicamente relevantes podem ocorrer e exigem revisão humana.

# 4. Síntese por outcome

## 4.1 Tempo de documentação

Direção:

> **favorável, mas magnitude não uniforme.**

Evidência:

- Afshar demonstra redução diária de tempo;
- Lukac demonstra redução com Nabla, mas não com DAX;
- Chowdhury mostra diferença adicional entre produtos.

Interpretação:

> ambient AI **pode reduzir** tempo de documentação, mas o benefício depende da tecnologia, adoção, workflow e métrica utilizada.

Não é defensável concluir:

> “ambient AI reduz X minutos em média”

porque nenhum pooled estimate foi calculado e as medidas não são intercambiáveis.

# 5. Workload / work exhaustion / burnout

Direção:

> **provavelmente favorável em alguns domínios, com incerteza.**

Evidência:

- Afshar: redução de work exhaustion/interpersonal disengagement;
- Lukac: Mini-Z/PTL/PFI-WE em direção geralmente favorável;
- Chowdhury: ambos os produtos melhoraram burnout versus baseline, sem diferença clara entre produtos.

Limites:

- outcomes subjetivos;
- desenhos open-label;
- possível expectancy/Hawthorne effect;
- amostras modestas;
- algumas estimativas secundárias imprecisas.

# 6. Work outside work / after-hours

Evidência principal:

- Afshar sugere redução;
- efeito perdeu robustez após exclusão das observações diárias mais extremas;
- Chowdhury não demonstrou diferença significativa entre produtos.

Conclusão:

> **possível redução, mas evidência pouco robusta para magnitude.**

# 7. Qualidade e segurança da nota

Evidência:

- Afshar: PDSQI-9 alto e sem sinal de drift;
- Lukac: inaccuracies clinicamente significativas foram relatadas ocasionalmente;
- Taylor: erros, inclusive potencialmente graves, foram identificados em uma amostra de notas.

Conclusão:

> **não foi demonstrada degradação média clara nas métricas avaliadas, mas a evidência não permite afirmar segurança equivalente ou ausência de dano.**

Implicação:

> revisão clínica das notas permanece necessária.

Isso é uma interpretação da evidência, não recomendação normativa do OES.

# 8. GRADE experimental

Importante:

> **GRADE foi executado pelo OES/IA e não passou por verificação humana qualificada.**

Os níveis abaixo são experimentais e não satisfazem o gate N3 formal.

## 8.1 Documentation time — ambient AI versus usual care

Base:

- RCTs → início em alta certeza.

Downgrades:

- **risk of bias: -1** — Lukac possui high risk para time-in-note por mensuração que não captura edição na plataforma;
- **inconsistency/heterogeneity: -1** — efeito varia por produto e escala; DAX versus controle não mostrou redução clara, enquanto Nabla e Afshar foram favoráveis.

Sem upgrade.

> **Certeza experimental final: LOW**

Interpretação:

> ambient AI **pode reduzir** tempo de documentação, mas magnitude e consistência entre ferramentas são incertas.

# 9. GRADE — work exhaustion / burnout

Base:

- randomized evidence.

Downgrades:

- **risk of bias: -1** — open-label, outcomes autorreferidos;
- **imprecision/heterogeneity: -1** — amostras modestas e medidas diferentes; algumas estimativas cruzam ausência de efeito.

> **Certeza experimental final: LOW**

Interpretação:

> ambient AI **pode reduzir** work exhaustion/workload em alguns contextos.

# 10. GRADE — work outside work

Base:

- randomized evidence principalmente de Afshar.

Downgrades:

- **imprecision/fragility: -1** — sensível a observações extremas;
- **indirectness/single-system evidence: -1** — evidência decisiva concentrada em um sistema/vendor.

> **Certeza experimental final: LOW**

Interpretação:

> pode haver redução de trabalho documental fora do horário, mas o tamanho do benefício é incerto.

# 11. GRADE — note quality / safety

Base:

- componente randomizado limitado + evidência contextual observacional/prospectiva.

Downgrades:

- **risk of bias: -1** — safety measurement heterogênea e parcialmente autorreportada;
- **indirectness: -1** — instrumentos diferentes e foco em qualidade da nota, não dano clínico direto;
- **imprecision/rare serious errors: -1** — eventos potencialmente graves são pouco frequentes e estimativas pouco estáveis.

> **Certeza experimental final: VERY LOW**

Interpretação:

> é muito incerto se ambient AI mantém segurança equivalente à documentação usual; erros clinicamente relevantes foram observados e não podem ser descartados.

# 12. Summary of Findings — experimental

| Outcome crítico | Efeito/direção | Certeza OES experimental | Interpretação |
|---|---|---|---|
| Documentation time | favorável, magnitude variável | LOW | pode reduzir tempo; efeito depende da ferramenta/workflow |
| Work exhaustion/burnout | direção favorável | LOW | pode reduzir carga/exaustão |
| Work outside work | possível redução | LOW | benefício possível, magnitude frágil |
| Note quality/safety | sem degradação média clara, mas erros relevantes existem | VERY LOW | segurança equivalente não demonstrada |

# 13. Conclusão da evidência

> **Ambient AI scribes podem reduzir o tempo de documentação e alguns componentes de carga/exaustão entre clínicos ambulatoriais, mas o tamanho do benefício varia por produto e contexto. A evidência sobre segurança é muito mais incerta: estudos não demonstram degradação média consistente da qualidade, porém inaccuracies, omissões e erros potencialmente graves foram observados. O corpo atual não sustenta tratar todas as ferramentas como equivalentes nem assumir que ganhos de eficiência implicam segurança equivalente.**

# 14. Aplicabilidade

Limitações de transferibilidade:

- estudos predominantemente em grandes sistemas acadêmicos dos EUA;
- early adopters/voluntários;
- integração Epic e workflows específicos;
- versões de produtos mudam rapidamente;
- contratos, treinamento e suporte variam;
- consultas em inglês predominam;
- adoção real pode ser baixa ou desigual.

Aplicabilidade formal não avaliada.

# 15. Limitações decorrentes do método rápido

- Europe PMC indisponível no runtime;
- segunda fonte substituta menos padronizada;
- ausência de Embase/Scopus/CINAHL;
- result counts não disponíveis;
- inglês predominante;
- citation chasing seletivo;
- triagem/extração/appraisal por IA;
- ausência de human-qualified secondary verification;
- ausência de expert review;
- nenhum pooling/meta-analysis novo.

# 16. Desvio de protocolo

`EUROPE_PMC_RUNTIME_ACCESS_FAILURE`

Status:

> **resolved_with_mitigation para desenvolvimento experimental**

Impacto residual:

> risco de perda de estudos permanece e deve reduzir confiança na completude da busca.

# 17. Quality controls

Podem ser materializados como controles executados por IA:

- search strategy check;
- screening pilot/check;
- secondary screening verification;
- critical data verification;
- RoB verification;
- certainty verification.

Todos deverão ter:

> `qualified=false`

e nunca poderão satisfazer os blockers humanos N3.

# 18. Publication/assurance

Mesmo que AI methodological verification futuramente passe:

- qualified human controls continuarão ausentes;
- expert independent review continuará ausente;
- A3 continuará ausente;
- `publishable=false` deverá permanecer.

# 19. Próxima etapa

> **Materializar o Caso Real N3-01 no OES-P1 em estado experimental A0, com protocolo, method decisions, Search/Screening, Reports/Results, RiskAssessment, Synthesis, Certainty, SoF decision e quality controls por IA.**

Depois:

- executar testes/rebuild;
- realizar verificação metodológica adversarial por IA;
- se PASSED, materializar A1 experimental;
- não avançar artificialmente para A3.

---

**Status:** síntese e certainty suficientes para materialização experimental; publicação formal não permitida.