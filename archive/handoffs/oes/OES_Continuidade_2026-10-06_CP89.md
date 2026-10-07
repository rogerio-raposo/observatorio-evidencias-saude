# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Início da Fase 4

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP89  
**Checkpoint anterior:** CP88  
**Status:** artefato de continuidade; não normativo  
**Escopo:** início formal da Fase 4 — Protocolo de Atualização

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_PROTOCOL_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

A Fase 3 permanece encerrada e não foi reaberta.

## 2. Freshness Gate de abertura

HEAD encontrado no início da conversa:

`1073dbd8e6b2196bdc211371bd7c453f4691ec32`

Checkpoint vigente então:

> CP88 — PHASE_3_COMPLETE / PHASE_4_NOT_STARTED

Não havia commits posteriores ao CP88.

A única divergência documental encontrada foi o cabeçalho inicial de STATE.md ainda declarar Fase 3 em desenvolvimento, embora o próprio STATE, CHANGELOG, Documento 188 e CP88 já registrassem a conclusão da Fase 3. A divergência foi classificada como não material e corrigida na transição para a Fase 4.

## 3. Documentos criados na Fase 4

### Documento 05

`docs/governance/05-protocolo-transversal-atualizacao.md`

Define a baseline conceitual para:

- manutenção M0–M3;
- gatilhos;
- update signals;
- materialidade;
- currentness;
- decisão de atualização;
- cadence;
- relógios de SLA;
- priorização;
- propagação;
- governança;
- fronteira de IA/automação.

### Documento 06

`docs/governance/06-revisao-adversarial-protocolo-atualizacao.md`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 4. Decisões arquiteturais consolidadas

1. versão científica, currentness, manutenção e estado operacional/comunicacional permanecem dimensões distintas;
2. ProductVersion recebe CurrencyState; InvestigationVersion não recebe CurrencyState artificial;
3. signal operacional é distinto de signal científico/currentness;
4. cadence vencida ou ciclo incompleto não altera currentness automaticamente;
5. atualização científica material exige versionamento history-preserving do alvo apropriado;
6. Alert não é atualização científica;
7. Monitor não é síntese;
8. propagação abre impact assessment, não reescreve dependentes;
9. M3 continua ortogonal a N0–N4;
10. M3 não reduz controles metodológicos/humanos do target;
11. automação autoritativa permanece não autorizada sem gate específico.

## 5. M3 permanece bloqueado

O blocker existente:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

não foi removido.

A existência do Documento 05 não torna M3 operacional.

Desbloqueio futuro exigirá:

- contrato físico;
- representação auditável da política;
- migration controlada;
- testes positivos e negativos;
- idempotência;
- rebuild-from-zero;
- regressões globais;
- gate explícito de readiness.

## 6. Estado técnico

Nenhuma migration, View, template, renderer ou workflow foi alterado neste bloco.

Última evidência técnica permanece:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37561515491** (#141);
- HEAD técnico validado `7d525fc978ee623f17a981b9bf42cdf18686c51e`;
- conclusion: **success**;
- artifact **11456897850**;
- digest `sha256:257b26162a577f24cede0c21befd437b1cad4dc6c5847d39ef29e2755d85e099`.

Os commits da Fase 4 até este checkpoint são exclusivamente metodológicos/documentais.

## 7. Commits da Fase 4 antes do checkpoint

- `b6570f76fba0bbfbdeb77bc6dd83cddaa68553ac` — Start Phase 4 update protocol architecture
- `16d1d43f2a8325885cab2601a22e965a63f5b1b7` — Harden Phase 4 update protocol semantics
- `1b29e772981fccdc9cc8af946b1232943b830906` — Review Phase 4 update protocol adversarially
- `9c31af46eceaaa56f3acab14cb850a6aa29ebeda` — Approve Phase 4 conceptual update baseline
- `8f66f3fdb825d3e9dbe684f7acc1a0ca9e932e81` — Align repository overview with Phase 4
- `3cbf3abc2e450b5675bed9337745d85993f356a2` — Mark Phase 4 active in project conception

## 8. Readiness atual

- Fase 3: COMPLETE;
- Fase 4: IN_PROGRESS;
- update protocol conceptual architecture: PASS_WITH_ARCHITECTURAL_DECISIONS;
- data contract: NOT_YET_SPECIFIED;
- migration de Fase 4: NOT_AUTHORIZED;
- M3 formal operacional: BLOCKED;
- thresholds quantitativos: NOT_DEFINED;
- SLAs numéricos: NOT_DEFINED;
- auto-classification: NOT_AUTHORIZED;
- auto-escalation: NOT_AUTHORIZED.

## 9. Ponto exato de retomada

> **Especificar o Contrato de Dados v0.1 do Protocolo Transversal de Atualização.**

Começar pelo modelo mínimo de:

1. maintenance policy/version;
2. update signal;
3. materiality assessment;
4. update decision.

Antes de qualquer migration:

> executar novo gate de coerência física do contrato contra OES-P1, CurrencyState, MethodDecision, provenance/dependency e os contratos de Monitor/Alert.

## 10. Disciplina de modo

O bloco conceitual de alta complexidade foi concluído neste checkpoint.

Implementação documental/mecânica pode usar modo médio.

Ao entrar na modelagem do Contrato de Dados v0.1 — decisão arquitetural difícil de reverter — recomenda-se novamente modo alto antes de fixar estruturas físicas.

**Fim do CP89**
