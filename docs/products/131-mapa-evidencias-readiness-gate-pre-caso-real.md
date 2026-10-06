# 131 — Mapa de Evidências: Readiness Gate Pré-Caso Real

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status do gate:** **ROTA EXPLORATÓRIA = READY_WITH_DOCUMENTED_CONDITIONS / ROTA FORMAL = NOT_READY**  
**Escopo:** prontidão antes da abertura do primeiro Caso Real do Mapa

---

# 1. Objetivo

Avaliar separadamente a prontidão operacional do OES para dois usos metodologicamente distintos do Mapa de Evidências:

1. **Rota A — exploratória / structured non-exhaustive**;
2. **Rota B — systematic map / evidence and gap map formal**.

A avaliação ocorre após:

- contrato técnico do Mapa = PASS;
- EvidenceMapView = PASS;
- Projection Readiness Gate = READY;
- template/renderização = PASS.

Este gate avalia prontidão **real**, não capacidade sintética.

---

# 2. Regra canônica

O Documento 123 estabelece que a busca deve ser proporcional à força da alegação.

Para mapa exploratório interno:

- cobertura limitada é admissível;
- completude não pode ser reivindicada;
- gaps devem ser aparentes;
- limitações devem ser explícitas;
- rótulo de systematic map/EGM formal é proibido.

Para systematic map/EGM formal:

- busca deve ser sistemática, reprodutível e suficientemente abrangente;
- seleção/classificação exigem controles humanos proporcionais;
- alegações formais de gap exigem cobertura compatível;
- assurance A3 e revisão especializada independente são requeridos pelo contrato quando aplicáveis.

---

# 3. Resultado agregado

| Rota | Estado |
|---|---|
| A — exploratória / structured non-exhaustive | **READY_WITH_DOCUMENTED_CONDITIONS** |
| B — systematic map / EGM formal | **NOT_READY** |

Não existe um único estado de readiness para todos os Mapas.

---

# 4. Rota A — exploratória / structured non-exhaustive

**Estado:** `ready_with_documented_conditions`

## 4.1 Condições permitidas

Um Caso Real exploratório pode ser aberto se:

- finalidade for interna/experimental;
- `coverage_claim=structured_non_exhaustive` ou `exploratory`;
- `gap_claim_mode=apparent_only` ou `none`;
- subtype não for usado para sugerir systematic map/EGM formal;
- nenhuma alegação de completude for feita;
- nenhuma célula vazia for descrita como ausência universal de evidência;
- limitações de fonte/busca forem explicitamente preservadas;
- uso de IA na classificação seja transparente;
- nenhum ReviewerAssignment humano seja fabricado;
- nenhum `human_verified` ou `human_consensus` seja produzido sem humano real;
- assurance reflita os controles realmente existentes;
- se permanecer A1, o produto permaneça interno e não publicado.

## 4.2 Assurance

O contrato permite:

- mapa interno A1, não publicado;
- mapa não sistemático publicado somente com mínimo A2.

Para o primeiro Caso Real exploratório:

> **a rota autorizada inicial é A1 / interna / under_review / publication_date=NULL / publishable=false.**

A2 não deve ser presumida antecipadamente.

Eventual owner governance approval será decisão posterior e não deve ser criada apenas para elevar assurance.

## 4.3 Classificação

Como a rota não é `systematic_comprehensive`, o publication gate formal de dupla classificação humana não é condição para manter um artefato interno A1.

Ainda assim:

- framework e codebook devem ser explícitos;
- classifications devem ser rastreáveis;
- IA deve ser registrada como IA;
- ambiguous classifications devem permanecer visíveis;
- nenhum selo humano deve ser simulado.

## 4.4 Gaps

Somente:

> `apparent_only`

Linguagem obrigatória:

> **nenhuma unidade elegível foi localizada nas fontes consultadas para esta classificação.**

Proibido:

> **não existe evidência.**

---

# 5. Candidato preferencial para o primeiro Caso Real exploratório

O corpus do **Caso Real N3-01 — ambient AI scribes e carga de documentação clínica** é o candidato preferencial.

Razões:

1. é um corpus real já persistido no OES;
2. possui protocolo, Search, SearchHit e Screening rastreáveis;
3. possui Studies, Reports, Results, appraisals e Syntheses reutilizáveis;
4. possui histórico de correção/versionamento;
5. suas limitações de cobertura são conhecidas e documentadas;
6. o adversarial layer demonstrou empiricamente que a cobertura não satisfaz N3 formal;
7. essa insuficiência impede alegação sistemática, mas não impede descrição exploratória do corpus efetivamente recuperado;
8. reutilizá-lo testa a natureza transversal do Mapa sem executar uma nova busca apenas para “fabricar” um caso.

---

# 6. Estado metodológico do corpus N3-01

O encerramento do Caso Real N3-01 registrou:

- Product `OES-P-2026-000701`;
- ProductVersion atual = 2;
- assurance A0;
- `under_review`;
- `publishable=false`;
- 20 hits materializados após correção;
- 34 decisões de screening;
- 13 referências utilizadas/contextuais;
- PubMed/MEDLINE como única base bibliográfica reproduzivelmente executada;
- Europe PMC não executável de forma reproduzível;
- OpenAlex direto não executável;
- publisher/DOI/citation chasing como fontes suplementares;
- novos estudos elegíveis ainda localizados após correções;
- qualified human controls ausentes.

Esses fatos significam:

> **o corpus não pode sustentar systematic_comprehensive nem formal gap claims.**

Mas permitem:

> **mapear de forma transparente o corpus acumulado como structured_non_exhaustive.**

---

# 7. Delimitação do primeiro Caso Real exploratório

Caso seja aberto, o primeiro mapa deverá declarar explicitamente que:

> **ele mapeia o corpus acumulado pelo Caso Real N3-01 e não pretende reconstruir toda a literatura sobre ambient AI scribes.**

A busca canônica será a busca já realizada no N3-01.

Não executar busca adicional apenas para tentar transformar o mapa em formal.

Se nova busca vier a ser executada no futuro:

- deverá ser registrada como nova evidência;
- poderá justificar nova versão;
- não deverá retroativamente alterar a natureza da versão exploratória original.

---

# 8. Subtype recomendado

Para evitar ambiguidade com systematic map/EGM formal:

> `mapping_subtype=descriptive_mapping_review`

Coverage:

> `structured_non_exhaustive`

Gap mode:

> `apparent_only`

Counting unit inicial:

> `study`

Essas escolhas deverão ser formalizadas no protocolo do Caso Real.

---

# 9. Framework inicial recomendado

O primeiro caso deve permanecer simples o suficiente para testar a arquitetura sem criar classificações artificiais.

Framework candidato:

### row axis

**evidence_role**

Categorias candidatas:

- primary_evidence;
- synthesis.

### column axis

**outcome_domain**

Categorias candidatas derivadas do protocolo N3:

- documentation_time;
- workload_or_exhaustion;
- work_outside_work;
- note_quality_or_safety;
- other_contextual_outcomes.

### filter

**study_design_or_evidence_context**

Categorias devem ser definidas somente após inventário das entidades reais a mapear.

O codebook deverá especificar classificação múltipla quando uma Study/Synthesis cobrir mais de um outcome domain.

---

# 10. Restrições do primeiro caso

Não:

- chamar o produto de systematic evidence map;
- chamar o produto de evidence gap map formal;
- usar `systematic_comprehensive`;
- usar `formal_within_scope`;
- criar A2/A3 por conveniência;
- fabricar reviewer assignments;
- transformar AI classification em `human_verified`;
- afirmar ausência global de evidência;
- transformar apparent gap em research priority;
- reabrir o Caso N3 como ProductVersion 3;
- modificar a conclusão/assurance do N3-01.

O Mapa será um **novo Product**, reutilizando entidades científicas elegíveis do corpus N3.

---

# 11. Rota B — systematic map / EGM formal

**Estado:** `not_ready`

## 11.1 Cobertura bibliográfica

**Estado:** `not_ready`

Evidência já demonstrada no N3-01:

- uma única base bibliográfica foi reproduzivelmente executada;
- a fonte planejada adicional falhou;
- OpenAlex direto não ficou operacional;
- fontes suplementares não substituíram uma segunda base bibliográfica;
- busca adversarial continuou localizando estudos elegíveis.

Para systematic map/EGM, a exigência de coverage é pelo menos tão rigorosa quanto a necessária para sustentar formal gap claims.

Conclusão:

> cobertura bibliográfica abrangente não pode ser garantida.

## 11.2 Equipe metodológica

**Estado:** `not_ready`

Conforme readiness N4 já registrado:

- existe apenas o proprietário como humano envolvido no projeto;
- não há dois revisores humanos qualificados e independentes;
- não há search peer reviewer/information specialist qualificado;
- não há data verifier/coder independente qualificado disponível;
- não há adjudicação humana independente configurada.

Para mapa formal, esses controles não podem ser substituídos por IA.

## 11.3 Governança/A3

**Estado:** `not_ready`

O modelo técnico suporta:

- A3;
- expert independent review;
- reviewer assignments;
- conflicts;
- qualified controls.

A configuração real não possui:

- expert independent reviewer qualificado;
- caminho operacional real para A3.

## 11.4 Ferramentas/artefatos

**Estado:** `ready`

Já disponíveis:

- migrations 016–017;
- mapping schema;
- cells/gaps;
- publication gate;
- EvidenceMapView;
- protocol/codebook artifacts;
- template;
- renderer/validator;
- provenance;
- rebuild;
- CI.

## 11.5 Resultado formal

> **NOT_READY**

Não abrir systematic map/EGM formal neste momento.

---

# 12. Por que as duas rotas não são contraditórias

A Rota A pergunta:

> podemos descrever de forma auditável um corpus real conhecido, sem alegar completude?

Resposta:

> **sim, com condições explícitas.**

A Rota B pergunta:

> podemos sustentar metodologicamente uma alegação abrangente de cobertura e formal gaps?

Resposta:

> **não, nas condições atuais.**

Isso preserva a proporcionalidade entre método e alegação.

---

# 13. Decisão

## Rota A

> **READY_WITH_DOCUMENTED_CONDITIONS**

Autorizado:

> abrir primeiro Caso Real exploratório do Mapa reutilizando o corpus N3-01, como novo Product interno A1, com `descriptive_mapping_review + structured_non_exhaustive + apparent_only`.

## Rota B

> **NOT_READY**

Não autorizado:

- systematic evidence map formal;
- evidence and gap map formal;
- formal gap claims;
- publicação A3;
- qualquer substituição de controles humanos por IA.

---

# 14. Próxima etapa

> **Abrir o Caso Real MAP-01 — ambient AI scribes: mapa exploratório do corpus N3-01.**

Primeiro artefato:

> **protocolo do Caso Real MAP-01**, definindo objetivo, corpus herdado, framework/codebook, counting unit, classificação, limitations, assurance e regra de apparent gaps antes da persistência do caso.

---

**Resultado final:** a infraestrutura real autoriza um Caso Real exploratório controlado; a rota formal systematic map/EGM permanece bloqueada.
