# 128 — Resultado da Validação do Projection Readiness da EvidenceMapView

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS — Projection Readiness Gate = READY**  
**Dependências:** Documentos 123–127; migrations 016–017

---

# 1. Finalidade

Registrar o fechamento do Projection Readiness Gate definido no Documento 127 antes da criação do template operacional do Mapa de Evidências.

# 2. Migration validada

Criada:

`database/017_evidence_map_view_rendering_readiness.sql`

Natureza:

> migration aditiva e idempotente de projeção.

A migration 017:

- não altera as sete tabelas do schema `mapping`;
- não reabre a migration 016;
- não muda a semântica de cells/counts/gaps;
- preserva `schema_version = oes.evidence_map_view/0.1`;
- amplia somente os dados disponíveis ao renderer.

# 3. Extensões da EvidenceMapView

A projeção passou a incluir explicitamente:

- `identity.intended_audience`;
- currency status na identity;
- protocolo com storage key/hash/status;
- codebook com storage key/hash/status;
- reviewer assignments;
- method controls;
- metadados ampliados de searches/exports;
- selection flow ampliado;
- assignments com verifier/rationale/timestamps;
- conclusão canônica;
- references ampliadas;
- lineage;
- `audit.synthetic_fixture`;
- `audit.search_controls_satisfied`;
- `audit.classification_controls_satisfied`;
- `audit.reviewer_assignment_count`;
- `audit.expert_independent_reviewed`;
- `audit.lineage_available`;
- `audit.invalidated_dependencies`.

# 4. Referências alcançáveis por Study MapItems

Foi criada:

`product.evidence_map_reference_reports(product_version_uuid)`

A função combina:

1. Report MapItems explícitos;
2. Reports canonicamente ligados a Study MapItems por `evidence.study_report_link`;
3. Reports recuperáveis pelo helper genérico de provenance do Product.

Na versão 0.1, Study–Report linkage resolve a versão `current` do Report entity ligado e registra a origem em `source_locations`.

Essa regra é explícita e poderá ser refinada futuramente caso seja necessário congelamento histórico de ReportVersion por vínculo Study–Report.

# 5. Testes da projeção

Criados:

- `database/f3-evidence-map-view-tests.sql`;
- `database/f3-evidence-map-view-rebuild-check.sql`.

Validações:

- **EMV-T01** — schema 0.1 preservado + synthetic fixture explícita;
- **EMV-T02** — conclusão canônica projetada;
- **EMV-T03** — protocolo/codebook com metadata auditável;
- **EMV-T04** — reviewer assignments projetados;
- **EMV-T05** — method controls de search/screening/classification projetados;
- **EMV-T06** — lineage completo + audit flags;
- **EMV-T07** — Report B recuperado exclusivamente via Study–Report linkage;
- **EMV-T08** — cells/gate/assurance anteriores preservados;
- **EMV-T09** — selection flow ampliado e coerente;
- **EMV-T10** — rebuild preserva a projeção;
- **EMV-T11** — migration 017 reaplica idempotentemente sem alterar semântica.

# 6. Regressões

O pipeline integrado confirmou:

- F2-B PASS;
- S4 PASS;
- S5 PASS;
- N0 PASS;
- N1 PASS;
- N2 PASS;
- N3 PASS;
- N4 PASS;
- Evidence Map contract PASS;
- EvidenceMapView rendering-readiness PASS;
- migration 016 duplicate detection PASS;
- migration 017 idempotent reapply PASS;
- rebuild through migration 017 PASS.

# 7. GitHub Actions

Run:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37466183355**;
- conclusion **success**;
- commit validado `0cd132d215bf156dee51c1ce49e3dd2a2c2adde2`.

Artifact:

- ID **11414726018**;
- nome `oes-s5-evidence-37466183355`;
- tamanho **115164 bytes**;
- digest `sha256:44ee38666b3d502bae5936adb388cdd49660b0f763990eb23b00b2a01bd420c6`.

# 8. Interpretação

O teste demonstra que:

> **a EvidenceMapView 0.1 agora contém informação suficiente para um renderer de referência apresentar coverage, cells, gaps, controls, assurance, lineage e provenance sem consultar diretamente o banco.**

Também demonstra que:

> **a extensão da camada de apresentação não alterou o contrato científico ou os resultados derivados do Mapa.**

# 9. Projection Readiness Gate

Resultado:

> **READY**

Os requisitos bloqueantes identificados no Documento 127 foram atendidos.

# 10. Autorização

Com o Projection Readiness Gate em READY:

> **fica autorizada a especificação do Template Operacional do Mapa de Evidências.**

Ainda não fica autorizado:

- Caso Real;
- formal gap claim real;
- uso clínico da fixture;
- inferência de effectiveness a partir de densidade.

# 11. Próxima etapa

> **Criar a Especificação do Template Operacional do Mapa de Evidências.**

O template deverá consumir exclusivamente `oes.evidence_map_view/0.1` e implementar integralmente o contrato do Documento 127.

---

**Resultado final:** Projection Readiness Gate = **READY**; EvidenceMapView apta à implementação da camada de apresentação.
