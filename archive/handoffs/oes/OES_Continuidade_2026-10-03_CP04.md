# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Metodológica

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP04  
**Checkpoint anterior:** CP03  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — extração e estruturação de dados  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP04

Estado formal:

> **Fase 0 — Concepção e fundamentos: EM DESENVOLVIMENTO**  
> **Documentos 00–03: CONSOLIDADOS COMO DOCUMENTOS VIVOS**  
> **Documento 10 — Busca e Recuperação: CONSOLIDADO**  
> **Documento 11 — Elegibilidade, Triagem e Seleção: CONSOLIDADO**  
> **Documento 12 — Avaliação de Risco de Viés e Qualidade Metodológica: CONSOLIDADO**  
> **Documento 13 — Extração e Estruturação de Dados: CONSOLIDADO**  
> **Documento 14 — Síntese de Evidências: NÃO INICIADO**

Base documental do checkpoint:

`main @ 5eb2881d597a9cbf93266e01a13776930aa9f089`

---

# 2. Novos artefatos desde CP03

- `docs/methodology/13-extracao-dados.md`
- `templates/data-extraction-record.md`

Também foram atualizados:

- `README.md`
- `CHANGELOG.md`
- `docs/README.md`
- `templates/README.md`
- `references/fontes-metodologicas.md`

---

# 3. Decisões consolidadas no Documento 13

1. Study, Report e Result são entidades distintas.
2. O valor originalmente relatado e o valor derivado serão preservados separadamente.
3. Dados críticos deverão manter proveniência granular.
4. Formulário estruturado será padrão em N2–N4.
5. N3 adotará, como padrão, um extrator com verificação por segundo revisor dos dados críticos capazes de alterar resultados ou conclusões.
6. N4 adotará extração independente em duplicata para dados de desfecho que alimentem sínteses.
7. Múltiplos Reports serão vinculados e reconciliados, não tratados como estudos independentes.
8. Discrepâncias entre fontes deverão ser registradas e resolvidas por regra explícita.
9. Estados de ausência serão diferenciados: não relatado, não aplicável, não medido, resultado indisponível, incerto, solicitado e obtido por contato.
10. Transformações deverão preservar o valor de origem e registrar método, parâmetros e saída.
11. Dados extraídos de gráficos serão marcados como derivados.
12. Correções posteriores deverão preservar histórico.
13. Antes de síntese quantitativa formal N3–N4 deverá existir congelamento lógico do conjunto de dados.
14. IA poderá localizar, pré-preencher, comparar e detectar inconsistências, mas não poderá inventar valores, resolver conflitos silenciosamente nem substituir a verificação humana de dados críticos em N3–N4.
15. O futuro modelo de dados deverá suportar múltiplos Reports/Results, múltiplos tempos/análises, proveniência por campo, valores derivados, histórico e versionamento.
16. O Data Extraction Record permanece separado do Risk of Bias Record, porém ambos deverão poder se vincular ao mesmo Result.
17. Dados extraídos poderão ser reutilizados em novas investigações apenas mediante confirmação de identidade, proveniência, validade da fonte e adequação ao novo contexto.

---

# 4. Estrutura conceitual ativa

Estrutura mínima:

**Study → Report → Result**

com vínculos para:

- Population;
- Intervention/Exposure;
- Comparator;
- Outcome;
- Timepoint;
- Analysis;
- Risk of Bias Assessment;
- Source/Provenance.

Essa estrutura ainda não equivale ao modelo computacional definitivo.

---

# 5. Controle de qualidade por nível

| Nível | Regra de extração |
|---|---|
| N0 | Extração mínima e exploratória; sem dupla extração obrigatória |
| N1 | Extração focal; dados que sustentem diretamente a conclusão devem ser conferidos contra a fonte |
| N2 | Formulário estruturado e proveniência; verificação dos campos críticos quando houver estimativas quantitativas ou maior consequência decisória |
| N3 | Um extrator + verificação por segundo revisor de todos os dados críticos |
| N4 | Extração independente em duplicata para dados de desfecho que alimentem sínteses; características preferencialmente duplicadas ou verificadas |

---

# 6. Proveniência e transformações

Regra central:

> **dado original e dado derivado não podem ser confundidos.**

Para transformações materiais deverão ser preservados:

- valor de entrada;
- fórmula/método;
- parâmetros;
- software/script quando utilizado;
- valor de saída;
- responsável;
- data;
- verificação.

Campos que alimentam sínteses quantitativas deverão manter proveniência suficiente para retorno à página, tabela, figura, suplemento, registro ou outra fonte.

---

# 7. Extraction Record

Template operacional:

`templates/data-extraction-record.md`

Identificador provisório:

`OES-DE-AAAA-NNNNNN`

O identificador poderá mudar quando o modelo de dados definitivo for consolidado.

---

# 8. Política de IA

IA pode:

- localizar trechos;
- pré-preencher campos;
- identificar tabelas;
- auxiliar vinculação Study–Report;
- detectar inconsistências;
- executar ou apoiar transformações reproduzíveis;
- comparar extrações;
- gerar alertas de possível erro.

IA não pode:

- inventar valores ausentes;
- representar inferência como dado observado;
- escolher silenciosamente entre fontes conflitantes;
- ocultar transformação;
- eliminar proveniência;
- substituir verificação humana de dados críticos em N3–N4.

---

# 9. Questões ainda abertas

Permanecem para fases posteriores:

- modelo de dados computacional definitivo;
- schema final de Study/Report/Result/Outcome/Analysis;
- identificadores persistentes definitivos;
- política detalhada para armazenamento de artefatos de extração;
- escolha de ferramentas eletrônicas de extração;
- critérios estatísticos de síntese e combinabilidade;
- regras finais para imputação e análise de sensibilidade;
- integração entre resultados, risco de viés e certeza do corpo de evidências;
- política formal de versionamento dos produtos.

Esses itens não devem ser tratados como resolvidos.

---

# 10. Ponto exato de retomada

## Documento 14 — Protocolo de Síntese de Evidências

Próximos elementos a definir:

- quando realizar síntese narrativa;
- quando realizar meta-análise;
- critérios de combinabilidade;
- escolha e harmonização de medidas de efeito;
- modelo de efeito fixo/comum versus efeitos aleatórios;
- heterogeneidade clínica, metodológica e estatística;
- I², tau² e intervalos de predição quando pertinentes;
- análises de subgrupo;
- meta-regressão quando aplicável;
- análises de sensibilidade;
- múltiplos braços e dependência entre estimativas;
- dados raros e zero events;
- síntese sem meta-análise;
- integração de risco de viés;
- exploração de small-study effects / missing evidence quando cabível;
- regras específicas por classe de pergunta;
- apresentação e interpretação dos resultados.

---

# 11. Regra para retomada

Antes de continuar:

1. consultar o ponteiro operacional;
2. ler este CP04;
3. aplicar o Template Canônico em Modo Continuidade;
4. executar Freshness Gate contra `main`;
5. consultar `STATE.md` e os Documentos 12 e 13;
6. apresentar Diagnóstico de Continuidade;
7. retomar no Documento 14 somente após confirmação da base.

---

**Fim do CP04**
