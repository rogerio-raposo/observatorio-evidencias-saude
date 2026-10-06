# 134 — Caso Real MAP-01: Codebook v0.1 do Framework de Classificação

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Mapa de Evidências  
**Caso:** MAP-01 — ambient AI scribes: mapa exploratório do corpus N3-01  
**Data:** 6 de outubro de 2026  
**Status:** codebook v0.1 pré-persistência  
**Dependências:** Documentos 132–133

---

# 1. Finalidade

Definir regras reproduzíveis para classificar os 17 MapItems autorizados do MAP-01 em:

1. `evidence_role`;
2. `outcome_domain`;
3. `evidence_context`.

O codebook é parte do FrameworkVersion.

Mudança material futura:

> exige nova FrameworkVersion.

---

# 2. Princípios

1. Classificar apenas informação sustentada por metadata/documentação já persistida.
2. Não inferir outcome apenas pelo desenho.
3. Não inferir eficácia pela presença do estudo.
4. Não usar certainty para definir categoria de outcome.
5. Não elevar Report a Study.
6. Não usar Report duplicado/excluído.
7. Permitir multi-label somente nas dimensions explicitamente multivaloradas.
8. Toda final assignment deve possuir rationale rastreável.
9. Nesta versão, classificações são produzidas por IA/OES e permanecem sem selo humano.

---

# 3. Dimension — evidence_role

Configuração:

- code = `evidence_role`;
- role = `row_axis`;
- required = true;
- multi-valued = false.

Todo MapItem ativo deverá ter exatamente uma categoria final nessa dimension.

---

# 4. Category — comparative_randomized_study

Aplicar quando:

- target type = Study;
- design persistido é randomized/randomized crossover/stepped-wedge randomized;
- o Study pertence ao conjunto comparativo do N3-01.

Inclui:

- Study 101 — Lukac;
- Study 102 — Afshar;
- Study 103 — Chowdhury.

Não inclui:

- before/after QI;
- prospective QI/pilot;
- Reports;
- Syntheses.

Assignment:

- method = `rule_based`;
- actor_type = `ai_system`;
- verification_status = `unverified`;
- rationale deve citar design persistido + papel no N3.

---

# 5. Category — contextual_primary_study

Aplicar quando:

- target type = Study;
- estudo foi incluído como contexto;
- não foi tratado como evidência causal equivalente aos RCTs.

Inclui:

- Study 104 — Stults;
- Study 105 — Taylor.

Assignment:

- `rule_based`;
- `ai_system`;
- `unverified`.

---

# 6. Category — contextual_secondary_report

Aplicar quando:

- target type = Report;
- full-text screening = include;
- não existe Study MapItem canônico escolhido para representar o mesmo conteúdo;
- uso no N3 foi contexto, secondary evidence, non-duplication, citation chasing ou implementação.

Inclui:

- Report 206;
- Reports 211–217.

Não inclui:

- Reports 201–205, pois seus Studies 101–105 são MapItems;
- 207 por duplicate_report;
- 208–210 por exclusão;
- 218–220 por exclusão.

Assignment:

- `rule_based` para role;
- `ai_system`;
- `unverified`.

---

# 7. Category — synthesis

Aplicar quando:

- target type = Synthesis;
- target é uma das quatro SynthesisVersions autorizadas.

Inclui:

- 501;
- 502;
- 503;
- 504.

Assignment:

- `rule_based`;
- `ai_system`;
- `unverified`.

---

# 8. Dimension — outcome_domain

Configuração:

- code = `outcome_domain`;
- role = `column_axis`;
- required = true;
- multi-valued = true.

Um MapItem poderá receber uma ou mais categorias.

---

# 9. Category — documentation_time

Definição:

> tempo dedicado à documentação, time-in-note, note time, EHR documentation time ou métrica diretamente equivalente.

Incluir somente quando:

- outcome explicitamente reportado/documentado;
- ou SynthesisVersion aponta para Outcome 010.

Classificações autorizadas no inventário:

- Study 101;
- Study 102;
- Study 103;
- Study 104;
- Synthesis 501.

Reports contextuais 206/211–217:

> não receber automaticamente esta categoria apenas por tratarem de documentation workflows.

Se o título/metadata não afirmar explicitamente tempo de documentação:

> não classificar.

---

# 10. Category — workload_work_exhaustion

Definição:

> workload, work exhaustion, burnout, documentation burden ou medidas diretamente relacionadas à carga percebida do clínico.

Classificações autorizadas:

- Study 101;
- Study 102;
- Study 103;
- Report 215;
- Report 216;
- Report 217;
- Synthesis 502.

Para Reports 215–217:

- classificação = `ai_assisted`;
- rationale deve citar o título/role persistido.

---

# 11. Category — work_outside_work

Definição:

> documentation work outside scheduled work, after-hours EHR ou WoW equivalente.

Classificações autorizadas:

- Study 102;
- Study 103;
- Synthesis 503.

Não inferir essa categoria de “documentation burden”.

---

# 12. Category — note_quality_safety

Definição:

> qualidade, accuracy, inaccuracies, omissions, hallucinations ou erros potencialmente danosos da nota.

Classificações autorizadas:

- Study 101;
- Study 102;
- Study 105;
- Synthesis 504.

Não classificar Report contextual como safety apenas por mencionar implementation.

---

# 13. Category — broader_implementation_context

Definição:

> implementação, aceitabilidade, adoção, workflow, experiência, contexto organizacional ou secondary review ampla que não deve ser reduzida a um outcome crítico único.

Classificações autorizadas:

- Study 104;
- Study 105;
- Report 206;
- Reports 211–217.

Essa categoria pode coexistir com outcome crítico quando ambos forem explicitamente sustentados.

Exemplos:

- Report 215 = workload_work_exhaustion + broader_implementation_context;
- Report 216 = workload_work_exhaustion + broader_implementation_context;
- Report 217 = workload_work_exhaustion + broader_implementation_context.

---

# 14. Dimension — evidence_context

Configuração:

- code = `evidence_context`;
- role = `filter`;
- required = false;
- multi-valued = true.

Não participa diretamente da matriz principal.

---

# 15. Category — ambient_vs_usual_care

Aplicar quando:

- Study/Synthesis inclui comparação com prática usual/documentação usual.

Autorizados:

- Study 101;
- Study 102;
- Syntheses 501–503.

Para Synthesis 501 e 503, manter também head-to-head quando explicitamente incorporado como contexto secundário.

---

# 16. Category — head_to_head_vendor

Aplicar quando:

- comparação é entre duas tecnologias ambient scribe.

Autorizados:

- Study 103;
- Synthesis 501;
- Synthesis 502 quando o resumo explicitamente incorpora o resultado Chowdhury;
- Synthesis 503.

Não aplicar a Synthesis 504 sem evidência explícita.

---

# 17. Category — implementation_context

Aplicar quando:

- unidade descreve implementação, before/after, experiência, aceitabilidade ou uso real sem equivalência causal aos RCTs.

Autorizados:

- Study 104;
- Reports 212–217;
- Study 105 quando usado como contexto operacional de safety/quality.

---

# 18. Category — secondary_review_context

Aplicar quando:

- Report é secondary review usado para contexto/non-duplication/citation chasing.

Autorizados:

- Report 206;
- Report 211.

---

# 19. Category — quality_safety_context

Aplicar quando:

- unidade tem função específica de avaliação de qualidade/segurança da nota.

Autorizados:

- Study 105;
- Synthesis 504.

---

# 20. Informação insuficiente

Se informação for insuficiente para outcome/context:

- não inventar classificação;
- evidence_role continua obrigatório;
- outcome_domain é obrigatório no Framework, portanto MapItem sem qualquer outcome deverá ser revisto antes da persistência;
- se a unidade for legitimamente apenas contexto amplo, usar `broader_implementation_context`;
- rationale deverá declarar a base da decisão.

---

# 21. Candidate versus final

Para MAP-01:

- assignments finais são necessárias para alimentar células;
- final não significa human verified;
- final significa apenas classificação operacional escolhida pelo codebook.

Regra:

> `decision_state=final` + `verification_status=unverified` é permitido nesta rota exploratória.

Não usar:

- `human_verified`;
- `human_consensus`.

---

# 22. Assignment method

## 22.1 rule_based

Usar quando a classificação decorre diretamente de:

- entity type;
- Study design;
- Synthesis outcome_entity_uuid;
- screening status;
- bibliographic role persistido.

## 22.2 ai_assisted

Usar quando:

- título/metadata textual precisa ser interpretado;
- multiple outcome tags exigem julgamento semântico;
- contexto não está codificado em campo discreto.

Em ambos:

> actor_type = `ai_system`.

---

# 23. Verification status

Nesta versão:

> `unverified`

Não registrar `ai_verified` apenas porque o mesmo sistema criou e revisou a classificação.

Uma verificação AI posterior poderá gerar revisão do caso, mas não deve ser confundida com independência.

---

# 24. Rationale payload mínimo

Toda final assignment deverá registrar, conforme aplicável:

- `source_document`;
- `source_field`;
- `source_entity_id`;
- `rule_code`;
- `reason`.

Rule codes:

- `ROLE_FROM_ENTITY_AND_DESIGN`;
- `ROLE_FROM_SCREENING_CONTEXT`;
- `OUTCOME_FROM_N3_COVERAGE`;
- `OUTCOME_FROM_SYNTHESIS_TARGET`;
- `OUTCOME_FROM_REPORT_METADATA`;
- `CONTEXT_FROM_COMPARATOR`;
- `CONTEXT_FROM_REPORT_ROLE`.

---

# 25. CellScope codebook

Matrix:

> `evidence_role × outcome_domain`

### comparative_randomized_study

- documentation_time = in_scope;
- workload_work_exhaustion = in_scope;
- work_outside_work = in_scope;
- note_quality_safety = in_scope;
- broader_implementation_context = excluded_by_framework.

### contextual_primary_study

Todos = in_scope.

### contextual_secondary_report

Todos = in_scope.

### synthesis

- documentation_time = in_scope;
- workload_work_exhaustion = in_scope;
- work_outside_work = in_scope;
- note_quality_safety = in_scope;
- broader_implementation_context = not_applicable.

Gap eligibility:

- in_scope = true;
- demais = false.

---

# 26. Apparent-gap interpretation

Uma célula in_scope sem unidade contada segundo o counting policy poderá ser apresentada como:

> **gap aparente no corpus recuperado.**

Como counting unit = Study:

- uma célula com apenas Reports ou Syntheses pode ter `counted_unit_count=0`;
- isso poderá produzir apparent gap de Study mesmo existindo evidência contextual/secundária.

O renderer deverá manter visíveis `report_count` e `synthesis_count` para evitar interpretação equivocada.

---

# 27. Validação antes da persistência

Verificar:

- 17 MapItems;
- 5 Studies;
- 8 Reports;
- 4 Syntheses;
- 20 CellScope;
- 18 in_scope;
- 1 excluded_by_framework;
- 1 not_applicable;
- nenhuma entidade excluída;
- nenhum Report 201–205 duplicado;
- nenhum human verification;
- todo MapItem com evidence_role;
- todo MapItem com pelo menos um outcome_domain.

---

# 28. Decisão

> **Codebook MAP-01 v0.1 fechado.**

O codebook poderá ser materializado como artifact do FrameworkVersion.

Próxima etapa:

> **persistir o MAP-01 em SQL usando o protocolo, inventário e codebook, sem criar nova busca nem alterar o N3-01.**

---

**Resultado:** regras de classificação pré-especificadas e auditáveis antes da persistência.
