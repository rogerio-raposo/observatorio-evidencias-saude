# 46 — Especificação do Template Operacional da Ficha de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — especificação inicial do template  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 40–45  
**Entrada canônica de renderização:** `EvidenceSheetView` — `oes.evidence_sheet_view/0.1`

---

# 1. Finalidade

Definir como o conteúdo científico já estruturado no `EvidenceSheetView` deverá ser apresentado ao leitor na primeira versão operacional da **Ficha de Evidência**.

Regra:

> **o template apresenta; não decide ciência.**

O template não poderá:

- escolher estudos;
- recalcular resultados;
- alterar certainty;
- reinterpretar risco de viés;
- modificar conclusão;
- transformar implicação em recomendação;
- preencher lacunas com inferência não registrada.

---

# 2. Formato inicial

A primeira implementação será:

> **Markdown canônico**

Motivos:

- legibilidade humana;
- versionamento simples em Git;
- independência de plataforma;
- facilidade de diff;
- conversão posterior para HTML/PDF/DOCX;
- baixo acoplamento tecnológico.

Markdown será o **formato-fonte do template**, não necessariamente o formato final de publicação.

---

# 3. Neutralidade de motor

O template utilizará notação contratual semelhante a:

- `{{path.to.value}}`;
- `{{#each collection}}`;
- `{{#if condition}}`.

Essa notação é **descritiva** nesta fase.

Ela não constitui escolha definitiva de:

- Mustache;
- Handlebars;
- Jinja;
- Liquid;
- outro motor.

Uma futura implementação deverá mapear essa semântica ao motor escolhido sem alterar o contrato científico.

---

# 4. Arquitetura de leitura

A Ficha possuirá duas camadas.

## 4.1 Camada 1 — leitura rápida

Deve permitir compreender a conclusão central sem percorrer toda a ficha.

Inclui:

1. identificação;
2. pergunta;
3. conclusão principal;
4. resultados prioritários;
5. certainty/confiança;
6. principais limitações;
7. aplicabilidade;
8. data de corte e atualidade.

## 4.2 Camada 2 — auditabilidade

Inclui:

- método;
- base de evidências;
- risco de viés;
- certainty detalhada;
- segurança/danos;
- histórico;
- referências;
- metadados de revisão;
- publication gate;
- vínculos auditáveis.

A Camada 2 não deve competir visualmente com a conclusão principal.

---

# 5. Ordem canônica das seções

1. Cabeçalho da Ficha;
2. Pergunta;
3. Conclusão da evidência;
4. Resultados/achados prioritários;
5. Certeza/confiança;
6. Principais limitações;
7. Aplicabilidade;
8. Segurança e danos, quando aplicável;
9. Método em resumo;
10. Base de evidências;
11. Risco de viés;
12. Atualidade e histórico;
13. Referências;
14. Auditoria e rastreabilidade.

Essa ordem poderá ser refinada após validação com casos reais, mas mudanças deverão ser registradas.

---

# 6. Cabeçalho

Exibir obrigatoriamente:

- título;
- Product ID;
- versão;
- estado editorial;
- estado de atualidade;
- N;
- M;
- data de corte;
- data de publicação, quando existente.

Formato conceitual:

```text
# [Título]

Product ID: ...
Versão: ...
Profundidade: N2
Manutenção: M...
Evidência considerada até: ...
Atualidade: ...
```

Não expor UUIDs técnicos na camada rápida.

UUIDs podem constar na auditoria.

---

# 7. Pergunta

Exibir:

- pergunta normalizada como forma principal;
- pergunta original opcionalmente em auditabilidade;
- contexto/estrutura quando necessário.

Regra:

não converter automaticamente PICO/PECO/PICo em texto natural se a versão natural não estiver validada.

---

# 8. Conclusão da evidência

A conclusão será exibida logo após a pergunta.

Fonte exclusiva:

`conclusion.text`

Regra:

- não editar automaticamente o sentido;
- não intensificar linguagem;
- não inserir “recomenda-se”;
- não omitir ressalva material registrada.

Quando vazia em produto não publicável:

> **Conclusão ainda não disponível — produto não publicado.**

Em produto publicado, conclusão vazia é incompatível com o publication gate.

---

# 9. Resultados/achados prioritários

## 9.1 Estrutura

Cada `priority_result` deverá ser renderizado como unidade independente.

Para resultado quantitativo, apresentar quando disponível:

- outcome;
- comparação;
- timepoint;
- estimand/métrica;
- magnitude;
- intervalo de incerteza;
- número de estudos;
- certainty.

Para achado qualitativo, apresentar:

- finding;
- contexto;
- estudos contribuintes;
- confidence/CERQual.

## 9.2 Tabela como padrão para quantitativo

Modelo:

| Desfecho/achado | Efeito/resultado | Estudos | Certeza |
|---|---|---:|---|
| ... | ... | ... | ... |

Se a estrutura do resultado não permitir tabela sem perda semântica, usar bloco narrativo.

## 9.3 Regra de magnitude

O template não calcula:

- RR;
- OR;
- RD;
- NNT;
- efeito absoluto;
- diferença média.

Ele renderiza apenas o que estiver em `result_summary` ou outro campo estruturado autorizado.

---

# 10. Certeza/confiança

## 10.1 Formalmente avaliada

Exibir:

- framework;
- nível final;
- estado da evidência;
- principais razões.

Exemplo de apresentação:

> **Certeza: moderada (GRADE)**  
> Principais limitações: imprecisão.

## 10.2 Não avaliada formalmente

Exibir literalmente:

> **Certeza/confiança: não avaliada formalmente.**

Não substituir por:

- baixa;
- muito baixa;
- incerta.

## 10.3 No evidence

Quando `evidence_state = no_evidence`:

> **Não foram identificadas evidências elegíveis para esta unidade.**

Não exibir nível `very_low`.

## 10.4 Certainty global

Não produzir badge ou rótulo global de certeza da Ficha.

A certainty acompanha cada unidade científica relevante.

---

# 11. Limitações

Exibir `limitations.summary` obrigatoriamente na Camada 1.

Título:

> **Principais limitações**

O texto deverá permanecer distinguível de:

- certainty;
- aplicabilidade;
- risco de viés.

Não sintetizar automaticamente domínios técnicos em nova limitação narrativa.

---

# 12. Aplicabilidade

Título padrão:

> **Aplicabilidade**

Quando o contexto-alvo for brasileiro e o conteúdo justificar:

> **Aplicabilidade ao Brasil**

Fonte inicial:

`applicability.summary`

Se não formalizada:

pode-se indicar discretamente:

> Avaliação formal de aplicabilidade ainda não implementada; análise descritiva.

Não usar score.

---

# 13. Segurança e danos

Se `safety[]` possuir itens:

- criar seção própria;
- apresentar cada síntese de segurança;
- não mesclar danos no mesmo campo de benefício sem distinção.

Se `safety[] = []`:

não afirmar “sem danos”.

Renderização permitida, conforme contexto:

> **Segurança não foi avaliada separadamente nesta Ficha.**

A frase não deve aparecer se segurança for realmente não aplicável à classe da pergunta; nesse caso, omitir a seção.

---

# 14. Método em resumo

Exibir de forma compacta:

- fontes/bases;
- data da última busca;
- contagem recuperada, quando útil;
- método de síntese;
- frameworks de certainty.

A estratégia completa de busca permanece na camada auditável.

Não reproduzir automaticamente query extensa no corpo principal.

---

# 15. Base de evidências

Exibir:

- número de Studies;
- número de Reports;
- desenhos identificados.

Opcionalmente, tabela de Studies:

| Study | Desenho | Amostra | Rótulo |
|---|---|---:|---|

Regra:

> **Studies e Reports nunca são apresentados como equivalentes.**

---

# 16. Risco de viés

Exibir resumo proporcional:

- frameworks;
- julgamentos gerais;
- número de avaliações.

Detalhamento por domínio será opcional na primeira camada auditável.

Não gerar:

- nota média;
- score global;
- semáforo universal não definido metodologicamente.

---

# 17. Atualidade

Bloco obrigatório.

Exibir:

- estado atual;
- data da última avaliação de atualidade;
- data de corte da evidência.

Rótulos de apresentação em português:

- `current` → **Atual**;
- `under_evaluation` → **Em avaliação**;
- `update_recommended` → **Atualização recomendada**;
- `outdated` → **Desatualizada**;
- `archived` → **Arquivada**.

Essa tradução é de apresentação; o valor canônico permanece em inglês no banco.

---

# 18. Histórico de versão

Exibir:

- versão;
- predecessor, quando houver;
- classes de mudança;
- histórico de atualidade.

Em versão inicial:

> **Versão inicial.**

Em atualização, resumir classes:

- nova evidência;
- correção científica;
- alteração quantitativa;
- mudança de certeza;
- mudança de aplicabilidade;
- mudança de conclusão;
- alteração editorial.

Não inventar changelog narrativo além dos dados disponíveis.

---

# 19. Referências

A primeira versão do template exibirá as referências derivadas de `references[]`.

Formato mínimo:

- título;
- data/ano;
- Report ID;
- localização usada, quando relevante.

O formato bibliográfico definitivo poderá ser refinado posteriormente.

Não reconstruir DOI/PMID que não estejam disponíveis no view.

---

# 20. Auditoria e rastreabilidade

Seção final, colapsável em interfaces futuras.

Markdown inicial exibirá:

- publishable;
- publication issues;
- revisões humanas;
- Investigation(s) vinculadas;
- Syntheses vinculadas;
- Certainty Assessments vinculadas;
- lineage disponível;
- UUIDs técnicos relevantes.

Essa seção não é destinada à leitura leiga primária.

---

# 21. Publication issues

## Produto publishable

Se `audit.publishable=true` e não houver errors:

> **Gate de publicação: aprovado.**

Warnings podem ser listados.

## Produto não publishable

Exibir:

> **Gate de publicação: não aprovado.**

Listar errors.

O template não deve ocultar erro bloqueante em preview interno.

Para publicação externa, produto com gate não aprovado não deve ser liberado.

---

# 22. NULL, vazio e NA

Regras:

### NULL

Campo desconhecido/não registrado:

- omitir quando não essencial;
- ou mostrar “não informado” em auditabilidade.

### []

Coleção vazia:

- omitir seção se opcional;
- nunca interpretar automaticamente como ausência de fenômeno.

### NA

Não aplicável:

- mostrar “não aplicável” apenas quando esse estado tiver sido determinado;
- não usar NA como sinônimo de NULL.

### String vazia

Não deverá ser usada como valor semântico.

---

# 23. Linguagem

A primeira versão canônica será em:

> **Português do Brasil**

Termos metodológicos poderão manter sigla/termo internacional quando necessário:

- GRADE;
- CERQual;
- Risk of Bias;
- Synthesis;
- Study;
- Report;
- Result.

O template deverá preferir termo português na leitura principal e termo técnico na auditoria quando isso aumentar clareza.

---

# 24. Badges e cor

A especificação lógica não dependerá de cor.

Estados como:

- certainty;
- atualidade;
- gate;

deverão ser compreensíveis em texto puro.

HTML/PDF futuros poderão adicionar cor como sinal redundante, nunca exclusivo.

Isso preserva:

- acessibilidade;
- impressão;
- exportação;
- compatibilidade Markdown.

---

# 25. Ícones

Ícones não são obrigatórios.

A primeira versão Markdown não dependerá deles.

---

# 26. Links

O template poderá apresentar links para:

- Report;
- Study;
- Investigation;
- Synthesis;
- Certainty;
- artifacts;

quando o ambiente de publicação possuir rota resolvível.

No Markdown de referência, IDs serão suficientes quando URL de aplicação não existir.

---

# 27. Regras de truncamento

Não truncar silenciosamente:

- conclusão;
- limitações;
- applicability;
- certainty rationale.

Listas muito extensas de Studies/Reports poderão ser resumidas no corpo e detalhadas na auditoria.

O template deverá indicar quando uma lista foi resumida.

---

# 28. Tabelas

Tabelas são recomendadas para:

- resultados quantitativos;
- Studies;
- histórico de atualização;
- referências, se útil.

Evitar tabelas para:

- conclusão;
- limitações;
- applicability;
- longos julgamentos narrativos.

---

# 29. Contrato de template

Arquivo proposto:

`templates/evidence-sheet.md`

Entrada:

> `EvidenceSheetView schema_version oes.evidence_sheet_view/0.1`

Saída:

> Markdown UTF-8.

O arquivo deverá começar com comentário declarando:

- versão do template;
- versão do view contract;
- status;
- não ser fonte canônica.

---

# 30. Template version

Primeira versão operacional:

`oes.evidence_sheet.template/0.1`

Mudança de layout compatível pode manter versão menor.

Mudança que altere exigência de campos/semântica deverá produzir nova versão do contrato/template.

---

# 31. Seções condicionais

O template deverá omitir ou adaptar:

- safety quando não aplicável;
- risk_of_bias quando não avaliado;
- certainty details quando não formal;
- predecessor em versão inicial;
- warnings quando inexistentes.

A condição não muda a ciência.

---

# 32. Preview versus publicação

## Preview

Pode renderizar produto não publishable.

Deve exibir claramente:

> **PREVIEW — NÃO PUBLICÁVEL**

e os blocking issues.

## Publicação

Só permitida quando:

`audit.publishable = true`

O motor de publicação futuro deverá aplicar essa regra fora do template também.

---

# 33. Critérios de validação do template

O template inicial deverá ser testado contra a fixture da Ficha e demonstrar:

1. título/identidade;
2. pergunta;
3. conclusão;
4. resultado prioritário;
5. certainty;
6. limitações;
7. applicability;
8. atualidade;
9. método;
10. base de evidências;
11. referências;
12. auditoria;
13. nenhuma ciência inventada;
14. nenhuma seção crítica perdida;
15. Markdown legível sem renderer especial.

---

# 34. Saída futura

A mesma semântica deverá permitir:

- HTML;
- PDF;
- DOCX;
- interface web;
- cards/resumos.

Essas saídas não devem criar contratos científicos divergentes.

---

# 35. Decisões consolidadas

1. Markdown é o primeiro formato-fonte.
2. EvidenceSheetView é a única entrada científica do template.
3. Notação de placeholders é neutra de motor.
4. Leitura rápida precede auditabilidade.
5. Conclusão aparece antes do método detalhado.
6. Resultados prioritários são unidades independentes.
7. Certainty é por unidade, não global.
8. No evidence é estado próprio.
9. Certainty ausente é “não avaliada formalmente”.
10. Limitações são obrigatórias na leitura rápida.
11. Applicability é separada.
12. Safety vazio não significa ausência de dano.
13. Atualidade é obrigatória.
14. Audit gate é visível em preview.
15. Produto não publishable não deve ser liberado externamente.
16. Template não calcula ciência.
17. Cor/ícone não são requisitos semânticos.
18. Markdown deve permanecer legível em texto puro.
19. Template version inicial será `oes.evidence_sheet.template/0.1`.
20. Template deverá ser validado com fixture antes de caso real.

---

# 36. Próxima etapa

Criar:

`templates/evidence-sheet.md`

Depois:

1. criar render de referência da fixture;
2. executar validação estrutural do Markdown;
3. confirmar equivalência com EvidenceSheetView;
4. criar checkpoint;
5. selecionar caso real para validação científica.

---

**Documento vivo. O template não substitui o contrato científico da Ficha.**
