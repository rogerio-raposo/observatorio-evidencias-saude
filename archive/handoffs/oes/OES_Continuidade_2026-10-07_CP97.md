# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — PASS Técnico do Controle Operacional Integrado da Fase 4

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP97  
**Checkpoint anterior:** CP96  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento técnico da migration 029 e do contrato operacional integrado

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_029 = PASS**

> **F4_OC_T01_T72 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada. A Fase 5 não foi iniciada.

## 2. Freshness Gate e reconciliação pós-CP96

Após a retomada, foi encontrado avanço pós-CP96 que não havia ficado visível de forma confiável na interface.

A reconciliação confirmou:

- migration 029 implementada;
- fixtures operacionais sintéticas criadas;
- suíte F4-OC criada;
- workflow S5 integrado;
- runs diagnósticas #145–#149;
- run canônica #150 verde;
- Documentos 27–29 atualizados;
- commits posteriores ao technical HEAD #150 são documentais.

O ponteiro ainda estava em CP96 e os documentos agregados ainda descreviam a migration 029 como não implementada.

Esse descompasso documental foi corrigido antes da criação deste checkpoint.

## 3. Migration 029

Arquivo:

`database/029_integrated_operational_control_contract.sql`

Escopo implementado:

1. `maintenance.update_triage`;
2. `maintenance.priority_assessment`;
3. `maintenance.priority_basis`;
4. `maintenance.escalation_case`;
5. `maintenance.escalation_reason`;
6. `maintenance.escalation_route`;
7. `maintenance.sla_calendar_version`;
8. `maintenance.sla_rule`;
9. `maintenance.sla_instance`;
10. `maintenance.sla_pause`;
11. `maintenance.workflow_round`;
12. `maintenance.workflow_milestone`;
13. validators/guards/issue helpers/readiness/helpers derivados estritamente necessários.

## 4. Limites preservados

Migration 029 não implementa:

- durações SLA normativas;
- priority score;
- pesos numéricos;
- auto-escalation autoritativa;
- scheduler;
- notification channels;
- scientific propagation;
- assurance promotion;
- auto-publication;
- M3 readiness.

## 5. Fixtures

Arquivo:

`database/f4-operational-control-fixtures.sql`

As durações SLA presentes nas fixtures são:

> **TEST-ONLY / NON-NORMATIVE**

Não são defaults, policies ou recomendações OES.

## 6. Suíte F4-OC

Arquivo:

`database/f4-operational-control-tests.sql`

Resultado:

> **F4-OC-T01–T69 = PASS**

Cobertura inclui:

- triage;
- authority;
- priority;
- PriorityBasis;
- escalation;
- calendar/rule;
- SLA instances;
- pauses;
- workflow rounds;
- milestones/adapters;
- currentness/assurance invariants;
- M3 blocker.

## 7. T70 — idempotência

> **F4-OC-T70 = PASS**

Migration 029 foi reaplicada.

A suíte T01–T69 permaneceu verde.

## 8. T71 — rebuild

> **F4-OC-T71 = PASS**

Rebuild-from-zero through migration 029 executado com:

- baseline migrations;
- fixtures F2-B/S4/S5;
- F3 Products;
- Monitor;
- Alert;
- F4 update protocol;
- F4 operational control;
- testes correspondentes.

## 9. T72 — regressões

> **F4-OC-T72 = PASS**

Permaneceram verdes:

- F2-B;
- S4;
- S5;
- F3 Products;
- Evidence Monitor;
- Evidence Alert;
- F4 Update Protocol.

## 10. Compatibilidade do protocolo anterior

Após migration 029:

- F4-UP-T01–T63 = PASS;
- F4-UP-P01–P63 = PASS;
- migration 027 idempotency = PASS;
- migration 028 idempotency = PASS;
- migrations 021–026 idempotency = PASS.

A suíte histórica F4 foi isolada de premissas acidentais sobre o signal 3.

Essa correção foi de:

> **TEST ISOLATION**

e não mudança científica/arquitetural.

## 11. Run canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37580906483** (#150)

Technical HEAD:

`ae45918bb8cbf1ab929aec2e1af53f7239f75323`

Job:

`postgres-s5`

Conclusão:

> **success**

Artifact:

> **11464672034**

Nome:

`oes-s5-evidence-37580906483`

Digest:

`sha256:ec4546afc64fb5eb86b69d966905fc583cfbe43e4586abc922b57eb48e67a43c`

Expiração:

`2026-11-06T06:20:33Z`

## 12. Runs diagnósticas anteriores

### #145 — 37580322842

Erro de implementação:

- alias ambíguo em validação de triage/SLA.

### #146 — 37580398825

Executada antes da correção correspondente.

Não canônica.

### #147 — 37580448414

Erro de setup de teste:

- T62 criou MaterialityAssessment potentially_material sem dimensão requerida.

### #148 — 37580616416

F4-OC passou, mas suíte antiga P revelou dependência acidental sobre signal 3 sem assessment.

Classificação:

> **TEST ISOLATION ERROR**

### #149 — 37580789193

Erro textual de delimitador PostgreSQL introduzido ao isolar testes.

Classificação:

> **TEST EDITING ERROR**

Nenhuma dessas runs é evidência de PASS.

## 13. Documento 29

Arquivo:

`docs/governance/29-resultado-validacao-controle-operacional-integrado.md`

Resultado:

> **PASS — migration 029 e contrato operacional integrado tecnicamente validados**

## 14. Documentos 27–28 pós-execução

Após a run #150:

- Documento 27 foi marcado tecnicamente validado;
- Documento 28 registrou execução do gate/migration;
- esses commits são documentais;
- não houve alteração de SQL após o technical HEAD `ae45918b...`.

Logo:

> a run #150 continua válida como evidência técnica canônica.

## 15. M3

Permanece:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

A migration 029 não remove:

- blocker;
- readiness requirement;
- necessidade de gate específico.

## 16. Invariantes preservadas

A infrastructure layer não:

- cria MaterialityAssessment automaticamente;
- cria UpdateDecision automaticamente;
- muda CurrencyState automaticamente;
- cria versão científica;
- cria MethodDecision automaticamente;
- fabrica ReviewRecord humano;
- promove assurance;
- publica;
- propaga ciência automaticamente.

## 17. Dívidas ainda abertas da Fase 4

Permanecem, entre outras:

- calibração normativa de SLA durations;
- calendários operacionais reais;
- configuração de SLA Rules reais;
- materialização física de UpdateRiskProfile;
- scheduler;
- notification channels;
- auto-escalation;
- propagation/re-baselining;
- M3 readiness;
- operação humana real;
- normalização mais especializada de transições M0–M3 quando necessário.

Nenhum desses blocos é iniciado automaticamente por este checkpoint.

## 18. Estado do repositório antes do checkpoint

HEAD imediatamente antes da criação do CP97:

`cfea9924b3cde1e0e71446ab21b237bd64c6eff2`

Mensagem:

`Log operational control technical PASS`

Após criação/ativação do CP97 haverá commits documentais adicionais de continuidade.

## 19. Próximo passo

> **Ainda não selecionado.**

A próxima retomada deverá:

1. executar Freshness Gate;
2. confirmar CP97;
3. escolher explicitamente qual dívida da Fase 4 será priorizada;
4. decidir o modo adequado conforme reversibilidade/impacto;
5. não iniciar Fase 5.

Não presumir que o próximo passo é SLA calibration, scheduler, notifications, propagation ou M3 readiness.

## 20. Disciplina de modo

Como o próximo bloco ainda não foi selecionado:

> **modo deve ser decidido somente depois de escolher a dívida.**

Arquitetura/metodologia difícil de reverter:

> modo alto.

Implementação mecânica já especificada:

> modo médio.

## 21. Regra de visibilidade

Durante blocos longos:

- emitir atualizações menores e frequentes;
- não deixar a interface sem estado visível por longos períodos;
- se houver perda de visibilidade, reconciliar pelo GitHub antes de continuar.

## 22. Regra de parada

Após ativação do CP97:

> **parar e aguardar instrução explícita do usuário.**

**Fim do CP97**
