# 22 — Auditoria Retrospectiva da Fase 4 até CP93

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — hardening corretivo requerido antes de prioridade/escalation**  
**Objeto:** Documentos 05–21, migration 027, fixtures/testes F4-UP, workflow S5, CP89–CP93  
**Natureza:** auditoria retrospectiva; não inicia novo bloco funcional

---

## 1. Finalidade

Revisar retrospectivamente a Fase 4 porque parte relevante da execução não ficou observável ao usuário durante a conversa.

A auditoria verifica:

- aderência ao escopo transferido pela Fase 3;
- ordem arquitetura → gate → implementação → validação;
- coerência dos Documentos 05–21;
- correspondência contrato lógico × migration 027;
- correspondência plano de testes × suíte executada;
- integridade dinâmica;
- continuidade/checkpoints;
- limites ainda pendentes.

Nenhuma conclusão científica é alterada por esta auditoria.

---

## 2. Resultado executivo

A arquitetura da Fase 4 permanece válida.

Estados preservados:

> **PHASE_4_UPDATE_PROTOCOL_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

Entretanto:

> **PHASE_4_UPDATE_DATA_CONTRACT_VALIDATION = REVISE_FOR_AUDIT_HARDENING**

Motivo:

- o run técnico anterior é real e permanece evidência válida do que executou;
- porém a bateria `F4-UP-T01–T63` não espelha um a um a lista de 63 testes mínimos do Documento 07;
- foram identificados gaps de integridade dinâmica e de issue helpers;
- a documentação agregada contém resíduos históricos que podem induzir leitura incorreta.

Conclusão:

> **não avançar para prioridade/escalation antes do hardening corretivo e nova validação canônica.**

---

## 3. Aderência à sequência prevista

A sequência executada foi:

1. Fase 3 encerrada em CP88;
2. Fase 4 iniciada somente após autorização;
3. Documentos 05–06 — arquitetura conceitual + revisão adversarial;
4. Documento 07 — contrato lógico;
5. Documento 08 — gate físico;
6. migration 027;
7. fixtures + testes;
8. integração S5;
9. Documento 09 — resultado técnico;
10. Documentos 16–17 — perfis de risco;
11. correção MethodDecision;
12. Documentos 18–19 — cadence/thresholds temporais;
13. CP91/CP92 — reconciliação;
14. Documentos 20–21 — SLA;
15. CP93.

Resultado:

> **SEQUÊNCIA METODOLÓGICA = CONFORME**

---

## 4. Limites da Fase 3 preservados

A Fase 3 transferiu explicitamente para Fase 4:

- M3 transversal;
- thresholds;
- SLAs;
- auto-escalation;
- notificações;
- priorização transversal;
- living evidence;
- governança operacional transversal.

Até CP93:

- M3 continua bloqueado;
- não existem durações universais de SLA;
- não existe score global;
- não existe auto-escalation;
- não existem notification channels operacionais;
- não existe migration de prioridade/SLA;
- não houve início formal da Fase 5.

Resultado:

> **FRONTEIRA F3→F4 = PRESERVADA**

---

## 5. Coerência conceitual dos Documentos 05–21

Invariantes mantidos de forma consistente:

1. Signal não equivale a conclusão.
2. Alert não equivale a atualização científica.
3. Monitor não equivale a síntese.
4. CurrencyState continua sendo currentness de ProductVersion.
5. InvestigationVersion não recebe CurrencyState artificial.
6. Assurance é eixo separado.
7. IA não é registrada como human verification.
8. Decisão autoritativa de atualização exige fronteira humana.
9. Cadence vencida não produz outdated automaticamente.
10. SLA breach não produz estado científico.
11. M3 não reduz controles N3/N4.
12. Propagação futura abre impact assessment; não reescreve dependentes.
13. M3 formal permanece bloqueado.

Resultado:

> **COERÊNCIA CONCEITUAL = PASS**

---

## 6. MethodDecision

Foi cometido erro de inventário durante o desenvolvimento:

> `investigation.method_decision` foi inicialmente tratada como inexistente.

A auditoria confirma:

- a tabela existe desde migration 014;
- Documentos 07–09 já foram corrigidos;
- MethodDecision e UpdateDecision possuem competências distintas;
- migration 027 não dependeu da premissa incorreta;
- CP91/CP92 documentaram a reconciliação.

Resultado:

> **ERRO HISTÓRICO = CORRIGIDO / SEM IMPACTO TÉCNICO DEMONSTRADO**

---

## 7. Evidência técnica anterior

Run canônico:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37570978847**;
- HEAD: `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- job: `postgres-s5`;
- conclusão: **success**;
- artifact: **11460960487**;
- digest: `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`.

Depois desse HEAD não houve mudança em:

- migration 027;
- fixtures F4;
- testes F4;
- workflow S5;

até o início desta auditoria.

Logo:

> o PASS anterior não é falso; ele demonstra corretamente a suíte que foi executada.

---

## 8. Achado crítico A — plano de 63 requisitos × suíte T01–T63

O Documento 07, seção 34, lista 63 requisitos mínimos.

O arquivo `database/f4-update-protocol-tests.sql` também possui T01–T63.

Entretanto:

> **a numeração não corresponde requisito por requisito ao plano do Documento 07.**

A suíte executada contém:

- testes de persistência/fixtures;
- sanity checks;
- helpers;
- invariantes negativos importantes;
- regressões de não-criação de objetos;
- preservação do blocker M3.

Mas vários requisitos do plano não possuem teste negativo dedicado identificável.

Exemplos:

- unicidade de policy ativa por ProductVersion/InvestigationVersion;
- target não-current;
- issue após target superseded;
- matriz completa M0/M1/M2/M3 × cadence;
- InvestigationVersion evidence_monitoring rejeitada;
- signal sobre policy inativa;
- `other` com rationale;
- verification metadata de UpdateSignal;
- locator XOR de source;
- segunda primary source;
- SearchHit fora de Monitor;
- assessment sem primary quando exigida;
- supersessão de assessment;
- supersessão de decision;
- `insufficient_to_decide → set_current`;
- currency action/status mismatch;
- contradição cycle/decision.

Decisão corretiva:

> criar uma nova suíte `F4-UP-P01–P63` cuja numeração espelhe exatamente os itens 1–63 do plano do Documento 07.

A suíte histórica T01–T63 permanece preservada.

---

## 9. Achado crítico B — decisão após invalidation do signal

Migration 027 exige signal ativo ao criar MaterialityAssessment.

Entretanto, ao criar UpdateDecision:

- o assessment precisa estar ativo;
- signal e policy são carregados;
- mas não existe rejeição explícita se o UpdateSignal tiver sido invalidado depois do assessment.

Sequência hoje possível em princípio:

1. signal active;
2. assessment active;
3. signal invalidated;
4. tentativa de nova UpdateDecision.

Decisão:

> **UpdateDecision INSERT deve exigir UpdateSignal ativo.**

Isso é hardening de lifecycle, não mudança da arquitetura científica.

---

## 10. Achado crítico C — CurrencyState linkage após decision superseded

O linkage exige UpdateDecision autoritativa.

Não exige explicitamente:

> `record_status='active'`.

Assim, uma decisão autoritativa já superseded poderia receber linkage novo posteriormente.

Decisão:

> **novo linkage UpdateDecision→CurrencyState deve exigir decisão ativa.**

Linkages históricos já existentes continuam válidos após supersessão posterior.

---

## 11. Achado D — issue helpers incompletos

Documento 07 exige detecção dinâmica de:

- target superseded/invalidated;
- Monitor governante superseded/incompatível;
- source invalidada;
- Alert drift;
- ausência de primary quando exigida;
- active decision sobre assessment superseded;
- linkage CurrencyState incoerente historicamente.

A migration 027 implementa os quatro helpers, mas não cobre integralmente essa lista.

Hardening requerido:

### update_policy_issues

Além do status:

- revalidar tipo/target do Monitor;
- revalidar target match;
- revalidar regras M×Monitor quando aplicável.

### update_signal_issues

Além da primary source:

- revalidar source existence/status;
- revalidar Monitor ownership;
- revalidar Alert target;
- revalidar SearchHit monitor context.

### materiality_assessment_issues

Além de confirmed/threat:

- potentially_material exige potential/uncertain;
- no_material_change não pode conter confirmed/threat;
- sinal inválido/superseded deve ser sinalizado quando material para estado ativo.

### update_decision_issues

Além de assessment superseded:

- signal invalidated;
- policy/target drift quando aplicável;
- linkage CurrencyState deve ser auditado contra target e ação sem penalizar supersessão normal posterior do CurrencyState.

---

## 12. Achado E — materiality completeness

O trigger de UpdateDecision garante dimensões compatíveis antes de uma decisão.

Porém um MaterialityAssessment ativo pode permanecer incompleto antes disso sem helper sinalizando todos os casos.

Decisão:

> issue helper deve tornar explícita a incompletude do assessment ativo.

Não é necessário bloquear INSERT do assessment, porque dimensões são adicionadas depois.

---

## 13. Achado F — transições M0–M3

Documento 05 exige registrar:

- estado anterior;
- estado novo;
- data;
- ator;
- justificativa;
- evidência/condição motivadora;
- impacto esperado sobre cadence/governança.

Migration 027 representa:

- estado anterior/novo via policy supersession;
- data;
- ator;
- rationale;
- cadence/governance payloads.

Mas não exige de forma estruturada:

- evidência/condição motivadora;
- impacto esperado.

Classificação:

> **TRACEABILITY GAP — não blocker técnico imediato.**

Decisão:

- não adicionar nova tabela neste hardening apenas para esse item;
- tornar obrigatório no contrato/documentação que transições por supersessão registrem motivação e impacto em rationale/payload enquanto não houver estrutura especializada;
- reavaliar modelagem física no futuro bloco de policy/re-baselining.

---

## 14. Achado G — documentação agregada

### STATE.md

O topo aponta corretamente CP93, mas o corpo histórico contém frases como:

> “checkpoint vigente = CP88”

e vários “Próximo passo exato” antigos.

Decisão:

> preservar o histórico, mas rotulá-lo como snapshot histórico e adicionar advertência de leitura no topo.

### database/README.md

Ainda aponta perfis de risco como próxima etapa.

Decisão:

> atualizar para refletir o bloco corretivo e, depois dele, prioridade/escalation.

### Dependências de documentos

Documentos 16, 18 e 20 incluem em `Dependências` o documento posterior que os valida.

Isso é semanticamente circular como metadata.

Decisão:

- `Dependências` deve listar apenas pré-requisitos;
- adicionar `Validado por` para Documento 17/19/21.

---

## 15. Escopo corretivo autorizado pela auditoria

A auditoria recomenda um gate físico específico para autorizar:

1. migration 028 **somente de hardening da migration 027**;
2. UpdateDecision exigir signal ativo;
3. novo CurrencyState linkage exigir decision ativa;
4. ampliar os quatro issue helpers;
5. fortalecer rastreabilidade documental de transições M;
6. nova suíte P01–P63 espelhada no Documento 07;
7. integração da migration 028 e da suíte P no S5;
8. idempotência 028;
9. rebuild-through-028;
10. regressões globais;
11. limpeza documental;
12. novo checkpoint.

Não autoriza:

- prioridade;
- SLA físico;
- triage físico;
- scheduler;
- notification channels;
- auto-escalation;
- propagation;
- M3 readiness;
- números universais.

---

## 16. Critério para restaurar PASS técnico

Somente após:

- P01–P63 = PASS;
- T01–T63 histórico = PASS;
- migration 028 idempotente;
- rebuild-through-028 = PASS;
- F2-B/S4/S5 = PASS;
- Monitor/Alert regressões = PASS;
- blocker M3 preservado.

Então:

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING**

---

## 17. Próximo passo

> **Executar gate de coerência física corretivo antes de escrever migration 028.**
