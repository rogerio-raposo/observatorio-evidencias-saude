# 159 — Checklist auxiliar de preparação para ensaios V033-06 e V035-03

**OES | Fase 4 | CP204 | 2026-10-20 | modo médio**
**Estado:** `PRE_EXECUTION_CHECKLIST_DRAFT_ONLY`. Exclusivamente documental; não institui novo gate, autorização ou estado de reconciliação.

## 1. Base, finalidade e escopo
Consolidação do bloco A1–A3 pós-CP203. A1: limites de cobertura concorrente e preflight; A2: matriz AUT-01–AUT-08; A3: confronto com governança existente. Fontes: Documento 158/CP203, `STATE.md`, catálogo `database/f4-reconciliation-postconditions-draft.json` e fontes SQL 033b/033c/034/035. Freshness Gate CP203/main `ce069fcda3b6701f964b0f261d15bfb50f4f2d8b` identical, antes da preparação. Nenhuma operação Neon, PostgreSQL, CI, dados científicos, custos, novo epoch ou alteração do catálogo.

## 2. Limites críticos de cobertura
**V033-06:** o trigger 033c examina `max(attempt_no)`; o DDL 033b declara `UNIQUE(measurement_opportunity_uuid,attempt_no)`. A unicidade não comprova integralmente a serialização de todas as regras de append, resolução e lifecycle. Cobrir inserção × inserção, inserção × resolução, inserção × conclusão, mudança do epoch e deriva do alvo. Oráculos futuros devem registrar decisões e estado confirmado de todas as transações, com cobertura e isolamento declarados.

**V035-03:** o preflight 035 é consultivo e verifica em `p_as_of`, enquanto a cronologia 034 valida autoridade e desvios em `started_at`; a ativação efetiva tem outras guardas. `PASS` não substitui autorização nem garante imunidade a TOCTOU. Delimitar mudanças antes/depois dos instantes relevantes, procedimento que consome preflight e estados finais persistidos; nenhum controle corretivo foi escolhido.

## 3. AUT-01–AUT-08: checklist subordinado
| Controle auxiliar | Pré-requisito de preparação | Relação à governança |
|---|---|---|
| AUT-01 escopo | cenários, ações e limites definidos | autorização expressa já exigida |
| AUT-02 ambiente | sandbox descartável isolado e identificado | requisito de segregação a detalhar |
| AUT-03 baseline | manifesto, fontes, hashes e dependências reconciliados | catálogo/BRG-06; não autoriza replay |
| AUT-04 dados | fixtures sintéticas reproduzíveis | política synthetic-only |
| AUT-05 transações | isolamento, sessões e interleavings especificados | detalhamento técnico, não autorização |
| AUT-06 recuperação | rollback, descarte e ausência de efeitos residuais verificáveis | detalhamento de segurança |
| AUT-07 evidências | logs, horários, resultados, erros e estado final auditáveis | revisão e `review_evidence` existentes |
| AUT-08 governança | executor, revisor, custos e decisão expressa | controles canônicos de papéis/autorização |

A1 e A3 identificaram sobreposição substancial em AUT-01/03/04/07/08 com exigências existentes; AUT-02/05/06 necessitam detalhamento técnico. Nenhum AUT tem autonomia normativa, operacional ou poder de promover entrada do catálogo, declarar BRG-06 PASS ou conceder acesso a banco. Os rótulos `NOT_ASSESSED`, `INCOMPLETE`, `BLOCKED`, `READY_FOR_AUTHORIZATION_REVIEW` e `EXPLICITLY_AUTHORIZED` são propostas analíticas; não são estados oficiais nem podem ser preenchidos por inferência.

## 4. Critério para eventual pedido de autorização
Apenas quando a descrição técnica documentar baseline exata, sandbox, fixtures, comandos e limites, transações/isolamento, critérios de aceitação, limpeza, observabilidade e papéis é possível submeter o pedido à instância autorizadora. `READY_FOR_AUTHORIZATION_REVIEW` significa preparação, **não** permissão. Executar SQL inclusive SELECT, testar concorrência/rollback ou modificar permissões requer autorização específica e prévia. Revisão independente não pode ser substituída por autoatestação.

## 5. Restrições
36 migrações `UNREVIEWED`; 0 pós-condições aprovadas; 36 requisitos 034–036 `NOT_COLLECTED`; 12 controles de papéis pendentes. BRG-03/06/07/08 `BLOCKED`, BRG-04/05 apenas históricos/sintéticos, BRG-09 parcial; B1R1 `EXPIRED_NOT_EXECUTED`; M3 bloqueado; Fase 4 `NOT_READY`; Fase 5 `NOT_STARTED`. Autoridade `PREPARE_G1_DOCUMENTARY_ONLY`.

## 6. Próxima atividade
Sob novo `Prossiga`, iniciar A1 do próximo bloco: especificar, ainda documentalmente, um pacote mínimo de evidências reproduzíveis para os dois cenários, priorizando isolamento/limpeza e evitando selecionar mecanismos corretivos ou executar testes. Modo médio; recomendar modo alto antes de decisão técnica material.
**STOP.**
