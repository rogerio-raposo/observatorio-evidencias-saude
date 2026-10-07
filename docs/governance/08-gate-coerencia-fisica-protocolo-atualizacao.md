# 08 — Revisão Adversarial Física do Contrato de Dados do Protocolo de Atualização

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — migration 027 autorizada no escopo definido**  
**Objeto:** Documento 07 pós-hardening  
**Dependências:** Documentos 05–07; OES-P1; migrations 006, 021–026

---

## 1. Finalidade

Verificar se o Contrato de Dados v0.1 do Protocolo Transversal de Atualização pode ser implementado sem:

- duplicar entidades científicas;
- criar currentness paralelo;
- confundir maintenance level com state científico;
- permitir automação autoritativa indevida;
- quebrar Monitor/Alert;
- antecipar M3;
- introduzir propagação silenciosa;
- comprometer rebuild/idempotência.

---

## 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

O contrato está:

> **READY_FOR_MIGRATION_027**

com escopo estritamente limitado às estruturas e guards definidos no Documento 07.

Não está autorizado neste gate:

- threshold quantitativo;
- SLA numérico;
- scheduler;
- notification channel;
- auto-classification;
- auto-escalation;
- propagation;
- Monitor re-baselining;
- M3 readiness;
- remoção de blocker M3;
- alteração automática de conclusão científica;
- promoção de assurance.

---

## 3. AR-F4-D01 — maintenance_level existente × policy operacional

### Risco

`investigation.investigation_version.maintenance_level` já existe.

Criar outro campo de manutenção sem semântica distinta produziria duas fontes concorrentes.

### Decisão

A semântica fica separada:

- `investigation_version.maintenance_level` = decisão histórica de roteamento registrada naquela InvestigationVersion;
- `update_policy.effective_maintenance_level` = regime operacional efetivo do target versionado durante a vigência da policy.

Precedência operacional:

> quando houver UpdatePolicy ativa, ela define o regime operacional vigente; a InvestigationVersion histórica não é reescrita.

Ausência de UpdatePolicy:

> não altera retroativamente a InvestigationVersion; significa apenas que o target ainda não foi incorporado ao protocolo transversal da Fase 4.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 4. AR-F4-D02 — escopo do target

### Risco

Aplicar UpdatePolicy a Monitor/Alert criaria recursão:

- Monitor de Monitor;
- atualização de Alert como se Alert fosse síntese científica;
- duplicação de lifecycle/currency existentes.

### Decisão

No v0.1:

- ProductVersion evidence_monitor = proibida como target;
- ProductVersion evidence_alert = proibida como target;
- InvestigationVersion evidence_monitoring = proibida como target.

Targets válidos:

- ProductVersion científica;
- InvestigationVersion científica.

**Resultado:** PASS.

---

## 5. AR-F4-D03 — target histórico/superseded

### Risco

Uma policy nova poderia ser criada sobre versão já superseded.

### Decisão

INSERT de UpdatePolicy exige target EntityVersion atual.

Supersessão posterior do target:

- não reescreve a policy;
- não retargeteia silenciosamente;
- gera issue dinâmico;
- eventual manutenção da nova versão exige nova policy.

**Resultado:** PASS.

---

## 6. AR-F4-D04 — autoridade da policy

### Risco

Uma policy M2/M3 poderia ser criada por IA ou sistema e passar a reger o target.

### Decisão

UpdatePolicy é registro autoritativo.

No v0.1:

- system = proibido;
- ai_system = proibido;
- human_reviewer, human_expert ou owner = permitidos;
- rationale obrigatório.

IA poderá sugerir policy fora desse registro, mas não ativá-la.

**Resultado:** PASS.

---

## 7. AR-F4-D05 — transições M0–M3

O contrato preserva as transições consolidadas no Documento 05.

Permitido por supersessão da mesma policy/target:

- M0 → M1/M2;
- M1 → M0/M2;
- M2 → M1/M3;
- M3 → M2/M1/M0;
- revisão no mesmo M.

Não permitido diretamente:

- M0 → M3;
- M1 → M3;
- M2 → M0.

**Resultado:** PASS.

---

## 8. AR-F4-D06 — policy × Monitor

### Decisão

- M0 → sem Monitor governante;
- M1 → sem Monitor governante;
- M2 → Monitor governante obrigatório;
- M3 → Monitor governante obrigatório.

O Monitor precisa:

- ser evidence_monitor;
- apontar para o mesmo target;
- preservar target linkage imutável;
- não estar invalidated/archived.

Monitor superseded/pausado posteriormente deve aparecer em helper de issues, não ser automaticamente substituído.

**Resultado:** PASS.

---

## 9. AR-F4-D07 — signal taxonomy

A taxonomia agora possui mapeamento implementável e determinístico de:

`signal_type → signal_class + trigger_class`.

`other` permanece escape controlado com rationale obrigatório.

Isso evita deixar a classificação científica para código ad hoc da migration.

**Resultado:** PASS.

---

## 10. AR-F4-D08 — signal source provenance

### Decisões

- source locator = exatamente um;
- no máximo uma primary source;
- SearchHit só é aceito em contexto de Monitor governante;
- CandidateAssessment/EvidenceEvent/MonitorCycle precisam pertencer ao mesmo Monitor;
- Alert source precisa ter o mesmo target;
- cadence_due pode ser derivado da própria policy sem source externa;
- governance_demand pode existir sem source externa quando ator/rationale estiverem explícitos.

Após MaterialityAssessment:

> SignalSource fica selada.

**Resultado:** PASS.

---

## 11. AR-F4-D09 — duplicação com Monitor/Alert

UpdateSignal não substitui:

- EvidenceEvent;
- CandidateAssessment;
- Alert;
- MonitoringCycle.

Esses objetos podem ser sources do signal.

UpdateSignal representa:

> entrada transversal normalizada para decisão de atualização.

Não há duplicação semântica obrigatória.

**Resultado:** PASS.

---

## 12. AR-F4-D10 — materiality assessment

### Competência

MaterialityAssessment pode ser registrado por:

- ai_system;
- human_reviewer;
- human_expert.

Owner não é tratado como avaliador científico apenas pela função de governança.

### Signal operacional

Signal operacional não pode produzir:

`material_change_confirmed`

sem signal científico/currentness correspondente.

Pode produzir:

- no_material_change;
- potentially_material;
- validity_or_use_threat;
- insufficient_to_decide.

### Versionamento

- um assessment ativo por signal;
- correção por supersessão;
- dimensions seladas após decision.

**Resultado:** PASS.

---

## 13. AR-F4-D11 — proposal × authoritative

### Proposal

Pode ser criada por IA ou humano.

### Authoritative

Exige:

- actor não-AI;
- human_verified ou human_consensus;
- verifier humano;
- assessment referenciado também human_verified/human_consensus.

Consequência:

> assessment AI-only nunca produz efeito autoritativo por cadeia indireta.

**Resultado:** PASS.

---

## 14. AR-F4-D12 — uma decisão ativa por signal

A decisão pertence semanticamente ao UpdateSignal, mesmo quando MaterialityAssessment é supersedido.

Por isso o contrato duplica controladamente:

- update_signal_uuid;
- materiality_assessment_uuid.

Guard deverá verificar correspondência.

Exigir:

> no máximo um UpdateDecision ativo por UpdateSignal.

Novo decision pode referenciar assessment mais recente e superseder decision anterior do mesmo signal.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 15. AR-F4-D13 — currentness matrix

O contrato evita transições cientificamente incoerentes.

Exemplos bloqueados:

- material_change_confirmed → set_current;
- insufficient_to_decide → set_current;
- no_scientific_update → set_outdated.

`currentness_only` possui matriz explícita de outcome × currency_action.

`archived` não é produzido por UpdateDecision v0.1.

**Resultado:** PASS.

---

## 16. AR-F4-D14 — CurrencyState

### ProductVersion

Pode receber linkage de decisão autoritativa para CurrencyState resultante.

### InvestigationVersion

Não recebe CurrencyState.

### Cardinalidade

Um UpdateDecision aponta para no máximo um CurrencyState.

Um mesmo CurrencyState pode resolver múltiplos signals/decisions coerentes.

Isso evita criação artificial de CurrencyStates duplicados.

### Histórico

CurrencyState precisa estar active no momento do linkage.

Supersessão posterior normal:

> não invalida o linkage histórico.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 17. AR-F4-D15 — MonitorCycle × CurrencyState

Quando MonitoringCycle já tiver produzido CurrencyState:

- UpdateDecision pode reutilizar o mesmo CurrencyState;
- não deve criar estado duplicado;
- action/status precisam ser coerentes;
- contradição precisa ser rejeitada.

Cadeia desejada:

`cycle → signal → assessment → decision → currency state`.

**Resultado:** PASS.

---

## 18. AR-F4-D16 — provenance/dependency

Policy, signal, assessment, decision e CurrencyState não são EntityVersions.

Logo:

- não criar dependency_edge artificial para esses UUIDs;
- usar relações especializadas;
- `provenance.record.process_record_uuid` poderá referenciar UpdateDecision em versão científica futura.

Dependency edge permanece apenas entre EntityVersions.

**Resultado:** PASS.

---

## 19. AR-F4-D17 — resulting scientific version

A migration 027 não criará linkage de resulting ProductVersion/InvestigationVersion.

Motivo:

- a decisão inicia workflow;
- a versão científica pode surgir posteriormente;
- antecipar FK mutável dentro de UpdateDecision quebraria imutabilidade.

Linkage futuro será desenhado em bloco próprio após evidência operacional.

**Resultado:** PASS.

---

## 20. AR-F4-D18 — assurance

Nenhuma tabela ou trigger da migration 027:

- cria assurance_record;
- promove A0–A3;
- copia assurance;
- converte verification em assurance.

**Resultado:** PASS.

---

## 21. AR-F4-D19 — M3

A migration 027 poderá representar policy M3, mas:

> **não tornará M3 formalmente operacional.**

O blocker:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

deve continuar funcionando exatamente como antes.

Não será criado:

- m3_ready;
- living_enabled;
- global unblock;
- bypass de publication gate.

**Resultado:** PASS.

---

## 22. AR-F4-D20 — compatibilidade aditiva

Escopo físico autorizado:

### Novas tabelas

1. `maintenance.update_policy`;
2. `maintenance.update_signal`;
3. `maintenance.update_signal_source`;
4. `maintenance.materiality_assessment`;
5. `maintenance.materiality_dimension`;
6. `maintenance.update_decision`;
7. `maintenance.update_decision_currency_state`.

### Novas funções/guards/helpers

Somente funções necessárias para:

- consistência;
- imutabilidade;
- supersessão;
- sealing;
- issues/readiness;
- currentness linkage.

### Alterações em tabelas existentes

> **nenhuma ALTER TABLE de entidade científica é autorizada neste gate.**

Pode haver triggers de proteção sobre estruturas novas.

Não alterar migrations 006/021–026.

**Resultado:** PASS.

---

## 23. Test strategy obrigatório

A implementação deverá possuir bateria dedicada:

> **F4-UP-T01+**

e validar:

1. guards locais;
2. negative cases;
3. supersessão;
4. sealing;
5. policy target drift;
6. Monitor/Alert integration;
7. CurrencyState;
8. AI/human authority separation;
9. M3 blocker preservado;
10. idempotent re-apply da migration 027;
11. rebuild-from-zero through 027;
12. regressões F2-B/S4/S5;
13. regressões completas de Monitor/Alert.

---

## 24. Idempotência

A migration 027 deverá preferir:

- CREATE TABLE IF NOT EXISTS;
- CREATE INDEX IF NOT EXISTS;
- CREATE OR REPLACE FUNCTION;
- DROP TRIGGER IF EXISTS + CREATE TRIGGER.

Reaplicação deverá ser explicitamente testada.

---

## 25. Decisão do gate

> **PHASE_4_UPDATE_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **MIGRATION_027 = AUTHORIZED**

Escopo:

> somente o contrato transversal v0.1 definido no Documento 07 pós-hardening.

---

## 26. Próximo passo exato

> **Implementar database/027_transversal_update_protocol_contract.sql + fixtures F4-UP + testes de contrato; executar validação específica, idempotência, rebuild-through-027, regressões globais e Monitor/Alert antes de qualquer novo bloco conceitual.**

## 27. Correção pós-gate — MethodDecision física

Após o gate foi confirmada a existência de `investigation.method_decision` desde a migration 014.

Isso corrige uma premissa documental do Documento 07, mas **não altera a conclusão do gate nem a validade técnica da migration 027**, porque:

- a migration 027 não criou tabela concorrente de decisão metodológica;
- `maintenance.update_decision` representa decisão especializada de atualização/currentness;
- `investigation.method_decision` permanece decisão metodológica ligada à InvestigationVersion;
- não houve FK, trigger ou automação baseada na premissa incorreta.

Fronteira consolidada:

> UpdateDecision pode recomendar/autorizar reroteamento; MethodDecision registra a decisão metodológica correspondente quando o fluxo de reroteamento for efetivamente executado.

Linkage especializado entre ambas, se necessário, será definido em bloco posterior e não será inferido retroativamente.

