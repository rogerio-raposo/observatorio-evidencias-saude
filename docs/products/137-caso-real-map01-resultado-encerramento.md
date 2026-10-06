# 137 — Caso Real MAP-01: Resultado da Validação e Encerramento Controlado

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Mapa de Evidências  
**Caso:** MAP-01 — ambient AI scribes: mapa exploratório do corpus N3-01  
**Data:** 6 de outubro de 2026  
**Status:** **CONCLUÍDO — A1 interno / não publicável**  
**Dependências:** Documentos 131–136; migrations 016–018

---

# 1. Finalidade

Registrar o resultado final da primeira execução real do Mapa de Evidências do OES.

O caso foi executado exclusivamente na rota autorizada pelo Documento 131:

> **descriptive_mapping_review + structured_non_exhaustive + apparent_only**

Nenhuma tentativa foi feita de converter o caso em systematic map/EGM formal.

---

# 2. Identidade

Product:

> `OES-P-2026-001401`

ProductVersion:

> `c8100000-0000-0000-0000-000000000020`

Question:

> `OES-Q-2026-001401`

Investigation própria do MAP-01:

> `OES-I-2026-001401`

Source corpus:

> `OES-I-2026-000701` — Investigation N3-01

Framework:

> `OES-MF-2026-001401`

---

# 3. Arquitetura real validada

O MAP-01 possui:

- Question própria;
- Investigation própria de `evidence_mapping`;
- FrameworkVersion própria;
- Product próprio;
- N3-01 ligada por `role=source_corpus`.

Não foram duplicados:

- Search;
- SearchHit;
- ScreeningDecision.

A EvidenceMapView projeta a pergunta do MAP-01 e identifica separadamente a Investigation-fonte do corpus.

---

# 4. Corpus mapeado

Inventário final:

- **5 Study MapItems**;
- **8 contextual Report MapItems**;
- **4 Synthesis MapItems**.

Total:

> **17 MapItems**

Reports 201–205 não foram duplicados como MapItems porque seus Studies canônicos já representam essas unidades.

Reports excluídos/duplicados:

- 207–210;
- 218–220;

permaneceram fora do mapa.

---

# 5. Framework

Dimensions:

1. `evidence_role`;
2. `outcome_domain`;
3. `evidence_context`.

Matrix:

> `evidence_role × outcome_domain`

CellScope:

- total = **20**;
- `in_scope` = **18**;
- `excluded_by_framework` = **1**;
- `not_applicable` = **1**.

Counting unit:

> `study`

---

# 6. Classificações

Assignments ativos:

> **67**

Todos:

- `decision_state=final`;
- `actor_type=ai_system`;
- `verification_status=unverified`;
- nenhum `human_verified`;
- nenhum `human_consensus`;
- nenhum ReviewerAssignment humano criado para MAP-01.

A verificação metodológica A1 não modificou o status epistemológico individual das assignments.

---

# 7. Gaps

Gap mode:

> `apparent_only`

Resultado:

- nenhum `empty_cell_gap` formal;
- existem apparent gaps derivados do counting unit = Study;
- células com Reports/Syntheses mas sem Study podem ter `counted_unit_count=0`;
- o renderer mantém counts por tipo para impedir interpretação equivocada.

Linguagem preservada:

> **Nenhuma unidade elegível foi localizada nas fontes consultadas para esta classificação.**

Não foi produzida alegação de ausência universal de evidência.

---

# 8. Search e screening herdados

EvidenceMapView projetou, via source corpus:

- **3 Search records**;
- **20 SearchHits materializados**;
- **34 ScreeningDecisions**.

Nenhum desses registros foi copiado para a Investigation MAP-01.

A origem permanece:

> `source_corpus`

---

# 9. Referências

Referências rastreáveis do Mapa:

> **13 Reports distintos**

Incluem:

- Reports alcançados via Study–Report linkage;
- Reports contextuais explícitos;
- provenance relevante.

A lista reconciliou sem inflar `study_count`.

---

# 10. Estado inicial A0

O caso foi persistido inicialmente:

- sem assurance record;
- `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- assurance = **A0**.

Testes:

> **MAP01-T01–T15 PASS**

Esses testes validaram:

- identidade/configuração;
- pergunta própria;
- source corpus;
- Search/Screening herdados;
- inventário;
- exclusões;
- 67 assignments;
- CellScope;
- counts;
- gaps;
- references;
- A0;
- preservação do N3-01.

---

# 11. Verificação metodológica por IA

Somente depois do PASS A0 foi executada:

> `OES_MAP01_AI_SECOND_PASS`

Foi criado:

- QualityControlRecord AI-only;
- `ai_methodological_verification=passed`.

Não foram criados:

- owner governance approval;
- expert independent review;
- ReviewerAssignment humano;
- human verification de assignments.

Resultado:

> **assurance = A1**

Testes:

> **MAP01-A1-T01–T07 PASS**

---

# 12. Estado final de assurance

Estado final:

> **A1 — verificação metodológica por IA**

O produto permanece:

- interno;
- `under_review`;
- sem publication date;
- não publicável.

Blockers formais preservados:

- `PRODUCT_NOT_PUBLISHED`;
- `MISSING_OWNER_APPROVAL`;
- `ASSURANCE_BELOW_REQUIRED_LEVEL`.

Warnings preservados:

- `NON_EXHAUSTIVE_MAP`;
- `APPARENT_GAPS_ONLY`;
- `AI_ASSISTED_CLASSIFICATION`;
- disclosure de stakeholder quando aplicável.

---

# 13. Renderização real

O template do Mapa foi ampliado de forma aditiva para mostrar:

> **Investigações-fonte do corpus**

A renderização real confirmou:

- MAP question correta;
- source corpus identificada;
- A1 visível;
- publication gate bloqueado;
- coverage não exaustiva;
- apparent gaps;
- ausência de formal-gap wording;
- limitações;
- references;
- lineage/audit;
- blockers e warnings.

Validator:

> **MAP01-RENDER-A1 PASS**

---

# 14. Preservação do N3-01

O MAP-01 não alterou:

- ProductVersion atual do N3-01;
- assurance N3;
- Search;
- Screening;
- Syntheses;
- conclusão causal do N3.

N3-01 permanece:

> **ProductVersion 2 / A0 / under_review / formalmente bloqueado**

---

# 15. Pipeline integrado

GitHub Actions:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37487017809**;
- conclusion **success**;
- commit validado `63daa96bbfab8b400c531e2315fac0729b226fd7`.

Artifact:

- ID **11423951911**;
- nome `oes-s5-evidence-37487017809`;
- tamanho **151335 bytes**;
- digest `sha256:ae81f09905853a395b0bf4ba03e5209938d1cb7e6175390531d117e49f0a46e8`.

O run confirmou:

- MAP01-T01–T15 PASS;
- MAP01-A1-T01–T07 PASS;
- MAP01-RENDER-A1 PASS;
- migrations 017–018 idempotentes;
- Evidence Map synthetic/formal regressions PASS;
- N0–N4 regressions PASS;
- rebuild through migration 018 + MAP-01 A1 PASS.

---

# 16. Interpretação metodológica

O primeiro Caso Real demonstra que o OES consegue:

1. reutilizar um corpus produzido por outro produto sem duplicar Search/Screening;
2. manter identidade própria de pergunta e método;
3. contar Study sem inflar com Reports;
4. mostrar Reports/Syntheses contextuais separadamente;
5. derivar apparent gaps sem convertê-los em formal gaps;
6. manter IA e revisão humana epistemologicamente distintas;
7. elevar um mapa interno de A0 para A1 apenas após verificação metodológica;
8. impedir que A1 ou corpus herdado produzam publicação indevida.

---

# 17. Limite da validação

O MAP-01 não valida a rota formal.

Continuam não demonstrados em caso real:

- systematic comprehensive coverage;
- search peer review humano qualificado;
- duplicate human classification;
- expert independent review;
- A3 real;
- formal gap claims;
- EGM formal.

A rota formal permanece:

> **NOT_READY**

---

# 18. Decisão de encerramento

> **MAP-01 concluído com sucesso como Mapa Exploratório A1 interno e não publicável.**

Não criar nova ProductVersion apenas para tentar aumentar assurance.

Nova versão deverá exigir mudança material, como:

- atualização real do corpus;
- nova fonte bibliográfica;
- mudança do framework/codebook;
- revisão humana real;
- mudança de finalidade/publication intent.

---

# 19. Próxima etapa da Fase 3

Com a trilha inicial do Mapa de Evidências exercitada de ponta a ponta:

> **iniciar a especificação científica e funcional do Overview de Revisões.**

O Mapa permanece disponível para evolução futura sem bloquear o restante da taxonomia de produtos.

---

**Resultado final:** primeiro Caso Real do Mapa de Evidências concluído em A1 interno, com herança de corpus, provenance, apparent-gap semantics e apresentação integralmente validados.
