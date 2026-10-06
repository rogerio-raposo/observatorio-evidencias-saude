# 132 — Caso Real MAP-01: Protocolo do Mapa Exploratório sobre Ambient AI Scribes

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Mapa de Evidências  
**Caso:** MAP-01 — ambient AI scribes: mapa exploratório do corpus N3-01  
**Data:** 6 de outubro de 2026  
**Status:** protocolo pré-especificado — caso interno/experimental  
**Readiness:** autorizado pelo Documento 131 apenas na rota exploratória

---

# 1. Objetivo

Construir um Mapa de Evidências exploratório e auditável do corpus real acumulado pelo Caso N3-01 sobre ambient AI scribes e carga de documentação clínica.

O objetivo é responder:

> **Como as unidades de evidência já recuperadas pelo OES no Caso N3-01 se distribuem por papel da evidência e domínio de outcome?**

O MAP-01 não busca responder novamente à pergunta causal do N3.

---

# 2. Natureza do produto

Configuração pré-especificada:

- `product_type=evidence_map`;
- `mapping_subtype=descriptive_mapping_review`;
- `coverage_claim=structured_non_exhaustive`;
- `gap_claim_mode=apparent_only`;
- `counting_unit_policy=study`;
- finalidade = validação metodológica interna;
- publicação formal = não pretendida;
- assurance esperado após verificação = no máximo A1 nesta primeira execução, salvo decisão posterior formalmente documentada.

Não usar:

- `systematic_evidence_map`;
- `evidence_gap_map` formal;
- `systematic_comprehensive`;
- `formal_within_scope`.

---

# 3. Relação com o Caso N3-01

O MAP-01 é um **novo Product transversal**.

Ele poderá reutilizar versões concretas de entidades já persistidas no N3-01:

- StudyVersion;
- ReportVersion;
- SynthesisVersion;
- Search;
- Screening;
- provenance e artifacts aplicáveis.

Ele não deverá:

- criar ProductVersion 3 do N3-01;
- alterar a conclusão do N3;
- alterar a assurance do N3;
- transformar o N3 em revisão sistemática;
- reinterpretar o bloqueio metodológico do N3 como resolvido.

---

# 4. Corpus herdado

Fonte operacional:

> **corpus acumulado e rastreável do N3-01 até o cutoff científico de 2026-10-05, incluindo a busca corretiva executada em 2026-10-06 para esse mesmo cutoff.**

O corpus inclui:

- busca PubMed/MEDLINE;
- targeted publisher/DOI/citation discovery;
- busca corretiva ampliada;
- SearchHits materializados;
- ScreeningDecisions;
- Reports incluídos/contextuais;
- cinco StudyVersions materializados;
- quatro SynthesisVersions narrativas.

A busca corretiva não altera retroativamente o cutoff científico do corpus.

---

# 5. Limite de cobertura

A cobertura é conscientemente não exaustiva.

Limitações herdadas:

- Europe PMC não executável de forma reproduzível;
- OpenAlex direto não operacional no runtime;
- Embase/Scopus/CINAHL não pesquisados pelo OES;
- result counts completos indisponíveis;
- foco predominante em inglês/português;
- novas unidades elegíveis continuaram sendo identificadas após correções.

Logo:

> **o MAP-01 descreve o corpus recuperado; não descreve toda a literatura existente.**

---

# 6. Unidade de contagem

Unidade principal:

> `Study`

Consequências:

- `study_count` é a contagem principal;
- Reports ligados ao mesmo Study não aumentam `study_count`;
- Reports contextuais sem Study materializado poderão aparecer como MapItems contextuais e em `report_count`;
- SynthesisVersions poderão aparecer em `synthesis_count`;
- o template deverá manter as contagens por tipo visíveis.

---

# 7. Entidades candidatas a MapItem

O inventário formal será fechado no Documento seguinte, mas o protocolo autoriza três classes.

## 7.1 Study MapItems

Cinco StudyVersions já persistidos:

- Lukac et al. — randomized trial;
- Afshar et al. — stepped-wedge randomized trial;
- Chowdhury et al. — randomized crossover trial;
- Stults et al. — before/after quality-improvement study;
- Taylor et al. — prospective note-quality pilot.

## 7.2 Synthesis MapItems

Quatro SynthesisVersions existentes:

- documentation time;
- workload/work exhaustion;
- work outside work;
- note quality/safety.

## 7.3 Contextual Report MapItems

Reports incluídos/contextuais que:

- pertencem ao corpus rastreável N3-01;
- não estão representados como Study MapItem;
- têm função de contexto, secondary evidence ou implementação.

Reports explicitamente excluídos pelo screening não serão MapItems.

Duplicate reports não serão unidades independentes de mapeamento quando representarem o mesmo Study.

---

# 8. Framework v0.1 — row axis

Dimension code:

> `evidence_role`

Role:

> `row_axis`

Single-valued:

> `false`? **Não.** Cada MapItem deverá possuir uma única função principal no MAP-01.

Portanto:

> `multi_valued=false`

Categorias:

1. `comparative_randomized_study`;
2. `contextual_primary_study`;
3. `contextual_secondary_report`;
4. `synthesis`.

Definições:

### comparative_randomized_study

StudyVersion randomizada/comparativa usada no conjunto comparativo N3.

### contextual_primary_study

StudyVersion prospectiva/QI usada como contexto e não como unidade causal equivalente ao RCT.

### contextual_secondary_report

ReportVersion contextual/review/discovery sem StudyVersion selecionado como MapItem no MAP-01.

### synthesis

SynthesisVersion derivada e já persistida no N3-01.

---

# 9. Framework v0.1 — column axis

Dimension code:

> `outcome_domain`

Role:

> `column_axis`

`multi_valued=true`

`required_flag=true`

Categorias:

1. `documentation_time`;
2. `workload_work_exhaustion`;
3. `work_outside_work`;
4. `note_quality_safety`;
5. `broader_implementation_context`.

Um MapItem poderá ocupar múltiplos outcome domains quando isso estiver explicitamente sustentado pelo corpus.

---

# 10. Dimension adicional — evidence context

Dimension code:

> `evidence_context`

Role:

> `filter`

`multi_valued=true`

`required_flag=false`

Categorias iniciais candidatas:

- `ambient_vs_usual_care`;
- `head_to_head_vendor`;
- `implementation_context`;
- `secondary_review_context`;
- `quality_safety_context`.

O inventário/codebook poderá remover categorias sem uso antes da persistência da FrameworkVersion.

---

# 11. CellScope

A matriz principal será:

> `evidence_role × outcome_domain`

Antes da persistência:

- gerar o produto cartesiano das categorias ativas;
- avaliar se cada célula é `in_scope`, `not_applicable` ou `excluded_by_framework`;
- justificar exceções;
- não usar ausência de MapItem para decidir retrospectivamente o scope.

Para células `in_scope`:

> `gap_eligible=true` poderá ser usado apenas para gerar **apparent gaps**.

---

# 12. Semântica de gap

Modo:

> `apparent_only`

Interpretação obrigatória:

> **Nenhuma unidade elegível foi localizada nas fontes consultadas para esta classificação.**

Não afirmar:

- ausência universal de evidência;
- ausência de estudos na literatura global;
- necessidade automática de pesquisa;
- prioridade de financiamento.

---

# 13. Classification policy

Primeira execução:

- classificação por IA/OES;
- `actor_type=ai_system`;
- `assignment_method=ai_assisted` ou `rule_based`, conforme a regra;
- `verification_status=unverified` ou `ai_verified`, nunca humano;
- candidate assignments poderão ser preservados quando houver ambiguidade;
- final assignment poderá ser produzido por regra explícita quando a classificação for diretamente derivável de metadata/protocolo;
- julgamentos ambíguos deverão carregar rationale.

Não criar:

- `human_verified`;
- `human_consensus`;
- ReviewerAssignment humano fictício.

---

# 14. Codebook

O codebook deverá registrar para cada categoria:

- definição;
- critérios de inclusão;
- critérios de exclusão;
- exemplos;
- regra para multi-label;
- tratamento de informação insuficiente;
- tratamento de secondary/contextual evidence.

O codebook será artifact versionado antes da persistência das assignments.

---

# 15. Search e Screening

O MAP-01 não executará nova busca científica nesta versão.

Ele reutilizará a Investigation N3-01 como Investigation primária de suporte ou, se a arquitetura exigir nova Investigation para identidade operacional, deverá preservar dependency/provenance explícita para a Investigation N3.

Decisão arquitetural para persistência:

> **preferir nova InvestigationVersion do MAP-01 somente se necessária para preservar identidade de método; a busca herdada não deve ser duplicada artificialmente.**

Em qualquer caso:

- Search records existentes permanecem fonte canônica da busca;
- ScreeningDecisions existentes permanecem fonte canônica da seleção;
- o Mapa não cria Search/Screening retroativos.

---

# 16. Cutoff

Evidence cutoff:

> **2026-10-05**

A busca corretiva de 6 de outubro foi uma ação de recuperação do corpus com cutoff declarado em 5 de outubro.

O MAP-01 deve preservar esse cutoff para não sugerir uma atualização posterior da literatura.

---

# 17. Appraisal e certainty

O MAP-01 poderá apontar para appraisal/certainty existentes para contexto auditável.

Não deverá:

- gerar appraisal novo;
- recalcular GRADE;
- criar certainty global do mapa;
- classificar densidade como qualidade.

Os níveis GRADE experimentais do N3 permanecem propriedade daquele produto/metodologia.

---

# 18. Assurance

Estado inicial:

> `A0`

Após a execução do caso, uma verificação metodológica por IA poderá produzir:

- `passed` → A1;
- `revise` → permanece A0;
- `failed` → permanece bloqueado.

Não criar owner approval automaticamente.

Assim:

> **A1 é objetivo de validação possível, não resultado pré-concedido.**

---

# 19. Estado editorial

Inicial:

- `status=under_review`;
- `publication_date=NULL`;
- `publishable=false`.

Mesmo se A1 for atingido:

> o produto permanecerá interno e não publicado.

---

# 20. Conclusão permitida

A conclusão do MAP-01 poderá descrever:

- onde o corpus recuperado está concentrado;
- quais outcome domains aparecem em quais tipos de evidência;
- onde existem apparent gaps dentro do corpus;
- presença/ausência de Synthesis MapItems no corpus.

Não poderá:

- reescrever os efeitos clínicos do N3;
- inferir eficácia;
- inferir segurança equivalente;
- afirmar completude;
- transformar apparent gap em formal gap.

---

# 21. Validação adversarial prevista

Depois da persistência e renderização, verificar:

1. o produto permanece explicitamente non-exhaustive;
2. apparent gaps não são apresentados como formais;
3. Study count não é inflado por Reports;
4. supplemental Reports não são tratados como Studies;
5. Synthesis não é tratada como estudo primário;
6. AI classifications não aparecem como human verified;
7. ausência de A2/A3 não é mascarada;
8. N3-01 permanece inalterado;
9. cutoff permanece 2026-10-05;
10. nenhum excluded Report entra como MapItem;
11. MapItem inventory reconcilia com o corpus autorizado;
12. renderer não gera inferência causal nova.

---

# 22. Critério de sucesso do MAP-01

Sucesso mínimo:

- corpus e framework rastreáveis;
- counts reconciliáveis;
- apparent gaps corretamente limitados;
- renderização tecnicamente válida;
- nenhuma alteração indevida no N3-01;
- adversarial verification sem blocker material.

Assurance desejável:

> **A1 interno**, somente se a verificação metodológica passar.

---

# 23. Próxima etapa

> **Produzir o inventário formal do corpus MAP-01 e fechar a lista de MapItems elegíveis antes de criar FrameworkVersion, assignments ou Product.**

---

**Resultado:** protocolo MAP-01 pré-especificado; persistência do caso ainda não iniciada.
