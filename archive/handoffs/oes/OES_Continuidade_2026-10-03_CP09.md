# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP09  
**Checkpoint anterior:** CP08  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — validação e gate do modelo lógico  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP09

Estado formal:

> **Fase 1 — Base metodológica inicial: CONSOLIDADA COMO DOCUMENTAÇÃO VIVA**  
> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **Documento 20 — Modelo Conceitual: CONSOLIDADO COMO DOCUMENTO VIVO**  
> **Documento 21 — Modelo Lógico: REFINADO E CANDIDATO**  
> **Documento 22 — Validação Arquitetural: CONCLUÍDA — PRIMEIRA BATERIA**  
> **Documento 23 — Checagem de Integridade: CONCLUÍDA**  
> **GATE F2-A — MODELO LÓGICO CANDIDATO: APROVADO**

Base documental do checkpoint:

`main @ b8c1fcf9db958f16ec64c229ce10b34cd80c6163`

---

# 2. Artefatos consolidados desde CP08

- `docs/architecture/22-validacao-arquitetural-casos-uso.md`
- `docs/architecture/23-checagem-integridade-modelo-dados.md`
- refinamentos em `docs/architecture/21-modelo-logico-dados.md`

Também foram atualizados:

- `README.md`
- `docs/README.md`
- `docs/architecture/README.md`
- `CHANGELOG.md`

---

# 3. Resultado da validação

Foram testados 15 cenários:

- 6 PASS;
- 7 PASS WITH REFINEMENT;
- 2 FAIL estruturais detectados antes do desenho físico.

As duas falhas estruturais foram corrigidas:

1. suporte explícito a braços/nós/contrastes para network meta-analysis;
2. identidade persistente de PredictionModel entre desenvolvimento e validações.

---

# 4. Refinamentos incorporados

- ScreeningDecision com target Report/Study;
- StudyGroup;
- GroupComponent;
- SynthesisNode;
- SynthesisNodeMapping;
- SynthesisContrast;
- DiagnosticResultDetail;
- PredictionModel;
- PredictionModelIdentifier;
- PredictionModelStudyRole;
- FindingContribution;
- ReportRelation;
- InvestigationRelation;
- Product apontando para versões específicas de Synthesis/Certainty;
- Synthesis com origem explícita;
- Result com grupos e timepoint estruturados.

---

# 5. Reserva de aplicabilidade

A metodologia distingue:

- certainty;
- indirectness;
- applicability.

Por isso foi reservada:

`ApplicabilityAssessment — OES-AP`

Sem definir prematuramente:

- score;
- categorias;
- domínios;
- thresholds.

`Product.applicability_summary` será derivado e não substituirá avaliação formal quando esta existir.

---

# 6. Gate F2-A

## Autorizado

- comparar alternativas arquiteturais;
- elaborar desenho físico candidato;
- testar modelos relacionais/documentais/grafo/híbridos;
- avaliar mecanismos de versionamento e proveniência.

## Não autorizado ainda

- congelar schema final;
- selecionar stack definitiva;
- iniciar automação ampla;
- fixar regras metodológicas ainda abertas.

---

# 7. Invariantes

1. Study, Report e Result permanecem separados.
2. Result mantém proveniência.
3. valor relatado e derivado permanecem separados.
4. SearchHit não é apagado por deduplicação.
5. Synthesis possui identidade própria.
6. Certainty Assessment possui identidade própria.
7. Ficha de Evidência não substitui entidades científicas.
8. histórico de versões permanece auditável.
9. merges são reversíveis.
10. tecnologia não redefine a metodologia.

---

# 8. Ponto exato de retomada

## Alternativas arquiteturais e primeiro desenho físico candidato

Próximas tarefas:

1. comparar armazenamento relacional, documental, grafo e híbrido;
2. mapear requisitos de integridade relacional forte;
3. mapear necessidades de flexibilidade documental;
4. definir armazenamento de artefatos;
5. definir representação de versionamento e proveniência;
6. selecionar **arquitetura candidata**, não stack definitiva;
7. elaborar primeiro desenho físico candidato.

---

# 9. Regra de retomada

1. consultar o ponteiro;
2. ler este CP09;
3. executar Freshness Gate;
4. consultar STATE e Documentos 20–23;
5. apresentar Diagnóstico de Continuidade;
6. retomar nas alternativas arquiteturais e desenho físico candidato.

---

**Fim do CP09**
