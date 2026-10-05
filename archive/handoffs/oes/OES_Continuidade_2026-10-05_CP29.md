# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-05  
**Checkpoint:** CP29  
**Checkpoint anterior:** CP28  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação, contrato e validação técnica inicial da Resposta de Evidência N1  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP29

> **Resposta de Evidência — N1: contrato científico/funcional consolidado**  
> **Contrato de dados: consolidado**  
> **Migration 012: PASS**  
> **EvidenceResponseView candidata: PASS técnico**  
> **ER-T01–T14: PASS**  
> **Regressão N2: PASS**

Base técnica validada:

`main @ a8f9042e41177b670c15c7f0782465e2b6c73bb4`

GitHub Actions:

- run **37356428107**;
- conclusão **success**;
- artifact **11364184531**;
- nome `oes-s5-evidence-37356428107`.

## 2. Documentos consolidados

### Documento 68

`docs/products/68-especificacao-resposta-evidencia.md`

Define função, fronteiras e contrato científico/funcional da Resposta de Evidência N1.

### Documento 69

`docs/products/69-resposta-evidencia-revisao-coerencia-arquitetura.md`

Decide reutilização ampla de OES-P1, especialização mínima e ausência de migration prematura.

### Documento 70

`docs/products/70-contrato-dados-resposta-evidencia.md`

Conclui que a v0.1 não exige nova tabela ou coluna e formaliza os invariantes do publication gate e a projeção candidata.

### Documento 71

`docs/products/71-resultado-validacao-contrato-resposta-evidencia.md`

Registra o PASS técnico do contrato N1.

## 3. Decisões arquiteturais materializadas

- Resposta de Evidência é Product subtype do OES-P1;
- primary Investigation = N1;
- busca é estruturada e seletiva, sem alegação de exaustividade;
- Synthesis é opcional;
- CertaintyAssessment é opcional;
- RiskAssessment formal é proporcional;
- provenance direta ProductVersion → ReportVersion é válida para fontes decisivas;
- resultados-chave podem ser projetados de provenance direta quando não houver Synthesis OES;
- publication gate N1 é específico;
- EvidenceSheetView não é reutilizada como contrato N1;
- assurance A0–A3 passou a possuir função derivada genérica, preservando wrapper da Ficha;
- nenhuma tabela ou coluna nova foi necessária na migration 012.

## 4. Implementação

Migration:

`database/012_evidence_response_contract.sql`

Fixture:

`database/f3-evidence-response-fixtures.sql`

Testes:

`database/f3-evidence-response-tests.sql`

Rebuild:

`database/f3-evidence-response-rebuild-check.sql`

A fixture prova explicitamente um caso N1 sem Synthesis link e sem Certainty link obrigatórios.

## 5. Validação

PASS confirmado para:

- ER-T01–T13;
- ER-T14 rebuild;
- F2-B regression;
- S4 regression;
- S5 runtime;
- Evidence Sheet contract;
- EvidenceSheetView;
- provenance;
- assurance;
- template da Ficha;
- Caso Real 01;
- rebuild through migration 012.

## 6. Itens que não são reabertos sem motivo

Não reabrir automaticamente:

- baseline OES-P1;
- Ficha como unidade persistente central preferencial;
- modelo A0–A3;
- publicação A2 do Caso Real 01;
- separação Evidence / Recommendation;
- decisão de N1 não exigir Synthesis universal;
- decisão de N1 não exigir CertaintyAssessment universal;
- uso de provenance direta para fonte decisiva no caso mínimo validado;
- ausência de nova tabela/coluna para contrato N1 v0.1.

Mudanças materiais futuras deverão ser justificadas por caso real ou inconsistência comprovada.

## 7. Reservas ainda abertas

- formalização definitiva do contrato EvidenceResponseView;
- template operacional N1;
- apresentação/renderização N1;
- caso real N1;
- comportamento com múltiplas fontes conflitantes;
- certainty externa real reutilizada;
- ApplicabilityAssessment operacional;
- monitoramento M2/M3;
- infraestrutura de produção.

## 8. Ponto exato de retomada

> **Fase 3 — formalizar o contrato de renderização EvidenceResponseView a partir da projeção candidata já validada na migration 012.**

Ordem:

1. documentar o contrato EvidenceResponseView;
2. conferir separação entre dados canônicos e apresentação;
3. consolidar regras de fontes-chave, resultados-chave, certainty e audit;
4. somente após PASS documental/técnico criar o template operacional N1;
5. depois validar com caso real.

**Fim do CP29**
