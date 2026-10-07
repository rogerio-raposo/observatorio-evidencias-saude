# 17 — Revisão Adversarial dos Perfis de Risco para Atualização

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS**  
**Objeto:** Documento 16 pós-hardening  
**Dependências:** Documentos 02–09 e 16; migration 027

---

## 1. Finalidade

Executar revisão adversarial da arquitetura de perfis de risco operacional/científico antes de:

- fixar cadence;
- definir thresholds;
- definir classes/durações de SLA;
- criar regras de prioridade;
- persistir qualquer estrutura física nova.

---

## 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

O Documento 16 está:

> **READY_TO_PARAMETERIZE_CADENCE_THRESHOLDS_SLA_PRIORITY**

mas:

> **NOT_READY_FOR_NEW_MIGRATION**

Nenhum número universal foi validado neste gate.

---

## 3. AR-F4-R01 — duplicação do Routing Record

### Risco

Criar “criticidade”, “volatilidade” e “incerteza” paralelas às dimensões já definidas no Documento 03.

### Decisão

O perfil de atualização reutiliza os conceitos canônicos do Routing Record.

É permitido reavaliá-los longitudinalmente porque:

- finalidade de uso pode mudar;
- base de evidências evolui;
- volatilidade muda;
- sensibilidade de conclusão muda.

A nova avaliação:

- não reescreve Routing Record histórico;
- deve declarar divergência e rationale.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 4. AR-F4-R02 — risco científico × capacidade

### Risco

Transformar baixa capacidade operacional em “baixo risco”.

### Decisão

Famílias permanecem separadas:

- A1–A5 = risco/necessidade científica-decisória;
- B1–B5 = observabilidade, carga, custo e viabilidade operacional.

Regra:

> **capacidade nunca compensa criticidade.**

Se necessidade é alta e capacidade é insuficiente:

> registrar high need / insufficient capacity.

Isso pode bloquear M3, exigir escalonamento ou redução de escopo, mas não reduz risco.

**Resultado:** PASS.

---

## 5. AR-F4-R03 — score aditivo

### Risco

Somar níveis qualitativos e produzir falsa precisão.

### Decisão

Nenhum score agregado é autorizado.

Razões:

- safety/integrity tem dominância;
- dimensões têm semânticas diferentes;
- dependency reach não é materiality;
- capacidade não é risco;
- pesos não foram validados.

**Resultado:** PASS.

---

## 6. AR-F4-R04 — segunda taxonomia R0–R3

### Risco

Criar estados de vigilância paralelos e concorrentes com M0–M3.

### Decisão

R0–R3 foi removido.

A saída do perfil utiliza somente:

- recommended maintenance level no domínio canônico M0–M3;
- recommended cadence mode no domínio já usado pela UpdatePolicy;
- feasibility;
- rationale/implicações.

**Resultado:** PASS após hardening.

---

## 7. AR-F4-R05 — M3 recomendado × M3 operacional

### Risco

Uma recomendação de perfil ativar living evidence.

### Decisão

`recommended_maintenance_level='M3'` é apenas recomendação.

M3 operacional continua exigindo:

- UpdatePolicy autoritativa;
- Monitor compatível;
- capacidade;
- futuro M3 readiness gate;
- remoção explícita e validada do blocker.

O blocker atual permanece:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

**Resultado:** PASS.

---

## 8. AR-F4-R06 — safety/integrity no perfil × signal ativo

### Risco

Duplicar safety signal/retraction/regulatory change dentro de um perfil estático.

### Decisão

A4 representa:

> exposição estrutural a consequências de segurança/integridade.

Eventos efetivos continuam em:

> `maintenance.update_signal`

e seguem:

> signal → materiality → decision.

Um Alert critical não redefine automaticamente A4.

**Resultado:** PASS após hardening.

---

## 9. AR-F4-R07 — dominância de safety/integrity

A4 alta justifica:

- forte vigilância event-driven;
- resposta prioritária quando signal correspondente surgir;
- baixa tolerância operacional a atraso.

Não justifica automaticamente:

- outdated;
- update_recommended;
- mudança de conclusão;
- M3.

**Resultado:** PASS.

---

## 10. AR-F4-R08 — criticidade alta + volatilidade baixa

### Teste adversarial

Uma área pode produzir pouca evidência nova, mas um evento raro pode ter alto impacto.

O modelo deve permitir:

- baixa frequência periódica;
- forte event-driven surveillance;
- alta prioridade para safety/regulatory signal.

Documento 16 permite essa combinação.

**Resultado:** PASS.

---

## 11. AR-F4-R09 — volatilidade alta isolada

Alta taxa de publicação não é razão suficiente para M3.

O modelo preserva:

- criticidade;
- sensibilidade;
- capacidade;
- observabilidade;
- custo.

Alta volatilidade pode justificar M2 sem M3.

**Resultado:** PASS.

---

## 12. AR-F4-R10 — sensibilidade × currentness

Sensibilidade alta significa maior probabilidade de nova evidência alterar conclusão/certeza.

Não significa:

- under_evaluation;
- update_recommended;
- outdated.

Currentness só muda por UpdateSignal + MaterialityAssessment + UpdateDecision autoritativa conforme contrato 027.

**Resultado:** PASS.

---

## 13. AR-F4-R11 — dependency reach

A5 mede alcance downstream.

A5 amplo/sistêmico:

- aumenta necessidade de impact assessment;
- pode elevar prioridade operacional;
- não transforma signal em material;
- não propaga mudança automaticamente.

**Resultado:** PASS.

---

## 14. AR-F4-R12 — observabilidade e latência

### Risco

Cadence interna mais curta que a capacidade real da fonte produzir falsa impressão de vigilância.

### Decisão

Cadence futura deverá considerar:

- source observability;
- source latency;
- redundância de fontes;
- event-driven channels.

Uma fonte mensalmente indexada não se torna “mais living” porque o scheduler roda diariamente.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 15. AR-F4-R13 — carga/custo

B3/B4 podem afetar viabilidade, planejamento e SLA.

Não podem:

- reduzir materiality;
- manter current artificialmente;
- justificar silêncio sobre lacuna.

**Resultado:** PASS.

---

## 16. AR-F4-R14 — capacidade temporal

### Risco

Tratar capacidade como atributo imutável da ProductVersion.

### Decisão

B5 é assessment com período de vigência.

Podem existir múltiplos perfis para o mesmo target versionado ao longo do tempo.

Mudança de capacidade:

- não exige nova ProductVersion;
- exige novo profile assessment quando material à policy.

**Resultado:** PASS após hardening.

---

## 17. AR-F4-R15 — profile target/versioning

Cada profile assessment deverá apontar para versão concreta do target.

Nova versão científica exige:

- novo profile assessment; ou
- carry-forward explícito e justificado.

Carry-forward silencioso é proibido.

**Resultado:** PASS.

---

## 18. AR-F4-R16 — output do perfil × UpdatePolicy

O perfil recomenda.

A UpdatePolicy decide/autoriza o regime operacional.

Portanto:

> profile assessment não atualiza `maintenance.update_policy` automaticamente.

Uma mudança de M efetivo requer nova UpdatePolicy/supersessão conforme migration 027.

**Resultado:** PASS.

---

## 19. AR-F4-R17 — prioridade prematura

### Risco

Definir agora classes de prioridade e, depois, forçar SLA a caber nessas classes.

### Decisão

Documento 16 registra apenas:

> `priority_implications`

sem taxonomia fechada.

Prioridade será definida no bloco próprio depois de cadence/threshold/SLA semantics.

**Resultado:** PASS após hardening.

---

## 20. AR-F4-R18 — thresholds

O perfil não define um threshold único.

Foram preservadas classes conceituais distintas:

- detecção;
- materialidade;
- currentness;
- escalonamento;
- temporal.

Isso é coerente com migration 027, que já separa signal, assessment e decision.

**Resultado:** PASS.

---

## 21. AR-F4-R19 — SLA

SLA é obrigação operacional.

Nunca poderá ser usado como atalho para:

- outdated;
- materiality;
- conclusion change.

Quebra de SLA gera issue/escalonamento operacional.

**Resultado:** PASS.

---

## 22. AR-F4-R20 — compatibilidade com referências metodológicas

A arquitetura é compatível com princípios externos revisados:

- atualização individualizada e baseada em necessidade/impacto;
- surveillance proporcional;
- living evidence reservada a contextos adequados;
- frequência/triggers explicitados prospectivamente;
- viabilidade considerada sem confundir capacidade com validade.

Nenhuma referência foi convertida em número universal.

**Resultado:** PASS.

---

## 23. Estado pós-gate

| Componente | Estado |
|---|---|
| perfil científico/decisório | PASS |
| perfil operacional | PASS |
| score agregado | REJECTED |
| taxonomia R0–R3 | REJECTED |
| output M0–M3 | PASS |
| M3 recommendation | PASS como recomendação |
| M3 operacional | BLOCKED |
| cadence sem números | READY_FOR_SPECIFICATION |
| threshold classes | READY_FOR_SPECIFICATION |
| SLA semantics | READY_FOR_SPECIFICATION |
| priority classes | NOT_YET_DEFINED |
| migration nova | NOT_AUTHORIZED |

---

## 24. Decisão

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

O perfil pode agora ser usado como entrada normativa para a política temporal.

---

## 25. Próximo passo exato

> **Definir a Política Transversal de Cadence e Thresholds Temporais, usando o Documento 16 como matriz de necessidade/viabilidade, sem ainda fixar um calendário universal e sem alterar migration 027.**

A política deverá separar explicitamente:

1. cadence de busca/vigilância;
2. event-driven surveillance;
3. cadence de reassessment de profile/policy;
4. atraso operacional;
5. thresholds temporais para escalation;
6. relação com source latency.

Somente depois:

> definir classes e relógios de SLA.
