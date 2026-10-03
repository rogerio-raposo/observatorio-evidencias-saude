# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP08  
**Checkpoint anterior:** CP07  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — modelo lógico de dados  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP08

Estado formal:

> **Fase 1 — Base metodológica inicial: CONSOLIDADA COMO DOCUMENTAÇÃO VIVA**  
> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **Documento 20 — Modelo Conceitual de Dados: CONSOLIDADO COMO DOCUMENTO VIVO**  
> **Documento 21 — Modelo Lógico de Dados: CONSOLIDADO COMO PRIMEIRA VERSÃO LÓGICA**

Base documental do checkpoint:

`main @ d2c863a9a89a7bd191a707e5d343d071bec51262`

---

# 2. Novos artefatos e refinamentos desde CP07

- `docs/architecture/21-modelo-logico-dados.md`
- refinamento de `docs/architecture/20-modelo-conceitual-dados.md`

Também foram atualizados:

- `docs/architecture/README.md`
- `docs/README.md`
- `README.md`
- `CHANGELOG.md`

---

# 3. Decisões lógicas consolidadas

1. IDs OES são chaves internas estáveis; identificadores externos são aliases.
2. entidades versionáveis possuem estado e relação de supersessão.
3. Question suporta hierarquia.
4. Investigation pode vincular múltiplas Questions.
5. Concept é previsto para normalização semântica.
6. Outcome é entidade reutilizável.
7. SearchHit preserva ocorrência bruta de recuperação.
8. deduplicação é auditável e reversível.
9. Study ↔ Report é N:M por StudyReportLink.
10. Study e Report possuem identificadores externos em estruturas próprias.
11. Result exige Study e proveniência.
12. transformações materiais exigem DerivationRecord.
13. ScreeningDecision suporta múltiplos revisores.
14. RiskAssessment mantém domínios separados.
15. Result N:M Synthesis é materializado por SynthesisContribution.
16. ReviewFinding suporta síntese qualitativa e CERQual.
17. CertaintyAssessment é vinculada à unidade avaliada.
18. Product agrega Investigation/Synthesis/Certainty por relações próprias.
19. Ficha de Evidência é inicialmente Product subtype, decisão reversível.
20. ProvenanceRecord é transversal.
21. merges de identidade são auditáveis e reversíveis.
22. nenhuma decisão fixa SGBD ou stack.

---

# 4. Refinamento estrutural relevante

A cardinalidade:

`Study 1:N Report`

foi refinada para:

`Study N:M Report`

por meio de:

`StudyReportLink`

Motivo:

- um Study pode possuir muitos Reports;
- um Report pode excepcionalmente documentar mais de um Study;
- a associação precisa carregar tipo, confiança, justificativa e decisão.

---

# 5. Entidades adicionais do modelo lógico

Além do núcleo conceitual, foram formalizadas:

- QuestionComponent;
- Concept;
- ConceptMapping;
- InvestigationQuestion;
- SearchHit;
- DedupCluster;
- StudyIdentifier;
- ReportIdentifier;
- StudyReportLink;
- Outcome;
- OutcomeOperationalization;
- ResultSource;
- DerivationRecord;
- ScreeningDecision;
- ExtractionRecord;
- RiskAssessmentDomain;
- SynthesisContribution;
- SynthesisStatistic;
- ReviewFinding;
- CertaintyDomainJudgement;
- CertaintyReview;
- ProductInvestigation;
- ProductSynthesis;
- ProductCertainty;
- ProvenanceRecord;
- MergeDecision.

---

# 6. Invariantes lógicos

- DOI/PMID não substituem Report ID;
- registro de ensaio não substitui Study ID;
- Result derivado não existe sem derivação rastreável;
- SearchHit não é apagado após deduplicação;
- merges não destroem IDs anteriores;
- versão superseded não é current;
- Product publicado possui data de corte;
- GRADE e CERQual apontam para unidades adequadas;
- Ficha de Evidência não substitui entidades científicas.

---

# 7. Ponto exato de retomada

## Validação arquitetural por casos de uso

Executar cenários representativos para testar:

1. ensaio com múltiplos Reports;
2. publicação com múltiplos Studies;
3. coorte com vários outcomes/timepoints;
4. revisão sistemática usada como unidade de evidência;
5. network meta-analysis;
6. diagnóstico;
7. predição;
8. síntese qualitativa + CERQual;
9. atualização de Ficha de Evidência;
10. guideline/HTA sem Study direto;
11. correção/retração;
12. mudança de certeza após nova evidência.

Objetivo:

> detectar falhas do modelo antes do desenho físico.

---

# 8. Regra de retomada

1. consultar o ponteiro;
2. ler este CP08;
3. executar Freshness Gate;
4. consultar STATE, Documentos 20–21 e metodologia relacionada;
5. apresentar Diagnóstico de Continuidade;
6. retomar na validação por casos de uso.

---

**Fim do CP08**
