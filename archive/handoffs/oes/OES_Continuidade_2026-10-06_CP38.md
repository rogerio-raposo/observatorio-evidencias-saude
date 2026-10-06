# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP38  
**Checkpoint anterior:** CP37  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento da trilha técnica inicial da Revisão de Evidências — N4, incluindo apresentação/template  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP38

> **Revisão de Evidências N4 — trilha técnica inicial fechada em PASS.**

Validado:

- especificação científica e funcional;
- arquitetura;
- contrato de dados;
- migration 015;
- ReviewerAssignment;
- publication gate;
- EvidenceReviewView;
- fixture formal sintética A3;
- testes adversariais ER4;
- rebuild;
- contrato de renderização;
- template Markdown;
- presentation map;
- renderer;
- validator positivo e adversarial.

Próximo estágio:

> **Caso Real N4 experimental — executar somente o Infrastructure Readiness Gate.**

Não iniciar protocolo/busca/seleção real antes do resultado de readiness.

## 2. Documentos N4 consolidados

- 115 — Especificação Científica e Funcional;
- 116 — Revisão de Coerência e Arquitetura;
- 117 — Contrato de Dados;
- 118 — Resultado da Validação Técnica do Contrato;
- 119 — Contrato de Renderização;
- 120 — Especificação do Template Operacional;
- 121 — Resultado da Validação do Template e Renderização.

## 3. Contrato técnico N4

Schema da view:

`oes.evidence_review_view/0.1`

Product type:

`evidence_review`

Nova estrutura DDL:

`investigation.reviewer_assignment`

ROB-ME em nível de síntese habilitado por extensão controlada de:

`appraisal.assert_risk_target_type()`

para aceitar `Synthesis`.

## 4. Fixture formal sintética

A fixture demonstra exclusivamente a capacidade arquitetural de representar um estado formal ideal:

- readiness ready;
- 3 bases bibliográficas;
- peer review de busca;
- dupla seleção;
- dupla extração;
- dupla appraisal;
- meta-analysis reprodutível;
- statistical review;
- ROB-ME;
- dupla GRADE;
- SoF;
- AI verification;
- owner approval;
- expert independent review;
- A3;
- gate aberto.

Todos os atores humanos da fixture são sintéticos/fictícios.

## 5. Validação de contrato

Run:

- **37417796591**;
- conclusion `success`;
- commit `a255bf2a33b1cfba1214c7d9daaca234a7f6987e`;
- artifact **11391167525**;
- digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

Resultados:

- ER4-T01–T25 PASS;
- ER4-T26 rebuild PASS;
- ER4-T27 duplicate migration detection PASS;
- Rebuild through migration 015 PASS.

## 6. Validação de apresentação

Run:

- **37418624629**;
- conclusion `success`;
- commit `4bd35271e94dfb05bf572fe76b49fa5c5af47bac`;
- artifact **11391724857**;
- digest `sha256:a2d0c3dc12758a14fc13a2ac4ca50a3868ac9ceeac615ec34c6b417ee37b44ba`.

Resultados:

- F3-ER4-TEMPLATE validation PASS;
- F3-ER4-TEMPLATE PASS;
- ER4-T01–T27 PASS;
- rebuild PASS;
- regressões N0–N3/F2-B/S4/S5 PASS.

## 7. Invariante visual validada

O template prova que:

> **A3 não equivale automaticamente a publication approval.**

No cenário adversarial em memória:

- assurance permanece A3;
- `publishable=false`;
- publication issue ativa;
- banner mostra `GATE DE PUBLICAÇÃO N4 NÃO APROVADO`;
- A3 permanece visível;
- stage controls ausentes permanecem blockers.

## 8. Disclosure sintético

`audit.synthetic_fixture=true` é projetado pela EvidenceReviewView.

O template exige:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA REVISÃO HUMANA REAL**

Isso impede interpretação do A3 sintético como validação humana real.

## 9. Estado real do projeto

Na configuração humana atual:

- existe apenas o proprietário do sistema;
- não há dois revisores humanos qualificados;
- não há search peer reviewer qualificado configurado;
- não há expert independent reviewer real;
- não há garantia de cobertura bibliográfica N4 suficiente.

Consequência:

> **nenhum Caso Real N4 formal está autorizado.**

## 10. Infrastructure Readiness Gate — próxima etapa obrigatória

Antes de qualquer Caso Real N4, avaliar explicitamente:

- bibliographic coverage;
- reviewer availability;
- search expertise;
- appraisal expertise;
- certainty expertise;
- statistical expertise quando aplicável;
- software/compute;
- artifact/versioning;
- A3 pathway;
- conflicts/governance.

Estados possíveis:

- `ready`;
- `ready_with_documented_conditions`;
- `not_ready`.

Na configuração conhecida, o resultado esperado é:

> **not_ready**

a menos que recursos humanos/infrastruturais adicionais estejam efetivamente disponíveis.

## 11. Regra de não contorno

Se readiness for `not_ready`:

- não iniciar busca definitiva N4;
- não reduzir silenciosamente os requisitos;
- não fabricar reviewer assignments;
- não usar IA como segundo reviewer humano;
- não converter o caso em N4 formal;
- registrar o bloqueio e decidir rerroteamento/deferimento.

## 12. Estado da Fase 3

Produtos exercitados:

1. N0 — caso real A1 interno;
2. N1 — caso real A2/published;
3. N2 — caso real A2/published;
4. N3 — contrato/template validados; caso real A0 corretamente bloqueado;
5. N4 — especificação, contrato, gate, view e template tecnicamente validados; caso real formal ainda não iniciado.

Produtos transversais/manutenção ainda pendentes:

- Mapa de Evidências;
- Overview de Revisões;
- Monitor;
- Alerta.

## 13. Ponto exato de retomada

> **Fase 3 — Caso Real N4 experimental: executar exclusivamente o Infrastructure Readiness Gate.**

Se `not_ready`, registrar a decisão e considerar seguir para o próximo produto da taxonomia em vez de iniciar uma revisão metodologicamente incompleta.

**Fim do CP38**