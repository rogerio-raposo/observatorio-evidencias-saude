# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Reconciliação pós-CP91 e disciplina de interação

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP92  
**Checkpoint anterior:** CP91  
**Status:** artefato de continuidade; não normativo  
**Escopo:** reconciliação documental do CP91 + regra operacional de pausa obrigatória após checkpoints

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Nenhum novo bloco metodológico foi iniciado neste checkpoint.

## 2. Freshness Gate e reconciliação

Na retomada após interrupção, o Freshness Gate encontrou:

- HEAD em CP91;
- ponteiro já movido para CP91;
- STATE ainda apontando CP90;
- CHANGELOG sem o bloco completo de perfis/cadence/CP91;
- README principal ainda apontando perfis de risco como próximo passo.

A divergência foi tratada como inconsistência de continuidade/documentação, não como divergência científica ou técnica.

## 3. MethodDecision

Foi confirmado diretamente em:

`database/014_rapid_evidence_synthesis_contract.sql`

que:

> `investigation.method_decision` existe fisicamente desde a migration 014.

Fronteira consolidada:

- `investigation.method_decision` = decisão metodológica ligada a InvestigationVersion;
- `maintenance.update_decision` = decisão especializada do protocolo transversal de atualização/currentness.

Documentos 07–09 já contêm a correção.

A migration 027 permanece:

> **PASS**

porque não dependia da ausência de MethodDecision.

## 4. Baseline metodológica consolidada no CP91

### Perfis de risco — Documentos 16–17

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Princípios preservados:

- criticidade/volatilidade reutilizam conceitos canônicos do Routing Record;
- risco científico e capacidade operacional permanecem separados;
- score agregado aditivo rejeitado;
- taxonomia paralela R0–R3 rejeitada;
- saída recomendatória usa M0–M3;
- recomendação M3 não ativa M3;
- currentness não é saída do perfil.

### Cadence e thresholds temporais — Documentos 18–19

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Princípios preservados:

- quatro relógios distintos;
- cadence ≠ processing SLA;
- cadence ≠ policy/profile reassessment;
- cadence ≠ scientific update duration;
- schedule compliance ≠ coverage continuity;
- M1 periodic não cria Monitoring Cycle por default;
- M2 periodic usa Monitor governante;
- planned_at = instante nominal programado de início;
- overdue é estado operacional;
- overdue/gap não altera currentness automaticamente;
- M3 continua bloqueado.

## 5. Estado técnico

Último PASS técnico continua sendo o contrato físico v0.1:

- migration 027;
- F4-UP-T01–T63 = PASS;
- F4-UP-IDEM = PASS;
- rebuild-through-027 = PASS;
- S5 run **37570978847** = success;
- HEAD técnico validado `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- artifact **11460960487**;
- digest `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`.

Nenhuma migration 028 foi criada.

## 6. Regra operacional de interação após checkpoint

Foi incorporada ao template canônico de continuidade a seguinte regra:

> após a conclusão e ativação de qualquer checkpoint formal, o trabalho deve parar e somente retomar após instrução explícita do usuário, tipicamente “Prossiga”.

Além disso:

- durante blocos longos dentro de um mesmo checkpoint, fornecer atualizações intermediárias suficientes para tornar o andamento observável;
- não iniciar automaticamente o bloco seguinte ao checkpoint;
- a regra vale mesmo quando o próximo passo é inequívoco e o modo de raciocínio já está adequado.

Arquivo atualizado:

`archive/continuity/OES_Template_Abertura_Continuidade.md`

## 7. Alinhamentos documentais

Foram alinhados:

- `README.md` — passa a incluir Documentos 16–19 e aponta SLA como próximo bloco;
- `CHANGELOG.md` — registra perfis, cadence e CP91;
- `STATE.md` — deve apontar CP92 após ativação deste checkpoint;
- ponteiro de continuidade — deve apontar CP92 após ativação.

## 8. Limites preservados

Ainda não definidos/implementados:

- classes formais de SLA;
- durações universais de SLA;
- pause/stop conditions de SLA;
- breach/escalation formal de SLA;
- prioridade global;
- thresholds quantitativos de materialidade;
- scheduler;
- notification channels;
- auto-classification;
- auto-escalation;
- propagation;
- Monitor re-baselining físico;
- M3 readiness;
- migration 028.

## 9. Próximo passo exato

> **Definir a arquitetura transversal de SLA como contratos operacionais entre eventos claramente definidos.**

Relógios mínimos:

1. detecção → triagem;
2. triagem → MaterialityAssessment;
3. MaterialityAssessment → UpdateDecision;
4. UpdateDecision → início do workflow científico;
5. início → conclusão da atualização científica;
6. conclusão científica → revisão/publicação quando aplicável.

O bloco deve definir semanticamente:

- start/stop/pause;
- breach;
- escalation;
- relação com criticidade/materialidade/prioridade;
- diferença entre SLA breach e currentness;
- relação com Alert urgency;
- fronteira de automação.

Não fixar durações universais antes do gate semântico.

## 10. Disciplina de modo

O próximo bloco é arquitetural/metodológico e transversal.

> **Modo alto é apropriado para definir a arquitetura de SLA.**

## 11. Regra de parada

Este checkpoint encerra a reconciliação pós-CP91.

> **Após ativar CP92, parar e aguardar instrução explícita do usuário para prosseguir.**

**Fim do CP92**
