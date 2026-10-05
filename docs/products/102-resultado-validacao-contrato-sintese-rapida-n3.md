# 102 — Resultado da Validação do Contrato da Síntese Rápida — N3

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Síntese Rápida de Evidências — N3  
**Data:** 5 de outubro de 2026  
**Status:** validação técnica concluída — **PASS**  
**Dependências:** Documentos 99–101; migration 014

---

# 1. Objetivo

Registrar a validação técnica do contrato N3 e, em particular, provar que:

1. o núcleo científico pode estar estruturalmente completo;
2. controles por IA podem ser registrados de forma transparente;
3. A2 não é suficiente para publicação formal N3;
4. ausência de controles humanos qualificados mantém o gate fechado;
5. o gate abre somente quando controles humanos qualificados e A3 coexistem.

# 2. Implementação validada

Migration:

`database/014_rapid_evidence_synthesis_contract.sql`

Fixture:

`database/f3-rapid-evidence-synthesis-fixtures.sql`

Testes:

`database/f3-rapid-evidence-synthesis-tests.sql`

Rebuild:

`database/f3-rapid-evidence-synthesis-rebuild-check.sql`

View:

`oes.rapid_evidence_synthesis_view/0.1`

# 3. Estruturas transversais validadas

## 3.1 `investigation.method_decision`

Representa:

- rapid restrictions;
- protocol deviations;
- method changes;
- rerouting triggers.

Histórico:

> **append-preserving**

## 3.2 `investigation.quality_control_record`

Representa:

- verificação da estratégia de busca;
- screening pilot;
- secondary screening verification;
- critical-data verification;
- risk-of-bias verification;
- statistical review quando aplicável;
- certainty verification.

IA pode ser registrada como executora de controle, mas não satisfaz `qualified human control`.

# 4. Fixture experimental

Product:

`OES-P-2026-001101`

Estado sintético:

- product_type `rapid_evidence_synthesis`;
- depth `N3`;
- protocolo presente;
- duas fontes de busca;
- seleção rastreável;
- dois estudos/reports;
- dois Results;
- dois RoB 2 assessments;
- uma Synthesis narrativa;
- uma CertaintyAssessment GRADE moderada;
- rapid restrictions explícitas;
- quality controls por IA;
- AI methodological verification = passed;
- owner governance approval = approved;
- assurance = **A2**;
- expert independent review = ausente;
- qualified human controls = ausentes;
- publishable = **false**.

Essa condição é deliberada e representa o estado experimental permitido na configuração atual do OES.

# 5. Testes RS-T01–T15

Resultados principais:

- RS-T01 — A2 sem controles humanos/A3 permanece não publicável;
- RS-T02 — núcleo científico completo;
- RS-T03 — lacunas de controles humanos identificadas individualmente;
- RS-T04 — expert review e A3 obrigatórios;
- RS-T05 — IA não é tratada como verificador humano qualificado;
- RS-T06 — RapidEvidenceSynthesisView projeta protocolo/busca/seleção/referências;
- RS-T07 — rapid restrictions explícitas;
- RS-T08 — MethodDecision append-preserving;
- RS-T09 — QualityControl append-preserving;
- RS-T10 — open protocol deviation bloqueia;
- RS-T11 — gate abre somente após controles humanos qualificados + A3;
- RS-T12 — quality-control revise ativo bloqueia;
- RS-T13 — referências/Synthesis/Certainty projetadas;
- RS-T14 — dependência invalidada bloqueia;
- RS-T15 — rebuild preserva estado A2 completo, porém bloqueado.

# 6. Prova de governança — RS-T11

O teste RS-T11 adiciona, apenas dentro de transação revertida:

- search strategy peer review humano qualificado;
- screening pilot humano qualificado;
- screening secondary verification humano qualificado;
- critical-data verification humana qualificada;
- risk-of-bias verification humana qualificada;
- certainty verification humana qualificada;
- expert independent review aprovado.

Com esses controles:

- assurance deriva **A3**;
- `missing_controls=[]`;
- publication gate abre.

A transação é revertida após o teste.

Portanto:

> **o fixture persistente continua A2/não publicável; o teste apenas demonstra que o caminho formal A3 é tecnicamente representável.**

# 7. Primeira execução e correção

Run inicial:

- **37384118734**;
- resultado: failure;
- causa: três UUIDs malformados em links da fixture sintética.

Diagnóstico:

- migration 014 havia instalado corretamente;
- N0/N1 regressions haviam passado;
- falha ocorreu no carregamento da fixture N3.

Correção:

- varredura de todos os UUIDs da fixture;
- três valores corrigidos;
- migration, tests e rebuild não continham o erro.

Não houve mudança metodológica nem relaxamento de constraint.

# 8. Execução final

GitHub Actions:

- run **37384225722**;
- conclusion **success**;
- commit validado `44d50afa11d385ef26f56f860676859fb40d4f3c`.

Artifact:

- ID **11375884187**;
- nome `oes-s5-evidence-37384225722`;
- digest `sha256:1d880f2490142ba5fb4c0a815741a7aee01f74bb06b0b969fb352d6883443e78`.

# 9. Outras validações

- `F3-RS-T16 PASS` — duplicate migration 014 detected;
- `RapidEvidenceSynthesisView PASS`;
- `N3 qualified-human-control gate PASS`;
- `Rebuild through migration 014 PASS`;
- regressões F2-B/S4/S5/N0/N1/N2 PASS.

# 10. Decisão

> **Contrato técnico da Síntese Rápida — N3: PASS.**

A arquitetura consegue representar:

- N3 científico;
- método rápido;
- controles por etapa;
- distinção IA versus revisor humano qualificado;
- A3 formal;
- bloqueio correto na configuração atual.

# 11. Limite operacional preservado

O PASS técnico não autoriza publicação de N3 formal pelo OES atual.

Enquanto não houver controles humanos qualificados reais e expert independent review:

> **qualquer caso N3 permanecerá experimental/draft e não publicável.**

# 12. Próxima etapa

Formalizar:

> **Contrato de Renderização da Síntese Rápida — N3**

A apresentação deverá tornar especialmente visíveis:

- rapid restrictions;
- protocol deviations;
- quality controls;
- qualified controls ausentes;
- assurance;
- bloqueio de publicação;
- distinção entre evidência científica e limitações do método rápido.

---

**Resultado final:** PASS.