# 165 — Especificação Científica e Funcional do Monitor de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** especificação científica e funcional inicial  
**Dependências OES:** Documentos 00, 02, 03, 40, 164 e arquitetura OES-P1  
**Fronteira de fase:** esta especificação define o produto e sua semântica; regras quantitativas/temporais gerais de atualização permanecem reservadas à Fase 4

---

# 1. Finalidade

Definir o contrato científico e funcional inicial do produto/processo:

> **OES — Monitor de Evidências**

O Monitor existe para manter vigilância rastreável sobre uma investigação ou produto científico já existente e identificar novas evidências ou eventos capazes de modificar materialmente:

- Results;
- Synthesis;
- Certainty;
- aplicabilidade;
- conclusão;
- estado de atualidade;
- necessidade de nova investigação.

O Monitor:

> **não é uma nova revisão, não é N5 e não altera silenciosamente o produto monitorado.**

---

# 2. Definição operacional

Um Monitor de Evidências OES é um processo persistente de manutenção que:

1. referencia um alvo científico existente;
2. define escopo de vigilância;
3. define fontes e estratégia de detecção;
4. executa ciclos de busca/vigilância rastreáveis;
5. identifica novas referências ou eventos;
6. realiza triagem inicial;
7. avalia potencial de impacto;
8. registra uma decisão de manutenção;
9. atualiza o estado de atualidade quando justificável;
10. encaminha para atualização científica quando houver mudança potencialmente material.

O resultado de um ciclo pode ser:

> **nenhuma atualização necessária / avaliar atualização / atualizar.**

A ausência de nova evidência material:

> **não cria automaticamente uma nova ProductVersion científica.**

---

# 3. Natureza arquitetural

O Monitor pertence à dimensão de manutenção:

- **M2 — monitoramento ativo**; ou
- **M3 — evidência viva**.

Ele herda a profundidade científica do objeto monitorado.

Exemplos:

- Ficha N2 + Monitor M2;
- Síntese Rápida N3 + Monitor M2;
- Revisão N4 + Monitor M3;
- Mapa + Monitor M2/M3;
- Overview + Monitor M2/M3.

Logo:

> **Monitor não possui profundidade N própria.**

A combinação N × M deverá permanecer explícita no Routing Record/Investigation correspondente.

---

# 4. Alvo monitorado

O Monitor deverá estar vinculado a pelo menos um alvo científico identificável.

Alvos preferenciais:

- ProductVersion de Ficha de Evidência;
- ProductVersion de Síntese Rápida;
- ProductVersion de Revisão de Evidências;
- ProductVersion de Mapa de Evidências;
- ProductVersion de Overview de Revisões;
- InvestigationVersion quando o objeto de vigilância ainda não se expressar adequadamente por um ProductVersion.

Para perguntas focais reutilizáveis:

> **a Ficha de Evidência continua sendo o alvo preferencial de monitoramento persistente.**

O Monitor poderá referenciar simultaneamente Investigation e ProductVersion, mas deverá existir um alvo primário inequívoco.

---

# 5. Regra de identidade e versionamento

O Monitor não substitui a identidade do produto monitorado.

Deverão permanecer distintos:

1. identidade do Monitor;
2. identidade do alvo monitorado;
3. ciclos de monitoramento;
4. novas evidências detectadas;
5. eventual nova versão científica do alvo.

Um ciclo de monitoramento sem mudança material:

> **não gera nova versão científica do alvo.**

Quando nova evidência exigir alteração material:

> **a mudança deverá ocorrer por nova ProductVersion ou revisão metodológica apropriada do alvo, preservando histórico e provenance.**

Classes de mudança já suportadas pelo OES incluem:

- `new_evidence`;
- `quantitative_change`;
- `certainty_change`;
- `applicability_change`;
- `conclusion_change`;
- `scientific_correction`.

O Monitor deverá apontar para essas mudanças, não substituí-las.

---

# 6. Relação com currentness

O OES já possui `product.currency_state` com estados:

- `current`;
- `under_evaluation`;
- `update_recommended`;
- `outdated`;
- `archived`.

O Monitor deverá interoperar com essa estrutura.

Regra:

> **um ciclo de Monitor pode sustentar uma nova avaliação de currentness sem necessariamente criar nova versão científica.**

Exemplos:

- nenhuma nova evidência material → alvo pode permanecer `current`;
- nova evidência potencialmente relevante ainda não avaliada → `under_evaluation`;
- evidência provavelmente capaz de exigir revisão → `update_recommended`;
- evidência acumulada torna a versão inadequada para uso corrente → `outdated`.

Mudança de `currency_state` deverá possuir rationale e provenance.

---

# 7. Quando utilizar

Monitor M2/M3 é apropriado quando:

- o produto deve permanecer atual ao longo do tempo;
- o campo possui produção científica contínua;
- nova evidência pode modificar decisão, interpretação ou certeza;
- a conclusão tem valor operacional recorrente;
- atualização completa em calendário fixo seria ineficiente;
- existe capacidade operacional de vigilância e triagem.

---

# 8. Quando não utilizar

Não abrir Monitor quando:

- o produto é deliberadamente estático M0;
- o produto está apenas elegível para atualização eventual M1;
- não existe alvo científico estável;
- a pergunta mudou materialmente e exige nova Investigation;
- a vigilância seria meramente informal, sem estratégia ou registro;
- não existe capacidade mínima para executar os ciclos propostos;
- o objetivo real é realizar imediatamente uma nova revisão completa.

Nesses casos:

> manter M0/M1, reformular a pergunta ou rotear para nova investigação.

---

# 9. M2 — monitoramento ativo

M2 representa:

> **vigilância periódica ativa em intervalo definido.**

O plano M2 deverá registrar:

- rationale para monitorar;
- alvo;
- escopo;
- fontes;
- estratégia;
- periodicidade ou regra de execução;
- responsável operacional;
- data de início;
- última execução;
- próximo ciclo esperado;
- critérios de triagem;
- critérios qualitativos de potencial impacto.

A Fase 3 não estabelece um intervalo universal.

> **A periodicidade deverá ser proporcional ao campo e formalizada pela política de atualização da Fase 4.**

---

# 10. M3 — evidência viva

M3 representa:

> **vigilância frequente ou contínua, com capacidade de incorporar nova evidência quando pertinente.**

M3 exige justificativa mais forte que M2, incluindo:

- importância elevada;
- incerteza relevante;
- expectativa de novos estudos;
- possibilidade plausível de mudança de conclusão;
- capacidade operacional contínua.

M3:

> **não transforma automaticamente N2 em N4 e não reduz exigências metodológicas do produto monitorado.**

Uma Revisão N4 + M3 somente poderá ser denominada revisão sistemática viva quando os requisitos metodológicos correspondentes forem efetivamente satisfeitos.

---

# 11. Plano de vigilância

Todo Monitor deverá possuir um plano prospectivo de vigilância.

Conteúdo mínimo:

- alvo primário;
- Question/escopo científico relevante;
- data de corte inicial;
- fontes;
- classes de fontes;
- estratégia por fonte;
- restrições;
- periodicidade/regra de execução;
- processo de deduplicação;
- processo de triagem;
- categorias de impacto;
- decisão de manutenção;
- política de escalonamento;
- política de atualização do alvo;
- política de encerramento/pausa.

Mudanças materiais no plano deverão ser registradas.

---

# 12. Fontes de vigilância

As fontes devem ser proporcionais ao alvo e ao método que o originou.

Podem incluir:

- bases bibliográficas;
- registros de ensaios;
- repositórios de revisões;
- bases regulatórias cientificamente relevantes;
- fontes de correção/retração;
- citation chaining;
- fontes especializadas do domínio.

Regra:

> **o Monitor não pode alegar cobertura que sua estratégia não sustenta.**

Monitoramento automatizado futuro não elimina a necessidade de provenance da fonte.

---

# 13. Estratégia de busca

A estratégia de Monitor deve ser:

- identificável;
- versionada quando necessário;
- reproduzível em grau proporcional ao método;
- vinculada à estratégia anterior quando for atualização incremental;
- suficientemente sensível ao tipo de mudança que o Monitor pretende detectar.

Pode haver estratégia incremental a partir da data de corte anterior.

Entretanto:

> **“buscar apenas o que parece novo” sem regra prospectiva não constitui Monitor OES.**

---

# 14. Ciclo de monitoramento

A unidade operacional central é:

> **Monitoring Cycle**

Cada ciclo deverá registrar, no mínimo:

- identificador;
- Monitor;
- alvo monitorado;
- início e fim;
- data de corte anterior;
- janela de vigilância;
- fontes previstas;
- fontes executadas;
- buscas executadas;
- referências detectadas;
- referências novas após deduplicação;
- itens triados;
- candidatos potencialmente relevantes;
- eventos não bibliográficos relevantes;
- decisão de manutenção;
- rationale;
- próximo estado.

A decisão física sobre nova entidade/tabela será feita no contrato de dados.

---

# 15. Resultados possíveis de um ciclo

Estado funcional mínimo candidato:

## 15.1 `no_update_needed`

Não foi identificada evidência com potencial material suficiente para justificar reavaliação científica do alvo.

Consequência possível:

- manter `currency_status=current`;
- registrar o ciclo;
- não criar nova ProductVersion científica.

## 15.2 `evaluate_update`

Foi identificada evidência plausivelmente relevante, mas ainda é necessária avaliação científica mais aprofundada.

Consequência possível:

- `currency_status=under_evaluation`;
- iniciar avaliação estruturada;
- eventualmente emitir Alerta, se a política futura permitir e o evento justificar.

## 15.3 `update_recommended`

A nova evidência tem potencial material suficientemente forte para justificar atualização do alvo.

Consequência possível:

- `currency_status=update_recommended`;
- abrir workflow de atualização da Investigation/Product;
- não modificar silenciosamente a conclusão vigente.

## 15.4 `outdated`

Quando a evidência disponível torna a versão científica atual inadequada para uso corrente antes de uma atualização concluída.

Consequência possível:

- `currency_status=outdated`;
- disclosure explícito;
- atualização prioritária.

A operacionalização exata dos thresholds pertence à Fase 4.

---

# 16. Triagem

A triagem deverá distinguir:

- novo record;
- novo Report;
- novo Study;
- atualização de Study/Review existente;
- correção;
- retratação;
- evento regulatório cientificamente relevante;
- duplicata;
- irrelevante.

Não confundir:

> **“nova publicação” com “nova evidência independente”.**

Multiple Reports do mesmo Study devem permanecer vinculados à mesma unidade científica quando aplicável.

---

# 17. Avaliação de potencial impacto

O Monitor não deve apenas detectar novidade.

Para cada candidato relevante, deverá avaliar se existe potencial de modificar:

- direção do efeito;
- magnitude;
- precisão;
- heterogeneidade;
- risco de viés;
- certainty/confiança;
- segurança/dano;
- aplicabilidade;
- validade de evidência previamente utilizada;
- conclusão;
- necessidade de nova pergunta.

Essa avaliação é inicialmente:

> **impact assessment de manutenção, não nova síntese científica completa.**

---

# 18. Categorias funcionais de impacto

Categorias candidatas, não quantitativas:

- `no_material_impact`;
- `possible_quantitative_impact`;
- `possible_certainty_impact`;
- `possible_applicability_impact`;
- `possible_conclusion_impact`;
- `validity_event`;
- `scope_change_signal`.

Uma mesma evidência poderá ocupar mais de uma categoria.

A Fase 4 deverá definir regras de escalonamento quando necessário.

---

# 19. Retratações, correções e validade de fontes

O Monitor deverá tratar explicitamente eventos que afetem evidência já incorporada, incluindo:

- retratação;
- expressão de preocupação;
- correção material;
- substituição/atualização de relatório;
- invalidação de dataset;
- mudança regulatória cientificamente relevante.

Esses eventos poderão ter impacto mesmo sem novo Study.

Regra:

> **um evento de validade deve ser propagado por provenance/dependency para identificar produtos potencialmente afetados.**

---

# 20. Relação com o Alerta de Evidência

Monitor e Alerta são produtos distintos.

Monitor:

> detecta, rastreia, tria e avalia potencial de impacto.

Alerta:

> comunica um evento potencialmente modificador.

Portanto:

- todo Alerta deve apontar para evidência/evento rastreável;
- Alerta não altera a conclusão;
- nem todo ciclo de Monitor gera Alerta;
- nem toda referência nova gera Alerta;
- atualização científica exige workflow próprio.

A classificação Informativo/Relevante/Crítico permanece preliminar e será operacionalizada na Fase 4.

---

# 21. Relação com atualização científica

Quando um ciclo recomendar atualização:

1. registrar a decisão;
2. marcar currentness apropriadamente;
3. abrir processo de atualização do alvo;
4. executar o método requerido pelo produto original;
5. criar nova ProductVersion quando houver mudança científica material;
6. classificar `version_change_class`;
7. preservar a versão anterior e a provenance.

O Monitor:

> **não substitui reextração, risk assessment, síntese, certainty assessment ou revisão metodológica quando essas etapas forem necessárias.**

---

# 22. Ausência de nova evidência

A ausência de novas referências relevantes em um ciclo:

- deve ser registrada;
- não prova ausência universal de nova evidência;
- deve ser interpretada conforme cobertura e data do ciclo;
- pode sustentar manutenção de currentness quando a estratégia é adequada.

Não gerar ProductVersion científica vazia apenas para registrar:

> “nenhuma mudança”.

O histórico operacional do Monitor deverá registrar essa verificação.

---

# 23. Falha ou incompletude do ciclo

Um ciclo pode ser incompleto por:

- fonte indisponível;
- falha de busca;
- export ausente;
- problema de deduplicação;
- triagem incompleta;
- capacidade operacional insuficiente.

Nesses casos:

> **não registrar artificialmente `no_update_needed`.**

O ciclo deverá indicar incompletude e o currentness do alvo deverá refletir a incerteza quando material.

---

# 24. Relação com assurance

Assurance do alvo científico e garantia do processo de Monitor são dimensões relacionadas, mas distintas.

Regra inicial:

> **o Monitor não herda automaticamente o nível A0–A3 do alvo como se isso validasse cada ciclo de vigilância.**

Da mesma forma:

> **um ciclo tecnicamente executado não eleva assurance do produto monitorado.**

Controles humanos exigidos pelo método do alvo continuam obrigatórios na eventual atualização científica.

A arquitetura de assurance específica do Monitor será detalhada em revisão de coerência/contrato de dados.

---

# 25. Uso de IA

IA poderá apoiar:

- geração/adaptação de estratégias;
- deduplicação;
- classificação preliminar;
- screening prioritization;
- linking Study/Report;
- identificação de possíveis mudanças;
- comparação com versões anteriores;
- preparação de rationale.

IA não poderá:

- inventar execução de busca;
- inventar referências;
- marcar revisão humana inexistente;
- alterar conclusão científica sem workflow de atualização;
- transformar ausência de detecção em prova de ausência de evidência;
- emitir assurance humana.

Toda ação material assistida por IA deverá ser auditável.

---

# 26. Human-in-the-loop

A intensidade de controle humano deverá ser proporcional ao alvo e ao impacto da decisão.

Princípio:

- triagem operacional de baixo risco pode admitir automação/IA com controles;
- decisões que possam tornar produto `outdated`, iniciar atualização formal ou modificar conclusão exigem governança compatível com o produto e a fase futura;
- M3 não reduz exigências humanas de N3/N4.

A especificação detalhada dos controles será fechada após revisão arquitetural.

---

# 27. Conteúdo mínimo da saída do Monitor

A projeção funcional futura deverá conseguir apresentar:

- identidade do Monitor;
- alvo monitorado;
- Question relevante;
- profundidade N herdada;
- maintenance level M2/M3;
- status do Monitor;
- plano de vigilância;
- fontes;
- periodicidade/regra;
- data de corte do alvo;
- último ciclo;
- histórico de ciclos;
- novas referências/eventos;
- triagem;
- candidatos relevantes;
- impacto potencial;
- decisão do ciclo;
- currentness antes/depois;
- atualização recomendada ou não;
- Alertas associados;
- lineage/provenance;
- limitações;
- audit/assurance.

---

# 28. Estados candidatos do Monitor

Estado operacional candidato:

- `planned`;
- `active`;
- `paused`;
- `under_evaluation`;
- `closed`;
- `archived`.

Esses estados:

> **não substituem o editorial status do ProductVersion nem o currency status do alvo.**

A decisão física e vocabulário final serão confirmados no contrato de dados.

---

# 29. Encerramento ou pausa

O Monitor poderá ser pausado/encerrado quando:

- alvo for arquivado;
- pergunta perder relevância;
- manutenção migrar M2 ↔ M3;
- produto for substituído;
- capacidade operacional deixar de existir;
- nova Investigation redefinir materialmente o escopo.

Pausa não deverá ser representada como evidência atual.

---

# 30. Compatibilidade com produtos OES

## Ficha de Evidência

Alvo preferencial para monitoramento persistente de pergunta focal.

## Resposta de Evidência

M2 possível quando justificado; monitoramento persistente deve preferencialmente migrar para Ficha.

## Evidence Scan

M2/M3 excepcional; se a necessidade se tornar persistente, rerotear.

## Síntese Rápida

M2/M3 possíveis, preservando limitações do método rápido.

## Revisão de Evidências

M2/M3 compatíveis; M3 pode sustentar living review apenas com requisitos específicos.

## Mapa de Evidências

Pode monitorar expansão/distribuição do corpus sem transformar automaticamente apparent gaps em formal gaps.

## Overview de Revisões

Pode monitorar novas reviews/updates, currentness, overlap e mudanças de síntese, sem executar meta-análise de segunda ordem automaticamente.

---

# 31. Critérios de readiness para próxima etapa

Antes de contrato de dados, a revisão de coerência arquitetural deverá responder:

1. Monitor será Product próprio, processo ligado a Product, ou composição das duas coisas?
2. Como representar target linkage sem duplicar `product.investigation_link`?
3. Como representar Monitoring Cycle?
4. Search existente pode ser reutilizada diretamente por ciclo?
5. Como representar referências detectadas antes de inclusão científica?
6. Como ligar ciclos a `currency_state`?
7. Como registrar decisão `no_update_needed/evaluate/update`?
8. Como representar eventos de retração/correção?
9. Como relacionar Monitor e futuro Alerta?
10. Que controles de assurance são próprios do Monitor?
11. Quais elementos pertencem à Fase 3 e quais devem permanecer reservados à Fase 4?
12. Como preservar idempotência, provenance e append-preserving history?

Nenhuma migration deve ser criada antes dessa revisão.

---

# 32. Decisões congeladas nesta especificação

Ficam estabelecidos:

1. Monitor é produto/processo de manutenção, não N5;
2. Monitor opera somente em M2/M3;
3. existe sempre alvo científico rastreável;
4. ciclos de vigilância são distintos de versões científicas;
5. ausência de mudança não cria automaticamente nova ProductVersion;
6. currentness pode ser atualizado sem mudança científica;
7. atualização material usa versionamento do produto monitorado;
8. Monitor não altera conclusão silenciosamente;
9. Monitor e Alerta são distintos;
10. Alertas não substituem atualização;
11. assurance do alvo não valida automaticamente o Monitor;
12. automação/IA não pode fabricar execução, evidência ou verificação humana;
13. thresholds temporais/quantitativos gerais permanecem para a Fase 4;
14. arquitetura física ainda não está congelada.

---

# 33. Próxima etapa

> **Executar revisão de coerência científica e arquitetural do Monitor de Evidências contra OES-P1, Investigation/ProductVersion, Search, provenance, currency_state, version_change_class e a fronteira Fase 3 × Fase 4.**

Somente após essa revisão:

> **definir o Contrato de Dados v0.1 do Monitor de Evidências.**

---

**Resultado:** Especificação Científica e Funcional inicial do Monitor de Evidências concluída, preservando a separação entre vigilância, currentness, atualização científica, assurance e Alerta de Evidência.
