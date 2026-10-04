# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP16  
**Checkpoint anterior:** CP15  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** fechamento da Fase 2 e transição para Fase 3  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP16

Estado formal:

> **Fase 0 — base inicial consolidada**  
> **Fase 1 — base metodológica inicial consolidada**  
> **Fase 2 — MODELO DE DADOS DA EVIDÊNCIA: CONCLUÍDA NO NÍVEL DE BASELINE ARQUITETURAL**  
> **Fase 3 — PRODUTOS DO OBSERVATÓRIO: PRÓXIMA FASE**  
> **OES-H1 — arquitetura de referência**  
> **OES-P1 — baseline arquitetural da Fase 2**  
> **PostgreSQL — implementação de referência validada; não stack final de produção**

Base documental anterior à criação deste checkpoint:

`main @ b2262f4f79760ec7424ca337f9416beb4389916c`

---

# 2. Evidência de fechamento da Fase 2

## GATE F2-A

PASS / aprovado.

## GATE F2-B

PASS.

## PoC-S4

PASS.

## PoC-S5

PASS.

Execução S5:

- run: **37189646452**
- PostgreSQL: **18.6**
- regressão F2-B: PASS
- regressão S4: PASS
- S5-T01–T17: PASS
- rebuild: PASS
- artifact: **11297653844**
- digest: `sha256:ba8aed9373dfde8c5ee14c67f91084b2158c3b76bc98560fbc5a22555b133719`

---

# 3. Matriz final de promoção

Critérios do Documento 25:

> **15 VALIDADO / 0 PARCIAL / 0 NÃO VALIDADO**

Cobertura inclui:

- identidade/versionamento;
- Search/Screening/Dedup;
- Study/Report N:M;
- Result/provenance;
- síntese quantitativa;
- NMA;
- PredictionModel;
- Qualitativa/CERQual;
- Certainty;
- Product;
- atualização/versionamento;
- retração/impact analysis;
- lineage completo.

---

# 4. Decisão arquitetural

Documento canônico:

`docs/architecture/38-decisao-promocao-fechamento-fase2.md`

Decisão:

> **OES-P1 PROMOVIDO A BASELINE ARQUITETURAL DA FASE 2.**

Significado:

- referência canônica para evolução posterior;
- mudanças estruturais exigem migration e justificativa;
- o baseline pode evoluir;
- não existe ainda schema final de produção;
- PostgreSQL não foi escolhido definitivamente para produção.

---

# 5. Reservas preservadas

A conclusão da Fase 2 não resolve automaticamente:

- especificação final dos produtos;
- ApplicabilityAssessment metodologicamente operacionalizado;
- monitoramento/atualização;
- automação e IA;
- autenticação/autorização;
- backup/HA;
- deployment;
- stack de produção.

Esses temas pertencem às fases seguintes.

---

# 6. Próxima fase

## Fase 3 — Produtos do Observatório

Objetivo original do Documento 00:

> padronizar fichas, relatórios, sínteses, mapas e monitores.

A Fase 3 deve começar por **arquitetura e taxonomia de produtos**, não por interface visual.

Produtos já concebidos preliminarmente:

- Resposta de Evidência;
- Ficha de Evidência;
- Síntese Rápida;
- Revisão de Evidências;
- Mapa de Evidências;
- Monitor de Evidências.

---

# 7. Ponto exato de retomada

Criar o primeiro documento da Fase 3 com:

1. taxonomia oficial dos produtos;
2. finalidade de cada produto;
3. pergunta/necessidade que cada um atende;
4. níveis de profundidade N0–N4 compatíveis;
5. níveis de manutenção M0–M3 compatíveis;
6. requisitos metodológicos mínimos;
7. entidades persistentes obrigatórias;
8. campos mínimos de saída;
9. linguagem de certeza/limitações;
10. fronteira entre síntese de evidência e recomendação;
11. critérios de escolha entre produtos;
12. política de versionamento dos produtos.

Somente depois deverão ser criados templates individuais.

---

# 8. Regra de retomada

1. consultar ponteiro operacional;
2. ler CP16;
3. aplicar Freshness Gate;
4. consultar Documentos 00, 02, 03, 15 e 38;
5. iniciar Fase 3 pela taxonomia/arquitetura de produtos;
6. não iniciar UI ou automação.

---

**Fim do CP16**
