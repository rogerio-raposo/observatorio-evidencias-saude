# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-05  
**Checkpoint:** CP30  
**Checkpoint anterior:** CP29  
**Status:** artefato de continuidade; não normativo  
**Escopo:** contrato de renderização e template operacional da Resposta de Evidência N1 validados  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP30

> **Resposta de Evidência N1: especificação + contrato + view + template = PASS técnico**  
> **ER-T01–T14: PASS**  
> **F3-ER-TEMPLATE: PASS**  
> **Regressões N2: PASS**  
> **Próximo estágio: Caso Real N1**

Base técnica final deste marco:

`main @ 68a3d7703c0f88f06419336936cea6007121516a`

Run de validação do template:

- GitHub Actions **37357423887**;
- conclusão **success**;
- artifact **11365292099**;
- nome `oes-s5-evidence-37357423887`.

## 2. Documentos desde CP29

- Documento 72 — `EvidenceResponseView`: contrato de renderização formalizado;
- Documento 73 — especificação do template operacional N1;
- Documento 74 — resultado da validação do template: PASS.

## 3. Implementação validada

- `templates/evidence-response.md`;
- `templates/evidence-response-presentation-map.json`;
- `scripts/render_evidence_response_reference.py`;
- `scripts/validate_evidence_response_render.py`.

A validação N1 é executada dentro do step de renderização F3 já existente por integração em:

- `scripts/validate_evidence_sheet_render.py`.

Essa escolha evita nova alteração do workflow YAML após bloqueios do conector e preserva a mesma sequência de CI.

## 4. Estado do produto N1

A Resposta de Evidência possui agora:

- função e fronteiras;
- critérios de elegibilidade/rerroteamento;
- método mínimo;
- contrato de dados;
- publication gate;
- assurance A0–A3;
- EvidenceResponseView;
- template Markdown;
- renderer;
- validator;
- fixture;
- testes;
- rebuild.

Ainda não possui validação científica ponta a ponta com conteúdo real.

## 5. Decisões que permanecem fechadas

Não reabrir sem evidência de problema:

- N1 é focal e não exaustivo;
- N1 não é Evidence Scan N0;
- N1 não é Ficha N2 reduzida;
- Synthesis não é obrigatória;
- CertaintyAssessment não é obrigatória;
- provenance direta para ReportVersion é válida;
- publication gate N1 é específico;
- assurance mínimo A2 para publicação formal/persistente N1;
- template não contém lógica científica.

## 6. Próxima etapa

> **Selecionar e executar um Caso Real N1.**

Critérios do caso:

1. pergunta focal;
2. síntese recente e adequada;
3. baixa/moderada necessidade de completude;
4. criticidade compatível;
5. nova investigação N2–N4 desproporcional;
6. possibilidade de busca estruturada seletiva;
7. fontes públicas e rastreáveis;
8. possibilidade de appraisal proporcional;
9. resposta sem recomendação normativa.

## 7. Ponto exato de retomada

1. selecionar a pergunta do Caso Real N1;
2. registrar protocolo/routing;
3. executar busca seletiva;
4. selecionar fonte(s) decisiva(s);
5. realizar appraisal proporcional;
6. construir resposta e provenance;
7. renderizar pelo template N1;
8. executar verificação metodológica;
9. somente depois solicitar owner governance approval para eventual publicação A2.

**Fim do CP30**
