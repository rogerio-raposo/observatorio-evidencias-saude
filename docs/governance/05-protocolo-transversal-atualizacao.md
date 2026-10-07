# 05 — Protocolo Transversal de Atualização — Arquitetura Conceitual v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 6 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — baseline conceitual aprovada após Documento 06**  
**Dependências:** Documentos 00–04 e 06; Documento 40; Documentos 165–188; OES-P1; migrations 006, 021–026

---

## 1. Finalidade

A Fase 4 transforma a noção geral de atualização do OES em um protocolo transversal auditável, preservando as separações arquiteturais consolidadas nas fases anteriores.

Este documento define a arquitetura conceitual inicial para:

- manutenção M0–M3;
- detecção e qualificação de gatilhos de atualização;
- avaliação de materialidade;
- currentness;
- decisão de atualizar;
- cadência;
- escalonamento;
- priorização;
- comportamento living/M3;
- propagação de mudanças;
- governança;
- fronteiras de automação.

Este documento **não**:

- cria migration;
- fixa thresholds numéricos;
- fixa SLAs em horas ou dias;
- cria automação;
- altera publication gates existentes;
- modifica silenciosamente conclusão científica;
- promove assurance;
- converte Monitor em síntese;
- converte Alert em atualização científica.

---

## 2. Decisão estrutural central

O OES manterá quatro dimensões distintas:

1. **versão científica** — conteúdo científico versionado do alvo;
2. **currentness** — avaliação da atualidade de uma ProductVersion específica;
3. **manutenção** — regime M0–M3 aplicado à vigilância/atualização;
4. **estado operacional/comunicacional** — ciclos de Monitor, Alerts, filas e execução.

Essas dimensões podem se influenciar, mas não são equivalentes.

Em particular:

> **novo sinal não é nova conclusão; Alert não é atualização; Monitor não é síntese; currentness não é assurance; manutenção M3 não é nível N5.**

---

## 3. Invariantes transversais

A Fase 4 adota como invariantes:

1. nenhuma evidência nova altera silenciosamente uma conclusão existente;
2. mudança científica material exige workflow científico e versionamento do alvo;
3. a ProductVersion anterior permanece historicamente preservada;
4. currentness canônico via product.currency_state é avaliado para uma ProductVersion específica, não para uma identidade abstrata; InvestigationVersion não recebe CurrencyState artificial;
5. um evento detectado pode iniciar avaliação sem produzir atualização;
6. uma mudança de currentness pode ocorrer sem nova ProductVersion científica;
7. uma nova ProductVersion científica não herda automaticamente assurance da anterior;
8. um Monitor não herda automaticamente assurance do alvo como validação de seus ciclos;
9. Alert classification não determina automaticamente currentness;
10. cadence vencida não torna automaticamente o produto outdated;
11. M3 não reduz requisitos metodológicos nem humanos do nível N do alvo;
12. propagação entre produtos dependentes abre avaliação; não reescreve produtos dependentes;
13. IA/automação nunca será registrada como human verification;
14. qualquer decisão autoritativa deve preservar ator, tempo, justificativa e provenance.

---

## 4. Estados de manutenção M0–M3

### M0 — Estático

Produto ou investigação sem vigilância ativa prevista.

M0 não significa necessariamente “current”. Um produto pode estar estático e tornar-se outdated.

### M1 — Elegível para atualização

Produto ou investigação sem vigilância ativa contínua, mas sujeito a reavaliação periódica, evento externo ou demanda explícita.

M1 exige que a elegibilidade para atualização esteja documentada, mas não exige Search recorrente.

### M2 — Monitoramento ativo

Existe plano prospectivo de vigilância com ciclos definidos, fontes e critérios de avaliação.

M2 requer Monitor formal quando a vigilância persistente for material ao uso do produto.

### M3 — Evidência Viva

Regime de manutenção contínua ou de alta frequência, com capacidade operacional para detectar, avaliar e incorporar evidência nova de forma sustentada.

M3 é um **regime operacional**, não um rótulo honorífico.

---

## 5. Transições de manutenção

Transições permitidas conceitualmente:

- M0 → M1;
- M0 → M2, quando houver justificativa explícita;
- M1 → M2;
- M2 → M3;
- M3 → M2;
- M2 → M1;
- M1 → M0;
- M3 → M1 ou M0 quando a vigilância deixar de ser justificável ou sustentável.

Toda transição deverá registrar:

- estado anterior;
- estado novo;
- data;
- ator;
- justificativa;
- evidência ou condição motivadora;
- impacto esperado sobre cadence e governança.

Mudança M0–M3 **não implica**, por si só:

- nova conclusão;
- novo assurance;
- mudança de currentness;
- nova ProductVersion científica.

A representação física dessas transições será decidida em contrato posterior e deverá ser history-preserving.

---

## 6. Elegibilidade para M3

M3 só poderá ser ativado quando houver justificativa documentada para o conjunto dos seguintes domínios:

1. **importância/criticidade** do tema ou decisão;
2. **incerteza relevante** ou sensibilidade da conclusão;
3. **expectativa plausível de evidência nova**;
4. **potencial de mudança material** de conclusão, certeza, benefício, dano ou aplicabilidade;
5. **capacidade operacional sustentável** para busca, triagem, avaliação e atualização;
6. **método compatível com incorporação incremental**;
7. **fontes e estratégia prospectivas explícitas**;
8. **cadence explícita**;
9. **governança e assurance compatíveis com o nível N do alvo**;
10. **plano de saída/downshift** se os critérios deixarem de ser atendidos.

Ausência de capacidade operacional bloqueia M3 formal mesmo que o tema seja importante.

A existência deste protocolo, por si só, **não torna operacional o blocker técnico de M3** já existente nas migrations do Monitor. Publicação formal de Monitor M3 continuará bloqueada até que um contrato físico específico da Fase 4:

- represente de forma auditável a política transversal aplicável;
- defina o gate que demonstra que essa política está operacional;
- seja implementado por migration controlada;
- passe por testes específicos, idempotência, rebuild e regressões globais.

Nenhum booleano ou flag de M3 poderá ser simplesmente invertido por documentação.

---

## 7. Unidade de entrada: signal de atualização

A unidade inicial do protocolo é um **signal de atualização** rastreável.

O protocolo distingue duas classes semânticas de signal:

### 7.1 Signal científico/currentness

Pode surgir de:

- Monitoring Cycle;
- Search/SearchHit;
- EvidenceEvent;
- CandidateAssessment;
- Alert;
- detecção de correção ou retratação;
- mudança regulatória fundamentada em evidência;
- revisão metodológica relevante;
- demanda explícita de reavaliação científica.

Pode abrir avaliação de materialidade/currentness quando aceito para esse fim.

### 7.2 Signal operacional

Pode surgir de:

- vencimento de cadence;
- ciclo incompleto;
- falha de cobertura;
- quebra de SLA futuro;
- indisponibilidade de fonte;
- incapacidade operacional para executar o regime M previsto.

Signal operacional exige primeiro avaliação do impacto da lacuna. Ele **não muda currentness automaticamente** e não deve ser tratado como se nova evidência científica tivesse sido encontrada.

> **Signal, científico ou operacional, não equivale a mudança científica material.**

---

## 8. Taxonomia transversal de gatilhos

Os gatilhos preliminares do Documento 03 são organizados em cinco classes.

### 8.1 Nova evidência

Inclui:

- novo ensaio ou estudo relevante;
- nova revisão;
- atualização de revisão existente;
- nova população ou subgrupo relevante;
- novo resultado capaz de afetar magnitude, precisão, benefício ou dano.

### 8.2 Integridade e validade

Inclui:

- retratação;
- correção material;
- expressão de preocupação;
- erro identificado em evidência incorporada;
- mudança metodológica que comprometa interpretação anterior.

### 8.3 Segurança e regulação

Inclui:

- sinal de segurança;
- alteração regulatória sustentada por evidência;
- nova restrição, contraindicação ou informação relevante de risco.

### 8.4 Temporal/operacional

Inclui:

- cadence vencida;
- ciclo incompleto;
- falha de cobertura de fonte obrigatória;
- ausência prolongada de reavaliação quando uma política exigir revisão periódica.

Esses gatilhos não tornam automaticamente o produto outdated nem under_evaluation. Primeiro deve ser avaliado se a lacuna operacional compromete materialmente a capacidade de sustentar a avaliação de atualidade.

### 8.5 Governança/demanda

Inclui:

- solicitação explícita de reavaliação;
- mudança de finalidade de uso;
- mudança de criticidade do contexto decisório;
- necessidade de reroteamento metodológico.

---

## 9. Avaliação de materialidade

Todo signal aceito para avaliação deverá ser analisado contra dimensões explícitas.

Dimensões transversais mínimas:

- benefício;
- dano;
- magnitude;
- precisão;
- certeza/confiança;
- aplicabilidade;
- conclusão;
- escopo;
- validade/integridade;
- status regulatório;
- método.

A avaliação deve distinguir pelo menos:

- **sem mudança material identificada**;
- **mudança potencialmente material**;
- **mudança material confirmada**;
- **ameaça à validade/uso corrente**;
- **evidência insuficiente para decidir**.

Esses resultados são científicos/operacionais e não devem ser confundidos com classification comunicacional do Alert.

---

## 10. Currentness

Esta state machine aplica-se ao currentness canônico de **ProductVersion** por `product.currency_state`.

Para target que seja somente InvestigationVersion:

- não criar CurrencyState fictício;
- registrar avaliação/decisão de atualização no mecanismo transversal apropriado;
- versionar InvestigationVersion quando houver mudança material da investigação;
- criar nova ProductVersion apenas quando um produto científico correspondente também mudar.

O vocabulário canônico permanece:

- current;
- under_evaluation;
- update_recommended;
- outdated;
- archived.

### 10.1 Semântica

**current**  
Não há, segundo a última avaliação registrada, razão suficiente para considerar a versão inadequada para uso corrente no escopo declarado.

**under_evaluation**  
Existe signal material ainda não resolvido ou avaliação de atualidade em andamento.

**update_recommended**  
A versão ainda pode ser utilizável dentro de limites explícitos, mas existe justificativa suficiente para atualização científica.

**outdated**  
A versão não deve ser tratada como síntese atual adequada para seu uso declarado sem qualificação substancial ou atualização.

**archived**  
A avaliação de currentness da ProductVersion foi encerrada para uso corrente por supersessão/arquivamento ou decisão explícita.

`currency_status='archived'` permanece distinto de:

- editorial status `archived` da ProductVersion;
- `core.entity_version.version_status='archived'`;
- supersessão científica da versão.

Esses estados podem coexistir, mas não devem ser colapsados.

### 10.2 Regras

1. detecção de signal não altera currentness automaticamente;
2. mudança de currentness exige assessment registrado;
3. current → under_evaluation é a transição normal quando um signal científico/currentness, ou uma lacuna operacional materialmente relevante, é explicitamente aceito para avaliação de atualidade;
4. under_evaluation → current exige conclusão documentada de ausência de impacto material suficiente;
5. under_evaluation → update_recommended exige decisão documentada de necessidade de atualização;
6. under_evaluation → outdated exige decisão documentada de inadequação para uso corrente;
7. update_recommended pode evoluir para outdated se a ameaça se intensificar;
8. conclusão de atualização científica normalmente produz nova ProductVersion; não “reescreve” a anterior;
9. retorno de outdated para current na mesma versão é excepcional e exige correção/reavaliação explicitamente justificada;
10. archived é terminal para uso corrente, preservando histórico.

---

## 11. Decisão de atualização

Após avaliação de materialidade, a decisão operacional deverá escolher explicitamente entre:

- nenhuma atualização científica;
- manter sob observação;
- atualizar currentness apenas;
- iniciar atualização científica incremental;
- iniciar atualização científica ampla;
- rerotear profundidade/método;
- suspender uso corrente enquanto atualização é preparada.

Não se cria neste documento uma taxonomia codificada U0–Ux.

A profundidade da atualização deverá ser proporcional a:

- natureza do signal;
- parte do corpo de evidência afetada;
- risco de propagação;
- criticidade;
- adequação da estratégia anterior;
- necessidade de nova busca completa;
- necessidade de nova avaliação de risco de viés/certainty;
- mudança de pergunta ou escopo.

---

## 12. Relação com versionamento científico

### 12.1 Target ProductVersion

Mudança científica material em produto deverá ocorrer por nova ProductVersion do alvo e poderá usar as classes já existentes em `product.version_change_class`:

- editorial;
- new_evidence;
- scientific_correction;
- quantitative_change;
- certainty_change;
- applicability_change;
- conclusion_change.

Uma atualização pode possuir múltiplas classes.

Atualização de currentness isolada não exige nova ProductVersion científica.

### 12.2 Target InvestigationVersion

Quando o target primário for InvestigationVersion, mudança material da investigação deverá ocorrer por nova InvestigationVersion history-preserving.

Se essa mudança alterar um produto científico derivado, o produto correspondente deverá ser versionado separadamente segundo seus próprios gates.

Mudança de escopo capaz de alterar a Question deverá acionar reroteamento e pode exigir nova QuestionVersion/InvestigationVersion, conforme a arquitetura existente.

> **Não criar ProductVersion apenas para simular versionamento de uma Investigation sem produto correspondente.**

---

## 13. Relação com Monitor

O Monitor:

- detecta e organiza signals;
- executa ciclos prospectivos;
- avalia cobertura e completude;
- pode sustentar reassessment de currentness;
- pode recomendar atualização;
- não altera conclusão do target;
- não cria nova versão científica do target por simples conclusão de cycle.

Um Monitoring Cycle concluído sem signal material:

> não cria automaticamente nova ProductVersion.

Um Monitoring Cycle incompleto:

> não pode ser usado como evidência de “nenhuma mudança”; deve preservar a incompletude e acionar avaliação do impacto da lacuna quando pertinente.

A incompletude somente deve abrir `under_evaluation` do target ProductVersion quando a análise da lacuna concluir que ela compromete materialmente a sustentação de currentness.

---

## 14. Relação com Alert

Alert continua sendo produto comunicacional persistente.

As categorias:

- informational;
- relevant;
- critical;

e as prioridades:

- routine;
- priority;
- urgent;

não são equivalentes a currentness.

Regras:

1. critical não implica automaticamente outdated;
2. urgent não cria automaticamente SLA numérico;
3. Alert não cria atualização científica;
4. Alert pode iniciar ou acelerar reassessment;
5. Alert incorporado deve apontar para a versão ou CurrencyState que materializou sua resolução quando aplicável;
6. auto-classification permanece não autorizada até contrato específico posterior.

---

## 15. Cadence

A Fase 4 adota uma gramática de cadence antes de fixar números.

Toda política de cadence deverá explicitar:

- regime M;
- data de referência;
- frequência ou condição de disparo;
- fontes cobertas;
- janela temporal;
- tolerância operacional;
- regra de atraso;
- comportamento diante de ciclo incompleto;
- condição para reavaliação da própria cadence.

Princípios:

- M1 pode usar reavaliação periódica ou por evento;
- M2 exige intervalo prospectivamente definido;
- M3 exige frequência compatível com caráter living e latência das fontes;
- idade cronológica isolada não determina outdated;
- cadence perdida gera dívida operacional/avaliação, não conclusão científica automática.

Thresholds numéricos serão definidos somente após validação da gramática e de perfis de risco.

---

## 16. Relógios de SLA

Antes de definir durações, o OES reconhece relógios distintos:

1. detecção → triagem;
2. triagem → avaliação de materialidade;
3. materialidade → decisão de atualização;
4. decisão → início do workflow científico;
5. início → conclusão da atualização;
6. conclusão científica → revisão/publicação quando aplicável.

SLAs futuros devem:

- possuir evento inicial e final inequívocos;
- definir condições de pausa;
- distinguir atraso operacional de risco científico;
- ser calibrados por criticidade/materialidade;
- nunca transformar vencimento de prazo em mudança científica automática.

---

## 17. Priorização transversal

A priorização entre signals/Alerts/updates deverá considerar, qualitativamente antes de qualquer score:

1. ameaça a segurança ou validade;
2. potencial de reversão/modificação substancial da conclusão;
3. criticidade da decisão suportada;
4. currentness atual;
5. magnitude e certeza do possível impacto;
6. abrangência de dependências afetadas;
7. urgência regulatória;
8. tempo desde cutoff e atraso operacional;
9. capacidade e custo de atualização.

Nenhum fator isolado determina prioridade global.

Pesos e scores não são definidos neste documento.

---

## 18. Propagação de mudanças

A propagação deverá utilizar lineage/provenance e dependency graph existentes.

Quando uma nova versão científica é criada:

1. dependentes potencialmente afetados são identificados;
2. abre-se avaliação de impacto;
3. nenhum dependente é modificado automaticamente;
4. currentness de cada dependente que seja ProductVersion é decidido localmente; InvestigationVersion dependente recebe avaliação de impacto sem CurrencyState artificial;
5. Monitor ligado à versão anterior deve passar por re-baselining/rebinding explícito se continuar ativo;
6. ponteiro para target não deve ser regravado silenciosamente;
7. Alerts relacionados podem ser marcados como incorporados apenas com linkage rastreável.

Mudança upstream não implica mudança downstream sem avaliação de correspondência e materialidade.

---

## 19. Governança

Toda decisão autoritativa da Fase 4 deverá registrar:

- objeto afetado;
- estado anterior;
- estado novo ou decisão;
- signal/source;
- evidência considerada;
- ator e actor_type;
- método/regra aplicada;
- justificativa;
- timestamp;
- verificação aplicável;
- vínculo com artifact/decision record quando necessário.

Decisões que alterem conclusão científica continuam sujeitas aos gates do produto e nível N correspondentes.

M3 não cria exceção a controles humanos qualificados exigidos por N3/N4.

Ativação formal de M3 exige decisão explícita de governança e capacidade documentada.

---

## 20. Fronteira de IA e automação

Na baseline v0.1, automação/IA pode:

- detectar candidatos;
- executar verificações mecânicas;
- sugerir classificação;
- sugerir materialidade;
- calcular prazos;
- sinalizar cadence vencida;
- priorizar provisoriamente filas;
- preparar draft de decisões.

Na baseline v0.1, automação/IA **não pode de forma autoritativa e sem gate explícito**:

- alterar conclusão científica;
- promover assurance;
- registrar human verification;
- publicar nova ProductVersion;
- declarar produto outdated apenas por idade;
- promover M2 → M3;
- classificar automaticamente Alert formal como critical;
- propagar mudança científica para produtos dependentes;
- resolver conflito metodológico.

Automação autoritativa futura exigirá regra específica, teste e governança explícita.

---

## 21. Consequências para o contrato físico futuro

O contrato físico da Fase 4 provavelmente precisará representar, de forma aditiva e history-preserving:

- policy/version de manutenção;
- transição M0–M3;
- update signal;
- materiality assessment;
- update decision;
- cadence specification;
- deadline/SLA instance;
- propagation/impact assessment;
- re-baselining de Monitor;
- representação explícita do gate de política M3 operacional, sem hardcode documental.

Esta lista é candidata, não autorização de migration.

A implementação deverá preferir reuso de:

- ProductVersion;
- InvestigationVersion;
- Search/SearchHit;
- CurrencyState;
- VersionChangeClass;
- MethodDecision;
- Assurance;
- provenance/dependency;
- maintenance Monitor/Alert.

---

## 22. Decisões explicitamente adiadas

Ainda não definidos:

- thresholds numéricos;
- dias/horas de SLA;
- cadence padrão por produto;
- fórmula de score de prioridade;
- auto-classification;
- auto-escalation;
- notification channels;
- integração de mensageria;
- scheduler;
- escolha tecnológica da automação;
- contrato físico;
- qualquer migration da Fase 4, cuja numeração e escopo somente serão definidos após o contrato físico;
- UI operacional.

Esses itens dependem da revisão adversarial desta arquitetura.

---

## 23. Gate de saída deste bloco

Antes de qualquer contrato de dados ou migration da Fase 4 deverá existir revisão adversarial explícita cobrindo pelo menos:

- separação maintenance × currentness × editorial × assurance;
- transições M0–M3;
- M3;
- currentness state machine;
- Alert × update;
- Monitor × update;
- propagação;
- cadence;
- SLA;
- governança;
- fronteira de automação.

Resultado permitido:

- PASS;
- PASS_WITH_ARCHITECTURAL_DECISIONS;
- REVISE;
- NOT_READY.

---

## 24. Próximo passo exato

> **Especificar o Contrato de Dados v0.1 do Protocolo Transversal de Atualização, conforme o gate do Documento 06, sem implementar migration antes de novo gate de coerência física.**
