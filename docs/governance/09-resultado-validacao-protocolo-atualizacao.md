# 09 — Resultado da Validação Técnica do Protocolo Transversal de Atualização v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS — contrato físico v0.1 validado**  
**Dependências:** Documentos 05–08; migration 027

---

## 1. Finalidade

Registrar o resultado técnico da primeira implementação física do Protocolo Transversal de Atualização da Fase 4.

O escopo validado corresponde exclusivamente ao Contrato de Dados v0.1 autorizado pelo Documento 08.

---

## 2. Artefatos implementados

### Migration

`database/027_transversal_update_protocol_contract.sql`

### Fixtures

`database/f4-update-protocol-fixtures.sql`

### Testes

`database/f4-update-protocol-tests.sql`

### Workflow

`.github/workflows/validate-s5.yml`

---

## 3. Estruturas validadas

Foram materializadas sete estruturas aditivas no schema `maintenance`:

1. `maintenance.update_policy`;
2. `maintenance.update_signal`;
3. `maintenance.update_signal_source`;
4. `maintenance.materiality_assessment`;
5. `maintenance.materiality_dimension`;
6. `maintenance.update_decision`;
7. `maintenance.update_decision_currency_state`.

Nenhuma entidade científica existente foi alterada por `ALTER TABLE`.

---

## 4. Semântica validada

A implementação demonstrou, no escopo v0.1:

- separação entre `investigation_version.maintenance_level` histórico e `update_policy.effective_maintenance_level` operacional;
- target XOR ProductVersion/InvestigationVersion;
- exclusão de Monitor/Alert como target da UpdatePolicy transversal;
- policy autoritativa somente por ator humano/owner;
- M0/M1 sem Monitor governante;
- M2/M3 com Monitor governante obrigatório;
- compatibilidade de target entre policy e Monitor;
- taxonomia determinística de UpdateSignal;
- separação entre signal científico/currentness e signal operacional;
- SearchHit aceito apenas quando pertencente ao Monitor governante;
- Alert aceito como source apenas quando target coincide;
- sealing de sources após MaterialityAssessment;
- MaterialityAssessment sem owner como proxy de expertise científica;
- signal operacional incapaz de confirmar, sozinho, mudança científica material;
- dimensions normalizadas e seladas após UpdateDecision;
- proposal de IA permitida;
- decisão autoritativa por IA bloqueada;
- decisão autoritativa exige assessment e decisão human-verified/human-consensus;
- um UpdateDecision ativo por signal;
- matriz estrita de materialidade × CurrencyState;
- InvestigationVersion sem CurrencyState artificial;
- compartilhamento rastreável do mesmo CurrencyState por múltiplos signals coerentes;
- reuso do CurrencyState já produzido por MonitoringCycle;
- ausência de criação automática de ProductVersion/InvestigationVersion;
- ausência de promotion de assurance;
- ausência de dependency edges artificiais para objetos operacionais;
- M3 representável, mas ainda formalmente bloqueado.

---

## 5. Bateria F4-UP

Resultado:

> **F4-UP-T01–T63 = PASS**

A bateria cobriu casos positivos e negativos, incluindo:

- integridade de policy;
- transitions M0–M3;
- authority boundary;
- signal taxonomy;
- source normalization;
- Monitor/Alert drift;
- sealing;
- materiality;
- decision authority;
- currentness matrix;
- CurrencyState linkage;
- imutabilidade;
- não criação de assurance/versionamento científico;
- preservação do blocker M3.

---

## 6. Idempotência

Resultado:

> **F4-UP-IDEM = PASS**

A migration 027 foi reaplicada com sucesso sem alterar a semântica persistida das fixtures F4.

---

## 7. Rebuild-from-zero

Resultado:

> **PASS**

O workflow reconstruiu o banco do zero através da migration 027, reaplicou fixtures/testes relevantes e preservou as regressões existentes.

---

## 8. Regressões

Permaneceram verdes:

- F2-B;
- PoC-S4;
- PoC-S5;
- Ficha de Evidência;
- Resposta N1;
- Evidence Scan N0;
- Síntese Rápida N3;
- Revisão N4;
- Mapa;
- Overview;
- Monitor;
- Alert;
- casos e gates já integrados ao S5.

Nenhuma regressão de Fase 3 foi detectada.

---

## 9. Validação canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37570978847**

Job:

> `postgres-s5`

Run conclusion:

> **success**

HEAD validado:

> `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`

Artifact:

> **11460960487**

Artifact name:

> `oes-s5-evidence-37570978847`

Digest:

> `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`

---

## 10. M3

A migration 027 não removeu o blocker:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

Foi validado simultaneamente que:

- UpdatePolicy M3 pode existir;
- Monitor M3 continua não publicável formalmente;
- nenhum `m3_ready`, bypass ou auto-unblock foi criado.

Estado:

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 11. Limites preservados

Este PASS não define nem autoriza:

- thresholds quantitativos;
- duração numérica de SLA;
- score de prioridade;
- scheduler;
- notification channel;
- auto-classification;
- auto-escalation;
- propagation automática;
- Monitor re-baselining;
- M3 readiness;
- auto-publication;
- auto-update científico.

---

## 12. Decisão

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_027 = PASS**

A baseline física v0.1 do protocolo transversal está validada para desenvolvimento/PoC.

Não constitui schema de produção congelado.

---

## 13. Próximo bloco recomendado

O próximo bloco da Fase 4 deve tratar:

> **política temporal e de prioridade**, antes de qualquer automação.

Ordem recomendada:

1. perfis de criticidade/volatilidade;
2. regras de cadence;
3. thresholds temporais;
4. relógios e classes de SLA;
5. priorização/escalonamento;
6. somente depois, M3 readiness e propagation/re-baselining.

Essa ordem evita transformar números arbitrários em comportamento automático sem modelo de risco.

---

## 14. Próximo passo exato

> **Definir a arquitetura transversal de perfis de risco operacional/científico que parametrizará cadence, thresholds, SLAs e prioridade, sem ainda fixar números universais nem implementar nova migration.**

## 15. Errata de inventário físico

Foi confirmado após esta validação que `investigation.method_decision` já existe desde a migration 014.

A correção não altera o PASS técnico da migration 027:

- nenhum teste ou guard dependia da inexistência de MethodDecision;
- UpdateDecision e MethodDecision possuem competências distintas;
- nenhuma estrutura científica ou metodológica existente foi sobrescrita;
- eventual integração entre reroute_method e MethodDecision permanece explícita e futura.

