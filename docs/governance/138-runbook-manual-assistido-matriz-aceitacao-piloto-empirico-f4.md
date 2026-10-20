# 138 — Runbook manual/assistido, matriz de aceitação e preservação do piloto empírico F4

**OES | 20 de outubro de 2026 (America/Recife) | CP182 | modo alto**  
**Estado do artefato:** `RUNBOOK_D0_SPECIFIED_WITH_EVIDENCE_GAPS`.  
**Escopo:** planejamento e documentação. Não é autorização para operação persistente, coleta factual, revisão científica independente, publicação autoritativa ou conclusão da Fase 4.

## 1. Continuidade, base e decisão

- Freshness Gate CP181/main no HEAD `148355f845d4c3307738b251924db43cd80c14a1`: `identical`, 0 ahead/behind. Ponteiro vigente CP181, handoff CP181, STATE.md, CHANGELOG.md, template e README confirmados.
- Fontes científicas/arquiteturais: Docs 04–07, 18, 27, 33–39, 135–137; 12 roteiros AT do Documento 137 são o escopo do runbook.
- Fontes da frente empírica: Docs 91–92 (preflight e agenda B1R1), 94–95 (primeiras PubMed/ClinicalTrials.gov), 104–110 (bloqueio de datastore, autorização sandbox e inventário Neon). Os materiais históricos não são reemitidos como autoridade vigente de execução.
- O titular esclareceu que **não pretende abandonar** o objetivo de medições reais após criar o Neon. A decisão deste CP é preservar o piloto como **pendência estratégica rastreável** e integrar sua preparação ao plano da Fase 4, sem antecipar novo epoch/horário, operação Neon ou qualquer dispensa de gate.
- Continuidade do Documento 135: D0 documentação/ensaio efêmero; D1 piloto persistente isolado; D2 operação autoritativa. Essas categorias não modificam os bloqueios existentes.

## 2. Objetivo e definição de sucesso

Orientar um **operador humano ou equipe assistida por IA** desde a identificação de um sinal até a decisão de manter, reavaliar ou atualizar uma evidência científica, sem confundir proposta, autoridade, execução técnica ou publicação. Separadamente, preservar o roteiro mínimo para viabilizar futuramente o **primeiro experimento empírico PubMed/ClinicalTrials.gov**.

O runbook só estará **documentalmente completo em D0** se cada etapa tiver: entrada identificável, responsável admissível, prova requerida, decisão explícita, estado resultante permitido, ação proibida e regra de STOP. A suficiência científica real, segurança operacional, restauração, horários normativos e controle de acesso dependem de avaliações específicas, não do texto.

## 3. Procedimento de atualização manual/assistida — v0.1, sem execução

### R0 — Identificação do objeto e autoridade

**Entrada:** ProductVersion ou InvestigationVersion existente, identidade da entidade, versão vigente, UpdatePolicy aplicável, nível N, assurance A, regime M0–M3, status editorial e CurrencyState se for ProductVersion.

**Responsável:** operador de preparação documenta; decisões substantivas só podem ser assinadas pelo papel humano admitido no contrato. IA pode auxiliar na extração e proposta sem personificar outro ator.

**Prova:** referências/versões, hashes/artefatos quando disponíveis, datas e escopo metodológico da pergunta; authority e eventuais conflitos.

**STOP:** target/policy ambíguos, credenciais/fonte não autorizadas, versão superseded não conciliada, authority ausente; nunca fabricar garantia A3 ou usar uma identidade de produto fictícia como objeto real.

### R1 — Detecção e registro de signal

**Entrada:** evento científico (estudo novo, correção, retratação, segurança, mudança de escopo) ou operacional (falha de ciclo, gap de cobertura, atraso); contexto e proveniência.

**Responsável:** assistente/operador pode **propor** o registro; a promoção autoritativa segue o contrato de triage e qualificação.

**Prova:** URI/ID de fonte quando permitido, data factual, relação com target versionado, cobertura observada e distinção `scientific_currentness` versus `operational`.

**STOP:** fonte incompleta não pode ser convertida em “nenhuma evidência nova”; um novo ID em PubMed/ClinicalTrials.gov não pode ser rotulado como mudança material automaticamente.

### R2 — Triage e deduplicação

**Entrada:** signal rastreável, comparação de duplicidades, avaliação de escopo e fonte.

**Responsável:** `accepted_for_materiality` pode ser encaminhado por owner ou humanos qualificados como roteamento conservador; `duplicate_or_already_covered` exige ator humano e linkage concreto; `invalid_signal`/`out_of_scope` científico autoritativo exige `human_reviewer` ou `human_expert`. IA apenas propõe quando apropriado.

**Prova:** disposição, vínculo à evidência/caso existente, justificativa, ator real e estado do signal; preservar registros históricos.

**STOP:** tentativa de invalidar scientific signal apenas por decisão da IA ou owner; duplicidade sem prova; status autoritativo inconsistente com signal `active/invalidated`.

### R3 — Avaliação de materialidade

**Entrada:** signal elegível, fontes preservadas, dados sobre benefício, dano, magnitude, precisão, certeza, aplicabilidade, validade, escopo e método.

**Responsável:** revisão científica `human_reviewer`/`human_expert` conforme o contrato; `owner` não atua como materiality assessor simplesmente por sua propriedade. IA fornece análise e contraexemplos como **proposta**.

**Prova:** avaliação argumentada, dimensões, conclusão limitada à evidência (`no_material_change`, `potentially_material`, `material_change_confirmed`, `validity_or_use_threat`, `insufficient_to_decide`), revisão e provenance.

**STOP:** dado insuficiente não vira “sem mudança material”; sinal operacional isolado não confirma mudança científica.

### R4 — Decisão sobre atualização e currentness

**Entrada:** MaterialityAssessment com authority coerente e target correto.

**Responsável:** decisão autoritativa nos limites da competência permitida; owner pode agir em governança operacional, mas decisão científica material exige revisão humana qualificada. A2 editorial não é aprovação científica independente.

**Saídas alternativas:** `no_scientific_update`, `observe`, `currentness_only`, `scientific_update_incremental`, `scientific_update_broad`, `reroute_method`, `suspend_current_use`, com `currency_action` coerente quando aplicável.

**Prova:** rationale, tipo de decisão, ator, verificação, ligação com assessment e com CurrencyState **somente** de ProductVersion.

**STOP:** `insufficient_to_decide → set_current`; `cadence_due → outdated`; Alert urgent → conclusão; alteração científica por mero evento operacional.

### R5 — Workflow científico e assurance

**Entrada:** decisão de atualizar/rerotear, profundidade N adequada e instâncias de revisão requeridas.

**Responsável:** equipe qualificada na produção científica, aprovação de governança pelo titular e revisão independente A3 quando exigida pelo Documento 04; N2 padrão pode usar A2 com disclosure, mas N2 de alta criticidade, N3 formal e N4 têm exigências distintas.

**Prova:** busca, appraisal, avaliação crítica, síntese, parecer/decisão humana **real**, verificação metodológica separada, publicação quando efetivamente autorizada.

**STOP:** nenhuma publicação, nova conclusão, A3 ou nova ProductVersion automática. Etapa de publicação não é satisfeita por milestone preparado ou verificação IA.

### R6 — Versionamento, propagação e re-baselining

**Entrada:** decisão científica efetiva e mudança aprovada em target versionado, ou correção estritamente editorial.

**Responsável:** papéis de ciência, produto, método e operação de acordo com a natureza da mudança.

**Prova:** old/new version, classes `editorial`/científicas apropriadas, provenance, dependentes, decisão própria de re-baselining; Monitor/UpdatePolicy/coverage/cadence/SLA antigos preservados.

**STOP:** retargeting in-place, copiar materiality/decision entre targets, herdar assurance, criar CurrencyState em InvestigationVersion ou supor que edição textual dispense todo versionamento.

### R7 — Monitor/Alert, follow-up e fechamento do caso

**Entrada:** transições de estado devidamente aprovadas e trilha de decisões, pendências, coverage gaps e SLA (sem números normativos não autorizados).

**Responsável:** operador pode registrar e encaminhar; owner pode decidir elementos operacionais em seu escopo; julgamentos científicos exigem pessoas qualificadas.

**Prova:** status do ciclo, Alert, pendências, comunicações com limitações, registro de data e causalidade, prazo de revisão quando legitimamente estabelecido.

**STOP:** M3, scheduler, notifications ou auto-escalation sem gate; nenhuma ausência de evidência inferida de fonte indisponível.

### R8 — Falhas, auditabilidade e reconciliação

**Entrada:** tentativa interrompida, decisão recusada, evidência incompleta, commit indeterminado ou divergência de integridade.

**Responsável:** operador registra incidente e suspende; decisão de reconciliação/restore fica sujeita a gates e autorização operacional específica.

**Prova:** último evento verificável, estado conhecido/unknown, hash e origem quando existentes, limite de confiabilidade da captura, quem interrompeu e por quê.

**STOP:** replay automático, SQL factual, afirmação de sucesso/rollback sem prova, recibo do mesmo runner usado como auditoria independente ou avanço com autoridade expirante/incerta.

## 4. Matriz de aceitação e evidências — 12 cenários CP181

A coluna “prova mínima” estabelece **o que seria exigido**, não algo coletado nesta revisão. Não existe avaliação end-to-end de nenhum cenário deste quadro.

| Caso | Decisão verificada | Prova mínima para futura aceitação | Oráculo de rejeição/STOP | Dependência externa | Execução neste CP |
|---|---|---|---|---|---|
| AT-01 | Materialidade não confirmada | Signal, fonte, appraisal documentado, assessor qualificado, decisão e CurrencyState quando aplicável | Nenhum novo ProductVersion; no_scientific_update não deriva de busca sem evidência suficiente | REQUIRES_QUALIFIED_SCIENTIFIC_ASSESSMENT | NOT_EXECUTED |
| AT-02 | Estudo potencialmente material; insuficiente | Fonte, lacunas de viés/certainty, pending assessment, decisão de manter em avaliação | Nenhum insufficient_to_decide→set_current ou no_scientific_update indevido | REQUIRES_QUALIFIED_SCIENTIFIC_ASSESSMENT | NOT_EXECUTED |
| AT-03 | Retratação ou ameaça à validade | Identificação de retratação, vínculo ao target, dimensão validity/harm, decisão/restrições de uso | Sem outdated ou suspensão por gatilho isolado; autoridade documentada | REQUIRES_QUALIFIED_SCIENTIFIC_ASSESSMENT | NOT_EXECUTED |
| AT-04 | Ciclo incompleto com zero hits | Registro de cobertura, fonte indisponível, lacuna, status de ciclo e reparo | Nenhum no_update_needed inferido de fonte incompleta | OPERATIONAL_GAP_AND_HUMAN_DECISION | NOT_EXECUTED |
| AT-05 | Duplicação e invalid_signal | Links de duplicidade; rationale; identidades e qualificações de atores; estado active/invalidated consistente | Duplicata não apaga histórico; invalid_signal científico não é decidido por owner/IA | QUALIFIED_REVIEWER_FOR_INVALID_SIGNAL | NOT_EXECUTED |
| AT-06 | Alert urgente e atraso | Alert e eventual signal vinculados, relógios separados, justification de priority/escalation | Sem transição automática currentness, conclusão, numeric SLA ou auto-escalation | HUMAN_SCOPE_SPECIFIC_PRIORITY | NOT_EXECUTED |
| AT-07 | Versionamento com dependentes | Old/new ProductVersion, lineage, policy/Monitor antiga, dispositions de rebaseline, novo signal downstream | Sem retarget in-place, herança automática de assurance ou conclusão downstream | SCIENTIFIC_REVIEW_AND_PRODUCT_GATES | NOT_EXECUTED |
| AT-08 | InvestigationVersion sem produto | Version lineage de Investigation/Question, source e decisão no target correto | Nenhuma CurrencyState ou ProductVersion inventada | QUALIFIED_SCOPE_DECISION | NOT_EXECUTED |
| AT-09 | Assurance N/A e alta criticidade | Nível N, garantia A vigente, finalidade, disclosure, expert review efetivo quando requerido | Não fabricar A3/parecer independente; N2 padrão A2 não substitui alto risco | REAL_EXPERT_REVIEW_WHEN_REQUIRED | NOT_EXECUTED |
| AT-10 | Interrupção com execução incerta | Attempt/receipts possíveis, estado indeterminado, eventual pós-condição verificável, registro de incidente | Sem sucesso ou rollback presumido e sem replay/reconciliação automática | FAIL_CLOSED_OPERATIONAL_GATES | NOT_EXECUTED |
| AT-11 | Readiness temporal insuficiente | N1/N2 Doc 48/50, status B1R1, lacunas de fonte/série/autoridade | Sem cadence/SLA normativos, restart B1R1 ou retrofato | NEW_TEMPORAL_AUTHORITY_REQUIRED | NOT_EXECUTED |
| AT-12 | Correção editorial | Diferença textual, justificativa de não alteração científica, política de versão, aprovação editorial | Sem reescrita silenciosa ou mudança automática de CurrencyState | EDITORIAL_POLICY_AND_SCOPE_REVIEW | NOT_EXECUTED |

**Resultado da matriz:** `12/12_SPECIFIED; 0/12_END_TO_END_EXECUTED; 0_HUMAN_EXPERT_REVIEWS`. Não afirmar testes PASS. A coerência dos roteiros do Documento 137 já foi revisada **apenas textualmente**, com ressalvas AT-05, AT-09 e AT-12.

## 5. Modelo de ficha de evidência de aceitação — uso futuro

```text
case_id: AT-__
execution_kind: NOT_RUN | DOCUMENTARY_SIMULATION | SYNTHETIC_TECHNICAL | REAL_PILOT
protocol_ref: Documento 138 / revisão versionada
target_type_and_version: ...
policy_maintenance_level: ...
source_provenance_and_coverage: ...
signal_type_and_class: ...
triage_disposition_and_real_actor: ...
materiality_outcome_rationale_and_qualified_actor: ...
update_decision_and_currency_action: ...
product_or_investigation_version_disposition: ...
monitor_alert_dependency_disposition: ...
assurance_level_and_genuine_human_review: ...
expected_invariants: ...
forbidden_transitions_checked: ...
evidence_artifact_refs_and_hashes: ...
limitations_and_missing_evidence: ...
result: NOT_EXECUTED | PASS_DOCUMENTARY_ONLY | REVISE | FAIL | INDETERMINATE
reviewer_identity_scope_and_date: ...
```

Nenhum formulário preenchido ou assinatura humana é gerado neste CP. `PASS_DOCUMENTARY_ONLY` não pode ser reutilizado como PASS científico, operacional ou de CI.

## 6. Frente estratégica preservada: primeiro piloto empírico PubMed/ClinicalTrials.gov

### 6.1 Por que permanece no planejamento da Fase 4

Os materiais da primeira PubMed (Doc 94) e primeira ClinicalTrials.gov (Doc 95) estão **PREPARED_ONLY / NOT_EXECUTED**. O live preflight do B1R1 não ocorreu; o epoch expirou `EXPIRED_NOT_EXECUTED` ao fechar a janela de 19/10/2026, 09:00 -03 (Docs 91 e 110). Portanto, a frente foi **interrompida em sua instância temporal**, não cientificamente cancelada.

A existência do sandbox Neon Free `oes-sandbox` na região `aws-sa-east-1`, com SELECT observado em 19/10, demonstra acesso de leitura naquela ocasião, **não** capacidade operacional factual, restore, ledger, schema ou autorização de nova coleta. O nome `production` da branch do provedor não equivale a produção OES.

**Decisão CP182 — nível de planejamento:** `F4_EMPIRICAL_FIRST_MEASUREMENTS = STRATEGIC_PENDING_WITH_BLOCKERS`; `B1R1 = EXPIRED_NOT_EXECUTED`; `NEW_EPOCH = NOT_AUTHORIZED`; `NEON_FACTUAL_WRITES = NOT_AUTHORIZED`.

### 6.2 Relação com o trabalho científico-funcional

Existem **duas frentes paralelas de planejamento**, não duas execuções aprovadas:
- **SF-D0:** finalizar runbook, verificar sua coerência, manter pendências de julgamento científico e definir limite de eventual encerramento apenas documental.
- **EMP-D1:** construir um pacote de decisão de **mínima prontidão apropriada ao risco** para um experimento prospectivo finito de primeiras observações de fontes. Gate operacional e nova autorização continuam obrigatórios, mesmo que a documentação D0 esteja avançada. Não exigir produção completa onde não for relevante, mas **não relaxar** os controles originalmente exigidos para escrita persistente factual.

Um piloto de **consulta pública sem persistência factual no OES** seria um experimento de escopo diferente, não equivaleria ao objetivo dos Docs 94–95 e demandaria seu próprio desenho/autorização se apresentado futuramente.

### 6.3 Registro de dependências e condições de retomada

| ID | Trabalho ou gate | Situação vigente no planejamento |
|---|---|---|
| PILOT-01 | Preservação e autoridade do escopo | PRESERVED_HISTORICAL_NOT_REACTIVATABLE |
| PILOT-02 | Banco persistente e esquema funcional | BLOCKED_FOR_FACTUAL_PERSISTENCE |
| PILOT-03 | Acesso seguro e auditabilidade | NOT_READY |
| PILOT-04 | Backup, artifacts e recuperação | BLOCKED |
| PILOT-05 | Executor, relógios e contingência | NOT_AUTHORIZED |
| PILOT-06 | Primeira medida PubMed | PENDING_NEW_EPOCH |
| PILOT-07 | Primeira medida ClinicalTrials.gov | PENDING_NEW_EPOCH |
| PILOT-08 | Governança científica pós-coleta | HUMAN_REVIEW_PENDING |
| PILOT-09 | Custo e decisão do titular | OWNER_DECISION_REQUIRED |

### PILOT-01 — Preservação e autoridade do escopo

- **Fontes:** Docs 91, 94–95, 104, 110.
- **Evidência canônica:** Preflight B1R1 e primeiras Opportunities históricas foram preparados mas não executados; B1R1 expirou.
- **Estado:** `PRESERVED_HISTORICAL_NOT_REACTIVATABLE`.
- **Próximo requisito e critério de prova:** Abrir proposta separada de novo epoch futuro com novas janelas, congelamento de artefatos e aprovação expressa; B1R1 imutável.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-02 — Banco persistente e esquema funcional

- **Fontes:** Doc 110, ODB-02/05/06, Política 30.
- **Evidência canônica:** Neon Free existente e SELECT histórico PASS; esquema OES vazio naquele inventário; 36 migrations UNREVIEWED.
- **Estado:** `BLOCKED_FOR_FACTUAL_PERSISTENCE`.
- **Próximo requisito e critério de prova:** Identificar sequência mínima correta, revisar migrations/ledger e pós-condições conforme gates aplicáveis; execução Neon requer nova autorização.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-03 — Acesso seguro e auditabilidade

- **Fontes:** BRG-03, Docs 131–135, ODB-03/09/11.
- **Evidência canônica:** Roles administrativas/owner, TLS/auditoria não comprovados; hash chain local não independente.
- **Estado:** `NOT_READY`.
- **Próximo requisito e critério de prova:** Definir requisitos mínimos observáveis de credenciais/TLS/segregação e trilha independente, com revisão especializada; não dar acesso admin a executor factual.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-04 — Backup, artifacts e recuperação

- **Fontes:** Docs 104–107/110, ODB-07/08.
- **Evidência canônica:** Backup independente e restore não configurados; artifacts externos sem durabilidade validada.
- **Estado:** `BLOCKED`.
- **Próximo requisito e critério de prova:** Prova de retenção, integridade, backup externo e restore relevante ao escopo factual antes de persistir medições; registrar responsável e custos.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-05 — Executor, relógios e contingência

- **Fontes:** Docs 88–95/110, ODB-09/10/12.
- **Evidência canônica:** Preflight factual B1R1 não executado; nenhum executor factual autorizado; CI sintética não substitui base operacional.
- **Estado:** `NOT_AUTHORIZED`.
- **Próximo requisito e critério de prova:** Desenhar executor com FAIL CLOSED, prova de relógio e janela futura, status partial/failed/indeterminate, operator approval e validação read-only antes de qualquer request.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-06 — Primeira medida PubMed

- **Fontes:** Doc 94.
- **Evidência canônica:** Pacote histórico READY, source query NOT_EXECUTED, MeasurementEvent NOT_CREATED.
- **Estado:** `PENDING_NEW_EPOCH`.
- **Próximo requisito e critério de prova:** Adaptar request/identidade de fonte congelada e oportunidade futura; somente após novo preflight PASS e activation autorizada, documentar request, resposta, timepoints e dados mínimos verdadeiros.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-07 — Primeira medida ClinicalTrials.gov

- **Fontes:** Doc 95.
- **Evidência canônica:** Pacote histórico READY, source query NOT_EXECUTED, MeasurementEvent NOT_CREATED.
- **Estado:** `PENDING_NEW_EPOCH`.
- **Próximo requisito e critério de prova:** Adaptar paginação, cursor, falhas parciais, schema drift e primeira baseline própria; somente após nova autoridade e janela válida.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-08 — Governança científica pós-coleta

- **Fontes:** Docs 04–07, 94–95.
- **Evidência canônica:** Identificador novo no epoch não é materialidade científica.
- **Estado:** `HUMAN_REVIEW_PENDING`.
- **Próximo requisito e critério de prova:** Submeter resultados ao triage/materiality/UpdateDecision, sem inferir conclusão a partir de contagem ou novos IDs.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.

### PILOT-09 — Custo e decisão do titular

- **Fontes:** Doc 107, Doc 110, BRG-09.
- **Evidência canônica:** Autorização histórica restrita a sandbox Free synthetic-only / São Paulo; uso factual ou serviços externos não autorizados.
- **Estado:** `OWNER_DECISION_REQUIRED`.
- **Próximo requisito e critério de prova:** Conferir plano/limites, evitar upgrade e pagamentos implícitos; exigir decisão explícita antes de provisionar ou ativar coleta factual.
- **Autoridade para execução:** nenhuma ação operacional aprovada neste CP; novo ato específico de governança e gates pertinentes.


### 6.4 Ordem proposta para tornar o piloto novamente exequível — sem autorizar

**E0 — revisão de dependências e custo:** confrontar ODB-01–12/BRGs com o menor experimento capaz de registrar primeiras medições reais com segurança; registrar lacunas e responsáveis; confirmar limites da conta Free com o titular. **Somente planejamento por enquanto.**

**E1 — decisão de infraestrutura e provas:** mediante autorização separada, revisar/aplicar migrations pertinentes, hardening de least privilege, auditoria, ledger, armazenamento de artifacts e backup/restore **nos gates aplicáveis**, sem misturar CI synthetic com fatos reais. Qualquer SQL/branch/role no Neon exige **nova aprovação específica**, mesmo no projeto Free já autorizado para sandbox sintético.

**E2 — novo desenho temporal:** propor um **novo epoch**, schedule prospectivo e autoridade nova; revalidar PubMed query/interface, ClinicalTrials.gov query/interface, congelamento e checks. Não alterar B1R1 nem seus 14 horários, não usar os antigos UUIDs como se fossem novos.

**E3 — live preflight factual:** só após aprovação de E0–E2 e ambiente habilitado, executar read-only preflight no horário real; ativação exclusivamente com PASS e autorização expressa, sem backdate.

**E4 — primeiras medições futuras:** sob Opportunities futuras, PubMed primeiro e ClinicalTrials.gov conforme agenda aprovada; gerar fatos e SQL **a partir de responses realmente observadas**, registrar status completed/partial/failed/indeterminate e guardas específicos. A ordem e horários serão definidos posteriormente.

**E5 — interpretação científica:** distinguir `new_to_epoch` de materialidade e usar o protocolo científico-funcional R0–R8, com instâncias humanas qualificadas onde pertinentes; primeiro MeasurementEvent não autoriza cadence normativa.

**Critério de parada transversal:** qualquer falha de autorização, custo, segurança, ausência de restore exigível, discrepância de fonte, incerteza temporal ou estado de banco não reconciliado = `STOP / DO_NOT_MEASURE / DO_NOT_PERSIST`.

### 6.5 Condição explícita contra esquecimento do piloto

No planejamento da Fase 4, acompanhar dois eixos **sem misturar seus estados**:
1. `F4_SCIENTIFIC_FUNCTIONAL_DOCUMENTAL_READINESS` — runbook publicado D0, revisão especializada e eventual fechamento documental ainda pendentes.
2. `F4_EMPIRICAL_SOURCE_MEASUREMENT_READINESS` — primeira medição factual futura ainda não autorizada e sem infraestrutura aprovada.

**Regra de próximo checkpoint candidato:** antes de mais uma sequência extensa de testes PG18 ou documentação de segurança sem decisão dependente, preparar um **quadro mínimo de retomada do piloto** (gates eliminatórios, evidências existentes, provas faltantes, responsável, custo e trilho de aprovação). Isso não determina iniciar o piloto, nem torna a sua execução condição automaticamente nova e obrigatória de toda a Fase 4 sem deliberação explícita.

## 7. Limites, classificação de suficiência e gates

- **Resultado:** `RUNBOOK_D0_SPECIFIED_WITH_EVIDENCE_GAPS`; `ACCEPTANCE_EVIDENCE_MATRIX_SPECIFIED_12_OF_12`; `SCENARIO_EXECUTION_ZERO`; `EMPIRICAL_PILOT_STRATEGIC_PENDING`; `PHASE_4_DOCUMENTAL_CLOSURE_NOT_READY`.
- **G1–G6 (Docs 136–137):** matriz e runbook especificados; cenário executado, parecer especializado, calibração real, operação persistente, validação do runbook e decisão de fronteira continuam pendentes.
- **BRG-03/06/07/08/09** bloqueados; **BRG-04/05** históricos/sintéticos. **36 migrations UNREVIEWED**, 0 pós-condições aprovadas, 36 evidências 034–036 `NOT_COLLECTED`, 12 controles do modelo de roles não satisfeitos.
- Nenhum SQL/branch/migration/role Neon; nenhuma CI, script PG18, request target-specific PubMed/ClinicalTrials.gov, nova activation, tentativa de coleta, serviço pago ou expert review neste CP.
- B1R1 `EXPIRED_NOT_EXECUTED`; M3 `BLOCKED`; Fase 5 `NOT_STARTED`. Nenhum dado real inventado.

## 8. Deliberação e continuidade

**Entregas CP182:** runbook R0–R8, matriz AT-01–AT-12, modelo de ficha de aceitação e rastreador estratégico PILOT-01–PILOT-09, com cronologia e guardas para futuro novo epoch.

**Próximo checkpoint candidato, somente com novo `Prossiga` e Freshness Gate:** CP183 — **matriz de mínima prontidão e autoridade para a retomada empírica** (Neon factual versus experimento estritamente não persistente, sem confundí-los; controles ODB/BRG, evidência necessária, custo e nova autorização). Propor um processo de decisão proporcional em modo alto, **sem** executar Neon ou ativar epoch. Em paralelo, conservar o runbook científico-funcional para revisão posterior, sem declarar a Fase 4 concluída.

**STOP — após publicação, conciliação do ponteiro/STATE/CHANGELOG e confirmação do HEAD, pausar.**
