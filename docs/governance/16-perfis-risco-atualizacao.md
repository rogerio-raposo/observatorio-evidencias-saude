# 16 — Perfis de Risco Operacional e Científico para Atualização

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **BASELINE CONCEITUAL CANDIDATA — requer revisão adversarial**  
**Dependências:** Documentos 02–09; OES-P1; migration 027

---

## 1. Finalidade

Definir a arquitetura transversal de perfis de risco que parametrizará, em blocos posteriores da Fase 4:

- cadence;
- thresholds temporais e de materialidade;
- classes de SLA;
- prioridade;
- escalonamento;
- elegibilidade M3;
- propagation/re-baselining.

Este documento não fixa:

- intervalos universais em dias;
- SLA em horas/dias;
- score numérico agregado;
- auto-classification;
- auto-escalation;
- scheduler;
- M3 readiness;
- automação autoritativa.

---

## 2. Princípio metodológico

O OES rejeita uma regra universal do tipo:

> “todo produto deve ser atualizado a cada X meses”.

A necessidade de vigilância e atualização depende do contexto do target.

Referências metodológicas contemporâneas convergem em que:

- atualização é julgamento individualizado/proporcional;
- prioridade e impacto potencial importam;
- living evidence é apropriada somente em situações selecionadas;
- frequência e triggers devem ser prospectivamente explícitos;
- capacidade operacional é requisito de viabilidade, mas não reduz risco científico.

Portanto:

> **cadence e SLA serão derivados de perfil de risco + política explícita, não da idade cronológica isolada.**

---

## 3. Relação com o Routing Record existente

O Documento 03 já possui dimensões canônicas de roteamento:

- criticidade;
- complexidade;
- maturidade;
- incerteza;
- volatilidade;
- contexto.

O Documento 16 **não cria uma taxonomia concorrente** para esses conceitos.

Regras:

- criticidade da atualização reutiliza a criticidade canônica, podendo ser reavaliada quando a finalidade/uso mudar;
- volatilidade reutiliza a dimensão canônica de volatilidade, agora aplicada longitudinalmente;
- sensibilidade da conclusão é avaliação de manutenção derivada de incerteza, maturidade, precisão e proximidade de mudança decisória;
- qualquer divergência entre Routing Record histórico e perfil posterior deve ser explícita e justificada;
- perfil de atualização nunca reescreve silenciosamente o Routing Record histórico.

## 4. Separação obrigatória: risco intrínseco × capacidade operacional

O OES manterá duas famílias de dimensões.

### 3.1 Risco científico/decisório intrínseco

Descreve o dano potencial de a evidência ficar inadequada ou mudar materialmente.

Não depende da capacidade atual da equipe.

### 3.2 Viabilidade/risco operacional

Descreve quão bem o OES consegue detectar, avaliar e responder à mudança.

Capacidade insuficiente:

> **não reduz o risco intrínseco.**

Ela pode:

- bloquear M3;
- exigir redução de escopo;
- exigir escalonamento de governança;
- tornar o SLA planejado não factível;
- exigir declaração explícita de limitação.

Nunca poderá ser usada para “rebaixar” artificialmente criticidade científica.

---

# 5. Família A — risco científico/decisório

## 5.1 A1 — Criticidade da decisão

Pergunta:

> qual o impacto potencial de uma conclusão desatualizada ou incorreta sobre pessoas, decisões ou políticas?

Níveis qualitativos candidatos:

### baixa

Consequências limitadas; uso predominantemente informativo/exploratório.

### moderada

Pode influenciar prática ou decisão, mas com consequências geralmente reversíveis ou de magnitude limitada.

### alta

Pode afetar decisões clínicas, de política, incorporação, segurança ou alocação relevante de recursos.

Regras:

- criticidade não é produto do nível N;
- N4 não é automaticamente crítico;
- N1 pode suportar decisão crítica e, nesse caso, pode exigir reroteamento/garantia maior;
- criticidade alta eleva exigência de resposta, mas não prova materialidade de um signal.

---

## 5.2 A2 — Volatilidade da base de evidências

Pergunta:

> quão provável é surgirem dados relevantes em ritmo capaz de alterar o estado informacional?

Indicadores qualitativos:

- pipeline conhecido de estudos;
- volume recente de publicações;
- tecnologia/intervenção emergente;
- múltiplos trials em andamento;
- área com mudanças regulatórias frequentes;
- rápida evolução de métodos/diagnósticos;
- campo estabilizado com baixa produção nova.

Níveis:

- baixa;
- moderada;
- alta.

Volatilidade:

> mede probabilidade/ritmo de mudança no corpo de evidências, não importância da mudança.

Alta volatilidade sem criticidade/sensibilidade elevada pode justificar vigilância ativa sem M3.

---

## 5.3 A3 — Sensibilidade da conclusão

Pergunta:

> quão plausível é que uma quantidade realista de nova informação altere conclusão, certeza, magnitude, aplicabilidade ou interpretação?

Indicadores:

- baixa certeza/confiança;
- estimativas imprecisas;
- proximidade de limiares decisórios;
- heterogeneidade relevante;
- inconsistência;
- pequeno número de estudos/eventos;
- resultados dominados por um único estudo;
- sinais conflitantes;
- efeito pequeno/modesto com implicação decisória relevante;
- conclusão robusta sustentada por corpo amplo e consistente.

Níveis:

- baixa;
- moderada;
- alta.

Sensibilidade alta:

> não significa que a conclusão já está outdated.

Significa que nova informação merece avaliação mais rápida/intensa.

---

## 5.4 A4 — Exposição a consequências de segurança/integridade

Pergunta:

> se surgir um evento de segurança, integridade ou regulação, qual a consequência potencial de atraso na sua detecção/avaliação?

Considerar:

- potencial de dano;
- dependência da conclusão de fontes vulneráveis a correção/retratação;
- relevância de fontes regulatórias;
- consequências de contraindicação/restrição tardia;
- possibilidade de invalidação metodológica relevante.

Níveis:

- baixa;
- moderada;
- alta.

A4 descreve **exposição estrutural do target**, não a existência de um signal ativo.

Quando efetivamente ocorre:

- safety signal;
- retraction;
- correction;
- expression of concern;
- regulatory change;

o evento pertence a `maintenance.update_signal` e segue MaterialityAssessment/UpdateDecision.

Regra de dominância:

> **A4 alta exige forte capacidade event-driven e prioridade elevada quando um signal correspondente surge.**

Não altera currentness automaticamente.

## 5.5 A5 — Alcance de dependências

Pergunta:

> quantos e quão importantes objetos downstream podem ser afetados se o target mudar?

Considerar:

- produtos derivados;
- Fichas alimentadas pela mesma síntese;
- Maps/Overviews que reutilizam corpus;
- Monitores;
- Alerts;
- decisões/documentos downstream rastreáveis;
- uso institucional conhecido.

Níveis:

- restrito;
- moderado;
- amplo;
- sistêmico.

A5 alto:

> eleva prioridade de impact assessment/coordenação.

Não aumenta, sozinho, materialidade científica da nova evidência.

---

# 6. Família B — perfil operacional

## 6.1 B1 — Observabilidade das fontes

Pergunta:

> quão detectável é a mudança relevante por fontes monitoráveis e tempestivas?

Considerar:

- indexação bibliográfica previsível;
- registros de ensaios;
- fontes regulatórias;
- disponibilidade de alertas estruturados;
- latência de indexação;
- fontes fragmentadas/não estruturadas;
- necessidade de busca manual especializada.

Níveis:

- alta;
- moderada;
- baixa;
- muito baixa.

Baixa observabilidade:

> aumenta risco operacional de atraso e pode exigir fontes redundantes.

Não reduz necessidade científica.

---

## 6.2 B2 — Latência de detecção

Pergunta:

> qual o intervalo plausível entre surgimento do evento relevante e sua detectabilidade pelo OES?

Classes qualitativas:

- curta;
- moderada;
- longa;
- imprevisível.

Latência depende da fonte, não apenas da cadence interna.

Uma cadence mais frequente que a latência real da fonte pode produzir custo sem ganho de atualidade.

---

## 6.3 B3 — Carga de vigilância

Pergunta:

> qual o volume esperado de itens que precisa ser triado para manter a política?

Considerar:

- yield histórico;
- precisão da estratégia;
- número de fontes;
- volume de SearchHits;
- deduplicação;
- tamanho do corpus;
- necessidade de avaliação especializada.

Níveis:

- baixa;
- moderada;
- alta;
- extrema.

Carga é variável operacional e não justificativa para ignorar risco.

---

## 6.4 B4 — Custo de incorporação científica

Pergunta:

> quando um signal é material, quão oneroso é convertê-lo em nova versão cientificamente válida?

Considerar:

- extração;
- risk of bias;
- meta-analysis;
- certainty;
- reavaliação de aplicabilidade;
- necessidade de especialista;
- extensão do texto/template;
- propagation downstream.

Níveis:

- baixo;
- moderado;
- alto;
- muito alto.

B4 alto pode justificar:

- triagem rápida + atualização científica posterior;
- priorização explícita;
- planejamento de capacidade.

Não justifica falso currentness.

---

## 6.5 B5 — Capacidade sustentável

Pergunta:

> há recursos, competência e disponibilidade suficientes para executar o regime de manutenção prometido?

Níveis:

- adequada;
- tensionada;
- insuficiente;
- indisponível.

B5 é uma fotografia operacional com período de vigência; pode mudar sem mudança científica do target.

B5 é gate de viabilidade.

Regras:

- M3 exige capacidade adequada;
- capacidade tensionada pode requerer redução de escopo, reforço de recursos ou M2;
- capacidade insuficiente/indisponível bloqueia M3 formal;
- nenhuma capacidade baixa rebaixa A1–A5.

---

# 7. Perfil composto sem score aditivo

O OES não somará A1–A5 e B1–B5 em um único número nesta etapa.

Motivos:

1. dimensões não são intercambiáveis;
2. segurança/integridade possui dominância própria;
3. capacidade não deve compensar criticidade;
4. alta dependência downstream não equivale a alta probabilidade de mudança científica;
5. scores precoces criariam falsa precisão.

Representação conceitual:

```text
ScientificRiskProfile
  criticality
  evidence_volatility
  conclusion_sensitivity
  safety_integrity
  dependency_reach

OperationalProfile
  source_observability
  detection_latency
  surveillance_load
  incorporation_cost
  sustainable_capacity
```

---

# 8. Saída recomendatória do perfil

O perfil não criará estados `R0–R3` nem qualquer segunda escala concorrente de M0–M3.

Sua saída conceitual deverá conter, separadamente:

- `recommended_maintenance_level`: M0, M1, M2 ou M3-candidate;
- `recommended_cadence_mode`: none, event_driven, periodic, hybrid ou continuous;
- `event_driven_surveillance_required`: recomendação qualitativa;
- `priority_posture`: rotina, elevada ou prioritária para desenho posterior;
- `feasibility_status`: adequada, tensionada, insuficiente ou indisponível;
- rationale explícita.

Regras:

1. essa saída é recomendatória e não modifica UpdatePolicy;
2. M3-candidate não equivale a M3 operacional;
3. mudança da policy exige decisão própria de governança;
4. não criar score agregado para escolher M automaticamente;
5. currentness não é parte da saída do perfil.

# 9. Regras de dominância e não compensação

## 9.1 Segurança/integridade

A4 alta:

- exige triagem prioritária;
- pode encurtar SLA futuro;
- pode abrir under_evaluation após assessment;
- não declara outdated automaticamente.

## 9.2 Criticidade

A1 alta não pode ser “compensada” por baixa volatilidade para eliminar vigilância quando eventos raros teriam grande impacto.

Pode favorecer:

- event-driven surveillance forte mesmo com periodicidade baixa.

## 9.3 Volatilidade

A2 alta isolada:

- aumenta necessidade de detecção;
- não implica M3 se A1/A3 forem baixos.

## 9.4 Sensibilidade

A3 alta:

- reduz tolerância a signals relevantes;
- não muda currentness sem assessment.

## 9.5 Capacidade

B5 insuficiente:

- não reduz A1–A5;
- deve gerar limitação/governança;
- pode bloquear regime prometido.

## 9.6 Dependências

A5 amplo/sistêmico:

- aumenta prioridade de propagation assessment;
- não altera conclusão científica do target.

---

# 10. Relação com cadence

Cadence futura deverá ser função de:

```text
need_for_surveillance
  = f(criticality, volatility, sensitivity, safety_integrity)
```

modulada por:

```text
source reality
  = f(observability, detection latency)
```

e condicionada por:

```text
feasibility
  = f(surveillance load, incorporation cost, sustainable capacity)
```

Regras:

1. não executar cadence mais frequente apenas porque é tecnicamente possível;
2. não usar incapacidade operacional para declarar risco baixo;
3. event-driven e periodic podem coexistir;
4. safety/regulatory sources podem exigir channel/event monitoring separado da busca bibliográfica;
5. cadence deve declarar sua rationale.

---

# 11. Relação com thresholds

Threshold futuro não será um único número global.

Classes de threshold a definir posteriormente:

### T1 — threshold de detecção

Quando um evento vira UpdateSignal.

### T2 — threshold de materialidade

Quando um signal justifica determinada classe de MaterialityAssessment/Decision.

### T3 — threshold de currentness

Quando assessment/decision sustenta mudança de CurrencyState.

### T4 — threshold de escalonamento

Quando prioridade/governança precisa ser elevada.

### T5 — threshold temporal

Quando atraso operacional se torna issue/escalation.

Esses thresholds poderão ser:

- categóricos;
- condicionais;
- quantitativos quando houver fundamento;
- específicos por domínio/produto.

---

# 12. Relação com SLA

SLA futuro será derivado de:

- A1 criticidade;
- A4 safety/integrity;
- A3 sensibilidade;
- materiality outcome;
- lifecycle do signal/decision;
- B1/B2 observabilidade/latência;
- capacidade declarada.

Regra fundamental:

> **SLA mede obrigação operacional; não mede verdade científica.**

Quebra de SLA:

- gera issue operacional;
- pode gerar escalonamento;
- não muda currentness automaticamente.

---

# 13. Relação com prioridade

Prioridade futura será multidimensional.

Ordem de consideração:

1. safety/integrity dominance;
2. ameaça de invalidade/uso;
3. criticidade da decisão;
4. materialidade provável/confirmada;
5. sensibilidade da conclusão;
6. alcance de dependências;
7. currentness vigente;
8. atraso operacional;
9. custo/capacidade para execução.

Não usar:

> `priority = soma simples dos níveis`

sem validação metodológica posterior.

---

# 14. Relação com M0–M3

O perfil recomenda, mas não muda M0–M3 automaticamente.

Padrões conceituais:

### perfil baixo/estável

Pode recomendar M0 ou M1.

### criticidade alta + volatilidade baixa

Pode recomendar M1 com forte vigilância event-driven.

### volatilidade alta + sensibilidade moderada/alta

Pode recomendar M2.

### criticidade alta + volatilidade alta + sensibilidade alta + capacidade adequada

Pode justificar `M3-candidate`.

### mesmo risco científico + capacidade insuficiente

A necessidade científica permanece alta, mas M3 formal fica bloqueado.

Resultado correto:

> **high need / insufficient capacity**

e não:

> “risco moderado”.

A decisão efetiva continua em `maintenance.update_policy`.

# 15. Relação com Alert

Alert classification não será usada como substituto do perfil.

Entretanto:

- critical Alert pode representar sinal de A4 alto/crítico;
- relevant Alert pode indicar aumento de A3/materialidade potencial;
- informational Alert não implica perfil baixo.

UpdateRiskProfile deve ser avaliado independentemente.

---

# 16. Relação com Monitor

Monitor M2/M3 fornece dados empíricos para revisão do perfil:

- SearchHit yield;
- candidate yield;
- source coverage;
- cycle completeness;
- tempo de detecção;
- frequência de material signals;
- burden real.

Isso permite revisão posterior de:

- A2 volatilidade;
- B1 observabilidade;
- B2 latência;
- B3 carga;
- B5 capacidade.

Monitor não decide sozinho o perfil.

---

# 17. Temporalidade e target do perfil

Cada assessment de perfil deverá:

- apontar para uma versão concreta do target;
- possuir `effective_at`;
- ser supersedível;
- preservar rationale e ator/verificação.

Podem existir múltiplos perfis ao longo do tempo para a **mesma** ProductVersion/InvestigationVersion.

Isso é necessário porque:

- capacidade muda;
- observabilidade das fontes muda;
- pipeline de pesquisa muda;
- finalidade de uso pode mudar;
- dependency reach pode mudar;

sem nova versão científica.

Nova versão científica:

> exige novo assessment ou carry-forward explícito.

Carry-forward nunca deve ser silencioso e deve declarar quais dimensões foram reavaliadas.

# 18. Revisão do próprio perfil

Triggers de reassessment do perfil incluem:

- nova versão científica;
- mudança de uso/finalidade;
- nova política/regulação;
- mudança importante no pipeline de pesquisa;
- alteração da certeza;
- mudança de frequência de sinais;
- mudança de capacidade;
- mudança de source observability;
- entrada/saída de M3;
- alteração material no dependency graph.

Perfil não deve ser tratado como permanente.

---

# 19. Implicações para future data contract

Contrato físico posterior poderá representar:

- risk profile;
- profile dimensions;
- profile assessment;
- profile rationale;
- assessor/verifier;
- effective period;
- supersession;
- target version;
- recommended maintenance level/cadence mode;
- feasibility status;
- issues.

Ainda não autorizado:

- migration 028;
- score;
- numeric cadence;
- SLA duration.

---

# 20. Exemplos conceituais

## 20.1 Campo estável, baixo impacto

- A1 baixa;
- A2 baixa;
- A3 baixa;
- A4 sem sinal;
- A5 restrito.

Recomendação provável:

> M0/M1, conforme finalidade, com cadence none/event-driven/periodic justificada.

## 20.2 Intervenção clínica em área ativa

- A1 alta;
- A2 alta;
- A3 moderada/alta;
- A4 sem sinal;
- A5 moderado.

Recomendação provável:

> M2 com cadence periodic/hybrid.

## 20.3 Evidência living candidata

- A1 alta/crítica;
- A2 alta;
- A3 alta;
- A4 variável;
- B1 alta;
- B2 curta/moderada;
- B5 adequada.

Recomendação:

> M3-candidate com cadence continuous/hybrid.

Ainda exige M3 gate.

## 20.4 Sinal raro de segurança

- A1 crítica;
- A2 baixa;
- A3 moderada;
- A4 crítico;
- B1 alta via fonte regulatória.

Recomendação:

> forte event-driven surveillance, mesmo sem busca bibliográfica de alta frequência.

Isso demonstra por que “cadence curta para tudo” seria um modelo ruim.

## 20.5 Alto risco, baixa capacidade

- A1 alta;
- A2 alta;
- A3 alta;
- B5 insuficiente.

Resultado:

> necessidade alta + feasibility insuficiente.

A resposta correta é escalonar capacidade/governança, não reduzir artificialmente o risco.

---

# 21. Referências metodológicas orientadoras

Esta baseline foi confrontada com:

1. **Cochrane Interactive Learning — Module 14: Conducting living systematic reviews (2026).**
   Aborda adequação do living mode, frequência mínima de busca, triggers de update, comunicação de status e saída do living mode.

2. **Cochrane Handbook — Chapter 22: Prospective approaches to accumulating evidence.**
   Caracteriza living systematic reviews como atualização contínua e destaca prioridade, baixa certeza e expectativa de nova evidência como fatores de adequação.

3. **Cochrane Handbook — Chapter IV: Updating a review.**
   Distingue atualizações com impacto pequeno, mudança de certeza e mudança de conclusão.

4. **Garner et al. When and how to update systematic reviews: consensus and checklist. BMJ 2016;354:i3507.**
   Defende decisão individualizada considerando atualidade da pergunta, novos estudos/métodos, impacto esperado e viabilidade.

5. **NICE — Processes and methods for NICE-wide guidance surveillance (PMG49, 2025).**
   Adota surveillance proporcional/targeted, combinando monitoring reativo, tracking prospectivo e revisões planejadas conforme prioridade.

6. **WHO — living guidelines approach.**
   Combina surveillance contínua, atualização rápida de revisões priorizadas e deliberação para manter recomendações atualizadas.

Essas referências orientam princípios; não são copiadas como thresholds universais do OES.

---

# 22. Gate antes de qualquer persistência física

A revisão adversarial deverá testar:

- risco intrínseco × capacidade;
- ausência de score aditivo prematuro;
- dominância de safety/integrity;
- relação R0–saída recomendatória × M0–M3;
- possibilidade de criticidade alta + baixa volatilidade;
- possibilidade de alto risco + baixa capacidade;
- currentness separado do perfil;
- Alert/Monitor como inputs, não autoridades;
- profile per target version;
- reassessment/carry-forward;
- compatibilidade com UpdatePolicy/migration 027.

Resultados permitidos:

- PASS;
- PASS_WITH_ARCHITECTURAL_DECISIONS;
- REVISE;
- NOT_READY.

---

# 23. Próximo passo exato

> **Executar revisão adversarial do Documento 16. Somente após PASS/PASS_WITH_ARCHITECTURAL_DECISIONS definir como o perfil parametriza cadence, thresholds, SLA e prioridade.**
