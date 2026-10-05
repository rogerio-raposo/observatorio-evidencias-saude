# 89 — Resultado da Validação do Contrato do Evidence Scan — N0

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Evidence Scan — N0  
**Data:** 5 de outubro de 2026  
**Status:** validação técnica concluída — **PASS**  
**Dependências:** Documentos 86–88; migration 013

---

# 1. Objetivo

Registrar a validação técnica do contrato do **Evidence Scan — N0** sobre o baseline OES-P1, sem criação de nova tabela ou coluna.

Foram validados:

- contrato de produto N0;
- publication gate específico;
- wrappers de assurance/referências;
- EvidenceScanView;
- componentes exploratórios via provenance;
- exceção controlada de campo `insufficient`;
- idempotência;
- rebuild;
- regressões N1/N2/OES-P1.

# 2. Implementação validada

Migration: `database/013_evidence_scan_contract.sql`

Fixture: `database/f3-evidence-scan-fixtures.sql`

Testes: `database/f3-evidence-scan-tests.sql`

Rebuild: `database/f3-evidence-scan-rebuild-check.sql`

Schema lógico da projeção: `oes.evidence_scan_view/0.1`

# 3. Decisões arquiteturais confirmadas

A validação confirmou que N0 pode ser implementado sem nova estrutura física central.

Reutiliza Question, Investigation, Search/SearchHit, Report/ReportVersion, Product/ProductVersion, currency state, assurance, provenance e dependency graph.

Componentes próprios do scan são projetados a partir de provenance controlada:

- field description;
- terminology;
- volume signals;
- evidence types;
- central sources;
- maturity;
- controversies;
- gaps;
- candidate questions;
- routing recommendation.

# 4. Comportamentos validados

Os testes ES-T01–T15 confirmaram:

1. Evidence Scan formal A2 é publicável;
2. N0 não exige Synthesis;
3. N0 não exige CertaintyAssessment;
4. N0 não exige RiskAssessment formal;
5. pergunta original é preservada;
6. método é explicitamente não exaustivo;
7. maturidade e roteamento são estruturados;
8. fontes centrais permanecem rastreáveis;
9. contagens de busca são qualificadas como sinais operacionais;
10. A1 pode sustentar scan interno, mas não publicação formal persistente;
11. depth deve permanecer N0;
12. pelo menos uma Search concluída é obrigatória;
13. maturidade é obrigatória;
14. dependência invalidada bloqueia publicação;
15. campo `insufficient` pode ser sustentado por Search sem Report central;
16. a exceção `insufficient` não pode ser usada fora desse estado;
17. audit expõe A2 e ausência de expert review;
18. rebuild reproduz o EvidenceScanView.

# 5. Correção realizada durante validação

A primeira execução detectou que o teste ES-T12 tentava alterar campos materiais de provenance já existente.

A proteção do OES funcionou corretamente.

A correção foi feita sem relaxar a regra:

> **provenance é append-preserving.**

Procedimento validado:

- registro anterior → `superseded`;
- novo provenance.record;
- ligação por `supersedes_provenance_uuid`.

Após essa correção, ES-T12 e ES-T13 passaram.

# 6. Evidência de execução

GitHub Actions:

- run **37366556793**;
- attempt **2**;
- status: completed;
- conclusion: **success**;
- commit validado: `a1aa98eec809f25add578ebf15ba6b40739d54ca`.

Artifact:

- ID **11368729267**;
- nome `oes-s5-evidence-37366556793`;
- digest `sha256:f734fceca49c384cf5671b81919d2991d54b2a167b03a420b2c4f19db42f4a3c`.

# 7. Logs confirmados

- `ES-T01–T14 PASS — N0 contract validated without mandatory Synthesis/Certainty/RiskAssessment`;
- `ES-T15 PASS — rebuild produced publishable A2 N0 EvidenceScanView`;
- `Evidence Scan N0 contract PASS`;
- `EvidenceScanView PASS`;
- `F3 projection migrations reapply PASS — migrations 008/009/011/012/013 are idempotent by design`;
- `Rebuild through migration 013 PASS`.

# 8. Regressões

Permaneceram em PASS:

- F2-B;
- S4;
- S5;
- Evidence Sheet N2;
- EvidenceResponse N1;
- assurance A0–A3;
- provenance;
- templates existentes;
- casos reais N1/N2.

# 9. Decisão

> **Contrato do Evidence Scan — N0: PASS técnico.**

A migration 013 passa a integrar o baseline evolutivo da Fase 3.

# 10. Próxima etapa

Formalizar:

> **Contrato de Renderização do Evidence Scan — N0**

Antes de criar template, deverão ser definidos:

- conteúdo obrigatório de apresentação;
- ordem semântica;
- tratamento de scan interno A1 versus scan formal A2;
- representação de maturidade;
- apresentação de controvérsias/lacunas;
- apresentação de routing;
- disclosure de não exaustividade;
- comportamento sem Report central;
- audit/assurance.

Somente depois deverá ser criado o template operacional.

---

**Resultado final:** PASS.