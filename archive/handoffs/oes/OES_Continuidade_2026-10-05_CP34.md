# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-05  
**Checkpoint:** CP34  
**Checkpoint anterior:** CP33  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação, arquitetura, contrato e validação técnica da Síntese Rápida N3  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP34

> **Síntese Rápida de Evidências — N3: especificação + arquitetura + contrato de dados + gate de controles humanos = PASS técnico**

> **RS-T01–T15: PASS**

> **Migration 014: structural migration validada; dupla aplicação detectada**

> **Próximo estágio: contrato de renderização da Síntese Rápida N3**

Base técnica validada:

`main @ 44d50afa11d385ef26f56f860676859fb40d4f3c`

Run final:

- GitHub Actions **37384225722**;
- conclusion **success**;
- artifact **11375884187**;
- digest `sha256:1d880f2490142ba5fb4c0a815741a7aee01f74bb06b0b969fb352d6883443e78`.

## 2. Documentação consolidada desde CP33

- Documento 99 — especificação científica e funcional N3;
- Documento 100 — revisão de coerência e decisão arquitetural;
- Documento 101 — contrato de dados N3;
- Documento 102 — resultado da validação técnica: PASS.

## 3. Decisões científicas/metodológicas consolidadas

- N3 é síntese formal rápida orientada a decisão;
- não é N1/N2 expandido;
- protocolo obrigatório;
- restrições rápidas são pré-especificadas, justificadas e divulgadas;
- busca é sistemática/reproduzível;
- appraisal é obrigatório;
- Synthesis é esperada;
- certainty/confidence formal é exigida para unidades críticas quando framework aplicável;
- meta-análise não é obrigatória, mas padrões estatísticos não são relaxados;
- Summary of Findings é esperado quando apropriado;
- N3 formal exige A3;
- A3 não substitui controles qualificados de etapa.

## 4. Arquitetura consolidada

O núcleo científico OES-P1 foi reutilizado:

- Question/Investigation;
- protocol artifact;
- Search/SearchHit;
- ScreeningDecision;
- Study/Report;
- Result/ResultSource;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- Product;
- assurance/provenance/artifacts.

Novas estruturas transversais:

- `investigation.method_decision`;
- `investigation.quality_control_record`.

Não foram criadas entidades científicas Rapid* paralelas.

## 5. Regra dos controles humanos

Quality controls formais N3 distinguem:

- IA;
- human reviewer;
- human expert.

Para satisfazer qualified control:

- ator humano;
- qualification_payload;
- independência real;
- decision passed.

IA pode executar/verificar preliminarmente, mas:

> **não satisfaz segundo revisor humano qualificado.**

## 6. Gate N3

Gate exige simultaneamente:

- núcleo científico válido;
- rapid restrictions registradas;
- desvios resolvidos;
- search strategy verification qualificada;
- screening pilot qualificado;
- screening secondary verification qualificada;
- critical-data verification qualificada;
- RoB verification qualificada;
- certainty verification qualificada;
- statistical review quando exigida;
- AI methodological verification;
- owner approval;
- expert independent review;
- assurance A3;
- publication date.

## 7. Fixture experimental

Fixture persistente:

`OES-P-2026-001101`

Estado:

- N3;
- científico estruturalmente completo;
- A2 sintético;
- quality controls por IA;
- sem expert independent review;
- sem qualified human controls;
- publishable=false.

Esse é o comportamento correto na configuração atual do OES.

## 8. Prova do caminho formal

RS-T11:

- adiciona controles humanos qualificados em transação;
- adiciona expert independent review;
- assurance deriva A3;
- missing_controls fica vazio;
- gate abre;
- transação é revertida.

Conclusão:

> **A arquitetura suporta N3 formal, mas não finge que o OES atual já possui revisores qualificados.**

## 9. Histórico de validação

Primeiro run:

- 37384118734 = failure;
- três UUIDs malformados na fixture;
- migration 014 instalada corretamente.

Correção:

- varredura integral de UUIDs;
- três links corrigidos;
- nenhuma regra metodológica alterada.

Run final:

- 37384225722 = success.

## 10. Validações

- RS-T01–T15 PASS;
- RapidEvidenceSynthesisView PASS;
- N3 qualified-human-control gate PASS;
- F3-RS-T16 duplicate migration detection PASS;
- rebuild through migration 014 PASS;
- regressões N0/N1/N2/F2-B/S4/S5 PASS.

## 11. Limite operacional

Na configuração atual:

- N3 pode ser especificado/implementado/testado;
- casos podem existir como experimental/draft;
- publicação formal permanece proibida sem qualified human controls reais + A3.

Bloqueio de publicação é comportamento esperado e validado.

## 12. Ponto exato de retomada

> **Fase 3 — formalizar o contrato de renderização da Síntese Rápida de Evidências — N3.**

Ordem:

1. definir estrutura de apresentação;
2. separar limitações da evidência de limitações do método rápido;
3. apresentar restrictions/deviations;
4. apresentar quality controls e missing controls;
5. apresentar Synthesis/Certainty;
6. apresentar assurance A0–A3;
7. garantir preview experimental quando publishable=false;
8. somente depois criar template operacional.

**Fim do CP34**