# 166 — Monitor de Evidências: Revisão de Coerência Científica e Decisão Arquitetural

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — pronto para Contrato de Dados v0.1**  
**Dependências:** Documento 165; Documentos 02, 03 e 40; OES-P1; migrations 002, 003 e 006

---

# 1. Finalidade

Confrontar a Especificação Científica e Funcional do Monitor de Evidências com o OES-P1 e decidir:

- identidade do Monitor;
- relação com Investigation e Product;
- isolamento da investigação científica original;
- reutilização de Search/SearchHit/Screening;
- representação de Monitoring Cycle;
- relação com `product.currency_state`;
- provenance/dependency;
- tratamento de eventos não bibliográficos;
- fronteira com o futuro Alerta de Evidência;
- fronteira Fase 3 × Fase 4.

Nenhuma migration é criada neste documento.

---

# 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

A arquitetura atual suporta o Monitor sem alterar entidades científicas fundamentais.

Será necessária:

> **uma camada especializada de manutenção**, pequena e aditiva.

Não será criada nova entidade científica paralela para:

- Study;
- Report;
- Result;
- Synthesis;
- Certainty;
- Question.

---

# 3. Decisão A — Monitor é Product próprio

O Monitor deverá possuir:

- `product.product`;
- `product.product_version`;
- `product_type='evidence_monitor'` como identificador lógico candidato.

Justificativa:

- possui identidade operacional persistente;
- possui estado;
- possui plano;
- possui histórico;
- pode ser apresentado/renderizado;
- deve existir independentemente de uma única execução;
- não pode ser reduzido a um atributo do produto monitorado.

Entretanto:

> **o Product Monitor não é uma nova síntese científica.**

Seu conteúdo principal é manutenção e vigilância.

---

# 4. Decisão B — Monitor possui Investigation própria

O Monitor deverá possuir Investigation própria.

Motivo central:

> **não misturar Searches e Screening de manutenção com a Investigation histórica que produziu o alvo científico.**

Se buscas futuras fossem anexadas diretamente à Investigation original:

- o método histórico seria alterado retrospectivamente;
- cutoff e selection flow perderiam significado;
- rebuilds e auditoria poderiam confundir produção original com manutenção;
- Search posterior poderia aparentar fazer parte do protocolo inicial.

Portanto:

> **Search do Monitor pertence à Investigation do Monitor.**

---

# 5. Profundidade da Investigation do Monitor

O schema OES-P1 exige `depth_level=N0–N4`.

Como Monitor não possui N próprio:

> **a Investigation do Monitor herda a profundidade N do alvo primário no momento de criação/versionamento do Monitor.**

Exemplo:

- Ficha N2 monitorada → Monitor Investigation N2/M2 ou N2/M3;
- Revisão N4 monitorada → Monitor Investigation N4/M2 ou N4/M3.

Isso não significa executar novamente integralmente N2/N4 a cada ciclo.

O `depth_level` representa:

> **o nível científico cuja manutenção está sendo realizada.**

`investigation_type` deverá distinguir claramente manutenção, por exemplo:

> `evidence_monitoring`

A nomenclatura física será fechada no contrato de dados.

---

# 6. Question

Default:

> **reutilizar a Question existente do alvo**, por vínculo explícito de QuestionVersion apropriada.

Não criar nova Question apenas porque foi aberto Monitor.

Nova Question será necessária somente se:

- escopo científico mudar;
- população/intervenção/comparador/outcome mudar materialmente;
- objetivo de vigilância deixar de corresponder ao alvo.

Nesse caso:

> reavaliar roteamento e possível abertura de nova investigação.

---

# 7. Decisão C — target linkage especializado

`product.investigation_link` não deve ser usado para fingir que a Investigation do alvo é a primary Investigation do Monitor.

O Monitor terá:

- sua própria primary Investigation via `product.investigation_link`;
- vínculo explícito ao alvo científico por camada de manutenção.

A camada especializada deverá permitir apontar para:

- ProductVersion primária monitorada;
- e, quando necessário, InvestigationVersion monitorada.

Regra:

> **exatamente um alvo primário por MonitorVersion.**

Poderão existir alvos secundários contextuais no futuro, mas não são necessários no v0.1.

---

# 8. Decisão D — dependency_edge complementa, não substitui target linkage

`provenance.dependency_edge` é adequado para representar lineage:

> target científico → Monitor

Mas não é suficiente sozinho para semântica operacional de monitoramento porque não registra:

- target role;
- início do monitoramento;
- rationale;
- estado do vínculo;
- parâmetros operacionais.

Portanto:

1. camada `maintenance` registra target linkage operacional;
2. `provenance.dependency_edge` espelha a dependência científica/versionada relevante.

Derivation rule candidata:

> `maintenance_surveillance_target`

---

# 9. Decisão E — Monitoring Cycle é entidade operacional especializada

O ciclo não será ProductVersion e não será InvestigationVersion.

Será registro operacional especializado ligado à versão do Monitor.

Motivo:

- ciclos podem ser frequentes;
- ausência de mudança não deve gerar versionamento científico;
- execução de um ciclo não muda necessariamente o plano do Monitor;
- ProductVersion deve continuar reservado a mudança material do próprio produto Monitor.

Monitoring Cycle deverá ser:

> **append-preserving e auditável.**

---

# 10. Monitoring Cycle — semântica mínima

Cada ciclo deverá possuir:

- identidade;
- Monitor ProductVersion;
- InvestigationVersion do Monitor;
- início/fim;
- cutoff anterior;
- janela observada;
- estado de execução;
- completeness;
- decisão final;
- rationale;
- performed_by;
- timestamps.

Estados candidatos de execução:

- planned;
- running;
- completed;
- incomplete;
- cancelled.

Decisões científicas de manutenção permanecem separadas do execution status.

---

# 11. Decisão F — Search existente será reutilizada

Não criar tabela paralela de busca para Monitor.

Usar:

> `investigation.search`

Cada Search continua ligada à InvestigationVersion do Monitor.

Para ligar execução ao ciclo será necessária relação especializada:

> **MonitoringCycle ↔ Search**

Regra v0.1:

> **uma Search execution do Monitor pertence a exatamente um Monitoring Cycle.**

Uma estratégia conceitual pode ser reutilizada/versionada entre ciclos, mas cada execução Search continua concreta e datada.

---

# 12. SearchHit e deduplicação

Reutilizar:

- `investigation.search_hit`;
- `investigation.dedup_cluster`.

Isso preserva:

- raw record;
- identificador de fonte;
- resolução para Report quando disponível;
- deduplicação;
- provenance operacional.

Nenhuma `maintenance.search_hit` paralela será criada.

---

# 13. Limite do ScreeningDecision existente

`investigation.screening_decision` aceita target:

- Report;
- Study.

Um SearchHit pode existir antes de resolução para Report.

Logo:

> **ScreeningDecision existente não cobre sozinho todo o estágio pré-resolução do Monitor.**

Decisão:

- não alterar ScreeningDecision para aceitar SearchHit no v0.1;
- criar representação especializada de **cycle candidate assessment** que possa referenciar SearchHit e, quando resolvido, Report/Study.

Quando candidato já estiver materializado como Report/Study:

> ScreeningDecision poderá ser utilizado para decisões científicas compatíveis.

Essa separação evita ampliar globalmente o contrato de screening apenas para necessidades operacionais do Monitor.

---

# 14. Decisão G — Candidate Assessment especializado

A camada maintenance deverá representar a avaliação inicial de candidatos detectados no ciclo.

Candidate Assessment poderá apontar para:

- `search_hit_uuid`;
- Report;
- Study;
- evento não bibliográfico.

Deverá registrar:

- relevância preliminar;
- tipo de sinal;
- impacto potencial;
- estado;
- rationale;
- ator;
- verificação.

Não será:

- Result;
- Synthesis;
- CertaintyAssessment.

---

# 15. Eventos não bibliográficos

Search/SearchHit não representam adequadamente:

- retratação;
- expressão de preocupação;
- correção material;
- invalidação de dataset;
- atualização regulatória cientificamente relevante;
- retirada de guideline/source.

Portanto a camada maintenance deverá possuir:

> **Evidence/Validity Event** especializado.

Esse evento deverá permitir provenance para:

- ReportVersion;
- artifact;
- URI/fonte;
- entidade afetada.

O evento:

> **não é o futuro Alerta de Evidência.**

Ele é fato/sinal operacional detectado pelo Monitor.

---

# 16. Decisão H — ciclo e currentness permanecem separados

`product.currency_state` já é canônico para atualidade do ProductVersion alvo.

Não criar `maintenance.currency_state`.

Um ciclo pode:

- não alterar currentness;
- gerar novo `currency_state`;
- sustentar `under_evaluation`;
- sustentar `update_recommended`;
- sustentar `outdated`.

Toda nova linha de currency deverá:

- ser append-preserving;
- superseder o estado ativo anterior;
- apontar rationale;
- ser rastreável ao ciclo por provenance/process record.

O contrato de dados deverá definir vínculo explícito Cycle → CurrencyState.

---

# 17. Decisão I — conclusão científica não fica no Monitor

O Monitor poderá registrar:

- impacto potencial;
- decisão de manutenção;
- necessidade de atualização.

Não deverá persistir como sua própria conclusão:

> **uma conclusão científica substitutiva do alvo.**

A conclusão científica vigente continua pertencendo ao ProductVersion monitorado.

Se a evidência mudar a conclusão:

> criar processo de atualização e nova ProductVersion do alvo.

---

# 18. Decisão J — version_change_class continua no alvo

Quando atualização científica for concluída, utilizar:

> `product.version_change_class`

no novo ProductVersion do alvo.

Exemplos:

- new_evidence;
- quantitative_change;
- certainty_change;
- applicability_change;
- conclusion_change.

O Monitoring Cycle pode ser provenance causal dessa mudança.

Não duplicar change classes em maintenance.

---

# 19. Decisão K — Alert não será implementado nesta etapa

O Monitor deverá possuir somente:

> **escalation recommendation / alert candidate**

como decisão operacional.

Não criar ainda:

- Alert Product;
- alert severity final;
- comunicação pública;
- categorias quantitativamente operacionalizadas.

Motivo:

> **Alerta de Evidência é o próximo produto e necessita especificação própria.**

Assim, o contrato v0.1 do Monitor deve prever interoperabilidade futura sem congelar o contrato do Alerta.

---

# 20. Estado do Monitor

Separar três dimensões:

## 20.1 Product editorial status

Já existente:

- draft;
- under_review;
- published;
- superseded;
- archived.

## 20.2 Monitor operational status

Camada maintenance candidata:

- planned;
- active;
- paused;
- closed;
- archived.

## 20.3 Target currency status

Já existente:

- current;
- under_evaluation;
- update_recommended;
- outdated;
- archived.

Regra:

> **essas três dimensões nunca serão colapsadas.**

---

# 21. ProductVersion do Monitor

Nova ProductVersion do Monitor é necessária quando houver mudança material no próprio plano/produto Monitor, por exemplo:

- alvo primário mudou;
- escopo mudou;
- maintenance M2↔M3 mudou;
- fontes obrigatórias mudaram materialmente;
- estratégia mudou materialmente;
- objetivo mudou;
- política de avaliação de impacto mudou.

Não criar nova Monitor ProductVersion para:

- execução rotineira de ciclo;
- Search nova prevista pelo plano;
- ausência de novos estudos;
- simples avanço da próxima data de execução.

---

# 22. Assurance

`product.assurance_record` é genericamente vinculado a ProductVersion e pode tecnicamente representar assurance do Monitor.

Entretanto:

> **assurance do Monitor deve avaliar o método/processo de vigilância, não reutilizar automaticamente assurance do alvo.**

Decisão v0.1:

- Monitor inicia A0;
- eventual A1 poderá decorrer de verificação metodológica por IA do plano/processo;
- A2/A3 não serão definidos como requisito de publicação antes de contrato/gate específico;
- assurance do alvo deve ser projetado como contexto, não copiado.

Nenhum owner/expert control é presumido.

---

# 23. Human controls

Não é correto exigir o mesmo controle humano para todo cycle de todo produto.

A necessidade depende de:

- profundidade N herdada;
- impacto potencial;
- decisão tomada;
- eventual atualização científica.

Entretanto:

> **um ciclo AI-only não pode fabricar human verification.**

Quando a atualização entrar no método N3/N4:

> controles humanos obrigatórios do método original continuam válidos.

A Fase 4 poderá estabelecer controles transversais adicionais de manutenção.

---

# 24. Fase 3 × Fase 4

## Fase 3 define

- identidade do Monitor;
- schema;
- cycles;
- search linkage;
- candidate assessment;
- validity events;
- target linkage;
- currentness integration;
- View;
- gate técnico;
- template.

## Fase 4 definirá

- cadência padrão por classes de produto/tema;
- thresholds temporais;
- thresholds de impacto;
- gatilhos automáticos;
- SLAs;
- política geral de escalonamento;
- regras quantitativas para Alert;
- política transversal de atualização.

O schema da Fase 3 deverá:

> **armazenar regras/decisões sem congelar thresholds globais ainda inexistentes.**

---

# 25. Camada especializada candidata

Namespace candidato:

> `maintenance`

Componentes conceituais mínimos:

1. `monitor_definition` ou configuração especializada por ProductVersion;
2. `monitor_target`;
3. `monitor_cycle`;
4. `cycle_search`;
5. `candidate_assessment`;
6. `evidence_event`;
7. vínculo Cycle → CurrencyState;
8. funções/view de projeção.

A nomenclatura final será definida no Contrato de Dados v0.1.

---

# 26. O que não criar

Não criar:

- nova Question se a pergunta é a mesma;
- nova tabela de Search;
- nova tabela de SearchHit;
- nova tabela de Study/Report;
- nova tabela de Result;
- nova tabela de currentness paralela;
- nova tabela de change classes;
- Alert completo;
- nova ProductVersion do alvo para ciclo sem mudança;
- Search do Monitor dentro da Investigation histórica do alvo.

---

# 27. Provenance e lineage

A arquitetura deverá permitir reconstruir:

> Monitor → Cycle → Search/SearchHit/Event → Candidate Assessment → decisão de manutenção → CurrencyState → eventual nova ProductVersion do alvo.

O caminho deve ser navegável sem inferência retrospectiva.

`provenance.record` e `dependency_edge` deverão ser reutilizados onde adequados.

---

# 28. Invalidation propagation

Se uma fonte usada pelo Monitor for invalidada:

- cycle evidence deve permanecer historicamente auditável;
- candidate assessment pode ser invalidado/superseded;
- decisão de manutenção derivada deve ser reavaliável;
- currency state afetado não deve permanecer silenciosamente sustentado por evidence invalidada.

O contrato deverá incluir testes de invalidation/provenance.

---

# 29. Rebuild/idempotência

A implementação futura deverá preservar padrões OES:

- migration controlada;
- rebuild-from-zero;
- regressões N0–N4/Mapa/Overview;
- append-preserving history;
- proteção contra duplicação de cycle/search linkage;
- nenhuma geração silenciosa de nova versão científica.

---

# 30. Decisão arquitetural consolidada

> **Monitor = Product próprio + Investigation própria de manutenção que herda N do alvo + camada especializada `maintenance` para target/cycle/candidate/event, reutilizando Search/SearchHit, currency_state, version_change_class e provenance existentes.**

Essa decisão evita:

- contaminação da Investigation científica original;
- duplicação de Search;
- versionamento científico a cada ciclo;
- currentness paralelo;
- antecipação do Alerta de Evidência.

---

# 31. Readiness

Scientific/functional readiness:

> **PASS**

Architectural coherence:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Data-contract readiness:

> **READY**

Migration readiness:

> **NOT_YET — primeiro definir e revisar Contrato de Dados v0.1.**

---

# 32. Próxima etapa

> **Definir o Contrato de Dados v0.1 do Monitor de Evidências.**

O contrato deverá especificar:

- tabelas/constraints do namespace maintenance;
- target cardinality;
- cycle lifecycle;
- cycle-search uniqueness;
- candidate polymorphism seguro;
- event provenance;
- currentness linkage;
- assurance/gates;
- funções de projeção candidatas;
- testes mínimos antes de migration.

---

**Resultado final:** a arquitetura do Monitor é coerente com OES-P1 e pode avançar para contrato de dados sem redefinir entidades científicas nem antecipar a política transversal de atualização da Fase 4.
