# STATE — Estado Atual do Projeto OES

**Última atualização:** 4 de outubro de 2026  
**Fase atual:** Fase 3 — Produtos do Observatório  
**Status geral:** em desenvolvimento

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP16 — 2026-10-04**.

## 2. Estado das fases

- Fase 0 — Concepção e fundamentos: base inicial consolidada;
- Fase 1 — Manual Metodológico: base inicial dos Documentos 10–15 consolidada;
- Fase 2 — Modelo de Dados da Evidência: **concluída no nível de baseline arquitetural**;
- Fase 3 — Produtos do Observatório: **iniciando**;
- Fases 4–7: ainda não iniciadas formalmente.

## 3. Arquitetura

### OES-H1

**Arquitetura de referência.**

Núcleo relacional canônico + estruturas documentais controladas + object storage + projeções derivadas.

### OES-P1

**Baseline arquitetural da Fase 2.**

Foi promovido após:

- GATE F2-A PASS;
- GATE F2-B PASS;
- PoC-S4 PASS;
- PoC-S5 PASS;
- 15/15 critérios de promoção validados.

### PostgreSQL

**Implementação de referência validada para desenvolvimento/PoC.**

Não constitui escolha definitiva de stack de produção.

## 4. Evidência técnica principal

### F2-B

- run 37187885839;
- T01–T19 PASS.

### PoC-S4

- run 37188934837;
- S4-T01–T15 PASS.

### PoC-S5

- run 37189646452;
- regressão F2-B PASS;
- regressão S4 PASS;
- S5-T01–T17 PASS;
- artifact 11297653844;
- digest `sha256:ba8aed9373dfde8c5ee14c67f91084b2158c3b76bc98560fbc5a22555b133719`.

## 5. Matriz de promoção do Documento 25

> **15 VALIDADO / 0 PARCIAL / 0 NÃO VALIDADO**

## 6. Decisão de fechamento da Fase 2

Documento:

`docs/architecture/38-decisao-promocao-fechamento-fase2.md`

Decisão:

- OES-P1 promovido a baseline arquitetural;
- Fase 2 concluída;
- schema de produção não congelado;
- stack de produção não escolhida;
- evolução futura deve ocorrer por migrations controladas.

## 7. Reservas metodológicas/operacionais

Ainda não finalizados:

- taxonomia definitiva dos produtos;
- templates individuais dos produtos;
- ApplicabilityAssessment operacional;
- protocolo de atualização/monitoramento;
- automação e IA;
- infraestrutura de produção;
- autenticação/autorização;
- backup/HA.

## 8. Próxima etapa

**Fase 3 — Produtos do Observatório.**

Primeira tarefa:

> definir a taxonomia oficial e a arquitetura dos produtos OES antes de criar templates individuais.

O documento deverá estabelecer:

- finalidade;
- público/necessidade;
- níveis N0–N4 e M0–M3;
- requisitos metodológicos mínimos;
- entidades persistentes obrigatórias;
- campos mínimos de saída;
- linguagem de certeza e limitações;
- fronteira evidência/recomendação;
- critérios de escolha entre produtos;
- política de versionamento.

## 9. Checkpoint vigente

**CP16 — 2026-10-04**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-04_CP16.md`

Ponto exato de retomada:

**Fase 3 — taxonomia e arquitetura dos produtos do Observatório.**
