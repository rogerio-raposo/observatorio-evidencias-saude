# 38 — Decisão de Promoção Arquitetural e Fechamento Técnico da Fase 2

**Projeto:** Observatório de Evidências em Saúde — OES  
**Data:** 4 de outubro de 2026  
**Status:** Decisão arquitetural consolidada  
**Base:** Documentos 20–37

## 1. Objeto

Decidir, após F2-A, F2-B, PoC-S4 e PoC-S5, se a arquitetura candidata OES-H1 e o candidato físico OES-P1 possuem evidência suficiente para serem promovidos a baseline arquitetural da Fase 2.

## 2. Evidência acumulada

Foram concluídos:

- GATE F2-A — PASS;
- GATE F2-B — PASS;
- PoC-S4 — PASS;
- PoC-S5 — PASS.

A última execução especializada preservou regressões do F2-B e da PoC-S4.

## 3. Critérios de promoção do Documento 25

Resultado final:

- **15 VALIDADO**;
- **0 PARCIALMENTE VALIDADO**;
- **0 NÃO VALIDADO**.

Foram validados:

1. Question/Investigation;
2. SearchHits;
3. deduplicação;
4. Study com múltiplos Reports;
5. Report com múltiplos Studies;
6. Result com provenance;
7. síntese quantitativa;
8. NMA;
9. PredictionModel;
10. qualitativa/CERQual;
11. Certainty;
12. Product/Ficha;
13. atualização/versionamento;
14. retração e impact analysis;
15. lineage completo.

## 4. Decisão sobre OES-H1

> **OES-H1 é PROMOVIDA a BASELINE ARQUITETURAL DA FASE 2.**

Sua estrutura conceitual/lógica passa a ser a referência oficial para as fases subsequentes, sujeita a evolução controlada e changelog.

Isso não significa arquitetura de produção imutável.

## 5. Decisão sobre OES-P1

> **OES-P1 é PROMOVIDO a BASELINE FÍSICO DE REFERÊNCIA DA FASE 2.**

Isso significa que:

- o desenho físico possui evidência suficiente de adequação ao domínio modelado;
- as migrations 002–005 constituem a sequência experimental de referência da Fase 2;
- futuras extensões deverão ser incrementais e justificadas;
- o núcleo não deverá ser reaberto sem evidência de defeito ou requisito novo formal.

Não significa:

- schema de produção congelado;
- solução operacional pronta;
- escolha definitiva de deployment;
- SLA/SLO definidos;
- banco gerenciado escolhido;
- segurança operacional concluída.

## 6. Decisão sobre PostgreSQL

> **PostgreSQL permanece implementação de referência validada para a arquitetura.**

Ainda não é decisão definitiva de stack de produção.

A escolha futura deverá avaliar requisitos não cobertos pelas PoCs, incluindo:

- operação;
- disponibilidade;
- backup;
- recuperação;
- segurança;
- custos;
- observabilidade;
- escalabilidade;
- integração.

## 7. Fechamento técnico da Fase 2

Condições definidas no Documento 33:

1. PoC-S4 concluída — **SIM**;
2. PoC-S5 concluída — **SIM**;
3. 15 critérios validados — **SIM**;
4. lineage/rebuild íntegros — **SIM**;
5. defeito estrutural crítico aberto — **NÃO**;
6. documentação sincronizada — **SIM, após esta consolidação**;
7. decisão explícita de promoção — **SIM**.

Consequentemente:

> **FASE 2 — MODELO DE DADOS DA EVIDÊNCIA: TECNICAMENTE CONCLUÍDA.**

## 8. Governança após promoção

A partir desta decisão:

- alterações estruturais exigem migration incremental;
- decisões persistentes devem atualizar documentação e changelog;
- nova entidade/tabela exige vínculo com requisito metodológico ou de produto;
- lineage/provenance continuam invariantes obrigatórias;
- regressões F2-B/S4/S5 devem ser preservadas quando houver alterações estruturais.

## 9. Itens deliberadamente não resolvidos pela Fase 2

Permanecem para fases posteriores:

- stack de produção definitiva;
- autenticação/autorização;
- gestão de usuários;
- observabilidade;
- deployment;
- backup/HA;
- interface;
- automação de buscas;
- motores estatísticos completos;
- integração operacional de IA;
- políticas de atualização em execução;
- experiência dos produtos OES.

Esses itens não invalidam o fechamento do modelo de dados.

## 10. Próxima fase

Conforme roadmap do OES:

> **Fase 3 — Produtos do Observatório**

Objetivo geral:

transformar a base metodológica e o modelo de dados em produtos científicos padronizados e auditáveis, começando pela especificação operacional dos produtos já definidos conceitualmente:

- Resposta de Evidência;
- Ficha de Evidência;
- Síntese Rápida;
- Revisão de Evidências;
- Mapa de Evidências;
- Monitor de Evidências.

A entrada na Fase 3 deverá começar pela arquitetura dos produtos e seus contratos de dados, não pela interface visual.

---

**Decisão final:** OES-H1 e OES-P1 promovidos a baselines da Fase 2; Fase 2 tecnicamente concluída; próxima etapa = Fase 3 — Produtos do Observatório.
