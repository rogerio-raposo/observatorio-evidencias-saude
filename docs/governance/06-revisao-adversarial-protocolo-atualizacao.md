# 06 — Revisão Adversarial do Protocolo Transversal de Atualização v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 6 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS**  
**Objeto:** Documento 05 pós-hardening  
**Dependências:** Documentos 00–05; 165–188; migrations 006 e 021–026

---

## 1. Finalidade

Executar revisão adversarial da arquitetura conceitual do Protocolo Transversal de Atualização antes de qualquer contrato físico, migration, threshold, SLA numérico ou automação.

O gate confronta o Documento 05 com:

- estados M0–M3;
- currentness existente;
- Monitor de Evidências;
- Alerta de Evidência;
- versionamento;
- assurance;
- provenance/dependency;
- invariantes físicos já validados.

---

## 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Não foi encontrada incompatibilidade que obrigue reabrir a Fase 3.

Foram identificadas cinco ambiguidades com potencial de produzir implementação incorreta. Todas foram incorporadas ao Documento 05 antes deste resultado final.

O protocolo está:

> **READY_FOR_DATA_CONTRACT_SPECIFICATION**

mas:

> **NOT_READY_FOR_MIGRATION**

e:

> **M3_FORMAL_OPERATIONALIZATION = STILL_BLOCKED**

---

## 3. AR-F4-01 — maintenance × currentness × editorial × assurance

**Risco adversarial:** colapsar estados independentes em uma única noção de “atualizado”.

**Verificação:**

- maintenance M0–M3 permanece regime de manutenção;
- CurrencyState permanece avaliação da atualidade de ProductVersion;
- editorial status permanece status da ProductVersion;
- EntityVersion status permanece lifecycle versionado;
- assurance A0–A3 permanece garantia metodológica.

**Resultado:** PASS.

Decisão:

> nenhuma dessas dimensões poderá ser derivada automaticamente de outra sem regra explícita.

---

## 4. AR-F4-02 — domínio de Currentness

**Risco adversarial:** aplicar product.currency_state a InvestigationVersion apenas para obter simetria de modelo.

A arquitetura existente só define CurrencyState para ProductVersion.

O Documento 05 foi endurecido para determinar:

- ProductVersion pode receber CurrencyState;
- InvestigationVersion não recebe CurrencyState fictício;
- mudanças materiais em InvestigationVersion usam versionamento da investigação;
- produto derivado é versionado separadamente se seu conteúdo científico mudar.

**Resultado:** PASS após hardening.

---

## 5. AR-F4-03 — signal operacional não é signal científico

**Risco adversarial:** cadence vencida, fonte indisponível ou ciclo incompleto gerar automaticamente under_evaluation/outdated.

Isso seria cientificamente indevido: falha operacional demonstra lacuna de vigilância, não necessariamente evidência de obsolescência.

Decisão:

- signal operacional é registrado;
- avalia-se impacto da lacuna;
- somente lacuna materialmente relevante para sustentação da atualidade pode abrir reassessment de currentness;
- idade ou atraso isolados não alteram conclusão.

**Resultado:** PASS após hardening.

---

## 6. AR-F4-04 — coerência com Monitor Cycle

A migration 021 já materializa:

- no_update_needed → current;
- evaluate_update → under_evaluation;
- update_recommended → update_recommended;
- outdated → outdated.

O Documento 05 é compatível com esse mapeamento.

Adicionalmente:

- cycle incompleto não pode sustentar no_update_needed;
- conclusão de cycle não cria ProductVersion do target;
- novo CurrencyState pode representar reavaliação temporal da mesma ProductVersion.

**Resultado:** PASS.

---

## 7. AR-F4-05 — desbloqueio de M3

**Risco adversarial:** interpretar a criação do Protocolo da Fase 4 como suficiente para tornar o blocker M3 operacional.

A migration 021 e a View do Monitor preservam explicitamente:

> M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL

Decisão arquitetural:

> Documento 05 não remove esse blocker.

M3 formal somente poderá ser desbloqueado após:

1. contrato físico específico;
2. representação auditável da política;
3. regra inequívoca de gate;
4. migration controlada;
5. testes negativos/positivos;
6. idempotência;
7. rebuild-from-zero;
8. regressões globais;
9. novo gate explícito de readiness.

Não será permitido simplesmente trocar flag ou literal false por true.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 8. AR-F4-06 — M3 não reduz método científico

M3 continua ortogonal a N0–N4.

Em especial:

- N3/N4 mantêm controles humanos qualificados existentes;
- M3 não transforma produto rápido em revisão sistemática;
- Monitor assurance não substitui assurance do target;
- atualização científica segue gates do target.

**Resultado:** PASS.

---

## 9. AR-F4-07 — versionamento por tipo de target

**Risco adversarial:** obrigar ProductVersion quando o target é InvestigationVersion.

Decisão:

- target ProductVersion materialmente alterado → nova ProductVersion;
- target InvestigationVersion materialmente alterado → nova InvestigationVersion;
- se produto derivado também mudar → versionamento próprio do produto;
- QuestionVersion muda apenas quando escopo/pergunta mudar materialmente.

**Resultado:** PASS após hardening.

---

## 10. AR-F4-08 — Alert × update × currentness

A arquitetura permanece coerente:

- informational/relevant/critical é classification comunicacional;
- routine/priority/urgent é prioridade de reassessment;
- nenhum desses estados determina CurrencyState;
- Alert não atualiza conclusão;
- Alert incorporado exige linkage rastreável;
- critical não implica outdated;
- urgent não implica SLA numérico automático.

**Resultado:** PASS.

---

## 11. AR-F4-09 — archived não pode ser colapsado

Foram identificados pelo menos três conceitos distintos:

- currency_status=archived;
- ProductVersion editorial status=archived;
- EntityVersion version_status=archived.

O Documento 05 foi endurecido para proibir equivalência implícita.

**Resultado:** PASS após hardening.

---

## 12. AR-F4-10 — propagação

O modelo proposto utiliza provenance/dependency apenas para identificar possíveis impactos.

Decisão:

> propagação abre assessment; não propaga conclusão nem currentness automaticamente.

Monitor ligado a target superseded deve passar por re-baselining/rebinding history-preserving.

Isso é coerente com monitor_target imutável por Monitor ProductVersion.

**Resultado:** PASS.

---

## 13. AR-F4-11 — cadence e SLA

O Documento 05 define gramática e relógios, mas não números.

Isso evita fixar prematuramente:

- intervalos universais;
- prazos por classificação;
- validade cronológica arbitrária;
- regras que tratem atraso como evidência científica.

Thresholds e durações devem ser objeto de bloco posterior com perfis de risco.

**Resultado:** PASS.

---

## 14. AR-F4-12 — automação

A baseline permite automação apenas para funções de apoio e candidatos.

Permanece bloqueado, sem gate específico:

- mudança autoritativa de conclusão;
- promoção de assurance;
- human verification fabricada;
- publicação automática;
- outdated por idade;
- M2→M3 automático;
- critical automático;
- propagação automática de mudança científica.

**Resultado:** PASS.

---

## 15. AR-F4-13 — necessidade de nova entidade científica

Nenhuma nova entidade científica paralela é necessária nesta etapa.

O futuro contrato deve preferir extensão aditiva da camada maintenance e reuso de:

- ProductVersion;
- InvestigationVersion;
- CurrencyState;
- Search/SearchHit;
- MethodDecision;
- provenance/dependency;
- Monitor/Alert.

**Resultado:** PASS.

---

## 16. Readiness pós-gate

| Camada | Estado |
|---|---|
| definição conceitual Fase 4 | PASS |
| separação de estados | PASS |
| gatilhos | PASS |
| currentness state machine | PASS |
| M0–M3 | PASS |
| M3 conceitual | PASS |
| M3 formal operacional | BLOCKED |
| cadence grammar | PASS |
| SLA clock grammar | PASS |
| propagação | PASS |
| governança | PASS |
| automação autoritativa | NOT_AUTHORIZED |
| contrato físico | NOT_YET_SPECIFIED |
| migration | NOT_AUTHORIZED |

---

## 17. Decisão do gate

> **PHASE_4_UPDATE_PROTOCOL_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

A Fase 4 está formalmente iniciada no plano metodológico.

Isso não significa que:

- M3 está operacional;
- thresholds existem;
- SLAs numéricos existem;
- scheduler existe;
- Alert auto-classification existe;
- auto-escalation existe;
- migration de Fase 4 está autorizada.

---

## 18. Próximo passo exato

> **Especificar o Contrato de Dados v0.1 do Protocolo Transversal de Atualização, começando pelo modelo mínimo de policy/version, update signal, materiality assessment e update decision, sem implementar migration antes de novo gate de coerência física.**
