# 130 — Resultado da Validação do Template e da Renderização do Mapa de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS — camada de apresentação validada**  
**Dependências:** Documentos 123–129; migrations 016–017  
**View:** `oes.evidence_map_view/0.1`  
**Template:** `oes.evidence_map.template/0.1`

---

# 1. Finalidade

Registrar a implementação e validação técnica da primeira camada operacional de apresentação do Mapa de Evidências.

# 2. Artefatos implementados

- `templates/evidence-map.md`;
- `templates/evidence-map-presentation-map.json`;
- `scripts/render_evidence_map_reference.py`;
- `scripts/validate_evidence_map_render.py`.

Integração:

- `.github/workflows/validate-s5.yml`.

# 3. Arquitetura de renderização

Fluxo validado:

> `EvidenceMapView → presentation map → renderer neutro → Markdown → validator`

O renderer:

- não consulta banco;
- não altera o payload;
- não recalcula cells/counts;
- não cria gap;
- não cria conclusão;
- não cria assurance;
- não cria recommendation/research priority.

# 4. Conteúdo da apresentação

O template projeta:

- synthetic fixture disclosure;
- publication gate;
- identidade;
- pergunta/objetivo;
- conclusão canônica;
- aviso epistemológico;
- mapping method;
- protocolo;
- codebook;
- FrameworkVersion;
- dimensões/categorias;
- composição do corpus;
- matriz/cells;
- gaps;
- concentrations;
- MapItems/drill-down;
- assignments;
- searches;
- selection flow;
- reviewer assignments;
- method controls;
- stakeholder engagement;
- appraisal/certainty quando projetados;
- limitações;
- references;
- lineage;
- update state;
- assurance/audit;
- publication issues;
- assurance records;
- IDs técnicos.

# 5. Semânticas de segurança validadas

A apresentação torna explícito que:

> **densidade de evidência não equivale a magnitude de efeito, certeza, qualidade ou benefício.**

Também preserva:

> **gap depende de framework, escopo, coverage, fontes e data de corte.**

Foram distinguidos visualmente:

- formal gap;
- apparent gap;
- primary-evidence gap;
- synthesis gap;
- `not_applicable`;
- `excluded_by_framework`.

Células fora de escopo não são apresentadas como gaps.

# 6. Fixture formal

O validator confirmou:

- `evidence_gap_map`;
- `systematic_comprehensive`;
- `formal_within_scope`;
- counting unit = Study;
- A3;
- publication gate aprovado;
- synthetic fixture visível;
- 3 dimensions;
- 5 categories;
- 4 MapItems;
- 4 cells;
- A×Y com Study=1, Report=1, Synthesis=1 e counted unit=1;
- A×Z como formal empty-cell gap;
- B×Z como `not_applicable` sem gap;
- B×Y como synthesis gap;
- 6 reviewer assignments;
- 3 method controls;
- protocolo e codebook;
- 2 references;
- Report B recuperado via Study–Report linkage;
- 5 lineage edges;
- conclusão e limitações projetadas.

# 7. Cenário adversarial A3 bloqueado

O validator cria uma cópia de apresentação com:

- `audit.publishable=false`;
- `audit.assurance_level=A3` preservado;
- search control marcado como não satisfeito;
- issue sintética `MISSING_SEARCH_PEER_REVIEW`.

Resultado exigido e obtido:

- banner **GATE DE PUBLICAÇÃO DO MAPA NÃO APROVADO**;
- A3 permanece visível;
- mensagem explícita de que A3 não substitui coverage/stage/classification/CellScope;
- blocker visível;
- nenhum texto de gate aprovado.

# 8. Cenário adversarial apparent gap

O validator cria cópia em memória com:

- coverage `structured_non_exhaustive`;
- gap mode `apparent_only`;
- A×Z convertido em apparent gap;
- warnings `NON_EXHAUSTIVE_MAP` e `APPARENT_GAPS_ONLY`.

Resultado exigido e obtido:

- coverage não exaustiva visível;
- gap mode aparente visível;
- rótulo **Gap aparente**;
- linguagem limitada às fontes consultadas;
- nenhuma alegação de gap formal para A×Z.

# 9. Primeiro run de template

Run **37467276979** terminou em failure exclusivamente no validator de apresentação.

Causa:

- a asserção procurava a string `Cobertura: estruturada não exaustiva`;
- o Markdown renderizado continha `**Cobertura:** estruturada não exaustiva`.

Diagnóstico:

> falha de asserção textual do validator; não falha de renderização, contrato científico, migration ou EvidenceMapView.

Correção:

- ajuste das asserções Markdown;
- nenhuma mudança científica ou de persistência.

# 10. Run final

GitHub Actions:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37467388595**;
- conclusion **success**;
- commit validado `5b3e7b30d8b0104501fb167e5ab0077fca6119d7`.

Artifact:

- ID **11415721992**;
- nome `oes-s5-evidence-37467388595`;
- tamanho **120649 bytes**;
- digest `sha256:889f31280259bf1f90439957d12652567d0a3542a465c379623d3810840b7afe`.

# 11. Pipeline final

No run final:

- migration 017 PASS;
- Evidence Map contract PASS;
- EvidenceMapView rendering-readiness PASS;
- Evidence Map template validation PASS;
- A3-blocked presentation PASS;
- apparent-gap presentation PASS;
- migration 017 idempotent reapply PASS;
- migration 016 duplicate detection PASS;
- regressões N0–N4 PASS;
- rebuild through migration 017 PASS.

# 12. Interpretação

O PASS demonstra que:

> **o Mapa de Evidências já possui uma camada de apresentação de referência que preserva a semântica do contrato científico e metodológico sem criar inferências novas no renderer.**

Também demonstra que:

> **o template consegue representar adequadamente tanto um mapa formal quanto estados bloqueados/não exaustivos sem confundir assurance, coverage e gap claim.**

# 13. Limites

O PASS permanece técnico e sintético.

Não foi validado ainda:

- Caso Real do Mapa;
- search coverage real compatível com systematic comprehensive;
- dupla classificação humana real;
- formal gap claim real;
- utilidade decisória com usuários/stakeholders reais.

# 14. Decisão

> **Camada de apresentação do Mapa de Evidências = PASS.**

Próxima etapa:

> **executar um Readiness Gate pré-Caso Real do Mapa, distinguindo explicitamente uma rota exploratória/non-exhaustive de uma rota formal systematic map/EGM.**

---

**Resultado final:** especificação, contrato de dados, EvidenceMapView, projection readiness e template/renderização do Mapa de Evidências tecnicamente validados.
