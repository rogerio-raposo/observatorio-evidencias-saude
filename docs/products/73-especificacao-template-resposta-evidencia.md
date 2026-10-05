# 73 — Especificação do Template Operacional da Resposta de Evidência — N1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — especificação inicial do template  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 68–72  
**Entrada canônica de renderização:** `EvidenceResponseView` — `oes.evidence_response_view/0.1`

---

# 1. Finalidade

Definir como o conteúdo científico já estruturado no `EvidenceResponseView` deverá ser apresentado ao leitor na primeira versão operacional da **Resposta de Evidência — N1**.

Regra:

> **o template apresenta; não decide ciência.**

O template não poderá:

- selecionar fontes;
- inventar resultados;
- recalcular efeitos;
- criar certainty;
- resolver conflito entre fontes;
- elevar a profundidade metodológica;
- alterar assurance;
- aprovar publicação;
- converter resposta em recomendação clínica ou normativa.

---

# 2. Formato inicial

A primeira implementação será:

> **Markdown canônico**

Motivos:

- legibilidade;
- versionamento Git;
- baixo acoplamento;
- facilidade de diff;
- transformação posterior para HTML/PDF/DOCX;
- compatibilidade com o padrão já utilizado pela Ficha N2.

Markdown é formato-fonte de apresentação, não definição do produto científico.

---

# 3. Arquitetura de leitura

A Resposta N1 deverá ser mais curta que a Ficha N2.

Terá duas camadas.

## 3.1 Camada 1 — resposta rápida

Deve permitir compreensão imediata de:

1. pergunta;
2. resposta sintética;
3. principais resultados;
4. certeza/confiança;
5. principais limitações;
6. data de corte.

## 3.2 Camada 2 — transparência

Deve permitir verificar:

- método de busca;
- caráter não exaustivo;
- fontes-chave;
- aplicabilidade;
- referências;
- assurance;
- publication issues;
- lineage/provenance.

A Camada 2 não deverá transformar o produto em uma Ficha N2 longa.

---

# 4. Ordem canônica das seções

1. Cabeçalho;
2. Pergunta;
3. Resposta da evidência;
4. Principais resultados;
5. Certeza/confiança;
6. Principais limitações;
7. Aplicabilidade, quando relevante;
8. Método em resumo;
9. Fontes-chave;
10. Referências;
11. Garantia metodológica e auditoria.

---

# 5. Cabeçalho

Exibir:

- título;
- Product ID;
- versão;
- estado editorial;
- profundidade N1;
- manutenção M;
- data de corte;
- data de publicação, quando existente;
- estado de atualidade.

UUIDs técnicos não devem aparecer na camada de leitura rápida.

Formato conceitual:

```text
# [Título]

Product ID: ...
Versão: ...
Profundidade: N1
Manutenção: M...
Evidência considerada até: ...
Estado: ...
```

---

# 6. Pergunta

Usar como forma principal:

`question.normalized_text`

A pergunta original pode aparecer apenas na auditoria quando houver diferença material.

Quando estrutura científica for útil, poderá ser apresentada de forma compacta.

Não reconstruir PICO/PICo/PECO por inferência textual.

---

# 7. Resposta da evidência

Fonte:

`answer.text`

Título:

> **Resposta da evidência**

A resposta deverá aparecer imediatamente após a pergunta.

Regras:

- preservar sentido;
- não intensificar certeza;
- não inserir linguagem prescritiva;
- não omitir incerteza material;
- não converter “associação” em “efeito”;
- não converter “pode” em “é”.

Se o produto não for publicável, a renderização deverá deixar explícito que se trata de **preview/draft**.

---

# 8. Principais resultados

Fonte preferencial:

`key_results[]`

Cada item deverá exibir somente informação disponível.

Campos possíveis:

- medida;
- estimativa;
- intervalo;
- unidade;
- contexto;
- fonte;
- localização na fonte.

O template não poderá inferir esquema fixo quando `source_value` variar por classe de pergunta.

## 8.1 Resultado estruturado

Quando `source_value` possuir campos numéricos reconhecíveis, apresentar em tabela simples.

Exemplo conceitual:

| Resultado | Valor | Fonte |
|---|---|---|
| ... | ... | ... |

## 8.2 Resultado narrativo

Quando o valor for narrativo ou heterogêneo, apresentar bloco textual.

## 8.3 Provenance visível

A fonte de cada resultado material deverá ser identificável por Report ID ou referência bibliográfica.

---

# 9. Certeza/confiança

## 9.1 Formalmente avaliada

Quando:

`certainty.formal_assessment = true`

apresentar:

- framework;
- nível final;
- data da avaliação;
- papel da avaliação.

Não atribuir rótulo global se houver múltiplas unidades heterogêneas.

## 9.2 Não formalmente avaliada

Quando:

`certainty.formal_assessment = false`

exibir literalmente:

> **Certeza/confiança: não avaliada formalmente pelo OES nesta Resposta de Evidência.**

Se a fonte externa relatar certainty e isso estiver provenanciado, poderá ser apresentado como:

> **Certeza relatada pela fonte:** ...

sem convertê-la em julgamento OES.

## 9.3 Proibição

Não substituir ausência de certainty por:

- baixa;
- muito baixa;
- incerta;

salvo se esse rótulo estiver explicitamente ligado a framework identificável.

---

# 10. Principais limitações

Fonte:

`limitations.summary`

Título:

> **Principais limitações**

A seção é obrigatória em produto publicado.

Deve incluir, quando pertinente:

- busca seletiva;
- fonte única;
- desatualização potencial;
- limitações metodológicas da fonte;
- ausência de certainty formal;
- conflito não resolvido;
- limite de aplicabilidade.

O template não cria novas limitações; apenas apresenta o resumo persistido.

---

# 11. Aplicabilidade

Fonte:

`applicability.summary`

Se presente:

> **Aplicabilidade**

Quando o foco for brasileiro:

> **Aplicabilidade ao Brasil**

Enquanto `formal_assessment=false`, poderá constar:

> Avaliação formal de aplicabilidade ainda não implementada; análise descritiva.

Se summary estiver ausente e aplicabilidade não for material, a seção pode ser omitida.

---

# 12. Método em resumo

Exibir:

- caráter seletivo/não exaustivo;
- fontes pesquisadas;
- data(s) da busca;
- estratégia registrada de forma auditável;
- número de resultados recuperados quando disponível.

Texto mínimo obrigatório:

> **Busca estruturada e seletiva. Esta Resposta de Evidência não pretende demonstrar identificação exaustiva de toda a literatura.**

Não usar expressões como:

- “revisão completa”;
- “todos os estudos”;
- “evidência total disponível”;

sem base metodológica correspondente.

---

# 13. Fontes-chave

Fonte:

`key_sources[]`

Apresentar:

- título;
- tipo/origem quando disponível;
- data;
- papel derivado;
- appraisal formal, quando existente;
- localizações utilizadas.

Papéis possíveis:

- decisiva;
- suporte;
- contextual;
- evidência vinculada.

O rótulo deve ser apresentado como função na resposta, não como hierarquia absoluta de qualidade.

Quando houver apenas uma fonte decisiva, isso deverá permanecer visível e coerente com o warning do gate.

---

# 14. Referências

Fonte:

`references[]`

Apresentar referências deduplicadas.

Preferir:

- título;
- data;
- identificador persistente quando disponível;
- origem.

A lista não deverá incluir item sem vínculo rastreável com a ProductVersion.

---

# 15. Garantia metodológica

Exibir sempre em produto formal:

- assurance level;
- verificação metodológica;
- aprovação de governança;
- situação de revisão especializada independente.

Para A2 sem A3:

> **Verificação metodológica:** processo OES assistido por IA.  
> **Aprovação de governança:** realizada pelo proprietário do projeto.  
> **Revisão especializada independente:** não realizada.

A ausência de expert review não deve ficar escondida em seção técnica colapsada.

---

# 16. Publication gate

## 16.1 Produto publicável

Quando:

`audit.publishable = true`

exibir:

> **Gate de publicação:** aprovado.

Warnings permanecem listados.

## 16.2 Produto não publicável

Quando:

`audit.publishable = false`

o documento deverá iniciar com aviso:

> **PREVIEW — NÃO PUBLICÁVEL**

e exibir os erros bloqueantes em auditoria.

O template não deverá mascarar erro de gate.

---

# 17. Warnings

Warnings podem incluir:

- `NO_EXPERT_INDEPENDENT_REVIEW`;
- `NO_FORMAL_CERTAINTY`;
- `SINGLE_REFERENCE_SOURCE`;
- `SINGLE_SEARCH_SOURCE`;
- `NO_FORMAL_APPRAISAL_OF_SINGLE_SOURCE`.

Eles devem ser apresentados sem linguagem alarmista e sem serem confundidos com erro bloqueante.

---

# 18. Auditoria técnica

A seção final poderá incluir:

- ProductVersion UUID;
- InvestigationVersion UUID;
- schema version da view;
- assurance records;
- publication issues;
- lineage available.

Essa seção é auditável, não destinada à leitura inicial.

---

# 19. Comportamento quando não houver key_results

Se `key_results=[]` mas a conclusão for sustentada por fonte decisiva rastreável, o template poderá apresentar:

> **Principais resultados:** consulte a síntese narrativa acima e as fontes-chave.

Isso só é aceitável se o publication gate permitir e a ausência não ocultar dado quantitativo material que deveria ter sido estruturado.

Caso real deverá testar esse comportamento.

---

# 20. Comportamento com múltiplas fontes

Quando houver múltiplas fontes decisivas:

- apresentar cada uma;
- não fundir resultados incompatíveis;
- explicitar discordância material se registrada;
- não criar “consenso” por contagem de fontes.

Se o conflito tornar N1 inadequado, o reroteamento deve ocorrer antes da publicação; o template não resolve isso.

---

# 21. Comportamento com certainty externa

Se certainty vier de fonte externa e não estiver estruturada como CertaintyAssessment OES:

- rotular como “relatada pela fonte”;
- identificar framework;
- não alterar o nível;
- não chamar de “avaliação OES”.

---

# 22. Linguagem de comunicação

A linguagem deve ser:

- objetiva;
- proporcional;
- não prescritiva;
- explícita sobre incerteza;
- acessível sem abandonar precisão metodológica.

Evitar:

- “comprovado”;
- “definitivo”;
- “sem dúvida”;
- “recomendado”;

salvo quando a fonte e a finalidade metodológica realmente autorizarem e o produto estiver roteado para isso.

---

# 23. Transformação de apresentação

O renderer poderá:

- formatar datas;
- ordenar fontes;
- apresentar JSON estruturado de key results em texto/tabela;
- traduzir códigos internos em rótulos;
- omitir campos vazios condicionais.

Não poderá:

- calcular novo efeito;
- inferir certainty;
- decidir fonte;
- modificar conclusion_text;
- suprimir publication issue ativo;
- transformar warning em aprovação.

---

# 24. Critérios de validação do template

O template inicial será considerado PASS quando:

1. renderizar view v0.1 válida;
2. mostrar pergunta e resposta;
3. mostrar caráter não exaustivo;
4. mostrar fontes-chave;
5. mostrar key results quando existentes;
6. representar ausência de certainty formal corretamente;
7. mostrar limitações;
8. mostrar assurance;
9. mostrar warning de ausência de expert review;
10. mostrar gate aprovado quando publishable=true;
11. mostrar PREVIEW quando publishable=false;
12. não deixar tokens não resolvidos;
13. não introduzir informação ausente da view;
14. regressões N2 permanecerem verdes.

---

# 25. Arquivos previstos

Após esta especificação:

- `templates/evidence-response.md`;
- eventual mapa de apresentação;
- renderer de referência;
- validator de renderização;
- testes no workflow.

---

# 26. Próxima etapa

Implementar o template Markdown de referência, renderer e validação automatizada usando a fixture N1 já aprovada.

A implementação deverá consumir exclusivamente:

`EvidenceResponseView — oes.evidence_response_view/0.1`

e não consultar tabelas científicas diretamente.

---

**Documento vivo. Alterações materiais deverão ser registradas no CHANGELOG.md.**
