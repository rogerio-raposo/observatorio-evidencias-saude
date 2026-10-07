# 25 — Arquitetura Transversal de Prioridade e Escalation

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISED_AFTER_ADVERSARIAL_REVIEW**  
**Dependências:** Documentos 05–09, 16–24; migrations 021–028  
**Objeto:** prioridade transversal, escalation e relação com risk profile, Alert, materiality, currentness, SLA, capacidade e dependências

---

## 1. Finalidade

Definir a arquitetura transversal de prioridade e escalation do OES antes de qualquer contrato físico adicional.

Este documento responde:

> **diante de múltiplos signals, Alerts, avaliações, updates e obrigações operacionais concorrentes, o que deve receber atenção primeiro, por quê, e quando a situação deve ser encaminhada a uma instância humana/operacional/governamental adicional?**

A resposta não deve:

- produzir verdade científica;
- substituir MaterialityAssessment;
- alterar CurrencyState;
- promover assurance;
- publicar produto;
- ativar M3;
- transformar atraso em conclusão;
- transformar capacidade disponível em “risco baixo”.

---

## 2. Escopo

Este bloco define:

1. objeto conceitual de prioridade transversal;
2. classes qualitativas de resposta;
3. regras de dominância/não compensação;
4. relação com criticidade, materialidade e currentness;
5. relação com Alert;
6. relação com SLA e breach;
7. relação com dependency reach;
8. relação com capacidade/feasibility;
9. motivos e rotas de escalation;
10. autoridade;
11. lifecycle conceitual;
12. versionamento/snapshot;
13. critérios para um futuro contrato físico.

Não define ainda:

- duração numérica de SLA;
- score ponderado;
- pesos quantitativos;
- scheduler;
- notification channels;
- auto-escalation;
- propagation automática;
- M3 readiness;
- migration 029.

---

## 3. Separações obrigatórias

O OES deverá manter separados:

### 3.1 Prioridade

Responde:

> **qual necessidade relativa de resposta existe agora para este caso?**

É um estado operacional/governamental derivado de evidência e contexto.

### 3.2 Escalation

Responde:

> **este caso precisa ser encaminhado a uma rota de autoridade, coordenação ou intervenção adicional?**

Escalation é ação/roteamento.

### 3.3 Materialidade

Responde:

> **o signal pode ou confirmou mudança material?**

Permanece em `maintenance.materiality_assessment`.

### 3.4 Currentness

Responde:

> **qual o estado de atualidade da ProductVersion?**

Permanece em `product.currency_state`.

### 3.5 SLA

Responde:

> **a obrigação operacional está dentro ou fora do prazo/regra aplicável?**

Não é prioridade por si só.

### 3.6 Feasibility/capacidade

Responde:

> **o OES possui capacidade sustentável para executar a resposta necessária?**

Capacidade não mede importância.

---

## 4. Objeto da prioridade

A prioridade transversal não pertence à identidade abstrata de um Product ou Investigation.

Ela deve ser avaliada sobre um **caso concreto de manutenção**, ancorado em:

- UpdateSignal;
- target version;
- UpdatePolicy vigente/snapshot aplicável;
- estágio do workflow de manutenção;
- contexto temporal correspondente.

O mesmo target pode ter:

- múltiplos signals simultâneos;
- prioridades diferentes;
- uma prioridade agregada de fila derivada de vários casos.

Regra:

> **não persistir “prioridade do produto” como atributo permanente sem caso/version/contexto.**

---

## 5. PriorityAssessment conceitual

O futuro contrato deverá ser capaz de representar uma avaliação de prioridade history-preserving.

Campos conceituais mínimos:

- target ProductVersion ou InvestigationVersion;
- UpdateSignal;
- stage;
- assessed_at;
- response_class;
- dominance_basis;
- materiality/currentness inputs observados;
- risk-profile snapshot/reference;
- Alert inputs quando houver;
- SLA inputs quando houver;
- dependency reach;
- feasibility status;
- rationale;
- assessed_by;
- actor_type;
- verification_status;
- authority_status = proposal | authoritative;
- supersedes PriorityAssessment opcional.

Este documento:

> **não autoriza ainda a criação física de `maintenance.priority_assessment`.**

---

## 6. Estágios de prioridade

PriorityAssessment deve poder ocorrer em momentos distintos.

### 6.1 signal_triage

Antes de materialidade qualificante.

Inputs mais fortes:

- tipo/classe do signal;
- safety/integrity;
- criticidade;
- Alert;
- fixed deadline externo;
- target currentness já conhecido;
- risk profile.

Resultado é necessariamente preliminar.

### 6.2 materiality_resolution

Após MaterialityAssessment qualificante.

Novo input decisivo:

- outcome de materialidade;
- dimensões afetadas;
- verification status.

### 6.3 update_decision

Após UpdateDecision autoritativa.

Inputs adicionais:

- decision_type;
- currency_action;
- necessidade de workflow;
- `suspend_current_use`;
- `reroute_method`.

### 6.4 execution

Durante workflow científico/operacional.

Inputs adicionais:

- SLA state;
- backlog/feasibility;
- external deadline;
- dependency impact;
- novas ocorrências.

### 6.5 resolution

Quando o caso é encerrado, incorporado, descartado, invalidado ou substituído.

A prioridade não deve permanecer indefinidamente “ativa” após terminalidade causal.

---

## 7. Não criar score aditivo

Não usar:

```text
priority_score =
  criticality +
  materiality +
  alert_urgency +
  currentness +
  breach +
  dependency_reach -
  update_cost
```

Razões:

1. dimensões não são intercambiáveis;
2. safety/integrity possui dominância qualitativa;
3. capacidade/custo não compensam risco;
4. breach operacional não é materialidade científica;
5. dependency reach mede alcance, não probabilidade de mudança;
6. Alert priority é local/comunicacional;
7. pesos artificiais produziriam falsa precisão.

O método baseline será:

> **regras de dominância + floors qualitativos + modificadores explícitos + rationale auditável.**

---

## 8. Classe transversal de resposta

A arquitetura define uma classe qualitativa própria, distinta de Alert `reassessment_priority`.

Domínio conceitual:

- `standard`;
- `expedited`;
- `urgent`;
- `immediate`.

Essas classes são:

> **ordinais para resposta operacional/governamental, sem duração temporal embutida.**

Não significam:

- standard = X dias;
- expedited = Y dias;
- urgent = Z horas;
- immediate = publicação/suspensão automática.

Durações futuras dependerão de SLA Rule.

---

## 9. Semântica das classes

### 9.1 standard

Caso válido sem condição atual que exija precedência especial.

Pode incluir:

- signal de baixa criticidade;
- no_material_change;
- observação sem currentness threat;
- demanda ordinária de manutenção.

Não significa:

- “sem importância”;
- “current”;
- “sem necessidade de avaliação”.

### 9.2 expedited

Caso deve preceder a fila standard.

Pode decorrer de:

- materialidade potencial relevante;
- criticidade/sensibilidade alta;
- update_recommended;
- fixed deadline;
- Alert formal forte;
- dependency reach amplo com impacto plausível.

Não implica emergência.

### 9.3 urgent

Resposta qualificada deve receber precedência elevada.

Pode decorrer de:

- validade/uso ameaçados;
- mudança material confirmada em contexto crítico;
- target outdated com alta criticidade;
- safety/integrity qualificado;
- obrigação temporal crítica;
- combinação de fatores não compensáveis.

Não muda currentness automaticamente.

### 9.4 immediate

Classe excepcional.

Indica:

> **necessidade de resposta imediata ao caso.**

A classe não identifica, por si só, a rota de governança. Quando houver obrigação de governança, isso será representado separadamente por escalation reason/route.

Exemplos conceituais:

- `suspend_current_use`;
- retraction/correction que ameaça diretamente validade e uso;
- regulatory action incompatível com continuidade de uso;
- safety threat grave qualificada;
- conflito de autoridade que impede resposta a risco grave.

Não significa:

- atualização científica automática;
- retirada automática de publicação;
- mudança automática de CurrencyState;
- auto-notification.

---

## 10. Hierarquia de resolução

A prioridade deverá ser resolvida em ordem lógica, não por soma.

### Passo 1 — dominance gates

Verificar:

- safety/integrity;
- validity/use threat;
- `suspend_current_use`;
- external regulatory constraint;
- autoridade externa/fixed deadline;
- external legal/normative constraint que afete a resposta.

### Passo 2 — scientific/decision need

Considerar:

- A1 criticality;
- A3 conclusion sensitivity;
- MaterialityAssessment;
- currentness;
- decision_type;
- uncertainty ainda não resolvida.

### Passo 3 — coordination reach

Considerar:

- A5 dependency reach;
- quantidade/tipo de dependentes;
- necessidade de propagation assessment;
- impacto de coordenação.

### Passo 4 — operational pressure

Considerar:

- SLA warning/breach;
- wall-clock age;
- repeated breach;
- external deadline;
- unresolved queue age.

### Passo 5 — feasibility

Considerar:

- B3 surveillance load;
- B4 incorporation cost;
- B5 sustainable capacity.

Feasibility pode abrir escalation.

Não pode reduzir priority class por si só.

### Passo 6 — rationale

Registrar:

- fatores dominantes;
- conflitos;
- floors;
- modificadores;
- motivo de qualquer downgrade;
- motivo de qualquer escalation.

---

## 11. Regras de floor

Floor significa:

> a classe não pode ser inferior à indicada enquanto a condição qualificada permanecer ativa, salvo reavaliação explícita que demonstre que a condição deixou de se aplicar.

### 11.1 safety/integrity qualificado

Signal `safety_signal`, `retraction`, `expression_of_concern`, `correction` ou `regulatory_change`:

- não ganha floor apenas pelo nome;
- deve considerar fonte, A4, target e qualificação;
- quando houver ameaça de uso/validade qualificada:
  - pelo menos `urgent`;
  - escalation assessment obrigatório.

### 11.2 validity_or_use_threat

MaterialityAssessment:

> `validity_or_use_threat`

impõe:

- floor `urgent`;
- escalation assessment obrigatório.

### 11.3 suspend_current_use

UpdateDecision:

> `suspend_current_use`

impõe:

- floor `immediate`;
- rota de current-use/safety governance obrigatória.

A decisão ainda não executa retirada/publicação automaticamente.

### 11.4 material_change_confirmed

Com A1 high:

- floor `urgent`.

Sem A1 high:

- é strong modifier;
- não cria floor universal isoladamente;
- response class depende do restante do contexto.

### 11.5 potentially_material

Com A1 high ou A3 high:

- pelo menos `expedited`.

### 11.6 update_recommended

Target ProductVersion em:

> `update_recommended`

é strong modifier de prioridade, mas não cria floor universal isoladamente.

Se combinado com:

- A1 high;
- ameaça safety/integrity;
- external deadline;
- materialidade qualificada relevante;

pode sustentar `expedited` ou `urgent`, conforme rationale.

### 11.7 outdated

`outdated` não implica automaticamente `immediate_governance`.

Mas:

- não pode ser ignorado por capacidade;
- com A1 high → floor `urgent`;
- com uso corrente material → escalation assessment.

---

## 12. Insufficient_to_decide

`insufficient_to_decide` não significa baixa prioridade.

Se coexistir com:

- A1 high;
- A4 high;
- deadline regulatório;
- target under_evaluation/outdated;
- safety/integrity signal;

o caso poderá ser:

- `expedited`;
- `urgent`;

conforme rationale.

Regra:

> **incerteza relevante não deve produzir downgrade silencioso.**

---

## 13. Alert como input, não como autoridade transversal

Alert possui:

### classification

- informational;
- relevant;
- critical.

### reassessment_priority

- routine;
- priority;
- urgent.

Esses campos permanecem:

> **classificação/urgência comunicacional local do AlertVersion.**

Não existe equivalência automática:

```text
Alert urgent != transversal urgent
Alert critical != transversal immediate
```

Entretanto:

- Alert `critical`;
- Alert `reassessment_priority='urgent'`;

exigem **priority reassessment** do caso transversal.

Regra anti-silent-downgrade:

> se um Alert human-verified/A2 `critical` ou `urgent` sustenta o caso, uma PriorityAssessment transversal inferior a `expedited` exige rationale explícita.

A regra não cria materialidade.

---

## 14. Materiality como input qualificado

PriorityAssessment deve distinguir:

- no assessment;
- assessment não qualificado;
- no_material_change;
- potentially_material;
- material_change_confirmed;
- validity_or_use_threat;
- insufficient_to_decide.

MaterialityAssessment não deve ser reinterpretado pela prioridade.

PriorityAssessment:

- pode usar o outcome;
- não pode alterá-lo;
- não pode “compensar” outcome científico com capacidade;
- para `authority_status='authoritative'`, um outcome científico usado como floor/strong modifier deve estar `human_verified` ou `human_consensus` quando a regra depender de qualificação científica;
- assessment AI-only pode sustentar `proposal`, não floor científico autoritativo.

---

## 15. Currentness como input, não resultado

Para ProductVersion:

- current;
- under_evaluation;
- update_recommended;
- outdated;
- archived.

Regras:

1. prioridade lê currentness;
2. prioridade não escreve currentness;
3. `current` não impede prioridade alta se houver signal grave novo;
4. `under_evaluation` não significa urgência uniforme;
5. `outdated` eleva necessidade conforme criticidade/uso;
6. archived/invalidated pode encerrar o caso ou exigir redirecionamento, não simples promoção de fila.

InvestigationVersion:

> sem CurrencyState artificial.

---

## 16. SLA × prioridade — regra anti-circularidade

A arquitetura de SLA já determinou que uma SLA Instance congela:

- rule;
- target;
- risk/priority inputs;
- due;
- calendar;
- pause policy.

Portanto:

### 16.1 no início do SLA

A SLA Rule pode usar a PriorityAssessment vigente como input.

### 16.2 depois do início

Mudança de prioridade:

> **não recalcula silenciosamente a SLA Instance existente.**

Pode:

- abrir nova obligation quando normativamente aplicável;
- exigir explicit rebase;
- alterar prioridade operacional do caso.

### 16.3 breach

SLA breach:

- não cria materiality;
- não muda currentness;
- não é origem única da prioridade científica;
- atua como **operational pressure modifier**;
- exige escalation assessment quando a rule assim determinar;
- preserva first_breached_at.

### 16.4 repeated breach

Breach repetido pode aumentar:

- prioridade operacional;
- escalation de capacidade/governança;

sem afirmar que a evidência científica é mais material.

---

## 17. Dependency reach

A5 continua sendo:

- restricted;
- moderate;
- broad;
- systemic.

Regra:

> dependency reach não aumenta, sozinho, materialidade do target.

Entretanto:

- broad/systemic pode elevar prioridade de **coordenação e propagation assessment**;
- quando material_change_confirmed coexistir com broad/systemic:
  - dependency escalation assessment é obrigatório;
- nenhum dependente muda automaticamente.

---

## 18. Capacidade e custo

### 18.1 Não compensação

B5 insufficient/unavailable:

> nunca reduz priority class.

B4 very_high:

> nunca reduz importância.

### 18.2 Efeito correto

Capacidade insuficiente diante de caso `urgent` ou `immediate` deve produzir:

- capacity escalation;
- resource/governance issue;
- eventualmente scope/sequence decision explícita.

Resultado correto:

> **high priority / insufficient capacity**

Não:

> “priority moderate porque não há equipe”.

### 18.3 Queue overload

Fila excessiva:

- é operational condition;
- pode exigir repriorização transparente;
- não autoriza downgrade silencioso de casos dominantes.

---

## 19. Escalation não é prioridade

Um caso pode ser:

- urgent sem escalation adicional, se rota já estiver adequadamente qualificada;
- expedited + escalation de capacidade;
- standard + governance escalation por conflito institucional;
- immediate + escalation de safety/current-use quando a condição correspondente existir.

Logo:

> **priority class e escalation são eixos distintos.**

---

## 20. Motivos canônicos de escalation

Taxonomia conceitual v0.1:

1. `safety_integrity`;
2. `validity_or_use`;
3. `scientific_materiality`;
4. `current_use_control`;
5. `methodological_reroute`;
6. `operational_delay`;
7. `capacity_constraint`;
8. `dependency_coordination`;
9. `regulatory_external`;
10. `governance_exception`.

Múltiplos motivos podem coexistir.

Não criar um único `severity_score`.

---

## 21. Rotas conceituais de escalation

Escalation deve poder encaminhar para uma ou mais rotas:

- `operational_owner`;
- `qualified_scientific_review`;
- `methodological_governance`;
- `current_use_governance`;
- `safety_integrity_governance`;
- `publication_governance`;
- `dependency_coordination`;
- `resource_governance`.

Rotas não são níveis hierárquicos numéricos.

Uma rota pode ser obrigatória por motivo específico.

---

## 22. Regras motivo → rota

### safety_integrity

Deve incluir:

- safety_integrity_governance;
- qualified_scientific_review quando houver componente científico.

### validity_or_use

Deve incluir:

- current_use_governance;
- qualified_scientific_review.

### scientific_materiality

Pode incluir:

- qualified_scientific_review;
- operational_owner.

### current_use_control

Deve incluir:

- current_use_governance.

### methodological_reroute

Deve incluir:

- methodological_governance.

### operational_delay

Pode incluir:

- operational_owner;
- resource_governance quando persistente/estrutural.

### capacity_constraint

Deve incluir:

- resource_governance.

### dependency_coordination

Deve incluir:

- dependency_coordination.

### regulatory_external

Deve incluir:

- operational_owner;
- governance route compatível com o objeto regulatório.

### governance_exception

Exige rationale explícita e rota humana.

---

## 23. Escalation lifecycle conceitual

Um futuro registro deverá distinguir:

- `candidate`;
- `active`;
- `acknowledged`;
- `resolved`;
- `cancelled_invalidated`.

### candidate

Condição foi detectada/proposta.

### active

Escalation foi ativada por autoridade/regra válida.

### acknowledged

Rota destinatária assumiu responsabilidade.

Não encerra o problema.

### resolved

Possui:

- resolution disposition;
- rationale;
- resolver;
- resolved_at;
- vínculo ao ato/decision correspondente.

### cancelled_invalidated

A base causal deixou de existir ou foi invalidada.

Deve preservar histórico.

---

## 24. Não resolver escalation pelo efeito científico

Escalation `resolved` não significa:

- no_material_change;
- current;
- update concluído;
- publicação concluída.

Resolução deve declarar o que foi resolvido.

Exemplos:

- capacity escalation resolvida porque recurso foi alocado;
- safety escalation resolvida porque uso foi suspenso;
- methodological escalation resolvida por MethodDecision;
- dependency escalation resolvida porque dependentes foram avaliados.

---

## 25. Autoridade

### 25.1 Status de autoridade

Toda PriorityAssessment futura deverá declarar:

- `proposal`;
- `authoritative`.

Regras:

- proposal pode ser produzido por AI/system ou humano;
- authoritative exige ator humano compatível com o fundamento da prioridade;
- authoritative downgrade de `urgent`/`immediate` exige rationale e autoridade compatível com o fundamento dominante;
- owner/governance não substitui qualificação científica quando esta for requerida.

### 25.2 AI/system

Pode:

- calcular sinais mecânicos;
- detectar floor potencial;
- propor PriorityAssessment;
- propor escalation candidate;
- identificar SLA breach;
- listar dependências;
- sugerir rota.

Não pode, na baseline v0.1:

- criar human verification;
- reduzir floor de safety/validity;
- ativar escalation autoritativa que produza decisão científica;
- suspender uso;
- alterar currentness;
- publicar;
- promover M3.

### 25.3 Human reviewer/expert

Pode qualificar:

- materialidade;
- prioridade científica;
- safety/integrity impact;
- rota científica/metodológica.

Dentro de sua competência.

### 25.4 Owner/governance

Pode decidir:

- alocação operacional;
- activation de escalation de governança;
- prioridade operacional final quando não contradizer floors científicos;
- resource response;
- current-use control dentro da governança aplicável.

Owner não substitui scientific assessment quando este é requerido.

---

## 26. Auto-escalation

Permanece:

> **NOT_AUTHORIZED**

A arquitetura admite que, no futuro, fatos puramente mecânicos como:

- SLA breach;
- monitor coverage failure;
- fixed deadline reached;

possam gerar automaticamente:

- issue;
- escalation candidate.

Mas:

> activation autoritativa automática exigirá contrato próprio, regra explícita, testes e governança.

Na baseline:

- `candidate` pode ser gerado automaticamente;
- `active` exige autoridade humana compatível;
- issue mecânico não equivale a escalation ativa.

Migration 029 não é autorizada por este documento.

---

## 27. Downgrade de prioridade

Priority class pode diminuir somente por evento justificável.

Exemplos:

- signal invalidated;
- source invalidada;
- MaterialityAssessment = no_material_change;
- target superseded e caso redirecionado;
- duplicate/already covered;
- external deadline removido;
- risk profile reavaliado com rationale.

Não é justificativa suficiente:

- falta de pessoal;
- fila longa;
- alto custo;
- desejo de cumprir SLA;
- ausência de reviewer disponível.

Todo downgrade de:

- urgent;
- immediate;

deve exigir rationale explícita e autoridade compatível.

---

## 28. Promotion de prioridade

Pode ocorrer por:

- novo safety/integrity input;
- materiality qualificada;
- mudança de currentness;
- UpdateDecision;
- Alert novo;
- dependency reach reavaliado;
- breach;
- fixed deadline;
- capacity failure;
- nova informação regulatória.

Promotion:

> não altera retrospectivamente snapshots anteriores.

---

## 29. Conflitos

Exemplo:

- material_change_confirmed;
- A1 high;
- capacidade unavailable.

Resultado:

- priority = urgent;
- feasibility = unavailable;
- capacity escalation = required.

Não reduzir prioridade.

Outro exemplo:

- Alert critical/urgent;
- MaterialityAssessment posterior = no_material_change;
- source válida.

Resultado possível:

- PriorityAssessment posterior pode cair para standard;
- exige rationale explícita reconciliando o Alert;
- Alert histórico não é reescrito.

---

## 30. Relação com Monitor

Monitor:

- fornece detections;
- CandidateAssessment;
- EvidenceEvent;
- coverage/completeness;
- cycle decision;
- escalation_recommendation local.

`monitor_cycle.escalation_recommendation`:

- none;
- evaluate_alert;
- urgent_reassessment.

Esse campo:

> **não é a escalation transversal da Fase 4.**

Ele é input.

`urgent_reassessment` deve disparar priority/escalation reassessment, não ativação automática.

---

## 31. Relação com MethodDecision

UpdateDecision:

> `reroute_method`

pode exigir:

- escalation reason `methodological_reroute`;
- route `methodological_governance`.

Isso não funde:

- `maintenance.update_decision`;
- `investigation.method_decision`.

Um futuro linkage explícito pode conectá-los.

Não inferir MethodDecision automaticamente.

---

## 32. Relação com propagação

Quando um caso material afeta target com dependency reach broad/systemic:

1. identificar dependentes;
2. abrir escalation/coordination assessment;
3. priorizar impact assessment conforme alcance/criticidade;
4. não editar dependentes;
5. decidir currentness localmente por dependente;
6. preservar lineage.

Priority não é propagation.

---

## 33. Relação com M0–M3

Priority class não altera:

- effective_maintenance_level;
- recommended_maintenance_level;
- cadence_mode.

Um caso `urgent` pode surgir em target M0/M1.

Um target M3 pode ter caso `standard`.

Regime de manutenção e prioridade de caso permanecem independentes.

---

## 34. Relação com N0–N4

Priority não altera nível N.

Caso urgente em N4:

- continua exigindo controles N4.

Caso imediato em N3/N4:

- não reduz human qualified review.

Urgência não autoriza atalho metodológico silencioso.

---

## 35. Priority × SLA Rule selection

Futura SLA Rule poderá usar:

- response_class;
- dominance_basis;
- A1/A4;
- materiality;
- currentness;
- external deadline.

Mas:

1. nenhuma duração é definida aqui;
2. mesma response_class pode ter SLA diferente por domínio;
3. SLA Instance congela a regra;
4. breach posterior modifica pressão/escalation, não retroage rule selection.

---

## 36. T4 — threshold de escalation

Documento 16 reservou T4.

T4 não será necessariamente numérico.

Pode ser:

- categórico;
- condicional;
- composto por dominance rule.

Exemplos de T4 qualitativo:

- validity_or_use_threat;
- suspend_current_use;
- urgent + capacity unavailable;
- confirmed material change + systemic dependencies;
- breached_open sob regra que exige governance route.

Nenhum exemplo define SLA numérico.

---

## 37. T5 — threshold temporal

T5 continua pertencendo ao tempo/SLA.

T5 pode:

- abrir operational_delay escalation candidate;
- promover pressão operacional;
- acionar resource governance.

T5 não:

- confirma materialidade;
- muda currentness;
- produz outdated.

---

## 38. Floor × modifier × feasibility

Modelo conceitual:

```text
PriorityDisposition =
  dominance_floor
  + scientific/decision context
  + coordination modifiers
  + operational pressure modifiers

Feasibility =
  separate axis

Escalation =
  reason(s) + route(s) + authority + lifecycle
```

O sinal “+” acima significa composição lógica, não soma numérica.

---

## 39. Snapshot e temporalidade

PriorityAssessment deve preservar:

- inputs usados;
- target version;
- UpdateSignal;
- policy;
- risk profile;
- materiality/currentness conhecidos;
- Alert version;
- SLA state;
- dependency state;
- feasibility;
- assessment timestamp.

Mudanças posteriores não reescrevem o snapshot.

Nova avaliação:

> cria novo record/supersession.

---

## 40. Concurrency

Múltiplos signals podem estar ativos para o mesmo target.

A arquitetura deve permitir:

- prioridade por signal/case;
- identificação derivada da maior necessidade de resposta na fila;
- agrupamento operacional sem fundir causalidade;
- uma escalation cobrir múltiplos casos somente com linkage explícito.

Não persistir, por default, uma prioridade agregada única que substitua as PriorityAssessments causais. Qualquer agregação futura deverá manter linkage explícito para todos os casos componentes.

Não deduplicar apenas porque target é o mesmo.

---

## 41. Target supersession

Se target for superseded durante caso ativo:

- priority record histórico permanece;
- abrir issue/reassessment;
- não retarget silenciosamente;
- novo target precisa de novo vínculo/caso ou carry-forward explícito.

Se risco persiste:

> prioridade deve ser reavaliada no novo target.

---

## 42. Invalidated signal/source

Signal invalidated:

- caso não deve continuar sendo promovido por esse signal;
- active escalation baseada exclusivamente nele deve ser revista;
- histórico permanece.

Source invalidada:

- abre issue;
- pode exigir priority reassessment;
- não apaga retrospectivamente decisões válidas sem governança própria.

---

## 43. Uso de prioridade em fila

Uma fila futura poderá ordenar por:

1. response_class;
2. dominance basis;
3. deadline/breach;
4. age;
5. dependency coordination;
6. tie-breaker auditável.

Mas:

- implementação de queue ordering não é autorizada aqui;
- não usar timestamp de criação tardia para gaming;
- não usar capacity como redutor;
- regras de desempate devem ser explícitas.

---

## 44. Casos adversariais

### Caso A — critical Alert + no_material_change

- Alert histórico: critical/urgent;
- assessment posterior: no_material_change;
- priority pode diminuir;
- rationale de reconciliação obrigatório;
- nenhum dado histórico é reescrito.

### Caso B — low volatility + high criticality safety event

- baixa volatilidade não compensa safety;
- priority pode ser urgent;
- event-driven route pode dominar.

### Caso C — high volatility + low criticality

- pode justificar M2;
- priority de um caso específico pode continuar standard/expedited;
- M2 não implica urgência.

### Caso D — urgent case + no capacity

- priority permanece urgent;
- feasibility insufficient/unavailable;
- resource escalation obrigatória.

### Caso E — SLA breach + no scientific issue

- operational pressure sobe;
- escalation pode ocorrer;
- materiality/currentness permanecem.

### Caso F — broad dependencies + no material change

- dependency reach sozinho não cria scientific urgency;
- propagation assessment pode ser standard ou encerrado.

### Caso G — confirmed material change + systemic dependencies

- confirmed material change isolado é strong modifier, não floor universal;
- se A1 high, urgent;
- systemic reach eleva coordination pressure;
- dependency coordination escalation assessment obrigatória.

### Caso H — suspend_current_use

- immediate;
- current-use governance route obrigatória;
- não publica/arquiva automaticamente.

---

## 45. Referências metodológicas externas

A arquitetura é compatível com os seguintes princípios externos:

### Cochrane Handbook — Chapter IV: Updating a review

A decisão de atualizar deve considerar:

- importância continuada da pergunta para decisores;
- disponibilidade de novos dados/métodos;
- potencial de impacto significativo nos achados.

### Cochrane Handbook — Chapter 22

Living review é mais apropriada para questões:

- de alta prioridade;
- com nova evidência provável;
- com potencial de impacto relevante.

Prioridade de atualização é contextual, não simples calendário.

### Cochrane Interactive Learning — Module 14, 2026

Living systematic review exige critérios prospectivos para:

- frequência de busca;
- gatilhos de atualização;
- comunicação do status;
- saída do living mode.

### NICE PMG49, 2025

Surveillance deve ser:

- proporcional;
- targeted;
- reativa a sinais;
- proativa quando necessária;
- sensível a safety information.

### WHO living-guidelines approach

Atualização deve priorizar situações em que atraso pode afetar saúde/bem-estar, sem consumir recursos escassos em tópicos estáveis sem necessidade.

Essas referências sustentam:

> prioridade proporcional, dinâmica, orientada a impacto e segurança, sem score universal obrigatório.

Nenhuma classificação externa foi copiada como domínio OES.

---

## 46. Consequências para contrato físico futuro

Candidatos conceituais:

1. PriorityAssessment;
2. PriorityBasis/Factor;
3. EscalationCase/Event;
4. EscalationReason;
5. EscalationRoute;
6. linkage Alert/Signal/SLA/Dependency;
7. authority/verification metadata;
8. supersession/history;
9. issue helpers.

Entretanto:

> **não autorizar migration 029 antes da revisão adversarial.**

---

## 47. Integração com gaps físicos já conhecidos

Um contrato físico conjunto deverá reconciliar prioridade/escalation com:

- triage transversal;
- SLA Rule/version;
- SLA Instance;
- pause ledger;
- workflow started/completed;
- review/publication adapters;
- incident/escalation;
- workflow/review round identity.

Decisão preliminar:

> prioridade/escalation não deve ser persistida isoladamente sem definir as referências mínimas a triage/SLA/workflow que evitam estados órfãos ou circulares.

---

## 48. Critérios de readiness

O bloco poderá ser considerado pronto para desenho físico quando a revisão adversarial confirmar:

1. classes não colidem com Alert e `immediate` não embute rota de governança;
2. floors não transformam prioridade em materiality;
3. currentness continua read-only para prioridade;
4. breach não cria circularidade SLA;
5. capacity não compensa risco;
6. dependency reach não vira materiality;
7. M0–M3 permanecem independentes;
8. N0–N4 permanecem independentes;
9. AI/system permanece dentro da fronteira autorizada;
10. downgrade/promotion são history-preserving;
11. escalation não equivale a decisão científica;
12. nenhuma duração/score é introduzida prematuramente.

---

## 49. Próximo passo

> **Reexecutar o gate do Documento 26 sobre esta versão revisada; somente após PASS definir readiness para desenho físico integrado.**


---

## 50. Correções decorrentes do Documento 26

A revisão adversarial inicial identificou e corrigiu:

1. `immediate_governance` → `immediate`, separando priority de escalation;
2. `material_change_confirmed` isolado deixou de ser floor universal;
3. `update_recommended` isolado deixou de ser floor universal;
4. PriorityAssessment passou a distinguir `proposal | authoritative`;
5. materiality AI-only não pode sustentar floor científico autoritativo;
6. target supersession/invalidation saiu de dominance gate e permanece lifecycle/reassessment;
7. queue aggregation passou a ser explicitamente derivada e causalmente ligada;
8. escalation `candidate` pode ser automática, mas `active` exige autoridade humana na baseline.

Estado após correção:

> **READY_FOR_ADVERSARIAL_RECHECK**

> **MIGRATION_029 = NOT_AUTHORIZED**
