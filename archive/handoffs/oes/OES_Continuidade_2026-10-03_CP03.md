# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Metodológica

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP03  
**Checkpoint anterior:** CP02  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — avaliação de risco de viés e qualidade metodológica  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP03

Estado formal:

> **Fase 0 — Concepção e fundamentos: EM DESENVOLVIMENTO**  
> **Documentos 00–03: CONSOLIDADOS COMO DOCUMENTOS VIVOS**  
> **Documento 10 — Busca e Recuperação: CONSOLIDADO**  
> **Documento 11 — Elegibilidade, Triagem e Seleção: CONSOLIDADO**  
> **Documento 12 — Avaliação de Risco de Viés e Qualidade Metodológica: CONSOLIDADO**  
> **Documento 13 — Extração e Estruturação de Dados: NÃO INICIADO**

Base documental do checkpoint:

`main @ ff42e507ce7687da70a972e824ce3233c46330f9`

---

# 2. Novos artefatos desde CP02

- `docs/methodology/12-avaliacao-risco-vies.md`
- `templates/risk-of-bias-record.md`

Também foram atualizados:

- `README.md`
- `STATE.md`
- `CHANGELOG.md`
- `docs/README.md`
- `templates/README.md`
- `references/fontes-metodologicas.md`

---

# 3. Decisões consolidadas no Documento 12

1. risco de viés, qualidade metodológica, qualidade de relato, aplicabilidade e certeza são constructos distintos;
2. o OES não utilizará score universal de qualidade;
3. a lógica original dos instrumentos será preservada;
4. a versão exata de cada ferramenta deverá ser registrada;
5. RoB 2 é padrão para ensaios randomizados;
6. ROBINS-I é candidato padrão para intervenções não randomizadas, com versionamento explícito;
7. ROBINS-E é candidato para exposições observacionais compatíveis;
8. QUADAS-3 é padrão para estudos de acurácia diagnóstica;
9. QUIPS é candidato padrão para fatores prognósticos;
10. PROBAST+AI é padrão para estudos de modelos de predição;
11. JBI é referência central para prevalência, qualitativos e outros desenhos observacionais quando apropriado;
12. ROBIS é padrão para risco de viés de revisões sistemáticas;
13. AMSTAR 2 pode complementar a avaliação metodológica de revisões, sem score numérico;
14. conflitos de interesse e financiamento são registrados separadamente;
15. ausência de relato não será convertida automaticamente em método inadequado nem em método adequado;
16. N3 adota um avaliador com verificação de todos os julgamentos por segundo avaliador;
17. N4 exige pelo menos dois avaliadores independentes;
18. IA pode localizar, extrair, organizar e sugerir, mas não produz julgamento final autônomo em N2–N4;
19. alto risco de viés não implica exclusão automática;
20. risco de viés deverá ser incorporado à síntese e interpretação;
21. risco de viés individual não será convertido mecanicamente em certeza do corpo de evidências;
22. aplicabilidade ao Brasil permanece separada da validade interna.

---

# 4. Matriz metodológica ativa

| Tipo de evidência | Instrumento padrão/candidato |
|---|---|
| Ensaio randomizado | RoB 2 |
| Intervenção não randomizada | ROBINS-I |
| Exposição observacional | ROBINS-E |
| Acurácia diagnóstica | QUADAS-3 |
| Fator prognóstico | QUIPS |
| Prognóstico global | QUIPS/PROBAST adaptado quando justificado |
| Modelo de predição | PROBAST+AI |
| Prevalência | JBI Prevalence |
| Qualitativo | JBI Qualitative |
| Quase experimental | ROBINS-I ou JBI conforme objetivo |
| Coorte/caso-controle/transversal | JBI ou ferramenta causal específica |
| Revisão sistemática | ROBIS |
| Revisão de intervenção | AMSTAR 2 complementar |
| Avaliação econômica | JBI ou ferramenta específica aprovada |

A matriz é roteadora e não substitui o manual de cada instrumento.

---

# 5. Aspectos de versionamento relevantes

- RoB 2: registrar versão/extensão exata.
- ROBINS-I: em outubro de 2026 a página oficial mantém ROBINS-I V2 como revised draft; a investigação deverá fixar explicitamente a versão utilizada.
- ROBINS-E: verificar compatibilidade do desenho com a versão vigente.
- QUADAS-3: padrão vigente para DTA; página oficial disponibiliza v1.2 em 2026.
- PROBAST+AI: padrão atual para prediction models baseados em regressão ou IA.

Não usar expressão genérica “latest version” em artefatos persistentes sem registrar versão concreta.

---

# 6. Unidade de avaliação

A avaliação poderá ocorrer no nível de:

- estudo;
- resultado;
- desfecho;
- estimativa;
- modelo;
- revisão.

Para RoB 2, preferir:

`Study ID + Outcome/Result + Estimand → Assessment`.

Foi introduzido identificador provisório:

`OES-RB-AAAA-NNNNNN`

até fechamento do modelo de dados.

---

# 7. Política de IA

IA pode:

- localizar trechos;
- comparar protocolo e publicação;
- extrair elementos para signalling questions;
- detectar inconsistências;
- sugerir julgamento preliminar;
- organizar justificativas.

IA não pode, como padrão N2–N4:

- emitir julgamento final sem supervisão humana;
- inventar informação ausente;
- transformar ausência de relato em confirmação;
- substituir adjudicação;
- gerar score universal.

---

# 8. Questões ainda abertas

Permanecem para fases posteriores:

- instrumento definitivo para avaliação de diretrizes;
- política detalhada para avaliações econômicas;
- eventual validação interna da assistência por IA para cada instrumento;
- modelo de dados final para Assessment ID;
- forma de incorporar risco de viés quantitativamente ou qualitativamente na síntese;
- método específico para missing evidence/ROB-ME;
- tradução das avaliações individuais para certeza do corpo de evidências.

Esses itens não devem ser tratados como resolvidos.

---

# 9. Ponto exato de retomada

## Documento 13 — Protocolo de Extração e Estruturação de Dados

Próximos elementos a definir:

- características do estudo;
- características dos participantes;
- intervenção/exposição/comparador;
- desfechos e timepoints;
- estimativas e medidas de efeito;
- estatísticas necessárias;
- unidade Study/Report/Result;
- proveniência de cada dado;
- dupla extração e verificação;
- extração de gráficos;
- dados ausentes;
- contato com autores;
- transformação/normalização;
- correções e versionamento;
- uso de IA;
- controle de erro;
- vínculo com Risk of Bias Record e síntese.

---

# 10. Regra para retomada

Antes de continuar:

1. consultar o ponteiro operacional;
2. ler este CP03;
3. aplicar o Template Canônico em Modo Continuidade;
4. executar Freshness Gate contra `main`;
5. consultar `STATE.md` e os Documentos 11 e 12;
6. apresentar Diagnóstico de Continuidade;
7. retomar no Documento 13 somente após confirmação da base.

---

**Fim do CP03**
