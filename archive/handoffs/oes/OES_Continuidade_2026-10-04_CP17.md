# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP17  
**Checkpoint anterior:** CP16  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 3 — consolidação da taxonomia e arquitetura dos produtos  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP17

Estado formal:

> **Fase 2 — concluída no nível de baseline arquitetural**  
> **Fase 3 — Produtos do Observatório: EM DESENVOLVIMENTO**  
> **Documento 40 — Taxonomia e Arquitetura dos Produtos: CONSOLIDADO COMO BASE INICIAL**  
> **Próximo produto a especificar: FICHA DE EVIDÊNCIA**

Base documental anterior à criação deste checkpoint:

`main @ c6a6de715f389710b297d41ca368552dd4cc4ef4`

---

# 2. Documento consolidado

`docs/products/40-taxonomia-arquitetura-produtos.md`

O Documento 40 formaliza a arquitetura comum da Fase 3 antes da criação de templates individuais.

---

# 3. Taxonomia oficial inicial

## Produtos de investigação

1. OES — Evidence Scan — N0;
2. OES — Resposta de Evidência — N1;
3. OES — Ficha de Evidência — N2;
4. OES — Síntese Rápida de Evidências — N3;
5. OES — Revisão de Evidências — N4.

## Produtos analíticos transversais

6. OES — Mapa de Evidências;
7. OES — Overview de Revisões.

## Produtos de manutenção

8. OES — Monitor de Evidências;
9. OES — Alerta de Evidência.

---

# 4. Decisões estruturais

1. Profundidade N0–N4 permanece independente de manutenção M0–M3.
2. Monitor de Evidências não é N5.
3. Alerta de Evidência não é nova síntese.
4. A Ficha de Evidência é a **unidade persistente central preferencial** para perguntas focais reutilizáveis.
5. Produtos científicos formais devem possuir data de corte.
6. Product e ProductVersion permanecem separados.
7. Estado editorial, estado de atualidade e estado científico são dimensões distintas.
8. Certainty não será inferida quando não formalmente avaliada.
9. Ausência de evidência não equivale a certeza muito baixa.
10. Aplicabilidade permanece separada de certainty quando conceitualmente apropriado.
11. Evidência, interpretação, aplicabilidade e eventual recomendação permanecem separadas.
12. A Fase 3 não cria framework de recomendação.
13. Mudanças materiais geram nova ProductVersion.
14. Monitoramento não altera conclusão silenciosamente.
15. Alerta é evento; mudança científica exige atualização formal do produto.
16. OES-P1 é o baseline arquitetural de persistência da camada de produtos.
17. Templates individuais somente serão criados após a especificação científica/funcional correspondente.

---

# 5. Classes iniciais de versionamento de produtos

- editorial;
- evidência nova;
- correção científica;
- mudança quantitativa;
- mudança de certeza;
- mudança de aplicabilidade;
- mudança de conclusão.

Uma versão poderá registrar múltiplas classes.

---

# 6. Estados separados

## Estado editorial

- draft;
- under_review;
- published;
- superseded;
- archived.

## Estado de atualidade

- atual;
- em_avaliacao;
- atualizacao_recomendada;
- desatualizada;
- arquivada.

## Estado científico

Permanece registrado nas entidades metodológicas apropriadas, sem fusão com os estados anteriores.

---

# 7. Regra de recomendação

Todos os produtos permanecem sob a cadeia:

> **evidência → certeza → interpretação → aplicabilidade → eventual recomendação**

Nenhum produto da taxonomia inicial transforma certainty automaticamente em recomendação.

---

# 8. Ponto exato de retomada

## Especificação da Ficha de Evidência

Próxima tarefa:

1. definir o contrato científico da Ficha;
2. formalizar objetivo e unidade de conhecimento;
3. definir seções obrigatórias;
4. mapear cada seção às entidades OES-P1;
5. distinguir campos obrigatórios, condicionais e não aplicáveis;
6. definir regras de conclusão e linguagem de certeza;
7. definir aplicabilidade;
8. definir estados e versionamento;
9. definir critérios mínimos para publicação;
10. definir relação com M0–M3;
11. definir regra de derivação a partir de ou para outros produtos;
12. criar exemplo estrutural;
13. somente depois criar o template operacional.

---

# 9. Regra para retomada

1. consultar o ponteiro;
2. ler CP17;
3. aplicar Freshness Gate;
4. consultar Documentos 02, 03, 15, 38 e 40;
5. iniciar a especificação individual da Ficha;
6. não criar template antes de fechar seu contrato científico.

---

**Fim do CP17**
